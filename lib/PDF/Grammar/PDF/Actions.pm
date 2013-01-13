use v6;

use PDF::Grammar::Actions;

# rules for constructing operand values for PDF::Grammar::PDF

class PDF::Grammar::PDF::Actions is PDF::Grammar::Actions {

    method pdf($/) {
	my %pdf;

	%pdf<header> = $<pdf_header>.ast;

	my @contents = $<content>.map({$_.ast});
	%pdf<contents> = @contents;

	make %pdf;
    }

    method pdf_header ($/) { make $<version>.Num }
    method pdf_tail ($/) { make $<trailer>.ast }

    method trailer ($/) {
	make $<byte_offset>.Int => $<dict>.ast;
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
	my ($operand) = $/.caps;
	make $operand.value.ast;
    }

    method dict ($/) {
	my @names = @<name>.map({ $_.ast });
	my @operands = @<operand>.map({ $_.ast });

	my %dict;
	%dict{ @names } = @operands;

	make %dict;
    }

    method array ($/) {
	my @operands = @<operand>.map({ $_.ast });
	make @operands;
    }

    method content($/) {
	my %content;
        my @indirect_objects = $<indirect_object>.map({ $_.ast });
	%content<objects> = @indirect_objects;
	%content<xref> = $_.ast
	    for $<xref>;
	%content<trailer> = $_.ast
	    for $<trailer>;

	make %content;
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
	%entry<byte_offset> = $<byte_offset>.Int;
	%entry<generation_number> = $<generation_number>.Int;
	%entry<status> = $<obj_status>.Str;

	make %entry;
    }

   # stream_head, stream_tail:
   # we don't actually capture streams, which can be huge and represent the
   # majority of data in a typical PDF. Rather we just return the byte
   # offsets of the start and the end of the stream and leave it up to the
   # caller to disseminate

    method stream_head($/) {
	make $<dict>.ast => $/.to;
    }

    method stream_tail($/) {
	make $/.from;
    }

    method stream($/) {
	my %stream;
	(%stream<atts>, %stream<stream_start>) = $<stream_head>.ast.kv;
	%stream<stream_end> = $<stream_tail>.ast;
	make %stream;
    }
}
