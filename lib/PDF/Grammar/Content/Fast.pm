use v6;

use PDF::Grammar;

grammar PDF::Grammar::Content::Fast
    is PDF::Grammar {
    #
    # A manually optimised version of PDF::Grammar::Content
    # Current parser needs a bit of help to handle postfix operators
    # efficiently. May become redundant in future Rakudo versions
    rule TOP {^ [<op=.instruction>||<op=.unknown>]* $}

    proto rule instruction {*}
    rule instruction:sym<block> {<block>}
    rule instruction:sym<op>    {<op>}

    # ------------------------
    # Blocks
    # ------------------------

    # text blocks: BT ... ET
    rule opBeginText           { (BT) }
    rule opEndText             { (ET) }

    # marked content blocks: BMC ... EMC   or   BDC ... EMC
    rule opBeginMarkedContent  { <name> (BMC)
                               | <name> [<name> | <dict>] (BDC) }
    rule opEndMarkedContent    { (EMC) }

    # image blocks BI ... ID ... EI
    rule opBeginImage          { (BI) }
    rule opImageData           { (ID) }
    rule opEndImage            { (EI) }

    # ignored blocks BX .. EX (nestable)
    rule opBeginIgnore         { (BX) }
    rule opEndIgnore           { (EX) }

    # blocks have limited nesting capability and aren't fully recursive.
    # So theoretically, we only have to deal with a few combinations...

    rule inner-text-block { <opBeginText> <op>* <opEndText> }
    rule inner-marked-content-block { <opBeginMarkedContent> <op>* <opEndMarkedContent> }
    proto rule block {*}
    rule block:sym<text> { <opBeginText> [ <inner-marked-content-block> | <op> ]* <opEndText> }
    rule block:sym<markedContent> { <opBeginMarkedContent> [ <inner-text-block> | <op> ]* <opEndMarkedContent> }
    rule imageAtts { [<name> <object>]* }
    rule block:sym<image> {
                      <opBeginImage>
                      <imageAtts>
                      <opImageData>$<encoded>=.*?\n<opEndImage>
    }

    proto rule ignored {*}
    rule ignored:sym<block> { <ignored-block> }
    rule ignored:sym<guff>  { <guff> }
    rule ignored:sym<char>  { . }
    rule ignored-block { <opBeginIgnore> <ignored>*? <opEndIgnore> }
    rule block:sym<ignore> { <ignored-block> }

    # ------------------------
    # Operators and Objects
    # ------------------------

    proto rule op {*}
    rule op:sym<unary>  { (b\*?|B\*?|F|f\*?|h|n|s|S|W\*?|T\*|Q|q) }
    rule op:sym<num>    { <number> [ (G|g|i|M|Tc|TL|Ts|Tw|Tz|w)
                                   | <number> [ (d0|l|m|Td|TD )
                                              | <string> (\")
                                              | <number> [ (rg|RG)
                                                         | <number> [ (k|K|re|SC|sc|v|y)
                                                                    | <number> <number> (c|cm|d1|Tm) ] ] ] ] }
    rule op:sym<name>   { <name> [ (cs|CS|Do|gs|MP|ri|sh) | [<name> | <dict>] (DP) | <number> (Tf) ]}
    rule op:sym<int>    { <int> (J|j|Tr) }
    rule op:sym<obj>    { <object>+ (scn|SCN) }
    rule op:sym<string> { <string> (Tj|\') }
    rule op:sym<array>  { <array> [ (TJ) | <number> (d) ] }

    # catchall for unknown opcodes and arguments
    token guff { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule unknown               { <object> || <guff> } 
}
