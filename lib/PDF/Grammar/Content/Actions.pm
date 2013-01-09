use v6;

use PDF::Grammar::Actions;

class PDF::Grammar::Content::Actions is PDF::Grammar::Actions {

    method TOP($/) {
	my @result = $/.caps.map({ $_.value.ast });
	make @result;
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

    sub _image_block_data($image_block) {

	my ($bi, $image_atts, $image_data_op, $image_data) = $image_block.caps;

	return (BI => $image_atts.value.ast,
		ID => $image_data.value.Str,
		EI => [],
	    );
    }

    sub _block_data($block) {

	if ($block.caps[0].key eq 'opBeginImage') {
	    return _image_block_data($block);
	}

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

    method imageAtts ($/) {

	my @names = @<name>.map({ $_.ast });
	my @operands = @<operand>.map({ $_.ast });

	my %atts;
	%atts{ @names } = @operands;

	make %atts;

    }

}
