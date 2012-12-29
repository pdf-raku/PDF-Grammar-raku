#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;

# test individual ops
for (
    '10 20 (hi) "',      # "         moveShow

    "(hello) '",         # '         show

    'B',                 # B         fillStroke

    'B*',                # B*        EOFfillStroke

    'BT ET',             # BT .. ET  Text block - empty
    'BT BT ET ET',       # BT .. ET  Text block - empty nested
    'BT ET',             # BT .. ET  Text block - empty
    'BT B* ET',          # BT .. ET  Text block - with valid content

    '/foo /bar BDC BT ET EMC',     # optional content - empty
    '/foo /bar BDC (hello) Tj EMC',     # optional content - basic

    '/foo BMC BT ET EMC',     # Marked content - empty
    '/bar BMC BT B* ET EMC',  # Marked content + text block - empty
    '/baz BMC B* EMC',        # BT .. ET  Text block - with valid content

    '(hello world) Tj'   # Tj        showText
    ) {
    ok($_ ~~ /^<PDF::Grammar::Content::op>$/,
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
