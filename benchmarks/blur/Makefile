
BASE = $(shell readlink -f ../..)

include $(BASE)/benchmarks/platforms.mk

XBS ?= 8
YBS ?= 1

OUTPUT = balloon.pgm balloon_blurred.pgm

#CFLAGS  = -g -std=gnu99 -O2 -Wall -I$(BASE)/include -I$(PANCAKE)/include -DXBS=$(XBS) -DYBS=$(YBS)
CFLAGS  = -g -std=gnu99 -O2 -Wall -Werror -I$(BASE)/include -I$(PANCAKE)/include
LDFLAGS = -g $(OCL_LDFLAGS) -L/usr/local/lib
LDLIBS  = -lm $(OCL_LDLIBS) -lpancake -ldrip

all: perror cl_blur ref_blur fuzzy_check

cl_blur: cl_blur.o pclu.o

ref_blur: ref_blur.o

fuzzy_check: fuzzy_check.o

$(BINARY): $(OBJS)

perror:
	(cd $(BASE) && make include/cl_perror.h)

clean:
	rm -f *.o ref_blur cl_blur fuzzy_check $(OUTPUT)

cl_check: cl_blur fuzzy_check
	@zcat balloon.pgm.gz > balloon.pgm
	LD_LIBRARY_PATH="$(OCL_LDPATH)" /usr/bin/time -p ./cl_blur
	@zcat correct.pgm.gz > correct.pgm
	@./fuzzy_check balloon_blurred.pgm correct.pgm
	@rm -f balloon.pgm correct.pgm

cl_stat: cl_blur fuzzy_check
	@zcat balloon.pgm.gz > balloon.pgm
	perf stat -e cache-misses ./ref_blur
	@zcat correct.pgm.gz > correct.pgm
	@./fuzzy_check balloon_blurred.pgm correct.pgm
	@rm -f balloon.pgm correct.pgm

ref_check: ref_blur fuzzy_check
	@zcat balloon.pgm.gz > balloon.pgm
	/usr/bin/time -p ./ref_blur
	@zcat correct.pgm.gz > correct.pgm
	@./fuzzy_check balloon_blurred.pgm correct.pgm
	@rm -f balloon.pgm correct.pgm

cl_gdb: cl_blur fuzzy_check
	@zcat balloon.pgm.gz > balloon.pgm
	LD_LIBRARY_PATH="$(OCL_LDPATH)" gdb ./cl_blur
	@zcat correct.pgm.gz > correct.pgm
	@./fuzzy_check balloon_blurred.pgm correct.pgm
	@rm -f balloon.pgm correct.pgm

test:
	(make cl_check)

bench-clover:
	OPENCL=clover CAKE_OPT=$(BASE)/scripts/clover-opt.sh make bench

bench:
	make clean
	make all
	make test

.PHONY: all clean cl_check ref_check test bench perror
