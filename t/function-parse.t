#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Function;
use PDF::Grammar::Function::Actions;
use PDF::Grammar::Test :parse-tests;

my $trivial-expr = '{6 7 mul}';
my $trivial-ast = (expr => [ :int(6), :int(7), :op<mul> ]);
my $trivial-ast-lite = (expr => [ 6, 7, :op<mul> ]);

my $example-expr = '{ 360 mul sin
  2 div
  exch 360 mul sin
  2 div
  add
}';

my $example-ast = (:expr[ :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<exch>, :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<add>]);
my $example-ast-lite = (:expr[ 360, :op<mul>, :op<sin>, 2, :op<div>, :op<exch>, 360, :op<mul>, :op<sin>, 2, :op<div>, :op<add>]);

my $if-expr = '{ 1 1 add 3 eq ' ~ $example-expr ~' if }';
my $if-ast = ( :expr[ :int(1), :int(1), :op<add>, :int(3), :op<eq>, :cond{if => :expr[ :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<exch>, :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<add>]}]);
my $if-ast-lite = ( :expr[ 1, 1, :op<add>, 3, :op<eq>, :cond{if => :expr[ 360, :op<mul>, :op<sin>, 2, :op<div>, :op<exch>, 360, :op<mul>, :op<sin>, 2, :op<div>, :op<add>]}]);

my $if-else-expr = '{2 1 1 add eq {7 6 mul} {42} ifelse}';
my $if-else-ast = ( :expr[:int(2), :int(1), :int(1), :op<add>, :op<eq>,
			  :cond{ if => :expr[ :int(7), :int(6), :op<mul>], else => :expr[ :int(42) ]}]);
my $if-else-ast-lite = ( :expr[2, 1, 1, :op<add>, :op<eq>,
			  :cond{ if => :expr[ 7, 6, :op<mul>], else => :expr[ 42 ]}]);

my $restricted-ops = '{ 360 sin <</x [exch]>> def }';
my $restricted-ast = :expr[ :int(360), :op<sin>, "??" => :dict{x => :array[ :op<exch> ]}, "??" => "def"];
my $restricted-ast-lite = :expr[ 360, :op<sin>, "??" => :dict{x => :array[ :op<exch> ]}, "??" => "def"];

my $radix-numbers = '{2#101010 4#222 8#52 16#2a 32#1A}';
my $radix-ast = :expr[ :int(42) xx 5 ];
my $radix-ast-lite = :expr[ 42 xx 5 ];

my PDF::Grammar::Function::Actions $actions .= new;
my PDF::Grammar::Function::Actions $lite-actions .= new: :lite;

for ([ :$trivial-expr, $trivial-ast, $trivial-ast-lite],
     [ :$example-expr, $example-ast, $example-ast-lite],
     [ :$if-expr, $if-ast, $if-ast-lite ],
     [ :$if-else-expr, $if-else-ast, $if-else-ast-lite ],
     [ :$restricted-ops, $restricted-ast, $restricted-ast-lite],
     [ :$radix-numbers, $radix-ast, $radix-ast-lite],
    ) {
    my $name = .[0].key;
    my %expected = input => .[0].value, ast => .[1];

    my $input = %expected<input> // die "malformed test";

    parse-tests(PDF::Grammar::Function, $input, :$actions, :rule('TOP'),
                :suite("functions - $name"), :%expected );

    with .[2] {
        %expected<ast> = $_;
         parse-tests(PDF::Grammar::Function, $input, :actions($lite-actions), :rule('TOP'),
                     :suite("functions - $name lite"), :%expected );
    }
}

done-testing;
