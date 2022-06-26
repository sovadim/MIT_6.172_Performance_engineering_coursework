# Analysis of Multithreaded Algorithms

**The Master Method**

The __Master Method__ for solving divide-and-conquer recurrences applies to recurrences of the form
```
T(n) = aT(n/b) + f(n)
```
where __a >= 1__, __b > 1__, and __f__ is asymptotically positive.

**Recursion Tree: T(n) = aT(n/b) + f(n)**

```
  A                   f(n) -------------------- f(n)
  |                 /  | __\___a
h = log b(n)      /    |    \
  |         f(n/b)   f(n/b)..f(n/b) ---------- af(n)
  |        /  |__\__a
  |      /    |    \
  |  f(n/b^2)...f(n/b^2) ------------------- a^2f(n)
  |      /
  |     :                                       :
  |    /
  V  T(1) -------------------------- a^log b(n) T(1)
```

IDEA: Compare n^log b(a) with f(n).

**Master Method - Case 1**

```
n^log b(a) >> f(n)
```

Geometrically increasing

T(n) = Θ(n^log b(a))

**Master Method - Case 2**

```
n^log b(a) ≈ f(n)
```

Arithmetically increasing

T(n) = Θ(n^log b(a) * lg^(k+1) (n))

**Master Method - Case 3**

```
n^log b(a) << f(n)
```

Geometrically decreasing

T(n) = Θ(f(n))

**Loop Parallelism in Cilk**

Example: in-place matrix transpose

```c++
cilk_for(int i = 1; i < n; ++i) {
    for (int j = 0; j < i; ++j) {
        double temp = A[i][j];
        A[i][j] = A[j][i];
        A[j][i] = temp;
    }
}
```

**Implementation of Parallel Loops**

Divide-and-conquer implementation

The Tapir/LLVM compiler implements ```cilk_for``` loops this way
at optimization level __-O1__ or higher.

```c++

void recur(int lo, int hi) { // half open
    if (hi > lo + 1) {
        int mid = lo + (hi - lo) / 2;
        cilk_spawn recur(lo, mid);
        recur(mid, hi);
        cilk_sync;
        return;
    }
    int i = lo;
    for (int j = 0; j < i; ++j) {
        double temp = A[i][j];
        A[i][j] = A[j][i];
        A[j][i] = temp;
    }
}
:
recur(1, n);
```

**Analysis of Parallel Loops**

Work: T1(n) = Θ(n^2)\
Span: Tinf(n) = Θ(n + lg n) = Θ(n)\
Parallelism: T1(n) / Tinf(n) = Θ(n)

Span of loop control = Θ(lg n)\
Max span of body = Θ(n)

**Analysis of Nested Parallel Loops**

```c++
cilk_for(int i = 1; i < n; ++i) {
    cilk_for(int j = 0; j < i; ++j) {
        double temp = A[i][j];
        A[i][j] = A[j][i];
        A[j][i] = temp;
    }
}
```

Work: T1(n) = Θ(n^2)\
Span: Tinf(n) = Θ(lg n)\
Parallelism: T1(n) / Tinf(n) = Θ(n^2 / lg n)

Span of outer loop control = Θ(lg n)\
Max span of inner loop control = Θ(lg n)\
Span of body = Θ(1)

**A closer Look at Parallel Loops**

Vector addition
```c++
cilk_for(int i = 0; i < n; ++i) {
    A[i] += B[i];
}
```

Work: T1(n) = Θ(n)\
Span: Tinf(n) = Θ(lg n)\
Parallelism: T1(n) / Tinf(n) = Θ(n / lg n)

**Coarsening Parallel Loops**

```c++
#pragma cilk grainsize G
cilk_for(int i = 0; i < n; ++i) {
    A[i] += B[i];
}
```

__Implementation with coarsening__
```c++
void recur() { // half open
    if (hi > lo + G) {
        int mid = lo + (hi - lo) / 2;
        cilk_spawn recur(lo, mid);
        recur(mid, hi);
        cilk_sync;
        return;
    }
    for (int i = lo; i < hi; ++i) {
        A[i] += B[i];
    }
}
:
recur(0, n);
```

If a grainsize pragma is not specified, the Cilk runtime system
makes its best guess to minimize overhead.

**Loop Grain Size**

Let __I__ be the time for one iteration of the loop body.\
Let __G__ be a grain size.\
Let __S__ be the time to perform a spawn and return.

Work: T1 = n \* I = (n/G - 1) \* S\
Span: Tinf = G \* I + lg(n/G) \* S\

Want G >> S/I and G small.

**Another Implementation**

```c++
void vadd(double *A, double *B, int n) {
    for (int i = 0; i < n; ++i) {
        A[i] += B[i];
    }
}
:
for (int j = 0; j < n; j += G) {
    cilk_spawn vadd(A + j, B + j, MIN(G, n - j));
}
cilk_sync;
```

Assume that G = 1

Work: T1 = Θ(n)\
Span: Ting = Θ(n)\
Parallelism: T1/Tinf = Θ(1)

Analyze in terms of G:

Work: T1 = Θ(n)\
Span: Ting = Θ(G + n/G) = Θ(sqrt(n)) // Choose G = sqrt(n) to minimize\
Parallelism: T1/Tinf = Θ(sqrt(n))

**The Performance Tips**

1. __Minimize the span__ to maximize parallelism.
Try to generate 10 times more parallelism than processors
for near-perfect linear speedup.

2. If you have plenty of parallelism, try to trade some of it off to reduce __work overhead__.

3. Use __divide-and-conquer recursion__ or __parallel loops__
rather than spawning one small thing after another.

__Do this:__
```c++
cilk_for (int i = 0; i < n; ++i) {
    foo(i);
}
```

__Not this:__
```c++
for (int i = 0; i < n; ++i) {
    cilk_spawn foo(i);
}
cilk_sync;
```

4. Ensure that work/spawns is sufficiently large.

5. Parallelize __outer loops__, as opposed to inner loops,
if you're focused to make a choice.

6. Watch out for __scheduling overheads__.

__Do this:__
```c++
cilk_for (int i = 0; i < 2; ++i) {
    for (int j = 0; j < n; ++j) {
        f(i, j);
    }
}
```

__Not this:__
```c++
for (int i = 0; i < 2; ++i) {
    cilk_for (int j = 0; j < n; ++j) {
        f(i, j);
    }
}
```

**Parallelizing Matrix Multiply**

```c++
cilk_for (int i = 0; i < n; ++i) {
    cilk_for (int j = 0; j < n; ++j) {
        for (int k = 0; k < n; ++k) {
            C[i][j] += A[i][k] * B[k][j];
        }
    }
}
```

Work: T1(n) = Θ(n^3)\
Span: Tinf(n) = Θ(n)\
Parallelism: T1(n)/Tinf(n) = Θ(n^2)

For 1000x1000 matrices, parallelism ≈ (10^3)^2 = 10^6.

**Recursive Matrix Multiplication**

**Divide and conquer** - uses cache more efficiently.

8 multiplications of n/2 x n/2 matrices.\
1 addition of n x n matrices.

**Representation of Submatrices**

**Row-major layout**

If __M__ is an __n x n__ submatrix of an underlying matrix with
row size __nM__, then the __(i, j)__ element of __M__ is __M[nM*i + j]__.

**Divide-and-Conquer Matrices**

```c++
void mm_dac(double *restrict C, int n_C,
            double *restrict A, int n_A,
            double *restrict B, int n_B,
            int n)
{
    assert((n & (-n)) == n); // n is a power of 2
    if (n <= THRESHOLD) {
        mm_base(C, n_C, A, n_A, B, n_B, n);
    } else {
        double *D = malloc(n * n * sizeof(*D));
        assert(D != NULL);
#define n_D n
#define X(M, r, c) (M + (r*(n_ ## M) + c)*(n/2))
        cilk_spawn mm_dac(X(C, 0, 0), n_C, X(A, 0, 0), n_A, X(B, 0, 0), n_B, n/2);
        cilk_spawn mm_dac(X(C, 0, 1), n_C, X(A, 0, 0), n_A, X(B, 0, 1), n_B, n/2);
        cilk_spawn mm_dac(X(C, 1, 0), n_C, X(A, 1, 0), n_A, X(B, 0, 0), n_B, n/2);
        cilk_spawn mm_dac(X(C, 1, 1), n_C, X(A, 1, 0), n_A, X(B, 0, 1), n_B, n/2);
        cilk_spawn mm_dac(X(C, 0, 0), n_C, X(A, 0, 1), n_A, X(B, 1, 0), n_B, n/2);
        cilk_spawn mm_dac(X(C, 0, 1), n_C, X(A, 0, 1), n_A, X(B, 1, 1), n_B, n/2);
        cilk_spawn mm_dac(X(C, 1, 0), n_C, X(A, 1, 1), n_A, X(B, 1, 0), n_B, n/2);
                   mm_dac(X(C, 1, 1), n_C, X(A, 1, 1), n_A, X(B, 1, 1), n_B, n/2);
        // А
        // |  Perform the 8 multiplications of (n/2) x (n/2) submatrices recursively in parallel.
        cilk_sync;
        m_add(C, n_C, D, n_D, n); // Add the tmp matrix D into the output matrix C.
        free(D);
    }
}

void m_add(double *restrict C, int n_C,
           double *restrict D, int n_D,
           int n)
{
    cilk_for (int i = 0; i < n; ++i) {
        cilk_for (int j = 0; j < n; ++j) {
            C[i*n_C + j] += D[i*n_D + j];
        }
    }
}
```
