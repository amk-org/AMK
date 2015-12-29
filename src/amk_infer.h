
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
		struct theorem_node *th, struct ast_node ** re,
		char *flag, struct ast_node ** reqs);

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
int infer(int depth,int max_depth,struct ast_node* labels_pointer,struct ast_node* req_exprs,int req_of_num)
{
	if (MAX_INFER_STEPS <0)
		return -1;

	struct ast_node* req_expr=req_exprs->links[depth];
	
	/* seach if can be found in previous steps */
	for (int i=0; i<rich_exprs_num; i++)
		if (search_diff_exprs(rich_exprs[i]->data, proof_expr)
				&& check(rich_exprs[i]->expr))
			return 0;

	if (MAX_INFER_STEPS == 0)
		return -1;

	char * flag = malloc(rich_exprs_num);
	struct ast_node ** reqs = malloc(sizeof(void *) * num_req_th);

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
			int res = search_req_fit_previous(0, num_req_th, th, &re, flag, reqs);
			if (res) {
				delete []flag;
				return 1;
			}
		}

	assert(MAX_INFER_STEPS <= 1);

	free(flag);
	free(reqs);

	return -1;
}

int exactly_same_expr(struct ast_node *a, struct ast_node *b)
{
	if (!a || !b)
		return !a && !b ? 1 : 0;
	if (a->num_links != b->num_links || strcmp(a->data, b->data))
		return 0;
	for (int i=0; i<a->num_links; i++)
		if (!exactly_same_expr(a->links[i], b->links[i]))
			return 0;
	return 1;
}

int check_structure_symbol(
			struct ast_node *expr,
			struct ast_node *req,
			char **syms,
			struct theorem_node *th)
{
	if (!expr || !req)
		return !expr && !req ? 1 : 0;

	if (!req->data) {
		int k;
		for (k = 0; k < th->node_require->links[0]->num_links
				&& strcmp(th->node_require->links[0]->link[k]->data,
					req->links[0]); k++);
		if (syms[k] && !exactly_same_expr(expr, syms[k]))
			return 0;
		if (!syms[k])
			syms[k] = expr;
		return 1;
	}

	if (req->data != expr->data || req->num_links != expr->num_links)
		return 0;

	for (int i=0; i<expr->num_links; i++)
		if (!check_structure_symbol(expr->links[i], req->links[i], syms, th))
			return 0;

	return 1;
}

struct ast_node *recursively_construct(
			struct ast_node *conclusion,
			struct ast_node **syms,
			struct theorem_node *th)
{
	if (!conclusion)
		return NULL;

	/* var */
	if (!conclusion->data) {
		int k;
		for (k = 0; k < th->node_require->links[0]->num_links
				&& strcmp(th->node_require->links[0]->link[k]->data,
					conclusion->links[0]); k++);
		return syms[k];
	}

	struct ast_node *re = malloc(sizeof(struct ast_node));
	re->data = conclusion->data;
	re->num_links = conclusion->num_links;
	for (int i=0; i<re->num_links; i++)
		re->links[i] = recursively_construct(conclusion->links[i],
				syms, th);
	return re;
}

struct ast_node * construct_according(
			struct theorem_node *th,
			struct ast_node **reqs)
{
	int num = th->node_require->links[1]->num_links;
	int table_size = th->node_require->links[0]->num_links;
	struct ast_node **syms = malloc(table_size * sizeof(void *));
	struct ast_nore *re = NULL;
	for (int i=0; i<table_size; i++)
		syms[i] = 0;//th->node_require->links[0]->links[i]->data;
	for (int i=0; i<num; i++) {
		struct ast_node *expr = reqs[i]->data;
		struct ast_node *req = th->node_require->links[1]->links[i];
		if (!check_structure_symbol(expr, req, syms, th))
			goto ret;
	}
	assert(th->node_conclude->num_links <= 1);
	re = recursively_construct(th->node_conclude->links[0], syms, th);
ret:
	free(syms);
	return re;
}

int search_req_fit_previous(int depth, int max_depth,
		struct theorem_node *th, struct ast_node ** re,
		char *flag, struct ast_node ** reqs)
{
	if (depth == max_depth) {
		*re = construct_according(th, reqs);
		if (!*re)
			return 0;
		int res = check(*re);
		free(*re);
		return res ? 1 : 0;
	}
	for (int i=0; i<rich_exprs_num; i++)
		if (!flag[i]) {
			flag[i] = 1;
			reqs[depth] = rich_exprs[i];
			if (search_req_fit_previous(depth+1, max_depth, th, re, flag))
				return 1;
			flag[i] = 0;
		}
	return 0;
}
#endif

