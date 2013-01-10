use v6;

use PDF::Grammar;
use PDF::Grammar::Body::Xref;

grammar PDF::Grammar::FDF is PDF::Grammar {
    #
    # An experimental Perl6  grammar for scanning the basic outer block
    # structure of FDF form data exchange files.
    #
    rule TOP {<fdf>}
    rule fdf {^<fdf_header><eol>[<content>+]'%%EOF'<eol>?$}

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token fdf_header {'%FDF-'(\d'.'\d)}

    # xref section is optional 
    rule content {<body><xref>?<trailer>} 
    rule body {<indirect_object>+}
    rule indirect_object { <integer> <integer> obj <object>* endobj }

    rule object { <indirect_reference> | <operand> }
    # override PDF::Grammar <array> and <dict> rules to include all objects
    rule array {\[ <object>* \]}
    rule dict {'<<' [<name> <object>]* '>>'}

    rule indirect_reference {<integer> <integer> R}

    rule xref {<PDF::Grammar::Body::Xref::xref>}

    rule trailer {
        trailer<eol><dict><eol>(startxref<eol>\d+<eol>)?}

}
