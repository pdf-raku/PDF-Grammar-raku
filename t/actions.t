#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;
use PDF::Grammar::Actions;

my $sample_content1 = '(Hello World\043) Tj';

for ($sample_content1) {
    my $p = PDF::Grammar::Content.parse($_, :actions(PDF::Grammar::Actions.new));
    ok($p, "parsed pdf content")
       or diag ("unable to parse: $_");
    say $p.ast;
}

done;
