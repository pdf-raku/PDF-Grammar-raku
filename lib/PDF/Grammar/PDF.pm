use v6;

use PDF::Grammar;

grammar PDF::Grammar::PDF
    is PDF::Grammar {
    #
    # An experimental Perl6  grammar for describing the basic block
    # structure of PDF documents.
    #
    rule TOP {^<pdf>$}
    rule pdf {<pdf-header> [<body>+]'%%EOF' }

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token pdf-header {'%PDF-'$<version>=(\d'.'\d)}

    # xref section is optional - document could have a cross reference stream
    # quite likely if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule body         { <indirect-obj>+ <xref>? <trailer>}
    rule indirect-obj { <obj-num=.integer> <gen-num=.integer> obj <object>* endobj }
    rule indirect-ref { <obj-num=.integer> <gen-num=.integer> R }

    # Object extensions:
    # modify <dict> - allow trailing stream anywhere
    rule object:sym<dict>  { <dict> <stream>? }
    # add <indirect-ref> to the list of permitted objects
    rule object:sym<indirect-ref>  { <indirect-ref> }

    # stream parsing
    token stream-head  {<.ws>stream\n}
    token stream-tail  {\n? endstream <.ws-char>+}
    rule stream        {<stream-head>.*?<stream-tail> }

    # cross reference table
    rule  xref         { xref\n<xref-section>+ }
    rule  xref-section {<object-first-num=.integer> <object-count=.integer>\n<xref-entry>+}
    rule  xref-entry   {<byte-offset=.integer> <gen-number=.integer> <obj-status>' '?\n}
    proto token obj-status      {<...>}
    token obj-status:sym<free>  {f}
    token obj-status:sym<inuse> {n}

    # the trailer contains the position of the cross reference
    # table plus the file trailer dictionary
    token trailer {
        trailer\n
        <dict>\n
        startxref\n
        <byte-offset=.integer>\n
	[<!before '%%EOF'><.ws-char>]*
    }

    # pdf-tail: special stand-alone regex for reverse matching
    # trailer information from the end of the file. Typically used
    # when reading last few KB of a PDF to locate root resources
    token pdf-tail {.*?<trailer>'%%EOF'\n?$}
}
