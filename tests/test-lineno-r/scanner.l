%{
/* A template scanner file to build "scanner.c".
   Run as:
          test-lineno-r    # report flex's yylineno
          test-lineno-r 1  # report count_newlines(stdin)
*/

#include <stdio.h>
#include <stdlib.h>
#include "config.h"

%}

%option 8bit outfile="scanner.c" prefix="test"
%option nounput nomain noyywrap yylineno reentrant
%option warn

WORD [[:alpha:]]+
DIGIT [[:digit:]]

%%
    /* The goal here is to test the yylineno processing by:
       - providing some rules than CAN match newlines and
         other rules that can NOT match newlines,
       - matching several newlines in one rule,
       - directly modifying yylineno.
    */

"yylineno++"          yylineno++;
"yylineno--"          yylineno--;
[[:space:]]+
{WORD}
{DIGIT}+(\n{DIGIT}+)*
\n
.
<<EOF>>  { printf("%d\n", yylineno);
           yyterminate();
         }

%%

/* returns number of '\n' characters in input, plus one.
   This is what flex does, essentially. */
   
static int
count_newlines (FILE* in)
{
    int n=1,c;
    while ((c=fgetc(in)) != EOF)
        if( c == '\n')
            n++;
    return n;
}

int
main ( int argc, char** argv )
{
    if( argc > 1 )
        printf("%d\n", count_newlines(stdin));

    else{
        yyscan_t s;
        yylex_init(&s);
        yyset_in(stdin,s);
        yyset_out(stdout,s);
        yylex(s);
        yylex_destroy(s);
    }
    return 0;
}