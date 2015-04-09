
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs((char*)1, 1);
  80003a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800049:	e8 4e 00 00 00       	call   80009c <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	8b 45 08             	mov    0x8(%ebp),%eax
  800059:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80005c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800063:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x22>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	89 54 24 04          	mov    %edx,0x4(%esp)
  800076:	89 04 24             	mov    %eax,(%esp)
  800079:	e8 b6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007e:	e8 05 00 00 00       	call   800088 <exit>
}
  800083:	c9                   	leave  
  800084:	c3                   	ret    
  800085:	00 00                	add    %al,(%eax)
	...

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80008e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800095:	e8 61 00 00 00       	call   8000fb <sys_env_destroy>
}
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	89 c6                	mov    %eax,%esi
  8000bc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000c1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000c4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000c7:	89 ec                	mov    %ebp,%esp
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000d4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000d7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	ba 00 00 00 00       	mov    $0x0,%edx
  8000df:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e4:	89 d1                	mov    %edx,%ecx
  8000e6:	89 d3                	mov    %edx,%ebx
  8000e8:	89 d7                	mov    %edx,%edi
  8000ea:	89 d6                	mov    %edx,%esi
  8000ec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000f1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000f7:	89 ec                	mov    %ebp,%esp
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 38             	sub    $0x38,%esp
  800101:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800104:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800107:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7e 28                	jle    80014b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800123:	89 44 24 10          	mov    %eax,0x10(%esp)
  800127:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 ef 0e 80 	movl   $0x800eef,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 0c 0f 80 00 	movl   $0x800f0c,(%esp)
  800146:	e8 3d 00 00 00       	call   800188 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80014e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800151:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800154:	89 ec                	mov    %ebp,%esp
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800161:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800164:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	ba 00 00 00 00       	mov    $0x0,%edx
  80016c:	b8 02 00 00 00       	mov    $0x2,%eax
  800171:	89 d1                	mov    %edx,%ecx
  800173:	89 d3                	mov    %edx,%ebx
  800175:	89 d7                	mov    %edx,%edi
  800177:	89 d6                	mov    %edx,%esi
  800179:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80017e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800181:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800184:	89 ec                	mov    %ebp,%esp
  800186:	5d                   	pop    %ebp
  800187:	c3                   	ret    

00800188 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80018e:	a1 08 20 80 00       	mov    0x802008,%eax
  800193:	85 c0                	test   %eax,%eax
  800195:	74 10                	je     8001a7 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019b:	c7 04 24 1a 0f 80 00 	movl   $0x800f1a,(%esp)
  8001a2:	e8 e8 00 00 00       	call   80028f <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b5:	a1 00 20 80 00       	mov    0x802000,%eax
  8001ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001be:	c7 04 24 1f 0f 80 00 	movl   $0x800f1f,(%esp)
  8001c5:	e8 c5 00 00 00       	call   80028f <cprintf>
	vcprintf(fmt, ap);
  8001ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8001cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 52 00 00 00       	call   80022e <vcprintf>
	cprintf("\n");
  8001dc:	c7 04 24 3b 0f 80 00 	movl   $0x800f3b,(%esp)
  8001e3:	e8 a7 00 00 00       	call   80028f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e8:	cc                   	int3   
  8001e9:	eb fd                	jmp    8001e8 <_panic+0x60>
	...

008001ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 14             	sub    $0x14,%esp
  8001f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f6:	8b 03                	mov    (%ebx),%eax
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ff:	83 c0 01             	add    $0x1,%eax
  800202:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800204:	3d ff 00 00 00       	cmp    $0xff,%eax
  800209:	75 19                	jne    800224 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80020b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800212:	00 
  800213:	8d 43 08             	lea    0x8(%ebx),%eax
  800216:	89 04 24             	mov    %eax,(%esp)
  800219:	e8 7e fe ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  80021e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800224:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800228:	83 c4 14             	add    $0x14,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800237:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023e:	00 00 00 
	b.cnt = 0;
  800241:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800248:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	89 44 24 08          	mov    %eax,0x8(%esp)
  800259:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800263:	c7 04 24 ec 01 80 00 	movl   $0x8001ec,(%esp)
  80026a:	e8 d5 01 00 00       	call   800444 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800275:	89 44 24 04          	mov    %eax,0x4(%esp)
  800279:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	e8 15 fe ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  800287:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800295:	8d 45 0c             	lea    0xc(%ebp),%eax
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	e8 87 ff ff ff       	call   80022e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    
  8002a9:	00 00                	add    %al,(%eax)
  8002ab:	00 00                	add    %al,(%eax)
  8002ad:	00 00                	add    %al,(%eax)
	...

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 3c             	sub    $0x3c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d7                	mov    %edx,%edi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002d8:	72 11                	jb     8002eb <printnum+0x3b>
  8002da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e0:	76 09                	jbe    8002eb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e2:	83 eb 01             	sub    $0x1,%ebx
  8002e5:	85 db                	test   %ebx,%ebx
  8002e7:	7f 51                	jg     80033a <printnum+0x8a>
  8002e9:	eb 5e                	jmp    800349 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002eb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002ef:	83 eb 01             	sub    $0x1,%ebx
  8002f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800301:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800305:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030c:	00 
  80030d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031a:	e8 11 09 00 00       	call   800c30 <__udivdi3>
  80031f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800323:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032e:	89 fa                	mov    %edi,%edx
  800330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800333:	e8 78 ff ff ff       	call   8002b0 <printnum>
  800338:	eb 0f                	jmp    800349 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	89 34 24             	mov    %esi,(%esp)
  800341:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800344:	83 eb 01             	sub    $0x1,%ebx
  800347:	75 f1                	jne    80033a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800349:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80034d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800351:	8b 45 10             	mov    0x10(%ebp),%eax
  800354:	89 44 24 08          	mov    %eax,0x8(%esp)
  800358:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035f:	00 
  800360:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	e8 ee 09 00 00       	call   800d60 <__umoddi3>
  800372:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800376:	0f be 80 3d 0f 80 00 	movsbl 0x800f3d(%eax),%eax
  80037d:	89 04 24             	mov    %eax,(%esp)
  800380:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800383:	83 c4 3c             	add    $0x3c,%esp
  800386:	5b                   	pop    %ebx
  800387:	5e                   	pop    %esi
  800388:	5f                   	pop    %edi
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038e:	83 fa 01             	cmp    $0x1,%edx
  800391:	7e 0e                	jle    8003a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800393:	8b 10                	mov    (%eax),%edx
  800395:	8d 4a 08             	lea    0x8(%edx),%ecx
  800398:	89 08                	mov    %ecx,(%eax)
  80039a:	8b 02                	mov    (%edx),%eax
  80039c:	8b 52 04             	mov    0x4(%edx),%edx
  80039f:	eb 22                	jmp    8003c3 <getuint+0x38>
	else if (lflag)
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 10                	je     8003b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a5:	8b 10                	mov    (%eax),%edx
  8003a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003aa:	89 08                	mov    %ecx,(%eax)
  8003ac:	8b 02                	mov    (%edx),%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	eb 0e                	jmp    8003c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b5:	8b 10                	mov    (%eax),%edx
  8003b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ba:	89 08                	mov    %ecx,(%eax)
  8003bc:	8b 02                	mov    (%edx),%eax
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c8:	83 fa 01             	cmp    $0x1,%edx
  8003cb:	7e 0e                	jle    8003db <getint+0x16>
		return va_arg(*ap, long long);
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d2:	89 08                	mov    %ecx,(%eax)
  8003d4:	8b 02                	mov    (%edx),%eax
  8003d6:	8b 52 04             	mov    0x4(%edx),%edx
  8003d9:	eb 22                	jmp    8003fd <getint+0x38>
	else if (lflag)
  8003db:	85 d2                	test   %edx,%edx
  8003dd:	74 10                	je     8003ef <getint+0x2a>
		return va_arg(*ap, long);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	89 c2                	mov    %eax,%edx
  8003ea:	c1 fa 1f             	sar    $0x1f,%edx
  8003ed:	eb 0e                	jmp    8003fd <getint+0x38>
	else
		return va_arg(*ap, int);
  8003ef:	8b 10                	mov    (%eax),%edx
  8003f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f4:	89 08                	mov    %ecx,(%eax)
  8003f6:	8b 02                	mov    (%edx),%eax
  8003f8:	89 c2                	mov    %eax,%edx
  8003fa:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800405:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800409:	8b 10                	mov    (%eax),%edx
  80040b:	3b 50 04             	cmp    0x4(%eax),%edx
  80040e:	73 0a                	jae    80041a <sprintputch+0x1b>
		*b->buf++ = ch;
  800410:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800413:	88 0a                	mov    %cl,(%edx)
  800415:	83 c2 01             	add    $0x1,%edx
  800418:	89 10                	mov    %edx,(%eax)
}
  80041a:	5d                   	pop    %ebp
  80041b:	c3                   	ret    

0080041c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800422:	8d 45 14             	lea    0x14(%ebp),%eax
  800425:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800429:	8b 45 10             	mov    0x10(%ebp),%eax
  80042c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800430:	8b 45 0c             	mov    0xc(%ebp),%eax
  800433:	89 44 24 04          	mov    %eax,0x4(%esp)
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	e8 02 00 00 00       	call   800444 <vprintfmt>
	va_end(ap);
}
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	53                   	push   %ebx
  80044a:	83 ec 4c             	sub    $0x4c,%esp
  80044d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800450:	8b 75 10             	mov    0x10(%ebp),%esi
  800453:	eb 12                	jmp    800467 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800455:	85 c0                	test   %eax,%eax
  800457:	0f 84 98 03 00 00    	je     8007f5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80045d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800461:	89 04 24             	mov    %eax,(%esp)
  800464:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800467:	0f b6 06             	movzbl (%esi),%eax
  80046a:	83 c6 01             	add    $0x1,%esi
  80046d:	83 f8 25             	cmp    $0x25,%eax
  800470:	75 e3                	jne    800455 <vprintfmt+0x11>
  800472:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800476:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80047d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800482:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800489:	b9 00 00 00 00       	mov    $0x0,%ecx
  80048e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800491:	eb 2b                	jmp    8004be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800493:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800496:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80049a:	eb 22                	jmp    8004be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80049f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004a3:	eb 19                	jmp    8004be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004af:	eb 0d                	jmp    8004be <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	0f b6 06             	movzbl (%esi),%eax
  8004c1:	0f b6 d0             	movzbl %al,%edx
  8004c4:	8d 7e 01             	lea    0x1(%esi),%edi
  8004c7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004ca:	83 e8 23             	sub    $0x23,%eax
  8004cd:	3c 55                	cmp    $0x55,%al
  8004cf:	0f 87 fa 02 00 00    	ja     8007cf <vprintfmt+0x38b>
  8004d5:	0f b6 c0             	movzbl %al,%eax
  8004d8:	ff 24 85 cc 0f 80 00 	jmp    *0x800fcc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004df:	83 ea 30             	sub    $0x30,%edx
  8004e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004e5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004e9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 4a                	ja     80053e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004fa:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004fd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800501:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800504:	8d 50 d0             	lea    -0x30(%eax),%edx
  800507:	83 fa 09             	cmp    $0x9,%edx
  80050a:	76 eb                	jbe    8004f7 <vprintfmt+0xb3>
  80050c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050f:	eb 2d                	jmp    80053e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 04             	lea    0x4(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800522:	eb 1a                	jmp    80053e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052b:	79 91                	jns    8004be <vprintfmt+0x7a>
  80052d:	e9 73 ff ff ff       	jmp    8004a5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800535:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80053c:	eb 80                	jmp    8004be <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80053e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800542:	0f 89 76 ff ff ff    	jns    8004be <vprintfmt+0x7a>
  800548:	e9 64 ff ff ff       	jmp    8004b1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800553:	e9 66 ff ff ff       	jmp    8004be <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 04 24             	mov    %eax,(%esp)
  80056a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800570:	e9 f2 fe ff ff       	jmp    800467 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 50 04             	lea    0x4(%eax),%edx
  80057b:	89 55 14             	mov    %edx,0x14(%ebp)
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 c2                	mov    %eax,%edx
  800582:	c1 fa 1f             	sar    $0x1f,%edx
  800585:	31 d0                	xor    %edx,%eax
  800587:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800589:	83 f8 06             	cmp    $0x6,%eax
  80058c:	7f 0b                	jg     800599 <vprintfmt+0x155>
  80058e:	8b 14 85 24 11 80 00 	mov    0x801124(,%eax,4),%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	75 23                	jne    8005bc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800599:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059d:	c7 44 24 08 55 0f 80 	movl   $0x800f55,0x8(%esp)
  8005a4:	00 
  8005a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ac:	89 3c 24             	mov    %edi,(%esp)
  8005af:	e8 68 fe ff ff       	call   80041c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005b7:	e9 ab fe ff ff       	jmp    800467 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c0:	c7 44 24 08 5e 0f 80 	movl   $0x800f5e,0x8(%esp)
  8005c7:	00 
  8005c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cf:	89 3c 24             	mov    %edi,(%esp)
  8005d2:	e8 45 fe ff ff       	call   80041c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005da:	e9 88 fe ff ff       	jmp    800467 <vprintfmt+0x23>
  8005df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005f3:	85 f6                	test   %esi,%esi
  8005f5:	ba 4e 0f 80 00       	mov    $0x800f4e,%edx
  8005fa:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005fd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800601:	7e 06                	jle    800609 <vprintfmt+0x1c5>
  800603:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800607:	75 10                	jne    800619 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800609:	0f be 06             	movsbl (%esi),%eax
  80060c:	83 c6 01             	add    $0x1,%esi
  80060f:	85 c0                	test   %eax,%eax
  800611:	0f 85 86 00 00 00    	jne    80069d <vprintfmt+0x259>
  800617:	eb 76                	jmp    80068f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061d:	89 34 24             	mov    %esi,(%esp)
  800620:	e8 76 02 00 00       	call   80089b <strnlen>
  800625:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800628:	29 c2                	sub    %eax,%edx
  80062a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80062d:	85 d2                	test   %edx,%edx
  80062f:	7e d8                	jle    800609 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800631:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800635:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800638:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80063b:	89 d6                	mov    %edx,%esi
  80063d:	89 c7                	mov    %eax,%edi
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	89 3c 24             	mov    %edi,(%esp)
  800646:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800649:	83 ee 01             	sub    $0x1,%esi
  80064c:	75 f1                	jne    80063f <vprintfmt+0x1fb>
  80064e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800651:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800654:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800657:	eb b0                	jmp    800609 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800659:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80065d:	74 18                	je     800677 <vprintfmt+0x233>
  80065f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800662:	83 fa 5e             	cmp    $0x5e,%edx
  800665:	76 10                	jbe    800677 <vprintfmt+0x233>
					putch('?', putdat);
  800667:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800672:	ff 55 08             	call   *0x8(%ebp)
  800675:	eb 0a                	jmp    800681 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800677:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800681:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800685:	0f be 06             	movsbl (%esi),%eax
  800688:	83 c6 01             	add    $0x1,%esi
  80068b:	85 c0                	test   %eax,%eax
  80068d:	75 0e                	jne    80069d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800692:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800696:	7f 11                	jg     8006a9 <vprintfmt+0x265>
  800698:	e9 ca fd ff ff       	jmp    800467 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069d:	85 ff                	test   %edi,%edi
  80069f:	90                   	nop
  8006a0:	78 b7                	js     800659 <vprintfmt+0x215>
  8006a2:	83 ef 01             	sub    $0x1,%edi
  8006a5:	79 b2                	jns    800659 <vprintfmt+0x215>
  8006a7:	eb e6                	jmp    80068f <vprintfmt+0x24b>
  8006a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006ba:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ee 01             	sub    $0x1,%esi
  8006bf:	75 ee                	jne    8006af <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c4:	e9 9e fd ff ff       	jmp    800467 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 f2 fc ff ff       	call   8003c5 <getint>
  8006d3:	89 c6                	mov    %eax,%esi
  8006d5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	0f 89 ad 00 00 00    	jns    800791 <vprintfmt+0x34d>
				putch('-', putdat);
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f2:	f7 de                	neg    %esi
  8006f4:	83 d7 00             	adc    $0x0,%edi
  8006f7:	f7 df                	neg    %edi
			}
			base = 10;
  8006f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fe:	e9 8e 00 00 00       	jmp    800791 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800703:	89 ca                	mov    %ecx,%edx
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 7e fc ff ff       	call   80038b <getuint>
  80070d:	89 c6                	mov    %eax,%esi
  80070f:	89 d7                	mov    %edx,%edi
			base = 10;
  800711:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800716:	eb 79                	jmp    800791 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800718:	89 ca                	mov    %ecx,%edx
  80071a:	8d 45 14             	lea    0x14(%ebp),%eax
  80071d:	e8 a3 fc ff ff       	call   8003c5 <getint>
  800722:	89 c6                	mov    %eax,%esi
  800724:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800726:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80072b:	85 d2                	test   %edx,%edx
  80072d:	79 62                	jns    800791 <vprintfmt+0x34d>
				putch('-', putdat);
  80072f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800733:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80073a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80073d:	f7 de                	neg    %esi
  80073f:	83 d7 00             	adc    $0x0,%edi
  800742:	f7 df                	neg    %edi
			}
			base = 8;
  800744:	b8 08 00 00 00       	mov    $0x8,%eax
  800749:	eb 46                	jmp    800791 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80074b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800756:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800759:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800764:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 50 04             	lea    0x4(%eax),%edx
  80076d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800770:	8b 30                	mov    (%eax),%esi
  800772:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800777:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80077c:	eb 13                	jmp    800791 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80077e:	89 ca                	mov    %ecx,%edx
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
  800783:	e8 03 fc ff ff       	call   80038b <getuint>
  800788:	89 c6                	mov    %eax,%esi
  80078a:	89 d7                	mov    %edx,%edi
			base = 16;
  80078c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800791:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800795:	89 54 24 10          	mov    %edx,0x10(%esp)
  800799:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a4:	89 34 24             	mov    %esi,(%esp)
  8007a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ab:	89 da                	mov    %ebx,%edx
  8007ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b0:	e8 fb fa ff ff       	call   8002b0 <printnum>
			break;
  8007b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007b8:	e9 aa fc ff ff       	jmp    800467 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c1:	89 14 24             	mov    %edx,(%esp)
  8007c4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ca:	e9 98 fc ff ff       	jmp    800467 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007da:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e1:	0f 84 80 fc ff ff    	je     800467 <vprintfmt+0x23>
  8007e7:	83 ee 01             	sub    $0x1,%esi
  8007ea:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ee:	75 f7                	jne    8007e7 <vprintfmt+0x3a3>
  8007f0:	e9 72 fc ff ff       	jmp    800467 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007f5:	83 c4 4c             	add    $0x4c,%esp
  8007f8:	5b                   	pop    %ebx
  8007f9:	5e                   	pop    %esi
  8007fa:	5f                   	pop    %edi
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 28             	sub    $0x28,%esp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800809:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800810:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800813:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081a:	85 c0                	test   %eax,%eax
  80081c:	74 30                	je     80084e <vsnprintf+0x51>
  80081e:	85 d2                	test   %edx,%edx
  800820:	7e 2c                	jle    80084e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800829:	8b 45 10             	mov    0x10(%ebp),%eax
  80082c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800830:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800833:	89 44 24 04          	mov    %eax,0x4(%esp)
  800837:	c7 04 24 ff 03 80 00 	movl   $0x8003ff,(%esp)
  80083e:	e8 01 fc ff ff       	call   800444 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800843:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800846:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800849:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084c:	eb 05                	jmp    800853 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80084e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
  80085e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800862:	8b 45 10             	mov    0x10(%ebp),%eax
  800865:	89 44 24 08          	mov    %eax,0x8(%esp)
  800869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	89 04 24             	mov    %eax,(%esp)
  800876:	e8 82 ff ff ff       	call   8007fd <vsnprintf>
	va_end(ap);

	return rc;
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    
  80087d:	00 00                	add    %al,(%eax)
	...

00800880 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	80 3a 00             	cmpb   $0x0,(%edx)
  80088e:	74 09                	je     800899 <strlen+0x19>
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	75 f7                	jne    800890 <strlen+0x10>
		n++;
	return n;
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008aa:	85 c9                	test   %ecx,%ecx
  8008ac:	74 1a                	je     8008c8 <strnlen+0x2d>
  8008ae:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008b1:	74 15                	je     8008c8 <strnlen+0x2d>
  8008b3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008b8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ba:	39 ca                	cmp    %ecx,%edx
  8008bc:	74 0a                	je     8008c8 <strnlen+0x2d>
  8008be:	83 c2 01             	add    $0x1,%edx
  8008c1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008c6:	75 f0                	jne    8008b8 <strnlen+0x1d>
		n++;
	return n;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008da:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008de:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e1:	83 c2 01             	add    $0x1,%edx
  8008e4:	84 c9                	test   %cl,%cl
  8008e6:	75 f2                	jne    8008da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	85 f6                	test   %esi,%esi
  8008fb:	74 18                	je     800915 <strncpy+0x2a>
  8008fd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800902:	0f b6 1a             	movzbl (%edx),%ebx
  800905:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800908:	80 3a 01             	cmpb   $0x1,(%edx)
  80090b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090e:	83 c1 01             	add    $0x1,%ecx
  800911:	39 f1                	cmp    %esi,%ecx
  800913:	75 ed                	jne    800902 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	57                   	push   %edi
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800925:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800928:	89 f8                	mov    %edi,%eax
  80092a:	85 f6                	test   %esi,%esi
  80092c:	74 2b                	je     800959 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80092e:	83 fe 01             	cmp    $0x1,%esi
  800931:	74 23                	je     800956 <strlcpy+0x3d>
  800933:	0f b6 0b             	movzbl (%ebx),%ecx
  800936:	84 c9                	test   %cl,%cl
  800938:	74 1c                	je     800956 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80093a:	83 ee 02             	sub    $0x2,%esi
  80093d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800942:	88 08                	mov    %cl,(%eax)
  800944:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800947:	39 f2                	cmp    %esi,%edx
  800949:	74 0b                	je     800956 <strlcpy+0x3d>
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800952:	84 c9                	test   %cl,%cl
  800954:	75 ec                	jne    800942 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800956:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800959:	29 f8                	sub    %edi,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800966:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800969:	0f b6 01             	movzbl (%ecx),%eax
  80096c:	84 c0                	test   %al,%al
  80096e:	74 16                	je     800986 <strcmp+0x26>
  800970:	3a 02                	cmp    (%edx),%al
  800972:	75 12                	jne    800986 <strcmp+0x26>
		p++, q++;
  800974:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800977:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80097b:	84 c0                	test   %al,%al
  80097d:	74 07                	je     800986 <strcmp+0x26>
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	3a 02                	cmp    (%edx),%al
  800984:	74 ee                	je     800974 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80099a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a2:	85 d2                	test   %edx,%edx
  8009a4:	74 28                	je     8009ce <strncmp+0x3e>
  8009a6:	0f b6 01             	movzbl (%ecx),%eax
  8009a9:	84 c0                	test   %al,%al
  8009ab:	74 24                	je     8009d1 <strncmp+0x41>
  8009ad:	3a 03                	cmp    (%ebx),%al
  8009af:	75 20                	jne    8009d1 <strncmp+0x41>
  8009b1:	83 ea 01             	sub    $0x1,%edx
  8009b4:	74 13                	je     8009c9 <strncmp+0x39>
		n--, p++, q++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009bc:	0f b6 01             	movzbl (%ecx),%eax
  8009bf:	84 c0                	test   %al,%al
  8009c1:	74 0e                	je     8009d1 <strncmp+0x41>
  8009c3:	3a 03                	cmp    (%ebx),%al
  8009c5:	74 ea                	je     8009b1 <strncmp+0x21>
  8009c7:	eb 08                	jmp    8009d1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d1:	0f b6 01             	movzbl (%ecx),%eax
  8009d4:	0f b6 13             	movzbl (%ebx),%edx
  8009d7:	29 d0                	sub    %edx,%eax
  8009d9:	eb f3                	jmp    8009ce <strncmp+0x3e>

008009db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	74 1c                	je     800a08 <strchr+0x2d>
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	75 09                	jne    8009f9 <strchr+0x1e>
  8009f0:	eb 1b                	jmp    800a0d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	74 14                	je     800a0d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009fd:	84 d2                	test   %dl,%dl
  8009ff:	75 f1                	jne    8009f2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
  800a06:	eb 05                	jmp    800a0d <strchr+0x32>
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a19:	0f b6 10             	movzbl (%eax),%edx
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	74 14                	je     800a34 <strfind+0x25>
		if (*s == c)
  800a20:	38 ca                	cmp    %cl,%dl
  800a22:	75 06                	jne    800a2a <strfind+0x1b>
  800a24:	eb 0e                	jmp    800a34 <strfind+0x25>
  800a26:	38 ca                	cmp    %cl,%dl
  800a28:	74 0a                	je     800a34 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 f2                	jne    800a26 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	53                   	push   %ebx
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a43:	89 da                	mov    %ebx,%edx
  800a45:	83 ea 01             	sub    $0x1,%edx
  800a48:	78 0d                	js     800a57 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a4a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800a4c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a4e:	88 0a                	mov    %cl,(%edx)
  800a50:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a53:	39 da                	cmp    %ebx,%edx
  800a55:	75 f7                	jne    800a4e <memset+0x18>
		*p++ = c;

	return v;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	57                   	push   %edi
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a69:	39 c6                	cmp    %eax,%esi
  800a6b:	72 0b                	jb     800a78 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	85 db                	test   %ebx,%ebx
  800a74:	75 29                	jne    800a9f <memmove+0x45>
  800a76:	eb 35                	jmp    800aad <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a78:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800a7b:	39 c8                	cmp    %ecx,%eax
  800a7d:	73 ee                	jae    800a6d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800a7f:	85 db                	test   %ebx,%ebx
  800a81:	74 2a                	je     800aad <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a83:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800a86:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800a88:	f7 db                	neg    %ebx
  800a8a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800a8d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800a8f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a94:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a98:	83 ea 01             	sub    $0x1,%edx
  800a9b:	75 f2                	jne    800a8f <memmove+0x35>
  800a9d:	eb 0e                	jmp    800aad <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a9f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800aa3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800aa6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800aa9:	39 d3                	cmp    %edx,%ebx
  800aab:	75 f2                	jne    800a9f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab8:	8b 45 10             	mov    0x10(%ebp),%eax
  800abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	89 04 24             	mov    %eax,(%esp)
  800acc:	e8 89 ff ff ff       	call   800a5a <memmove>
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae7:	85 ff                	test   %edi,%edi
  800ae9:	74 37                	je     800b22 <memcmp+0x4f>
		if (*s1 != *s2)
  800aeb:	0f b6 03             	movzbl (%ebx),%eax
  800aee:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af1:	83 ef 01             	sub    $0x1,%edi
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800af9:	38 c8                	cmp    %cl,%al
  800afb:	74 1c                	je     800b19 <memcmp+0x46>
  800afd:	eb 10                	jmp    800b0f <memcmp+0x3c>
  800aff:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b04:	83 c2 01             	add    $0x1,%edx
  800b07:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b0b:	38 c8                	cmp    %cl,%al
  800b0d:	74 0a                	je     800b19 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b0f:	0f b6 c0             	movzbl %al,%eax
  800b12:	0f b6 c9             	movzbl %cl,%ecx
  800b15:	29 c8                	sub    %ecx,%eax
  800b17:	eb 09                	jmp    800b22 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b19:	39 fa                	cmp    %edi,%edx
  800b1b:	75 e2                	jne    800aff <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b32:	39 d0                	cmp    %edx,%eax
  800b34:	73 15                	jae    800b4b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b3a:	38 08                	cmp    %cl,(%eax)
  800b3c:	75 06                	jne    800b44 <memfind+0x1d>
  800b3e:	eb 0b                	jmp    800b4b <memfind+0x24>
  800b40:	38 08                	cmp    %cl,(%eax)
  800b42:	74 07                	je     800b4b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b44:	83 c0 01             	add    $0x1,%eax
  800b47:	39 d0                	cmp    %edx,%eax
  800b49:	75 f5                	jne    800b40 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b59:	0f b6 02             	movzbl (%edx),%eax
  800b5c:	3c 20                	cmp    $0x20,%al
  800b5e:	74 04                	je     800b64 <strtol+0x17>
  800b60:	3c 09                	cmp    $0x9,%al
  800b62:	75 0e                	jne    800b72 <strtol+0x25>
		s++;
  800b64:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b67:	0f b6 02             	movzbl (%edx),%eax
  800b6a:	3c 20                	cmp    $0x20,%al
  800b6c:	74 f6                	je     800b64 <strtol+0x17>
  800b6e:	3c 09                	cmp    $0x9,%al
  800b70:	74 f2                	je     800b64 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b72:	3c 2b                	cmp    $0x2b,%al
  800b74:	75 0a                	jne    800b80 <strtol+0x33>
		s++;
  800b76:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b79:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7e:	eb 10                	jmp    800b90 <strtol+0x43>
  800b80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b85:	3c 2d                	cmp    $0x2d,%al
  800b87:	75 07                	jne    800b90 <strtol+0x43>
		s++, neg = 1;
  800b89:	83 c2 01             	add    $0x1,%edx
  800b8c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b90:	85 db                	test   %ebx,%ebx
  800b92:	0f 94 c0             	sete   %al
  800b95:	74 05                	je     800b9c <strtol+0x4f>
  800b97:	83 fb 10             	cmp    $0x10,%ebx
  800b9a:	75 15                	jne    800bb1 <strtol+0x64>
  800b9c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9f:	75 10                	jne    800bb1 <strtol+0x64>
  800ba1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba5:	75 0a                	jne    800bb1 <strtol+0x64>
		s += 2, base = 16;
  800ba7:	83 c2 02             	add    $0x2,%edx
  800baa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800baf:	eb 13                	jmp    800bc4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800bb1:	84 c0                	test   %al,%al
  800bb3:	74 0f                	je     800bc4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bba:	80 3a 30             	cmpb   $0x30,(%edx)
  800bbd:	75 05                	jne    800bc4 <strtol+0x77>
		s++, base = 8;
  800bbf:	83 c2 01             	add    $0x1,%edx
  800bc2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bcb:	0f b6 0a             	movzbl (%edx),%ecx
  800bce:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bd1:	80 fb 09             	cmp    $0x9,%bl
  800bd4:	77 08                	ja     800bde <strtol+0x91>
			dig = *s - '0';
  800bd6:	0f be c9             	movsbl %cl,%ecx
  800bd9:	83 e9 30             	sub    $0x30,%ecx
  800bdc:	eb 1e                	jmp    800bfc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bde:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 08                	ja     800bee <strtol+0xa1>
			dig = *s - 'a' + 10;
  800be6:	0f be c9             	movsbl %cl,%ecx
  800be9:	83 e9 57             	sub    $0x57,%ecx
  800bec:	eb 0e                	jmp    800bfc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800bee:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bf1:	80 fb 19             	cmp    $0x19,%bl
  800bf4:	77 14                	ja     800c0a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bf6:	0f be c9             	movsbl %cl,%ecx
  800bf9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bfc:	39 f1                	cmp    %esi,%ecx
  800bfe:	7d 0e                	jge    800c0e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c00:	83 c2 01             	add    $0x1,%edx
  800c03:	0f af c6             	imul   %esi,%eax
  800c06:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c08:	eb c1                	jmp    800bcb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c0a:	89 c1                	mov    %eax,%ecx
  800c0c:	eb 02                	jmp    800c10 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c0e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c14:	74 05                	je     800c1b <strtol+0xce>
		*endptr = (char *) s;
  800c16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c19:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c1b:	89 ca                	mov    %ecx,%edx
  800c1d:	f7 da                	neg    %edx
  800c1f:	85 ff                	test   %edi,%edi
  800c21:	0f 45 c2             	cmovne %edx,%eax
}
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    
  800c29:	00 00                	add    %al,(%eax)
  800c2b:	00 00                	add    %al,(%eax)
  800c2d:	00 00                	add    %al,(%eax)
	...

00800c30 <__udivdi3>:
  800c30:	83 ec 1c             	sub    $0x1c,%esp
  800c33:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800c37:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800c3b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800c3f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800c43:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c47:	8b 74 24 24          	mov    0x24(%esp),%esi
  800c4b:	85 ff                	test   %edi,%edi
  800c4d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800c51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c55:	89 cd                	mov    %ecx,%ebp
  800c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5b:	75 33                	jne    800c90 <__udivdi3+0x60>
  800c5d:	39 f1                	cmp    %esi,%ecx
  800c5f:	77 57                	ja     800cb8 <__udivdi3+0x88>
  800c61:	85 c9                	test   %ecx,%ecx
  800c63:	75 0b                	jne    800c70 <__udivdi3+0x40>
  800c65:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6a:	31 d2                	xor    %edx,%edx
  800c6c:	f7 f1                	div    %ecx
  800c6e:	89 c1                	mov    %eax,%ecx
  800c70:	89 f0                	mov    %esi,%eax
  800c72:	31 d2                	xor    %edx,%edx
  800c74:	f7 f1                	div    %ecx
  800c76:	89 c6                	mov    %eax,%esi
  800c78:	8b 44 24 04          	mov    0x4(%esp),%eax
  800c7c:	f7 f1                	div    %ecx
  800c7e:	89 f2                	mov    %esi,%edx
  800c80:	8b 74 24 10          	mov    0x10(%esp),%esi
  800c84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800c88:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800c8c:	83 c4 1c             	add    $0x1c,%esp
  800c8f:	c3                   	ret    
  800c90:	31 d2                	xor    %edx,%edx
  800c92:	31 c0                	xor    %eax,%eax
  800c94:	39 f7                	cmp    %esi,%edi
  800c96:	77 e8                	ja     800c80 <__udivdi3+0x50>
  800c98:	0f bd cf             	bsr    %edi,%ecx
  800c9b:	83 f1 1f             	xor    $0x1f,%ecx
  800c9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ca2:	75 2c                	jne    800cd0 <__udivdi3+0xa0>
  800ca4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800ca8:	76 04                	jbe    800cae <__udivdi3+0x7e>
  800caa:	39 f7                	cmp    %esi,%edi
  800cac:	73 d2                	jae    800c80 <__udivdi3+0x50>
  800cae:	31 d2                	xor    %edx,%edx
  800cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb5:	eb c9                	jmp    800c80 <__udivdi3+0x50>
  800cb7:	90                   	nop
  800cb8:	89 f2                	mov    %esi,%edx
  800cba:	f7 f1                	div    %ecx
  800cbc:	31 d2                	xor    %edx,%edx
  800cbe:	8b 74 24 10          	mov    0x10(%esp),%esi
  800cc2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800cc6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800cca:	83 c4 1c             	add    $0x1c,%esp
  800ccd:	c3                   	ret    
  800cce:	66 90                	xchg   %ax,%ax
  800cd0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800cd5:	b8 20 00 00 00       	mov    $0x20,%eax
  800cda:	89 ea                	mov    %ebp,%edx
  800cdc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800ce0:	d3 e7                	shl    %cl,%edi
  800ce2:	89 c1                	mov    %eax,%ecx
  800ce4:	d3 ea                	shr    %cl,%edx
  800ce6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ceb:	09 fa                	or     %edi,%edx
  800ced:	89 f7                	mov    %esi,%edi
  800cef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800cf3:	89 f2                	mov    %esi,%edx
  800cf5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800cf9:	d3 e5                	shl    %cl,%ebp
  800cfb:	89 c1                	mov    %eax,%ecx
  800cfd:	d3 ef                	shr    %cl,%edi
  800cff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d04:	d3 e2                	shl    %cl,%edx
  800d06:	89 c1                	mov    %eax,%ecx
  800d08:	d3 ee                	shr    %cl,%esi
  800d0a:	09 d6                	or     %edx,%esi
  800d0c:	89 fa                	mov    %edi,%edx
  800d0e:	89 f0                	mov    %esi,%eax
  800d10:	f7 74 24 0c          	divl   0xc(%esp)
  800d14:	89 d7                	mov    %edx,%edi
  800d16:	89 c6                	mov    %eax,%esi
  800d18:	f7 e5                	mul    %ebp
  800d1a:	39 d7                	cmp    %edx,%edi
  800d1c:	72 22                	jb     800d40 <__udivdi3+0x110>
  800d1e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800d22:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d27:	d3 e5                	shl    %cl,%ebp
  800d29:	39 c5                	cmp    %eax,%ebp
  800d2b:	73 04                	jae    800d31 <__udivdi3+0x101>
  800d2d:	39 d7                	cmp    %edx,%edi
  800d2f:	74 0f                	je     800d40 <__udivdi3+0x110>
  800d31:	89 f0                	mov    %esi,%eax
  800d33:	31 d2                	xor    %edx,%edx
  800d35:	e9 46 ff ff ff       	jmp    800c80 <__udivdi3+0x50>
  800d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d40:	8d 46 ff             	lea    -0x1(%esi),%eax
  800d43:	31 d2                	xor    %edx,%edx
  800d45:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d49:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800d4d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800d51:	83 c4 1c             	add    $0x1c,%esp
  800d54:	c3                   	ret    
	...

00800d60 <__umoddi3>:
  800d60:	83 ec 1c             	sub    $0x1c,%esp
  800d63:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800d67:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800d6b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800d6f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d73:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d77:	8b 74 24 24          	mov    0x24(%esp),%esi
  800d7b:	85 ed                	test   %ebp,%ebp
  800d7d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800d81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d85:	89 cf                	mov    %ecx,%edi
  800d87:	89 04 24             	mov    %eax,(%esp)
  800d8a:	89 f2                	mov    %esi,%edx
  800d8c:	75 1a                	jne    800da8 <__umoddi3+0x48>
  800d8e:	39 f1                	cmp    %esi,%ecx
  800d90:	76 4e                	jbe    800de0 <__umoddi3+0x80>
  800d92:	f7 f1                	div    %ecx
  800d94:	89 d0                	mov    %edx,%eax
  800d96:	31 d2                	xor    %edx,%edx
  800d98:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d9c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800da0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800da4:	83 c4 1c             	add    $0x1c,%esp
  800da7:	c3                   	ret    
  800da8:	39 f5                	cmp    %esi,%ebp
  800daa:	77 54                	ja     800e00 <__umoddi3+0xa0>
  800dac:	0f bd c5             	bsr    %ebp,%eax
  800daf:	83 f0 1f             	xor    $0x1f,%eax
  800db2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db6:	75 60                	jne    800e18 <__umoddi3+0xb8>
  800db8:	3b 0c 24             	cmp    (%esp),%ecx
  800dbb:	0f 87 07 01 00 00    	ja     800ec8 <__umoddi3+0x168>
  800dc1:	89 f2                	mov    %esi,%edx
  800dc3:	8b 34 24             	mov    (%esp),%esi
  800dc6:	29 ce                	sub    %ecx,%esi
  800dc8:	19 ea                	sbb    %ebp,%edx
  800dca:	89 34 24             	mov    %esi,(%esp)
  800dcd:	8b 04 24             	mov    (%esp),%eax
  800dd0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800dd4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800dd8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ddc:	83 c4 1c             	add    $0x1c,%esp
  800ddf:	c3                   	ret    
  800de0:	85 c9                	test   %ecx,%ecx
  800de2:	75 0b                	jne    800def <__umoddi3+0x8f>
  800de4:	b8 01 00 00 00       	mov    $0x1,%eax
  800de9:	31 d2                	xor    %edx,%edx
  800deb:	f7 f1                	div    %ecx
  800ded:	89 c1                	mov    %eax,%ecx
  800def:	89 f0                	mov    %esi,%eax
  800df1:	31 d2                	xor    %edx,%edx
  800df3:	f7 f1                	div    %ecx
  800df5:	8b 04 24             	mov    (%esp),%eax
  800df8:	f7 f1                	div    %ecx
  800dfa:	eb 98                	jmp    800d94 <__umoddi3+0x34>
  800dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 f2                	mov    %esi,%edx
  800e02:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e06:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e0a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e0e:	83 c4 1c             	add    $0x1c,%esp
  800e11:	c3                   	ret    
  800e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e18:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e1d:	89 e8                	mov    %ebp,%eax
  800e1f:	bd 20 00 00 00       	mov    $0x20,%ebp
  800e24:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	d3 e0                	shl    %cl,%eax
  800e2c:	89 e9                	mov    %ebp,%ecx
  800e2e:	d3 ea                	shr    %cl,%edx
  800e30:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e35:	09 c2                	or     %eax,%edx
  800e37:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e3b:	89 14 24             	mov    %edx,(%esp)
  800e3e:	89 f2                	mov    %esi,%edx
  800e40:	d3 e7                	shl    %cl,%edi
  800e42:	89 e9                	mov    %ebp,%ecx
  800e44:	d3 ea                	shr    %cl,%edx
  800e46:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e4f:	d3 e6                	shl    %cl,%esi
  800e51:	89 e9                	mov    %ebp,%ecx
  800e53:	d3 e8                	shr    %cl,%eax
  800e55:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e5a:	09 f0                	or     %esi,%eax
  800e5c:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e60:	f7 34 24             	divl   (%esp)
  800e63:	d3 e6                	shl    %cl,%esi
  800e65:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e69:	89 d6                	mov    %edx,%esi
  800e6b:	f7 e7                	mul    %edi
  800e6d:	39 d6                	cmp    %edx,%esi
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	89 d7                	mov    %edx,%edi
  800e73:	72 3f                	jb     800eb4 <__umoddi3+0x154>
  800e75:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e79:	72 35                	jb     800eb0 <__umoddi3+0x150>
  800e7b:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e7f:	29 c8                	sub    %ecx,%eax
  800e81:	19 fe                	sbb    %edi,%esi
  800e83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e88:	89 f2                	mov    %esi,%edx
  800e8a:	d3 e8                	shr    %cl,%eax
  800e8c:	89 e9                	mov    %ebp,%ecx
  800e8e:	d3 e2                	shl    %cl,%edx
  800e90:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e95:	09 d0                	or     %edx,%eax
  800e97:	89 f2                	mov    %esi,%edx
  800e99:	d3 ea                	shr    %cl,%edx
  800e9b:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e9f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ea3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ea7:	83 c4 1c             	add    $0x1c,%esp
  800eaa:	c3                   	ret    
  800eab:	90                   	nop
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	39 d6                	cmp    %edx,%esi
  800eb2:	75 c7                	jne    800e7b <__umoddi3+0x11b>
  800eb4:	89 d7                	mov    %edx,%edi
  800eb6:	89 c1                	mov    %eax,%ecx
  800eb8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  800ebc:	1b 3c 24             	sbb    (%esp),%edi
  800ebf:	eb ba                	jmp    800e7b <__umoddi3+0x11b>
  800ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	39 f5                	cmp    %esi,%ebp
  800eca:	0f 82 f1 fe ff ff    	jb     800dc1 <__umoddi3+0x61>
  800ed0:	e9 f8 fe ff ff       	jmp    800dcd <__umoddi3+0x6d>
