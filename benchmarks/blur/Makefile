
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
	@rm -f balloon.pgm

ref_check: ref_blur
	@zcat balloon.pgm.gz > balloon.pgm
	/usr/bin/time -p ./ref_blur
	@rm -f balloon.pgm

.PHONY: clean
