
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800049:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  800052:	e8 09 01 00 00       	call   800160 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 64             	imul   $0x64,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x34>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800078:	89 34 24             	mov    %esi,(%esp)
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
}
  800085:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800088:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008b:	89 ec                	mov    %ebp,%esp
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 61 00 00 00       	call   800103 <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 0c             	sub    $0xc,%esp
  8000aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000be:	89 c3                	mov    %eax,%ebx
  8000c0:	89 c7                	mov    %eax,%edi
  8000c2:	89 c6                	mov    %eax,%esi
  8000c4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000cf:	89 ec                	mov    %ebp,%esp
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000df:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ec:	89 d1                	mov    %edx,%ecx
  8000ee:	89 d3                	mov    %edx,%ebx
  8000f0:	89 d7                	mov    %edx,%edi
  8000f2:	89 d6                	mov    %edx,%esi
  8000f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000ff:	89 ec                	mov    %ebp,%esp
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	83 ec 38             	sub    $0x38,%esp
  800109:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80010c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80010f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800112:	b9 00 00 00 00       	mov    $0x0,%ecx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	89 cb                	mov    %ecx,%ebx
  800121:	89 cf                	mov    %ecx,%edi
  800123:	89 ce                	mov    %ecx,%esi
  800125:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800127:	85 c0                	test   %eax,%eax
  800129:	7e 28                	jle    800153 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800136:	00 
  800137:	c7 44 24 08 ff 0e 80 	movl   $0x800eff,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 1c 0f 80 00 	movl   $0x800f1c,(%esp)
  80014e:	e8 3d 00 00 00       	call   800190 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800153:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800156:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800159:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80015c:	89 ec                	mov    %ebp,%esp
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800169:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80016c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	ba 00 00 00 00       	mov    $0x0,%edx
  800174:	b8 02 00 00 00       	mov    $0x2,%eax
  800179:	89 d1                	mov    %edx,%ecx
  80017b:	89 d3                	mov    %edx,%ebx
  80017d:	89 d7                	mov    %edx,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800183:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800186:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800189:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80018c:	89 ec                	mov    %ebp,%esp
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800196:	a1 08 20 80 00       	mov    0x802008,%eax
  80019b:	85 c0                	test   %eax,%eax
  80019d:	74 10                	je     8001af <_panic+0x1f>
		cprintf("%s: ", argv0);
  80019f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a3:	c7 04 24 2a 0f 80 00 	movl   $0x800f2a,(%esp)
  8001aa:	e8 e8 00 00 00       	call   800297 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bd:	a1 00 20 80 00       	mov    0x802000,%eax
  8001c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c6:	c7 04 24 2f 0f 80 00 	movl   $0x800f2f,(%esp)
  8001cd:	e8 c5 00 00 00       	call   800297 <cprintf>
	vcprintf(fmt, ap);
  8001d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8001d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dc:	89 04 24             	mov    %eax,(%esp)
  8001df:	e8 52 00 00 00       	call   800236 <vcprintf>
	cprintf("\n");
  8001e4:	c7 04 24 4b 0f 80 00 	movl   $0x800f4b,(%esp)
  8001eb:	e8 a7 00 00 00       	call   800297 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f0:	cc                   	int3   
  8001f1:	eb fd                	jmp    8001f0 <_panic+0x60>
	...

008001f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	53                   	push   %ebx
  8001f8:	83 ec 14             	sub    $0x14,%esp
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fe:	8b 03                	mov    (%ebx),%eax
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800207:	83 c0 01             	add    $0x1,%eax
  80020a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80020c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800211:	75 19                	jne    80022c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800213:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80021a:	00 
  80021b:	8d 43 08             	lea    0x8(%ebx),%eax
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	e8 7e fe ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  800226:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80022c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800230:	83 c4 14             	add    $0x14,%esp
  800233:	5b                   	pop    %ebx
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80023f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800246:	00 00 00 
	b.cnt = 0;
  800249:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800250:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
  800256:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800261:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 f4 01 80 00 	movl   $0x8001f4,(%esp)
  800272:	e8 dd 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800277:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80027d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800281:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800287:	89 04 24             	mov    %eax,(%esp)
  80028a:	e8 15 fe ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  80028f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80029d:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 87 ff ff ff       	call   800236 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    
	...

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d7                	mov    %edx,%edi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002e8:	72 11                	jb     8002fb <printnum+0x3b>
  8002ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ed:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f0:	76 09                	jbe    8002fb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f2:	83 eb 01             	sub    $0x1,%ebx
  8002f5:	85 db                	test   %ebx,%ebx
  8002f7:	7f 51                	jg     80034a <printnum+0x8a>
  8002f9:	eb 5e                	jmp    800359 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ff:	83 eb 01             	sub    $0x1,%ebx
  800302:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800306:	8b 45 10             	mov    0x10(%ebp),%eax
  800309:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800311:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800315:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031c:	00 
  80031d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032a:	e8 11 09 00 00       	call   800c40 <__udivdi3>
  80032f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800333:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033e:	89 fa                	mov    %edi,%edx
  800340:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800343:	e8 78 ff ff ff       	call   8002c0 <printnum>
  800348:	eb 0f                	jmp    800359 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034e:	89 34 24             	mov    %esi,(%esp)
  800351:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800354:	83 eb 01             	sub    $0x1,%ebx
  800357:	75 f1                	jne    80034a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800359:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800361:	8b 45 10             	mov    0x10(%ebp),%eax
  800364:	89 44 24 08          	mov    %eax,0x8(%esp)
  800368:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036f:	00 
  800370:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800373:	89 04 24             	mov    %eax,(%esp)
  800376:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037d:	e8 ee 09 00 00       	call   800d70 <__umoddi3>
  800382:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800386:	0f be 80 4d 0f 80 00 	movsbl 0x800f4d(%eax),%eax
  80038d:	89 04 24             	mov    %eax,(%esp)
  800390:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800393:	83 c4 3c             	add    $0x3c,%esp
  800396:	5b                   	pop    %ebx
  800397:	5e                   	pop    %esi
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80039e:	83 fa 01             	cmp    $0x1,%edx
  8003a1:	7e 0e                	jle    8003b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a8:	89 08                	mov    %ecx,(%eax)
  8003aa:	8b 02                	mov    (%edx),%eax
  8003ac:	8b 52 04             	mov    0x4(%edx),%edx
  8003af:	eb 22                	jmp    8003d3 <getuint+0x38>
	else if (lflag)
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	74 10                	je     8003c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b5:	8b 10                	mov    (%eax),%edx
  8003b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ba:	89 08                	mov    %ecx,(%eax)
  8003bc:	8b 02                	mov    (%edx),%eax
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c3:	eb 0e                	jmp    8003d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ca:	89 08                	mov    %ecx,(%eax)
  8003cc:	8b 02                	mov    (%edx),%eax
  8003ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    

008003d5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d8:	83 fa 01             	cmp    $0x1,%edx
  8003db:	7e 0e                	jle    8003eb <getint+0x16>
		return va_arg(*ap, long long);
  8003dd:	8b 10                	mov    (%eax),%edx
  8003df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e2:	89 08                	mov    %ecx,(%eax)
  8003e4:	8b 02                	mov    (%edx),%eax
  8003e6:	8b 52 04             	mov    0x4(%edx),%edx
  8003e9:	eb 22                	jmp    80040d <getint+0x38>
	else if (lflag)
  8003eb:	85 d2                	test   %edx,%edx
  8003ed:	74 10                	je     8003ff <getint+0x2a>
		return va_arg(*ap, long);
  8003ef:	8b 10                	mov    (%eax),%edx
  8003f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 02                	mov    (%edx),%eax
  8003f8:	89 c2                	mov    %eax,%edx
  8003fa:	c1 fa 1f             	sar    $0x1f,%edx
  8003fd:	eb 0e                	jmp    80040d <getint+0x38>
	else
		return va_arg(*ap, int);
  8003ff:	8b 10                	mov    (%eax),%edx
  800401:	8d 4a 04             	lea    0x4(%edx),%ecx
  800404:	89 08                	mov    %ecx,(%eax)
  800406:	8b 02                	mov    (%edx),%eax
  800408:	89 c2                	mov    %eax,%edx
  80040a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800415:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	3b 50 04             	cmp    0x4(%eax),%edx
  80041e:	73 0a                	jae    80042a <sprintputch+0x1b>
		*b->buf++ = ch;
  800420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800423:	88 0a                	mov    %cl,(%edx)
  800425:	83 c2 01             	add    $0x1,%edx
  800428:	89 10                	mov    %edx,(%eax)
}
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800432:	8d 45 14             	lea    0x14(%ebp),%eax
  800435:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800439:	8b 45 10             	mov    0x10(%ebp),%eax
  80043c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	89 44 24 04          	mov    %eax,0x4(%esp)
  800447:	8b 45 08             	mov    0x8(%ebp),%eax
  80044a:	89 04 24             	mov    %eax,(%esp)
  80044d:	e8 02 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 4c             	sub    $0x4c,%esp
  80045d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800460:	8b 75 10             	mov    0x10(%ebp),%esi
  800463:	eb 12                	jmp    800477 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800465:	85 c0                	test   %eax,%eax
  800467:	0f 84 98 03 00 00    	je     800805 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80046d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800477:	0f b6 06             	movzbl (%esi),%eax
  80047a:	83 c6 01             	add    $0x1,%esi
  80047d:	83 f8 25             	cmp    $0x25,%eax
  800480:	75 e3                	jne    800465 <vprintfmt+0x11>
  800482:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800486:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80048d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800492:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800499:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a1:	eb 2b                	jmp    8004ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004aa:	eb 22                	jmp    8004ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004af:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004b3:	eb 19                	jmp    8004ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004bf:	eb 0d                	jmp    8004ce <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	0f b6 06             	movzbl (%esi),%eax
  8004d1:	0f b6 d0             	movzbl %al,%edx
  8004d4:	8d 7e 01             	lea    0x1(%esi),%edi
  8004d7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004da:	83 e8 23             	sub    $0x23,%eax
  8004dd:	3c 55                	cmp    $0x55,%al
  8004df:	0f 87 fa 02 00 00    	ja     8007df <vprintfmt+0x38b>
  8004e5:	0f b6 c0             	movzbl %al,%eax
  8004e8:	ff 24 85 dc 0f 80 00 	jmp    *0x800fdc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ef:	83 ea 30             	sub    $0x30,%edx
  8004f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004f5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004f9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004ff:	83 fa 09             	cmp    $0x9,%edx
  800502:	77 4a                	ja     80054e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800507:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80050a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80050d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800511:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800514:	8d 50 d0             	lea    -0x30(%eax),%edx
  800517:	83 fa 09             	cmp    $0x9,%edx
  80051a:	76 eb                	jbe    800507 <vprintfmt+0xb3>
  80051c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051f:	eb 2d                	jmp    80054e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800532:	eb 1a                	jmp    80054e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800534:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800537:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053b:	79 91                	jns    8004ce <vprintfmt+0x7a>
  80053d:	e9 73 ff ff ff       	jmp    8004b5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800545:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80054c:	eb 80                	jmp    8004ce <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80054e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800552:	0f 89 76 ff ff ff    	jns    8004ce <vprintfmt+0x7a>
  800558:	e9 64 ff ff ff       	jmp    8004c1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80055d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800563:	e9 66 ff ff ff       	jmp    8004ce <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 04 24             	mov    %eax,(%esp)
  80057a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800580:	e9 f2 fe ff ff       	jmp    800477 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 04             	lea    0x4(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 00                	mov    (%eax),%eax
  800590:	89 c2                	mov    %eax,%edx
  800592:	c1 fa 1f             	sar    $0x1f,%edx
  800595:	31 d0                	xor    %edx,%eax
  800597:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800599:	83 f8 06             	cmp    $0x6,%eax
  80059c:	7f 0b                	jg     8005a9 <vprintfmt+0x155>
  80059e:	8b 14 85 34 11 80 00 	mov    0x801134(,%eax,4),%edx
  8005a5:	85 d2                	test   %edx,%edx
  8005a7:	75 23                	jne    8005cc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ad:	c7 44 24 08 65 0f 80 	movl   $0x800f65,0x8(%esp)
  8005b4:	00 
  8005b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005bc:	89 3c 24             	mov    %edi,(%esp)
  8005bf:	e8 68 fe ff ff       	call   80042c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c7:	e9 ab fe ff ff       	jmp    800477 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d0:	c7 44 24 08 6e 0f 80 	movl   $0x800f6e,0x8(%esp)
  8005d7:	00 
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005df:	89 3c 24             	mov    %edi,(%esp)
  8005e2:	e8 45 fe ff ff       	call   80042c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ea:	e9 88 fe ff ff       	jmp    800477 <vprintfmt+0x23>
  8005ef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800603:	85 f6                	test   %esi,%esi
  800605:	ba 5e 0f 80 00       	mov    $0x800f5e,%edx
  80060a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80060d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800611:	7e 06                	jle    800619 <vprintfmt+0x1c5>
  800613:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800617:	75 10                	jne    800629 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800619:	0f be 06             	movsbl (%esi),%eax
  80061c:	83 c6 01             	add    $0x1,%esi
  80061f:	85 c0                	test   %eax,%eax
  800621:	0f 85 86 00 00 00    	jne    8006ad <vprintfmt+0x259>
  800627:	eb 76                	jmp    80069f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800629:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062d:	89 34 24             	mov    %esi,(%esp)
  800630:	e8 76 02 00 00       	call   8008ab <strnlen>
  800635:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800638:	29 c2                	sub    %eax,%edx
  80063a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80063d:	85 d2                	test   %edx,%edx
  80063f:	7e d8                	jle    800619 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800641:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800645:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800648:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80064b:	89 d6                	mov    %edx,%esi
  80064d:	89 c7                	mov    %eax,%edi
  80064f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800653:	89 3c 24             	mov    %edi,(%esp)
  800656:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800659:	83 ee 01             	sub    $0x1,%esi
  80065c:	75 f1                	jne    80064f <vprintfmt+0x1fb>
  80065e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800661:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800664:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800667:	eb b0                	jmp    800619 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800669:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80066d:	74 18                	je     800687 <vprintfmt+0x233>
  80066f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800672:	83 fa 5e             	cmp    $0x5e,%edx
  800675:	76 10                	jbe    800687 <vprintfmt+0x233>
					putch('?', putdat);
  800677:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800682:	ff 55 08             	call   *0x8(%ebp)
  800685:	eb 0a                	jmp    800691 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800687:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068b:	89 04 24             	mov    %eax,(%esp)
  80068e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800691:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800695:	0f be 06             	movsbl (%esi),%eax
  800698:	83 c6 01             	add    $0x1,%esi
  80069b:	85 c0                	test   %eax,%eax
  80069d:	75 0e                	jne    8006ad <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a6:	7f 11                	jg     8006b9 <vprintfmt+0x265>
  8006a8:	e9 ca fd ff ff       	jmp    800477 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ad:	85 ff                	test   %edi,%edi
  8006af:	90                   	nop
  8006b0:	78 b7                	js     800669 <vprintfmt+0x215>
  8006b2:	83 ef 01             	sub    $0x1,%edi
  8006b5:	79 b2                	jns    800669 <vprintfmt+0x215>
  8006b7:	eb e6                	jmp    80069f <vprintfmt+0x24b>
  8006b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006bc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ca:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006cc:	83 ee 01             	sub    $0x1,%esi
  8006cf:	75 ee                	jne    8006bf <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d4:	e9 9e fd ff ff       	jmp    800477 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d9:	89 ca                	mov    %ecx,%edx
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	e8 f2 fc ff ff       	call   8003d5 <getint>
  8006e3:	89 c6                	mov    %eax,%esi
  8006e5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	0f 89 ad 00 00 00    	jns    8007a1 <vprintfmt+0x34d>
				putch('-', putdat);
  8006f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800702:	f7 de                	neg    %esi
  800704:	83 d7 00             	adc    $0x0,%edi
  800707:	f7 df                	neg    %edi
			}
			base = 10;
  800709:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070e:	e9 8e 00 00 00       	jmp    8007a1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800713:	89 ca                	mov    %ecx,%edx
  800715:	8d 45 14             	lea    0x14(%ebp),%eax
  800718:	e8 7e fc ff ff       	call   80039b <getuint>
  80071d:	89 c6                	mov    %eax,%esi
  80071f:	89 d7                	mov    %edx,%edi
			base = 10;
  800721:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800726:	eb 79                	jmp    8007a1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800728:	89 ca                	mov    %ecx,%edx
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
  80072d:	e8 a3 fc ff ff       	call   8003d5 <getint>
  800732:	89 c6                	mov    %eax,%esi
  800734:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800736:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80073b:	85 d2                	test   %edx,%edx
  80073d:	79 62                	jns    8007a1 <vprintfmt+0x34d>
				putch('-', putdat);
  80073f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800743:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80074d:	f7 de                	neg    %esi
  80074f:	83 d7 00             	adc    $0x0,%edi
  800752:	f7 df                	neg    %edi
			}
			base = 8;
  800754:	b8 08 00 00 00       	mov    $0x8,%eax
  800759:	eb 46                	jmp    8007a1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80075b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800766:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800769:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800774:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 50 04             	lea    0x4(%eax),%edx
  80077d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800780:	8b 30                	mov    (%eax),%esi
  800782:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800787:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80078c:	eb 13                	jmp    8007a1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078e:	89 ca                	mov    %ecx,%edx
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
  800793:	e8 03 fc ff ff       	call   80039b <getuint>
  800798:	89 c6                	mov    %eax,%esi
  80079a:	89 d7                	mov    %edx,%edi
			base = 16;
  80079c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b4:	89 34 24             	mov    %esi,(%esp)
  8007b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bb:	89 da                	mov    %ebx,%edx
  8007bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c0:	e8 fb fa ff ff       	call   8002c0 <printnum>
			break;
  8007c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c8:	e9 aa fc ff ff       	jmp    800477 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d1:	89 14 24             	mov    %edx,(%esp)
  8007d4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007da:	e9 98 fc ff ff       	jmp    800477 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ea:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ed:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007f1:	0f 84 80 fc ff ff    	je     800477 <vprintfmt+0x23>
  8007f7:	83 ee 01             	sub    $0x1,%esi
  8007fa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007fe:	75 f7                	jne    8007f7 <vprintfmt+0x3a3>
  800800:	e9 72 fc ff ff       	jmp    800477 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800805:	83 c4 4c             	add    $0x4c,%esp
  800808:	5b                   	pop    %ebx
  800809:	5e                   	pop    %esi
  80080a:	5f                   	pop    %edi
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 28             	sub    $0x28,%esp
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800819:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800820:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800823:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082a:	85 c0                	test   %eax,%eax
  80082c:	74 30                	je     80085e <vsnprintf+0x51>
  80082e:	85 d2                	test   %edx,%edx
  800830:	7e 2c                	jle    80085e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800839:	8b 45 10             	mov    0x10(%ebp),%eax
  80083c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800840:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800843:	89 44 24 04          	mov    %eax,0x4(%esp)
  800847:	c7 04 24 0f 04 80 00 	movl   $0x80040f,(%esp)
  80084e:	e8 01 fc ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800853:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800856:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800859:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085c:	eb 05                	jmp    800863 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800872:	8b 45 10             	mov    0x10(%ebp),%eax
  800875:	89 44 24 08          	mov    %eax,0x8(%esp)
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	89 04 24             	mov    %eax,(%esp)
  800886:	e8 82 ff ff ff       	call   80080d <vsnprintf>
	va_end(ap);

	return rc;
}
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    
  80088d:	00 00                	add    %al,(%eax)
	...

00800890 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	80 3a 00             	cmpb   $0x0,(%edx)
  80089e:	74 09                	je     8008a9 <strlen+0x19>
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	75 f7                	jne    8008a0 <strlen+0x10>
		n++;
	return n;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	85 c9                	test   %ecx,%ecx
  8008bc:	74 1a                	je     8008d8 <strnlen+0x2d>
  8008be:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008c1:	74 15                	je     8008d8 <strnlen+0x2d>
  8008c3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008c8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ca:	39 ca                	cmp    %ecx,%edx
  8008cc:	74 0a                	je     8008d8 <strnlen+0x2d>
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008d6:	75 f0                	jne    8008c8 <strnlen+0x1d>
		n++;
	return n;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008f1:	83 c2 01             	add    $0x1,%edx
  8008f4:	84 c9                	test   %cl,%cl
  8008f6:	75 f2                	jne    8008ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
  800906:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	85 f6                	test   %esi,%esi
  80090b:	74 18                	je     800925 <strncpy+0x2a>
  80090d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800912:	0f b6 1a             	movzbl (%edx),%ebx
  800915:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800918:	80 3a 01             	cmpb   $0x1,(%edx)
  80091b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091e:	83 c1 01             	add    $0x1,%ecx
  800921:	39 f1                	cmp    %esi,%ecx
  800923:	75 ed                	jne    800912 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800932:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800935:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800938:	89 f8                	mov    %edi,%eax
  80093a:	85 f6                	test   %esi,%esi
  80093c:	74 2b                	je     800969 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80093e:	83 fe 01             	cmp    $0x1,%esi
  800941:	74 23                	je     800966 <strlcpy+0x3d>
  800943:	0f b6 0b             	movzbl (%ebx),%ecx
  800946:	84 c9                	test   %cl,%cl
  800948:	74 1c                	je     800966 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80094a:	83 ee 02             	sub    $0x2,%esi
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800952:	88 08                	mov    %cl,(%eax)
  800954:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800957:	39 f2                	cmp    %esi,%edx
  800959:	74 0b                	je     800966 <strlcpy+0x3d>
  80095b:	83 c2 01             	add    $0x1,%edx
  80095e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800962:	84 c9                	test   %cl,%cl
  800964:	75 ec                	jne    800952 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800966:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800969:	29 f8                	sub    %edi,%eax
}
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800979:	0f b6 01             	movzbl (%ecx),%eax
  80097c:	84 c0                	test   %al,%al
  80097e:	74 16                	je     800996 <strcmp+0x26>
  800980:	3a 02                	cmp    (%edx),%al
  800982:	75 12                	jne    800996 <strcmp+0x26>
		p++, q++;
  800984:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800987:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80098b:	84 c0                	test   %al,%al
  80098d:	74 07                	je     800996 <strcmp+0x26>
  80098f:	83 c1 01             	add    $0x1,%ecx
  800992:	3a 02                	cmp    (%edx),%al
  800994:	74 ee                	je     800984 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800996:	0f b6 c0             	movzbl %al,%eax
  800999:	0f b6 12             	movzbl (%edx),%edx
  80099c:	29 d0                	sub    %edx,%eax
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	53                   	push   %ebx
  8009a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009aa:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	74 28                	je     8009de <strncmp+0x3e>
  8009b6:	0f b6 01             	movzbl (%ecx),%eax
  8009b9:	84 c0                	test   %al,%al
  8009bb:	74 24                	je     8009e1 <strncmp+0x41>
  8009bd:	3a 03                	cmp    (%ebx),%al
  8009bf:	75 20                	jne    8009e1 <strncmp+0x41>
  8009c1:	83 ea 01             	sub    $0x1,%edx
  8009c4:	74 13                	je     8009d9 <strncmp+0x39>
		n--, p++, q++;
  8009c6:	83 c1 01             	add    $0x1,%ecx
  8009c9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009cc:	0f b6 01             	movzbl (%ecx),%eax
  8009cf:	84 c0                	test   %al,%al
  8009d1:	74 0e                	je     8009e1 <strncmp+0x41>
  8009d3:	3a 03                	cmp    (%ebx),%al
  8009d5:	74 ea                	je     8009c1 <strncmp+0x21>
  8009d7:	eb 08                	jmp    8009e1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009de:	5b                   	pop    %ebx
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e1:	0f b6 01             	movzbl (%ecx),%eax
  8009e4:	0f b6 13             	movzbl (%ebx),%edx
  8009e7:	29 d0                	sub    %edx,%eax
  8009e9:	eb f3                	jmp    8009de <strncmp+0x3e>

008009eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	0f b6 10             	movzbl (%eax),%edx
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	74 1c                	je     800a18 <strchr+0x2d>
		if (*s == c)
  8009fc:	38 ca                	cmp    %cl,%dl
  8009fe:	75 09                	jne    800a09 <strchr+0x1e>
  800a00:	eb 1b                	jmp    800a1d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a05:	38 ca                	cmp    %cl,%dl
  800a07:	74 14                	je     800a1d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a09:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a0d:	84 d2                	test   %dl,%dl
  800a0f:	75 f1                	jne    800a02 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
  800a16:	eb 05                	jmp    800a1d <strchr+0x32>
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	0f b6 10             	movzbl (%eax),%edx
  800a2c:	84 d2                	test   %dl,%dl
  800a2e:	74 14                	je     800a44 <strfind+0x25>
		if (*s == c)
  800a30:	38 ca                	cmp    %cl,%dl
  800a32:	75 06                	jne    800a3a <strfind+0x1b>
  800a34:	eb 0e                	jmp    800a44 <strfind+0x25>
  800a36:	38 ca                	cmp    %cl,%dl
  800a38:	74 0a                	je     800a44 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	84 d2                	test   %dl,%dl
  800a42:	75 f2                	jne    800a36 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	53                   	push   %ebx
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a53:	89 da                	mov    %ebx,%edx
  800a55:	83 ea 01             	sub    $0x1,%edx
  800a58:	78 0d                	js     800a67 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a5a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800a5c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a5e:	88 0a                	mov    %cl,(%edx)
  800a60:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a63:	39 da                	cmp    %ebx,%edx
  800a65:	75 f7                	jne    800a5e <memset+0x18>
		*p++ = c;

	return v;
}
  800a67:	5b                   	pop    %ebx
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a79:	39 c6                	cmp    %eax,%esi
  800a7b:	72 0b                	jb     800a88 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	85 db                	test   %ebx,%ebx
  800a84:	75 29                	jne    800aaf <memmove+0x45>
  800a86:	eb 35                	jmp    800abd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a88:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800a8b:	39 c8                	cmp    %ecx,%eax
  800a8d:	73 ee                	jae    800a7d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800a8f:	85 db                	test   %ebx,%ebx
  800a91:	74 2a                	je     800abd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a93:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800a96:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800a98:	f7 db                	neg    %ebx
  800a9a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800a9d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800a9f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800aa4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800aa8:	83 ea 01             	sub    $0x1,%edx
  800aab:	75 f2                	jne    800a9f <memmove+0x35>
  800aad:	eb 0e                	jmp    800abd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800aaf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ab3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ab6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800ab9:	39 d3                	cmp    %edx,%ebx
  800abb:	75 f2                	jne    800aaf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac8:	8b 45 10             	mov    0x10(%ebp),%eax
  800acb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	89 04 24             	mov    %eax,(%esp)
  800adc:	e8 89 ff ff ff       	call   800a6a <memmove>
}
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af7:	85 ff                	test   %edi,%edi
  800af9:	74 37                	je     800b32 <memcmp+0x4f>
		if (*s1 != *s2)
  800afb:	0f b6 03             	movzbl (%ebx),%eax
  800afe:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b01:	83 ef 01             	sub    $0x1,%edi
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b09:	38 c8                	cmp    %cl,%al
  800b0b:	74 1c                	je     800b29 <memcmp+0x46>
  800b0d:	eb 10                	jmp    800b1f <memcmp+0x3c>
  800b0f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b14:	83 c2 01             	add    $0x1,%edx
  800b17:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b1b:	38 c8                	cmp    %cl,%al
  800b1d:	74 0a                	je     800b29 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c0             	movzbl %al,%eax
  800b22:	0f b6 c9             	movzbl %cl,%ecx
  800b25:	29 c8                	sub    %ecx,%eax
  800b27:	eb 09                	jmp    800b32 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b29:	39 fa                	cmp    %edi,%edx
  800b2b:	75 e2                	jne    800b0f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b3d:	89 c2                	mov    %eax,%edx
  800b3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b42:	39 d0                	cmp    %edx,%eax
  800b44:	73 15                	jae    800b5b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b4a:	38 08                	cmp    %cl,(%eax)
  800b4c:	75 06                	jne    800b54 <memfind+0x1d>
  800b4e:	eb 0b                	jmp    800b5b <memfind+0x24>
  800b50:	38 08                	cmp    %cl,(%eax)
  800b52:	74 07                	je     800b5b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	39 d0                	cmp    %edx,%eax
  800b59:	75 f5                	jne    800b50 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b69:	0f b6 02             	movzbl (%edx),%eax
  800b6c:	3c 20                	cmp    $0x20,%al
  800b6e:	74 04                	je     800b74 <strtol+0x17>
  800b70:	3c 09                	cmp    $0x9,%al
  800b72:	75 0e                	jne    800b82 <strtol+0x25>
		s++;
  800b74:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b77:	0f b6 02             	movzbl (%edx),%eax
  800b7a:	3c 20                	cmp    $0x20,%al
  800b7c:	74 f6                	je     800b74 <strtol+0x17>
  800b7e:	3c 09                	cmp    $0x9,%al
  800b80:	74 f2                	je     800b74 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b82:	3c 2b                	cmp    $0x2b,%al
  800b84:	75 0a                	jne    800b90 <strtol+0x33>
		s++;
  800b86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8e:	eb 10                	jmp    800ba0 <strtol+0x43>
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b95:	3c 2d                	cmp    $0x2d,%al
  800b97:	75 07                	jne    800ba0 <strtol+0x43>
		s++, neg = 1;
  800b99:	83 c2 01             	add    $0x1,%edx
  800b9c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba0:	85 db                	test   %ebx,%ebx
  800ba2:	0f 94 c0             	sete   %al
  800ba5:	74 05                	je     800bac <strtol+0x4f>
  800ba7:	83 fb 10             	cmp    $0x10,%ebx
  800baa:	75 15                	jne    800bc1 <strtol+0x64>
  800bac:	80 3a 30             	cmpb   $0x30,(%edx)
  800baf:	75 10                	jne    800bc1 <strtol+0x64>
  800bb1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bb5:	75 0a                	jne    800bc1 <strtol+0x64>
		s += 2, base = 16;
  800bb7:	83 c2 02             	add    $0x2,%edx
  800bba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbf:	eb 13                	jmp    800bd4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800bc1:	84 c0                	test   %al,%al
  800bc3:	74 0f                	je     800bd4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bca:	80 3a 30             	cmpb   $0x30,(%edx)
  800bcd:	75 05                	jne    800bd4 <strtol+0x77>
		s++, base = 8;
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bdb:	0f b6 0a             	movzbl (%edx),%ecx
  800bde:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800be1:	80 fb 09             	cmp    $0x9,%bl
  800be4:	77 08                	ja     800bee <strtol+0x91>
			dig = *s - '0';
  800be6:	0f be c9             	movsbl %cl,%ecx
  800be9:	83 e9 30             	sub    $0x30,%ecx
  800bec:	eb 1e                	jmp    800c0c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bf1:	80 fb 19             	cmp    $0x19,%bl
  800bf4:	77 08                	ja     800bfe <strtol+0xa1>
			dig = *s - 'a' + 10;
  800bf6:	0f be c9             	movsbl %cl,%ecx
  800bf9:	83 e9 57             	sub    $0x57,%ecx
  800bfc:	eb 0e                	jmp    800c0c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800bfe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 14                	ja     800c1a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c06:	0f be c9             	movsbl %cl,%ecx
  800c09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c0c:	39 f1                	cmp    %esi,%ecx
  800c0e:	7d 0e                	jge    800c1e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c10:	83 c2 01             	add    $0x1,%edx
  800c13:	0f af c6             	imul   %esi,%eax
  800c16:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c18:	eb c1                	jmp    800bdb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c1a:	89 c1                	mov    %eax,%ecx
  800c1c:	eb 02                	jmp    800c20 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c1e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c24:	74 05                	je     800c2b <strtol+0xce>
		*endptr = (char *) s;
  800c26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c29:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c2b:	89 ca                	mov    %ecx,%edx
  800c2d:	f7 da                	neg    %edx
  800c2f:	85 ff                	test   %edi,%edi
  800c31:	0f 45 c2             	cmovne %edx,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    
  800c39:	00 00                	add    %al,(%eax)
  800c3b:	00 00                	add    %al,(%eax)
  800c3d:	00 00                	add    %al,(%eax)
	...

00800c40 <__udivdi3>:
  800c40:	83 ec 1c             	sub    $0x1c,%esp
  800c43:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800c47:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800c4b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800c4f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800c53:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c57:	8b 74 24 24          	mov    0x24(%esp),%esi
  800c5b:	85 ff                	test   %edi,%edi
  800c5d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800c61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c65:	89 cd                	mov    %ecx,%ebp
  800c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6b:	75 33                	jne    800ca0 <__udivdi3+0x60>
  800c6d:	39 f1                	cmp    %esi,%ecx
  800c6f:	77 57                	ja     800cc8 <__udivdi3+0x88>
  800c71:	85 c9                	test   %ecx,%ecx
  800c73:	75 0b                	jne    800c80 <__udivdi3+0x40>
  800c75:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7a:	31 d2                	xor    %edx,%edx
  800c7c:	f7 f1                	div    %ecx
  800c7e:	89 c1                	mov    %eax,%ecx
  800c80:	89 f0                	mov    %esi,%eax
  800c82:	31 d2                	xor    %edx,%edx
  800c84:	f7 f1                	div    %ecx
  800c86:	89 c6                	mov    %eax,%esi
  800c88:	8b 44 24 04          	mov    0x4(%esp),%eax
  800c8c:	f7 f1                	div    %ecx
  800c8e:	89 f2                	mov    %esi,%edx
  800c90:	8b 74 24 10          	mov    0x10(%esp),%esi
  800c94:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800c98:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800c9c:	83 c4 1c             	add    $0x1c,%esp
  800c9f:	c3                   	ret    
  800ca0:	31 d2                	xor    %edx,%edx
  800ca2:	31 c0                	xor    %eax,%eax
  800ca4:	39 f7                	cmp    %esi,%edi
  800ca6:	77 e8                	ja     800c90 <__udivdi3+0x50>
  800ca8:	0f bd cf             	bsr    %edi,%ecx
  800cab:	83 f1 1f             	xor    $0x1f,%ecx
  800cae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cb2:	75 2c                	jne    800ce0 <__udivdi3+0xa0>
  800cb4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800cb8:	76 04                	jbe    800cbe <__udivdi3+0x7e>
  800cba:	39 f7                	cmp    %esi,%edi
  800cbc:	73 d2                	jae    800c90 <__udivdi3+0x50>
  800cbe:	31 d2                	xor    %edx,%edx
  800cc0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc5:	eb c9                	jmp    800c90 <__udivdi3+0x50>
  800cc7:	90                   	nop
  800cc8:	89 f2                	mov    %esi,%edx
  800cca:	f7 f1                	div    %ecx
  800ccc:	31 d2                	xor    %edx,%edx
  800cce:	8b 74 24 10          	mov    0x10(%esp),%esi
  800cd2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800cd6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800cda:	83 c4 1c             	add    $0x1c,%esp
  800cdd:	c3                   	ret    
  800cde:	66 90                	xchg   %ax,%ax
  800ce0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ce5:	b8 20 00 00 00       	mov    $0x20,%eax
  800cea:	89 ea                	mov    %ebp,%edx
  800cec:	2b 44 24 04          	sub    0x4(%esp),%eax
  800cf0:	d3 e7                	shl    %cl,%edi
  800cf2:	89 c1                	mov    %eax,%ecx
  800cf4:	d3 ea                	shr    %cl,%edx
  800cf6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800cfb:	09 fa                	or     %edi,%edx
  800cfd:	89 f7                	mov    %esi,%edi
  800cff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d03:	89 f2                	mov    %esi,%edx
  800d05:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d09:	d3 e5                	shl    %cl,%ebp
  800d0b:	89 c1                	mov    %eax,%ecx
  800d0d:	d3 ef                	shr    %cl,%edi
  800d0f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d14:	d3 e2                	shl    %cl,%edx
  800d16:	89 c1                	mov    %eax,%ecx
  800d18:	d3 ee                	shr    %cl,%esi
  800d1a:	09 d6                	or     %edx,%esi
  800d1c:	89 fa                	mov    %edi,%edx
  800d1e:	89 f0                	mov    %esi,%eax
  800d20:	f7 74 24 0c          	divl   0xc(%esp)
  800d24:	89 d7                	mov    %edx,%edi
  800d26:	89 c6                	mov    %eax,%esi
  800d28:	f7 e5                	mul    %ebp
  800d2a:	39 d7                	cmp    %edx,%edi
  800d2c:	72 22                	jb     800d50 <__udivdi3+0x110>
  800d2e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800d32:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d37:	d3 e5                	shl    %cl,%ebp
  800d39:	39 c5                	cmp    %eax,%ebp
  800d3b:	73 04                	jae    800d41 <__udivdi3+0x101>
  800d3d:	39 d7                	cmp    %edx,%edi
  800d3f:	74 0f                	je     800d50 <__udivdi3+0x110>
  800d41:	89 f0                	mov    %esi,%eax
  800d43:	31 d2                	xor    %edx,%edx
  800d45:	e9 46 ff ff ff       	jmp    800c90 <__udivdi3+0x50>
  800d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d50:	8d 46 ff             	lea    -0x1(%esi),%eax
  800d53:	31 d2                	xor    %edx,%edx
  800d55:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d59:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800d5d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800d61:	83 c4 1c             	add    $0x1c,%esp
  800d64:	c3                   	ret    
	...

00800d70 <__umoddi3>:
  800d70:	83 ec 1c             	sub    $0x1c,%esp
  800d73:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800d77:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800d7b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800d7f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d83:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d87:	8b 74 24 24          	mov    0x24(%esp),%esi
  800d8b:	85 ed                	test   %ebp,%ebp
  800d8d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800d91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d95:	89 cf                	mov    %ecx,%edi
  800d97:	89 04 24             	mov    %eax,(%esp)
  800d9a:	89 f2                	mov    %esi,%edx
  800d9c:	75 1a                	jne    800db8 <__umoddi3+0x48>
  800d9e:	39 f1                	cmp    %esi,%ecx
  800da0:	76 4e                	jbe    800df0 <__umoddi3+0x80>
  800da2:	f7 f1                	div    %ecx
  800da4:	89 d0                	mov    %edx,%eax
  800da6:	31 d2                	xor    %edx,%edx
  800da8:	8b 74 24 10          	mov    0x10(%esp),%esi
  800dac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800db0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800db4:	83 c4 1c             	add    $0x1c,%esp
  800db7:	c3                   	ret    
  800db8:	39 f5                	cmp    %esi,%ebp
  800dba:	77 54                	ja     800e10 <__umoddi3+0xa0>
  800dbc:	0f bd c5             	bsr    %ebp,%eax
  800dbf:	83 f0 1f             	xor    $0x1f,%eax
  800dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc6:	75 60                	jne    800e28 <__umoddi3+0xb8>
  800dc8:	3b 0c 24             	cmp    (%esp),%ecx
  800dcb:	0f 87 07 01 00 00    	ja     800ed8 <__umoddi3+0x168>
  800dd1:	89 f2                	mov    %esi,%edx
  800dd3:	8b 34 24             	mov    (%esp),%esi
  800dd6:	29 ce                	sub    %ecx,%esi
  800dd8:	19 ea                	sbb    %ebp,%edx
  800dda:	89 34 24             	mov    %esi,(%esp)
  800ddd:	8b 04 24             	mov    (%esp),%eax
  800de0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800de4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800de8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800dec:	83 c4 1c             	add    $0x1c,%esp
  800def:	c3                   	ret    
  800df0:	85 c9                	test   %ecx,%ecx
  800df2:	75 0b                	jne    800dff <__umoddi3+0x8f>
  800df4:	b8 01 00 00 00       	mov    $0x1,%eax
  800df9:	31 d2                	xor    %edx,%edx
  800dfb:	f7 f1                	div    %ecx
  800dfd:	89 c1                	mov    %eax,%ecx
  800dff:	89 f0                	mov    %esi,%eax
  800e01:	31 d2                	xor    %edx,%edx
  800e03:	f7 f1                	div    %ecx
  800e05:	8b 04 24             	mov    (%esp),%eax
  800e08:	f7 f1                	div    %ecx
  800e0a:	eb 98                	jmp    800da4 <__umoddi3+0x34>
  800e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 f2                	mov    %esi,%edx
  800e12:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e16:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e1a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e1e:	83 c4 1c             	add    $0x1c,%esp
  800e21:	c3                   	ret    
  800e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e28:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e2d:	89 e8                	mov    %ebp,%eax
  800e2f:	bd 20 00 00 00       	mov    $0x20,%ebp
  800e34:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	d3 e0                	shl    %cl,%eax
  800e3c:	89 e9                	mov    %ebp,%ecx
  800e3e:	d3 ea                	shr    %cl,%edx
  800e40:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e45:	09 c2                	or     %eax,%edx
  800e47:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e4b:	89 14 24             	mov    %edx,(%esp)
  800e4e:	89 f2                	mov    %esi,%edx
  800e50:	d3 e7                	shl    %cl,%edi
  800e52:	89 e9                	mov    %ebp,%ecx
  800e54:	d3 ea                	shr    %cl,%edx
  800e56:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e5f:	d3 e6                	shl    %cl,%esi
  800e61:	89 e9                	mov    %ebp,%ecx
  800e63:	d3 e8                	shr    %cl,%eax
  800e65:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e6a:	09 f0                	or     %esi,%eax
  800e6c:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e70:	f7 34 24             	divl   (%esp)
  800e73:	d3 e6                	shl    %cl,%esi
  800e75:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e79:	89 d6                	mov    %edx,%esi
  800e7b:	f7 e7                	mul    %edi
  800e7d:	39 d6                	cmp    %edx,%esi
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 d7                	mov    %edx,%edi
  800e83:	72 3f                	jb     800ec4 <__umoddi3+0x154>
  800e85:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e89:	72 35                	jb     800ec0 <__umoddi3+0x150>
  800e8b:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e8f:	29 c8                	sub    %ecx,%eax
  800e91:	19 fe                	sbb    %edi,%esi
  800e93:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e98:	89 f2                	mov    %esi,%edx
  800e9a:	d3 e8                	shr    %cl,%eax
  800e9c:	89 e9                	mov    %ebp,%ecx
  800e9e:	d3 e2                	shl    %cl,%edx
  800ea0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ea5:	09 d0                	or     %edx,%eax
  800ea7:	89 f2                	mov    %esi,%edx
  800ea9:	d3 ea                	shr    %cl,%edx
  800eab:	8b 74 24 10          	mov    0x10(%esp),%esi
  800eaf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800eb3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800eb7:	83 c4 1c             	add    $0x1c,%esp
  800eba:	c3                   	ret    
  800ebb:	90                   	nop
  800ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	39 d6                	cmp    %edx,%esi
  800ec2:	75 c7                	jne    800e8b <__umoddi3+0x11b>
  800ec4:	89 d7                	mov    %edx,%edi
  800ec6:	89 c1                	mov    %eax,%ecx
  800ec8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  800ecc:	1b 3c 24             	sbb    (%esp),%edi
  800ecf:	eb ba                	jmp    800e8b <__umoddi3+0x11b>
  800ed1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	39 f5                	cmp    %esi,%ebp
  800eda:	0f 82 f1 fe ff ff    	jb     800dd1 <__umoddi3+0x61>
  800ee0:	e9 f8 fe ff ff       	jmp    800ddd <__umoddi3+0x6d>
