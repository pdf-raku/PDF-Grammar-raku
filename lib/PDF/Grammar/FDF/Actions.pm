use v6;

use PDF::Grammar::PDF::Actions;

# rules for constructing PDF::Grammar::FDF AST                                                                                                 

class PDF::Grammar::FDF::Actions
    is PDF::Grammar::PDF::Actions {

    method TOP($/) { make $<fdf>.ast }
    method fdf-header ($/) { make $<version>.Rat }
    method fdf($/) {
        my %fdf;

        %fdf<header> = $<fdf-header>.ast;

        my @contents = $<body>».ast;
        %fdf<body> = @contents;

        make %fdf;
    }

};
