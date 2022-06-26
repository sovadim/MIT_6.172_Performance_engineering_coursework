	.text
	.file	"fib.c"
	.globl	fib                             # -- Begin function fib
	.p2align	4, 0x90
	.type	fib,@function
fib:                                    # @fib
	.cfi_startproc
# %bb.0:
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	pushq	%rax
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	xorl	%r14d, %r14d
	cmpq	$2, %rdi
	jl	.LBB0_3
# %bb.1:
	movq	%rdi, %rbx
	.p2align	4, 0x90
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	leaq	-1(%rbx), %rdi
	callq	fib
	leaq	-2(%rbx), %rdi
	addq	%rax, %r14
	cmpq	$3, %rbx
	movq	%rdi, %rbx
	jg	.LBB0_2
.LBB0_3:
	addq	%rdi, %r14
	movq	%r14, %rax
	addq	$8, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	fib, .Lfunc_end0-fib
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 13.0.0-2"
	.section	".note.GNU-stack","",@progbits
	.addrsig
