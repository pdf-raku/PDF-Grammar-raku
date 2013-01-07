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
    rule opBeginText           { (BT) }
    rule opEndText             { (ET) }

    # marked content blocks: BMC ... EMC   or   BDC ... EMC
    rule opBeginMarkedContent  { [<name> (BMC)]
				     | [<name> [<name> | <dict>] (BDC)] }
    rule opEndMarkedContent    { (EMC) }

    # image blocks BI ... ID ... EI
    rule opBeginImage          { (BI) }
    rule opImageData           { (ID) }
    rule opEndImage            { (EI) }

    # ignored blocks BX .. EX (nestable)
    rule opBeginIgnore         {(BX)}
    rule opEndIgnore           {(EX)}

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

    # operator names courtersy of xpdf / Gfx.cc (http://foolabs.com/xdf/)
    proto rule op { <...> }
    rule op:sym<MoveSetShowText>     { <number> <number> <string> ('"') } 
    rule op:sym<MoveShowText>        { <string> ("'") }
    rule op:sym<EOFillStroke>        { (B\*) }
    rule op:sym<FillStroke>          { (B) }
    rule op:sym<SetStrokeColorSpace> { <name> (CS) }
    rule op:sym<MarkPoint>           { [<name> (MP)
					| <name> [<name> | <dict>] (DP)] }
    rule op:sym<XObject>             { <name> (Do) }
    rule op:sym<EOFill>              { (f\*) }
    rule op:sym<Fill>                { (F|f) }
    rule op:sym<SetStrokeGray>       { <number> (G) }
    rule op:sym<SetLineCap>          { <integer> (J) }
    rule op:sym<SetStrokeCMYKColor>  { <number>**4 (K) }
    rule op:sym<SetMiterLimit>       { <number> (M) }
    rule op:sym<Restore>             { (Q) }
    rule op:sym<SetStrokeRGBColor>   { <number>**3 (RG) }
    rule op:sym<SetStrokeColorN>     { <operand>+ (SCN) }
    rule op:sym<SetStrokeColor>      { <number>**4 (SC) }
    rule op:sym<Stroke>              { (S) }
    rule op:sym<TextNextLine>        { (T\*) }
    rule op:sym<TextMoveSet>         { <number> <number> (TD) }
    rule op:sym<ShowSpaceText>       { <array> (TJ) }
    rule op:sym<SetTextLeading>      { <number> (TL) }
    rule op:sym<SetCharSpacing>      { <number> (Tc) }
    rule op:sym<TextMove>            { <number> <number> (Td) }
    rule op:sym<SetFont>             { <name> <number> (Tf) }
    rule op:sym<ShowText>            { <string> (Tj) }
    rule op:sym<SetTextMatrix>       { <number>**6 (Tm) }
    rule op:sym<SetTextRender>       { <integer> (Tr) }
    rule op:sym<SetTextRise>         { <number> (Ts) }
    rule op:sym<SetWordSpacing>      { <number> (Tw) }
    rule op:sym<SetHorizScaling>     { <number> (Tz) }
    rule op:sym<EOClip>              { (W\*) }
    rule op:sym<Clip>                { (W) } 
    rule op:sym<CloseEOFillStroke>   { (b\*) }
    rule op:sym<CloseFillStroke>     { (b) } 
    rule op:sym<Concat>              { <number>**6 (cm) }
    rule op:sym<CurveTo>             { <number>**6 (c) }
    rule op:sym<SetFillColorSpace>   { <name> (cs) }
    rule op:sym<SetDash>             { <array> <number> (d) }
    rule op:sym<SetCharWidth>        { <number> <number> (d0) }
    rule op:sym<SetCacheDevice>      { <number>**6 (d1) }
    rule op:sym<SetExtGState>        { <name> (gs) }
    rule op:sym<SetFillGray>         { <number> (g) }
    rule op:sym<ClosePath>           { (h) }
    rule op:sym<SetFlat>             { <number> (i) }
    rule op:sym<SetLineJoin>         { <integer> (j) }
    rule op:sym<SetFillCMYKColor>    { <number>**4 (k) }
    rule op:sym<LineTo>              { <number> <number> (l) }
    rule op:sym<MoveTo>              { <number> <number> (m) }
    rule op:sym<EndPath>             { (n) }
    rule op:sym<Save>                { (q) }
    rule op:sym<Rectangle>           { <number>**4 (re) }
    rule op:sym<SetFillRGBColor>     { <number>**3 (rg) }
    rule op:sym<SetRenderingIntent>  { <name> (ri) }
    rule op:sym<CloseStroke>         { (s) }
    rule op:sym<SetFillColorN>       { <operand>+ (scn) }
    rule op:sym<SetFillColor>        { <number>**4 (sc) }
    rule op:sym<ShFill>              { <name> (sh) }
    rule op:sym<CurverTo1>           { <number>**4 (v) }
    rule op:sym<SetLineWidth>        { <number> (w) }
    rule op:sym<CurveTo2>            { <number>**4 (y) }
    # catchall for unknown opcodes and arguments
    token id { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule unknown               { [<operand>|<id>]+? } 
}


