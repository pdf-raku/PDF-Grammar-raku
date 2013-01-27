use v6;

use PDF::Grammar;

grammar PDF::Grammar::Function is PDF::Grammar {
    #
    # A Simple PDF grammar for parsing PDF Type 4 PostScript Calculator
    # functions, as described in [PDF 1.7] section 7.10.5
    rule TOP {^ <expression> $}

    rule expression { '{' [ <ifelse> | <if> | <operator> | <operand> | <unknown> ]+ '}' }

    # Operands - restricted to numbers, booleans or strings
    rule operand { <number> | <bool> | <string> }

    rule operator {<op>}

    proto token op { <...> }

    token op:sym<arithmetic> {
	abs|add|atan|ceiling|cos|cvi|cvr|div|exp|floor
	|idiv|ln|log|mod|mul|neg|round|sin|sqrt|sub|truncate
    }

    token op:sym<bitwise> {
	and|bitshift|eq|false|ge|gt|le|lt|ne|not|or|true|xor
    }

    token op:sym<stack> {
	copy|dup|exch|index|pop|roll
    }

    rule if { $<if_expr>=<expression> 'if' }
    rule ifelse { $<if_expr>=<expression> $<else_expr>=<expression> 'ifelse' }

    token guff { <[a..zA..Z]><[\w]>* }
    rule unknown { [<operand>|<operator>|<guff>]+? } 
}
