%{
#include <stdio.h>
#include <string.h>
#include "defs.h"

int level = 0;
int pos = 0;

const int IDENT_LENGHT = 2;
const int LINE_WIDTH = 78;

void indent();

int yylex(void);
int yyerror(const char *txt);
%}

%union 
{
	char s[MAXSTRLEN+1]; 
}

%token<s> PI_TAG_BEG
%token<s> PI_TAG_END
%token<s> STAG_BEG
%token<s> ETAG_BEG
%token<s> TAG_END
%token<s> ETAG_END
%token<s> CHAR
%token<s> S

%type<s> start_tag end_tag word


%%

Grammar: %empty {printf("File is empty\n"); YYERROR;} | error | DOCUMENT
;

/* whole document*/

DOCUMENT: BEGGINING ELEMENT
;

BEGGINING: PROCESS_INSTRUCTIONS NEWLINE_LIST 
| '\n' PROCESS_INSTRUCTIONS NEWLINE_LIST
;

NEWLINE_LIST: '\n' | NEWLINE_LIST '\n'
;

PROCESS_INSTRUCTIONS: PROCESS_INSTRUCTION | PROCESS_INSTRUCTION PROCESS_INSTRUCTIONS
;

PROCESS_INSTRUCTION: PI_TAG_BEG PI_TAG_END {
	printf("<?%s?>\n", $1);
};

ELEMENT: EMPTY_TAG | TAGS_PAIR
;

EMPTY_TAG: STAG_BEG ETAG_END 
;

TAGS_PAIR: start_tag CONTENT_LIST end_tag {
	if(strcmp($1, $3) != 0)
	{
		yyerror("Tags do not match!\n");
	}
};

start_tag: STAG_BEG TAG_END {
	indent();
	printf("<%s>\n", $1);
	level++;
};

end_tag: ETAG_BEG TAG_END {
	level--;
	indent();
	printf("</%s>\n", $1);
	
};

CONTENT_LIST: CONTENT | CONTENT CONTENT_LIST
;

CONTENT: ELEMENT_LIST | WHITE_CHAR_LIST | word | NEWLINE_LIST | %empty 
;

ELEMENT_LIST: ELEMENT | ELEMENT ELEMENT_LIST
;

WHITE_CHAR_LIST: S | S WHITE_CHAR_LIST
;

word: CHAR | CHAR word 
;

%%

int yyerror( const char *txt )
{
	printf( "Syntax error: %s\n", txt );
	return 0;
}

void indent()
{
	for(int i=0; i<level; i++)
		for(int j=0; j<IDENT_LENGHT; j++)
			printf(" ");
}

int main()
{
	return yyparse();
}