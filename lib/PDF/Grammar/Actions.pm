use v6;

# base rules for constructing AST from PDF::Grammar.

use PDF::Grammar::Attributes;

class PDF::Grammar::Actions:ver<0.0.1> {

    method ast(Mu $ast, :$pdf-type, :$pdf-subtype) {
        $ast
            does PDF::Grammar::Attributes
            unless $ast.can('pdf-type');

        $ast.pdf-type = $pdf-type if defined $pdf-type;
        $ast.pdf-subtype = $pdf-subtype if defined $pdf-subtype;

        return $ast;
    }

    method null($/) { make Any }
    method bool($/) {
        make $.ast( $/.Str eq 'true', :pdf-type<bool> );
    }

    method real($/) {
        make $.ast( $/.Num, :pdf-type<number>, :pdf-subtype<real> );
    }

    method integer($/) {
        make $.ast( $/.Int, :pdf-type<number>, :pdf-subtype<integer> );
    }

    method number ($/) {
        make ($<real> || $<integer>).ast;
    }

    method hex-char($/) {
        make chr( _from_hex($/.Str) )
    }

    method name-chars:sym<number-symbol>($/) {
        make '#';
    }
    method name-chars:sym<escaped>($/) {
        make $<hex-char>.ast;
    }
    method name-chars:sym<regular>($/) {
        make $/.Str;
    }

    method name ($/) {
        make $.ast( $/.caps.map({ $_.value.ast }).join(''),
                    :pdf-type<name> );
    }

    method hex-string ($/) {
        my $xdigits = $<xdigit>.map({$_.Str}).join('');
        my @hex-codes = $xdigits.comb(/..?/).map({ _from_hex ($_) });
        my $string = @hex-codes.map({ chr($_) }).join('');

        make $.ast( $string, :pdf-subtype<hex> );
    }

    method literal:sym<eol>($/) { make "\n" }
    method literal:sym<substring>($/)    {
        make '(' ~ $<literal-string>.ast ~ ')'
    }
    method literal:sym<regular>($/)      { make $/.Str }
    # literal escape sequences
    method literal:sym<esc-octal>($/)  {
        make chr( _from_octal($<octal-code>) )
    }
    method literal:sym<esc-delim>($/)        { make $<delim>.Str }
    method literal:sym<esc-backspace>($/)    { make "\b" }
    method literal:sym<esc-formfeed>($/)     { make "\f" }
    method literal:sym<esc-newline>($/)      { make "\n" }
    method literal:sym<esc-cr>($/)           { make "\r" }
    method literal:sym<esc-tab>($/)          { make "\t" }
    method literal:sym<esc-continuation>($/) { make '' }

    method literal-string ($/) {
        my $string = $<literal>.map({ $_.ast }).join('');
        make $.ast( $string, :pdf-subtype<literal> );
    }

    method string ($/) {
        my $string = ($<literal-string> || $<hex-string>).ast;
        make $.ast( $string, :pdf-type<string> );
    }

    method array ($/) {
        my @objects = @<object>.map({ $_.ast });
        make $.ast( @objects, :pdf-type<array> );
    }

    method dict ($/) {
        my @names = @<name>.map({ $_.ast });
        my @objects = @<object>.map({ $_.ast });

        my %dict;
        %dict{ @names } = @objects;

        make $.ast( %dict, :pdf-type<dict> );
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

            my $hex-digit;

            if ($_ ge '0' && $_ le '9') {
                $hex-digit = $_;
            }
            elsif ($_ ge 'A' && $_ le 'F') {
                $hex-digit = ord($_) - ord('A') + 10;
            }
            elsif ($_ ge 'a' && $_ le 'f') {
                $hex-digit = ord($_) - ord('a') + 10;
            }
            else {
                # our grammar shouldn't allow this
                die "illegal hexidecimal digit: $_";
            }

            $result *= 16;
            $result += $hex-digit;
        }
        $result *= 16 if $hex.chars < 2;
        return $result;
    }
}
