
show: rects.pdf
	okular rects.pdf

rects.pdf: rects.txt rects.gp
	gnuplot rects.gp

clean:
	rm -f rects.pdf

.PHONY: clean show
