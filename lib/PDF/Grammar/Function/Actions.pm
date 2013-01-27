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
	%branch<if> = $<if_expr>.ast;
	make %branch;
    }

    method ifelse($/) {
	my %branch;
	%branch<if> = $<if_expr>.ast;
	%branch<else> = $<else_expr>.ast;
	make %branch;
    }

    method unknown ($/) {
	my @u =  $/.caps.map({ $_.value.ast });
	make '??' => @u
    }
}
