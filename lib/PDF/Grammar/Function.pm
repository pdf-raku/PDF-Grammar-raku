use v6;

use PDF::Grammar;

grammar PDF::Grammar::Function
    is PDF::Grammar {
    #
    # Simple PDF grammar extensions for parsing PDF Type 4 PostScript
    # Calculator Functions, as described in [PDF 1.7] section 7.10.5
    rule TOP {^ <expression> $}

    rule expression { '{' [<statement>||<statement=.unknown>]* '}' }

    proto rule statement {*}
    rule statement:sym<ifelse>     { <ifelse> }
    rule statement:sym<if>         { <if> }
    rule statement:sym<object>     { <object=.illegal-object>||<object> }

    proto rule illegal-object {*}
    rule illegal-object:sym<dict>  { <dict> }
    rule illegal-object:sym<array> { <array> }
    rule illegal-object:sym<name>  { <name> }
    rule illegal-object:sym<null>  { <sym> }

    # extend <object> add <ps-op>
    rule object:sym<ps-op> {<ps-op>}

    proto token ps-op {*}

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

    token unknown { <alpha><[\w]>* }
}
