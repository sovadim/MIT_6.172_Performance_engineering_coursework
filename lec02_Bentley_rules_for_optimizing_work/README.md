Some ways of optimization with explanation and examples

# Data structures

### Packing and encoding

Transforming data to another format for better usage

Example:
* Date in **text format** to **struct**
```c
typedef struct {
    int year: 1;
    int month: 2;
    int day: 3;
} date_t
```

### Augmentation

Adding information to a data structure to make common operations do less work

Example:
* Augmenting a linked list with a **tail pointer** so that the appending operates in constant time

### Precomputation

Performing calculations in advance

Example:
* Precomputing array of values that may be used in execution time

### Compile-time initialization

Performing calculations in compile-time

Example:
* Calculating binomial coefficients in **compile-time**

### Caching

Store results that have been accessed recently so that the program need not compute them again

```c
double cached_A = 0.0;
double cached_B = 0.0;
double cached_h = 0.0;

inline double hypotenuse(double A, double B) {
    if (A == cached_A && B == cached_B) {
        return cached_h;
    }
    cached_A = A;
    cached_B = B;
    cached_h = sqrt(A*A + B*B);
    return cached_h;
}
```

### Sparsity

Avoiding storing and computing on zeroes

Example:
* Compressed Sparse Row (CSR)
* Storing a static sparse graph

```c
typedef struct {
    int n, nnz;
    int *rows;    // length n
    int *cols;    // lenght nnz
    double *vals; // length nnz
} sparse_matrix_t;

void smmv(sparse_matrix_t *A, double *x, double *y) {
    for (int i = 0; i < A->n; ++i) {
        y[i] = 0;
        for (int k = A->rows[i]; k < A->rows[i + 1]; ++k) {
            int j = A->cols[k];
            y[i] += A->vals[k] * x[j];
        }
    }
}
```

# Logic

### Constant Folding and Propagation

Evaluating constant expressions and substituting the result into further expressions during compilation

Example:
* Precomputations with constants in math expressions

### Common-subexpression elimination

Avoiding computing the same expression multiple times by evaluating the expression once and storing the result for later use

Example:
* Storing temporal values that used multiple times

### Algebraic Identities

Replacing expensive algebraic expressions with algebraic equivalents that require less work

### Short-Circuiting

Stopping evaluation as soon as you know the answer

Example:
* Sum of elements in array exceeds some value before counting to the end

### Ordering Tests

Performing logical tests that are more often successful or less expensive first

Example:
* Figuring out if char is a whitespace we firstly compare it with the most frequent symbol considered as whitespace

### Creating a Fast Path

Performing additional check before expensive computation that may give a negative or positive answer faster

Example:
* The balls do not collide if they move in opposite directions

### Combining Tests

Replacing a sequence of tests with one test or switch

# Loops

### Hoisting (loop-invariant code motion)

Avoiding recomputing loop-invariant code each time through the body of the loop

### Sentinels

Special dummy values placed in data structure to simplify the logic of boundary conditions, and in particular, the handling of loop-exit tests

```c
// All elements of A are nonnegative
// A[n] and A[n+1] exist and can be clobbered
bool overflow(int64_t *A, size_t n) {
    A[n] = INT64_MAX;
    A[n + 1] = 1;
    size_t i = 0;
    int64_t sum = A[0];
    // One comparison per loop insted of 2 if we used for-loop
    while (sum >= A[i]) {
        sum += A[++i];
    }
    if (i < n) return true;
    return false;
}
```

### Loop Unrolling

Just loop unrolling. Can be full or partial

Benefits:
* Lower number of instructions in loop control code
* Enables more compiler optimizations

NB: Unrolling too much can cause poor use of instruction cache

Example:

```c
int sum = 0;
int j;

for (j = 0; j < n - 3; j += 4) {
    sum += A[j];
    sum += A[j + 1];
    sum += A[j + 2];
    sum += A[j + 3];
}

for (int i = 0; i < n; ++i) {
    sum += A[i];
}
```

### Loop Fusion (jamming)

Combining multiple loops over the same index range into a single loop body

### Eliminating Wasted Iterations

Modifying loop bounds to avoid executing loop iterations over essentially empty loop bodies

# Functions

### Inlining

Replacing a call to the function with the body of the function itself

### Tail-Recursion Elimination

Replacing a recursive call with a branch, saving function-call overhead

### Coarsening Recursion

Increasing the size of the base case and handling it with more efficient code that avoids function-call overhead

Example:
* Fallback from quicksort (which is recursive) to insertion sort if number of elements is less than some threshold
