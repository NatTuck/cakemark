
HDRS=$(wildcard *.h)
SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)

LDLIBS=-lSDL2 -lgc
CFLAGS=-g -std=gnu99

demo: $(OBJS)
	gcc -g -o demo $(OBJS) $(LDLIBS)

$(OBJS): $(SRCS) $(HDRS)

clean:
	rm -f demo $(OBJS)
