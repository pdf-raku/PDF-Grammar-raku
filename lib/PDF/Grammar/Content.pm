use v6;

use PDF::Grammar;

grammar PDF::Grammar::Content is PDF::Grammar {
    #
    # A Simple PDF grammar for parsing PDF content, i.e. Graphics and
    # Text operations as describe in sections 8 and 9 of [PDF 1.7].
    rule TOP {<content>}
    rule content {^(BT <content> ET)|<op>*$}
    rule op {bazinga} #stub

}

