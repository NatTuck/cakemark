
#include <stdlib.h>
#include <alloca.h>
#include <math.h>

typedef unsigned char byte;

static
double
gauss(double x, double mu, double sigma)
{
    double aa  = 1.0 / (sigma * sqrt(2.0 * M_PI));
    double bbT = -pow(x - mu, 2.0);
    double bbB = 2 * pow(sigma, 2.0);
    double bb  = bbT / bbB;
    return aa * exp(bb);
}

static
int
clamp(int xx, int x0, int x1)
{
    if (xx < x0) return x0;
    if (xx > x1) return x1;
    return xx;
}

void
blur(byte* im0, size_t ww, size_t hh, int sigma)
{
    int rr = 3 * sigma;

    /* Generate the blur vector */
    double *bvec = malloc((2 * rr + 1) * sizeof(double));
    double bsum = 0.0;

    for (int kk = -rr; kk <= rr; ++kk) {
        int ii = kk + rr;
        bvec[ii] = gauss(kk, 0.0, sigma);
        bsum += bvec[ii];
    }

    for (int ii = 0; ii < 2 * rr + 1; ++ii) {
        bvec[ii] *= 1.0 / bsum;
    }

    byte* im1 = malloc(ww * hh * sizeof(byte));

    /* Blur im0 horizontally into im1 */
    for (int ii = 0; ii < hh; ++ii) {
        for (int jj = 0; jj < ww; ++jj) {
            double p1 = 0.0;

            for (int kk = -rr; kk <= rr; ++kk) {
                int jj0 = clamp(jj + kk, 0, ww - 1);
                p1 += bvec[kk + rr] * im0[ww*ii + jj0];
            }

            im1[ww*ii + jj] = clamp(round(p1), 0, 255);
        }
    }

    /* Blur im1 vertically back into im0 */
    for (int jj = 0; jj < ww; ++jj) {
        for (int ii = 0; ii < hh; ++ii) {
            double p0 = 0.0;

            for (int kk = -rr; kk <= rr; ++kk) {
                int ii0 = clamp(ii + kk, 0, hh - 1);
                p0 += bvec[kk + rr] * im1[ww*ii0 + jj];
            }

            im0[ww*ii + jj] = clamp(round(p0), 0, 255);
        }
    }

    free(im1);
    free(bvec);
}
