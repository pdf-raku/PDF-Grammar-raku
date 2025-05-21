unit class PDF::Grammar::Content::Actions;

use PDF::Grammar::Actions;
also is PDF::Grammar::Actions;

method TOP($/) {
    my @result = $/<op>».ast;
    make @result;
}

sub _op-ast($op) {
    my $operator;
    my @objects;

    for $op.caps -> $cap {
        if $cap.key eq '0' {
            $operator = ~$cap.value;
        }
        else {
            push @objects, $cap.value.ast;
        }
    }

    return $operator => @objects;
 }

multi sub _val(Pair:D $_) { .value }
multi sub _val($_) { $_ }

multi sub _block-ast($/ where $<opBeginImage>) {
    my Hash $dict = $<imageDict>.ast;
    my UInt $start = $<start>.to;
    # [ISO_32000-2 Section 8.9.7 - PDF 2.0 Inline images must have a /L or /Length entry ]
    my UInt $len = .&_val() with $dict<L> // $dict<Length>;
    $len //= $<end>.from - $start;
    $start -= $/.from;
    my $encoded = $/.substr($start, $len);

    (:BI[], :ID[:$dict, :$encoded], :EI[]).Slip;
}

multi sub _block-ast($/) {
    ($/.caps.map: -> $token {
        given $token.key.substr(0,2) {
            when 'op' { $token.value.&_op-ast    }
            when 'in' { $token.value.&_block-ast }
            default   {'tba: ' ~ $token.key ~ ' = '  ~ $token.value};
        };
    }).Slip;
}

method instruction:sym<block>($/) {
    make $<block>.&_block-ast;
}

method instruction:sym<op>($/) {
    make $<op>.&_op-ast;
}

method imageDict($/) {
    my Str @names = @<name>.map: *.ast.value;
    my @objects = @<object>».ast;

    my %atts = @names Z=> @objects;
    make %atts;
}

method suspect($/) {
    make '??' => _op-ast($/);
}

