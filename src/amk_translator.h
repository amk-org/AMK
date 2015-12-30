#ifndef amk_translator_h
#define amk_translator_h

#define MAX_NUM_THEOREM 100
#define MAX_NUM_PART_OF_EXPR 100
#define MAX_REQ_STATE 100
#define MAX_NUM_RICH_EXPR 100

#define SUCCESS 0
#define ERROR 1
#define WARNING 2

void print_message(int type,const char* message,int first_line,int last_line)
{
	switch (type)
	{
		case SUCCESS:
			printf("[correct %d:%d] %s\n",first_line,last_line,message);
			break;
		case ERROR:
			printf("[error %d:%d] %s\n",first_line,last_line,message);
			break;
		default:
			printf("[warning %d:%d] %s\n",first_line,last_line,message);
			break;
	}
}

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

int program_success=1;

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

int find_rich_expr_by_name(char* s)
{
	for (int i=0;i<rich_exprs_num;i++)
		if (rich_exprs[i].name && strcmp(s,rich_exprs[i].name)==0)
			return i;
	return -1;
}

int next_possible_comb(int n,struct expr_hash_node* expr_hash)
{
	int i,j;
	for(i=n-1;i>1 && expr_hash[i].index<expr_hash[i-1].index;i--);
	if (i==1) return 0;
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
	if (p1->data==p2->data)
	{
		for (int i=0;i<p1->num_links;i++)
		{
			int t=search_diff_exprs(p1->links[i],p2->links[i],req_num);
			if (t==0) return 0;
		}
		return 1;
	}
	return 0;
}

#include "amk_infer.h"

/*
	depth: current depth
	max_depth: limitation of the depth, in other words, the total number of invoking labels in a rich_expr
	labels_pointer: in order to get labels
	req_exprs: requirments of the theorem
	req_of_num: the number of variables that need to be identify
*/
int check_require(int depth, int max_depth, struct ast_node* labels_pointer,
		struct ast_node* req_exprs, int req_of_num, int is_auto,
		struct ast_node* missing_expr, struct ast_node *proof_expr)
{
	if (depth>=max_depth) return 1;
	if (strcmp("x",(char*)labels_pointer->links[depth])==0 && is_auto==0)
	{
		char * ret_msg;
		int d = infer(depth, max_depth, labels_pointer, req_exprs, req_of_num, proof_expr, &ret_msg);
		if (d == -1) {
			print_message(ERROR, "cannot infer the <x> expression",
					labels_pointer->location->first_line,
					labels_pointer->location->last_line);
			free(ret_msg);
			return 0;
		}
		else {
			char msg[512];
			sprintf(msg, "infer exactly %d step(s) to get <x>: %s", d, ret_msg);
			print_message(WARNING, msg,
					labels_pointer->location->first_line,
					labels_pointer->location->last_line);
			free(ret_msg);
			return 1;
		}
	}

	int id=find_rich_expr_by_name((char*)labels_pointer->links[depth]);

	if (id==-1 && is_auto==0)
	{
		print_message(ERROR,"cannot find proper label(s) by name",labels_pointer->location->first_line,labels_pointer->location->last_line);
		return 0;
	}

	struct ast_node* pointer;
	if (is_auto==0)
		pointer=rich_exprs[id].pointer;
	else
		pointer=missing_expr;
	struct ast_node* req_expr=req_exprs->links[depth];

//	fprintf(stderr, "xcheck %x\n", rich_exprs);

	//printf("string:%s id:%d \n",(char*)labels_pointer->links[depth],id);

	struct expr_hash_node expr_hash[MAX_NUM_PART_OF_EXPR];

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
			if (!pointer)
				return 0;
		}
		expr_hash[sub_expr_num].expr=pointer;
		sub_expr_num++;
	}
	//printf("sub_expr_num %d\n",sub_expr_num);

	/* initalize the combination */
	for (int i=0;i<sub_expr_num;i++)
		expr_hash[i].index=i;

	int success;
	do
	{
		success=1;

		struct ast_node* reqs_back[req_of_num];
		for (int i=0;i<req_of_num;i++)
			reqs_back[i]=reqs[i].pointer;

		/*printf("   sub debug : sub_expr_hash \n");
		for (int i=0;i<sub_expr_num;i++)
			printf("    %d ",expr_hash[i].index);
		printf("\n");*/

		struct ast_node* sub_exprs[sub_expr_num];
		for (int i=0;i<sub_expr_num;i++)
			sub_exprs[expr_hash[i].index]=expr_hash[i].expr;

		int index=0;

		/* check the requirement */
		pointer=req_expr;
		if ((enum operators)pointer->data==op_get)
		{
			int res=search_diff_exprs(pointer->links[1],sub_exprs[index++],req_of_num);
			//printf("result %d\n",res);
			if (!res) success=0;

			pointer=pointer->links[0];
			while ((enum operators)pointer->data==op_comma)
			{
				//printf("=== \n");
				res=search_diff_exprs(pointer->links[0],sub_exprs[index],req_of_num);
				//printf(" %d %d\n",(int)pointer->links[0]->data,(int)sub_exprs[index]->data);
				index++;
				//printf("result %d\n",res);
				if (!res) success=0;
				if (!success) break;
				pointer=pointer->links[1];
			}

			res=search_diff_exprs(pointer,sub_exprs[index++],req_of_num);
			//printf("result %d\n",res);
			if (!res) success=0;
		}

		if (success)
		{
			/*printf(" %d sub debug  : sub_expr_hash \n",depth);
			for (int i=0;i<sub_expr_num;i++)
				printf("    %d ",expr_hash[i].index);
			printf("\n");*/

			success=check_require(depth+1,max_depth,labels_pointer,req_exprs,req_of_num,0,NULL, proof_expr);
			//break;
		}

		for (int i=0;i<req_of_num;i++)
			reqs[i].pointer=reqs_back[i];

		//printf("final result %d\n",success);
		if (success) break;
	}
	while (next_possible_comb(sub_expr_num,expr_hash));
	return success;
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

			char* type=((char*)node->data)+strlen((char*)node->data)+1;
			//printf("theorem: %s\n",(char*)type);
			table_theorem[theorem_total].type=0;
			table_theorem[theorem_total].node_require=node->links[0];
			table_theorem[theorem_total].node_conclude=node->links[1];
			theorem_total++;

			if (strcmp(type,"a")!=0)
			{
				if (node->links[2]!=NULL)
					translate(node->links[2]);
				else
				{
					print_message(ERROR,"lack proof part",node->location->first_line,node->location->last_line);
					program_success=0;
				}
			}

			break;
		case nd_rich_exprs:

			rich_exprs_num=0;

			for (int i=0;i<node->num_links;i++)
			{
				translate(node->links[i]);

				rich_exprs[rich_exprs_num].name=(char*)node->links[i]->links[1];
				rich_exprs[rich_exprs_num].pointer=node->links[i]->data;
				rich_exprs_num++;
				//printf(" + %s\n",(char*)node->links[i]->links[1]);
			}

			/* veriry the conclusion */
			struct ast_node* con_expr=table_theorem[theorem_total-1].node_conclude;
			con_expr=con_expr->links[0];
			//printf("%d\n",(int)con_expr->data);

			struct ast_node* last_expr=node->links[node->num_links-1]->data;
			//printf("%d\n",(int)last_expr->data);

			int res=search_same_exprs(con_expr,last_expr);
			if (res)
				print_message(SUCCESS,"last line matches its conclusion",node->location->first_line,node->location->last_line);
			else
			{
				print_message(ERROR,"last line does not match its conclusion",node->location->first_line,node->location->last_line);
				program_success=0;
			}

			break;
		case nd_rich_expr:
			/* deal with each line in the proof body */

			/* find theorem by name */
			id=find_theorem_by_name(node->links[0]->data);
			if (id==-1)
			{
				print_message(ERROR,"cannot find proper theorem by name",node->location->first_line,node->location->last_line);
				program_success=0;
				break;
			}

			struct ast_node* req=table_theorem[id].node_require;
			struct ast_node* con=table_theorem[id].node_conclude;
			struct ast_node* pointer;

			/* deal with of_exprs in requirement of theorem */
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

			/* deal with sub_expr in requirement of theorem */
			pointer=node->data;
			struct ast_node* proof_expr=pointer;
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

			/* initalize the combination */
			for (int i=0;i<sub_expr_num;i++)
				expr_hash[i].index=i;

			int labels_num=0;
			struct ast_node* labels_pointer=node->links[0]->links[1];
			if (labels_pointer!=NULL)
				labels_num=labels_pointer->num_links;

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
				if (!success) continue;
				if (!labels_num) break;

				/*printf(" debug : sub_expr_hash \n");
				for (int i=0;i<sub_expr_num;i++)
					printf("%d ",expr_hash[i].index);
				printf("\n");*/

				//printf("lable num %d\n",labels_num);

				success=check_require(0,labels_num,labels_pointer,req->links[1],req_num,0,NULL, node->data);

				if (success) break;
			}
			while (next_possible_comb(sub_expr_num,expr_hash));

			if (success)
				print_message(SUCCESS,"match conclusion part and requirement part",node->location->first_line,node->location->last_line);
			else
			{
				print_message(ERROR,"cannot match conclusion part",node->location->first_line,node->location->last_line);
				program_success=0;
			}
			break;
		case nd_ref_body:
			break;
		case nd_expr:
			break;
		default:
			break;
	}
}


#endif
