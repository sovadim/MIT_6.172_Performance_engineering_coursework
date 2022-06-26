	.text
	.file	"fib.c"
	.globl	fib                             # -- Begin function fib
	.p2align	4, 0x90
	.type	fib,@function
fib:                                    # @fib
	.cfi_startproc
# %bb.0:
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	xorl	%eax, %eax
                                        # kill: def $rax killed $eax
	cmpq	$2, %rdi
	movq	%rdi, 40(%rsp)                  # 8-byte Spill
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	jl	.LBB0_2
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	addq	$-1, %rdi
	movq	%rdi, (%rsp)                    # 8-byte Spill
	callq	fib
	movq	8(%rsp), %rsi                   # 8-byte Reload
	movq	16(%rsp), %rdx                  # 8-byte Reload
	movq	%rdx, %rcx
	addq	$-2, %rcx
	movq	%rcx, 24(%rsp)                  # 8-byte Spill
	addq	%rsi, %rax
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	cmpq	$4, %rdx
	movq	%rcx, 40(%rsp)                  # 8-byte Spill
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	jge	.LBB0_1
.LBB0_2:
	movq	48(%rsp), %rcx                  # 8-byte Reload
	movq	40(%rsp), %rax                  # 8-byte Reload
	addq	%rcx, %rax
	addq	$56, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	fib, .Lfunc_end0-fib
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 13.0.0-2"
	.section	".note.GNU-stack","",@progbits
	.addrsig
