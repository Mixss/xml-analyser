#
CC=gcc
LEX=flex

all: x.l
	$(LEX) x.l
	gcc lex.yy.c -lfl -o ./x


