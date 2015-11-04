%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*  Lexer prototype required by bison, aka getNextToken() */
int yylex(); 

extern int yylineno;

int yyerror(const char *p) { 
	fprintf(stderr, "Error at line %d\n", yylineno);
	return 1;
}
%}

/* SYMBOL SEMANTIC VALUES */
%union {
  int val;
  char *str;
  void *ptr;
};
%token <ptr> import	theorem	axiom lemma require
%token <ptr> conclude proof where left_bracket right_bracket
%token <ptr> left_ref right_ref left_parren	right_parren colon
%token <ptr> comma
%token <str> file_name	identifier	label
%token <val> left_tab	right_tab

/* GRAMMAR RULES */
%%
import_expr: import file_name { printf("import file: %s\n", $2);}
%%

/* FUNCTION DEFINITIONS */
int main()
{
	yyparse();
	return 0;
}
