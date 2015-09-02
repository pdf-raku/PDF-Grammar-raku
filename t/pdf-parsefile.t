#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::PDF;

my $pdf-file = %*ENV<TEST_PDF>;
if ($pdf-file) {
    diag "loading $pdf-file";
}
else {
    $pdf-file = 't/helloworld.pdf';
    diag "loading $pdf-file (set \$TEST_PDF to override)";
}

my $p = PDF::Grammar::PDF.parsefile($pdf-file);

ok($p, "parsed pdf content ($pdf-file)");

done-testing;
