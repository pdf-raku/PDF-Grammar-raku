use v6;

use PDF::Grammar;

grammar PDF::Grammar::Content is PDF::Grammar {
    #
    # A Simple PDF grammar for parsing PDF content, i.e. Graphics and
    # Text operations as describe in sections 8 and 9 of [PDF 1.7].
    rule TOP {<instruction>*}

   rule instruction {(<op>|<textBlock>|<markedContentBlock>|<imageBlock>|<ignoreBlock>)*}

    # arguments
    rule obj {<null> | <name>}
    rule str {<obj> | <string>}
    rule arr {<obj> | <array>}
    rule dct {<obj> | <dict>}
    rule num {<obj> | <number>}
    rule any {<operand>*}

    # blocks have limited nesting capability and aren't fully recursive.
    # So theretically, we only have to deal with a few combinations...

    rule rBMC { <opBeginMarkedContent> | <opBeginOptionalContent> }
    rule rEMC { <opEndMarkedContent> }
    rule textBlock {<opBeginText> ( (<rBMC> <op>* <rEMC>) | <op>)* <opEndText>}
    rule markedContentBlock {<rBMC> ( (<opBeginText> <op>* <opEndText>) | <op> )* <rEMC>}
    rule imageBlock {
                      <opBeginImage>
                      (<name> <operand>)*
                      <opImageData>.*?<eol>?<opEndImage>
    }

    rule ignoreBlock {BX: (<ignoreBlock>|.)*? EX}
    rule op {<opMoveSetShowText>|<opMoveShowText>|<opFillStroke>|<opEOFFillStroke>|<opShowText>|<opSetStrokeColorSpace>|<opMarkPoint>|<opXObject>}
    rule opMoveSetShowText{<num> <num> <str> \"} 
    rule opMoveShowText{<str> \'}
    rule opFillStroke{B<!before I><!before X>}
    rule opEOFFillStroke{B\*}
    rule opBeginOptionalContent{<obj> <dict> BDC}
    rule opBeginImage{BI}
    rule opBeginMarkedContent{<obj> BMC}
    rule opBeginText {BT}
    rule opBeginIgnore {BX}
    rule opSetStrokeColorSpace{<obj> CS}
    rule opMarkPoint{<obj> <dct> DP}
    rule opXObject{<obj> Do}
    rule opEndImage{EI}
    rule opEndMarkedContent{EMC}
    rule opEndText{ET}
    rule opEndIgnore{EX}
##  {"F",   0, {tchkNone},
##          &Gfx::opFill},
##  {"G",   1, {tchkNum},
##          &Gfx::opSetStrokeGray},
##  {"ID",  0, {tchkNone},
##          &Gfx::opImageData},
    rule opImageData{ID}
##  {"J",   1, {tchkInt},
##          &Gfx::opSetLineCap},
##  {"K",   4, {tchkNum,    tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opSetStrokeCMYKColor},
##  {"M",   1, {tchkNum},
##          &Gfx::opSetMiterLimit},
##  {"MP",  1, {tchkName},
##          &Gfx::opMarkPoint},
##  {"Q",   0, {tchkNone},
##          &Gfx::opRestore},
##  {"RG",  3, {tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opSetStrokeRGBColor},
##  {"S",   0, {tchkNone},
##          &Gfx::opStroke},
##  {"SC",  -4, {tchkNum,   tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opSetStrokeColor},
##  {"SCN", -33, {tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN},
##          &Gfx::opSetStrokeColorN},
##  {"T*",  0, {tchkNone},
##          &Gfx::opTextNextLine},
##  {"TD",  2, {tchkNum,    tchkNum},
##          &Gfx::opTextMoveSet},
##  {"TJ",  1, {tchkArray},
##          &Gfx::opShowSpaceText},
##  {"TL",  1, {tchkNum},
##          &Gfx::opSetTextLeading},
##  {"Tc",  1, {tchkNum},
##          &Gfx::opSetCharSpacing},
##  {"Td",  2, {tchkNum,    tchkNum},
##          &Gfx::opTextMove},
##  {"Tf",  2, {tchkName,   tchkNum},
##          &Gfx::opSetFont},
##  {"Tj",  1, {tchkString},
##          &Gfx::opShowText},
    rule opShowText{<str> Tj}
##  {"Tm",  6, {tchkNum,    tchkNum,    tchkNum,    tchkNum,
##	      tchkNum,    tchkNum},
##          &Gfx::opSetTextMatrix},
##  {"Tr",  1, {tchkInt},
##          &Gfx::opSetTextRender},
##  {"Ts",  1, {tchkNum},
##          &Gfx::opSetTextRise},
##  {"Tw",  1, {tchkNum},
##          &Gfx::opSetWordSpacing},
##  {"Tz",  1, {tchkNum},
##          &Gfx::opSetHorizScaling},
##  {"W",   0, {tchkNone},
##          &Gfx::opClip},
##  {"W*",  0, {tchkNone},
##          &Gfx::opEOClip},
##  {"b",   0, {tchkNone},
##          &Gfx::opCloseFillStroke},
##  {"b*",  0, {tchkNone},
##          &Gfx::opCloseEOFillStroke},
##  {"c",   6, {tchkNum,    tchkNum,    tchkNum,    tchkNum,
##	      tchkNum,    tchkNum},
##          &Gfx::opCurveTo},
##  {"cm",  6, {tchkNum,    tchkNum,    tchkNum,    tchkNum,
##	      tchkNum,    tchkNum},
##          &Gfx::opConcat},
##  {"cs",  1, {tchkName},
##          &Gfx::opSetFillColorSpace},
##  {"d",   2, {tchkArray,  tchkNum},
##          &Gfx::opSetDash},
##  {"d0",  2, {tchkNum,    tchkNum},
##          &Gfx::opSetCharWidth},
##  {"d1",  6, {tchkNum,    tchkNum,    tchkNum,    tchkNum,
##	      tchkNum,    tchkNum},
##          &Gfx::opSetCacheDevice},
##  {"f",   0, {tchkNone},
##          &Gfx::opFill},
##  {"f*",  0, {tchkNone},
##          &Gfx::opEOFill},
##  {"g",   1, {tchkNum},
##          &Gfx::opSetFillGray},
##  {"gs",  1, {tchkName},
##          &Gfx::opSetExtGState},
##  {"h",   0, {tchkNone},
##          &Gfx::opClosePath},
##  {"i",   1, {tchkNum},
##          &Gfx::opSetFlat},
##  {"j",   1, {tchkInt},
##          &Gfx::opSetLineJoin},
##  {"k",   4, {tchkNum,    tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opSetFillCMYKColor},
##  {"l",   2, {tchkNum,    tchkNum},
##          &Gfx::opLineTo},
##  {"m",   2, {tchkNum,    tchkNum},
##          &Gfx::opMoveTo},
##  {"n",   0, {tchkNone},
##          &Gfx::opEndPath},
##  {"q",   0, {tchkNone},
##          &Gfx::opSave},
##  {"re",  4, {tchkNum,    tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opRectangle},
##  {"rg",  3, {tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opSetFillRGBColor},
##  {"ri",  1, {tchkName},
##          &Gfx::opSetRenderingIntent},
##  {"s",   0, {tchkNone},
##          &Gfx::opCloseStroke},
##  {"sc",  -4, {tchkNum,   tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opSetFillColor},
##  {"scn", -33, {tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN,   tchkSCN,    tchkSCN,    tchkSCN,
##	        tchkSCN},
##          &Gfx::opSetFillColorN},
##  {"sh",  1, {tchkName},
##          &Gfx::opShFill},
##  {"v",   4, {tchkNum,    tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opCurveTo1},
##  {"w",   1, {tchkNum},
##          &Gfx::opSetLineWidth},
##  {"y",   4, {tchkNum,    tchkNum,    tchkNum,    tchkNum},
##          &Gfx::opCurveTo2},
##
}


