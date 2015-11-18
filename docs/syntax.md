# Documentation: Syntax
By ssy @ Nov 2015
***

## Data Union
The union for data passing during **yylex()** is defined as follows.
	
	/* union */
	%union {
	  char *str;
	  struct ast_node *ptr;
	};
	

## AST Node
### Struct Definition
**struct ast\_node** is defined as follows.

```c
/* node in AST */
struct ast_node {
	/* info of this node */
	enum node_types node_type;
	void * data;
	
	/* links */
	int num_links;
	struct ast_node ** links;
};
```


### Explanation for Node Types
For differnet node types, we define the member variables as the following table indicates.

| node_type | data| num_links | links
---|---|---|---|---
nd_program  |NULL|2|import\_part, proof\_part
nd\_import\_part  |NULL|n|import\_expr
nd\_proof\_part  |NULL|n|proof\_block
nd\_import\_expr  |(char *) str|0|NULL
nd\_rich\_exprs  |NULL|n|rich\_expr
nd\_exprs  |NULL|n|expr
nd\_proof\_block  |(char *) name | 3|proof\_require, proof\_conclude, proof\_body / NULL
nd\_rich\_expr  | (struct ast_node *) expr | 2 | theorem\_ref, label
nd\_ref\_body  | (char *) theorem\_name | 2 | ref\_pref, ref\_labels
nd\_ref\_labels  |NULL|n|identifier
nd\_expr | (enum operators) op (NULL if none) | k = 1 or 2| (ast_node *) expr / (char *) var
nd\_of\_expr | var | 1 | type
nd\_of\_exprs | NULL | n | of\_expr
nd\_proof\_req | NULL | 2 | of\_exprs, exprs
nd\_type | (char *) identifier / "set" / "list" | 0 or 1 | (sub-)type


## Operator Precedence and Associativity
	/* operator precedence and associativity */
	%right dget
	%right get
	%right dcontain
	%right contain
	%right vee
	%right wedge
	%nonassoc not
