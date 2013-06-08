use v6;

use PDF::Grammar;

grammar PDF::Grammar::PDF
    is PDF::Grammar {
    #
    # An experimental Perl6  grammar for describing the basic block
    # structure of PDF documents.
    #
    rule TOP {^<pdf>$}
    rule pdf {<pdf-header><.eol>[<body>+]'%%EOF'<.eol>?}

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token pdf-header {'%PDF-'$<version>=(\d'.'\d)}

    # xref section is optional - document could have a cross reference stream
    # quite likely if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule body {<indirect-obj>+<xref>**0..1<trailer>}
    rule indirect-obj { <integer> <integer> obj <object>* endobj }
    rule indirect-ref { <integer> <integer> R }

    # Object extensions:
    # modify <dict> - allow trailing stream anywhere
    rule object:sym<dict>  { <dict><stream>**0..1 }
    # add <indirect-ref> to the list of permitted objects
    rule object:sym<indirect-ref>  { <indirect-ref> }

    # stream parsing
    rule stream-head { stream<.eol>}
    token stream-tail {<.eol>? endstream <.ws-char>+}
    rule stream {<stream-head>.*?<stream-tail>}

    # cross reference table
    rule  xref         {xref<.eol><xref-section>+}
    token digits       {\d+}
    rule  xref-section {<object-first-num=.digits> <object-count=.digits><.eol><xref-entry>+}
    rule  xref-entry   {<byte-offset=.digits> <gen-number=.digits> <obj-status>' '?<.eol>}
    proto token obj-status {<...>}
    token obj-status:sym<free>  {f}
    token obj-status:sym<inuse> {n}

    # the trailer contains the position of the cross reference
    # table plus the file trailer dictionary
    rule trailer {
        trailer<.eol><dict><.eol>startxref<.eol><byte-offset=.digits><.eol>}

    # pdf-tail: special stand-alone regex for reverse matching
    # trailer information from the end of the file. Typically used
    # when reading last few KB of a PDF to locate root resources
    regex pdf-tail {.*<trailer>'%%EOF'<.eol>?$}
}
