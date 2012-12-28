use v6;

use PDF::Grammar::Simple::Xref;

grammar PDF::Grammar::Simple {
    #
    # A Simple theoretical PDF grammar, first draft
    # - doesn't handle PDFs that are linearized PDFs or encrypted
    # - eats memory/slow - don't try on documents > ~ 200K
    # - token level parsing only, no attempt to interpret high level
    #   objects (e.g. Fonts, Pages)
    # - limited to non-existant stream parsing
    # - no attempt yet to capture content
    #
    rule TOP {<pdf>}
    rule pdf {^<header><eol>(<content>+)'%%EOF'<eol>?$}
    rule content {<body><xref><trailer>} 

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token header {'%PDF-1.'\d}
    token eol {"\r\n"  # ms/dos
               | "\n"  #'nix
               | "\r"} # macosx
    rule body {<object>*}

    rule xref {<PDF::Grammar::Simple::Xref::xref>}

    # [PDF 1.7] 7.2.2 Character Set + 7.2.3 Comment characters
    # ---------------
    # This <ws> rule treats % as "comment to eol".
    token ws_char {['%' \N* \n? | "\n" | "\t" | "\o12" | "\f" | "\r" | " "]}
    token ws {
        <!ww>
        <ws_char>*
    }

    # [PDF 1.7] 7.3.2  Boolean Objects
    # ---------------
    token bool { ['true' | 'false'] }

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    # nb must be at least one digit either before or after the decimal point
    token int { ('+' | '-')? \d+ }
    rule real { ('+' | '-')? ((\d+\.\d*) | (\d*\.\d+)) | <int> }

    token literal_char_escaped { '\n' | '\r' | '\t' | '\b' | '\f' | '\(' | '\)' | '//' | ('\\' <[0..7]> ** 1..3) }
    # literal_character - all but '(' ')' '\'
    token literal_char_regular { <-[\(\)\\]> }
    token literal_line_continuation {"\\"<eol>}
    rule literal_substring { '('(<literal_char_escaped>|<literal_char_regular>|<literal_substring>|<literal_line_continuation>)*')' }

    # nb
    # -- new-lines are acceptable within strings
    # -- nested parenthesis are acceptable - allow recursive substrings
    rule literal_string {<literal_substring>}
    # hex strings

    token hex_char {<xdigit>**1..2}
    token hex_string { \<<hex_char>(<hex_char>|<eol>)*\> }

    rule string {<hex_string>|<literal_string>}

    token name_char_number_symbol { '##' }
    # name escapes are strictly two hex characters
    token name_char_escaped { \#(<xdigit>**2) }
    # all printable but '#', '/', '[', ']',
##  not having any luck with the following regex; me? rakudo-star? (2012.11)
##   token name_char_printable { <[\!..\~] - [\[\#\]\//\(\)\<\>]> }
##  .. rather more ungainly...
    token name_char_printable { <[a..z A..Z 0..9 \! \" \$..\' \*..\. \: \; \= \? \@ _ \^ \' \{ \| \} \~]> }

    rule name { '/'(<name_char_printable>|<name_char_escaped>|<name_char_number_symbol>)* }

    rule array {\[ <object>* \]}

    rule dict {'<<' (<name> <object>)* '>>'}

    # stream parsing - efficiency matters here
    token stream_marker {stream<eol>}
    # the spec says that a newline should procede 'endstream'. In practice the
    # only common factor seems to be the trailing 'endobj'.
    token endstream_marker {<eol>?endstream<ws_char>+<?before 'endobj'>}
    rule stream {<dict> <stream_marker>.*?<endstream_marker>}

    token null { 'null' }

    rule indirect_object {<int> <int> obj <object>* endobj}
    rule indirect_reference {<int> <int> R}

    rule object { <stream> | <indirect_reference> | <indirect_object> | <real> | <int> | <bool> | <string> | <name> | <array> | <dict> | <null> }

 rule trailer {
        trailer<eol>
        <dict>
        startxref<eol>\d+<eol>}

}

