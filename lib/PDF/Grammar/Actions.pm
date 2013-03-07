use v6;

# base rules for constructing AST from PDF::Grammar.

use PDF::Grammar::Attributes;

class PDF::Grammar::Actions:ver<0.0.1> {

    method ast(Mu $ast, :$pdf_type, :$pdf_subtype) {
        $ast
            does PDF::Grammar::Attributes
            unless $ast.can('pdf_type');

        $ast.pdf_type = $pdf_type if defined $pdf_type;
        $ast.pdf_subtype = $pdf_subtype if defined $pdf_subtype;

        return $ast;
    }

    method null($/) { make Any }
    method bool($/) {
        make $.ast( $/.Str eq 'true', :pdf_type('bool') );
    }

    method real($/) {
        make $.ast( $/.Num, :pdf_type('number'), :pdf_subtype('real') );
    }

    method integer($/) {
        make $.ast( $/.Int, :pdf_type('number'), :pdf_subtype('integer') );
    }

    method number ($/) {
        make ($<real> || $<integer>).ast;
    }

    method hex_char($/) {
        make chr( _from_hex($/.Str) )
    }

    method name_chars:sym<number_symbol>($/) {
        make '#';
    }
    method name_chars:sym<escaped>($/) {
        make $<hex_char>.ast;
    }
    method name_chars:sym<regular>($/) {
        make $/.Str;
    }

    method name ($/) {
        make $.ast( $/.caps.map({ $_.value.ast }).join(''),
                    :pdf_type('name') );
    }

    method hex_string ($/) {
        my $xdigits = $<xdigit>.map({$_.Str}).join('');
        my @hex_codes = $xdigits.comb(/..?/).map({ _from_hex ($_) });
        my $string = @hex_codes.map({ chr($_) }).join('');

        make $.ast( $string, :pdf_subtype('hex') );
    }

    method literal:sym<eol>($/) { make "\n" }
    method literal:sym<substring>($/)    {
        make '(' ~ $<literal_string>.ast ~ ')'
    }
    method literal:sym<regular>($/)      { make $/.Str }
    # literal escape sequences
    method literal:sym<esc_octal>($/)  {
        make chr( _from_octal($<octal_code>) )
    }
    method literal:sym<esc_delim>($/)        { make $<delim>.Str }
    method literal:sym<esc_backspace>($/)    { make "\b" }
    method literal:sym<esc_formfeed>($/)     { make "\f" }
    method literal:sym<esc_newline>($/)      { make "\n" }
    method literal:sym<esc_cr>($/)           { make "\r" }
    method literal:sym<esc_tab>($/)          { make "\t" }
    method literal:sym<esc_continuation>($/) { make '' }

    method literal_string ($/) {
        my $string = $<literal>.map({ $_.ast }).join('');
        make $.ast( $string, :pdf_subtype('literal') );
    }

    method string ($/) {
        my $string = ($<literal_string> || $<hex_string>).ast;
        make $.ast( $string, :pdf_type('string') );
    }

    method array ($/) {
        my @objects = @<object>.map({ $_.ast });
        make $.ast( @objects, :pdf_type('array') );
    }

    method dict ($/) {
        my @names = @<name>.map({ $_.ast });
        my @objects = @<object>.map({ $_.ast });

        my %dict;
        %dict{ @names } = @objects;

        make $.ast( %dict, :pdf_type('dict') );
    }

    method object:sym<number>($/)  { make $<number>.ast }
    method object:sym<bool>($/)    { make $<bool>.ast }
    method object:sym<string>($/)  { make $<string>.ast }
    method object:sym<name>($/)    { make $<name>.ast }
    method object:sym<array>($/)   { make $<array>.ast }
    method object:sym<dict>($/)    { make $<dict>.ast }
    method object:sym<null>($/)    { make $<null>.ast }

    # utility subs

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
}
