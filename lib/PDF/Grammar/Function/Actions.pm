use v6;

use PDF::Grammar::Actions;

class PDF::Grammar::Function::Actions is PDF::Grammar::Actions {

    method TOP($/) { make $<expression>.ast }

    method expression($/) {
        my @result = $<statement>>>.ast;
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
  
    method object:sym<ps-op>($/) {make $.ast( $<ps-op>.ast, :pdf-type<ps-op> )};
    # extended postcript operators
    method ps-op:sym<arithmetic>($/) {make $<op>.Str }
    method ps-op:sym<bitwise>($/)    {make $<op>.Str }
    method ps-op:sym<stack>($/)      {make $<op>.Str }

    method if($/)     { make {if => $<if-expr>.ast} }

    method ifelse($/) { make {if => $<if-expr>.ast,
                              else => $<else-expr>.ast} }
}
