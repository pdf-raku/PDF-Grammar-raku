use v6;

# rules for constructing operand values for PDF::Grammar

class PDF::Grammar::Actions {

    sub _from_octal($oct) {

	my $result = 0;

	for $oct.split('') {
	    die "illegal octal char: $_"
		unless $_ ge '0' && $_ le '7';
	    $result *= 8;
	    $result += $_;
	}
	return $result;
    }

    sub _from_hex($hex) {

	$hex ~= '0'
	    unless $hex.chars >= 2;

	my $result = 0;

	for $hex.split('') {

	    my $hex_digit;

	    if ($_ ~~ /\d/) {
		$hex_digit = $_;
	    }
	    elsif ($_ ge 'A' && $_ le 'F') {
		$hex_digit = ord($_) - ord('A') + 10;
	    }
	    elsif ($_ ge 'a' && $_ le 'f') {
		$hex_digit = ord($_) - ord('a') + 10;
	    }
	    else {
		# our grammar shouldn't allow this
		die "illegal hexidecimal digit: $_";
	    }

	    $result *= 16;
	    $result += $hex_digit;
	}
	return $result;
    }

    method null($/) { make Any }
    method bool($/) {
	make $/.Str eq 'true';
    }
    method real($/) {make $/.Num}
    method integer($/) {make $/.Int}
    method number ($/) {
	my $number = ($<real> || $<integer>).ast;
	make $number;
    }
    method hex_char($/) {
	make chr( _from_hex($/.Str))
    }

    method name_char_number_symbol($/) {
	make '#';
    }
    method name_char_escaped($/) {
	make $<hex_char>.ast;
    }
    method name_chars_printable($/) {
	make $/;
    }

    method name ($/) {
	make $/.caps.map({ $_.value.ast }).join('')
    }

    method hex_string ($/) {
	make $/.caps.grep({$_.key eq 'hex_char'}).map({ $_.value.ast }).join('')
    }

    method literal_chars($/) { make $/.Str }
    method line_continuation($/) { make '' }

    method escape_seq ($/) {
       my $char;

       if $<char_code> {
	   $char =  {n => "\n", r => "\r", t => "\t",
		     b => "\b", f => "\f",
		     '(' => '(', ')' => ')'}{ $<char_code> }
			 or die "unhandled escape character \$<char_code>";

       }
       elsif $<octal_code> {
	   $char =  chr( _from_octal( $<octal_code> ) );
       }
       else {
	   $char = '';
       }

       make $char;
    }

    method literal_string ($/) {
	make $/.caps.map({

	    my $token = $_;

	    given $token.key {
		when 'line_continuation' {''}
		when 'eol' {"\n"}
                when 'literal_string' {'(' ~ $token.value.ast ~ ')'}
		default { $token.value.ast} }
                
	 }).join('')
    }

    method string ($/) {
	my $string = ($<literal_string> || $<hex_string>).ast;
	make $string;
    }

    method array ($/) {
	my @operands = @<operand>.map({ $_.ast });
	make @operands;
    }

    method dict ($/) {
	my @names = @<name>.map({ $_.ast });
	my @operands = @<operand>.map({ $_.ast });

	my %dict;
	%dict{ @names } = @operands;

	make %dict;
    }

    method operand($/) {
	my ($operand) = $/.caps;
	make $operand.value.ast;
    }
}
