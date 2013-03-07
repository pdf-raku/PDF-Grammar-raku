# AST Testing - utility functions

module t::AST {

    use Test;

    our sub parse_tests($input, $parse,
                         :$rule, :$suite, :%expected) {

        my $parsed = %expected<parse> // $input;

        if (defined $input) {
            is($parse.Str, $parsed, "{$suite}: " ~ $rule ~ " parse: " ~ $input)
        }
        else {
            ok($parse.Str, "{$suite}: " ~ $rule ~ " parsed")
        }

        if defined (my $ast = %expected<ast>) {
            is($parse.ast, $ast, "{$suite} - ast")
                or diag $parse.ast.perl;
        }
        else {
            if defined $parse.ast {
                note {untested_ast =>  $parse.ast}.perl
                    unless %expected.exists('ast');
            }
            else {
                diag "no {$suite} ast: " ~ ($input // '');
            }
        }
    }
}
