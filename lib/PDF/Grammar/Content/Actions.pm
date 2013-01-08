use v6;

use PDF::Grammar::Actions;

# rules for constructing operand values for PDF::Grammar::Content

class PDF::Grammar::Content::Actions is PDF::Grammar::Actions {

    method TOP($/) {
	my @result = $/.caps.map({ $_.value.ast });
	make @result;
    }

    sub _get_ast($cap) {
       my $ast = $cap.key ~~ m/^\d$/ ?? $cap.value.Str !! $cap.value.ast; 
       return $ast;
    }

    sub _op_data($op) {
	my $operator;
	my @operands;

        for $op.caps -> $cap {
	    if $cap.key eq '0' {
		$operator = $cap.value.Str;
	    }
	    else {
		push @operands, $cap.value.ast;
	    }
	}

	return $operator => @operands;
     }

    sub _block_data($block) {
  	my @result = ( $block.caps.map({

	    my $token = $_;

	    given $token.key {
		when /^op/ {_op_data( $token.value )}
		when /inner.*block/ { _block_data( $token.value ) }
                default {'tba: ' ~ $token.key ~ ' = '  ~ $token.value};
	    }
        }) );
	return @result;
    }

    method instruction ($/) {

	my @result;

	if $<op> {
	    @result = _op_data($<op>);
	}
	elsif $<block> {
	    @result = _block_data($<block>);
	}
	else {
	    die "unable to process instruction: " ~ $/.Str;
	}
	make @result;
    }

    method id ($/) {
	make $/.Str;
    }

    method unknown ($/) {
	my @u =  $/.caps.map({ $_.value.ast });
	make '??' => @u
    }

}
