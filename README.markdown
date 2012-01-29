This is a proof-of-concept attempt working with Sony's PRS-T1 eReader database. This gem provides the lower-level layer: the plumbing on which other tools can be built.

Example
-------

Ensure you have ImageMagick's `convert` tool available on the path, and have installed this gem, then:

from the command line
=====================

If you have a collection of books, you can do sync them all up if they are in the proper hierarchy using:

    $ sreader PATH_TO_READER sync PATH_TO_BOOK_COLLECTION

The book collection is an on-disk database holding directories of authors, and books or series underneath. Lay out your directory structure like this:

    PATH_TO_BOOK_COLLECTION/
      David Eddings/
        The Belgariad/
          01 Pawn of Prophecy.epub
          01 Pawn of Prophecy.jpeg
          02 Queen of Sorcery.epub
          02 Queen of Sorcery.png
          ...

        # Individual books can be added as well
        The Redemption of Althalus.epub
        The Redemption of Althalus.jpg

      Terry Goodkind/
        Sword of Truth/
          01 Wizard's First Rule.epub
          01 Wizard's First Rule.jpg
          02 Stone of Tears.epub
          02 Stone of Tears.jpg
          ...

`sreader` will only add books and collections which are missing. It does not yet handle data deletion. To delete anything, use your reader's UI.

Cover images must have one of three extensions: jpg, jpeg or png.

You can add single books to your reader using:

    $ sreader PATH_TO_READER add --title="Book's Title" --author="Book's Author" --epub="path/to/epub" --cover="path/to-cover"

This will not manage the collections for you.


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
