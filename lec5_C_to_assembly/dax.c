#include <inttypes.h>

void dax(double *restrict y, double a, const double *restrict x, int64_t n)
{
    for (int64_t i = 0; i < n; ++i)
    {
        y[i] = a * x[i];
    }
}
