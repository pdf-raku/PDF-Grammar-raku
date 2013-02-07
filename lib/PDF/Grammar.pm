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
    token comment {'%' <- eol>* <eol>?}
    token ws_char {"\n" | "\t" | "\o12" | "\f" | "\r" | " " | <comment>}
    token ws {<!ww><ws_char>*}

   # Newlines, on various platforms.
    proto token eol        {<...>}
    token eol:sym<ms_dos>  {"\r\n"}
    token eol:sym<nix>     {"\n"}
    token eol:sym<mac_osx> {"\r"}

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token integer { ['+' | '-']? \d+ }
    # reals must have at least one digit either before or after the decimal
    # point
    token real { ['+' | '-']? [[\d+\.\d*] | [\d*\.\d+]] }

    rule number { <real> | <integer> }

    token octal_code {<[0..7]> ** 1..3}
    token char_code  {<[nrtbf\(\)\\]>}

    token literal_delimiter {<[ \( \) \\ \n \r ]>}

    proto token literal {<...>}
    token literal:sym<continuation> {"\\"<eol>}
    token literal:sym<eol>          {<eol>}
    token literal:sym<escape>       {'\\'[<octal_code>|<char_code>]?}
    token literal:sym<substring>    {<literal_string>}
    token literal:sym<chars>        {<-literal_delimiter>+}

    rule literal_string {'('<literal>*')'}

    # hex strings
    token hex_char {<xdigit>**1..2}
    token hex_string {\< [<xdigit>|<ws_char>]* \>}

    rule string {<hex_string>|<literal_string>}

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
    rule array  {\[ <operand>* \]}
    rule dict   {'<<' [<name> <operand>]* '>>'}

    # Define a core set of objects/operands.
    proto rule object { <...> }
    rule object:sym<number>  { <number> }
    rule object:sym<bool>    { <bool> }
    rule object:sym<string>  { <string> }
    rule object:sym<name>    { <name> }
    rule object:sym<array>   { <array> }
    rule object:sym<dict>    { <dict> }
    rule object:sym<null>    { <null> }

    rule operand { <object> }
};
