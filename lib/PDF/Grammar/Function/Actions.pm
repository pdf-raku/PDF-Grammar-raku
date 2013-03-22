use v6;

use PDF::Grammar::Actions;

class PDF::Grammar::Function::Actions is PDF::Grammar::Actions {

    method TOP($/) { make $<expression>.ast }

    method expression($/) {
        my @result = $<statement>.map({ $_.ast });
        make (expr => @result);
    }

    method statement:sym<ifelse>($/)     { make $<ifelse>.ast; }
    method statement:sym<if>($/)         { make $<if>.ast; }
    method statement:sym<object>($/)     { make $<object>.ast}
    method statement:sym<unexpected>($/) { make ('??' => $<unexpected>.ast); }
    method statement:sym<unknown>($/)    { make ('??' => $<unknown>.Str); }

    method unexpected:sym<dict>($/)  { make $<dict>.ast }
    method unexpected:sym<array>($/) { make $<array>.ast }
    method unexpected:sym<name>($/)  { make $<name>.ast }
    method unexpected:sym<null>($/)  { make $<null>.ast }
  
    method object:sym<ps_op>($/) {make $.ast( $<ps_op>.ast, :pdf_type('ps_op') )};
    # extended postcript operators
    method ps_op:sym<arithmetic>($/) {make $<op>.Str }
    method ps_op:sym<bitwise>($/)    {make $<op>.Str }
    method ps_op:sym<stack>($/)      {make $<op>.Str }

    method if($/)     { make {if => $<if_expr>.ast} }

    method ifelse($/) { make {if => $<if_expr>.ast,
                              else => $<else_expr>.ast} }
}
