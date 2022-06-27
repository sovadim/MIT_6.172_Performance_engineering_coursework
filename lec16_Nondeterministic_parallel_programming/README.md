# Nondeterministic Parallel Programming

**Determinism**

**Definition.** A program is __deterministic__ on
a given input if every memory location is
updated with the same sequence of values
in every execution.

* The program always behaves the same way.
* Two different memory locations may be updated
in different orders, but each location always
sees the same sequence of updates.

Advantage: Debugging.

**Golden Rule of Parallel Programming**

__Never__ write nondeterministic parallel programs.

**Silver Rule of Parallel Programming**

__Never__ write nondeterministic parallel programs.
But if you must (for performance reasons) always
devise a test strategy to manage the nondeterminism.

**Typical test strategies**

* Turn off nondeterminism.
* Encapsulate nondeterminism.
* Substitute a deterministic alternative.
* Use analysis tools.

**Mutual Exclusion & Atomicity**

**Hash Table**

```
 ___     ___ ___     ___ ___
|_*-|-->|_x_|_*-|-->|_x_|_*_|
|_*-|-->|_x_|_*_|
|_*_|
|_*_|
```

Insert ```x``` into table
```c
slot = hash(x->key);
x->next = table[slot];
table[slot] = x;
```

**Concurrent Hash Table**

```c
slot = hash(x->key);    (1)
x->next = table[slot];  (2)
table[slot] = x;        (6)

slot = hash(y->key);    (3)
y->next = table[slot];  (4)
table[slot] = y;        (5)

RACE BUG!
```

**Atomicity**

**Definition.** A sequence of instructions is
__atomic__ if the rest of the system cannot ever
view them as partially executed. At any
moment, either no instructions in the
sequence have executed or all have executed.

**Definition.** A __critical section__ is a piece of
code that accesses a shared data structure
that must not be accessed by two or more
threads at the same time (__mutual exclusion__).

**Definition.** A __mutex__ is an object with ```lock``` and
```unlock``` member functions. An attempt by a thread
to lock an already locked mutex causes that thread
to __block__ (i.e., wait) until the mutex is unlocked.

**Modified code:** Each slot is a ```struct``` with a mutex
```L``` and a pointer ```head``` to the slot contents.

```c
slot = hash(x->key);
lock(&table[slot].L);
x->next = table[slot].head; | critical
table[slot].head = x;       | section
unlock(&table[slot].L);
```

Mutexes can be used to implement atomicity.

**Recall: Determinacy Races**

// definition recall

* A program execution with no determinacy races
means that the program is deterministic on that input.

* The program always behaves thr same on that input,
no matter how it is scheduled and executed.

* If determinacy races exist in an ostensibly
deterministic program (e.g., a program with no
mutexes), Cilksan guarantees to find such a race.

**Data Races**

**Definition.** A __data race__ occurs when two logically
parallel instructions __holding no locks in common__
access the same memory location and at least one
of the instructions performs a write.

Although data-race-free programs obey atomicity
constraints, they can still be nondeterministic,
because acquiring a lock can cause a determinacy
race with another lock acquisition.

**No Data Races ≠ No Bugs**

Example
```c
slot = hash(x->key);

lock(&(table[slot].L));
x->next = table[slot].head;
unlock(&(table[slot].L));

lock(&table[slot].L);
table[slot].head = x;
unlock(&table[slot].L);

No data race, atomicity violation
```

**"Benign" Races**

Example: Identify the set of digits in an array.

```c
for (int i = 0; i < 10; ++i) {
    digits[i] = 0;
}
cilk_for(int i = 0; i < N; ++i) {
    digits[A[i]] = 1; // benign race
}
// we don't care about the race here
```

Caution: This code only works correctly if the
hardware writes the array elements atomically -
e.g., it races for byte values on some architectures.

**Implementation of Mutexes**

**Properties of Mutexes**

* **Yielding / spinning**\
A yielding mutex returns control to the operating
system when it blocks. A spinning mutex consumes
processor cycles while blocked.

* **Reentrant / nonreentrant**\
A reentrant mutex allows a thread that is already
holding a lock to acquire it again. A nonreentrant
mutex deadlocks if the thread attempts to reacquire
a mutex it already holds.

* **Fair / unfair**\
A fair mutex puts blocked threads on a FIFO queue,
and the unlock operation unblocks the thread that
has been waiting the longest. An unfair mutex lets
any blocked thread go next.

**Simple Spinning Mutex**

```
Spin_Mutex:
    cmp 0, mutex ; Check if mutex is free
    je Get_Mutex
    pause ; x86 hack to unconfuse pipeline
    jmp Spin_Mutex
Get_Mutex:
    mov 1, %eax
    xchg mutex, %eax ; Try to get mutex
    cmp 0, %eax ; Test if successful
    jne Spin_Mutex
Critical_Section:
    <critical-section code>
    mov 0, mutex ; Release mutex
```

**Key property:** ```xchg``` is an atomic exchange.

**Simple Yielding Mutex**

```
Spin_Mutex:
    cmp 0, mutex ; Check if mutex is free
    je Get_Mutex
    call pthread_yield ; Yield quantum
    jmp Spin_Mutex
Get_Mutex:
    mov 1, %eax
    xchg mutex, %eax ; Try to get mutex
    cmp 0, %eax ; Test if successful
    jne Spin_Mutex
Critical_Section:
    <critical-section code>
    mov 0, mutex ; Release mutex
```

**Competitive Mutex**

**Competing goals:**

* To claim mutex soon after it is released.
* To behave nicely and waste few cycles.

IDEA: Spin for a while, and then yield.

**How long to spin?**\
As long as a context switch takes. Then, you
never wait longer than twice the optimal time.

* If the mutex is released while spinning, optimal.
* If the mutex is released after yield, __<= 2 x__ optimal.

**Randomized algorithm**\
A clever randomized algorithm can achieve a
competitive ratio of __e/(e-1) ≈ 1.58__.

**Locking Anomaly: Deadlock**

Holding more than one lock at a time can be dangerous:

```c
// Thread 1             // Thread 2
lock(&A);               lock(&B);
lock(&B);               lock(&A);
<critical section>      <critical section>
lock(&B);               unlock(&A);
lock(&A);               unlock(&B);
```

**Conditions for Deadlock**

1. **Mutual exclusion** - Each thread claims
exclusive control over the resources it holds.

2. **Nonpreemption** - Each thread does
not release the resources it holds until
it completes its use of them.

3. **Circular waiting** - A cycle of threads
exists in which each thread is blocked
waiting for resources held by the next
thread in the cycle.

**Dining Philosophers**

Each of __n__ philosophers needs the two chopstick
on either side of his plate to eat his noodles.

Philosopher __i__
```c
while (1) {
    think();
    lock(&chopstick[i].L);
    lock(&chopstick[(i+1)%n].L);
    eat();
    unlock(&chopstick[i].L);
    unlock(&chopstick[(i+1)%n].L);
}
```

**Preventing Deadlock**

**Theorem.** Assume that we can linearly order the
mutexes __L1 < L2 <...< Ln__ so that whenever a
thread holds a mutex __Li__ and attempts to lock
another mutex __Lj__, we have __Li < Lj__. Then, no
deadlock can occur.

**Proof.** Suppose that a cycle of waiting exists. Consider the
thread in the cycle that holds the "largest" mutex __Lmax__ in the
ordering, and suppose that it is waiting on a mutex __L__ held by
the next thread in the cycle. Then, we must have __Lmax < L__.
Contradiction.

Philosopher __i__
```c
while (1) {
    think();
    lock(&chopstick[min((i+1)%n)].L);
    lock(&chopstick[max((i+1)%n)].L);
    eat();
    unlock(&chopstick[i].L);
    unlock(&chopstick[(i+1)%n].L);
}
```

**Deadlocking Cilk**

```c
void main() {
    cilk_spawn foo();
    lock(&L);
    cilk_sync;
    unlock(&L);
}

void foo() {
    lock(&L);
    unlock(&L);
}
```

* Don't hold mutexes across __cilk_sync__.
* Hold mutexes only within strands.
* As always, try to avoid nondeterministic
programming.

**Transactional Memory**

```c
Gaussian_Eliminate(G, v) {
    atomic {
        S = neighbors[v];
        for u ∈ S {
            E(G) = E(G) - {(u, v)};
            E(G) = E(G) - {(v, u)};
        }
        V(G) = V(G) - {v};
        for u ∈ S
            for u' ∈ S - {u}
                E(G) = E(G) ⋃ {(u, u')};
    }
}
```

**Atomicity**
* On transactional __commit__, all memory updates in
the critical region appear to take effect at once.
* On transaction __abort__, none of the memory
updates appear to take effect, and the transaction
must be __restarted__.
* A restarted transaction may take a different
code path.

**Definitions**

**Conflict**\
When two or more transactions attempt to access
the same location of transactional memory concurrently.

**Contention resolution**\
Deciding which of two conflicting transactions to
wait or to abort and restart, and under what conditions.

**Forward progress**\
Avoiding deadlock, __livelock__, and __starvation__.

**Throughput**\
Run as many transactions concurrently as possible.

**Algorithm L**

Assume that the transactional-memory system
provides mechanisms for
* logging reads and writes,
* aborting and rolling back transactions,
* restarting.

Algorithm L employs a lock-based approach that
combines two ideas:
* finite ownership array,
* release-sort-reacquire.

**Finite Ownership Array**

* An array ```lock[0..n-1]``` of antistarvation (queuing)
__mutual-exclusive locks__, which support:
    * Acquire: Grab lock l, blocking until it becomes available.
    * Try_Acquire: Try to grab lock l, and return true or
    false to indicate success or failure, respectively.
    * Release: Release lock l.

* An __owner function__ h: U -> {0, 1, ..., n-1} mapping
the space U of memory locations to indexes in ```lock```.
* To lock location x ∈ U, acquire ```lock[h(x)]```.

**Release-Sort-Reacquire**

Before accessing a memory location ```x```, try to acquire
```lock[h(x)]``` greedily. On conflict (i.e., the lock is
already held):
1. Roll back the transaction (without releasing locks).
2. Release all locks with indexes larger than ```h[x]```.
3. Acquire ```lock[h(x)]```, blocking if already help.
4. Reacquiring the released locks in sorted order,
blocking if already held.
5. Restart the transaction.

**Algorithm L**

```c
Safe_Access(x, L)
    if h(x) ∉ L
        M = {i ∈ L : i > h(x)}
        L = L ∪ {h(x)}
        if M == Ø
            Acquire(lock[h(x)]) // blocking
        elseif Try_Acquire(lock[h(x)]) // nonblocking
            // do nothing
        else
            roll back transaction state (without releasing locks)
            for i ∈ M
                Release(lock[i])
            Acquire(lock[h(x)]) // blocking
            for i ∈ M in increasing order
                Acquire(lock[i]) // blocking
            restart transaction // does not return
    access location x
```

Safety access a memory location __x__ within a transaction having local
lock-index set __L__.
* At transaction start, the transaction's lock-index set __L__ is initialized
to the empty set: L = Ø.
* When the transaction completes, all locks with indexes in __L__ are released.

**Forward Progress**

**No livelocks or starvation**\
Each time a transaction restarts, it holds at least one more
lock than it held the previous time. Thus, a transaction can
be attempted at most __n__ times, where __n__ is the size of
the ownership array.

**Locking Anomaly: Convoying**

A lock __convoy__ occurs when multiple threads of
equal priority contend repeatedly for the same lock.

Example: Performance bug in MIT-Cilk\
When a random work-stealing, each thief grabs a
mutex on its victim's deque:
* If the victim's deque is empty, the thief releases the
mutex and tries again at random.
* If the victim's deque contains work, the thief steals
the topmost frame and then releases the mutex.
