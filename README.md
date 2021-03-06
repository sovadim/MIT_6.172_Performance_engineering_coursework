# MIT 6.172 Performance Engineering Fall 2018, coursework

[course link](https://ocw.mit.edu/courses/6-172-performance-engineering-of-software-systems-fall-2018/)\
[playlist with lectures on youtube](https://www.youtube.com/playlist?list=PLUl4u3cNGP63VIBQVWguXxZZi0566y7Wf)

Instructors: Prof. Charles Leiserson, Prof. Julian Shun

## Status

In progress

- [x] [Lectures](#lectures) (23/23)
- [ ] [Assignments](#assignments) (3/10)
- [ ] [Projects](#projects) (0/4)

## Lectures

### 1. Introduction and matrix multiplication

* cache-efficiency
* compiler flags
* parallel algorithms of matrix multiplication
* vectorization

### 2. Bentley Rules for optimizing work

* data structures
* logic
* loops
* functions

### 3. Bit Hacks

* Bit operations and their applications

### 4. Assembly Language & Computer Architecture

* Assembly language overview
* Floating-point and vector hardware
* Overview of computer architecture
* Superscalar processing
* Out-of-order execution
* Branch prediction

### 5. C to Assembly

* LLVM IR Primer
* C to LLVM IR
* LLVM IR to Assembly

### 6. Multicore Programming

* Shared-memory hardware
* Concurrency platforms

### 7. Races and Parallelism

* Race conditions
* Cilksan
* Work and span analysis
* Cilkscale
* Scheduling

### 8. Analysis of Multithreaded Algorithms

* Parallelization analysis
* Cilk loop parallelism

### 9. What Compilers Can and Cannot Do

* Compiler reports
* Optimizing a scalar
* Optimizing a structure
* Optimizing function calls
* Optimizing loops

### 10. Measurement and Timing

* Timing variability
* Ways to measure time
* Interpretation of measurements

### 11. Storage Allocation

* Stack and heap allocation
* Garbage collection

### 12. Parallel Storage Allocation

* Virtual memory allocation
* Cactus stack
* Parallel allocation strategies

### 13. The Cilk Runtime System

* Internals of Cilk runtime system

### 14. Caching and Cache-Efficient Algorithms

* Cache associativity
* Cache-aware algorithms
* Cache-oblivious algorithms

### 15. Cache-Oblivious Algorithms

* Cache-oblivious stencil computations
* Cache-oblivious sorting

### 16. Nondeterministic Parallel Programming

* Nondeterministic parallel programming
* Atomicity
* Data races
* Deadlock
* Transactional memory

### 17. Synchronization Without Locks

* Sequential consistency
* Mutual exclusion without locks
* Relaxed memory consistency
* Instruction reordering
* Compare-and-swap

### 18. Domain Specific Languages and Autotuning

* GraphIt
* Halide
* OpenTuner

### 19. Leiserchess Codewalk

* Project 4 overview

### 20. Speculative Parallelism & Leiserchess

* Speculative parallelism
* More project 4 insights

### 21. Tuning a TSP Algorithm

* Review of recursive generation
* The traveling salesperson problem
* A sequence of TSP algorithms
* Principles of algorithm engineering

### 22. Graph Optimization

* Graph representations
* Breadth-first search
* Graph compression/reordering

### 23. High Performance in Dynamic Languages

* Julia overview

## Assignments

### 1. Basic Tools, C Primer

* valgrind
* asan
* llvm-cov

### 2. Profiling

* perf
* cachegrind
* inlining analysis
* pointers vs arrays
* efficient memory usage

### 3. Vectorization

* vectorization in clang
* sse and avx2 comparison
* performance measure
* vectorization cost
