BASE := $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

XBS ?= 8
YBS ?= 1

CFLAGS  := -g -Wall -std=gnu99 -I$(PANCAKE)/include -I$(BASE)/include -DXBS=$(XBS) -DYBS=$(YBS)
LDFLAGS := -g -L$(OCL_LDPATH) -L$(PANCAKE)/lib
LDLIBS  := $(OCL_LDLIBS) -lpancake

BINF := mmul
SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.o)

all:
	(cd $(BASE) && make include/cl_perror.h)
	make $(BINF)

$(BINF): $(OBJS)

$(OBJS): %.o: %.c *.h 

test: $(BINF)
	LD_LIBRARY_PATH=$(OCL_LDPATH) ./$(BINF)

keep-test: $(BINF)
	SHOW_LLVM_COMMANDS=1 POCL_LEAVE_TEMP_DIRS=1 LD_LIBRARY_PATH=$(OCL_LDPATH) ./$(BINF)

bench:
	make clean
	make all
	SPEC_TEXT="nn=1024,spin=1" SPEC_KERN="fmma" make test

bench-clover:
	OPENCL=clover CAKE_OPT=$(BASE)/scripts/clover-opt.sh make bench

clean:
	rm -f *.o *~ $(BINF) pclu_perror.c pclu_perror.h

.PHONY: all clean test bench


