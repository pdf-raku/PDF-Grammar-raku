grammar PDF::Grammar::Simple::Xref {

    token ws {
       # Turn off white-space handling
        <!ww>
        [ "\t" ]*
    }

    rule  xref {xref\r?\n<subsection>+}
    rule  subsection {\d+\x20\d+\r?\n<entry>+}
    rule  entry {<byte_offset>\x20<generation_number>\x20<status><eol>}
    token byte_offset {\d**10}
    token generation_number {\d**5}
    rule  status {<status_free>|<status_inuse>}
    token status_free {f}
    token status_inuse {n}
    rule  eol { "\r\n" | " \r" | " \n"
                | "\n" # not part of the standard, but seen in practice
                       # e.g. pdftk generated xref
    }
};