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
last_tab = 0;
cur_tab = 0;
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
	
[a-z0-9A-Z_-~]*\.[a-z0-0A-Z_.-~]		{
												yylval.str = malloc(strlen(yytext));
												strcpy(yylval.str,yytext); 
												return file_name;
										}

[a-zA-Z_][a-zA-Z0-9_]*		{
									yylval.str = malloc(strlen(yytext));
									strcpy(yylval.str,yytext);
									return idn;
							}


\|- |
\|-\| |
-> |
not |
vee |
wedge	{
		yylval.str = malloc(strlen(yytext));
		strcpy(yylval.str,yytext);
		return operator;
	}

,	{return comma;}

:	{return colon;}

\<[a-zA-Z0-9_]+\>		{		yylval.str = malloc(strlen(yytext));
						strcpy(yylval.str,yytext + 1);
						return label;
				}

\[		{return left_bracket;}

-\[		{left++;return left_ref;}

\]		{if(left){
			left--;
			return right_ref;
			}			
			else return right_bracket;
		}

\(		{return left_parren}

\)		{return right_parren}

\n		{	last_tab = cur_tab; 
			cur_tab = 0;
			return new_line;
		}

[ ]+	{}	

[\t]+\n		{}

\t\t		{	cur_tab++;
			yyless(1);
		}

\t		{	cur_tab ++;
			if(cur_tab > last_tab){
					yylval.num = cur_tab - last_tab;
					return right_tab;
				}
			if(cur_tab < last_tab){
					yylval.num = last_tab - cur_tab;
					return left_tab;
			}	
		}		

#[^\n]	{}
	
	
%%

main(argc, argv)
int argc;
char **argv;
{
  if(argc > 1) {
    if(!(yyin = fopen(argv[1], "r"))) {
      perror(argv[1]);
      return (1);
    }
  }

  yylex();
}
yywrap() { return 1; }

