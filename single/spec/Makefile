
CXXFLAGS := -std=gnu++11 -I../include $(shell llvm-config --cxxflags)
LDFLAGS  := $(shell llvm-config --ldflags)
LDLIBS   := -lLLVM-3.3 -lgc -lbsd

SRCS := $(wildcard *.cc)
OBJS := $(SRCS:.cc=.o)

all: libspec.so

libspec.so: $(OBJS) libcake.a
	$(CXX) -shared $(LDFLAGS) -o $@ $(OBJS) libcake.a $(LDLIBS)

$(OBJS): $(SRCS)

libcake.a:
	(cd ../cake && make)
	cp ../cake/libcake.a .

clean:
	rm -f *.o *.so *.a *~

.PHONY: all clean libcake.a
