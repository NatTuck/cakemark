
CFLAGS=-I../../include

all: main

main: main.o fib.o

*.o: %.o: %.c

test: main
	CAKE_TIMINGS="test_timings.txt" ./main
	@echo
	@echo "  == Timings =="
	@cat test_timings.txt

clean:
	rm -f *.o main *~ test_timings.txt
