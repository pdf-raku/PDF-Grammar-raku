use v6;

use PDF::Grammar;

grammar PDF::Grammar::Content is PDF::Grammar {
    #
    # A Simple PDF grammar for parsing PDF content, i.e. Graphics and
    # Text operations as describe in sections 8 and 9 of [PDF 1.7].
    rule TOP {^ [<instruction>|<unknown>]* $}

    rule instruction {<textBlock>|<markedContentBlock>|<imageBlock>|<ignoreBlock>|<op>}

    # ------------------------
    # Blocks
    # ------------------------

    # text blocks: BT ... ET
    rule opBeginText           { BT }
    rule opEndText             { ET }

    # marked content blocks: BMC ... EMC   or   BDC ... EMC
    rule opBeginMarkedContent  { [<obj> BMC] | [<obj> <dct> BDC] }
    rule opEndMarkedContent    { EMC }

    # image blocks BI ... ID ... EI
    rule opBeginImage          { BI }
    rule opImageData           { ID }
    rule opEndImage            { EI }

    # ignored blocks BX .. EX (nestable)
    rule opBeginIgnore         {BX}
    rule opEndIgnore           {EX}

    # blocks have limited nesting capability and aren't fully recursive.
    # So theretically, we only have to deal with a few combinations...

    rule innerTextBlock { <opBeginText> <op>* <opEndText> }
    rule innerMarkedContentBlock {<opBeginMarkedContent> <op>* <opEndMarkedContent>}
    rule textBlock {<opBeginText> [ <innerMarkedContentBlock> | <op>]* <opEndText>}
    rule markedContentBlock {<opBeginMarkedContent> [ <innerTextBlock> | <op> ]* <opEndMarkedContent>}
    regex imageBlock {
                      <opBeginImage>:
                      [<name> <operand>]*
                      <opImageData>(.*?)<eol>?<opEndImage>
    }

    rule ignoreBlock {<opBeginIgnore>: (<ignoreBlock>|.)*? <opEndIgnore>}

    # ------------------------
    # Operators and Operands
    # ------------------------

    # arguments
    rule obj {<null> | <name>}
    rule str {<obj>  | <string>}
    rule arr {<obj>  | <array>}
    rule dct {<obj>  | <dict>}
    rule num {<obj>  | <number>}
    rule int {<obj>  | <integer>}

    # operations

    # operator names courtersy of xpdf / Gfx.cc (http://foolabs.com/xdf/)
    proto rule op { <...> }
    rule op:sym<MoveSetShowText>     { <num> <num> <str> ('"') } 
    rule op:sym<MoveShowText>        { <str> ("'") }
    rule op:sym<EOFillStroke>        { (B\*) }
    rule op:sym<FillStroke>          { (B) }
    rule op:sym<SetStrokeColorSpace> { <obj> (CS) }
    rule op:sym<MarkPoint>           { <obj> (MP) }
    rule op:sym<MarkPoint2>          { <obj> <dct> (DP) }
    rule op:sym<XObject>             { <obj> (Do) }
    rule op:sym<EOFill>              { (f\*) }
    rule op:sym<Fill>                { (F|f) }
    rule op:sym<SetStrokeGray>       { <num> (G) }
    rule op:sym<SetLineCap>          { <int> (J) }
    rule op:sym<SetStrokeCMYKColor>  { <num>**4 (K) }
    rule op:sym<SetMiterLimit>       { <num> (M) }
    rule op:sym<Restore>             { (Q) }
    rule op:sym<SetStrokeRGBColor>   { <num>**3 (RG) }
    rule op:sym<SetStrokeColorN>     { <operand>+ (SCN) }
    rule op:sym<SetStrokeColor>      { <num>**4 (SC) }
    rule op:sym<Stroke>              { (S) }
    rule op:sym<TextNextLine>        { (T\*) }
    rule op:sym<TextMoveSet>         { <num> <num> (TD) }
    rule op:sym<ShowSpaceText>       { <arr> (TJ) }
    rule op:sym<SetTextLeading>      { <num> (TL) }
    rule op:sym<SetCharSpacing>      { <num> (Tc) }
    rule op:sym<TextMove>            { <num> <num> (Td) }
    rule op:sym<SetFont>             { <obj> <num> (Tf) }
    rule op:sym<ShowText>            { <str> (Tj) }
    rule op:sym<SetTextMatrix>       { <num>**6 (Tm) }
    rule op:sym<SetTextRender>       { <int> (Tr) }
    rule op:sym<SetTextRise>         { <num> (Ts) }
    rule op:sym<SetWordSpacing>      { <num> (Tw) }
    rule op:sym<SetHorizScaling>     { <num> (Tz) }
    rule op:sym<EOClip>              { (W\*) }
    rule op:sym<Clip>                { (W) } 
    rule op:sym<CloseEOFillStroke>   { (b\*) }
    rule op:sym<CloseFillStroke>     { (b) } 
    rule op:sym<Concat>              { <num>**6 (cm) }
    rule op:sym<CurveTo>             { <num>**6 (c) }
    rule op:sym<SetFillColorSpace>   { <obj> (cs) }
    rule op:sym<SetDash>             { <arr> <num> (d) }
    rule op:sym<SetCharWidth>        { <num> <num> (d0) }
    rule op:sym<SetCacheDevice>      { <num>**6 (d1) }
    rule op:sym<SetExtGState>        { <obj> (gs) }
    rule op:sym<SetFillGray>         { <num> (g) }
    rule op:sym<ClosePath>           { (h) }
    rule op:sym<SetFlat>             { <num> (i) }
    rule op:sym<SetLineJoin>         { <int> (j) }
    rule op:sym<SetFillCMYKColor>    { <num>**4 (k) }
    rule op:sym<LineTo>              { <num> <num> (l) }
    rule op:sym<MoveTo>              { <num> <num> (m) }
    rule op:sym<EndPath>             { (n) }
    rule op:sym<Save>                { (q) }
    rule op:sym<Rectangle>           { <num>**4 (re) }
    rule op:sym<SetFillRGBColor>     { <num>**3 (rg) }
    rule op:sym<SetRenderingIntent>  { <obj> (ri) }
    rule op:sym<CloseStroke>         { (s) }
    rule op:sym<SetFillColorN>       { <operand>+ (scn) }
    rule op:sym<SetFillColor>        { <num>**4 (sc) }
    rule op:sym<ShFill>              { <name> (sh) }
    rule op:sym<CurverTo1>           { <num>**4 (v) }
    rule op:sym<SetLineWidth>        { <num> (w) }
    rule op:sym<CurveTo2>            { <num>**4 (y) }
    # catchall for unknown opcodes and arguments
    token id { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule unknown               { [<operand>|<id>]+? } 
}


