# What Compilers Can and Cannot Do

**Simple Model of the Compiler**

An optimizing compiler performs a sequence of __transformation passes__ on the code.

* Each transformation pass __analyzes and edits__ the code to try to __optimize__ the code's performance.
* A transformation pass might run __multiple times__.
* Passes run in a __predetermined order__ that seems to work well most ot the time.

**Compiler Reports**

Clang/LLVM can produce __reports__ for many of its transformation passes:

-Rpass=\<string\>: Produces reports of which optimizations matching \<string\> were successfull.

-Rpass-missed=\<string\>: Produces reports of which optimizations matching \<string\> were not successfull.

-Rpass-analysis=\<string\>: Produces reports of the analyses performed by optimizations matching \<string\>.

The argument \<string\> is a __regular expression__.\
To see the whole report, use ```".*"``` as the string.

**Outline**

- Example compiler optimizations
    - Optimizing a scalar
    - Optimizing a structure
    - Optimizing function calls
    - Optimizing loops

- Diagnosing failures
    - Case studies

**Overview of Compiler Optimizations**

**~~Data structures~~**

**Loops**

- Hoisting
- ~~Sentinels~~
- Loop unrolling
- Loop fusion
- Eliminating wasted iterations

**Logic**

- Constant folding and propagation
- Common-subexpression elimination
- Algebraic identities
- Short-circuiting
- Ordering tests
- ~~Creating a fast path~~
- Combining tests

**Functions**

- Inlining
- Tail-recursion elimination
- ~~Coarsening recursion~~

// Bentley rules without some cases and with restrictions

**More Compiler Optimizations**

**Data structures**

- Register allocation
- Memory to registers
- Scalar replacement of aggregates
- Alignment

**Loops**

- Vectorization
- Unswitching
- Idiom replacement
- Loop fission
- Loop skewing
- Loop tiling
- Loop intercharge

**Logic**

- Elimination of redundant instructions
- Strength reduction
- Dead-code elimination
- Idiom replacement
- Branch reordering
- Global value numbering

**Functions**

- Unswitching
- Argument elimination

**Arithmetic Opt's: C vs. LLVM IR**

Most compiler optimizations happen on the IR, although not all of them.

Example: Let __n__ be a __uint32_t__.

```c
C code                  LLVM IR                     Assembly

uint32_t x = n * 8;     %2 = shl nsw i32 %0, 3      leal (,%rdi,8), %eax

uint32_t y = n * 15;    %3 = mul nsw i32 %0, 15     leal (%rdi, %rdi, 4), %eax
                                                    leal (%rax, %rax, 2), %eax

uint32_t z = n / 71     %4 = udiv i32 %0, 71        movl  %edi, %eax
                                                    movl  $3871519817, %ecx *
                                                    imulq %rax, %rcx
                                                    shrq  %38, %rcx
```
\* - magic number 2^38 / 71 + 1.

**Basic Routines for 2D Vectors**

```c
typedef struct vec_t {
    double x, y;
} vec_t;

static vec_t vec_add(vec_t a, vec_t b) {
    vec_t sum = { a.x + b.x, a.y + b.y };
    return sum;
}

static vec_t vec_scale(vec_t v, double a) {
    vec_t scaled = { v.x * a, v.y * a };
    return scaled;
}

static double vec_length2(vec_t v) {
    return v.x * v.x + v.y * v.y;
}
```

```bash
$ clang -O0 -c -S -emit-llvm vec.c -o vecO0.ll
$ clang -O1 -c -S -emit-llvm vec.c -o vecO1.ll
$ clang -O2 -c -S -emit-llvm vec.c -o vecO2.ll
```

**Handling One Argument, -O0 Code**

The parameter ```a``` in ```vec_scale``` at -O0
```
define internal { double, double }
@vec_scale(double %0, double %1, double %2) #0 {
  ...
  %6 = alloca double, align 8  - Allocate stack storage
  ...
  store double %2, double* %6, align 8  - Store a onto the stack
  ...
  %13 = load double, double* %6, align 8  - Load a from the stack
  %14 = fmul double %12, %13
  ...
  %18 = load double, double* %6, align 8  - Load a from the stack
  %19 = fmul double %17, %18
  ...
}
```

**Promoting Memory to Registers**

IDEA: Replace the stack-allocated variable with the copy in the register.

Step 1: Replace loaded values with original register.\
Step 2: Remove dead code.

```
define internal { double, double }
@vec_scale(double %0, double %1, double %2) #0 {
  ...
  --%6 = alloca double, align 8-- Removed
  ...
  --store double %2, double* %6, align 8-- Removed
  ...
  --%13 = load double, double* %6, align 8-- Removed
  %14 = fmul double %12, %2 <-- %13 changed to %2
  ...
  --%18 = load double, double* %6, align 8-- Removed
  %19 = fmul double %17, %2 <-- %18 changed to %2
  ...
}
```

**Removing Structures**

IDEA: Eliminate struct-type arguments and local variables as well.

Problem: Structures are harder to handle because code operates on individual fields.

```
define internal { double, double }
@vec_scale(double %0, double %1, double %2) #0 {
  ...
  %5 = alloca %struct.vec_t, align 8  | - Allocate storage for a struct
  ...                                                  ___
  %7 = bitcast %struct.vec_t* %5 to { double, double }*   |
  %8 = getelementptr inbounds { double, double },         | Store the
       { double, double }* %7, i32 0, i32 0               | first element
  store double %0, double* %8, align 8           _________|
  %9 = getelementptr inbounds { double, double },         |
       { double, double }* %7, i32 0, i32 1               | Store the
  store double %1, double* %9, align 8           _________| second element
  ...                                        ____
  %11 = getelementptr inbounds %struct.vec_t,    |
        %struct.vec_t* %5, i32 0, i32 0          | Load the
  %12 = load double, double* %11, align 8    ____| first field
  %14 = fmul double %12, %2
  ...                                        ____
  %16 = getelementptr inbounds %struct.vec_t,    |
        %struct.vec_t* %5, i32 0, i32 1          | Load the
  %17 = load double, double* %16, align 8    ____| second field
  %19 = fmul double %17, %2
  ...
}
```

**Scalar replacement of Aggregates**

IDEA: Optimize individual fields of the aggregate type.

Let's consider the first field.
```
define internal { double, double }
@vec_scale(double %0, double %1, double %2) #0 {
  ...
  %5 = alloca %struct.vec_t, align 8
  ...                                                  ___
  %7 = bitcast %struct.vec_t* %5 to { double, double }*   |
  %8 = getelementptr inbounds { double, double },         | Both address calculations
       { double, double }* %7, i32 0, i32 0               | refer to the same struct field
  store double %0, double* %8, align 8           _________| |
  ...                                        ____           |
  %11 = getelementptr inbounds %struct.vec_t,    |__________|
        %struct.vec_t* %5, i32 0, i32 0      ____|
  %12 = load double, double* %11, align 8  | Q: What value will the load retrieve?
  %14 = fmul double %12, %2                  A: %0
  ...                 |__ Replace the use of that field with the register value
}
```

```
define internal { double, double }
@vec_scale(double %0, double %1, double %2) #0 {
  ...
  --%5 = alloca %struct.vec_t, align 8-- Removed
  ...
  --%7 = bitcast %struct.vec_t* %5 to { double, double }*-- Removed
  --%8 = getelementptr inbounds { double, double },
       { double, double }* %7, i32 0, i32 0-- Removed
  --store double %0, double* %8, align 8-- Removed
  ...
  --%11 = getelementptr inbounds %struct.vec_t,
        %struct.vec_t* %5, i32 0, i32 0-- Removed
  --%12 = load double, double* %11, align 8-- Removed
  %14 = fmul double %0, %2 - %12 replaced to %0
  ...
}
```

A similar but more complicated optimization can optimize the __return-value structure__.

**Result of Optimizations**

Result of optimizing all aggregate variables
```
define internal { double, double }
@vec_scale(double %0, double %1, double %2) #0 {
  %4 = fmul double %0, %2
  %5 = fmul double %1, %2
  %.fca.0.insert = insertvalue { double, double } undef, double %4, 0
  %.fca.1.insert = insertvalue { double, double } %.fca.0.insert, double %5, 1
  ret { double, double } %.fca.1.insert
}
```

Summary: Compilers transform data structures to store as much as possible in registers.

**Optimizing Function Calls**

**Example: Updating Positions**

Some code snippet with ```vec_scale``` call
```c
vec_scale(
    vec_add(bodies[i].velocity, new_velocity),
    time_quantum / 2.0
);
```

The according LLVM IR
```
%24 = extractvalue { double, double } %23, 0
%25 = extractvalue { double, double } %23, 1
%26 = fmul double %2, 5.000000e-01
%27 = call { double, double } @vec_scale(double %24, double %25, double %26)
```

**Function Inlining**

IDEA: The code for ```vec_scale``` is small, so copy-paste it into the call site.

Step 1: Copy code from ```vec_scale```.\
Step 2: Remove call and return.

```
%24 = extractvalue { double, double } %23, 0
%25 = extractvalue { double, double } %23, 1
%26 = fmul double %2, 5.000000e-01
%4.in = fmul double %0, %2
%5.in = fmul double %1, %2
%27 = insertvalue { double, double } undef, double %4.in, 0
%27 = insertvalue { double, double } %27, double %5.in, 1
```

Function inlining enables more optimizations.

```
%24 = extractvalue { double, double } %23, 0
%25 = extractvalue { double, double } %23, 1
%26 = fmul double %2, 5.000000e-01
%4.in = fmul double %0, %2
%5.in = fmul double %1, %2
// The below instructions pack struct fields and then immediately unpack them.
--%27 = insertvalue { double, double } undef, double %4.in, 0-- Remove
--%27 = insertvalue { double, double } %27, double %5.in, 1-- Remove
// The further code
--%28 = extractvalue { double, double } %27, 0-- Remove
--%29 = extractvalue { double, double } %27, 1-- Remove
```

**Sequences of Function Calls**

C code
```c
vec_add(
    bodies[i].position,
    vec_scale(
        vec_add(bodies[i].velocity, new_velocity),
        time_quantum / 2.0
    )    
);
```

LLVM IR
```
%23 = call { double, double } @vec_add(double %20, double %22, double %17, double %18)
%24 = extractvalue { double, double } %23, 0
%25 = extractvalue { double, double } %23, 1
%26 = fmul double %2, 5.000000e-01
%4.in = fmul double %0, %2
%5.in = fmul double %1, %2
...
%34 = call { double, double } @vec_add(double %31, double %33, double %4.in, double %5.in)
```

IDEA: Inline ```vec_add``` as well.

Optimized LLVM IR
```
%22 = fadd double %19, %16
%23 = fadd double %21, %17
%26 = fmul double %2, 5.000000e-01
%4.in = fmul double %0, %2
%5.in = fmul double %1, %2
...
%31 = fadd double %28, %4.in
%32 = fadd double %30, %5.in
```

Function inlining and additional transformations can eliminate the cost of the function abstraction.

**Problems with Function Inlining**

Why doesn't the compiler inline all function calls?

* Some function calls, such as recursive calls, cannot be inlined except in special cases, e.g., "recursive tail calls".

* The compiler cannot inline a function defined in another __compilation unit__ unless one uses __whole-program optimization__.

* Function inlining can __increase code size__, which can hurt performance.

**Controlling Function Inlining**

How does the compiler know whether or not inlining a function will hurt performance?

- It doesn't know. It makes a best guess based on heuristics, such as the function's size.

Tips for controlling function inlining:

* Mark functions that should __always__ be inlined with ```__atrribute__((always_inline))```.

* Mark functions that should __never__ be inlined with ```__attribute__((no_inline))```.

* Use __link-time optimization (LTO)__ to enable whole-program optimization.

**Loop Optimizations**

**Example: Calculationg Forces**

Let's look at some common optimization on loops: __code hoisting__ a.k.a., __loop-invariant-code motion (LICM)__.

C code
```c
void calculate_forces(int nbodies, body_t *bodies) {
    for (int i = 0; i < nbodies; ++i) {
        for (int j = 0; j < nbodies; ++j) {
            if (i == j) continue;
            add_force(&bodies[i], calculate_force(&bodies[i], &bodies[j]));
        }
    }
}
```

// LLVM snippet is pretty big

**Code Hoisting: Euqivalent C**

After
```c
void calculate_forces(int nbodies, body_t *bodies) {
    for (int i = 0; i < nbodies; ++i) {
        body_t *bi = &bodies[i];
        for (int j = 0; j < nbodies; ++j) {
            if (i == j) continue;
            add_force(bi, calculate_force(bi, &bodies[j]));
        }
    }
}
```

In general, if the compiler can prove some calculation is __loop-invariant__, it will attempt to hoist the code out of the loop.

**Something the Compiler Cannot Do**

```c
void calculate_forces(int nbodies, body_t *bodies) {
    for (int i = 0; i < nbodies; ++i) {
        for (int j = 0; j < nbodies; ++j) {
            if (i == j) continue;
            add_force(&bodies[i], calculate_force(&bodies[i], &bodies[j]));
        }
    }
}
```

The compiler is unlikely to automatically expoloit __symmetry__ in this problem, i.e., that F12 = -F21.

**Diagnosing Failures: Case Study**

**Vectorization**

Does the following loop vectorize?
```c
void daxpy(double *y, double a,
           double *x, int64_t n)
{
    for (int64_t i = 0; i < n; ++i) {
        y[i] += a * x[i];
    }
}
```
\- The compiler generates __multiple versions__ of the loop due to uncertainty about __memory aliasing__.

// The control-flow graph is complicated.

**Dealing with Memory Aliasing**

Compilers perform __alias analysis__ to determine which addresses computed off of different pointers might refer to the same location.

* In general, alias analysis is __undecidable__ [HU79, R94].

* Compilers use a variety of tricks to get useful alias-analysis results in practice.

* Example: Clang uses __metadata__ to track alias information derived from various sources, such as type information in the source code.
```
%34 = load double, double* %33, align 8, !tbaa !3, !alias.scope !12, !noalias !9
```

**What You Can Do About Aliasing**

* The ```restrict``` keyword allows the compiler to assume that address
calculations based on a pointer will not alias those based on other pointers.

* The ```const``` keyword indicates that addresses based on a particular pointer will only be read.
