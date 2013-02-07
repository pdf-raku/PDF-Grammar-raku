use v6;

use PDF::Grammar::Actions;

class PDF::Grammar::Function::Actions is PDF::Grammar::Actions {

    method TOP($/) { make $<expression>.ast }

    method expression($/) {
        my @result = $<statement>.map({ $_.ast });
        make (expr => @result);
    }

    method statement($/) {
        make $/.caps[0].value.ast;
    }

    method object:sym<ps_op>($/) {make ($/.ast || 42)};
    # extended postcript operators
    method ps_op:sym<arithmetic>($/) {make $<op>.Str }
    method ps_op:sym<bitwise>($/)    {make $<op>.Str }
    method ps_op:sym<stack>($/)      {make $<op>.Str }

    method if($/) {
        my %branch;
        %branch<if> = $<if_expr>.ast;
        make %branch;
    }

    method ifelse($/) {
        my %branch;
        %branch<if> = $<if_expr>.ast;
        %branch<else> = $<else_expr>.ast;
        make %branch;
    }

    method restricted($/) {make ('??' => $/.caps.[0].value.ast)}
    method unknown($/) {make ('??' => $/.Str)}

}
