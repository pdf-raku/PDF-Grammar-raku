#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

# Proof-of concept for handling decryption via an actions subclass

sub crypt-handler(str $cipher-text, UInt :$obj-num, UInt :$gen-num ) {
    "$obj-num $gen-num R: $cipher-text";
}

class DecryptActions is PDF::Grammar::PDF::Actions {
    has $.crypt-handler;
    method string($/) {
	my $ast := $<string>.ast;

	if my &handler = $.crypt-handler and my $obj-num = $*OBJ-NUM {
	    my $gen-num = $*GEN-NUM;
	    $ast.value = &handler( $ast.value, :$obj-num, :$gen-num );
	}

	make $ast;
    }

    method stream($/) {
	my $encoded := ~$<encoded>;

	if my &handler = $.crypt-handler and my $obj-num = $*OBJ-NUM {
	    my $gen-num = $*GEN-NUM;
	    $encoded := &handler( $encoded, :$obj-num, :$gen-num );
	}

        make $encoded;
    }
}

my $ind-obj1 = q:to"--END--";
123 4 obj <<
  /Author (PDF-Grammar/t/pdf-crypt.t)
>>
endobj
--END--

my $actions = DecryptActions.new( :&crypt-handler );

my $ind-obj-ast = (:ind-obj([123, 4, :dict{:Author(:literal("123 4 R: PDF-Grammar/t/pdf-crypt.t"))}]));
PDF::Grammar::PDF.parse($ind-obj1, :rule<ind-obj>, :$actions)
  or die "unable to parse ind-obj: $ind-obj1";
my $ast = $/.ast;
is-deeply $ast, $ind-obj-ast, 'ind-obj - strings';

PDF::Grammar::PDF.subparse($ind-obj1, :rule<ind-obj-nibble>, :$actions)
  or die "unable to parse ind-obj-nibble: $ind-obj1";
$ast = $/.ast;
is-deeply $ast, $ind-obj-ast, 'ind-obj-nibble - strings';

my $ind-obj2 = q:to"--END--";
5 0 obj
<< /Length 45 >>
stream
BT
/F1 24 Tf
100 250 Td (Hello, world!) Tj
ET
endstream
endobj
--END--

PDF::Grammar::PDF.parse($ind-obj2, :rule<ind-obj>, :$actions)
  or die "unable to parse: $ind-obj2";
$ast = $/.ast;
is-deeply $ast, (:ind-obj($[5, 0, :stream({:dict(${:Length(:int(45))}),
					   :encoded("5 0 R: BT\n/F1 24 Tf\n100 250 Td (Hello, world!) Tj\nET")})])), 'streams';

done-testing;
