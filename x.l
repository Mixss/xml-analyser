%{
#include <stdio.h>
#include "defs.h"
#include "x.tab.h"
%}

%x ST_COMMENT ST_PI ST_TAG
%option yylineno

%%
 /* ident */
[A-Za-z:_]([A-Za-z:_0-9]|"-")* { printf("IDENT"); return IDENT; }
 /* comment */
<INITIAL>"<!--" { BEGIN(ST_COMMENT); }
<ST_COMMENT>[^-]"-->" { BEGIN(INITIAL); }
<ST_COMMENT>.|\n
%%

int yywrap()
{
    if(YY_START == ST_COMMENT){
        printf("Comment is not closed at line: %d\n", yylineno);
    }
    return 1;
}