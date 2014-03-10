
LIB := libnvcommon.so

SRCS=$(wildcard *.cpp)

LDFLAGS := -L$(PANCAKE)/lib
LDLIBS  := -lpancake
CFLAGS  := -I$(PANCAKE)/include -I../include

$(LIB): $(SRCS)
	g++ -g -o $(LIB) -shared -fPIC -std=gnu++11 $(SRCS) $(CFLAGS) $(LDFLAGS) $(LDLIBS)

clean:
	rm $(LIB)
