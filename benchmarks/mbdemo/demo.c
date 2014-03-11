
#include <stdint.h>
#include <stdio.h>
#include <gc/gc.h>

#include "pclu.h"
#include "pancake/timer.h"
#include "display.h"
#include "mandelbrot.h"

const int   WW = 1280;
const int   HH = 800;
const float XX = 0.5534476f;
const float YY = 0.6251437f;

pclu_context *pclu;
pclu_program *pgm;

void
opencl_setup()
{
    pclu = pclu_create_context();

    printf("%s\n", pclu_context_info(pclu));

    pgm  = pclu_create_program(pclu, "kernel.cl");
    char *log = pclu_program_build_log(pgm);
    if (strlen(log) > 0)
        printf("Build log:\n%s\n", log);
}

void
mandelbrot_cl(uint32_t* image, int ww, int hh, float zz, int iters)
{
    size_t image_size = ww * hh * sizeof(uint32_t);
    pclu_buffer *image_buf = pclu_create_buffer(pclu, image_size);

    cl_kernel kernel = pclu_get_kernel(pgm, "mandelbrot");
    pclu_set_arg_buf(kernel, 0, image_buf);
    pclu_set_arg_lit(kernel, 1, ww);
    pclu_set_arg_lit(kernel, 2, hh);
    pclu_set_arg_lit(kernel, 3, XX);
    pclu_set_arg_lit(kernel, 4, YY);
    pclu_set_arg_lit(kernel, 5, zz);
    pclu_set_arg_lit(kernel, 6, iters);

    pclu_range range = pclu_range_2d(hh, ww);
    range.local[0] = 8;
    range.local[1] = 8;
    range.local[2] = 1;

    pclu_call_kernel(pgm, kernel, range);

    pclu_read_buffer(image_buf, image_size, image);

    pclu_destroy_buffer(image_buf);
}

int
main(int argc, char* argv[])
{
    cake_timer tm;
    double tt;

    Display* dd = display_create(WW, HH);
    uint32_t* image = malloc(WW * HH * sizeof(uint32_t));

    int use_cl = (getenv("OPENCL") != 0);

    if (use_cl)
        opencl_setup();

    for (int ii = 0; ii < 500; ++ii) {
        cake_timer_reset(&tm);
        if (use_cl)
            mandelbrot_cl(image, WW, HH, powf(1.028f, ii), 200);
        else    
            mandelbrot(image, WW, HH, XX, YY, powf(1.028f, ii), 200);
        tt = cake_timer_read(&tm);
        printf("mandelbrot time: %.02f\n", tt);

        cake_timer_reset(&tm);
        display_show(dd, image);
        tt = cake_timer_read(&tm);
        printf("display time: %.02f\n", tt);

        display_show(dd, image);
        display_wait(dd, 3);
    }
    
    return 0;
}
