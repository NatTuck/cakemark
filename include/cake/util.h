#ifndef CAKE_UTIL_H
#define CAKE_UTIL_H

#ifdef __cplusplus
extern "C"
{
#endif

#define carp(msg) cake_carp(__FILE__, __LINE__, (msg))

void cake_carp(const char* file, int line, const char* msg);

int memeq(const void* aa, const void* bb, size_t nn);

#ifdef __cplusplus
}
#endif

#endif
