
#include <stdint.h>
#include <stdio.h>
#include <gc/gc.h>

#include "display.h"
#include "mandelbrot.h"

const int WW = 1280;
const int HH = 800;

void
fill_image(uint32_t* image, int ww, int hh) {
    for (int ii = 0; ii < hh; ++ii) {
        for (int jj = 0; jj < ww; ++jj) {
            image[ii*ww + jj] = ii + jj;
        }
    }
}

int
main(int argc, char* argv[])
{
    Display* dd = display_create(WW, HH);
    uint32_t* image = malloc(WW * HH * sizeof(uint32_t));

    for (int ii = 0; ii < 1000; ++ii) {
        mandelbrot(image, WW, HH, 1000);
        display_show(dd, image);
        display_wait(dd, 500);
    }

    return 0;
}
