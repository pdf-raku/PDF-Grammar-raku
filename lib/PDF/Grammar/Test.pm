use v6;

module PDF::Grammar::Test {

    use Test;
    use JSON::Tiny;
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

        if (my $ast = %expected<ast>).defined {
            is(to-json($parse.ast), to-json($ast), "{$suite} $rule - ast");
        }
        else {
            if defined $parse.ast {
                note {untested_ast =>  $parse.ast}.perl
                    unless %expected<ast>:exists;
            }
        }
    }
}
