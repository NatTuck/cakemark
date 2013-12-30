
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <drip/lstring.h>
#include <drip/lio.h>
#include <drip/carp.h>

const int FUZZ = 5;

void
read_header(FILE* ff)
{
    char* ftype = lgetline(ff);

    if (!streq(ftype, "P2\n"))
        carp("That's not an ASCII PGM");

    int ch;
    while ((ch = fgetc(ff)) == '#') {
        char* _junk = lgetline(ff);
        _junk = _junk;
    }

    ungetc(ch, ff);
}

int
read_int(FILE* ff)
{
    int nn;
    int rv = fscanf(ff, "%d", &nn);
    assert(rv == 1 || rv == EOF);
    return nn;
}

int
main(int argc, char* argv[]) 
{
    if (argc != 3) {
        fprintf(stderr, "Usage:\n  ./fuzzy_check xx.pgm yy.pgm\n");
        return 1;
    }

    FILE* pgm0 = fopen(argv[1], "r");
    FILE* pgm1 = fopen(argv[2], "r");

    if (pgm0 == 0 || pgm1 == 0)
        carp("Failed to open something");

    read_header(pgm0);
    read_header(pgm1);

    while (!feof(pgm0) && !feof(pgm1)) {
        int num0 = read_int(pgm0);
        int num1 = read_int(pgm1);

        if (abs(num0 - num1) > FUZZ) {
            printf("Mismatch: %d != %d\n", num0, num1);
            return 0;
        }
    }

    fclose(pgm1);
    fclose(pgm0);

    printf("[cake: OK]\n");

    return 0;
}
