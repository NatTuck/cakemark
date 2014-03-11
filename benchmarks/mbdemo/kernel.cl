
kernel
void
mandelbrot(global uint* image, int ww, int hh, float xc, float yc, float zz, int iters)
/* @spec mandelbrot(ww, hh, iters) */
{
    int ii = get_global_id(0);
    int jj = get_global_id(1);
 
    float x0 = (3.5f * ((float)jj/(float)ww) - 2.5f) / zz - xc;
    float y0 = (2.0f * ((float)ii/(float)hh) - 1.0f) / zz - yc;

    float xx = 0.0f;
    float yy = 0.0f;

    int kk;

    for (kk = 0; (xx * xx + yy * yy < 4.0f) && (kk < iters); ++kk) {
        float x1 = x0 + xx * xx - yy * yy;
        yy = y0 + 2 * xx * yy;
        xx = x1;
    }

    image[ii * ww + jj] = kk * (2 << 25) / (kk + 2);
}

