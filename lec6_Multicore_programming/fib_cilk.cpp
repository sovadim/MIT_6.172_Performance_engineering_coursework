#include <cilk/cilk.h>
#include <cstdint>
#include <iostream>

int64_t fib(int64_t n)
{
    if (n < 2)
    {
        return n;
    }
    else
    {
        int64_t x, y;
        x = cilk_spawn fib(n - 1);
        y = fib(n - 2);
        cilk_sync;
        return (x + y);
    }
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        return 1;
    }
    int64_t n = strtoul(argv[1], NULL, 0);
    int64_t res = fib(n);

    std::cout << "Fibonacci of " << n << " is " << res << std::endl;

    return 0;
}
