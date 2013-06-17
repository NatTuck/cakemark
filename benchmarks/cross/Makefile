CC=gcc
CFLAGS=-g -Wall
#LDFLAGS=-g -L$(HOME)/Apps/pocl/lib
LDFLAGS=-g -L$(HOME)/Apps/llvm-3.2/lib
LDLIBS=-lpocl -lltdl -lpoclu
#LDLIBS=-lOpenCL -lpancake `../../scripts/llvm-libs.pl` -lpthread

BINF=example1
OBJS=$(shell ls *.c | perl -pe 's/\.c\b/.o/')

all:
	make $(BINF)

$(BINF): $(OBJS)

$(OBJS): %.o: %.c 

pclu_perror.c pclu_perror.h: generate_perror.pl
	./generate_perror.pl

clean:
	rm -f *.o *~ $(BINF) pclu_perror.c pclu_perror.h

.PHONY: clean


