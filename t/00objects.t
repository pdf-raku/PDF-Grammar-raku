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
    ws =>              {input => ' ',                ast => Mu},
    ws =>              {input => "  \r\n \t",        ast => Mu},
    ws =>              {input => "  \x0A \x0 ",      ast => Mu},
    ws =>              {input => " %hi\r",           ast => Mu},
    ws =>              {input => "\%XX\n \%\%YYY\n", ast => Mu},
    ws =>              {input => '%bye',             ast => Mu},

    name =>            {input => '/##',              ast => :name<#>},
    name =>            {input => '/#6E',             ast => :name<n>},
    name =>            {input => '/snoopy',          ast => :name<snoopy>},
    name =>            {input => '/s#6Eo#6fpy',      ast => :name<snoopy>},

    # [PDF 1.7] 3.2.4 "it is recommended that the sequence of bytes (after
    #        expansion of # sequences, if any) be interpreted according
    #        to UTF-8, a variable-length byte-encoded representation".
    name =>            {input => '/Zs#c3#b3fia',      ast => :name<Zsófia>},

    hex-string =>      {input => '<736E6F6f7079>',   ast => :hex-string<snoopy>},

    literal-string =>  {input => '(hello world\41)',      ast => :literal('hello world!')},
    literal-string =>  {input => '(hi\nagain)',           ast => :literal("hi\nagain")},
    literal-string =>  {input => "(hi\r\nagain)",         ast => :literal("hi\nagain")},
    literal-string =>  {input => '(perl(6) rocks! :-\))', ast => :literal('perl(6) rocks! :-)')},
    literal-string =>  {input => "(continued\\\n line)",  ast => :literal('continued line')},
    literal-string =>  {input => '(stray back\-slash)',   ast => :literal('stray back-slash')},
    literal-string =>  {input => "(try\\\n\\\n%this\\\n)",ast => :literal('try%this')},

    string =>          {input => '(hi)',             ast => :literal<hi>},
    string =>          {input => "<68\n69>",         ast => :hex-string<hi>},
    string =>          {input => "<6\n869>",         ast => :hex-string<hi>},
    string =>          {input => "<68\n7>",          ast => :hex-string<hp>},

    int    =>          {input => '42',               ast => :int(42)},
    real   =>          {input => '12.5',             ast => :real(12.5e0)},
    number =>          {input => '42',               ast => :int(42)},
    number =>          {input => '12.5',             ast => :real(12.5e0)},

    object =>          {input => 'true',             ast => :bool},
    object =>          {input => 'false',            ast => :!bool},
    object =>          {input => 'null',             ast => :null(Any)},

    object =>          {input => '(hi)',             ast => :literal<hi>},

    object => {input => '<6869>',                    ast => :hex-string<hi>},

    object => {input => '-042',                      ast => int => -42},

    object => {input => '+3.50',                     ast => real => 3.5e0},

    object => {input => 'true',              ast => :bool},
    object => {input => 'false',             ast => :!bool},

    object => {input => '<</Length 42>>',    ast => :dict{ Length => :int(42)}},
    object => {input => '[/Apples(oranges)]', ast => :array[ :name<Apples>, :literal<oranges> ]},
    object => {input => '<</MoL 42>>',        ast => :dict{ :MoL( :int(42) )} },
    object => {input => '[ 42 (snoopy) <</foo (bar)>>]', ast => :array[:int(42), :literal<snoopy>, :dict{foo => :literal<bar>}]},
    );

for @tests {
    my $rule = .key;
    my %expected = %( .value );
    my $input = %expected<input>;

    PDF::Grammar::Test::parse-tests(PDF::Grammar, $input, :$rule, :$actions, :suite($rule), :%expected );
}

done;
