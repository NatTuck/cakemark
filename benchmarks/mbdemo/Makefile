BASE := $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

HDRS := $(wildcard *.h)
SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.o)

THREADS := $(shell grep processor /proc/cpuinfo | wc -l)

LDFLAGS=-L$(PANCAKE)/lib
LDLIBS=-lpancake -lSDL2 -lgc -lm -lpthread
CFLAGS=-g -O3 -std=gnu99 -Wall -Werror -I$(PANCAKE)/include -DTHREADS=$(THREADS)

demo: $(OBJS)
	gcc -g $(LDFLAGS) -o demo $(OBJS) $(LDLIBS)

$(OBJS): $(SRCS) $(HDRS)

clean:
	rm -f demo $(OBJS)
