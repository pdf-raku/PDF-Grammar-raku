use v6;

use PDF::Grammar::Doc::Actions;

# rules for constructing PDF::Grammar::FDF AST                                                                                                 
class PDF::Grammar::PDF::Actions
    is PDF::Grammar::Doc::Actions {

    method ind-obj-nibble($/) {
        my $object = $<object>.ast;
        if $<stream-head> {
            # locate the start of the stream data following the 'stream' token. The
            # invokee can deterime the length using the /Length entry in the dictionary
            $object = :stream( %( $object.kv,
                                  :start( $<stream-head>.to ),
                               ));
        }
        make (:ind-obj[ $<obj-num>.ast.value, $<gen-num>.ast.value, $object ]);
    }

    method object-stream-indice($/) { make [$<obj-num>.ast.value, $<byte-offset>.ast.value] }
    method object-stream-index($/)  { make [ $<object-stream-indice>>>.ast ] }
}
