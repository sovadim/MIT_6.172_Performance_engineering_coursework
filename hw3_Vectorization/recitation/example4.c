// Copyright (c) 2015 MIT License by 6.172 Staff

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define SIZE (1L << 16)

double test(double *restrict a)
{
    size_t i;

    double *x = __builtin_assume_aligned(a, 16);

    double y = 0;

    for (i = 0; i < SIZE; i++)
    {
        y += x[i];
    }
    return y;
}

int main()
{
    double a[SIZE];
    for (int i = 0; i < SIZE; i++)
    {
        a[i] = 1.0 / (i * 1.0 + 1.0);
    }
    double sum = test(a);
    printf("The decimal floating point sum result is: %f\n", sum);
    printf("The raw floating point sum result is: %a\n", sum);

    return 0;
}
