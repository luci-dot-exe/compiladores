%{
    #include <stdio.h>

    int yylex(void);
    void yyerror (char const *s);
%}

%start initialSymbol

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_PR_END
%token TK_PR_DEFAULT
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_LIT_ARRAY_SIZE
%token TK_IDENTIFICADOR
%token TOKEN_ERRO

%%

initialSymbol: globalVariableDeclaration | functionDeclaration ;

globalVariableDeclaration: staticVariableDeclaration ';' | nonStaticVariableDeclaration ';' ;
staticVariableDeclaration: TK_PR_STATIC variableType;
nonStaticVariableDeclaration: variableType;

variableType: charType | intType | floatType | boolType | stringType;
charType: TK_PR_CHAR identifiers;
intType: TK_PR_INT identifiers;
floatType: TK_PR_FLOAT identifiers;
boolType: TK_PR_BOOL identifiers;
stringType: TK_PR_STRING identifiers;

identifiers: singleIdentifier | listOfIdentifiers ;
singleIdentifier: valueOrArray ;
listOfIdentifiers: valueOrArray ',' identifiers ;

valueOrArray: value | array ;
value: TK_IDENTIFICADOR;
array: TK_IDENTIFICADOR '[' TK_LIT_ARRAY_SIZE ']';



functionDeclaration: staticFunctionDeclaration ';' | nonStaticFunctionDeclaration ';' ;
staticFunctionDeclaration: TK_PR_STATIC returnType;
nonStaticFunctionDeclaration: returnType;

returnType: charFnType | intFnType | floatFnType | boolFnType | stringFnType;
charFnType: TK_PR_CHAR functionIdentifier;
intFnType: TK_PR_INT functionIdentifier;
floatFnType: TK_PR_FLOAT functionIdentifier;
boolFnType: TK_PR_BOOL functionIdentifier;
stringFnType: TK_PR_STRING functionIdentifier;

functionIdentifier: TK_IDENTIFICADOR argumentsAndBody ;

argumentsAndBody: functionWithNoArguments | functionWithArguments;
functionWithNoArguments : '(' ')' '{' '}' ;
functionWithArguments : '(' arguments ')' '{' '}' ;

arguments: singleArgument | listOfArguments ;
singleArgument: argumentTypes TK_IDENTIFICADOR ;
listOfArguments: singleArgument ',' arguments ;

argumentTypes: constTypes | basicTypes;
constTypes: TK_PR_CONST basicTypes ;
basicTypes: TK_PR_CHAR | TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_STRING ;

%%

void yyerror(char const *s) {
    printf("%s\n", s);
}
