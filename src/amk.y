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
  void * VOID;
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
%token <ptr> conclude proof where left_bracket right_bracket
%token <ptr> left_ref right_ref left_parren	right_parren 
%token <ptr> not vee wedge contain get dget dcontain
%token <ptr> indent dedent

%token <str> file_name	identifier	label

/* non-terminal tokens */
/* Basic AMK */
%type <ptr> program import_part proof_part
%type <ptr> proof_block
%type <ptr> proof_req proof_con proof_body
%type <ptr> theorem_ref
%type <ptr> ref_body ref_vars
%type <ptr> expr exprs rich_expr rich_exprs
%type <ptr> var
%type <ptr> import_expr

%type <str> ref_pref ref_theo
%type <str> proof_head theorem_pref
/* logics.proposition */


/*****************************************************************************/
/* GRAMMAR RULES */
%%

/* TODO: contruction of AST and passing of values */

/* Basic AMK Grammar */

program: import_part proof_part {
			$$ = new_ast_node(nd_program, $1, $2, NULL);
	   }

import_part: {
				$$ = new_ast_node(nd_import_part, NULL, NULL, NULL); 
		   }
		   | import_expr import_part {
				$$ = new_ast_node(nd_import_part, $1, $2, NULL); 
		   }

import_expr: import file_name {
				$$ = new_ast_node(nd_import_expr, $2, NULL, NULL); 
				fprintf(stderr, "import: %s\n", $2);
		   }

proof_part: {
				$$ = new_ast_node(nd_proof_part, NULL, NULL, NULL);
		  }
		  | proof_block proof_part {
				$$ = new_ast_node(nd_proof_part, $1, $2, NULL);
		  }

proof_block: proof_head proof_req proof_con proof_body {
				struct ast_node ** arr = malloc(sizeof(void *) * 3);
				arr[0] = $2;
				arr[1] = $3;
				arr[2] = $4;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr, NULL);
		   }
		   | proof_head proof_req proof_con {
				struct ast_node ** arr = malloc(sizeof(void *) * 2);
				arr[0] = $2;
				arr[1] = $3;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr, NULL);
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
		}
		| lemma {
			$$ = malloc(sizeof(char));
			*$$ = 'l';
		}
		| axiom {
			$$ = malloc(sizeof(char));
			*$$ = 'a';
		}

proof_head: theorem_pref identifier ':' {
			$$ = $2; 
		  }
	
proof_req: require ':' exprs {
			$$ = $3;	 
		 }

proof_con: conclude ':' exprs {
			$$ = $3; 
		 }

proof_body: proof ':' rich_exprs {
			$$ = $3;
		  }

exprs: expr {
		$$ = new_ast_node(nd_exprs, $1, NULL, NULL);
	 }
	 | expr exprs {
		$$ = new_ast_node(nd_exprs, $1, $2, NULL);
	 }

rich_exprs: rich_expr {
			$$ = new_ast_node(nd_rich_exprs, $1, NULL, NULL);
		  }
		  | rich_expr rich_exprs {
			$$ = new_ast_node(nd_rich_exprs, $1, $2, NULL);
		  }

rich_expr: expr { 
			$$ = new_ast_node(nd_rich_exprs, $1, NULL, NULL);
		  }
		  | expr theorem_ref {
			$$ = new_ast_node(nd_rich_exprs, $1, $2, NULL);
		  }
		  | expr label {
			$$ = new_ast_node(nd_rich_exprs, $1, NULL, $2);
		  }
		  | expr theorem_ref label {
			$$ = new_ast_node(nd_rich_exprs, $1, $2, $3);
		  }

theorem_ref: left_ref ref_body right_ref {
			$$ = $2; 
		   }

ref_body: ref_pref ref_theo {
			$$ = new_ast_node(nd_ref_body, $2, $1, NULL);
		}
		| ref_pref ref_theo ':' ref_vars {
			$$ = new_ast_node(nd_ref_body, $2, $1, $4);
		}
		| ref_theo ':' ref_vars {
			$$ = new_ast_node(nd_ref_body, $1, NULL, $3);
		}
		| ':' ref_vars {
			$$ = new_ast_node(nd_ref_body, NULL, NULL, $2);
		}

ref_theo: identifier {
			$$ = $1;
		}

ref_vars: var {
			$$ = new_ast_node(nd_ref_vars, $1, NULL, NULL);	
		}
		| var ',' ref_vars {
			$$ = new_ast_node(nd_ref_vars, $1, $3, NULL);	
		}

var: identifier {
		$$ = new_ast_node(nd_var, $1, NULL, NULL);
	}

/* logics.proposition Grammar */

expr: var {
		$$ = new_ast_node(nd_expr, NULL, NULL, NULL);
	}
	| not expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_not), $2, NULL);
	}
	| expr wedge expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_wedge), $1, $3);
	}
	| expr vee expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_vee), $1, $3);
	}
	| expr contain expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_contain), $1, $3);
	}
	| expr dcontain expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_dcontain), $1, $3);
	}
	| expr get expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_get), $1, $3);
	}
	| expr dget expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_dget), $1, $3);
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

