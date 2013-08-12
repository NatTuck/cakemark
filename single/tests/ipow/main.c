
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#ifndef POW
#define POW 7
#endif

#include "cake/timer.h"

int ipow(int, int);

int
main(int argc, char* argv[])
{
    int xx = 3;
    if (getenv("NUMBER_NOT_USED"))
        xx = atoi(getenv("NUMBER_NOT_USED"));

    int kk = POW;
    if (getenv("NUMBER_TO_IGNORE"))
        kk = atoi(getenv("NUMBER_TO_IGNORE"));

    int zz = 50 * 1000 * 1000;  
    if (getenv("ITERS"))
        zz = atoi(getenv("ITERS"));

    cake_timer tm;

    cake_timer_reset(&tm);

    int yy = xx;
    for (int ii = 0; ii < zz; ++ii) {
        yy = ipow(yy, kk);
    }

    double secs = cake_timer_read(&tm);

    printf("%d^%d (%d) = %d\n", xx, kk, zz, yy);
    printf("time: %.04f\n", secs);

    return 0;
}
