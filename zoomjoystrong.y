/**
 * Author: Owen Dunn
 * Date:   3/12/18
 *
 * Zoomjoystong language: Parser file
 * 
 * This file is used to parse the tokens provided by the lexer file 
 * and run the appropriate code. Bison uses the defined context-free
 * grammar to produce a C-language function to recognize correct
 * grammar. 
 */
 
/* DEFINITIONS */
%{
	#include <stdio.h>
	#include "zoomjoystrong.h"
	
	#define WIDTH   1024
	#define HEIGHT  768
	#define MAX_RGB 255
	
	void yyerror(const char* msg);
	int yylex();
%}

%error-verbose

%start program

%token END
%token END_STATEMENT
%token POINT
%token LINE 
%token CIRCLE
%token RECTANGLE
%token SET_COLOR
%token INT
%token FLOAT

%union { int i; float f; }
%type<i> INT number
%type<f> FLOAT 

/*
 * RULES: Define the context-free grammar. C-code is run as instances
 *   	  of the rules are found. The code run is listed after each
 *	  defined rule. Error checking is included within the code to
 *	  make sure user input is within the proper screen dimensions
 *	  for drawing and color values are valid. 
 */
%%

program: statement_list END
;

statement_list:	statement
	      | statement statement_list
;

statement: command END_STATEMENT   
;

command: draw_point
       | draw_line
       | draw_circle
       | draw_rectangle
       | set_color
;

draw_point: POINT number number
	    {
	    printf("Drawing point: x=%d, y=%d.\n", $2, $3);
	    if ($2 > WIDTH || $2 < 0)
	      	printf("Error: %d outside of width range.\n", $2);
	    else if ($3 > HEIGHT || $3 < 0)
	      	printf("Error: %d outside of height range.\n", $3);
	    else 
	      	point($2, $3);  
	    }
;

draw_line: LINE number number number number
	   {
	   printf("Drawing line: x1=%d, y1=%d to x2=%d, y2=%d.\n", 
		   $2, $3, $4, $5);
	   if ($2 > WIDTH || $2 < 0)
	      printf("Error: %d outside of width range.\n", $2);
	   else if ($3 > HEIGHT || $3 < 0)
	      printf("Error: %d outside of height range.\n", $3);
	   else if ($4 > WIDTH || $4 < 0)
	      printf("Error: %d outside of width range.\n", $4);
	   else if ($5 > HEIGHT || $5 < 0)
	      printf("Error: %d outside of height range.\n", $5);
	   else
	      line($2, $3, $4, $5);
	   }
;

draw_circle: CIRCLE number number number
	     {
	     printf("Drawing circle: about point x=%d, y=%d ", 
		     $2, $3);
	       printf("with\nradius r=%d.\n", $4);
	     if ($2 > WIDTH || $2 < 0)
		printf("Error: %d outside of width range.\n", $2);
	     else if ($3 > HEIGHT || $3 < 0)
		printf("Error: %d outside of height range.\n", $3);
	     else if ( ($2 + $4) > WIDTH || ($2 - $4) < 0 )
		printf("Error: Circle reaches outside of display.\n");
	     else if ( ($3 + $4) > HEIGHT || ($3 - $4) < 0 )
		printf("Error: Circle reaches outside of display.\n");
	     else
		circle($2, $3, $4);
	     }
;

draw_rectangle: RECTANGLE number number number number
		{
		printf("Drawing rectangle: from upper left corner");
		  printf(" x=%d, y=%d, ", $2, $3);
		  printf("\nwidth=%d, height=%d.\n", $4, $5);
		if ( ($2 + $4) > WIDTH ) {
		    printf("Error: Rectangle would reach outside ");
		      printf("screen.\n");
		}
		else if ( ($3 + $5) > HEIGHT ) {
		    printf("Error: Rectangle would reach outside ");
		      printf("screen.\n");
		}
		else if ($2 < 0 || $2 > WIDTH || $3 < 0 || 
			 $3 > HEIGHT || $4 < 0 || $5 < 0) {
		    printf("Error: Invalid value for position, ");
		      printf("width, or height.\n");
		}
		else
		    rectangle($2, $3, $4, $5);
		}
;

set_color: SET_COLOR number number number
	   { 
	   printf("Setting color: r:%d, g:%d, b:%d.\n", $2, $3, $4);
	   if ($2 > MAX_RGB || $2 < 0)
	      printf("Error: Red value (%d) invalid.\n", $2);
	   else if ($3 > MAX_RGB || $3 < 0)
	      printf("Error: Green value (%d) invalid.\n", $3);
	   else if ($4 > MAX_RGB || $4 < 0)
	      printf("Error: Blue value (%d) invalid.\n", $4);
	   else
	      set_color($2, $3, $4);
	   }
;

number: INT
      | FLOAT	{ $$ = (int)$1; } /* change to an int (float not used) */
;

/* CODE */
%%

/**
 * Parse the tokens and do appropriate actions based on the defined
 * context free grammar above. When a matching sentence is found, as
 * defined above, the blocked code will run to control the drawing 
 * program if no errors are found. SDL2 functions are used to draw the
 * patterns as defined in the "zoomjoystrong.h" file. The user may
 * provide a program filled with statements to draw or provide one
 * statement at a time. The drawing process stops when "end" is 
 * provided as a statement. The syntax of the Zoomjoystrong language
 * is defined in the Flex file.
 *
 * param:  zjs input file or zjs statements from a command line
 * return: exit condition (int)
 */
int main(int argc, char** argv) {
    char ch;
    
    printf("=====================Zoomjoystong=====================\n");
    printf("Valid statements:\n");
    printf("1. \"line x y u v\": plot a line from x,y to u,v\n");
    printf("2. \"point x y\":  plot a point at x,y\n");
    printf("3. \"circle x y r\": plot a circle of radius r around\n");
      printf("point x,y\n");
    printf("4. \"rectangle x y w h\": draw a rectangle of height h\n");
      printf("and width w beginning at the top left edge x,y\n");
    printf("5. \"set_color\": change the current drawing color to\n");
      printf("the r,g,b tuple\n");
    printf("Enter \"end\" to stop.\n\n");
    printf("Press CTRL-d to send EOF signal if running from terminal.\n");

    setup();   /* Set up drawing display. */
    yyparse(); /* Parse the tokens */
    printf("Drawing complete.\n\n");
    finish();  /* Wait 5 seconds, close window, and quit. */
    printf("======================================================\n");
    
    return 0;
}

/**
 * This function is used to print syntax error messages to the user.
 * This function must be defined for Bison.
 * 
 * param:  msg (string)
 * return: none
 */
void yyerror(const char* msg) {
    fprintf(stderr, "ERROR! %s\n", msg);
}
