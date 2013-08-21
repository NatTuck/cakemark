
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <alloca.h>
#include <assert.h>

#include "pclu.h"

#define LOAD_BINARY 1

#define COUNT 64
#define SIZE  (COUNT * sizeof(cl_uint))

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

void
cl_get_ids(pclu_context* pclu, cl_int* ids)
{
#if LOAD_BINARY
    pclu_program* pgm = pclu_load_binary(pclu, "get_ids.s");
#else
    pclu_program* pgm = pclu_create_program(pclu, "get_ids.cl");

    char *log = pclu_program_build_log(pgm);
    if (strlen(log) > 0)
        printf("Build log:\n%s\n", log);
#endif

    pclu_buffer* ids_buf = pclu_create_buffer(pclu, SIZE);
    pclu_write_buffer(ids_buf, SIZE, ids);

    pclu_range range = pclu_range_1d(COUNT);

    /* Blur horizontally */
    cl_kernel get_ids = pclu_get_kernel(pgm, "get_ids");
    pclu_set_arg_buf(get_ids, 0, ids_buf);

    pclu_call_kernel(pgm, get_ids, range);

    pclu_read_buffer(ids_buf, SIZE, ids);

    pclu_destroy_program(pgm);
}

int
main(int argc, char* argv[])
{
    pclu_context* pclu = pclu_create_context();
    printf("\n%s\n", pclu_context_info(pclu));

    cl_int ids[COUNT];

    cl_get_ids(pclu, &(ids[0]));

    for (int ii = 0; ii < COUNT; ++ii) {
        printf("%d ", ids[ii]);
    }

    printf("\n");

    pclu_destroy_context(pclu);
    return 0;
}
