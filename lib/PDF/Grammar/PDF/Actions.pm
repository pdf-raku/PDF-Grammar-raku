use v6;

use PDF::Grammar::Actions;

# rules for constructing operand values for PDF::Grammar::PDF

class PDF::Grammar::PDF::Actions is PDF::Grammar::Actions {

    method pdf($/) {
	my %pdf;
	my @contents = $<content>.map({$_.ast});
	%pdf<contents> = @contents;
	%pdf<header> = $<pdf_header>.ast;
	make %pdf;
    }

    method pdf_header ($/) { make $<version>.Num }
    method pdf_tail ($/) { make $<trailer>.ast }

    method trailer ($/) {
	make $<byte_offset>.Int => $<dict>.ast;
    }

    method indirect_reference($/) {
	my @ind_ref = $/.caps.map({ $_.value.ast });
	make @ind_ref;
    }

    method indirect_object($/) {
	my @ind_obj = $/.caps.map({ $_.value.ast });
	make @ind_obj;
    }

    method object($/) {
	my ($object) = $/.caps;
	make $object.value.ast;
    }

    method dict ($/) {
	my @names = @<name>.map({ $_.ast });
	my @objects = @<object>.map({ $_.ast });

	my %dict;
	%dict{ @names } = @objects;

	make (dict => %dict);
    }

    method array ($/) {
	my @objects = @<object>.map({ $_.ast });
	make @objects;
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
   # majority of content in a typical PDF. Rather we just return the byte
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
	(%stream<dict>, %stream<stream_start>) = $<stream_head>.ast.kv;
	%stream<stream_end> = $<stream_tail>.ast;
	make %stream;
    }
}
