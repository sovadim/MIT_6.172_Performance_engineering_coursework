## How C code is implemented in x86-64 assembly

## Clang/LLVM Compilation Pipeline

C source (bitarray.c) -->\
**Clang pre-processor** -->\
Preprocessed source(bitarray.i) -->\
**Clang code generator** -->\
LLVM IR (bitarray.ll) -->\
**LLVM optimizer** -->\
Optimized LLVM IR (bitarray.ll) -->\
**LLVM code generator** -->\
Assembly (bitarray.s)

**Viewing LLVM IR**

Generating LLVM IR from source
```bash
$ clang -O3 fib.c -S -emit-llvm
```

Translating LLVM IR into assembly
```bash
$ clang fib.ll -S
```

## LLVM IR Primer

**Components of LLVM IR**

* Functions
* Instructions
* LLVM IR Registers
* Data types

**LLVM IR vs Assembly**

LLVM IR is similar to assembly

* LLVM IR uses a __simple instruction format__, i.e., \<destination operand\> = \<opcode\> \<source operands\>
* LLVM IR code adopts a __similar structure__ to asssembly code.
* Control flow is implemented using conditional and unconditional branches.

LLVM IR is __simpler__ than assembly

* Smaller instruction set.
* Infinite LLVM IR registers, similar to variables in C.
* No implicit FLAGS register or condition codes.
* No explicit stack pointer or frame pointer.
* C-like type system.
* C-like functions.

**LLVM IR Registers**

LLVM IR stores values variables, called __registers__.

* Syntax: %\<name\>
* LLVM registers are like C variables: LLVM supports an infinite number of registers,
each distinguished by name.
* Register names are __local__ to each LLVM IR function.

**LLVM IR Instructions**

LLVM code is organized into __instructions__.

* Syntax for instructions that produce a value:
```
%<name> = <opcode> <operand list>
```

* Syntax for other instructions:
```
<opcode> <operand list>
```

* Operands are __registers__, __constants__, or "__basic blocks__".

Instruction that produces a value:
```
%6 = add nsw i64 %0, -2
```

Instruction that does not produce a value:
```
ret i64 %8
```

**Common LLVM IR Instructions**

* Data movement
    * Stack allocation: __alloca__
    * Memory read: __load__
    * Memory write: __store__
    * Type conversion: __bitcast, ptrtoint__
* Arithmetic and logic:
    * Integer arithmetic: __add, sub, mul, div, shl, shr__
    * Floating-point arithmetic: __fadd, fmul__
    * Binary logic: __and, or, xor, not__
    * Boolean logic: __icmp__
    * Address calculation: __getelementptr__
* Control flow:
    * Unconditional jump: __br \<location\>__
    * Conditional jump: __br\<condition\>, \<true\>, \<false\>__
    * Subroutines: __call, ret__
    * Maintaining SSA form: __phi__

**LLVM IR Data Types**

LLVM IR supports a variety of __data types__.

* Integers: i\<number\>
    * Example: A 64-bit integer: __i64__
    * Example: A 1-bit integer: __i1__
* Floating-point values: __double, float__
* Arrays: [\<number\> x \<type\>]
    * Example: An array of 5 ints: [5 x i32]
* Structs: {\<type\>, ...}
* Vectors: \< \<number\> x \<type\> \>
* Pointers: \<type\>*
    * Example: A pointer to an 8-bit integer: __i8*__
* Labels (i.e., basic blocks): __label__

## C to LLVM IR

**Straight-Line C Code in LLVM IR**

Straight-line C code (i.e., containing no conditionals or loops)
becomes a __sequence__ of LLVM IR instructions.

* Arguments are evaluated before the C operation.

* Intermediate results are stored in __registers__.

C code
```c
foo(n - 1) + bar(n - 2)
```

LLVM IR (register __%0__ holds the value of __n__)
```
%4 = add nsw i64 %0, -1
%5 = tail call i64 @foo(i64 %4)
%6 = add nsw i64 %0, -2
%7 = tail call i64 @bar(i64 %6)
%8 = add nsw i64 %7, %5
```

**Aggregate Types**

A variable with an __aggregate type__ (i.e., an array or a struct)
is typically stored in memory.

Accessing the aggregate type involves computing an address and then reading or writing memory.

C code
```c
int A[7];
A[x];
```

LLVM IR (register __%4__ stores the value of __x__)
```
// Compute an address and store it into register %5
%5 = getelement inbounds [7 x i32], [7 x i32]* %2, i64 0, i64 %4
// Read memory at the address stored in %5
%6 = load i32, i32* %5, align 4
```

**The getelementptr Instruction**

https://llvm.org/docs/LangRef.html#getelementptr-instruction

The __getelementptr__ instruction computes a memory address from
a __pointer__ and a __list of indices__.

Example: Compute the address %2 + 0 + %4
```
%5 = getelement inbounds [7 x i32], [7 x i32]* %2, i64 0, i64 %4
```

**LLVM IR Functions**

C code: __fib.c__
```c
int64_t fib(int64_t n) {
    ...
    return n;
}
```

LLVM IR: __fib.ll__
```
define i64 @fib(i64) local_unnamed_addr #0 {
    ...
    ret i64 %0
}
```

**Function Parameters**

LLVM IR function parameters map __directly__ to their C counterparts.

C code: __mm.c__
```c
void mm_base(
    double *restrict C,
    int n_C,
    double *restrict A,
    int n_A,
    double *restrict B,
    int n_B,
    int n) { ... }
```

LLVM IR: __mm.ll__
```
define void @mm_base(
    double* noalias nocapture,
    i32,
    double* noalias nocapture readonly,
    i32,
    double* noalias nocapture readonly,
    i32,
    i32) local_unnamed_addr #0 { ... }
```
Function parameters are automatically named %0, %1, %2, etc.

**Basic Blocks**

The body of a function definition is partitioned into __basic blocks__:
sequences of instructions (i.e., straight-line code) where control
obly enters through the first instruction and only exits from the last.

C code: __fib.c__
```c
int64_t fib(int64_t n) {
    if (n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}
```

LLVM IR: __fib.ll__
```
define dso_local i64 @fib(i64 %0) local_unnamed_addr #0 {
  %2 = icmp slt i64 %0, 2
  br i1 %2, label %11, label %3

3:                                                ; preds = %1, %3
  %4 = phi i64 [ %8, %3 ], [ %0, %1 ]
  %5 = phi i64 [ %9, %3 ], [ 0, %1 ]
  %6 = add nsw i64 %4, -1
  %7 = tail call i64 @fib(i64 %6)
  %8 = add nsw i64 %4, -2
  %9 = add nsw i64 %7, %5
  %10 = icmp slt i64 %4, 4
  br i1 %10, label %11, label %3

11:                                               ; preds = %3, %1
  %12 = phi i64 [ 0, %1 ], [ %9, %3 ]
  %13 = phi i64 [ %0, %1 ], [ %8, %3 ]
  %14 = add nsw i64 %13, %12
  ret i64 %14
}
```

**Control-Flow Graphs**

Control-flow instructions (e.g., __br__ instructions) induce __control-flow edges__
between the basic blocks of a function, creating a __control-flow graph (CFG)__.

```
              Block 1
 False branch v     |
           Block 3  | True branch
                    v
                 Block 9
```

**C Conditionals to LLVM IR**

A conditional in C is translated into a __conditional branch instruction__, __br__, in LLVM IR.

The conditional branch in LLVM IR takes as argument a 1-bit integer and two basic-block labels

C code
```c
if (n < 2)
```

LLVM IR
```
%2 = icmp slt i64 %0, 2
br i1 %2, label %9, label %3
// i1 %2 - Predicate
// label %9 - Destination block if the predicate is true
// label %3 - Destination block if the predicate is false
```

**Unconditional Branches**

If a __br__ instruction has just one operand, it is an __unconditional branch__.

```
br label %6
```

An unconditional branch __terminates__ its basic block and
produces __1__ outgoing control-flow edge.

**LLVM Loops to LLVM IR**

**Components of a C Loop**

A C loop involves a __loop body__ and __loop control__.

// Look at dax.c and dax.ll

```c
for (int64_t i = 0; i < n; ++i) // loop control
    y[i] = a * x[i]; // loop body
```

**Loops in the CFG**

A C loop produces a __loop pattern__ in the control-flow graph.

**Loop Control**

The __loop control__ for a C loop consists of a loop __induction variable__,
an __initialization__, a __condition__, and an __increment__.

C code
```c
for (int64_t i = 0; i < n; ++i)
```

LLVM IR
```
; <label>:8:        ; preds = %6, %8
    %9 = phi i64 [ %14, %8 ], [ 0, %6 ] // [ 0, %6 ] - Initialization
                                        // %9 is inductive variable for a while
    ...
    %14 = add nuw nsw i64 %9, 1 // Increment
                                // Now %14 is inductive variable
    %15 = icmp eq i64 %14, %3       // |
    br i1 %15, label %7, label %8   // | Condition
```

The induction variable __changes registers__ at the code for the loop increment.

**Static Single Assignment**

LLVM IR maintains the __static single assignment (SSA)__ invariant:
a register is defined by at most __one__ instruction in a function.

**The Phi Instruction**

The __phi__ instruction specifies, for each predecessor __P__ of a basic block __B__,
the value of the destination register if control enters __B__ via __P__.

* A block with __multiple incoming edges__ may have __phi__ instructions.
* The __phi__ instruction is __not__ a real instruction.

**Attributes**

LLVM IR constructs (e.g., instructions, operands, functions, and function parameters)
might be decorated with __attributes__.

C code
```c
convert[(x * deBruijn) >> 58];
```

LLVM IR
```
%4 = getelementptr inbounds [64 x i32], [64 x i32]* @convert, i64 0, i64 %3
%5 = load i32, i32* %4, align 4, !tbaa !2
// align 4 - attribute describing the alignment of the read from memory.
```

Some attributes are derived from the __source code__.

const --> readonly\
restrict --> noalias

Other attributes are determined by __compiler analysis__.

## LLVM IR to Assembly

LLVM IR is __structurally similar__ to assembly.

The compiler must perform __three tasks__ to translate LLVM IR into x86-64 assembly.

* **Select** assembly instructions to implement LLVM IR instructions.

* **Allocate** x86-64 general-purpose registers to hold values.

* **Coordinate** function calls.

**Layout of a Program in Memory**

When a program executes, virtual memory is organized into __segments__.

```
High        | stack         |-
virtual     |-------|-------| |
address     |       V       | | Dynamically
    |       |               | | allocated
    |       |       A       | | memory
    |       |-------|-------| |
    |       | heap          | |
    |       |---------------|-
    |       | bss           | |
    |       | (uninitiaized)| | Static data
    |       |---------------| | (bss initialized to 0)
    |       | data          | |
Low         | (initialized) | |
virtual     |---------------|-
address     | text          | | Code
```

**Assembler Directives**

Assembly code contains __directives__ that refer to
and operate on sections of assembly.

* **Segment directives** organize the contents
of an assembly file into segments.

    * ".text": Identifies the text segment.
    * ".bss": Identifies the bss segment.
    * ".data": Identifies the data segment.

* **Storage directives** store content into the current segment.

Examples:
```
x: .space 20        Allocates 20 bytes at location x.
y: .long 172        Stores the constant 172L at location y.
z: .asciz "6.172"   Stores the string "6.172\0" at location z.
   .align 8         Align the next content to an 8-byte boundary.
```

* **Scope and linkage directives** control linking.

Example: ".globl fib": Makes "fib" visible to other object files.

**The Call Stack**

The __stack__ segment stores data in memory to manage __function calls__ and __returns__.

More specifically, what data is stored on the stack?

* The __return address__ of a function call.
* __Register state__, so different functions can use the same registers.
* __Function arguments__ and __local variables__ that don't fit in registers.

**Coordinating Function Calls**

How do functions in __different__ object files __coordinate__
their use of the stack and of register state?

Functions abide by a __calling convention__.

**Linux x86-64 Calling Convention**

The Linux x86-64 calling convention organizes the
stack into __frames__, where each function instantiation
gets a single frame of its own.

* The __%rbp__ register points to the __top__ of the current stack frame.
* The __%rsp__ register points to the __bottom__ of the current stack frame. 

The __call__ and __ret__ instructions use the stack and the instruction
pointer, __%rip__, to manage the __return address__ for each function call.

* A __call__ instruction in x86-64 __pushes %rip__ onto the stack
and __jumps__ to the operand, which is the address of a function.

* A __ret__ instruction in x86-64 __pops %rip__ from the stack
and returns to the caller.

**Maintaining Registers Across Calls**

Who's responsible for preserving the register state accross a function call and return?

* The __caller__ might waste work saving register state that the callee doesn't use.
* The __callee__ might waste work saving register state that the caller wasn't using.

The Linux x86-64 calling convention does a bit of both.

* __Callee-saved registers__: %rbx, %rbp, %r12-%r15.
* All other registers are __caller-saved__.

**Linux C Subroutine Linkage**

Function B was called from funciton A and is about to call function C.

```
             Stack segment
             -----------------------
  Linkage | | args from A to B      |
    block   |-----------------------|
            | A's return address    |
            |-----------------------|
            | A's base pointer      |
    %rbp--> |-----------------------|   B's frame
            | B's local variables   |
            |-----------------------|
  Linkage | | args from B to B's    |
    block | | callees               |
    %rsp --> -----------------------
            | B's return address    | Appears when C called
             -----------------------  %rsp is set beneath this block
```

Funciton B accesses its __nonregister arguments__ from A,
which lie in a __linkage block__, by indexing %rbp with __positive__ offsets.

Funciton B accesses its __local variables__ by indexing %rbp with __negative__ offsets.

Before calling C, B places the __nonregister arguments__ for C
int the reserved __linkage block__ it will share with C,
which B accesses by indexing %rbp with __negarive offsets__.

B __calls__ C, which __saves the return address__ for B on the stack
and __transfers control__ to C.

When function C starts, it executes a __function prologue__:

1. Save B's base pointer on the stack,
2. Set %rbp = %rsp,
3. Advance %rsp to allocate space for C's __local variables__ and __linkage block__.

Optimization: If a function never performs stack allocations except during
function calls (i.e., %rbp-%rsp (minus) is a __compile-time constant__), indexing
can be done off %rsp, and %rbp can be used as an ordinary callee-saved register.
