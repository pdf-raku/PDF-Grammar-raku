use v6;

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

    sub _image-ast($/) {

        my $dict = $<imageAtts>.ast;
        my $encoded = ~$<encoded>;

        (:BI[:$dict], :ID[:$encoded], :EI[]).Slip;
    }

    multi sub _block-ast($/ where $<opBeginImage>) {
        _image-ast($/)
    }

    multi sub _block-ast($block) is default {

        my @result = map -> $token {
            given $token.key {
                when /^op/          { _op-ast( $token.value )    }
                when /inner.*block/ { _block-ast( $token.value ) }
                default {'tba: ' ~ $token.key ~ ' = '  ~ $token.value};
            };
        }, $block.caps;

        @result.Slip;
    }

    method instruction:sym<block>($/) {
        make _block-ast($<block>);
    }

    method instruction:sym<op>($/) {
        make _op-ast($<op>);
    }

    method guff ($/) {
        make ~$/;
    }

    method unknown ($/) {
        my @u =  $/.caps.map( *.value.ast );
        make '??' => @u
    }

    method imageAtts ($/) {
        my @names = @<name>.map( *.ast.value );
        my @objects = @<object>».ast;

        my %atts = @names Z=> @objects;
        make %atts;
    }

}
