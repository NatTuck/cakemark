
#include <bsd/string.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <alloca.h>
#include <pcre.h>
#include <gc.h>

#include "cake/spec.h"
#include "cake/lstring.h"
#include "cake/util.h"

static const char* SPEC_MAGIC = "spec01\n";

spec_info*
alloc_spec_info(uint64_t num_args)
{
    spec_info* info = GC_malloc(sizeof(spec_info));
    info->num_args  = num_args;
    info->args      = GC_malloc(num_args * sizeof(spec_arg));
    return info;
}

spec_arg
build_spec_arg(uint64_t spec, const char* name, const char* type,
        uint64_t size, void* value)
{
    spec_arg arg;
    arg.spec = spec;
    arg.name = lstrdup(name);
    arg.type = lstrdup(type);

    if (spec) {
        assert(size > 0);
        arg.size  = size;
        arg.value = GC_malloc_atomic(size);
        memcpy(arg.value, value, size);
    }
    else {
        arg.size  = 0;
        arg.value = 0;
    }

    return arg;
}

static void
write1(const void* data, size_t size, FILE* file)
{
    int count = fwrite(data, size, 1, file);
    if (count != 1) {
        perror(__FILE__ ": write error");
        fflush(stderr);
        abort();
    }
}

static void
read1(void* data, size_t size, FILE* file)
{
    int count = fread(data, size, 1, file);
    if (count != 1) {
        if (feof(file)) {
            fprintf(stderr, __FILE__ ": eof in read\n");
        }
        else {
            perror(__FILE__ ": read error");

        }
        fflush(stderr);
        abort();
    }
}

void
write_spec_info(spec_info* info, const char* filename)
{
    FILE* file = fopen(filename, "w");

    assert(strlen(SPEC_MAGIC) + 1 == 8);
    write1(SPEC_MAGIC, 8, file);
    
    for (int ii = 0; ii < 3; ++ii)
        write1(&(info->global_size[ii]), sizeof(uint64_t), file);
    
    for (int ii = 0; ii < 3; ++ii)
        write1(&(info->global_offset[ii]), sizeof(uint64_t), file);
    
    for (int ii = 0; ii < 3; ++ii)
        write1(&(info->local_size[ii]), sizeof(uint64_t), file);

    write1(&(info->num_args), sizeof(uint64_t), file);

    for (int ii = 0; ii < info->num_args; ++ii) {
        spec_arg* arg = &(info->args[ii]);
        
        write1(&(arg->spec), sizeof(uint64_t), file);

        uint64_t name_len = strlen(arg->name) + 1;
        write1(&name_len, sizeof(uint64_t), file);
        write1(arg->name, name_len, file);

        uint64_t type_len = strlen(arg->type) + 1;
        write1(&type_len, sizeof(uint64_t), file);
        write1(arg->type, type_len, file);
        
        if (arg->spec) {
            write1(&(arg->size), sizeof(uint64_t), file);
            write1(arg->value, arg->size, file);
        }
    }

    fclose(file);
}

spec_info*
read_spec_info(const char* filename)
{
    spec_info* info = alloc_spec_info(0);
    FILE* file = fopen(filename, "r");
    
    char* magic = alloca(8);
    read1(magic, 8, file);
    assert(streq(magic, SPEC_MAGIC));
    
    for (int ii = 0; ii < 3; ++ii)
        read1(&(info->global_size[ii]), sizeof(uint64_t), file);
    
    for (int ii = 0; ii < 3; ++ii)
        read1(&(info->global_offset[ii]), sizeof(uint64_t), file);
    
    for (int ii = 0; ii < 3; ++ii)
        read1(&(info->local_size[ii]), sizeof(uint64_t), file);

    read1(&(info->num_args), sizeof(uint64_t), file);

    info->args = GC_malloc(info->num_args * sizeof(spec_arg));

    for (int ii = 0; ii < info->num_args; ++ii) {
        spec_arg* arg = &(info->args[ii]);
       
        read1(&(arg->spec), sizeof(uint64_t), file);

        uint64_t name_len;
        read1(&name_len, sizeof(uint64_t), file);
        arg->name = GC_malloc_atomic(name_len);
        read1(arg->name, name_len, file);

        uint64_t type_len;
        read1(&type_len, sizeof(uint64_t), file);
        arg->type = GC_malloc_atomic(type_len);
        read1(arg->type, type_len, file);

        if (arg->spec) {
            read1(&(arg->size), sizeof(uint64_t), file);
            arg->value = GC_malloc_atomic(arg->size);
            read1(arg->value, arg->size, file);
        }
    }

    fclose(file);
    return info;
}

spec_info*
parse_spec_text(char** arg_names, int nn, const char* text)
{
    spec_info* info = alloc_spec_info(nn);

    lstrvec* as = lsplitc(',', lstripc(' ', text));

    for (int ii = 0; ii < nn; ++ii) {
        uint64_t spec = 0;
        char*    name = arg_names[ii];
        char*    type = lstrdup("i32");
        uint64_t size = 4;
        void*   value = 0;

        for (int jj = 0; jj < lstrvec_size(as); ++jj) {
            lstrvec* kv = lsplitc('=', lstrvec_get(as, jj));
            
            char* sname = lstrvec_get(kv, 0);
            printf("Name = %s, Sname = %s\n", name, sname);

            if (streq(name, sname)) {
                if (lstrvec_size(kv) == 2) {
                    spec  = 1;
                    value = GC_malloc_atomic(size);
                    *((uint64_t*) value) = atoi(lstrvec_get(kv, 1));
                }
            }
        }

        info->args[ii] = build_spec_arg(spec, name, type, size, value);
    }

    return info;
}

void
print_spec_info(spec_info* info)
{
    printf("== spec_info object: ==\n");
    printf("Global size: %ld %ld %ld\n",
            info->global_size[0], info->global_size[1], info->global_size[2]);
    printf("Global Offset: %ld %ld %ld\n",
            info->global_offset[0], info->global_offset[1], 
            info->global_offset[2]);
    printf("Local size: %ld %ld %ld\n",
            info->local_size[0], info->local_size[1], info->local_size[2]);

    printf("Args: (%ld)\n", info->num_args);

    for (int ii = 0; ii < info->num_args; ++ii) {
        spec_arg* arg = &(info->args[ii]);
        printf("  spec: %ld\n", arg->spec);
        printf("  name: %s\n", arg->name);
        printf("  type: %s\n", arg->type);
        printf("  size: %ld\n", arg->size);
        printf("  data: %s\n", cake_hex_string(arg->value, arg->size));
    }
}

int
cake_spec_enabled()
{
    static int enabled = -1;

    if (enabled == -1) {
        if (getenv("CAKE_SPEC"))
            enabled = 1;
        else
            enabled = 0;
    }

    return enabled;
}

char*
cake_spec_extract(const char* name, const char* source)
{
    const char *re_format = "/*\\s+@spec\\s+%s\\((.*?)\\)..";
    char* re_string;
    int   rv;

    pcre* re;

    const char* re_error;
    int   re_offset;

    const int OVEC_SIZE = 12;
    int   re_ovec[OVEC_SIZE];
    int   rc;

    int   match_size;
    char* match_text;

    /* Build the pattern */
    re_string = lsprintf(re_format, name);

    /* Compile the pattern */
    re = pcre_compile(re_string, 0, &re_error, &re_offset, 0);
    if (re == 0) {
        fprintf(stderr, "cake_spec: bad regex %s @ %d\n", 
                re_error, re_offset);
        fprintf(stderr, "in pattern: [%s]\n", re_string);
        abort();
    }

    char* force_spec = getenv("CAKE_FORCE_SPEC");
    if (force_spec)
        source = force_spec;

    /* Match the pattern in the source */    
    rc = pcre_exec(re, 0, source, strlen(source), 0, 0, re_ovec, OVEC_SIZE);

    switch (rc) {
    case 0:
        fprintf(stderr, "cake_spec: multiple spec annotations for %s\n",
                name);
        abort();
    case -1:
        fprintf(stderr, "cake_spec: no spec annotation for %s\n", name);
        return lstrdup("");
    default:
        if (rc < 0) {
            fprintf(stderr, "cake_spec: error matching spec for %s\n",
                    name);
            abort();
        }
        else {
            /* fprintf(stderr, "cake_spec: too many matches (%d) for %s\n",
                    rc, name); */
        }
    }
    
    /* 2 and 3 is the first paren group */
    match_size = re_ovec[3] - re_ovec[2];
    match_text = alloca(match_size + 2);
    
    /* The C programming language is dumb */
    strncpy(match_text, source + re_ovec[2], match_size);
    match_text[match_size] = 0;

    return lstrdup(match_text);
}

lstrvec*
cake_spec_split(const char* spec)
{
    int nn = strlen(spec);
    int ac = 0;
    int ii, jj, i0;

    lstrvec* vec;

    /* Empty means 0 args */
    if (nn == 0)
        return lstrvec_alloc(0);

    /* Non-empty means ac = 1 + count(commas) */
    ac += 1;

    for (ii = 0; ii < nn; ++ii) {
        if (spec[ii] == ',')
            ac += 1;
    }

    /* Build the vector */
    vec = lstrvec_alloc(ac);

    for (ii = 0, i0 = 0, jj = 0; ii <= nn; ++ii) {
        if (ii == nn || spec[ii] == ',') {
            lstrvec_set(vec, jj, lsubstr(spec, i0, ii - i0));

            i0 = ii;
            while (spec[i0] == ',' || spec[i0] == ' ')
                i0 += 1;

            jj += 1;
        }
    }

    return vec;
}

char*
cake_hex_string(const void* data, size_t size)
{
    if (data == 0) {
        return lstrdup("NULL");
    }

    int ii;
    unsigned char* xx = (unsigned char*) data;
    char* yy = GC_malloc_atomic(2*size + 1);

    for (ii = 0; ii < size; ++ii) {
        snprintf(yy + 2*ii, 3, "%02x", xx[ii]);
    }

    yy[2*size] = 0;

    return yy;
}

void
cake_hex_data(void* data, const char* hex, size_t size)
{
    if (streq(hex, "NULL")) {
        return;
    }

    size_t ii;
    int tmp;
    unsigned char* pp = (char*) data;

    if (strlen(hex) != 2 * size) {
        carp("Size mismatch");
    }

    for (ii = 0; ii < size; ++ii) {
        sscanf(hex + 2*ii, "%02x", &tmp);
        pp[ii] = (unsigned char) tmp;
    }
}
