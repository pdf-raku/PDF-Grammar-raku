#!/usr/bin/env perl6

use Test;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

my $header = '%PDF-1.3';

my $indirect_obj1 = '1 0 obj
<<
/Type /Catalog
/Pages 3 0 R
/Outlines 2 0 R
>>
endobj
';

my $indirect_obj2 = '5 0 obj
<< /Length 44 >>
stream
BT
/F1 24 Tf
100 100 Td (Hello, world!) Tj
ET
endstream
endobj
';

my $body = $indirect_obj1 ~
$indirect_obj2 ~
'3 0 obj
<<
  /Type /Outlines
  /Count 0
>>
endobj
4 0 obj
<<
  /Type /Pages
  /Count 1
  /Kids [4 0 R]
>>
endobj
5 0 obj
<<
  /Type /Page
  /Parent 3 0 R
  /Resources << /Font << /F1 7 0 R >>/ProcSet 6 0 R
  >>
  /MediaBox [0 0 612 792]
  /Contents 5 0 R
>>
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

my $trailer = 'trailer
<<
/Size 8
/Root 1 0 R
>>
startxref
553
';

my $pdf = "$header
$body
$xref$trailer%\%EOF";

my $actions = PDF::Grammar::PDF::Actions.new;

for (
      pdf_header => $header,
      indirect_object => $indirect_obj1,
      indirect_object => $indirect_obj2,
      trailer => $trailer,
      xref => $xref,
      content => $body ~ "\n" ~ $trailer,
      pdf => $pdf,
    ) {
     my $rule = $_.key;
     my $str = $_.value;
     my $p = PDF::Grammar::PDF.parse($str, :rule($rule), :actions($actions)),

     ok($p, "pdf parse - rule: " ~ $rule)
       or do {diag $str; next};

     diag {$rule => $p.ast}.perl;
}

done;
