require "sony_reader/version"
require "fileutils"
require "pathname"
require "sequel"
require "escape"
require "logger"
require "time"

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

    def add_book(title, author, path_to_epub, path_to_thumbnail)
      epub_path_on_device = reader_path + "Sony_Reader/media/books/#{Time.now.to_i}.epub"

      db.transaction do
        epub_path_on_device.dirname.mkpath
        FileUtils::Verbose.cp(path_to_epub, epub_path_on_device)

        key = books.insert(:title         => title,
                           :author        => author,
                           :added_date    => Time.now.utc.to_i,
                           :modified_date => Time.now.utc.to_i,
                           :reading_time  => Time.parse("2011-01-01 00:00+0000").to_i,
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
  end

  # class Book < Sequel::Model
  # end
end
