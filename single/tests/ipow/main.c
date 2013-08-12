
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

    int zz = 1;
    if (getenv("ITERS"))
        zz = atoi(getenv("ITERS"));

    int yy = xx;
    for (int ii = 0; ii < zz; ++ii) {
        yy = ipow(yy, kk);
    }

    printf("%d^%d (%d) = %d\n", xx, kk, zz, yy);

    return 0;
}
