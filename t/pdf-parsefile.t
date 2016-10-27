#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::PDF;

my $pdf-file = 't/helloworld.pdf';
with %*ENV<TEST_PDF> {
    $pdf-file = $_;
    diag "loading $pdf-file";
}
else {
    diag "loading $pdf-file (set \$TEST_PDF to override)";
}

my $p = PDF::Grammar::PDF.parsefile($pdf-file);

ok $p, "parsed pdf content ($pdf-file)";

done-testing;
