
#include <stdint.h>
#include <stdio.h>
#include <math.h>
#include <gc/gc.h>

#include <pancake/timer.h>

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
    cake_timer tm;
    double tt;

    cake_timer_init();

    Display* dd = display_create(WW, HH);
    uint32_t* image = malloc(WW * HH * sizeof(uint32_t));

    for (int ii = 1; ii < 500; ++ii) {
        printf("frame %d\n", ii);

        cake_timer_reset(&tm);
        mandelbrot(image, WW, HH, 0.5534476f, 0.6251437f, powf(1.028f, ii), 200);
        tt = cake_timer_read(&tm);
        printf("mandelbrot time: %.02f\n", tt);

        cake_timer_reset(&tm);
        display_show(dd, image);
        tt = cake_timer_read(&tm);
        printf("display time: %.02f\n", tt);


        display_wait(dd, 3);
    }

    return 0;
}
