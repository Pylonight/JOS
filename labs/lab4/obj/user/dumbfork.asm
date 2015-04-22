
obj/user/dumbfork:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2f 02 00 00       	call   800260 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 32 0e 00 00       	call   800e88 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 00 14 80 	movl   $0x801400,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  800075:	e8 4a 02 00 00       	call   8002c4 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 49 0e 00 00       	call   800ee7 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 23 14 80 	movl   $0x801423,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  8000bd:	e8 02 02 00 00       	call   8002c4 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 c0 0a 00 00       	call   800b9a <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 57 0e 00 00       	call   800f45 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  80010d:	e8 b2 01 00 00       	call   8002c4 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
static __inline envid_t sys_exofork(void) __attribute__((always_inline));
static __inline envid_t
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	cprintf("fuck %d\n", envid);
  80012e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800132:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  800139:	e8 8d 02 00 00       	call   8003cb <cprintf>
	if (envid < 0)
  80013e:	85 f6                	test   %esi,%esi
  800140:	79 20                	jns    800162 <dumbfork+0x49>
		panic("sys_exofork: %e", envid);
  800142:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800146:	c7 44 24 08 50 14 80 	movl   $0x801450,0x8(%esp)
  80014d:	00 
  80014e:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800155:	00 
  800156:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  80015d:	e8 62 01 00 00       	call   8002c4 <_panic>
	if (envid == 0) {
  800162:	85 f6                	test   %esi,%esi
  800164:	75 19                	jne    80017f <dumbfork+0x66>
		// We're the child.
		// The copied value of the global variable 'env'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		env = &envs[ENVX(sys_getenvid())];
  800166:	e8 bd 0c 00 00       	call   800e28 <sys_getenvid>
  80016b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800170:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800173:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800178:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80017d:	eb 7e                	jmp    8001fd <dumbfork+0xe4>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80017f:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800186:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80018b:	3d 00 00 80 00       	cmp    $0x800000,%eax
  800190:	76 23                	jbe    8001b5 <dumbfork+0x9c>
  800192:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019b:	89 1c 24             	mov    %ebx,(%esp)
  80019e:	e8 91 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8001a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001a6:	05 00 10 00 00       	add    $0x1000,%eax
  8001ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001ae:	3d 0c 20 80 00       	cmp    $0x80200c,%eax
  8001b3:	72 e2                	jb     800197 <dumbfork+0x7e>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	89 34 24             	mov    %esi,(%esp)
  8001c4:	e8 6b fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001d0:	00 
  8001d1:	89 34 24             	mov    %esi,(%esp)
  8001d4:	e8 ca 0d 00 00       	call   800fa3 <sys_env_set_status>
  8001d9:	85 c0                	test   %eax,%eax
  8001db:	79 20                	jns    8001fd <dumbfork+0xe4>
		panic("sys_env_set_status: %e", r);
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	c7 44 24 08 60 14 80 	movl   $0x801460,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 13 14 80 00 	movl   $0x801413,(%esp)
  8001f8:	e8 c7 00 00 00       	call   8002c4 <_panic>

	return envid;
}
  8001fd:	89 f0                	mov    %esi,%eax
  8001ff:	83 c4 20             	add    $0x20,%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <umain>:

envid_t dumbfork(void);

void
umain(void)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80020f:	e8 05 ff ff ff       	call   800119 <dumbfork>
  800214:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800216:	be 00 00 00 00       	mov    $0x0,%esi
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80021b:	bf 7e 14 80 00       	mov    $0x80147e,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800220:	eb 26                	jmp    800248 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800222:	85 db                	test   %ebx,%ebx
  800224:	b8 77 14 80 00       	mov    $0x801477,%eax
  800229:	0f 44 c7             	cmove  %edi,%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	89 74 24 04          	mov    %esi,0x4(%esp)
  800234:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  80023b:	e8 8b 01 00 00       	call   8003cb <cprintf>
		sys_yield();
  800240:	e8 13 0c 00 00       	call   800e58 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800245:	83 c6 01             	add    $0x1,%esi
  800248:	83 fb 01             	cmp    $0x1,%ebx
  80024b:	19 c0                	sbb    %eax,%eax
  80024d:	83 e0 0a             	and    $0xa,%eax
  800250:	83 c0 0a             	add    $0xa,%eax
  800253:	39 c6                	cmp    %eax,%esi
  800255:	7c cb                	jl     800222 <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800257:	83 c4 1c             	add    $0x1c,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    
	...

00800260 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 18             	sub    $0x18,%esp
  800266:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800269:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80026c:	8b 75 08             	mov    0x8(%ebp),%esi
  80026f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  800272:	e8 b1 0b 00 00       	call   800e28 <sys_getenvid>
  800277:	25 ff 03 00 00       	and    $0x3ff,%eax
  80027c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80027f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800284:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800289:	85 f6                	test   %esi,%esi
  80028b:	7e 07                	jle    800294 <libmain+0x34>
		binaryname = argv[0];
  80028d:	8b 03                	mov    (%ebx),%eax
  80028f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800294:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800298:	89 34 24             	mov    %esi,(%esp)
  80029b:	e8 66 ff ff ff       	call   800206 <umain>

	// exit gracefully
	exit();
  8002a0:	e8 0b 00 00 00       	call   8002b0 <exit>
}
  8002a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002ab:	89 ec                	mov    %ebp,%esp
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    
	...

008002b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002bd:	e8 09 0b 00 00       	call   800dcb <sys_env_destroy>
}
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8002ca:	a1 08 20 80 00       	mov    0x802008,%eax
  8002cf:	85 c0                	test   %eax,%eax
  8002d1:	74 10                	je     8002e3 <_panic+0x1f>
		cprintf("%s: ", argv0);
  8002d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d7:	c7 04 24 ad 14 80 00 	movl   $0x8014ad,(%esp)
  8002de:	e8 e8 00 00 00       	call   8003cb <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f1:	a1 00 20 80 00       	mov    0x802000,%eax
  8002f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fa:	c7 04 24 b2 14 80 00 	movl   $0x8014b2,(%esp)
  800301:	e8 c5 00 00 00       	call   8003cb <cprintf>
	vcprintf(fmt, ap);
  800306:	8d 45 14             	lea    0x14(%ebp),%eax
  800309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030d:	8b 45 10             	mov    0x10(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 52 00 00 00       	call   80036a <vcprintf>
	cprintf("\n");
  800318:	c7 04 24 94 14 80 00 	movl   $0x801494,(%esp)
  80031f:	e8 a7 00 00 00       	call   8003cb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800324:	cc                   	int3   
  800325:	eb fd                	jmp    800324 <_panic+0x60>
	...

00800328 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	53                   	push   %ebx
  80032c:	83 ec 14             	sub    $0x14,%esp
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800332:	8b 03                	mov    (%ebx),%eax
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80033b:	83 c0 01             	add    $0x1,%eax
  80033e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800340:	3d ff 00 00 00       	cmp    $0xff,%eax
  800345:	75 19                	jne    800360 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800347:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80034e:	00 
  80034f:	8d 43 08             	lea    0x8(%ebx),%eax
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	e8 12 0a 00 00       	call   800d6c <sys_cputs>
		b->idx = 0;
  80035a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800360:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800364:	83 c4 14             	add    $0x14,%esp
  800367:	5b                   	pop    %ebx
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800373:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80037a:	00 00 00 
	b.cnt = 0;
  80037d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800384:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800387:	8b 45 0c             	mov    0xc(%ebp),%eax
  80038a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	89 44 24 08          	mov    %eax,0x8(%esp)
  800395:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80039b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039f:	c7 04 24 28 03 80 00 	movl   $0x800328,(%esp)
  8003a6:	e8 d9 01 00 00       	call   800584 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ab:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003bb:	89 04 24             	mov    %eax,(%esp)
  8003be:	e8 a9 09 00 00       	call   800d6c <sys_cputs>

	return b.cnt;
}
  8003c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8003d1:	8d 45 0c             	lea    0xc(%ebp),%eax
  8003d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	e8 87 ff ff ff       	call   80036a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    
	...

008003f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 3c             	sub    $0x3c,%esp
  8003f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fc:	89 d7                	mov    %edx,%edi
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800404:	8b 45 0c             	mov    0xc(%ebp),%eax
  800407:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80040d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800410:	b8 00 00 00 00       	mov    $0x0,%eax
  800415:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800418:	72 11                	jb     80042b <printnum+0x3b>
  80041a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800420:	76 09                	jbe    80042b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800422:	83 eb 01             	sub    $0x1,%ebx
  800425:	85 db                	test   %ebx,%ebx
  800427:	7f 51                	jg     80047a <printnum+0x8a>
  800429:	eb 5e                	jmp    800489 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80042f:	83 eb 01             	sub    $0x1,%ebx
  800432:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800436:	8b 45 10             	mov    0x10(%ebp),%eax
  800439:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800441:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800445:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044c:	00 
  80044d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045a:	e8 f1 0c 00 00       	call   801150 <__udivdi3>
  80045f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800463:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80046e:	89 fa                	mov    %edi,%edx
  800470:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800473:	e8 78 ff ff ff       	call   8003f0 <printnum>
  800478:	eb 0f                	jmp    800489 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80047e:	89 34 24             	mov    %esi,(%esp)
  800481:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800484:	83 eb 01             	sub    $0x1,%ebx
  800487:	75 f1                	jne    80047a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800489:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800491:	8b 45 10             	mov    0x10(%ebp),%eax
  800494:	89 44 24 08          	mov    %eax,0x8(%esp)
  800498:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80049f:	00 
  8004a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ad:	e8 ce 0d 00 00       	call   801280 <__umoddi3>
  8004b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b6:	0f be 80 ce 14 80 00 	movsbl 0x8014ce(%eax),%eax
  8004bd:	89 04 24             	mov    %eax,(%esp)
  8004c0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004c3:	83 c4 3c             	add    $0x3c,%esp
  8004c6:	5b                   	pop    %ebx
  8004c7:	5e                   	pop    %esi
  8004c8:	5f                   	pop    %edi
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ce:	83 fa 01             	cmp    $0x1,%edx
  8004d1:	7e 0e                	jle    8004e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d8:	89 08                	mov    %ecx,(%eax)
  8004da:	8b 02                	mov    (%edx),%eax
  8004dc:	8b 52 04             	mov    0x4(%edx),%edx
  8004df:	eb 22                	jmp    800503 <getuint+0x38>
	else if (lflag)
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	74 10                	je     8004f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ea:	89 08                	mov    %ecx,(%eax)
  8004ec:	8b 02                	mov    (%edx),%eax
  8004ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f3:	eb 0e                	jmp    800503 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f5:	8b 10                	mov    (%eax),%edx
  8004f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004fa:	89 08                	mov    %ecx,(%eax)
  8004fc:	8b 02                	mov    (%edx),%eax
  8004fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800508:	83 fa 01             	cmp    $0x1,%edx
  80050b:	7e 0e                	jle    80051b <getint+0x16>
		return va_arg(*ap, long long);
  80050d:	8b 10                	mov    (%eax),%edx
  80050f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800512:	89 08                	mov    %ecx,(%eax)
  800514:	8b 02                	mov    (%edx),%eax
  800516:	8b 52 04             	mov    0x4(%edx),%edx
  800519:	eb 22                	jmp    80053d <getint+0x38>
	else if (lflag)
  80051b:	85 d2                	test   %edx,%edx
  80051d:	74 10                	je     80052f <getint+0x2a>
		return va_arg(*ap, long);
  80051f:	8b 10                	mov    (%eax),%edx
  800521:	8d 4a 04             	lea    0x4(%edx),%ecx
  800524:	89 08                	mov    %ecx,(%eax)
  800526:	8b 02                	mov    (%edx),%eax
  800528:	89 c2                	mov    %eax,%edx
  80052a:	c1 fa 1f             	sar    $0x1f,%edx
  80052d:	eb 0e                	jmp    80053d <getint+0x38>
	else
		return va_arg(*ap, int);
  80052f:	8b 10                	mov    (%eax),%edx
  800531:	8d 4a 04             	lea    0x4(%edx),%ecx
  800534:	89 08                	mov    %ecx,(%eax)
  800536:	8b 02                	mov    (%edx),%eax
  800538:	89 c2                	mov    %eax,%edx
  80053a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80053d:	5d                   	pop    %ebp
  80053e:	c3                   	ret    

0080053f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800545:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800549:	8b 10                	mov    (%eax),%edx
  80054b:	3b 50 04             	cmp    0x4(%eax),%edx
  80054e:	73 0a                	jae    80055a <sprintputch+0x1b>
		*b->buf++ = ch;
  800550:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800553:	88 0a                	mov    %cl,(%edx)
  800555:	83 c2 01             	add    $0x1,%edx
  800558:	89 10                	mov    %edx,(%eax)
}
  80055a:	5d                   	pop    %ebp
  80055b:	c3                   	ret    

0080055c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800562:	8d 45 14             	lea    0x14(%ebp),%eax
  800565:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800569:	8b 45 10             	mov    0x10(%ebp),%eax
  80056c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800570:	8b 45 0c             	mov    0xc(%ebp),%eax
  800573:	89 44 24 04          	mov    %eax,0x4(%esp)
  800577:	8b 45 08             	mov    0x8(%ebp),%eax
  80057a:	89 04 24             	mov    %eax,(%esp)
  80057d:	e8 02 00 00 00       	call   800584 <vprintfmt>
	va_end(ap);
}
  800582:	c9                   	leave  
  800583:	c3                   	ret    

00800584 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	57                   	push   %edi
  800588:	56                   	push   %esi
  800589:	53                   	push   %ebx
  80058a:	83 ec 4c             	sub    $0x4c,%esp
  80058d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800590:	8b 75 10             	mov    0x10(%ebp),%esi
  800593:	eb 12                	jmp    8005a7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800595:	85 c0                	test   %eax,%eax
  800597:	0f 84 98 03 00 00    	je     800935 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80059d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a1:	89 04 24             	mov    %eax,(%esp)
  8005a4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a7:	0f b6 06             	movzbl (%esi),%eax
  8005aa:	83 c6 01             	add    $0x1,%esi
  8005ad:	83 f8 25             	cmp    $0x25,%eax
  8005b0:	75 e3                	jne    800595 <vprintfmt+0x11>
  8005b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d1:	eb 2b                	jmp    8005fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005da:	eb 22                	jmp    8005fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005df:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005e3:	eb 19                	jmp    8005fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005ef:	eb 0d                	jmp    8005fe <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	0f b6 06             	movzbl (%esi),%eax
  800601:	0f b6 d0             	movzbl %al,%edx
  800604:	8d 7e 01             	lea    0x1(%esi),%edi
  800607:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80060a:	83 e8 23             	sub    $0x23,%eax
  80060d:	3c 55                	cmp    $0x55,%al
  80060f:	0f 87 fa 02 00 00    	ja     80090f <vprintfmt+0x38b>
  800615:	0f b6 c0             	movzbl %al,%eax
  800618:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80061f:	83 ea 30             	sub    $0x30,%edx
  800622:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800625:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800629:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80062f:	83 fa 09             	cmp    $0x9,%edx
  800632:	77 4a                	ja     80067e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800637:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80063a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80063d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800641:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800644:	8d 50 d0             	lea    -0x30(%eax),%edx
  800647:	83 fa 09             	cmp    $0x9,%edx
  80064a:	76 eb                	jbe    800637 <vprintfmt+0xb3>
  80064c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80064f:	eb 2d                	jmp    80067e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800662:	eb 1a                	jmp    80067e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066b:	79 91                	jns    8005fe <vprintfmt+0x7a>
  80066d:	e9 73 ff ff ff       	jmp    8005e5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800675:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80067c:	eb 80                	jmp    8005fe <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80067e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800682:	0f 89 76 ff ff ff    	jns    8005fe <vprintfmt+0x7a>
  800688:	e9 64 ff ff ff       	jmp    8005f1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80068d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800693:	e9 66 ff ff ff       	jmp    8005fe <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	89 04 24             	mov    %eax,(%esp)
  8006aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006b0:	e9 f2 fe ff ff       	jmp    8005a7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 50 04             	lea    0x4(%eax),%edx
  8006bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006be:	8b 00                	mov    (%eax),%eax
  8006c0:	89 c2                	mov    %eax,%edx
  8006c2:	c1 fa 1f             	sar    $0x1f,%edx
  8006c5:	31 d0                	xor    %edx,%eax
  8006c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8006c9:	83 f8 08             	cmp    $0x8,%eax
  8006cc:	7f 0b                	jg     8006d9 <vprintfmt+0x155>
  8006ce:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  8006d5:	85 d2                	test   %edx,%edx
  8006d7:	75 23                	jne    8006fc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8006d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006dd:	c7 44 24 08 e6 14 80 	movl   $0x8014e6,0x8(%esp)
  8006e4:	00 
  8006e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ec:	89 3c 24             	mov    %edi,(%esp)
  8006ef:	e8 68 fe ff ff       	call   80055c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006f7:	e9 ab fe ff ff       	jmp    8005a7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800700:	c7 44 24 08 ef 14 80 	movl   $0x8014ef,0x8(%esp)
  800707:	00 
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070f:	89 3c 24             	mov    %edi,(%esp)
  800712:	e8 45 fe ff ff       	call   80055c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800717:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80071a:	e9 88 fe ff ff       	jmp    8005a7 <vprintfmt+0x23>
  80071f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800725:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8d 50 04             	lea    0x4(%eax),%edx
  80072e:	89 55 14             	mov    %edx,0x14(%ebp)
  800731:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800733:	85 f6                	test   %esi,%esi
  800735:	ba df 14 80 00       	mov    $0x8014df,%edx
  80073a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80073d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800741:	7e 06                	jle    800749 <vprintfmt+0x1c5>
  800743:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800747:	75 10                	jne    800759 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800749:	0f be 06             	movsbl (%esi),%eax
  80074c:	83 c6 01             	add    $0x1,%esi
  80074f:	85 c0                	test   %eax,%eax
  800751:	0f 85 86 00 00 00    	jne    8007dd <vprintfmt+0x259>
  800757:	eb 76                	jmp    8007cf <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800759:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075d:	89 34 24             	mov    %esi,(%esp)
  800760:	e8 76 02 00 00       	call   8009db <strnlen>
  800765:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800768:	29 c2                	sub    %eax,%edx
  80076a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80076d:	85 d2                	test   %edx,%edx
  80076f:	7e d8                	jle    800749 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800771:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800775:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800778:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80077b:	89 d6                	mov    %edx,%esi
  80077d:	89 c7                	mov    %eax,%edi
  80077f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800783:	89 3c 24             	mov    %edi,(%esp)
  800786:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800789:	83 ee 01             	sub    $0x1,%esi
  80078c:	75 f1                	jne    80077f <vprintfmt+0x1fb>
  80078e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800791:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800794:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800797:	eb b0                	jmp    800749 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800799:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80079d:	74 18                	je     8007b7 <vprintfmt+0x233>
  80079f:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007a2:	83 fa 5e             	cmp    $0x5e,%edx
  8007a5:	76 10                	jbe    8007b7 <vprintfmt+0x233>
					putch('?', putdat);
  8007a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ab:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007b2:	ff 55 08             	call   *0x8(%ebp)
  8007b5:	eb 0a                	jmp    8007c1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8007b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8007c5:	0f be 06             	movsbl (%esi),%eax
  8007c8:	83 c6 01             	add    $0x1,%esi
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	75 0e                	jne    8007dd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d6:	7f 11                	jg     8007e9 <vprintfmt+0x265>
  8007d8:	e9 ca fd ff ff       	jmp    8005a7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007dd:	85 ff                	test   %edi,%edi
  8007df:	90                   	nop
  8007e0:	78 b7                	js     800799 <vprintfmt+0x215>
  8007e2:	83 ef 01             	sub    $0x1,%edi
  8007e5:	79 b2                	jns    800799 <vprintfmt+0x215>
  8007e7:	eb e6                	jmp    8007cf <vprintfmt+0x24b>
  8007e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8007ec:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007fa:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007fc:	83 ee 01             	sub    $0x1,%esi
  8007ff:	75 ee                	jne    8007ef <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800801:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800804:	e9 9e fd ff ff       	jmp    8005a7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800809:	89 ca                	mov    %ecx,%edx
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
  80080e:	e8 f2 fc ff ff       	call   800505 <getint>
  800813:	89 c6                	mov    %eax,%esi
  800815:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800817:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081c:	85 d2                	test   %edx,%edx
  80081e:	0f 89 ad 00 00 00    	jns    8008d1 <vprintfmt+0x34d>
				putch('-', putdat);
  800824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800828:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80082f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800832:	f7 de                	neg    %esi
  800834:	83 d7 00             	adc    $0x0,%edi
  800837:	f7 df                	neg    %edi
			}
			base = 10;
  800839:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083e:	e9 8e 00 00 00       	jmp    8008d1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800843:	89 ca                	mov    %ecx,%edx
  800845:	8d 45 14             	lea    0x14(%ebp),%eax
  800848:	e8 7e fc ff ff       	call   8004cb <getuint>
  80084d:	89 c6                	mov    %eax,%esi
  80084f:	89 d7                	mov    %edx,%edi
			base = 10;
  800851:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800856:	eb 79                	jmp    8008d1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800858:	89 ca                	mov    %ecx,%edx
  80085a:	8d 45 14             	lea    0x14(%ebp),%eax
  80085d:	e8 a3 fc ff ff       	call   800505 <getint>
  800862:	89 c6                	mov    %eax,%esi
  800864:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800866:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80086b:	85 d2                	test   %edx,%edx
  80086d:	79 62                	jns    8008d1 <vprintfmt+0x34d>
				putch('-', putdat);
  80086f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800873:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80087a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80087d:	f7 de                	neg    %esi
  80087f:	83 d7 00             	adc    $0x0,%edi
  800882:	f7 df                	neg    %edi
			}
			base = 8;
  800884:	b8 08 00 00 00       	mov    $0x8,%eax
  800889:	eb 46                	jmp    8008d1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80088b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800896:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800899:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008a4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008aa:	8d 50 04             	lea    0x4(%eax),%edx
  8008ad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008b0:	8b 30                	mov    (%eax),%esi
  8008b2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008bc:	eb 13                	jmp    8008d1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008be:	89 ca                	mov    %ecx,%edx
  8008c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c3:	e8 03 fc ff ff       	call   8004cb <getuint>
  8008c8:	89 c6                	mov    %eax,%esi
  8008ca:	89 d7                	mov    %edx,%edi
			base = 16;
  8008cc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e4:	89 34 24             	mov    %esi,(%esp)
  8008e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008eb:	89 da                	mov    %ebx,%edx
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	e8 fb fa ff ff       	call   8003f0 <printnum>
			break;
  8008f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008f8:	e9 aa fc ff ff       	jmp    8005a7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800901:	89 14 24             	mov    %edx,(%esp)
  800904:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800907:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80090a:	e9 98 fc ff ff       	jmp    8005a7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800913:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80091a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80091d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800921:	0f 84 80 fc ff ff    	je     8005a7 <vprintfmt+0x23>
  800927:	83 ee 01             	sub    $0x1,%esi
  80092a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80092e:	75 f7                	jne    800927 <vprintfmt+0x3a3>
  800930:	e9 72 fc ff ff       	jmp    8005a7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800935:	83 c4 4c             	add    $0x4c,%esp
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5f                   	pop    %edi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	83 ec 28             	sub    $0x28,%esp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800949:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800950:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800953:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80095a:	85 c0                	test   %eax,%eax
  80095c:	74 30                	je     80098e <vsnprintf+0x51>
  80095e:	85 d2                	test   %edx,%edx
  800960:	7e 2c                	jle    80098e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800969:	8b 45 10             	mov    0x10(%ebp),%eax
  80096c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800970:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800973:	89 44 24 04          	mov    %eax,0x4(%esp)
  800977:	c7 04 24 3f 05 80 00 	movl   $0x80053f,(%esp)
  80097e:	e8 01 fc ff ff       	call   800584 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800983:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800986:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800989:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098c:	eb 05                	jmp    800993 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80098e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80099b:	8d 45 14             	lea    0x14(%ebp),%eax
  80099e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	e8 82 ff ff ff       	call   80093d <vsnprintf>
	va_end(ap);

	return rc;
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    
  8009bd:	00 00                	add    %al,(%eax)
	...

008009c0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009ce:	74 09                	je     8009d9 <strlen+0x19>
		n++;
  8009d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d7:	75 f7                	jne    8009d0 <strlen+0x10>
		n++;
	return n;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	85 c9                	test   %ecx,%ecx
  8009ec:	74 1a                	je     800a08 <strnlen+0x2d>
  8009ee:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009f1:	74 15                	je     800a08 <strnlen+0x2d>
  8009f3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009f8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fa:	39 ca                	cmp    %ecx,%edx
  8009fc:	74 0a                	je     800a08 <strnlen+0x2d>
  8009fe:	83 c2 01             	add    $0x1,%edx
  800a01:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a06:	75 f0                	jne    8009f8 <strnlen+0x1d>
		n++;
	return n;
}
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a1e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a21:	83 c2 01             	add    $0x1,%edx
  800a24:	84 c9                	test   %cl,%cl
  800a26:	75 f2                	jne    800a1a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a28:	5b                   	pop    %ebx
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a36:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a39:	85 f6                	test   %esi,%esi
  800a3b:	74 18                	je     800a55 <strncpy+0x2a>
  800a3d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a42:	0f b6 1a             	movzbl (%edx),%ebx
  800a45:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a48:	80 3a 01             	cmpb   $0x1,(%edx)
  800a4b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a4e:	83 c1 01             	add    $0x1,%ecx
  800a51:	39 f1                	cmp    %esi,%ecx
  800a53:	75 ed                	jne    800a42 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a65:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a68:	89 f8                	mov    %edi,%eax
  800a6a:	85 f6                	test   %esi,%esi
  800a6c:	74 2b                	je     800a99 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800a6e:	83 fe 01             	cmp    $0x1,%esi
  800a71:	74 23                	je     800a96 <strlcpy+0x3d>
  800a73:	0f b6 0b             	movzbl (%ebx),%ecx
  800a76:	84 c9                	test   %cl,%cl
  800a78:	74 1c                	je     800a96 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800a7a:	83 ee 02             	sub    $0x2,%esi
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a82:	88 08                	mov    %cl,(%eax)
  800a84:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a87:	39 f2                	cmp    %esi,%edx
  800a89:	74 0b                	je     800a96 <strlcpy+0x3d>
  800a8b:	83 c2 01             	add    $0x1,%edx
  800a8e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a92:	84 c9                	test   %cl,%cl
  800a94:	75 ec                	jne    800a82 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800a96:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a99:	29 f8                	sub    %edi,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa9:	0f b6 01             	movzbl (%ecx),%eax
  800aac:	84 c0                	test   %al,%al
  800aae:	74 16                	je     800ac6 <strcmp+0x26>
  800ab0:	3a 02                	cmp    (%edx),%al
  800ab2:	75 12                	jne    800ac6 <strcmp+0x26>
		p++, q++;
  800ab4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ab7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800abb:	84 c0                	test   %al,%al
  800abd:	74 07                	je     800ac6 <strcmp+0x26>
  800abf:	83 c1 01             	add    $0x1,%ecx
  800ac2:	3a 02                	cmp    (%edx),%al
  800ac4:	74 ee                	je     800ab4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac6:	0f b6 c0             	movzbl %al,%eax
  800ac9:	0f b6 12             	movzbl (%edx),%edx
  800acc:	29 d0                	sub    %edx,%eax
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ada:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ae2:	85 d2                	test   %edx,%edx
  800ae4:	74 28                	je     800b0e <strncmp+0x3e>
  800ae6:	0f b6 01             	movzbl (%ecx),%eax
  800ae9:	84 c0                	test   %al,%al
  800aeb:	74 24                	je     800b11 <strncmp+0x41>
  800aed:	3a 03                	cmp    (%ebx),%al
  800aef:	75 20                	jne    800b11 <strncmp+0x41>
  800af1:	83 ea 01             	sub    $0x1,%edx
  800af4:	74 13                	je     800b09 <strncmp+0x39>
		n--, p++, q++;
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800afc:	0f b6 01             	movzbl (%ecx),%eax
  800aff:	84 c0                	test   %al,%al
  800b01:	74 0e                	je     800b11 <strncmp+0x41>
  800b03:	3a 03                	cmp    (%ebx),%al
  800b05:	74 ea                	je     800af1 <strncmp+0x21>
  800b07:	eb 08                	jmp    800b11 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b11:	0f b6 01             	movzbl (%ecx),%eax
  800b14:	0f b6 13             	movzbl (%ebx),%edx
  800b17:	29 d0                	sub    %edx,%eax
  800b19:	eb f3                	jmp    800b0e <strncmp+0x3e>

00800b1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b25:	0f b6 10             	movzbl (%eax),%edx
  800b28:	84 d2                	test   %dl,%dl
  800b2a:	74 1c                	je     800b48 <strchr+0x2d>
		if (*s == c)
  800b2c:	38 ca                	cmp    %cl,%dl
  800b2e:	75 09                	jne    800b39 <strchr+0x1e>
  800b30:	eb 1b                	jmp    800b4d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b32:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800b35:	38 ca                	cmp    %cl,%dl
  800b37:	74 14                	je     800b4d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b39:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800b3d:	84 d2                	test   %dl,%dl
  800b3f:	75 f1                	jne    800b32 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	eb 05                	jmp    800b4d <strchr+0x32>
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b59:	0f b6 10             	movzbl (%eax),%edx
  800b5c:	84 d2                	test   %dl,%dl
  800b5e:	74 14                	je     800b74 <strfind+0x25>
		if (*s == c)
  800b60:	38 ca                	cmp    %cl,%dl
  800b62:	75 06                	jne    800b6a <strfind+0x1b>
  800b64:	eb 0e                	jmp    800b74 <strfind+0x25>
  800b66:	38 ca                	cmp    %cl,%dl
  800b68:	74 0a                	je     800b74 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	84 d2                	test   %dl,%dl
  800b72:	75 f2                	jne    800b66 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	53                   	push   %ebx
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b83:	89 da                	mov    %ebx,%edx
  800b85:	83 ea 01             	sub    $0x1,%edx
  800b88:	78 0d                	js     800b97 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800b8a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800b8c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800b8e:	88 0a                	mov    %cl,(%edx)
  800b90:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b93:	39 da                	cmp    %ebx,%edx
  800b95:	75 f7                	jne    800b8e <memset+0x18>
		*p++ = c;

	return v;
}
  800b97:	5b                   	pop    %ebx
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba9:	39 c6                	cmp    %eax,%esi
  800bab:	72 0b                	jb     800bb8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	85 db                	test   %ebx,%ebx
  800bb4:	75 29                	jne    800bdf <memmove+0x45>
  800bb6:	eb 35                	jmp    800bed <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800bbb:	39 c8                	cmp    %ecx,%eax
  800bbd:	73 ee                	jae    800bad <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800bbf:	85 db                	test   %ebx,%ebx
  800bc1:	74 2a                	je     800bed <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800bc3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800bc6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800bc8:	f7 db                	neg    %ebx
  800bca:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800bcd:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800bcf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800bd4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800bd8:	83 ea 01             	sub    $0x1,%edx
  800bdb:	75 f2                	jne    800bcf <memmove+0x35>
  800bdd:	eb 0e                	jmp    800bed <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800bdf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800be3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800be6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800be9:	39 d3                	cmp    %edx,%ebx
  800beb:	75 f2                	jne    800bdf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bf8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
  800c09:	89 04 24             	mov    %eax,(%esp)
  800c0c:	e8 89 ff ff ff       	call   800b9a <memmove>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	57                   	push   %edi
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c27:	85 ff                	test   %edi,%edi
  800c29:	74 37                	je     800c62 <memcmp+0x4f>
		if (*s1 != *s2)
  800c2b:	0f b6 03             	movzbl (%ebx),%eax
  800c2e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c31:	83 ef 01             	sub    $0x1,%edi
  800c34:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800c39:	38 c8                	cmp    %cl,%al
  800c3b:	74 1c                	je     800c59 <memcmp+0x46>
  800c3d:	eb 10                	jmp    800c4f <memcmp+0x3c>
  800c3f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800c44:	83 c2 01             	add    $0x1,%edx
  800c47:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800c4b:	38 c8                	cmp    %cl,%al
  800c4d:	74 0a                	je     800c59 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800c4f:	0f b6 c0             	movzbl %al,%eax
  800c52:	0f b6 c9             	movzbl %cl,%ecx
  800c55:	29 c8                	sub    %ecx,%eax
  800c57:	eb 09                	jmp    800c62 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c59:	39 fa                	cmp    %edi,%edx
  800c5b:	75 e2                	jne    800c3f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c72:	39 d0                	cmp    %edx,%eax
  800c74:	73 15                	jae    800c8b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c76:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c7a:	38 08                	cmp    %cl,(%eax)
  800c7c:	75 06                	jne    800c84 <memfind+0x1d>
  800c7e:	eb 0b                	jmp    800c8b <memfind+0x24>
  800c80:	38 08                	cmp    %cl,(%eax)
  800c82:	74 07                	je     800c8b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c84:	83 c0 01             	add    $0x1,%eax
  800c87:	39 d0                	cmp    %edx,%eax
  800c89:	75 f5                	jne    800c80 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c99:	0f b6 02             	movzbl (%edx),%eax
  800c9c:	3c 20                	cmp    $0x20,%al
  800c9e:	74 04                	je     800ca4 <strtol+0x17>
  800ca0:	3c 09                	cmp    $0x9,%al
  800ca2:	75 0e                	jne    800cb2 <strtol+0x25>
		s++;
  800ca4:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca7:	0f b6 02             	movzbl (%edx),%eax
  800caa:	3c 20                	cmp    $0x20,%al
  800cac:	74 f6                	je     800ca4 <strtol+0x17>
  800cae:	3c 09                	cmp    $0x9,%al
  800cb0:	74 f2                	je     800ca4 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb2:	3c 2b                	cmp    $0x2b,%al
  800cb4:	75 0a                	jne    800cc0 <strtol+0x33>
		s++;
  800cb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbe:	eb 10                	jmp    800cd0 <strtol+0x43>
  800cc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc5:	3c 2d                	cmp    $0x2d,%al
  800cc7:	75 07                	jne    800cd0 <strtol+0x43>
		s++, neg = 1;
  800cc9:	83 c2 01             	add    $0x1,%edx
  800ccc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd0:	85 db                	test   %ebx,%ebx
  800cd2:	0f 94 c0             	sete   %al
  800cd5:	74 05                	je     800cdc <strtol+0x4f>
  800cd7:	83 fb 10             	cmp    $0x10,%ebx
  800cda:	75 15                	jne    800cf1 <strtol+0x64>
  800cdc:	80 3a 30             	cmpb   $0x30,(%edx)
  800cdf:	75 10                	jne    800cf1 <strtol+0x64>
  800ce1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ce5:	75 0a                	jne    800cf1 <strtol+0x64>
		s += 2, base = 16;
  800ce7:	83 c2 02             	add    $0x2,%edx
  800cea:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cef:	eb 13                	jmp    800d04 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800cf1:	84 c0                	test   %al,%al
  800cf3:	74 0f                	je     800d04 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfa:	80 3a 30             	cmpb   $0x30,(%edx)
  800cfd:	75 05                	jne    800d04 <strtol+0x77>
		s++, base = 8;
  800cff:	83 c2 01             	add    $0x1,%edx
  800d02:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
  800d09:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d0b:	0f b6 0a             	movzbl (%edx),%ecx
  800d0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d11:	80 fb 09             	cmp    $0x9,%bl
  800d14:	77 08                	ja     800d1e <strtol+0x91>
			dig = *s - '0';
  800d16:	0f be c9             	movsbl %cl,%ecx
  800d19:	83 e9 30             	sub    $0x30,%ecx
  800d1c:	eb 1e                	jmp    800d3c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800d1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d21:	80 fb 19             	cmp    $0x19,%bl
  800d24:	77 08                	ja     800d2e <strtol+0xa1>
			dig = *s - 'a' + 10;
  800d26:	0f be c9             	movsbl %cl,%ecx
  800d29:	83 e9 57             	sub    $0x57,%ecx
  800d2c:	eb 0e                	jmp    800d3c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800d2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d31:	80 fb 19             	cmp    $0x19,%bl
  800d34:	77 14                	ja     800d4a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d36:	0f be c9             	movsbl %cl,%ecx
  800d39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d3c:	39 f1                	cmp    %esi,%ecx
  800d3e:	7d 0e                	jge    800d4e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d40:	83 c2 01             	add    $0x1,%edx
  800d43:	0f af c6             	imul   %esi,%eax
  800d46:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d48:	eb c1                	jmp    800d0b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d4a:	89 c1                	mov    %eax,%ecx
  800d4c:	eb 02                	jmp    800d50 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d4e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d54:	74 05                	je     800d5b <strtol+0xce>
		*endptr = (char *) s;
  800d56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d59:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d5b:	89 ca                	mov    %ecx,%edx
  800d5d:	f7 da                	neg    %edx
  800d5f:	85 ff                	test   %edi,%edi
  800d61:	0f 45 c2             	cmovne %edx,%eax
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    
  800d69:	00 00                	add    %al,(%eax)
	...

00800d6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	89 c3                	mov    %eax,%ebx
  800d88:	89 c7                	mov    %eax,%edi
  800d8a:	89 c6                	mov    %eax,%esi
  800d8c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d8e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d91:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d94:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d97:	89 ec                	mov    %ebp,%esp
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	ba 00 00 00 00       	mov    $0x0,%edx
  800daf:	b8 01 00 00 00       	mov    $0x1,%eax
  800db4:	89 d1                	mov    %edx,%ecx
  800db6:	89 d3                	mov    %edx,%ebx
  800db8:	89 d7                	mov    %edx,%edi
  800dba:	89 d6                	mov    %edx,%esi
  800dbc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc7:	89 ec                	mov    %ebp,%esp
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 38             	sub    $0x38,%esp
  800dd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddf:	b8 03 00 00 00       	mov    $0x3,%eax
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 cb                	mov    %ecx,%ebx
  800de9:	89 cf                	mov    %ecx,%edi
  800deb:	89 ce                	mov    %ecx,%esi
  800ded:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 28                	jle    800e1b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dfe:	00 
  800dff:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0e:	00 
  800e0f:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800e16:	e8 a9 f4 ff ff       	call   8002c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e24:	89 ec                	mov    %ebp,%esp
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e34:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e37:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3c:	b8 02 00 00 00       	mov    $0x2,%eax
  800e41:	89 d1                	mov    %edx,%ecx
  800e43:	89 d3                	mov    %edx,%ebx
  800e45:	89 d7                	mov    %edx,%edi
  800e47:	89 d6                	mov    %edx,%esi
  800e49:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e54:	89 ec                	mov    %ebp,%esp
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <sys_yield>:

void
sys_yield(void)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e61:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e64:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e67:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 d3                	mov    %edx,%ebx
  800e75:	89 d7                	mov    %edx,%edi
  800e77:	89 d6                	mov    %edx,%esi
  800e79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e81:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e84:	89 ec                	mov    %ebp,%esp
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 38             	sub    $0x38,%esp
  800e8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e91:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e94:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	be 00 00 00 00       	mov    $0x0,%esi
  800e9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	89 f7                	mov    %esi,%edi
  800eac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	7e 28                	jle    800eda <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ebd:	00 
  800ebe:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800ec5:	00 
  800ec6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecd:	00 
  800ece:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800ed5:	e8 ea f3 ff ff       	call   8002c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800edd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee3:	89 ec                	mov    %ebp,%esp
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    

00800ee7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 38             	sub    $0x38,%esp
  800eed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	b8 05 00 00 00       	mov    $0x5,%eax
  800efb:	8b 75 18             	mov    0x18(%ebp),%esi
  800efe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f07:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800f33:	e8 8c f3 ff ff       	call   8002c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f38:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f41:	89 ec                	mov    %ebp,%esp
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 38             	sub    $0x38,%esp
  800f4b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f4e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f51:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f59:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f61:	8b 55 08             	mov    0x8(%ebp),%edx
  800f64:	89 df                	mov    %ebx,%edi
  800f66:	89 de                	mov    %ebx,%esi
  800f68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 28                	jle    800f96 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f72:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f79:	00 
  800f7a:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f89:	00 
  800f8a:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800f91:	e8 2e f3 ff ff       	call   8002c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9f:	89 ec                	mov    %ebp,%esp
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 38             	sub    $0x38,%esp
  800fa9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800faf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb7:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	89 df                	mov    %ebx,%edi
  800fc4:	89 de                	mov    %ebx,%esi
  800fc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	7e 28                	jle    800ff4 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd0:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe7:	00 
  800fe8:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  800fef:	e8 d0 f2 ff ff       	call   8002c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ff4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffd:	89 ec                	mov    %ebp,%esp
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 38             	sub    $0x38,%esp
  801007:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80100d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801010:	bb 00 00 00 00       	mov    $0x0,%ebx
  801015:	b8 09 00 00 00       	mov    $0x9,%eax
  80101a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101d:	8b 55 08             	mov    0x8(%ebp),%edx
  801020:	89 df                	mov    %ebx,%edi
  801022:	89 de                	mov    %ebx,%esi
  801024:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801026:	85 c0                	test   %eax,%eax
  801028:	7e 28                	jle    801052 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801035:	00 
  801036:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  80103d:	00 
  80103e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801045:	00 
  801046:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  80104d:	e8 72 f2 ff ff       	call   8002c4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801052:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801055:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801058:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80105b:	89 ec                	mov    %ebp,%esp
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    

0080105f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	83 ec 38             	sub    $0x38,%esp
  801065:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801068:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80106b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801073:	b8 0a 00 00 00       	mov    $0xa,%eax
  801078:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107b:	8b 55 08             	mov    0x8(%ebp),%edx
  80107e:	89 df                	mov    %ebx,%edi
  801080:	89 de                	mov    %ebx,%esi
  801082:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801084:	85 c0                	test   %eax,%eax
  801086:	7e 28                	jle    8010b0 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801088:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801093:	00 
  801094:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  80109b:	00 
  80109c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a3:	00 
  8010a4:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  8010ab:	e8 14 f2 ff ff       	call   8002c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8010b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010b9:	89 ec                	mov    %ebp,%esp
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010c9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cc:	be 00 00 00 00       	mov    $0x0,%esi
  8010d1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010df:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010e4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010e7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ed:	89 ec                	mov    %ebp,%esp
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	83 ec 38             	sub    $0x38,%esp
  8010f7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010fa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010fd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801100:	b9 00 00 00 00       	mov    $0x0,%ecx
  801105:	b8 0d 00 00 00       	mov    $0xd,%eax
  80110a:	8b 55 08             	mov    0x8(%ebp),%edx
  80110d:	89 cb                	mov    %ecx,%ebx
  80110f:	89 cf                	mov    %ecx,%edi
  801111:	89 ce                	mov    %ecx,%esi
  801113:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  801115:	85 c0                	test   %eax,%eax
  801117:	7e 28                	jle    801141 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801119:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801124:	00 
  801125:	c7 44 24 08 24 17 80 	movl   $0x801724,0x8(%esp)
  80112c:	00 
  80112d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801134:	00 
  801135:	c7 04 24 41 17 80 00 	movl   $0x801741,(%esp)
  80113c:	e8 83 f1 ff ff       	call   8002c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801141:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801144:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801147:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80114a:	89 ec                	mov    %ebp,%esp
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    
	...

00801150 <__udivdi3>:
  801150:	83 ec 1c             	sub    $0x1c,%esp
  801153:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801157:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80115b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80115f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801163:	89 74 24 10          	mov    %esi,0x10(%esp)
  801167:	8b 74 24 24          	mov    0x24(%esp),%esi
  80116b:	85 ff                	test   %edi,%edi
  80116d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801171:	89 44 24 08          	mov    %eax,0x8(%esp)
  801175:	89 cd                	mov    %ecx,%ebp
  801177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117b:	75 33                	jne    8011b0 <__udivdi3+0x60>
  80117d:	39 f1                	cmp    %esi,%ecx
  80117f:	77 57                	ja     8011d8 <__udivdi3+0x88>
  801181:	85 c9                	test   %ecx,%ecx
  801183:	75 0b                	jne    801190 <__udivdi3+0x40>
  801185:	b8 01 00 00 00       	mov    $0x1,%eax
  80118a:	31 d2                	xor    %edx,%edx
  80118c:	f7 f1                	div    %ecx
  80118e:	89 c1                	mov    %eax,%ecx
  801190:	89 f0                	mov    %esi,%eax
  801192:	31 d2                	xor    %edx,%edx
  801194:	f7 f1                	div    %ecx
  801196:	89 c6                	mov    %eax,%esi
  801198:	8b 44 24 04          	mov    0x4(%esp),%eax
  80119c:	f7 f1                	div    %ecx
  80119e:	89 f2                	mov    %esi,%edx
  8011a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ac:	83 c4 1c             	add    $0x1c,%esp
  8011af:	c3                   	ret    
  8011b0:	31 d2                	xor    %edx,%edx
  8011b2:	31 c0                	xor    %eax,%eax
  8011b4:	39 f7                	cmp    %esi,%edi
  8011b6:	77 e8                	ja     8011a0 <__udivdi3+0x50>
  8011b8:	0f bd cf             	bsr    %edi,%ecx
  8011bb:	83 f1 1f             	xor    $0x1f,%ecx
  8011be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011c2:	75 2c                	jne    8011f0 <__udivdi3+0xa0>
  8011c4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8011c8:	76 04                	jbe    8011ce <__udivdi3+0x7e>
  8011ca:	39 f7                	cmp    %esi,%edi
  8011cc:	73 d2                	jae    8011a0 <__udivdi3+0x50>
  8011ce:	31 d2                	xor    %edx,%edx
  8011d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d5:	eb c9                	jmp    8011a0 <__udivdi3+0x50>
  8011d7:	90                   	nop
  8011d8:	89 f2                	mov    %esi,%edx
  8011da:	f7 f1                	div    %ecx
  8011dc:	31 d2                	xor    %edx,%edx
  8011de:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011e2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ea:	83 c4 1c             	add    $0x1c,%esp
  8011ed:	c3                   	ret    
  8011ee:	66 90                	xchg   %ax,%ax
  8011f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011f5:	b8 20 00 00 00       	mov    $0x20,%eax
  8011fa:	89 ea                	mov    %ebp,%edx
  8011fc:	2b 44 24 04          	sub    0x4(%esp),%eax
  801200:	d3 e7                	shl    %cl,%edi
  801202:	89 c1                	mov    %eax,%ecx
  801204:	d3 ea                	shr    %cl,%edx
  801206:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80120b:	09 fa                	or     %edi,%edx
  80120d:	89 f7                	mov    %esi,%edi
  80120f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801213:	89 f2                	mov    %esi,%edx
  801215:	8b 74 24 08          	mov    0x8(%esp),%esi
  801219:	d3 e5                	shl    %cl,%ebp
  80121b:	89 c1                	mov    %eax,%ecx
  80121d:	d3 ef                	shr    %cl,%edi
  80121f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801224:	d3 e2                	shl    %cl,%edx
  801226:	89 c1                	mov    %eax,%ecx
  801228:	d3 ee                	shr    %cl,%esi
  80122a:	09 d6                	or     %edx,%esi
  80122c:	89 fa                	mov    %edi,%edx
  80122e:	89 f0                	mov    %esi,%eax
  801230:	f7 74 24 0c          	divl   0xc(%esp)
  801234:	89 d7                	mov    %edx,%edi
  801236:	89 c6                	mov    %eax,%esi
  801238:	f7 e5                	mul    %ebp
  80123a:	39 d7                	cmp    %edx,%edi
  80123c:	72 22                	jb     801260 <__udivdi3+0x110>
  80123e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801242:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801247:	d3 e5                	shl    %cl,%ebp
  801249:	39 c5                	cmp    %eax,%ebp
  80124b:	73 04                	jae    801251 <__udivdi3+0x101>
  80124d:	39 d7                	cmp    %edx,%edi
  80124f:	74 0f                	je     801260 <__udivdi3+0x110>
  801251:	89 f0                	mov    %esi,%eax
  801253:	31 d2                	xor    %edx,%edx
  801255:	e9 46 ff ff ff       	jmp    8011a0 <__udivdi3+0x50>
  80125a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801260:	8d 46 ff             	lea    -0x1(%esi),%eax
  801263:	31 d2                	xor    %edx,%edx
  801265:	8b 74 24 10          	mov    0x10(%esp),%esi
  801269:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80126d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801271:	83 c4 1c             	add    $0x1c,%esp
  801274:	c3                   	ret    
	...

00801280 <__umoddi3>:
  801280:	83 ec 1c             	sub    $0x1c,%esp
  801283:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801287:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80128b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80128f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801293:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801297:	8b 74 24 24          	mov    0x24(%esp),%esi
  80129b:	85 ed                	test   %ebp,%ebp
  80129d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8012a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a5:	89 cf                	mov    %ecx,%edi
  8012a7:	89 04 24             	mov    %eax,(%esp)
  8012aa:	89 f2                	mov    %esi,%edx
  8012ac:	75 1a                	jne    8012c8 <__umoddi3+0x48>
  8012ae:	39 f1                	cmp    %esi,%ecx
  8012b0:	76 4e                	jbe    801300 <__umoddi3+0x80>
  8012b2:	f7 f1                	div    %ecx
  8012b4:	89 d0                	mov    %edx,%eax
  8012b6:	31 d2                	xor    %edx,%edx
  8012b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012c4:	83 c4 1c             	add    $0x1c,%esp
  8012c7:	c3                   	ret    
  8012c8:	39 f5                	cmp    %esi,%ebp
  8012ca:	77 54                	ja     801320 <__umoddi3+0xa0>
  8012cc:	0f bd c5             	bsr    %ebp,%eax
  8012cf:	83 f0 1f             	xor    $0x1f,%eax
  8012d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d6:	75 60                	jne    801338 <__umoddi3+0xb8>
  8012d8:	3b 0c 24             	cmp    (%esp),%ecx
  8012db:	0f 87 07 01 00 00    	ja     8013e8 <__umoddi3+0x168>
  8012e1:	89 f2                	mov    %esi,%edx
  8012e3:	8b 34 24             	mov    (%esp),%esi
  8012e6:	29 ce                	sub    %ecx,%esi
  8012e8:	19 ea                	sbb    %ebp,%edx
  8012ea:	89 34 24             	mov    %esi,(%esp)
  8012ed:	8b 04 24             	mov    (%esp),%eax
  8012f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012fc:	83 c4 1c             	add    $0x1c,%esp
  8012ff:	c3                   	ret    
  801300:	85 c9                	test   %ecx,%ecx
  801302:	75 0b                	jne    80130f <__umoddi3+0x8f>
  801304:	b8 01 00 00 00       	mov    $0x1,%eax
  801309:	31 d2                	xor    %edx,%edx
  80130b:	f7 f1                	div    %ecx
  80130d:	89 c1                	mov    %eax,%ecx
  80130f:	89 f0                	mov    %esi,%eax
  801311:	31 d2                	xor    %edx,%edx
  801313:	f7 f1                	div    %ecx
  801315:	8b 04 24             	mov    (%esp),%eax
  801318:	f7 f1                	div    %ecx
  80131a:	eb 98                	jmp    8012b4 <__umoddi3+0x34>
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	89 f2                	mov    %esi,%edx
  801322:	8b 74 24 10          	mov    0x10(%esp),%esi
  801326:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80132a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80132e:	83 c4 1c             	add    $0x1c,%esp
  801331:	c3                   	ret    
  801332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801338:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80133d:	89 e8                	mov    %ebp,%eax
  80133f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801344:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801348:	89 fa                	mov    %edi,%edx
  80134a:	d3 e0                	shl    %cl,%eax
  80134c:	89 e9                	mov    %ebp,%ecx
  80134e:	d3 ea                	shr    %cl,%edx
  801350:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801355:	09 c2                	or     %eax,%edx
  801357:	8b 44 24 08          	mov    0x8(%esp),%eax
  80135b:	89 14 24             	mov    %edx,(%esp)
  80135e:	89 f2                	mov    %esi,%edx
  801360:	d3 e7                	shl    %cl,%edi
  801362:	89 e9                	mov    %ebp,%ecx
  801364:	d3 ea                	shr    %cl,%edx
  801366:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80136b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80136f:	d3 e6                	shl    %cl,%esi
  801371:	89 e9                	mov    %ebp,%ecx
  801373:	d3 e8                	shr    %cl,%eax
  801375:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80137a:	09 f0                	or     %esi,%eax
  80137c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801380:	f7 34 24             	divl   (%esp)
  801383:	d3 e6                	shl    %cl,%esi
  801385:	89 74 24 08          	mov    %esi,0x8(%esp)
  801389:	89 d6                	mov    %edx,%esi
  80138b:	f7 e7                	mul    %edi
  80138d:	39 d6                	cmp    %edx,%esi
  80138f:	89 c1                	mov    %eax,%ecx
  801391:	89 d7                	mov    %edx,%edi
  801393:	72 3f                	jb     8013d4 <__umoddi3+0x154>
  801395:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801399:	72 35                	jb     8013d0 <__umoddi3+0x150>
  80139b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80139f:	29 c8                	sub    %ecx,%eax
  8013a1:	19 fe                	sbb    %edi,%esi
  8013a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013a8:	89 f2                	mov    %esi,%edx
  8013aa:	d3 e8                	shr    %cl,%eax
  8013ac:	89 e9                	mov    %ebp,%ecx
  8013ae:	d3 e2                	shl    %cl,%edx
  8013b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013b5:	09 d0                	or     %edx,%eax
  8013b7:	89 f2                	mov    %esi,%edx
  8013b9:	d3 ea                	shr    %cl,%edx
  8013bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8013bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8013c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8013c7:	83 c4 1c             	add    $0x1c,%esp
  8013ca:	c3                   	ret    
  8013cb:	90                   	nop
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	39 d6                	cmp    %edx,%esi
  8013d2:	75 c7                	jne    80139b <__umoddi3+0x11b>
  8013d4:	89 d7                	mov    %edx,%edi
  8013d6:	89 c1                	mov    %eax,%ecx
  8013d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8013dc:	1b 3c 24             	sbb    (%esp),%edi
  8013df:	eb ba                	jmp    80139b <__umoddi3+0x11b>
  8013e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	39 f5                	cmp    %esi,%ebp
  8013ea:	0f 82 f1 fe ff ff    	jb     8012e1 <__umoddi3+0x61>
  8013f0:	e9 f8 fe ff ff       	jmp    8012ed <__umoddi3+0x6d>
