
no-spec: main.o mmul.o
	clang -o no-spec main.o mmul.o -lrt

spec: main.o mmul-256.o
	clang -o spec main.o mmul-256.o -lrt

main.o: main.c
	clang -c -o main.o main.c

mmul-256.o: mmul-256-opt.ll
	llc -filetype=obj -o $@ $<

mmul-256-opt.ll: mmul-256.ll
	opt -S -o $@ $(OPTS) $< 

mmul.o: mmul-opt.ll
	llc -filetype=obj -o $@ $<
	
mmul-opt.ll: mmul.ll
	opt -S -o $@ $(OPTS) $< 

mmul.ll: mmul.c
	clang -S -emit-llvm -o $@ $<

clean:
	rm -f *.o no-spec spec *opt.ll mmul.ll *~
