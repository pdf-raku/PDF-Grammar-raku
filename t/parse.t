#!/usr/bin/env perl6

use Test;
use PDF::Grammar::Simple;

for ('%PDF-1.0', '%PDF-1.7') {
    ok($_ ~~ /^<PDF::Grammar::Simple::header>$/, "header: $_");
}

my $header = '%PDF-1.0';
ok($header ~~ /^<PDF::Grammar::Simple::header>$/, "header: $header");

my $body = '1 0 obj
<<
/Type /Catalog
/Pages 3 0 R
/Outlines 2 0 R
>>
endobj
2 0 obj
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
ok($body ~~ /^<PDF::Grammar::Simple::body>$/, "body")
    or diag $body;

my $xref = "xref
0 8
0000000000 65535 f
0000000009 00000 n
0000000074 00000 n
0000000120 00000 n
0000000179 00000 n
0000000322 00000 n
0000000415 00000 n
0000000445 00000 n
";
ok($xref ~~ /^<PDF::Grammar::Simple::xref>$/, "xref")
    or diag $xref;

my $trailer = 'trailer
<<
/Size 8
/Root 1 0 R
>>
startxref
553
';
ok($trailer ~~ /^<PDF::Grammar::Simple::trailer>$/, "trailer")
    or diag $trailer;

my $simple_pdf = "$header
$body
$xref$trailer%\%EOF";

my $edited_pdf = "$header
$body
$xref$trailer
$body
$xref$trailer%\%EOF";

for ($simple_pdf, $edited_pdf) {
    ok($_ ~~ /^<PDF::Grammar::Simple::pdf>$/, "pdf")
       or diag $_;
}

done;
