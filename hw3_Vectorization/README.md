# Vectorization

// The assembly snippets in this document were taken from godbolt

## Getting started

Enabling vectorizer in clang:
* Loop Vectorizer
    * -fvectorize / -fno-vectorize
* SLP Vectorizer
    * -fslp-vectorize / -fno-slp-vectorize

Enabled by default with: __-Os, -O2, -O3__

Documentation:
* [Clang](https://llvm.org/docs/Vectorizers.html)
* [GCC](https://gcc.gnu.org/projects/tree-ssa/vectorization.html)

## Recitation

**Example 1**

A very first version of ```test``` function
```c
void test(uint8_t * a, uint8_t * b)
{
    for (uint64_t i = 0; i < SIZE; i++) {
        a[i] += b[i];
    }
}
```

```bash
$ make ASSEMBLE=1 VECTORIZE=1 example1.o
```

The output
```
remark: vectorized loop (vectorization width: 16, interleaved count: 2) [-Rpass=loop-vectorize]
```
indicates that for loop was vectorized.

**Write-up 1:** Look at the assembly code. The compiler has translated the code to set the start index at -2^16 and adds to it for each memory access. Why doesn’t it set the start index to 0 and use small positive offsets?

In my case I couldn't reproduce the same behavior.\
In the MIT's code code snippet, value ```-65536``` is set to ```rax```.
```
movq $-65536, %rax
```
```rax``` is used in comparing the counter ```i``` with ```SIZE```.
```
// Increment of i
addq $64, %rax
// check i < SIZE and go back to loop if true
jne .LBB0_3
```

In my case the optimization dod not reproduce and the same action is done in 3 steps:
```
// Increment i
add     rax, 64
// Check i < SIZE
cmp     rax, 65536
// Go back to loop if true
jne     .LBB0_1
```

So, as the machine preserves the result of last operation and has an instruction to compare it with zero, setting the start index to ```-2^16``` saved one instruction per loop entry.

(write-up finished)

Let's make compiler assume that the data is aligned using the intrinsic ```__builtin_assume_aligned```.
```
void test(uint8_t * restrict a, uint8_t * restrict b) {
    a = __builtin_assume_aligned(a, 16);
    b = __builtin_assume_aligned(b, 16);
```

Now compiler uses ```movdqa``` instruction for aligned move instead of ```movdqu``` and saves 4 instructions per loop in expression ```a[i] += b[i];```:

Unaligned
```
movdqu  xmm0, xmmword ptr [rsi + rax]
movdqu  xmm1, xmmword ptr [rsi + rax + 16]
movdqu  xmm2, xmmword ptr [rdi + rax]
paddb   xmm2, xmm0
movdqu  xmm0, xmmword ptr [rdi + rax + 16]
paddb   xmm0, xmm1
movdqu  xmm1, xmmword ptr [rdi + rax + 32]
movdqu  xmm3, xmmword ptr [rdi + rax + 48]
movdqu  xmmword ptr [rdi + rax], xmm2
movdqu  xmmword ptr [rdi + rax + 16], xmm0
movdqu  xmm0, xmmword ptr [rsi + rax + 32]
paddb   xmm0, xmm1
movdqu  xmm1, xmmword ptr [rsi + rax + 48]
paddb   xmm1, xmm3
movdqu  xmmword ptr [rdi + rax + 32], xmm0
movdqu  xmmword ptr [rdi + rax + 48], xmm1
```

Aligned
```
movdqa  xmm0, xmmword ptr [rdi + rax]
movdqa  xmm1, xmmword ptr [rdi + rax + 16]
movdqa  xmm2, xmmword ptr [rdi + rax + 32]
movdqa  xmm3, xmmword ptr [rdi + rax + 48]
paddb   xmm0, xmmword ptr [rsi + rax]
paddb   xmm1, xmmword ptr [rsi + rax + 16]
movdqa  xmmword ptr [rdi + rax], xmm0
movdqa  xmmword ptr [rdi + rax + 16], xmm1
paddb   xmm2, xmmword ptr [rsi + rax + 32]
paddb   xmm3, xmmword ptr [rsi + rax + 48]
movdqa  xmmword ptr [rdi + rax + 32], xmm2
movdqa  xmmword ptr [rdi + rax + 48], xmm3
```

**AVX**

Now, trying to turn on AVX2 instructions.

```bash
$ make clean; make ASSEMBLE=1 VECTORIZE=1 AVX2=1 example1.o
```

**Write-up 2:** This code is still not aligned when using AVX2 registers. Fix the code to make sure it uses aligned moves for the best performance. 

Assembly of ```a[i] += b[i];```:
```
vmovdqu ymm0, ymmword ptr [rdi + rax]
vmovdqu ymm1, ymmword ptr [rdi + rax + 32]
vmovdqu ymm2, ymmword ptr [rdi + rax + 64]
vmovdqu ymm3, ymmword ptr [rdi + rax + 96]
vpaddb  ymm0, ymm0, ymmword ptr [rsi + rax]
vpaddb  ymm1, ymm1, ymmword ptr [rsi + rax + 32]
vpaddb  ymm2, ymm2, ymmword ptr [rsi + rax + 64]
vpaddb  ymm3, ymm3, ymmword ptr [rsi + rax + 96]
vmovdqu ymmword ptr [rdi + rax], ymm0
vmovdqu ymmword ptr [rdi + rax + 32], ymm1
vmovdqu ymmword ptr [rdi + rax + 64], ymm2
vmovdqu ymmword ptr [rdi + rax + 96], ymm3
```

```vmovdqu``` is an AVX instruction for unaligned move.\
AVX requires 32-byte alignment:
```c
__builtin_assume_aligned(a, 32);
```

The assembly size stated the same, but ```vmovdqu``` changed by ```vmovdqa```.

**Example 2**

```bash
$ make clean; make ASSEMBLE=1 VECTORIZE=1 example2.o
```

The loop with this if statement was not vectorized
```c
if (b[i] > a[i])
{
    a[i] = b[i];
}
```

For proper vectorization, it changed to
```c
a[i] = (b[i] > a[i]) ? b[i] : a[i];
```

movdqa  xmm0, xmmword ptr [rsi + rax]
movdqa  xmm1, xmmword ptr [rsi + rax + 16]
pmaxub  xmm0, xmmword ptr [rdi + rax]
pmaxub  xmm1, xmmword ptr [rdi + rax + 16]
movdqa  xmmword ptr [rdi + rax], xmm0
movdqa  xmmword ptr [rdi + rax + 16], xmm1
movdqa  xmm0, xmmword ptr [rsi + rax + 32]
movdqa  xmm1, xmmword ptr [rsi + rax + 48]
pmaxub  xmm0, xmmword ptr [rdi + rax + 32]
pmaxub  xmm1, xmmword ptr [rdi + rax + 48]
movdqa  xmmword ptr [rdi + rax + 32], xmm0
movdqa  xmmword ptr [rdi + rax + 48], xmm1

For returning the pack of maximum values between 2 vectors, compiler uses instruction ```pmaxub```.

**Write-up 3:** Provide a theory for why the compiler is generating dramatically different assembly.

Ternary operator allow compilere to make just move operation, while if statement requires compare and jump steps as I see in assembly and LLVM IR. The gist of both ternary operator and if statement in the example is same and after a long search of a reason I don't understand why compiler doesnt't compile these cases in same way.

**Example 3**

```bash
$ make clean; make ASSEMBLE=1 VECTORIZE=1 example3.o
```

**Write-up 4:** Inspect the assembly and determine why the assembly does not include instructions with vector registers. Do you think it would be faster if it did vectorize? Explain.

The process of vectorization consists of 3 phases:
* Legality
* Profitability
* Transform

Sinse vectorization was not applied with both Loop and SLP vectorizers, it could either be illegal or expensive.

Let's look at assembly carefully
```
push    rax
inc     rsi
mov     edx, 65536
call    memcpy@PLT
pop     rax
ret
```

The whole data move is just one call of memcpy and it cannot be accelerated by vectorization.

**Example 4**

```bash
$ make clean; make ASSEMBLE=1 VECTORIZE=1 example4.o
```

**Write-up 5:** Check the assembly and verify that it does in fact vectorize properly. Also what do you notice when you run the command
```bash
$ clang -O3 example4.c -o example4; ./example4
```
with and without the -ffast-math flag? Specifically, why do you a see a difference in the output. 

With ```-ffast-math``` flag clang notices that the loop was vectorized and assembly use ```addpd``` instruction, which is SSE instuction, instead of ```addsd``` used before. 

Execution
```bash
$ clang -O3 example4.c -o example4
$ ./example4
The decimal floating point sum result is: 11.667578
The raw floating point sum result is: 0x1.755cccec10aa5p+3
```

With -ffast-math flag
```bash
$ clang -O3 example4.c -o example4 -ffast-math
$ ./example4
The decimal floating point sum result is: 11.667578
The raw floating point sum result is: 0x1.755cccec10aa3p+3
```

The difference in output is in hexadecimal form of sum.\
It caused by the reordered sum of floating-point numbers, since floating-point operations are not associative and may give different result due to error rounding rules.

## Homework. Performance Impacts of Vectorization

Build without vectorization
```bash
$ make
$ ./loop
```
Best elapsed execution time over 10 runs: ```0.075208 sec```

Build with SSE vectorization
```bash
$ make VECTORIZE=1
$ ./loop
```
Best elapsed execution time over 10 runs: ```0.011556 sec```

Build with AVX2 vectorization
```bash
$ make VECTORIZE=1 AVX2=1
$ ./loop
```
Best elapsed execution time over 10 runs: ```0.005000 sec```

The support of AVX2 instruction can be seen with ```cat /proc/cpuinfo```

**Write-up 6:**\
What speedup does the vectorized code achieve over the unvectorized code?\
What additional speedup does using -mavx2 give?\
What can you infer about the bit width of the default vector registers on your machine?\
What about the bit width of the AVX2 vector registers?\
Hint: aside from speedup and the vectorization report, the most relevant information is that the data type for each array is uint32_t. 

The speedup of vectorized code with SSE is about x7, with AVX2 is x15.\
The bit width of SSE registers is 128-bit, AVX2 - 256-bit or 512-bit.

**Debugging vectorization**

Useful flags:
* **-Rpass=loop-vectorize**\
Identify successfully vectorized loops.
* **-Rpass-missed=loop-vectorize**\
Identify failed vectorization.
* **-Rpass-analysis=loop-vectorize**\
Identify the statements that caused vectorization to fail.

Build into assembly
```bash
$ make ASSEMBLE=1 VECTORIZE=1
```

**Write-up 7:** Compare the contents of loop.s when the VECTORIZE flag is set/not set.\
Which instruction (copy its text here) is responsible for the vector add operation?\
Which instruction (copy its text here) is responsible for the vector add operation when you additionally pass AVX2=1?

// ```-fno-unroll-loops``` flag added

__VECTORIZE=0__

```
.loc	1 75 32 is_stmt 1               # loop.c:75:32
movl	4128(%rsp,%rax,4), %ecx
.loc	1 75 25 is_stmt 0               # loop.c:75:25
addl	8224(%rsp,%rax,4), %ecx
.loc	1 75 18                         # loop.c:75:18
movl	%ecx, 32(%rsp,%rax,4)
```

__VECTORIZE=1__
```
.loc	1 75 32 is_stmt 1               # loop.c:75:32
movdqa	4128(%rsp,%rax,4), %xmm0
.loc	1 75 25 is_stmt 0               # loop.c:75:25
paddd	8224(%rsp,%rax,4), %xmm0
.loc	1 75 18                         # loop.c:75:18
movdqa	%xmm0, 32(%rsp,%rax,4)
```

__VECTORIZE=1 AVX2=1__
```
.loc	1 75 32 is_stmt 1               # loop.c:75:32
vmovdqu	4128(%rsp,%rax,4), %ymm0
.loc	1 75 25 is_stmt 0               # loop.c:75:25
vpaddd	8224(%rsp,%rax,4), %ymm0, %ymm0
.loc	1 75 18                         # loop.c:75:18
vmovdqu	%ymm0, 32(%rsp,%rax,4)
```

The corresponding add instructions are: __addl, paddd, vpaddd__.

**Write-up 8:** Use the __OP__ macro to experiment with different operators in the data parallel loop. Do any versions of the loop not vectorize with VECTORIZE=1 AVX2=1? Study the assembly code for << with just VECTORIZE=1 and explain how it differs from the AVX2 version.

The loop with division operator was not vectorized.\

Shift with SSE
```
.loc	1 75 20 is_stmt 1               # loop.c:75:20
movdqa	8224(%rsp,%rcx,4), %xmm1
.loc	1 75 32 is_stmt 0               # loop.c:75:32
movdqa	4128(%rsp,%rcx,4), %xmm2
.loc	1 75 25                         # loop.c:75:25
pslld	$23, %xmm2
paddd	%xmm0, %xmm2
cvttps2dq	%xmm2, %xmm2
pshufd	$245, %xmm1, %xmm3              # xmm3 = xmm1[1,1,3,3]
pmuludq	%xmm2, %xmm1
pshufd	$232, %xmm1, %xmm1              # xmm1 = xmm1[0,2,2,3]
pshufd	$245, %xmm2, %xmm2              # xmm2 = xmm2[1,1,3,3]
pmuludq	%xmm3, %xmm2
pshufd	$232, %xmm2, %xmm2              # xmm2 = xmm2[0,2,2,3]
punpckldq	%xmm2, %xmm1            # xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
.loc	1 75 18                         # loop.c:75:18
movdqa	%xmm1, 32(%rsp,%rcx,4)
```

Shift with AVX2
```
.loc	1 75 20 is_stmt 1               # loop.c:75:20
vmovdqu	8224(%rsp,%rcx,4), %ymm0
.loc	1 75 25 is_stmt 0               # loop.c:75:25
vpsllvd	4128(%rsp,%rcx,4), %ymm0, %ymm0
.loc	1 75 18                         # loop.c:75:18
vmovdqu	%ymm0, 32(%rsp,%rcx,4)
```

The AVX2 instruction set has a single instruction ```vpsllvd``` for shift. SSE also has but only support shift to constant value.

**Packing smaller words into vectors**

**Write-up 9:** What is the new speedup for the vectorized code, over the unvectorized code, and for the AVX2 vectorized code, over the unvectorized code, when you change __TYPE__ to ```uint64_t```, ```uint32_t```, ```uint16_t``` and ```uint8_t```? For each experiment, set __OP__ to ```+``` and do not change ```N```.

__uint64_t__
```
Default:    0.059382 sec
SSE:        0.028241 sec // x2
AVX2:       0.012709 sec // x5
```

__uint32_t__
```
Default:    0.057300 sec
SSE:        0.011556 sec // x5
AVX2:       0.005000 sec // x11
```

__uint16_t__
```
Default:    0.051612 sec
SSE:        0.004991 sec // x10
AVX2:       0.000024 sec // x2100
```

__uint8_t__
```
Default:    0.051934 sec
SSE:        0.000024 sec // x2100
AVX2:       0.000024 sec // x2100
```

**To vectorize or not to vectorize**

**Write-up 10:** You already determined that ```uint64_t``` yields the least performance improvement for vectorized codes. Test a vector multiplication (i.e., ```__OP__``` is ```*```) using ```uint64_t``` arrays. What happens to the AVX2 vectorized code’s speedup relative to the unvectorized code (also using ```uint64_t``` and ```*```)? What about when you set the data type width to be smaller - say ```uint8_t```?

__uint64_t__
```
Default:    0.073939 sec
SSE:        0.058997 sec // x1.5
AVX2:       0.038294 sec // x2
```

__uint8_t__
```
Default:    0.058916 sec
SSE:        0.000026 sec // x2200
AVX2:       0.000026 sec // x2200
```

**Write-up 11:** Open up the __perf-report__ tool for the AVX2 vectorized multiply code using ```uint64_t```. Does the vector multiply take the most time? If not, where is time going instead? Now change ```__OP__``` back to ```+```, rerun the experiment and inspect perf-report again. How does the percentage of time taken by the AVX2 vector add instruction compare to the time spent on the AVX2 vector multiply instruction?

// ```-fno-unroll-loops``` flag added

```bash
$ perf record ./loop
$ perf report
```

perf annotate
```
       │     C[j] = A[j] __OP__ B[j];
  2,35 │ a0:   vmovdqu      0x4020(%rsp,%rcx,8),%ymm0
 10,05 │       vmovdqu      0x2020(%rsp,%rcx,8),%ymm1
  6,22 │       vpsrlq       $0x20,%ymm1,%ymm2
  2,34 │       vpmuludq     %ymm0,%ymm2,%ymm2
  1,57 │       vpsrlq       $0x20,%ymm0,%ymm3
  3,94 │       vpmuludq     %ymm3,%ymm1,%ymm3
 27,79 │       vpaddq       %ymm2,%ymm3,%ymm2
 18,86 │       vpsllq       $0x20,%ymm2,%ymm2
       │       vpmuludq     %ymm0,%ymm1,%ymm0
  2,21 │       vpaddq       %ymm2,%ymm0,%ymm0
 10,37 │       vmovdqu      %ymm0,0x20(%rsp,%rcx,8)
```

The instructions responsible for vector multiplication are all between first 2 moves and last one move. The are 73,3% together.\
Multiplication of vectors is ```vpmuludq``` and it takes 2,34% and 3,94%.\
The hottest instruction is ```vpaddq``` - 27,79% which is significantly less than ```vpmuludq```.\
12,4% is for moving ```A``` and ```B``` to vectors and 10,37% for moving vectors to ```C```.\
The whole line is 96,07%.

With ```__OP__``` = +
```
       │     C[j] = A[j] __OP__ B[j];
       │ a0:   vmovdqu      0x2020(%rsp,%rcx,8),%ymm0
 67,63 │       vpaddq       0x4020(%rsp,%rcx,8),%ymm0,%ymm0
  6,80 │       vmovdqu      %ymm0,0x20(%rsp,%rcx,8)
```

The whole line is 73,74%.\
The next hottest place is jump in the end of outher loop which takes 18,41%.

So, the add instruction ```vpaddq``` takes the most time in both cases.

**Vector Patterns**

**Loops with Runtime Bounds**

**Write-up 12:** Get rid of the ```#define N 1024``` macro and redefine N as: ```int N = atoi(argv[1]);``` (Setting N through the command line ensures that the compiler will make no assumptions about it). Rerun (with various choices of N) and compare the AVX2 vectorized, non-AVX2 vectorized, and unvectorized codes. Does the speedup change dramatically relative to the ```N = 1024``` case? Why?

__N = 1024__
```
Default:    0.073646 sec
SSE:        0.031774 sec // x2
AVX2:       0.013214 sec // x5
```

The non-vectorized version is a little slower. Speedup preserves almost the same.

I've also tried ```N = 1111``` which is not a power of two and there is no visible change in execution time.

The speedup is not relative to ```N```. The loop now has 2 variants - vectorized and non-vectorized. Non-vectorized version is only executed with tail elements if vector register width was not a divisor of ```N```.

```Striding```

**Write-up 13:** Set ```__TYPE__``` to uint32_t and ```__OP__``` to ```+```, and change your inner loop to be strided. Does clang vectorize the code? Why might it choose not to vectorize the code?

Clang did not vectorized the code. It writes the remark that cost-model indicated the vectorization as not beneficial. 

**Write-up 14:** Use the ```#vectorize pragma``` described in the clang language extensions webpage above to make clang vectorize the strided loop.\
What is the speedup over non-vectorized code for non-AVX2 and AVX2 vectorization?\
What happens if you change the vectorize width to 2?\
Play around with the clang loop pragmas and report the best you found (that vectorizes the loop).\
Did you get a speedup over the non-vectorized code? 

```
Default:    0.023327 sec
#pragma clang loop vectorize(enable) interleave(enable)
SSE:        0.036966 sec - Best SSE
AVX2:       0.018620 sec - Best AVX2
#pragma clang loop vectorize_width(2) interleave_count(2)
SSE:        0.046169 sec
AVX2:       0.032797 sec
#pragma clang loop vectorize_width(4) interleave_count(2)
SSE:        0.039841 sec
AVX2:       0.018464 sec - Best AVX2
#pragma clang loop vectorize_width(4) interleave_count(8)
SSE:        0.043076 sec
AVX2:       0.018906 sec - Best AVX2
#pragma clang loop vectorize_width(8) interleave_count(2)
SSE:        0.041651 sec
AVX2:       0.039403 sec
#pragma clang loop vectorize_width(8) interleave_count(4)
SSE:        0.043806 sec
AVX2:       0.041787 sec
#pragma clang loop vectorize_width(8) interleave_count(8)
SSE:        0.043971 sec
AVX2:       0.042554 sec
```

SSE vectorization did not give any speedup.\
AVX2 vectorization gave up to 20% speedup in some cases.

**Strip Mining**

```c
for (j = 0; j < N; j++) {
    total += A[j];
}
```

**Write-up 15:** This code vectorizes, but how does it vectorize? Turn on ASSEMBLE=1, look at the assembly dump, and explain what the compiler is doing.

According to Clang Vectorizers documentation, the reduction variable becomes a vector of integers, and at the end of the loop the elements of the array are added together to create the correct result

```
for (j = 0; j < N; j++) {
    total += A[j];
}
>>
vpaddq  ymm0, ymm0, ymmword ptr [rsp + 8*rax - 208]
vpaddq  ymm1, ymm1, ymmword ptr [rsp + 8*rax - 176]
vpaddq  ymm2, ymm2, ymmword ptr [rsp + 8*rax - 144]
vpaddq  ymm3, ymm3, ymmword ptr [rsp + 8*rax - 112]
vpaddq  ymm0, ymm0, ymmword ptr [rsp + 8*rax - 80]
vpaddq  ymm1, ymm1, ymmword ptr [rsp + 8*rax - 48]
vpaddq  ymm2, ymm2, ymmword ptr [rsp + 8*rax - 16]   assignment
vpaddq  ymm3, ymm3, ymmword ptr [rsp + 8*rax + 16]  ___________
add     rax, 32
cmp     rax, 65564                                   for loop
jne     .LBB0_1
vpaddq  ymm0, ymm1, ymm0
vpaddq  ymm0, ymm2, ymm0
vpaddq  ymm0, ymm3, ymm0
vextracti128    xmm1, ymm0, 1
vpaddq  xmm0, xmm0, xmm1
vpshufd xmm1, xmm0, 238                 # xmm1 = xmm0[2,3,2,3]
vpaddq  xmm0, xmm0, xmm1
vmovq   rbx, xmm0
```
