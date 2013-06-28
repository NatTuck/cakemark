
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <alloca.h>
#include <assert.h>

const char* INPUT  = "balloon.pgm";
const char* OUTPUT = "balloon_blurred.pgm";
const int   SIGMA  = 20;

typedef unsigned char byte;

typedef struct image {
    size_t width;
    size_t height;
    byte* data;
} image;

int
streq(const char* aa, const char* bb)
{
    return strcmp(aa, bb) == 0;
}

void
carp(const char* msg)
{
    fprintf(stderr, "FATAL: %s\n", msg);
    fflush(stderr);
    abort();
}

image*
alloc_image(int ww, int hh)
{
    image* im  = malloc(sizeof(image));
    im->width  = ww;
    im->height = hh;
    im->data   = malloc(ww * hh * sizeof(byte));
    return im;
}

void
free_image(image* im)
{
    free(im->data);
    free(im);
}

image*
read_image(const char* filename) 
{
    char*  line = alloca(16);
    size_t size = 16;
    size_t ww, hh;
    int    cc;

    FILE* imf = fopen(filename, "r");
    
    getline(&line, &size, imf);
    if (!streq(line, "P2\n"))
        carp("Bad image file; not ASCII PGM");

    /* Assume leading comments only */
    while ((cc = getc(imf))) {
        if (cc == '#') {
            // throw away the line
            while (getc(imf) != '\n');
        }
        else {
            ungetc(cc, imf);
            break;
        }
    }

    fscanf(imf, "%ld", &ww);
    fscanf(imf, "%ld", &hh);
    
    image* im = alloc_image(ww, hh);

    for (int ii = 0; ii < ww * hh; ++ii) {
        int cc;
        fscanf(imf, "%d", &cc);
        im->data[ii] = (byte) cc;
    }

    fclose(imf);

    return im;
}

void
write_image(const char* filename, image* im)
{
    FILE* imf = fopen(filename, "w");
    
    fprintf(imf, "P2\n");
    fprintf(imf, "# Output from Cakemark Blur\n");
    fprintf(imf, "%ld %ld\n", im->width, im->height);
    
    size_t data_size = im->width * im->height;

    for (int ii = 0; ii < data_size; ++ii) {
        fprintf(imf, "%d\n", im->data[ii]);
    }

    fclose(imf);
}

double
gauss(double x, double mu, double sigma)
{
    double aa  = 1.0 / (sigma * sqrt(2.0 * M_PI));
    double bbT = -pow(x - mu, 2.0);
    double bbB = 2 * pow(sigma, 2.0);
    double bb  = bbT / bbB;
    return aa * exp(bb);
}

int
clamp(int xx, int x0, int x1)
{
    if (xx < x0) return x0;
    if (xx > x1) return x1;
    return xx;
}

void
gaussian_blur(image* im0, int sigma)
{
    assert(sigma > 0);

    size_t ww = im0->width;
    size_t hh = im0->height;
    int    rr = 3 * sigma;

    /* Generate the blur vector */
    double bvec[2 * rr + 1];
    double bsum = 0.0;

    for (int kk = -rr; kk <= rr; ++kk) {
        int ii = kk + rr;
        bvec[ii] = gauss(kk, 0.0, sigma);
        bsum += bvec[ii];
    }

    for (int ii = 0; ii < 2 * rr + 1; ++ii) {
        bvec[ii] *= 1.0 / bsum;
    }

    image* im1 = alloc_image(ww, hh);

    /* Blur horizontally */
    for (int ii = 0; ii < hh; ++ii) {
        for (int jj = 0; jj < ww; ++jj) {
            double p1 = 0.0;

            for (int kk = -rr; kk <= rr; ++kk) {
                int jj0 = clamp(jj + kk, 0, ww - 1);
                p1 += bvec[kk + rr] * im0->data[ww*ii + jj0];
            }

            im1->data[ww*ii + jj] = clamp(round(p1), 0, 255);
        }
    }

    /* Blur vertically */
    for (int jj = 0; jj < ww; ++jj) {
        for (int ii = 0; ii < hh; ++ii) {
            double p0 = 0.0;

            for (int kk = -rr; kk <= rr; ++kk) {
                int ii0 = clamp(ii + kk, 0, hh - 1);
                p0 += bvec[kk + rr] * im1->data[ww*ii0 + jj];
            }

            im0->data[ww*ii + jj] = clamp(round(p0), 0, 255);
        }
    }

    free_image(im1);
}

int
main(int argc, char* argv[])
{
    image* im = read_image(INPUT);
    gaussian_blur(im, SIGMA);
    write_image(OUTPUT, im);
    free_image(im);
    return 0;
}
