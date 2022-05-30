## Analyzing fib

Diassembling fib.c
```bash
$ clang -O3 -S fib.c
```

Assembling fib.s
```bash
$ clang -c fib.s
```

Disassembling fib.o
```bash
$ objdump -S fib.o
```

## Assembly language

**x86-64 Registers**

The most important registers right now are:

* General-purpose registers
* Flag registers
* Instruction pointer register
* XMM registers (for SSE)
* YMM registers (for AVX)

**Instruction format**

Format: \<opcode\> \<operand list\>

* \<operand list\> is 0, 1, 2, 3 operands, separated by commas
* Typically all operands are sources, and one might be the destination

```
addl %edi, %ecx
// ecx is destination
```

**Common x86-64 Opcodes**

Type of operation and examples

* Data movement
    * Move: __mov__
    * Conditional move: __cmov__
    * Sign or zero extension: __movs, movz__
    * Stack: __push, pop__\
<br>
* Ariphmetic and logic
    * Integer ariphmetic: __add, sub, mul, imul, div, idiv, lea, sal, sar, shl, shr, rol, ror, inc, dec, neg__
    * Binary logic: __and, or, xor, not__
    * Boolean logic: __test, cmp__\
<br>
* Control transfer
    * Unconditional jumps: __jmp__
    * Conditional jumps: __j \<condition\>__
    * Subroutines: __call, ret__

**Opcode suffixes**

```
movq -16(%rbp), %rax
// q - moving a 64-bit integer
```

**Data types**

C declaration / x86-64 size (bytes) / Asm suffix / x86-64 data type

* char / 1 / b / Byte
* short / 2 / w / Word
* int / 4 / l or d / Double word
* unsigned int / 4 / l or d / Double word
* long / 8 / q / Quad word
* unsigned long / 8 / q / Quad word
* char * / 8 / q / Quad word
* float / 4 / s / Single precision
* double / 8 / d / Double precision
* long double / 16 / t / Extended precision

**Opcode suffixes for Extension**

```
movzbl %al, %edx
// z - extend with zeros
// b - 8-bit integer
// l - 32-bit integer
```

```
movslq %eax, %rdx
// s - preserve the sign
// l - 32-bit integer
// q - 64-bit integer
```

**Conditional Operations**

Conditional jumps and conditional moves use a one- or two-character
suffix to indicate the __condition code__.

```
cmpq %4096, %r14
jne .LBB1_1
// ne - jump if the arguments of the previous comarison are not equal
```

**RFLAGS Register**

Ariphmetic and logic operations update __status flags__ in the __RFLAGS__ register.

Bit(s) / Abbreviation / Description

* 0 / CF / Carry
* 1 / - / __Reserved__
* 2 / PF / Parity
* 3 / - / __Reserved__
* 4 / AF / Adjust
* 5 / - / __Reserved__
* 6 / ZF / Zero
* 7 / SF / Sign
* 8 / TF / Trap
* 9 / IF / Interrupt enable
* 10 / DF / Direction
* 11 / OF / Overflow
* 12-63 / - / __System flags or reserved__

```
decq %rbx
// Decrement %rbx and set ZF if the result is 0
jne .LBB7_1
// Jump to label .LBB7_1 if ZF is not set
```

**Condition codes**

Condition code / Translation / RFLAGS status flags checked

* a / if above / CF = 0 and ZF = 0
* ae / if above or equal / CF = 0
* c / on carry / CF = 1
* e / if equal / ZF = 1
* ge / if greater or equal / SF = OF
* ne / if not equal / ZF = 0
* o / on overflow / OF = 1
* z / if zero / ZF = 1

**x86-64 Direct Addressing Modes**

Direct addressing modes

* **Immediate**: Use the specified value
```
movq $172, %rdi
```

* **Register**: Use the value in the specified register
```
movq %rcx, %rdi
```

* **Direct memory**: Use the value at the specified memory address
```
movq 0x172, %rdi
```

**x86-64 Indirect Addressing Modes**

Indirect addressing - specifying a memory address by some computation

* **Register indirect**: The address is stored in the specified register
```
movq (%rax), %rdi
```

* **Register indexed**: The address is a constant offset of the value in the specified register
```
movq 172(%rax), %rdi
```

* **Instruction-pointer relative**: The address is indexed relative to %rip
```
movq 172(%rip), %rdi
// rip - instruction pointer
```

**Base Indexed Scale Displacement**

The most general form of indirect addressing supported by x86-64 is the
__base indexed scale displacement__ mode.

```
movq 172(%rdi, %rdx, 8), %rax
// 172 - Displacement: an 8-bit, 16-bit, or 32-bit value
// %rdi - Base: a GPR
// %rdx - Index: a GPR
// 8 - Scale: either 1, 2, 4, or 8
```

This mode refers to the address
__Base + Index * Scale + Displacement__.\
If unspecified, __Index__ and __Displacement__ default to __0__, and __Scale__ defaults to __1__.

**Jump Instructions**

The x86-64 jump instructions, __jmp__ and __j\<condition\>__,
take a __label__ as their operand, which identifies a location in the code.

fib.s
```
jge LBB0_1
...
LBB0_1:
    leaq -1(%rbx), %rdi
```

objdump fib.o
```
jge 5 <_fib+0x15>
...
15:
    leaq -1(%rbx), %rdi
```

* Labels can be __symbols__, __exact addresses__, or __relative addresses__.

* An __indirect jump__ takes as its operand an indirect address.
```
jmp *%eax
```

**Assembly Idiom 1**

The XOR opcode, "xor A, B" computes the bitwise XOR of A and B.

What this do?
```
xor %rax, %rax
```
It zeros the register

**Assembly Idiom 2**

The test opcode, "test A, B" computes the bitwise AND of A and B and discard the result,
preserving the RFLAGS register.

What does the __test__ instruction test for in the following snippets?
```
test %rcx, %rcx
je 400c0a <mm+0xda>
```
```
test %rax, %rax
cmovne %rax, %r8
```
Checks to see whether the register is 0.

**Assembly Idiom 3**

The x86-64 ISA includes several no-op (no operation) instructions,
including "nop", "nop A" (no-op with an argument), and "data16"

What does this line of assembly do?
```
data16 data16 data16 nopw %cs:0x0(%rax, %rax, 1)
```
Nothing

Why would the compiler generate assembly with these idioms?

Mainly, to optimize instruction memory (e.g., code size, alignment)

## Floating-Point and Vector Hardware

**Floating-Point Instruction Sets**

Modern x86-64 architectures support __scalar__
(i.e. non-vector) floating-point arithmetic via
a couple of different instruction sets.

* The __SSE and AVX instruction__ support single-precision
and double-precision scalar floating-point arithmetic, i.e., "float" and "double"

* The __x87 instructions__ support single-, double-,
and extended-precision scalar floating-point arithmetic,
i.e., "float", "double", and "long double"

The SSE and AVX instruction sets also include __vector instructions__.

**SSE for Scalar Floating-Point**

Compilers prefer to use the SSE instructions over the x87 instructions
because SSE instructions are simpler to compile and to optimize.

* SSE opcodes on floating-point values are similar to x86-64 opcodes.

* SSE operands use XMM registers and floating-point types.

```
movsd (%rcx, %rsi, 8), %xmm1
musld %xmm0, %xmm1
addsd (%rax, %rsi, 8), %xmm1
movsd %xmm1, (%rax, %rsi, 8)
// sd - Data type is a double-precision floating-point value (i.e., a double)
```

**SSE Opcode Suffixes**

Assembly suffix / Data type

* ss / One single-precision floating-point value (float)
* sd / One double-precision floating-point value (double)
* ps / Vector of single-precision floating-point values
* pd / Vector of double-precision floating-point values

**Vector Hardware**

Modern microprocessors often incorporate __vector hardware__ to process data in a
__single-instruction stream, multiple-data stream (SIMD)__ fashion.

**Vector Instructions**

__Vector instructions__ generally operate in an __elementwise__ fashion:

* The ith __element__ of one vector register can only take part in operations
with the ith element of other vector registers.

* All lanes perform __exactly the same operation__ on their respective
elements of the vector.

* Depending on the architecture, vector memory operands might need to be __aligned__,
meaning their address must be a multiple of the vector width.

* Some architectures support cross-lane operations, such as __inserting__ of
__extracting__ subsets of vector elements, __permuting__ (a.k.a. __shuffling__)
the vector, __scatter__, or __gather__.

**Vector Instruction Sets**

Modern x86-64 architectures support multiple __vector-instruction sets__.

* Modern __SSE instruction sets__ support vector operations on integer,
single-precision, and double-precision floating-point values.

* The __AVX instructions__ support vector operations on single-precision,
and double-precision floating-point values.

* The __AVX2 instructions__ add integer-vector operations to the AVX instruction set.

* The __AVX-512 (AVX3) instructions__ increase the register length to 512 bits
and provide new vector operations, including popcount. 

**SSE vs AVX and AVX2**

The AVX and AVX2 instruction sets extend the SSE instruction set in several ways.

* The __SSE instructions__ use __128-bit XMM__ vector registers and operate
on at most __2__ operands at a time.

* The __AVX instructions__ can alternatively use __256-bit YMM__ vector registers
and can operate on __3__ operands at a time: two source operands,
and one distinct destination operand.

Example AVX instruction
```
vaddpd %ymm0, %ymm1, %ymm2
```

**SSE and AVX Vector Opcodes**

Opcodes to add 64-bit values

SSE / AVX/AVX2

* Floating-point: addpd / vaddpd
* Integer: paddpq / vpaddpq

The "v" prefix distinguishes the AVX/AVX2 instructions.

The "p" prefix distinguishes an integer vector instruction.

## Overview of Computer Architecture

**A Simple 5-Stage Processor**

Each instruction is executed through __5__ stages:

1. **Instruction fetch (IF)**: Read instruction from memory.

2. **Instruction decode (ID)**: Determine which units to use
to execute the instruction, and extract the register arguments.

3. **Execute (EX)**: Perform ALU operations.

4. **Memory (MA)**: Read/write data memory.

5. **Write back (WB)**: Store result into registers.

**Architectural Improvements**

Historically, computer architects have aimed
to improve processor performance by two means:

* Exploit __parallelism__ by executing multiple instructions simultaneously.
    * Example: __instruction-level parallelism (ILP)__, __vectorization__, __multicore__.

* Exploit __locality__ to minimize data movement.
    * Example: __caching__.

**Pipelined Instruction Execution**

Processor hardware exploits __instruction-level parallelism__
by finding opportunities to execute multiple instructions
simultaneously in different pipeline stages.

__Ideal pipelined timing__\
Each pipeline stage is executing a different instruction at cycle #5.
```
Instr # | Cycle
        | 1     | 2     | 3     | 4     | 5     | 6     | 7     | 8     | 9     |
--------------------------------------------------------------------------------|
i       | IF    | ID    | EX    | MA    | WB    |       |       |       |       |
i + 1   |       | IF    | ID    | EX    | MA    | WB    |       |       |       |
i + 2   |       |       | IF    | ID    | EX    | MA    | WB    |       |       |
i + 3   |       |       |       | IF    | ID    | EX    | MA    | WB    |       |
i + 4   |       |       |       |       | IF    | ID    | EX    | MA    | WB    |
```

Pipelining improves processor __throughput__.

In practice, various issues can prevent an instruction from executing
during its designated cycle, causing the processor pipeline to __stall__.

**Sources of Pipeline Stalls**

Three types of __hazards__ may prevent at instruction from executing
during its designated clock cycle.

* **Structural hazard**: Two instructions attempt to use the same
functional unit at the same time.

* **Data hazard**: An instruction depends on the result of a
prior instruction in the pipeline.

* **Control hazard**: Fetching and decoding the next instruction
to execute is delayed by a decision about control flow (i.e., a conditional jump).

**Sources of Data Hazards**

An instruction __i__ can create a data hazard with later instruction __j__
due to a __dependence__ between __i__ and __j__.

* **True dependence (RAW)**:
Instruction __i__ writes a location that instruction __j__ reads.
```
addq %rbx, %rax
subq %rax, %rcx
```

* **Anti-dependence (WAR)**:
Instruction __i__ reads a location that instruction __j__ writes.
```
addq %rbx, %rax
subq %rcx, %rbx
```

* **Output-dependence (WAW)**:
Both instructions __i__ and __j__ write to the same location.
```
movq 0x0, %rax
movq 0x1, %rax
```

**Complex Operations**

Some arithmetic operations are __complex__ to implement in
hardware and have __long latencies__.

__Idea__: Use __separate functional units__ for complex operations,
such as floatin-point arithmetic.

Functional units might be pipelined __fully__, __partially__, or __not at all__.

**From Complex to Superscalar**

Given these additional functional units, __how can the processor further exploit ILP__?

__Idea__: Fetch and issue __multiple instructions per cycle__ to keep the units busy.

**Intel Haswell Fetch and Decode**

Haswell break up x86-64 instructions into simpler operations, called __micro-ops__.

**Block Diagram of a Superscalar Pipeline**

The __issue__ stage in the pipeline manages the functional units and
handles scheduling of instructions.

```
                 ____________________________
                |                            |
IF --> ID --> Issue --> ALU --> Data Mem --> WB
                    -->     FAdd         -->
                    -->     FMul         -->
                    -->     FDiv         -->
```

What does the issue stage do to exploit ILP?

**Bypassing**

__Bypassing__ allows an instruction to read its arguments
before they've been stored in a GPR.

Example:\
Without bypassing
```
addq %rbx, %rax // (1)
subq %rax, %rcx // (2)

Instr # | Cycle
        | 1     | 2     | 3     | 4     | 5     | 6     | 7     | 8     | 9     |
--------------------------------------------------------------------------------|
1       | IF    | ID    | EX    | MA    | WB    |       |       |       |       |
2       |       | IF    | ID    | ID    | ID    | EX    | MA    | WB    |       |
```
Stall waiting for %rax to be written to a register.

With bypassing
```
Instr # | Cycle
        | 1     | 2     | 3     | 4     | 5     | 6     | 7     | 8     | 9     |
--------------------------------------------------------------------------------|
1       | IF    | ID    | EX    | MA    | WB    |       |       |       |       |
2       |       | IF    | ID    | EX    | MA    | WB    |       |       |       |
```
Stall eliminated

// The more complex example and optimization of its data-flow graph is not written down 

**Out-of-Order Execution**

__Idea__: Let the hardware issue an instruction as soon as its data dependencies are satisfied.

## Control Hazards

What happens if the processor encouners a __conditional jump__, a.k.a., a __branch__?

Outcome of the branch is known after the __execute__ stage.

__Instruction-fetch__ stage needs to know the outcome of the branch.

**Speculative execution**

To handle a control hazard, the processor either __stalls__ at the branch or
__speculatively__ executes past it.

Example:
```
cmpq    %r14, %rbp
jae     .LBB9_3
movq    %rbx, %rdi
movq    %rbp, %rsi
callq   bitarray_get
```

When a branch is encountered, assume it's __not taken__, and keep executing normally.

If it is later found that the branch was __taken__, then __undo__ the speculative computation.

__Problem__: The effect on throughput of undoing computation is just like __stalling__.

On Haswell, a mispredicted branch costs 15-20 cycles.

Most of the machines use a __branch-predictor__.
