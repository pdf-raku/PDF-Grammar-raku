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

    'BX this stuff gets ignored EX',
    'BX this stuff gets BX doubly EX ignored EX',

    '/RGB CS',
    '/foo <</bar 42>> DP',
    '/MyForm Do',
    'F',
    '/gg G',
    '2 J',
    '.1  0.2  0.30  .400  K',
    '0.35 M',
    '/here MP',
    'Q',
    '.3 .5 .7 RG',
    'S',
    '.1  0.2  0.30  .400  SC',
    '0.30 0.75 0.21 /P2 SCN',
    'T*',
    '200 100 TD',
    '[(hello) (world)] TJ',
    ) {
    ok($_ ~~ /^<PDF::Grammar::Content::instruction>$/, "instruction")
	or do {
	    diag "failed instruction: $_";
	    if ($_ ~~ /^(.*?)(<PDF::Grammar::Content::instruction>)(.*?)$/) {

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
##todo    'BX BX EX',                 # BX ... EX incorrect nesting (extra BX)
    'BX EX EX',                 # BX ... EX incorrect nesting (extra EX)
    ) {
    ok($_ !~~ /^<PDF::Grammar::Content::instruction>$/,
       "invalid instruction: $_");
}

##my $sample_content = q:to/END/;
##END

##my $p = PDF::Grammar::Content.parse($sample_content);
##ok($p, "parsed pdf content");

done;
