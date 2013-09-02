BASE := $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

CC      := g++
CFLAGS  := -g -Wall -I$(BASE)/include
LDFLAGS := -g -L$(OCL_LDPATH)
LDLIBS  := $(OCL_LDLIBS) -lGL -lglut

DIR := MandelGPU-v1.3
CMD := mandelGPU 1 0 preprocessed_rendering_kernel.cl 2048 2048 1024

all: build

build:
	(cd $(DIR) && make CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" LDLIBS="$(LDLIBS)")

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

bench-clover:
	OPENCL=clover CAKE_OPT=$(BASE)/scripts/clover-opt.sh make bench

clean:
	(cd $(DIR) && rm -f image.ppm)
	(cd $(DIR) && make clean)

.PHONY: all clean test bench


