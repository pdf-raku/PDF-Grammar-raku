use v6;

use PDF::Grammar::Actions;

# rules for constructing PDF::Grammar::PDF AST

class PDF::Grammar::PDF::Actions is PDF::Grammar::Actions {

    method TOP($/) { make $<pdf>.ast }

    method pdf($/) {
        my %pdf;

        %pdf<header> = $<pdf-header>.ast;

        my @contents = $<body>>>.ast;
        %pdf<body> = @contents;

        make %pdf;
    }

    method pdf-header ($/) { make $<version>.Num }
    method pdf-tail ($/) { make $<trailer>.ast }

    method trailer ($/) {
        make { dict => $<dict>.ast,
               byte-offset => $<byte-offset>.ast };
    }

    method indirect-ref($/) {
        my @ind_ref = $/.caps.map({ .value.ast });
        make (ind_ref => @ind_ref);
    }

    method indirect-obj($/) {
        my @ind_obj = $/.caps.map({ .value.ast });
        make (ind_obj => @ind_obj);
    }

    method object:sym<indirect-ref>($/)  { make $<indirect-ref>.ast }

    method object:sym<dict>($/) {

        if ($<stream>) {
            # <dict> is a just a header the following <stream>
            my %stream;
            %stream<dict> = $<dict>.ast;
            (%stream<start>, %stream<end>) = $<stream>[0].ast.kv;
            make (stream => %stream)
        }
        else {
            # simple stand-alone <dict>
            make $<dict>.ast;
        }
    }

    method body($/) {
        my %body;
        my @indirect-objs = $<indirect-obj>>>.ast;
        %body<objects> = @indirect-objs;
        %body<xref> = .ast
            for $<xref>;
        %body<trailer> = .ast
            for $<trailer>;

        make %body;
    }

    method xref($/) {
        my @sections = $<xref-section>>>.ast;
        make @sections;
    }

    method digits($/) { make $/.Int }

    method xref-section($/) {
        my %section;
        %section<object-first-num> = $<object-first-num>.ast;
        %section<object-count> = $<object-count>.ast;
        my @entries = $<xref-entry>>>.ast;
        %section<entries> = @entries;
        make %section;
    }

    method xref-entry($/) {
        my %entry;
        %entry<offset> = $<byte-offset>.ast;
        %entry<gen> = $<gen-number>.ast;
        %entry<status> = $<obj-status>.Str;

        make %entry;
    }

   # we don't actually capture streams, which can be huge and represent
   # the majority of data in a typical PDF. Rather we just return the byte
   # offsets of the start and the end of the stream and leave it up to the
   # caller to disseminate

    method stream($/) {
        make (($<stream-head>.to + 1) => ($<stream-tail>.from - 1));
    }
}
