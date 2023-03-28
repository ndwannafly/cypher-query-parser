%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "query.h"

int yylex();
int yyparse();
void yyerror(const char *s);

query_tree tree = {.type = UNDEFINED};

extern char *yytext;
#define YYDEBUG_LEXER_TEXT yytext



%}

%token OBRACE CBRACE QUOTE DOT COMMA SEMICOLON


%start commands

%%


commands: /* empty */
	| commands command SEMICOLON {
	YYACCEPT;
	}
	;


command:
	open_file
	|
	create_file
	|
	close_file
	|
	add_schema
	|
	delete_schema
	|
	add_vertex
	|
	select_command
	;


select_command:

open_file:

create_file:

close_file:

add_schema:

delete_schema:

add_vertex:

%%


void yyerror(const char *str)
{
	fprintf(stderr,"error: %s\n%s\n",str, yytext);
}

int yywrap()
{
	return 1;
}

query_tree get_query_tree(){
    return tree;
}
