use v6;

use PDF::Grammar::Actions;

# rules for constructing PDF::Grammar::PDF AST

class PDF::Grammar::PDF::Actions
    is PDF::Grammar::Actions {

    method TOP($/) { make $<pdf>.ast.value }

    method pdf($/) {
	my $bodies-ast = [ $<body>>>.ast.map({ .value.item }) ];
        make 'pdf' => {
	    header => $<header>.ast,
	    body => $bodies-ast,
        }
    }

    method header($/)    { make 'version' => $<version>.Rat }
    method postamble($/) { make 'startxref' => $<byte-offset>.ast.value }

    method trailer($/)   {
	make 'trailer' => $<dict>.ast
    }

    method startxref($/)   {
	make 'startxref' => $<byte-offset>.ast.value
    }

    method ind-ref($/) {
        make 'ind-ref' => [ $<obj-num>.ast.value, $<gen-num>.ast.value ];
    }

    method ind-obj($/) {
        make 'ind-obj' => [ $<obj-num>.ast.value, $<gen-num>.ast.value, $<object>.ast ];
    }

    method ind-obj-nibble($/) {
        my $object = $<object>.ast;
        if $<stream-head> {
            # locate the start of the stream data following the 'stream' token. The
            # invokee can deterime the length using the /Length entry in the dictionary
            $object = :stream( %( $object.kv,
                                  :start( $<stream-head>.to ),
                               ));
        }
        make 'ind-obj' => [ $<obj-num>.ast.value, $<gen-num>.ast.value, $object ];
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
                    $<startxref>.ast,
                    ($<index> ?? @( $<index>.ast ) !! () ),
            );
        
        make (:%body);
    }

    method index($/) {
        make [ $<xref>.ast, $<trailer>.ast ];
    }

    method xref($/) {
	my $sections = [ $<xref-section>>>.ast ];
	make 'xref' => $sections;
    }

    method xref-section($/) {
        my @entries = $<xref-entry>».ast;
        make {
	    object-first-num => $<object-first-num>.ast.value,
	    object-count => $<object-count>.ast.value,
	    entries => @entries,
        }
    }

    method xref-entry($/) {
        make {
            type   => $<obj-status>.ast,
            offset => $<byte-offset>.ast.value,
            gen    => $<gen-number>.ast.value,
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
