// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// faulting access was a write(FEC_WR means Page fault caused by a write)
	// and to a cow page
	if (!((err & FEC_WR) && (vpt[VPN(addr)] & PTE_COW)))
	{
		panic("fault at %x with pte %x from %08x, not copy-on-write", 
			addr, vpt[PPN(addr)], (&addr)[4]);
	}

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.
	
	// LAB 4: Your code here.
	// envid2env(0) refers to curenv rather than envs[0]
	// Allocate a new page, map it at a temporary location (PFTEMP)
	if ((r = sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_P | PTE_U)) < 0)
	{
		panic("sys_page_alloc: %e", r);
	}
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	memmove(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
	if ((r = sys_page_map(0, (void *)PFTEMP, 0,
		(void *)ROUNDDOWN(addr, PGSIZE), PTE_W | PTE_P | PTE_U)) < 0)
	{
		panic("sys_page_map: %e", r);
	}

	//panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why mark ours copy-on-write again
// if it was already copy-on-write?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
// 
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	void *addr;
	pte_t pte;

	// LAB 4: Your code here.
	// give an answer to the exercise first:
	// what if parent's is writeable and will be written soon?
	// so this method forces writable to cow
	if (vpt[pn] & (PTE_W | PTE_COW))
	{
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
			(void *)(pn*PGSIZE), PTE_U | PTE_P | PTE_COW)) < 0)
		{
			panic("sys_page_map: %e", r);
			return r;
		}
		// we can do this by calling pgdir_walk()
		// but we are not supposed to
		// as this is in user mode, we need to syscall
		// map the page to itself, add PTE_COW to its perm
		// page_insert() will unmap the existed then map again
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), 0,
			(void *)(pn*PGSIZE), PTE_U | PTE_P | PTE_COW)) < 0)
		{
			panic("sys_page_map: %e", r);
			return r;
		}
	}
	else
	{
		if ((r = sys_page_map(0, (void *)(pn*PGSIZE), envid,
			(void *)(pn*PGSIZE), PTE_U | PTE_P)) < 0)
		{
			panic("sys_page_map: %e", r);
			return r;
		}
	}

	//panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use vpd, vpt, and duppage.
//   Remember to fix "env" and the user exception stack in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	// Set up our page fault handler appropriately.
	// The parent sets the user page fault entrypoint for the child to look like its own.
	set_pgfault_handler(pgfault);
	int r;
	// Create a child.
	envid_t envid= sys_exofork();
	// error
	if (envid < 0)
	{
		panic("sys_exofork: %e", envid);
		return envid;
	}
	else if (envid == 0)
	{
		// child
		// fix env, do as in "dumbfork.c"
		// extern volatile struct Env *env;
		// We're the child.
		// The copied value of the global variable 'env'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		env = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else
	{
		// We are the parent
		// Copy our address space
		int i, j;
		for (i = 0; i*PTSIZE < UTOP; ++i)
		{
			// use vpd as a page
			if(((pte_t *)vpd)[i] & PTE_P)
			{
				// Travel the address space
				for (j = 0; j*PGSIZE+i*PTSIZE < UTOP && j < NPTENTRIES; ++j)
				{
					// Neither user exception stack should ever be marked copy-on-write,
					if(j*PGSIZE + i*PTSIZE == UXSTACKTOP-PGSIZE)
					{
						continue;
					}
					// Copy the address space to child
					pte_t pte = ((pte_t *)vpt)[i*NPTENTRIES+j];
					if((pte & PTE_P) && (pte & PTE_U))
					{
						if((r =duppage(envid, i*NPTENTRIES+j)) < 0)
						{
							panic("duppage: %e", r);
						}
					}
						
				}
			}
		}
		// alloc a new page for child's excp stack
		if((r = sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_P | PTE_U | PTE_W)) < 0)
		{
			panic("sys_page_alloc: %e", r);
		}
		extern void _pgfault_upcall(void);
		// set the child's page fault upcall routine
		if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
		{
			panic("sys_env_set_pgfault_upcall: %e", r);
		}
		// set child to be runnable
		if((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		{
			panic("sys_env_set_status: %e", r);
		}
		return envid;
	}

	//panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
