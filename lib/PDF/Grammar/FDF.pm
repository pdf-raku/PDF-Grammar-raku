use v6;

use PDF::Grammar::Doc;

#
# An experimental Perl6 grammar for scanning the basic outer block
# structure of FDF form data exchange files.
#
grammar PDF::Grammar::FDF
    is PDF::Grammar::Doc {

    token doc-type {:i 'fdf' }
}
