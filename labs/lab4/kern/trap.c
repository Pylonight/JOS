#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>

static struct Taskstate ts;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = { { 0 } };
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Falt",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
}


void
idt_init(void)
{
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	extern void idt_divide_error();
	extern void idt_debug_exception();
	extern void idt_nmi_interrupt();
	// well, I originally call it "breakpoint()", but there should be an
	// implemented inline function under the same name in "inc/x86.h"
	extern void idt_breakpoint();
	extern void idt_overflow();
	extern void idt_bound_check();
	extern void idt_illegal_opcode();
	extern void idt_device_not_available();
	extern void idt_double_fault();
	extern void idt_invalid_tss();
	extern void idt_segment_not_present();
	extern void idt_stack_exception();
	extern void idt_general_protection_fault();
	extern void idt_page_fault();
	extern void idt_floating_point_error();
	extern void idt_aligment_check();
	extern void idt_machine_check();
	extern void idt_simd_floating_point_error();
	extern void idt_system_call();

	// #define SETGATE(gate, istrap, sel, off, dpl)
	// gate: describes the info of gate, should be a struct.
	// istrap: 1 for excp, and 0 for intr.
	// sel: segment selector, should be 0x8 or GD_KT, kernel text.
	// off: offset in code segment for interrupt/trap handler,
	// which should be the handler function entry points.
	// dpl: Descriptor Privilege Level, will be compared with cpl
	SETGATE(idt[T_DIVIDE], 0, GD_KT, idt_divide_error, 0);
	SETGATE(idt[T_DEBUG], 0, GD_KT, idt_debug_exception, 0);
	SETGATE(idt[T_NMI], 0, GD_KT, idt_nmi_interrupt, 0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, idt_breakpoint, 3);
	SETGATE(idt[T_OFLOW], 1, GD_KT, idt_overflow, 3);
	SETGATE(idt[T_BOUND], 1, GD_KT, idt_bound_check, 3);
	// SETGATE(idt[T_OFLOW], 0, GD_KT, idt_overflow, 0);
	// SETGATE(idt[T_BOUND], 0, GD_KT, idt_bound_check, 0);
	SETGATE(idt[T_ILLOP], 0, GD_KT, idt_illegal_opcode, 0);
	SETGATE(idt[T_DEVICE], 0, GD_KT, idt_device_not_available, 0);
	// I just cannot set the gate's type to 0101B, which states a task gate
	// Don't know why. May be modified later?
	SETGATE(idt[T_DBLFLT], 0, GD_KT, idt_double_fault, 0);
	SETGATE(idt[T_TSS], 0, GD_KT, idt_invalid_tss, 0);
	SETGATE(idt[T_SEGNP], 0, GD_KT, idt_segment_not_present, 0);
	SETGATE(idt[T_STACK], 0, GD_KT, idt_stack_exception, 0);
	SETGATE(idt[T_GPFLT], 1, GD_KT, idt_general_protection_fault, 0);
	// SETGATE(idt[T_GPFLT], 0, GD_KT, idt_general_protection_fault, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, idt_page_fault, 0);
	SETGATE(idt[T_FPERR], 0, GD_KT, idt_floating_point_error, 0);
	SETGATE(idt[T_ALIGN], 0, GD_KT, idt_aligment_check, 0);
	SETGATE(idt[T_MCHK], 0, GD_KT, idt_machine_check, 0);
	SETGATE(idt[T_SIMDERR], 0, GD_KT, idt_simd_floating_point_error, 0);
	SETGATE(idt[T_SYSCALL], 1, GD_KT, idt_system_call, 3);
	// SETGATE(idt[T_SYSCALL], 0, GD_KT, idt_system_call, 3);

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
	ts.ts_ss0 = GD_KD;

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	cprintf("  err  0x%08x\n", tf->tf_err);
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	cprintf("  esp  0x%08x\n", tf->tf_esp);
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno)
	{
		case T_PGFLT:
			// dispatch page fault exceptions to page_fault_handler()
			page_fault_handler(tf);
			return;
		case T_BRKPT:
			// invoke kernel monitor
			monitor(tf);
			return;
		case T_SYSCALL:
			// Generic system call: pass system call number in AX,
			// up to five parameters in DX, CX, BX, DI, SI.
			// Interrupt kernel with T_SYSCALL.
			// According to lib/syscall.c
			// Correct order or endless page fault
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
				tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi,
				tf->tf_regs.reg_esi);
			return;
	}
	
	// Handle clock and serial interrupts.
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		env_destroy(curenv);
		return;
	}
}

void
trap(struct Trapframe *tf)
{
	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
		env_run(curenv);
	else
		sched_yield();
}


void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
	{
        		panic("Page fault in kernel");  
		return;
	}

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// The trap handler needs one word of scratch space at the top of the
	// trap-time stack in order to return.  In the non-recursive case, we
	// don't have to worry about this because the top of the regular user
	// stack is free.  In the recursive case, this means we have to leave
	// an extra word between the current top of the exception stack and
	// the new stack frame because the exception stack _is_ the trap-time
	// stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack, or the exception stack overflows,
	// then destroy the environment that caused the fault.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall != NULL)
	{
		struct UTrapframe *utf;
		// when there is nested page fault, just push a blank word
		// into stack before pushing an UTrapframe.
		// When it is needed to check whether it is nested,
		// just check whether the crrent stack stands between
		// “UXSTACKTOP-PGSIZE” and “UXSTACKTOP-1”.
		// current stack means "esp"
		if ((unsigned int)tf->tf_esp >= UXSTACKTOP-PGSIZE
			&& (unsigned int)tf->tf_esp < UXSTACKTOP)
		{
			// nested page fault, a blank word needed to save esp to
			// switch recursively later to jump back to user code
			// without visiting kernel after page_fault_handler
			// see _pgfault_upcall
			utf = (struct UTrapframe *)(tf->tf_esp-sizeof(struct UTrapframe)-4);
		}
		else
		{
			// the first page fault
			utf = (struct UTrapframe *)(UXSTACKTOP-sizeof(struct UTrapframe));
		}
		// set up page fault stack frame on user excp stack
		// Read processor's CR2 register to find the faulting address
		// fault_va = rcr2();
		utf->utf_fault_va = fault_va;
		utf->utf_err = tf->tf_err;
		utf->utf_regs = tf->tf_regs;
		utf->utf_eip = tf->tf_eip;
		utf->utf_eflags = tf->tf_eflags;
		utf->utf_esp = tf->tf_esp;
		//  To change what the user environment runs, modify 'curenv->env_tf'
		//  (the 'tf' variable points at 'curenv->env_tf').
		// Well, then why should we set such an argument?
		// eip points to the next ins
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
		// to start executing on user excp stack
		tf->tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

