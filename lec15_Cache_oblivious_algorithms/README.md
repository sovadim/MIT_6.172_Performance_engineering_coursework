# Cache-Oblivious Algorithms

**Heat Diffusion**

**2D heat equation**

Let __u(t, x, y)__ = temperature at time __t__ of point __(x, y)__.

$$ \frac{\partial u}{\partial t} = \alpha (\frac{\partial^2 u}{\partial x^2} + \frac{\partial^2 u}{\partial y^2}) $$

__α__ is the __thermal diffusivity__.

**1D head equation**

$$ \frac{\partial u}{\partial t} = \alpha \frac{\partial^2 u}{\partial x^2} $$

**Finite-Difference Approximation**

$$ \frac{\partial}{\partial t} u(t, x) \approx \frac{u(t + \Delta t, x) - u(t, x)}{\Delta t} $$

$$ \frac{\partial}{\partial x} u(t, x) \approx \frac{u(t, x + \Delta x / 2) - u(t, x - \Delta x / 2)}{\Delta x} $$

$$ \frac{\partial^2}{\partial x^2} u(t, x) \approx \frac{\frac{\partial}{\partial x} u(t, x + \Delta x / 2) - \frac{\partial}{\partial x} u(t, x - \Delta x / 2)}{\Delta x} $$

$$ \approx \frac{u(t, x + \Delta x) - 2u(t, x) + u(t, x - \Delta x)}{(\Delta x)^2} $$

The 1D heat equation thus reduces to

$$ \frac{u(t + \Delta t, x) - u(t, x)}{\Delta t} = \alpha (\frac{u(t, x + \Delta x) - 2u(t, x) + u(t, x - \Delta x)}{(\Delta x)^2}) $$

**3-Point Stencil**

A __Stencil computation__ updates each point in
an array by a fixed pattern, called a __stencil__.

```c
u[t+1][x] = u[t][x] + ALPHA * (u[t][x+1] - 2*u[t][x] + u[t][x-1]);
```

**Cache Behavior of Looping**

```c
double u[2][N]; // even-odd trick

static inline double kernel(double * w) {
    return w[0] + ALPHA * (w[-1] - 2*w[0] + w[1]);
}

for (size_t t = 1; t < T-1; ++t) // time loop
    for (size_t x = 1; x < N-1; ++x) // space loop
        u[(t+1)%2][x] = kernel(&u[t%2][x]);
```

Assuming LRU, if __N > M__, then __Q = Θ(NT/B)__.

**Cache-Oblivious 3-Point Stencil**

Recursively traverse trapezoidal regions of space-time points __(t, x)__ such that

t0 <= t < t1\
x0 + dx0(t-t0) <= x < x1 + dx1(t-t0)\
dx0, dx1 ∈ {-1, 0, 1}

**Base Case**

If __height = 1__, compute all space-time points in the trapezoid.
Any order of computation is valid, since no point depends on another.

**Space Cut**

If __width >= 2*height__, cut the trapezoid with a line
of slope __-1__ through the center. Traverse the
trapezoid on the left first, and then the one on the right.

**Time Cut**

If __width < 2*height__, cut the trapezoid with a
horizontal line through the center. Traverse the
bottom trapezoid first, and then the top one.

**C Implementation**

```c
void trapezoid(int64_t t0, int64_t t1, int64_t x0, int64_t dx0,
               int64_t x1, int64_t dx1)
{
    int64_t lt = t1 - t0;
    if (lt == 1) { // base case
        for (int64_t x = x0; x < x1; ++x)
            u[t1%2][x] = kernel(&u[t0%2][x]);
    } else if (lt > 1) {
        if (2 * (x1 - x0) + (dx1 - dx0) * lt >= 4 * lt) { // space cut
            int64_t xm = (2 * (x0 + x1) + (2 + dx0 + dx1) * lt) / 4;
            trapezoid(t0, t1, x0, dx0, xm, -1);
            trapezoid(t0, t1, xm, -1, x1, dx1);
        } else { // time cut
            int64_t halflt = lt / 2;
            trapezoid(t0, t0 + halflt, x0, dx0, x1, dx1);
            trapezoid(t0 + halflt, t1, x0 + dx0 * haldlt, dx0,
                      x1 + dx1 * halflt, dx1);
        }
    }
}
```

**Cache Analysis**

* Each leaf represents __Θ(hw)__ points, where __h = Θ(w)__.
* Each leaf incurs __Θ(w/B)__ misses, where __w = Θ(M)__.
* __Θ(NT/hw)__ leaves.
* internal nodes = leaves - 1 do not contribute substantially to __Q__.
* __Q = Θ(NT/hw)\*Θ(w/B) = Θ(NT/M^2)\*Θ(M/B) = Θ(NT/MB)__.
* For d dimensions, __Q = Θ(NT/M ^(1/d)B)__.

**Impact on Performance**

**Q.** How can the cache-oblivious trapezoidal
decomposition have so many fewer cache misses,
but the advantage gained over the looping version
be so marginal?

**A.** __Prefetching__ and a good memory architecture. One
core cannot saturate the memory bandwidth.

**Caching and Parallelism**

**Parallel Space Cuts**

A __parallel space cut__ produces two trapezoids that can be executed in parallel
and a third trapezoid that executes in series with the previous trapezoids.

**Impediments to Speedup**

* Insufficient parallelism
* Scheduling overhead
* Lack of memory bandwidth
* Contention (locking and true/false sharing)

Cilkscale can diagnose the first two problems.

**Q.** How can we detect the 3rd?

**A.** Run __P__ identical copies of the serial code in parallel -
if you have enough memory.

Tools exist to detect lock contention in an execution,
but not the __potential__ for lock contention. Potential for
true and false sharing is even harder to detect.

**Cache-Oblivious Sorting**

**Merging Two Sorted Arrays**

```c
void merge(int64_t *C, int64_t *A, int64_t na,
           int64_t *B, int64_t nb) {
    while (na > 0 && nb > 0) {
        if (*A <= *B) {
            *C++ = *A++;
            na--;
        } else {
            *C++ = *B++;
            nb--;
        }
    }
    while (na > 0) {
        *C++ = *A++;
        na--;
    }
    while (nb > 0) {
        *C++ = *B++;
        nb--;
    }
}
```

Time to merge __n__ elements = __Θ(n)__.

Number of cache misses = __Θ(n/B)__.

```c
void merge_sort(int64_t *B, int64_t *A, int64_t n) {
    if (n == 1) {
        B[0] = A[0];
    } else {
        int64_t C[n];
        cilk_spawn merge_sort(C, A, n/2);
                   merge_sort(C+n/2, A+n/2, n-n/2);
        cilk_sync;
        merge(B, C, n/2, C+n/2, n-n/2);
    }
}
```

**Work of Merge Sort**

Work: W(n) = 2W(n/2) + Θ(n) = Θ(n lg n)

**Caching**

Merge subroutine

Q(n) = Θ(n/B)

Merge sort
```
Q(n) = | Θ(n/B)            if n <= cM, constant c <= 1;
       | 2Q(n/2) + Θ(n/B)  otherwise.
```

* For __n >> M__, we have __lg(n/M) ≈ lg n__, thus __W(n)/Q(n) ≈ Θ(B)__.
* For __n ≈ M__, we have __lg(n/M) ≈ Θ(1)__, thus __W(n)/Q(n) ≈ Θ(B lg n)__.

...\
multiwway merge sort\
...
