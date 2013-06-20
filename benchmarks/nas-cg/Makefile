
include ../platforms.mk

CLASS=A
BENCH=cg
NPB  =../NPB3.3-OCL

all:
	(cd $(NPB) && make $(BENCH) CLASS=$(CLASS))
	
test: all
	(cd $(NPB)/bin && LD_LIBRARY_PATH="$(OCL_LDPATH)" \
		./run_ocl_cpu.sh $(BENCH) $(CLASS)) |\
		perl $(NPB)/check-output.pl

bench:
	make clean
	make all
	make test

clean:
	(cd $(NPB) && make veryclean)


.PHONY: all test bench clean
