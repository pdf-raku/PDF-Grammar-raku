use v6;

# base rules for constructing AST from PDF::Grammar.

use PDF::Grammar::Attributes;

class PDF::Grammar::Actions:ver<0.0.1> {

    method node(Mu $node, :$pdf-type, :$pdf-subtype) {
        $node
            does PDF::Grammar::Attributes
            unless $node.can('pdf-type');

        $node.pdf-type = $pdf-type if defined $pdf-type;
        $node.pdf-subtype = $pdf-subtype if defined $pdf-subtype;

        return $node;
    }

    method real($/) {
        make $.node( $/.Num, :pdf-type<number>, :pdf-subtype<real> );
    }

    method integer($/) {
        make $.node( $/.Int, :pdf-type<number>, :pdf-subtype<integer> );
    }

    method number ($/) {
        make ($<real> // $<integer>).ast;
    }

    method hex-char($/) {
        make chr( _hex-pair(~$/) )
    }

    method name-chars:sym<number-symbol>($/) {
        make '#';
    }
    method name-chars:sym<escaped>($/) {
        make $<hex-char>.ast;
    }
    method name-chars:sym<regular>($/) {
        make ~$/;
    }

    method name ($/) {
        make $.node( [~] $<name-chars>».ast, :pdf-type<name> );
    }

    method hex-string ($/) {
        my $xdigits = [~] $<xdigit>».Str;
        my @hex-codes = $xdigits.comb(/..?/).map({ _hex-pair($_) });
        my $string = [~] @hex-codes.map({ chr($_) });

        make $.node( $string, :pdf-subtype<hex> );
    }

    method literal:sym<eol>($/) { make "\n" }
    method literal:sym<substring>($/)    {
        make '(' ~ $<literal-string>.ast ~ ')'
    }
    method literal:sym<regular>($/)      { make ~$/ }
    # literal escape sequences
    method literal:sym<esc-octal>($/)  {
        make chr( :8(~$<octal-code>) )
    }
    method literal:sym<esc-delim>($/)        { make ~$<delim> }
    method literal:sym<esc-backspace>($/)    { make "\b" }
    method literal:sym<esc-formfeed>($/)     { make "\f" }
    method literal:sym<esc-newline>($/)      { make "\n" }
    method literal:sym<esc-cr>($/)           { make "\r" }
    method literal:sym<esc-tab>($/)          { make "\t" }
    method literal:sym<esc-continuation>($/) { make '' }

    method literal-string ($/) {
        my $string = [~] $<literal>».ast;
        make $.node( $string, :pdf-subtype<literal> );
    }

    method string ($/) {
        my $string = ($<literal-string> // $<hex-string>).ast;
        make $.node( $string, :pdf-type<string> );
    }

    method array ($/) {
        my @objects = @<object>».ast;
        make $.node( @objects, :pdf-type<array> );
    }

    method dict ($/) {
        my @names = @<name>».ast;
        my @objects = @<object>».ast;

        my %dict = @names Z=> @objects;

        make $.node( %dict, :pdf-type<dict> );
    }

    method object:sym<number>($/)  { make $<number>.ast }
    method object:sym<true>($/)    {
        make $.node( True, :pdf-type<bool> );
    }
    method object:sym<false>($/)   {
        make $.node( False, :pdf-type<bool> );
    }
    method object:sym<bool>($/)    { make $<bool>.ast }
    method object:sym<string>($/)  { make $<string>.ast }
    method object:sym<name>($/)    { make $<name>.ast }
    method object:sym<array>($/)   { make $<array>.ast }
    method object:sym<dict>($/)    { make $<dict>.ast }
    method object:sym<null>($/)    { make Any }

    # utility subs

    sub _hex-pair($hex) {
        my $result = :16($hex);
        $result *= 16 if $hex.chars % 2;
        return $result;
    }
}
