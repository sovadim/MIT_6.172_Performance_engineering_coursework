## Perf and Cachegrind

Typical usage
```bash
$ make <target> DEBUG=1
$ perf record <binary> <args>
$ rerf report
```

## Perf

Running isort
```bash
$ make isort DEBUG=1
$ ./isort <n elements> <k times>
```

Running with perf
```bash
$ perf record ./isort 10000 10
$ perf report
```

Attaching perf to process for N seconds
```bash
$ perf record -d <pid> sleep <N>
```

Making flamegraph
```bash
$ perf record -g ./isort 10000 10
$ perf script | stackcollapse-perf.pl | flamegraph.pl > graph.svg
```

**Performance report:**

// Identify branch misses, clock cycles and instructions. Diagnose the performance bottlenecks in
the program.

__perf stat ./isort 10000 10__ shows the next valuable things:

* 1 885 366 444 cycles
* 5 271 606 504 instructions
* 753 243 575 branches
* 110 179 branch-misses # 0,01% of all branches

**Checkoff Item 1**: Make note of one bottleneck.

The hottest part of isort is inner while-cycle
```c
while (index >= left && *index > val)
```

## Cachegrind

Typical usage of cachegrind
```bash
$ valgrind --tool=cachegrind --branch-sim=yes <program_name> <program_arguments>
```

Information about your CPU
```
$ lscpu
```

**Checkoff Item 2**: Run sum under cachegrind to identify cache performance.

Building and running sum
```
$ make sum
$ valgrind --tool=cachegrind --branch-sim=yes ./sum
```

D1 and LLd misses
```
==109850== D1  misses:      100,546,446  ( 99,920,777 rd   +     625,669 wr)
==109850== LLd misses:       69,276,434  ( 68,650,802 rd   +     625,632 wr)
==109850== D1  miss rate:          16.5% (       25.0%     +         0.3%  )
==109850== LLd miss rate:          11.4% (       17.2%     +         0.3%  )
```

Playing around with the values N and U.

Valuable data from ```lscpu```:
```
L1d cache:                       192 KiB
L1i cache:                       192 KiB
L2 cache:                        1,5 MiB
L3 cache:                        12 MiB
```

Reducing U 10 times resulted in 0% LLD miss rate.
```
==110611== LLd misses:           64,329  (      1,261 rd   +      63,068 wr)
==110611== LLd miss rate:           0.0% (        0.0%     +         0.0%  )
```

Presumably, this is because the entire array of U elements could be stored in L3 cache.

Reducing U 100 and 1000 more times resulted in 3% and 0% D1 miss rate respectively.
```
==111295== D1  misses:            2,155  (      1,488 rd   +         667 wr)
==111295== D1  miss rate:           0.0% (        0.0%     +         0.0%  )
```
The whole array supposed to be stored in L1 cache in this case.

Reducing N results into progressive reducing of cache miss rate,
because the less memory reads it make, the less cache misses happened.

## Homework: Sorting 

**Write-up 1**

Comparing the Cachegrind output on the DEBUG=1 (-O0) code versus DEBUG=0 (-O3).

```
$ make DEBUG=1
$ make DEBUG=0
$ valgrind --tool=cachegrind --branch-sim=yes ./sort 100000 1 
```

DEBUG=1
```
==116115== I   refs:      467,940,424
==116115== I1  misses:          1,645
==116115== LLi misses:          1,593
==116115== I1  miss rate:        0.00%
==116115== LLi miss rate:        0.00%

==116115== D   refs:      307,316,698  (230,066,573 rd   + 77,250,125 wr)
==116115== D1  misses:        641,258  (    335,045 rd   +    306,213 wr)
==116115== LLd misses:         27,123  (      1,442 rd   +     25,681 wr)
==116115== D1  miss rate:         0.2% (        0.1%     +        0.4%  )
==116115== LLd miss rate:         0.0% (        0.0%     +        0.0%  )

==116115== Branches:       45,940,871  ( 44,240,202 cond +  1,700,669 ind)
==116115== Mispredicts:     3,507,488  (  3,507,200 cond +        288 ind)
==116115== Mispred rate:          7.6% (        7.9%     +        0.0%   )
```

DEBUG=0
```
==116436== I   refs:      277,332,306
==116436== I1  misses:          1,707
==116436== LLi misses:          1,612
==116436== I1  miss rate:        0.00%
==116436== LLi miss rate:        0.00%

==116436== D   refs:      101,969,432  (61,889,242 rd   + 40,080,190 wr)
==116436== D1  misses:        642,627  (   335,238 rd   +    307,389 wr)
==116436== LLd misses:         27,146  (     1,465 rd   +     25,681 wr)
==116436== D1  miss rate:         0.6% (       0.5%     +        0.8%  )
==116436== LLd miss rate:         0.0% (       0.0%     +        0.1%  )

==116436== Branches:       30,660,107  (28,959,426 cond +  1,700,681 ind)
==116436== Mispredicts:     1,107,576  ( 1,107,271 cond +        305 ind)
==116436== Mispred rate:          3.6% (       3.8%     +        0.0%   )
```

Optimized version has ~30% less branches and x2 less branch misses, x2-x3 less cache refs.

## Inlining

* Copying all the code from ```sort_a.c``` to sort_.c
* Adding ```inline``` where it can bu useful.

**Write-up 2**: Explain which functions you chose to inline and report the performance differences you observed between the inlined and uninlined sorting routines. 

I firstly chose the functions which are short and more likely to be inlined: 
__copy_i__, __mem_alloc__, and __mem_free__.

Inlining __mem_alloc__ and __mem_free__ requires to define functions in-place
Changes in Cachegrind:

* Branches: 15m -> 20m
* Branch misses: 3.4% -> 2.6%
* D refs: 52m -> 59m

No other notable changes.

Check execution time:
```
% ./sort 10000000 1
```

__Best times across numerous runs.__\
Old version: 0.891875 sec\
New version: 0.893618 sec

No execution time boosts noticed.

Adding ```inline``` to different functions in ```sort_i.c``` did not produce any change in cache.

Trying to find inlined functions.\
Compile sort_i.c to LLVM IR
```bash
$ clang -O0 -S -emit-llvm sort_i.c
```

All functions are preserved as expected.\
Compiling with optimizations.
```bash
$ clang -O3 -S -emit-llvm sort_i.c
```

__merge_i__ and __copy_i__ no more found in IR and so were inlined.

The inlining of __mem_alloc__ and __mem_free__ also can be seen in perf annotation.

I could make inlining work with __sort_i__ only with GCC.

* ```sort.c``` moved to ```sort.h```, __sort_i__ marked inline static

After inlining a number of branch mispredicts increased a little (0.2%) and that is not 

**Write-up 3**: Explain the possible performance downsides of inlining recursive functions. How could profiling data gathered using cachegrind help you measure these negative performance effects?

* If function size significantly increases, it may no longer fit on the cache.
Cachegrind can show this in number of cache-misses.

* Inlining grow the number of variables that may use register, it can cause utilization overhead.

## Pointers vs Arrays

The task is to use pointers instead of arrays in __sort_p__ function.

**Write-up 4**: Give a reason why using pointers may improve performance. Report on any performance differences you observed in your implementation.

* All expressions of type ```arr[k]``` changed by ```*(arr + k)```.

No changes in Cachegrind.\
No visible changes in execution time.

Differences in LLVM IR.

-O3:\
No differences.

-O0:\
The only difference found in function __merge_p__ in this line:
```
copy_p(&*(A + q + 1), right, n2);
```
specifically, in way of counting the first argument:
```
&*(A + q + 1)
```bash
$ diff sort_a.ll sort_p.ll
<   %60 = add nsw i32 %59, 1
<   %61 = sext i32 %60 to i64
<   %62 = getelementptr inbounds i32, i32* %58, i64 %61
---
>   %60 = sext i32 %59 to i64
>   %61 = getelementptr inbounds i32, i32* %58, i64 %60
>   %62 = getelementptr inbounds i32, i32* %61, i64 1
```
When indexing an array, clang calculates index first, and when
accessing a pointer, it searches for address twice.

The assemblies in -O3 don't have sufficient differences.\
-O0 diff
```
$ diff sort_a.s sort_p.s
<       movl    -16(%rbp), %eax
<       addl    $1, %eax
<       cltq
---
>       movslq  -16(%rbp), %rax
```
The assembly also corresponds to code before 2nd __copy_p__ call in __merge__ and calculates the argument in 2 less instructions.

## Coarsening

The task is to coarsen the recursion with another sorting algorithm to use in base case.

**Write-up 5**: Explain what sorting algorithm you used and how you chose the number of elements to be sorted in the base case. Report on the performance differences you observed. 

1. Insertion sort

Firstly check this algorithm. because it's already implemented.

For __base case__ of the recursion, it's only possible to choose some constant different from 1.

The execution time of ```./sort 10000000 1``` for previous sorts was about ```1.39 sec.```

Let BASE be 10, just to check.

Changed __sort_c__ stuff:
```c
#define BASE 10

static inline void sort_c(data_t *A, int p, int r)
{
    if ((p + BASE) < r)
    {
        ...<same>
    }
    else
    {
        isort(&A[p], &A[r]);
    }
}
```

Execution time has improved to ```~1.04 sec.```

Let's choose ```BASE``` wisely.\
I assume that better performance will be achieved when sorts between merges start operate with arrays that can be stored in L1 cache.

// Anyway, I suppose the most time consuming thing in current sort is memory allocation in ```merge``` routine and the result can be not clean due to ```merge``` calls reduction.

The size of L1 cache on my PC is **192 KiB**.\
So, it can store an array of ```(192 bytes * 1024) / 4 bytes``` = 49152 elements of type uint32_t.\
The first idea is that we have to sort as many elements by coarsened sort algorithm as possible up to cached limit and then merge the segments.

Measures.\
```
$ valgrind --tool=cachegrind --branch-sim=yes ./sort 100000 1
```

```
BASE = 0

==34909== I   refs:      139,520,908
==34909== I1  miss rate:        0.00%

==34909== D   refs:       59,166,047  (35,270,839 rd   + 23,895,208 wr)
==34909== D1  miss rate:         0.6% (       0.5%     +        0.7%  )

==34909== Branches:       20,327,946  (19,027,321 cond +  1,300,625 ind)
==34909== Mispred rate:          3.0% (       3.2%     +        0.0%   )
```

```
BASE = 100

==37450== I   refs:      91,732,704
==37450== I1  miss rate:       0.00%

==37450== D   refs:      33,998,912  (18,298,483 rd   + 15,700,429 wr)
==37450== D1  miss rate:        1.0% (       1.0%     +        1.0%  )

==37450== Branches:      22,418,279  (22,305,366 cond +    112,913 ind)
==37450== Mispred rate:         1.0% (       1.0%     +        0.3%   )
```

```
BASE = 1000

==38583== I   refs:      441,250,639
==38583== I1  miss rate:        0.00%

==38583== D   refs:      134,194,296  ( 68,057,498 rd   + 66,136,798 wr)
==38583== D1  miss rate:         0.3% (        0.3%     +        0.2%  )

==38583== Branches:      124,463,849  (124,361,688 cond +    102,161 ind)
==38583== Mispred rate:          0.2% (        0.2%     +        0.3%   )
```

Execution time with ```BASE = 1000``` rapidly increased to 1.6 sec. There is also a significant raise of cache references.

Perf analysis marks the inner ```while``` cycle of ```isort``` as the most hot place in code that take over 50% of time.

Best BASE: 100\
Best exec time: 1,02 sec.

## Reducing Memory Usage

The task:
* Leave only one memory scratch space between ```left``` and ```right``` in ```merge```.
* Use the input array to be sorted as the other memory scratch space in merge operation.

**Write-up 6**: Explain any difference in performance in your sort_m.c. Can a compiler automatically make this optimization for you and save you all the effort? Why or why not?

Execution time after this optimization dropped down from __1,02__ sec. to __0,76__ sec. in best run.

Performance-sensitive changes:
* Reduced memory allocation for temporary data by 2 times;
* Added condition in branch.

Cachegrind:
```
==92118== I   refs:      79,885,327
==92118== I1  misses:         1,659
==92118== I1  miss rate:       0.00%

==92118== D   refs:      20,673,854  (12,272,352 rd   + 8,401,502 wr)
==92118== D1  misses:       280,428  (   152,910 rd   +   127,518 wr)
==92118== D1  miss rate:        1.4% (       1.2%     +       1.5%  )

==92118== Branches:       8,852,240  ( 8,653,305 cond +   198,935 ind)
==92118== Mispred rate:         3.0% (       3.1%     +       0.2%   )
```

The number of cache refs was significantly decreased.\
Branch miss rate increased a little due to adding a new condition in the cycle. The condition can be removed for better performance.

-O3 option did not push compiler to do this itself.\
I'm not aware of such compiler optimizations that can do the same. The change is not trivial for compiler in my opinion.

## Reusing Temporary Memory

Task: allocate tmp buffer for merge routine only once.

**Write-up 7**: Report any differences in performance in your sort_f.c, and explain the differences using profiling data.

Implementation details:

__sort_f__ is splitted in 2 functions:
* __sort_f__ allocates tmp buffer and calls __sort_f_impl__;
* __sort_f_impl__ do the same sort, but takes buffer as argument and throws it further to __merge__;

Results:

Execution time changed a little from __0,76__ sec. to __0,72__ sec. in best run.

I'm expecting performance change due to reducing the number of __malloc__ calls.

Let's look at system calls.
```bash
$ strace ./sort 10000000 1
```
Number of __brk__ and __mmap__ calls:
* sort_m:
    * brk: 11
    * mmap: 22
* sort_f:
    * brk: 4
    * mmap: 15

The number of memory managing calls reduced.

Perf data of sort_m:
* call malloc use only 0,02% of time.
// mem_free takes a little more

Cachegrind:
```
==102039== I   refs:      74,155,294
==102039== I1  miss rate:       0.00%

==102039== D   refs:      14,298,937  (8,732,558 rd   + 5,566,379 wr)
==102039== D1  miss rate:        1.9% (      1.7%     +       2.2%  )

==102039== Branches:       5,878,953  (5,778,308 cond +   100,645 ind)
==102039== Mispred rate:         4.6% (      4.7%     +       0.3%   )
```

Notable changes:
* > 25% D refs drop;
* > 30% branches drop.

**Final run with all sorts**

```bash
$ ./sort 10000000 1

sort_a          : Elapsed execution time: 0.936171 sec
sort_a repeated : Elapsed execution time: 1.121375 sec
sort_i          : Elapsed execution time: 1.165944 sec
sort_p          : Elapsed execution time: 0.901534 sec
sort_c          : Elapsed execution time: 0.709929 sec
sort_m          : Elapsed execution time: 0.754481 sec
sort_f          : Elapsed execution time: 0.736368 sec
```
