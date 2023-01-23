%{
#include <stdio.h>
#include "defs.h"
#include "x.tab.h"

int process_token(const char *text, const char *TokenType, const char *TokenVal, const int TokenID);
%}

%x ST_COMMENT ST_PI ST_TAG
%option yylineno

IDENT_EXPR [A-Za-z:_]([A-Za-z:_0-9]|"-")* 

%%
 /* comment */
<INITIAL>"<!--" { BEGIN(ST_COMMENT); }
<ST_COMMENT>[^-]"-->" { BEGIN(INITIAL); }
<ST_COMMENT>.|\n

 /* processing instruction */
<INITIAL>"<?"{IDENT_EXPR} { BEGIN(ST_PI); char* substr = malloc(MAXSTRLEN); strncpy(substr, yytext+2, MAXSTRLEN); return process_token(yytext, "PI_TAG_BEG", substr, PI_TAG_BEG); }
<ST_PI>"?>" { BEGIN(INITIAL); return process_token(yytext, "PI_TAG_END", "", PI_TAG_END); }
<ST_PI>.

<INITIAL>"<"{IDENT_EXPR} { 
    BEGIN(ST_TAG); 
    char* substr = malloc(MAXSTRLEN); 
    strncpy(substr, yytext+1, MAXSTRLEN); 
    return process_token(yytext, "STAG_BEG", substr, STAG_BEG);
}

<INITIAL>"</"{IDENT_EXPR} { 
    BEGIN(ST_TAG); 
    char* substr = malloc(MAXSTRLEN); 
    strncpy(substr, yytext+2, MAXSTRLEN); 
    return process_token(yytext, "ETAG_BEG", substr, ETAG_BEG);
}

<ST_TAG>">" {
    BEGIN(INITIAL);
    return process_token(yytext, "TAG_END", "", TAG_END);
}

<ST_TAG>"/>" {
    BEGIN(INITIAL);
    return process_token(yytext, "ETAG_END", "", ETAG_END);
}

<ST_TAG>.

 /* special symbols */
"&lt" { return process_token(yytext, "CHAR", "<", CHAR); }
"&gt" { return process_token(yytext, "CHAR", ">", CHAR); }
"&amp" { return process_token(yytext, "CHAR", "&", CHAR); }
"&apos" { return process_token(yytext, "CHAR", "'", CHAR); }
"&quote" { return process_token(yytext, "CHAR", "\"", CHAR); }

 /* tabulations, spaces, newline*/
^[ \t]+
[\r]+
[\n] { return '\n'; }

[ \t] { return process_token(yytext, "S", yytext, S); }

 /* other signs */
. { return process_token(yytext, "CHAR", yytext, CHAR); }

%%

int process_token(const char *text, const char *TokenType, const char *TokenVal, const int TokenID)
{
    printf("%-20.20s%-15s .%s.\n", text, TokenType, TokenVal);
    switch (TokenID) {
        case PI_TAG_BEG:
            strncpy(yylval.s, TokenVal, MAXSTRLEN); break;
        case STAG_BEG:
            strncpy(yylval.s, TokenVal, MAXSTRLEN); break;
        case ETAG_BEG:
            strncpy(yylval.s, TokenVal, MAXSTRLEN); break;
        case CHAR:
            strncpy(yylval.s, TokenVal, MAXSTRLEN); break;
        case S:
            strncpy(yylval.s, TokenVal, MAXSTRLEN); break;
    }

    return TokenID;
}

int yywrap()
{
    if(YY_START == ST_COMMENT){
        printf("\nComment is not closed at line: %d\n", yylineno);
    }
    return 1;
}