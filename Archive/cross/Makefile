BASE = ../../

include $(BASE)/benchmarks/platforms.mk

CC=gcc
CFLAGS=-g -Wall -I$(BASE)/include
LDFLAGS=-g -L$(OCL_LDPATH)
LDLIBS =$(OCL_LDLIBS) -lpoclu

BINF=example1
SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)

all:
	(cd $(BASE) && make include/cl_perror.h)
	make $(BINF)

$(BINF): $(OBJS)

$(OBJS): %.o: %.c 

test: $(BINF)
	LD_LIBRARY_PATH=$(OCL_LDPATH) ./$(BINF)

bench:
	make clean
	make all OPENCL=$(OPENCL)
	make test OPENCL=$(OPENCL)

clean:
	rm -f *.o *~ $(BINF) pclu_perror.c pclu_perror.h

.PHONY: all clean test bench


