/* Parser to convert "C" assignments to lisp. */
/* Demonstrates parameters passed to yyparse and to yylex */
/* Compile: bison -d -y flexexample5.y */

%{
#include "lex.yy.h"  /* Generated by reflex: scanner_t, yyscan_t, yylex_init, yylex_destroy */
/* %pure-parser requires us to pass the argument 'params->scanner' from yyparse through to yylex. */
#define YYLEX_PARAM params->scanner
/* Pass argument `struct pass_through *param` with scanner object and other data */
struct pass_through {
  yyscanner_t *scanner;
  int count;
};
void yyerror(struct pass_through *param, const char *msg); /* yyerror accepts `params` */
%}

/* pure-parser adds yylval parameter to yylex() */
%pure-parser
/* parse-param adds extra parameter to yylex() */
%parse-param { struct pass_through *params }

%union {
    int num;
    char* str;
}

%token <str> STRING
%token <num> NUMBER

%%

assignments : assignment
            | assignment assignments
            ;
assignment  : STRING '=' NUMBER ';' { printf("(setf %s %d)\n", $1, $3); ++params->count; }
            ;

%%

int main()
{
  struct pass_through params;
  yyscanner_t scanner;	// new way in C++ using reflex-generated yyscanner_t
  params.scanner = &scanner;
  params.count = 0;
  yyparse(&params);	// %parse-param, we pass params->scanner on to yylex()
  printf("# assignments = %d\n", params.count);
  return 0;
}

void yyerror(struct pass_through *params, const char*)
{
  fprintf(stderr, "syntax error at %lu\n", params->scanner->matcher().lineno());
}
