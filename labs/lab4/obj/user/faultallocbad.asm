
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003b:	8b 45 08             	mov    0x8(%ebp),%eax
  80003e:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800040:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800044:	c7 04 24 40 13 80 00 	movl   $0x801340,(%esp)
  80004b:	e8 ff 01 00 00       	call   80024f <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 99 0c 00 00       	call   800d08 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 60 13 80 	movl   $0x801360,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 4a 13 80 00 	movl   $0x80134a,(%esp)
  800092:	e8 b1 00 00 00       	call   800148 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 8c 13 80 	movl   $0x80138c,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 62 07 00 00       	call   800815 <snprintf>
}
  8000b3:	83 c4 24             	add    $0x24,%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <umain>:

void
umain(void)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  8000bf:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  8000c6:	e8 05 0f 00 00       	call   800fd0 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000cb:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  8000da:	e8 0d 0b 00 00       	call   800bec <sys_cputs>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  8000f6:	e8 ad 0b 00 00       	call   800ca8 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 f6                	test   %esi,%esi
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 03                	mov    (%ebx),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80011c:	89 34 24             	mov    %esi,(%esp)
  80011f:	e8 95 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 05 0b 00 00       	call   800c4b <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80014e:	a1 08 20 80 00       	mov    0x802008,%eax
  800153:	85 c0                	test   %eax,%eax
  800155:	74 10                	je     800167 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	c7 04 24 c4 13 80 00 	movl   $0x8013c4,(%esp)
  800162:	e8 e8 00 00 00       	call   80024f <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	89 44 24 08          	mov    %eax,0x8(%esp)
  800175:	a1 00 20 80 00       	mov    0x802000,%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	c7 04 24 c9 13 80 00 	movl   $0x8013c9,(%esp)
  800185:	e8 c5 00 00 00       	call   80024f <cprintf>
	vcprintf(fmt, ap);
  80018a:	8d 45 14             	lea    0x14(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8b 45 10             	mov    0x10(%ebp),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 52 00 00 00       	call   8001ee <vcprintf>
	cprintf("\n");
  80019c:	c7 04 24 48 13 80 00 	movl   $0x801348,(%esp)
  8001a3:	e8 a7 00 00 00       	call   80024f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a8:	cc                   	int3   
  8001a9:	eb fd                	jmp    8001a8 <_panic+0x60>
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	83 c0 01             	add    $0x1,%eax
  8001c2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c9:	75 19                	jne    8001e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d2:	00 
  8001d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d6:	89 04 24             	mov    %eax,(%esp)
  8001d9:	e8 0e 0a 00 00       	call   800bec <sys_cputs>
		b->idx = 0;
  8001de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e8:	83 c4 14             	add    $0x14,%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fe:	00 00 00 
	b.cnt = 0;
  800201:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800208:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800223:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  80022a:	e8 d5 01 00 00       	call   800404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800235:	89 44 24 04          	mov    %eax,0x4(%esp)
  800239:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023f:	89 04 24             	mov    %eax,(%esp)
  800242:	e8 a5 09 00 00       	call   800bec <sys_cputs>

	return b.cnt;
}
  800247:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024d:	c9                   	leave  
  80024e:	c3                   	ret    

0080024f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800255:	8d 45 0c             	lea    0xc(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	e8 87 ff ff ff       	call   8001ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    
  800269:	00 00                	add    %al,(%eax)
  80026b:	00 00                	add    %al,(%eax)
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 3c             	sub    $0x3c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d7                	mov    %edx,%edi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800284:	8b 45 0c             	mov    0xc(%ebp),%eax
  800287:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800290:	b8 00 00 00 00       	mov    $0x0,%eax
  800295:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800298:	72 11                	jb     8002ab <printnum+0x3b>
  80029a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029d:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a0:	76 09                	jbe    8002ab <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a2:	83 eb 01             	sub    $0x1,%ebx
  8002a5:	85 db                	test   %ebx,%ebx
  8002a7:	7f 51                	jg     8002fa <printnum+0x8a>
  8002a9:	eb 5e                	jmp    800309 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ab:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002af:	83 eb 01             	sub    $0x1,%ebx
  8002b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002bd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002c1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cc:	00 
  8002cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d0:	89 04 24             	mov    %eax,(%esp)
  8002d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002da:	e8 b1 0d 00 00       	call   801090 <__udivdi3>
  8002df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e7:	89 04 24             	mov    %eax,(%esp)
  8002ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ee:	89 fa                	mov    %edi,%edx
  8002f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002f3:	e8 78 ff ff ff       	call   800270 <printnum>
  8002f8:	eb 0f                	jmp    800309 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fe:	89 34 24             	mov    %esi,(%esp)
  800301:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800304:	83 eb 01             	sub    $0x1,%ebx
  800307:	75 f1                	jne    8002fa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800311:	8b 45 10             	mov    0x10(%ebp),%eax
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	e8 8e 0e 00 00       	call   8011c0 <__umoddi3>
  800332:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800336:	0f be 80 e5 13 80 00 	movsbl 0x8013e5(%eax),%eax
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800343:	83 c4 3c             	add    $0x3c,%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034e:	83 fa 01             	cmp    $0x1,%edx
  800351:	7e 0e                	jle    800361 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800353:	8b 10                	mov    (%eax),%edx
  800355:	8d 4a 08             	lea    0x8(%edx),%ecx
  800358:	89 08                	mov    %ecx,(%eax)
  80035a:	8b 02                	mov    (%edx),%eax
  80035c:	8b 52 04             	mov    0x4(%edx),%edx
  80035f:	eb 22                	jmp    800383 <getuint+0x38>
	else if (lflag)
  800361:	85 d2                	test   %edx,%edx
  800363:	74 10                	je     800375 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800365:	8b 10                	mov    (%eax),%edx
  800367:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036a:	89 08                	mov    %ecx,(%eax)
  80036c:	8b 02                	mov    (%edx),%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	eb 0e                	jmp    800383 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800375:	8b 10                	mov    (%eax),%edx
  800377:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037a:	89 08                	mov    %ecx,(%eax)
  80037c:	8b 02                	mov    (%edx),%eax
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800388:	83 fa 01             	cmp    $0x1,%edx
  80038b:	7e 0e                	jle    80039b <getint+0x16>
		return va_arg(*ap, long long);
  80038d:	8b 10                	mov    (%eax),%edx
  80038f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800392:	89 08                	mov    %ecx,(%eax)
  800394:	8b 02                	mov    (%edx),%eax
  800396:	8b 52 04             	mov    0x4(%edx),%edx
  800399:	eb 22                	jmp    8003bd <getint+0x38>
	else if (lflag)
  80039b:	85 d2                	test   %edx,%edx
  80039d:	74 10                	je     8003af <getint+0x2a>
		return va_arg(*ap, long);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 fa 1f             	sar    $0x1f,%edx
  8003ad:	eb 0e                	jmp    8003bd <getint+0x38>
	else
		return va_arg(*ap, int);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	89 c2                	mov    %eax,%edx
  8003ba:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c9:	8b 10                	mov    (%eax),%edx
  8003cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ce:	73 0a                	jae    8003da <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d3:	88 0a                	mov    %cl,(%edx)
  8003d5:	83 c2 01             	add    $0x1,%edx
  8003d8:	89 10                	mov    %edx,(%eax)
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8003e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8003e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	89 04 24             	mov    %eax,(%esp)
  8003fd:	e8 02 00 00 00       	call   800404 <vprintfmt>
	va_end(ap);
}
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 4c             	sub    $0x4c,%esp
  80040d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800410:	8b 75 10             	mov    0x10(%ebp),%esi
  800413:	eb 12                	jmp    800427 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800415:	85 c0                	test   %eax,%eax
  800417:	0f 84 98 03 00 00    	je     8007b5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80041d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800421:	89 04 24             	mov    %eax,(%esp)
  800424:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800427:	0f b6 06             	movzbl (%esi),%eax
  80042a:	83 c6 01             	add    $0x1,%esi
  80042d:	83 f8 25             	cmp    $0x25,%eax
  800430:	75 e3                	jne    800415 <vprintfmt+0x11>
  800432:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800436:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80043d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800442:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800449:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800451:	eb 2b                	jmp    80047e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800456:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80045a:	eb 22                	jmp    80047e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80045f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800463:	eb 19                	jmp    80047e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800468:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80046f:	eb 0d                	jmp    80047e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800471:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800477:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	0f b6 06             	movzbl (%esi),%eax
  800481:	0f b6 d0             	movzbl %al,%edx
  800484:	8d 7e 01             	lea    0x1(%esi),%edi
  800487:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80048a:	83 e8 23             	sub    $0x23,%eax
  80048d:	3c 55                	cmp    $0x55,%al
  80048f:	0f 87 fa 02 00 00    	ja     80078f <vprintfmt+0x38b>
  800495:	0f b6 c0             	movzbl %al,%eax
  800498:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049f:	83 ea 30             	sub    $0x30,%edx
  8004a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004a5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004a9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004af:	83 fa 09             	cmp    $0x9,%edx
  8004b2:	77 4a                	ja     8004fe <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004ba:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004bd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004c1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c7:	83 fa 09             	cmp    $0x9,%edx
  8004ca:	76 eb                	jbe    8004b7 <vprintfmt+0xb3>
  8004cc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004cf:	eb 2d                	jmp    8004fe <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d4:	8d 50 04             	lea    0x4(%eax),%edx
  8004d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e2:	eb 1a                	jmp    8004fe <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004eb:	79 91                	jns    80047e <vprintfmt+0x7a>
  8004ed:	e9 73 ff ff ff       	jmp    800465 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004fc:	eb 80                	jmp    80047e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800502:	0f 89 76 ff ff ff    	jns    80047e <vprintfmt+0x7a>
  800508:	e9 64 ff ff ff       	jmp    800471 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800513:	e9 66 ff ff ff       	jmp    80047e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 04             	lea    0x4(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800525:	8b 00                	mov    (%eax),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800530:	e9 f2 fe ff ff       	jmp    800427 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 c2                	mov    %eax,%edx
  800542:	c1 fa 1f             	sar    $0x1f,%edx
  800545:	31 d0                	xor    %edx,%eax
  800547:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800549:	83 f8 08             	cmp    $0x8,%eax
  80054c:	7f 0b                	jg     800559 <vprintfmt+0x155>
  80054e:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	75 23                	jne    80057c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800559:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055d:	c7 44 24 08 fd 13 80 	movl   $0x8013fd,0x8(%esp)
  800564:	00 
  800565:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800569:	8b 7d 08             	mov    0x8(%ebp),%edi
  80056c:	89 3c 24             	mov    %edi,(%esp)
  80056f:	e8 68 fe ff ff       	call   8003dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800577:	e9 ab fe ff ff       	jmp    800427 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80057c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800580:	c7 44 24 08 06 14 80 	movl   $0x801406,0x8(%esp)
  800587:	00 
  800588:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058f:	89 3c 24             	mov    %edi,(%esp)
  800592:	e8 45 fe ff ff       	call   8003dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80059a:	e9 88 fe ff ff       	jmp    800427 <vprintfmt+0x23>
  80059f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 50 04             	lea    0x4(%eax),%edx
  8005ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005b3:	85 f6                	test   %esi,%esi
  8005b5:	ba f6 13 80 00       	mov    $0x8013f6,%edx
  8005ba:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005bd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005c1:	7e 06                	jle    8005c9 <vprintfmt+0x1c5>
  8005c3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005c7:	75 10                	jne    8005d9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	0f be 06             	movsbl (%esi),%eax
  8005cc:	83 c6 01             	add    $0x1,%esi
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	0f 85 86 00 00 00    	jne    80065d <vprintfmt+0x259>
  8005d7:	eb 76                	jmp    80064f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005dd:	89 34 24             	mov    %esi,(%esp)
  8005e0:	e8 76 02 00 00       	call   80085b <strnlen>
  8005e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005e8:	29 c2                	sub    %eax,%edx
  8005ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	7e d8                	jle    8005c9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  8005f1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005f5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005f8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8005fb:	89 d6                	mov    %edx,%esi
  8005fd:	89 c7                	mov    %eax,%edi
  8005ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800603:	89 3c 24             	mov    %edi,(%esp)
  800606:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	83 ee 01             	sub    $0x1,%esi
  80060c:	75 f1                	jne    8005ff <vprintfmt+0x1fb>
  80060e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800611:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800614:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800617:	eb b0                	jmp    8005c9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061d:	74 18                	je     800637 <vprintfmt+0x233>
  80061f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800622:	83 fa 5e             	cmp    $0x5e,%edx
  800625:	76 10                	jbe    800637 <vprintfmt+0x233>
					putch('?', putdat);
  800627:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	eb 0a                	jmp    800641 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800637:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063b:	89 04 24             	mov    %eax,(%esp)
  80063e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800641:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800645:	0f be 06             	movsbl (%esi),%eax
  800648:	83 c6 01             	add    $0x1,%esi
  80064b:	85 c0                	test   %eax,%eax
  80064d:	75 0e                	jne    80065d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800652:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800656:	7f 11                	jg     800669 <vprintfmt+0x265>
  800658:	e9 ca fd ff ff       	jmp    800427 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065d:	85 ff                	test   %edi,%edi
  80065f:	90                   	nop
  800660:	78 b7                	js     800619 <vprintfmt+0x215>
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	79 b2                	jns    800619 <vprintfmt+0x215>
  800667:	eb e6                	jmp    80064f <vprintfmt+0x24b>
  800669:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80066c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800673:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80067a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067c:	83 ee 01             	sub    $0x1,%esi
  80067f:	75 ee                	jne    80066f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800684:	e9 9e fd ff ff       	jmp    800427 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 f2 fc ff ff       	call   800385 <getint>
  800693:	89 c6                	mov    %eax,%esi
  800695:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800697:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069c:	85 d2                	test   %edx,%edx
  80069e:	0f 89 ad 00 00 00    	jns    800751 <vprintfmt+0x34d>
				putch('-', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b2:	f7 de                	neg    %esi
  8006b4:	83 d7 00             	adc    $0x0,%edi
  8006b7:	f7 df                	neg    %edi
			}
			base = 10;
  8006b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006be:	e9 8e 00 00 00       	jmp    800751 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c3:	89 ca                	mov    %ecx,%edx
  8006c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c8:	e8 7e fc ff ff       	call   80034b <getuint>
  8006cd:	89 c6                	mov    %eax,%esi
  8006cf:	89 d7                	mov    %edx,%edi
			base = 10;
  8006d1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006d6:	eb 79                	jmp    800751 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  8006d8:	89 ca                	mov    %ecx,%edx
  8006da:	8d 45 14             	lea    0x14(%ebp),%eax
  8006dd:	e8 a3 fc ff ff       	call   800385 <getint>
  8006e2:	89 c6                	mov    %eax,%esi
  8006e4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8006e6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	79 62                	jns    800751 <vprintfmt+0x34d>
				putch('-', putdat);
  8006ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006fd:	f7 de                	neg    %esi
  8006ff:	83 d7 00             	adc    $0x0,%edi
  800702:	f7 df                	neg    %edi
			}
			base = 8;
  800704:	b8 08 00 00 00       	mov    $0x8,%eax
  800709:	eb 46                	jmp    800751 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80070b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800716:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800719:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800724:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8d 50 04             	lea    0x4(%eax),%edx
  80072d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800730:	8b 30                	mov    (%eax),%esi
  800732:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80073c:	eb 13                	jmp    800751 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073e:	89 ca                	mov    %ecx,%edx
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
  800743:	e8 03 fc ff ff       	call   80034b <getuint>
  800748:	89 c6                	mov    %eax,%esi
  80074a:	89 d7                	mov    %edx,%edi
			base = 16;
  80074c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800751:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800755:	89 54 24 10          	mov    %edx,0x10(%esp)
  800759:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80075c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800760:	89 44 24 08          	mov    %eax,0x8(%esp)
  800764:	89 34 24             	mov    %esi,(%esp)
  800767:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076b:	89 da                	mov    %ebx,%edx
  80076d:	8b 45 08             	mov    0x8(%ebp),%eax
  800770:	e8 fb fa ff ff       	call   800270 <printnum>
			break;
  800775:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800778:	e9 aa fc ff ff       	jmp    800427 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800781:	89 14 24             	mov    %edx,(%esp)
  800784:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800787:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078a:	e9 98 fc ff ff       	jmp    800427 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800793:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80079a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007a1:	0f 84 80 fc ff ff    	je     800427 <vprintfmt+0x23>
  8007a7:	83 ee 01             	sub    $0x1,%esi
  8007aa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ae:	75 f7                	jne    8007a7 <vprintfmt+0x3a3>
  8007b0:	e9 72 fc ff ff       	jmp    800427 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007b5:	83 c4 4c             	add    $0x4c,%esp
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5f                   	pop    %edi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	83 ec 28             	sub    $0x28,%esp
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007da:	85 c0                	test   %eax,%eax
  8007dc:	74 30                	je     80080e <vsnprintf+0x51>
  8007de:	85 d2                	test   %edx,%edx
  8007e0:	7e 2c                	jle    80080e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f7:	c7 04 24 bf 03 80 00 	movl   $0x8003bf,(%esp)
  8007fe:	e8 01 fc ff ff       	call   800404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800803:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800806:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800809:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080c:	eb 05                	jmp    800813 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80080e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
  80081e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800822:	8b 45 10             	mov    0x10(%ebp),%eax
  800825:	89 44 24 08          	mov    %eax,0x8(%esp)
  800829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 82 ff ff ff       	call   8007bd <vsnprintf>
	va_end(ap);

	return rc;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    
  80083d:	00 00                	add    %al,(%eax)
	...

00800840 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
  80084b:	80 3a 00             	cmpb   $0x0,(%edx)
  80084e:	74 09                	je     800859 <strlen+0x19>
		n++;
  800850:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800853:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800857:	75 f7                	jne    800850 <strlen+0x10>
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800865:	b8 00 00 00 00       	mov    $0x0,%eax
  80086a:	85 c9                	test   %ecx,%ecx
  80086c:	74 1a                	je     800888 <strnlen+0x2d>
  80086e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800871:	74 15                	je     800888 <strnlen+0x2d>
  800873:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800878:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087a:	39 ca                	cmp    %ecx,%edx
  80087c:	74 0a                	je     800888 <strnlen+0x2d>
  80087e:	83 c2 01             	add    $0x1,%edx
  800881:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800886:	75 f0                	jne    800878 <strnlen+0x1d>
		n++;
	return n;
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800895:	ba 00 00 00 00       	mov    $0x0,%edx
  80089a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	75 f2                	jne    80089a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	85 f6                	test   %esi,%esi
  8008bb:	74 18                	je     8008d5 <strncpy+0x2a>
  8008bd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008c2:	0f b6 1a             	movzbl (%edx),%ebx
  8008c5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c8:	80 3a 01             	cmpb   $0x1,(%edx)
  8008cb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ce:	83 c1 01             	add    $0x1,%ecx
  8008d1:	39 f1                	cmp    %esi,%ecx
  8008d3:	75 ed                	jne    8008c2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5e                   	pop    %esi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	57                   	push   %edi
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
  8008df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e8:	89 f8                	mov    %edi,%eax
  8008ea:	85 f6                	test   %esi,%esi
  8008ec:	74 2b                	je     800919 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8008ee:	83 fe 01             	cmp    $0x1,%esi
  8008f1:	74 23                	je     800916 <strlcpy+0x3d>
  8008f3:	0f b6 0b             	movzbl (%ebx),%ecx
  8008f6:	84 c9                	test   %cl,%cl
  8008f8:	74 1c                	je     800916 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008fa:	83 ee 02             	sub    $0x2,%esi
  8008fd:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800902:	88 08                	mov    %cl,(%eax)
  800904:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800907:	39 f2                	cmp    %esi,%edx
  800909:	74 0b                	je     800916 <strlcpy+0x3d>
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800912:	84 c9                	test   %cl,%cl
  800914:	75 ec                	jne    800902 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800916:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800919:	29 f8                	sub    %edi,%eax
}
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800929:	0f b6 01             	movzbl (%ecx),%eax
  80092c:	84 c0                	test   %al,%al
  80092e:	74 16                	je     800946 <strcmp+0x26>
  800930:	3a 02                	cmp    (%edx),%al
  800932:	75 12                	jne    800946 <strcmp+0x26>
		p++, q++;
  800934:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800937:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80093b:	84 c0                	test   %al,%al
  80093d:	74 07                	je     800946 <strcmp+0x26>
  80093f:	83 c1 01             	add    $0x1,%ecx
  800942:	3a 02                	cmp    (%edx),%al
  800944:	74 ee                	je     800934 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800946:	0f b6 c0             	movzbl %al,%eax
  800949:	0f b6 12             	movzbl (%edx),%edx
  80094c:	29 d0                	sub    %edx,%eax
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800957:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800962:	85 d2                	test   %edx,%edx
  800964:	74 28                	je     80098e <strncmp+0x3e>
  800966:	0f b6 01             	movzbl (%ecx),%eax
  800969:	84 c0                	test   %al,%al
  80096b:	74 24                	je     800991 <strncmp+0x41>
  80096d:	3a 03                	cmp    (%ebx),%al
  80096f:	75 20                	jne    800991 <strncmp+0x41>
  800971:	83 ea 01             	sub    $0x1,%edx
  800974:	74 13                	je     800989 <strncmp+0x39>
		n--, p++, q++;
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097c:	0f b6 01             	movzbl (%ecx),%eax
  80097f:	84 c0                	test   %al,%al
  800981:	74 0e                	je     800991 <strncmp+0x41>
  800983:	3a 03                	cmp    (%ebx),%al
  800985:	74 ea                	je     800971 <strncmp+0x21>
  800987:	eb 08                	jmp    800991 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800989:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098e:	5b                   	pop    %ebx
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 01             	movzbl (%ecx),%eax
  800994:	0f b6 13             	movzbl (%ebx),%edx
  800997:	29 d0                	sub    %edx,%eax
  800999:	eb f3                	jmp    80098e <strncmp+0x3e>

0080099b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	74 1c                	je     8009c8 <strchr+0x2d>
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	75 09                	jne    8009b9 <strchr+0x1e>
  8009b0:	eb 1b                	jmp    8009cd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009b5:	38 ca                	cmp    %cl,%dl
  8009b7:	74 14                	je     8009cd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009b9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009bd:	84 d2                	test   %dl,%dl
  8009bf:	75 f1                	jne    8009b2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	eb 05                	jmp    8009cd <strchr+0x32>
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d9:	0f b6 10             	movzbl (%eax),%edx
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	74 14                	je     8009f4 <strfind+0x25>
		if (*s == c)
  8009e0:	38 ca                	cmp    %cl,%dl
  8009e2:	75 06                	jne    8009ea <strfind+0x1b>
  8009e4:	eb 0e                	jmp    8009f4 <strfind+0x25>
  8009e6:	38 ca                	cmp    %cl,%dl
  8009e8:	74 0a                	je     8009f4 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 f2                	jne    8009e6 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memset>:


void *
memset(void *v, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a03:	89 da                	mov    %ebx,%edx
  800a05:	83 ea 01             	sub    $0x1,%edx
  800a08:	78 0d                	js     800a17 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a0a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800a0c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a0e:	88 0a                	mov    %cl,(%edx)
  800a10:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	75 f7                	jne    800a0e <memset+0x18>
		*p++ = c;

	return v;
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	57                   	push   %edi
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a29:	39 c6                	cmp    %eax,%esi
  800a2b:	72 0b                	jb     800a38 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	85 db                	test   %ebx,%ebx
  800a34:	75 29                	jne    800a5f <memmove+0x45>
  800a36:	eb 35                	jmp    800a6d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a38:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800a3b:	39 c8                	cmp    %ecx,%eax
  800a3d:	73 ee                	jae    800a2d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800a3f:	85 db                	test   %ebx,%ebx
  800a41:	74 2a                	je     800a6d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a43:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800a46:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800a48:	f7 db                	neg    %ebx
  800a4a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800a4d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800a4f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a54:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a58:	83 ea 01             	sub    $0x1,%edx
  800a5b:	75 f2                	jne    800a4f <memmove+0x35>
  800a5d:	eb 0e                	jmp    800a6d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a5f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a63:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a66:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a69:	39 d3                	cmp    %edx,%ebx
  800a6b:	75 f2                	jne    800a5f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a78:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	89 04 24             	mov    %eax,(%esp)
  800a8c:	e8 89 ff ff ff       	call   800a1a <memmove>
}
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa7:	85 ff                	test   %edi,%edi
  800aa9:	74 37                	je     800ae2 <memcmp+0x4f>
		if (*s1 != *s2)
  800aab:	0f b6 03             	movzbl (%ebx),%eax
  800aae:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	83 ef 01             	sub    $0x1,%edi
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800ab9:	38 c8                	cmp    %cl,%al
  800abb:	74 1c                	je     800ad9 <memcmp+0x46>
  800abd:	eb 10                	jmp    800acf <memcmp+0x3c>
  800abf:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ac4:	83 c2 01             	add    $0x1,%edx
  800ac7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800acb:	38 c8                	cmp    %cl,%al
  800acd:	74 0a                	je     800ad9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800acf:	0f b6 c0             	movzbl %al,%eax
  800ad2:	0f b6 c9             	movzbl %cl,%ecx
  800ad5:	29 c8                	sub    %ecx,%eax
  800ad7:	eb 09                	jmp    800ae2 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad9:	39 fa                	cmp    %edi,%edx
  800adb:	75 e2                	jne    800abf <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aed:	89 c2                	mov    %eax,%edx
  800aef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af2:	39 d0                	cmp    %edx,%eax
  800af4:	73 15                	jae    800b0b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800afa:	38 08                	cmp    %cl,(%eax)
  800afc:	75 06                	jne    800b04 <memfind+0x1d>
  800afe:	eb 0b                	jmp    800b0b <memfind+0x24>
  800b00:	38 08                	cmp    %cl,(%eax)
  800b02:	74 07                	je     800b0b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b04:	83 c0 01             	add    $0x1,%eax
  800b07:	39 d0                	cmp    %edx,%eax
  800b09:	75 f5                	jne    800b00 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b19:	0f b6 02             	movzbl (%edx),%eax
  800b1c:	3c 20                	cmp    $0x20,%al
  800b1e:	74 04                	je     800b24 <strtol+0x17>
  800b20:	3c 09                	cmp    $0x9,%al
  800b22:	75 0e                	jne    800b32 <strtol+0x25>
		s++;
  800b24:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b27:	0f b6 02             	movzbl (%edx),%eax
  800b2a:	3c 20                	cmp    $0x20,%al
  800b2c:	74 f6                	je     800b24 <strtol+0x17>
  800b2e:	3c 09                	cmp    $0x9,%al
  800b30:	74 f2                	je     800b24 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b32:	3c 2b                	cmp    $0x2b,%al
  800b34:	75 0a                	jne    800b40 <strtol+0x33>
		s++;
  800b36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b39:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3e:	eb 10                	jmp    800b50 <strtol+0x43>
  800b40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b45:	3c 2d                	cmp    $0x2d,%al
  800b47:	75 07                	jne    800b50 <strtol+0x43>
		s++, neg = 1;
  800b49:	83 c2 01             	add    $0x1,%edx
  800b4c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b50:	85 db                	test   %ebx,%ebx
  800b52:	0f 94 c0             	sete   %al
  800b55:	74 05                	je     800b5c <strtol+0x4f>
  800b57:	83 fb 10             	cmp    $0x10,%ebx
  800b5a:	75 15                	jne    800b71 <strtol+0x64>
  800b5c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5f:	75 10                	jne    800b71 <strtol+0x64>
  800b61:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b65:	75 0a                	jne    800b71 <strtol+0x64>
		s += 2, base = 16;
  800b67:	83 c2 02             	add    $0x2,%edx
  800b6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b6f:	eb 13                	jmp    800b84 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b71:	84 c0                	test   %al,%al
  800b73:	74 0f                	je     800b84 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b75:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7d:	75 05                	jne    800b84 <strtol+0x77>
		s++, base = 8;
  800b7f:	83 c2 01             	add    $0x1,%edx
  800b82:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
  800b89:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b8b:	0f b6 0a             	movzbl (%edx),%ecx
  800b8e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b91:	80 fb 09             	cmp    $0x9,%bl
  800b94:	77 08                	ja     800b9e <strtol+0x91>
			dig = *s - '0';
  800b96:	0f be c9             	movsbl %cl,%ecx
  800b99:	83 e9 30             	sub    $0x30,%ecx
  800b9c:	eb 1e                	jmp    800bbc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b9e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ba1:	80 fb 19             	cmp    $0x19,%bl
  800ba4:	77 08                	ja     800bae <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 57             	sub    $0x57,%ecx
  800bac:	eb 0e                	jmp    800bbc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800bae:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 14                	ja     800bca <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bbc:	39 f1                	cmp    %esi,%ecx
  800bbe:	7d 0e                	jge    800bce <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bc0:	83 c2 01             	add    $0x1,%edx
  800bc3:	0f af c6             	imul   %esi,%eax
  800bc6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bc8:	eb c1                	jmp    800b8b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bca:	89 c1                	mov    %eax,%ecx
  800bcc:	eb 02                	jmp    800bd0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bce:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd4:	74 05                	je     800bdb <strtol+0xce>
		*endptr = (char *) s;
  800bd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bdb:	89 ca                	mov    %ecx,%edx
  800bdd:	f7 da                	neg    %edx
  800bdf:	85 ff                	test   %edi,%edi
  800be1:	0f 45 c2             	cmovne %edx,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
  800be9:	00 00                	add    %al,(%eax)
	...

00800bec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 0c             	sub    $0xc,%esp
  800bf2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bf5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bf8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	89 c3                	mov    %eax,%ebx
  800c08:	89 c7                	mov    %eax,%edi
  800c0a:	89 c6                	mov    %eax,%esi
  800c0c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c11:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c14:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c17:	89 ec                	mov    %ebp,%esp
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c34:	89 d1                	mov    %edx,%ecx
  800c36:	89 d3                	mov    %edx,%ebx
  800c38:	89 d7                	mov    %edx,%edi
  800c3a:	89 d6                	mov    %edx,%esi
  800c3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c47:	89 ec                	mov    %ebp,%esp
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 38             	sub    $0x38,%esp
  800c51:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c57:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 cb                	mov    %ecx,%ebx
  800c69:	89 cf                	mov    %ecx,%edi
  800c6b:	89 ce                	mov    %ecx,%esi
  800c6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7e 28                	jle    800c9b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800c86:	00 
  800c87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8e:	00 
  800c8f:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800c96:	e8 ad f4 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c9e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ca4:	89 ec                	mov    %ebp,%esp
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cb1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cb4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbc:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc1:	89 d1                	mov    %edx,%ecx
  800cc3:	89 d3                	mov    %edx,%ebx
  800cc5:	89 d7                	mov    %edx,%edi
  800cc7:	89 d6                	mov    %edx,%esi
  800cc9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ccb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cce:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cd1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd4:	89 ec                	mov    %ebp,%esp
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_yield>:

void
sys_yield(void)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ce1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf1:	89 d1                	mov    %edx,%ecx
  800cf3:	89 d3                	mov    %edx,%ebx
  800cf5:	89 d7                	mov    %edx,%edi
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cfb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cfe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d04:	89 ec                	mov    %ebp,%esp
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	83 ec 38             	sub    $0x38,%esp
  800d0e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d11:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d14:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	be 00 00 00 00       	mov    $0x0,%esi
  800d1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 f7                	mov    %esi,%edi
  800d2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7e 28                	jle    800d5a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d36:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800d45:	00 
  800d46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4d:	00 
  800d4e:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800d55:	e8 ee f3 ff ff       	call   800148 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d5a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d5d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d60:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d63:	89 ec                	mov    %ebp,%esp
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 38             	sub    $0x38,%esp
  800d6d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d70:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d73:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 28                	jle    800db8 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d94:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800da3:	00 
  800da4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dab:	00 
  800dac:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800db3:	e8 90 f3 ff ff       	call   800148 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800db8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dbb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbe:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc1:	89 ec                	mov    %ebp,%esp
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	83 ec 38             	sub    $0x38,%esp
  800dcb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dce:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd9:	b8 06 00 00 00       	mov    $0x6,%eax
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	8b 55 08             	mov    0x8(%ebp),%edx
  800de4:	89 df                	mov    %ebx,%edi
  800de6:	89 de                	mov    %ebx,%esi
  800de8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7e 28                	jle    800e16 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800df9:	00 
  800dfa:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e01:	00 
  800e02:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e09:	00 
  800e0a:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e11:	e8 32 f3 ff ff       	call   800148 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e16:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e19:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e1c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1f:	89 ec                	mov    %ebp,%esp
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	83 ec 38             	sub    $0x38,%esp
  800e29:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e2c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e37:	b8 08 00 00 00       	mov    $0x8,%eax
  800e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	89 df                	mov    %ebx,%edi
  800e44:	89 de                	mov    %ebx,%esi
  800e46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	7e 28                	jle    800e74 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e50:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e57:	00 
  800e58:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e5f:	00 
  800e60:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e67:	00 
  800e68:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e6f:	e8 d4 f2 ff ff       	call   800148 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e74:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e77:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7d:	89 ec                	mov    %ebp,%esp
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 38             	sub    $0x38,%esp
  800e87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e95:	b8 09 00 00 00       	mov    $0x9,%eax
  800e9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	89 df                	mov    %ebx,%edi
  800ea2:	89 de                	mov    %ebx,%esi
  800ea4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	7e 28                	jle    800ed2 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eaa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eae:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800ebd:	00 
  800ebe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec5:	00 
  800ec6:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800ecd:	e8 76 f2 ff ff       	call   800148 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ed2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800edb:	89 ec                	mov    %ebp,%esp
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	83 ec 38             	sub    $0x38,%esp
  800ee5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eeb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	89 df                	mov    %ebx,%edi
  800f00:	89 de                	mov    %ebx,%esi
  800f02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 28                	jle    800f30 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f13:	00 
  800f14:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800f2b:	e8 18 f2 ff ff       	call   800148 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f30:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f33:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f36:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f39:	89 ec                	mov    %ebp,%esp
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f46:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f49:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	be 00 00 00 00       	mov    $0x0,%esi
  800f51:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f59:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f64:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f67:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f6a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f6d:	89 ec                	mov    %ebp,%esp
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 38             	sub    $0x38,%esp
  800f77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8d:	89 cb                	mov    %ecx,%ebx
  800f8f:	89 cf                	mov    %ecx,%edi
  800f91:	89 ce                	mov    %ecx,%esi
  800f93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f95:	85 c0                	test   %eax,%eax
  800f97:	7e 28                	jle    800fc1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fa4:	00 
  800fa5:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800fac:	00 
  800fad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb4:	00 
  800fb5:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800fbc:	e8 87 f1 ff ff       	call   800148 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fc1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fca:	89 ec                	mov    %ebp,%esp
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    
	...

00800fd0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 14             	sub    $0x14,%esp
	int r;

	// Set the page fault handler function.
	// If there isn't one yet, _pgfault_handler will be 0.
	if (_pgfault_handler == 0) {
  800fd7:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800fde:	75 77                	jne    801057 <set_pgfault_handler+0x87>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800fe0:	e8 c3 fc ff ff       	call   800ca8 <sys_getenvid>
  800fe5:	89 c3                	mov    %eax,%ebx
		// The first time we register a handler, we need to 
		// allocate an exception stack (one page of memory with its top
		// at UXSTACKTOP). [UXSTACKTOP-PGSIZE, UXSTACKTOP-1]
		// user can read, write
		if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE),
  800fe7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fee:	00 
  800fef:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800ff6:	ee 
  800ff7:	89 04 24             	mov    %eax,(%esp)
  800ffa:	e8 09 fd ff ff       	call   800d08 <sys_page_alloc>
  800fff:	85 c0                	test   %eax,%eax
  801001:	79 20                	jns    801023 <set_pgfault_handler+0x53>
			PTE_W | PTE_U | PTE_P)) < 0)
		{
			panic("sys_page_alloc: %e", r);
  801003:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801007:	c7 44 24 08 4f 16 80 	movl   $0x80164f,0x8(%esp)
  80100e:	00 
  80100f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801016:	00 
  801017:	c7 04 24 62 16 80 00 	movl   $0x801662,(%esp)
  80101e:	e8 25 f1 ff ff       	call   800148 <_panic>
			return;
		}
		// tell the kernel to call the assembly-language
		// _pgfault_upcall routine when a page fault occurs.
		if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801023:	c7 44 24 04 68 10 80 	movl   $0x801068,0x4(%esp)
  80102a:	00 
  80102b:	89 1c 24             	mov    %ebx,(%esp)
  80102e:	e8 ac fe ff ff       	call   800edf <sys_env_set_pgfault_upcall>
  801033:	85 c0                	test   %eax,%eax
  801035:	79 20                	jns    801057 <set_pgfault_handler+0x87>
		{
			panic("sys_env_set_pgfault_upcall: %e", r);
  801037:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80103b:	c7 44 24 08 70 16 80 	movl   $0x801670,0x8(%esp)
  801042:	00 
  801043:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80104a:	00 
  80104b:	c7 04 24 62 16 80 00 	movl   $0x801662,(%esp)
  801052:	e8 f1 f0 ff ff       	call   800148 <_panic>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80105f:	83 c4 14             	add    $0x14,%esp
  801062:	5b                   	pop    %ebx
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    
  801065:	00 00                	add    %al,(%eax)
	...

00801068 <_pgfault_upcall>:
  801068:	54                   	push   %esp
  801069:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80106e:	ff d0                	call   *%eax
  801070:	83 c4 04             	add    $0x4,%esp
  801073:	8b 44 24 28          	mov    0x28(%esp),%eax
  801077:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80107b:	89 41 fc             	mov    %eax,-0x4(%ecx)
  80107e:	83 c4 08             	add    $0x8,%esp
  801081:	61                   	popa   
  801082:	83 c4 04             	add    $0x4,%esp
  801085:	9d                   	popf   
  801086:	5c                   	pop    %esp
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	c3                   	ret    
  80108b:	00 00                	add    %al,(%eax)
  80108d:	00 00                	add    %al,(%eax)
	...

00801090 <__udivdi3>:
  801090:	83 ec 1c             	sub    $0x1c,%esp
  801093:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801097:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80109b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80109f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010a3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010a7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010ab:	85 ff                	test   %edi,%edi
  8010ad:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b5:	89 cd                	mov    %ecx,%ebp
  8010b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bb:	75 33                	jne    8010f0 <__udivdi3+0x60>
  8010bd:	39 f1                	cmp    %esi,%ecx
  8010bf:	77 57                	ja     801118 <__udivdi3+0x88>
  8010c1:	85 c9                	test   %ecx,%ecx
  8010c3:	75 0b                	jne    8010d0 <__udivdi3+0x40>
  8010c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ca:	31 d2                	xor    %edx,%edx
  8010cc:	f7 f1                	div    %ecx
  8010ce:	89 c1                	mov    %eax,%ecx
  8010d0:	89 f0                	mov    %esi,%eax
  8010d2:	31 d2                	xor    %edx,%edx
  8010d4:	f7 f1                	div    %ecx
  8010d6:	89 c6                	mov    %eax,%esi
  8010d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010dc:	f7 f1                	div    %ecx
  8010de:	89 f2                	mov    %esi,%edx
  8010e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ec:	83 c4 1c             	add    $0x1c,%esp
  8010ef:	c3                   	ret    
  8010f0:	31 d2                	xor    %edx,%edx
  8010f2:	31 c0                	xor    %eax,%eax
  8010f4:	39 f7                	cmp    %esi,%edi
  8010f6:	77 e8                	ja     8010e0 <__udivdi3+0x50>
  8010f8:	0f bd cf             	bsr    %edi,%ecx
  8010fb:	83 f1 1f             	xor    $0x1f,%ecx
  8010fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801102:	75 2c                	jne    801130 <__udivdi3+0xa0>
  801104:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801108:	76 04                	jbe    80110e <__udivdi3+0x7e>
  80110a:	39 f7                	cmp    %esi,%edi
  80110c:	73 d2                	jae    8010e0 <__udivdi3+0x50>
  80110e:	31 d2                	xor    %edx,%edx
  801110:	b8 01 00 00 00       	mov    $0x1,%eax
  801115:	eb c9                	jmp    8010e0 <__udivdi3+0x50>
  801117:	90                   	nop
  801118:	89 f2                	mov    %esi,%edx
  80111a:	f7 f1                	div    %ecx
  80111c:	31 d2                	xor    %edx,%edx
  80111e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801122:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801126:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80112a:	83 c4 1c             	add    $0x1c,%esp
  80112d:	c3                   	ret    
  80112e:	66 90                	xchg   %ax,%ax
  801130:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801135:	b8 20 00 00 00       	mov    $0x20,%eax
  80113a:	89 ea                	mov    %ebp,%edx
  80113c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801140:	d3 e7                	shl    %cl,%edi
  801142:	89 c1                	mov    %eax,%ecx
  801144:	d3 ea                	shr    %cl,%edx
  801146:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80114b:	09 fa                	or     %edi,%edx
  80114d:	89 f7                	mov    %esi,%edi
  80114f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801153:	89 f2                	mov    %esi,%edx
  801155:	8b 74 24 08          	mov    0x8(%esp),%esi
  801159:	d3 e5                	shl    %cl,%ebp
  80115b:	89 c1                	mov    %eax,%ecx
  80115d:	d3 ef                	shr    %cl,%edi
  80115f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801164:	d3 e2                	shl    %cl,%edx
  801166:	89 c1                	mov    %eax,%ecx
  801168:	d3 ee                	shr    %cl,%esi
  80116a:	09 d6                	or     %edx,%esi
  80116c:	89 fa                	mov    %edi,%edx
  80116e:	89 f0                	mov    %esi,%eax
  801170:	f7 74 24 0c          	divl   0xc(%esp)
  801174:	89 d7                	mov    %edx,%edi
  801176:	89 c6                	mov    %eax,%esi
  801178:	f7 e5                	mul    %ebp
  80117a:	39 d7                	cmp    %edx,%edi
  80117c:	72 22                	jb     8011a0 <__udivdi3+0x110>
  80117e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801182:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801187:	d3 e5                	shl    %cl,%ebp
  801189:	39 c5                	cmp    %eax,%ebp
  80118b:	73 04                	jae    801191 <__udivdi3+0x101>
  80118d:	39 d7                	cmp    %edx,%edi
  80118f:	74 0f                	je     8011a0 <__udivdi3+0x110>
  801191:	89 f0                	mov    %esi,%eax
  801193:	31 d2                	xor    %edx,%edx
  801195:	e9 46 ff ff ff       	jmp    8010e0 <__udivdi3+0x50>
  80119a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011a0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011a3:	31 d2                	xor    %edx,%edx
  8011a5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011a9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011ad:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011b1:	83 c4 1c             	add    $0x1c,%esp
  8011b4:	c3                   	ret    
	...

008011c0 <__umoddi3>:
  8011c0:	83 ec 1c             	sub    $0x1c,%esp
  8011c3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011c7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011cb:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011cf:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011d3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011d7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011db:	85 ed                	test   %ebp,%ebp
  8011dd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e5:	89 cf                	mov    %ecx,%edi
  8011e7:	89 04 24             	mov    %eax,(%esp)
  8011ea:	89 f2                	mov    %esi,%edx
  8011ec:	75 1a                	jne    801208 <__umoddi3+0x48>
  8011ee:	39 f1                	cmp    %esi,%ecx
  8011f0:	76 4e                	jbe    801240 <__umoddi3+0x80>
  8011f2:	f7 f1                	div    %ecx
  8011f4:	89 d0                	mov    %edx,%eax
  8011f6:	31 d2                	xor    %edx,%edx
  8011f8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011fc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801200:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801204:	83 c4 1c             	add    $0x1c,%esp
  801207:	c3                   	ret    
  801208:	39 f5                	cmp    %esi,%ebp
  80120a:	77 54                	ja     801260 <__umoddi3+0xa0>
  80120c:	0f bd c5             	bsr    %ebp,%eax
  80120f:	83 f0 1f             	xor    $0x1f,%eax
  801212:	89 44 24 04          	mov    %eax,0x4(%esp)
  801216:	75 60                	jne    801278 <__umoddi3+0xb8>
  801218:	3b 0c 24             	cmp    (%esp),%ecx
  80121b:	0f 87 07 01 00 00    	ja     801328 <__umoddi3+0x168>
  801221:	89 f2                	mov    %esi,%edx
  801223:	8b 34 24             	mov    (%esp),%esi
  801226:	29 ce                	sub    %ecx,%esi
  801228:	19 ea                	sbb    %ebp,%edx
  80122a:	89 34 24             	mov    %esi,(%esp)
  80122d:	8b 04 24             	mov    (%esp),%eax
  801230:	8b 74 24 10          	mov    0x10(%esp),%esi
  801234:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801238:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80123c:	83 c4 1c             	add    $0x1c,%esp
  80123f:	c3                   	ret    
  801240:	85 c9                	test   %ecx,%ecx
  801242:	75 0b                	jne    80124f <__umoddi3+0x8f>
  801244:	b8 01 00 00 00       	mov    $0x1,%eax
  801249:	31 d2                	xor    %edx,%edx
  80124b:	f7 f1                	div    %ecx
  80124d:	89 c1                	mov    %eax,%ecx
  80124f:	89 f0                	mov    %esi,%eax
  801251:	31 d2                	xor    %edx,%edx
  801253:	f7 f1                	div    %ecx
  801255:	8b 04 24             	mov    (%esp),%eax
  801258:	f7 f1                	div    %ecx
  80125a:	eb 98                	jmp    8011f4 <__umoddi3+0x34>
  80125c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 f2                	mov    %esi,%edx
  801262:	8b 74 24 10          	mov    0x10(%esp),%esi
  801266:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80126a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80126e:	83 c4 1c             	add    $0x1c,%esp
  801271:	c3                   	ret    
  801272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801278:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80127d:	89 e8                	mov    %ebp,%eax
  80127f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801284:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801288:	89 fa                	mov    %edi,%edx
  80128a:	d3 e0                	shl    %cl,%eax
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	d3 ea                	shr    %cl,%edx
  801290:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801295:	09 c2                	or     %eax,%edx
  801297:	8b 44 24 08          	mov    0x8(%esp),%eax
  80129b:	89 14 24             	mov    %edx,(%esp)
  80129e:	89 f2                	mov    %esi,%edx
  8012a0:	d3 e7                	shl    %cl,%edi
  8012a2:	89 e9                	mov    %ebp,%ecx
  8012a4:	d3 ea                	shr    %cl,%edx
  8012a6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012af:	d3 e6                	shl    %cl,%esi
  8012b1:	89 e9                	mov    %ebp,%ecx
  8012b3:	d3 e8                	shr    %cl,%eax
  8012b5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ba:	09 f0                	or     %esi,%eax
  8012bc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012c0:	f7 34 24             	divl   (%esp)
  8012c3:	d3 e6                	shl    %cl,%esi
  8012c5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012c9:	89 d6                	mov    %edx,%esi
  8012cb:	f7 e7                	mul    %edi
  8012cd:	39 d6                	cmp    %edx,%esi
  8012cf:	89 c1                	mov    %eax,%ecx
  8012d1:	89 d7                	mov    %edx,%edi
  8012d3:	72 3f                	jb     801314 <__umoddi3+0x154>
  8012d5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012d9:	72 35                	jb     801310 <__umoddi3+0x150>
  8012db:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012df:	29 c8                	sub    %ecx,%eax
  8012e1:	19 fe                	sbb    %edi,%esi
  8012e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012e8:	89 f2                	mov    %esi,%edx
  8012ea:	d3 e8                	shr    %cl,%eax
  8012ec:	89 e9                	mov    %ebp,%ecx
  8012ee:	d3 e2                	shl    %cl,%edx
  8012f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012f5:	09 d0                	or     %edx,%eax
  8012f7:	89 f2                	mov    %esi,%edx
  8012f9:	d3 ea                	shr    %cl,%edx
  8012fb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012ff:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801303:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801307:	83 c4 1c             	add    $0x1c,%esp
  80130a:	c3                   	ret    
  80130b:	90                   	nop
  80130c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801310:	39 d6                	cmp    %edx,%esi
  801312:	75 c7                	jne    8012db <__umoddi3+0x11b>
  801314:	89 d7                	mov    %edx,%edi
  801316:	89 c1                	mov    %eax,%ecx
  801318:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80131c:	1b 3c 24             	sbb    (%esp),%edi
  80131f:	eb ba                	jmp    8012db <__umoddi3+0x11b>
  801321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801328:	39 f5                	cmp    %esi,%ebp
  80132a:	0f 82 f1 fe ff ff    	jb     801221 <__umoddi3+0x61>
  801330:	e9 f8 fe ff ff       	jmp    80122d <__umoddi3+0x6d>
