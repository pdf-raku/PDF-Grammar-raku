#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Function;
use PDF::Grammar::Function::Actions;

my $trivial_expr = '{6 7 mul}';

my $example_expr = '{ 360 mul sin
  2 div
  exch 360 mul sin
  2 div
  add
}';

my $if_expr = '{ 1 1 add 3 eq ' ~ $example_expr ~' if }';

my $if_else_expr = '{false ' ~ $if_expr ~' {(booya!)} ifelse}';

my $actions = PDF::Grammar::Function::Actions.new;

for (trivial => $trivial_expr,
     example => $example_expr,
     if => $if_expr,
     if_else => $if_else_expr,
    ) {
    my $p = PDF::Grammar::Function.parse($_.value, :actions($actions));

    ok($p, "function parse " ~ $_.key)
        or diag $_.value;

    diag "****" ~ $p.ast.perl;
}

done;
