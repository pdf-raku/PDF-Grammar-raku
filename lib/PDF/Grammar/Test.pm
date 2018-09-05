use v6;

module PDF::Grammar::Test {

    use Test;

    # allow only json compatible data
    multi sub json-eqv (Hash:D $a, Hash:D $b) {
        if +$a != +$b { return False }
	for $a.kv -> $k, $v {
            unless $b{$k}:exists && json-eqv($v, $b{$k}) {
                return False;
            }
	}
	True;
    }
    multi sub json-eqv (List:D $a, List:D $b) {
        if +$a != +$b { return False }
	for $a.kv -> $k, $v {
	    return False
		unless (json-eqv($v, $b[$k]));
	}
	True;
    }
    multi sub json-eqv (array:D $a, $b) {
        # somewhat lax to accomodate shaped arrays
        $a.Str eq $b.Str;
    }
    multi sub json-eqv (Numeric:D $a, Numeric:D $b) { $a == $b }
    multi sub json-eqv (Stringy $a, Stringy $b) { $a eq $b }
    multi sub json-eqv (Mu $a, Mu $b) {
        return json-eqv( %$a, $b) if $a.isa(Pair);
        return json-eqv( $a, %$b) if $b.isa(Pair);
        return True if !$a.defined && !$b.defined;
	diag("data type mismatch"
	     ~ "\n  - expected: {$b.perl}"
	     ~ "\n  -      got: {$a.perl}");
	False;
    }

    sub is-json-equiv(\a, |c) is export(:is-json-equiv) {
	cmp-ok(a, &json-eqv, |c);
    }

    our sub parse-tests($class, $input, :$parse is copy, :$actions,
			:$rule = 'TOP', :$suite, :%expected) is export(:parse-tests) {

        $parse //= $class.subparse( $input, :$rule, :$actions);
        my $parsed = %expected<parse> // $input;

        with $input {
            my $desc = (.chars < 60
                        ?? $_
                        !! [~] .substr(0, 32), ' ... ', .substr(*-20))\
                        .subst(/\s+/, ' ', :g);
            is ~$parse, $parsed, "{$suite}: " ~ $rule ~ " parse: " ~ $desc;
        }
        else {
            ok ~$parse, "{$suite}: " ~ $rule ~ " parsed";
        }

        with %expected<ast> -> $expected-ast {
            is-json-equiv($parse.ast, $expected-ast, "{$suite} $rule - ast");
        }
        else {
            with $parse.ast {
                note {untested_ast => $_}.perl
                    unless %expected<ast>:exists;
            }
        }
    }
}
