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
    rule str {<obj>  | <string>}
    rule arr {<obj>  | <array>}
    rule dct {<obj>  | <dict>}
    rule num {<obj>  | <number>}
    rule int {<obj>  | <integer>}
    rule any {<operand>+}

    # blocks have limited nesting capability and aren't fully recursive.
    # So theretically, we only have to deal with a few combinations...

    rule textBlock {<opBeginText> ( (<opBeginMarkedContent> <op>* <opEndMarkedContent>) | <op>)* <opEndText>}
    rule markedContentBlock {<opBeginMarkedContent> ( (<opBeginText> <op>* <opEndText>) | <op> )* <opEndMarkedContent>}
    rule imageBlock {
                      <opBeginImage>
                      (<name> <operand>)*
                      <opImageData>.*?<eol>?<opEndImage>
    }

    rule ignoreBlock {BX: (<ignoreBlock>|.)*? EX}
    rule op {<opMoveSetShowText>|<opMoveShowText>|<opFillStroke>|<opEOFFillStroke>|<opShowText>|<opSetStrokeColorSpace>|<opMarkPoint>|<opXObject>|<opFill>|<opSetStrokeGray>|<opSetLineCap>|<opSetStrokeCMYKColor>|<opSetMiterLimit>|<opRestore>|<opSetStrokeRGBColor>|<opStroke>|<opSetStrokeColor>|<opSetStrokeColorN>|<opTextNextLine>|<opTextMoveSet>|<opShowSpaceText>|<opSetTextLeading>|<opSetCharSpacing>|<opTextMove>|<opSetFont>|<opSetTextMatrix>|<opSetTextRender>|<opSetTextRise>|<opSetWordSpacing>|<opSetHorizScaling>|<opEOClip>|<opClip>}
    # operator names borrowed from xpdf / Gfx.cc
    rule opMoveSetShowText{<num> <num> <str> \"} 
    rule opMoveShowText{<str> \'}
    # todo 'BI' 'BX' matches misbehaving (not BT!??)
    rule opFillStroke{B<!before I><!before X>}
    rule opEOFFillStroke{B\*}
    rule opBeginImage{BI}
    rule opBeginMarkedContent{(<obj> BMC) | (<obj> <dict> BDC)}
    rule opBeginText {BT}
    rule opBeginIgnore {BX}
    rule opSetStrokeColorSpace{<obj> CS}
    rule opMarkPoint{(<obj> <dct> DP)|(<obj> MP)}
    rule opXObject{<obj> Do}
    rule opEndImage{EI}
    rule opEndMarkedContent{EMC}
    rule opEndText{ET}
    rule opEndIgnore{EX}
    rule opFill{F}
    rule opSetStrokeGray{<num> G}
    rule opImageData{ID}
    rule opSetLineCap{<int> J}
    rule opSetStrokeCMYKColor{<num> <num> <num> <num> K}
    rule opSetMiterLimit{<num> M}
    rule opRestore{Q}
    rule opSetStrokeRGBColor{<num> <num> <num> RG}
    rule opStroke{S}
    rule opSetStrokeColor{ <num> <num> <num> <num> SC }
    rule opSetStrokeColorN{ <any> SCN }
    rule opTextNextLine{ T\* }
    rule opTextMoveSet{ <num> <num> TD }
    rule opShowSpaceText{ <arr> TJ }
    rule opSetTextLeading{ <num> TL }
    rule opSetCharSpacing{ <num> Tc }
    rule opTextMove{ <num> <num> Td }
    rule opSetFont{ <obj> <num> Tf }
    rule opShowText{<str> Tj}
    rule opSetTextMatrix{ <num> <num> <num> <num> <num> <num> Tm }
    rule opSetTextRender{ <int> Tr }
    rule opSetTextRise { <num> Ts }
    rule opSetWordSpacing { <num> Tw }
    rule opSetHorizScaling{ <num> Tz }
    rule opEOClip{ 'W*' }
    rule opClip{ W } 
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


