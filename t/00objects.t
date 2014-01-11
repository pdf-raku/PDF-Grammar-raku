#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar;
use PDF::Grammar::Test;
use PDF::Grammar::Actions;
use PDF::Grammar::Attributes;

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
    ws =>              {input => " %hi\r",           ast => Mu},
    ws =>              {input => "\%XX\n \%\%YYY\n", ast => Mu},
    ws =>              {input => '%bye',             ast => Mu},

    null =>            {input => 'null',             ast => Mu},

    bool =>            {input => 'true',             ast => True},
    bool =>            {input =>  'false',           ast => False},

    name-chars =>      {input => '##',               ast => '#'},
    hex-char =>        {input => '6D',               ast => 'm'},
    name-chars =>      {input => '#6E',              ast => 'n'},
    name-chars =>      {input => 'snoopy',           ast => 'snoopy'},
    name =>            {input => '/snoopy',          ast => 'snoopy'},
    name =>            {input => '/s#6Eo#6fpy',      ast => 'snoopy'},

    hex-string =>      {input => '<736E6F6f7079>',   ast => 'snoopy'},

    literal-string =>  {input => '(hello world\41)',      ast => 'hello world!'},
    literal-string =>  {input => '(hi\nagain)',           ast => "hi\nagain"},
    literal-string =>  {input => "(hi\r\nagain)",         ast => "hi\nagain"},
    literal-string =>  {input => '(perl(6) rocks! :-\))', ast => 'perl(6) rocks! :-)'},
    literal-string =>  {input => "(continued\\\n line)",  ast => 'continued line'},
    literal-string =>  {input => '(stray back\-slash)',   ast => 'stray back-slash'},
    literal-string =>  {input => "(try\\\n\\\n%this\\\n)",ast => 'try%this'},

    string =>          {input => '(hi)',             ast => 'hi'},
    string =>          {input => "<68\n69>",         ast => 'hi'},
    string =>          {input => "<6\n869>",         ast => 'hi'},
    string =>          {input => "<68\n7>",          ast => 'hp'},

    integer =>         {input => '42',               ast => 42},
    real =>            {input => '12.5',             ast => 12.5e0},
    number =>          {input => '42',               ast => 42},
    number =>          {input => '12.5',             ast => 12.5e0},

    object => {type => 'string',
	       subtype => 'literal',  input => '(hi)',            ast => 'hi'},

    object => {type => 'string',
	       subtype => 'hex',      input => '<6869>',          ast => 'hi'},

    object => {type => 'number',
                  subtype => 'integer',  input => '-042',         ast => -42},

    object => {type => 'number',
                  subtype => 'real',     input => '+3.50',        ast => 3.5e0},

    object => {type => 'dict',     input => '<</Length 42>>',     ast => {Length => 42}},

    object => {type => 'array',    input => '[/Apples(oranges)]', ast => ['Apples', 'oranges']},

    object => {type => 'bool',     input => 'true',              ast => True},
    object => {type => 'bool',     input => 'false',             ast => False},
    object => {type => 'dict',     input => '<</Length 42>>',    ast => {Length => 42}},

    );

for @tests {
    my $rule = .key;
    my %test = .value;
    my $input = %test<input>;

    my $p = PDF::Grammar.parse($input, :rule($rule), :actions($actions));
    PDF::Grammar::Test::parse_tests($input, $p, :rule($rule), :suite($rule), :expected(%test) );
    
    my $type = %test<type>;
 
    if $p && $type {
    
       my $result = $p.ast;
       if $result.can('pdf-type') {
            diag "type: " ~ $result.pdf-type;
            is($result.pdf-type, $type, $rule ~ ' - type');
        }
        else {
            diag "$rule - doesn't do .pdf-subtype";
            fail( $rule ~ ' - type' );
        }
    }

    my $subtype = %test<subtype>;

    if $p && $subtype {
       
       my $result = $p.ast;
       if $result.can('pdf-subtype') {
            diag "subtype: " ~ $result.pdf-subtype;
            is($result.pdf-subtype, $subtype, $rule ~ ' - subtype');
        }
        else {
            diag "$rule - doesn't do .pdf-subsubtype";
            fail( $rule ~ ' - subtype' );
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
