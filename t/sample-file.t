#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Simple;

my $test_pdf = %*ENV<TEST_PDF>;
if ($test_pdf) {
    diag "loading $test_pdf";
}
else {
    $test_pdf = 't/helloworld.pdf';
    diag "loading $test_pdf (set \$TEST_PDF to override)";
}

my $fh = open $test_pdf, :bin
    or die "unable to open $fh: $!";

my $pdf_content = join("\n", $fh.lines);
$fh.close;

my $p = PDF::Grammar::Simple.parse($pdf_content);

ok($p, "parsed pdf content ($test_pdf)");

done;
