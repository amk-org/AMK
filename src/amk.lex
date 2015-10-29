/********************************************************
 * ex1.l 
 ********************************************************/
%{
#include "amk.tab.hpp"
#include <cstdlib>
#include <iostream>
using namespace std;
%}

%option noyywrap
%option yylineno

%%

[0-9]+   { yylval.val = atoi(yytext); return NUM; }
[\+|\-]  { yylval.sym = yytext[0]; return OPA; }
[\*|/]   { yylval.sym = yytext[0]; return OPM; }
"("      { return LP; }
")"      { return RP; }
";"      { return STOP; }
<<EOF>>  { return 0; }
[ \t\n]+ { }
.        { fprintf(stderr, "Unrecognized token!\n"); exit(1); }
%%

