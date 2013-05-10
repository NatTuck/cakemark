
ifndef DERP
	DERP=burp
endif

all:
	scripts/generate_perror.pl

clean:
	rm -f include/cl_perror.h
	find ./src -name "Makefile" -exec sh -c 'cd `dirname {}` && make clean' \;
	find ./tests -name "Makefile" -exec sh -c 'cd `dirname {}` && make clean' \;
   
## Random experiments:

derp:
	@echo $(DERP)
