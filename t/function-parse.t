#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Function;
use PDF::Grammar::Function::Actions;
use PDF::Grammar::Test;

my $trivial-expr = '{6 7 mul}';
my $trivial-ast = (expr => [ :int(6), :int(7), :op<mul> ]);

my $example-expr = '{ 360 mul sin
  2 div
  exch 360 mul sin
  2 div
  add
}';

my $example-ast = (:expr[ :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<exch>, :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<add>]);

my $if-expr = '{ 1 1 add 3 eq ' ~ $example-expr ~' if }';
my $if-ast = ( :expr[ :int(1), :int(1), :op<add>, :int(3), :op<eq>, :expr{if => :expr[ :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<exch>, :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<add>]}]);

my $if-else-expr = '{2 1 1 add eq {7 6 mul} {(booya!)} ifelse}';
my $if-else-ast = ( :expr[:int(2), :int(1), :int(1), :op<add>, :op<eq>,
			  :expr{ if => :expr[ :int(7), :int(6), :op<mul>], else => :expr[ :literal<booya!> ]}]);

my $restricted-ops = '{ 360 sin <</x [exch]>> def }';
my $restricted-ast = :expr[ :int(360), :op<sin>, "??" => :dict{x => :array[ :op<exch> ]}, "??" => "def"];
my $actions = PDF::Grammar::Function::Actions.new;

for ([ :$trivial-expr, $trivial-ast],
     [ :$example-expr, $example-ast],
     [ :$if-expr, $if-ast ],
     [ :$if-else-expr, $if-else-ast ],
     [ :$restricted-ops, $restricted-ast],
    ) {
    my $name = .[0].key;
    my %expected = input => .[0].value, ast => .[1];
    
    my $input = %expected<input> // die "malformed test";

    PDF::Grammar::Test::parse-tests(PDF::Grammar::Function, $input, :$actions, :rule('TOP'),
                                    :suite("functions - $name"), :%expected );
}

done-testing;
