	.text
	.file	"test.ll"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	movq	b@GOTPCREL(%rip), %rax
	movl	(%rax), %eax
	addl	$2, %eax
	movq	a@GOTPCREL(%rip), %rcx
	movl	%eax, (%rcx)
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	b,@object                       # @b
	.bss
	.globl	b
	.p2align	2, 0x0
b:
	.long	0                               # 0x0
	.size	b, 4

	.type	a,@object                       # @a
	.globl	a
	.p2align	2, 0x0
a:
	.long	0                               # 0x0
	.size	a, 4

	.section	".note.GNU-stack","",@progbits
