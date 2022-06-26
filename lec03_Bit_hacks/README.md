## Basic bit operations

Setting the kth bit in a word x to 1
```c
y = x | (1 << k);
```

Setting the kth bit in a word x to 0
```c
y = x & ~(1 << k);
```

Flipping the kth bit
```c
y = x ^ (1 << k)
```

Extracting a bit field
```c
(x & mask) >> shift;
```

Setting a bit field in a word **x** to a value **y**
```c
x = (x & ~mask) | (y << shift)
```

## Bit problems

### No-Temp Swap

```c
x = x ^ y;
y = x ^ y;
x = x ^ y;
```

Performance: Poor at exploiting __instruction-level parallelism (ILP)__

### No-Branch Minimum

```c
r = y ^ ((x ^ y) & -(x < y))
```

### Merging 2 Sorted Arrays

```c
static void merge(long * __restrict C,
                  long * __restrict A,
                  long * __restrict B,
                  size_t na,
                  size_t nb) {
    while (na > 0 && nb > 0) {
        if (*A <= *B>) {
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

Branchless
```c
static void merge(long * __restrict C,
                  long * __restrict A,
                  long * __restrict B,
                  size_t na,
                  size_t nb) {
    while (na > 0 && nb > 0) {
        long cmp = (*A <= *B);
        long min = *B ^ ((*B ^ *A) & (-cmp));
        *C++ = min;
        A += cmp;
        na -= cmp;
        B += !cmp;
        nb -= !cmp;
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

NB: with clang -O3 the branchless version is usually slower than the branching the compiler can perform this optimization better

### Modular Addition

Problem: (x + y) mod n where x and y are in range [0, n)

```c
r = (x + y) % n; // division is expensive unless n is a power of 2

z = x + y;
r = z - (n & -(z >= n)); // same trick as minimum
```

### Round up to a Power of 2

```c
uint64_t n;   // 0010.0000.0101.0000
...
--n;          // 0010.0000.0100.1111
n |= n >> 1;  // 0011.0000.0110.1111
n |= n >> 2;
n |= n >> 4;  // 0011.1100.0111.1111
n |= n >> 8;
n |= n >> 16;
n |= n >> 32; // 0011.1111.1111.1111
++n;          // 0100.0000.0000.0000
```

### Least-Significant 1

```c
r = x & (-x);
```

### Log Base 2 of a Power of 2

Problem: Compute log(x) where x is a power of 2

```c
const uint64_t deBruijn = 0x022fdd63cc95386d;
const int convert[64] = {
    0,  1,  2,  53, 3,  7,  54, 27,
    4,  38, 41, 8,  34, 55, 48, 28,
    62, 5,  39, 46, 44, 42, 22, 9,
    24, 35, 59, 56, 49, 18, 29, 11,
    63, 52, 6,  26, 37, 40, 33, 47,
    61, 45, 43, 21, 23, 58, 17, 10,
    51, 25, 36, 32, 60, 20, 57, 16,
    50, 31, 19, 15, 30, 14, 13, 12
};
r = convert[(x * deBruijn) >> 58];
```

### Population Count

Problem: Count the number of 1 bits in a word **x**

```c
// Repeatedly eliminate the least-significant 1
// In the worst case the running time is proportional to the number of bits in the word
for (int r = 0; x != 0; ++r) {
    x &= x - 1;
}
```

Table look-up
```c
// The performance is highly relying on cache
static const int count[256] = {
    0, 1, 1, 2, 1, 2, 2, 3, 1, ..., 8
}

for (int r = 0; x != 0; x >>= 8) {
    r += count[x & 0xFF];
}
```

Parallel divide-and-conquer
```c
// Create masks
M5 = ~((-1) << 32);
M4 = M5 ^ (M5 << 16);
M3 = M4 ^ (M4 << 8);
M2 = M3 ^ (M3 << 4);
M1 = M2 ^ (M2 << 2);
M0 = M1 ^ (M1 << 1);
// Compute popcount
x = ((x >> 1) & M0) + (x & M0);
x = ((x >> 2) & M1) + (x & M1);
x = ((x >> 4) + x) & M2;
x = ((x >> 8) + x) & M3;
x = ((x >> 16) + x) & M4;
x = ((x >> 32) + x) & M5;
```

Repformance: Proportional to (log w) time where w is a word length

Some machines provide popcount instructions and can be accesse via compiler intrinsics\
Example, GCC:
```c
int __builtin_popcount(unsigned int x);
```
