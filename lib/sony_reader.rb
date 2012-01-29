require "sony_reader/version"
require "digest/md5"
require "fileutils"
require "pathname"
require "sequel"
require "escape"
require "logger"
require "time"
require "find"
require "pp"

begin
  require "ruby-debug"
rescue LoadError
  # NOP: Ignore
end

module SonyReader
  # Works against this schema:
  #
  #   CREATE TABLE books (
  #       _id INTEGER PRIMARY KEY AUTOINCREMENT
  #     , title TEXT
  #     , author TEXT
  #     , kana_title TEXT
  #     , kana_author TEXT
  #     , title_key TEXT
  #     , author_key TEXT
  #     , source_id INTEGER
  #     , added_date INTEGER
  #     , modified_date INTEGER
  #     , reading_time INTEGER
  #     , purchased_date INTEGER
  #     , file_path TEXT
  #     , file_name TEXT
  #     , file_size INTEGER
  #     , thumbnail TEXT
  #     , mime_type TEXT
  #     , corrupted INTEGER
  #     , expiration_date INTEGER
  #     , prevent_delete INTEGER
  #     , sony_id TEXT
  #     , periodical_name TEXT
  #     , kana_periodical_name TEXT
  #     , periodical_name_key TEXT
  #     , publication_date INTEGER
  #     , conforms_to TEXT
  #     , description TEXT
  #     , logos TEXT);
  class Database
    def initialize(reader_path, db_path)
      @reader_path = Pathname.new(reader_path)
      @db = Sequel.connect("sqlite://#{db_path}", :logger => Logger.new(STDERR))
    end

    attr_reader :db, :reader_path

    COVER_EXTENSIONS = %w(jpg jpeg png).map(&:freeze).freeze

    def sync(path_to_collection)
      path_to_book_collection = Pathname.new(path_to_collection).expand_path
      expected_books = Hash.new
      path_to_book_collection.find do |pathname|
        next unless pathname.extname == ".epub"
        expected_books[pathname.basename.to_s.sub(/^\d+\s+/, "").sub(".epub", "")] = pathname
      end

      actual_books = book_titles.select_map(:title)
      missing_books = expected_books.reject {|title, _| actual_books.include?(title)}
      missing_books.each do |title, path_to_epub|
        author = path_to_epub.relative_path_from(path_to_book_collection).to_s.split("/").first
        extname = COVER_EXTENSIONS.detect {|extension| File.file?(path_to_epub.to_s.sub(".epub", ".#{extension}"))}
        path_to_thumbnail = path_to_epub.to_s.sub(".epub", ".#{extname}")

        add_book(title, author, path_to_epub.to_s, path_to_thumbnail.to_s)
      end

      book_collections = expected_books.select do |_, path_to_epub|
        path_to_epub.relative_path_from(path_to_book_collection).to_s.split("/").length == 3
      end.inject(Hash.new {|h,k| h[k] = []}) do |memo, (_, path_to_epub)|
        collection_name = path_to_epub.relative_path_from(path_to_book_collection).to_s.split("/")[1]
        memo[collection_name] << path_to_epub
        memo
      end

      collection_ids = book_collections.keys.inject(Hash.new) do |memo, collection_name|
        id = if collections.filter(:title => collection_name).select(:_id).any? then
               collections.filter(:title => collection_name).select(:_id).first.fetch(:_id)
             else
               collections.insert(:title => collection_name, :source_id => 0)
             end
        memo[collection_name] = id
        memo
      end

      collection_ids.each do |collection_name, id|
        collection_books.filter(:collection_id => id).delete
        book_collections[collection_name].sort_by(&:to_s).each do |path_to_epub|
          order, title = path_to_epub.to_s.split("/").last.sub(".epub", "").split(" ", 2)
          collection_books.insert(:collection_id => id, :added_order => order.to_i, :content_id => books.filter(:title => title).select(:_id).limit(1))
        end
      end
    end

    def add_book(title, author, path_to_epub, path_to_thumbnail)
      fingerprint = Digest::MD5.hexdigest("#{title}:#{author}")
      epub_path_on_device = reader_path + "Sony_Reader/media/books/#{fingerprint}.epub"

      db.transaction do
        epub_path_on_device.dirname.mkpath
        FileUtils::Verbose.cp(path_to_epub, epub_path_on_device)

        key = books.insert(:title         => title,
                           :author        => author,
                           :added_date    => Time.now.utc.to_i * 1000,
                           :modified_date => Time.now.utc.to_i * 1000,
                           :reading_time  => Time.parse("2011-01-01 00:00+0000").to_i * 1000,
                           :file_path     => epub_path_on_device.relative_path_from(reader_path).to_s,
                           :file_name     => epub_path_on_device.basename.to_s,
                           :file_size     => File.size(path_to_epub),
                           :thumbnail     => nil, # We need the primary key before we can set the path
                           :mime_type     => "application/epub+zip")

        thumb_path_on_device = reader_path + "Sony_Reader/database/cache/books/#{key}/thumbnail/main_thumbnail.jpg"
        thumb_path_on_device.dirname.mkpath

        cmd = Escape.shell_command(["convert", path_to_thumbnail.to_s, "-strip", "-resize", "754x584", thumb_path_on_device.to_s])
        STDERR.puts "EX: #{cmd}"
        system(cmd)
        books.filter(:_id => key).update(:thumbnail => thumb_path_on_device.relative_path_from(reader_path).to_s)
      end
    end

    def books
      db[:books]
    end

    def book_titles
      books.select(:title, :logos)
    end

    #     CREATE TABLE collection (_id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT,kana_title TEXT,source_id INTEGER,uuid TEXT);
    def collections
      db[:collection]
    end

    #     CREATE TABLE collections (_id INTEGER PRIMARY KEY AUTOINCREMENT,collection_id INTEGER,content_id INTEGER,added_order INTEGER);
    def collection_books
      db[:collections]
    end
  end

  # class Book < Sequel::Model
  # end
end
