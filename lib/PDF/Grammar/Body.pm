use v6;

use PDF::Grammar;
use PDF::Grammar::Body::Xref;

grammar PDF::Grammar::Body is PDF::Grammar {
    #
    # An experimental Perl6  grammar for scanning the basic outer block
    # structure of PDF documents or FDF form data files.
    #
    rule TOP {<pdf>}
    rule pdf {^<header><eol>[<content>+]'%%EOF'<eol>?$}

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token header {'%'(PDF|FDF)'-'(\d'.'\d)}

    # xref section is optional - document could have a cross reference stream
    # quite likley if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule content {<body><xref>?<trailer>} 
    rule body {<indirect_object>+}
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

    rule xref {<PDF::Grammar::Body::Xref::xref>}

    rule trailer {
        trailer<eol><dict><eol>(startxref<eol>\d+<eol>)?}

}
