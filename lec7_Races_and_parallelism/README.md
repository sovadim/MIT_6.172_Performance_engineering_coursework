# Races and Parallelism

## Determinacy Races

**Definition.** A __determinacy race__ occurs when two
logically parallel instructions access the same memory location
and at least one of the instructions performs a write.

Example
```c++
int x = 0;
cilk_for(int i = 0; i < 2; ++i) {
    x++;
}
assert(x == 2);
```

## Types of Races

Suppose that instruction __A__ and instruction __B__ both access
a location __x__, and suppose that __A||B__.

```
 A      | B     | Race Type
-----------------------------
 read   | read  | none
 read   | write | read race
 write  | read  | read race
 write  | write | write race
```

Two sections of code are independent if they have no determinacy races between them.

**Avoiding Races**

* Iterations of a __cilk_for__ should be independent. 

* Between a __cilk_spawn__ and the corresponding __silk_sync__,
the code of the spawned child should be independent of the code
of the parent, including code executed by additional spawned or called children.

**Cilksan Race Detector**

* The Cilksan-instrumented program is produced by compiling with the __-fsanitize=cilk__ flag.

**Computation Dag**

(Here is supposed to be a picture of graph)

* A parallel instruction stream is a dag G = (V, E).

* Each vertex v <- V is a __strand__: a sequence of instructions
not containing a spawn, sync, or return from a spawn.

* An edge e <- E is a __spawn__, __call__, __return__, or __continue__ edge.

* Loop parallelism (cilk_for) if converted to spawns and syncs using recursive divide-and-conquer.

**Amdahl's Law**

In general, if a fraction __a__ of an application must be run serially, the speedup can be at most __1/a__.

**Quantifying Parallelism**

```
         S
         v
         S
        / \
      /     \
     C        \
    / \         \
  /     \         \
 O       C         O
 |      /  \      / \
 |     C     O   O   O
 v     v     v   |   v
 O     C     O   v   O
  \    |    /    O  /
    \  |  /      | /
      \v/        |
       C        |
         \     |
            \ |
             v
             S

S - sequentially executed
C + S - critical path
```

Amdahl's Law says that sinse the serial fraction is 3/18 = 1/6, the speedup is upper-bounded by 6.

**Performance Measures**

Tp - execution time on __P__ processors

T1 = work = 18

Tinf = span* = 9

*Also called __critical-path length__ or __computational depth__.

Work law:
* Tp >= T1/P

Span law:
* Tp >= Tinf

**Series Composition**

```
--> A --> B -->
```

Work: T1(A U B) = T1(A) + T1(B)\
Span: Tinf(A U B) = Tinf(A) + Tinf(B)

**Parallel Composition**

```
   _ A _
_/       \_
 \ _   _ /
     B
```

Work: T1(A U B) = T1(A) + T1(B)\
Span: Tinf(A U B) = max{Tinf(A), Tinf(B)}

**Speedup**

**Definition.** T1/Tp = __speedup__ on __P__ processors.

* If T1/Tp < P, we have __sublinear speedup__.
* If T1/Tp = P, we have __(perfect) linear speedup__.
* If T1/Tp > P, we have __superlinear speerdup__, which is not possible
in this simple performance model, because of the Work Law Tp >= T1/P.

**Example: fib(4)**

Assume for simplicity that each strand in fib(4) takes unit time to execute.

Work: T1 = 17\
Spac: Tinf = 8\
Parallelism: T1 / Tinf = 2.125

**Cilkscale Scalability Analizer**

* The Tapir/LLVM compiler provides a __scalability analyzer__ called __Cilkscale__.

* Like the Cilksan race detector, Cilkscale uses __compiler-instrumentation__ to analize a serial execution of a program.

* Cilkscale computes __work__ and __span__ to derive upper bounds on parallel performance.

**Quicksort Analysis**

Parallel quicksort
```c++
static void quicksort(int64_t *left, int64_t *right) {
    int64_t *p;
    if (left == right) return;
    p = partition(left, right);
    cilk_spawn quicksort(left, p);
    quicksort(p + 1, right);
    cilk_sync;
}
```

**Scheduling Theory**

* The Cilk __scheduler__ maps strands onto processors dynamically at runtime.

* Since the theory of __distributed__ schedulers is complicated,
we'll explore the ideas with a __centralized__ scheduler.

**Greedy Scheduling**

Idea: Do as much as possible on every step.

Definition: A strand is __ready__ if all its predecessors have executed.

Complete step
* >= P strands ready.
* Run any P.

Incomplete step
* < P strands ready.
* Run all of them.

**Analysis of Greedy**

**Theorem.** Any greedy scheduler achieves ```Tp <= T1/P + Tinf```

**Corollary.** Any greedy scheduler achieves within a factor of 2 of optimal.

**Corollary.** Any greedy scheduler achieves near-perfect linear speedup whenever T1/Tinf >> P.

**Definition.** The quantity T1/PTinf is called the __parallel slackness__.

**Cilk Performance**

* Cilk's work-stealing scheduler achieves
    * Tp = T1/P + O(Tinf) expected time (provably);
    * Tp ~ T1/P + Tinf (empirically).

* Near-perfect __linear speedup__ as long as P << T1/Tinf.

* Instrumentation in Cilkscale allows you to measure T1 and Tinf.

**The Cilk Runtime System**

Each worker (processor) maintains a __work deque__ of ready strands,
and it manipulates the bottom of the deque like a stack.

**Cactus Stack**

Cilk supports C's __rule for pointers__:
A pointer to stack space can be passed from parent to child, but not from child to parent.
