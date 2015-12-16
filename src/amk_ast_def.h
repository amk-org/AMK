#ifndef amk_ast_def_h
#define amk_ast_def_h
/*** Function Definitions ***/

#define AST_RPT(fmt, ...)  do {														\
	fprintf(out, "%s<%d-%d>(%d): " fmt , node_type_names[root->node_type],		\
			root->location->first_line, root->location->last_line,					\
			root->num_links, ##__VA_ARGS__);										\
	fprintf(out, " CHILD [");														\
	for (int _=0; _<root->num_links; _++)											\
		if (visit_links)															\
			if (root->links[_])														\
				fprintf(out, "%s, ", node_type_names[root->links[_]->node_type]);	\
			else																	\
				fprintf(out, "NULL, ");												\
		else																		\
			fprintf(out, "%s, ", (char *) root->links[_]);							\
	fprintf(out, "]\n");															\
	fflush(out);																	\
} while(0)

void print_ast(struct ast_node * root, int depth, FILE * out) {
	if (!root)
		return;
	char visit_data = 0;
	char visit_links = 1;

	for (int i=0; i<depth; i++)
		fprintf(out, "\t");
	switch (root->node_type) {
		case nd_program:
			AST_RPT();
			break;

		case nd_import_part:
		case nd_proof_part:
		case nd_rich_exprs:
		case nd_of_exprs:
		case nd_exprs:
			AST_RPT();
			break;

		case nd_import_expr:
			AST_RPT("module '%s'", root->data);
			break;

		case nd_proof_block:
			AST_RPT("name '%s'", root->data);
			break;

		case nd_proof_block_dcl:
			AST_RPT("name '%s'", root->data);
			break;

		case nd_rich_expr:
			visit_data = 1;
			fprintf(out, "%s(%d): CHILD [", node_type_names[root->node_type],
					root->num_links);
			fprintf(out, "%s, %s]\n", node_type_names[root->links[0]->node_type],
					root->links[1] ? (char *)root->links[1] : "NULL");
			break;

		case nd_ref_body:
			visit_links = 0;
			fprintf(out, "%s(%d): use '%s' CHILD [", node_type_names[root->node_type],
					root->num_links, root->data);
			if (root->links[0])
				fprintf(out, "prefix '%s',", (char *)root->links[0]);
			if (root->links[1])
				fprintf(out, "%s ]", node_type_names[root->links[1]->node_type]);
			fprintf(out, "\n");
			break;

		case nd_ref_labels:
			visit_links = 0;
			AST_RPT();
			break;

		case nd_expr:
			if (!root->data) {
				visit_links = 0;
				AST_RPT("var '%s'", (char *)root->links[0]);
			}
			else
				AST_RPT("op '%s'", operator_names[(int)root->data]);
			break;

		case nd_of_expr:
			AST_RPT("var '%s'", root->data);
			break;

		case nd_proof_req:
			AST_RPT();
			break;

		case nd_type:
			AST_RPT("type '%s'", root->data);
			break;

		default:
			fprintf(out, "Unrecognizable node_type %d\n", root->node_type);
	}

	if (visit_data)
		print_ast(root->data, depth+1, out);
	if (root->node_type == nd_rich_expr)
		print_ast(root->links[0], depth+1, out);
	else if (root->node_type == nd_ref_body)
		print_ast(root->links[1], depth+1, out);
	else if (visit_links)
		for (int i=0; i<root->num_links; i++)
			print_ast(root->links[i], depth+1, out);
}

void free_ast_node(struct ast_node * node) {
	if (node->num_links > 0)
		free(node->links);
	free(node);
}

#define AST_NODE_MALLOC(p, nd_t); do {\
	(p) = (struct ast_node *)malloc(sizeof(struct ast_node));\
	(p)->node_type = (nd_t);\
} while(0)

struct ast_node *new_ast_node(enum node_types node_type, void *arg, void *arg2, void *arg3, int flno, int llno) {
	struct ast_node *re = NULL;
	switch (node_type) {

		/* the while program */
		/* arg - import_part, arg2 - proof_part */
		case nd_program:
			AST_NODE_MALLOC(re, node_type);
			re->data = NULL;
			re->num_links = 2;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg);
			re->links[1] = AST_NODE_PTR(arg2);
			break;

		/* an import expression */
		/* arg - string ptr (.mamk file) */
		case nd_import_expr:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 0;
			re->links = NULL;
			break;

		/* the import part of the prog */
		/* arg - import expr, arg2 - import part node */
		case nd_import_part:

		/* the proof part of the prog */
		/* arg - proof block, arg2 - proof part node */
		case nd_proof_part:

		/* of_exprs */
		/* arg - of_expr, arg2 - of_exprs */
		case nd_of_exprs:

		/* rich_exprs */
		/* arg - rich_expr, arg2 - rich_exprs */
		case nd_rich_exprs:

		/* ref_labels */
		/* arg - label, arg2 - ref_labels */
		case nd_ref_labels:

		/* exprs */
		/* arg - expr, arg2 - exprs */
		case nd_exprs:

			AST_NODE_MALLOC(re, node_type);
			re->data = NULL;
			if (!arg){
				re->num_links = 0;
				break;
			}
			re->num_links = arg2 ? AST_NODE_PTR(arg2)->num_links + 1 : 1;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg);
			if (arg2) {
				for (int i=0; i < AST_NODE_PTR(arg2)->num_links; i++)
					re->links[i+1] = AST_NODE_PTR(arg2)->links[i];
				free_ast_node(AST_NODE_PTR(arg2));
			}
			break;

		/* a proof block */
		/* arg - theorem_name, arg2 - ast_node ** */
		case nd_proof_block:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 3;
			re->links = (struct ast_node **)arg2;
			break;

		/* a proof block (only declaration) */
		/* arg - theorem_name, arg2 - ast_node ** */
		case nd_proof_block_dcl:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 2;
			re->links = (struct ast_node **)arg2;
			break;

		/* rich expr */
		/* arg - expr, arg2 - theorem_ref, arg3 - label */
		/* re->links: expr, theorem_ref, label */
		case nd_rich_expr:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 2;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg2);
			re->links[1] = AST_NODE_PTR(arg3);
			break;

		/* reference body */
		/* arg - ref_theo, arg2 - ref_pref, arg3 - ref_labels */
		case nd_ref_body:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 2;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg2);
			re->links[1] = AST_NODE_PTR(arg3);
			break;

		/* expr */
		/* arg - operator; arg2, arg3 - parameters */
		case nd_expr:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = (arg3 ? 2 : 1);
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg2);
			if (arg3)
				re->links[1] = AST_NODE_PTR(arg3);
			break;

		/* proof_req */
		/* arg - of_exprs, arg2 - exprs */
		case nd_proof_req:
			AST_NODE_MALLOC(re, node_type);
			re->data = NULL;
			re->num_links = 2;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg);
			re->links[1] = AST_NODE_PTR(arg2);
			break;

		/* of_expr */
		/* arg - var, arg2 - type */
		case nd_of_expr:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = 1;
			LINKS_MALLOC(re->links, re->num_links);
			re->links[0] = AST_NODE_PTR(arg2);
			break;

		/* type */
		/* arg - name or "set" "list", arg2 - subtype */
		case nd_type:
			AST_NODE_MALLOC(re, node_type);
			re->data = arg;
			re->num_links = (arg2 ? 1 : 0);
			if (arg2) {
				LINKS_MALLOC(re->links, re->num_links);
				re->links[0] = AST_NODE_PTR(arg2);
			}
			break;

		/* otherwise: error */
		default:
			yyerror(NULL, "Unknown node type");
	}
	if (re) {
		re->location = malloc(sizeof(struct YYLTYPE));
		re->location->first_line = flno - lineoff;
		re->location->last_line = llno - lineoff;
	}
	return re;
}

#endif
