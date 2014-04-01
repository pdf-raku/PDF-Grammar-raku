use v6;

use PDF::Grammar::Actions;

class PDF::Grammar::Content::Actions
    is PDF::Grammar::Actions {

    method TOP($/) {
        my @result = $/<op>».ast;
        make @result;
    }

    sub _op_data($op) {
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

    sub _image_block_data($/) {

        return (BI => $<imageAtts>.ast,
                ID => ~$0,
                EI => [],
            );
    }

    sub _block_data($block) {

        if ($block.caps[0].key eq 'opBeginImage') {
            return _image_block_data($block)
        }

        my @result = map -> $token {
            given $token.key {
                when /^op/ {_op_data( $token.value )}
                when /inner.*block/ { _block_data( $token.value ) }
                default {'tba: ' ~ $token.key ~ ' = '  ~ $token.value};
            }
        }, $block.caps;

        return @result;
    }

    method instruction:sym<block>($/) {
        make _block_data($<block>);
    }

    method instruction:sym<op>($/) {
        make _op_data($<op>);
    }

    method guff ($/) {
        make ~$/;
    }

    method unknown ($/) {
        my @u =  $/.caps.map( *.value.ast );
        make '??' => @u
    }

    method imageAtts ($/) {
        my @names = @<name>».ast;
        my @objects = @<object>».ast;

        my %atts;
        %atts{ @names } = @objects;

        make %atts;
    }

}
