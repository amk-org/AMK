# Reconstruction
By *Shuyang Shi* @ Dec 2015
***

## Motivation

The previous implementation of the interpreter heavily depend on the written
    *modules/logics/proposition.mamk* file.
During runtime, it only import axioms (and theorems) and the types and operators
    are written statically into the interpreter.
This feature raise conflicts to my previous thoughts, and really really
    inconvenient to extend to other areas.

Therefore, my work this time is to rewrite as many codes as needed to **reconstruct** the
    interpreter so that it can **dynamically** import *types*, *operators*,
    as well as *axioms(theorems)* from the specified *.mamk* module files.

## Design

### TYPE

#### Declare a type

Previously define `union type_node` as follows:

```c
union type_node {
    char * type_name; /* each type have a char[] to store its name */
    struct {
        char * nest_type; /* "set" or "list" */
        union type_node * subtype; /* the nested type */
    } nest;
};
```

Use global counter and macro for naming:

```c
int cnt_types;
#define TYND(num) (ty_nd_ ##num)/* type node name with num */
```

Each time meet a type declaration, declare a variable of type `union type_node`:

```c
union type_node * TYND(cnt_types)
        = malloc(sizeof(union type_node));
TYND(cnt_types)->type_name = "statement";
/* ... */
cnt_types++;
```

#### Declare a variable

There are generally two kinds of variables:

1. variables of a **trace type**, meaning the variables record their path during the generation without certain values. Example: *statement*.
2. variables of a **value type**, meaning the variables record their specific value and abandon the path of generation. Example: *integer*.

```c
struct var_node {
    char * name; /* name (identifier) of the variable */
    union type_node * type; /* ptr to its type node union */
    void * data; /* ptr to value or generator(function) */
    void ** params; /* ptr to values if generator */
};
```

Use global counter and macro for naming:

```c
int cnt_vars;
#define VRND(num) (vr_nd_ ##num)/* variable node name with num */
```

So for example there is a `define p of statement` in the *.amk* file, the executed codes should be:

```c
struct var_node * VRND(cnt_vars)
        = malloc(sizeof(struct var_node));
VRND(cnt_vars)->name = "p";
VRND(cnt_vars)->type = find_type_by_name("statement");
VRND(cnt_vars)->data = NULL;
cnt_vars++;
```

### OPERATOR

Generally, operators are defined as functions.

```
-> (statement, statement) => statement
mult2 (integer) => integer : $1 + $1
```

is similar to funciton definitions of

```cpp
statement * ->(statement a, statement b) {
    return new statement(a, b);
}

int * mult2 (int a) {
    return a + a;
}
```

Use the above operators as helpers, `struct op_node` is developed as follows:

```c

struct op_tree {
    char isop; /* operator or params */
    union {
        struct op_node * op_node_ptr;
        int param_no; /* param number */
    }
    int num_links;
    struct op_tree ** links;
};

struct op_node {
    char * name;
    union type_node * ret_val;
    int num_params;
    union type_node ** params;

    struct op_tree * calc;
    void *** param_in_calc; /* void * pic[num_params][num_appear] */
};
```

Each time we meet something like `a->b`, a `struct op_node *` is defined within 'nd_expr'.


### Naming Convention

- type: identifier (letters, _, numbers with numbers cannot be placed first)
- variable: identifier
- operator: identifier with characters from ['+', '-', '*', '/', '|', '-', '=', '<', '>', '^', '~']



- '[', ']' are used in nested types and cannot be overrided.
- '-[', ']' are used in references and cannot be overrided.
- '(', ')' are used to regulate precedence and cannot be overrided.
