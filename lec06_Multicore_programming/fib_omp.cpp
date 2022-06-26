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
#pragma omp task shared(x, n)
        x = fib(n - 1);
#pragma omp task shared(y, n)
        y = fib(n - 2);
#pragma omp taskwait
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
