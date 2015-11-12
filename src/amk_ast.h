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

/* line number variable */
extern int yylineno;

/* error reporting function */
int yyerror(const char *p) {
	fprintf(stderr, "Error at line %d: %s\n", yylineno, p);
	return 1;
}

/* macros for debugging */
#define DEBUG_FILE_PTR stderr
#define RPT(status, fmt, ...)  do {							\
	if (DEBUG_FILE_PTR)										\
		fprintf(DEBUG_FILE_PTR, "#\t" #status ": "			\
				fmt "\n" , ##__VA_ARGS__);					\
} while(0)

/*****************************************************************************/
/*** Abstract Syntax Tree (prototypes) ***/

/* keywords */
enum keywords {
	kw_import,
	kw_theorem,
	kw_axiom,
	kw_lemma,
	kw_require,
	kw_conclude,
	kw_proof,
	kw_where
};

/* operators */
enum operators {
	op_not,
	op_wedge,
	op_vee,
	op_contain,
	op_dcontain,
	op_get,
	op_dget
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
	nd_var,
	nd_expr
};

/* node in AST */
struct ast_node {
	/* info of this node */
	enum node_types node_type;
	void * data;

	/* links */
	int num_links;
	struct ast_node ** links;
};

/* new node */
struct ast_node *new_ast_node(enum node_types, void *, void *, void *);

/* free node */
void free_ast_node(struct ast_node *);

/*****************************************************************************/
/*** Function Definitions ***/

void free_ast_node(struct ast_node * node) {
	if (node->num_links > 0)
		free(node->links);
	free(node);
}

#define AST_NODE_MALLOC(p, nd_t); do {\
	(p) = (struct ast_node *)malloc(sizeof(struct ast_node));\
	(p)->node_type = (nd_t);\
} while(0)

#define AST_NODE_PTR(p) ((struct ast_node *)(p))

#define AST_NODE_PTR_ARR(p) ((struct ast_node **)(p))

#define LINKS_MALLOC(p, n); do {\
	(p) = (struct ast_node **)malloc(sizeof(void *) * (n));\
} while(0)

struct ast_node *new_ast_node(enum node_types node_type, void *arg, void *arg2, void *arg3) {
	struct ast_node *re = NULL;
	switch (node_type) {

		/* the while program */
		/* arg - import_part, arg2 - proof_part */
		case nd_program:
			AST_NODE_MALLOC(re, node_type);
			re->data = NULL;
			re->num_links = 2;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg);
			re->links[1] = AST_NODE_PTR(arg2);
			break;

		/* an import expression */
		/* arg - string ptr (.mamk file) */
		case nd_import_expr:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 0;
			re->links = NULL;
			break;

		/* the import part of the prog */
		/* arg - import expr, arg2 - import part node */
		case nd_import_part:

		/* the proof part of the prog */
		/* arg - proof block, arg2 - proof part node */
		case nd_proof_part:

		/* rich_exprs */
		/* arg - rich_expr, arg2 - rich_exprs */
		case nd_rich_exprs:

		/* ref_labels */
		/* arg - label, arg2 - ref_labels */
		case nd_ref_labels:

		/* exprs */
		/* arg - expr, arg2 - exprs */
		case nd_exprs:

			AST_NODE_MALLOC(re, node_type);
			re->data = NULL;
			if (!arg){
				re->num_links = 0;
				break;
			}
			re->num_links = arg2 ? AST_NODE_PTR(arg2)->num_links + 1 : 1;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg);
			if (arg2) {
				for (int i=0; i < AST_NODE_PTR(arg2)->num_links; i++)
					re->links[i+1] = AST_NODE_PTR(arg2)->links[i];
				free_ast_node(AST_NODE_PTR(arg2));
			}
			break;

		/* a proof block */
		/* arg - theorem_name, arg2 - ast_node ** */
		case nd_proof_block:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 3;
			re->links = (struct ast_node **)arg2;
			break;

		/* a proof block (only declaration) */
		/* arg - theorem_name, arg2 - ast_node ** */
		case nd_proof_block_dcl:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 2;
			re->links = (struct ast_node **)arg2;
			break;

		/* rich expr */
		/* arg - expr, arg2 - theorem_ref, arg3 - label */
		/* re->links: expr, theorem_ref, label */
		case nd_rich_expr:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 2;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg2);
			re->links[1] = AST_NODE_PTR(arg3);
			break;

		/* reference body */
		/* arg - ref_theo, arg2 - ref_pref, arg3 - ref_vars */
		case nd_ref_body:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 2;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg2);
			re->links[1] = AST_NODE_PTR(arg3);
			break;

		/* var */
		/* arg - identifier */
		case nd_var:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 0;
			break;

		/* expr */
		/* arg - operator; arg2, arg3 - parameters */
		case nd_expr:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = (arg3 ? 2 : 1);
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg2);
			if (arg3)
				re->links[1] = AST_NODE_PTR(arg3);
			break;

		/* otherwise: error */
		default:
			yyerror("Unknown node type");
	}
	return re;
}

#endif
