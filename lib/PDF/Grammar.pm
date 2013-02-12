use v6;

grammar PDF::Grammar:ver<0.0.5> {
    # abstract base grammar for PDF Elements, see instances:
    # PDF::Grammar::Content  - Text and Graphics Content
    # PDF::Grammar::FDF      - Describes FDF (Form Data) files
    # PDF::Grammar::PDF      - Overall PDF Document Structure
    # PDF::Grammar::Function - Postscript calculator functions
    # 

    # [PDF 1.7] 7.2.2 Character Set + 7.2.3 Comment characters
    # ---------------
    # Newlines, on various platforms.
    proto token eol        {<...>}
    token eol:sym<ms_dos>  {"\r\n"}
    token eol:sym<nix>     {"\n"}
    token eol:sym<mac_osx> {"\r"}

    token comment {'%' <- eol>* <eol>?}
    token ws_char {' ' | "\t" | "\f" | <eol> | <comment>}
    token ws {<!ww><ws_char>*}

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token integer { ['+' | '-']? \d+ }
    # reals must have at least one digit either before or after the decimal
    # point
    token real { ['+' | '-']? [[\d+\.\d*] | [\d*\.\d+]] }

    rule number { <real> | <integer> }

    token octal_code {<[0..7]> ** 1..3}
    token literal_delimiter {<[ \( \) \\ \n \r ]>}

    # literal string components
    proto token literal {<...>}
    token literal:sym<eol>              {<eol>}
    token literal:sym<substring>        {<literal_string>}
    token literal:sym<regular>          {<-literal_delimiter>+}
    # literal string escape codes
    token literal:sym<esc_octal>        {\\ <octal_code>}
    token literal:sym<esc_delim>        {\\ $<delim>=[\( | \) | \\]}
    token literal:sym<esc_backspace>    {\\ b}
    token literal:sym<esc_formfeed>     {\\ f}
    token literal:sym<esc_newline>      {\\ n}
    token literal:sym<esc_cr>           {\\ r}
    token literal:sym<esc_tab>          {\\ t}
    token literal:sym<esc_continuation> {\\ <eol>?}

    token literal_string {'('<literal>*')'}

    # hex strings
    token hex_char {<xdigit>**1..2}
    token hex_string {\< [<xdigit>|<ws_char>]* \>}

    token string {<hex_string>|<literal_string>}

    # [PDF 1.7] 7.2.2 Character Set
    regex delimiter_char {<[ \( \) \< \> \[ \] \{ \} \/ \% \# ]>}

    proto token name_chars {<...>}
    token name_chars:sym<number_symbol> {'##'}
    token name_chars:sym<escaped>       {'#'<hex_char> }
    token name_chars:sym<regular>       {[<[\! .. \~] - delimiter_char>]+}

    rule name { '/'<name_chars>+ }

    # [PDF 1.7] 7.3.2  Boolean objects + Null object
    # ---------------
    token bool  {'true' | 'false'}
    token null  {'null'}
    rule array  {\[ <object>* \]}
    rule dict   {'<<' [<name> <object>]* '>>'}

    # Define a core set of objects.
    proto rule object { <...> }
    rule object:sym<number>  { <number> }
    rule object:sym<bool>    { <bool> }
    rule object:sym<string>  { <string> }
    rule object:sym<name>    { <name> }
    rule object:sym<array>   { <array> }
    rule object:sym<dict>    { <dict> }
    rule object:sym<null>    { <null> }
};
