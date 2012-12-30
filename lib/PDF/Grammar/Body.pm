use v6;

use PDF::Grammar;
use PDF::Grammar::Body::Xref;

grammar PDF::Grammar::Body is PDF::Grammar {
    #
    # A Simple PDF grammar for parsing the basic block structure of a
    # PDF document.
    # - memory hungry/slow - don't try on documents > ~ 500K
    # - token/block-structure  level parsing only, no attempt to interpret
    #   overall structure, character escapes  or high level objects (e.g.
    #   Fonts, Pages)
    # - limited to non-existant stream parsing
    # - no attempt yet to capture content
    # - no error handling or diagnostics
    #
    rule TOP {<pdf>}
    rule pdf {^<header><eol>(<content>+)'%%EOF'<eol>?$}
    # xref section is optional - document could have a cross reference stream
    # quite likley if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule content {<body><xref>?<trailer>} 

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token header {'%PDF-1.'\d}
    rule body {<indirect_object>+}

    rule xref {<PDF::Grammar::Body::Xref::xref>}
    rule indirect_object { <int> <int> obj <object>* endobj }

    rule trailer {
        trailer<eol>
        <dict>
        startxref<eol>\d+<eol>}

}

