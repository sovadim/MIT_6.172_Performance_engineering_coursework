#include <inttypes.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

int64_t fib(int64_t n)
{
    if (n < 2)
    {
        return n;
    }
    else
    {
        int64_t x = fib(n - 1);
        int64_t y = fib(n - 2);
        return (x + y);
    }
}

typedef struct
{
    int64_t input;
    int64_t output;
} thread_args;

void *thread_func(void *ptr)
{
    int64_t i = ((thread_args *)ptr)->input;
    ((thread_args *)ptr)->output = fib(i);
    return NULL;
}

int main(int argc, char *argv[])
{
    pthread_t thread;
    thread_args args;
    int status;
    int64_t result;

    if (argc < 2)
    {
        return 1;
    }

    int64_t n = strtoul(argv[1], NULL, 0);

    if (n < 30)
    {
        result = fib(n);
    }
    else
    {
        args.input = n - 1;
        status = pthread_create(&thread, NULL, thread_func, (void *)&args);

        if (status != 0)
        {
            return 1;
        }
        result = fib(n - 2);

        status = pthread_join(thread, NULL);
        if (status != 0)
        {
            return 1;
        }

        result += args.output;
    }

    printf("Fibbonacci of %" PRId64 " is %" PRId64 ".\n", n, result);

    return 0;
}
