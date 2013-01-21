use v6;

grammar PDF::Grammar:ver<0.0.3> {
    # abstract base grammar for PDF Elements, see instances:
    # PDF::Grammar::Content  - Text and Graphics Content
    # PDF::Grammar::FDF      - Describes FDF (Form Data) files
    # PDF::Grammar::PDF     - Overall PDF Document Structure
    # 

    # [PDF 1.7] 7.2.2 Character Set + 7.2.3 Comment characters
    # ---------------
    # This <ws> rule treats % as "comment to eol".
    token ws_char {'%' <- eol>* <eol>? | "\n" | "\t" | "\o12" | "\f" | "\r" | " "}

    token ws {
	<!ww>
	<ws_char>*}

    token eol {"\r\n"  # ms/dos
               | "\n"  #'nix
               | "\r"} # mac-osx

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token integer { ['+' | '-']? \d+ }
    # reals must have at least one digit either before or after the decimal
    # point
    token real { ['+' | '-']? [[\d+\.\d*] | [\d*\.\d+]] }

    rule number { <real> | <integer> }

    token line_continuation {"\\"<eol>}
    token octal_code { <[0..7]> ** 1..3 }
    token char_code  {<[nrtbf\(\)\\]>}
    token escape_seq { '\\'[<octal_code>|<char_code>]? }
    # literal_character - all but '(' ')' '\'
    token printable_char{<[\! .. \~]>+}
    token literal_escaped {<[ \( \) \\ \n \r ]>}
    token literal_chars { <-literal_escaped>+ }
    # nb
    # -- new-lines are acceptable within strings
    # -- nested parenthesis are acceptable - allow recursive substrings
    rule literal_string {'('[<line_continuation>|<eol>|<escape_seq>|<literal_string>|<literal_chars>]*')'}

    # hex strings
    token hex_char {<xdigit>**1..2}
    token hex_string { \< [<xdigit>|<ws_char>]* \> }

    rule string {<hex_string>|<literal_string>}

    token name_char_number_symbol { '##' }
    token name_char_escaped { '#'<hex_char> }
    # [PDF 1.7] 7.2.2 Character Set
    regex delimiter_char {<[ \( \) \< \> \[ \] \{ \} \/ \% \# ]>}
    token name_chars_regular{ [<[\! .. \~] - delimiter_char>]+ }

    rule name { '/'[<name_chars_regular>|<name_char_escaped>|<name_char_number_symbol>]+ }

    # [PDF 1.7] 7.3.2  Boolean objects + Null object
    # ---------------
    token bool { ['true' | 'false'] }

    token null { 'null' }

    rule array {\[ <operand>* \]}
    rule dict {'<<' [<name> <operand>]* '>>'}

    # Operand - as permitted in Content streams [PDF 1.7] 7.8.2
    rule operand { <number> | <bool> | <string> | <name> | <array> | <dict> | <null> }
};
