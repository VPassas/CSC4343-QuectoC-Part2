#include <stdio.h>
#include "parser.tab.h"

extern int lexical_error;

int yylex_destroy(void);

int main(void)
{
    int status = yyparse();

    yylex_destroy();

    if (status != 0 || lexical_error) {
        puts("PARSE_ERROR");
        return 1;
    }

    puts("PARSE_OK");
    return 0;
}