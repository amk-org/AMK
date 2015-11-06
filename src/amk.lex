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
tmp_tab = 0;

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
not {
	return not;
}

vee {
	return vee;
}
wedge
	{
		return wedge;
	}

\<[a-zA-Z0-9_]+\>		{		yylval.str = malloc(strlen(yytext) + 1);
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

\t		{	
			if(tmp_tab == 0)
			{
				cur_tab++;
				if(cur_tab != last_tab){
					tmp_tab = 1;
					yyless(1);
				}
			
			}
			else
			{
				if(cur_tab < last_tab)
				{
					last_tab --;
					if(cur_tab != last_tab)
						yyless(1);
					else
						tmp_tab = 0;
					return dedent;
				}
				if(cur_tab > last_tab){
					last_tab ++;
					if(cur_tab != last_tab)
						yyless(1);
					else
						tmp_tab = 0;
					return indent;
				}
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

