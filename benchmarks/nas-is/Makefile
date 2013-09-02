BASE := $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

CLASS := B
BENCH := is
NPB   := ../NPB3.3-OCL
TEMP  := $(shell tempfile)

all:
	(cd $(NPB) && make $(BENCH) CLASS=$(CLASS))
	
test: all
	(cd $(NPB)/bin && LD_LIBRARY_PATH="$(OCL_LDPATH)" \
		./run_ocl_$(OCL_DTYPE).sh $(BENCH) $(CLASS)) | tee $(TEMP)
	perl $(NPB)/check-output.pl < $(TEMP)
	rm $(TEMP)

bench:
	make clean
	make all
	make test

bench-clover:
	OPENCL=clover CAKE_OPT=$(BASE)/scripts/clover-opt.sh make bench

clean:
	(cd $(NPB) && make veryclean)


.PHONY: all test bench clean
