
# make FLAGS="-mem2reg -sccp -loop-rotate -loop-unroll -simplifycfg"
# -instcombine -argpromotion


BASE := ../..

NAME := blur

CFLAGS := -I$(BASE)/include
LDLIBS := -lm

SLIB := $(BASE)/spec/libspec.so

FLAGS ?= -domtree
SPEC  ?= -spec-text="ww=1024,hh=768,sigma=3"

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

charts: $(NAME).bars
	$(BASE)/scripts/barchart.pl $(NAME).bars

show-run:
	make charts
	okular *run-time.pdf &

clean:
	rm -f *.bc *.ll *.s *.o $(NAME) *~ *.pdf
	rm -f balloon_blurred.pgm

.PHONY: all static spec clean charts show-run

