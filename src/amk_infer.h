
#ifndef amk_infer_h
#define amk_infer_h

#include <assert.h>

#define MAX_INFER_STEPS 1

/*
 * check whether the provided expression is the missing one.
 *
 * Method: check the theorem usage.
 *
 * Parameter:
 *		@missing_expr: a newly constructed expr to be added into proof
 *			and be labeled as <x>
 *
 *		(to be added)
 *
 * Return Value:
 *		Success:	1
 *		Fail:		0
 */
int check(struct ast_node *missing_expr)
{
	/* TODO */
}

void search_req_fit_previous(int depth, int max_depth,
		struct theorem_node *th, struct ast_node ** re);

/*
 * Infer at most MAX_INFER_STEPS steps.
 *
 * Trigger: use <x> in theorem refernce, e.g.
 *		a |- not b -[theorem T: <x> <aa>] <bb>
 *
 * Analysis:
 *		1. provided with the missing requirement Q in theorem definition;
 *		2. search all previous steps, try to match and check through theorem T;
 *		3. if non of previous expressions fits, scan all existing theorems
 *			and find one with
 *			a). its conclusion line (suppose there is only one) matched,
 *			b). its requirements can be satisfied in a way of combing
 *				existing expressions.
 *		  construct the missing expression with such theorem's conclusion
 *			and check through theorem T;
 *		4. if step 3 fails, dive into deeper search.
 *
 * Parameter:
 *	@proof_expr: the nd_expr currently dealing with in proof_block.
 *
 *	@req_expr: the corresponding requirement expression Q in theorem T's
 *		requirement part.
 *
 * Return value:
 *		Success: return depth
 *		Fail: -1
 */
int infer(struct ast_node * proof_expr,
			struct ast_node * req_expr,
			struct ast_node *labels_pointer,
			struct ast_node *req_exprs,
			int num_of_expr)
{
	if (MAX_INFER_STEPS <0)
		return -1;

	/* seach if can be found in previous steps */
	for (int i=0; i<rich_exprs_num; i++)
		if (search_diff_exprs(rich_exprs[i]->data, proof_expr)
				&& check(rich_exprs[i]->expr))
			return 0;

	if (MAX_INFER_STEPS == 0)
		return -1;

	char * flag = malloc(rich_exprs_num);

	/* search through theorems */
	for (int i=0, j, k; i<theorem_total; i++)
		if (table_theorem[i].node_conclude->num_links == 1
				&& search_diff_exprs(table_theorem[i].node_conclude->links[0],
						proof_expr)){
			struct theorem_node * th = table_theorem[i];
			int num_req_th = th.node_require->num_links;
			struct ast_note *re = NULL;
			memset(flag, 0, rich_exprs_num);

			/*
			 * find legal combination of theorem `th`'s requirement,
			 * and save the newly constructed expression in re
			 */
			search_req_fit_previous(0, num_req_th, th, &re, flag);
			if (re!=NULL && check(re)) {
				delete []flag;
				return 1;
			}
		}

	assert(MAX_INFER_STEPS <= 1);

	delete []flag;

	return -1;
}


void search_req_fit_previous(int depth, int max_depth,
		struct theorem_node *th, struct ast_node ** re,
		char *flag)
{
	if (depth == max_depth) {
		/* TODO */
		return;
	}
	for (int i=0; i<rich_exprs_num; i++)
		if (!flag[i]) {
			flag[i] = 1;
			search_req_fit_previous(depth+1, max_depth, th, re, flag);
			flag[i] = 0;
		}
}
#endif

