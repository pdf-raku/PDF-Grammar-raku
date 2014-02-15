use v6;

use PDF::Grammar::PDF::Actions;

# rules for constructing PDF::Grammar::FDF AST                                                                                                 

class PDF::Grammar::FDF::Actions
    is PDF::Grammar::PDF::Actions {

    method TOP($/) { make $<fdf>.ast }
    method fdf-header ($/) { make $<version>.Rat }
    method fdf($/) {
	my $body = [ $<body>>>.ast ];
        make {
	    header => $<fdf-header>.ast,
	    body => $body,
        }
     }
};
