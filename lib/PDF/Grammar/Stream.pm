use v6;

# raw stream parse mode. In particular, comments are not applicable

grammar PDF::Grammar::Stream {
    token ws {
       # Turn off white-space handling
        <!ww>
        [ "\t" ]*
    }

    token eol {"\r\n"  # ms/dos
               | "\n"  # 'nix
               | " \n" # 'nix - trailing blank
               | "\r"  # mac-osx
               | " \r" # mac-osx - trailing blank
    }

    regex char     { . }    # omit whitespace
    regex chars    { .* }   # omit whitespace
}
