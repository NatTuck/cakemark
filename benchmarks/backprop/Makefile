BASE = ../../

include $(BASE)/benchmarks/platforms.mk

# C compiler
CC = g++
CFLAGS = -g -O2 -I$(BASE)/include
LDLIBS = $(OCL_LDLIBS)

CSRCS =$(wildcard *.c)
CCSRCS=$(wildcard *.cpp)
OBJS=$(CSRCS:.c=.o) $(CCSRCS:.cpp=.o)

all: backprop

backprop: $(OBJS)
	$(CC) $(LDFLAGS) -o backprop $(OBJS) $(LDLIBS)

%.o: %.cpp
	$(CC) $(CFLAGS) $< -c

%.o: %.[ch]
	$(CC) $(CFLAGS) $< -c

test:
	LD_LIBRARY_PATH=$(OCL_LDPATH) ./backprop 65536

bench:
	make clean
	make all OPENCL=$(OPENCL)
	make test OPENCL=$(OPENCL)

clean:
	rm -f *.o *~ backprop *.linkinfo
