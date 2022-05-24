/*
# clang-12 matrix_mult.c -o matrix_mult
# ./matrix_mult

Measuring cache miss rate
# valgrind --tool=cachegrind ./matrix_mult

Optimization flags
-O2 gives about x3 speed-up

Compiling with vectorization
clang-12 matrix_mult.c -o matrix_mult -O3 -std=c99 -Rpass=vector

Vectorization flags:
* -mavx
* -mavx2
* -mfma
* -march=<string>
* -march=native
/ -ffast-math might be needed for these flags to have an effect

Memory access analysis
* 4096 * 1 = 4096 writes to C;
* 4096 * 1 = 4096 reads from A;
* 4096 * 4096 = 16,777,216 reads from B;
* 16,785,408 memory accesses total.

*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define n 4096

double A[n][n];
double B[n][n];
double C[n][n];

float tdiff(struct timeval *start, struct timeval *end)
{
    return (end->tv_sec - start->tv_sec) + 1e-6 * (end->tv_usec - start->tv_usec);
}

int main(int argc, const char *argv[])
{
    for (int i = 0; i < n; ++i)
    {
        for (int j = 0; j < n; ++j)
        {
            A[i][j] = (double)rand() / (double)RAND_MAX;
            B[i][j] = (double)rand() / (double)RAND_MAX;
            C[i][j] = 0;
        }
    }

    struct timeval start, end;
    gettimeofday(&start, NULL);

    // Reordering loops to [i, k, j] can give x10 time speed-up
    // It gives about 1% of cache misses, less than other loop permutations
    for (int i = 0; i < n; ++i)
    {
        for (int k = 0; k < n; ++k)
        {
            for (int j = 0; j < n; ++j)
            {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    gettimeofday(&end, NULL);
    printf("%0.6f\n", tdiff(&start, &end)); // Supposed to be 19 mins. x18 faster than Python

    return 0;
}
