/********************************************************
 * ex1.l 
 ********************************************************/
%{
#include "amk.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* macros for debugging */
#define DEBUG_FILE_PTR stderr
#define RPT(status)  do {							\
	if (DEBUG_FILE_PTR)										\
		fprintf(DEBUG_FILE_PTR, "Lexer  " #status "\n");					\
} while(0)

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
of {return of;}
define {return define;}
import {
		RPT(import);
	return import;}
theorem {	
	RPT(theorem);
	return theorem;}
axiom {return axiom;}
lemma {return lemma;}
require {RPT(require);
		return require;
		}
conclude {
	RPT(conclude);
	return conclude;}
proof {return proof;}
where	{return where;}
not {return not;}
wedge {return wedge;}
vee {return vee;}

[:]		{
	RPT(colon);

	return colon;
}

[,]	{
	return comma;
}
[a-z0-9A-Z_-~]*\.[a-z0-0A-Z_.-~]*		{
												yylval.str = malloc(strlen(yytext) + 1);
												strcpy(yylval.str,yytext); 
												return file_name;
										}

[a-zA-Z_][a-zA-Z0-9_]*		{
									yylval.str = malloc(strlen(yytext) + 1);
									strcpy(yylval.str,yytext);
									//printf("lexer found iden %s\n",yylval.str);
									return identifier;
							}


\|- {
	return get;
}
\|-\| {
	RPT(dget);
	return dget;
}

-> {
	return contain;
}
\<-\> {
	return dcontain;
}

\<[a-zA-Z0-9_]+\>		{
	RPT(label);
	yylval.str = malloc(strlen(yytext) + 1);
						strcpy(yylval.str,yytext + 1);
						return label;
				}

\[		{ 
		return left_bracket;
	}

-\[		{ 
	RPT(left_ref);
	left++;
	return left_ref;
}

\]		{if(left){
			left--;
			return right_ref;
			}			
			else return right_bracket;
		}

\(		{return left_parren;}

\)		{return right_parren;}

[\n]+		{	last_tab = cur_tab; 
			cur_tab = 0;
			//printf("\nnext line : line no. %d\n", yylineno);
			RPT(new_line);
			return new_line;
		}

[ ]+	{
			//printf("waste space\n");
		}	

[\s\t]*\n	
{
	RPT(blankline);
}

[\t][\t]		{	cur_tab++;
					unput('\t');
		}

[\t]		{
			/*printf("catch tab now!\n");
			cur_tab++;
			if(cur_tab > last_tab){
				printf("indent\n");
				//return require;
			}
			if(cur_tab < last_tab){
				printf("dedent\n");
			//	return dedent;
			}
			*/

			if(tmp_tab == 0)
			{
				RPT(first_tab_try);
				cur_tab++;
				if(cur_tab != last_tab){
					tmp_tab = 1;
					unput('\t');
				}
			}
			else
			{
				if(cur_tab < last_tab)
				{
					//printf("cur %d  last %d \n", cur_tab, last_tab);
					last_tab --;
					if(cur_tab != last_tab){
						RPT(tab_dedent_twice);	
						unput('\t');
					}
					else
						tmp_tab = 0;
					printf("dedent\n");
					return dedent;
				}
				if(cur_tab > last_tab){
					//printf("cur %d last %d \n", cur_tab , last_tab);
					last_tab ++;
					if(cur_tab != last_tab){
						//printf("indent\n");
						unput('\t');
					}
					else
						tmp_tab = 0;
					printf("indent\n");
					return indent;
				}
			}	
		}		

[\s\t]*#[^\n]	{}

<<EOF>> {
	printf("tab num : %d\n", last_tab);
	if(last_tab != 0){
		last_tab --;
		printf("dedent\n");
		return dedent;
	}
	
	yyterminate();
	return dedent;
}
	
%%

int yywrap() { return 1; }

