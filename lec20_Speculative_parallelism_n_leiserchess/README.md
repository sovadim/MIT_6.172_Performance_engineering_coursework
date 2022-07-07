# Speculative Parallelism & Leiserchess

**Thresholding a Sum**

```c
bool sum_exceeds(size_t *A, size_t n, size_t limit) {
    size_t sum = 0;
    for (size_t i = 0; i < n; ++i) {
        sum += A[i];
    }
    return sum > limit;
}
```

```c
bool sum_exceeds(size_t *A, size_t n, size_t limit) {
    size_t sum;
    CILK_C_REDUCER_OPADD(sum, size_t, 0);
    CILK_C_REGISTER_REDUCER(sum);
    cilk_for (size_t i = 0; i < n; ++i) {
        REDUCER_VIEW(sum) += A[i];
    }
    CILK_C_UNREGISTER_REDUCER(sum);
    return REDUCER_VIEW(sum) > limit;
}
```

Question:\
How can we parallelize a short-circuited loop?

**Divide-and-Conquer Loop**

```c
size_t sum_of(size_t *A, size_t n) {
    if (n > 1) {
        size_t s1 = cilk_spawn sum_of(A, n/2);
        size_t s2 = sum_of(A + n/2, n - n/2);
        cilk_sync;
        size_t sum = s1 + s2;
        return sum;
    }
    return A[0];
}

bool sum_exceeds(size_t *A, size_t n, size_t limit) {
    return sum_of(A, n) > limit;
}
```

How might we quit early and save work if
the partial sum exceeds the threshold?

**Short-Circuiting in Parallel**

```c
size_t sum_of(size_t *A, size_t n, size_t limit, bool *abort_flag) {
    if (*abort_flag) return 0;
    if (n > 1) {
        size_t s1 = cilk_spawn sum_of(A, n/2, limit, abort_flag);
        size_t s2 = sum_of(A + n/2, n - n/2, limit, abort_flag);
        cilk_sync;
        size_t sum = s1 + s2;
        if (sum > limit && !abort_flag) *abort_flag = true;
        return sum;
    }
    return A[0];
}

bool sum_exceeds(size_t *A, size_t n, size_t limit) {
    bool abort_flag = false;
    return sum_of(A, n, limit, &abort_flag) > limit;
}
```

Notes:
* Nondeterministic code!
* The benign race in ```abort_flag``` can cause
true-sharing contention if you are not careful.
* Don't forget to reset ```abort_flag``` after use.
* Is a memory fence necessary?

**Speculative Parallelism**

**Definition.** __Speculative parallelism__ occurs when
a program spawns some parallel work that might
not be performed in a serial execution.

**Rule of Thumb:** Don't spawn speculative work
unless there is little other opportunity for
parallelism and there is a good chance it will be needed.

More project 4 insights since this moment.
