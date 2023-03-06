# base rules for constructing AST from PDF::Grammar.
class PDF::Grammar::Actions {

    has Bool $.lite;

    method real($/) {
        make $!lite ?? $/.Rat !! :real($/.Rat);
    }

    method int($/) {
        make $!lite ?? $/.Int !! (:int($/.Int));
    }

    method numeric:sym<real>($/) {
        make $<frac> ?? ($!lite ?? $/.Rat !! :real($/.Rat)) !! $<int>.ast;
    }
    method numeric:sym<frac>($/) {
        make $!lite ?? $/.Rat !! (:real($/.Rat));
    }
    method number($/) { make $<numeric>.ast }

    method name-bytes:sym<number-symbol>($/) {
        make '#'.ord; 
    }
    method name-bytes:sym<escaped>($/) {
        make :16( $/.substr(1) )
    }
    method name-bytes:sym<regular>($/) {
        make $/.ords.Slip;
    }

    method name($/) {
        # names are utf-8 encoded
        my Str $name = Buf.new( $<name-bytes>».ast ).decode;
        make (:$name);
    }

    method hex-string ($/) {
        my $xdigits = [~] $<xdigit>».Str;
        my uint8 @hex-codes = $xdigits.comb.map: -> $a, $b = '0' { :16($a ~ $b) };
        my $hex-string = [~] @hex-codes».chr;

        make (:$hex-string);
    }

    method literal:sym<eol>($/) {
        my Str $ch = ~$/;
        make $ch.ords.first(10)  ?? "\n" !! $ch
    }
    method literal:sym<substring>($/)    {
        make '(' ~ $<literal-string>.ast.value ~ ')'
    }
    method literal:sym<regular>($/)      { make ~$/ }
    method literal:sym<escaped>($/)      { make $<literal-esc>.ast }
    # literal escape sequences
    method literal-esc:sym<octal>($/)  {
        make chr( :8(~$<octal-code>) )
    }
    method literal-esc:sym<delim>($/)        { make ~$/ }
    method literal-esc:sym<backspace>($/)    { make "\b" }
    method literal-esc:sym<formfeed>($/)     { make "\f" }
    method literal-esc:sym<newline>($/)      { make "\n" }
    method literal-esc:sym<cr>($/)           { make "\r" }
    method literal-esc:sym<tab>($/)          { make "\t" }
    method literal-esc:sym<continuation>($/) { make '' }

    method literal-string($/) {
        my $literal = [~] $<literal>».ast;
        make (:$literal);
    }

    method string($/) {
        make $<string>.ast;
    }

    method array($/) {
        my @array = @<object>».ast;
        make (:@array);
    }

    method dict($/) {
        my @names = @<name>.map: *.ast.value;
        my @objects = @<object>».ast;

        my %dict = @names Z=> @objects;

        make (:%dict);
    }

    method object:sym<number>($/)  { make $<number>.ast }
    method object:sym<true>($/)    { make ($!lite ?? True !! :bool) }
    method object:sym<false>($/)   { make ($!lite ?? False !! :!bool) }
    method object:sym<bool>($/)    { make $<bool>.ast }
    method object:sym<string>($/)  { make $<string>.ast }
    method object:sym<name>($/)    { make $<name>.ast }
    method object:sym<array>($/)   { make $<array>.ast }
    method object:sym<dict>($/)    { make $<dict>.ast }
    method object:sym<null>($/)    { make 'null' => Any }

}
