#ifndef LEAKY_STRING_H
#define LEAKY_STRING_H

#include <stdio.h>

#ifdef __cplusplus
extern "C"
{
#endif

/* Boring string utility functions */
int streq(const char* aa, const char* bb);

/* String operations that assume gc for results. */

char* lstrdup(const char* ss);
char* lstrcat(const char* aa, const char* bb);
char* lsprintf(const char* fmt, ...);
char* lsubstr(const char* ss, int offset, int length);
char* lchomp(const char* ss);

/* IO Operations */
char* lgetline(FILE* file);

/* Vector of strings. */

typedef struct lstrvec {
    int size;
    char** xs;
} lstrvec;

lstrvec* lstrvec_alloc(int size);
int lstrvec_size(lstrvec* vec); 
char* lstrvec_get(lstrvec* vec, int ii);
void lstrvec_set(lstrvec* vec, int ii, char* vv);
int lstrvec_contains(lstrvec* vec, const char* ss);

/* String / Vector Ops */

lstrvec* lwords(const char* ss);

#ifdef __cplusplus
}
#endif

#endif
