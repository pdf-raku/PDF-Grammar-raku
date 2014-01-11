use v6;

module PDF::Grammar::Test {

    use Test;

    our sub parse_tests($input, $parse,
			:$rule = 'TOP', :$suite, :%expected) {

        my $parsed = %expected<parse> // $input;

        if $input.defined {
            is(~$parse, $parsed, "{$suite}: " ~ $rule ~ " parse: " ~ $input)
        }
        else {
            ok(~$parse, "{$suite}: " ~ $rule ~ " parsed")
        }

        if (my $ast = %expected<ast>).defined {
            is($parse.ast.perl, $ast.perl, "{$suite} - ast")
                or diag $parse.ast.perl;
        }
        else {
            if defined $parse.ast {
                note {untested_ast =>  $parse.ast}.perl
                    unless %expected<ast>:exists;
            }
        }
    }
}
