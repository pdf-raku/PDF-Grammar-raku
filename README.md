PDF-Grammar
===========

PDF::Grammar is under construction as experimental grammar parsing PDF
documents. I'm using this to experiment with Perl6 Grammars and learn more
about PDF internals.

So far, I've implemented PDF::Grammar::Body, which describes the outer
structure of a PDF document; headers, trailers, top-level objects and the
cross reference table.

PDF::Grammar::Content is also under construction as a description of the text
and graphics operators that are used to produce page layout.

PDF::Grammar has so far been tested against a limited sample of PDF documents
and test cases. Furthermore, it has so far only been built and tested against
Rakudo Star 2012-11.

It is not designed for reuse nor is it authoritative. If it survives at all,
the tokens and capturing rules that comprise it will most likely change
significantly. Having said that, I'm also open to any input or contributions.
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