use v6;

class PDF::Grammar::Actions {

    method octal_char($/) {

	say $/;
	warn "matched";
	make 123;

    }

}
