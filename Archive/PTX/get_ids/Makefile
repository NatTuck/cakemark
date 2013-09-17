
BASE = ../../..

CFLAGS = -g -I$(BASE)/include -I/usr/local/include -std=gnu99
LDLIBS = -lOpenCL -lm

POCL = /home/nat/Apps/pocl/lib/pocl/llvmopencl.so

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

#all: main get_ids.s
all: main

main: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

$(OBJS): $(SRCS) *.h

get_ids.s: link1.bc
	llc -o $@ -march=r600 -mcpu=cypress link1.bc

link1.bc: link0.bc
	opt -load=$(POCL) -flatten -kernel=get_ids -always-inline -globaldce -o link1.bc link0.bc 

link0.bc: get_ids.bc libclc/cypress-r600--.bc
	llvm-link -o link0.bc libclc/cypress-r600--.bc get_ids.bc

%.bc: %.cl
	clang -c -emit-llvm -x cl -o $@ $<

%.ll: %.bc
	llvm-dis $<

get_ids.ptx: get_ids.cl
	./build-ptx.sh get_ids.cl get_ids.ptx

clean:
	rm -f *~ *.o *.ll *.bc *.s main

.PHONY: all clean
