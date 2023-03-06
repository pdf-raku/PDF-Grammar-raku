use PDF::Grammar::Actions;

class PDF::Grammar::Content::Actions
    is PDF::Grammar::Actions {

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

    multi sub _block-ast($/ where $<opBeginImage>) {
        my Hash $dict = $<imageDict>.ast;
        my UInt $start = $<start>.to;
        my UInt $len = $<end>.from - $start;
        $start -= $/.from;
        my $encoded = $/.substr($start, $len);

        (:BI[:$dict], :ID[:$encoded], :EI[]).Slip;
    }

    multi sub _block-ast($/) {
        ($/.caps.map: -> $token {
            given $token.key.substr(0,2) {
                when 'op' { _op-ast( $token.value )    }
                when 'in' { _block-ast( $token.value ) }
                default   {'tba: ' ~ $token.key ~ ' = '  ~ $token.value};
            };
        }).Slip;
    }

    method instruction:sym<block>($/) {
        make _block-ast($<block>);
    }

    method instruction:sym<op>($/) {
        make _op-ast($<op>);
    }

    method imageDict($/) {
        my @names = @<name>.map: *.ast.value;
        my @objects = @<object>».ast;

        my %atts = @names Z=> @objects;
        make %atts;
    }

    method suspect($/) {
        make '??' => _op-ast($/);
    }

}
