BASE = ../../

include $(BASE)/benchmarks/platforms.mk

CC=g++
CFLAGS =-g -Wall -I$(BASE)/include -I$(PANCAKE)/include
LDFLAGS=-g -L$(OCL_LDPATH) -L$(PANCAKE)/lib
LDLIBS =$(OCL_LDLIBS) -lgc -lbsd -lpancake

CXXFLAGS = $(CFLAGS)

CC = g++
SRCS = $(wildcard *.cpp)
HDRS = $(wildcard *.h)
OBJS = $(SRCS:.cpp=.o)

EXE = gaussian

all: $(EXE)

$(EXE): $(OBJS)
	$(CC) $(LDFLAGS) -o $(EXE) $(OBJS) $(LDLIBS)

$(OBJS): %.o: %.cpp $(HDRS)

#release:
#	$(CC) $(CC_FLAGS) -lOpenCL  -fopenmp $(SRC) -o $(EXE) -I$(OPENCL_INC) -L$(OPENCL_LIB)

test: $(EXE)
	LD_LIBRARY_PATH=$(OCL_LDPATH) ./gaussian matrix1024.txt
	echo "[cake: OK]"

keep-test: $(EXE)
	SHOW_LLVM_COMMANDS=1 POCL_LEAVE_TEMP_DIRS=1 \
	    LD_LIBRARY_PATH=$(OCL_LDPATH)./gaussian matrix1024.txt

bench:
	make clean
	make all
	SPEC_TEXT="nn=1024,spin=1" SPEC_KERN="fmma" make test

bench-clover:
	OPENCL=clover CAKE_OPT=$(BASE)/scripts/clover-opt.sh make bench

clean: 
	rm -f $(EXE) *.o 
