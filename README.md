# 3240-control-flow
Control of flow in GAS x86

# Introduction

## Background Exercises

Start by cloning the lab and changing into the directory if you have not done
so already:

```shell
$ git clone git@github.com:DrAlbertCruz/3240-control-flow.git
$ cd 3240-control-flow/
```

The following are exercises where we use `gcc` to generate GAS x86 files. The
files contain examples of common constructs we use in programming such as:

* `if`
* `while`
* `for`
* `case`

with some comments about how we might optimize it.

### Branching in x86

The `%rip` is register that points to the next instruction to be executed. An
intuitive way to move `%rip` would be to perform arithmetic on it, such as
moving it to some arbitrary address:

```x86
mov %rip, label
```

which is wrong. You can't directly modify the instruction pointer, you need to
use special instructions that perform conditional/comparisons instead. There
is also a potential pitfall here, watch out for guides online that refer to
`%eip`. `%eip` is the 32-bit version of the instruction pointer. However, we
are working with 64-bit version of x86, so it must be `%rip`. There are two
types of instructions which move the instruction pointer:

* Unconditional aka jumps
* Conditional aka branches

#### Unconditional branches

Unconditional branching is a unary command (accepts one argument) where you
provide the label to jump to. For example:

```asm
jmp	.L3
```

Jump to whatever is labelled `.L3`.

#### Conditional branches

Conditional branching in x86 is a two-step process. Surprisingly it is more
complicated than MIPS which specifies a conditional branch in a single
instruction. The two steps are:

* Use a `cmp` command to perform the comparison, and
* Use a conditional jump to move the instruction pointer.

An important note is that when we form conditionals we usually have a left-hand
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
cmp b, a # Do a - b
jg jump_target
```
*Note that `cmp` order is reversed!* `cmp` is short hand for a subtraction operation. This subtraction operation sets a flag register. Then, a condition jump is called to implement
the specific inequality you need. Here is a short summary of them:

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

The first example is `example_if.s`. It has a global variable called `badger`
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

is the creation of `main()`'s stack frame and we can ignore it. The first
relevant line of code is:

```assembly
movl	badger(%rip), %eax
cmpl	$10, %eax
jle	.L2
```

The line `movl	badger(%rip), %eax` means to dereference `badger` and place the
value into `%eax`. `cmpl	$10, %eax` performs the conditional `badger - 10`.
`jle	.L2` means that if `badger - 10 <= 0` to jump to `.L2`.

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
```

Study this, and move on. Optionally, set `badger` to a value that will get
the other outcome for our program.
