PDF-Grammar
===========

Although PDF documents do not lend themselves to an overall BNF style grammar
description; there are areas where these can be put to use, including:

- The overall file structure (headers, objects, cross-reference tables and footers).
- The operands that make up content streams. These are used to markup text, forms,
images and graphical elements.

PDF::Grammar is an experimental set of Perl 6 grammars for parsing and validation of real-world PDF examples. There are
four grammars:

`PDF::Grammar::Content` - describes the text and graphics operators that are used to produce page layout.

`PDF::Grammar::Content::Fast` - is an optimized version of PDF::Grammar::Content.

`PDF::Grammar::FDF` - this describes the file structure of FDF (Form Data)
exchange files.

`PDF::Grammar::PDF` - this  describes the file structure of PDF documents,
including headers, trailers, top-level objects and the cross-reference table.

`PDF::Grammar::Function` - a tokeniser for Postscript Calculator (type 4) functions. 

PDF-Grammar has so far been tested against a number of sample of PDF documents and may still be subject to change.

I have been working off the PDF 1.7 reference manual (http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_reference_1-7.pdf). I've relaxed rules, when needed, to handle real-world examples.

Usage Notes
-----------

- PDF input files typically contain a mixture of ASCII directives and binary data, plus byte-orientated addressing. For this
reason **`latin1` encoding is recommended **. For example:

   ```% perl6 -MPDF::Grammar::PDF -e"say PDF::Grammar::PDF.parse( slurp($f, :enc<latin1>) )"```

- This module is put to work by the down-stream [PDF](https://github.com/p6-pdf/perl6-PDF-Tools) module. E.g.
  to uncompress a PDF, using the installed `pdf-rewriter` script:

  ```
  % pdf-rewriter.pl --uncompress flyer.pdf
  ```

Examples
--------

- parse some markup content:

    ```% perl6 -MPDF::Grammar::Content -e"say PDF::Grammar::Content.parse('(Hello, world\041) Tj')"```

- parse a PDF file:

   ```% perl6 -MPDF::Grammar::PDF -e"say PDF::Grammar::PDF.parsefile( $f )"```

- dump the contents of a PDF

    ```
    use v6;
    use PDF::Grammar::PDF;
    use PDF::Grammar::PDF::Actions;

    sub MAIN(Str $pdf-file) {
        my $actions = PDF::Grammar::PDF::Actions.new;

        if PDF::Grammar::PDF.parsefile( $pdf-file, :$actions ) {
            say $/.ast.perl;
        }
        else {
            say "failed to parse PDF: $pdf-file";
        }
    }
    ```

Ast Reference
-------------
The action methods in this module return AST trees. Each node in the
tree consists of a key, value pair, where the key is the AST Tag,
indicating the type of the AST node.

For example, here's the AST tree for the following parse:

```
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
my $actions = PDF::Grammar::PDF::Actions.new;

PDF::Grammar::PDF.parse( q:to"--END-DOC--", :rule<ind-obj>, :$actions);
3 0 obj <<
   /Type /Pages
   /Count 1
   /Kids [4 0 R]
>>
endobj
--END-DOC--

say '# ' ~ $/.ast.perl;
# :ind-obj($[3, 0, :dict({:Count(:int(1)), :Kids(:array([:ind-ref($[4, 0])])), :Type(:name("Pages"))})])
```

This is an indirect object (`ind-obj`), it contains a dictionary object (`dict`). Entries in the dictionary are:
- `Count` with integer value (`int`) of 1.
- `Kids`, and array (`array`) containing one indirect reference (`ind-ref`).
- `Type` with name (`name`) 'Pages'.

In most cases, the node type corresponds to the name of the rule or token that was used to construct the node.

This AST representation is used extensively throughout the PDF tool-chain. For example, as an intermediate format by `PDF::Writer` for reserialization.

For reference, here is a list of all AST node types:

*AST Tag* | Perl Type | Description
--- | --- | --- | --- |
array | Array[Any] | Array object type, e.g. `[ 0 0 612 792 ]`
body | Array[Hash] | The FDF/PDF body. A PDF with revisions has multiple body segments
bool | Bool | Boolean object type, e.g. `true`
dict | Hash | Dictionary object type, e.g. `<< /Type /Catalog /Pages 3 0 R >>`
encoded | Str | Raw encoded stream data. This is returned as a latin-1 byte-string.
entries | Array[Hash] | A list of entries in a cross reference segment
decoded | Str | Uncompressed/unencrypted stream data
fdf | Hash | An FDF document
gen-num | UInt | Object generation number
header | Hash | PDF or FDF header, e.g. `%PDF1.4`
hex-string | Str | A hex-string, e.g. `<736e6f6f7079>`
ind-ref | Array[UInt] | An indirect reference, .e.g. `23 2 R`
ind-obj | Any | An indirect object. This is a three element array that contains an object number, generation number and the object
int | Int | Integer object type, e.g. `42`
obj-count | UInt | object count/number of entries in a cross reference segment
obj-first-num | UInt | object first number in a  cross reference segment
obj-num | UInt | Object number
offset | UInt | byte offset of an indirect object in the file.
literal | Str | A literal string, e.g. `(Hello, World!)`
name | Str | String object type, e.g. `/Fred`
null | Mu | Null object type, e.g. `null`
pdf | Hash | A PDF document, consisting of a `header` and `body` array
real | Real | Real object type, e.g. `42.0`
start | UInt | Start position of stream data (returned by `ind-obj-nibble` rule)
startxref | UInt | byte offset from the start of the file to the start of the trailer
stream | Hash | Stream object type. A dictionary indirect object followed by stream data
trailer | Hash | Trailer. This typically contains the trailer `dict` entry.
type | UInt | Index entry type: 0 - free, 1 - inuse, 2 - stream object
version | Rat | The PDF / FDF version number, parsed from the header

## See also

- [PDF](https://github.com/p6-pdf/perl6-PDF-Tools) - for PDF manipulation, including compression, encryption and reading and writing of PDF data.

