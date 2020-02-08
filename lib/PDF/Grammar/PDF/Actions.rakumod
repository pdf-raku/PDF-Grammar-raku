use v6;

use PDF::Grammar::COS::Actions;

class PDF::Grammar::PDF::Actions
    is PDF::Grammar::COS::Actions {

    method xref-first($/) {
        my $xref = [ $<xref-section>».ast ];
	my @entries = $<xref-entry>».ast;
        $xref.unshift: {
	    :obj-first-num(0),
	    :obj-count(+@entries),
	    :@entries,
        };

	make (:$xref);
    }
}
