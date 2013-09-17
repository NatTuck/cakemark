
kernel
void
blur_hor(global uchar* im1, global uchar* im0, global float* bvec, 
        int ww, int hh, int rr)
/* @spec blur_hor(ww, hh, rr) global_size(0, 1) */
{
    int ii = get_global_id(0);
    int jj = get_global_id(1);
   
    //int   rr = 3 * sigma;
    float pp = 0.0f;

    for (int kk = -rr; kk <= rr; ++kk) {
        int jj0 = clamp(jj + kk, 0, ww - 1);
        pp += bvec[kk + rr] * im0[ww*ii + jj0];
    }

    im1[ww*ii + jj] = clamp((int)round(pp), 0, 255);
}

kernel
void
blur_ver(global uchar* im1, global uchar* im0, global float* bvec, 
        int ww, int hh, int rr)
/* @spec blur_ver(ww, hh, rr) global_size(0, 1) */
{
    int ii = get_global_id(0);
    int jj = get_global_id(1);
   
    //int   rr = 3 * sigma;
    float pp = 0.0f;

    for (int kk = -rr; kk <= rr; ++kk) {
        int ii0 = clamp(ii + kk, 0, hh - 1);
        pp += bvec[kk + rr] * im0[ww*ii0 + jj];
    }

    im1[ww*ii + jj] = clamp((int)round(pp), 0, 255);
}
