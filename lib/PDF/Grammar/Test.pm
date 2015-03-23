use v6;

module PDF::Grammar::Test {

    use Test;
    use JSON::Tiny;

    # allow only json compatible data
    multi sub json-eqv (EnumMap:D $a, EnumMap:D $b) {
        if +$a != +$b { return False }
	for $a.kv -> $k, $v {
            unless $b{$k}:exists && json-eqv($a{$k}, $b{$k}) {
                return False;
            }
	}
	return True;
    }
    multi sub json-eqv (List:D $a, List:D $b) {
        if +$a != +$b { return False }
	for (0 .. +$a-1) {
	    return False
		unless (json-eqv($a[$_], $b[$_]));
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
	note "data type mismatch";
	note "  - expected: {$b.perl}";
	note "  -      got: {$a.perl}";
	return False;
    }

    use Test;
    sub is-json-equiv($got, $expected, Str $test = '') is export(:is-json-equiv) {
        unless ok(json-eqv($got, $expected), $test) {
                diag "expected: " ~ to-json($expected);
                diag "got     : " ~ to-json($got)
            };

    }

    our sub parse-tests($class, $input, :$parse is copy, :$actions,
			:$rule = 'TOP', :$suite, :%expected) {

        $parse //= do { 
            $class.subparse( $input, :$rule, :$actions)
        };

        my $parsed = %expected<parse> // $input;

        if $input.defined {
            my $desc = ($input.chars < 60
                        ?? $input
                        !! [~] $input.substr(0, 32), ' ... ', $input.substr(*-20))\
                        .subst(/\n+/, ' ', :g);
            is(~$parse, $parsed, "{$suite}: " ~ $rule ~ " parse: " ~ $desc)
        }
        else {
            ok(~$parse, "{$suite}: " ~ $rule ~ " parsed")
        }

        if (my $expected-ast = %expected<ast>).defined {
            is-json-equiv($parse.ast, $expected-ast, "{$suite} $rule - ast");
        }
        else {
            if defined $parse.ast {
                note {untested_ast =>  $parse.ast}.perl
                    unless %expected<ast>:exists;
            }
        }
    }
}
