use v6;

use PDF::Grammar::Actions;

class PDF::Grammar::Function::Actions is PDF::Grammar::Actions {

    method TOP($/) { make $<expression>.ast }

    method expression($/) {
	my @result = $/.caps.map({ $_.value.ast });
	make (expr => @result);
    }

    method operator($/) {
	make (op => $<op>.Str);
    }

    method if($/) {
	my %branch;
	%branch<if_expr> = $<if_expr>.ast.value;
	make %branch;
    }

    method ifelse($/) {
	my %branch;
	%branch<if_expr> = $<if_expr>.ast.value;
	%branch<else_expr> = $<else_expr>.ast.value;
	make %branch;
    }

    method unknown ($/) {
	my @u =  $/.caps.map({ $_.value.ast });
	make '??' => @u
    }
}
