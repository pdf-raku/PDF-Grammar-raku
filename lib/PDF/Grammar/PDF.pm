use v6;

use PDF::Grammar::COS;

#
# An experimental Perl6 grammar for scanning the basic outer block
# structure of FDF form data exchange files.
#
grammar PDF::Grammar::PDF
    is PDF::Grammar::COS {

    token doc-type {'PDF'}

    # To support << /Linearized 1 /T <offset> .. >>
    # <offset> skips 'xref' \n <n> <m>
    # and starts reading from the first xref section
    # - <n> is zero
    # - <m> is derivable
    rule xref-first {.<xref-entry>+<xref-section>*}

}
