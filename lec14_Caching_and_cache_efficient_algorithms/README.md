# Caching and Cache-Efficient Algorithms

**Multicore Cache Hierarchy**

```
  ______   ______   ______
 |_DRAM_| |_DRAM_| |_DRAM_|
 ____________________________________
|  _____________________  _________  |
| | Memory              || Network | |
| |_Controller__________||_________| |
|  ________________________________  |
| |           LLC (L3)             | |
| |________________________________| |
|  ___________    ___________        |
| |    L2     |  |    L2     |       |
| |___________|  |___________|       |
|  ____   ____    ____   ____        |
| |L1  | |L1  |  |L1  | |L1  |       |
| |data| |inst|  |data| |inst| ..... |
|                                    |
| (     P     )  (     P     ) .. (P)|
|____________________________________|
```

Multiple chips on the same server are connected through a network.

```
|Level  | Size   | Assoc. | Latency |
|_______|________|________|___(ns)__|
| Main  | 128 GB |        |    50   |
|-------|--------|--------|---------|
| LLC   | 30 MB  |   20   |    6    |
|-------|--------|--------|---------|
| L2    | 256 KB |   8    |    4    |
|-------|--------|--------|---------|
| L1-d  | 32 KB  |   8    |    2    |
|-------|--------|--------|---------|
| L1-i  | 32 KB  |   8    |    2    |

64 B cache blocks
```

**Fully Associative Cache**

In a fully associative cache a cache block can reside anywhere in the cache.

To find a block in the cache, the entire cache must be searched for the tag.
When the cache becomes full, a block must be __evicted__ to make room for a new block.
The __replacement policy__ determines which block to evict.

One common replacement policy is LRU.

**Direct-Mapped Cache**

A cache block's __set__ determines its location in the cache.

**w**-bit address space\
Cache size **M**\
Block size **B**
```
      address
      ___________ __________ ________
     |_tag_______|_set______|_offset_|
bits |_w_-_lg(M)_|_lg(M/B)__|_lg(B)__|
```

To find a block in the cache, only a single
location in the cache need to be searched.

**Set-Associative Cache**

**k = 2**-way associativity.

A cache block's __set__ determines __k__ possible cache locations.

```
      address
      ____________ __________ ________
     |_tag________|_set______|_offset_|
bits |_w_-_lg(M/k)|_lg(M/kB)_|_lg(B)__|
```

To find a block in the cache, only the __k__ locations of its set must be searched.

**Taxonomy of Cache Misses**

**Cold miss**

* The first time the cache block is accessed.

**Capacity miss**

* The previous cached copy would have been
evicted even with a fully associative cache.

**Conflict miss**

* Too many blocks from the same set in the cache. The block
would not have been evicted with a fully associative cache.

**Sharing miss**

* Another processor acquired exclusive access to the cache block.
* **True-sharing miss:** Two processors are accessing the same data on the cache line.
* **False-sharing miss:** Two processors are accessing different data that happen to reside on the same cache line.

**Conflict Misses for Submatrices**

```
   A
   | 4096 columns
<--- of doubles = 2^15 bytes --->
   |
  s4096   A __32
  rows     |    |32
   |       |____|
   V
```

Conflict misses can be problematic for caches with limited associativity.

**Assume:**
* Word width __w = 64.__
* Cache size __M = 32K.__
* Line (block) size __B = 64.__
* __k = 4__-way associativity.

```
      address
      ____________ __________ ________
     |_tag________|_set______|_offset_|
bits |_w_-_lg(M/k)|_lg(M/kB)_|_lg(B)__|
     |_____51_____|____7_____|___6____|
```

**Analysis**

Look at a column of submatrix __A__.\
The addresses of the elements are:\
__x__, __x+2^15__, __x+2\*2^15__, ..., __x+31\*2^15__.\
The all fall into the same set.

**Solutions**

Copy __A__  into a temporary __32x32__ matrix or pad rows.

**Ideal-Cache Model**

**Parameters**

* Two-level hierarchy.
* Cache size of __M__ bytes.
* Cache-line length of __B__ bytes.
* Fully associative.
* Optimal, omniscient replacement.

**Performance measures**

* Work __W__ (ordinary running time)
* Cache misses __Q__

**How Reasonable Are Ideal Caches?**

**"LRU" Lemma.** Suppose that an algorithm incurs __Q__
cache misses on an ideal cache of size __M__.
Then on a fully associative cache of size __2M__ that uses
the LRU replacement policy, it incurs at most __2Q__ cache misses.

**Implication**

For asymptotic analyses, one can assume optimal ot LRU replacement, as convenient.

**Software Engineering**
* Design a theoretically good algorithm.
* Engineer for detailed performance.
    - Real caches are not fully associative.
    - Loads and stores have different costs
    with respect to bandwidth and latency.

**Cache-Miss Lemma**

**Lemma.** Suppose that a program reads a set of __r__ data
segments, where the __ith__ segment consist of __si__
bytes, and suppose that
$$ \sum_{i=1}^{r} s_i = N < M/3 \: and \: N/r \geq B $$
Then all the segments fit into cache, and the number
of misses to read them all is at most __3N/B__.

**Tall Caches**

**Tall-cache assumption**\
__B^2 < c*M__ for some sufficiently small constant __c <= 1__.

**What's Wrong with Short Caches?**

An __n*n__ submatrix stored in row-major order may not
fit in a short cache even if __n^2 < c*M__.

**Submatrix Caching Lemma**

**Lemma.** Suppose that an __n*n__ submatrix __A__ is read
into a tall cache satisfying __B^2 < c*M__, where __c <= 1__ is
constant, and suppose that __c*M <= n^2 < M/3. Then __A__
fits into cache, and the number of misses to read all
__A's__ elements is at most __3n^2/B__.

**Proof.** We have __N = n^2__, __n = r = si__, __B <= n = N/r__,
and __N < M/3__. Thus, the Cache-Miss Lemma applies.

**Cache Analysis of Matrix Multiplication**

**Multiply Square Matrices**

```c
void Mult(double *C, double *A, double *B, int64_t n) {
     for (int64_t i = 0; i < n; ++i)
          for (int64_t j = 0; j < n; ++j)
               for (int64_t k = 0; k < n; ++k)
                    C[i*n+j] += A[i*n+k] * B[k*n+j];
}
```

Analysis of work\
W(n) = Θ(n^3)

Assume row major and tall cache

**Case 1**

n > c*M/B

Analyze matrix __B__. Assume LRU.

Q(n) = Θ(n^3), since matrix __B__ misses on every access.

**Case 2**

c'*M^(1/2) < n < c*M/B

Analyze matrix __B__. Assume LRU.

Q(n) = n*Θ(n^2/B) = Θ(n^3/B),\
since MATRIX __B__ can exploit spatial locality.

**Case 3**

n < c'*M^(1/2)

Analyze matrix __B__. Assume LRU.

Q(n) = Θ(n^2/B),\
since everything fits in cache.

**Swapping Inner Loop Order**

[i,j,k] -> [i,k,j]

Analyze matrix __B__. Assume LRU.

Q(n) = n*Θ(n^2/B),\
since matrix __B__ can exploit spatial locality.

**Tiling**

**Tiled Matrix Multiplication**

```c
void Tiled_Mult(double *C, double *A, double *B, int64_t) {
     for (int64_t i1 = 0; i1 < n/s; i1 += s)
          for (int64_t j1 = 0; j1 < n/s; j1 += s)
               for (int64_t k1 = 0; k1 < n/s; k1 += s)
                    for (int64_t i = i1; i < i1 + s && i < n; ++i)
                         for (int64_t j = j1; j < j1 + s && j < n; ++j)
                              for (int64_t k = k1; k < k1 + s && k < n; ++k)
                                   C[i*n+j] += A[i*n+k] + B[k*n+j];
}
```

Analysis of work

W(n) = Θ((n/s)^3 * (s^3)) = Θ(n^3)

Analysis of cache misses

* Tune __s__ so that the submatrices just fit into cache =>\
s = Θ(M^(1/2)).

* Submatrix caching lemma implies Θ(s^2/B) misses per submatrix.

* Q(n) = Θ((n/s)^3 * (s^2/B)) = Θ(n^3/(BM^(1/2)))

* Optimal.

**Two-Level Cache**

* Two "voodoo" tuning parameters __s__ and __t__.
* Multidimensional tuning optimization cannot be done with binary search.

**Three-Level Cache**

* Three "voodoo" tuning parameters.
* Twelve nested for loops.
* Multiprogrammed environment:
Don't know the effective cache size when other jobs are running =>
easy to mistune the parameters.

**Divide & Conquer**

**Recursive Matrix Multiplication**

Divide-and-conquer on __n*n__ matrices.

```
 ____ _____     ____ ____     ____ ____
|C11 | C12 |   |A11 |A12 |   |B11 |B12 |
|----|-----| = |----|----| x |----|----| =
|C21_|_C22_|   |A21_|A22_|   |B21_|B22_|
   _______ _______     _______ _______
  |A11 B11|A11 B12|   |A12 B21|A12 B22|
= |-------|-------| + |-------|-------|
  |A21_B11|A21_B12|   |A22_B21|A22_B22|
```

__8__ multiply-adds of __(n/2)x(n/2)__ matrices.

**Recursive Code**

```c
// Assume that n is an exact power of 2.
void Rec_Mult(double *C, double *A, double *B,
              int64_t n, int64_t rowsize) {
     if (n == 1)
          C[0] += A[0] * B[0];
     else {
          int64_t d11 = 0;
          int64_t d12 = n/2;
          int64_t d21 = (n/2) * rowsize;
          int64_t d22 = (n/2) * (rowsize + 1);

          Rec_Mult(C + d11, A + d11, B + d11, n/2, rowsize);
          Rec_Mult(C + d11, A + d12, B + d21, n/2, rowsize);
          Rec_Mult(C + d12, A + d11, B + d12, n/2, rowsize);
          Rec_Mult(C + d12, A + d12, B + d22, n/2, rowsize);
          Rec_Mult(C + d21, A + d21, B + d11, n/2, rowsize);
          Rec_Mult(C + d21, A + d22, B + d21, n/2, rowsize);
          Rec_Mult(C + d22, A + d21, B + d12, n/2, rowsize);
          Rec_Mult(C + d22, A + d22, B + d22, n/2, rowsize);
     }
}
```

Analysis of work


```
W(n) = 8W(n/2) + Θ(1) = Θ(n^3)

Q(n) = | Q(n^2/B) if n^2 < cM for suff. small const c <= 1,
       | 8Q(n/2) + Θ(1) otherwise.
```

Analysis of cache misses

Q(n) = Θ(n^3/(BM^(1/2)))

Same cache misses as with tiling.

**Efficient Cache-Oblivious Algorithms**

* No voodoo tuning parameters.
* No explicit knowledge of caches.
* Passively autotune.
* Handle multilevel caches automatically.
* Good in multiprogrammed environments.

**Recursive Parallel Matrix Multiply**

```c
// Assume that n is an exact power of 2.
void Rec_Mult(double *C, double *A, double *B,
              int64_t n, int64_t rowsize) {
     if (n == 1)
          C[0] += A[0] * B[0];
     else {
          int64_t d11 = 0;
          int64_t d12 = n/2;
          int64_t d21 = (n/2) * rowsize;
          int64_t d22 = (n/2) * (rowsize + 1);

          cilk_spawn Rec_Mult(C + d11, A + d11, B + d11, n/2, rowsize);
          cilk_spawn Rec_Mult(C + d11, A + d12, B + d21, n/2, rowsize);
          cilk_spawn Rec_Mult(C + d12, A + d11, B + d12, n/2, rowsize);
          Rec_Mult(C + d12, A + d12, B + d22, n/2, rowsize);
          cilk_sync;
          cilk_spawn Rec_Mult(C + d21, A + d21, B + d11, n/2, rowsize);
          cilk_spawn Rec_Mult(C + d21, A + d22, B + d21, n/2, rowsize);
          cilk_spawn Rec_Mult(C + d22, A + d21, B + d12, n/2, rowsize);
          Rec_Mult(C + d22, A + d22, B + d22, n/2, rowsize);
          cilk_sync;
     }
}
```

**Cilk and Caching**

**Theorem.** Let Qp be the number of cache misses in a
deterministic Cilk computation when run on __P__
processors, each with a private cache of size __M__, and
let __Sp__ be the number of successful steals during the
computation. In the ideal-cache model, we have
```
Qp = Q1 + O(Sp*M/B),
```
where __M__ is the cache size and __B__ is the size of a cache block.

**Proof.** After a worker steals a continuation, its cache is
completely cold in the worst case. But after __M/B__ (cold) cache
misses, its cache is identical to that in the serial execution. The
same is true when a worker resumes a stolen subcomputation
after a ```cilk_sync```. The number of times these two situations can
occur is at most __2Sp__.

Minimizing cache misses in the serial elision
essentially minimizes them in parallel execution.
