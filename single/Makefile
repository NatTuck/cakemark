

all: cake spec

cake:
	(cd cake && make)

spec:
	(cd spec && make)

clean:
	(cd cake && make clean)
	(cd spec && make clean)
	find tests -name Makefile -exec sh -c 'cd `dirname {}` && make clean' \;

.PHONY: all cake spec clean
