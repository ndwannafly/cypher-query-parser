%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "query.h"

int yylex();
int yyparse();
void yyerror(const char *s);

bool is_vector_used = false;

query_tree tree = {.type = UNDEFINED};

char *file_name;
int opened = 0;


statement_t *cur_statement = NULL;


extern char *yytext;
#define YYDEBUG_LEXER_TEXT yytext



%}

%union
{
	int integer;
	char *string;
	float decimal;
	int boolean;
	char *ref_name;
	int attribute_type;
	int compare_option;
}

%type<string> quoted_argument
%type<attribute_type> attribute_type

%token OBRACE CBRACE QUOTE DOT COMMA SEMICOLON

%token TOK_OPEN TOK_CREATE TOK_CLOSE
%token TOK_ADD_SCHEMA TOK_DELETE_SCHEMA
%token TOK_ADD_NODE TOK_NODES TOK_SELECT
%token TOK_EQUAL TOK_GREATER TOK_GREATER_EQUAL TOK_LESS TOK_LESS_EQUAL TOK_NOT_EQUAL TOK_LIKE
%token TOK_VALUES TOK_DELETE
%token TOK_OUT
%token <string> FILENAME

%token <integer> INTEGER
%token <decimal> DECIMAL
%token <boolean> BOOLEAN
%token <string> WORD
%token <string> STRING

%type <compare_option> compare_option

%token TOK_INTEGER
%token TOK_FLOAT
%token TOK_STRING
%token TOK_BOOLEAN
%token TOK_REFERENCE

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
	add_node
	|
	select_command
	;



select_command:
	select_nodes {
		tree.type = SELECT_REQ;
	}
	| select_command select_condition
	| select_command join
	| select_command delete_command
	;

open_file:
	TOK_OPEN OBRACE QUOTE FILENAME QUOTE CBRACE
	{
		tree.type = OPEN;
		tree.file_work.filename = malloc(sizeof(char) * strlen($4));
		strcpy(tree.file_work.filename, $4);
	};

create_file:
	TOK_CREATE OBRACE QUOTE FILENAME QUOTE CBRACE
	{
		tree.type = CREATE;
		tree.file_work.filename = malloc(sizeof(char) * strlen($4));
		strcpy(tree.file_work.filename, $4);
	};

close_file:
	TOK_CLOSE OBRACE CBRACE
	{
		tree.type = CLOSE;
	};

add_schema:
	TOK_ADD_SCHEMA OBRACE quoted_argument attribute_pairs CBRACE
	{
		tree.type = ADD_SCHEMA;
		tree.add_schema.schema_name = malloc(sizeof(char) * strlen($3));
		strcpy(tree.add_schema.schema_name, $3);
	};

delete_schema:
	TOK_DELETE_SCHEMA OBRACE quoted_argument CBRACE
	{
		tree.type = DELETE_SCHEMA;
		tree.add_schema.schema_name = malloc(sizeof(char) * strlen($3));
		strcpy(tree.add_schema.schema_name, $3);
	};

add_node:
	TOK_ADD_NODE OBRACE quoted_argument attribute_value_pairs CBRACE
	{
		tree.type = ADD_NODE;
		tree.add_node.schema_name = malloc(sizeof(char) * strlen($3));
		strcpy(tree.add_node.schema_name, $3);
	}
	;

select_nodes:
	TOK_NODES OBRACE quoted_argument CBRACE
	{
		tree.schema_name = malloc(sizeof(char) * strlen($3));
		strcpy(tree.schema_name, $3);
	}
	;

select_condition:
	| DOT TOK_SELECT OBRACE select_statements CBRACE
	{
		if(!is_vector_used) {
			tree.statements = create_vector(4);
			is_vector_used = true;
		}
		add(tree.statements, cur_statement);
		cur_statement = NULL;
	}
	;

join:
	| DOT TOK_OUT OBRACE quoted_argument CBRACE
	{
		if(!is_vector_used) {
			tree.statements = create_vector(4);
			is_vector_used = true;
		}
		cur_statement = malloc(sizeof(statement_t));
		cur_statement->type = OUT;
		cur_statement->attr_name = malloc(sizeof(char) * strlen($4));
		strcpy(cur_statement->attr_name, $4);
		add(tree.statements, cur_statement);
		cur_statement = NULL;
	}
	;

delete_command:
	| DOT TOK_DELETE {
		if(!is_vector_used) {
			tree.statements = create_vector(4);
			is_vector_used = true;
		}
		cur_statement = malloc(sizeof(statement_t));
		cur_statement->type = DELETE;
		add(tree.statements, cur_statement);
		cur_statement = NULL;
	}
	;

select_statements:
	| select_statements select_statement COMMA {

	}
	| select_statements select_statement {

	}
	;

select_statement:
	quoted_argument COMMA compare_option OBRACE INTEGER CBRACE {
		if(cur_statement == NULL) {
			cur_statement = malloc(sizeof(statement_t));
			cur_statement->type = SELECT;
			cur_statement->conditions = create_vector(4);
		}
		select_cond_t *cond = malloc(sizeof(select_cond_t));
		cond->attr_name = malloc(sizeof(char) * strlen($1));
		strcpy(cond->attr_name, $1);
		cond->option = $3;
		cond->type = INT;
		cond->value.integer_value = $5;
		add(cur_statement->conditions, cond);
	}
	| quoted_argument COMMA compare_option OBRACE DECIMAL CBRACE {
		if(cur_statement == NULL) {
			cur_statement = malloc(sizeof(statement_t));
			cur_statement->type = SELECT;
			cur_statement->conditions = create_vector(4);
		}
		select_cond_t *cond = malloc(sizeof(select_cond_t));
		cond->attr_name = malloc(sizeof(char) * strlen($1));
		strcpy(cond->attr_name, $1);
		cond->option = $3;
		cond->type = FLOAT;
		cond->value.float_value = $5;
		add(cur_statement->conditions, cond);
	}
	| quoted_argument COMMA compare_option OBRACE BOOLEAN CBRACE {
		if(cur_statement == NULL) {
			cur_statement = malloc(sizeof(statement_t));
			cur_statement->type = SELECT;
			cur_statement->conditions = create_vector(4);
		}
		select_cond_t *cond = malloc(sizeof(select_cond_t));
		cond->attr_name = malloc(sizeof(char) * strlen($1));
		strcpy(cond->attr_name, $1);
		cond->option = $3;
		cond->type = BOOL;
		cond->value.bool_value = $5;
		add(cur_statement->conditions, cond);
	}
	| quoted_argument COMMA compare_option OBRACE quoted_argument CBRACE {
		if(cur_statement == NULL) {
			cur_statement = malloc(sizeof(statement_t));
			cur_statement->type = SELECT;
			cur_statement->conditions = create_vector(4);
		}
		select_cond_t *cond = malloc(sizeof(select_cond_t));
		cond->attr_name = malloc(sizeof(char) * strlen($1));
		strcpy(cond->attr_name, $1);
		cond->option = $3;
		cond->type = STR;
		cond->value.string_value = $5;
		add(cur_statement->conditions, cond);
	}
	;

attribute_value_pairs:
	| attribute_value_pairs COMMA attribute_value_pair {

	};

attribute_value_pair:

	quoted_argument COMMA INTEGER {
		if(!is_vector_used) {
			tree.add_node.attribute_values = create_vector(4);
			is_vector_used = true;
		}
		attr_value_t *attr_val = malloc(sizeof(attr_value_t));
		*attr_val = (attr_value_t) {
			.attr_name = malloc(sizeof(char) * strlen($1)),
			.type = INT,
			.value = (base_value_t) {.integer_value = $3}
		};
		strcpy(attr_val->attr_name, $1);
		add(tree.add_node.attribute_values, attr_val);
	}
	| quoted_argument COMMA DECIMAL{
		if(!is_vector_used) {
			tree.add_node.attribute_values = create_vector(4);
			is_vector_used = true;
		}
		attr_value_t *attr_val = malloc(sizeof(attr_value_t));
		*attr_val = (attr_value_t) {
			.attr_name = malloc(sizeof(char) * strlen($1)),
			.type = FLOAT,
			.value = (base_value_t) {.float_value = $3}
		};
		strcpy(attr_val->attr_name, $1);
		add(tree.add_node.attribute_values, attr_val);
	}
	| quoted_argument COMMA BOOLEAN{
		if(!is_vector_used) {
			tree.add_node.attribute_values = create_vector(4);
			is_vector_used = true;
		}
		attr_value_t *attr_val = malloc(sizeof(attr_value_t));
		*attr_val = (attr_value_t) {
			.attr_name = malloc(sizeof(char) * strlen($1)),
			.type = BOOL,
			.value = (base_value_t) {.bool_value = $3}
		};
		strcpy(attr_val->attr_name, $1);
		add(tree.add_node.attribute_values, attr_val);
	}
	| quoted_argument COMMA quoted_argument{
		if(!is_vector_used) {
			tree.add_node.attribute_values = create_vector(4);
			is_vector_used = true;
		}
		attr_value_t *attr_val = malloc(sizeof(attr_value_t));
		*attr_val = (attr_value_t) {
			.attr_name = malloc(sizeof(char) * strlen($1)),
			.type = STR,
			.value = (base_value_t) {.string_value = malloc(sizeof(char) * strlen($3))}
		};
		strcpy(attr_val->value.string_value, $3);
		strcpy(attr_val->attr_name, $1);
		add(tree.add_node.attribute_values, attr_val);
	}
	;

attribute_pairs:
	| attribute_pairs COMMA attribute_pair {
	}
	;

attribute_type:
	TOK_INTEGER {
		$$ = INT;
	}
	| TOK_STRING {
		$$ = STR;
	}
	| TOK_FLOAT {
		$$ = FLOAT;
	}
	| TOK_BOOLEAN {
		$$ = BOOL;
	}
	| TOK_REFERENCE {
		$$ = REFERENCE;
	}

	;
attribute_pair:
	quoted_argument COMMA attribute_type {
		if (!is_vector_used) {
            tree.add_schema.attribute_declarations = create_vector(4);
            is_vector_used = true;
		}
		attribute_declaration_t *attr_decl = malloc(sizeof(attribute_declaration_t));
		*attr_decl = (attribute_declaration_t) {
            .attr_name = malloc(sizeof(char) * strlen($1)),
            .type = $3,
		};
		strcpy(attr_decl->attr_name, $1);
		add(tree.add_schema.attribute_declarations, attr_decl);
	}
	| quoted_argument COMMA TOK_REFERENCE OBRACE quoted_argument CBRACE {
		if (!is_vector_used) {
            tree.add_schema.attribute_declarations = create_vector(4);
            printf("arraylist created\n");
            is_vector_used = true;
		}
		attribute_declaration_t *attr_decl = malloc(sizeof(attribute_declaration_t));
		*attr_decl = (attribute_declaration_t) {
            .attr_name = malloc(sizeof(char) * strlen($1)),
            .type = REFERENCE,
            .schema_ref_name = malloc(sizeof(char) * strlen($5))
		};
		strcpy(attr_decl->attr_name, $1);
		strcpy(attr_decl->schema_ref_name, $5);
		add(tree.add_schema.attribute_declarations, attr_decl);
	}
	;

compare_option:
	TOK_EQUAL {
		$$ = EQUAL;
	}
	| TOK_GREATER {
		$$ = GREATER;
	}
	| TOK_GREATER_EQUAL {
		$$ = GREATER_EQUAL;
	}
	| TOK_LESS {
		$$ = LESS;
	}
	| TOK_LESS_EQUAL {
		$$ = LESS_EQUAL;
	}
	| TOK_NOT_EQUAL {
		$$ = NOT_EQUAL;
	}
	| TOK_LIKE {
		$$ = LIKE;
	}
	;


quoted_argument:
	QUOTE WORD QUOTE
	{
		$$ = $2;
	}
	;
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
