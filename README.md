PDF-Grammar-Simple
==================

Sample PDF Grammar for parsing non-linearized PDF's (perl6)

This is under construction as an example perl Grammar for tokenizing
simple PDF documents.

This has been thrown together over the last few days using Rakudo Star
2012-11. The tokens and capturing rules that comprise the grammar will
most likely change.

So far it has only been tested a against a very limited number of PDF
documents. It starts to creak and groan when processing PDFs over about
200K in size.

Works best with PDFs up to 1.5. May work for high versions if they haven't
been linearized (Web Optimized).

The only dependency is Rakudo Star. It use perl6, plus ufo to create the
Makefile. So to run the tests, following on from a build of rakudo star
(don't forget to complete the Rakudo build with 'make install':

    % git co git@github.com:dwarring/PDF-Grammar-Simple.git
    % cd /PDF-Grammar-Simple
    % # to get perl6 and ufo
    % export PATH=~/src/rakudo-star-2012.11/install/bin:$PATH
    % ufo # Build Makefile
    % make
    %
    % make Test
    % # ... alternatively...
    % PERL6LIB=lib prove -v -e 'perl6' t