unit class PDF::Grammar::Content::Actions;

use PDF::Grammar::Actions;
also is PDF::Grammar::Actions;

method TOP($/) {
    my @result = $/<op>».ast;
    make @result;
}

sub op-ast(Capture $op) {
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

multi sub val(Pair:D $_) { .value }
multi sub val($_) { $_ }

multi sub block-ast(Capture $/ where $<opBeginImage>) {
    my Hash $dict = $<imageDict>.ast;
    my UInt $start = $<start>.to;
    # [ISO_32000-2 Section 8.9.7 - PDF 2.0 Inline images must have a /L or /Length entry ]
    my UInt $len = .&val with $dict<L> // $dict<Length>;
    $len //= $<end>.from - $start;
    $start -= $/.from;
    my $encoded = $/.substr($start, $len);

    (:BI[], :ID[:$dict, :$encoded], :EI[]).Slip;
}

multi sub block-ast(Capture $/) {
    ($/.caps.map: -> $token {
        given $token.key.substr(0,2) {
            when 'op' { $token.value.&op-ast    }
            when 'in' { $token.value.&block-ast }
            default   {'tba: ' ~ $token.key ~ ' = '  ~ $token.value};
        };
    }).Slip;
}

method instruction:sym<block>($/) {
    make $<block>.&block-ast;
}

method instruction:sym<op>($/) {
    make $<op>.&op-ast;
}

method imageDict($/) {
    my Str @names = @<name>.map: *.ast.value;
    my @objects = @<object>».ast;

    my %atts = @names Z=> @objects;
    make %atts;
}

method suspect($/) {
    make '??' => $/.&op-ast;
}

