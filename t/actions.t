#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar;
use PDF::Grammar::Actions;
use PDF::Grammar::Attributes;

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
    my $p = PDF::Grammar.parse($escape_seq, :rule('literal'), :actions($actions));
    die ("unable to parse escape_seq: $escape_seq")
	unless $p;
    my $result = $p.ast;
    is($result, $expected_result, "literal escape: $escape_seq");
}

my @tests = (
#    rule                      input               result

    'ws',                      ' ',                Any,
    'ws',                      "  \r\n \t",        Any,
    'ws',                      " %hi\r",           Any,
    'ws',                      "\%XX\n \%\%YYY\n", Any,
    'ws',                      '\%bye',            Any,

    'null',                    'null',             Any,

    'bool',                    'true',             True,
    'bool',                    'false',            False,

    'name_chars',              '##',               '#',
    'hex_char',                '6D',               'm',
    'name_chars',              '#6E',              'n',
    'name_chars',              'snoopy',           'snoopy',
    'name',                    '/snoopy',          'snoopy',
    'name',                    '/s#6Eo#6fpy',      'snoopy',

    'hex_string',              '<736E6F6f7079>',   'snoopy',

    'literal_string',          '(hello world\41)',      'hello world!',
    'literal_string',          '(hi\nagain)',           "hi\nagain",
    'literal_string',          "(hi\r\nagain)",         "hi\nagain",
    'literal_string',          '(perl(6) rocks! :-\))', 'perl(6) rocks! :-)',
    'literal_string',          "(continued\\\n line)",  'continued line',
    'literal_string',          "(try\\\n\\\n%this\\\n)",'try%this',

    'string',                  '(hi)',             'hi',
    'string',                  "<68\n69>",         'hi',
    'string',                  "<6\n869>",         'hi',
    'string',                  "<68\n7>",          'hp',

    'integer',                 '42',                42,
    'real',                    '12.5',              12.5,
    'number',                  '42',                42,
    'number',                  '12.5',              12.5,

    'operand' => ['string',
		  'literal'],  '(hi)',              'hi',

    'operand' => ['string',
		  'hex'],      '<6869>',            'hi',

    'operand' => ['number',
		  'integer'],  '-042',             -42,

    'operand' => ['number',
		  'real'],     '+3.50',             3.5,

    'operand' => ['dict'],     '<</Length 42>>',    {Length => 42},

    'operand' => ['array'],    '[/Apples(oranges)]',['Apples', 'oranges'],

    'operand' => ['bool'],     'true',              True,
    'operand' => ['bool'],     'false',             False,
    'operand' => ['dict'],     '<</Length 42>>',    {Length => 42},

    );

for @tests -> $_rule, $string, $expected_result {
    my $expected_type;
    my $expected_subtype;
    my $rule;

    if $_rule.isa('Pair') {
	($rule, my $type) = $_rule.kv;
	($expected_type, $expected_subtype) = @$type;
    }
    else {
	$rule = $_rule;
    }

    my $p = PDF::Grammar.parse($string, :rule($rule), :actions($actions));
    die ("unable to parse as $rule: $string")
	unless $p;
    my $result = $p.ast;
    if defined $expected_result {
	is($result, $expected_result, "rule $rule: $string => $expected_result");
    }
    else {
	ok(! defined($result), "rule $rule: $string => (undef)");
    }

    if ($expected_type) {
	my $test = "rule $rule: $string has type $expected_type";
	if $result.can('pdf_type') {
	    is($result.pdf_type, $expected_type, $test);
	}
	else {
	    diag "$rule - doesn't do .pdf_type";
	    fail( $test );
	}
    }

    if ($expected_subtype) {
	my $test = "rule $rule: $string has subtype $expected_subtype";
	if $result.can('pdf_subtype') {
	    diag "type: " ~ $result.pdf_type;
	    diag "subtype: " ~ $result.pdf_subtype;
	    is($result.pdf_subtype, $expected_subtype, $test);
	}
	else {
	    diag "$rule - doesn't do .pdf_subtype";
	    fail( $test );
	}
    }
}

my $p = PDF::Grammar.parse('<</MoL 42>>', :rule('dict'), :actions($actions));

my %dict = $p.ast;
my $dict_eqv = {'MoL' => 42};

is(%dict, $dict_eqv, "dict structure")
    or diag {dict => %dict, eqv => $dict_eqv}.perl;

$p = PDF::Grammar.parse('[ 42 (snoopy) <</foo (bar)>>]', :rule('array'), :actions($actions));
my $array = $p.ast;

my $array_eqv = [42, 'snoopy', {foo => 'bar'}];

is($array, $array_eqv, "array structure")
    or diag {array => $array, eqv => $array_eqv}.perl;

done;
