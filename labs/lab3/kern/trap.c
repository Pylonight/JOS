#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>

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
	return "(unknown trap)";
}


void
idt_init(void)
{
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	extern void divide_error();
	extern void debug_exception();
	extern void nmi_interrupt();
	extern void breakpoint();
	extern void overflow();
	extern void bound_check();
	extern void illegal_opcode();
	extern void device_not_available();
	extern void double_fault();
	extern void invalid_tss();
	extern void segment_not_present();
	extern void stack_exception();
	extern void general_protection_fault();
	extern void page_fault();
	extern void floating_point_error();
	extern void aligment_check();
	extern void machine_check();
	extern void simd_floating_point_error();
	extern void system_call();

	// #define SETGATE(gate, istrap, sel, off, dpl)
	// gate: describes the info of gate, should be a struct.
	// istrap: 1 for excp, and 0 for intr.
	// sel: segment selector, should be 0x8 or GD_KT, kernel text.
	// off: offset in code segment for interrupt/trap handler,
	// which should be the handler function entry points.
	// dpl: Descriptor Privilege Level, will be compared with cpl
	SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_error, 0);
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_exception, 0);
	SETGATE(idt[T_NMI], 0, GD_KT, nmi_interrupt, 0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, breakpoint, 3);
	SETGATE(idt[T_OFLOW], 1, GD_KT, overflow, 3);
	SETGATE(idt[T_BOUND], 1, GD_KT, bound_check, 3);
	SETGATE(idt[T_ILLOP], 0, GD_KT, illegal_opcode, 0);
	SETGATE(idt[T_DEVICE], 0, GD_KT, device_not_available, 0);
	// I just cannot set the gate's type to 0101B, which states a task gate
	// Don't know why. May be modified later?
	SETGATE(idt[T_DBLFLT], 0, GD_KT, double_fault, 0);
	SETGATE(idt[T_TSS], 0, GD_KT, invalid_tss, 0);
	SETGATE(idt[T_SEGNP], 0, GD_KT, segment_not_present, 0);
	SETGATE(idt[T_STACK], 0, GD_KT, stack_exception, 0);
	SETGATE(idt[T_GPFLT], 1, GD_KT, general_protection_fault, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, page_fault, 0);
	SETGATE(idt[T_FPERR], 0, GD_KT, floating_point_error, 0);
	SETGATE(idt[T_ALIGN], 0, GD_KT, aligment_check, 0);
	SETGATE(idt[T_MCHK], 0, GD_KT, machine_check, 0);
	SETGATE(idt[T_SIMDERR], 0, GD_KT, simd_floating_point_error, 0);
	SETGATE(idt[T_SYSCALL], 1, GD_KT, system_call, 3);

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
			// arrange for the return value to be
			// passed back to the user process in %eax
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
				tf->tf_regs.reg_ecx, tf->tf_regs.reg_edx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_esi,
				tf->tf_regs.reg_edi);
			return;
	}

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
	cprintf("Incoming TRAP frame at %p\n", tf);

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

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
        env_run(curenv);
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

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

