use v6;

grammar PDF::Grammar {
   # abstract base grammar for PDF Elements, see:
   # PDF::Grammar::Body     - Overall PDF Document Structure
   # PDF::Grammar::Content  - Text and Graphics Content
   # 

    # [PDF 1.7] 7.2.2 Character Set + 7.2.3 Comment characters
    # ---------------
    # This <ws> rule treats % as "comment to eol".
    token ws_char {['%' <- eol>* <eol>? | "\n" | "\t" | "\o12" | "\f" | "\r" | " "]}
    token ws {
        <!ww>
        <ws_char>*
    }

};
