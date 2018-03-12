/**
 * Author: Owen Dunn
 * Date:   3/12/18
 *
 * Zoomjoystrong language: Lexer file
 *
 * This file will be used by Flex to produce a lexer file for the 
 * Zoomjoystrong language. The created file scans input to look for 
 * occurances of the defined regular expressions. When a regular 
 * expression instance is found by the created file, the followed 
 * code is run (on the same line).
 */

/* DEFINITIONS */
%{
	#include <stdlib.h>
	/* created by Bison from parser file */
	#include "zoomjoystrong.tab.h" 
%}

/* read only one input file */
%option noyywrap
/* used to avoid compilation warning for implicit declaration of fileno */
%option never-interactive

/*
 * RULES: Define the tokens with regex and pass them to the parser when 
 *        found. The associated value is placed in the global variable
 * 	  yylval and the token type is returned to interface with the
 *	  parser created by Bison.
 */
%% 

end			{ return END; } /* exit interpreter - parser action */
;			{ return END_STATEMENT; } /* end commands with ';'  */
point			{ return POINT; }
line			{ return LINE; }
circle			{ return CIRCLE; }
rectangle		{ return RECTANGLE; }
set_color		{ return SET_COLOR; }
[-]?[0-9]+		{ yylval.i = atoi(yytext); return INT; }
[-]?[0-9]+\.[0-9]+	{ yylval.f = atof(yytext); return FLOAT; }
[ \t\n]			; /* do nothing for spaces */
.			{ 
			printf("Error: unrecognized character: %s\n", 
			       yytext); 
			}
    
%%

/* Code: left blank */