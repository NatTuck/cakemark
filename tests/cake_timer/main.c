
#include <unistd.h>
#include <time.h>

#define CAKE_TIMER_MAIN 1
#include "cake_timer.h"

extern int fib10();

int
main(int argc, char* argv[])
{
    printf("Cake timer test cases.\n");
    printf(" - uSleep for 320 ms.\n");

    cake_timer t0;

    cake_timer_reset(&t0);
    usleep(320);
    cake_timer_log(&t0, "usleep(320)");

    cake_timer_reset(&t0);
    usleep(9001);
    cake_timer_log(&t0, "usleep(9001)");

    cake_timer_reset(&t0);
    usleep(1);
    cake_timer_log(&t0, "usleep(1)");

    struct timespec ts;
    ts.tv_sec  = 0;
    
    cake_timer_reset(&t0);
    ts.tv_nsec = 1;
    nanosleep(&ts, 0);
    cake_timer_log(&t0, "nanosleep(1)");

    cake_timer_note("nanosleep coming up");

    cake_timer_reset(&t0);
    ts.tv_nsec = 1;
    clock_nanosleep(CLOCK_MONOTONIC, 0, &ts, 0);
    cake_timer_log(&t0, "clock_nanosleep(1)");

    printf("fib(k) = %d\n", fibK());

    return 0;
}
