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
		;}

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
#define MAX_NUM_PART_OF_EXPR 100
#define MAX_REQ_STATE 100
#define MAX_NUM_RICH_EXPR 100

struct theorem_node
{
	char* name;
	int type;
	struct ast_node* node_require;
	struct ast_node* node_conclude;
};

struct expr_hash_node
{
	struct ast_node* expr;
	int index;
};

struct req_node
{
	char* name;
	char* type;
	struct ast_node* pointer;
};

struct rich_expr_node
{
	char* name;
	struct ast_node* pointer;
};

struct theorem_node table_theorem[MAX_NUM_THEOREM];
struct expr_hash_node expr_hash[MAX_NUM_PART_OF_EXPR];
struct req_node reqs[MAX_REQ_STATE];
struct rich_expr_node rich_exprs[MAX_NUM_RICH_EXPR];
int theorem_total=0;
int require_num=0;
int rich_exprs_num=0;

int find_theorem_by_name(char* s)
{
	for (int i=0;i<theorem_total;i++)
		if (strcmp(s,table_theorem[i].name)==0)
			return i;
	return -1;
}

int find_require_by_name(char* s,int req_num)
{
	for (int i=0;i<req_num;i++)
		if (strcmp(s,reqs[i].name)==0)
			return i;
	return -1;
}

int next_possible_comb(int n)
{
	int i,j;
	for(i=n-1;i>0 && expr_hash[i].index<expr_hash[i-1].index;i--);
	if (i==0) return 0;
	for(j=n-1;j>i && expr_hash[j].index<expr_hash[i-1].index;j--);
	int temp;
	temp=expr_hash[i-1].index;
	expr_hash[i-1].index=expr_hash[j].index;
	expr_hash[j].index=temp;
	for(i=i,j=n-1;i<j;i++,j--)
	{
		temp=expr_hash[i].index;
		expr_hash[i].index=expr_hash[j].index;
		expr_hash[j].index=temp;
	}
	return 1;
}

int search_same_exprs(struct ast_node* p1,struct ast_node* p2)
{
	//printf(" %d %d \n",(int)p1->data,(int)p2->data);
	if (p1->data!=p2->data) return 0;
	if (p1->data==0)
		if (strcmp((char*)p1->links[0],(char*)p2->links[0])!=0) return 0;
	if (p1->data>0)
	{
		if (p1->num_links!=p2->num_links) return 0;
		for (int i=0;i<p1->num_links;i++)
		{
			int t=search_same_exprs(p1->links[i],p2->links[i]);
			if (t==0) return 0;
		}
	}
	return 1;
}

int search_diff_exprs(struct ast_node* p1,struct ast_node* p2,int req_num)
{
	if (p1->data==0)
	{
		//printf(" require name %s\n",(char*)p1->links[0]);
		int id=find_require_by_name((char*)p1->links[0],req_num);
		if (strcmp("set",reqs[id].type)==0)
			return 1;
		if (reqs[id].pointer==NULL)
		{
			reqs[id].pointer=p2;
			return 1;
		}
		//printf(" you reached!\n");
		return search_same_exprs(reqs[id].pointer,p2);
	}
	return 0;
}

void translate(struct ast_node* node)
{
	enum node_types node_type=node->node_type;
	int node_num,i,id;
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
			//printf("theorem: %s\n",(char*)node->data);
			table_theorem[theorem_total].type=0;
			table_theorem[theorem_total].node_require=node->links[0];
			table_theorem[theorem_total].node_conclude=node->links[1];
			theorem_total++;
			if (node->links[2]!=NULL)
				translate(node->links[2]);
			break;
		case nd_rich_exprs:
			
			rich_exprs_num=0;

			for (int i=0;i<node->num_links;i++)
			{
				printf("#	[translator] program: begin to verify %dth line of proof body\n",i+1);
				translate(node->links[i]);

				rich_exprs[rich_exprs_num].name=(char*)node->links[i]->links[1];
				rich_exprs[rich_exprs_num].pointer=node->links[i]->data;
				rich_exprs_num++;
				printf(" + %s\n",(char*)node->links[i]->links[1]);
			}
			
			/* veriry the conclusion */
			struct ast_node* con_expr=table_theorem[theorem_total-1].node_conclude;
			con_expr=con_expr->links[0];
			//printf("%d\n",(int)con_expr->data);
			
			struct ast_node* last_expr=node->links[node->num_links-1]->data;
			//printf("%d\n",(int)last_expr->data);

			int res=search_same_exprs(con_expr,last_expr);
			if (res)
				printf("#	[translator] program: last line do match it's conclusion\n");
			else
				printf("#	[translator] program: last line don't matche it's conclusion\n");

			break;
		case nd_rich_expr:
			//printf("%s\n",(char*)node->links[0]->data);
			id=find_theorem_by_name(node->links[0]->data);
			struct ast_node* req=table_theorem[id].node_require;
			struct ast_node* con=table_theorem[id].node_conclude;
			struct ast_node* pointer;

			/* deal with of_exprs */
			pointer=req->links[0];
			int state_req_num=0;
			int req_num=0;
			for (int i=0;i<pointer->num_links;i++)
			{
				if (strcmp("statement",pointer->links[i]->links[0]->data)==0)
				{
					reqs[req_num].name=pointer->links[i]->data;
					//printf("%s\n",reqs[req_num].name);
					reqs[req_num].type=pointer->links[i]->links[0]->data;
					state_req_num++;
					req_num++;
				}
				if (strcmp("set",pointer->links[i]->links[0]->data)==0)
				{
					reqs[req_num].name=pointer->links[i]->data;
					//printf("%s\n",reqs[req_num].name);
					reqs[req_num].type=pointer->links[i]->links[0]->data;
					req_num++;
				}
				
			}
			//printf("num_state_req %d, num_req %d\n",state_req_num,req_num);

			pointer=node->data;
			int sub_expr_num=0;
			if ((enum operators)pointer->data==op_get)
			{
				/* deal with rght part of the expr */
				expr_hash[sub_expr_num].expr=pointer->links[1];
				sub_expr_num++;
				pointer=pointer->links[0];
				while ((enum operators)pointer->data==op_comma)
				{
					expr_hash[sub_expr_num].expr=pointer->links[0];
					sub_expr_num++;
					pointer=pointer->links[1];
				}
				expr_hash[sub_expr_num].expr=pointer;
				sub_expr_num++;
			}
			//printf("sub_expr_num %d\n",sub_expr_num);

			/* initalize the combination */
			for (int i=0;i<sub_expr_num;i++)
				expr_hash[i].index=i;

			struct ast_node* t=node->links[0]->links[1];
			printf(" la la %d\n",(int)t->node_type);
			int lables_num=node->links[0]->num_links;
			printf("lables num %d\n",lables_num);
			
			/* verify a single line in the proof body */
			int success;
			do
			{
				success=1;
				for (int i=0;i<req_num;i++)
					reqs[i].pointer=NULL;

				/*printf(" debug : sub_expr_hash \n");
				for (int i=0;i<sub_expr_num;i++)
					printf("%d ",expr_hash[i].index);
				printf("\n");*/

				struct ast_node* sub_exprs[sub_expr_num]; 
				for (int i=0;i<sub_expr_num;i++)
					sub_exprs[expr_hash[i].index]=expr_hash[i].expr;

				int index=0;
				/* check the conclusion part */
				pointer=con->links[0];
				if ((enum operators)pointer->data==op_get)
				{
					int res=search_diff_exprs(pointer->links[1],sub_exprs[index++],req_num);
					//printf("result %d\n",res);
					if (!res) success=0;
					if (!success) continue;
					
					pointer=pointer->links[0];
					while ((enum operators)pointer->data==op_comma)
					{
						//printf("=== \n");
						res=search_diff_exprs(pointer->links[0],sub_exprs[index++],req_num);
						//printf("result %d\n",res);
						if (!res) success=0;
						if (!success) break;
						pointer=pointer->links[1];
					}
					if (!success) continue;
					
					res=search_diff_exprs(pointer,sub_exprs[index++],req_num);
					//printf("result %d\n",res);
					if (!res) success=0;
					if (!success) continue;
				}

				/* continue verify requirements */
				

				if (success) break;
			}
			while (next_possible_comb(sub_expr_num));

			if (success)
				printf("#	[translator] program: match with conclusion part\n");
			else
				printf("#	[translator] program: could not match with conclusion part\n");
			break;
		case nd_ref_body:
			break;
		case nd_expr:
			break;
		default:
			break;
	}
}

/* FUNCTION DEFINITIONS */
int main()
{
	/* parse to get AST */
	yyparse(&root);
	//printf("%x\n", (unsigned int)root);

	/* print AST structure */
	FILE * ast_log = fopen("ast_structure.log", "w");
	print_ast(root, 0, ast_log);
	fclose(ast_log);
	RPT(AST, "finished.");

	/* perform Syntax-Directed Translation*/
	translate(root);
	
	return 0;
}
