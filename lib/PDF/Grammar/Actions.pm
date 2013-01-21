use v6;

# rules for constructing operand values for PDF::Grammar
use PDF::Grammar::Attributes;

class PDF::Grammar::Actions {

    sub _from_octal($oct) {

	my $result = 0;

	for $oct.split('') {

	    # our grammar shouldn't allow this
	    die "illegal octal digit: $_"
		unless $_ ge '0' && $_ le '7';

	    $result *= 8;
	    $result += $_;
	}

	return $result;
    }

    sub _from_hex($hex) {

	my $result = 0;

	for $hex.split('') {

	    my $hex_digit;

	    if ($_ ge '0' && $_ le '9') {
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
	$result *= 16 if $hex.chars < 2;
	return $result;
    }

    method null($/) { make Any }
    method bool($/) {
	make $/.Str eq 'true';
    }

    method real($/) {
	my $num = $/.Num
	    does PDF::Grammar::Attributes;

	$num.pdf_subtype = 'real';
	make $num;
    }

    method integer($/) {
	my $num = $/.Int
	    does PDF::Grammar::Attributes;

	$num.pdf_subtype = 'integer';
	make $num;
    }

    method number ($/) {
	my $number = ($<real> || $<integer>).ast;
	make $number;
    }

    method hex_char($/) {
	make chr( _from_hex($/.Str) )
    }

    method name_char_number_symbol($/) {
	make '#';
    }
    method name_char_escaped($/) {
	make $<hex_char>.ast;
    }
    method name_chars_regular($/) {
	make $/.Str;
    }

    method name ($/) {
	make $/.caps.map({ $_.value.ast }).join('')
    }

    method hex_string ($/) {
	my $xdigits = $/.caps.grep({$_.key eq 'xdigit'}).map({$_.value}).join('');
	my @hex_codes = $xdigits.comb(/..?/).map({ _from_hex ($_) });
	my $string = @hex_codes.map({ chr($_) }).join('')
	    does PDF::Grammar::Attributes;

        $string.pdf_subtype = 'hex';
	make $string;
    }

    method literal_chars($/) { make $/.Str }
    method line_continuation($/) { make '' }

    method escape_seq ($/) {
       my $char;

       if $<char_code> {
	   $char =  {
		     b   => "\b", 
                     f   => "\f",
                     n   => "\n",
                     r   => "\r",
                     t   => "\t",
		     '(' => '(',
                     ')' => ')'
           }{ $<char_code> }
	       or die "illegal escape character \$<char_code>";
       }
       elsif $<octal_code> {
	   $char =  chr( _from_octal( $<octal_code> ) );
       }
       else {
	   # silently consume stray '\'
	   $char = '';
       }

       make $char;
    }

    method literal_string ($/) {
	my $string = $/.caps.map({
	    my $token = $_;

	    given $token.key {
		when 'line_continuation' {''}
		when 'eol' {"\n"}
                when 'literal_string' {'(' ~ $token.value.ast ~ ')'}
		default { $token.value.ast} }
                
	 }).join('');

	$string does PDF::Grammar::Attributes;

        $string.pdf_subtype = 'literal';
	make $string;
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
	my ($_operand) = $/.caps;

	my $operand =  $_operand.value.ast;

	$operand
	    does PDF::Grammar::Attributes
	    unless $operand.can('pdf_type'); 

	$operand.pdf_type = $_operand.key;
	make $operand;
    }
}
