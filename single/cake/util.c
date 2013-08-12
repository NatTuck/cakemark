
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alloca.h>
#include <string.h>

#include "cake/lstring.h"
#include "cake/util.h"

void
cake_carp(const char* file, int line, const char* msg)
{
    fprintf(stderr, "\n carp at %s:%d\n%s\n\n", file, line, msg);
    fflush(stderr);
    fflush(stdout);
    abort();
}

int
memeq(const void* aa, const void* bb, size_t nn)
{
    return memcmp(aa, bb, nn) == 0;
}
