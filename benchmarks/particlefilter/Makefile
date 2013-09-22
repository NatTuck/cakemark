BASE := $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

# C compiler
CC=g++
CFLAGS  = -g -Wall -I$(BASE)/include -I$(PANCAKE)/include
LDFLAGS = -g $(OCL_LDFLAGS) -L$(PANCAKE)/lib
LDLIBS  = $(OCL_LDLIBS) -lpancake

SRCS = $(wildcard *.cpp)
HDRS = $(wildcard *.h)
OBJS = $(SRCS:.cpp=.o)

BIN = pfilter

all: $(BIN) 

$(BIN): $(OBJS)
	$(CC) $(LDFLAGS) -o $(BIN) $(OBJS) $(LDLIBS)

$(OBJS): %.o: %.cpp $(HDRS)
	$(CC) -c $(CFLAGS) -o $@ $<

test: $(BIN)
	LD_LIBRARY_PATH=$(OCL_LDPATH) ./$(BIN) -x 128 -y 128 -z 10 -np 400000
	echo "[cake: OK]"

bench:
	make clean
	make all
	make test

bench-clover:
	OPENCL=clover CAKE_OPT=$(BASE)/scripts/clover-opt.sh make bench

clean:
	rm -f *.o *~ $(BIN)
