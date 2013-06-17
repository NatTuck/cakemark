
include ../bench-common.mk

CC=g++
CFLAGS=-g -Wall
LDFLAGS=-g -L$(OCL_LDPATH)
LDLIBS =$(OCL_LDLIBS)
#LDLIBS=-lOpenCL -lpancake `../../scripts/llvm-libs.pl` -lpthread

BINF=mmul
OBJS=$(shell ls *.c | perl -pe 's/\.c\b/.o/')

all:
	./generate_perror.pl
	make $(BINF)

$(BINF): $(OBJS)

$(OBJS): %.o: %.c *.h pclu_perror.h

pclu_perror.c pclu_perror.h: generate_perror.pl
	./generate_perror.pl

test: $(BINF)
	LD_LIBRARY_PATH=$(OCL_LDPATH) ./$(BINF)

bench:
	make clean
	make all OPENCL=$(OPENCL)
	make test OPENCL=$(OPENCL)

clean:
	rm -f *.o *~ $(BINF) pclu_perror.c pclu_perror.h

.PHONY: all clean test bench


