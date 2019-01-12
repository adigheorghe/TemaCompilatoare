%{
	#include "y.tab.h"
	int lineNo = 1;
	int colNo = 1;
%}

%%
"PROGRAM"	{colNo+=7; return T_PROGRAM;}
"VAR"		{colNo+=3; return T_VAR;}
"BEGIN"		{colNo+=5; return T_BEGIN;}
"END"		{colNo+=3; return T_END;}
"INTEGER"       {colNo+=7; return T_INTEGER;}
":="		{colNo+=2; return '=';}
"+" 		{colNo+=1; return '+';}	
"-"		{colNo+=1; return '-';}
"*"		{colNo+=1; return '*';}
"DIV"		{colNo+=3; return T_DIV;}
"("		{colNo+=1; return '(';}
")"		{colNo+=1; return ')';}
"READ"		{colNo+=4; return T_READ;}
"WRITE"		{colNo+=5; return T_WRITE;}
"FOR"		{colNo+=3; return T_FOR;}
"DO"		{colNo+=2; return T_DO;}
"TO"		{colNo+=2; return T_TO;}
0|[1-9][0-9]*	{colNo+=strlen(yytext);
		yylval.val=atoi(yytext);
		yylloc.first_line=lineNo; yylloc.first_column=colNo;
		return T_INT;}
[a-zA-Z][a-zA-Z0-9_]* {colNo+=strlen(yytext);
		yylval.sir=new char[strlen(yytext)+1];
		yylloc.first_line=lineNo; yylloc.first_column=colNo;
		strcpy(yylval.sir,yytext);
		return T_ID;}
[ ]         	{}
"\n"		{colNo=1;lineNo+=1;}   
";"		{colNo+=1;return ';';}
","		{colNo+=1;return ',';}
":"		{colNo+=1;return ':';}
.		{printf("Lexical error: l:%d c:%d ", lineNo, colNo); colNo++;
		return T_ERROR;}

	   	
