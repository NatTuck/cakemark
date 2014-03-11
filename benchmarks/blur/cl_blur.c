
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <alloca.h>
#include <assert.h>

#include "pclu.h"

const char* INPUT  = "balloon.pgm";
const char* OUTPUT = "balloon_blurred.pgm";
const int   SIGMA  = 20;

#ifndef XBS
#define XBS 8
#endif

#ifndef YBS
#define YBS 1
#endif

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
    int    rv;

    FILE* imf = fopen(filename, "r");
    
    rv = getline(&line, &size, imf);
    assert(rv != -1);
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

    rv = fscanf(imf, "%ld", &ww);
    assert(rv == 1);
    rv = fscanf(imf, "%ld", &hh);
    assert(rv == 1);
    rv = fscanf(imf, "%d",  &cc);
    assert(rv == 1);

    assert(cc == 255);
    
    image* im = alloc_image(ww, hh);

    for (int ii = 0; ii < ww * hh; ++ii) {
        rv = fscanf(imf, "%d", &cc);
        assert(rv == 1);
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
    fprintf(imf, "%ld %ld\n255\n", im->width, im->height);
    
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
cl_gaussian_blur(pclu_context* pclu, image* im0, int sigma)
{
    assert(sigma > 0);

    size_t ww = im0->width;
    size_t hh = im0->height;
    int    rr = 3 * sigma;

    /* Generate the blur vector */
    size_t bvec_size = (2 * rr + 1) * sizeof(float);
    float* bvec = (float*) alloca(bvec_size);
    float  bsum = 0.0;

    for (int kk = -rr; kk <= rr; ++kk) {
        int ii = kk + rr;
        bvec[ii] = (float) gauss(kk, 0.0, sigma);
        bsum += bvec[ii];
    }

    for (int ii = 0; ii < 2 * rr + 1; ++ii) {
        bvec[ii] *= 1.0f / bsum;
    }

    image* im1 = alloc_image(ww, hh);

    pclu_program* pgm = pclu_create_program(pclu, "blur_kernels.cl");
    char *log = pclu_program_build_log(pgm);
    if (strlen(log) > 0)
        printf("Build log:\n%s\n", log);

    pclu_buffer* im0_buf = pclu_create_buffer(pclu, ww*hh);
    pclu_write_buffer(im0_buf, ww*hh, im0->data);

    pclu_buffer* im1_buf = pclu_create_buffer(pclu, ww*hh);
    pclu_write_buffer(im1_buf, ww*hh, im1->data);

    pclu_buffer* bvc_buf = pclu_create_buffer(pclu, bvec_size);
    pclu_write_buffer(bvc_buf, bvec_size, bvec);

    pclu_range range = pclu_range_2d(hh, ww);
    range.local[0] = XBS;
    range.local[1] = YBS;

    /* Kernel expects 32 bit args */
    int ww32 = (int) ww, hh32 = (int) hh;

    /* Blur horizontally */
    cl_kernel blur_hor = pclu_get_kernel(pgm, "blur_hor");
    pclu_set_arg_buf(blur_hor, 0, im1_buf);
    pclu_set_arg_buf(blur_hor, 1, im0_buf);
    pclu_set_arg_buf(blur_hor, 2, bvc_buf);
    pclu_set_arg_lit(blur_hor, 3, ww32);
    pclu_set_arg_lit(blur_hor, 4, hh32);
    pclu_set_arg_lit(blur_hor, 5, rr);

    pclu_call_kernel(pgm, blur_hor, range);

    /* Blur vertically */
    cl_kernel blur_ver = pclu_get_kernel(pgm, "blur_ver");
    pclu_set_arg_buf(blur_ver, 0, im0_buf);
    pclu_set_arg_buf(blur_ver, 1, im1_buf);
    pclu_set_arg_buf(blur_ver, 2, bvc_buf);
    pclu_set_arg_lit(blur_ver, 3, ww32);
    pclu_set_arg_lit(blur_ver, 4, hh32);
    pclu_set_arg_lit(blur_ver, 5, rr);
    
    pclu_call_kernel(pgm, blur_ver, range);

    pclu_read_buffer(im0_buf, ww*hh, im0->data);
    pclu_read_buffer(im1_buf, ww*hh, im1->data);

    pclu_destroy_program(pgm);
    free_image(im1);
}

int
main(int argc, char* argv[])
{
    pclu_context* pclu = pclu_create_context();
    printf("\n%s\n", pclu_context_info(pclu));

    image* im = read_image(INPUT);
    cl_gaussian_blur(pclu, im, SIGMA);
    write_image(OUTPUT, im);
    free_image(im);

    pclu_destroy_context(pclu);
    return 0;
}
