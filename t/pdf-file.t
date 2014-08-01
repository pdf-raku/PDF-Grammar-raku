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

my $pdf-body = slurp( $pdf-file );
my $p = PDF::Grammar::PDF.parse($pdf-body);

ok($p, "parsed pdf content ($pdf-file)");

done;
