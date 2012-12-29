grammar PDF::Grammar::Body::Xref {

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

    rule  xref {xref<eol><subsection>+}
    rule  subsection {\d+\x20\d+<eol><entry>+}
    rule  entry {<byte_offset>\x20<generation_number>\x20<status><eol>}
    token byte_offset {\d**10}
    token generation_number {\d**5}
    rule  status {<status_free>|<status_inuse>}
    token status_free {f}
    token status_inuse {n}
};
