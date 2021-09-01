# CMPS-3240-Control-Flow

Introduction to control of flow in GAS x86

## Objectives

* Learn how to format conditionals using `cmp` and `j` operations
* Understand `if` and `switch` statements at the assembly level
* Optimize a `while` loop at the assembly level

## Prerequisites

* Using global variables with GAS x86 (referencing and dereferencing)
* Knowledge of the stack is not required (local scope)

## Requirements

### General

* Familiarity with C-language `if`, `switch` and `while` constructs

### Software

This lab requires the following software: `gcc` version 8.3.0, `make`, `git`.

### Hardware

This lab requires an x86 processor. It will not work on an ARM system (such as a Raspberry Pi).

### OS Compatability

| Linux | Mac | Windows |
| :--- | :--- | :--- |
| Yes* | No | Yes, with WSL* |

This lab requires you to assemble an x86 program. Syntax and calling conventions are specific down to the operating system and version of `gcc` you are using. This lab was created for a system running Debian GNU/Linux 10 (buster). It may work on Ubuntu (check `gcc` version with `gcc --version`).

## Background Exercises

Start by cloning the lab and changing into the directory if you have not done
so already:

```shell
$ git clone git@github.com:DrAlbertCruz/3240-Control-Flow.git
$ cd 3240-Control-Flow/
```

The following are exercises where we use `gcc` to generate GAS x86 files. The
files contain examples of common constructs we use in programming such as:

* `if`
* `case`
* `while`

with some comments about how we might optimize it. We do not go over `for` because
of how similar it is to a `while` loop.

### Branching in x86

The `%rip` is register that points to the next instruction to be executed. There
is a potential trap here. Watch out for guides online that refer to
`%eip`. `%eip` is the 32-bit version of the instruction pointer. However, we
are working with 64-bit version of x86, so it must be `%rip`. With x86-64, 
virtual memory addresses are 64-bits and will need to be stored in 64-bit
sized registers.

To alter the flow of the program you move `%rip`. The simplest approach is to
perform arithmetic on it, such as moving it to some arbitrary address:

```asm
movq %rip, label
```

Or, adding a certain number of bytes to it:

```asm
addq $4, %rip
```

However, both are wrong. You can't directly modify the instruction pointer. It is special.
You need to use specific instructions instead. There are two types of instructions which move the instruction pointer:

* Unconditional aka jumps
* Conditional aka branches (only jump if a condition is true)

#### Unconditional branches

Unconditional branching is a unary command (accepts one argument) where you
provide the label to jump to. For example:

```asm
jmp	.L3
```

Jump to whatever is labelled `.L3`. *Note that labels with a dot were generated
by the compiler/linker. Labels do not always need to start with a dot.*

#### Conditional branches

Conditional branching in x86 is a two-step process. Surprisingly it is more
complicated than MIPS which specifies a conditional branch in a single
instruction. The two steps are:

* Use a `cmp` command to do the math for the conditional expression, and
* Use a conditional jump that checks the result of the previous step against some inequality.

The inequality must always be the expression vs. zero, which complicates things a bit. 
When we form conditionals we usually have a left-hand
side (LHS) and a right-hand side (RHS). For example:

```c
if ( a > b ) {
```

This checks if `a > b`. This is how we naturally form our conditionals as a
high-level programmer. However, in x86, the RHS must be zero. So, before
encoding the conditional, refactor it so that the RHS zero. With this example,
the same condition is:

```c
if ( a - b > 0 ) {
```

This converts to the following pseudo-assembly code:

```asm
cmp b, a
jg jump_target
```
Note that with GAS x86 syntax, the source is first and the destination is
second. So, `b` comes before `a`.  `cmp` is short hand for a subtraction
operation. This subtraction operation sets a flag register. Then, a conditional
jump is called to implement the specific inequality you need. It refers to the flag
register, it does not refer to the contents of the source and destination registers. 
Here is a short summary of conditional operations:

| Command  | Inequality | Explanation |
| ------------- | ------------- | ------------- |
| `je`  | `==` | `a - b == 0` |
| `jne`  | `~=` | `a - b != 0` |
| `jge`  | `>=` | `a - b >= 0` |
| `jg`  | `>` | `a - b > 0` |
| `jle`  | `<=` | `a - b <= 0` |
| `jl`  | `<` | `a - b < 0` |

If the statement is `True`, the jump will be performed. If the statement is
`False`, the instruction pointer will instead move the instruction that
immediately follows the conditional jump. This is called a *fall through*.

### `example_if.s`

The first example is `example_if.s`. Study `example_if.c` before moving on.

It has a global variable called `badger`
which is set to integer value 7. The `main()` function checks if the value of
`badger` is greater or less than ten, and has `printf()` statements based on
the value of `badger`. Since we know that `badger` is 7, it should display:

```shell
Badger is less than or equal to ten!
```

The makefile target `example_if.s` will generate our assembly code. Make it if
you have not done this yet:

```shell
$ make example_if.s
gcc -Wall -O0 -S -o example_if.s example_if.c
```

and open the file in your favorite text editor. This code:

```asm
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
```

is the creation of `main()`'s stack frame and we can ignore it. Ignore it for all following examples. The first
relevant line of code is:

```assembly
movl	badger(%rip), %eax
cmpl	$10, %eax
jle	.L2
```

The line `movl	badger(%rip), %eax` means to dereference `badger` and place the
value into `%eax`. Note that while `badger(%rip)` is a 64-bit address, an `int` is 32-bits.
Thus, the operation should be to move only 32-bits, which is why we use `movl` to 
perform the dereference. `movl` stands for move `long` or double-word, and 32-bits is considered `long`
for x86. If you did `movq`--move quad-word--it would attempt to read 64 bits from memory. Since
`badger` is a 32-bit integer it would be an error. `cmpl $10, %eax` performs the conditional `badger - 10`.
`jle .L2` means that if `badger - 10 <= 0` to jump to `.L2`.

In C-language, the operation is `badger > 10`. However, refactoring that based
on the background discussion it must be `badger - 10 > 0`. *Time out. Why is it
doing the opposite?* `gcc` wants to maintain the order of the blocks. The `if`
block should come first, and the `else` block comes second. Thus, if the inverse
of the condition is true, go to what we think of as the else block. Otherwise,
fall through into what we think of as the `if` block. You can confirm this by
noting that the instructions immediately following the `jle` are to:

```assembly
leaq	.LC0(%rip), %rdi
movl	$0, %eax
call	printf@PLT
jmp	.L3
```

This is a call to `printf()` and `.LC0` is `"Badger is greater than ten!"`.
This is the `if` block, not the `else` block. `.L3` is the point where the two
separate threads of `if` and `else` rejoin into the rest of the program, which
should just `return 1`.

Moving on, the `jmp` is unconditional. So the next few lines:

```assembly
.L2:
	leaq	.LC1(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
```

can only be naturally reached by a jump (not by falling through). `.LC1` is
`"Badger is less than or equal to ten!"` so this must be our `else` block. The
makefile target `example_if.out` will create an executable binary from our
assembly source:

```shell
$ make example_if.out
gcc -Wall -O0 -c -o example_if.o example_if.s
gcc -Wall -O0 -o example_if.out example_if.o
$ ./example_if.out
Badger is less than or equal to ten
```

Study this, and move on. This is quite simple, and we do not need
to optimize this example. Optional exercises if you wanted the challenge:

1. Set `badger` to a value that will get the other outcome for our program.
2. Place the `else` block in the fall through position and the `if` statement
as the branch.

### `example_switch.s`

The first example is `example_switch.s`. Study `example_switch.c` before moving on.
This example uses the C-language `switch` construct. It appears to take only one
argument on the C-side, and branches based on the equivalent of the argument to
explicitly given values. The `default` block is what happens if `ibex` is not
equal to any specified `case` statement. If you haven't already, go ahead and
make the assembly source:

```shell
$ make example_switch.s
gcc -Wall -O0 -S -o example_switch.s example_switch.c
```

and open `example_switch.s` in your favorite text editor. Skip down to:

```c
movl	ibex(%rip), %eax
cmpl	$7, %eax
je	.L2
cmpl	$12, %eax
je	.L3
jmp	.L7
```

This is where the `switch` statement happens. `ibex` is the variable we are
checking. It's value is dereferenced into `%eax`. The first `case` statement
checks if `ibex == 7`, which is realized with `cmpl	$7, %eax`. `je	.L2` branches
if the `%eax - $7 == 0`. If this is true jump to `.L2`. Otherwise, fall through
into another check for `ibex == 12`. One thing to note is that the `switch`
constructs as created by the compiler do not have block code in the fall through
position. There is a jump to each block. Run this code to make sure it works:

```shell
$ make example_switch.out
gcc -Wall -O0 -c -o example_switch.o example_switch.s
gcc -Wall -O0 -o example_switch.out example_switch.o
$ ./example_switch.out
Twelve!
```

#### Optimization of a `switch` statement

There is a very minor optimization that can be performed here. Note that the
default state has a `jmp` to it's block. Yet, if you fall through after `je	.L7`
it will neither be 7 or 12, so it is safe to assume that instructions occurring
after this block should be a part of `default`. So, you can remove the `.L7`
block entirely and change:

```asm
cmpl	$12, %eax
je	.L3
jmp	.L7 /* Why do you jump to default? */
.L2:
```

to:

```asm
cmpl	$12, %eax
je	.L3
leaq	.LC2(%rip), %rdi /* Just cut and paste it here ... */
movl	$0, %eax
call	printf@PLT
jmp .L5 /* ... end of cut and paste */
.L2:
```

That is, cut and paste the `.L7` block to be in the fall through position of
`je	.L3`. *But wait, this still has the same number of `jmp` ops?* Note that
since we have removed the `.L7` block entirely, `.L3` can fall through into
`.L5` directly, and we do not need to `jmp .L5`. As an optional exercise, repeat the above on your own. Make sure it works the same as before the change.

### `example_while.s`

Our next stop: a `while` loop. This example will dive off the deep end for sure.
Start by studying `example_while.c`, then make the assembly code if you haven't done so already:

```shell
$ make example_while.s
gcc -Wall -O0 -S -o example_while.s example_while.c
```

and open `example_while.s` in your favorite text editor. Here is what happened
to our `while` loop:

```asm
jmp	.L2 /* Jump to the check for ( counter < 10 ) */
.L3: /* Start of loop body */
leaq	.LC0(%rip), %rdi
movl	$0, %eax
call	printf@PLT
movl	counter(%rip), %eax /* Refresh counter */
addl	$1, %eax /* Counter++ */
movl	%eax, counter(%rip) /* Save counter */
.L2: /* Check for ( counter < 10 ) */
movl	counter(%rip), %eax
cmpl	$9, %eax
jle	.L3 /* Jump to loop body */
```

To start, there is a `jmp .L2`. `.L2` block appears to be the check to see if
you should loop again. For some reason `gcc` has created a specific block just
for the concept of our loop test. `movl	counter(%rip), %eax` refreshes the value
of `counter` each time the test is performed. Then, we compare it with
`cmpl	$9, %eax` and `jle	.L3`. Alternatively, this could have been
`cmpl	$10, %eax` and `jl	.L3`. They are equivalent.

Inside of `.L3`, we increment `counter` with:

```asm
movl	counter(%rip), %eax
addl	$1, %eax
movl	%eax, counter(%rip)
```

We see this behavior again where `gcc` refreshes the value of `counter` *every*
time it is used. Unfortunately, we have to allow this. You might think to reserve
a specific register for `counter` to save memory read/writes, but there are function
`call`s. Registers are generally not preserved across function calls. We will learn how to preserve
register values across function calls, but that is two labs from now. For now, we will have to ignore this.

### Optimization of a `while` loop

The way `gcc` creates loops seems unnatural. At least, it is not like the way
we coded things by hand during lecture. So, you can try to refactor it lecture
style:

```asm
looptop:               /* What was previously .LC2 is now here */
movl	counter(%rip), %eax
cmpl	$10, %eax        /* %eax - 10 >= 0 */
jge	loopquit           /* Conditional will check need to EXIT */
leaq	.LC0(%rip), %rdi /* Loop body is fall through into here, no need for .LC3 */
movl	$0, %eax
call	printf@PLT
movl	counter(%rip), %eax /* Refresh counter */
addl	$1, %eax
movl	%eax, counter(%rip)
jmp looptop            /* Jump up to looptop */
loopquit:
```

You can fall through into `looptop:` normally because it's the first instruction
after setting up `main()`'s call frame. Note that when we do this, we can remove
the concept of `.LC2` and `.LC3`.

Can we do better? Can we reduce the number of times we have to dereference
`counter`? Consider the loop body:

```c
printf( "Count!" );
counter++;
```

When you call a function, you generally cannot guarantee that the registers will
have the same values (without the stack). So the issue seems to be that we make
a call to `printf()` before doing `counter++`. What if we reversed it?

```c
counter++;
printf( "Count!" );
```

This code is roughly equivalent. On the assembly side we can rearrange it, and also remove
the refresh of `counter`:

```asm
looptop:               
movl	counter(%rip), %eax
cmpl	$10, %eax        
jge	loopquit           
addl	$1, %eax /* Removed a refresh of counter */
movl	%eax, counter(%rip)
leaq	.LC0(%rip), %rdi
movl	$0, %eax
call	printf@PLT
jmp looptop            
loopquit:
```

`cmpl	$10, %eax` does not modify the value in `%eax`. So, the second time that
you carry out `movl	counter(%rip), %eax`, we have not changed it. Thus it is
redundant and you can remove it. Whereas the change to `looptop`/`loopquit` was
stylistic, removing a memory dereference is a significant optimization. Memory
is among the slowest class of instruction types/operations you can perform on a
 microprocessor. As an optional exercise, repeat the above. Make sure it works.
 It should display `Count!` nine times.

 # Technical Approach

A *command line user interface* or CUI is a type of program that displays a
menu in the terminal. Your goal is to implement a CUI program that keeps records
for a company. `lab_control_flow.c` contains code for a program that will view
employee and customer records for a company. However, it has two flaws that
you need to fix:

1. It loops infinitely. If you look at the code, it should stop if the user
enters the value 10.
2. It does not react to the menu. For this lab, it should display some mock up.

## Requirements

Your solution to the lab must be done in assembly. That is, you can use the
make target for `make lab_control_flow.s` to create an initial solution. And,
**you should modify the GAS x86 assembly code** to make a working program.
Solutions where you did it all in C-language will be obvious. The point of the
examples was to demonstrate that `gcc` does some strange stuff, and it will be
obvious to me if you did this in C and not x86. Solutions done in C will not get
any credit.

When the user selects options 1 and 2, display some mock up. It does not need
to be a working program. For example:

```shell
===============================
Welcome, here are your options:
1. View employee data
2. View customer data
10. Quit
===============================
Enter your response now:
1
Employee data:
Jotaro Kujo, 30, 195cm, B
===============================
Welcome, here are your options:
1. View employee data
2. View customer data
10. Quit
===============================
Enter your response now:
```

# Submission

Submit your code to Moodle for credit. You must submit your `.s` file.
