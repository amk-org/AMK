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
import |
theorem |
axiom |
lemma |
require |
conclude |
proof |
where	{strcpy(yylval.str,yytext);return keyword;}
	
[a-z0-9A-Z_-~]*\.[a-z0-0A-Z_.-~]		{strcpy(yylval.str,yytext); return file_name;}

[a-zA-Z_][a-zA-Z0-9_]*		{strcpy(yylval.str,yytext);return idn;}

[0-9]+						{yylval.num = atoi(yytext);return number;}


\|- |
\|-\| |
-> |
not |
vee |
wedge	{strcpy(yylval.str,yytext);return operator;}

,	{return comma;}

:	{return colon;}

\<[a-zA-Z0-9_]+\>		{	strcpy(yylval.str,yytext + 1);
							return label}

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

\t\t	{	cur_tab++;
			yyless(1);
		}

\t		{	cur_tab ++;
			if(cur_tab > last_tab)
				for(int i = 0;i < cur_tab - last_tab;i++){
					return right_tab;
				}
			if(cur_tab < last_tab)
				for(int i = 0;i < last_tab - cur_tab;i++){
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

yywrap() { return 1; }

