
SRCS := $(wildcard src/*.cpp)

all: $(EXECUTABLE)

INCDIR ?= ../include

LDFLAGS := -L../lib -L$(PANCAKE)/lib
LDLIBS := -lnvcommon -lOpenCL -lpancake
CFLAGS := -g -I../include -I$(PANCAKE)/include -I$(INCDIR)

$(EXECUTABLE): $(SRCS)
	g++ -o $(EXECUTABLE) $(SRCS) $(CFLAGS) $(LDFLAGS) $(LDLIBS)

run:
	LD_LIBRARY_PATH="$(LD_LIBRARY_PATH):../lib" ./$(EXECUTABLE)

clean:
	rm -f $(EXECUTABLE) *.ptx SdkConsoleLog.txt

.PHONY: all clean run
