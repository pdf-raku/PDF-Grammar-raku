#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;

my $sample_image = q:to/end_image/;
BI                  % Begin inline image object
    /W 17           % Width in samples
    /H 17           % Height in samples
    /CS /RGB        % Colour space
    /BPC 8          % Bits per component
    /F [/A85 /LZW]  % Filters
ID                  % Begin image data
J1/gKA>.]AN&J?]-<HW]aRVcg*bb.\eKAdVV%/PcZ
…Omitted data…
R.s(4KE3&d&7hb*7[%Ct2HCqC~>
EI
end_image

# test individual ops
for (
    '10 20 (hi) "',      # "         moveShow

    "(hello) '",         # '         show

    'B',                 # B         fillStroke

    'B*',                # B*        EOFfillStroke

    'BT ET',             # BT .. ET  Text block - empty
    'BT B* ET',          # BT .. ET  Text block - with valid content

    '/foo /bar BDC BT ET EMC',     # optional content - empty
    '/foo /bar BDC (hello) Tj EMC',     # optional content - basic

    '/foo BMC BT ET EMC',     # Marked content - empty
    '/bar BMC BT B* ET EMC',  # Marked content + text block - empty
    '/baz BMC B* EMC',        # BT .. ET  Text block - with valid content

    '(hello world) Tj',   # Tj        showText
    ) {
    ok($_ ~~ /^<PDF::Grammar::Content::statement>$/,
       "op: $_");
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
    '/foo BMC BT ET EMC EMC',   # Marked content - bad nesting
    '/BMC BT B* ET EMC',        # Marked content mising arg
    '/baz BMC (hi) EMC',        # Marked content - incomplete contents

    ) {
    ok($_ !~~ /^<PDF::Grammar::Content::op>$/,
       "not op: $_");
}

##my $sample_content = q:to/END/;
##END

##my $p = PDF::Grammar::Content.parse($sample_content);
##ok($p, "parsed pdf content");

done;
