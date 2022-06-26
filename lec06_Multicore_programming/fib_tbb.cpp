#include <cstdint>
#include <iostream>
#include <oneapi/tbb/parallel_invoke.h>
#include <oneapi/tbb/task_group.h>

class FibTask
{
public:
    FibTask(int64_t n_, int64_t *sum_) : n(n_), sum(sum_)
    {
    }

    void operator()() const
    {
        if (n < 2)
        {
            *sum = n;
        }
        else
        {
            int64_t x, y;
            oneapi::tbb::parallel_invoke(FibTask(n - 1, &x), FibTask(n - 2, &y));
            *sum = x + y;
        }
    }

private:
    const int64_t n;
    int64_t *const sum;
};

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        return 1;
    }
    int64_t n = strtoul(argv[1], NULL, 0);
    int64_t res;

    FibTask(n, &res)();

    std::cout << "Fibonacci of " << n << " is " << res << std::endl;

    return 0;
}
