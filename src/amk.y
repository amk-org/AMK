%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-- Lexer prototype required by bison, aka getNextToken()
int yylex(); 
extern int yylineno;
int yyerror(const char *p) { 
	fprintf(stderr, "Error at line %d\n", yylineno);
	return 1;
}
%}

//-- SYMBOL SEMANTIC VALUES -----------------------------
%union {
  int val; 
  char* str;
  void* pr
};
%token <pr> left_bracket right_bracket left_ref right_ref left_parren right_parren colon comma
%token <str> file_name idn label
%token <val> left_tab right_tab

//-- GRAMMAR RULES ---------------------------------------
%%
run: res run | res  
%%
//-- FUNCTION DEFINITIONS ---------------------------------
int main()
{
  yyparse();
  return 0;
}
