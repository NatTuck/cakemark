
all: rects-blur_hor.pdf rects-blur_ver.pdf	

rects-blur_hor.pdf: rects-blur_hor.txt rects.gp
	kern=blur_hor gnuplot rects.gp

rects-blur_ver.pdf: rects-blur_ver.txt rects.gp
	kern=blur_ver gnuplot rects.gp

clean:
	rm -f rects*.pdf

.PHONY: clean show
