use PDF::Grammar;

grammar PDF::Grammar::Content::Fast
    is PDF::Grammar {
    # Manually optimised version of PDF::Grammar::Content. Also
    # more forgiving; doesn't enforce text or marked content blocks
    rule TOP {^ [<op=.instruction>||<op=.suspect>]* $}

    proto rule instruction {*}
    rule instruction:sym<op>    {<op>}
    rule instruction:sym<block> {<block>}

    # image blocks BI ... ID ... EI
    rule opBeginImage          { (BI) }
    token opImageData          { (ID)[\n|' '|<.comment>]* }
    token opEndImage           { (EI) }

    proto rule block {*}
    rule imageDict {
        [<name> <object> { $*Len = try $<object>.trim.Int if ~$<name>.trim eq '/L' } ]*
    }
    rule block:sym<image> {
        :my $*Len;
        <opBeginImage>
        <imageDict>
        $<start>=<opImageData>[
        || <?{ $*Len.defined }> .**{ $*Len } <opEndImage>
        || .*?$<end>=[\n|' ' ]<opEndImage>
        || .*?$<end>=<opEndImage>] # more forgiving fallback
    }

    # ------------------------
    # Operators and Objects
    # ------------------------

    proto rule op {*}
    rule op:sym<unary>  { (b\*?|B[T|X|\*]?|E[MC|T|X]|F|f\*?|h|n|s|S|W\*?|T\*|Q|q) }
    rule op:sym<num>    { <number> [ (G|g|i|M|Tc|T[L|s|w|z]|w)
                                   | <number> [ (d0|l|m|Td|TD)
                                              | <string> (\")
                                              | <number> [ (rg|RG)
                                                         | <number> [ (k|K|re|v|y)
                                                                    | <number> <number> (c|cm|d1|Tm) ] ] ] ] }
    rule op:sym<name>   { <name> [ (BMC|cs|CS|Do|gs|MP|ri|sh)
                                 | [<name> | <dict>] (BDC|DP)
                                 | <number> (Tf) ]}
    rule op:sym<int>    { <int> (J|j|Tr) }
    rule op:sym<obj>    { <object>+ (scn?|SCN?) }
    rule op:sym<string> { <string> (Tj|\') }
    rule op:sym<array>  { <array> [ (TJ) | <number> (d) ] }

    # catchall for unknown opcodes and mismatched arguments
    token op-like { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule suspect  { <object>* (<.op-like>) } 
}
