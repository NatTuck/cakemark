
ifndef DERP
	DERP=burp
endif

all: include/cl_perror.h

include/cl_perror.h: /usr/include/CL/cl.h
	./include/generate_perror.pl

clean:
	rm -f include/cl_perror.h
	find ./benchmarks -name "Makefile" -exec sh -c 'cd `dirname {}` && make clean' \;
	find ./tests -name "Makefile" -exec sh -c 'cd `dirname {}` && make clean' \;

prereqs:
	sudo apt-get install libtext-csv-perl libpdl-stats-perl plplot12-driver-xwin plplot11-driver-cairo libplplot-dev plplot11-driver-gd plplot11-driver-wxwidgets imview

.PHONY: all clean prereqs
