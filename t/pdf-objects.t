#!/usr/bin/env perl6

use Test;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

use PDF::Grammar::Test;

my $header = '%PDF-1.3';
my $header-ast = { :type<PDF>, :version(1.3) };

my $ind-ref1 =  '3 0 R';
my $ind-ref1-ast = :ind-ref[ 3, 0 ];

my $ind-obj-dict = "1 0 obj
<<
/Type /Catalog
/Pages {$ind-ref1}
/Outlines 2 0 R
>>
endobj";
my $ind-obj-dict-ast = :ind-obj[ 1, 0, :dict{ Type => :name<Catalog>,
                                         Pages => $ind-ref1-ast,
                                         Outlines => :ind-ref[ 2, 0 ]}];

my $stream-content = 'BT
  /F1 24 Tf  % useless comment
  100 100 Td (Hello, world!) Tj
ET';
my $stream-length = $stream-content.chars;

my $ind-obj-stream-nibble = "5 0 obj
<< /Length $stream-length >>
stream
";

my $ind-obj-stream = $$ind-obj-stream-nibble ~ $stream-content ~ "
endstream
endobj
";

my $ind-obj-stream-nibble-ast = :ind-obj[ 5, 0,
                             :stream{
                                 :dict{Length => :int(68)}, :start(32),
                             }];

my $ind-obj-stream-ast = :ind-obj[ 5, 0,
                             :stream{
                                 :dict{Length => :int(68)},
				 :encoded("BT\n  /F1 24 Tf  % useless comment\n  100 100 Td (Hello, world!) Tj\nET"),
                             }];

my $body = $ind-obj-dict ~ "\n" ~
$ind-obj-stream ~
'3 0 obj
<<
  /Type /Outlines
  /Count 0
>>
endobj
4 2 obj
[/PDF /Text]
endobj';

my $body-objects-ast = [$ind-obj-dict-ast,
                        :ind-obj[ 5, 0, :stream{
                                            :dict{Length => :int(68)},
			                    :encoded("BT\n  /F1 24 Tf  % useless comment\n  100 100 Td (Hello, world!) Tj\nET"),
                                         }],
                        :ind-obj[ 3, 0, :dict{Type => :name<Outlines>, Count => :int(0) }],
                        :ind-obj[ 4, 2, :array[ :name<PDF>, :name<Text> ]]];

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
my $xref-ast = [
                {:obj-first-num(0),
                 :obj-count(8),
                 :entries[{:offset(0), :gen-num(65535),  :type(0)},
                          {:offset(9), :gen-num(0), :type(1)},
                          {:offset(74), :gen-num(0), :type(1)},
                          {:offset(120), :gen-num(0), :type(1)},
                          {:offset(179), :gen-num(0), :type(1)},
                          {:offset(322), :gen-num(0), :type(1)},
                          {:offset(415), :gen-num(0), :type(1)},
                          {:offset(445), :gen-num(0), :type(1)}]
               },
              ];

my $xref-first = "\x[A]0000000000 65535 f 
0000000018 00000 n 
2 3
0000000077 00000 n 
0000000178 00000 n 
0000000457 00000 n 
";

my $xref-multiple = "xref
0 2$xref-first";

my $xref-multiple-ast = [
                {:obj-first-num(0),
                 :obj-count(2),
                 :entries[{:offset(0), :gen-num(65535),  :type(0)},
                          {:offset(18), :gen-num(0), :type(1)},
                         ]
               },

                {:obj-first-num(2), :obj-count(3),
                 entries => [{:offset(77), :gen-num(0), :type(1)},
                             {:offset(178), :gen-num(0), :type(1)},
                             {:offset(457), :gen-num(0), :type(1)},
                            ]
               },
              ];

my $xref-empty = "xref
0 0
";

my $xref-empty-ast = [
    {:obj-first-num(0),
     :obj-count(0),
     :entries[],
    },
];

# note: extra newline between trailer and trailer dict - as observed in pdftk
my $trailer = 'trailer

<<
/Size 8
/Root 1 0 R
>>
';

my $trailer-ast = { :dict{ Size => :int(8),
                           Root => :ind-ref[ 1, 0 ]},
                  };

my $startxref = 'startxref
553
';

my $startxref-ast = :startxref(553);

my $body-ast = :body{objects => $body-objects-ast, :xref($xref-ast), trailer => $trailer-ast, $startxref-ast};

my $pdf = "$header
$body
$xref$trailer$startxref%\%EOF";

my $actions = PDF::Grammar::PDF::Actions.new;

my $object-stream-index = "125 0 126 28 127 81 128 109 ";
my $object-stream-index-ast = [[125, 0], [126 ,28], [127, 81], [128, 109]];

my $body-input = [~] ($body, "\n", $xref, $trailer,  $startxref);

my $index-ast = {:trailer($trailer-ast), :xref($xref-ast) };

for (
      { :rule<header>,  :input($header),     :ast($header-ast)},
      { :rule<ind-ref>,  :input($ind-ref1),  :ast($ind-ref1-ast)},
      { :rule<ind-obj>,  :input($ind-obj-dict),  :ast($ind-obj-dict-ast)},
      { :rule<ind-obj>,  :input($ind-obj-stream),  :ast($ind-obj-stream-ast)},
      { :rule<ind-obj-nibble>,  :input($ind-obj-dict),  :ast($ind-obj-dict-ast)},
      { :rule<ind-obj-nibble>,  :input($ind-obj-stream-nibble),  :ast($ind-obj-stream-nibble-ast)},
      { :rule<trailer>,  :input($trailer),    ast => :trailer($trailer-ast)},
      { :rule<startxref>,  :input($startxref),     :ast($startxref-ast)},
      { :rule<xref>,  :input($xref),          ast => :xref($xref-ast)},
      { :rule<xref>,  :input($xref-multiple), ast => :xref($xref-multiple-ast)},
      { :rule<xref>,  :input($xref-empty), ast => :xref($xref-empty-ast)},
      { :rule<xref-first>,  :input($xref-first), ast => :xref($xref-multiple-ast)},
      { :rule<body>,  :input($body-input),  :ast($body-ast)},
      { :rule<index>,  :input($xref ~ "\n" ~ $trailer), :ast($index-ast) },
      { :rule<pdf>,  :input($pdf), ast => Any},
      { :rule<object-stream-index>,  :input($object-stream-index),  :ast($object-stream-index-ast)},
    ) -> % ( :$rule!, :$input, *%expected ) {
     # normalise lines for Win platforms
     my $in = $input.subst(/\n/, "\n", :g);

     PDF::Grammar::Test::parse-tests(PDF::Grammar::PDF, $in, :$rule, :$actions, :suite('pdf doc'), :%expected );
}

done-testing;
