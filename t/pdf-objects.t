#!/usr/bin/env perl6

use Test;
use PDF::Grammar::PDF;

# integers
for ('123', '43445', '+17', '-98', '0') {
    ok($_ ~~ /^<PDF::Grammar::PDF::integer>$/, "integer: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::number>$/, "number: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::operand>$/, "operand: $_");
}
# reals
for ('1234567890.', '.0', '34.5', '-3.62', '+123.6', '4.', '-.002', '0.0') {
    ok($_ !~~ /^<PDF::Grammar::PDF::integer>$/, "not integer: $_");
    ok($_  ~~ /^<PDF::Grammar::PDF::number>$/, "number: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::operand>$/, "operand: $_");
}
# some invalid cases (exponential format not allowed)
for ('', '123A', '.', '. 42', '16#FFFE', '6.02E23') {
    ok($_ !~~ /^<PDF::Grammar::PDF::number>$/, "not number: $_");
    ok($_ !~~ /^<PDF::Grammar::PDF::operand>$/, "not operand: $_");
}

# bool
for ('true', 'false') {
    ok($_ ~~ /^<PDF::Grammar::PDF::bool>$/, "bool: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::operand>$/, "operand: $_");
}
ok(''           !~~ /^<PDF::Grammar::PDF::bool>$/, 'not bool: blank');

# hex strings
ok('<Af309>'     ~~ /^<PDF::Grammar::PDF::hex_string>$/, 'hex: basic');
ok('<Af309>'     ~~ /^<PDF::Grammar::PDF::operand>$/, 'hex operand: basic');
ok('<4E6F762073686D6F7A206B6120706F702E>'     ~~ /^<PDF::Grammar::PDF::hex_string>$/, 'hex: example ');
ok('<901FA3>'     ~~ /^<PDF::Grammar::PDF::hex_string>$/, 'hex: example 2a (90, 1F, A3)');
ok('<901FA>'     ~~ /^<PDF::Grammar::PDF::hex_string>$/, 'hex: example 2b (90, 1F, A0)');
# - multiline hex strings - found in the field
ok('<304B66CBD3DCBEC4CA8EA2B66D8DACF1F6FBC1D2E2A4B2C052708FE9EBED4F62
77BFD5EB7A99B8A4BBD26A7B8DDEE9F5B6CEE744586E8AA7C5C4D7EC97B4D2FF>'  ~~ /^<PDF::Grammar::PDF::hex_string>$/, 'hex: multiline');

# - hex strings - counter examples
ok('< ABC123>'         !~~ /^<PDF::Grammar::PDF::hex_string>$/, 'not hex whitespace lhs');
ok('<ABC123 >'         !~~ /^<PDF::Grammar::PDF::hex_string>$/, 'not hex whitespace rhs');
ok('<>'         !~~ /^<PDF::Grammar::PDF::hex_string>$/, 'not hex empty');
ok('<x>'        !~~ /^<PDF::Grammar::PDF::hex_string>$/, 'not hex illegal char');

# literal strings
# -- escaped
for ('\n', '\r', '\t', '\b', '\f', '\(', '\(', '\40', '\040') {
    ok($_      ~~ /^<PDF::Grammar::PDF::escape_seq>$/, "literal char escaped: $_");
    ok($_     !~~ /^<PDF::Grammar::PDF::literal_chars>+$/, "not literal char regular: $_");
    ok("($_)"  ~~ /^<PDF::Grammar::PDF::literal_string>$/, "literal string: ($_)");
}

# [pdf 1.7] section 7.2.4.2 example 5:
# -- '\0053' :== \005 + '3'
ok('\0053' ~~ /^<PDF::Grammar::PDF::escape_seq>3$/, "literal escaped char followed by numeric");
# -- '\005' :== '\05' :== \005
ok('\005' ~~ /^<PDF::Grammar::PDF::escape_seq>$/, "literal escaped 3 octal digits");
ok('\05' ~~ /^<PDF::Grammar::PDF::escape_seq>$/, "literal escaped 2 octal digits");

do {
    # TODO: some octal escaping cases - not clear from spec
    # (check handling by gs, xpdf, acroreader)";
   ok('\5' ~~ /^<PDF::Grammar::PDF::escape_seq>$/, "literal escaped 1 octal digit"); 
   ok('\059' ~~ /^<PDF::Grammar::PDF::escape_seq>9$/, "literal escaped 2 octal digits - followed by non-octal/decimal digit"); 
}

# -- regular
for ('a', '}', ' ') {
    ok($_      ~~ /^<PDF::Grammar::PDF::literal_chars>$/, "literal char regular: $_");
    ok($_     !~~ /^<PDF::Grammar::PDF::escape_seq>$/, "not literal char escaped: $_");
    ok($_     !~~ /^<PDF::Grammar::PDF::line_continuation>$/, "not literal line continuation: $_");
    ok("($_)"  ~~ /^<PDF::Grammar::PDF::literal_string>$/, "literal string: ($_)");
}

# -- invalid
for ('\99', '\x', '\?', ')') {
    ok($_     !~~ /^<PDF::Grammar::PDF::escape_seq>$/, "not literal escape: $_");
    ok($_     !~~ /^<PDF::Grammar::PDF::literal_chars>+$/, "not literal char regular: $_");
    ok($_     !~~ /^<PDF::Grammar::PDF::line_continuation>+$/, "not literal line_continuation: $_");
}

# -- line continuation
for ("\\\n") {
    ok($_  ~~ /^<PDF::Grammar::PDF::line_continuation>$/, "literal line continuation: $_");
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
    ok($_     ~~ /^<PDF::Grammar::PDF::literal_string>$/, "literal string: $_");
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

ok('/Name1' ~~ /^<PDF::Grammar::PDF::operand>$/, "operand: /Name1");
ok('[/Name1]' ~~ /^<PDF::Grammar::PDF::array>$/, "array: [/Name1]");

ok('/a[/b]/c' ~~ /^<PDF::Grammar::PDF::name><PDF::Grammar::PDF::array><PDF::Grammar::PDF::name>$/, "parse: /a[/b]/c");

my $id_plus_array = '/ID[<81b14aafa313db63dbd6f981e49f94f4>
<81b14aafa313db63dbd6f981e49f94f4>
]';
ok($id_plus_array ~~ /^<PDF::Grammar::PDF::name><PDF::Grammar::PDF::array>$/, "parse: $id_plus_array");

for ('[]', '[ ]', '[42]', '[/Name]', '[42/Name]', '[49 3.14 false (Ralph) /SomeName]') {
    ok($_ ~~ /^<PDF::Grammar::PDF::array>$/, "array: $_");
}

my $dict_example = "<< /Size 22
/Root 2 0 R/Info 1 0 R/ID[<81b14aafa313db63dbd6f981e49f94f4>
<81b14aafa313db63dbd6f981e49f94f4>
]
>>";

my $dict_example2 =
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

my $dict_example3 =
'<</BaseFont/Times-Roman/Type/Font
/Subtype /Type1>>';

# nested stream - seems that this can happen in practice
my $dict_example4 =
"<</Type /Example
  /Subtype /NestedStreamTest
  /StreamDict << /Length 22 >>
  stream
Nested stream - yikes!
  endstream
  /NowWhereWasI (?)
>>";

for (empty1 => '<<>>', empty2 => '<< >>', trival => '<</id 42>>',
     trivial2 => '<</a 1 /b (2)>>', example_hex => $dict_example,
     example_nested => $dict_example2, sans_whitespace => $dict_example3,
     nested_stream => $dict_example4) {
    ok($_.value ~~ /^<PDF::Grammar::PDF::dict>$/, "dict " ~ $_.key)
    or diag $_;
}

for ('/BaseFont/Times-Roman', '/Producer(AFPL Ghostscript 8.51)', '/X<</Y(42)>>', '/Z#20[[1]]', '/a/b%comment') {
    ok($_ ~~ /^<PDF::Grammar::PDF::name><PDF::Grammar::PDF::operand>$/, "name + operand: $_");
}

my $empty_stream = "<< /Length 0 >>
stream

endstream
";

# hopefully always at least two newlines shouldn't have to handle this
my $this_stream_is_invalid_I_think = "<< /Length 0 >>
stream
endstream
";

my $stream1 = "<< /Length 4 >>
stream
TEST
endstream
";

my $stream2 = "<< /Length 44 >>
stream
BT
/F1 24 Tf
100 100 Td (Hello, world!) Tj
ET
endstream
";

my $content3 = "abc123\n"~chr(255)~chr(0)~'z endstream - not';

my $stream3 = sprintf "<< /Length %d >>
stream
%s
endstream
", $content3.chars, $content3;

# have observed endstream without a proceeding eol
my $stream4 = sprintf "<< /Length %d >>
stream
%sendstream
", $content3.chars, $content3;

my $stream5 = '<< /Length 8 0 R >>% An indirect reference to object 8
stream
BT
/F1 12 Tf
72 712 Td
(A stream with an indirect length) Tj
ET
endstream
';

my $stream6 = q{<< /Length 534
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

for (empty => $empty_stream, tiny => $stream1, content => $stream2,
     non_ascii => $stream3, no_eol => $stream4, indirect => $stream5,
     sizable => $stream6) {
    my $test = $_.key;
    my $val = $_.value;
    ok($val ~~ /^<PDF::Grammar::PDF::dict> <PDF::Grammar::PDF::stream_head>/, "$test stream - head match");
    ok($val ~~ /<PDF::Grammar::PDF::stream_tail>$/, "$test stream - tail match");
    ok("$val endobj" ~~ /^<PDF::Grammar::PDF::dict> <PDF::Grammar::PDF::stream>'endobj'$/, "$test stream - full match")
    or diag $val;
}

my $ind_obj1 = "10 0 obj
(Brillig) % blah blah blah
endobj";
my $ind_ref1 = '10 0 R';

my $ind_obj2 = '20 1 obj endobj';
my $ind_ref2 = '20 1 R';

my $ind_obj3 = '13 0 obj<</BaseFont/Times-Roman/Type/Font
/Subtype/Type1>>endobj';
my $ind_ref3 = '13 0 R';

for ($ind_ref1, $ind_ref2, $ind_ref3) {
    ok($_ ~~ /^<PDF::Grammar::PDF::indirect_reference>$/, "indirect_reference: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::operand>$/, "operand: $_");
}

my $ind_obj4 = "7 0 obj
<< /Length 8 0 R >>% An indirect reference to object 8
stream
BT
/F1 12 Tf
72 712 Td
(A stream with an indirect length) Tj
ET
endstream
endobj";

my $ind_obj5 = '8 0 obj
% hello
77% The length of the preceding stream
% goodbye
endobj';

my $ind_obj_fdf = '1 0 obj
<</FDF
    << /F (empty.pdf) /Fields [] >>
>>
endobj';

for (simple => $ind_obj1, empty => $ind_obj2, squashed => $ind_obj3,
     stream => $ind_obj4, comments => $ind_obj5, fdf => $ind_obj_fdf) {
    ok($_.value ~~ /^<PDF::Grammar::PDF::indirect_object>$/, "indirect_object - " ~ $_.key)
        or diag $_.value;
}

# null
for ('null') {
    ok($_ ~~ /^<PDF::Grammar::PDF::null>$/, "null: $_");
    ok($_ ~~ /^<PDF::Grammar::PDF::operand>$/, "operand: $_");
}

done;
