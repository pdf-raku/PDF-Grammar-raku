#!/usr/bin/env perl6

use Test;
use PDF::Grammar::PDF;

# integers
for ('123', '43445', '+17', '-98', '0') {
    ok($_ ~~ /^<PDF::Grammar::PDF::int>$/, "int: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::number>$/, "number: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::object>$/, "object: $_");
}
# reals
for ('1234567890.', '.0', '34.5', '-3.62', '+123.6', '4.', '-.002', '0.0') {
    ok($_ !~~ /^<PDF::Grammar::PDF::int>$/, "not int: $_");
    ok($_  ~~ /^<PDF::Grammar::PDF::number>$/, "number: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::object>$/, "object: $_");
}
# some invalid cases (exponential format not allowed)
for ('', '123A', '.', '. 42', '16#FFFE', '6.02E23') {
    ok($_ !~~ /^<PDF::Grammar::PDF::number>$/, "not number: $_");
    ok($_ !~~ /^<PDF::Grammar::PDF::object>$/, "not object: $_");
}

# bool
for ('true', 'false') {
    ok($_ ~~ /^<PDF::Grammar::PDF::object>$/, "object: $_");
}
ok(''           !~~ /^<PDF::Grammar::PDF::object>$/, 'not object: blank');

# hex strings
ok('<Af309>'     ~~ /^<PDF::Grammar::PDF::hex-string>$/, 'hex: basic');
ok('<Af309>'     ~~ /^<PDF::Grammar::PDF::object>$/, 'hex object: basic');
ok('<4E6F762073686D6F7A206B6120706F702E>'     ~~ /^<PDF::Grammar::PDF::hex-string>$/, 'hex: example ');
ok('<901FA3>'     ~~ /^<PDF::Grammar::PDF::hex-string>$/, 'hex: example 2a (90, 1F, A3)');
ok('<901FA>'     ~~ /^<PDF::Grammar::PDF::hex-string>$/, 'hex: example 2b (90, 1F, A0)');
# - multiline hex strings - found in the field
ok('<304B66CBD3DCBEC4CA8EA2B66D8DACF1F6FBC1D2E2A4B2C052708FE9EBED4F62
77BFD5EB7A99B8A4BBD26A7B8DDEE9F5B6CEE744586E8AA7C5C4D7EC97B4D2FF>'  ~~ /^<PDF::Grammar::PDF::hex-string>$/, 'hex: multiline');

# - hex strings - counter examples
ok('<x>'        !~~ /^<PDF::Grammar::PDF::hex-string>$/, 'not hex illegal char');

# literal strings
# -- escaped
for ('\n', '\r', '\t', '\b', '\f', '\(', '\(', '\40', '\040') {
    ok(($_~'X') ~~ /^<PDF::Grammar::PDF::literal>X$/, "literal char escaped: $_");
    ok("($_)"   ~~ /^<PDF::Grammar::PDF::literal-string>$/, "literal string: ($_)");
}

# [pdf 1.7] section 7.2.4.2 example 5:
# -- '\0053' :== \005 + '3'
ok('\0053' ~~ /^<PDF::Grammar::PDF::literal>3$/, "literal escaped char followed by numeric");
# -- '\005' :== '\05' :== \005
ok('\005' ~~ /^<PDF::Grammar::PDF::literal>$/, "literal escaped 3 octal digits");
ok('\05' ~~ /^<PDF::Grammar::PDF::literal>$/, "literal escaped 2 octal digits");

do {
    # TODO: some octal escaping cases - not clear from spec
    # (check handling by gs, xpdf, acroreader)";
   ok('\5X' ~~ /^<PDF::Grammar::PDF::literal>X$/, "literal escaped 1 octal digit"); 
   ok('\059' ~~ /^<PDF::Grammar::PDF::literal>9$/, "literal escaped 2 octal digits - followed by non-octal/decimal digit"); 
}

# -- regular
for ('a', '}', ' ') {
    ok($_      ~~ /^<PDF::Grammar::PDF::literal>$/, "literal char regular: $_");
    ok("($_)"  ~~ /^<PDF::Grammar::PDF::literal-string>$/, "literal string: ($_)");
}

for (
    # -- example strings from [pdf 1.7] Section 7.3.4.2
    '(42)',
    '(This is a string)',
    "(Strings may contain newlines\nand such.)",
    '(Strings may contain balanced parentheses ( ) and\nspecial characters (*!&}^% and so on).)',
    '(The following is an empty string.)',
    '()',
    '(It has zero (0) length.)',
    "(These \\\ntwo strings \\\nare the same.)",
    '(These two strings are the same.)',
    "(This string has an end-of-line at the end of it.\n)",
    '(So does this one.\n)',
    '(This string contains \245two octal characters\307.)',
    # -- a few extras
    "(\n)",
    "(\\\n)",
    "(\\\n()\n)",
    "(These (\\\ntwo strings) \\\nare the same.)",
    '(These (two strings) are the same.)',       
    '(This \( is unmatched)',
    ) {
    ok($_     ~~ /^<PDF::Grammar::PDF::literal-string>$/, "literal string: $_");
}

# name strings

for (
    # examples from PDF Reference
    '/Name1',
     '/ASomewhatLongerName',
     '/A;Name_With-Various***Characters?',
     '/1.2',
     '/$$',
     '/@pattern',
     '/.notdef',
     '/lime#20Green',
     '/paired#28#29parentheses',
     '/The_Key_of_F#23_Minor',
     '/A#42',
      # a few picked up in the field
     '/Times-Roman',
    ) {
    ok($_ ~~ /^<PDF::Grammar::PDF::name>$/, "name: $_");
}

ok('/Name1' ~~ /^<PDF::Grammar::PDF::object>$/, "object: /Name1");
ok('[/Name1]' ~~ /^<PDF::Grammar::PDF::array>$/, "array: [/Name1]");

ok('/a[/b]/c' ~~ /^<PDF::Grammar::PDF::name><PDF::Grammar::PDF::array><PDF::Grammar::PDF::name>$/, "parse: /a[/b]/c");

my $id_plus_array = '/ID[<81b14aafa313db63dbd6f981e49f94f4>
<81b14aafa313db63dbd6f981e49f94f4>
]';
ok($id_plus_array ~~ /^<PDF::Grammar::PDF::name><PDF::Grammar::PDF::array>$/, "parse: $id_plus_array");

for ('[]', '[ ]', '[42]', '[/Name]', '[42/Name]', '[49 3.14 false (Ralph) /SomeName]') {
    ok($_ ~~ /^<PDF::Grammar::PDF::array>$/, "array: $_");
}

my $with-hex-strings = "<< /Size 22
/Root 2 0 R/Info 1 0 R/ID[<81b14aafa313db63dbd6f981e49f94f4>
<81b14aafa313db63dbd6f981e49f94f4>
]
>>";

my $nested-dictionary = 
"<</Type /Example
  /Subtype /DictionaryExample
  /Version 0.01
  /IntegerItem 12
  /StringItem (a string)
  /Subdictionary << /Item1 0.4
                    /Item2 true
                    /LastItem (not!)
                    /VeryLastItem (OK)
                 >>
>>";

my $sans-whitespace = 
'<</BaseFont/Times-Roman/Type/Font
/Subtype /Type1>>';

# nested stream - seems that this can happen in practice
my $nested-stream =
"<</Type /Example
  /Subtype /NestedStreamTest
  /StreamDict << /Length 22 >>
  stream
Nested stream - yikes!
  endstream
  /NowWhereWasI (?)
>>";

for (empty1 => '<<>>', empty2 => '<< >>', trival => '<</id 42>>',
     trivial2 => '<</a 1 /b (2)>>', :$with-hex-strings,
     :$nested-dictionary, :$sans-whitespace, :$nested-stream) {
    ok(.value ~~ /^<PDF::Grammar::PDF::dict>$/, "dict " ~ .key)
    or diag $_;
}

for ('/BaseFont/Times-Roman', '/Producer(AFPL Ghostscript 8.51)', '/X<</Y(42)>>', '/Z#20[[1]]', '/a/b%comment') {
    ok($_ ~~ /^<PDF::Grammar::PDF::name><PDF::Grammar::PDF::object>$/, "name + object: $_");
}

my $empty = "<< /Length 0 >>
stream

endstream
";

# hopefully always at least two newlines shouldn't have to handle this
my $this_stream-is_invalid_I_think = "<< /Length 0 >>
stream
endstream
";

my $tiny = "<< /Length 4 >>
stream
TEST
endstream
";

my $smallish = "<< /Length 44 >>
stream
BT
/F1 24 Tf
100 100 Td (Hello, world!) Tj
ET
endstream
";

# pushing spec boundaries
my $content3 = "abc123\n"~chr(0xFF)~chr(0)~'z endstream! - not really!';

my $non-ascii = sprintf "<< /Length %d >>
stream
%s
endstream
", $content3.codes, $content3;

# have observed endstream without a proceeding eol
my $no-eoln = sprintf "<< /Length %d >>
stream
%sendstream
", $content3.chars, $content3;

my $indirect-object-reference = '<< /Length 8 0 R >>% An indirect reference to object 8
stream
BT
/F1 12 Tf
72 712 Td
(A stream with an indirect length) Tj
ET
endstream
';

my $medium-size = q{<< /Length 534
/Filter [/ASCII85Decode /LZWDecode]
>>
stream
J..)6T`?p&<!J9%_[umg"B7/Z7KNXbN'S+,*Q/&"OLT'F
LIDK#!n`$"<Atdi`\Vn%b%)&'cA*VnK\CJY(sF>c!Jnl@
RM]WM;jjH6Gnc75idkL5]+cPZKEBPWdR>FF(kj1_R%W_d
&/jS!;iuad7h?[L-F$+]]0A3Ck*$I0KZ?;<)CJtqi65Xb
Vc3\n5ua:Q/=0$W<#N3U;H,MQKqfg1?:lUpR;6oN[C2E4
ZNr8Udn.'p+?#X+1>0Kuk$bCDF/(3fL5]Oq)^kJZ!C2H1
'TO]Rl?Q:&'<5&iP!$Rq;BXRecDN[IJB`,)o8XJOSJ9sD
S]hQ;Rj@!ND)bD_q&C\g:inYC%)&u#:u,M6Bm%IY!Kb1+
":aAa'S`ViJglLb8<W9k6Yl\\0McJQkDeLWdPN?9A'jX*
al>iG1p&i;eVoK&juJHs9%;Xomop"5KatWRT"JQ#qYuL,
JD?M$0QP)lKn06l1apKDC@\qJ4B!!(5m+j.7F790m(Vj8
8l8Q:_CZ(Gm1%X\N1&u!FKHMB~>
endstream
};

for (:$empty, :$tiny, :$smallish,
     :$non-ascii, :$no-eoln,
     :$indirect-object-reference,
     :$medium-size) {
    my $test = .key;
    my $val = .value;

    ok($val ~~ /^<PDF::Grammar::PDF::dict> <PDF::Grammar::PDF::stream-head>/, "$test stream - head match");
    ok($val ~~ /<PDF::Grammar::PDF::stream-tail>$/, "$test stream - tail match");
    my $ind-obj = "42 0 obj $val endobj";
    ok($ind-obj ~~ /^<PDF::Grammar::PDF::ind-obj-nibble>/, "$test stream - ind-obj-nibble");
    ok($ind-obj !~~ /^<PDF::Grammar::PDF::ind-obj-nibble>$/, "$test stream - ind-obj-nibble");
    ok($ind-obj ~~ /^<PDF::Grammar::PDF::ind-obj>$/, "$test stream - ind-obj")
    or diag $ind-obj;
}

my $simple = "10 0 obj
(Brillig) % blah blah blah
endobj";
my $ind-ref1 = '10 0 R';
my $ind-ref2 = '20 1 R';
my $ind-ref3 = '013 01 R';

for ($ind-ref1, $ind-ref2, $ind-ref3) {
    ok($_ ~~ /^<PDF::Grammar::PDF::ind-ref>$/, "ind-ref: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::object>$/, "object: $_");
}

my $squashed1 = '13 0 obj<</BaseFont/Times-Roman/Type/Font/Subtype/Type1>>endobj';
my $stream = "7 0 obj
<< /Length 8 0 R >>% An indirect reference to object 8
stream
BT
/F1 12 Tf
72 712 Td
(A stream with an indirect length) Tj
ET
endstream
endobj";

my $comments = '8 0 obj
% hello
77% The length of the preceding stream
% goodbye
endobj';

my $fdf = '1 0 obj
<</FDF
    << /F (empty.pdf) /Fields [] >>
>>
endobj';

my $squashed2 = '1 0 obj<</FDF<</F(Document.pdf)/ID[<7a0631678ed475f0898815f0a818cfa1><bef7724317b311718e8675b677ef9b4e>]/Fields[<</T(Street)/V(345 Park Ave.)>><</T(City)/V(San Jose)>>]>>>> 
endobj';

for (:$simple, :$squashed1, :$squashed2,
    :$stream, :$comments, :$fdf,
     ) {
    ok(.value ~~ /^<PDF::Grammar::PDF::ind-obj>$/, "ind-obj - " ~ .key)
        or diag .value;
    ok(.value ~~ /^<PDF::Grammar::PDF::ind-obj-nibble>/, "ind-obj-nibble - " ~ .key)
}

# null
for ('null') {
    ok($_ ~~ /^<PDF::Grammar::PDF::object>$/, "object: $_");
}

done-testing;
