use v6;

use PDF::Grammar;

grammar PDF::Grammar::PDF is PDF::Grammar {
    #
    # An experimental Perl6  grammar for scanning the basic outer block
    # structure of PDF documents.
    #
    rule TOP {<pdf>}
    rule pdf {^<pdf_header><eol>[<content>+]'%%EOF'<eol>?$}

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token pdf_header {'%PDF-'$<version>=(\d'.'\d)}

    # xref section is optional - document could have a cross reference stream
    # quite likley if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule content {<indirect_object>+<xref>?<trailer>}
    rule indirect_object { <integer> <integer> obj <object>* endobj }

    rule object { <stream> | <indirect_reference> | <operand> }
    # override PDF::Grammar <array> and <dict> rules to include all objects
    rule array {\[ <object>* \]}
    rule dict {'<<' [<name> <object>]* '>>'}

    rule indirect_reference {<integer> <integer> R}

    # stream parsing
    rule stream_head {<dict> stream<eol>}
    token stream_tail {<eol>?endstream<ws_char>+}
    rule stream {<stream_head>.*?<stream_tail>}

    rule  xref {xref<eol><xref_section>+}
    token object_first_num{\d+}
    token object_count{\d+}
    rule  xref_section {<object_first_num>\x20<object_count><eol><xref_entry>+}
    rule  xref_entry {<byte_offset>\x20<generation_number>\x20<obj_status><eol>}
    token byte_offset {\d+}
    token generation_number {\d+}
    rule  obj_status {<obj_status_free>|<obj_status_inuse>}
    token obj_status_free {f}
    token obj_status_inuse {n}

    # the trailer contains the position of the cross reference
    # table plus the file trailer dictionary
    rule trailer {
        trailer<eol><dict><eol>startxref<eol>$<byte_offset>=(\d+)<eol>}

    # pdf_tail: special stand-alone regex for reverse matching
    # trailer information from the end of the file. Typically used
    # when reading last few KB of a PDF to locate trailer information
    regex pdf_tail {<trailer>'%%EOF'<eol>?$}

}
