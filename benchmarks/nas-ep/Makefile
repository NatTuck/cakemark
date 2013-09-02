BASE := $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

CLASS=A
BENCH=ep
NPB  =../NPB3.3-OCL

all:
	(cd $(NPB) && make $(BENCH) CLASS=$(CLASS))
	
test: all
	(cd $(NPB)/bin && LD_LIBRARY_PATH="$(OCL_LDPATH)" \
		./run_ocl_$(OCL_DTYPE).sh $(BENCH) $(CLASS)) |\
		perl $(NPB)/check-output.pl

bench:
	make clean
	make all
	make test

bench-clover:
	OPENCL=clover CAKE_OPT=$(BASE)/scripts/clover-opt.sh make bench

clean:
	(cd $(NPB) && make veryclean)


.PHONY: all test bench clean
