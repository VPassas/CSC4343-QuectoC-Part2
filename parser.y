%{
#include <stdio.h>

int yylex(void);
void yyerror(const char *message);

extern int lexical_error;
%}

%locations

%token KW_LET
%token KW_INT
%token KW_PRINT
%token KW_IF
%token KW_ELSE
%token KW_WHILE
%token KW_FOR

%token IDENTIFIER
%token INT_LITERAL

%token ASSIGN
%token EQ
%token NE
%token LT
%token LE
%token GT
%token GE

%token PLUS
%token MINUS
%token STAR
%token SLASH
%token PERCENT

%token SEMICOLON
%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE

%token STRING_BEGIN
%token STRING_TEXT
%token STRING_END

%start program

%%

program:
      statement_list
    ;

statement_list:
      statement
    | statement_list statement
    ;

statement:
      declaration
    | assignment SEMICOLON
    | print_statement
    | block
    | if_statement
    | while_statement
    | for_statement
    ;
    // dont use | here because all of them are needed to format a for loop
for_statement:
      KW_FOR LPAREN
      assignment SEMICOLON
      condition SEMICOLON
      assignment
      RPAREN block
    ;

print_statement:
      KW_PRINT LPAREN expression RPAREN SEMICOLON
    | KW_PRINT LPAREN quoted_text RPAREN SEMICOLON
    ;

quoted_text:
      STRING_BEGIN STRING_END
    | STRING_BEGIN STRING_TEXT STRING_END
    ;

block:
      LBRACE block_contents RBRACE
    ;
// it can be empty {}
block_contents:
      %empty
    | statement_list
    ;

condition:
      expression comparison_operator expression
    ;

comparison_operator:
      EQ
    | NE
    | LT
    | LE
    | GT
    | GE
    ;

if_statement:
      KW_IF LPAREN condition RPAREN block
    | KW_IF LPAREN condition RPAREN block KW_ELSE block
    ;

while_statement:
      KW_WHILE LPAREN condition RPAREN block
    ;

declaration:
      KW_LET IDENTIFIER ASSIGN expression SEMICOLON
    | KW_INT IDENTIFIER SEMICOLON
    | KW_INT IDENTIFIER ASSIGN expression SEMICOLON
    ;
// no semicolon because of cases like for (i = 0; i < 10; i = i + 1)
assignment:
      IDENTIFIER ASSIGN expression
    ;

expression:
      expression PLUS term
    | expression MINUS term
    | term
    ;    

term:
      term STAR unary
    | term SLASH unary
    | term PERCENT unary
    | unary
    ;

unary:
      PLUS unary
    | MINUS unary
    | primary
    ; 
    
primary:
      INT_LITERAL
    | IDENTIFIER
    | LPAREN expression RPAREN
    ;       
    
%%

void yyerror(const char *message)
{
    if (!lexical_error) {
        fprintf(stderr, "PARSER_ERROR %d:%d %s\n", yylloc.first_line, yylloc.first_column, message);
    }
}