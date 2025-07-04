%{
#include "../../.build/parser.tab.hpp"     
#include <string>

// Variables para seguimiento de columnas
int yycolumn = 1;
int lex_error = 0;

// Macro que se ejecuta ANTES de cada token
#define YY_USER_ACTION \
    yylloc.first_line = yylineno; \
    yylloc.first_column = yycolumn; \
    yylloc.last_line = yylineno; \
    yylloc.last_column = yycolumn + yyleng - 1; \
    yycolumn += yyleng;  // Actualizar después de registrar la posición
%}

%option noyywrap         
%option yylineno   
%option nounput       

%%

[_]+[a-zA-Z0-9_]+       { lex_error = 1; fprintf(stderr, "Error léxico. Variable inválida: '%s' en %d:%d\n", yytext, yylineno, yylloc.first_column); }
[0-9]+[a-zA-Z_]+        { lex_error = 1; fprintf(stderr, "Error léxico. Variable inválida: '%s' en %d:%d\n", yytext, yylineno, yylloc.first_column); }


[0-9]+(\.[0-9]+)?       { 
                            yylval.num = atof(yytext); 
                            printf("Token: %s → Línea %d, Columna %d\n", yytext, yylineno, yylloc.first_column);
                            return NUMBER; 
                        }
\"(?:\\.|[^"])*\"       {
                            std::string raw = yytext;
                            yylval.str = new std::string(raw.substr(1, raw.size() - 2));
                            printf("String: %s  → Línea %d, Columna %d\n", yytext, yylineno, yylloc.first_column);
                            return STRING;
                        }
"True"                  {
                            yylval.boolean = true;
                            printf("Boolean: %s  → Línea %d, Columna %d\n", yytext, yylineno, yylloc.first_column);
                            return BOOL;
                        }
"False"                 {
                            yylval.boolean = false;
                            printf("Boolean: %s  → Línea %d, Columna %d\n", yytext, yylineno, yylloc.first_column);
                            return BOOL;
                        }
"Null"                  { 
                            printf("Null value → Línea %d, Columna %d\n", yylineno, yylloc.first_column);
                            return NULL_VAL; 
                        }


[+]                     { printf(" + \n"); return ADD; }
[-]                     { printf(" - \n"); return SUB; }
[*]                     { printf(" * \n"); return MUL; }
[/]                     { printf(" / \n"); return DIV; }
[%]                     { printf(" mod \n"); return MOD; }
[\^]                    { printf(" ^ \n"); return POW; }
[*][*]                  { printf(" ** \n"); return POW; }

[<]                     { printf(" < \n"); return LT; }
[>]                     { printf(" > \n"); return GT; }
"<="                    { printf(" <= \n"); return LE; }
">="                    { printf(" >= \n"); return GE; }
"=="                    { printf(" == \n"); return EQ; }
"!="                    { printf(" != \n"); return NE; }


"&"                     { printf(" & \n"); return AND; }
"!"                     { printf(" ! \n"); return NOT; }
[|]                     { printf(" | \n"); return OR; }


"@"                     { printf(" @ \n"); return CONCAT; }
"@@"                    { printf(" @@ \n"); return CONCAT_SPACE; }


"sin"                   { printf(" sin \n"); return SIN; }
"cos"                   { printf(" cos \n"); return COS; }
"max"                   { printf(" max \n"); return MAX; }
"min"                   { printf(" min \n"); return MIN; }
"sqrt"                  { printf(" sqrt \n"); return SQRT; }
"exp"                   { printf(" exp \n"); return EXP; }
"log"                   { printf(" log \n"); return LOG; }
"rand"                  { printf(" rand \n"); return RANDOM; }


"print"                 { printf("print\n"); return PRINT; }


"PI"                    { printf("PI\n"); return PI; }
"E"                     { printf("E\n"); return E; }


"function"              { printf("definir nueva función\n"); return FUNC; }
"=>"                    { printf("lambda \n"); return LAMBDA; }

"let"                   { printf("definir nueva variable\n"); return LET; }
"in"                    { printf("definir scope\n"); return IN; }
"="                     { printf("asignar valor\n"); return '='; }
":="                    { printf("reasignar valor\n"); return REASSIGN; }

"if"                    { printf("if\n"); return IF; }
"else"                  { printf("else\n"); return ELSE; }
"elif"                  { printf("elif\n"); return ELIF; }

"for"                   { printf("for\n"); return FOR; }
"while"                 { printf("while\n"); return WHILE; }
"range"                 { printf("range\n"); return RANGE; }

"type"                  { printf("type\n"); return TYPE; }
"new"                   { printf("new\n"); return NEW; }
"self"                  { printf("self\n"); return SELF; }
"inherits"              { printf("inherits\n"); return INHERITS; }
"base"                  { printf("base\n"); return BASE; }


[a-zA-Z_][a-zA-Z0-9_]*  {
                            yylval.str = new std::string(yytext);
                            printf("ID: %s  → Línea %d, Columna %d\n", yytext, yylineno, yylloc.first_column);
                            return ID;
                        }

"("                     { printf(" ( \n"); return '('; }
")"                     { printf(" ) \n"); return ')'; }
"{"                     { printf(" { \n"); return '{'; }
"}"                     { printf(" } \n"); return '}'; }
","                     { printf(" , \n"); return ','; }            
";"                     { 
                            printf("';' symbol  → Línea %d, Columna %d\n", yylineno, yylloc.first_column);
                            return ';'; 
                        }
"."                     { printf(" . \n"); return '.'; }            


[ \t]+                  { /* Whitespace handled by YY_USER_ACTION */ }  // Ignorar espacios
\n                      { yycolumn = 1; }        // Resetear columna al salto de línea
.                       { 
                            lex_error = 1;
                            fprintf(stderr, "Error léxico: '%s' en %d:%d\n", yytext, yylineno, yylloc.first_column); 
                        }

%%