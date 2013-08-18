
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <alloca.h>
#include <assert.h>

#define CAKE_TIMER_FAST_LINK 1
#include <cake/timer.h>

const char* INPUT  = "balloon.pgm";
const char* OUTPUT = "balloon_blurred.pgm";
const int   SIGMA  = 3;

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
    fscanf(imf, "%d",  &cc);

    assert(cc == 255);
    
    image* im = alloc_image(ww, hh);

    for (int ii = 0; ii < ww * hh; ++ii) {
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
    fprintf(imf, "%ld %ld\n255\n", im->width, im->height);
    
    size_t data_size = im->width * im->height;

    for (int ii = 0; ii < data_size; ++ii) {
        fprintf(imf, "%d\n", im->data[ii]);
    }

    fclose(imf);
}

void blur(byte* im0, size_t ww, size_t hh, int sigma);

void
gaussian_blur(image* im0, int sigma)
{
    assert(sigma > 0);

    cake_timer tm;
    cake_timer_reset(&tm);

    blur(im0->data, im0->width, im0->height, sigma);

    double secs = cake_timer_read(&tm);
    printf("time: %.04f\n", secs);
}

int
main(int argc, char* argv[])
{
    image* im = read_image(INPUT);
    gaussian_blur(im, SIGMA);
    write_image(OUTPUT, im);
    free_image(im);
    system("cmp balloon_blurred.pgm correct.pgm && echo '[cake: OK]'");
    return 0;
}
