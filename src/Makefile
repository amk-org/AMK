# Makefile: A simple makefile for ex1.

OBJ = mycalc
NAME = amk
LEX = $(NAME).lex
YACC = $(NAME).ypp

default:
	bison -d $(YACC)
	flex $(LEX)
	g++ -o $(OBJ) $(NAME).tab.cpp lex.yy.c

clean:
	rm $(NAME).tab.hpp $(NAME).tab.cpp lex.yy.c $(OBJ)
