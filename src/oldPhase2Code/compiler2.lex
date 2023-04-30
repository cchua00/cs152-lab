%{
    #include "y.tab.h"
%}

%%

int {return INT;}
;   {return SMICOLON;}
[a-zA-z]+   {return IDENT;}
"{" {return LBR;}
"}" {return RBR;}
"," {return COMMA;}
"(" {return LPR;}
")" {return RPR;}
"\n"    {}
[ \t]+   []

%%