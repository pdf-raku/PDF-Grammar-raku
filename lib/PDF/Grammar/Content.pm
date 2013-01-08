use v6;

use PDF::Grammar;

grammar PDF::Grammar::Content is PDF::Grammar {
    #
    # A Simple PDF grammar for parsing PDF content, i.e. Graphics and
    # Text operations as describe in sections 8 and 9 of [PDF 1.7].
    rule TOP {^ [<instruction>|<unknown>]* $}

    rule instruction {<block>|<op>}

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

    rule inner_text_block { <opBeginText> <op>* <opEndText> }
    rule inner_marked_content_block {<opBeginMarkedContent> <op>* <opEndMarkedContent>}
    proto rule block { <...> }
    rule block:sym<text> {<opBeginText> [ <inner_marked_content_block> | <op>]* <opEndText>}
    rule block:sym<markedContent> {<opBeginMarkedContent> [ <inner_text_block> | <op> ]* <opEndMarkedContent>}
    regex block:sym<image> {
                      <opBeginImage>:
                      [<name> <operand>]*
                      <opImageData>(.*?)<eol>?<opEndImage>
    }

    rule block:sym<ignore> {<opBeginIgnore>: (<block:sym<ignore>>|.)*? <opEndIgnore>}

    # ------------------------
    # Operators and Operands
    # ------------------------

    # operator names courtersy of xpdf / Gfx.cc (http://foolabs.com/xdf/)
    proto rule op { <...> }
    rule op:sym<CloseEOFillStroke>   { (b\*) }
    rule op:sym<CloseFillStroke>     { (b) } 
    rule op:sym<EOFillStroke>        { (B\*) }
    rule op:sym<FillStroke>          { (B) }

    rule op:sym<CurveTo>             { <number>**6 (c) }
    rule op:sym<Concat>              { <number>**6 (cm) }
    rule op:sym<SetFillColorSpace>   { <name> (cs) }
    rule op:sym<SetStrokeColorSpace> { <name> (CS) }

    rule op:sym<SetDash>             { <array> <number> (d) }
    rule op:sym<SetCharWidth>        { <number> <number> (d0) }
    rule op:sym<SetCacheDevice>      { <number>**6 (d1) }
    rule op:sym<XObject>             { <name> (Do) }
    rule op:sym<MarkPoint>           { <name> [<name> | <dict>] (DP) }

    rule op:sym<EOFill>              { (f\*) }
    rule op:sym<Fill>                { (F|f) }

    rule op:sym<SetStrokeGray>       { <number> (G) }
    rule op:sym<SetFillGray>         { <number> (g) }
    rule op:sym<SetExtGState>        { <name> (gs) }

    rule op:sym<ClosePath>           { (h) }

    rule op:sym<SetFlat>             { <number> (i) }

    rule op:sym<SetLineJoin>         { <integer> (j) }
    rule op:sym<SetLineCap>          { <integer> (J) }

    rule op:sym<SetFillCMYKColor>    { <number>**4 (k) }
    rule op:sym<SetStrokeCMYKColor>  { <number>**4 (K) }

    rule op:sym<LineTo>              { <number> <number> (l) }

    rule op:sym<MoveTo>              { <number> <number> (m) }
    rule op:sym<SetMiterLimit>       { <number> (M) }
    rule op:sym<MarkPoint2>          { <name> (MP) }

    rule op:sym<EndPath>             { (n) }

    rule op:sym<Save>                { (q) }
    rule op:sym<Restore>             { (Q) }

    rule op:sym<Rectangle>           { <number>**4 (re) }
    rule op:sym<SetFillRGBColor>     { <number>**3 (rg) }
    rule op:sym<SetStrokeRGBColor>   { <number>**3 (RG) }
    rule op:sym<SetRenderingIntent>  { <name> (ri) }

    rule op:sym<CloseStroke>         { (s) }
    rule op:sym<Stroke>              { (S) }
    rule op:sym<SetStrokeColor>      { <number>**4 (SC) }
    rule op:sym<SetFillColor>        { <number>**4 (sc) }
    rule op:sym<SetFillColorN>       { <operand>+ (scn) }
    rule op:sym<SetStrokeColorN>     { <operand>+ (SCN) }
    rule op:sym<ShFill>              { <name> (sh) }

    rule op:sym<TextNextLine>        { (T\*) }
    rule op:sym<SetCharSpacing>      { <number> (Tc) }
    rule op:sym<TextMove>            { <number> <number> (Td) }
    rule op:sym<TextMoveSet>         { <number> <number> (TD) }
    rule op:sym<SetFont>             { <name> <number> (Tf) }
    rule op:sym<ShowText>            { <string> (Tj) }
    rule op:sym<ShowSpaceText>       { <array> (TJ) }
    rule op:sym<SetTextLeading>      { <number> (TL) }
    rule op:sym<SetTextMatrix>       { <number>**6 (Tm) }
    rule op:sym<SetTextRender>       { <integer> (Tr) }
    rule op:sym<SetTextRise>         { <number> (Ts) }
    rule op:sym<SetWordSpacing>      { <number> (Tw) }
    rule op:sym<SetHorizScaling>     { <number> (Tz) }

    rule op:sym<CurverTo1>           { <number>**4 (v) }

    rule op:sym<EOClip>              { (W\*) }
    rule op:sym<Clip>                { (W) } 
    rule op:sym<SetLineWidth>        { <number> (w) }

    rule op:sym<CurveTo2>            { <number>**4 (y) }

    rule op:sym<MoveSetShowText>     { <number> <number> <string> ('"') } 
    rule op:sym<MoveShowText>        { <string> ("'") }

    # catchall for unknown opcodes and arguments
    token id { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule unknown               { [<operand>|<id>]+? } 
}


