/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv, (const void *)s, len, PTE_U | PTE_W | PTE_P);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console.
// Returns the character.
static int
sys_cgetc(void)
{
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
		/* do nothing */;

	return c;
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	
	// LAB 4: Your code here.
	struct Env *env;
	if (env_alloc(&env, curenv->env_id) < 0)
	{
		return -E_NO_FREE_ENV;
	}
	env->env_status = ENV_NOT_RUNNABLE;
	env->env_tf = curenv->env_tf;
	// amazing, set child's returned value to 0
	env->env_tf.tf_regs.reg_eax = 0;
	return env->env_id;

	//panic("sys_exofork not implemented");
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
  	// Hint: Use the 'envid2env' function from kern/env.c to translate an
  	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	
	// LAB 4: Your code here.
	// Set envid's env_status to status, which must be ENV_RUNNABLE
	// or ENV_NOT_RUNNABLE.
	// check status
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
	{
		return -E_INVAL;
	}
	struct Env *env;
	// check envid
	if (envid2env(envid, &env, 1) < 0)
	{
		return -E_BAD_ENV;
	}
	env->env_status = status;
	return 0;

	//panic("sys_env_set_status not implemented");
}

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3) with interrupts enabled.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 4: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	panic("sys_set_trapframe not implemented");
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// Set the page fault upcall for 'envid' by modifying the corresponding struct
	// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
	// kernel will push a fault record onto the exception stack, then branch to
	// 'func'.
	struct Env *env;
	// set envid2env's third argument to 1, which will check whether
	// the current environment has permission to set envid's status.
	if (envid2env(envid, &env, 1) < 0)
	{
		return -E_BAD_ENV;
	}
	env->env_pgfault_upcall = func;
	return 0;

	//panic("sys_env_set_pgfault_upcall not implemented");
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// Allocate a page of memory and map it at 'va' with permission
	// 'perm' in the address space of 'envid'.
	// PGOFF(va) = va & 0xfff, to check whether va is page-aligned
	if ((unsigned int)va >= UTOP || PGOFF(va) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
	{
		return -E_INVAL;
	}
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
	{
		return -E_BAD_ENV;
	}
	struct Page *pg;
	if (page_alloc(&pg) < 0)
	{
		return -E_NO_MEM;
	}
	// If page_insert() fails, remember to free the page you allocated!
	if (page_insert(env->env_pgdir, pg, va, perm) < 0)
	{
		// remember to use "page_decref" rather than
		// "page_free", as page cannot be freed until pg_ref = 0.
		page_decref(pg);
		return -E_NO_MEM;
	}
	// The page's contents are set to 0.
	// Remember "page2kva", ha?
	memset(page2kva(pg), 0, PGSIZE);
	return 0;

	//panic("sys_page_alloc not implemented");
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// Map the page of memory at 'srcva' in srcenvid's address space
	// at 'dstva' in dstenvid's address space with permission 'perm'.
	if ((unsigned int)srcva >= UTOP || PGOFF(srcva) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)
		|| (unsigned int)dstva >= UTOP || PGOFF(dstva) )
	{
		return -E_INVAL;
	}
	struct Env *srcenv, *dstenv;
	if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0)
	{
		return -E_BAD_ENV;
	}
	pte_t *pte_addr;
	struct Page *pg = page_lookup(srcenv->env_pgdir, srcva, &pte_addr);
	// find it in src address space
	if (pg == NULL)
	{
		return -E_INVAL;
	}
	// check extra perm
	if ((perm & PTE_W) && !(*pte_addr & PTE_W))
	{
		return -E_INVAL;
	}
	// map to dst address space
	if (page_insert(dstenv->env_pgdir, pg, dstva, perm) < 0)
	{
		return -E_NO_MEM;
	}
	return 0;

	//panic("sys_page_map not implemented");
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	
	// LAB 4: Your code here.
	// Unmap the page of memory at 'va' in the address space of 'envid'.
	if ((unsigned int)va >= UTOP || PGOFF(va))
	{
		return -E_INVAL;
	}
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
	{
		return -E_BAD_ENV;
	}
	page_remove(env->env_pgdir, va);
	return 0;

	//panic("sys_page_unmap not implemented");
}

// Try to send 'value' to the target env 'envid'.
// If va != 0, then also send page currently mapped at 'va',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target has not requested IPC with sys_ipc_recv.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused ipc_recv system call.
//
// If the sender sends a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc doesn't happen unless no errors occur.
//
// Returns 0 on success where no page mapping occurs,
// 1 on success where a page mapping occurs, and < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	panic("sys_ipc_try_send not implemented");
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	panic("sys_ipc_recv not implemented");
	return 0;
}


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno)
	{
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return (int32_t)sys_cgetc();
		case SYS_getenvid:
			return (int32_t)sys_getenvid();
		case SYS_env_destroy:
			return (int32_t)sys_env_destroy((envid_t)a1);
		case SYS_yield:
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t) a3, (void *)a4, (int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		default:	//NSYSCALLS means non-syscalls
			return -E_INVAL;
	}

	//panic("syscall not implemented");
}

