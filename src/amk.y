%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*** interface to the lexer ***/

/*  Lexer prototype required by bison, aka getNextToken() */
int yylex();

/* line number variable */
extern int yylineno;

/* error reporting function */
int yyerror(void * addr_root, const char *p) {
	fprintf(stderr, "Error at line %d: %s\n", yylineno, p);
	return 1;
}

/* include header file for AST */
#include "amk_ast.h"

%}

/* union */
%union {
  char *str;
  struct ast_node *ptr;
};

/* param of parser */
%parse-param {void *addr_root} 

/* operator precedence and associativity */
%right dget
%right get
%right comma
%right dcontain
%right contain
%right vee
%right wedge
%nonassoc not

/* terminal tokens */
%token <ptr> import	theorem	axiom lemma require
%token <ptr> conclude proof where define of 
%token <ptr> left_bracket right_bracket
%token <ptr> left_ref right_ref left_parren	right_parren
%token <ptr> colon comma
%token <ptr> set list
%token <ptr> not vee wedge contain get dget dcontain
%token <ptr> indent dedent new_line
%type <ptr> type

%token <str> file_name	identifier	label
%token <str> type_identifier

/* non-terminal tokens */
/* Basic AMK */
%type <ptr> program import_part proof_part
%type <ptr> proof_block
%type <ptr> proof_req proof_con proof_body
%type <ptr> theorem_ref
%type <ptr> ref_body ref_labels
%type <ptr> exprs rich_exprs of_exprs of_expr rich_expr
%type <ptr> import_expr

%type <str> ref_pref ref_theo
%type <str> var
%type <str> proof_head theorem_pref

/* logics.proposition */
%type <ptr> expr


/*****************************************************************************/
/* GRAMMAR RULES */
%%

/* Basic AMK Grammar */

program: import_part proof_part {
			$$ = new_ast_node(nd_program, $1, $2, NULL);
			*AST_NODE_PTR_ARR(addr_root) = $$;
			RPT(program, "finished");
	   }

import_part: {
				$$ = new_ast_node(nd_import_part, NULL, NULL, NULL);
				RPT(import_part, "start merging");
		   }
		   | import_expr import_part {
				$$ = new_ast_node(nd_import_part, $1, $2, NULL);
				RPT(import_part, "merge with %s", (char *)($1->data));
		   }

import_expr: import file_name new_line{
				$$ = new_ast_node(nd_import_expr, $2, NULL, NULL);
				RPT(import_expr, "input %s", $2);
		   }

proof_part: {
				$$ = new_ast_node(nd_proof_part, NULL, NULL, NULL);
				RPT(proof_part, "start merging");
		  }
		  | proof_block proof_part {
				$$ = new_ast_node(nd_proof_part, $1, $2, NULL);
				RPT(proof_part, "merge with theorem %s", (char *)($1->data));
		  }

proof_block: proof_head indent proof_req proof_con proof_body dedent {
				struct ast_node ** arr = malloc(sizeof(void *) * 3);
				arr[0] = $3;
				arr[1] = $4;
				arr[2] = $5;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr, NULL);
				RPT(proof_block, "theorem %s constructed", $1);
		   }
		   | proof_head indent proof_req proof_con dedent {
				struct ast_node ** arr = malloc(sizeof(void *) * 3);
				arr[0] = $3;
				arr[1] = $4;
				arr[2] = NULL;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr, NULL);
				RPT(proof_block, "theorem %s declared", $1);
		   }

theorem_pref: theorem {
				/* nothing */
			}
			| lemma {
				/* nothing */
			}

ref_pref: {
			$$ = malloc(2);
			$$[0]='a'; $$[1]=0;
			RPT(reference_prefix, "axiom");
		}
		| theorem {
			$$ = malloc(2);
			$$[0]='t'; $$[1]=0;
			RPT(reference_prefix, "theorem");
		}
		| lemma {
			$$ = malloc(2);
			$$[0]='l'; $$[1]=0;
			RPT(reference_prefix, "lemma");
		}
		| axiom {
			$$ = malloc(2);
			$$[0]='a'; $$[1]=0;
			RPT(reference_prefix, "axiom");
		}

proof_head: theorem_pref identifier colon new_line {
			$$ = $2;
			RPT(proof_head, "name is %s", $2);
		  }

proof_req: require colon new_line indent of_exprs exprs dedent {
			$$ = new_ast_node(nd_proof_req, $5, $6, NULL);
			RPT(proof_req, "finished");
		 }

proof_con: conclude colon new_line indent exprs dedent{
			$$ = $5;
			RPT(proof_con, "finished");
		 }

proof_body: proof colon new_line indent rich_exprs dedent {
			$$ = $5;
			RPT(proof_body, "finished");
		  }

of_exprs: {
			$$ = new_ast_node(nd_of_exprs, NULL, NULL, NULL);
		}
		| of_expr of_exprs {
			$$ = new_ast_node(nd_of_exprs, $1, $2, NULL);
		}

of_expr: define var of type new_line {
			$$ = new_ast_node(nd_of_expr, $2, $4, NULL);
			RPT(of_expr, "var %s of type %s", $2, (char *)($4->data));
		}

type: identifier {
		$$ = new_ast_node(nd_type, $1, NULL, NULL);
		RPT(type, "%s", $1);
	}
	| set left_bracket type right_bracket {
		$$ = new_ast_node(nd_type, (char *)str_set, $3, NULL);
		RPT(set_type, "%s", (char *)($3->data));
	}
	| list left_bracket type right_bracket {
		$$ = new_ast_node(nd_type, (char *)str_list, $3, NULL);
		RPT(list_type, "%s", (char *)($3->data));
	}


exprs: {
		$$ = new_ast_node(nd_exprs, NULL, NULL, NULL);
		RPT(exprs, "bound");
	 }
	 | expr new_line exprs {
		$$ = new_ast_node(nd_exprs, $1, $3, NULL);
	 }

rich_exprs: rich_expr {
			$$ = new_ast_node(nd_rich_exprs, $1, NULL, NULL);
			RPT(rich_exprs, "bound");
		  }
		  | rich_expr rich_exprs {
			$$ = new_ast_node(nd_rich_exprs, $1, $2, NULL);
		  }

rich_expr: expr new_line {
			$$ = new_ast_node(nd_rich_expr, $1, NULL, NULL);
			RPT(rich_expr, "without additional info");
		  }
		  | expr theorem_ref new_line {
			$$ = new_ast_node(nd_rich_expr, $1, $2, NULL);
			RPT(rich_expr, "with reference of theorem %s", (char*)($2->data));
		  }
		  | expr label new_line {
			$$ = new_ast_node(nd_rich_expr, $1, NULL, $2);
			RPT(rich_expr, "with label %s", $2);
		  }
		  | expr theorem_ref label new_line {
			$$ = new_ast_node(nd_rich_expr, $1, $2, $3);
			RPT(rich_expr, "with reference of theorem %s, label %s",
				(char*)($2->data), $3);
		  }

theorem_ref: left_ref ref_body right_ref {
			$$ = $2;
			RPT(theorem_reference, "completed with -[ and ]");
		   }

ref_body: ref_pref ref_theo {
			$$ = new_ast_node(nd_ref_body, $2, $1, NULL);
			RPT(reference, "%s", $2);
		}
		| ref_pref ref_theo colon ref_labels {
			$$ = new_ast_node(nd_ref_body, $2, $1, $4);
			RPT(reference, "with theorem %s and labels", $2);
		}
		| colon ref_labels {
			$$ = new_ast_node(nd_ref_body, NULL, NULL, $2);
			RPT(reference, "with an axiom and labels");
		}

ref_theo: identifier {
			$$ = $1;
			RPT(reference_theorem, "%s referred", $1);
		}

ref_labels: label {
			$$ = new_ast_node(nd_ref_labels, $1, NULL, NULL);
			RPT(label, "%s", $1);
		}
		| label ref_labels {
			$$ = new_ast_node(nd_ref_labels, $1, $2, NULL);
			RPT(label, " with %s", $1);
		}

var: identifier {
		$$ = $1;
		RPT(var, "%s", $1);
	}

/* logics.proposition Grammar */

expr: var {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_null), $1, NULL);
		RPT(expr, "with single var %s", $1);
	}
	| not expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_not), $2, NULL);
		RPT(expr, "with 'not'");
	}
	| expr wedge expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_wedge), $1, $3);
		RPT(expr, "with 'wedge'");
	}
	| expr vee expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_vee), $1, $3);
		RPT(expr, "with 'vee'");
	}
	| expr contain expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_contain), $1, $3);
		RPT(expr, "with 'contain'");
	}
	| expr dcontain expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_dcontain), $1, $3);
		RPT(expr, "with 'dcontain'");
	}
	| expr get expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_get), $1, $3);
		RPT(expr, "with 'get'");
	}
	| expr dget expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_dget), $1, $3);
		RPT(expr, "with 'dget'");
	}
	| expr comma expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_comma), $1, $3);
		RPT(expr, "with comma");
	}


%%

#define MAX_NUM_THEOREM 100

struct theorem_node
{
	char* name;
	int type;
	struct ast_node* node_require;
	struct ast_node* node_conclude;
};

struct theorem_node table_theorem[MAX_NUM_THEOREM];
int theorem_total=0;
int require_num=0;

void translate(struct ast_node* node)
{
	enum node_types node_type=node->node_type;
	int node_num,i;
	node_num=node->num_links;
	switch (node_type)
	{
		case nd_program:
			/* now, only focus on the proof parts */
			translate(node->links[1]); 
			break;
		case nd_proof_part:
			/* deal with each proof block */
			for (i=0;i<node_num;i++)
				translate(node->links[i]);
			break;
		case nd_proof_block:
			table_theorem[theorem_total].name=(char*)node->data;
			printf("%s\n",(char*)node->data);
			table_theorem[theorem_total].type=0;
			table_theorem[theorem_total].node_require=node->links[0];
			table_theorem[theorem_total].node_conclude=node->links[1];
			theorem_total++;
			if (node->links[2]!=NULL)
				translate(node->links[2]);
			break;
		case nd_rich_exprs:
			/* in order to get requires firstly */
			printf("%d\n",(int)node);
			printf(" ?? %d %d\n",node->links[1]->node_type,(int)node->links[1]);
			translate(node->links[1]);

			translate(node->links[0]);
			break;
		case nd_ref_body:
			printf("%si ooo \n",node->data);
			break;
		case nd_expr:
			printf("==++==\n");
			break;
		default:
			break;
	}
}

void search_require(struct ast_node* node)
{
	enum node_types node_type=node->node_type;
	printf("== = == %d\n",node_type);
}


/* FUNCTION DEFINITIONS */
int main()
{
	/* parse to get AST */
	yyparse(&root);
	printf("%x\n", (unsigned int)root);

	/* print AST structure */
	FILE * ast_log = fopen("ast_structure.log", "w");
	print_ast(root, 0, ast_log);
	fclose(ast_log);

	/* perform Syntax-Directed Translation*/
	translate(root);
	printf("lalala\n");

	for (int i=0;i<theorem_total;i++)
	{
		printf("%s\n",table_theorem[i].name);
		search_require(table_theorem[i].node_require);
	}
	
	return 0;
}
