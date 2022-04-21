use PDF::Grammar::COS;

# A Raku grammar for scanning the outer block
# structure of FDF form data exchange files.
grammar PDF::Grammar::FDF
    is PDF::Grammar::COS {

    token doc-type {'FDF'}
}
