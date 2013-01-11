use v6;

use PDF::Grammar::Stream;

grammar PDF::Grammar::Xref is PDF::Grammar::Stream {

    rule  xref {xref<eol><subsection>+}
    rule  subsection {\d+\x20\d+<eol><entry>+}
    rule  entry {<byte_offset>\x20<generation_number>\x20<status><eol>}
    token byte_offset {\d**10}
    token generation_number {\d**5}
    rule  status {<status_free>|<status_inuse>}
    token status_free {f}
    token status_inuse {n}
};
