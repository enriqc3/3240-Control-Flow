#Enrique Tapia
	.file	"lab_control_flow.c"
	.text
	.globl	user_response
	.bss
	.align 4
	.type	user_response, @object
	.size	user_response, 4
user_response:
	.zero	4
	.section	.rodata
	.align 8
.LC0:
	.string	"==============================="
	.align 8
.LC1:
	.string	"Welcome, here are your options:"
.LC2:
	.string	"1. View employee data"
.LC3:
	.string	"2. View customer data"
.LC4:
	.string	"10. Quit"
.LC5:
	.string	"Enter your response now:"
.LC6:
	.string	"%d"
	.text
	.globl	main
	.type	main, @function
LC7: 
	.string "Now quitting. . ."
LC8:
	.string "\nEmployee data:\nJotaro Kujo, 30, 195cm, B\n"
LC9:
	.string "\nCustomer data:\nRiley, 8, 110CM, A\n"
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
.L2:
	/*While not true*/
	movl	user_response(%rip), %eax
	cmpl	$10, %eax /*if user_response == 10 then je*/
	je	loopquit
	

	leaq	.LC0(%rip), %rdi /*print top bar */
	call	puts@PLT
	leaq	.LC1(%rip), %rdi /*print Welcome, here are your options*/
	call	puts@PLT
	leaq	.LC2(%rip), %rdi /*print 1. View employee data*/
	call	puts@PLT
	leaq	.LC3(%rip), %rdi /*print 2. View customer data*/
	call	puts@PLT
	leaq	.LC4(%rip), %rdi /*print 10. Quit*/
	call	puts@PLT
	leaq	.LC0(%rip), %rdi /*print bottom bar*/
	call	puts@PLT
	leaq	.LC5(%rip), %rdi /*print Enter your response now*/
	call	puts@PLT
	leaq	user_response(%rip), %rsi
	leaq	.LC6(%rip), %rdi
	movl	$0, %eax
	call	__isoc99_scanf@PLT

	/*check if user_response is either 1 or 2*/
	movl	user_response(%rip), %eax
	cmpl	$1, %eax /*if user_response == 1 then je*/
	je	employee
	cmpl	$2, %eax /*if user_response == 2 then je*/
	je	customer

	jmp	.L2
	.cfi_endproc

employee:
	leaq	LC8(%rip), %rdi /*print employee data*/
	call	puts@PLT
	movl	user_response(%rip), %eax
	movl	$0, %eax
	jmp .L2				/*jump back to while loop*/

customer:
	leaq	LC9(%rip), %rdi /*print customer data*/
	call	puts@PLT
	movl	user_response(%rip), %eax
	movl	$0, %eax
	jmp .L2				/*jump back to while loop*/

loopquit:
	leaq	LC7(%rip), %rdi /*print Now quitting. . .*/
	call	puts@PLT
	movl	$1, %eax
	popq	%rbp
	ret

.LFE0:
	.size	main, .-main
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits
