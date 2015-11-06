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

/* terminal tokens */
%token <ptr> import	theorem	axiom lemma require
%token <ptr> conclude proof where left_bracket right_bracket
%token <ptr> left_ref right_ref left_parren	right_parren 
%token <ptr> not vee wedge contain get dget
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

%type <str> import_expr
%type <str> var
%type <str> ref_pref ref_theo
%type <str> proof_head theorem_pref
/* logics.proposition */


/*****************************************************************************/
/* GRAMMAR RULES */
%%

/* TODO: contruction of AST and passing of values */

/* Basic AMK Grammar */

program: import_part proof_part {
			$$ = new_ast_node(nd_program, $1, $2);
	   }

import_part: {
				$$ = new_ast_node(nd_import_part, NULL, NULL); 
		   }
		   | import_expr import_part {
				$$ = new_ast_node(nd_import_part, $1, $2); 
		   }

import_expr: import file_name {
				$$ = new_ast_node(nd_import_expr, $2, NULL); 
				fprintf(stderr, "import: %s\n", $2);
		   }

proof_part: {
				$$ = new_ast_node(nd_proof_part, NULL, NULL);
		  }
		  | proof_block proof_part {
				$$ = new_ast_node(nd_proof_part, $1, $2);
		  }

proof_block: proof_head proof_req proof_con proof_body {
				struct ast_node ** arr = malloc(sizeof(void *) * 3);
				arr[0] = $2;
				arr[1] = $3;
				arr[2] = $4;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr);
		   }
		   | proof_head proof_req proof_con {
				struct ast_node ** arr = malloc(sizeof(void *) * 2);
				arr[0] = $2;
				arr[1] = $3;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr);
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
		$$ = new_ast_node(nd_exprs, $1, NULL);
	 }
	 | expr exprs {
		$$ = new_ast_node(nd_exprs, $1, $2);
	 }

rich_exprs: rich_expr {
			$$ = new_ast_node(nd_rich_exprs, $1, NULL);
		  }
		  | rich_expr rich_exprs {
			$$ = new_ast_node(nd_rich_exprs, $1, $2);
		  }

rich_expr: expr { 
			$$ = new_ast_node(nd_rich_exprs, $1, NULL);
		  }
		  | expr theorem_ref {
			void * arr[2];
			arr[0] = $2;
			arr[1] = NULL;
			$$ = new_ast_node(nd_rich_exprs, $1, arr);
		  }
		  | expr label {
			void * arr[2];
			arr[0] = NULL;
			arr[1] = $2;
			$$ = new_ast_node(nd_rich_exprs, $1, arr);
		  }
		  | expr theorem_ref label {
			void * arr[2];
			arr[0] = $2;
			arr[1] = $3;
			$$ = new_ast_node(nd_rich_exprs, $1, arr);
		  }

theorem_ref: left_ref ref_body right_ref {
			$$ = $2; 
		   }

ref_body: ref_pref ref_theo {
		
		}
		| ref_pref ref_theo ':' ref_vars {
		
		}
		| ref_theo ':' ref_vars {
		
		}
		| ':' ref_vars {
		
		}

ref_vars: var {
		
		}
		| var ',' ref_vars {
		
		}

/* logics.proposition Grammar */



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

