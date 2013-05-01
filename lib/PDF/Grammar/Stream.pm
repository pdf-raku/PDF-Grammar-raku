use v6;

# raw stream parse mode. In particular, limited whitespace, no comments

grammar PDF::Grammar::Stream {
    token ws {
       # Turn off white-space handling
        <!ww>
        [ "\t" ]*
    }

    regex char     { . }    # omit whitespace
    regex chars    { .* }   # omit whitespace
}
