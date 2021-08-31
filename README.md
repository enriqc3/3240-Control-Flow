# 3240-control-flow
Control of flow in GAS x86

# Introduction

# Background Exercises

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

## Branching in x86

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

### Unconditional branches

Unconditional branching is a unary command (accepts one argument) where you
provide the label to jump to. For example:

```asm
jmp	.L3
```

Jump to whatever is labelled `.L3`.

### Conditional branches

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
cmp a, b # a and b would be replaced by argument names
jg jump_target
```

Basically, `cmp` is short hand for a subtraction operation. This subtraction
operation sets a flag register. Then, a condition jump is called to implement
the specific inequality you need. Here is a short summary of them:

| Command  | Inequality | Explanation |
| ------------- | ------------- |
| `je`  | `==` | `a - b == 0` |
| `jne`  | `~=` | `a - b != 0` |
| `jge`  | `>=` | `a - b >= 0` |
| `jg`  | `>` | `a - b > 0` |
| `jle`  | `<=` | `a - b <= 0` |
| `jl`  | `<` | `a - b < 0` |

## `example_if.s`

The first example is `example_if.s`. It has a global variable called `badger`
which is set to integer value 7. The `main()` function checks if the value of
`badger` is greater or less than zero, and has `printf()` statements based on
the value of `badger`. Since we know that `badger` is 7, it should display:

```shell
Badger is greater than zero!
```

The makefile target `example_if.s` will generate our assembly code. Make it if
you have not done this yet:

```shell
$ make example_if.s
gcc -Wall -O0 -S -o example_if.s example_if.c
```

and open the file in your favorite text editor. This code:

```asm
