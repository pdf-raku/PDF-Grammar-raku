use v6;

use PDF::Grammar::COS::Actions;

class PDF::Grammar::PDF::Actions
    is PDF::Grammar::COS::Actions {

    method xref-first($/) {
        my $xref = [ $<xref-section>».ast ];
	my @entries = $<xref-entry>».ast;
        my $obj-num = 0;
        @entries[$_;0] = $obj-num++
            for 0 ..^ +@entries;
        $xref.unshift: {
	    :obj-count(+@entries),
	    :@entries,
        };

	make (:$xref);
    }
}
