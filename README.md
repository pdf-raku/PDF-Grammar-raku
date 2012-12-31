PDF-Grammar
===========

PDF documents as whole do not lend themselves to BNF style descriptions or
grammars. There are ares where these can be very useful including:

(*) The overall file structure (headers, objects, cross reference tables and
footers.

(*) The operands that make up content streams. These are used to markup
text and graphics.

PDF::Grammar is under construction as experimental perl6 grammars for parsing
and  validation of PDF compnents. It currently implements two grammars:

`PDF::Grammar::Body` - this  describes the file structure of PDF documents,
including headers, trailers, top-level objects and the cross reference table.

`PDF::Grammar::Content` - is also under construction as a description of the
text and graphics operators that are used to produce page layout.

PDF-Grammar has so far been tested against a limited sample of PDF documents
and test cases. Furthermore, it has so far only been built and tested against
Rakudo Star 2012-11.

It has so far just been used for validation purposes and has not been put to
use for any serious PDF processing. The grammar is still evolving and is likely
to change at short notice.

I have been working off the PDF 1.7 reference manual (http://wwwimages.adobe.com/www.adobe.com/content/dam/Adobe/en/devnet/pdf/pdfs/PDF32000_2008.pdf).

The only dependency is Rakudo Star. It runs on `perl6`. `ufo` is also to
locally create the Makefile. To run the tests, after building rakudo star
(https://github.com/rakudo/star/downloads - don't forget the final
`make install`):

    % git co git@github.com/dwarring/PDF-Grammar.git
    % cd PDF-Grammar
    % # to get perl6 and ufo
    % export PATH=~/src/rakudo-star-2012.11/install/bin:$PATH
    % ufo # Build Makefile
    % make
    % make test
    %
    % # ... alternatively...
    % PERL6LIB=lib prove -v -e 'perl6' t