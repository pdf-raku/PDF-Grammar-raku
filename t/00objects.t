#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar;
use PDF::Grammar::Test;
use PDF::Grammar::Actions;

my %escapes = (
    '\n'   => "\n", 
    '\r'   => "\r", 
    '\t'   => "\t", 
    '\b'   => "\b",
    '\('   => '(',
    '\)'   => ')',
    '\041' => '!',
    '\10'  => "\b",
    );

my $actions = PDF::Grammar::Actions.new;

for %escapes.kv -> $escape_seq, $expected_result {
    my $p = PDF::Grammar.parse($escape_seq, :rule('literal'), :actions($actions));
    die ("unable to parse escape_seq: $escape_seq")
        unless $p;
    my $result = $p.ast;
    is($result, $expected_result, "literal escape: $escape_seq");
}

my @tests = (
    { :rule<ws>, input => ' ',                ast => Mu},
    { :rule<ws>, input => "  \r\n \t",        ast => Mu},
    { :rule<ws>, input => "  \x0A \x0 ",      ast => Mu},
    { :rule<ws>, input => " %hi\r",           ast => Mu},
    { :rule<ws>, input => "\%XX\n \%\%YYY\n", ast => Mu},
    { :rule<ws>, input => '%bye',             ast => Mu},

    { :rule<name>, input => '/##',              ast => :name<#>},
    { :rule<name>, input => '/#6E',             ast => :name<n>},
    { :rule<name>, input => '/snoopy',          ast => :name<snoopy>},
    { :rule<name>, input => '/s#6Eo#6fpy',      ast => :name<snoopy>},

    # [PDF 1.7] 3.2.4 "it is recommended that the sequence of bytes (after
    #        expansion of # sequences, if any) be interpreted according
    #        to UTF-8, a variable-length byte-encoded representation".
    { :rule<name>, input => '/Zs#c3#b3fia',      ast => :name<Zsófia>},

    { :rule<hex-string>, input => '<736E6F6f7079>',   ast => :hex-string<snoopy>},

    { :rule<literal-string>, input => '(hello world\41)',      ast => :literal('hello world!')},
    { :rule<literal-string>, input => '(hi\nagain)',           ast => :literal("hi\nagain")},
    { :rule<literal-string>, input => "(hi\r\nagain)",         ast => :literal("hi\nagain")},
    { :rule<literal-string>, input => '(perl(6) rocks! :-\))', ast => :literal('perl(6) rocks! :-)')},
    { :rule<literal-string>, input => "(continued\\\n line)",  ast => :literal('continued line')},
    { :rule<literal-string>, input => '(stray back\-slash)',   ast => :literal('stray back-slash')},
    { :rule<literal-string>, input => "(some\ncontrol\x[b]chars)",   ast => :literal("some\ncontrol\x[b]chars")},
    { :rule<literal-string>, input => "(try\\\n\\\n%this\\\n)",ast => :literal('try%this')},

    { :rule<string>, input => '(hi)',             ast => :literal<hi>},
    { :rule<string>, input => "<68\n69>",         ast => :hex-string<hi>},
    { :rule<string>, input => "<6\n869>",         ast => :hex-string<hi>},
    { :rule<string>, input => "<68\n7>",          ast => :hex-string<hp>},

    { :rule<int>, input => '42',               ast => :int(42)},
    { :rule<real>, input => '12.5',             ast => :real(12.5e0)},
    { :rule<number>, input => '42',               ast => :int(42)},
    { :rule<number>, input => '12.5',             ast => :real(12.5e0)},

    { :rule<object>, input => 'true',             ast => :bool},
    { :rule<object>, input => 'false',            ast => :!bool},
    { :rule<object>, input => 'null',             ast => :null(Any)},

    { :rule<object>, input => '(hi)',             ast => :literal<hi>},

    { :rule<object>, input => '<6869>',                    ast => :hex-string<hi>},

    { :rule<object>, input => '-042',                      ast => int => -42},

    { :rule<object>, input => '+3.50',                     ast => real => 3.5e0},

    { :rule<object>, input => 'true',              ast => :bool},
    { :rule<object>, input => 'false',             ast => :!bool},

    { :rule<object>, input => '<</Length 42>>',    ast => :dict{ Length => :int(42)}},
    { :rule<object>, input => '[/Apples(oranges)]', ast => :array[ :name<Apples>, :literal<oranges> ]},
    { :rule<object>, input => '<</MoL 42>>',        ast => :dict{ :MoL( :int(42) )} },
    { :rule<object>, input => '[ 42 (snoopy) <</foo (bar)>>]', ast => :array[:int(42), :literal<snoopy>, :dict{foo => :literal<bar>}]},
    );

for @tests -> % ( :$rule!, :$input, *%expected ) {
    PDF::Grammar::Test::parse-tests(PDF::Grammar, $input, :$rule, :$actions, :suite($rule), :%expected );
}

done-testing;
