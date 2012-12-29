#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;

# test individual ops
for (
    '10 20 (hi) "',      # "     moveShow
    "(hello) '",         # '     show
    'B',                 # B     fillStroke
    '(hello world) Tj'   # Tj    showText
    ) {
    ok(PDF::Grammar::Content.parse($_),
       "op parse: $_");
}

# invalid cases
for (
    '20 (hi) "',      # too few args
    '10 (hi) 20 "',   # type mismatch (wrong order)
    'crud',           # unknown operator
    ) {
    ok( !PDF::Grammar::Content.parse($_),
       "invalid op: $_");
}

##my $sample_content = q:to/END/;
##END

##my $p = PDF::Grammar::Content.parse($sample_content);
##ok($p, "parsed pdf content");

done;
