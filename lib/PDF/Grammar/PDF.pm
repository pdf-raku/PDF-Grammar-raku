use v6;

use PDF::Grammar::Doc;

#
# An experimental Perl6 grammar for scanning the basic outer block
# structure of FDF form data exchange files.
#
grammar PDF::Grammar::PDF
    is PDF::Grammar::Doc {

    token doc-type {:i 'pdf' }

    #== PDF Reader Support ==#

    # reads an indirect object, stopping if the start of a stream is encountered
    # typically used when the reader is locating objects via the index and doesn't
    # need to fully scan the PDF. The reader can manually (and lazily) extract the
    # stream using the dictionary /Length entry
    rule ind-obj-nibble { <obj-num=.int> <gen-num=.int> obj [<object=.dict>[ endobj|<stream-head>] || <object> endobj] }

    # support for index loading
    # (1) read the last few bytes of a PDF, parse the 'startxref' directive
    # (2) seek to the indicated position in the PDF, load the xref, which may either be:
    #    a. an immediately cross reference table (see <xref> token)
    #    b. a cross reference stream, indirect object, which may occur anywhere in the PDF
    token postamble {
        .*?
        startxref\n
        <byte-offset=.int>\n
        '%%EOF'\n?
        $
    }

    # PDF reference 1.7 3.4.6 Object Streams
    # These occur as the content of objects of /Type /ObjStm
    # They consist of an index followed by a sequence of pdf objects
    rule object-stream-indice {
        <obj-num=.int> <byte-offset=.int>
    }
    rule object-stream-index {
        <object-stream-indice>+
    }

}
