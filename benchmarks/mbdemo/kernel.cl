

kernel
mandelbrot(global uint32* image, int ww, int hh, float xx, float yy, float zz, int iters)
{
    int ii = get_global_id(0);
    int jj = get_global_id(1);
 
    float x0 = (3.5f * ((float)jj/(float)ww) - 2.5f - xc) / zz;
    float y0 = (2.0f * ((float)ii/(float)hh) - 1.0f - yc) / zz;

    float xx = 0.0f;
    float yy = 0.0f;

    int kk = 0;

    while ((xx * xx + yy * yy < 4.0f) && (kk < max)) {
        float x1 = x0 + xx * xx - yy * yy;
        yy = y0 + 2 * xx * yy;
        xx = x1;
        kk += 1;
    }

    image[ii * ww + jj] = iters * (2 << 25) / (max + 2);
}
