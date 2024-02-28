

%{
    #include <stdio.h>
    #include <string.h>
    #include "parsercode.tab.h"
%}


delim       [ \t\n]
ws          {delim}+  
digit       [0-9]	
number      {digit}+(\.{digit}+)?([eE][+\-]?{digit}+)?

%%

{ws}        { ; }
{number}    {strcpy(yylval.num , yytext); return NUM;}

"+"       {return ADD;}
"-"       {return SUB;}
"*"       {return MUL;}
"/"       {return DIV;}

[-=()]       {return yytext[0];}

.           printf("Unexpected Character!\n");

%%

