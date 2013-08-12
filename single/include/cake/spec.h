#ifndef CAKE_SPEC_H
#define CAKE_SPEC_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

#include "lstring.h"

typedef struct spec_arg {
    uint64_t spec; // 8 bytes for a boolean
    char* name;
    char* type;
    uint64_t size;
    void* value;
} spec_arg;

typedef struct spec_info {
    uint64_t global_size[3];
    uint64_t global_offset[3];
    uint64_t local_size[3];
    uint64_t num_args;
    spec_arg* args;
} spec_info;

spec_info* alloc_spec_info(size_t num_args);
spec_arg   build_spec_arg(uint64_t spec, const char* name, const char* type,
        uint64_t size, void* value);

void write_spec_info(spec_info* info, const char* filename);
spec_info* read_spec_info(const char* filename);
void print_spec_info(spec_info* info);

spec_info* parse_spec_text(char** arg_names, int arg_count, const char* text);

int cake_spec_enabled();
char* cake_spec_extract(const char* name, const char* source);
lstrvec* cake_spec_split(const char* spec);
char* cake_hex_string(const void* data, size_t size);
void cake_hex_data(void* data, const char* hex, size_t size);

#ifdef __cplusplus
}
#endif

#endif
