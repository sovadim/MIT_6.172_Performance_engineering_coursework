#ifndef SORT_M_H
#define SORT_M_H

/**
 * Copyright (c) 2012 MIT License by 6.172 Staff
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 **/

#include "./isort.h"
#include "./util.h"

// Function prototypes
static inline void merge_m(data_t *A, int p, int q, int r);
static inline void copy_m(data_t *source, data_t *dest, int n);

// A basic merge sort routine that sorts the subarray A[p..r]
static inline void sort_m(data_t *A, int p, int r)
{
    assert(A);
    const int BASE = 10;
    if (r - p > BASE)
    {
        int q = (p + r) / 2;
        sort_m(A, p, q);
        sort_m(A, q + 1, r);
        merge_m(A, p, q, r);
    }
    else
    {
        isort(&A[p], &A[r]);
    }
}

static inline void merge_m(data_t *A, int p, int q, int r)
{
    assert(A);
    assert(p <= q);
    assert((q + 1) <= r);
    const int n1 = q - p + 1;
    const int n2 = r - q;

    data_t *buffer = 0;
    mem_alloc(&buffer, n1 + 1);
    if (buffer == NULL)
    {
        mem_free(&buffer);
        return;
    }

    copy_m(&(A[p]), buffer, n1);
    buffer[n1] = UINT_MAX;

    int i = 0;
    int j = 0;

    for (int k = p; k <= r; k++)
    {
        if (buffer[i] <= A[n1 + j] || j >= n2)
        {
            A[k] = buffer[i];
            i++;
        }
        else
        {
            A[k] = A[n1 + j];
            j++;
        }
    }
    mem_free(&buffer);
}

static inline void copy_m(data_t *source, data_t *dest, int n)
{
    assert(dest);
    assert(source);

    for (int i = 0; i < n; i++)
    {
        dest[i] = source[i];
    }
}

#endif // SORT_M_H
