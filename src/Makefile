# Makefile: A simple makefile for ex1.

OBJ = amki
NAME = amk
LEX = $(NAME).lex
YACC = $(NAME).y

default:
	bison -d $(YACC)
	flex $(LEX)
	gcc -o $(OBJ) $(NAME).tab.c lex.yy.c

clean:
	rm $(NAME).tab.h $(NAME).tab.c lex.yy.c $(OBJ)
