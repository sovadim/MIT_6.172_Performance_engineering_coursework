# Storage Allocation

**Stack Allocation**

Array and pointer
```
    ___________________________
A  |__used__|______unused______|
            A
            |
            sp
```

Allocate ```x``` bytes
```c
sp += x;
return sp - x;
```

Should check for stack overflow.

Free ```x``` bytes
```c
sp -= x;
```

Should check for stack underflow.

* Allocating and freeing take Θ(1) time.
* Must free consistent with stack discipline.
* Limited applicability, but great when it works.
* One can allocate on the call stack using ```alloca()```,
but this function is deprecated, and the compiler is
more efficient with fixed-size frames.

**Heap Allocation**

C provides ```malloc()``` and ```free()```.\
C++ provides ```new``` and ```delete```.

**Fixed-size Heap Allocation**

**Free list**

* Every piece of storage has the same size.
* Unused storage has a pointer to next unused block.

Bitmap mechanism
* Bit for each block saying whether or not it is free.
* Bit tricks for allocation.

Allocate 1 object
```c
x = free;
free = free->next;
return x;
```

Should check ```free != NULL```.

Free object ```x```
```c
x->next = free;
free = x;
```

* Allocating and freeing take Θ(1) time.
* Good temporal locality.
* Poor spatial locality due to __external fragmentation__ -
blocks distributed across virtual memory - which can
increase the size of the page table and cause __disk thrashing__.
* The __translation lookaside buffer (TLB)__ can also be a problem.

**Mitigating External Fragmentation**

* Keep a free list (or bitmap) per disk page.
* Allocate from the free list for the fullest page.
* Free a block of storage to the free list for the page
on which the block resides.
* If a page becomes empty (only free-list items), the
virtual-memory system can page it out without
affecting program performance.
* __90-10__ is better than __50-50__.

**Variable-size Heap Allocation**

**Binned free lists**

* Leverage the efficiency of free lists.
* Accept a bounded amount of internal fragmentation.

Bin ```k``` holds memory blocks of size ```2^k```.

Allocate ```x``` bytes

* If bin ```k = |lg x| (upper bound)``` is nonempty, return a block.
* Otherwise, find a block in the next larger nonempty bin ```k' > k```,
split it up into blocks of sizes ```2^(k'-1)```, ```2^(k'-2)```, ..., ```2^k```,
and distribute the pieces.

Example:\
x = 3 => |log x| = 2. Bin 2 is empty.

￼
If no larger blocks exist, ask the OS to allocate more memory.

**How Virtual is Virtual Memory?**

__Q__: Since a 64-bit address space takes over a
century to write at a rate of 4 billion bytes per
second, we effectively never run out of virtual
memory. Why not just allocate out of virtual
memory and never free?

__A__: __External fragmentation__ would be horrendous.
The performance of the page table would degrade
tremendously leading to __disk thrashing__, since
all nonzero memory must be backed up on disk in
page-sized blocks.

**Analysis of Binned Free Lists**

**Theorem.** Suppose that the maximum amount of
heap memory in use at any time by a program is __M__.
If the heap is managed by a BFL allocator, the
amount of virtual memory consumed by heap storage
is ```O(M lg M)```

__Proof.__ An allocation request for a block of size __x__
consumes __2^|lg x| <= 2x__ storage. Thus, the amount
of virtual memory devoted to blocks of size __2^k__ is at
most __2M__. Since there are at most __lg M__ free lists,
the theorem holds.

=> In fact, BFL is Θ(1)-competitive with the optimal
allocator (assuming no coalescing).

**Coalescing**

Binned free lists can sometimes be heuristically
improved by __splicing together__ adjacent small
blocks into a larger block.

* Clever schemes exist for finding adjacent blocks
efficiently - e.g., the __"buddy" system__ - but the
overhead is still greater than simple BFL.

* No good theoretical bounds exist that __prove__ the
effectiveness of coalescing.

* Coalescing seems to reduce fragmentation __in practice__,
because heap storage tends to be deallocated as a stack (LIFO) or in batches.

**Garbage Collectors**

* Free the programmer from freeing objects.
* A garbage collector identifies and recycles the
objects that the program can no longer access.
* GC can be built-in (Java, Python) or do-it-yourself.

**Terminology**

* **Roots** are objects directly accessible by the
program (globals, stack, etc.).

* **Live** objects are reachable from the roots by
following pointers.

* **Dead** objects are inaccessible and can be recycled.

How can the GC identify pointers?

* Strong typing.
* Prohibit pointer arithmetic (which may slow down some programs).

**Reference Counting**

Keep a count of the number of pointers referencing
each object. If the count drops to 0, free the dead object.

**Mark-and-Sweep Garbage Collection**

* **Mark stage:** Breadth-first search marked all of the live objects.

* **Sweep stage:** Scan over memory to free unmarked objects.

**Copying Garbage Collector**

Stop and copy algorithm.
