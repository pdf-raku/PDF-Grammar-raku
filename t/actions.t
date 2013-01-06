#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar;
use PDF::Grammar::Actions;

use v6;

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

for %escape_char_mappings.kv -> $escape_seq, $expected_result {
    my $p = PDF::Grammar.parse($escape_seq, :rule('escape_seq'), :actions(PDF::Grammar::Actions.new));
    die ("unable to parse escape_seq: $escape_seq")
	unless $p;
    my $result = $p.ast;
    is($result, $expected_result, "string escape seq: $escape_seq");
}

my @tests = (
#    rule                      input               result
    'null',                    'null',             '',
    'bool',                    'true',             1,
    'bool',                    'false',            0,

    'name_char_number_symbol', '##',               '#',
    'hex_char',                '6D',               'm',
    'name_char_escaped',       '#6E',              'n'
,
    'name_chars_printable',    'snoopy',           'snoopy',
    'name',                    '/snoopy',          'snoopy',
    'name',                    '/s#6Eo#6fpy',      'snoopy',
    'hex_string',              '<736E6F6f7079>',   'snoopy',

    'literal_string',          '(hello world\41)', 'hello world!',
    'literal_string',          '(hi\nagain)',      "hi\nagain",
    'literal_string',          "(hi\r\nagain)",    "hi\nagain",
    'literal_string',          '(perl(6) rocks!)', 'perl(6) rocks!',

    'integer',                 '42',               42,
    'real',                    '12.5',             12.5,
    'number',                  '42',               42,
    'number',                  '12.5',             12.5,

    );

for @tests -> $rule, $string, $expected_result {
    my $p = PDF::Grammar.parse($string, :rule($rule), :actions(PDF::Grammar::Actions.new));
    die ("unable to parse as $rule: $string")
	unless $p;
    my $result = $p.ast;
    is($result, $expected_result, "rule $rule: $string => $expected_result");
} 

PDF::Grammar.parse('/s#6Eoopy', :rule('name'), :actions(PDF::Grammar::Actions.new));

done;
