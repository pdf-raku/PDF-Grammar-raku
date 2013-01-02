PDF-Grammar
===========

Although PDF documents as do not lend themselves to an overall BNF style
grammar description; there are areas which these can be put to use,
including:

- The overall file structure (headers, objects, cross reference tables and footers.

- The operands that make up content streams and are used to markup text and graphics.

PDF::Grammar is an experimental example Perl6 grammar for parsing
and validation of PDF components. It currently implements two grammars:

`PDF::Grammar::Body` - this  describes the file structure of PDF documents,
including headers, trailers, top-level objects and the cross reference table.

`PDF::Grammar::Content` - is a description of the text and graphics operators that are used to produce page layout.

PDF-Grammar has so far been tested against a limited sample of PDF documents
and test cases and has not yet been put to use for any serious PDF processing. The grammar is still evolving and is likely to change at short notice.

I have been working off the PDF 1.7 reference manual (http://wwwimages.adobe.com/www.adobe.com/content/dam/Adobe/en/devnet/pdf/pdfs/PDF32000_2008.pdf).

Rakudo Star
-----------
The test suite currently only runs on the Rakudo Star.

To run the tests; first, you'll need a built Rakudo Star 2012.11, or better
(https://github.com/rakudo/star/downloads - don't forget the final
`make install`):

    % git co git@github.com/dwarring/PDF-Grammar.git
    % cd PDF-Grammar
    % # to get perl6 and ufo on your path
    % export PATH=~/src/rakudo-star-2012.11/install/bin:$PATH
    % ufo # Build Makefile
    % make
    % make test
    %
    % # ... alternatively...
    % PERL6LIB=lib prove -v -e 'perl6' t

To try the parser:

    %  perl6 -Ilib -MPDF::Grammar::Content -e"say PDF::Grammar::Content.parse('(Hello, world\041) Tj')"

Niecza
------
I haven't tested this throughly, but the grammars do seem to run under Niecza,
e.g.:

    % ~/src/niecza-24/run/Niecza.exe -Ilib -e'use PDF::Grammar::Content; say PDF::Grammar::Content.parse("/F1 24 Tf 2 J 0 j .51 w 3.86 M [] 0 d");'