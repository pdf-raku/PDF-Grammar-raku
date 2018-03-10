use v6;

use PDF::Grammar::COS;

#
# An experimental Perl6 grammar for scanning the basic outer block
# structure of FDF form data exchange files.
#
grammar PDF::Grammar::FDF
    is PDF::Grammar::COS {

    token doc-type {'FDF'}
}
