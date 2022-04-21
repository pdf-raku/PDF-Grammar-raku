use PDF::Grammar::COS;

#| A Raku grammar for scaning the outer block structure of PDF files
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
