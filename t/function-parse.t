#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Function;

my $trivial_expr = '{42}';

my $example_expr = '{ 360 mul sin
  2 div
  exch 360 mul sin
  2 div
  add
}';

my $if_expr = '{ 1 1 add 3 eq ' ~ $example_expr ~' if }';

my $if_else_expr = '{false ' ~ $if_expr ~' {(booya!)} ifelse}';

for (trivial => $trivial_expr,
     example => $example_expr,
     if => $if_expr,
     if_else => $if_else_expr,

    ) {
    my $p = PDF::Grammar::Function.parse($_.value);

    ok($p, "function parse " ~ $_.key)
        or diag $_.value; 
}

done;
