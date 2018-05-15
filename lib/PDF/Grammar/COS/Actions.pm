use v6;

use PDF::Grammar::Actions;

# rules for constructing PDF::Grammar::PDF AST

class PDF::Grammar::COS::Actions
    is PDF::Grammar::Actions {

    has Bool $.get-offsets is rw = False; #| return ind-obj byte offsets in AST

    method TOP($/) { make $<cos>.ast.value }

    method cos($/) {
        my $header = $<header>.ast;
	my $body = [ $<body>>>.ast.map({ .value }) ];
        make 'cos' => {
	    :$header,
	    :$body,
        }
    }
    method doc-type($/) {
        make $/.Str
    }

    method header($/)    {
        my $type = $<doc-type>.ast;
        my $version = $<version>.Rat;
        make { :$type, :$version }
    }

    method postamble($/) {
        my %postamble;
        %postamble<startxref> = .ast.value
            with $<byte-offset>;
        %postamble.push: .ast
            with $<trailer>;

        make %postamble;
    }

    method trailer($/)   {
	make (:trailer($<dict>.ast))
    }

    method startxref($/)   {
	make (:startxref($<byte-offset>.ast.value))
    }

    method ind-ref($/) {
        my $obj-num = $<obj-num>.ast.value;
        my $gen-num = $<gen-num>.ast.value;
        my $ind-ref = [ $obj-num, $gen-num ];
        make (:$ind-ref);
    }

    method ind-obj($/) {
        my $obj-num = $<obj-num>.ast.value;
        my $gen-num = $<gen-num>.ast.value;
        my $ind-obj = [ $obj-num, $gen-num, $<object>.ast ];
        $ind-obj.push: $/.from
            if self.get-offsets;
        make (:$ind-obj)
    }

    method object:sym<ind-ref>($/)  { make $<ind-ref>.ast }

    method object:sym<dict>($/) {
        with $<stream> {
            # <dict> is a just a header the following <stream>
            my %stream = $<dict>.ast;
	    %stream<encoded> = .ast;
            make (:%stream)
        }
        else {
            make $<dict>.ast;
        }
    }

    method body($/) {
        my $objects = [ $<ind-obj>>>.ast ];
        my %body = :$objects;
        %body.push: .ast with $<startxref>;
        %body.push: .ast with $<index>;
        make (:%body);
    }

    method index($/) {
        my %index = $<trailer>.ast;
        %index.push: .ast with $<xref>;
        make %index;
    }

    method xref($/) {
	my $xref = [ $<xref-section>>>.ast ];
	make (:$xref);
    }

    method xref-section($/) {
        my UInt $obj-count = $<obj-count>.ast.value;
        my UInt $obj-first-num = $<obj-first-num>.ast.value;
        my List $rows = $<xref-entry>».ast.List;

        unless $rows {
            # RT131965 - rakudo doesn't like shaped arrays of length 0
            $rows = (array[uint64].new(0, 65535, 0), );
            $obj-count++ unless $obj-count;
        }
        my uint64 @entries[+$rows; 3] = $rows;
        make { :$obj-first-num, :$obj-count, :@entries };
    }

    method xref-entry($/) {
        my uint64 @entry = $<byte-offset>.ast.value, $<gen-number>.ast.value, $<obj-status>.ast;
        make @entry;
    }

    method obj-status:sym<free>($/)  { make 0 }
    method obj-status:sym<inuse>($/) { make 1 }

    method stream($/) {
        my $start = $<stream-head>.to;
        my $len = $<stream-tail>.from - $start;
        $start -= $/.from;
        make $/.substr($start, $len)
    }

    method ind-obj-nibble($/) {
        my $object = $<object>.ast;
        if $<stream-head> {
            # locate the start of the stream data following the 'stream' token. The
            # invokee can deterime the length using the /Length entry in the dictionary
	    my $start = (~$/).codes;
            $object = :stream( %( %$object, :$start, ));
        }
        make (:ind-obj[ $<obj-num>.ast.value, $<gen-num>.ast.value, $object ]);
    }

    method object-stream-indice($/) { make [$<obj-num>.ast.value, $<byte-offset>.ast.value] }
    method object-stream-index($/)  { make [ $<object-stream-indice>>>.ast ] }

}
