
include ../platforms.mk

CLASS := S
BENCH := lu
NPB   := ../NPB3.3-OCL
TEMP  := $(shell tempfile)

all:
	(cd $(NPB) && make $(BENCH) CLASS=$(CLASS))
	
test: all
	(cd $(NPB)/bin && LD_LIBRARY_PATH="$(OCL_LDPATH)" \
		./run_ocl_cpu.sh $(BENCH) $(CLASS)) | tee $(TEMP)
	perl $(NPB)/check-output.pl < $(TEMP)
	rm $(TEMP)

bench:
	make clean
	make all
	make test

clean:
	(cd $(NPB) && make veryclean)


.PHONY: all test bench clean
