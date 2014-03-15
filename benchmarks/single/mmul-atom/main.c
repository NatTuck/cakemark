
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#define CAKE_TIMER_FAST_LINK 1
#include "timer.h"

#ifndef NN
#define NN 256
#endif

#define SIZE (NN * NN * sizeof(double))

void mmul(double*, double*, double*, int);

double
rand48()
{
    static unsigned short seed[3] = { 50, 461, 0 };
    static int seeded = 0;

    if (seeded == 0) {
        seed[2] = (short)getpid();
        seeded = 1;
    }

    return (double) erand48(seed);
}

double*
alloc_matrix()
{
    double* mm = (double*) malloc(SIZE);
    for (int ii = 0; ii < (NN * NN); ++ii)
        mm[ii] = 0.0;
    return mm;
}

double*
alloc_identity_matrix()
{
    double* mm = alloc_matrix();
    
    for (int ii = 0; ii < NN; ++ii)
        mm[ii * NN + ii] = 1.0;

    return mm;
}

double*
alloc_random_matrix()
{
    double* mm = alloc_matrix();

    for (int ii = 0; ii < (NN * NN); ++ii)
        mm[ii] = rand48();

    return mm;
}

int
matrix_eq(double* aa, double* bb)
{
    for (int ii = 0; ii < (NN * NN); ++ii) {
        if (aa[ii] != bb[ii]) {
            printf("Error at %d: %.02f != %.02f\n",
                    ii, aa[ii], bb[ii]);
            return 0;
        }
    }

    return 1;
}

void
print_matrix(double* mm)
{
    for (int ii = 0; ii < NN; ++ii) {
        for (int jj = 0; jj < NN; ++jj) {
            printf("%.02f ", mm[ii * NN + jj]);
        }
        printf("\n");
    }
    printf("\n");
}

int
main(int argc, char* argv[])
{
    int nn = NN;

    if (getenv("NUMBER_NOT_USED"))
        nn = atoi(getenv("NUMBER_NOT_USED"));
    
    double* aa = alloc_random_matrix();
    double* bb = alloc_identity_matrix();
    double* cc = alloc_matrix();

    cake_timer tm;
    cake_timer_reset(&tm);
  
    mmul(cc, bb, aa, nn);

    double secs = cake_timer_read(&tm);

#if 0
    printf("aa\n");
    print_matrix(aa);
    printf("bb\n");
    print_matrix(bb);
    printf("cc\n");
    print_matrix(cc);
#endif


    if (matrix_eq(aa, cc))
        printf("[cake: OK]\nresult good\n");
    else
        printf("result bad =(\n");

    printf("time: %.04f\n", secs);
    
    free(bb);
    free(aa);
    free(cc);

    return 0;
}
