%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* include header file for AST */
#include "amk_ast.h"

%}

/* union */
%union {
  int val;
  char *str;
  void *ptr;
};

/* terminal tokens */
%token <ptr> import	theorem	axiom lemma require
%token <ptr> conclude proof where left_bracket right_bracket
%token <ptr> left_ref right_ref left_parren	right_parren colon
%token <ptr> comma colon
%token <ptr> not vee wedge contain get dget
%token <ptr> indent dedent
%token <str> file_name	identifier	label

/* non-terminal tokens */
/* Basic AMK */
%token <ptr> import_part proof_part
%token <ptr> proof_block
%token <str> file_name import_expr

/* logics.proposition */


/*****************************************************************************/
/* GRAMMAR RULES */
%%

/* TODO: contruction of AST and passing of values */

/* Basic AMK Grammar */

program: import_part proof_part {}

import_part: {
		   
		   }
		   | import_expr import_part {
		   
		   }

import_expr: import file_name {
				$$ = $2; 
		   }

proof_part: {
		  
		  }
		  | proof_block proof_part {
		  
		  }

proof_block: proof_head proof_req proof_con proof_body {
		   
		   }
		   | proof_head proof_req proof_con {
		   
		   }

theorem_pref: theorem {
			
			}
			| lemma {
			
			}

ref_pref: theorem {
		
		}
		| lemma {
		
		}
		| axiom {
		
		}

proof_head: theorem_pref identifier colon {
		  
		  }
	
proof_req: require colon exprs {
		 
		 }

proof_con: conclusion colon exprs {
		 
		 }

proof_body: proof colon rich_exprs {
		  
		  }

exprs: expr {
	 
	 }
	 | expr exprs {
	 
	 }

rich_exprs: expr {
		  
		  }
		  | expr theorem_ref {
		  
		  }
		  | expr label {
		  
		  }
		  | expr theorem_ref label {
		  
		  }

theorem_ref: left_ref ref_body right_ref {
		   
		   }

ref_body: ref_pref {
		
		}
		| ref_pref colon ref_vars {
		
		}
		| colon ref_vars {
		
		}

ref_vars: var {
		
		}
		| var comma ref_vars {
		
		}

/* logics.proposition Grammar*/



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
