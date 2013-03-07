use v6;

use PDF::Grammar;

grammar PDF::Grammar::PDF is PDF::Grammar {
    #
    # An experimental Perl6  grammar for describing the basic block
    # structure of PDF documents.
    #
    rule TOP {^<pdf>$}
    rule pdf {<pdf_header><.eol>[<body>+]'%%EOF'<.eol>?}

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token pdf_header {'%PDF-'$<version>=(\d'.'\d)}

    # xref section is optional - document could have a cross reference stream
    # quite likely if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule body {<indirect_obj>+<xref>?<trailer>}
    rule indirect_obj { <integer> <integer> obj <object>* endobj }
    rule indirect_ref { <integer> <integer> R }

    # Object extensions:
    # modify <dict> - allow trailing stream anywhere
    rule object:sym<dict>  { <dict><stream>? }
    # add <indrect_ref> to the list of permitted objects
    rule object:sym<indirect_ref>  { <indirect_ref> }

    # stream parsing
    rule stream_head { stream<.eol>}
    token stream_tail {<.eol>?endstream<.ws_char>+}
    rule stream {<stream_head>.*?<stream_tail>}

    # cross reference table
    rule  xref {xref<.eol><xref_section>+}
    token object_first_num{\d+}
    token object_count{\d+}
    rule  xref_section {<object_first_num> <object_count><.eol><xref_entry>+}
    rule  xref_entry {<byte_offset> <generation_number> <obj_status>' '?<.eol>}
    token byte_offset {\d+}
    token generation_number {\d+}
    rule  obj_status {<obj_status_free>|<obj_status_inuse>}
    token obj_status_free {f}
    token obj_status_inuse {n}

    # the trailer contains the position of the cross reference
    # table plus the file trailer dictionary
    rule trailer {
        trailer<.eol><dict><eol>startxref<.eol>$<byte_offset>=(\d+)<.eol>}

    # pdf_tail: special stand-alone regex for reverse matching
    # trailer information from the end of the file. Typically used
    # when reading last few KB of a PDF to locate root resources
    regex pdf_tail {<trailer>'%%EOF'<.eol>?$}
}
