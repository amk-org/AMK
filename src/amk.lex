/********************************************************
 * ex1.l 
 ********************************************************/
%{
#include "amk.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option yylineno




%{
/*Key Word*/

int keyword = 0;
int left = 0;
int last_tab = 0;
int cur_tab = 0;
int tmp_tab = 0;

%}

%%
import {return import;}
theorem {return theorem;}
axiom {return axiom;}
lemma {return lemma;}
require {return require;}
conclude {return conclude;}
proof {return proof;}
where	{return where;}
not {return not;}
wedge {return wedge;}
vee {return vee;}

[:] {
}

[a-z0-9A-Z_-~]*\.[a-z0-0A-Z_.-~]*		{
												yylval.str = malloc(strlen(yytext) + 1);
												strcpy(yylval.str,yytext); 
												return file_name;
										}

[a-zA-Z_][a-zA-Z0-9_]*		{
									yylval.str = malloc(strlen(yytext) + 1);
									strcpy(yylval.str,yytext);
									return identifier;
							}


\|- {
	return get;
}
\|-\| {
	return dget;
}

-> {
	return contain;
}
\<-\> {
	return dcontain;
}

\<[a-zA-Z0-9_]+\>		{		yylval.str = malloc(strlen(yytext) + 1);
						strcpy(yylval.str,yytext + 1);
						return label;
				}

\[		{ 
		return left_bracket;
	}

-\[		{ 
	left++;return left_ref;
}

\]		{if(left){
			left--;
			return right_ref;
			}			
			else return right_bracket;
		}

\(		{return left_parren;}

\)		{return right_parren;}

\n		{	last_tab = cur_tab; 
			cur_tab = 0;
		//	return new_line;
		}

[ ]+	{}	

[\t]+\n		{}

\t\t		{	cur_tab++;
			yyless(1);
		}

[\t]		{
			printf("!!!!!!!!!!!!!!!!!!!!!\n");
			yyless(yyleng - 1);

			//return indent;
			/*return dedent;
			if(tmp_tab == 0)
			{
				printf("firstpart\n");
				cur_tab++;
				if(cur_tab != last_tab){
					tmp_tab = 1;
					yyless(1);
					printf("yoooo\n");
				}
			
			}
			else
			{
				printf("secondpart\n");
				if(cur_tab < last_tab)
				{
					printf("cur %d  last %d \n", cur_tab, last_tab);
					last_tab --;
					if(cur_tab != last_tab)
						yyless(1);
					else
						tmp_tab = 0;
					
					return dedent;
				}
				if(cur_tab > last_tab){
					printf("cur %d last %d \n", cur_tab , last_tab);
					last_tab ++;
					if(cur_tab != last_tab)
						yyless(1);
					else
						tmp_tab = 0;
					return indent;
				}
			}	*/
		}		

#[^\n]	{}

[*]{
	printf("yubbbbbbbbbbbbbb\n");
}
	
	
%%

int yywrap() { return 1; }

