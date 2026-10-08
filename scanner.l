%option noyywrap noinput nounput never-interactive nodefault
%{
#include <stdio.h>
#include "parser.tab.h"

int lexical_error = 0;
int line = 1;
int column = 1;

int block_comment_line;
int block_comment_column;

int string_line;
int string_column;

void advance_location(const char *text, int length)
{
    for (int i = 0; i < length; i++) {
        if (text[i] == '\n') {
            line++;
            column = 1;
        }
        else {
            column++;
        }
    }
}

int return_token(int token, const char *text, int length)
{
    yylloc.first_line = line;
    yylloc.first_column = column;

    advance_location(text, length);

    yylloc.last_line = line;
    yylloc.last_column = column;

    return token;
}

int lexical_fail(int error_line,
                 int error_column,
                 const char *reason)
{
    lexical_error = 1;

    fprintf(stderr, "LEX_ERROR %d:%d %s\n", error_line, error_column, reason);

    return 0;
}

%}

DIGIT       [0-9]
HEXDIGIT    [0-9a-fA-F]
NUMCHAR     [a-zA-Z0-9_.]
NUMCAND     ({DIGIT}|[.]{DIGIT}){NUMCHAR}*

%x LINE_COMMENT
%x BLOCK_COMMENT
%x STRING

%%
"let"       { return return_token(KW_LET, yytext, yyleng); }
"int"       { return return_token(KW_INT, yytext, yyleng); }
"print"     { return return_token(KW_PRINT, yytext, yyleng); }
"if"        { return return_token(KW_IF, yytext, yyleng); }
"else"      { return return_token(KW_ELSE, yytext, yyleng); }
"for"       { return return_token(KW_FOR, yytext, yyleng); }
"while"     { return return_token(KW_WHILE, yytext, yyleng); }

"=="        { return return_token(EQ, yytext, yyleng); }
"!="        { return return_token(NE, yytext, yyleng); }
"<="        { return return_token(LE, yytext, yyleng); }
">="        { return return_token(GE, yytext, yyleng); }
"="         { return return_token(ASSIGN, yytext, yyleng); }
"<"         { return return_token(LT, yytext, yyleng); }
">"         { return return_token(GT, yytext, yyleng); }
"+"         { return return_token(PLUS, yytext, yyleng); }
"-"         { return return_token(MINUS, yytext, yyleng); }
"*"         { return return_token(STAR, yytext, yyleng); }

"//" { advance_location(yytext, yyleng);
    BEGIN(LINE_COMMENT); }
<LINE_COMMENT>\r\n { advance_location(yytext, yyleng);
    BEGIN(INITIAL); }
<LINE_COMMENT>\n { advance_location(yytext, yyleng);
    BEGIN(INITIAL); }
<LINE_COMMENT>\r { advance_location(yytext, yyleng); }
<LINE_COMMENT>[^\r\n]+ { advance_location(yytext, yyleng); }
<LINE_COMMENT><<EOF>> {
    yylloc.first_line = line;
    yylloc.first_column = column;
    yylloc.last_line = line;
    yylloc.last_column = column;

    return 0;
}

"/*" {
    block_comment_line = line;
    block_comment_column = column;

    advance_location(yytext, yyleng);
    BEGIN(BLOCK_COMMENT);
}
<BLOCK_COMMENT>"*/" {
    advance_location(yytext, yyleng);
    BEGIN(INITIAL);
}
<BLOCK_COMMENT>\r\n { advance_location(yytext, yyleng); }
<BLOCK_COMMENT>\r { advance_location(yytext, yyleng); }
<BLOCK_COMMENT>\n { advance_location(yytext, yyleng); }
<BLOCK_COMMENT>[^*\r\n]+ { advance_location(yytext, yyleng); }
<BLOCK_COMMENT>"*" { advance_location(yytext, yyleng);}
<BLOCK_COMMENT><<EOF>> { return lexical_fail(block_comment_line, block_comment_column, "unterminated block comment");}

"/"         { return return_token(SLASH, yytext, yyleng); }
"%"         { return return_token(PERCENT, yytext, yyleng); }

";"         { return return_token(SEMICOLON, yytext, yyleng); }
"("         { return return_token(LPAREN, yytext, yyleng); }
")"         { return return_token(RPAREN, yytext, yyleng); }
"{"         { return return_token(LBRACE, yytext, yyleng); }
"}"         { return return_token(RBRACE, yytext, yyleng); }

0[xX]{HEXDIGIT}+ { return return_token(INT_LITERAL, yytext, yyleng); }

{DIGIT}+ { return return_token(INT_LITERAL, yytext, yyleng); }

\" {
    string_line = line;
    string_column = column;

    BEGIN(STRING);
    return return_token(STRING_BEGIN, yytext, yyleng);
}
<STRING>[^"\r\n]+ { return return_token(STRING_TEXT, yytext, yyleng); }
<STRING>\" { BEGIN(INITIAL); return return_token(STRING_END, yytext, yyleng); }
<STRING>\r\n { return lexical_fail(string_line, string_column, "unterminated string"); }
<STRING>\n { return lexical_fail(string_line, string_column, "unterminated string");}
<STRING>\r { return lexical_fail(string_line, string_column, "unterminated string");}
<STRING><<EOF>> { return lexical_fail(string_line, string_column, "unterminated string"); }

{NUMCAND} { return lexical_fail(line, column, "invalid integer spelling");}

[a-zA-Z_][a-zA-Z0-9_]* { return return_token(IDENTIFIER, yytext, yyleng); }
[ \t\r\n]+  { advance_location(yytext, yyleng); }

. { return lexical_fail(line, column, "unexpected character");}

<INITIAL><<EOF>> {
    yylloc.first_line = line;
    yylloc.first_column = column;
    yylloc.last_line = line;
    yylloc.last_column = column;

    return 0;
}

%%