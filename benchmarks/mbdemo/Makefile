BASE := $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

HDRS := $(wildcard *.h)
SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.o)

THREADS := $(shell grep processor /proc/cpuinfo | wc -l)

LDFLAGS := $(OCL_LDFLAGS) -L$(PANCAKE)/lib
LDLIBS  := $(OCL_LDLIBS) -lpancake -lSDL2 -lgc -lm -lpthread -lOpenCL
CFLAGS  := -g -O3 -std=gnu99 -Wall -Werror -I$(PANCAKE)/include -I$(BASE)/include -DTHREADS=$(THREADS)

all: demo

demo: $(OBJS) 
	gcc -g $(LDFLAGS) -o demo $(OBJS) $(LDLIBS)

$(OBJS): $(SRCS) $(HDRS) perror

perror:
	(cd $(BASE) && make include/cl_perror.h)

clean:
	rm -f demo $(OBJS)

test:
	LD_LIBRARY_PATH=$(OCL_LDPATH) ./demo

bench:
	make clean
	make all
	make test

.PHONY: perror clean all bench
