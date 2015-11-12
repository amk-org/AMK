%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* include header file for AST */
#include "amk_ast.h"

%}

/* union */
%union {
  char *str;
  struct ast_node *ptr;
};

/* operator precedence and associativity */
%right dget
%right get
%right dcontain
%right contain
%right vee
%right wedge
%nonassoc not

/* terminal tokens */
%token <ptr> import	theorem	axiom lemma require
%token <ptr> conclude proof where of left_bracket right_bracket
%token <ptr> left_ref right_ref left_parren	right_parren
%token <ptr> colon comma
%token <ptr> not vee wedge contain get dget dcontain
%token <ptr> indent dedent new_line

%token <str> file_name	identifier	label

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
				struct ast_node ** arr = malloc(sizeof(void *) * 2);
				arr[0] = $3;
				arr[1] = $4;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr, NULL);
				RPT(proof_block, "theorem %s declared", $1);
		   }

theorem_pref: theorem {
				/* nothing */
			}
			| lemma {
				/* nothing */
			}

ref_pref: theorem {
			$$ = malloc(sizeof(char));
			*$$ = 't';
			RPT(reference_prefix, "theorem");
		}
		| lemma {
			$$ = malloc(sizeof(char));
			*$$ = 'l';
			RPT(reference_prefix, "lemma");
		}
		| axiom {
			$$ = malloc(sizeof(char));
			*$$ = 'a';
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
			$$ = $3;
			RPT(proof_body, "finished");
		  }

of_exprs: {
			$$ = new_ast_node(nd_of_exprs, NULL, NULL, NULL);
		}
		| of_expr of_exprs {
			$$ = new_ast_node(nd_of_exprs, $1, $2, NULL);
		}

of_expr: var of identifier new_line {
			$$ = new_ast_node(nd_of_expr, $1, $3, NULL);
			RPT(of_expr, "var %s of type %s", $1, $3);
		}


exprs: expr new_line{
		$$ = new_ast_node(nd_exprs, $1, NULL, NULL);
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
			$$ = new_ast_node(nd_rich_exprs, $1, NULL, NULL);
			RPT(rich_expr, "without additional info");
		  }
		  | expr theorem_ref new_line {
			$$ = new_ast_node(nd_rich_exprs, $1, $2, NULL);
			RPT(rich_expr, "with reference of theorem %s", (char*)($2->data));
		  }
		  | expr label new_line {
			$$ = new_ast_node(nd_rich_exprs, $1, NULL, $2);
			RPT(rich_expr, "with label %s", $2);
		  }
		  | expr theorem_ref label new_line {
			$$ = new_ast_node(nd_rich_exprs, $1, $2, $3);
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
		| ref_theo colon ref_labels {
			$$ = new_ast_node(nd_ref_body, $1, NULL, $3);
			RPT(reference, "with theorem/lemma/axiom %s and labels", $1);
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
		| label comma ref_labels {
			$$ = new_ast_node(nd_ref_labels, $1, $3, NULL);
			RPT(label, " with %s", $1);
		}

var: identifier {
		$$ = $1;
		RPT(var, "%s", $1);
	}

/* logics.proposition Grammar */

expr: var {
		$$ = new_ast_node(nd_expr, NULL, $1, NULL);
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


%%

/* FUNCTION DEFINITIONS */
int main()
{
	/* parse to get AST */
	yyparse();

	/* perform Syntax-Directed Translation*/
	/* TODO */
	return 0;
}

