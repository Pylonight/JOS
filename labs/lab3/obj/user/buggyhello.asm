
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
  800049:	e8 66 00 00 00       	call   8000b4 <sys_cputs>
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
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  800062:	e8 09 01 00 00       	call   800170 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	6b c0 64             	imul   $0x64,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 61 00 00 00       	call   800113 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 0c             	sub    $0xc,%esp
  8000ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000dc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fc:	89 d1                	mov    %edx,%ecx
  8000fe:	89 d3                	mov    %edx,%ebx
  800100:	89 d7                	mov    %edx,%edi
  800102:	89 d6                	mov    %edx,%esi
  800104:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800106:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800109:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80010c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 38             	sub    $0x38,%esp
  800119:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80011c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	b9 00 00 00 00       	mov    $0x0,%ecx
  800127:	b8 03 00 00 00       	mov    $0x3,%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	89 cb                	mov    %ecx,%ebx
  800131:	89 cf                	mov    %ecx,%edi
  800133:	89 ce                	mov    %ecx,%esi
  800135:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800137:	85 c0                	test   %eax,%eax
  800139:	7e 28                	jle    800163 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80013b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800146:	00 
  800147:	c7 44 24 08 0f 0f 80 	movl   $0x800f0f,0x8(%esp)
  80014e:	00 
  80014f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800156:	00 
  800157:	c7 04 24 2c 0f 80 00 	movl   $0x800f2c,(%esp)
  80015e:	e8 3d 00 00 00       	call   8001a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800163:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800166:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800169:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80016c:	89 ec                	mov    %ebp,%esp
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 0c             	sub    $0xc,%esp
  800176:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800179:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80017c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017f:	ba 00 00 00 00       	mov    $0x0,%edx
  800184:	b8 02 00 00 00       	mov    $0x2,%eax
  800189:	89 d1                	mov    %edx,%ecx
  80018b:	89 d3                	mov    %edx,%ebx
  80018d:	89 d7                	mov    %edx,%edi
  80018f:	89 d6                	mov    %edx,%esi
  800191:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800193:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800196:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800199:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80019c:	89 ec                	mov    %ebp,%esp
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8001a6:	a1 08 20 80 00       	mov    0x802008,%eax
  8001ab:	85 c0                	test   %eax,%eax
  8001ad:	74 10                	je     8001bf <_panic+0x1f>
		cprintf("%s: ", argv0);
  8001af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b3:	c7 04 24 3a 0f 80 00 	movl   $0x800f3a,(%esp)
  8001ba:	e8 e8 00 00 00       	call   8002a7 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8001bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cd:	a1 00 20 80 00       	mov    0x802000,%eax
  8001d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d6:	c7 04 24 3f 0f 80 00 	movl   $0x800f3f,(%esp)
  8001dd:	e8 c5 00 00 00       	call   8002a7 <cprintf>
	vcprintf(fmt, ap);
  8001e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ec:	89 04 24             	mov    %eax,(%esp)
  8001ef:	e8 52 00 00 00       	call   800246 <vcprintf>
	cprintf("\n");
  8001f4:	c7 04 24 5b 0f 80 00 	movl   $0x800f5b,(%esp)
  8001fb:	e8 a7 00 00 00       	call   8002a7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800200:	cc                   	int3   
  800201:	eb fd                	jmp    800200 <_panic+0x60>
	...

00800204 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	53                   	push   %ebx
  800208:	83 ec 14             	sub    $0x14,%esp
  80020b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80020e:	8b 03                	mov    (%ebx),%eax
  800210:	8b 55 08             	mov    0x8(%ebp),%edx
  800213:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800217:	83 c0 01             	add    $0x1,%eax
  80021a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80021c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800221:	75 19                	jne    80023c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800223:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80022a:	00 
  80022b:	8d 43 08             	lea    0x8(%ebx),%eax
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	e8 7e fe ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  800236:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80023c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800240:	83 c4 14             	add    $0x14,%esp
  800243:	5b                   	pop    %ebx
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80024f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800256:	00 00 00 
	b.cnt = 0;
  800259:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800260:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800263:	8b 45 0c             	mov    0xc(%ebp),%eax
  800266:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800271:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027b:	c7 04 24 04 02 80 00 	movl   $0x800204,(%esp)
  800282:	e8 dd 01 00 00       	call   800464 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800287:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80028d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800291:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800297:	89 04 24             	mov    %eax,(%esp)
  80029a:	e8 15 fe ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80029f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002ad:	8d 45 0c             	lea    0xc(%ebp),%eax
  8002b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	e8 87 ff ff ff       	call   800246 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002bf:	c9                   	leave  
  8002c0:	c3                   	ret    
	...

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 3c             	sub    $0x3c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d7                	mov    %edx,%edi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002f8:	72 11                	jb     80030b <printnum+0x3b>
  8002fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	76 09                	jbe    80030b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800302:	83 eb 01             	sub    $0x1,%ebx
  800305:	85 db                	test   %ebx,%ebx
  800307:	7f 51                	jg     80035a <printnum+0x8a>
  800309:	eb 5e                	jmp    800369 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80030f:	83 eb 01             	sub    $0x1,%ebx
  800312:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800316:	8b 45 10             	mov    0x10(%ebp),%eax
  800319:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800321:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800325:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032c:	00 
  80032d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800336:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033a:	e8 11 09 00 00       	call   800c50 <__udivdi3>
  80033f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800343:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800347:	89 04 24             	mov    %eax,(%esp)
  80034a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034e:	89 fa                	mov    %edi,%edx
  800350:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800353:	e8 78 ff ff ff       	call   8002d0 <printnum>
  800358:	eb 0f                	jmp    800369 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80035a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035e:	89 34 24             	mov    %esi,(%esp)
  800361:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800364:	83 eb 01             	sub    $0x1,%ebx
  800367:	75 f1                	jne    80035a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800369:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800371:	8b 45 10             	mov    0x10(%ebp),%eax
  800374:	89 44 24 08          	mov    %eax,0x8(%esp)
  800378:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037f:	00 
  800380:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800383:	89 04 24             	mov    %eax,(%esp)
  800386:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038d:	e8 ee 09 00 00       	call   800d80 <__umoddi3>
  800392:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800396:	0f be 80 5d 0f 80 00 	movsbl 0x800f5d(%eax),%eax
  80039d:	89 04 24             	mov    %eax,(%esp)
  8003a0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003a3:	83 c4 3c             	add    $0x3c,%esp
  8003a6:	5b                   	pop    %ebx
  8003a7:	5e                   	pop    %esi
  8003a8:	5f                   	pop    %edi
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ae:	83 fa 01             	cmp    $0x1,%edx
  8003b1:	7e 0e                	jle    8003c1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b8:	89 08                	mov    %ecx,(%eax)
  8003ba:	8b 02                	mov    (%edx),%eax
  8003bc:	8b 52 04             	mov    0x4(%edx),%edx
  8003bf:	eb 22                	jmp    8003e3 <getuint+0x38>
	else if (lflag)
  8003c1:	85 d2                	test   %edx,%edx
  8003c3:	74 10                	je     8003d5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ca:	89 08                	mov    %ecx,(%eax)
  8003cc:	8b 02                	mov    (%edx),%eax
  8003ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d3:	eb 0e                	jmp    8003e3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d5:	8b 10                	mov    (%eax),%edx
  8003d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003da:	89 08                	mov    %ecx,(%eax)
  8003dc:	8b 02                	mov    (%edx),%eax
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e8:	83 fa 01             	cmp    $0x1,%edx
  8003eb:	7e 0e                	jle    8003fb <getint+0x16>
		return va_arg(*ap, long long);
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003f2:	89 08                	mov    %ecx,(%eax)
  8003f4:	8b 02                	mov    (%edx),%eax
  8003f6:	8b 52 04             	mov    0x4(%edx),%edx
  8003f9:	eb 22                	jmp    80041d <getint+0x38>
	else if (lflag)
  8003fb:	85 d2                	test   %edx,%edx
  8003fd:	74 10                	je     80040f <getint+0x2a>
		return va_arg(*ap, long);
  8003ff:	8b 10                	mov    (%eax),%edx
  800401:	8d 4a 04             	lea    0x4(%edx),%ecx
  800404:	89 08                	mov    %ecx,(%eax)
  800406:	8b 02                	mov    (%edx),%eax
  800408:	89 c2                	mov    %eax,%edx
  80040a:	c1 fa 1f             	sar    $0x1f,%edx
  80040d:	eb 0e                	jmp    80041d <getint+0x38>
	else
		return va_arg(*ap, int);
  80040f:	8b 10                	mov    (%eax),%edx
  800411:	8d 4a 04             	lea    0x4(%edx),%ecx
  800414:	89 08                	mov    %ecx,(%eax)
  800416:	8b 02                	mov    (%edx),%eax
  800418:	89 c2                	mov    %eax,%edx
  80041a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80041d:	5d                   	pop    %ebp
  80041e:	c3                   	ret    

0080041f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800425:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800429:	8b 10                	mov    (%eax),%edx
  80042b:	3b 50 04             	cmp    0x4(%eax),%edx
  80042e:	73 0a                	jae    80043a <sprintputch+0x1b>
		*b->buf++ = ch;
  800430:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800433:	88 0a                	mov    %cl,(%edx)
  800435:	83 c2 01             	add    $0x1,%edx
  800438:	89 10                	mov    %edx,(%eax)
}
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800442:	8d 45 14             	lea    0x14(%ebp),%eax
  800445:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800449:	8b 45 10             	mov    0x10(%ebp),%eax
  80044c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800450:	8b 45 0c             	mov    0xc(%ebp),%eax
  800453:	89 44 24 04          	mov    %eax,0x4(%esp)
  800457:	8b 45 08             	mov    0x8(%ebp),%eax
  80045a:	89 04 24             	mov    %eax,(%esp)
  80045d:	e8 02 00 00 00       	call   800464 <vprintfmt>
	va_end(ap);
}
  800462:	c9                   	leave  
  800463:	c3                   	ret    

00800464 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	57                   	push   %edi
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	83 ec 4c             	sub    $0x4c,%esp
  80046d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800470:	8b 75 10             	mov    0x10(%ebp),%esi
  800473:	eb 12                	jmp    800487 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800475:	85 c0                	test   %eax,%eax
  800477:	0f 84 98 03 00 00    	je     800815 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80047d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800481:	89 04 24             	mov    %eax,(%esp)
  800484:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800487:	0f b6 06             	movzbl (%esi),%eax
  80048a:	83 c6 01             	add    $0x1,%esi
  80048d:	83 f8 25             	cmp    $0x25,%eax
  800490:	75 e3                	jne    800475 <vprintfmt+0x11>
  800492:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800496:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80049d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b1:	eb 2b                	jmp    8004de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004b6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004ba:	eb 22                	jmp    8004de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004bf:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004c3:	eb 19                	jmp    8004de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004cf:	eb 0d                	jmp    8004de <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	0f b6 06             	movzbl (%esi),%eax
  8004e1:	0f b6 d0             	movzbl %al,%edx
  8004e4:	8d 7e 01             	lea    0x1(%esi),%edi
  8004e7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004ea:	83 e8 23             	sub    $0x23,%eax
  8004ed:	3c 55                	cmp    $0x55,%al
  8004ef:	0f 87 fa 02 00 00    	ja     8007ef <vprintfmt+0x38b>
  8004f5:	0f b6 c0             	movzbl %al,%eax
  8004f8:	ff 24 85 ec 0f 80 00 	jmp    *0x800fec(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ff:	83 ea 30             	sub    $0x30,%edx
  800502:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800505:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800509:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80050f:	83 fa 09             	cmp    $0x9,%edx
  800512:	77 4a                	ja     80055e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800517:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80051a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80051d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800521:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800524:	8d 50 d0             	lea    -0x30(%eax),%edx
  800527:	83 fa 09             	cmp    $0x9,%edx
  80052a:	76 eb                	jbe    800517 <vprintfmt+0xb3>
  80052c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052f:	eb 2d                	jmp    80055e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 50 04             	lea    0x4(%eax),%edx
  800537:	89 55 14             	mov    %edx,0x14(%ebp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800542:	eb 1a                	jmp    80055e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800547:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054b:	79 91                	jns    8004de <vprintfmt+0x7a>
  80054d:	e9 73 ff ff ff       	jmp    8004c5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800555:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80055c:	eb 80                	jmp    8004de <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80055e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800562:	0f 89 76 ff ff ff    	jns    8004de <vprintfmt+0x7a>
  800568:	e9 64 ff ff ff       	jmp    8004d1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800573:	e9 66 ff ff ff       	jmp    8004de <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 50 04             	lea    0x4(%eax),%edx
  80057e:	89 55 14             	mov    %edx,0x14(%ebp)
  800581:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800585:	8b 00                	mov    (%eax),%eax
  800587:	89 04 24             	mov    %eax,(%esp)
  80058a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800590:	e9 f2 fe ff ff       	jmp    800487 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 04             	lea    0x4(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 c2                	mov    %eax,%edx
  8005a2:	c1 fa 1f             	sar    $0x1f,%edx
  8005a5:	31 d0                	xor    %edx,%eax
  8005a7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8005a9:	83 f8 06             	cmp    $0x6,%eax
  8005ac:	7f 0b                	jg     8005b9 <vprintfmt+0x155>
  8005ae:	8b 14 85 44 11 80 00 	mov    0x801144(,%eax,4),%edx
  8005b5:	85 d2                	test   %edx,%edx
  8005b7:	75 23                	jne    8005dc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8005b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bd:	c7 44 24 08 75 0f 80 	movl   $0x800f75,0x8(%esp)
  8005c4:	00 
  8005c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cc:	89 3c 24             	mov    %edi,(%esp)
  8005cf:	e8 68 fe ff ff       	call   80043c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005d7:	e9 ab fe ff ff       	jmp    800487 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e0:	c7 44 24 08 7e 0f 80 	movl   $0x800f7e,0x8(%esp)
  8005e7:	00 
  8005e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ef:	89 3c 24             	mov    %edi,(%esp)
  8005f2:	e8 45 fe ff ff       	call   80043c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fa:	e9 88 fe ff ff       	jmp    800487 <vprintfmt+0x23>
  8005ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800605:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800613:	85 f6                	test   %esi,%esi
  800615:	ba 6e 0f 80 00       	mov    $0x800f6e,%edx
  80061a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80061d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800621:	7e 06                	jle    800629 <vprintfmt+0x1c5>
  800623:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800627:	75 10                	jne    800639 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800629:	0f be 06             	movsbl (%esi),%eax
  80062c:	83 c6 01             	add    $0x1,%esi
  80062f:	85 c0                	test   %eax,%eax
  800631:	0f 85 86 00 00 00    	jne    8006bd <vprintfmt+0x259>
  800637:	eb 76                	jmp    8006af <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800639:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063d:	89 34 24             	mov    %esi,(%esp)
  800640:	e8 76 02 00 00       	call   8008bb <strnlen>
  800645:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800648:	29 c2                	sub    %eax,%edx
  80064a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80064d:	85 d2                	test   %edx,%edx
  80064f:	7e d8                	jle    800629 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800651:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800655:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800658:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80065b:	89 d6                	mov    %edx,%esi
  80065d:	89 c7                	mov    %eax,%edi
  80065f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800663:	89 3c 24             	mov    %edi,(%esp)
  800666:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800669:	83 ee 01             	sub    $0x1,%esi
  80066c:	75 f1                	jne    80065f <vprintfmt+0x1fb>
  80066e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800671:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800674:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800677:	eb b0                	jmp    800629 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800679:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80067d:	74 18                	je     800697 <vprintfmt+0x233>
  80067f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800682:	83 fa 5e             	cmp    $0x5e,%edx
  800685:	76 10                	jbe    800697 <vprintfmt+0x233>
					putch('?', putdat);
  800687:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800692:	ff 55 08             	call   *0x8(%ebp)
  800695:	eb 0a                	jmp    8006a1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069b:	89 04 24             	mov    %eax,(%esp)
  80069e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8006a5:	0f be 06             	movsbl (%esi),%eax
  8006a8:	83 c6 01             	add    $0x1,%esi
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	75 0e                	jne    8006bd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b6:	7f 11                	jg     8006c9 <vprintfmt+0x265>
  8006b8:	e9 ca fd ff ff       	jmp    800487 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006bd:	85 ff                	test   %edi,%edi
  8006bf:	90                   	nop
  8006c0:	78 b7                	js     800679 <vprintfmt+0x215>
  8006c2:	83 ef 01             	sub    $0x1,%edi
  8006c5:	79 b2                	jns    800679 <vprintfmt+0x215>
  8006c7:	eb e6                	jmp    8006af <vprintfmt+0x24b>
  8006c9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8006cc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006da:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006dc:	83 ee 01             	sub    $0x1,%esi
  8006df:	75 ee                	jne    8006cf <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e4:	e9 9e fd ff ff       	jmp    800487 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 f2 fc ff ff       	call   8003e5 <getint>
  8006f3:	89 c6                	mov    %eax,%esi
  8006f5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	0f 89 ad 00 00 00    	jns    8007b1 <vprintfmt+0x34d>
				putch('-', putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800712:	f7 de                	neg    %esi
  800714:	83 d7 00             	adc    $0x0,%edi
  800717:	f7 df                	neg    %edi
			}
			base = 10;
  800719:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071e:	e9 8e 00 00 00       	jmp    8007b1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800723:	89 ca                	mov    %ecx,%edx
  800725:	8d 45 14             	lea    0x14(%ebp),%eax
  800728:	e8 7e fc ff ff       	call   8003ab <getuint>
  80072d:	89 c6                	mov    %eax,%esi
  80072f:	89 d7                	mov    %edx,%edi
			base = 10;
  800731:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800736:	eb 79                	jmp    8007b1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800738:	89 ca                	mov    %ecx,%edx
  80073a:	8d 45 14             	lea    0x14(%ebp),%eax
  80073d:	e8 a3 fc ff ff       	call   8003e5 <getint>
  800742:	89 c6                	mov    %eax,%esi
  800744:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800746:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80074b:	85 d2                	test   %edx,%edx
  80074d:	79 62                	jns    8007b1 <vprintfmt+0x34d>
				putch('-', putdat);
  80074f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800753:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80075a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80075d:	f7 de                	neg    %esi
  80075f:	83 d7 00             	adc    $0x0,%edi
  800762:	f7 df                	neg    %edi
			}
			base = 8;
  800764:	b8 08 00 00 00       	mov    $0x8,%eax
  800769:	eb 46                	jmp    8007b1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80076b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800776:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800779:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800784:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8d 50 04             	lea    0x4(%eax),%edx
  80078d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800790:	8b 30                	mov    (%eax),%esi
  800792:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800797:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80079c:	eb 13                	jmp    8007b1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079e:	89 ca                	mov    %ecx,%edx
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a3:	e8 03 fc ff ff       	call   8003ab <getuint>
  8007a8:	89 c6                	mov    %eax,%esi
  8007aa:	89 d7                	mov    %edx,%edi
			base = 16;
  8007ac:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c4:	89 34 24             	mov    %esi,(%esp)
  8007c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007cb:	89 da                	mov    %ebx,%edx
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	e8 fb fa ff ff       	call   8002d0 <printnum>
			break;
  8007d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d8:	e9 aa fc ff ff       	jmp    800487 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e1:	89 14 24             	mov    %edx,(%esp)
  8007e4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ea:	e9 98 fc ff ff       	jmp    800487 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007fa:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800801:	0f 84 80 fc ff ff    	je     800487 <vprintfmt+0x23>
  800807:	83 ee 01             	sub    $0x1,%esi
  80080a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80080e:	75 f7                	jne    800807 <vprintfmt+0x3a3>
  800810:	e9 72 fc ff ff       	jmp    800487 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800815:	83 c4 4c             	add    $0x4c,%esp
  800818:	5b                   	pop    %ebx
  800819:	5e                   	pop    %esi
  80081a:	5f                   	pop    %edi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	83 ec 28             	sub    $0x28,%esp
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800829:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800830:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083a:	85 c0                	test   %eax,%eax
  80083c:	74 30                	je     80086e <vsnprintf+0x51>
  80083e:	85 d2                	test   %edx,%edx
  800840:	7e 2c                	jle    80086e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800849:	8b 45 10             	mov    0x10(%ebp),%eax
  80084c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800850:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800853:	89 44 24 04          	mov    %eax,0x4(%esp)
  800857:	c7 04 24 1f 04 80 00 	movl   $0x80041f,(%esp)
  80085e:	e8 01 fc ff ff       	call   800464 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800863:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800866:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086c:	eb 05                	jmp    800873 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
  80087e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800882:	8b 45 10             	mov    0x10(%ebp),%eax
  800885:	89 44 24 08          	mov    %eax,0x8(%esp)
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 82 ff ff ff       	call   80081d <vsnprintf>
	va_end(ap);

	return rc;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    
  80089d:	00 00                	add    %al,(%eax)
	...

008008a0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ae:	74 09                	je     8008b9 <strlen+0x19>
		n++;
  8008b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b7:	75 f7                	jne    8008b0 <strlen+0x10>
		n++;
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ca:	85 c9                	test   %ecx,%ecx
  8008cc:	74 1a                	je     8008e8 <strnlen+0x2d>
  8008ce:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008d1:	74 15                	je     8008e8 <strnlen+0x2d>
  8008d3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008d8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008da:	39 ca                	cmp    %ecx,%edx
  8008dc:	74 0a                	je     8008e8 <strnlen+0x2d>
  8008de:	83 c2 01             	add    $0x1,%edx
  8008e1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008e6:	75 f0                	jne    8008d8 <strnlen+0x1d>
		n++;
	return n;
}
  8008e8:	5b                   	pop    %ebx
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	53                   	push   %ebx
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008fe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	84 c9                	test   %cl,%cl
  800906:	75 f2                	jne    8008fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800908:	5b                   	pop    %ebx
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
  800916:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800919:	85 f6                	test   %esi,%esi
  80091b:	74 18                	je     800935 <strncpy+0x2a>
  80091d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800922:	0f b6 1a             	movzbl (%edx),%ebx
  800925:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800928:	80 3a 01             	cmpb   $0x1,(%edx)
  80092b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092e:	83 c1 01             	add    $0x1,%ecx
  800931:	39 f1                	cmp    %esi,%ecx
  800933:	75 ed                	jne    800922 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800945:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800948:	89 f8                	mov    %edi,%eax
  80094a:	85 f6                	test   %esi,%esi
  80094c:	74 2b                	je     800979 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80094e:	83 fe 01             	cmp    $0x1,%esi
  800951:	74 23                	je     800976 <strlcpy+0x3d>
  800953:	0f b6 0b             	movzbl (%ebx),%ecx
  800956:	84 c9                	test   %cl,%cl
  800958:	74 1c                	je     800976 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80095a:	83 ee 02             	sub    $0x2,%esi
  80095d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800962:	88 08                	mov    %cl,(%eax)
  800964:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800967:	39 f2                	cmp    %esi,%edx
  800969:	74 0b                	je     800976 <strlcpy+0x3d>
  80096b:	83 c2 01             	add    $0x1,%edx
  80096e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800972:	84 c9                	test   %cl,%cl
  800974:	75 ec                	jne    800962 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800976:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800979:	29 f8                	sub    %edi,%eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800989:	0f b6 01             	movzbl (%ecx),%eax
  80098c:	84 c0                	test   %al,%al
  80098e:	74 16                	je     8009a6 <strcmp+0x26>
  800990:	3a 02                	cmp    (%edx),%al
  800992:	75 12                	jne    8009a6 <strcmp+0x26>
		p++, q++;
  800994:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800997:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80099b:	84 c0                	test   %al,%al
  80099d:	74 07                	je     8009a6 <strcmp+0x26>
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	3a 02                	cmp    (%edx),%al
  8009a4:	74 ee                	je     800994 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a6:	0f b6 c0             	movzbl %al,%eax
  8009a9:	0f b6 12             	movzbl (%edx),%edx
  8009ac:	29 d0                	sub    %edx,%eax
}
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ba:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c2:	85 d2                	test   %edx,%edx
  8009c4:	74 28                	je     8009ee <strncmp+0x3e>
  8009c6:	0f b6 01             	movzbl (%ecx),%eax
  8009c9:	84 c0                	test   %al,%al
  8009cb:	74 24                	je     8009f1 <strncmp+0x41>
  8009cd:	3a 03                	cmp    (%ebx),%al
  8009cf:	75 20                	jne    8009f1 <strncmp+0x41>
  8009d1:	83 ea 01             	sub    $0x1,%edx
  8009d4:	74 13                	je     8009e9 <strncmp+0x39>
		n--, p++, q++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dc:	0f b6 01             	movzbl (%ecx),%eax
  8009df:	84 c0                	test   %al,%al
  8009e1:	74 0e                	je     8009f1 <strncmp+0x41>
  8009e3:	3a 03                	cmp    (%ebx),%al
  8009e5:	74 ea                	je     8009d1 <strncmp+0x21>
  8009e7:	eb 08                	jmp    8009f1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f1:	0f b6 01             	movzbl (%ecx),%eax
  8009f4:	0f b6 13             	movzbl (%ebx),%edx
  8009f7:	29 d0                	sub    %edx,%eax
  8009f9:	eb f3                	jmp    8009ee <strncmp+0x3e>

008009fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	74 1c                	je     800a28 <strchr+0x2d>
		if (*s == c)
  800a0c:	38 ca                	cmp    %cl,%dl
  800a0e:	75 09                	jne    800a19 <strchr+0x1e>
  800a10:	eb 1b                	jmp    800a2d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a12:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800a15:	38 ca                	cmp    %cl,%dl
  800a17:	74 14                	je     800a2d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a19:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800a1d:	84 d2                	test   %dl,%dl
  800a1f:	75 f1                	jne    800a12 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
  800a26:	eb 05                	jmp    800a2d <strchr+0x32>
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a39:	0f b6 10             	movzbl (%eax),%edx
  800a3c:	84 d2                	test   %dl,%dl
  800a3e:	74 14                	je     800a54 <strfind+0x25>
		if (*s == c)
  800a40:	38 ca                	cmp    %cl,%dl
  800a42:	75 06                	jne    800a4a <strfind+0x1b>
  800a44:	eb 0e                	jmp    800a54 <strfind+0x25>
  800a46:	38 ca                	cmp    %cl,%dl
  800a48:	74 0a                	je     800a54 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	84 d2                	test   %dl,%dl
  800a52:	75 f2                	jne    800a46 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a63:	89 da                	mov    %ebx,%edx
  800a65:	83 ea 01             	sub    $0x1,%edx
  800a68:	78 0d                	js     800a77 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a6a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800a6c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a6e:	88 0a                	mov    %cl,(%edx)
  800a70:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a73:	39 da                	cmp    %ebx,%edx
  800a75:	75 f7                	jne    800a6e <memset+0x18>
		*p++ = c;

	return v;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a89:	39 c6                	cmp    %eax,%esi
  800a8b:	72 0b                	jb     800a98 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	75 29                	jne    800abf <memmove+0x45>
  800a96:	eb 35                	jmp    800acd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a98:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800a9b:	39 c8                	cmp    %ecx,%eax
  800a9d:	73 ee                	jae    800a8d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	74 2a                	je     800acd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800aa3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800aa6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800aa8:	f7 db                	neg    %ebx
  800aaa:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800aad:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800aaf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800ab4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800ab8:	83 ea 01             	sub    $0x1,%edx
  800abb:	75 f2                	jne    800aaf <memmove+0x35>
  800abd:	eb 0e                	jmp    800acd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800abf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800ac3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ac6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800ac9:	39 d3                	cmp    %edx,%ebx
  800acb:	75 f2                	jne    800abf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad8:	8b 45 10             	mov    0x10(%ebp),%eax
  800adb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	89 04 24             	mov    %eax,(%esp)
  800aec:	e8 89 ff ff ff       	call   800a7a <memmove>
}
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b07:	85 ff                	test   %edi,%edi
  800b09:	74 37                	je     800b42 <memcmp+0x4f>
		if (*s1 != *s2)
  800b0b:	0f b6 03             	movzbl (%ebx),%eax
  800b0e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b11:	83 ef 01             	sub    $0x1,%edi
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800b19:	38 c8                	cmp    %cl,%al
  800b1b:	74 1c                	je     800b39 <memcmp+0x46>
  800b1d:	eb 10                	jmp    800b2f <memcmp+0x3c>
  800b1f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800b24:	83 c2 01             	add    $0x1,%edx
  800b27:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800b2b:	38 c8                	cmp    %cl,%al
  800b2d:	74 0a                	je     800b39 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800b2f:	0f b6 c0             	movzbl %al,%eax
  800b32:	0f b6 c9             	movzbl %cl,%ecx
  800b35:	29 c8                	sub    %ecx,%eax
  800b37:	eb 09                	jmp    800b42 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b39:	39 fa                	cmp    %edi,%edx
  800b3b:	75 e2                	jne    800b1f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4d:	89 c2                	mov    %eax,%edx
  800b4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b52:	39 d0                	cmp    %edx,%eax
  800b54:	73 15                	jae    800b6b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b5a:	38 08                	cmp    %cl,(%eax)
  800b5c:	75 06                	jne    800b64 <memfind+0x1d>
  800b5e:	eb 0b                	jmp    800b6b <memfind+0x24>
  800b60:	38 08                	cmp    %cl,(%eax)
  800b62:	74 07                	je     800b6b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b64:	83 c0 01             	add    $0x1,%eax
  800b67:	39 d0                	cmp    %edx,%eax
  800b69:	75 f5                	jne    800b60 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b79:	0f b6 02             	movzbl (%edx),%eax
  800b7c:	3c 20                	cmp    $0x20,%al
  800b7e:	74 04                	je     800b84 <strtol+0x17>
  800b80:	3c 09                	cmp    $0x9,%al
  800b82:	75 0e                	jne    800b92 <strtol+0x25>
		s++;
  800b84:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b87:	0f b6 02             	movzbl (%edx),%eax
  800b8a:	3c 20                	cmp    $0x20,%al
  800b8c:	74 f6                	je     800b84 <strtol+0x17>
  800b8e:	3c 09                	cmp    $0x9,%al
  800b90:	74 f2                	je     800b84 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b92:	3c 2b                	cmp    $0x2b,%al
  800b94:	75 0a                	jne    800ba0 <strtol+0x33>
		s++;
  800b96:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b99:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9e:	eb 10                	jmp    800bb0 <strtol+0x43>
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ba5:	3c 2d                	cmp    $0x2d,%al
  800ba7:	75 07                	jne    800bb0 <strtol+0x43>
		s++, neg = 1;
  800ba9:	83 c2 01             	add    $0x1,%edx
  800bac:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb0:	85 db                	test   %ebx,%ebx
  800bb2:	0f 94 c0             	sete   %al
  800bb5:	74 05                	je     800bbc <strtol+0x4f>
  800bb7:	83 fb 10             	cmp    $0x10,%ebx
  800bba:	75 15                	jne    800bd1 <strtol+0x64>
  800bbc:	80 3a 30             	cmpb   $0x30,(%edx)
  800bbf:	75 10                	jne    800bd1 <strtol+0x64>
  800bc1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bc5:	75 0a                	jne    800bd1 <strtol+0x64>
		s += 2, base = 16;
  800bc7:	83 c2 02             	add    $0x2,%edx
  800bca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcf:	eb 13                	jmp    800be4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800bd1:	84 c0                	test   %al,%al
  800bd3:	74 0f                	je     800be4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bda:	80 3a 30             	cmpb   $0x30,(%edx)
  800bdd:	75 05                	jne    800be4 <strtol+0x77>
		s++, base = 8;
  800bdf:	83 c2 01             	add    $0x1,%edx
  800be2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800beb:	0f b6 0a             	movzbl (%edx),%ecx
  800bee:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bf1:	80 fb 09             	cmp    $0x9,%bl
  800bf4:	77 08                	ja     800bfe <strtol+0x91>
			dig = *s - '0';
  800bf6:	0f be c9             	movsbl %cl,%ecx
  800bf9:	83 e9 30             	sub    $0x30,%ecx
  800bfc:	eb 1e                	jmp    800c1c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bfe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 08                	ja     800c0e <strtol+0xa1>
			dig = *s - 'a' + 10;
  800c06:	0f be c9             	movsbl %cl,%ecx
  800c09:	83 e9 57             	sub    $0x57,%ecx
  800c0c:	eb 0e                	jmp    800c1c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800c0e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c11:	80 fb 19             	cmp    $0x19,%bl
  800c14:	77 14                	ja     800c2a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c16:	0f be c9             	movsbl %cl,%ecx
  800c19:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c1c:	39 f1                	cmp    %esi,%ecx
  800c1e:	7d 0e                	jge    800c2e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c20:	83 c2 01             	add    $0x1,%edx
  800c23:	0f af c6             	imul   %esi,%eax
  800c26:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c28:	eb c1                	jmp    800beb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c2a:	89 c1                	mov    %eax,%ecx
  800c2c:	eb 02                	jmp    800c30 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c2e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c34:	74 05                	je     800c3b <strtol+0xce>
		*endptr = (char *) s;
  800c36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c39:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c3b:	89 ca                	mov    %ecx,%edx
  800c3d:	f7 da                	neg    %edx
  800c3f:	85 ff                	test   %edi,%edi
  800c41:	0f 45 c2             	cmovne %edx,%eax
}
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    
  800c49:	00 00                	add    %al,(%eax)
  800c4b:	00 00                	add    %al,(%eax)
  800c4d:	00 00                	add    %al,(%eax)
	...

00800c50 <__udivdi3>:
  800c50:	83 ec 1c             	sub    $0x1c,%esp
  800c53:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800c57:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800c5b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800c5f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800c63:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c67:	8b 74 24 24          	mov    0x24(%esp),%esi
  800c6b:	85 ff                	test   %edi,%edi
  800c6d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800c71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c75:	89 cd                	mov    %ecx,%ebp
  800c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7b:	75 33                	jne    800cb0 <__udivdi3+0x60>
  800c7d:	39 f1                	cmp    %esi,%ecx
  800c7f:	77 57                	ja     800cd8 <__udivdi3+0x88>
  800c81:	85 c9                	test   %ecx,%ecx
  800c83:	75 0b                	jne    800c90 <__udivdi3+0x40>
  800c85:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8a:	31 d2                	xor    %edx,%edx
  800c8c:	f7 f1                	div    %ecx
  800c8e:	89 c1                	mov    %eax,%ecx
  800c90:	89 f0                	mov    %esi,%eax
  800c92:	31 d2                	xor    %edx,%edx
  800c94:	f7 f1                	div    %ecx
  800c96:	89 c6                	mov    %eax,%esi
  800c98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800c9c:	f7 f1                	div    %ecx
  800c9e:	89 f2                	mov    %esi,%edx
  800ca0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ca4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ca8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800cac:	83 c4 1c             	add    $0x1c,%esp
  800caf:	c3                   	ret    
  800cb0:	31 d2                	xor    %edx,%edx
  800cb2:	31 c0                	xor    %eax,%eax
  800cb4:	39 f7                	cmp    %esi,%edi
  800cb6:	77 e8                	ja     800ca0 <__udivdi3+0x50>
  800cb8:	0f bd cf             	bsr    %edi,%ecx
  800cbb:	83 f1 1f             	xor    $0x1f,%ecx
  800cbe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cc2:	75 2c                	jne    800cf0 <__udivdi3+0xa0>
  800cc4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800cc8:	76 04                	jbe    800cce <__udivdi3+0x7e>
  800cca:	39 f7                	cmp    %esi,%edi
  800ccc:	73 d2                	jae    800ca0 <__udivdi3+0x50>
  800cce:	31 d2                	xor    %edx,%edx
  800cd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cd5:	eb c9                	jmp    800ca0 <__udivdi3+0x50>
  800cd7:	90                   	nop
  800cd8:	89 f2                	mov    %esi,%edx
  800cda:	f7 f1                	div    %ecx
  800cdc:	31 d2                	xor    %edx,%edx
  800cde:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ce2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ce6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800cea:	83 c4 1c             	add    $0x1c,%esp
  800ced:	c3                   	ret    
  800cee:	66 90                	xchg   %ax,%ax
  800cf0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800cf5:	b8 20 00 00 00       	mov    $0x20,%eax
  800cfa:	89 ea                	mov    %ebp,%edx
  800cfc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d00:	d3 e7                	shl    %cl,%edi
  800d02:	89 c1                	mov    %eax,%ecx
  800d04:	d3 ea                	shr    %cl,%edx
  800d06:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d0b:	09 fa                	or     %edi,%edx
  800d0d:	89 f7                	mov    %esi,%edi
  800d0f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d13:	89 f2                	mov    %esi,%edx
  800d15:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d19:	d3 e5                	shl    %cl,%ebp
  800d1b:	89 c1                	mov    %eax,%ecx
  800d1d:	d3 ef                	shr    %cl,%edi
  800d1f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d24:	d3 e2                	shl    %cl,%edx
  800d26:	89 c1                	mov    %eax,%ecx
  800d28:	d3 ee                	shr    %cl,%esi
  800d2a:	09 d6                	or     %edx,%esi
  800d2c:	89 fa                	mov    %edi,%edx
  800d2e:	89 f0                	mov    %esi,%eax
  800d30:	f7 74 24 0c          	divl   0xc(%esp)
  800d34:	89 d7                	mov    %edx,%edi
  800d36:	89 c6                	mov    %eax,%esi
  800d38:	f7 e5                	mul    %ebp
  800d3a:	39 d7                	cmp    %edx,%edi
  800d3c:	72 22                	jb     800d60 <__udivdi3+0x110>
  800d3e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800d42:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d47:	d3 e5                	shl    %cl,%ebp
  800d49:	39 c5                	cmp    %eax,%ebp
  800d4b:	73 04                	jae    800d51 <__udivdi3+0x101>
  800d4d:	39 d7                	cmp    %edx,%edi
  800d4f:	74 0f                	je     800d60 <__udivdi3+0x110>
  800d51:	89 f0                	mov    %esi,%eax
  800d53:	31 d2                	xor    %edx,%edx
  800d55:	e9 46 ff ff ff       	jmp    800ca0 <__udivdi3+0x50>
  800d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d60:	8d 46 ff             	lea    -0x1(%esi),%eax
  800d63:	31 d2                	xor    %edx,%edx
  800d65:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d69:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800d6d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800d71:	83 c4 1c             	add    $0x1c,%esp
  800d74:	c3                   	ret    
	...

00800d80 <__umoddi3>:
  800d80:	83 ec 1c             	sub    $0x1c,%esp
  800d83:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800d87:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800d8b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800d8f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d93:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d97:	8b 74 24 24          	mov    0x24(%esp),%esi
  800d9b:	85 ed                	test   %ebp,%ebp
  800d9d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800da1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da5:	89 cf                	mov    %ecx,%edi
  800da7:	89 04 24             	mov    %eax,(%esp)
  800daa:	89 f2                	mov    %esi,%edx
  800dac:	75 1a                	jne    800dc8 <__umoddi3+0x48>
  800dae:	39 f1                	cmp    %esi,%ecx
  800db0:	76 4e                	jbe    800e00 <__umoddi3+0x80>
  800db2:	f7 f1                	div    %ecx
  800db4:	89 d0                	mov    %edx,%eax
  800db6:	31 d2                	xor    %edx,%edx
  800db8:	8b 74 24 10          	mov    0x10(%esp),%esi
  800dbc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800dc0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800dc4:	83 c4 1c             	add    $0x1c,%esp
  800dc7:	c3                   	ret    
  800dc8:	39 f5                	cmp    %esi,%ebp
  800dca:	77 54                	ja     800e20 <__umoddi3+0xa0>
  800dcc:	0f bd c5             	bsr    %ebp,%eax
  800dcf:	83 f0 1f             	xor    $0x1f,%eax
  800dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd6:	75 60                	jne    800e38 <__umoddi3+0xb8>
  800dd8:	3b 0c 24             	cmp    (%esp),%ecx
  800ddb:	0f 87 07 01 00 00    	ja     800ee8 <__umoddi3+0x168>
  800de1:	89 f2                	mov    %esi,%edx
  800de3:	8b 34 24             	mov    (%esp),%esi
  800de6:	29 ce                	sub    %ecx,%esi
  800de8:	19 ea                	sbb    %ebp,%edx
  800dea:	89 34 24             	mov    %esi,(%esp)
  800ded:	8b 04 24             	mov    (%esp),%eax
  800df0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800df4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800df8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800dfc:	83 c4 1c             	add    $0x1c,%esp
  800dff:	c3                   	ret    
  800e00:	85 c9                	test   %ecx,%ecx
  800e02:	75 0b                	jne    800e0f <__umoddi3+0x8f>
  800e04:	b8 01 00 00 00       	mov    $0x1,%eax
  800e09:	31 d2                	xor    %edx,%edx
  800e0b:	f7 f1                	div    %ecx
  800e0d:	89 c1                	mov    %eax,%ecx
  800e0f:	89 f0                	mov    %esi,%eax
  800e11:	31 d2                	xor    %edx,%edx
  800e13:	f7 f1                	div    %ecx
  800e15:	8b 04 24             	mov    (%esp),%eax
  800e18:	f7 f1                	div    %ecx
  800e1a:	eb 98                	jmp    800db4 <__umoddi3+0x34>
  800e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e20:	89 f2                	mov    %esi,%edx
  800e22:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e26:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e2a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e2e:	83 c4 1c             	add    $0x1c,%esp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e3d:	89 e8                	mov    %ebp,%eax
  800e3f:	bd 20 00 00 00       	mov    $0x20,%ebp
  800e44:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800e48:	89 fa                	mov    %edi,%edx
  800e4a:	d3 e0                	shl    %cl,%eax
  800e4c:	89 e9                	mov    %ebp,%ecx
  800e4e:	d3 ea                	shr    %cl,%edx
  800e50:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e55:	09 c2                	or     %eax,%edx
  800e57:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e5b:	89 14 24             	mov    %edx,(%esp)
  800e5e:	89 f2                	mov    %esi,%edx
  800e60:	d3 e7                	shl    %cl,%edi
  800e62:	89 e9                	mov    %ebp,%ecx
  800e64:	d3 ea                	shr    %cl,%edx
  800e66:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e6f:	d3 e6                	shl    %cl,%esi
  800e71:	89 e9                	mov    %ebp,%ecx
  800e73:	d3 e8                	shr    %cl,%eax
  800e75:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e7a:	09 f0                	or     %esi,%eax
  800e7c:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e80:	f7 34 24             	divl   (%esp)
  800e83:	d3 e6                	shl    %cl,%esi
  800e85:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e89:	89 d6                	mov    %edx,%esi
  800e8b:	f7 e7                	mul    %edi
  800e8d:	39 d6                	cmp    %edx,%esi
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	89 d7                	mov    %edx,%edi
  800e93:	72 3f                	jb     800ed4 <__umoddi3+0x154>
  800e95:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e99:	72 35                	jb     800ed0 <__umoddi3+0x150>
  800e9b:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e9f:	29 c8                	sub    %ecx,%eax
  800ea1:	19 fe                	sbb    %edi,%esi
  800ea3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ea8:	89 f2                	mov    %esi,%edx
  800eaa:	d3 e8                	shr    %cl,%eax
  800eac:	89 e9                	mov    %ebp,%ecx
  800eae:	d3 e2                	shl    %cl,%edx
  800eb0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eb5:	09 d0                	or     %edx,%eax
  800eb7:	89 f2                	mov    %esi,%edx
  800eb9:	d3 ea                	shr    %cl,%edx
  800ebb:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ebf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ec3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ec7:	83 c4 1c             	add    $0x1c,%esp
  800eca:	c3                   	ret    
  800ecb:	90                   	nop
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	39 d6                	cmp    %edx,%esi
  800ed2:	75 c7                	jne    800e9b <__umoddi3+0x11b>
  800ed4:	89 d7                	mov    %edx,%edi
  800ed6:	89 c1                	mov    %eax,%ecx
  800ed8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  800edc:	1b 3c 24             	sbb    (%esp),%edi
  800edf:	eb ba                	jmp    800e9b <__umoddi3+0x11b>
  800ee1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee8:	39 f5                	cmp    %esi,%ebp
  800eea:	0f 82 f1 fe ff ff    	jb     800de1 <__umoddi3+0x61>
  800ef0:	e9 f8 fe ff ff       	jmp    800ded <__umoddi3+0x6d>
