
#include <stdint.h>
#include <stdio.h>
#include <pthread.h>
#include <assert.h>

#ifndef THREADS
#define THREADS 4
#endif

typedef struct mb_job_info {
    int job;
    int ww;
    int hh;
    float xc;
    float yc;
    float zz;
    int max;
    uint32_t* image;
} mb_job_info;

uint32_t
mb_iterate(int ww, int hh, int ii, int jj, float xc, float yc, float zz, int max) 
{
    float x0 = (3.5f * ((float)jj/(float)ww) - 2.5f) / zz - xc;
    float y0 = (2.0f * ((float)ii/(float)hh) - 1.0f) / zz - yc;

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

void* 
mb_job_main(void* info_ptr)
{
    mb_job_info* info = (mb_job_info*)info_ptr;

    for (int ii = info->job; ii < info->hh; ii += THREADS) {
        for (int jj = 0; jj < info->ww; ++jj) {
            uint32_t iters = mb_iterate(info->ww, info->hh, ii, jj, info->xc, 
                    info->yc, info->zz, info->max);
            info->image[ii * info->ww + jj] = iters * (2 << 25) / (info->max + 2);
        }
    }

    return 0;
}

void
mandelbrot(uint32_t* image, int ww, int hh, float xx, float yy, float zz, int max)
{
    pthread_t   jobs[THREADS];
    mb_job_info infos[THREADS];
    int rv, ii;
    
    printf("mandelbrot at %.04f, %.04f * %.04f\n", xx, yy, zz);

    for (ii = 0; ii < THREADS; ++ii) {
        infos[ii].job = ii;
        infos[ii].ww = ww;
        infos[ii].hh = hh;
        infos[ii].xc = xx;
        infos[ii].yc = yy;
        infos[ii].zz = zz;
        infos[ii].max = max;
        infos[ii].image = image;

        rv = pthread_create(&(jobs[ii]), 0, mb_job_main, &(infos[ii]));
        assert(rv == 0);
    }

    for (ii = 0; ii < THREADS; ++ii) {
        rv = pthread_join(jobs[ii], 0);
        assert(rv == 0);
    }
}
