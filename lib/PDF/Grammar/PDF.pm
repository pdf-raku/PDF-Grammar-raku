use v6;

use PDF::Grammar;
use PDF::Grammar::Xref;

grammar PDF::Grammar::PDF is PDF::Grammar {
    #
    # An experimental Perl6  grammar for scanning the basic outer block
    # structure of PDF documents.
    #
    rule TOP {<pdf>}
    rule pdf {^<pdf_header><eol>[<content>+]'%%EOF'<eol>?$}

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token pdf_header {'%PDF-'(\d'.'\d)}

    # xref section is optional - document could have a cross reference stream
    # quite likley if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule content {<indirect_object>+<xref>?<trailer>}
    rule indirect_object { <integer> <integer> obj <object>* endobj }

    rule object { <stream> | <indirect_reference> | <operand> }
    # override PDF::Grammar <array> and <dict> rules to include all objects
    rule array {\[ <object>* \]}
    rule dict {'<<' [<name> <object>]* '>>'}

    rule indirect_reference {<integer> <integer> R}

    # stream parsing - efficiency matters here
    token stream_marker {stream<eol>}
    # Hmmm allow endstream .. anywhere?
    # Seems to be some chance of streams appearing where they're not
    # supposed to, e.g. nested in a subdictionary
    token endstream_marker {<eol>?endstream<ws_char>+}
    rule stream {<dict> <stream_marker>.*?<endstream_marker>}

    rule xref {<PDF::Grammar::Xref::xref>}

    # the trailer contains the position of the cross reference
    # table plus the file trailer dictionary
    rule trailer {
        trailer<eol><dict><eol>startxref<eol>(\d+)<eol>}

    # file_trailer: special stand-alone regex for reverse matching
    # trailer information from the end of the file. Typically used
    # when reading last few KB of a PDF to locate trailer information
    regex file_trailer {<trailer>'%%EOF'<eol>?$}

}
