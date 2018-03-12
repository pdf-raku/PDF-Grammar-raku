use v6;

use PDF::Grammar::COS::Actions;

class PDF::Grammar::PDF::Actions
    is PDF::Grammar::COS::Actions {

    method xref-first($/) {
	my @entries = $<xref-entry>».ast;
        my $first-section = {
	    :obj-first-num(0),
	    :obj-count(+@entries),
	    :@entries,
        };

	my @xref = [$first-section, ];
	@xref.append: $<xref-section>>>.ast;

	make (:@xref);
    }
}
