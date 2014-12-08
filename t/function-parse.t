#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Function;
use PDF::Grammar::Function::Actions;
use PDF::Grammar::Test;

my $trivial_expr = '{6 7 mul}';
my $trivial_ast = (expr => [ :int(6), :int(7), :op<mul> ]);

my $example_expr = '{ 360 mul sin
  2 div
  exch 360 mul sin
  2 div
  add
}';

my $example_ast = (:expr[ :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<exch>, :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<add>]);

my $if-expr = '{ 1 1 add 3 eq ' ~ $example_expr ~' if }';
my $if_ast = ( :expr[ :int(1), :int(1), :op<add>, :int(3), :op<eq>, {if => :expr[ :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<exch>, :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<add>]}]);

my $if_else-expr = '{2 1 1 add eq {7 6 mul} {(booya!)} ifelse}';
my $if_else_ast = ( :expr[:int(2), :int(1), :int(1), :op<add>, :op<eq>, {"if" => :expr[ :int(7), :int(6), :op<mul>], "else" => :expr[ :literal<booya!> ]}]);

my $restricted_ops = '{ 360 sin <</x [exch]>> def }';
my $restricted_ast = :expr[ :int(360), :op<sin>, "??" => :dict{x => :array[ :op<exch> ]}, "??" => "def"];
my $actions = PDF::Grammar::Function::Actions.new;

for (trivial =>    {input => $trivial_expr,   ast => $trivial_ast},
     example =>    {input => $example_expr,   ast => $example_ast},
     if =>         {input => $if-expr,        ast => $if_ast},
     if_else =>    {input => $if_else-expr,   ast => $if_else_ast},
     unexpected => {input => $restricted_ops, ast => $restricted_ast},
    ) {
    my %expected = %( .value );
    my $input = %expected<input> // die "malformed test";

    PDF::Grammar::Test::parse-tests(PDF::Grammar::Function, $input, :$actions, :rule('TOP'),
                                    :suite('functions'), :%expected );
}

done;
