/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* The TRAPHANDLER macro defines a globally-visible function for handling
 * a trap.  It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 */ 
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(idt_divide_error, T_DIVIDE)
	TRAPHANDLER_NOEC(idt_debug_exception, T_DEBUG)
	TRAPHANDLER_NOEC(idt_nmi_interrupt, T_NMI)
	TRAPHANDLER_NOEC(idt_breakpoint, T_BRKPT)
	TRAPHANDLER_NOEC(idt_overflow, T_OFLOW)
	TRAPHANDLER_NOEC(idt_bound_check, T_BOUND)
	TRAPHANDLER_NOEC(idt_illegal_opcode, T_ILLOP)
	TRAPHANDLER_NOEC(idt_device_not_available, T_DEVICE)
	TRAPHANDLER(idt_double_fault, T_DBLFLT)

	TRAPHANDLER(idt_invalid_tss, T_TSS)
	TRAPHANDLER(idt_segment_not_present, T_SEGNP)
	TRAPHANDLER(idt_stack_exception, T_STACK)
	TRAPHANDLER(idt_general_protection_fault, T_GPFLT)
	TRAPHANDLER(idt_page_fault, T_PGFLT)

	TRAPHANDLER_NOEC(idt_floating_point_error, T_FPERR)
	TRAPHANDLER(idt_aligment_check, T_ALIGN)
	TRAPHANDLER_NOEC(idt_machine_check, T_MCHK)
	TRAPHANDLER_NOEC(idt_simd_floating_point_error, T_SIMDERR)
	TRAPHANDLER_NOEC(idt_system_call, T_SYSCALL)

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	/* push values to make the stack look like a struct Trapframe */
	pushl	%ds
	pushl	%es
	/* push all regs in */
	pushal

	/* load GD_KD into %ds and %es */
	/* notice that ds and es are 16 bits width */
	movl	$GD_KD,	%eax
	movw	%ax,	%ds
	movw	%ax,	%es

	/* pushl %esp to pass a pointer to the Trapframe
	as an argument to trap() and call trap() */
	pushl	%esp
	call trap

	/* pop the values pushed in steps 1-3 and iret*/
	popl	%esp
	popal
	popl	%es
	popl	%ds
	iret