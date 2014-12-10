use v6;

# base rules for constructing AST from PDF::Grammar.

class PDF::Grammar::Actions:ver<0.0.1> {

    method real($/) {
        make 'real' => $/.Num;
    }

    method int($/) {
        make 'int' => $/.Int;
    }

    method number ($/) {
        make ($<real> // $<int>).ast;
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

    method name($/) {
        make 'name' => [~] $<name-chars>».ast;
    }

    method hex-string ($/) {
        my $xdigits = [~] $<xdigit>».Str;
        my @hex-codes = $xdigits.comb(/..?/).map({ _hex-pair($_) });
        my $string = [~] @hex-codes.map({ chr($_) });

        make 'hex-string' => $string;
    }

    method literal:sym<eol>($/) { make "\n" }
    method literal:sym<substring>($/)    {
        make '(' ~ $<literal-string>.ast.value ~ ')'
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
        make 'literal' => $string;
    }

    method string ($/) {
        make ($<literal-string> // $<hex-string>).ast;
    }

    method array ($/) {
        my @objects = @<object>».ast;
        make 'array' => @objects;
    }

    method dict ($/) {
        my @names = @<name>».ast.map: *.value;
        my @objects = @<object>».ast;

        my %dict = @names Z=> @objects;

        make 'dict' => %dict;
    }

    method object:sym<number>($/)  { make $<number>.ast }
    method object:sym<true>($/)    {
        make 'bool' => True;
    }
    method object:sym<false>($/)   {
        make 'bool' => False;
    }
    method object:sym<bool>($/)    { make $<bool>.ast }
    method object:sym<string>($/)  { make $<string>.ast }
    method object:sym<name>($/)    { make $<name>.ast }
    method object:sym<array>($/)   { make $<array>.ast }
    method object:sym<dict>($/)    { make $<dict>.ast }
    method object:sym<null>($/)    { make 'null' => Any }

    # utility subs

    sub _hex-pair($hex) {
        my $result = :16($hex);
        $result *= 16 unless $hex.chars %% 2;
        return $result;
    }
}
