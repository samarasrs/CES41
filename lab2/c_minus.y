
/****************************************************/
/* File: c_minus.y                                  */
/* BNF Grammar for C-                               */
/* Compiler Construction: Projeto 1 CES-41          */
/****************************************************/


%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static int savedNum;
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */
static int yylex(void);
int yyerror(char *s);

%}

%token IF ELSE INT VOID WHILE RETURN
%token ID NUM 
%token PLUS MINUS TIMES OVER LEQ LT GEQ GT EQ NEQ ASSIGN SEMI COMMA LPAREN RPAREN LBRACKETS RBRACKETS LBRACES RBRACES
%token ERROR 

%% /* Grammar for C_MINUS */

program     : decl_list
                 { savedTree = $1;} 
            ;
decl_list   : decl_list decl
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $2;
                     $$ = $1; }
                     else $$ = $2;
                 }
            | decl  { $$ = $1; }
            ;
decl        : var_decl { $$ = $1; }
            | func_decl { $$ = $1; }
            | error  { $$ = NULL; }
            ;
id          : ID
              { 
                savedName = copyString(tokenString);
                savedLineNo = lineno; 
              }
            ;
num         : NUM
                {
                  savedNum = atoi(tokenString);
                  savedLineNo = lineno; 
                }
            ;
tipo_espe   : INT
              {
                $$ = newdeclNode(IntK);
              }
            | VOID
              {
                $$ = newdeclNode(VoidK);
              }
var_decl    : tipo_espe  id 
                { $$ = $1;
                  $$->child[0] = newExpNode(IdK);
                  $$->child[0]->attr.name = savedName;
                } SEMI
            | tipo_espe  id 
                  {
                    $$ = $1;
                    $$->child[0] = newExpNode(IdK);
                    $$->child[0]->attr.name = savedName;
                  }
                  l_brackets  num
                  {
                    $$ = $3;
                    $$->child[0]->child[0] = $4;
                    $$->child[0]->child[1] = newExpNode(NumK);
                    $$->child[0]->child[1]->attr.val = savedNum;

                  } r_brackets 
                  { 
                    $$ = $3;
                    $$->child[0]->child[2] = $7;
                  } SEMI
            ;
func_decl   : tipo_espe  id
                {
                  $$ = $1;
                  $$->child[0] = newExpNode(IdK);
                  $$->child[0]->attr.name = savedName;
                } 
                LPAREN params RPAREN comp_decl
                { 
                  $$ = $3;
                  $$->child[0]->child[0] = $5;
                  $$->child[0]->child[1] = $7;
                }
            ;
params      : params_list { $$ = $1; }
            | VOID  {$$ = NULL;}
            ;
params_list : params_list COMMA param
                 { YYSTYPE t = $1;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $3;
                     $$ = $1; }
                    else $$ = $3;
                 }
            | param  { $$ = $1; }
            ;
param       : tipo_espe  id 
                {
                  $$ = $1;
                  $$->child[0] = newExpNode(IdK);
                  $$->child[0]->attr.name = savedName;
                }
            | tipo_espe  id  
                {
                  $$ = $1;
                  $$->child[0] = newExpNode(IdK);
                  $$->child[0]->attr.name = savedName;
                } 
                l_brackets r_brackets 
                { 
                  $$ = $3;
                  $$->child[0]->child[0] = $4;
                  $$->child[0]->child[1] = $5;
                }
            ;
comp_decl   : LBRACES l_decl stat_list RBRACES
                {  YYSTYPE t = $2;
                   if (t != NULL)
                   { while (t->sibling != NULL)
                        t = t->sibling;
                     t->sibling = $3;
                     $$ = $2; }
                    else $$ = $3;
                }
            ;
l_decl      : l_decl var_decl
                { YYSTYPE t = $1;
                  if (t != NULL)
                  { while (t->sibling != NULL)
                      t = t->sibling;
                    t->sibling = $2;
                    $$ = $1; }
                  else $$ = $2;
                }
            | {$$ = NULL;}
            ;
stat_list   : stat_list stat
                { YYSTYPE t = $1;
                  if (t != NULL)
                  { while (t->sibling != NULL)
                      t = t->sibling;
                    t->sibling = $2;
                    $$ = $1; }
                  else $$ = $2;
                }
            | {$$ = NULL;}
            ;
stat        : exp_decl { $$ = $1; }
            | comp_decl { $$ = $1; }
            | if_decl { $$ = $1; }
            | while_decl { $$ = $1; }
            | return_decl { $$ = $1; }
            ;
exp_decl    : exp SEMI
                {$$ = $1;}
            | SEMI {$$ = NULL;}
if_decl     : IF LPAREN exp RPAREN stat
                 { $$ = newdeclNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 }
            | IF LPAREN exp RPAREN stat ELSE stat
                 { $$ = newdeclNode(IfK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                   $$->child[2] = $7;
                 }
            ;
while_decl : WHILE LPAREN exp RPAREN stat
                 { $$ = newdeclNode(WhileK);
                   $$->child[0] = $3;
                   $$->child[1] = $5;
                 }
            ;
return_decl : RETURN SEMI
                { $$ = newdeclNode(ReturnK);}
            | RETURN exp SEMI
                { $$ = newdeclNode(ReturnK);
                  $$->child[0] = $2;}
            ;
exp         : var ASSIGN exp
                { $$ = newExpNode(OpK);
                  $$->attr.op = ASSIGN;
                  $$->child[0] = $1;
                  $$->child[1] = $3;  
                }
            | simples_exp {$$ = $1;}
            ;
var         :  id 
                { 
                  $$ = newExpNode(IdK);
                  $$->attr.name = savedName;
                }
            |  id 
                {
                  $$ = newExpNode(IdK);
                  $$->attr.name = savedName;
                }
                l_brackets exp r_brackets
                { 
                  $$ = $2;
                  $$->child[0] = $3;
                  $$->child[1] = $4;
                  $$->child[2] = $5;
                }
            ;
simples_exp : soma_exp LEQ soma_exp
                {
                    $$ = newExpNode(OpK);
                    $$->attr.op = LEQ;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | soma_exp LT soma_exp
                {
                    $$ = newExpNode(OpK);
                    $$->attr.op = LT;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | soma_exp GT soma_exp
                {
                    $$ = newExpNode(OpK);
                    $$->attr.op = GT;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | soma_exp GEQ soma_exp 
                {
                    $$ = newExpNode(OpK);
                    $$->attr.op = GEQ;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | soma_exp EQ soma_exp
                {
                    $$ = newExpNode(OpK);
                    $$->attr.op = EQ;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | soma_exp NEQ soma_exp
                {
                    $$ = newExpNode(OpK);
                    $$->attr.op = NEQ;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | soma_exp { $$ = $1;}
            ;
soma_exp    : soma_exp PLUS termo
                { $$ = newExpNode(OpK);
                    $$->attr.op = PLUS;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | soma_exp MINUS termo
                { $$ = newExpNode(OpK);
                    $$->attr.op = MINUS;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | termo { $$ = $1; }
            ;
termo       : termo TIMES fator
                { $$ = newExpNode(OpK);
                    $$->attr.op = TIMES;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | termo OVER fator
                { $$ = newExpNode(OpK);
                    $$->attr.op = OVER;
                    $$->child[0] = $1;
                    $$->child[1] = $3;

                }
            | fator { $$ = $1; }
            ;
fator       : LPAREN exp RPAREN
                { $$ = $2;}
            | var { $$ = $1;}
            | ativacao { $$ = $1;}
            |  num 
                { $$ = newExpNode(NumK);
                  $$->attr.val = savedNum;
                }
            | error { $$ = NULL;}
            ;
ativacao    :  id 
                { 
                  $$ = newExpNode(IdK);
                  $$->attr.name = savedName; 
                } 
                LPAREN args RPAREN
                { 
                  $$ = $2;
                  $$->child[0] = $4;
                }
            ;
args        : arg_list { $$ = $1;}
            | {$$ = NULL;}
            ;
arg_list    : arg_list COMMA exp
                { YYSTYPE t = $1;
                  if (t != NULL)
                  { while (t->sibling != NULL)
                      t = t->sibling;
                    t->sibling = $3;
                    $$ = $1; }
                  else $$ = $3;
                }
            | exp{ $$ = $1;}
            ;
l_brackets : LBRACKETS 
                { $$ = newExpNode(BracketsK);
                  $$->attr.op = LBRACKETS;
                }
            ;
r_brackets : RBRACKETS 
                { $$ = newExpNode(BracketsK);
                  $$->attr.op = RBRACKETS;
                }
            ;


%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}

