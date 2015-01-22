use v6;

use PDF::Grammar;

grammar PDF::Grammar::PDF
    is PDF::Grammar {
    #
    # An experimental Perl6  grammar for describing the basic block
    # structure of PDF documents.
    #
    rule TOP {^<pdf>$}
    rule pdf {<header> [<body>+]'%%EOF' }

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token header {'%PDF-'$<version>=(\d'.'\d)}

    # xref section is optional - document could have a cross reference stream
    # quite likely if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule body    { <ind-obj>+ <xref>? <trailer>}
    rule ind-obj { <obj-num=.int> <gen-num=.int> obj <object> endobj }
    rule ind-ref { <obj-num=.int> <gen-num=.int> R }

    # Object extensions:
    # modify <dict> - allow trailing stream anywhere
    rule object:sym<dict>  { <dict> <stream>? }
    # add <indirect-ref> to the list of permitted objects
    rule object:sym<ind-ref>  { <ind-ref> }

    # stream parsing
    token stream-head  {<.ws>stream\n}
    token stream-tail  {\n? endstream <.ws-char>+}
    rule stream        {<stream-head>.*?<stream-tail> }

    # cross reference table
    rule  xref         { xref\n<xref-section>+ }
    rule  xref-section {<object-first-num=.int> <object-count=.int>\n<xref-entry>+}
    rule  xref-entry   {<byte-offset=.int> <gen-number=.int> <obj-status>' '?\n}
    proto token obj-status      {<...>}
    token obj-status:sym<free>  {f}
    token obj-status:sym<inuse> {n}

    # the trailer contains the position of the cross reference
    # table plus the file trailer dictionary
    token trailer {
        [trailer\n
         <dict>\n]?
        startxref\n
        <byte-offset=.int>\n
	[<!before ['%%EOF'\n?$]><.ws-char>]*
    }

    #== PDF::Core Support ==#

    # support for index loading
    # (1) read the last few bytes of a PDF, parse the 'startxref' directive
    # (2) seek to the indicated position in the PDF, load the xref, which may either be:
    #    a. an immediately cross reference table (see <xref> token)
    #    b. a cross reference stream, indirect object, which may occur anywhere in the PDF
    token postamble {
        .*?
        startxref\n
        <byte-offset=.int>\n
        '%%EOF'\n?
        $
    }

    # PDF reference 1.7 3.4.6 Object Streams
    # These occur as the content of objects of /Type /ObjStm
    # They consist of an index followed by a sequence of pdf objects
    rule object-stream-indice {
        <obj-num=.int> <byte-offset=.int>
    }
    rule object-stream-index {
        <object-stream-indice>+
    }

}
