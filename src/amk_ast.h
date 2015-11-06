/*************************************************************************
    > File Name: amk-ast.h
    > Author: Shuyang Shi
    > Created Time: Fri 11/ 6 17:04:54 2015
 ************************************************************************/

#ifndef amk_ast_h
#define amk_ast_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*** interface to the lexer ***/

/*  Lexer prototype required by bison, aka getNextToken() */
int yylex();

/* line number variable*/
extern int yylineno;

/* error reporting function */
int yyerror(const char *p) {
	fprintf(stderr, "Error at line %d: %s\n", yylineno, p);
	return 1;
}


/*****************************************************************************/
/*** Abstract Syntax Tree ***/

/* node in AST */
struct ast_node {
	int node_type;
	/* TODO */
};

struct ast_node *new_ast_node();

#endif
