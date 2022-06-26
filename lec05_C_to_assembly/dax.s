	.text
	.file	"dax.c"
	.globl	dax                             # -- Begin function dax
	.p2align	4, 0x90
	.type	dax,@function
dax:                                    # @dax
	.cfi_startproc
# %bb.0:
	subq	$136, %rsp
	.cfi_def_cfa_offset 144
	movq	%rdi, 104(%rsp)                 # 8-byte Spill
	movsd	%xmm0, 112(%rsp)                # 8-byte Spill
	movq	%rsi, 120(%rsp)                 # 8-byte Spill
	movq	%rdx, 128(%rsp)                 # 8-byte Spill
	cmpq	$0, %rdx
	jle	.LBB0_9
# %bb.1:
	movq	128(%rsp), %rcx                 # 8-byte Reload
	xorl	%eax, %eax
                                        # kill: def $rax killed $eax
	cmpq	$4, %rcx
	movq	%rax, 96(%rsp)                  # 8-byte Spill
	jb	.LBB0_8
# %bb.2:
	movsd	112(%rsp), %xmm0                # 8-byte Reload
                                        # xmm0 = mem[0],zero
	movq	128(%rsp), %rcx                 # 8-byte Reload
	andq	$-4, %rcx
	movq	%rcx, 24(%rsp)                  # 8-byte Spill
	unpcklpd	%xmm0, %xmm0                    # xmm0 = xmm0[0,0]
	movaps	%xmm0, 32(%rsp)                 # 16-byte Spill
	movaps	%xmm0, 48(%rsp)                 # 16-byte Spill
	addq	$-4, %rcx
	movq	%rcx, %rax
	shrq	$2, %rax
	addq	$1, %rax
	movq	%rax, 72(%rsp)                  # 8-byte Spill
	andq	$1, %rax
	movq	%rax, 80(%rsp)                  # 8-byte Spill
	xorl	%eax, %eax
                                        # kill: def $rax killed $eax
	cmpq	$0, %rcx
	movq	%rax, 88(%rsp)                  # 8-byte Spill
	je	.LBB0_5
# %bb.3:
	movq	72(%rsp), %rax                  # 8-byte Reload
	movabsq	$9223372036854775806, %rcx      # imm = 0x7FFFFFFFFFFFFFFE
	andq	%rcx, %rax
	xorl	%ecx, %ecx
                                        # kill: def $rcx killed $ecx
	movq	%rcx, 8(%rsp)                   # 8-byte Spill
	movq	%rax, 16(%rsp)                  # 8-byte Spill
.LBB0_4:                                # =>This Inner Loop Header: Depth=1
	movq	16(%rsp), %rcx                  # 8-byte Reload
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	104(%rsp), %rdx                 # 8-byte Reload
	movaps	32(%rsp), %xmm2                 # 16-byte Reload
	movaps	48(%rsp), %xmm3                 # 16-byte Reload
	movq	120(%rsp), %rdi                 # 8-byte Reload
	movupd	(%rdi,%rax,8), %xmm1
	movupd	16(%rdi,%rax,8), %xmm0
	mulpd	%xmm3, %xmm1
	movaps	%xmm1, -96(%rsp)                # 16-byte Spill
	mulpd	%xmm2, %xmm0
	movaps	%xmm0, -80(%rsp)                # 16-byte Spill
	movupd	%xmm1, (%rdx,%rax,8)
	movupd	%xmm0, 16(%rdx,%rax,8)
	movq	%rax, %rsi
	orq	$4, %rsi
	movq	%rsi, -56(%rsp)                 # 8-byte Spill
	movupd	(%rdi,%rsi,8), %xmm1
	movupd	16(%rdi,%rsi,8), %xmm0
	mulpd	%xmm3, %xmm1
	movaps	%xmm1, -48(%rsp)                # 16-byte Spill
	mulpd	%xmm2, %xmm0
	movaps	%xmm0, -32(%rsp)                # 16-byte Spill
	movupd	%xmm1, (%rdx,%rsi,8)
	movupd	%xmm0, 16(%rdx,%rsi,8)
	addq	$8, %rax
	movq	%rax, -8(%rsp)                  # 8-byte Spill
	addq	$-2, %rcx
	movq	%rcx, (%rsp)                    # 8-byte Spill
	cmpq	$0, %rcx
	movq	%rax, %rdx
	movq	%rdx, 8(%rsp)                   # 8-byte Spill
	movq	%rcx, 16(%rsp)                  # 8-byte Spill
	movq	%rax, 88(%rsp)                  # 8-byte Spill
	jne	.LBB0_4
.LBB0_5:
	movq	80(%rsp), %rax                  # 8-byte Reload
	movq	88(%rsp), %rcx                  # 8-byte Reload
	movq	%rcx, -104(%rsp)                # 8-byte Spill
	cmpq	$0, %rax
	je	.LBB0_7
# %bb.6:
	movq	104(%rsp), %rax                 # 8-byte Reload
	movq	-104(%rsp), %rcx                # 8-byte Reload
	movaps	32(%rsp), %xmm2                 # 16-byte Reload
	movaps	48(%rsp), %xmm3                 # 16-byte Reload
	movq	120(%rsp), %rdx                 # 8-byte Reload
	movupd	(%rdx,%rcx,8), %xmm1
	movupd	16(%rdx,%rcx,8), %xmm0
	mulpd	%xmm3, %xmm1
	mulpd	%xmm2, %xmm0
	movupd	%xmm1, (%rax,%rcx,8)
	movupd	%xmm0, 16(%rax,%rcx,8)
.LBB0_7:
	movq	24(%rsp), %rax                  # 8-byte Reload
	movq	128(%rsp), %rcx                 # 8-byte Reload
	cmpq	%rcx, %rax
	movq	%rax, 96(%rsp)                  # 8-byte Spill
	je	.LBB0_9
.LBB0_8:
	movq	96(%rsp), %rax                  # 8-byte Reload
	movq	%rax, -112(%rsp)                # 8-byte Spill
	jmp	.LBB0_10
.LBB0_9:
	addq	$136, %rsp
	.cfi_def_cfa_offset 8
	retq
.LBB0_10:                               # =>This Inner Loop Header: Depth=1
	.cfi_def_cfa_offset 144
	movq	-112(%rsp), %rax                # 8-byte Reload
	movq	128(%rsp), %rcx                 # 8-byte Reload
	movq	104(%rsp), %rdx                 # 8-byte Reload
	movq	120(%rsp), %rsi                 # 8-byte Reload
	movsd	112(%rsp), %xmm0                # 8-byte Reload
                                        # xmm0 = mem[0],zero
	mulsd	(%rsi,%rax,8), %xmm0
	movsd	%xmm0, -128(%rsp)               # 8-byte Spill
	movsd	%xmm0, (%rdx,%rax,8)
	addq	$1, %rax
	movq	%rax, -120(%rsp)                # 8-byte Spill
	cmpq	%rcx, %rax
	movq	%rax, -112(%rsp)                # 8-byte Spill
	je	.LBB0_9
	jmp	.LBB0_10
.Lfunc_end0:
	.size	dax, .Lfunc_end0-dax
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 13.0.0-2"
	.section	".note.GNU-stack","",@progbits
	.addrsig
