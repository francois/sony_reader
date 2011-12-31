This is a proof-of-concept attempt working with Sony's PRS-T1 eReader database. This gem provides the lower-level layer: the plumbing on which other tools can be built.

Example
-------

Ensure you have ImageMagick's `convert` tool available on the path, and have installed this gem, then:

from the command line
=====================

    $ sreader PATH_TO_READER add --title="Book's Title" --author="Book's Author" --epub="path/to/epub" --cover="path/to-cover"


from Ruby (IRB works just fine)
===============================

    require "sony_reader"

    db = SonyReader::Database.new("/Volumes/READER", "/Volumes/READER/Sony_Reader/database/books.db")
    db.add_book("Book's Title", "Book's Author", "PATH/TO/EPUB", "PATH/TO/COVER")

Why?
----

When I attempted to install the Sony Reader software, it wanted to reboot my machine. I chose not to install the software and roll my own solution, especially after I noticed the use of SQLite as the database format.

License
-------

Copyright (C) 2011 François Beausoleil

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
