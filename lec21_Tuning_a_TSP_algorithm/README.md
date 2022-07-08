# Tuning a TSP Algorithm

Jon Bentley

**Outline**

* Review of Recursive Generation
* The Traveling Salesperson Problem
* A Sequence of TSP Algorithms
* Principles of Algorithm Engineering

**Recursive Generation**

A technique for systematically generating all members of a class.\
Example: all subset of the n integers 0, 1, 2, ..., n-1

Representation?\
{1, 2, 3} or 01011 or ...

An iterative solution: binary counting\
0000 0001 0010 .... 1111

A recursive solution to fill p
```c++
void allsubsets(int m) {
    if (m == 0) {
        visit();
    } else {
        p[m - 1] = 0;
        allsubsets(m - 1);
        p[m - 1] = 1;
        allsubsets(m - 1);
    }
}
```

**The TSP***

The problem

* Scheduling vehicles, drills, plotters
* Automobile assembly lines

A prototypical problem

* NP-hard
* Held-Karp dynamic programming
* Approximation algorithms
* Kernighan-Lin heuristics

**Representation Details**

Count of Cities
```c++
#define MAXN 20
int n;
```

Permutation of Cities
```c++
int p[MAXN];
```

Distances Between Cities
```c++
typedef double Dist
Dist d(int i, int j)
```

**Algorithm 1**

The idea:\
Recursively generate all n! permutations and choose the best

Implementation
```c++
void search1(int m) {
    if (m == 1) {
        check1();
    } else {
        for (int i = 0; i < m; ++i) {
            swap(i, m - 1);
            search(m - 1);
            swap(i, m - 1);
        }
    }
}
```

**Supporting Code**

```c++
void check() {
    Dist sum = dist(p[0], p[n - 1]);
    for (int i = 1; i < n; ++i) {
        sum += dist1(p[i - 1], p[i]);
    }
    save(sum);
}

void save(Dist sum) {
    if (sum < minsum) {
        minsum = sum;
        for (int i = 0; i < n; ++i) {
            minp[i] = p[i];
        }
    }
}

void solve1() {
    search(n);
}
```

**Run Time of Algorithm 1**

Analysis
* Permutations: n!
* Distance calculations at each: n
* Total distance calculations: n x n!

**Constant Factor Improvements**

External to the Program
* Compiler optimizations
* Faster hardware

Internal Changes
* Modify the C code

**Constant Factor Improvements: Internal**

Faster computation -- Once huge, now tiny
* Change doubles to floats or (scaled) ints
* Measure and use faster size (short, int, long)

Avoid recomputing math-intensive functions

Algorithm 1
```c++
Dist geomdist(int i, int j) {
    return (Dist) (sqrt(sqr(c[i].x - c[j].x) +
                        sqr(c[i].y - c[i].y)));
}
```

Algorithm 2\
Precompute all n^2 distances in a table
```c++
#define dist2(i, j) distarr[i][j]
```

Algorithm 3

Idea: Reduce distance calculations by examining
fewer permutation.

Code
```c++
void solve3() {
    search2(n - 1);
}
```

Analysis
* Permutations: (n - 1)!
* Distance calculations at each: n
* Total distance calculations: n x (n-1)! = n!

Algorithm 4

Don't recompute sum. Carry along a partial sum instead.

```c++
void solve4() {
    search4(n - 1, ZERO);
}

void search4(int m, Dist sum) {
    if (m == 1) {
        check4(sum + dist2(p[0], p[1]));
    } else {
        for (int i = 0; i < m; ++i) {
            swap(i, m - 1);
            search4(m - 1, sum + dist2(p[m - 1], p[m]));
            swap(i, m - 1);
        }
    }
}

void check4(Dist sum) {
    sum += dist2(p[0], p[n - 1]);
    save(sum);
}
```

Reduces n x (n - 1)! to ~(1 + e) x (n - 1)!

**Perspective on Factorial Growth**

Each factor of n allows us to increase the problem
size by 1 in about the same wall-clock time.

Fast machines, great compilers and code tuning
allow us to solve problems into the teens.

Algorithm 5

Don't keep doing what doesn't work
```c++
void search5(int m, Dist sum) {
    if (sum > minsum)
        return;
    if (m == 1) {
        ...
    }
}
```

Algorithm 6

A better lower bound: Add MST of remaining points.

```c++
void search6(int m, Dist sum, Mask mask) {
    if (sum + mstdist(mask | bit[p[m]]) > minsum)
        return;
    search6(m - 1,
            sum + dist2(p[m - 1], p[m]),
            mask & ~bit[p[m - 1]]);
}
```

**Return of Caching**

Cache MST distances rather than recomputing them

Algorithm 7: Store all (used) distances in a table of size 2^n
```c++
nmask = mask | bit[p[m]];
if (mstdistarr[nmask] < 0.0)
    mstdistarr[nmask] = mstdist(nmask);
if (sum + mstdistarr[nmask] > minsum)
    return;
```

Algorithm 8: Store them in a hash table
```c++
if (sum + mstdistlookup(mask | bit[p[m]]) > minsum)
    return;
```

Hash Table Implementation
```c++
Dist mstdistlookup(Mask mask) {
    Trtr p;
    int h;
    h = mask % MAXBIN;
    for (p = bin[h]; p != NULL; p = p->next) {
        if (p->arg == mask)
            return p->val;
    }
    p = (Trtp) malloc(sizeof(Tnode));
    p->arg = mask;
    p->val = mstdist(mask);
    p->next = bin[h];
    bin[h] = p;
    return p->val;
}
```

Algorithm 9

Sort edges to visit nearest city first, then others in order.

**Possible Additional Improvements**

Constant Factor Speedups
* Faster machines
* Code tuning as before
* Better hashing: larger table, remove ```malloc```

Better Pruning
* Better starting tour
* Better bounds: MST Length + Nearest Neighbor to each
* Earlier pruning tests

Better Sorting
* Tune insertion sort; better algorithms
* Precompute all sorts
    * Sort once for each city
    * Select subsequence using mask

