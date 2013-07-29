BASE = ../../

include $(BASE)/benchmarks/platforms.mk

CC=g++
CFLAGS =-g -Wall -I$(BASE)/include -DXBS=$(XBS) -DYBS=$(YBS)
LDFLAGS=-g -L$(OCL_LDPATH)
LDLIBS =$(OCL_LDLIBS)

DIR=MandelGPU-v1.3
CMD=mandelGPU 1 0 preprocessed_rendering_kernel.cl 2048 2048 1024

all: build

build:
	(cd $(DIR) && make)

test: build
	(cd $(DIR) && LD_LIBRARY_PATH=$(OCL_LDPATH) ./$(CMD))
	(cd $(DIR) && perl check.pl)

keep-test: build
	(cd $(DIR) && SHOW_LLVM_COMMANDS=1 POCL_LEAVE_TEMP_DIRS=1 \
	   	LD_LIBRARY_PATH=$(OCL_LDPATH) ./$(CMD))

bench:
	make clean
	make all
	make test

clean:
	(cd $(DIR) && rm -f image.ppm)
	(cd $(DIR) && make clean)

.PHONY: all clean test bench


