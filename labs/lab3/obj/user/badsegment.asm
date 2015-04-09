
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
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
  800049:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80004c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800053:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	7e 08                	jle    800062 <libmain+0x22>
		binaryname = argv[0];
  80005a:	8b 0a                	mov    (%edx),%ecx
  80005c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800062:	89 54 24 04          	mov    %edx,0x4(%esp)
  800066:	89 04 24             	mov    %eax,(%esp)
  800069:	e8 c6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006e:	e8 05 00 00 00       	call   800078 <exit>
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    
  800075:	00 00                	add    %al,(%eax)
	...

00800078 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800085:	e8 61 00 00 00       	call   8000eb <sys_env_destroy>
}
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800095:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800098:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000b1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000b4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000b7:	89 ec                	mov    %ebp,%esp
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000e7:	89 ec                	mov    %ebp,%esp
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 38             	sub    $0x38,%esp
  8000f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 df 0e 80 	movl   $0x800edf,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 fc 0e 80 00 	movl   $0x800efc,(%esp)
  800136:	e8 3d 00 00 00       	call   800178 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80013e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800141:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800144:	89 ec                	mov    %ebp,%esp
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 0c             	sub    $0xc,%esp
  80014e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800151:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800154:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 02 00 00 00       	mov    $0x2,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80016e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800171:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800174:	89 ec                	mov    %ebp,%esp
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80017e:	a1 08 20 80 00       	mov    0x802008,%eax
  800183:	85 c0                	test   %eax,%eax
  800185:	74 10                	je     800197 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	c7 04 24 0a 0f 80 00 	movl   $0x800f0a,(%esp)
  800192:	e8 e8 00 00 00       	call   80027f <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a5:	a1 00 20 80 00       	mov    0x802000,%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	c7 04 24 0f 0f 80 00 	movl   $0x800f0f,(%esp)
  8001b5:	e8 c5 00 00 00       	call   80027f <cprintf>
	vcprintf(fmt, ap);
  8001ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 52 00 00 00       	call   80021e <vcprintf>
	cprintf("\n");
  8001cc:	c7 04 24 2b 0f 80 00 	movl   $0x800f2b,(%esp)
  8001d3:	e8 a7 00 00 00       	call   80027f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d8:	cc                   	int3   
  8001d9:	eb fd                	jmp    8001d8 <_panic+0x60>
	...

008001dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 14             	sub    $0x14,%esp
  8001e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e6:	8b 03                	mov    (%ebx),%eax
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ef:	83 c0 01             	add    $0x1,%eax
  8001f2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f9:	75 19                	jne    800214 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800202:	00 
  800203:	8d 43 08             	lea    0x8(%ebx),%eax
  800206:	89 04 24             	mov    %eax,(%esp)
  800209:	e8 7e fe ff ff       	call   80008c <sys_cputs>
		b->idx = 0;
  80020e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800214:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800218:	83 c4 14             	add    $0x14,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800227:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022e:	00 00 00 
	b.cnt = 0;
  800231:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800238:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800242:	8b 45 08             	mov    0x8(%ebp),%eax
  800245:	89 44 24 08          	mov    %eax,0x8(%esp)
  800249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800253:	c7 04 24 dc 01 80 00 	movl   $0x8001dc,(%esp)
  80025a:	e8 d5 01 00 00       	call   800434 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 15 fe ff ff       	call   80008c <sys_cputs>

	return b.cnt;
}
  800277:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800285:	8d 45 0c             	lea    0xc(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	8b 45 08             	mov    0x8(%ebp),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	e8 87 ff ff ff       	call   80021e <vcprintf>
	va_end(ap);

	return cnt;
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
  80029b:	00 00                	add    %al,(%eax)
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 3c             	sub    $0x3c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d7                	mov    %edx,%edi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002c8:	72 11                	jb     8002db <printnum+0x3b>
  8002ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d0:	76 09                	jbe    8002db <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d2:	83 eb 01             	sub    $0x1,%ebx
  8002d5:	85 db                	test   %ebx,%ebx
  8002d7:	7f 51                	jg     80032a <printnum+0x8a>
  8002d9:	eb 5e                	jmp    800339 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002db:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002df:	83 eb 01             	sub    $0x1,%ebx
  8002e2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ed:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002f1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fc:	00 
  8002fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800306:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030a:	e8 11 09 00 00       	call   800c20 <__udivdi3>
  80030f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800313:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031e:	89 fa                	mov    %edi,%edx
  800320:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800323:	e8 78 ff ff ff       	call   8002a0 <printnum>
  800328:	eb 0f                	jmp    800339 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032e:	89 34 24             	mov    %esi,(%esp)
  800331:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800334:	83 eb 01             	sub    $0x1,%ebx
  800337:	75 f1                	jne    80032a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800339:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034f:	00 
  800350:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	e8 ee 09 00 00       	call   800d50 <__umoddi3>
  800362:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800366:	0f be 80 2d 0f 80 00 	movsbl 0x800f2d(%eax),%eax
  80036d:	89 04 24             	mov    %eax,(%esp)
  800370:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800373:	83 c4 3c             	add    $0x3c,%esp
  800376:	5b                   	pop    %ebx
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80037e:	83 fa 01             	cmp    $0x1,%edx
  800381:	7e 0e                	jle    800391 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800383:	8b 10                	mov    (%eax),%edx
  800385:	8d 4a 08             	lea    0x8(%edx),%ecx
  800388:	89 08                	mov    %ecx,(%eax)
  80038a:	8b 02                	mov    (%edx),%eax
  80038c:	8b 52 04             	mov    0x4(%edx),%edx
  80038f:	eb 22                	jmp    8003b3 <getuint+0x38>
	else if (lflag)
  800391:	85 d2                	test   %edx,%edx
  800393:	74 10                	je     8003a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800395:	8b 10                	mov    (%eax),%edx
  800397:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039a:	89 08                	mov    %ecx,(%eax)
  80039c:	8b 02                	mov    (%edx),%eax
  80039e:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a3:	eb 0e                	jmp    8003b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a5:	8b 10                	mov    (%eax),%edx
  8003a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003aa:	89 08                	mov    %ecx,(%eax)
  8003ac:	8b 02                	mov    (%edx),%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b8:	83 fa 01             	cmp    $0x1,%edx
  8003bb:	7e 0e                	jle    8003cb <getint+0x16>
		return va_arg(*ap, long long);
  8003bd:	8b 10                	mov    (%eax),%edx
  8003bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 02                	mov    (%edx),%eax
  8003c6:	8b 52 04             	mov    0x4(%edx),%edx
  8003c9:	eb 22                	jmp    8003ed <getint+0x38>
	else if (lflag)
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	74 10                	je     8003df <getint+0x2a>
		return va_arg(*ap, long);
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d4:	89 08                	mov    %ecx,(%eax)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 fa 1f             	sar    $0x1f,%edx
  8003dd:	eb 0e                	jmp    8003ed <getint+0x38>
	else
		return va_arg(*ap, int);
  8003df:	8b 10                	mov    (%eax),%edx
  8003e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 02                	mov    (%edx),%eax
  8003e8:	89 c2                	mov    %eax,%edx
  8003ea:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fe:	73 0a                	jae    80040a <sprintputch+0x1b>
		*b->buf++ = ch;
  800400:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800403:	88 0a                	mov    %cl,(%edx)
  800405:	83 c2 01             	add    $0x1,%edx
  800408:	89 10                	mov    %edx,(%eax)
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800412:	8d 45 14             	lea    0x14(%ebp),%eax
  800415:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800419:	8b 45 10             	mov    0x10(%ebp),%eax
  80041c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800420:	8b 45 0c             	mov    0xc(%ebp),%eax
  800423:	89 44 24 04          	mov    %eax,0x4(%esp)
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
  80042a:	89 04 24             	mov    %eax,(%esp)
  80042d:	e8 02 00 00 00       	call   800434 <vprintfmt>
	va_end(ap);
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	57                   	push   %edi
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	83 ec 4c             	sub    $0x4c,%esp
  80043d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800440:	8b 75 10             	mov    0x10(%ebp),%esi
  800443:	eb 12                	jmp    800457 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800445:	85 c0                	test   %eax,%eax
  800447:	0f 84 98 03 00 00    	je     8007e5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80044d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800451:	89 04 24             	mov    %eax,(%esp)
  800454:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800457:	0f b6 06             	movzbl (%esi),%eax
  80045a:	83 c6 01             	add    $0x1,%esi
  80045d:	83 f8 25             	cmp    $0x25,%eax
  800460:	75 e3                	jne    800445 <vprintfmt+0x11>
  800462:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800466:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80046d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800472:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800479:	b9 00 00 00 00       	mov    $0x0,%ecx
  80047e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800481:	eb 2b                	jmp    8004ae <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800486:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80048a:	eb 22                	jmp    8004ae <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80048f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800493:	eb 19                	jmp    8004ae <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800498:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80049f:	eb 0d                	jmp    8004ae <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	0f b6 06             	movzbl (%esi),%eax
  8004b1:	0f b6 d0             	movzbl %al,%edx
  8004b4:	8d 7e 01             	lea    0x1(%esi),%edi
  8004b7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004ba:	83 e8 23             	sub    $0x23,%eax
  8004bd:	3c 55                	cmp    $0x55,%al
  8004bf:	0f 87 fa 02 00 00    	ja     8007bf <vprintfmt+0x38b>
  8004c5:	0f b6 c0             	movzbl %al,%eax
  8004c8:	ff 24 85 bc 0f 80 00 	jmp    *0x800fbc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004cf:	83 ea 30             	sub    $0x30,%edx
  8004d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004d5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004d9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004df:	83 fa 09             	cmp    $0x9,%edx
  8004e2:	77 4a                	ja     80052e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004ea:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ed:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004f1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004f4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f7:	83 fa 09             	cmp    $0x9,%edx
  8004fa:	76 eb                	jbe    8004e7 <vprintfmt+0xb3>
  8004fc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ff:	eb 2d                	jmp    80052e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 50 04             	lea    0x4(%eax),%edx
  800507:	89 55 14             	mov    %edx,0x14(%ebp)
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800512:	eb 1a                	jmp    80052e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800514:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800517:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051b:	79 91                	jns    8004ae <vprintfmt+0x7a>
  80051d:	e9 73 ff ff ff       	jmp    800495 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800525:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80052c:	eb 80                	jmp    8004ae <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80052e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800532:	0f 89 76 ff ff ff    	jns    8004ae <vprintfmt+0x7a>
  800538:	e9 64 ff ff ff       	jmp    8004a1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800543:	e9 66 ff ff ff       	jmp    8004ae <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 04 24             	mov    %eax,(%esp)
  80055a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800560:	e9 f2 fe ff ff       	jmp    800457 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 c2                	mov    %eax,%edx
  800572:	c1 fa 1f             	sar    $0x1f,%edx
  800575:	31 d0                	xor    %edx,%eax
  800577:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800579:	83 f8 06             	cmp    $0x6,%eax
  80057c:	7f 0b                	jg     800589 <vprintfmt+0x155>
  80057e:	8b 14 85 14 11 80 00 	mov    0x801114(,%eax,4),%edx
  800585:	85 d2                	test   %edx,%edx
  800587:	75 23                	jne    8005ac <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800589:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058d:	c7 44 24 08 45 0f 80 	movl   $0x800f45,0x8(%esp)
  800594:	00 
  800595:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800599:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059c:	89 3c 24             	mov    %edi,(%esp)
  80059f:	e8 68 fe ff ff       	call   80040c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a7:	e9 ab fe ff ff       	jmp    800457 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b0:	c7 44 24 08 4e 0f 80 	movl   $0x800f4e,0x8(%esp)
  8005b7:	00 
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005bf:	89 3c 24             	mov    %edi,(%esp)
  8005c2:	e8 45 fe ff ff       	call   80040c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ca:	e9 88 fe ff ff       	jmp    800457 <vprintfmt+0x23>
  8005cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005e3:	85 f6                	test   %esi,%esi
  8005e5:	ba 3e 0f 80 00       	mov    $0x800f3e,%edx
  8005ea:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005f1:	7e 06                	jle    8005f9 <vprintfmt+0x1c5>
  8005f3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005f7:	75 10                	jne    800609 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	0f be 06             	movsbl (%esi),%eax
  8005fc:	83 c6 01             	add    $0x1,%esi
  8005ff:	85 c0                	test   %eax,%eax
  800601:	0f 85 86 00 00 00    	jne    80068d <vprintfmt+0x259>
  800607:	eb 76                	jmp    80067f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060d:	89 34 24             	mov    %esi,(%esp)
  800610:	e8 76 02 00 00       	call   80088b <strnlen>
  800615:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800618:	29 c2                	sub    %eax,%edx
  80061a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80061d:	85 d2                	test   %edx,%edx
  80061f:	7e d8                	jle    8005f9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800621:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800625:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800628:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80062b:	89 d6                	mov    %edx,%esi
  80062d:	89 c7                	mov    %eax,%edi
  80062f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800633:	89 3c 24             	mov    %edi,(%esp)
  800636:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800639:	83 ee 01             	sub    $0x1,%esi
  80063c:	75 f1                	jne    80062f <vprintfmt+0x1fb>
  80063e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800641:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800644:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800647:	eb b0                	jmp    8005f9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800649:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064d:	74 18                	je     800667 <vprintfmt+0x233>
  80064f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800652:	83 fa 5e             	cmp    $0x5e,%edx
  800655:	76 10                	jbe    800667 <vprintfmt+0x233>
					putch('?', putdat);
  800657:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800662:	ff 55 08             	call   *0x8(%ebp)
  800665:	eb 0a                	jmp    800671 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800667:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800671:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800675:	0f be 06             	movsbl (%esi),%eax
  800678:	83 c6 01             	add    $0x1,%esi
  80067b:	85 c0                	test   %eax,%eax
  80067d:	75 0e                	jne    80068d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800682:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800686:	7f 11                	jg     800699 <vprintfmt+0x265>
  800688:	e9 ca fd ff ff       	jmp    800457 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80068d:	85 ff                	test   %edi,%edi
  80068f:	90                   	nop
  800690:	78 b7                	js     800649 <vprintfmt+0x215>
  800692:	83 ef 01             	sub    $0x1,%edi
  800695:	79 b2                	jns    800649 <vprintfmt+0x215>
  800697:	eb e6                	jmp    80067f <vprintfmt+0x24b>
  800699:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80069c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006aa:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ac:	83 ee 01             	sub    $0x1,%esi
  8006af:	75 ee                	jne    80069f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b4:	e9 9e fd ff ff       	jmp    800457 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b9:	89 ca                	mov    %ecx,%edx
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 f2 fc ff ff       	call   8003b5 <getint>
  8006c3:	89 c6                	mov    %eax,%esi
  8006c5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006cc:	85 d2                	test   %edx,%edx
  8006ce:	0f 89 ad 00 00 00    	jns    800781 <vprintfmt+0x34d>
				putch('-', putdat);
  8006d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006e2:	f7 de                	neg    %esi
  8006e4:	83 d7 00             	adc    $0x0,%edi
  8006e7:	f7 df                	neg    %edi
			}
			base = 10;
  8006e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ee:	e9 8e 00 00 00       	jmp    800781 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f3:	89 ca                	mov    %ecx,%edx
  8006f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f8:	e8 7e fc ff ff       	call   80037b <getuint>
  8006fd:	89 c6                	mov    %eax,%esi
  8006ff:	89 d7                	mov    %edx,%edi
			base = 10;
  800701:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800706:	eb 79                	jmp    800781 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800708:	89 ca                	mov    %ecx,%edx
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
  80070d:	e8 a3 fc ff ff       	call   8003b5 <getint>
  800712:	89 c6                	mov    %eax,%esi
  800714:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800716:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071b:	85 d2                	test   %edx,%edx
  80071d:	79 62                	jns    800781 <vprintfmt+0x34d>
				putch('-', putdat);
  80071f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800723:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80072d:	f7 de                	neg    %esi
  80072f:	83 d7 00             	adc    $0x0,%edi
  800732:	f7 df                	neg    %edi
			}
			base = 8;
  800734:	b8 08 00 00 00       	mov    $0x8,%eax
  800739:	eb 46                	jmp    800781 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80073b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800746:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800749:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800754:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800760:	8b 30                	mov    (%eax),%esi
  800762:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800767:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80076c:	eb 13                	jmp    800781 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80076e:	89 ca                	mov    %ecx,%edx
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
  800773:	e8 03 fc ff ff       	call   80037b <getuint>
  800778:	89 c6                	mov    %eax,%esi
  80077a:	89 d7                	mov    %edx,%edi
			base = 16;
  80077c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800781:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800785:	89 54 24 10          	mov    %edx,0x10(%esp)
  800789:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80078c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800790:	89 44 24 08          	mov    %eax,0x8(%esp)
  800794:	89 34 24             	mov    %esi,(%esp)
  800797:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079b:	89 da                	mov    %ebx,%edx
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	e8 fb fa ff ff       	call   8002a0 <printnum>
			break;
  8007a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007a8:	e9 aa fc ff ff       	jmp    800457 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b1:	89 14 24             	mov    %edx,(%esp)
  8007b4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ba:	e9 98 fc ff ff       	jmp    800457 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ca:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d1:	0f 84 80 fc ff ff    	je     800457 <vprintfmt+0x23>
  8007d7:	83 ee 01             	sub    $0x1,%esi
  8007da:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007de:	75 f7                	jne    8007d7 <vprintfmt+0x3a3>
  8007e0:	e9 72 fc ff ff       	jmp    800457 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007e5:	83 c4 4c             	add    $0x4c,%esp
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5f                   	pop    %edi
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	83 ec 28             	sub    $0x28,%esp
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800800:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800803:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080a:	85 c0                	test   %eax,%eax
  80080c:	74 30                	je     80083e <vsnprintf+0x51>
  80080e:	85 d2                	test   %edx,%edx
  800810:	7e 2c                	jle    80083e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800819:	8b 45 10             	mov    0x10(%ebp),%eax
  80081c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800820:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800823:	89 44 24 04          	mov    %eax,0x4(%esp)
  800827:	c7 04 24 ef 03 80 00 	movl   $0x8003ef,(%esp)
  80082e:	e8 01 fc ff ff       	call   800434 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800833:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800836:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083c:	eb 05                	jmp    800843 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80084b:	8d 45 14             	lea    0x14(%ebp),%eax
  80084e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800852:	8b 45 10             	mov    0x10(%ebp),%eax
  800855:	89 44 24 08          	mov    %eax,0x8(%esp)
  800859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	89 04 24             	mov    %eax,(%esp)
  800866:	e8 82 ff ff ff       	call   8007ed <vsnprintf>
	va_end(ap);

	return rc;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    
  80086d:	00 00                	add    %al,(%eax)
	...

00800870 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	80 3a 00             	cmpb   $0x0,(%edx)
  80087e:	74 09                	je     800889 <strlen+0x19>
		n++;
  800880:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800887:	75 f7                	jne    800880 <strlen+0x10>
		n++;
	return n;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	85 c9                	test   %ecx,%ecx
  80089c:	74 1a                	je     8008b8 <strnlen+0x2d>
  80089e:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008a1:	74 15                	je     8008b8 <strnlen+0x2d>
  8008a3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008a8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008aa:	39 ca                	cmp    %ecx,%edx
  8008ac:	74 0a                	je     8008b8 <strnlen+0x2d>
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008b6:	75 f0                	jne    8008a8 <strnlen+0x1d>
		n++;
	return n;
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ca:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ce:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008d1:	83 c2 01             	add    $0x1,%edx
  8008d4:	84 c9                	test   %cl,%cl
  8008d6:	75 f2                	jne    8008ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e9:	85 f6                	test   %esi,%esi
  8008eb:	74 18                	je     800905 <strncpy+0x2a>
  8008ed:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008f2:	0f b6 1a             	movzbl (%edx),%ebx
  8008f5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f8:	80 3a 01             	cmpb   $0x1,(%edx)
  8008fb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fe:	83 c1 01             	add    $0x1,%ecx
  800901:	39 f1                	cmp    %esi,%ecx
  800903:	75 ed                	jne    8008f2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	57                   	push   %edi
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800912:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800915:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800918:	89 f8                	mov    %edi,%eax
  80091a:	85 f6                	test   %esi,%esi
  80091c:	74 2b                	je     800949 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80091e:	83 fe 01             	cmp    $0x1,%esi
  800921:	74 23                	je     800946 <strlcpy+0x3d>
  800923:	0f b6 0b             	movzbl (%ebx),%ecx
  800926:	84 c9                	test   %cl,%cl
  800928:	74 1c                	je     800946 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80092a:	83 ee 02             	sub    $0x2,%esi
  80092d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800932:	88 08                	mov    %cl,(%eax)
  800934:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800937:	39 f2                	cmp    %esi,%edx
  800939:	74 0b                	je     800946 <strlcpy+0x3d>
  80093b:	83 c2 01             	add    $0x1,%edx
  80093e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800942:	84 c9                	test   %cl,%cl
  800944:	75 ec                	jne    800932 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800946:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800949:	29 f8                	sub    %edi,%eax
}
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5f                   	pop    %edi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800956:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800959:	0f b6 01             	movzbl (%ecx),%eax
  80095c:	84 c0                	test   %al,%al
  80095e:	74 16                	je     800976 <strcmp+0x26>
  800960:	3a 02                	cmp    (%edx),%al
  800962:	75 12                	jne    800976 <strcmp+0x26>
		p++, q++;
  800964:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800967:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80096b:	84 c0                	test   %al,%al
  80096d:	74 07                	je     800976 <strcmp+0x26>
  80096f:	83 c1 01             	add    $0x1,%ecx
  800972:	3a 02                	cmp    (%edx),%al
  800974:	74 ee                	je     800964 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	0f b6 c0             	movzbl %al,%eax
  800979:	0f b6 12             	movzbl (%edx),%edx
  80097c:	29 d0                	sub    %edx,%eax
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800987:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80098a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800992:	85 d2                	test   %edx,%edx
  800994:	74 28                	je     8009be <strncmp+0x3e>
  800996:	0f b6 01             	movzbl (%ecx),%eax
  800999:	84 c0                	test   %al,%al
  80099b:	74 24                	je     8009c1 <strncmp+0x41>
  80099d:	3a 03                	cmp    (%ebx),%al
  80099f:	75 20                	jne    8009c1 <strncmp+0x41>
  8009a1:	83 ea 01             	sub    $0x1,%edx
  8009a4:	74 13                	je     8009b9 <strncmp+0x39>
		n--, p++, q++;
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ac:	0f b6 01             	movzbl (%ecx),%eax
  8009af:	84 c0                	test   %al,%al
  8009b1:	74 0e                	je     8009c1 <strncmp+0x41>
  8009b3:	3a 03                	cmp    (%ebx),%al
  8009b5:	74 ea                	je     8009a1 <strncmp+0x21>
  8009b7:	eb 08                	jmp    8009c1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c1:	0f b6 01             	movzbl (%ecx),%eax
  8009c4:	0f b6 13             	movzbl (%ebx),%edx
  8009c7:	29 d0                	sub    %edx,%eax
  8009c9:	eb f3                	jmp    8009be <strncmp+0x3e>

008009cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 1c                	je     8009f8 <strchr+0x2d>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	75 09                	jne    8009e9 <strchr+0x1e>
  8009e0:	eb 1b                	jmp    8009fd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009e5:	38 ca                	cmp    %cl,%dl
  8009e7:	74 14                	je     8009fd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009e9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009ed:	84 d2                	test   %dl,%dl
  8009ef:	75 f1                	jne    8009e2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	eb 05                	jmp    8009fd <strchr+0x32>
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a09:	0f b6 10             	movzbl (%eax),%edx
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	74 14                	je     800a24 <strfind+0x25>
		if (*s == c)
  800a10:	38 ca                	cmp    %cl,%dl
  800a12:	75 06                	jne    800a1a <strfind+0x1b>
  800a14:	eb 0e                	jmp    800a24 <strfind+0x25>
  800a16:	38 ca                	cmp    %cl,%dl
  800a18:	74 0a                	je     800a24 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 f2                	jne    800a16 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	53                   	push   %ebx
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a33:	89 da                	mov    %ebx,%edx
  800a35:	83 ea 01             	sub    $0x1,%edx
  800a38:	78 0d                	js     800a47 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a3a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800a3c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a3e:	88 0a                	mov    %cl,(%edx)
  800a40:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a43:	39 da                	cmp    %ebx,%edx
  800a45:	75 f7                	jne    800a3e <memset+0x18>
		*p++ = c;

	return v;
}
  800a47:	5b                   	pop    %ebx
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a59:	39 c6                	cmp    %eax,%esi
  800a5b:	72 0b                	jb     800a68 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a62:	85 db                	test   %ebx,%ebx
  800a64:	75 29                	jne    800a8f <memmove+0x45>
  800a66:	eb 35                	jmp    800a9d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a68:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800a6b:	39 c8                	cmp    %ecx,%eax
  800a6d:	73 ee                	jae    800a5d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800a6f:	85 db                	test   %ebx,%ebx
  800a71:	74 2a                	je     800a9d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a73:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800a76:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800a78:	f7 db                	neg    %ebx
  800a7a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800a7d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800a7f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a84:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a88:	83 ea 01             	sub    $0x1,%edx
  800a8b:	75 f2                	jne    800a7f <memmove+0x35>
  800a8d:	eb 0e                	jmp    800a9d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a8f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a93:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a96:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a99:	39 d3                	cmp    %edx,%ebx
  800a9b:	75 f2                	jne    800a8f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa8:	8b 45 10             	mov    0x10(%ebp),%eax
  800aab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	89 04 24             	mov    %eax,(%esp)
  800abc:	e8 89 ff ff ff       	call   800a4a <memmove>
}
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800acc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acf:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad7:	85 ff                	test   %edi,%edi
  800ad9:	74 37                	je     800b12 <memcmp+0x4f>
		if (*s1 != *s2)
  800adb:	0f b6 03             	movzbl (%ebx),%eax
  800ade:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae1:	83 ef 01             	sub    $0x1,%edi
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800ae9:	38 c8                	cmp    %cl,%al
  800aeb:	74 1c                	je     800b09 <memcmp+0x46>
  800aed:	eb 10                	jmp    800aff <memcmp+0x3c>
  800aef:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800af4:	83 c2 01             	add    $0x1,%edx
  800af7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800afb:	38 c8                	cmp    %cl,%al
  800afd:	74 0a                	je     800b09 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800aff:	0f b6 c0             	movzbl %al,%eax
  800b02:	0f b6 c9             	movzbl %cl,%ecx
  800b05:	29 c8                	sub    %ecx,%eax
  800b07:	eb 09                	jmp    800b12 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b09:	39 fa                	cmp    %edi,%edx
  800b0b:	75 e2                	jne    800aef <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b22:	39 d0                	cmp    %edx,%eax
  800b24:	73 15                	jae    800b3b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b2a:	38 08                	cmp    %cl,(%eax)
  800b2c:	75 06                	jne    800b34 <memfind+0x1d>
  800b2e:	eb 0b                	jmp    800b3b <memfind+0x24>
  800b30:	38 08                	cmp    %cl,(%eax)
  800b32:	74 07                	je     800b3b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b34:	83 c0 01             	add    $0x1,%eax
  800b37:	39 d0                	cmp    %edx,%eax
  800b39:	75 f5                	jne    800b30 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b49:	0f b6 02             	movzbl (%edx),%eax
  800b4c:	3c 20                	cmp    $0x20,%al
  800b4e:	74 04                	je     800b54 <strtol+0x17>
  800b50:	3c 09                	cmp    $0x9,%al
  800b52:	75 0e                	jne    800b62 <strtol+0x25>
		s++;
  800b54:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b57:	0f b6 02             	movzbl (%edx),%eax
  800b5a:	3c 20                	cmp    $0x20,%al
  800b5c:	74 f6                	je     800b54 <strtol+0x17>
  800b5e:	3c 09                	cmp    $0x9,%al
  800b60:	74 f2                	je     800b54 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b62:	3c 2b                	cmp    $0x2b,%al
  800b64:	75 0a                	jne    800b70 <strtol+0x33>
		s++;
  800b66:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6e:	eb 10                	jmp    800b80 <strtol+0x43>
  800b70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b75:	3c 2d                	cmp    $0x2d,%al
  800b77:	75 07                	jne    800b80 <strtol+0x43>
		s++, neg = 1;
  800b79:	83 c2 01             	add    $0x1,%edx
  800b7c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	0f 94 c0             	sete   %al
  800b85:	74 05                	je     800b8c <strtol+0x4f>
  800b87:	83 fb 10             	cmp    $0x10,%ebx
  800b8a:	75 15                	jne    800ba1 <strtol+0x64>
  800b8c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8f:	75 10                	jne    800ba1 <strtol+0x64>
  800b91:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b95:	75 0a                	jne    800ba1 <strtol+0x64>
		s += 2, base = 16;
  800b97:	83 c2 02             	add    $0x2,%edx
  800b9a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9f:	eb 13                	jmp    800bb4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ba1:	84 c0                	test   %al,%al
  800ba3:	74 0f                	je     800bb4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800baa:	80 3a 30             	cmpb   $0x30,(%edx)
  800bad:	75 05                	jne    800bb4 <strtol+0x77>
		s++, base = 8;
  800baf:	83 c2 01             	add    $0x1,%edx
  800bb2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bbb:	0f b6 0a             	movzbl (%edx),%ecx
  800bbe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bc1:	80 fb 09             	cmp    $0x9,%bl
  800bc4:	77 08                	ja     800bce <strtol+0x91>
			dig = *s - '0';
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 30             	sub    $0x30,%ecx
  800bcc:	eb 1e                	jmp    800bec <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bce:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bd1:	80 fb 19             	cmp    $0x19,%bl
  800bd4:	77 08                	ja     800bde <strtol+0xa1>
			dig = *s - 'a' + 10;
  800bd6:	0f be c9             	movsbl %cl,%ecx
  800bd9:	83 e9 57             	sub    $0x57,%ecx
  800bdc:	eb 0e                	jmp    800bec <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800bde:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 14                	ja     800bfa <strtol+0xbd>
			dig = *s - 'A' + 10;
  800be6:	0f be c9             	movsbl %cl,%ecx
  800be9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bec:	39 f1                	cmp    %esi,%ecx
  800bee:	7d 0e                	jge    800bfe <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	0f af c6             	imul   %esi,%eax
  800bf6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bf8:	eb c1                	jmp    800bbb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bfa:	89 c1                	mov    %eax,%ecx
  800bfc:	eb 02                	jmp    800c00 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bfe:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c04:	74 05                	je     800c0b <strtol+0xce>
		*endptr = (char *) s;
  800c06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c09:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c0b:	89 ca                	mov    %ecx,%edx
  800c0d:	f7 da                	neg    %edx
  800c0f:	85 ff                	test   %edi,%edi
  800c11:	0f 45 c2             	cmovne %edx,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
  800c19:	00 00                	add    %al,(%eax)
  800c1b:	00 00                	add    %al,(%eax)
  800c1d:	00 00                	add    %al,(%eax)
	...

00800c20 <__udivdi3>:
  800c20:	83 ec 1c             	sub    $0x1c,%esp
  800c23:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800c27:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800c2b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800c2f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800c33:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c37:	8b 74 24 24          	mov    0x24(%esp),%esi
  800c3b:	85 ff                	test   %edi,%edi
  800c3d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800c41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c45:	89 cd                	mov    %ecx,%ebp
  800c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c4b:	75 33                	jne    800c80 <__udivdi3+0x60>
  800c4d:	39 f1                	cmp    %esi,%ecx
  800c4f:	77 57                	ja     800ca8 <__udivdi3+0x88>
  800c51:	85 c9                	test   %ecx,%ecx
  800c53:	75 0b                	jne    800c60 <__udivdi3+0x40>
  800c55:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5a:	31 d2                	xor    %edx,%edx
  800c5c:	f7 f1                	div    %ecx
  800c5e:	89 c1                	mov    %eax,%ecx
  800c60:	89 f0                	mov    %esi,%eax
  800c62:	31 d2                	xor    %edx,%edx
  800c64:	f7 f1                	div    %ecx
  800c66:	89 c6                	mov    %eax,%esi
  800c68:	8b 44 24 04          	mov    0x4(%esp),%eax
  800c6c:	f7 f1                	div    %ecx
  800c6e:	89 f2                	mov    %esi,%edx
  800c70:	8b 74 24 10          	mov    0x10(%esp),%esi
  800c74:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800c78:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800c7c:	83 c4 1c             	add    $0x1c,%esp
  800c7f:	c3                   	ret    
  800c80:	31 d2                	xor    %edx,%edx
  800c82:	31 c0                	xor    %eax,%eax
  800c84:	39 f7                	cmp    %esi,%edi
  800c86:	77 e8                	ja     800c70 <__udivdi3+0x50>
  800c88:	0f bd cf             	bsr    %edi,%ecx
  800c8b:	83 f1 1f             	xor    $0x1f,%ecx
  800c8e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c92:	75 2c                	jne    800cc0 <__udivdi3+0xa0>
  800c94:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800c98:	76 04                	jbe    800c9e <__udivdi3+0x7e>
  800c9a:	39 f7                	cmp    %esi,%edi
  800c9c:	73 d2                	jae    800c70 <__udivdi3+0x50>
  800c9e:	31 d2                	xor    %edx,%edx
  800ca0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca5:	eb c9                	jmp    800c70 <__udivdi3+0x50>
  800ca7:	90                   	nop
  800ca8:	89 f2                	mov    %esi,%edx
  800caa:	f7 f1                	div    %ecx
  800cac:	31 d2                	xor    %edx,%edx
  800cae:	8b 74 24 10          	mov    0x10(%esp),%esi
  800cb2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800cb6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800cba:	83 c4 1c             	add    $0x1c,%esp
  800cbd:	c3                   	ret    
  800cbe:	66 90                	xchg   %ax,%ax
  800cc0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800cc5:	b8 20 00 00 00       	mov    $0x20,%eax
  800cca:	89 ea                	mov    %ebp,%edx
  800ccc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800cd0:	d3 e7                	shl    %cl,%edi
  800cd2:	89 c1                	mov    %eax,%ecx
  800cd4:	d3 ea                	shr    %cl,%edx
  800cd6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800cdb:	09 fa                	or     %edi,%edx
  800cdd:	89 f7                	mov    %esi,%edi
  800cdf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ce3:	89 f2                	mov    %esi,%edx
  800ce5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ce9:	d3 e5                	shl    %cl,%ebp
  800ceb:	89 c1                	mov    %eax,%ecx
  800ced:	d3 ef                	shr    %cl,%edi
  800cef:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800cf4:	d3 e2                	shl    %cl,%edx
  800cf6:	89 c1                	mov    %eax,%ecx
  800cf8:	d3 ee                	shr    %cl,%esi
  800cfa:	09 d6                	or     %edx,%esi
  800cfc:	89 fa                	mov    %edi,%edx
  800cfe:	89 f0                	mov    %esi,%eax
  800d00:	f7 74 24 0c          	divl   0xc(%esp)
  800d04:	89 d7                	mov    %edx,%edi
  800d06:	89 c6                	mov    %eax,%esi
  800d08:	f7 e5                	mul    %ebp
  800d0a:	39 d7                	cmp    %edx,%edi
  800d0c:	72 22                	jb     800d30 <__udivdi3+0x110>
  800d0e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800d12:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d17:	d3 e5                	shl    %cl,%ebp
  800d19:	39 c5                	cmp    %eax,%ebp
  800d1b:	73 04                	jae    800d21 <__udivdi3+0x101>
  800d1d:	39 d7                	cmp    %edx,%edi
  800d1f:	74 0f                	je     800d30 <__udivdi3+0x110>
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	31 d2                	xor    %edx,%edx
  800d25:	e9 46 ff ff ff       	jmp    800c70 <__udivdi3+0x50>
  800d2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d30:	8d 46 ff             	lea    -0x1(%esi),%eax
  800d33:	31 d2                	xor    %edx,%edx
  800d35:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d39:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800d3d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800d41:	83 c4 1c             	add    $0x1c,%esp
  800d44:	c3                   	ret    
	...

00800d50 <__umoddi3>:
  800d50:	83 ec 1c             	sub    $0x1c,%esp
  800d53:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800d57:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800d5b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800d5f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d63:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d67:	8b 74 24 24          	mov    0x24(%esp),%esi
  800d6b:	85 ed                	test   %ebp,%ebp
  800d6d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800d71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d75:	89 cf                	mov    %ecx,%edi
  800d77:	89 04 24             	mov    %eax,(%esp)
  800d7a:	89 f2                	mov    %esi,%edx
  800d7c:	75 1a                	jne    800d98 <__umoddi3+0x48>
  800d7e:	39 f1                	cmp    %esi,%ecx
  800d80:	76 4e                	jbe    800dd0 <__umoddi3+0x80>
  800d82:	f7 f1                	div    %ecx
  800d84:	89 d0                	mov    %edx,%eax
  800d86:	31 d2                	xor    %edx,%edx
  800d88:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d8c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800d90:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800d94:	83 c4 1c             	add    $0x1c,%esp
  800d97:	c3                   	ret    
  800d98:	39 f5                	cmp    %esi,%ebp
  800d9a:	77 54                	ja     800df0 <__umoddi3+0xa0>
  800d9c:	0f bd c5             	bsr    %ebp,%eax
  800d9f:	83 f0 1f             	xor    $0x1f,%eax
  800da2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da6:	75 60                	jne    800e08 <__umoddi3+0xb8>
  800da8:	3b 0c 24             	cmp    (%esp),%ecx
  800dab:	0f 87 07 01 00 00    	ja     800eb8 <__umoddi3+0x168>
  800db1:	89 f2                	mov    %esi,%edx
  800db3:	8b 34 24             	mov    (%esp),%esi
  800db6:	29 ce                	sub    %ecx,%esi
  800db8:	19 ea                	sbb    %ebp,%edx
  800dba:	89 34 24             	mov    %esi,(%esp)
  800dbd:	8b 04 24             	mov    (%esp),%eax
  800dc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800dc4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800dc8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800dcc:	83 c4 1c             	add    $0x1c,%esp
  800dcf:	c3                   	ret    
  800dd0:	85 c9                	test   %ecx,%ecx
  800dd2:	75 0b                	jne    800ddf <__umoddi3+0x8f>
  800dd4:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd9:	31 d2                	xor    %edx,%edx
  800ddb:	f7 f1                	div    %ecx
  800ddd:	89 c1                	mov    %eax,%ecx
  800ddf:	89 f0                	mov    %esi,%eax
  800de1:	31 d2                	xor    %edx,%edx
  800de3:	f7 f1                	div    %ecx
  800de5:	8b 04 24             	mov    (%esp),%eax
  800de8:	f7 f1                	div    %ecx
  800dea:	eb 98                	jmp    800d84 <__umoddi3+0x34>
  800dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df0:	89 f2                	mov    %esi,%edx
  800df2:	8b 74 24 10          	mov    0x10(%esp),%esi
  800df6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800dfa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800dfe:	83 c4 1c             	add    $0x1c,%esp
  800e01:	c3                   	ret    
  800e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e08:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e0d:	89 e8                	mov    %ebp,%eax
  800e0f:	bd 20 00 00 00       	mov    $0x20,%ebp
  800e14:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800e18:	89 fa                	mov    %edi,%edx
  800e1a:	d3 e0                	shl    %cl,%eax
  800e1c:	89 e9                	mov    %ebp,%ecx
  800e1e:	d3 ea                	shr    %cl,%edx
  800e20:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e25:	09 c2                	or     %eax,%edx
  800e27:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e2b:	89 14 24             	mov    %edx,(%esp)
  800e2e:	89 f2                	mov    %esi,%edx
  800e30:	d3 e7                	shl    %cl,%edi
  800e32:	89 e9                	mov    %ebp,%ecx
  800e34:	d3 ea                	shr    %cl,%edx
  800e36:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e3f:	d3 e6                	shl    %cl,%esi
  800e41:	89 e9                	mov    %ebp,%ecx
  800e43:	d3 e8                	shr    %cl,%eax
  800e45:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e4a:	09 f0                	or     %esi,%eax
  800e4c:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e50:	f7 34 24             	divl   (%esp)
  800e53:	d3 e6                	shl    %cl,%esi
  800e55:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e59:	89 d6                	mov    %edx,%esi
  800e5b:	f7 e7                	mul    %edi
  800e5d:	39 d6                	cmp    %edx,%esi
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	89 d7                	mov    %edx,%edi
  800e63:	72 3f                	jb     800ea4 <__umoddi3+0x154>
  800e65:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e69:	72 35                	jb     800ea0 <__umoddi3+0x150>
  800e6b:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e6f:	29 c8                	sub    %ecx,%eax
  800e71:	19 fe                	sbb    %edi,%esi
  800e73:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e78:	89 f2                	mov    %esi,%edx
  800e7a:	d3 e8                	shr    %cl,%eax
  800e7c:	89 e9                	mov    %ebp,%ecx
  800e7e:	d3 e2                	shl    %cl,%edx
  800e80:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e85:	09 d0                	or     %edx,%eax
  800e87:	89 f2                	mov    %esi,%edx
  800e89:	d3 ea                	shr    %cl,%edx
  800e8b:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e8f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e93:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e97:	83 c4 1c             	add    $0x1c,%esp
  800e9a:	c3                   	ret    
  800e9b:	90                   	nop
  800e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	39 d6                	cmp    %edx,%esi
  800ea2:	75 c7                	jne    800e6b <__umoddi3+0x11b>
  800ea4:	89 d7                	mov    %edx,%edi
  800ea6:	89 c1                	mov    %eax,%ecx
  800ea8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  800eac:	1b 3c 24             	sbb    (%esp),%edi
  800eaf:	eb ba                	jmp    800e6b <__umoddi3+0x11b>
  800eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	39 f5                	cmp    %esi,%ebp
  800eba:	0f 82 f1 fe ff ff    	jb     800db1 <__umoddi3+0x61>
  800ec0:	e9 f8 fe ff ff       	jmp    800dbd <__umoddi3+0x6d>
