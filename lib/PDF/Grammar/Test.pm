use v6;

module PDF::Grammar::Test {

    use Test;
    use JSON::Tiny;

    # allow only json compatible data
    multi sub json-eqv (EnumMap:D $a, EnumMap:D $b) {
        if +$a != +$b { return False }
	for $a.kv -> $k, $v {
            unless $b.exists_key($k) && json-eqv($a{$k}, $b{$k}) {
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
    multi sub json-eqv (Any $a, Any $b) {
        return json-eqv( %$a, $b) if $a.isa(Pair);
        return json-eqv( $a, %$b) if $b.isa(Pair);
        return True if !$a.defined && !$b.defined;
	note "data type mismatch";
	note "  - expected: {$b.perl}";
	note "  -      got: {$a.perl}";
	return False;
    }

    use Test;
    our sub parse-tests($class, $input, :$parse is copy, :$actions,
			:$rule = 'TOP', :$suite, :%expected) {

        $parse //= do { 
            $class.subparse( $input, :$rule, :$actions)
        };

        my $parsed = %expected<parse> // $input;

        if $input.defined {
            is(~$parse, $parsed, "{$suite}: " ~ $rule ~ " parse: " ~ $input)
        }
        else {
            ok(~$parse, "{$suite}: " ~ $rule ~ " parsed")
        }

        if (my $expected-ast = %expected<ast>).defined {
            unless ok(json-eqv($parse.ast, $expected-ast), "{$suite} $rule - ast") {
                diag "expected: " ~ to-json($expected-ast);
                diag "got     : " ~ to-json($parse.ast)
            };
        }
        else {
            if defined $parse.ast {
                note {untested_ast =>  $parse.ast}.perl
                    unless %expected<ast>:exists;
            }
        }
    }
}
