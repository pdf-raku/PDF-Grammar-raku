#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;

my $test_image_block = 'BI                  % Begin inline image object
    /W 17           % Width in samples
    /H 17           % Height in samples
    /CS /RGB        % Colour space
    /BPC 8          % Bits per component
    /F [/A85 /LZW]  % Filters
ID                  % Begin image data
J1/gKA>.]AN&J?]-<HW]aRVcg*bb.\eKAdVV%/PcZ
%…Omitted data…
%R.s(4KE3&d&7hb*7[%Ct2HCqC~>
EI';

# test individual ops
for (
    '10 20 (hi) "',      # "         moveShow

    "(hello) '",         # '         show

    'B',                 # B         fillStroke

    'B*',                # B*        EOFfillStroke

    'BT ET',             # BT .. ET  Text block - empty
    'BT B* ET',          # BT .. ET  Text block - with valid content

    '/foo <</MP /yup>> BDC BT ET EMC',     # optional content - empty
    '/foo <</MP /yup>> BDC (hello) Tj EMC',     # optional content - basic

    '/foo BMC BT ET EMC',     # Marked content - empty
    '/bar BMC BT B* ET EMC',  # Marked content + text block - empty
    '/baz BMC B* EMC',        # BT .. ET  Text block - with valid content

    '(hello world) Tj',   # Tj        showText

    $test_image_block,
    ) {
    ok($_ ~~ /^<PDF::Grammar::Content::statement>$/, "statement")
	or do {
	    diag "failed statement: $_";
	    if ($_ ~~ /^(.*?)(<PDF::Grammar::Content::statement>)(.*?)$/) {

		my $p = $0 && $0.join(',');
		note "(preceeding: $p)" if $p;
		my $m = $1 && $1.join(',');
		note "(best match: $m)" if $m;
		my $f = $2 && $2.join(',');
		note "(following: $f)" if $f;
	    }
    }
}

# invalid cases
for (
    '20 (hi) "',      # too few args
    '10 (hi) 20 "',   # type mismatch (wrong order)
    'crud',           # unknown operator
    'B ET',           # unbalanced text block
    'BT B',           # unbalanced text block
    'BT B ET ET',     # unbalanced text block
    'BT 42 ET',       # Text block incomplete content
    'BT BT ET ET',    # Text block nested
    '/foo BMC BT EMC ET',     # Marked content - empty
    '/bar BMC /baz BMC B* EMC EMC',  # Marked content - nested
    '/foo BMC BT ET EMC EMC',   # Marked content - closed out of order
    '/BMC BT B* ET EMC',        # Marked content mising arg
    '/baz BMC (hi) EMC',        # Marked content - incomplete contents

    ) {
    ok($_ !~~ /^<PDF::Grammar::Content::statement>$/,
       "not statement: $_");
}

##my $sample_content = q:to/END/;
##END

##my $p = PDF::Grammar::Content.parse($sample_content);
##ok($p, "parsed pdf content");

done;
