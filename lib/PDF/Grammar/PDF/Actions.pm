use v6;

use PDF::Grammar::Actions;

# rules for constructing PDF::Grammar::PDF AST

class PDF::Grammar::PDF::Actions
    is PDF::Grammar::Actions {

    method TOP($/) { make $<pdf>.ast }

    method pdf($/) {
	my $body = [ $<body>>>.ast ];
        make {
	    header => $<pdf-header>.ast,
	    body => $body,
        }
    }

    method pdf-header ($/) { make $<version>.Rat }
    method pdf-tail ($/) { make $<trailer>.ast }

    method trailer ($/) {
	make {
	    dict => $<dict>.ast.value,
	    ( $<byte-offset> ??  offset => $<byte-offset>.ast.value !! () ),
	};
    }

    method indirect-ref($/) {
        my @ind_ref = $/.caps.map( *.value.ast );
        make 'ind-ref' => [ $<obj-num>.ast.value, $<gen-num>.ast.value ];
    }

    method indirect-obj($/) {
        my @ind_obj = $/.caps.map( *.value.ast );
        make 'ind-obj' => [ $<obj-num>.ast.value, $<gen-num>.ast.value, $<object>>>.ast ];
    }

    method object:sym<indirect-ref>($/)  { make $<indirect-ref>.ast }

    method object:sym<dict>($/) {

        if ($<stream>) {
            # <dict> is a just a header the following <stream>
            my %stream;
            %stream<dict> = $<dict>.ast.value;
            (%stream<start>, %stream<end>) = $<stream>.ast.kv;
            make (stream => %stream)
        }
        else {
            # simple stand-alone <dict>
            make $<dict>.ast;
        }
    }

    method body($/) {
	my $objects = [ $<indirect-obj>>>.ast ];
        make {
	    objects => $objects,
            trailer => $<trailer>.ast,
	    ($<xref> ?? xref => $<xref>.ast !! () ),
       }
    }

    method xref($/) {
	my $sections = [ $<xref-section>>>.ast ];
	make $sections;
    }

    method xref-section($/) {
        my @entries = $<xref-entry>».ast;
        make {
	    object-first-num => $<object-first-num>.ast,
	    object-count => $<object-count>.ast,
	    entries => @entries,
        }
    }

    method xref-entry($/) {
        make {
            offset => $<byte-offset>.ast.value,
            gen    => $<gen-number>.ast.value,
            status => $<obj-status>.lc,
            };
    }

   # don't actually capture streams, which can be huge and represent
   # the majority of data in a typical PDF. Rather just return the byte
   # offsets of the start and the end of the stream and leave it up to
   # the caller to disseminate

    method stream($/) {
        make (($<stream-head>.to + 1) => ($<stream-tail>.from - 1));
    }
}
