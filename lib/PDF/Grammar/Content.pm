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
    rule opBeginMarkedContent  { [<obj> (BMC)] | [<obj> <dct> (BDC)] }
    rule opEndMarkedContent    { (EMC) }

    # image blocks BI ... ID ... EI
    rule opBeginImage          { (BI) }
    rule opImageData           { (ID) }
    rule opEndImage            { (EI) }

    # ignored blocks BX .. EX (nestable)
    rule opBeginIgnore         {BX}
    rule opEndIgnore           {EX}

    # blocks have limited nesting capability and aren't fully recursive.
    # So theretically, we only have to deal with a few combinations...

    rule innerTextBlock { <opBeginText> <op>* <opEndText> }

    rule innerMarkedContentBlock {<opBeginMarkedContent> <op>* <opEndMarkedContent>}
    rule textBlock {<opBeginText> [ <innerMarkedContentBlock> | <op>]* <opEndText>}
    rule markedContentBlock {<opBeginMarkedContent> [ <innerTextBlock> | <op> ]* <opEndMarkedContent>}
    rule imageBlock {
                      <opBeginImage>
                      [<name> <operand>]*
                      <opImageData>.*?<eol>?<opEndImage>
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
    rule any {<operand>+}

    # operations
    rule op {<opMoveSetShowText>|<opMoveShowText>|<opEOFillStroke>|<opFillStroke>|<opShowText>|<opSetStrokeColorSpace>|<opMarkPoint>|<opMarkPoint2>|<opXObject>|<opEOFill>|<opFill>|<opSetStrokeGray>|<opSetLineCap>|<opSetStrokeCMYKColor>|<opSetMiterLimit>|<opRestore>|<opSetStrokeRGBColor>|<opStroke>|<opSetStrokeColorN>|<opSetStrokeColor>|<opTextNextLine>|<opTextMoveSet>|<opShowSpaceText>|<opSetTextLeading>|<opSetCharSpacing>|<opTextMove>|<opSetFont>|<opSetTextMatrix>|<opSetTextRender>|<opSetTextRise>|<opSetWordSpacing>|<opSetHorizScaling>|<opEOClip>|<opClip>|<opCloseEOFillStroke>|<opCloseFillStroke>|<opConcat>|<opCurveTo>|<opSetFillColorSpace>|<opSetDash>|<opSetCharWidth>|<opSetCacheDevice>|<opSetExtGState>|<opSetFillGray>|<opClosePath>|<opSetFlat>|<opSetLineJoin>|<opSetFillCMYKColor>|<opLineTo>|<opMoveTo>|<opEndPath>|<opSave>|<opRectangle>|<opSetFillRGBColor>|<opSetRenderingIntent>|<opCloseStroke>|<opSetFillColorN>|<opSetFillColor>|<opShFill>|<opCurverTo1>|<opSetLineWidth>|<opCurveTo2>}
    # operator names courtersy of xpdf / Gfx.cc (http://foolabs.com/xdf/)
    rule opMoveSetShowText     { <num> <num> <str> ('"') } 
    rule opMoveShowText        { <str> ("'") }
    rule opEOFillStroke        { (B\*) }
    rule opFillStroke          { (B) }
    rule opSetStrokeColorSpace { <obj> (CS) }
    rule opMarkPoint           { <obj> (MP) }
    rule opMarkPoint2          { <obj> <dct> (DP) }
    rule opXObject             { <obj> (Do) }
    rule opEOFill              { (f\*) }
    rule opFill                { (F|f) }
    rule opSetStrokeGray       { <num> (G) }
    rule opSetLineCap          { <int> (J) }
    rule opSetStrokeCMYKColor  { <num>**4 (K) }
    rule opSetMiterLimit       { <num> (M) }
    rule opRestore             { (Q) }
    rule opSetStrokeRGBColor   { <num>**3 (RG) }
    rule opStroke              { (S) }
    rule opSetStrokeColorN     { <any> (SCN) }
    rule opSetStrokeColor      { <num>**4 (SC) }
    rule opTextNextLine        { (T\*) }
    rule opTextMoveSet         { <num> <num> (TD) }
    rule opShowSpaceText       { <arr> (TJ) }
    rule opSetTextLeading      { <num> (TL) }
    rule opSetCharSpacing      { <num> (Tc) }
    rule opTextMove            { <num> <num> (Td) }
    rule opSetFont             { <obj> <num> (Tf) }
    rule opShowText            { <str> (Tj) }
    rule opSetTextMatrix       { <num>**6 (Tm) }
    rule opSetTextRender       { <int> (Tr) }
    rule opSetTextRise         { <num> (Ts) }
    rule opSetWordSpacing      { <num> (Tw) }
    rule opSetHorizScaling     { <num> (Tz) }
    rule opEOClip              { (W\*) }
    rule opClip                { (W) } 
    rule opCloseEOFillStroke   { (b\*) }
    rule opCloseFillStroke     { (b) } 
    rule opConcat              { <num>**6 (cm) }
    rule opCurveTo             { <num>**6 (c) }
    rule opSetFillColorSpace   { <obj> cs }
    rule opSetDash             { <arr> <num> (d) }
    rule opSetCharWidth        { <num> <num> (d0) }
    rule opSetCacheDevice      { <num>**6 (d1) }
    rule opSetExtGState        { <obj> (gs) }
    rule opSetFillGray         { <num> (g) }
    rule opClosePath           { (h) }
    rule opSetFlat             { <num> (i) }
    rule opSetLineJoin         { <int> (j) }
    rule opSetFillCMYKColor    { <num>**4 (k) }
    rule opLineTo              { <num> <num> (l) }
    rule opMoveTo              { <num> <num> (m) }
    rule opEndPath             { (n)}
    rule opSave                { (q) }
    rule opRectangle           { <num>**4 (re) }
    rule opSetFillRGBColor     { <num>**3 (rg) }
    rule opSetRenderingIntent  { <obj> (ri) }
    rule opCloseStroke         { (s) }
    rule opSetFillColorN       { <any> (scn) }
    rule opSetFillColor        { <num>**4 (sc) }
    rule opShFill              { <name> (sh) }
    rule opCurverTo1           { <num>**4 (v) }
    rule opSetLineWidth        { <num> (w) }
    rule opCurveTo2            { <num>**4 (y) }
    # catchall for unknown opcodes and arguments
    token id { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule unknown               { [<any>|<id>]+? } 
}


