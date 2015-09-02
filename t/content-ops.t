#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;

my $test-image-block = 'BI                  % Begin inline image object
    /W 17           % Width in samples
    /H 17           % Height in samples
    /CS /RGB        % Colour space
    /BPC 8          % Bits per component
    /F [/A85 /LZW]  % Filters
ID                  % Begin image data
J1/gKA>.]AN&J?]-<HW]aRVcg*bb.\eKAdVV%/PcZ
%…Omitted data…
%R.s(4KE3&d&7hb*7[%Ct2HCqC~>
EI';

# test individual ops
for (
    text-block-empty               => 'BT ET',
    text-block-populated           => 'BT B* ET',

    BDC-marked-content-empty-text  =>'/foo <</MP /yup>> BDC BT ET EMC',
    BDC-marked-content-with-op     => '/foo <</MP /yup>> BDC (hello) Tj EMC',
    BDC-content-dict-ref           => '/EmbeddedDocument /MC3 BDC q EMC',      # optional content - named dict
    BMC-marked-content-empty-text  => '/foo BMC BT ET EMC',     # Marked content - empty
    BMC-marked-content-with-text   => '/bar BMC BT B* ET EMC',  # Marked content + text block - empty
    BMC-marked-content-with-op     => '/baz BMC B* EMC',        # BT .. ET  Text block - with valid content

    'BI .. ID .. EI image-block'   => $test-image-block,

    'BX .. EX ignored text'        => 'BX this stuff gets ignored EX',
    'BX .. BX .. EX .. EX nesting' => 'BX this stuff gets BX doubly EX ignored EX',

    CloseFileStroke => 'b',
    CloseEOFillStroke => 'b*',
    FillStroke => 'B',
    EOFillStroke => 'B*',

    CurveTo             => '.1 .2 .3 4. 5. 6.0 c',
    ConcatMatrix        => '.1 .2 .3 4. 5. 6.0 cm',
    SetFillColorSpace   => '/RGB cs',
    SetStrokeColorSpace => '/CMYK CS',

    Dash => '[1 2] 2 d',
    SetCharWidth => '.67 1.2 d0',
    SetCacheDevice => '.1 .2 .3 4. 5. 6.0 d1',
    XObject => '/MyForm Do',
    'MarkPoint (inline dict)' => '/foo <</bar 42>> DP',
    'MarkPoint (dict ref)' => '/foo /baz DP',

    Fill => 'F', 'Fill (Obsolete)' => 'f', 'EOFill' => 'f*',

    SetStrokeGray => '.7 G',
    SetFillGray => '.5 g',
    SetExtState => '/Gs1 gs',

    ClosePath => 'h',

    SetFlat => '2 i',

    SetLineJoin => '3 j',
    SetLineCap => '2 J',

    SetFillCMYK => '.7 .3 .2 .05 k',
    SetStrokeCMYK => '.1  0.2  0.30  .400  K',

    LineTo => '20 30 l',

    moveTo => '100 125 m',
    setMiterLimit => '0.35 M',
    MarkPoint => '/here MP',

    EndPath => 'n',

    Save => 'q',
    Restore => 'Q',

    Rectangle => '20 50 30 60 re',
    SetStrokeRGB =>  '.3 .5 .7 RG',
    SetFilLRGB => '.7 2. .5 rg',
    SetRenderingIntent => '/foo ri',
 
    CloseStroke => 's',
    SetFillColor => '.2 .35 .7 .9 sc',
    SetFillColorN => '0.30 0.75 0.21 /P2 scn',
    Stroke => 'S',
    SetStrokeColor => '.1  0.2  0.30  .400  SC',
    SetStrokeColorN => '0.30 0.75 0.21 /P2 SCN',
    shFill => '/bar sh',

    TextNewLine => 'T*',
    SetCharSpacing => '4.5 Tc',
    TextMove => '20 15 Td',
    TextMoveSet => '200 100 TD',
    SetFont => '/TimesRoman 12 Tf',
    ShowText => '(hello world) Tj',
    ShowSpaceText => '[(hello) -10.5 (world)] TJ',
    SetTextLeading => '13 TL',
    SetTextMatrix => '9 0 0 9 476.48 750 Tm',
    SetTextRender => '2 Tr',
    SetTextRise => '1.7 Ts',
    SetTextWordSpacing => '2.5 Tw',
    SetHorizScaling => '0.7 Tz',

    CurveTo => '.1 .2 .3 .4 v',

    EOClip => 'W',
    Clip => 'W*',
    SetLineWidth => '1.35 w',

    CurveTo2 => '.1 .2 .3 .4 y',

    MoveSetShowText => '10 20 (hi) "',      # "         moveShow
    MoveShowText => "(hello) '",            # '         show

    ) {
    ok(.value ~~ /^<PDF::Grammar::Content::instruction>$/, "instruction " ~ .key)
        or do {
            diag "failed instruction: " ~ .value;
            if (.value ~~ /^(.*?)(<PDF::Grammar::Content::instruction>)(.*?)$/) {

                my $p = $0 && $0.join(',');
                note "(preceeding: $p)" if $p;
                my $m = $1 && $1.join(',');
                note "(best match: $m)" if $m;
                my $f = $2 && $2.join(',');
                note "(following: $f)" if $f;
            }
    }
}

# invalid cases
for (
    'too few args' =>'20 (hi) "',      
    'type mismatch (wrong order)' =>'10 (hi) 20 "',   
    'unknown operator' =>'crud',           
    'Text block - unclosed' =>'BT B',           
    'Text block - unopened' =>'B ET',           
    'Text block - extra end' =>'BT B ET ET',     
    'Text block - incomplete content' =>'BT 42 ET',       
    'Text block - nested' =>'BT BT ET ET',    
    'Marked content - incorrect text nesting' =>'/foo BMC BT EMC ET',     
    'Marked content - nested' =>'/bar BMC /baz BMC B* EMC EMC',  
    'Marked content - extra end' =>'/foo BMC BT ET EMC EMC',   
    'Marked content - mising arg' =>'/BMC BT B* ET EMC',        
    'Marked content - incomplete contents' =>'/baz BMC (hi) EMC',        
    'BX ... EX incorrect nesting (extra BX)' => 'BX BX EX',
    'BX ... EX incorrect nesting (extra EX)' =>'BX EX EX',                 
    ) {
    # test our parser's resilience
    ok(.value !~~ /^<PDF::Grammar::Content::instruction>$/,
       "invalid instruction: " ~ .key)
        or diag .value;
    ok($_ ~~ /<PDF::Grammar::Content::unknown>/,
       "parsed as unknown: " ~ .key);
}

done-testing;
