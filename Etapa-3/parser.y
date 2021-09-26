%{
    // Grupo L
    // Guilherme de Oliveira (00278301)
    // Jean Pierre Comerlatto Darricarrere (00182408)

    #include <stdio.h>
    #include "lexical_structures.h"

    extern void *arvore;
    extern int yylineno;

    function_node_t DUMMY = { .label = "DUMMY"};

    int yylex(void);
    void yyerror (char const *s);
%}

%union {
    valor_lexico_t valor_lexico;
    function_node_t valor_node;
}

%expect 0

%start program

%token<valor_lexico> TK_PR_INT
%token<valor_lexico> TK_PR_FLOAT
%token<valor_lexico> TK_PR_BOOL
%token<valor_lexico> TK_PR_CHAR
%token<valor_lexico> TK_PR_STRING
%token<valor_lexico> TK_PR_IF
%token<valor_lexico> TK_PR_THEN
%token<valor_lexico> TK_PR_ELSE
%token<valor_lexico> TK_PR_WHILE
%token<valor_lexico> TK_PR_DO
%token<valor_lexico> TK_PR_INPUT
%token<valor_lexico> TK_PR_OUTPUT
%token<valor_lexico> TK_PR_RETURN
%token<valor_lexico> TK_PR_CONST
%token<valor_lexico> TK_PR_STATIC
%token<valor_lexico> TK_PR_FOREACH
%token<valor_lexico> TK_PR_FOR
%token<valor_lexico> TK_PR_SWITCH
%token<valor_lexico> TK_PR_CASE
%token<valor_lexico> TK_PR_BREAK
%token<valor_lexico> TK_PR_CONTINUE
%token<valor_lexico> TK_PR_CLASS
%token<valor_lexico> TK_PR_PRIVATE
%token<valor_lexico> TK_PR_PUBLIC
%token<valor_lexico> TK_PR_PROTECTED
%token<valor_lexico> TK_PR_END
%token<valor_lexico> TK_PR_DEFAULT
%token<valor_lexico> TK_OC_LE
%token<valor_lexico> TK_OC_GE
%token<valor_lexico> TK_OC_EQ
%token<valor_lexico> TK_OC_NE
%token<valor_lexico> TK_OC_AND
%token<valor_lexico> TK_OC_OR
%token<valor_lexico> TK_OC_SL
%token<valor_lexico> TK_OC_SR
%token<valor_lexico> TK_LIT_INT
%token<valor_lexico> TK_LIT_FLOAT
%token<valor_lexico> TK_LIT_FALSE
%token<valor_lexico> TK_LIT_TRUE
%token<valor_lexico> TK_LIT_CHAR
%token<valor_lexico> TK_LIT_STRING
%token<valor_lexico> TK_IDENTIFICADOR
%token<valor_lexico> TOKEN_ERRO

%type <valor_node> functionDef;
%type <valor_node> topLevelDefList;
%type <valor_node> program;

%%

optionalStatic:
    %empty
    | TK_PR_STATIC
    ;

type:
    TK_PR_INT
    | TK_PR_FLOAT
    | TK_PR_BOOL
    | TK_PR_CHAR
    | TK_PR_STRING
    ;

optionalArray:
    %empty
    | '[' TK_LIT_INT ']'
    ;

varOrVecName:
    TK_IDENTIFICADOR optionalArray
    ;

varOrVecNameList:
    varOrVecName
    | varOrVecNameList ',' varOrVecName
    ;

globalDef:
    optionalStatic type varOrVecNameList ';'
    ;

optionalConst:
    %empty
    | TK_PR_CONST
    ;

optionalParamList:
    %empty
    | paramList
    ;

paramList:
    param
    | paramList ',' param
    ;

param:
    optionalConst type TK_IDENTIFICADOR
    ;

functionDef:
    optionalStatic type TK_IDENTIFICADOR '(' optionalParamList ')' command_block {
        valor_lexico_t x = $3;
        function_node_t function = { .label = x.token_value.string, .next_function = NULL};
        $$ = function;
    }
    ;


command_block:
    '{' optionalSimpleCommandList '}'
    ;

optionalSimpleCommandList:
    %empty
    | simpleCommandList
    ;

simpleCommandList:
    simpleCommand
    | simpleCommandList simpleCommand
    ;

simpleCommand:
    command_block ';'
    | localDef ';'
    | varSet ';'
    | varShift ';'
    | conditional ';'
    | IO ';'
    | functionCall ';'
    | TK_PR_RETURN expression ';'
    | TK_PR_CONTINUE ';'
    | TK_PR_BREAK ';'
    ;


literal:
    TK_LIT_INT
    | TK_LIT_FLOAT
    | TK_LIT_FALSE
    | TK_LIT_TRUE
    | TK_LIT_CHAR
    | TK_LIT_STRING
    ;


localDef:
    optionalStatic optionalConst type localNameDefList
    ;

localNameDefList:
    localNameDef
    | localNameDefList ',' localNameDef
    ;

localNameDef:
    TK_IDENTIFICADOR
    | TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR
    | TK_IDENTIFICADOR TK_OC_LE literal
    ;


optionalArrayAccess:
    %empty
    | '[' expression ']'
    ;

varSet:
    TK_IDENTIFICADOR optionalArrayAccess '=' expression
    ;
    

varShift:
    TK_IDENTIFICADOR optionalArrayAccess shiftOperator expression
    ;

shiftOperator:
    TK_OC_SR
    | TK_OC_SL
    ;


functionCall:
    TK_IDENTIFICADOR '(' optionalExpressionList ')'
    ;


IO:
    TK_PR_INPUT TK_IDENTIFICADOR
    | TK_PR_OUTPUT TK_IDENTIFICADOR
    | TK_PR_OUTPUT literal
    ;


conditional:
    TK_PR_IF '(' expression ')' command_block
    | TK_PR_IF '(' expression ')' command_block TK_PR_ELSE command_block
    | TK_PR_FOR '(' varSet ':' expression ':' varSet ')' command_block
    | TK_PR_WHILE '(' expression ')' TK_PR_DO command_block
    ;

expression:
    optionalOperator expressionOperand
    | optionalOperator '(' expression ')'
    ;

optionalOperator:
    %empty
    | optionalOperator unaryOperator
    | expression binaryOperator
    | expression '?' expression ':'
    ;

expressionOperand: 
    TK_IDENTIFICADOR
    | TK_IDENTIFICADOR '[' expression ']'
    | literal
    | functionCall
    ;

unaryOperator:
    '&'
    | '!'
    | '+'
    | '-'
    | '?'
    | '*'
    | '#'
    ;

binaryOperator:
    TK_OC_LE
    | TK_OC_GE
    | TK_OC_EQ
    | TK_OC_NE
    | TK_OC_AND
    | TK_OC_OR
    | '<'
    | '>'
    | '+'
    | '-'
    | '*'
    | '/'
    | '%'
    | '|'
    | '&'
    | '^'
    ;

optionalExpressionList:
    %empty
    | expressionList
    ;

expressionList:
    expression
    | expressionList ',' expression
    ;


topLevelDefList:
    globalDef { $$ = DUMMY; }
    | functionDef {$$ = $1; }
    | topLevelDefList globalDef { $$ = DUMMY; }
    | topLevelDefList functionDef { $$ = DUMMY; }
    ;

program:
    %empty { $$ = DUMMY; }
    | topLevelDefList {
        function_node_t function = $1;
        if(strcmp(function.label, "DUMMY") != 0){
            printf("%i [label=\"%s\"];", &function, function.label);
        }
        $$ = $1;
    }
    ;

%%

void exporta(void *arvore) {
    ;
}

void libera(void *arvore) {
    ;
}

void yyerror(char const *s) {
    printf("%s na linha %d\n", s, yylineno);
}
