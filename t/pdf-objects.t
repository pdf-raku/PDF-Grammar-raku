#!/usr/bin/env perl6

use Test;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

use PDF::Grammar::Test;

my $header = '%PDF-1.3';
my $header-ast = { :type<PDF>, :version(1.3) };

my $ind-ref1 =  '3 0 R';
my $ind-ref1-ast = :ind-ref[ 3, 0 ];

my $ind-obj1 = "1 0 obj
<<
/Type /Catalog
/Pages {$ind-ref1}
/Outlines 2 0 R
>>
endobj
";
my $ind-obj1-ast = :ind-obj[ 1, 0, :dict{ Type => :name<Catalog>,
                                         Pages => $ind-ref1-ast,
                                         Outlines => :ind-ref[ 2, 0 ]}];

my $stream-content = 'BT
  /F1 24 Tf  % useless comment
  100 100 Td (Hello, world!) Tj
ET';
my $stream-length = $stream-content.chars;

my $ind-obj2 = "5 0 obj
<< /Length $stream-length >>
stream
$stream-content
endstream
endobj
";
my $ind-obj2-ast = :ind-obj[ 5, 0,
                             :stream{
                                 :dict{Length => :int(68)}, :start(32), :end(99)
                             }];

my $body = $ind-obj1 ~
$ind-obj2 ~
'3 0 obj
<<
  /Type /Outlines
  /Count 0
>>
endobj
4 2 obj
[/PDF /Text]
endobj';

my $body-objects-ast = [$ind-obj1-ast,
                        :ind-obj[ 5, 0, :stream{ :dict{Length => :int(68)},
                                                 :start(97),
                                                 :end(164)}],
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
                {:object-first-num(0),
                 :object-count(8),
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

my $xref-multiple = "xref
0 2
0000000000 65535 f 
0000000018 00000 n 
2 3
0000000077 00000 n 
0000000178 00000 n 
0000000457 00000 n 
";

my $xref-multiple-ast = [
                {:object-first-num(0),
                 :object-count(2),
                 :entries[{:offset(0), :gen-num(65535),  :type(0)},
                          {:offset(18), :gen-num(0), :type(1)},
                         ]
               },

                {:object-first-num(2), :object-count(3),
                 entries => [{:offset(77), :gen-num(0), :type(1)},
                             {:offset(178), :gen-num(0), :type(1)},
                             {:offset(457), :gen-num(0), :type(1)},
                            ]
               },
              ];


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


for (
      header => { :input($header),     :ast($header-ast)},
      ind-ref => { :input($ind-ref1),  :ast($ind-ref1-ast)},
      ind-obj => { :input($ind-obj1),  :ast($ind-obj1-ast)},
      ind-obj => { :input($ind-obj2),  :ast($ind-obj2-ast)},
      trailer => { :input($trailer),    ast => :trailer($trailer-ast)},
      startxref => { :input($startxref),     :ast($startxref-ast)},
      xref => { :input($xref),          ast => :xref($xref-ast)},
      xref => { :input($xref-multiple), ast => :xref($xref-multiple-ast)},
      body => {input => $body-input,  :ast($body-ast)},
      pdf => { :input($pdf), ast => Any},
      object-stream-index => { :input($object-stream-index),  :ast($object-stream-index-ast)},
    ) {
     my $rule = .key;
     my %expected = %( .value );
     my $input = %expected<input>;

     PDF::Grammar::Test::parse-tests(PDF::Grammar::PDF, $input, :$rule, :$actions, :suite('pdf doc'), :%expected );
}

done;
