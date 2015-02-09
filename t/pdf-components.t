#!/usr/bin/env perl6

use Test;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

my $pdf-header-version = 1.5;
my $header = "%PDF-{$pdf-header-version}";

for ('%PDF-1.0', $header) {
     ok($_ ~~ /^<PDF::Grammar::PDF::header>$/, "pdf header: $_");
}

my $ind-obj1 = '1 0 obj
<<
/Type /Catalog
/Pages 3 0 R
/Outlines 2 0 R
>>
endobj
';

my $body = $ind-obj1 ~
'2 0 obj
<<
/Type /Outlines
/Count 0
>>
endobj
3 0 obj
<<
/Type /Pages
/Count 1
/Kids [4 0 R]
>>
endobj
4 0 obj
<<
/Type /Page
/Parent 3 0 R
/Resources << /Font << /F1 7 0 R >>/ProcSet 6 0 R
>>
/MediaBox [0 0 612 792]
/Contents 5 0 R
>>
endobj
5 0 obj
<< /Length 44 >>
stream
BT
/F1 24 Tf
100 100 Td (Hello, world!) Tj
ET
endstream
endobj
6 0 obj
[/PDF /Text]
endobj
7 0 obj
<<
/Type /Font
/Subtype /Type1
/Name /F1
/BaseFont /Helvetica
/Encoding /MacRomanEncoding
>>
endobj';

for ($ind-obj1) {
    ok($_ ~~ /^<PDF::Grammar::PDF::ind-obj>$/, "indirect object")
        or diag $_;
}

for ($ind-obj1, $body) {
    ok($_ ~~ /^<PDF::Grammar::PDF::ind-obj>+$/, "body")
        or diag $_;
}

my $xref = join("\n", "xref",
"0 8",
"0000000000 65535 f" ~ " ",
"0000000009 00000 n" ~ " ",  # trailing space
"0000000074 00000 n",        # no trailing space
"0000000120 00000 n",
"0000000179 00000 n",
"0000000322 00000 n",
"0000000415 00000 n",
"0000000445 00000 n",
"");

ok($xref ~~ /^<PDF::Grammar::PDF::xref>$/, "xref")
    or diag $xref;

my $trailer = 'trailer
<<
/Size 8
/Root 1 0 R
>>
';

my $footer = 'startxref
553
';
ok($trailer ~~ /^<PDF::Grammar::PDF::trailer>$/, "trailer")
    or diag $trailer;

my $nix-pdf = "$header
$body
$xref$trailer$footer%\%EOF";

my $bin-commented-pdf = "$header
%âãÏÓ
$body
$xref$trailer$footer%\%EOF";

my $edited-pdf-small = "$header
$ind-obj1
$xref$trailer$footer
{$ind-obj1.subst(/0/, '9'):g}
{$xref.subst(/0/, '9'):g}$trailer$footer%\%EOF";

my $edited-pdf = "$header
$body
$xref$trailer$footer
$body
$xref$trailer$footer%\%EOF";

(my $mac-osx-pdf = $nix-pdf)  ~~ s:g/\n/\r/;
# nb although the document remains parsable, converting to ms-dos line-endings
# changes byte offsets and corrupts the xref table
(my $ms-dos-pdf = $nix-pdf)  ~~ s:g/\n/\r\n/;

my $actions = PDF::Grammar::PDF::Actions.new;

for (unix => $nix-pdf,
     bin-comments => $bin-commented-pdf,
     edit-history-small => $edited-pdf-small,
     edit-history => $edited-pdf,
     mac-osx-formatted => $mac-osx-pdf,
     ms-dos-formatted => $ms-dos-pdf,
     ) {

     my $p = PDF::Grammar::PDF.parse(.value, :$actions);
     ok($p, "pdf parse - " ~ .key)
       or diag .value;

     my $pdf-ast = $p.ast;
     is $pdf-ast<header><version>, $pdf-header-version, "pdf version - as expected";
     ok $pdf-ast<body>, "pdf has body";

     # see if we can independently locate the trailer (parse)
     my $tail = .value.substr(*-64);
     my $tail-p = PDF::Grammar::PDF.subparse($tail, :rule<postamble>, :$actions);
     ok $tail-p, "pdf postamble parse - " ~ .key
       or note '...' ~ $tail;
     my $trailer-ast = $tail-p.ast;
     is $trailer-ast.key, 'startxref', '<startxref> in trailer ast'
         or diag :$trailer-ast.perl;
}

done;
