use v6;

use PDF::Grammar::Actions;

class PDF::Grammar::Function::Actions
    is PDF::Grammar::Actions {

    method TOP($/) { make $<expression>.ast }

    method expression($/) {
        my @result = $<statement>».ast;
        make (expr => @result);
    }

    method statement:sym<ifelse>($/)     { make $<ifelse>.ast; }
    method statement:sym<if>($/)         { make $<if>.ast; }
    method statement:sym<object>($/)     { make $<object>.ast}
    method statement:sym<unexpected>($/) { make ('??' => $<unexpected>.ast); }
    method unknown($/)    { make ('??' => ~$/); }

    method illegal-object:sym<dict>($/)  { make '??' => $<dict>.ast }
    method illegal-object:sym<array>($/) { make '??' => $<array>.ast }
    method illegal-object:sym<name>($/)  { make '??' => $<name>.ast }
    method illegal-object:sym<null>($/)  { make '??' => Any }
  
    method object:sym<ps-op>($/) {make 'op' => $<ps-op>.ast }
    # extended postcript operators
    method ps-op:sym<arithmetic>($/) {make ~$<op> }
    method ps-op:sym<bitwise>($/)    {make ~$<op> }
    method ps-op:sym<stack>($/)      {make ~$<op> }

    method if($/)     { make {if => $<if-expr>.ast} }

    method ifelse($/) { make {if => $<if-expr>.ast,
                              else => $<else-expr>.ast} }
}
