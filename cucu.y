%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define YYSTYPE char*

	extern FILE* yyin;
	extern FILE* yyout;
	extern int LINE, CHAR;
	extern void yyerror(char* msg);
	extern int yylex();
%}

%token IDENTIFIER NUMBER TYPE IF WHILE ELSE RETURN RELATIONAL_OPERATOR COMMENT END

%%

LANGUAGE:	PROG END	{
	printf("********************\n");
	printf("   START   \n");
	printf("********************\n");
	printf("\n\n%s\n\n", $1);
	printf("********************\n");
	printf("   END    \n");
	printf("********************\n");
	return 1;
}
;

PROG:	ET			{$$ = malloc(strlen($1)+2); sprintf($$, "%s\n", $1); free($1);}
| 			PROG ET	{$$ = malloc(strlen($2) + strlen($1) +3); sprintf($$, "%s\n%s\n", $1, $2); free($2);}
;

ET:	VARIABLE_DECLARATION				{$$ = malloc(sizeof(char)*(strlen($1) + 4)); sprintf($$, "=> %s", $1); free($1);}
|			FUNCTION_DECLARATION	LINE_END	{$$ = malloc(sizeof(char)*100); sprintf($$, "=> newFunction(%s)", $1);}
|			DEFINITION						{$$ = $1;}
;

DEFINITION:	FUNCTION_DECLARATION STATEMENT	{$$ = malloc(sizeof(char)*500); sprintf($$, "=> functionDefinition\t(%s)\n\n    Body_Begin\n******************\n\n%s\n\n******************\n    Body_End", $1, $2);}
;

VARIABLE_DECLARATION:	TYPE DECLARATION_LIST LINE_END			{$$ = malloc(sizeof(char)*100); sprintf($$, "newVariables(Type: %s, Units: %s)", $1, $2); free($1); free($2);}
;

DECLARATION_LIST:	UNIT							{$$ = $1;}
|			DECLARATION_LIST ',' UNIT				{$$ = malloc(strlen($1) + strlen($3) + 3); sprintf($$, "%s, %s", $1, $3); free($3); free($1);}
;

UNIT:		IDENTIFIER								{$$ = $1;}
|			IDENTIFIER '=' ARITHMETIC_EXPRPRESSION				{$$ = malloc(strlen($1) + strlen($3) + 25); sprintf($$, "declareAndAssign(%s, %s)", $1, $3);}
;

FUNCTION_DECLARATION:	TYPE IDENTIFIER '(' ARGUMENT_LIST ')'	{$$ = malloc(sizeof(char)*100); sprintf($$, "returnType: %s funcName: %s funcArgs: %s", $1, $2, $4); free($1); free($2); free($4);}
|				TYPE IDENTIFIER '(' ')'				{$$ = malloc(sizeof(char)*100); sprintf($$, "returnType: %s funcName: %s", $1, $2); free($1); free($2);}
;

ARGUMENT_LIST:	TYPE IDENTIFIER					{$$ = malloc(sizeof(char)*200); sprintf($$, "%s", $2); free($1); free($2);}
|			ARGUMENT_LIST ',' TYPE IDENTIFIER	{$$ = $1; sprintf($$, "%s, %s", $1, $4); free($3); free($4);}
;

LINE_END:	';'
|			LINE_END ';'
;

STATEMENT:	ASSIGNMENT_STATEMENT		{$$ = $1;}
|		CALL_STATEMENT					{$$ = $1;}
|		RETURN_STATEMENT				{$$ = $1;}
|		CONDITIONAL_STATEMENT			{$$ = $1;}
|		LOOP_STATEMENT					{$$ = $1;}
|		BLOCK_STATEMENT					{$$ = $1;}
;

ASSIGNMENT_STATEMENT:	IDENTIFIER '=' ARITHMETIC_EXPRPRESSION LINE_END			{$$ = malloc(sizeof(char)*100); sprintf($$, "assign(LHS=%s,RHS=%s)", $1, $3); free($1); free($3);}
|			INDEX '=' ARITHMETIC_EXPRPRESSION LINE_END		{$$ = malloc(sizeof(char)*100); sprintf($$, "assign(LHS=%s,RHS=%s)", $1, $3); free($1); free($3);}
;

FUNCTION_CALL:	IDENTIFIER '(' PARAMETER_LIST ')'				{$$ = malloc(sizeof(char)*100); sprintf($$, "funcCall(name: %s, parameters: %s)", $1, $3); free($1); free($3);}
|			IDENTIFIER '('')'									{$$ = malloc(sizeof(char)*100); sprintf($$, "funcCall(name: %s, parameters: NONE)", $1); free($1);}
;

CALL_STATEMENT: FUNCTION_CALL LINE_END					{$$ = $1;}

PARAMETER_LIST: ARITHMETIC_EXPRPRESSION							{$$ = $1;}
|			PARAMETER_LIST ',' ARITHMETIC_EXPRPRESSION			{$$ = malloc(strlen($1) + strlen($3) + 3); sprintf($$, "%s, %s", $1, $3); free($1); free($3);}
;

RETURN_STATEMENT:	RETURN ARITHMETIC_EXPRPRESSION LINE_END			{$$ = malloc(sizeof(char)*100); sprintf($$, "return(%s)", $2);}
;

CONDITIONAL_STATEMENT:	IF '(' BOOL_EXPR ')' BLOCK_STATEMENT						{$$ = malloc(sizeof(char)*500); sprintf($$, "ifCondition(%s)\n    If_Begins\n*******************\n%s\n******************\n    If_End\n", $3, $5); free($3); free($5);}
|			IF '(' BOOL_EXPR ')' BLOCK_STATEMENT ELSE BLOCK_STATEMENT		{$$ = malloc(sizeof(char)*500); sprintf($$, "ifCondition(%s)\n    If_Begins\n*******************\n%s\n******************\n    If_End\n    Else_Begins\n*******************\n%s\n******************\n    Else_End\n", $3, $5, $7); free($3); free($5); free($7);}
;
LOOP_STATEMENT: WHILE '(' BOOL_EXPR ')' BLOCK_STATEMENT					{$$ = malloc(sizeof(char)*500); sprintf($$, "Loop Statements:\n%s\n", $5);}
;

BLOCK_STATEMENT: '{''}'												{$$ = malloc(sizeof(char)*strlen("Empty Block\n")); sprintf($$, "Empty Block\n");}
|			'{' STATEMENT_LIST '}'									{$$ = $2;}
;

STATEMENT_LIST:	STATEMENT							{$$ = malloc(sizeof(char)*500); sprintf($$, "%s", $1);}
|			VARIABLE_DECLARATION						{$$ = malloc(sizeof(char)*500); sprintf($$, "%s", $1);}
|			STATEMENT_LIST STATEMENT					{$$ = $1; sprintf($$, "%s\n%s", $1, $2);}
|			STATEMENT_LIST VARIABLE_DECLARATION				{$$ = $1; sprintf($$, "%s\n%s", $1, $2);}
;

ARITHMETIC_EXPRPRESSION: ADD_SUB						{$$ = malloc(sizeof(char)*100); sprintf($$, "%s", $1); free($1);}
| 			ARITHMETIC_EXPRPRESSION RELATIONAL_OPERATOR ADD_SUB			{$$ = malloc(strlen($1)+strlen($3)+7); sprintf($$, "relOp(%s,%s)", $1, $3); free($1); free($3);}

ADD_SUB:	FACTOR										{$$ = malloc(sizeof(char)*100); sprintf($$, "%s", $1); free($1);}
|			ADD_SUB '+' FACTOR			{$$ = malloc(strlen($1)+strlen($3)+7); sprintf($$, "add(%s,%s)", $1, $3); free($1); free($3);}
|			ADD_SUB '-' FACTOR			{$$ = malloc(strlen($1)+strlen($3)+7); sprintf($$, "sub(%s,%s)", $1, $3); free($1); free($3);}
;

FACTOR:	TERM								{$$ = malloc(sizeof(char)*100); sprintf($$, "%s", $1); free($1);}
|		FACTOR '*' TERM						{$$ = malloc(strlen($1)+strlen($3)+7); sprintf($$, "mul(%s,%s)", $1, $3); free($1); free($3);}
|		FACTOR '/' TERM						{$$ = malloc(strlen($1)+strlen($3)+7); sprintf($$, "div(%s,%s)", $1, $3); free($1); free($3);}
;

TERM:	IDENTIFIER							{$$ = $1;}
|		INT									{$$ = $1;}
|		FUNCTION_CALL 						{$$ = $1;}
|		INDEX								{$$ = $1;}
|		DECIMAL 							{$$ = $1;}
|		'(' ARITHMETIC_EXPRPRESSION ')'					{$$ = malloc(sizeof(char)*(strlen($2)+3)); sprintf($$, "(%s)", $2);}
;

INT:	NUMBER									{$$ = malloc(sizeof(char)*(strlen($1) + 6)); sprintf($$, "%s", $1); free($1);}
|		'-' NUMBER								{$$ = malloc(sizeof(char)*(strlen($1) + 7)); sprintf($$, "-%s", $2); free($2);}
;

INDEX:	IDENTIFIER '['ARITHMETIC_EXPRPRESSION']'					{$$ = malloc(strlen($1) + strlen($3) + 20); sprintf($$, "index(%s, pos=%s)", $1, $3); free($1); free($3);}

DECIMAL:	NUMBER '.' NUMBER 					{$$ = malloc(strlen($1)+strlen($3) + 2); sprintf($$, "%s.%s", $1, $3); free($1); free($3);}
;

BOOL_EXPR:	ARITHMETIC_EXPRPRESSION RELATIONAL_OPERATOR ARITHMETIC_EXPRPRESSION 		{$$ = malloc(sizeof(char)*(strlen($1) + strlen($2) + strlen($3) + 3)); sprintf($$, "%s %s %s", $1, $2, $3);}
;

%%

int main(int argc, char** argv){
	if(argc < 2){
		printf("Syntax is %s <filename>\n", argv[0]);
		return 0;
	}
	yyin = fopen(argv[1], "r");
	yyout = fopen("Lexer.txt", "w");
	stdout = fopen("Parser.txt", "w");
	yyparse();
}

void yyerror(char* msg){
	printf("Prog Syntax Incorrect\nError at line:char = %d:%d\tDid not expect: %s", LINE, CHAR, yylval);
	free(yylval);
}