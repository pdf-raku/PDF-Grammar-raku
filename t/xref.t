#!/usr/bin/env perl6

use Test;
use PDF::Grammar::Simple::Xref;

for ("\r\n", " \n", " \r") {
    ok($_ ~~ /^<PDF::Grammar::Simple::Xref::eol>$/, "xref_eol: $_");
}

for ("0000000003 65535 f \n", "0000000409 00000 n\r\n") {
    ok($_ ~~ /^<PDF::Grammar::Simple::Xref::entry>$/, "xref_entry: $_");
}

my $xref = "xref
0 6
0000000003 65535 f\r
0000000017 00000 n\r
0000000081 00000 n\r
0000000000 00007 f\r
0000000331 00000 n\r
0000000409 00000 n\r
";

for ($xref) {
    ok($_ ~~ /^<PDF::Grammar::Simple::Xref::xref>$/, "xref")
        or diag $_;
}

done;
