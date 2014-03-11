BASE := $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

DIR  := ../NV-OCL/oclDCT
TEMP := $(shell tempfile)

all:
	(cd $(DIR) && make)

test: all
	(cd $(DIR) && LD_LIBRARY_PATH="$(OCL_LDPATH)" make run) | tee $(TEMP)
	perl ../NV-OCL/check-output.pl < $(TEMP)
	rm $(TEMP)

bench:
	make clean
	make all
	make test

clean:
	(cd $(DIR) && make clean)


.PHONY: all test bench clean
