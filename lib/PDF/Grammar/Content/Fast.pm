use v6;

use PDF::Grammar;

grammar PDF::Grammar::Content::Fast
    is PDF::Grammar {
    # Manually optimised version of PDF::Grammar::Content. Also
    # more forgiving; doesn't enforce text or marked content blocks
    rule TOP {^ [<op=.instruction>||<op=.unknown>]* $}

    proto rule instruction {*}
    rule instruction:sym<op>    {<op>}
    rule instruction:sym<block> {<block>}

    # image blocks BI ... ID ... EI
    rule opBeginImage          { (BI) }
    rule opImageData           { (ID) }
    rule opEndImage            { (EI) }

    # ignored blocks BX .. EX (nestable)
    rule opBeginIgnore         { (BX) }
    rule opEndIgnore           { (EX) }

    proto rule block {*}
    rule imageDict { [<name> <object>]* }
    rule block:sym<image> {
                      <opBeginImage>
                      <imageDict>
                      $<start>=<opImageData>.*?$<end>=\n<opEndImage>
    }

    rule ignored-block { <opBeginIgnore> <ignored>*? <opEndIgnore> }

    proto rule ignored {*}
    rule ignored:sym<block> { <ignored-block> }
    rule ignored:sym<guff>  { <guff> }
    rule ignored:sym<char>  { . }

    rule block:sym<ignore> { <ignored-block> }

    # ------------------------
    # Operators and Objects
    # ------------------------

    proto rule op {*}
    rule op:sym<unary>  { (b\*?|B[T|\*]?|EMC|ET|F|f\*?|h|n|s|S|W\*?|T\*|Q|q) }
    rule op:sym<num>    { <number> [ (G|g|i|M|Tc|TL|Ts|Tw|Tz|w)
                                   | <number> [ (d0|l|m|Td|TD )
                                              | <string> (\")
                                              | <number> [ (rg|RG)
                                                         | <number> [ (k|K|re|SC|sc|v|y)
                                                                    | <number> <number> (c|cm|d1|Tm) ] ] ] ] }
    rule op:sym<name>   { <name> [ (BMC|cs|CS|Do|gs|MP|ri|sh) | [<name> | <dict>] (BDC|DP) | <number> (Tf) ]}
    rule op:sym<int>    { <int> (J|j|Tr) }
    rule op:sym<obj>    { <object>+ (scn|SCN) }
    rule op:sym<string> { <string> (Tj|\') }
    rule op:sym<array>  { <array> [ (TJ) | <number> (d) ] }

    # catchall for unknown opcodes and arguments
    token guff    { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule unknown  { <object> || <guff> } 
}
