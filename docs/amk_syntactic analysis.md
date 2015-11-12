#	AMK 语法分析
Drafted by *zhq* @ Oct, 2015
***

注意：下版本仅是一个草稿，并未进行任何验证！

存在未解决的问题:

- 如何确定Tab的长度问题？解决方案：全部把tab与空格删掉后处理。
- 注释未处理 解决方案：在语法分析前把注释全部删掉

其中TYPE与OPERATOR并未处理，其中TYPE在之后的实现中可以认为是类型，OPERATOR可以认为是函数。将来版本的语法分析应该按照定义类型与定义函数的方式来解析TYPE与OPERATOR。

以下为Yacc源程序的部分代码，用于分析AMK语法(目前还没有验证正确性)。

	%%
	line : theorem "\n"
	     | "\n"
	     ;
	theorem : "theorem " theorem_name ":\n\t" theorembody
			| "lemma " theorem_name ":\n\t" theorembody
			| "axiom " theorem_name ":\n\t" theorembody
	        ;
	theorem_name : identifier
	             ;
	theorembody : require "\n\t" conclude "\n\t" proof "\n"
	            ;
	require : "require:\n" declarations "\n"
	        ;
	declarations : declaration declarations
	             | /* empty */
	             ;
	declaration : identifier " of statement\n"
	            | identifier " of list[statement]\n"
	            | identifier "\n"  /* 默认为statement类型 */
	            ;
	conclude : "conclude: " express_1 "\n"
	         | "conclude: " express_1 "\nwhere\n" assignments
	         ;
	proof : "proof:\n" reasonings
	      ;
	expresses : express_1 ", " expresses
	          | express_1
	          ;
	express_1 : express_1 "wedge" express_2
	          | express_2
	          ;
	express_2 : express_2 "vee" express_3
	          | express_3	
              ;
	express_3 : "not" express3
	          | express_4
	          ;
	express_4 : express_4 "->" express_5
	          | express_5
	          ;
	express_5 : express_5 "|-" express_6
	          | express_6	
	          ;
	express_6 : "(" express_1 ")"
	          | identifier
	          ;
	assignment : "state " identifier " = " express_1
	           ;
	assignments : assginment "\n" assignments
			    | /* empty */
	            ;
	reasonings : reasoning "\n" reasonings
	           | /* empty */
	           ;
	reasoning : express_1 reasoning_body_1
	reasoning_body_1 : [theorem_label] reasoning_body_2 
	                 | reasoning_body_2
	                 ;
	theorem_label : "theorem " identifier ":" reasoning_labels
	              | "lemma " identifier ":" reasoning_labels
	              | "axiom " identifier ":" reasoning_labels
	              ;
	reasoning_labels : reasoning_label "," reasoning_labels
	                 | /* empty */
	                 ;
	reasoning_label : identifier
	                ;
	reasoning_body_2 : <reasoning_label>
                     | /* empty */
	%%