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

/* const strings */
const char str_set[] = "set\0";
const char str_list[] = "list\0";

/* macros for debugging */
#define DEBUG_FILE_PTR stderr
#define NAME "parser"
#define RPT(status, fmt, ...)  do {							\
	if (DEBUG_FILE_PTR)										\
		fprintf(DEBUG_FILE_PTR, "#\t" "[" NAME "] "			\
		#status ": " fmt "\n" , ##__VA_ARGS__);				\
} while(0)

/*****************************************************************************/
/*** Abstract Syntax Tree (prototypes) ***/

/* operators */
enum operators {
	op_null,
	op_not,
	op_wedge,
	op_vee,
	op_contain,
	op_dcontain,
	op_get,
	op_dget,
	op_comma
};

/* operator names */
const char *  operator_names[] = {
	"op_null",
	"op_not",
	"op_wedge",
	"op_vee",
	"op_contain",
	"op_dcontain",
	"op_get",
	"op_dget",
	"op_comma"
};

/* node types */
enum node_types {
	nd_program,
	nd_import_expr,
	nd_import_part,
	nd_proof_part,
	nd_proof_block,
	nd_proof_block_dcl, // declare
	nd_exprs,
	nd_rich_exprs,
	nd_rich_expr,
	nd_ref_body,
	nd_ref_labels,
	nd_of_exprs,
	nd_of_expr,
	nd_proof_req,
	nd_expr,
	nd_type
};

const char * node_type_names[] = {
	"nd_program",
	"nd_import_expr",
	"nd_import_part",
	"nd_proof_part",
	"nd_proof_block",
	"nd_proof_block_dcl", // declare
	"nd_exprs",
	"nd_rich_exprs",
	"nd_rich_expr",
	"nd_ref_body",
	"nd_ref_labels",
	"nd_of_exprs",
	"nd_of_expr",
	"nd_proof_req",
	"nd_expr",
	"nd_type"
};

/* node in AST */
struct ast_node {
	/* info of this node */
	enum node_types node_type;
	void * data;

	/* info of location */
	struct YYLTYPE * location;

	/* links */
	int num_links;
	struct ast_node ** links;
};

/* root of AST */
struct ast_node *root;

/* new node */
struct ast_node *new_ast_node(enum node_types, void *, void *, void *, int, int);

/* free node */
void free_ast_node(struct ast_node *);

/* print AST structure */
void print_ast(struct ast_node *, int, FILE *);

/*****************************************************************************/

#define AST_NODE_PTR(p) ((struct ast_node *)(p))

#define AST_NODE_PTR_ARR(p) ((struct ast_node **)(p))

#define LINKS_MALLOC(p, n); do {\
	(p) = (struct ast_node **)malloc(sizeof(void *) * (n));\
} while(0)

#endif
