
/* Matrix multiply and accumulate */

kernel void
bmmul(global float *C, global float *A, global float *B, long nn, long blksz)
/* @spec bmmul(nn, blksz) */
{
    int xx0 = get_global_id(0) * blksz;
    int yy0 = get_global_id(1) * blksz;
    
    int xx1 = xx0 + blksz;
    int yy1 = yy0 + blksz;

    for (int yy = yy0; yy < yy1; ++yy) {
        for (int xx = xx0; xx < xx1; ++xx) {
            float sum = C[nn * yy + xx];

            for (int kk = 0; kk < nn; ++kk) {
                sum += A[nn * yy + kk] * B[nn * kk + xx];
            }

            C[nn * yy + xx] = sum;
        }
    }
}
