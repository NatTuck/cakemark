
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <alloca.h>
#include <string.h>
#include <gc.h>

#include "cake/lstring.h"
#include "cake/util.h"

typedef struct file_hash_cache {
    size_t size;
    void*  data;
    char*  hash;
} file_hash_cache;

#define MAX_CACHE_SIZE 10
static file_hash_cache cache[MAX_CACHE_SIZE];
static int cache_next = 0;

static
void
cache_put(const char* data, size_t size, const char* hash)
{
    int nn = cache_next;
    cache[nn].size = size;
    cache[nn].data = GC_malloc_atomic(size);
    memcpy(cache[nn].data, data, size);
    cache[nn].hash = lstrdup(hash);
    cache_next = (nn + 1) % MAX_CACHE_SIZE;
}

static
char*
cache_get(const char* data, size_t size)
{
    if (size == 0)
        carp("Why are we looking up a size 0 thing?");

    for (int ii = 0; ii < MAX_CACHE_SIZE; ++ii) {
        if (cache[ii].size != size)
            continue;

        if (memeq(cache[ii].data, data, size))
            return cache[ii].hash;
    }

    return 0;
} 

char*
sha256_file_hex(const char* filename)
{
    size_t data_size;
    void* data = lslurpb(filename, &data_size);
    
    char* hash = cache_get(data, data_size);
    if (hash)
        return hash;
    
    printf("file_hex: Cache miss for file %s\n", filename);

    char* tempname = lstrdup("sha256_XXXXXX");
    int fd = mkstemp(tempname);

    if (fd == -1) {
        perror("mkstemp");
        carp("Giving up");
    }

    char* cmd = lsprintf("sha256sum '%s' > '%s'", filename, tempname);
    int rv = system(cmd);

    if (rv != 0) {
        perror("system");
        carp("Giving up");
    }
    
    FILE* temp = fdopen(fd, "r");

    hash = GC_malloc_atomic(68);
    int count = fread(hash, 64, 1, temp);

    if (count != 1) {
        perror("fread");
        carp("Giving up");
    }

    hash[64] = 0;

    fclose(temp);

    unlink(tempname);

    cache_put(data, data_size, hash);

    return hash;
}
