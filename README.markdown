This is an proof-of-concept attempt at preventing rootkits from Sony.

When I attempted to install the Sony Reader software, it wanted to reboot my machine. I chose not to install the software and roll my own solution, especially after I noticed the use of SQLite as the database format.

This gem will be a lower-layer, accessible from higher-level GUIs and tools.

Example
-------

Ensure you have ImageMagick's `convert` tool available on the path, and have installed this gem, then from Ruby (IRB works just fine):

    require "sony_reader"

    db = SonyReader::Database.new("/Volumes/READER", "/Volumes/READER/Sony_Reader/database/books.db")
    db.add_book("Book's Title", "Book's Author", "PATH/TO/EPUB", "PATH/TO/COVER")
