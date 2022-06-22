# The Cilk Runtime System

**Recall: Cilk Scheduling**

* The Cilk concurrency platform allows the
programmer to express __logical parallelism__
in an application.

* The Cilk __scheduler__ maps the executing program
onto the processor cores dynamically at runtime.

* Cilk's __work-stealing scheduling algorithm__
is provably efficient.

**The Cilk Platform**

The compiler links binary with runtime-system library ```libcilkrts.so```.

The compiler and runtime library together implement the runtime system.

**Outline**

* Required functionality
* Performance considerations
* Implementing a worker deque
* Spawning computation
* Stealing computation
* Synchronizing computation

**Required functionality**

* A single worker must be able to execute the
computation on its own similarity to an
ordinary __serial computation__.

* A thief must be able to jump into the
middle of an executing function to __steal a continuation__.

* A sync must stall a function's execution until
__child subcomputation__ complete.

* The runtime must implement a __cactus stack__
for its parallel workers.

* Thieves must be able to handle __mixtures of called spawned functions__.

**Cactus Stack**

Cilk's __cactus stack__ supports
multiple views in parallel.

**Recall: Work Stealing**

Each worker (processor) maintains a __work deque__ of
ready strands, and it manipulates the bottom of the
deque like a stack.

Each deque contains a mixture of
spawned frames and called frames.

If a worker runs out of work, it __steals__
from the top of a __random__ victim's deque.

A steal takes __all__ frames up to the next spawned frame.

```
|spawned|          |spawned| |spawned|
|called |          |called | |called |
|called |          |spawned| |spawned|
|called |          |called |
|spawned|          |called |
|spawned|      steal
              /
   (P)       (P)       (P)       (P)
 |
 V

|spawned| |spawned|          |spawned|
|called | |called |          |called |
|called |          |spawned| |spawned|
|called |          |called |
|spawned|          |called |
|spawned|

   (P)       (P)       (P)       (P)
```

* What is __involved__ in stealing frames?
* What __synchronization__ is needed?
* What happens to the __stack__?
* How __efficient__ can this be?

**Performance Considerations**

**Recall: Work-Stealing Bounds**

**Theorem.** The Cilk work-stealing scheduler
achieves expected running time
```
Tp ≈ T1/P  +  O(Tinf)
      |          |
 Time workers    Time workers
 spend working   spend stealing
```
on P processors.

If the program achieves __linear speedup__, then
workers spend most of their time __working__.

**Parallel Speedup**

Ideally, parallelizing a serial code makes it run P times
faster on P processors.

**Work Efficiency**

Let Ts denote the work of a serial program.
Suppose the serial program is parallelized.
Let T1 denote the work of the parallel program,
and let Tinf denote the span of the parallel program.

To achieve linear speedup on P processors
over the serial program, i.e., Tp ≈ Ts/P,
the parallel program must exhibit:

* Ample __parallelism__: T1/Tinf >> P.
* High __work efficiency__: Ts/T1 ≈ 1.

**The Work-First Principle**

To optimize the execution of programs with
__sufficient parallelism__, the implementation of
the Cilk runtime system works to maintain high
work-efficiency by abiding by the __work-first principle__:\
Optimize for the __ordinary serial execution__,
at the expense of some additional computation in steals.

**Division of Labor**

The work-first principle guides the division of
the Cilk runtime system between the __compiler__
and the __runtime library__.

**Compiler**

* Uses a handful of __small data structures__, e.g.,
workers and stack frames.

* Implements optimized __fast paths__ for
execution of functions when no steals have occured.

**Runtime library**

* Uses __larger data structures__.

* Handles __slow paths__ of execution, e.g., when a steal occurs.

**Implementing a Worker Deque**

**Running Example**

```c++
int foo(int n) {
    int x, y;
    x = cilk_spawn bar(n);
    y = baz(n);
    cilk_sync;
    return x + y;
}
```

* Function ```foo``` is a __spawning function__,
meaning that ```foo```contains a ```cilk_spawn```.

* Function ```bar``` is __spawned__ by ```foo```.

* The call to ```baz``` occurs in the __continuation__ of the spawn.

**Requirements of Worker Deques**

Problem: How do we implement a worker's deque?

* The worker should operate its own deque like a stack.
* A steal needs to transfer ownership of several
consecutive frames to a thief.
* A thief needs to be able to resume a continuation.

**Basic Worker-Deque Design**

IDEA: The worker deque is an external structure with
pointers to stack frames.

* A Cilk worker maintains __head and tail pointers__ to its deque.
* Stealable frames maintain a local __structure__ to store information
necessary for stealing the frame.

**Implementation Details**

The Intel Cilk Plus runtime elaborates on this
idea as follows:

* Every spawned subcomputation runs in its own
__spawn-helper__ function.

* The runtime maintains three basic data
structures as workers execute work:

    * A __worker structure__ for every worker used
    to execute the program.

    * A __Cilk stack-frame structure__ for each
    instantiation of a spawning function.

    * A __spawn-helper stack frame__ for each
    instantiation of a ```cilk_spawn```.

**The Cilk Stack Frame (Simplified)**

Each Cilk stack frame stores:

* A __context buffer__, ```ctx```, which contains enough
information to resume a function at a continuation,
i.e., after a ```cilk_spawn``` or ```cilk_sync```.

* An integer, ```flags```, that summarizes the __state__ of
the Cilk stack frame.

* A pointer, ```parent```, to its __parent__ Cilk stack frame.

**The Cilk Worker Structure (Simplified)**

Each Cilk worker maintains:

* A __deque__ of stack frames that can be stolen.
* A pointer to the __current stack frame__.

**Spawning Computation**

**Code for a Spawning Function**

C pseudocode of a spawning function
```c
int foo(int n) {
    __cilkrts_stack_frame_t st;  | Create and initialize a Cilk
    __cilkrts_enter_frame(&sf);  | stack-frame structure.
    int x, y;
    if (!setjmp(sf.ctx))  | Prepare to spawn.
        spawn_bar(&x, n);  | Invoke the spawn helper.
    y = baz(n);
    if (sf.flags & CILK_FRAME_UNSYNCHED)  | Perform a sync.
        if (!setjmp(sf.ctx))              |
            __cilkrts_sync(&sf);          |
    int result = x + y;
    __cilkrts_pop_frame(&sf);  | Clean up the Cilk stack-frame structure.
    if (sf.flags)                    | Clean up
        __cilkrts_leave_frame(&sf);  | the deque.
    return result;
}
```

**Code for a Spawn Helper**

C pseudocode of a spawn helper
```c
void spawn_bar(int *x, int n) {
    __cilkrts_stack_frame sf;         | Create and initialize a Cilk
    __cilkrts_enter_frame_fast(&sf);  | stack-frame structure.

    __cilkrts_detach();  | Update the deque to allow
                         | the parent to be stolen.

    *x = bar(n);  | Invoke the spawned subroutine.

    __cilkrts_pop_frame(&sf);  | Clean up the Cilk stack-frame structure.
    __cilkrts_leave_frame(&sf);  | Clean up the deque and attempt to return.
}
```

**Entering a Spawning Function**

When execution enters a spawning function, the
Cilk worker's current stack-frame structure is updated.

**Preparing to Spawn**

Cilk code
```c
int foo(int n) {
    ...
    x = cilk_spawn bar(n);
    ...
}
```

C pseudocode
```c
int foo(int n) {
    ...
    if (!setjmp(sf.ctx))
        spawn_bar(&x, n);
    ...
}
```

Cilk uses the ```setjmp``` function to allow thieves to
steal the continuation.

The ```setjmp``` function stores information necessary for
resuming the function at the ```setjmp``` into the given buffer.

Q: What information needs to be saved?

A: Registers %rip, %rbp, %rsp, and callee-saved registers.

**Spawning a Function**

C pseudocode
```c
int foo(int n) {
    ...
    if (!setjmp(sf.ctx))
        spawn_bar(&x, n);
    ...
}

void spawn_bar(int *x, int n) {
    __cilkrts_stack_frame sf;
    __cilkrts_enter_frame_fast(&sf);
    __cilkrts_detach();
    *x = bar(n);
}
```

**Returning from a Spawn**

C pseudocode
```c
void spawn_bar(int *x, int n) {
    ...
    *x = bar(n);
    __cilkrts_pop_frame(&sf);
    __cilkrts_leave_frame(&sf);
}
```

**Popping the Deque**

In ```__cilkrts_leave_frame```, the worker tries to
__pop__ the stack frame from the __tail__ of the deque.\
There are two possible outcomes:
1. If the pop __succeeds__, then the execution
continues as normal.
2. If the pop __fails__, then the worker is out of
work to do. It thus becomes a __thief__ and
tries to steal work from the top of a __random__
victim's deque.

Q: Which case is more important to optimize?

A: Case 1.

**Recall: Stealing Work**

Conceptually, a thief takes frames off of the
top of a victim worker's deque.

Need to handle concurrent accesses to the deque.

**Synchronizing Deque Accesses**

Worker protocol
```c
void push() {
    tail++;
}
bool pop() {
    tail--;
    if (head > tail) {
        tail++;
        lock(L);
        tail--;
        if (head > tail) {
            tail++;
            unlock(L);
            return FAILURE;
        }
        unlock(L);
    }
    return SUCCESS;
}
```

The worker and thief coordinate operations
on the deque using the __THE protocol__:

__Thief protocol__
```c
bool steal() {
    lock(L);
    head++;
    if (head > tail) {
        head--;
        unlock(L);
        return FAILURE;
    }
    unlock(L);
    return SUCCESS;
}
```

The thief always grabs a lock before operating on the deque.

The worker only grabs a lock if the deque appears to be empty.

**Resuming a Continuation**

Cilk uses the ```longjmp``` function to __resume__ a stolen continuation.\
Previously, the victim performed a ```setjmp``` to store register state in foo_sf.ctx.\
Executing ```longjmp(current_sf->ctx, 1)``` sets the thief's registers
to start executing at the location of the ```setjmp```.

**Implementing the Cactus Stack**

Thieves maintain their own call stacks and use pointer tricks to implement the cactus stack.

Example: A thief steals the continuation of ```foo```, and then calls ```baz```.

**More Cilk Runtime Features**

The Cilk runtime system implements many
other features and optimizations:

* Schemes for making the full-frame tree
simpler and easier to maintain.

* Data structure and protocol enhancements
to support C++ exceptions.

* Sibling pointers between full frames to
support __reducer hyperobjects__.

* __Pedigrees__ to assign a unique, deterministic
ID to each strand efficiently in parallel.
