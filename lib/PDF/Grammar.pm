use v6;

grammar PDF::Grammar:ver<0.0.6> {
    # abstract base grammar for PDF Elements, see instances:
    # PDF::Grammar::Content  - Text and Graphics Content
    # PDF::Grammar::FDF      - Describes FDF (Form Data) files
    # PDF::Grammar::PDF      - Overall PDF Document Structure
    # PDF::Grammar::Function - Postscript calculator functions
    # 

    # [PDF 1.7] 7.2.2 Character Set + 7.2.3 Comment characters
    # ---------------
    # Newlines, on various platforms.
    proto token eol    {<...>}
    token eol:sym<dos> {\x0d\x0a} # cr lf
    token eol:sym<nix> {\x0a}     # lf
    token eol:sym<mac> {\x0d}     # cr

    token comment {'%' <- eol>* <.eol>?}
    token ws-char {' ' | "\t" | "\f" | <.eol> | <.comment>}
    token ws {<!ww><.ws-char>*}

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token integer { ['+' | '-']? \d+ }
    # reals must have a decimal point and some digits before or after it.
    token real { ['+' | '-']? [\d+\.\d* | \.\d+] }

    rule number { <real> | <integer> }

    token octal-code {<[0..7]> ** 1..3}
    token literal_delimiter {<[ \( \) \\ \n \r ]>}

    # literal string components
    proto token literal {<...>}
    token literal:sym<regular>          {<-literal_delimiter>+}
    token literal:sym<eol>              {<.eol>}
    token literal:sym<substring>        {<literal-string>}
    # literal string escape sequences
    token literal:sym<esc-octal>        {\\ <octal-code>}
    token literal:sym<esc-delim>        {\\ $<delim>=[\( | \) | \\]}
    token literal:sym<esc-backspace>    {\\ b}
    token literal:sym<esc-formfeed>     {\\ f}
    token literal:sym<esc-newline>      {\\ n}
    token literal:sym<esc-cr>           {\\ r}
    token literal:sym<esc-tab>          {\\ t}
    token literal:sym<esc-continuation> {\\ <.eol>?}

    token literal-string { '(' ~ ')' <literal>* }

    # hex strings
    token hex-char   {<xdigit>**1..2}
    token hex-string {\< [ <xdigit> | <.ws-char> ]* \>}

    token string {<hex-string>|<literal-string>}

    # [PDF 1.7] 7.2.2 Character Set
    regex char_delimiter {<[ \( \) \< \> \[ \] \{ \} \/ \% \# ]>}

    proto token name-chars {<...>}
    token name-chars:sym<number-symbol> {'##'}
    token name-chars:sym<escaped>       {'#'<hex-char> }
    token name-chars:sym<regular>       {[<[\! .. \~] -char_delimiter>]+}

    rule name { '/'<name-chars>+ }

    # [PDF 1.7] 7.3.2  Boolean objects + Null object
    # ---------------
    token bool  { true | false }
    token null  { null }
    rule array  {\[ ~ \] <object>*}
    rule dict   {'<<' ~ '>>' [<name> <object>]*}

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
