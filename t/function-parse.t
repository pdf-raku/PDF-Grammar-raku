#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Function;
use PDF::Grammar::Function::Actions;

my $trivial_expr = '{6 7 mul}';
my $trivial_ast = (expr => [6, 7, "mul"]);

my $example_expr = '{ 360 mul sin
  2 div
  exch 360 mul sin
  2 div
  add
}';

my $example_ast = (expr => [360, "mul", "sin", 2, "div", "exch", 360, "mul", "sin", 2, "div", "add"]);

my $if_expr = '{ 1 1 add 3 eq ' ~ $example_expr ~' if }';
my $if_ast = (expr => [1, 1, "add", 3, "eq", {"if" => "expr" => [360, "mul", "sin", 2, "div", "exch", 360, "mul", "sin", 2, "div", "add"]}]);

my $if_else_expr = '{2 1 1 add eq {7 6 mul} {(booya!)} ifelse}';
my $if_else_ast = (expr => [2, 1, 1, "add", "eq", {"if" => "expr" => [7, 6, "mul"], "else" => "expr" => ["booya!"]}]);

my $restricted_ops = '{ 360 sin <</x [exch]>> def }';
my $restricted_ast = (expr => [360, "sin", "??" => {"x" => ["exch"]}, "??" => "def"]);
my $actions = PDF::Grammar::Function::Actions.new;

for (trivial =>    {input => $trivial_expr,   ast => $trivial_ast},
     example =>    {input => $example_expr,   ast => $example_ast},
     if =>         {input => $if_expr,        ast => $if_ast},
     if_else =>    {input => $if_else_expr,   ast => $if_else_ast},
     unexpected => {input => $restricted_ops, ast => $restricted_ast},
    ) {
    my $test = $_.value;
    my $input = %$test<input> // die "malformed test";
    my $p = PDF::Grammar::Function.parse($input, :actions($actions));

    is($p.Str, $input, "function parse " ~ $_.key)
        or diag $input;

    my $expected_ast = %$test<ast>;

    if defined $expected_ast  {
        is($p.ast, $expected_ast, 'AST ' ~ $_.key)
            or diag $p.ast.perl;
    }
    else {
        diag "****" ~ $p.ast.perl;
    }
}

done;
