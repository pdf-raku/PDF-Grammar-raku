PDF-Grammar
===========

PDF::Grammar is an experimental perl6 grammar for basic tokenization
and block structure parsing of PDF documents.

This is a proof of concept to see if grammars can be reasonably constructed
to tokenize and validate real-world PDF documents. It has so far been tested
against a limited sample of PDF documents. Furthermore, it has so far only
been built and tested against Rakudo Star 2012-11.

If this grammar survives at all; the tokens and capturing rules that
comprise it will most likely change significantly.

The only dependency is Rakudo Star. It runs on `perl6`. `ufo` is also to
locally create the Makefile. To run the tests, after building rakudo star
(https://github.com/rakudo/star/downloads - don't forget the final
`make install`):

    % git co git@github.com:dwarring/PDF-Grammar.git
    % cd PDF-Grammar
    % # to get perl6 and ufo
    % export PATH=~/src/rakudo-star-2012.11/install/bin:$PATH
    % ufo # Build Makefile
    % make
    % make test
    %
    % # ... alternatively...
    % PERL6LIB=lib prove -v -e 'perl6' t