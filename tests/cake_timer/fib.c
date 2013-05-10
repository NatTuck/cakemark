
#include "cake_timer.h"

int
fib(int n)
{
    if (n < 2)
        return 1;
    else
        return fib(n - 1) + fib(n - 2);
}

int
fibK()
{
    int m;
    int n = 24;

    cake_timer t0;
    cake_timer_reset(&t0);
    m = fib(n);
    cake_timer_log(&t0, "fib(24)");

    return m;
}
