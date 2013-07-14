
BASE = ../..

include $(BASE)/benchmarks/platforms.mk

OUTPUT = balloon.pgm balloon_blurred.pgm

CFLAGS  = -g -std=gnu99 -Wall -I$(BASE)/include
LDFLAGS = -g -L$(OCL_LDPATH)
LDLIBS  = -lm $(OCL_LDLIBS)

all: cl_blur ref_blur

cl_blur: cl_blur.o pclu.o

ref_blur: ref_blur.o

$(BINARY): $(OBJS)

clean:
	rm -f *.o ref_blur cl_blur $(OUTPUT)

cl_check: cl_blur
	@zcat balloon.pgm.gz > balloon.pgm
	/usr/bin/time -p ./cl_blur
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

.PHONY: all clean cl_check ref_check test bench