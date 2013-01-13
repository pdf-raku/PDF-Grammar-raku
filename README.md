PDF-Grammar
===========

Although PDF documents do not lend themselves to an overall BNF style grammar
description; there are areas which these can be put to use, including:

- The overall file structure (headers, objects, cross reference tables and footers.
- The operands that make up content streams and are used to markup text, forms,
images and graphical elements.

PDF::Grammar is under construction as an experimental/example Perl6 grammar
for parsing and validation of real-world PDF examples. It currently implements
three grammars:

`PDF::Grammar::Content` - is a description of the text and graphics operators that are used to produce page layout.

`PDF::Grammar::FDF` - this describes the file structure of FDF (Form Data)
exchange files.

`PDF::Grammar::PDF` - this  describes the file structure of PDF documents,
including headers, trailers, top-level objects and the cross reference table.

PDF-Grammar has so far been tested against a limited sample of PDF documents
and has not yet been put to use for any serious PDF processing. The grammar is still evolving and is likely to change.

I have been working off the PDF 1.7 reference manual (http://wwwimages.adobe.com/www.adobe.com/content/dam/Adobe/en/devnet/pdf/pdfs/PDF32000_2008.pdf). I've
been liberal, when needed, to handle real-world examples.

Rakudo Star
-----------
You'll first need to download and build Rakudo Star 2012.11 or better (https://github.com/rakudo/star/downloads - don't forget the final `make install`):

Ensure that `perl6` and `panda` are available on your path, e.g. :

    % export PATH=~/src/rakudo-star-2012.11/install/bin:$PATH

You can then use `panda` to test and install `PDF::Grammar`:

    % panda install PDF::Grammar

To try parsing some content:

    % perl6 -MPDF::Grammar::Content -e"say PDF::Grammar::Content.parse('(Hello, world\041) Tj')"
