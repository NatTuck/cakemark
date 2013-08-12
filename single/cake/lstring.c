

#include <bsd/string.h>
#include <string.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include <gc.h>

#include "cake/lstring.h"

/* Extra common string functions */

int 
streq(const char* aa, const char* bb)
{
    return strcmp(aa, bb) == 0;
}

/* Leaky versions of common string ops */

char*
lstrdup(const char* aa)
{
    size_t size = strlen(aa) + 1;
    char* bb = (char*) GC_malloc_atomic(size);
    strlcpy(bb, aa, size);
    return bb;
}

char*
lstrcat(const char* aa, const char* bb)
{
    size_t size = strlen(aa) + strlen(bb) + 1;
    char* cc = (char*) GC_malloc_atomic(size);

    cc[0] = 0;
    strlcat(cc, aa, size);
    strlcat(cc, bb, size);

    return cc;
}

char*
lsprintf(const char* fmt, ...)
{
    va_list ap1;
    va_list ap2;

    va_start(ap1, fmt);
    va_copy(ap2, ap1);

    int   size = 1 + vsnprintf(0, 0, fmt, ap1);
    char* outp = (char*) GC_malloc_atomic(size);

    vsnprintf(outp, size, fmt, ap2);

    va_end(ap1);
    va_end(ap2);

    return outp;
}

char* 
lsubstr(const char* ss, int offset, int length)
{
    char* yy = GC_malloc_atomic(length + 1);
    int ii;

    for (ii = 0; ii < length; ++ii) {
        yy[ii] = ss[ii + offset];
    }

    yy[length] = 0;

    return yy;
}

char*
lchomp(const char* ss)
{
    char* yy = lstrdup(ss);
    int nn = strlen(yy);
    int ii = nn - 1;

    while (yy[ii] == '\n') {
        yy[ii] = '\0';
        ii -= 1;
    }

    return yy;
}

char*
lstripc(const char cc, const char* ss)
{
    char* yy = alloca(strlen(ss) + 2);

    int jj = 0;
    for (int ii = 0; ii < strlen(ss); ++ii) {
        if (ss[ii] != cc) {
            yy[jj] = ss[ii];
            jj += 1;
        }
    }
    yy[jj] = 0;

    return lstrdup(yy);
}

/* Some stuff on void*'s */

void*
lmemcpy(void* src, size_t n)
{
    void* dest = GC_malloc(n);
    memcpy(dest, src, n);
    return dest;
}

/* FILE* using I/O ops */

char*
lgetline(FILE* file)
{
    char*  temp = 0;
    size_t zero = 0;

    if (getline(&temp, &zero, file) == -1) {
        if (feof(file)) {
            return 0;
        }
        else {
            perror("getline in lgetline");
            fflush(stderr);
            abort();
        }
    }

    char* line = lstrdup(temp);
    free(temp);
    return line;
}

char*
lslurp(const char* filename)
{
    size_t ignored;
    return (char*) lslurpb(filename, &ignored);
}

void*
lslurpb(const char* filename, size_t* size_return)
{
    const size_t BS = 1024;
    void* block = alloca(BS);
    void* data  = GC_malloc_atomic(1);

    size_t count = 0;
    size_t size  = 0;

    FILE* file = fopen(filename, "r");

    while ((count = fread(block, 1, BS, file))) {
        data = GC_realloc(data, size + count);
        memcpy(data + size, block, count);
        size += count;
    }

    if (!feof(file)) {
        perror("Read error in lslurpb");
        fflush(stderr);
        abort();
    }

    fclose(file);

    *size_return = size;
    return data;
}

/* Leaky String Vectors */

lstrvec* 
lstrvec_alloc(int size)
{
    lstrvec* vec = GC_malloc(sizeof(lstrvec));
    vec->size = size;
    if (size != 0)
        vec->xs   = GC_malloc(size * sizeof(char*));
    return vec;
}

int
lstrvec_size(lstrvec* vec)
{
    return vec->size;
}

char*
lstrvec_get(lstrvec* vec, int ii)
{
    if (ii < 0 || ii > vec->size - 1) {
        fprintf(stderr, "lstrvec: Out of bounds get(%d) (size = %d).\n",
                ii, vec->size);
        abort();
    }

    return lstrdup(vec->xs[ii]);
}

void
lstrvec_set(lstrvec* vec, int ii, char* vv)
{
    if (ii < 0 || ii > vec->size - 1) {
        fprintf(stderr, "lstrvec: Out of bounds get(%d) (size = %d).\n",
                ii, vec->size);
        abort();
    }

    vec->xs[ii] = lstrdup(vv);
}

int 
lstrvec_contains(lstrvec* vec, const char* ss)
{
    int ii;

    for (ii = 0; ii < vec->size; ++ii) {
        if (streq(ss, vec->xs[ii]))
            return 1;
    }

    return 0;
}

/* String / Vector Ops */

lstrvec*
lwords(const char* ss)
{
    char* aa = lstrdup(ss);
    int ii, jj;
    int nn = strlen(aa);
    int spaces = 0;

    lstrvec* xs;
    
    /* How many spaces? */
    for (ii = 0; ii < nn; ++ii) {
        if (aa[ii] == ' ') {
            aa[ii] = '\0';
            spaces += 1;

            while (aa[ii + 1] == ' ') {
                ii += 1;
                aa[ii] = '\0';
            }
        }
    }

    xs = lstrvec_alloc(spaces + 1);

    for (ii = 0; ii < spaces + 1; ++ii) {
        lstrvec_set(xs, ii, lstrdup(aa));
        
        aa += strlen(aa);
        while(aa[0] == '\0')
            aa += 1;
    }

    return xs;
}

lstrvec*
lsplitc(const char cc, const char* ss)
{
    char* aa = lstrdup(ss);
    int ii, jj;
    int nn = strlen(aa);
    int slots = 1;

    lstrvec* xs;
    
    /* How many pieces? */
    for (ii = 0; ii < nn; ++ii) {
        if (aa[ii] == cc) {
            aa[ii] = '\0';
            slots += 1;
        }
    }

    xs = lstrvec_alloc(slots);

    for (ii = 0; ii < slots; ++ii) {
        lstrvec_set(xs, ii, lstrdup(aa));
        
        aa += strlen(aa);
        while(aa[0] == '\0')
            aa += 1;
    }

    return xs;
}
