// Copyright (c) 2012 MIT License by 6.172 Staff

#ifndef UTIL_H
#define UTIL_H

#include <assert.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint32_t data_t;

static inline void mem_alloc(data_t **space, int size)
{
    *space = (data_t *)malloc(sizeof(data_t) * size);
    if (*space == NULL)
    {
        printf("out of memory...\n");
    }
}

static inline void mem_free(data_t **space)
{
    free(*space);
    *space = 0;
}

#endif // UTIL_H
