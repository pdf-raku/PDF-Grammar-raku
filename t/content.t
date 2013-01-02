#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;

my $test_image_block = 'BI                  % Begin inline image object
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
    '10 20 (hi) "',      # "         moveShow

    "(hello) '",         # '         show

    'B',                 # B         fillStroke

    'B*',                # B*        EOFfillStroke

    'BT ET',             # BT .. ET  Text block - empty
    'BT B* ET',          # BT .. ET  Text block - with valid content

    '/foo <</MP /yup>> BDC BT ET EMC',     # optional content - empty
    '/foo <</MP /yup>> BDC (hello) Tj EMC',     # optional content - basic
    '/EmbeddedDocument /MC3 BDC q EMC',      # optional content - named dict
    '/foo BMC BT ET EMC',     # Marked content - empty
    '/bar BMC BT B* ET EMC',  # Marked content + text block - empty
    '/baz BMC B* EMC',        # BT .. ET  Text block - with valid content

    '(hello world) Tj',   # Tj        showText

    $test_image_block,

    'BX this stuff gets ignored EX',
    'BX this stuff gets BX doubly EX ignored EX',

    '/RGB gs',
    '/foo <</bar 42>> DP',
    '/MyForm Do',
    'F',
    '/gg G',
    '2 J',
    '.1  0.2  0.30  .400  K',
    '0.35 M',
    '/here MP',
    'Q',
    '.3 .5 .7 RG',
    'S',
    '.1  0.2  0.30  .400  SC',
    '0.30 0.75 0.21 /P2 SCN',
    'T*',
    '200 100 TD',
    '[(hello) (world)] TJ',
    '13 TL',
    '4.5 Tc',
    '20 15 Td',
    '/TimesRoman 12 Tf',
    '9 0 0 9 476.48 750 Tm',
    '2 Tr',
    '1.7 Ts',
    '2.5 Tw',
    '0.7 Tz',
    'W',
    'W*',
    'b',
    'b*',
    '.1 .2 .3 4. 5. 6.0 c',
    '.1 .2 .3 4. 5. 6.0 cm',
    '/RGB cs',
    '[1 2] 2 d',
    '.67 1.2 d0',
    '.1 .2 .3 4. 5. 6.0 d1',
    'f',
    'f*',
    '.7 g',
    '/Gs1 gs',
    'h',
    '2 i',
    '3 j',
    '.7 .3 .2 .05 k',
    '20 30 l',
    '100 125 m',
    'n',
    'q',
    '20 50 30 60 re',
    '.7 2. .5 rg',
    '/foo ri',
    's',
    '.2 .35 .7 .9 sc',
    '0.30 0.75 0.21 /P2 scn',
    '/bar sh',
    '.1 .2 .3 .4 v',
    '1.35 w',
    '.1 .2 .3 .4 y',
    ) {
    ok($_ ~~ /^<PDF::Grammar::Content::instruction>$/, "instruction")
	or do {
	    diag "failed instruction: $_";
	    if ($_ ~~ /^(.*?)(<PDF::Grammar::Content::instruction>)(.*?)$/) {

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
    '20 (hi) "',      # too few args
    '10 (hi) 20 "',   # type mismatch (wrong order)
    'crud',           # unknown operator
    'B ET',           # unbalanced text block
    'BT B',           # unbalanced text block
    'BT B ET ET',     # unbalanced text block
    'BT 42 ET',       # Text block incomplete content
    'BT BT ET ET',    # Text block nested
    '/foo BMC BT EMC ET',     # Marked content - incorrect text nesting
    '/bar BMC /baz BMC B* EMC EMC',  # Marked content - nested
    '/foo BMC BT ET EMC EMC',   # Marked content - extra end
    '/BMC BT B* ET EMC',        # Marked content mising arg
    '/baz BMC (hi) EMC',        # Marked content - incomplete contents
##todo    'BX BX EX',                 # BX ... EX incorrect nesting (extra BX)
    'BX EX EX',                 # BX ... EX incorrect nesting (extra EX)
    ) {
    # test our parser's resilience
    ok($_ !~~ /^<PDF::Grammar::Content::instruction>$/,
       "invalid instruction: $_");
    ok($_ ~~ /<PDF::Grammar::Content::unknown>/,
       "unknown operator(s)");
}

my $sample_content1 = '/RGB CS';

my $sample_content2 = '9 0 0 9 476.48 750 Tm';

my $sample_content3 = '[(Using this Guide)-13.5( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .)-257.1( xiii)]TJ';

my $sample_content4 = q:to/END4/;
/GS1 gs
BT
  /TT6 1 Tf
  9 0 0 9 476.48 750 Tm
  0 g
  0 Tc
  0 Tw
  (Some random test opcodes)Tj
  1.6111 -1.2222 TD
  (version 10.0)Tj
  -42.5533 -77.3778 TD
  (Doc. Revision 1.0)Tj
  45.04 0 TD
  (Page i)Tj
ET
.25 .085 0 .25 K
2 J 0 j .51 w 3.86 M [] 0 d
1 i 
q 1 0 0 1 540 54 cm 0 0 m
-432 0 l
S
Q
/EmbeddedDocument /MC3 BDC
  q
  66.184 0 0 29 474.55 705.39 cm
  /Im3 Do
  Q
EMC
BT
  /TT2 1 Tf
  22 0 0 22 108 676.53 Tm
  -.01 Tc
  (Contents)Tj
  12 0 0 12 108 641.2 Tm
  0 Tc
  [(Using this Guide)-13.5( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .)-257.1( xiii)]TJ
  /TT8 1 Tf
  .0909 Tw
  [( ...almost there)]TJ
  -37.9318 -1.2727 TD
  0 Tw
ET
END4

my $sample_content5 = q:to/END5/;    # example from [PDF 1.7] Section 7.8
0.0 G					% Set stroking colour to black
1.0 1.0 0.0 rg				% Set nonstroking colour to yellow
25 175 175 -150 re			% Construct rectangular path
f					% Fill path
/Cs12 cs				% Set pattern colour space
0.77 0.20 0.00 /P1 scn			% Set nonstroking colour and pattern
99.92 49.92 m				% Start new path
99.92 77.52 77.52 99.92 49.92 99.92 c	% Construct lower-left circle
22.32 99.92 -0.08 77.52 -0.08 49.92 c
-0.08 22.32 22.32 -0.08 49.92 -0.08 c
77.52 -0.08 99.92 22.32 99.92 49.92 c
B					% Fill and stroke path
0.2 0.8 0.4 /P1 scn			% Change nonstroking colour
224.96 49.92 m				% Start new path
224.96 77.52 202.56 99.92 174.96 99.92 c% Construct lower-right circle
147.36 99.92 124.96 77.52 124.96 49.92 c
124.96 22.32 147.36 -0.08 174.96 -0.08 c
202.56 -0.08 224.96 22.32 224.96 49.92 c
B					% Fill and stroke path
0.3 0.7 1.0 /P1 scn			% Change nonstroking colour
87.56 201.70 m				% Start new path
63.66 187.90 55.46 157.30 69.26 133.4 c	% Construct upper circle
83.06 109.50 113.66 101.30 137.56 115.10 c
161.46 128.90 169.66 159.50 155.86 183.40 c
142.06 207.30 111.46 215.50 87.56 201.70 c
B					% Fill and Stroke path
0.5 0.2 1.0 /P1 scn			% Change nonstroking colour
50 50 m					% Start new path
175 50 l				% Construct triangular path
112.5 158.253 l
b					% Close, fill, and stroke path
END5

for ($sample_content1, $sample_content2, $sample_content3, $sample_content4) {
    my $p = PDF::Grammar::Content.parse($_);
    ok($p, "parsed pdf content")
       or diag ("unable to parse: $_");
}

done;
