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
    token comment {'%' \N* \n?}
    # [PDF 1.7] Table 3.1: White-space characters
    token LF      { \x0A }
    token NUL     { \x0 }
    token ws-char {' ' | \t | \f | \n | <LF> | <NUL> | <.comment>}
    token ws      {<!ww><.ws-char>*}

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token int { < + - >? \d+ }
    # reals must have a decimal point and some digits before or after it.
    token real { < + - >? [\d+\.\d* | \.\d+] }

    rule number { <real> | <int> }

    token octal-code {<[0..7]> ** 1..3}
    token literal_delimiter {<[ ( ) \\ \n \r ]>}

    # literal string components
    proto token literal {<...>}
    token literal:sym<regular>          {<-literal_delimiter>+}
    token literal:sym<eol>              {\n}
    token literal:sym<substring>        {<literal-string>}
    # literal string escape sequences
    token literal:sym<esc-octal>        {\\ <octal-code>}
    token literal:sym<esc-delim>        {\\ $<delim>=<[ ( ) \\ ]>}
    token literal:sym<esc-backspace>    {\\ b}
    token literal:sym<esc-formfeed>     {\\ f}
    token literal:sym<esc-newline>      {\\ n}
    token literal:sym<esc-cr>           {\\ r}
    token literal:sym<esc-tab>          {\\ t}
    token literal:sym<esc-continuation> {\\ \n?}

    token literal-string { '(' <literal>* ')' }

    # hex strings
    token hex-char   {<xdigit>**1..2}
    token hex-string {\< [ <xdigit> | <.ws-char> ]* \>}

    token string {<hex-string>|<literal-string>}

    # [PDF 1.7] 7.2.2 Character Set
    regex char_delimiter {<[ ( ) < > \[ \] { } / % \# ]>}
    regex name-reg-char  {<[\! .. \~] -char_delimiter>}

    proto token name-bytes {<...>}
    token name-bytes:sym<number-symbol> {'##'}
    token name-bytes:sym<escaped>       {'#'<hex-char> }
    token name-bytes:sym<regular>       {<name-reg-char>}

    rule name { '/'<name-bytes>+ }

    # [PDF 1.7] 7.3.2  Boolean objects + Null object
    # ---------------
    rule array  {'[' <object>* ']'}
    rule dict   {'<<' [ <name> <object> ]* '>>'}

    # Define a core set of objects.
    proto rule object { <...> }
    rule object:sym<number>  { <number> }
    rule object:sym<true>    { <sym> }
    rule object:sym<false>   { <sym> }
    rule object:sym<string>  { <string> }
    rule object:sym<name>    { <name> }
    rule object:sym<array>   { <array> }
    rule object:sym<dict>    { <dict> }
    rule object:sym<null>    { <sym> }

    method parsefile( $pdf-file, :$rule = 'TOP', :$actions ) {
        my $pdf-body = slurp( $pdf-file, :enc<latin1> );
        my $result = $.parse($pdf-body, :$rule, :$actions );
        nqp::getlexcaller('$/') = $result;
    }

};

