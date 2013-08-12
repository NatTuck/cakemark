
# make FLAGS="-mem2reg -sccp -loop-rotate -loop-unroll -simplifycfg"

BASE := ../..

CFLAGS := -I$(BASE)/include
LDLIBS := $(BASE)/cake/libcake.a

SLIB := $(BASE)/spec/libspec.so
NAME := ipow

POW ?= 7

FLAGS ?= -domtree
SPEC  ?= -spec-text="kk=$(POW)"

ifneq ($(SPEC),) 
SPEC1 := -specialize -kernel=ipow $(SPEC)
endif

all: $(NAME)

$(NAME): main.bc $(NAME)-opt.bc
	llvm-link -o linked.bc main.bc $(NAME)-opt.bc
	llc -o $(NAME).s linked.bc
	gcc -o $(NAME) $(NAME).s $(LDLIBS)

$(NAME)-opt.bc: $(NAME).bc
	opt -load=$(SLIB) \
		$(SPEC1) \
		$(FLAGS) \
	   	-o $(NAME)-opt.bc $(NAME).bc

$(NAME).ll: $(NAME).bc
	llvm-dis $(NAME).bc

%.bc: %.c
	clang -c -emit-llvm $(CFLAGS) -o $@ $<

%.ll: %.bc
	llvm-dis -o $@ $<

$(NAME).bc: $(NAME).c

clean:
	rm -f *.bc *.ll *.s *.o $(NAME) *~

.PHONY: all static spec clean

