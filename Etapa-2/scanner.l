%{
	// Turma L
	// Guilherme de Oliveira (00278301)
	// Jean Pierre Comerlatto Darricarrere (00182408)

	#include "parser.tab.h" 

	// Function prototype
	int get_ascii_value();

	// Variable definition
	int line_number = 1;
	int state_before_comment;
%}

pattern_line_comment "//".*

pattern_special_char [,;:()\[\]{}+\-|*/<>=!&%#^.$\?]

pattern_alphabetic [a-zA-Z_]
pattern_alphanumeric [a-zA-Z_0-9]
pattern_identifier {pattern_alphabetic}{pattern_alphanumeric}*

pattern_digit [0-9]
pattern_integer {pattern_digit}+
pattern_signed_int [+-]?{pattern_integer}
pattern_exponent [eE]{pattern_signed_int}
pattern_float {pattern_signed_int}\.{pattern_integer}{pattern_exponent}?

pattern_char '.'
pattern_string \"(\\.|[^"\n])*\"
/* " <-- This messes up the editor color coding */

%x MULTILINE_COMMENT
%x POTENTIAL_SUM

%%

<INITIAL,POTENTIAL_SUM>{pattern_line_comment} {
	/* Discards anything between // and \n */
};

<INITIAL,POTENTIAL_SUM>"/*" {
	state_before_comment = YY_START;
	BEGIN(MULTILINE_COMMENT);
}

"int" return TK_PR_INT;
"float" return TK_PR_FLOAT;
"bool" return TK_PR_BOOL;
"char" return TK_PR_CHAR;
"string" return TK_PR_STRING;
"if" return TK_PR_IF;
"then" return TK_PR_THEN;
"else" return TK_PR_ELSE;
"while" return TK_PR_WHILE;
"do" return TK_PR_DO;
"input" return TK_PR_INPUT;
"output" return TK_PR_OUTPUT;
"return" return TK_PR_RETURN;
"const" return TK_PR_CONST;
"static" return TK_PR_STATIC;
"foreach" return TK_PR_FOREACH;
"for" return TK_PR_FOR;
"switch" return TK_PR_SWITCH;
"case" return TK_PR_CASE;
"break" return TK_PR_BREAK;
"continue" return TK_PR_CONTINUE;
"class" return TK_PR_CLASS;
"private" return TK_PR_PRIVATE;
"public" return TK_PR_PUBLIC;
"protected" return TK_PR_PROTECTED;

"false" return TK_LIT_FALSE;
"true" return TK_LIT_TRUE;

"end" return TK_PR_END;
"default" return TK_PR_DEFAULT;

{pattern_special_char} {
	return get_ascii_value();
}

"<=" return TK_OC_LE;
">=" return TK_OC_GE;
"==" return TK_OC_EQ;
"!=" return TK_OC_NE;
"&&" return TK_OC_AND;
"||" return TK_OC_OR;
">>" return TK_OC_SL;
"<<" return TK_OC_SR;

{pattern_identifier} {
	BEGIN(POTENTIAL_SUM);
	return TK_IDENTIFICADOR;
}
{pattern_signed_int} {
	BEGIN(POTENTIAL_SUM);
	return TK_LIT_INT;
}
{pattern_float} {
	BEGIN(POTENTIAL_SUM);
	return TK_LIT_FLOAT;
}

<POTENTIAL_SUM>[+\-]/([ \t\n]*({pattern_signed_int}|{pattern_float})) {
	/**
	* * + or - followed by int or float and preceded by int, float or variable:
	* * unary or binary operators, not part of the next int or float
	* * ignores spaces, tabs and new-lines in-between
	**/
	BEGIN(INITIAL);
	return get_ascii_value();
}
<POTENTIAL_SUM>[^ \t\n] {
	/**
	* * If it didn't find something suitable to sum-up with, then re-scan and continue as normal.
	* * If it's a space, tab or new-line, then it will be processed by the line-counter and space-eater, as normal.
	**/
	BEGIN(INITIAL);
	yyless(0);
}

{pattern_char} return TK_LIT_CHAR;
{pattern_string} return TK_LIT_STRING;

<INITIAL,MULTILINE_COMMENT,POTENTIAL_SUM>\n {
	++line_number;
	/* Increment line counter regardless of state, takes precedence over next rule due to order. */
}
<MULTILINE_COMMENT>. {
	/* Eat everything preceding the closing multi-line comment (one char at a time) */
}

<MULTILINE_COMMENT>"*/" {
	/* End the multi-line comment. Takes precedence to former two due to match length (two chars vs one). */
	BEGIN(state_before_comment);
}

<INITIAL,POTENTIAL_SUM>[[:blank:]] {
	/* Discard tabs and whitespaces. Equivalent with [ \t] */
}
. {
	/* Everything else should be an error. */
	return TOKEN_ERRO;
}

<<EOF>> {
	return TK_EOF;
}

%%

int get_ascii_value() {
	return yytext[0];
}

int get_line_number () {
	return line_number;
}
