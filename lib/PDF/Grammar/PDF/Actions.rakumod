use PDF::Grammar::COS::Actions;

class PDF::Grammar::PDF::Actions
    is PDF::Grammar::COS::Actions {

    method xref-first($/) {
	my @entries = $<xref-entry>».ast;
        my $obj-num = 0;
        @entries[$_;0] = $obj-num++
            for 0 ..^ +@entries;
        my @xref = {
	    :obj-count(+@entries),
	    :@entries,
        }, $<xref-section>».ast.Slip;

	make (:@xref);
    }
}
