#!/usr/bin/env perl6

use Test;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

use lib '.';
use t::AST;

my $header = '%PDF-1.3';
my $header_ast = 1.3;

my $ind_ref1 =  '3 0 R';
my $ind_ref1_ast = "ind_ref" => [3, 0];

my $ind_obj1 = "1 0 obj
<<
/Type /Catalog
/Pages {$ind_ref1}
/Outlines 2 0 R
>>
endobj
";
my $ind_obj1_ast = "ind_obj" => [1, 0, {"Type" => "Catalog", "Pages" => $ind_ref1_ast, "Outlines" => 'ind_ref' => [2, 0]}];

my $stream_content = 'BT
  /F1 24 Tf  % useless comment
  100 100 Td (Hello, world!) Tj
ET';
my $stream_length = $stream_content.chars;

my $ind_obj2 = "5 0 obj
<< /Length $stream_length >>
stream
$stream_content
endstream
endobj
";
my $ind_obj2_ast = "ind_obj" => [5, 0, "stream" => {"atts" => {"Length" => 68}, "start" => 33, "end" => 99}];

my $body = $ind_obj1 ~
$ind_obj2 ~
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
my $xref_ast = [{"object_first_num" => 0, "object_count" => 8, "entries" => [{"offset" => 0, "gen" => 65535, "status" => "f"}, {"offset" => 9, "gen" => 0, "status" => "n"}, {"offset" => 74, "gen" => 0, "status" => "n"}, {"offset" => 120, "gen" => 0, "status" => "n"}, {"offset" => 179, "gen" => 0, "status" => "n"}, {"offset" => 322, "gen" => 0, "status" => "n"}, {"offset" => 415, "gen" => 0, "status" => "n"}, {"offset" => 445, "gen" => 0, "status" => "n"}]}];

my $trailer = 'trailer
<<
/Size 8
/Root 1 0 R
>>
startxref
553
';

my $trailer_ast = "trailer" => {"dict" => {"Size" => 8, "Root" => "ind_ref" => [1, 0]}, "byte_offset" => 553};

my $pdf = "$header
$body
$xref$trailer%\%EOF";

my $actions = PDF::Grammar::PDF::Actions.new;

for (
      pdf_header => {input => $header, ast => $header_ast},
      indirect_ref => {input => $ind_ref1, ast => $ind_ref1_ast},
      indirect_obj => {input => $ind_obj1, ast => $ind_obj1_ast},
      indirect_obj => {input => $ind_obj2, ast => $ind_obj2_ast},
      trailer => {input => $trailer, ast => $trailer_ast},
      xref => {input => $xref, ast => $xref_ast},
      body => {input => $body ~ "\n" ~ $trailer},
      pdf => {input => $pdf},
    ) {
     my $rule = $_.key;
     my %test = $_.value;
     my $input = %test<input>;

     my $p = PDF::Grammar::PDF.parse($input, :rule($rule), :actions($actions)),

    t::AST::parse_tests($input, $p, :rule($rule), :suite('css3'),
                         :expected(%test) );
}

done;
