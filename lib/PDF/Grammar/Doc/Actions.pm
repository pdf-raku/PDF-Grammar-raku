use v6;

use PDF::Grammar::Actions;

# rules for constructing PDF::Grammar::PDF AST

class PDF::Grammar::Doc::Actions
    is PDF::Grammar::Actions {
 
    has Bool $.get-offsets is rw = False; #| return ind-obj byte offsets in AST

    method TOP($/) { make $<pdf>.ast.value }

    method pdf($/) {
        my $header = $<header>.ast;
	my $body = [ $<body>>>.ast.map({ .value.item }) ];
        make 'pdf' => {
	    :$header,
	    :$body,
        }
    }
    method doc-type($/) {
        make $/.uc
    }

    method header($/)    {
        my $type = $<doc-type>.ast;
        my $version = $<version>.Rat;
        make { :$type, :$version }
    }

    method postamble($/) {
        my %postamble;
        %postamble<startxref> = $<byte-offset>.ast.value
            if $<byte-offset>;
        %postamble<trailer> = $<trailer>.ast.value
            if $<trailer>;

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

        if ($<stream>) {
            # <dict> is a just a header the following <stream>
            my %stream = $<dict>.ast.kv;
            (%stream<start>, %stream<end>) = $<stream>.ast.flat;
            make (:%stream)
        }
        else {
            # simple stand-alone <dict>
            make $<dict>.ast;
        }
    }

    method body($/) {
        my %body = (:objects[ $<ind-obj>>>.ast ],
                    ($<startxref> ?? $<startxref>.ast !! () ),
                    ($<index>.defined ?? @( $<index>.ast ) !! () ),
            );

        make (:%body);
    }

    method index($/) {
        my %index = ($<xref>.defined ?? $<xref>.ast !! (),
                     $<trailer>.ast);
        make %index;
    }

    method xref($/) {
	my $sections = [ $<xref-section>>>.ast ];
	make (:xref($sections));
    }

    method xref-section($/) {
        my @entries = $<xref-entry>».ast;
        make {
	    object-first-num => $<object-first-num>.ast.value,
	    object-count => $<object-count>.ast.value,
	    :@entries,
        }
    }

    method xref-entry($/) {
        make {
            type   => $<obj-status>.ast,
            offset => $<byte-offset>.ast.value,
            gen-num  => $<gen-number>.ast.value,
            };
    }

    method obj-status:sym<free>($/)  { make 0}
    method obj-status:sym<inuse>($/) { make 1}

   # don't actually capture streams, which can be huge and represent
   # the majority of data in a typical PDF. Rather just return the byte
   # offsets of the start and the end of the stream and leave it up to
   # the caller to disseminate

    method stream($/) {
        make [ $<stream-head>.to, $<stream-tail>.from - 1 ];
    }
}
