use v6;

use PDF::Grammar;

grammar PDF::Grammar::Function
    is PDF::Grammar {
    #
    # Simple PDF grammar extensions for parsing PDF Type 4 PostScript
    # Calculator Functions, as described in [PDF 1.7] section 7.10.5
    rule TOP {^ <expression> $}

    rule expression { '{' ~ '}' <statement>* }

    proto rule statement {<...>}
    rule statement:sym<ifelse>     { <ifelse> }
    rule statement:sym<if>         { <if> }
    rule statement:sym<unexpected> { <unexpected> }
    rule statement:sym<object>     { <object> }
    rule statement:sym<unknown>    { <unknown> }

    proto rule unexpected {<...>}
    rule unexpected:sym<dict>  { <dict> }
    rule unexpected:sym<array> { <array> }
    rule unexpected:sym<name>  { <name> }
    rule unexpected:sym<null>  { <null> }

    # extend <object> add <ps-op>
    rule object:sym<ps-op> {<ps-op>}

    proto token ps-op { <...> }

    token ps-op:sym<arithmetic> {
        $<op>=[abs|add|atan|ceiling|cos|cvi|cvr|div|exp|floor
        |idiv|ln|log|mod|mul|neg|round|sin|sqrt|sub|truncate]
    }

    token ps-op:sym<bitwise> {
        $<op>=[and|bitshift|eq|false|ge|gt|le|lt|ne|not|or|true|xor]
    }

    token ps-op:sym<stack> {
        $<op>=[copy|dup|exch|index|pop|roll]
    }

    rule if { <if-expr=.expression> 'if' }
    rule ifelse { <if-expr=.expression> <else-expr=.expression> 'ifelse' }

    token unknown { <[a..zA..Z]><[\w]>* }
}
