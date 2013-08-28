
# make FLAGS="-mem2reg -sccp -loop-rotate -loop-unroll -simplifycfg"
# -instcombine -argpromotion


BASE := ../..

NAME := mmul
NN   ?= 512

CFLAGS := -I$(BASE)/include -DNN=$(NN)
LDLIBS := 

SLIB := $(BASE)/spec/libspec.so


FLAGS ?= -domtree
SPEC  ?= -spec-text="nn=$(NN)"

ifneq ($(SPEC),) 
SPEC1 := -specialize -kernel=$(NAME) $(SPEC)
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

%.bc: %.c Makefile
	clang -c -emit-llvm $(CFLAGS) -o $@ $<

%.ll: %.bc
	llvm-dis -o $@ $<

$(NAME).bc: $(NAME).c

charts: mmul.bars
	$(BASE)/scripts/barchart.pl mmul.bars "mmul (nn = $(NN))"

show-run:
	make charts
	okular *run-time.pdf &

clean:
	rm -f *.bc *.ll *.s *.o $(NAME) *~ *.pdf

.PHONY: all static spec clean charts show-run

