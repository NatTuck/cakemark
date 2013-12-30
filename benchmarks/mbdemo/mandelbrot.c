
#include <stdint.h>

uint32_t
mb_iterate(int ww, int hh, int ii, int jj, int max) 
{
    float x0 = 3.5f * ((float)jj/(float)ww) - 2.5f;
    float y0 = 2.0f * ((float)ii/(float)hh) - 1.0f;

    float xx = 0.0f;
    float yy = 0.0f;

    int kk = 0;

    while ((xx * xx + yy * yy < 4.0f) && (kk < max)) {
        float x1 = x0 + xx * xx - yy * yy;
        yy = y0 + 2 * xx * yy;
        xx = x1;
        kk += 1;
    }

    return kk;
}

void
mandelbrot(uint32_t* image, int ww, int hh, int max)
{
    for (int ii = 0; ii < hh; ++ii) {
        for (int jj = 0; jj < ww; ++jj) {
            uint32_t iters = mb_iterate(ww, hh, ii, jj, max);
            image[ii * ww + jj] = iters * (2 << 24) / (max + 1);
        }
    }
}
