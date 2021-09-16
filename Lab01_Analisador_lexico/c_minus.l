/****************************************************/
/* File: c_minus.l                                  */
/* Lex specification for C-                         */
/* Compiler Construction: Projeto 1 CES-41          */
/****************************************************/

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}
digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \n
whitespace  [ \t]+
%%

"if"            {return IF;}
"else"		{return ELSE;}
"int"		{return INT;}
"return"	{return RETURN;}
"void"		{return VOID;}
"while"	{return WHILE;}
"+"             {return PLUS;}
"-"             {return MINUS;}
"/*"		{ char c; int fim = 0;
                  do
                  { c = input();
                    if (c == EOF) break;
                    if (c == '\n') lineno++;
                    if (c == '*') fim++;
                    if (c == '/' && fim == 1) fim++;
                  } while (fim < 2);
                }
"*"             {return TIMES;}
"/"             {return OVER;}
"<="		{return LEQ;}
"<"             {return LT;}
">="		{return GEQ;}
">"             {return GT;}
"=="		{return EQ;}
"!="		{return NEQ;}
"="		{return ASSIGN;}
";"             {return SEMI;}
","             {return COMMA;}
"("             {return LPAREN;}
")"             {return RPAREN;}
"["             {return LBRACKETS;}
"]"             {return RBRACKETS;}
"{"             {return LBRACES;}
"}"             {return RBRACES;}
{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
.               {return ERROR;}
%%
TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t%d: ",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}
