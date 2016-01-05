%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* include header file for AST */
#include "amk_ast.h"

/*** interface to the lexer ***/

/*  Lexer prototype required by bison, aka getNextToken() */
int yylex();

/* line number variable */
extern int yylineno;

extern char * yytext;

/* lineno offset */
static int lineoff = 0; 

/* error reporting function */
int yyerror(void * addr_root, const char *p) {
	fprintf(stderr, "Error at line %d: %s\n", yylineno - lineoff, p);
	exit(0);
	return 1;
}

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
%token <ptr> left_ref right_ref left_paren	right_paren
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
			$$ = new_ast_node(nd_program, $1, $2, NULL, @1.first_line + lineoff, @2.last_line - 1);
			*AST_NODE_PTR_ARR(addr_root) = $$;
			RPT(program, "finished");
	   }

import_part: {
				$$ = new_ast_node(nd_import_part, NULL, NULL, NULL, lineoff, 0);
				RPT(import_part, "start merging");
		   }
		   | import_expr import_part {
				$$ = new_ast_node(nd_import_part, $1, $2, NULL, @1.first_line + lineoff, @2.last_line - 1);
				RPT(import_part, "merge with %s", (char *)($1->data));
		   }

import_expr: import file_name new_line{
				$$ = new_ast_node(nd_import_expr, $2, NULL, NULL, @1.first_line, @2.last_line);
				RPT(import_expr, "input %s", $2);
		   }

proof_part: {
				$$ = new_ast_node(nd_proof_part, NULL, NULL, NULL, 0, 0);
				RPT(proof_part, "start merging");
		  }
		  | proof_block proof_part {
				$$ = new_ast_node(nd_proof_part, $1, $2, NULL, @1.first_line, @2.last_line - 1);
				RPT(proof_part, "merge with theorem %s", (char *)($1->data));
		  }

proof_block: proof_head indent proof_req proof_con proof_body dedent {
				struct ast_node ** arr = malloc(sizeof(void *) * 3);
				arr[0] = $3;
				arr[1] = $4;
				arr[2] = $5;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr, NULL, @1.first_line, @5.last_line - 1);
				RPT(proof_block, "theorem %s constructed", $1);
		   }
		   | proof_head indent proof_req proof_con dedent {
				struct ast_node ** arr = malloc(sizeof(void *) * 3);
				arr[0] = $3;
				arr[1] = $4;
				arr[2] = NULL;
				$$ = new_ast_node(nd_proof_block, (void *)$1, (void *)arr, NULL, @1.first_line, @4.last_line - 1);
				RPT(proof_block, "theorem %s declared", $1);
		   }

theorem_pref: theorem {
				$$ = (char *) theorem_prefix;
			}
			| lemma {
				$$ = (char *) theorem_prefix+2;
			}
			| axiom {
				$$ = (char *) theorem_prefix+4;
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
			$$ = malloc(strlen($2)+3);
			strcpy($$, $2);
			strcpy($$+strlen($2)+1, $1);
			RPT(proof_head, "name is %s", $2);
			free($2);
		  }
		  | theorem_pref identifier new_line {
			$$ = malloc(strlen($2)+3);
			strcpy($$, $2);
			strcpy($$+strlen($2)+1, $1);
			RPT(proof_head, "name is %s", $2);
			free($2);
		  }

proof_req: require colon new_line indent of_exprs exprs dedent {
			$$ = new_ast_node(nd_proof_req, $5, $6, NULL, @1.first_line, @6.last_line - 1);
			RPT(proof_req, "finished");
		 }
		 | require new_line indent of_exprs exprs dedent {
			$$ = new_ast_node(nd_proof_req, $4, $5, NULL, @1.first_line, @6.last_line - 1);
			RPT(proof_req, "finished");
		 }

proof_con: conclude colon new_line indent exprs dedent{
			$$ = $5;
			RPT(proof_con, "finished");
		 }
		 | conclude new_line indent exprs dedent {
			$$ = $4;
			RPT(proof_con, "finished");
		 }

proof_body: proof colon new_line indent rich_exprs dedent {
			$$ = $5;
			RPT(proof_body, "finished");
		  }
		  | proof new_line indent rich_exprs dedent {
			$$ = $4;
			RPT(proof_body, "finished");
		  }

of_exprs: {
			$$ = new_ast_node(nd_of_exprs, NULL, NULL, NULL, 0, 0);
		}
		| of_expr of_exprs {
			$$ = new_ast_node(nd_of_exprs, $1, $2, NULL, @1.first_line, @2.last_line - 1);
		;}

of_expr: define var of type new_line {
			$$ = new_ast_node(nd_of_expr, $2, $4, NULL, @1.first_line, @3.last_line);
			RPT(of_expr, "var %s of type %s", $2, (char *)($4->data));
		}

type: identifier {
		$$ = new_ast_node(nd_type, $1, NULL, NULL, @1.first_line, @1.last_line);
		RPT(type, "%s", $1);
	}
	| set left_bracket type right_bracket {
		$$ = new_ast_node(nd_type, (char *)str_set, $3, NULL, @1.first_line, @4.last_line);
		RPT(set_type, "%s", (char *)($3->data));
	}
	| list left_bracket type right_bracket {
		$$ = new_ast_node(nd_type, (char *)str_list, $3, NULL, @1.first_line, @4.last_line);
		RPT(list_type, "%s", (char *)($3->data));
	}


exprs: {
		$$ = new_ast_node(nd_exprs, NULL, NULL, NULL, 0, 0);
		RPT(exprs, "bound");
	 }
	 | expr new_line exprs {
		$$ = new_ast_node(nd_exprs, $1, $3, NULL, @1.first_line, @3.last_line - 1);
	 }

rich_exprs: rich_expr {
			$$ = new_ast_node(nd_rich_exprs, $1, NULL, NULL, @1.first_line, @1.last_line);
			RPT(rich_exprs, "bound");
		  }
		  | rich_expr rich_exprs {
			$$ = new_ast_node(nd_rich_exprs, $1, $2, NULL, @1.first_line, @2.last_line - 1);
		  }

rich_expr: expr new_line {
			$$ = new_ast_node(nd_rich_expr, $1, NULL, NULL, @1.first_line, @1.last_line);
			RPT(rich_expr, "without additional info");
		  }
		  | expr theorem_ref new_line {
			$$ = new_ast_node(nd_rich_expr, $1, $2, NULL, @1.first_line, @2.last_line);
			RPT(rich_expr, "with reference of theorem %s", (char*)($2->data));
		  }
		  | expr label new_line {
			$$ = new_ast_node(nd_rich_expr, $1, NULL, $2, @1.first_line, @2.last_line);
			RPT(rich_expr, "with label %s", $2);
		  }
		  | expr theorem_ref label new_line {
			$$ = new_ast_node(nd_rich_expr, $1, $2, $3, @1.first_line, @3.last_line);
			RPT(rich_expr, "with reference of theorem %s, label %s",
				(char*)($2->data), $3);
		  }

theorem_ref: left_ref ref_body right_ref {
			$$ = $2;
			RPT(theorem_reference, "completed with -[ and ]");
		   }

ref_body: ref_pref ref_theo {
			$$ = new_ast_node(nd_ref_body, $2, $1, NULL, @1.first_line, @2.last_line);
			RPT(reference, "%s", $2);
		}
		| ref_pref ref_theo colon ref_labels {
			$$ = new_ast_node(nd_ref_body, $2, $1, $4, @1.first_line, @4.last_line);
			RPT(reference, "with theorem %s and labels", $2);
		}
		| colon ref_labels {
			$$ = new_ast_node(nd_ref_body, NULL, NULL, $2, @1.first_line, @2.last_line);
			RPT(reference, "with an axiom and labels");
		}

ref_theo: identifier {
			$$ = $1;
			RPT(reference_theorem, "%s referred", $1);
		}

ref_labels: label {
			$$ = new_ast_node(nd_ref_labels, $1, NULL, NULL, @1.first_line, @1.last_line);
			RPT(label, "%s", $1);
		}
		| label ref_labels {
			$$ = new_ast_node(nd_ref_labels, $1, $2, NULL, @1.first_line, @2.last_line);
			RPT(label, " with %s", $1);
		}

var: identifier {
		$$ = $1;
		RPT(var, "%s", $1);
	}

/* logics.proposition Grammar */

expr: var {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_null), $1, NULL, @1.first_line, @1.last_line);
		RPT(expr, "with single var %s: %s", $1, yytext);
	}
	| left_paren expr right_paren {
		$$ = $2;
		RPT(expr, "with parentheses: %s", yytext);
	}
	| not expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_not), $2, NULL, @1.first_line, @2.last_line);
		RPT(expr, "with 'not': %s", yytext);
	}
	| expr wedge expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_wedge), $1, $3, @1.first_line, @3.last_line);
		RPT(expr, "with 'wedge': %s", yytext);
	}
	| expr vee expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_vee), $1, $3, @1.first_line, @3.last_line);
		RPT(expr, "with 'vee': %s", yytext);
	}
	| expr contain expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_contain), $1, $3, @1.first_line, @3.last_line);
		RPT(expr, "with 'contain': %s", yytext);
	}
	| expr dcontain expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_dcontain), $1, $3, @1.first_line, @3.last_line);
		RPT(expr, "with 'dcontain': %s", yytext);
	}
	| expr get expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_get), $1, $3, @1.first_line, @3.last_line);
		RPT(expr, "with 'get': %s", yytext);
	}
	| expr dget expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_dget), $1, $3, @1.first_line, @3.last_line);
		RPT(expr, "with 'dget': %s", yytext);
	}
	| expr comma expr {
		$$ = new_ast_node(nd_expr, AST_NODE_PTR(op_comma), $1, $3, @1.first_line, @3.last_line);
		RPT(expr, "with comma: %s", yytext);
	}


%%

/* include header file for AST (function definitions) */
#include "amk_ast_def.h"

/* include header file for Translator */
#include "amk_translator.h"

void print_tree(struct ast_node* node,FILE* fp)
{
	enum node_types node_type=node->node_type;
	int node_num=node->num_links;
	int i;
	switch (node_type)
	{
		case nd_program:
			print_tree(node->links[1],fp);
			break;
		case nd_proof_part:
			for (i=0;i<node_num;i++)
				print_tree(node->links[i],fp);
			break;
		case nd_proof_block:
			//fprintf(fp," \\( a, \\neg a, \\neg b \\vdash b .\\)<span>%s</span><br/>\n",(char*)node->data);
			
			char* type=((char*)node->data)+strlen((char*)node->data)+1;
			if ((strcmp(type,"a")!=0)&&(node->links[2]!=NULL))
				print_tree(node->links[2],fp);

			fprintf(fp,"\n");
			break;
		case nd_rich_exprs:
			for (int i=0;i<node->num_links;i++)
				print_tree(node->links[i],fp);
			break;
		case nd_rich_expr:	
			fprintf(fp,"\\([%s]: a, \\neg a, \\neg b \\vdash b  \\)<span>%s</span>\n ",(char*)node->links[1],node->links[0]->data);
			
			struct ast_node* lables_pointer=node->links[0]->links[1];
			if (lables_pointer!=NULL)
			{
				int lables_num=lables_pointer->num_links;
				for (int i=0;i<lables_num;i++)
					fprintf(fp,"(%s)",(char*)lables_pointer->links[i]);
			}
			fprintf(fp," <br/>\n");
			break;
		default:
			break;
	}
}

void print(struct ast_node* node)
{
	FILE *fp=fopen("out.tex","w");
	print_tree(node,fp);
}

/* FUNCTION DEFINITIONS */
int main(int argc, char ** argv)
{

	if (argc > 1)
		lineoff = atoi(argv[1]);

	/* parse to get AST */
	yyparse(&root);

	/* print AST structure */
/*	FILE * ast_log = fopen("ast_structure.log", "w");
	print_ast(root, 0, ast_log);
	fclose(ast_log);
	RPT(AST, "finished.");
*/

	/* perform Syntax-Directed Translation*/
	translate(root);
	
	if (program_success)
		print_message(SUCCESS,"program passes the varification successfully",root->location->first_line,root->location->last_line);

	/* print it to pdf file*/
	print(root);
	return 0;
}
