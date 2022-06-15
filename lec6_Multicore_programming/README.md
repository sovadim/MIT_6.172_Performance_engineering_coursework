# Multicore Programming

## Shared-Memory Hardware

Cache coherence problem

Each processor has its own private cache that may cause to inconsistency of variable value throughout processors' caches.

**MSI Protocol**

Each cache line is labeled with a __state__:

* **M:** cache block has been __modified__. No other caches contain this block in **M** or **S** states.

* **S**: other caches may be __sharing__ this block.

* **I**: cache block is __invalid__.

Before a cache modifies a location, the hardware first invalidates all other copies.

**Concurrency Platforms**

Examples:

* Pthreads
* Threading Building Blocks
* OpenMP
* Cilk

A __concurrency platform__ abstracts processor cores,
handles synchronization and communication protocols,
and performs load balancing.

**Pthreads**

* Each thread implements an abstraction of a processor, which are multiplexed onto machine resources.
* Threads communicate through __shared memory__.
* Library fucntions mask the __protocols__ involved in interthread coordination.

**Key Pthread Functions**

```c
int pthread_create(
    pthread_t *thread,          // returned identifier for the new thread
    const pthread_attr_t *attr, // object to set thread attributes (NULL for default)
    void *(*func)(void *),      // routine executed after creation
    void *arg                   // a single argument passed to func
) // returns error status
```

```c
int pthread_join(
    pthread_t thread,   // identifier of thread to wait for
    void **status       // terminating thread's status (NULL to ignore)
) // returns error status
```

Fibonacci function implemented in ```fib_pthreads.c```.

**Issues with Pthreads**

* **Overhead**\
    The cost of creating a thread >10^4 cycles => coarse-grained concurrency. (Thread pools can help)

* **Scalability**\
    Fibonacci code gets at most about 1.5 speedup for 2 cores.

* **Modularity**\
    The Fibonacci logic is no longer neatly encapsulated in the fib() function.

* **Code simplicity**\
    Programmers must marshal arguments and engage in error-prone protocols in order to load-balance.

**Threading Building Blocks**

* Implemented as a __C++ library__ that runs on top of native threads.

* Programmers specifies __tasks__ rather than threads.

* Tasks are automatically load balanced across the threads using a __work-stealing__ algorithm.

* Focus on __performance__. 

**OpenMP**

* Specification by an industry consortium.

* Several compilers available, including __GCC__, __ICC__, __Clang__, __MSVC__.

* Linguistic extensions to C/C++ and Fortran in the form of compiler pragmas.

* Runs on top of native threads.

* Supports loop parallelism, task parallelism and pipeline parallelism.

* OpenMP provides many pragma directives to express common patterns, such as:
    * __parallel_for__ for loop parallelism,
    * __reduction__ for data aggregation,
    * directives for sceduling and data sharing.

* OpenMP supplies a variety of __syncronization constructs__, such as
barriers, atomic updates, and mutual-exclusion (mutex) locks.

**Intel Cilk Plus**

* __Cilk__ is a small set of __linguistic extensions to C/C++__ to support __fork-join parallelism__.

* __Plus__ means support of __vector parallelism__.

* Features a provably efficient __work-stealing__ scheduler.

* Provides a __hyperobject__ library for parallelizing code with global variables.

* Ecosystem includes the __Cilkscreen__ race detector and __Cilkview__ scalability analizer.

**Tapir/LLVM and Cilk**

* Generally produces __better code__ relative to its base compiler than other implementations of Cilk.

* Uses __Intel's Cilk Plus runtime system__.

* Supports __more general features__, such as the spawning of code blocks.

Cilk keywords __grant permission__ for parallel execution. The do not __commant__ parallel execution.

**Loop Parallelism in Cilk**

Example: In-place matrix transpose.

```c++
cilk_for (int i = 1; i < n; ++i) [
    for (int j = 0; j < i; ++j) {
        double temp = A[i][j];
        A[j][i] = A[j][i];
        A[j][i] = temp;
    }
]
```

**Reducers in Cilk**

Example: Parallel summation.

```c++
CILK_C_REDUCER_OPADD(sum, unsigned long, 0);
CILK_C_REGISTER_REDUCER(sum);
cilk_for (int i = 0; i < n; ++i) {
    REDUCER_VIEW(sum) += i;
}
printf("The sum is %f\n", REDUCER_VIEW(sum));
CILK_C_UNREGISTER_REDUCER(sum);
```

Reducers can be created for __monoids__ (algebraic structures with associative binary operation and an identity element)

Cilk has several predefined reducers (add, multiply, min, max, and, or, xor, etc.)

**Scheduling**

* The Cilk concurrency platform allows the programmer to express __logical parallelism__ in an application.

* The Cilk __scheduler__ maps the executing program onto the processor cores dynamically at runtime.

* Cilk's __work-stealing scheduling algorithm__ is provably efficient.
