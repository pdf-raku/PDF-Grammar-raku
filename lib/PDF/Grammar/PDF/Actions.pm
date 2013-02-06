use v6;

use PDF::Grammar::Actions;

# rules for constructing operand values for PDF::Grammar::PDF

class PDF::Grammar::PDF::Actions is PDF::Grammar::Actions {

    method TOP($/) { make $<pdf>.ast }

    method pdf($/) {
	my %pdf;

	%pdf<header> = $<pdf_header>.ast;

	my @contents = $<body>.map({$_.ast});
	%pdf<body> = @contents;

	make %pdf;
    }

    method pdf_header ($/) { make $<version>.Num }
    method pdf_tail ($/) { make $<trailer>.ast }

    method trailer ($/) {
	my %trailer;
	%trailer<dict> = $<dict>.ast;
	%trailer<byte_offset> = $<byte_offset>.Int;
	make (trailer => %trailer);
    }

    method indirect_reference($/) {
	my @ind_ref = $/.caps.map({ $_.value.ast });
	make (ind_ref => @ind_ref);
    }

    method indirect_object($/) {
	my @ind_obj = $/.caps.map({ $_.value.ast });
	make (ind_obj => @ind_obj);
    }

    method operand($/) {
	my ($operand, $stream) = $/.caps;
	my $value = $operand.value.ast;

	if ($stream) {
	    my %stream;
	    %stream<atts> = $value;
	    (%stream<start>, %stream<end>) = $stream.value.ast.kv;
	    make (stream => %stream)
	}
	else {
	    make $value;
	}
    }

    method body($/) {
	my %body;
        my @indirect_objects = $<indirect_object>.map({ $_.ast });
	%body<objects> = @indirect_objects;
	%body<xref> = $_.ast
	    for $<xref>;
	%body<trailer> = $_.ast
	    for $<trailer>;

	make %body;
    }

    method xref($/) {
	my @sections = $<xref_section>.map({ $_.ast });
	make @sections;
    }

    method xref_section($/) {
	my %section;
	%section<object_first_num> = $<object_first_num>.Int;
	%section<object_count> = $<object_count>.Int;
	my @entries = $<xref_entry>.map({$_.ast});
	%section<entries> = @entries;
	make %section;
    }

    method xref_entry($/) {
	my %entry;
	%entry<offset> = $<byte_offset>.Int;
	%entry<gen> = $<generation_number>.Int;
	%entry<status> = $<obj_status>.Str;

	make %entry;
    }

   # stream_head, stream_tail:
   # we don't actually capture streams, which can be huge and represent the
   # majority of data in a typical PDF. Rather we just return the byte
   # offsets of the start and the end of the stream and leave it up to the
   # caller to disseminate

    method stream_head($/) {
	make $/.to + 1;
    }

    method stream_tail($/) {
	make $/.from - 1;
    }

    method stream($/) {
	make ($<stream_head>.ast => $<stream_tail>.ast);
    }
}
