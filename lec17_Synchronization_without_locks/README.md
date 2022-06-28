# Synchronization Without Locks

**Sequential Consistency**

**Memory Models**

Initially, a = b = 0.

```
Processor 0             Processor 1

mov 1, a    ; Store     mov 1, b    ; Store
mov b, %ebx ; Load      mov a, %eax ; Load
```

**Q.** Is it possible that Processor 0's ```%ebx``` and
Processor 1's ```%eax``` both contain the value ```0``` after
the processors have both executed their code?

**A.** It depends on the __memory model__: how memory
operations behave in the parallel computer system.

**Sequential Consistency**

The result of any execution is the same as
if the operations of all the processors were
executed in some sequential order, and the
operations of each individual processor
appear in this sequence in the order specified
by its program. (Leslie Lamport)

* The sequence of instructions as defined by a processor's
program are __interleaved__ with the corresponding sequences
defined by the other processors' programs to produce a global
__linear order__ of all instructions.

* A ```LOAD``` instruction receives the value stored to that address by
the most recent ```STORE``` instruction that precedes the ```LOAD```,
according to the linear order.

* The hardware can do whatever it wants, but for the execution
to be sequentially consistent, it must __appear__ as if ```LOAD```'s and
```STORE```'s obey some global linear order.


```
Processor 0                 Processor 1

(1) mov 1, a    ; Store     (3) mov 1, b    ; Store
(2) mov b, %ebx ; Load      (4) mov a, %eax ; Load
```

```
     _______________________
    |_____Interleavings_____|
    |_1_|_1_|_1_|_3_|_3_|_3_|
    |_2_|_3_|_3_|_1_|_1_|_4_|
    |_3_|_2_|_4_|_2_|_4_|_1_|
____|_4_|_4_|_2_|_4_|_2_|_2_|
%eax|_1_|_1_|_1_|_1_|_1_|_0_|
%ebx|_0_|_1_|_1_|_1_|_1_|_1_|
```

**Reasoning About Sequential Consistency**

* An execution induces a __"happens before"__ relation,
which we shall denote as **->**.

* The **->** relation is __linear__, meaning that for any two
distinct instructions ```x``` and ```y```, either ```x -> y``` or ```y -> x```.

* The **->** relation respects __processor order__, the order
of instructions in each processor.

* A ```LOAD``` from a location in memory reads the value
written by the __most recent__ ```STORE``` to that location
according to ```->```.

* For the memory resulting from an execution to be
sequentially consistent, there must exist such a
linear order ```->``` that yields that memory state.

**Mutual Exclusion Without Locks**

**Mutual-Exclusion Problem**

**Recall**
A __critical section__ is a piece of code that accesses
a shared data structure that must not be accessed
by two or more threads at the same time (__mutual exclusion__).

Most implementations of mutual exclusion
employ an __atomic read-modify-write__ instruction
or the equivalent, usually to implement a lock:
* e.g., ```xchg```, test-and-set, compare-and-swap,
load-linked-store-conditional.

**Q.** Can mutual exclusion be implemented with
```LOAD```'s and ```STORE```'s as the only memory operations?

**A.** Yes, Dekker and Dijkstra showed that it can,
as long as the computer system is sequentially consistent.

**Peterson's ALgorithm**

```c
                        widget x; // protected variable
                        bool A_wants = false;
                        bool B_wants = false;
                        enum {A, B} turn;
                                |
                    ____________|____________
Alice              |                         |                Bob
                   V                         V
A_wants = true;                     B_wants = true;
turn = B;                           turn = A;
while (B_wants && turn == B);       while (A_wants && turn == A);
frob(&x); // critical section       borf(&x); // critical section
A_wants = false;                    B_wants = false;
```

**Intuition**
 
* If __Alice__ and __Bob__ both try to enter the critical section,
then whoever writes last to __turn__ spins and the other progresses.
* If only __Alice__ tries to enter the critical section, then she
progresses, since ```B_wants``` is false.
* If only __Bob__ tries to enter the critical section, then he
progresses, since ```A_wants``` is false.

**Proof of Mutual Exclusion**

**Theorem.** Peterson's algorithm achieves
mutual exclusion on the critical section.

**Proof.**
* Assume for the purpose of contradiction that both
__Alice__ and __Bob__ find themselves in the critical
section together.
* Consider __the most-recent time__ that each of them
executed the code before entering the critical section.
* We shall derive a contradiction.
* WLOG, assume that __Bob__ was the last to write to ```turn```:\
$ write_A (turn = B) \rightarrow write_B (turn = A) $
* __Alice__'s program order:\
$ write_A (A_wants = true) \rightarrow write_A (turn = B) $
* __Bob__'s program order:\
$ write_B (turn = A) \rightarrow read_B (A_wants) \rightarrow read_B (turn) $
* What did __Bob__ read?
```
A_wants: true  | Bob should spin.
turn: A        | Contradiction.
```

**Starvation Freedom**

**Theorem.** Peterson's algorithm guarantees
__starvation freedom__: While __Alice__ wants to execute
her critical section, __Bob__ cannot execute his critical
section twice in a row, and vice versa.

**Relaxed Memory Consistency**

**Memory Models Today**

* No modern-day processor implements sequential consistency.
* All implement some form of __relaxed consistency__.
* Hardware actively reorders instructions.
* Compilers may reorder instructions too.

**Instruction Reordering**

```
Program order           Execution order
mov 1, a    ; Store     mov b, %ebx ; Load
mov b, %ebx ; Load      mov 1, a    ; Store
```

**Q.** Why might the hardware or compiler decide to
reorder these instructions?

**A.** To obtain higher performance by covering load
latency - __instruction-level parallelism__.

**Q.** When is it safe for the hardware or compiler to
perform this reordering?

**A1.** When a ≠ b.

**A2.** There's no concurrency.

**Hardware Reordering**

```
           ______Load_Bypass___
          |   ______________   V           ________
        ---->|_Store_Buffer_|------------>| Memory |
Processor                       Network   | System |
        <---------------------------------|________|
```

* The processor can issue ```STORE```'s faster than the
network can handle them => __store buffer__.
* Since a ```LOAD``` can stall the processor until it is satisfied,
__loads take priority__, bypassing the store buffer.
* If a ```LOAD``` address matches an address in the store
buffer, the store buffer returns the result.
* Thus, a ```LOAD``` can __bypass__ a ```STORE``` to a different address.

**x86-64 Total Store Order**

**House rules:**

1. ```LOAD```'s are __not__ reordered with ```LOAD```'s.
2. ```STORE```'s are __not__ reordered with ```STORE```'s.
3. ```STORE```'s are __not__ reordered with __prior__ ```LOAD```'s.
4. A ```LOAD``` may be reordered with a prior
```STORE``` to a __different__ location but __not__
with a prior __STORE__ to the __same__ location.
5. ```LOAD```'s and ```STORE```'s are __not__ reordered
with ```LOCK``` instructions.
6. ```STORE```'s to the same location respect a __global total order__.
7. ```LOCK``` instructions respect a __global total order__.
8. Memory ordering preserves __transitive visibility__ ("causality").

Total Store Ordering (TSO) is weaker than sequential consistency.

**Impact of Reordering**

```
Processor 0                 Processor 1
(1) mov 1, a    ; Store     (3) mov 1, b    ; Store
(2) mov b, %ebx ; Load      (4) mov a, %eax ; Load

(2) mov b, %ebx ; Load      (4) mov a, %eax ; Load
(1) mov 1, a    ; Store     (3) mov 1, b    ; Store
```
The ordering <2, 4, 1, 3> produces ```%eax = %ebx = 0```.

Instruction reordering violates sequential consistency.

**Further Impact of Reordering**

**Peterson's algorithm revisited**

```c
Alice                           Bob

A_wants = true;                 B_wants = true;
turn = B;                       turn = A;
while (B_wants && turn == B);   while (A_wants && turn == A);
frob(&x); // critical section   borf(&x); // critical section
A_wants = false;                B_wants = false;
```

* The ```LOAD```'s of ```B_wants``` and ```A_wants``` can be reordered
before the ```STORE```'s of ```A_wants``` and ```B_wants```, respectively.
* Both __Alice__ and __Bob__ might enter their critical sections
simultaneously.

**Memory Fences**

* A __memory fence__ (or __memory barrier__) is a hardware
action that enforces an __ordering__ constraint between the
instructions before and after the fence.
* A memory fence can be issued explicitly as an
instruction (x86: ```mfence```) or be performed __implicitly__ by
locking, exchanging, and other synchronizing instructions.
* The Tapir/LLVM compiler implements a memory fence
via the function ```atomic_thread_fence()```.
* The typical cost of a memory fence is comparable to
that of an __L2-cache access__.

**Restoring Consistency**

```c
Alice                           Bob

A_wants = true;                 B_wants = true;
turn = B;                       turn = A;
atomic_thread_fence();          atomic_thread_fence();
while (B_wants && turn == B);   while (A_wants && turn == A);
frob(&x); // critical section   borf(&x); // critical section
A_wants = false;                B_wants = false;
```

You also need to make sure that the __compiler__
doesn't screw you over.

```c
Alice                           Bob

A_wants = true;                 B_wants = true;
turn = B;                       turn = A;
atomic_thread_fence();          atomic_thread_fence();
while (B_wants && turn == B);   while (A_wants && turn == A);
asm volatile("":::"memory");    asm volatile("":::"memory");
frob(&x); // critical section   borf(&x); // critical section
asm volatile("":::"memory");    asm volatile("":::"memory");
A_wants = false;                B_wants = false;
```

In addition to the memory fence:
* You must declare variables as ```volatile``` to prevent the
compiler from optimizing away memory references;
* You need __compiler fences__ around ```frob()``` and ```borf()``` to
prevent compiler reordering.

**Restoring Consistency with C11**

```c
Alice                           Bob

atomic_store(&A_wants, true);   atomic_store(&B_wants, true);
atomic_store(&turn, B);         atomic_store(&turn, A);
while(atomic_load(&B_wants) &&  while(atomic_load(&A_wants) &&
      atomic_load(&turn) == B);       atomic_load(&turn) == A;
frob(&x); // critical section   borf(&x); // critical section
atomic_store(&A_wants, false);  atomic_store(&B_wants, false);
```

The C11 language standard defines its own weak
memory model, in which you can control hardware and
compiler reordering of memory operations by:
* Declaring variables as ```_Atomic```; and
* Using the functions ```atomic_load()```, ```atomic_store()```,
etc. as needed.

**Implementing General Mutexes**

**Theorem.** Any ```n```-thread deadlock-free
mutual-exclusion algorithm using only ```LOAD``` and
```STORE``` memory operations requires __Ω(n)__ space.

**Theorem.** Any ```n```-thread deadlock-free
mutual-exclusion algorithm on a modern
machine must use an expensive operation such
as a __memory fence__ or an __atomic compare-and-swap__
operation.

**Compare-and-Swap**

The __compare-and-swap__ operation is provided by the
```cmpxchg``` instruction on x86-64. The C header file
```stdatomic.h``` provides __CAS__ via the built-in function\
```atomic_compare_exchange_strong()```\
which can operate on various integer types.

```c
bool CAS(T *x, T old, T new) {
    if (*x == old) {
        *x = new;
        return true;
    }
    return false;
}
```

* Executes atomically.
* Implicit fence.

**Mutex Using CAS**

**Theorem.** An ```n```-thread deadlock-free
mutual-exclusion algorithm using ```CAS```
can be implemented using Θ(1) space.

**Proof.**
```c
void lock(int *lock_var) {
    while (!CAS(lock_var, false, true));
}
```

```c
void unlock(int *lock_var) {
    *lock_var = false;
}
```

**Summing Problem**

```c
int compute(const X& v);
int main() {
    const int n = 1000000;
    extern X myArray[n];
    // ...

    int result = 0;
    cilk_for(int i = 0; i < n; ++i) {
        result += compute(myArray[i]); // Race
    }
    printf("%d", result);
    return 0;
}
```

**Mutex Solution**

```c
int compute(const X& v);
int main() {
    const int n = 1000000;
    extern X myArray[n];
    mutex L;
    // ...

    int result = 0;
    cilk_for(int i = 0; i < n; ++i) {
        int temp = compute(myArray[i]);
        L.lock();
        result += temp;
        L.unlock();
    }
    printf("%d", result);
    return 0;
}
```

**Q.** What happens if the OS swaps out a loop
iteration just after it acquires the mutex?

**A.** All other loop iterations must wait.

Yet all we want is to atomically execute a ```LOAD```
of ```x``` followed by a store of ```x```.

**CAS Solution**

```c
int result = 0;
cilk_for(int i = 0; i < n; ++i) {
    int temp = compute(myArray[i]);
    int old, new;
    do {
        old = result;
        new = old + temp;
    } while (!CAS(&result, old, new));
}
```

**Q.** Now what happens if the OS
swaps out a loop iteration?

**A.** No other loop iteration needs
to wait. The algorithm is __nonblocking__.
