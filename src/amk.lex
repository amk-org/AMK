/********************************************************
 * ex1.l 
 ********************************************************/
%{
#include "amk.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* macros for debugging */
#define DEBUG_FILE_PTR NULL /* stderr */
#define RPTF(status, fmt, ...)  do {							\
	if (DEBUG_FILE_PTR)											\
		fprintf(DEBUG_FILE_PTR, "#\t[Lexer] " #status			\
			fmt "\n", ##__VA_ARGS__);	\
} while(0)
#define RPT(status)  do {										\
	if (DEBUG_FILE_PTR)											\
		fprintf(DEBUG_FILE_PTR, "#\t[Lexer] " #status "\n");	\
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
int fake_newline = 1;
/* handle locations */
int yycolumn = 1;

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;	\
	yylloc.first_column = yycolumn;										\
	yylloc.last_column = yycolumn + yyleng - 1;							\
	yycolumn += yyleng;													

%}

%%
of {fake_newline = 0; return of;}
set {fake_newline = 0;return set;}
list {fake_newline = 0;return list;}
define {fake_newline = 0;return define;}
import {
		fake_newline = 0;
		RPT(import);
	return import;}
theorem {
	fake_newline = 0;	
	//printf("cur %d last %d\n", cur_tab, last_tab);
	if(last_tab != 0 && left == 0){
		last_tab --;
		yyless(0);
		//printf("dedent in theorem \n ");
		return dedent;
	}
	RPT(theorem);
	return theorem;}
axiom {fake_newline = 0;return axiom;}
lemma {fake_newline = 0;return lemma;}
require {fake_newline = 0;RPT(require);
		return require;
		}
conclude {
	fake_newline = 0;
	RPT(conclude);
	return conclude;}
proof {
	fake_newline = 0;
	return proof;}
where	{fake_newline = 0;return where;}
not {fake_newline = 0;return not;}
wedge {fake_newline = 0;return wedge;}
vee {fake_newline = 0;return vee;}

[:]		{fake_newline = 0;
	RPT(colon);

	return colon;
}

[,]	{fake_newline = 0;
	return comma;
}
[a-z0-9A-Z_-~]*\.[a-z0-0A-Z_.-~]*		{fake_newline = 0;
												yylval.str = malloc(strlen(yytext) + 1);
												strcpy(yylval.str,yytext); 
												return file_name;
										}

[a-zA-Z_][a-zA-Z0-9_]*		{fake_newline = 0;
									yylval.str = malloc(strlen(yytext) + 1);
									strcpy(yylval.str,yytext);
									//printf("lexer found iden %s\n",yylval.str);
									return identifier;
							}


\|- {fake_newline = 0;
	return get;
}
\|-\| {fake_newline = 0;
	RPT(dget);
	return dget;
}

-> {fake_newline = 0;
	return contain;
}
\<-\> {fake_newline = 0;
	return dcontain;
}

\<[a-zA-Z0-9_]+\>		{fake_newline = 0;
	RPT(label);
	yylval.str = malloc(strlen(yytext));
						memcpy(yylval.str,yytext + 1, strlen(yytext) - 2);
						yylval.str[strlen(yytext) - 2] = 0;
						return label;
				}

\[		{ fake_newline = 0;
		return left_bracket;
	}

-\[		{ fake_newline = 0;
	RPT(left_ref);
	left++;
	return left_ref;
}

\]		{fake_newline = 0;if(left){fake_newline = 0;
			left--;
			return right_ref;
			}			
			else return right_bracket;
		}

\(		{fake_newline = 0;return left_paren;}

\)		{fake_newline = 0;return right_paren;}

([\s\t ]*(#[^\n]*)*[\n])+		{	last_tab = cur_tab; 
			cur_tab = 0;
			yycolumn = 1;
			//printf("\nnext line : line no. %d\n", yylineno);
			RPT(new_line);
			if(fake_newline == 0){
				fake_newline = 1;
				return new_line;
			}
		}

[ ]+	{fake_newline = 0;
			//printf("waste space\n");
		}	


[\t][\t]		{	fake_newline = 0;cur_tab++;
					unput('\t');
		}

[\t]		{fake_newline = 0;
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
					RPT(dedent);
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
					RPT(indent);
					return indent;
				}
			}	
		}		


<<EOF>> {
	RPTF(tab, "num : %d", last_tab);
	if(last_tab != 0){
		last_tab --;
		RPT(dedent);
		return dedent;
	}
	
	yyterminate();
	return dedent;
}
	
%%

int yywrap() { return 1; }

