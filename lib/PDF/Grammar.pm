use v6;

grammar PDF::Grammar:ver<0.1.6> {
    # abstract base grammar for PDF Elements, see instances:
    # PDF::Grammar::COS      - Base class for FDF and PDF
    # -- PDF::Grammar::FDF      - Describes FDF (Form Data) files
    # -- PDF::Grammar::PDF      - Overall PDF Document Structure
    # PDF::Grammar::Content  - Text and Graphics Content
    # PDF::Grammar::Function - Postscript calculator functions
    #
    enum AST-Types is export(:AST-Types) < array body bool cos
	dict encoded end entries decoded fdf gen-num header hex-string
	ind-ref ind-obj int obj-count obj-first-num offset literal
	name null real start startxref stream trailer type version cond>;

    # [PDF 1.7] 7.2.2 Character Set + 7.2.3 Comment characters
    # ---------------
    token comment {'%' \N* \n?}
    # [PDF 1.7] Table 3.1: White-space characters
    token ws-char {<[ \x20 \x0A \x0 \t \f \n ]> | <.comment>}
    token ws      {<!ww><.ws-char>*}

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token int { < + - >? \d+ }
    # reals must have a decimal point and some digits before or after it.
    token real { < + - >? [\d+\.\d* | \.\d+] }

    rule number { <real> | <int> }

    token octal-code {<[0..7]> ** 1..3}
    token literal-delimiter {<[ ( ) \\ \n \r ]>}

    # literal string components
    proto token literal {*}
    token literal:sym<regular>          {<-literal-delimiter>+}
    token literal:sym<eol>              {\n}
    token literal:sym<substring>        {<literal-string>}
    token literal:sym<escaped>          {\\ <literal-esc>}
    # literal string escape sequences
    proto token literal-esc {*}
    token literal-esc:sym<octal>        {<octal-code>}
    token literal-esc:sym<delim>        {<[ ( ) \\ ]>}
    token literal-esc:sym<backspace>    {b}
    token literal-esc:sym<formfeed>     {f}
    token literal-esc:sym<newline>      {n}
    token literal-esc:sym<cr>           {r}
    token literal-esc:sym<tab>          {t}
    token literal-esc:sym<continuation> {\n?}

    token literal-string { '(' <literal>* ')' }

    # hex strings
    token hex-string {'<' [ <xdigit> | <.ws-char> ]* '>'}

    token string {<string=.hex-string>|<string=.literal-string>}

    # [PDF 1.7] 7.2.2 Character Set
    token char-delimiter {<[ ( ) < > \[ \] { } / % \# ]>}

    proto token name-bytes {*}
    token name-bytes:sym<number-symbol> {'##'}
    token name-bytes:sym<escaped>       {'#'<xdigit>**2 }
    token name-bytes:sym<regular>       {<[\! .. \~] -char-delimiter>+}

    rule name { '/'<name-bytes>* }

    # [PDF 1.7] 7.3.2  Boolean objects + Null object
    # ---------------
    rule array  {'[' <object>* ']'}
    rule dict   {'<<' [ <name> <object> ]* '>>'}

    # Define a core set of objects.
    proto rule object {*}
    rule object:sym<number>  { <number> }
    rule object:sym<true>    { <sym> }
    rule object:sym<false>   { <sym> }
    rule object:sym<string>  { <string> }
    rule object:sym<name>    { <name> }
    rule object:sym<array>   { <array> }
    rule object:sym<dict>    { <dict> }
    rule object:sym<null>    { <sym> }

    # ensure we load and decode the file appropriately
    method parsefile(Str $file, |c) {
        self.parse( slurp($file, :bin).decode("latin-1"), |c);
    }

}

