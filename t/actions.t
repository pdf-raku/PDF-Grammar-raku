#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar;
use PDF::Grammar::Actions;

my $sample_content1 = '(Hello\nWorld\043) Tj';

my %escape_char_mappings = (
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

for %escape_char_mappings.kv -> $escape_seq, $expected_result {
    my $p = PDF::Grammar.parse($escape_seq, :rule('escape_seq'), :actions($actions));
    die ("unable to parse escape_seq: $escape_seq")
	unless $p;
    my $result = $p.ast;
    is($result, $expected_result, "string escape seq: $escape_seq");
}

my @tests = (
#    rule                      input               result
    'null',                    'null',             Any,
    'bool',                    'true',             True,
    'bool',                    'false',            False,

    'name_char_number_symbol', '##',               '#',
    'hex_char',                '6D',               'm',
    'name_char_escaped',       '#6E',              'n'
,
    'name_chars_printable',    'snoopy',           'snoopy',
    'name',                    '/snoopy',          'snoopy',
    'name',                    '/s#6Eo#6fpy',      'snoopy',

    'hex_string',              '<736E6F6f7079>',   'snoopy',

    'literal_string',          '(hello world\41)',     'hello world!',
    'literal_string',          '(hi\nagain)',          "hi\nagain",
    'literal_string',          "(hi\r\nagain)",        "hi\nagain",
    'literal_string',          '(perl(6) rocks!)',     'perl(6) rocks!',
    'literal_string',          "(continued\\\n line)", 'continued line',

    'string',                  '(hi)',             'hi',
    'string',                  "<68\n69>",         'hi',

    'integer',                 '42',                42,
    'real',                    '12.5',              12.5,
    'number',                  '42',                42,
    'number',                  '12.5',              12.5,

    );

for @tests -> $rule, $string, $expected_result {
    my $p = PDF::Grammar.parse($string, :rule($rule), :actions($actions));
    die ("unable to parse as $rule: $string")
	unless $p;
    my $result = $p.ast;
    if ($expected_result.isa('Any')) {
	ok($result.isa('Any'), "rule $rule: $string => (Any)");
    }
    else {
	is($result, $expected_result, "rule $rule: $string => $expected_result");
    }
}

my $p = PDF::Grammar.parse('<</MoL 42>>', :rule('dict'), :actions($actions));

my $dict = $p.ast;
my $dict_eqv = {'MoL' => (number => 42)};

ok($dict eqv $dict_eqv, "dict structure")
    or diag {dict => $dict, eqv => $dict_eqv}.perl;

$p = PDF::Grammar.parse('[ 42 (snoopy) <</foo (bar)>>]', :rule('array'), :actions($actions));
my $array = $p.ast;

my $array_eqv = [
    number => 42,
    string => 'snoopy',
    dict => {
	foo => (string => 'bar')
     },
];

ok($array eqv $array_eqv, "array structure")
    or diag {array => $array, eqv => $array_eqv}.perl;

done;
