PDF-Grammar
===========

Although PDF documents do not lend themselves to an overall BNF style grammar
description; there are areas where these can be put to use, including:

- The overall file structure (headers, objects, cross-reference tables and footers).
- The operands that make up content streams. These are used to markup text, forms,
images and graphical elements.

PDF::Grammar is under construction as an experimental/example Perl 6 grammar
for parsing and validation of real-world PDF examples. It currently implements
four grammars:

`PDF::Grammar::Content` - describes the text and graphics operators that are used to produce page layout.

`PDF::Grammar::FDF` - this describes the file structure of FDF (Form Data)
exchange files.

`PDF::Grammar::PDF` - this  describes the file structure of PDF documents,
including headers, trailers, top-level objects and the cross-reference table.

`PDF::Grammar::Function` - a tokeniser for Postscript Calculator (type 4) functions. 

PDF-Grammar has so far been tested against a limited sample of PDF documents
and has not yet been put to use for any serious PDF processing. The grammar is still evolving and is likely to change.

I have been working off the PDF 1.7 reference manual (http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_reference_1-7.pdf). I've relaxed rules, when needed, to handle real-world examples.

Rakudo Star
-----------
You'll first need to download and build Rakudo Star 2013.05 or better (http://rakudo.org/downloads/star/ - don't forget the final `make install`):

Ensure that `perl6` and `panda` are available on your path, e.g. :

    % export PATH=~/src/rakudo-star-2013.05/install/bin:$PATH

You can then use `panda` to test and install `PDF::Grammar`:

    % panda install PDF::Grammar

Usage Notes
-----------

- PDF input files typically contain a mixture of ascii directives and binary data, plus byte-orientated addressing. For this
reason **`latin1` encoding is recommended **. For example:

   ```% perl6 -MPDF::Grammar::PDF -e"say PDF::Grammar::PDF.parse( slurp($f, :enc<latin1>) )"```

- `pdftk` is a useful utility for preprocessing pdfs, including uncompression and decryption:

    ```
    % pdftk flyer.pdf output flyer.unc.pdf uncompress
    % perl6 -MPDF::Grammar::PDF -e"say PDF::Grammar::PDF.parsefile( 'flyer.unc.pdf' )"
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
