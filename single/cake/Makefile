
CFLAGS := -std=gnu99 -I../include -fPIC

SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.o)

all: libcake.a

libcake.a: $(OBJS)
	ar rcs $@ $(OBJS)

$(OBJS): $(SRCS)

clean:
	rm -f *.o *.a *~

.PHONY: all clean
