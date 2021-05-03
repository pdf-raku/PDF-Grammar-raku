#!/usr/bin/env raku
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

my PDF::Grammar::PDF $p .= parse: slurp($pdf-file, :bin).decode("latin-1");

ok $p, "parsed pdf content ($pdf-file)";

done-testing;
