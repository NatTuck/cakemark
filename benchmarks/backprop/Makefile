# C compiler
CC = g++
FLAGS = -g -O2 -I../../include

# LIBS = -lOpenCL
LIBS = -L$(HOME)/Apps/pocl/lib -lpocl -lltdl -lpthread

backprop: backprop.o imagenet.o facetrain.o backprop_ocl.o
	$(CC) $(FLAGS) -o backprop backprop_ocl.o backprop.o imagenet.o facetrain.o $(LIBS)

%.o: %.cpp
	$(CC) $(FLAGS) $< -c

%.o: %.[ch]
	$(CC) $(FLAGS) $< -c

test:
	./backprop 65536

clean:
	rm -f *.o *~ backprop *.linkinfo
