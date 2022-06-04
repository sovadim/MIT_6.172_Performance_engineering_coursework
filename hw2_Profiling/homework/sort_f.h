#ifndef SORT_F_H
#define SORT_F_H

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

// static data_t *buffer = 0;

// Function prototypes
static inline void sort_f_impl(data_t *A, int p, int r, data_t *buffer);
static inline void merge_f(data_t *A, int p, int q, int r, data_t *buffer);
static inline void copy_f(data_t *source, data_t *dest, int n);

// A basic merge sort routine that sorts the subarray A[p..r]
static inline void sort_f(data_t *A, int p, int r)
{
    assert(A);

    data_t *buffer = 0;
    const int n1 = (p + r) / 2 - p + 1;
    mem_alloc(&buffer, n1 + 1);
    if (buffer == NULL)
    {
        mem_free(&buffer);
        return;
    }

    sort_f_impl(A, p, r, buffer);

    mem_free(&buffer);
}

static inline void sort_f_impl(data_t *A, int p, int r, data_t *buffer)
{
    static const int BASE = 10;
    if (r - p > BASE)
    {
        int q = (p + r) / 2;
        sort_f_impl(A, p, q, buffer);
        sort_f_impl(A, q + 1, r, buffer);
        merge_f(A, p, q, r, buffer);
    }
    else
    {
        isort(&A[p], &A[r]);
    }
}

static inline void merge_f(data_t *A, int p, int q, int r, data_t *buffer)
{
    assert(A);
    assert(p <= q);
    assert((q + 1) <= r);
    const int n1 = q - p + 1;
    const int n2 = r - q;

    copy_f(&(A[p]), buffer, n1);
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
}

static inline void copy_f(data_t *source, data_t *dest, int n)
{
    assert(dest);
    assert(source);

    for (int i = 0; i < n; i++)
    {
        dest[i] = source[i];
    }
}

#endif // SORT_F_H
