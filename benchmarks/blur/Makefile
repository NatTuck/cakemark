
BASE = ../..

include $(BASE)/benchmarks/platforms.mk

XBS ?= 8
YBS ?= 1

OUTPUT = balloon.pgm balloon_blurred.pgm

CFLAGS  = -g -std=gnu99 -Wall -I$(BASE)/include -DXBS=$(XBS) -DYBS=$(YBS)
LDFLAGS = -g -L$(OCL_LDPATH)
LDLIBS  = -lm $(OCL_LDLIBS)

all: perror cl_blur ref_blur

cl_blur: cl_blur.o pclu.o

ref_blur: ref_blur.o

$(BINARY): $(OBJS)

perror:
	(cd $(BASE) && make include/cl_perror.h)

clean:
	rm -f *.o ref_blur cl_blur $(OUTPUT)

cl_check: cl_blur
	@zcat balloon.pgm.gz > balloon.pgm
	/usr/bin/time -p ./cl_blur
	@zcat correct.pgm.gz > correct.pgm
	@cmp balloon_blurred.pgm correct.pgm && echo "[cake: OK]"
	@rm -f balloon.pgm correct.pgm

cl_stat: cl_blur
	@zcat balloon.pgm.gz > balloon.pgm
	perf stat -e cache-misses ./ref_blur
	@zcat correct.pgm.gz > correct.pgm
	@cmp balloon_blurred.pgm correct.pgm && echo "[cake: OK]"
	@rm -f balloon.pgm correct.pgm

ref_check: ref_blur
	@zcat balloon.pgm.gz > balloon.pgm
	/usr/bin/time -p ./ref_blur
	@zcat correct.pgm.gz > correct.pgm
	@cmp balloon_blurred.pgm correct.pgm && echo "OK"
	@rm -f balloon.pgm correct.pgm

test:
	(make cl_check)

bench:
	make clean
	make all
	make test

.PHONY: all clean cl_check ref_check test bench perror
