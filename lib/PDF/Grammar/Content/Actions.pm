use v6;

# rules for constructing operand values for PDF::Grammar

class PDF::Grammar::Content::Actions {

    method op ($/) {

	warn "new op";

	foreach my $tkn $/.cap {
	    warn "\t - token: $tkn";
	}
    }

}
