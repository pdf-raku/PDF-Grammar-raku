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
	    dict => $<dict>.ast,
	    ( $<byte-offset> ??  byte-offset => $<byte-offset>.ast !! () ),
	};
    }

    method indirect-ref($/) {
        my @ind_ref = $/.caps.map( *.value.ast );
        make (ind_ref => @ind_ref);
    }

    method indirect-obj($/) {
        my @ind_obj = $/.caps.map( *.value.ast );
	make (ind_obj => @ind_obj);
    }

    method object:sym<indirect-ref>($/)  { make $<indirect-ref>.ast }

    method object:sym<dict>($/) {

        if ($<stream>) {
            # <dict> is a just a header the following <stream>
            my %stream;
            %stream<dict> = $<dict>.ast;
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

    method digits($/) { make $/.Int }

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
            offset => $<byte-offset>.ast,
            gen    => $<gen-number>.ast,
            status => ~$<obj-status>,
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
