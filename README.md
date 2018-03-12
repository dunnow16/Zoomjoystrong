# Zoomjoystrong
Interpretive language created using Flex and Bison to draw using SDL2.<br />

#Compile: <br />
bison -d zoomjoystrong.y <br />
flex zoomjoystrong.lex <br />
gcc -o zjs zoomjoystrong.c lex.yy.c zoomjoystrong.tab.c -lSDL2 -lm <br />
<br />
#Run: <br />
zjs < gv.zjs <br />

