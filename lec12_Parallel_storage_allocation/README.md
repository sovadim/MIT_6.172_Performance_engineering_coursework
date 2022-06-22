# Parallel Storage Allocation

**Heap Storage in C**

```c
void* malloc(size_t s);
```

Allocate and return a pointer to a block of
memory containing at leas ```s``` bytes.

```c
void* memalign(size_t a, size_t s);
```

Allocate and return a pointer to a block of
memory containing at least ```s``` bytes, aligned to a
multiple of ```a```, where ```a``` must be exact power of 2:

```c
0 = ((size_t) memalign(a, s)) % a
```

```c
void free(void* p);
```

```p``` is a pointer to a block of memory returned
by ```malloc()``` or ```memalign()```. Deallocate the block.

**Allocating Virtual Memory**

The ```mmap()``` system call can be used to allocate
virtual memory by __memory mapping__:

```c
void *p = mmap(0, 
               size,
               PROT_READ | PROT_WRITE,
               MAP_PRIVATE | MAP_ANON,
               -1,
               0
);
```

The Linux kernel finds a contiguous, unused region in
the address space of the application large enough to
hold ```size``` bytes, modifies the page table, and creates
the necessary virtual-memory management structures
within the OS to make the user's access to this area
"legal" so that accesses won't result in a segfault.

**Properties of mmap()**

* ```mmap()``` is lazy. Id does not immediately allocate
physical memory for the requested allocation.

* Instead, it populates the page table with entries
pointing to a special zero page and marks the page
as read only.

* The first write into such a page causes a page fault.

* At that point, the OS allocates a physical page,
modifies the page table, and restarts the instruction.

* You can ```mmap()``` a terabyte of virtual memory on a
machine with only a gigabyte of DRAM.

* A process may die from running out of physical
memory well after the ```mmap()``` call.

**```malloc()``` and ```mmap()```**

* The funcitons ```malloc()``` and ```free()``` are part of the
memory-allocation interface of the heap-management code in the C library.

* The heap-management code uses available system facilities,
including ```mmap()```, to obtain memory (virtual address space)
from the kernel.

* The heap-management code within ```malloc()```
attempts to satisfy user requests for heap
storage by reusing freed memory whenever possible.

* When necessary, the ```malloc()``` implementation
invokes ```mmap()``` and other system calls to
expand the size of the user's heap storage.

**Traditional Linear Stack**

Rule for pointers: A parent can pass pointers to its
stack variables down to its children, but not the other way around.

**Cactus Stack**

A __cactus stack__ supports multiple views in parallel.

**Heap-Based Cactus Stack**

A heap-based cactus stack allocates frames off the heap.

Each stack-frame has a pointer to the parent stack-frame.

**Space Bound**

**Theorem.** Let S1 be the stack space required by a
serial execution of a Cilk program. The stack space of
a P-worker execution using a heap-based cactus stack
is at most Sp <= PS1.

**Proof.** Cilk's work-stealing algorithm maintains the busy-leaves property:\
Every active lead frame has a worker executing it.

**D&C Matrix Multiplication**

```c++
void mm_dac(double *restrict C, int n_C,
            double *restrict A, int n_A,
            double *restrict B, int n_B,
            int n)
{
    assert((n & (-n)) == n);
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
        cilk_sync;
        m_add(C, n_C, D, n_D, n);
        free(D);
    }
}
```

**Analysis of D&C Matrix Multiplication**

Work: T1(n) = Θ(n^3)\
Span: Tinf(n) = Θ(lg^2 n)\
Space: S1(n) = S1(n/2) + Θ(n^2) = Θ(n^2)

By the busy-leaves property, we have Sp(n) = O(Pn^2)

We can actually prove a stronger bound.\
Sp(n) = Θ(P^(1/3)n^2)

**Interoperability**

Problem: With heap-based linkage, parallel functions
fail to interoperate with legacy and third-party serial
binaries. Our implementation of Cilk uses a less
space-efficient strategy that preserves interoperability
by using a pool of linear stacks.

**Allocator Speed**

Definition. Allocator __speed__ is the number of
allocations and deallocations per second that the
allocator can sustain.

**Q.** Is it more important to maximize allocator
speed for large blocks or small blocks?

**A.** Small blocks.\
Typically, a user program writes all the bytes
of an allocated block. A large block takes so
much time to write that the allocator time has
little effect on the overall runtime. In contrast,
if a program allocates many small blocks, the
allocator time can represent a significant overhead.

**Fragmentation**

**Definition.** The __user footprint__ is the maximum over
time of the number U of bytes in use by the user program
(allocated but not freed). The __allocator footprint__
is the maximum over time of the number A of bytes of
memory provided to the allocator by the operating system.
The __fragmentation__ is F = A/U.

The ideal is 1.

**Remark.** __A__ grows monotonically for many allocators. 

**Theorem** (proved in lec 11). The fragmentation
for binned free lists is Fv = O(lg U).

**Fragmentation Glossary**

* **Space overhead**: Space used by the allocator for bookkeeping.

* **Internal fragmentation**: Waste due to allocating
larger blocks than the user requests.

* **External fragmentation**: Waste due to the inability
to use storage because it is not contiguous.

* **Blowup**: For a parallel allocator, the additional
space beyond what a serial allocator would require.

**Parallel Allocation Strategies**

**Strategy 1: Global Heap**

* Default C allocator.
* All threads (processors) share a single heap.
* Accesses are mediated by a mutex (or lock-free synchronization) to preserve atomicity.
* Blowup = 1. No more memory in use than with serial allocator.
* Slow - acquiring a lock is like an L2-cache access.
* Contention can inhibit scalability.

**Scalability**

Ideally, as the number of threads (processors) grows,
the time to perform an allocation or deallocation
should not increase.

* The most common reason for loss of scalability is __lock contention__.

**Q.** Is lock contention more of a problem for large blocks or for small blocks?

**A.** Small blocks.\
Typically, a user program writes all the bytes
of an allocated block, making it hard for a thread
allocating large blocks to issue allocation
requests at a high rate. In contrast, if a program
allocates many small blocks in parallel,
contention can be a significant issue.

**Strategy 2: Local Heaps**

* Each thread allocates out of its own heap.
* No locking is necessary.
* Fast - no synchronization.
* Suffers from __memory drift__: blocks allocated
by one thread are freed on another => unbounded blowup.

**Strategy 3: Local Ownership**

* Each object is labeled with its owner.
* Freed objects are returned to the owner's heap.
* Fast allocation and freeing of local objects.
* Freeing remote objects requires synchronization.
* Blowup <= P.
* Resilience to __false sharing__.

**False Sharing**

True sharing: 2 processors are trying to access the same memory location.\
False sharing: multiple processors access different memory locations,\
but those locations happen to be on the same cache line.

**How False Sharing Can Occur**

A __program__ can include false sharing having
different threads process nearby objects.

* The programmer can mitigate this problem by
aligning the object on a cache-line boundary and
padding out the object to the size of a cache line,
but this solution can be wasteful of space.

An __allocator__ can induce sharing in two ways:

* __Actively__, when the allocator satisfies memory
requests from different threads using the same cache block.

* __Passively__, when the program passes objects lying on
the same cache line to different threads, and the allocator
reuses the objects' storage after the objects are freed
to satisfy requests from those threads.

**The Hoard Allocator**

* **P** local heaps.
* **1** global heap.
* Memory is organized into large __superblocks__ of size **S**.
* Only superblocks are moved between the local heaps and the global heap.

* Fast.
* Scalable.
* Bounded blowup.
* Resilience to false sharing.

**Hoard Allocation**

Assume without loss of generality that all
blocks are the same size (fixed-size allocation).

```x = malloc()``` on thread ```i```.
```c
if (there exists a free object in heap i) {
    x = an object from the fullest nonfull superblock in i's heap;
} else {
    if (the global heap is empty) {
        B = a new superblock from the OS;
    } else {
        B = a superblock in the global heap;
    }
    set the owner of B to i;
    x = a free object in B;
}
return x;
```

**Hoard Deallocation**

Let __ui__ be the in-use storage in heap __i__, and
let __ai__ be the storage owned by heap __i__.\
Hoard maintains the following invariant for all heaps __i__:
```
ui >= min(ai - 2S, ai/2)
```
where __S__ is the superblock size.

```free(x)```, where ```x``` is owned by thread ```i```:
```c
put x back in heap i;
if (ui < min(ai - 2S, ai/2)) {
    move a superblock that is at least 1/2 empty from
        heap i to the global heap;
}
```

**Hoard's Blowup**

**Lemma.** The maximum storage allocated in
global heap is at most maximum storage
allocated in local heaps.

**Theorem.** Let U be the user footprint for a
program, and let A be Hoard's allocator footprint.
We have
```
A <= O(U + SP)
```
and hence the blowup is
```
A/U = 1 + O(SP / U)
```

**Proof.** Analyze storage in local heaps.
Recall that ui >= min(ai - 2S, ai/2).\
First term: at most 2S unutilized storage per heap for a total of O(SP).\
Second item: allocated storage is at most twice the used storage for a total of O(U).

**Other Solutions**

**jemalloc** is like Hoard, with a few differences:

* jemalloc has a separate global lock for each different allocation size.

* jemalloc allocates the object with the smallest address among all objects
of the requested size.

* jemelloc releases empty pages using\
```madvise(p, MADV_DONTNEED, ...)```,\
which zeros the page while keeping the virtual address valid.

* jemalloc is a popular choice for parallel systems
due to its performance and robustness.

**SuperMalloc** is an up-and-coming contender ([paper by Bradley C.Kuszmaul](http://supertech.csail.mit.edu/papers/Kuszmaul15.pdf)).
