use v6;

module PDF::Grammar::Test {

    use Test;
    use JSON::Fast;

    # allow only json compatible data
    multi sub json-eqv (Hash:D $a, Hash:D $b) {
        if +$a != +$b { return False }
	for $a.keys -> $k {
            unless $b{$k}:exists && json-eqv($a{$k}, $b{$k}) {
                return False;
            }
	}
	return True;
    }
    multi sub json-eqv (List:D $a, List:D $b) {
        if +$a != +$b { return False }
	for $a.keys -> $k {
	    return False
		unless (json-eqv($a[$k], $b[$k]));
	}
	return True;
    }
    multi sub json-eqv (Numeric:D $a, Numeric:D $b) { $a == $b }
    multi sub json-eqv (Stringy $a, Stringy $b) { $a eq $b }
    multi sub json-eqv (Bool $a, Bool $b) { $a == $b }
    multi sub json-eqv (Mu $a, Mu $b) {
        return json-eqv( %$a, $b) if $a.isa(Pair);
        return json-eqv( $a, %$b) if $b.isa(Pair);
        return True if !$a.defined && !$b.defined;
	diag("data type mismatch"
	     ~ "\n  - expected: {$b.perl}"
	     ~ "\n  -      got: {$a.perl}");
	return False;
    }

    use Test;
    sub is-json-equiv($got, $expected, Str $test = '') is export(:is-json-equiv) {
        my $ok = True;
        unless ok(json-eqv($got, $expected), $test) {
                diag "expected: " ~ to-json($expected);
                diag "got     : " ~ to-json($got);
                $ok = False;
            };
        $ok;
    }

    our sub parse-tests($class, $input, :$parse is copy, :$actions,
			:$rule = 'TOP', :$suite, :%expected) {

        $parse //= do { 
            $class.subparse( $input, :$rule, :$actions)
        };

        my $parsed = %expected<parse> // $input;

        with $input {
            my $desc = (.chars < 60
                        ?? $_
                        !! [~] .substr(0, 32), ' ... ', .substr(*-20))\
                        .subst(/\s+/, ' ', :g);
            is(~$parse, $parsed, "{$suite}: " ~ $rule ~ " parse: " ~ $desc)
        }
        else {
            ok(~$parse, "{$suite}: " ~ $rule ~ " parsed")
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
