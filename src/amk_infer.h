
#ifndef amk_infer_h
#define amk_infer_h

#include <assert.h>

#define MAX_INFER_STEPS 1

#define MAX_INFER_RET_MSG_LEN 256

int check_require(int depth,
		int max_depth,
		struct ast_node* labels_pointer,
		struct ast_node* req_exprs,
		int req_of_num,
		int is_auto,
		struct ast_node* missing_expr,
		struct ast_node *proof_expr);

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
int check(int depth, int max_depth,
		struct ast_node *labels_pointer,
		struct ast_node *req_exprs,
		int req_of_num,
		struct ast_node *missing_expr,
		struct ast_node *proof_expr)
{
	return check_require(depth, max_depth, labels_pointer,
			req_exprs, req_of_num, 1, missing_expr, proof_expr) ? 1 : 0;
}

int search_req_fit_previous(
		int depth,
		int max_depth,
		struct theorem_node *th,
		struct ast_node ** re,
		char *flag,
		struct ast_node ** reqs,
		int _depth,
		int _max_depth,
		struct ast_node* _labels_pointer,
		struct ast_node* _req_exprs,
		int _req_of_num,
		struct ast_node *proof_expr);

void bp(){
	fprintf(stderr, "@");
}

int exactly_same_expr(struct ast_node *a, struct ast_node *b)
{
	if (!a || !b)
		return !a && !b ? 1 : 0;
	if (a->num_links != b->num_links || a->data != b->data)
		return 0;
	if (!a->data)
		return strcmp((char *)a->links[0], (char *)b->links[0]) ? 0 : 1;
	for (int i=0; i<a->num_links; i++)
		if (!exactly_same_expr(a->links[i], b->links[i]))
			return 0;
	return 1;
}

int structure_same_expr(struct ast_node *a, struct ast_node *b, int flag)
{
	if (!a || !b)
		return !a && !b ? 1 : 0;
	if (!a->data || (flag && !b->data))
		return 1;
	if (a->num_links != b->num_links || a->data != b->data)
		return 0;
	if (a->data) {
		for (int i=0; i<a->num_links; i++)
			if (!structure_same_expr(a->links[i], b->links[i], flag))
				return 0;
	}
	return 1;
}

#define INFER_DEBUG_FILE_PTR stderr

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
 * Return value:
 *		Success: return depth
 *		Fail: 1
 *
 * Readable message stored in *ret_msg.
 */
int infer(
		int depth,
		int max_depth,
		struct ast_node* labels_pointer,
		struct ast_node* req_exprs,
		int req_of_num,
		struct ast_node *proof_expr,
		char ** ret_msg)
{
	if (MAX_INFER_STEPS <0)
		return -1;

	struct ast_node* req_expr=req_exprs->links[depth];

	if (INFER_DEBUG_FILE_PTR != NULL)
		fprintf(INFER_DEBUG_FILE_PTR, "INFER STEP: 0\n");

	*ret_msg = malloc(MAX_INFER_RET_MSG_LEN);

	/* seach if can be found in previous steps */
	for (int i=0; i<rich_exprs_num; i++) {
		if (INFER_DEBUG_FILE_PTR != NULL && i==3) {
			fprintf(INFER_DEBUG_FILE_PTR, "considering %d-th req and <%s>, same=%d, check=%d\n",
					depth, rich_exprs[i].name,
					structure_same_expr(req_expr, rich_exprs[i].pointer, 0),
					check(depth, max_depth, labels_pointer,
						req_exprs, req_of_num, rich_exprs[i].pointer, proof_expr));
			bp();
			structure_same_expr(req_expr, rich_exprs[i].pointer, 0);
			check(depth, max_depth, labels_pointer,
				req_exprs, req_of_num, rich_exprs[i].pointer, proof_expr);
		}
		if (structure_same_expr(req_expr, rich_exprs[i].pointer, 0)
				&& check(depth, max_depth, labels_pointer,
					req_exprs, req_of_num, rich_exprs[i].pointer, proof_expr)) {
			sprintf(*ret_msg, "Your missing expression is the expression with label <%s>\n", rich_exprs[i].name);
			return 0;
		}
	}

	if (MAX_INFER_STEPS == 0)
		return -1;

	if (INFER_DEBUG_FILE_PTR != NULL)
		fprintf(INFER_DEBUG_FILE_PTR, "INFER_STEP: 1\n");

	char * flag = malloc(rich_exprs_num);
	int max_num_req = 0;
	for (int i=0; i<theorem_total; i++)
		if (max_num_req < table_theorem[i].node_require->links[1]->num_links)
			max_num_req = table_theorem[i].node_require->links[1]->num_links;
	struct ast_node ** reqs = malloc(sizeof(void *) * max_num_req);

	/* search through theorems */
	for (int i=0, j, k; i<theorem_total - 1; i++)
		if (table_theorem[i].node_conclude->num_links == 1
				&& structure_same_expr(table_theorem[i].node_conclude->links[0], req_expr, 1)
				) {
			struct theorem_node * th = &table_theorem[i];
			int num_req_th = th->node_require->num_links;
			struct ast_node *re = NULL;
			memset(flag, 0, rich_exprs_num);

			/*
			 * find legal combination of theorem `th`'s requirement,
			 * and save the newly constructed expression in re
			 */
			int res = search_req_fit_previous(0, num_req_th, th, &re, flag, reqs,
					depth, max_depth, labels_pointer,
					req_exprs, req_of_num, proof_expr);
			if (res) {
				sprintf(*ret_msg, "match theorem %s with expression(s)", th->name);
				for (int k=0; k<rich_exprs_num; k++)
					if (flag[k]){
						strcat(*ret_msg, " <");
						strcat(*ret_msg, rich_exprs[k].name);
						strcat(*ret_msg, ">");
					}
				strcat(*ret_msg, "\n");
				free(flag);
				return 1;
			}
		}

	assert(MAX_INFER_STEPS <= 1);

	free(flag);
	free(reqs);

	return -1;
}


int check_structure_symbol(
			struct ast_node *expr,
			struct ast_node *req,
			struct ast_node **syms,
			struct theorem_node *th)
{
	if (!expr || !req)
		return !expr && !req ? 1 : 0;

	if (!req->data) {
		int k;
		for (k = 0; k < th->node_require->links[0]->num_links
				&& strcmp(th->node_require->links[0]->links[k]->data,
					(char *)req->links[0]); k++);
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
				&& strcmp(th->node_require->links[0]->links[k]->data,
					(char *)conclusion->links[0]); k++);
		return syms[k];
	}

	struct ast_node *re;
	AST_NODE_MALLOC(re, nd_expr);
	LINKS_MALLOC(re->links, conclusion->num_links);
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
	struct ast_node *re = NULL;
	memset(syms, 0, sizeof(void *) * table_size);
	for (int i=0; i<num; i++) {
		struct ast_node *expr = reqs[i];
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
		char *flag, struct ast_node ** reqs,
		int _depth,
		int _max_depth,
		struct ast_node* _labels_pointer,
		struct ast_node* _req_exprs,
		int _req_of_num,
		struct ast_node *proof_expr)
{
	if (depth == max_depth) {
		*re = construct_according(th, reqs);
		if (!*re)
			return 0;
		int res = check(_depth, _max_depth, _labels_pointer,
				_req_exprs, _req_of_num, *re, proof_expr);
		free(*re);
		return res ? 1 : 0;
	}
	for (int i=0; i<rich_exprs_num; i++)
		if (!flag[i]) {
			flag[i] = 1;
			reqs[depth] = rich_exprs[i].pointer;
			if (search_req_fit_previous(depth+1, max_depth, th, re, flag, reqs,
						_depth, _max_depth, _labels_pointer, _req_exprs, _req_of_num,
						proof_expr))
				return 1;
			flag[i] = 0;
		}
	return 0;
}
#endif

