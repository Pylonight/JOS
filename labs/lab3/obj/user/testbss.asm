
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ef 00 00 00       	call   800120 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 a8 0f 80 00 	movl   $0x800fa8,(%esp)
  800041:	e8 2d 02 00 00       	call   800273 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80004d:	75 11                	jne    800060 <umain+0x2c>
umain(void)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != 0)
  800054:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  80005b:	00 
  80005c:	74 27                	je     800085 <umain+0x51>
  80005e:	eb 05                	jmp    800065 <umain+0x31>
umain(void)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800069:	c7 44 24 08 24 10 80 	movl   $0x801024,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 41 10 80 00 	movl   $0x801041,(%esp)
  800080:	e8 e7 00 00 00       	call   80016c <_panic>
umain(void)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800085:	83 c0 01             	add    $0x1,%eax
  800088:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008d:	75 c5                	jne    800054 <umain+0x20>
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800094:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009b:	83 c0 01             	add    $0x1,%eax
  80009e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a3:	75 ef                	jne    800094 <umain+0x60>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a5:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000ac:	75 10                	jne    8000be <umain+0x8a>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000ae:	b8 01 00 00 00       	mov    $0x1,%eax
		if (bigarray[i] != i)
  8000b3:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000ba:	74 27                	je     8000e3 <umain+0xaf>
  8000bc:	eb 05                	jmp    8000c3 <umain+0x8f>
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c7:	c7 44 24 08 c8 0f 80 	movl   $0x800fc8,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 41 10 80 00 	movl   $0x801041,(%esp)
  8000de:	e8 89 00 00 00       	call   80016c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e3:	83 c0 01             	add    $0x1,%eax
  8000e6:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000eb:	75 c6                	jne    8000b3 <umain+0x7f>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ed:	c7 04 24 f0 0f 80 00 	movl   $0x800ff0,(%esp)
  8000f4:	e8 7a 01 00 00       	call   800273 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f9:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  800100:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800103:	c7 44 24 08 50 10 80 	movl   $0x801050,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 41 10 80 00 	movl   $0x801041,(%esp)
  80011a:	e8 4d 00 00 00       	call   80016c <_panic>
	...

00800120 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80012c:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  800133:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 c0                	test   %eax,%eax
  800138:	7e 08                	jle    800142 <libmain+0x22>
		binaryname = argv[0];
  80013a:	8b 0a                	mov    (%edx),%ecx
  80013c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800142:	89 54 24 04          	mov    %edx,0x4(%esp)
  800146:	89 04 24             	mov    %eax,(%esp)
  800149:	e8 e6 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014e:	e8 05 00 00 00       	call   800158 <exit>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    
  800155:	00 00                	add    %al,(%eax)
	...

00800158 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80015e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800165:	e8 01 0b 00 00       	call   800c6b <sys_env_destroy>
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800172:	a1 24 20 c0 00       	mov    0xc02024,%eax
  800177:	85 c0                	test   %eax,%eax
  800179:	74 10                	je     80018b <_panic+0x1f>
		cprintf("%s: ", argv0);
  80017b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017f:	c7 04 24 7e 10 80 00 	movl   $0x80107e,(%esp)
  800186:	e8 e8 00 00 00       	call   800273 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80018b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 44 24 08          	mov    %eax,0x8(%esp)
  800199:	a1 00 20 80 00       	mov    0x802000,%eax
  80019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a2:	c7 04 24 83 10 80 00 	movl   $0x801083,(%esp)
  8001a9:	e8 c5 00 00 00       	call   800273 <cprintf>
	vcprintf(fmt, ap);
  8001ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 52 00 00 00       	call   800212 <vcprintf>
	cprintf("\n");
  8001c0:	c7 04 24 3f 10 80 00 	movl   $0x80103f,(%esp)
  8001c7:	e8 a7 00 00 00       	call   800273 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cc:	cc                   	int3   
  8001cd:	eb fd                	jmp    8001cc <_panic+0x60>
	...

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 14             	sub    $0x14,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 03                	mov    (%ebx),%eax
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001e3:	83 c0 01             	add    $0x1,%eax
  8001e6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ed:	75 19                	jne    800208 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f6:	00 
  8001f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fa:	89 04 24             	mov    %eax,(%esp)
  8001fd:	e8 0a 0a 00 00       	call   800c0c <sys_cputs>
		b->idx = 0;
  800202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800208:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80020c:	83 c4 14             	add    $0x14,%esp
  80020f:	5b                   	pop    %ebx
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800222:	00 00 00 
	b.cnt = 0;
  800225:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800232:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800243:	89 44 24 04          	mov    %eax,0x4(%esp)
  800247:	c7 04 24 d0 01 80 00 	movl   $0x8001d0,(%esp)
  80024e:	e8 d1 01 00 00       	call   800424 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800253:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	e8 a1 09 00 00       	call   800c0c <sys_cputs>

	return b.cnt;
}
  80026b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800279:	8d 45 0c             	lea    0xc(%ebp),%eax
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 87 ff ff ff       	call   800212 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    
  80028d:	00 00                	add    %al,(%eax)
	...

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 3c             	sub    $0x3c,%esp
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	89 d7                	mov    %edx,%edi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002b8:	72 11                	jb     8002cb <printnum+0x3b>
  8002ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002c0:	76 09                	jbe    8002cb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c2:	83 eb 01             	sub    $0x1,%ebx
  8002c5:	85 db                	test   %ebx,%ebx
  8002c7:	7f 51                	jg     80031a <printnum+0x8a>
  8002c9:	eb 5e                	jmp    800329 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002cb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002cf:	83 eb 01             	sub    $0x1,%ebx
  8002d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002dd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002e1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ec:	00 
  8002ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fa:	e8 01 0a 00 00       	call   800d00 <__udivdi3>
  8002ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800303:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030e:	89 fa                	mov    %edi,%edx
  800310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800313:	e8 78 ff ff ff       	call   800290 <printnum>
  800318:	eb 0f                	jmp    800329 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031e:	89 34 24             	mov    %esi,(%esp)
  800321:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800324:	83 eb 01             	sub    $0x1,%ebx
  800327:	75 f1                	jne    80031a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800329:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800331:	8b 45 10             	mov    0x10(%ebp),%eax
  800334:	89 44 24 08          	mov    %eax,0x8(%esp)
  800338:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033f:	00 
  800340:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034d:	e8 de 0a 00 00       	call   800e30 <__umoddi3>
  800352:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800356:	0f be 80 9f 10 80 00 	movsbl 0x80109f(%eax),%eax
  80035d:	89 04 24             	mov    %eax,(%esp)
  800360:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800363:	83 c4 3c             	add    $0x3c,%esp
  800366:	5b                   	pop    %ebx
  800367:	5e                   	pop    %esi
  800368:	5f                   	pop    %edi
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036e:	83 fa 01             	cmp    $0x1,%edx
  800371:	7e 0e                	jle    800381 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800373:	8b 10                	mov    (%eax),%edx
  800375:	8d 4a 08             	lea    0x8(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 02                	mov    (%edx),%eax
  80037c:	8b 52 04             	mov    0x4(%edx),%edx
  80037f:	eb 22                	jmp    8003a3 <getuint+0x38>
	else if (lflag)
  800381:	85 d2                	test   %edx,%edx
  800383:	74 10                	je     800395 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800385:	8b 10                	mov    (%eax),%edx
  800387:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 02                	mov    (%edx),%eax
  80038e:	ba 00 00 00 00       	mov    $0x0,%edx
  800393:	eb 0e                	jmp    8003a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800395:	8b 10                	mov    (%eax),%edx
  800397:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039a:	89 08                	mov    %ecx,(%eax)
  80039c:	8b 02                	mov    (%edx),%eax
  80039e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a8:	83 fa 01             	cmp    $0x1,%edx
  8003ab:	7e 0e                	jle    8003bb <getint+0x16>
		return va_arg(*ap, long long);
  8003ad:	8b 10                	mov    (%eax),%edx
  8003af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b2:	89 08                	mov    %ecx,(%eax)
  8003b4:	8b 02                	mov    (%edx),%eax
  8003b6:	8b 52 04             	mov    0x4(%edx),%edx
  8003b9:	eb 22                	jmp    8003dd <getint+0x38>
	else if (lflag)
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	74 10                	je     8003cf <getint+0x2a>
		return va_arg(*ap, long);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 fa 1f             	sar    $0x1f,%edx
  8003cd:	eb 0e                	jmp    8003dd <getint+0x38>
	else
		return va_arg(*ap, int);
  8003cf:	8b 10                	mov    (%eax),%edx
  8003d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d4:	89 08                	mov    %ecx,(%eax)
  8003d6:	8b 02                	mov    (%edx),%eax
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ee:	73 0a                	jae    8003fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f3:	88 0a                	mov    %cl,(%edx)
  8003f5:	83 c2 01             	add    $0x1,%edx
  8003f8:	89 10                	mov    %edx,(%eax)
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800402:	8d 45 14             	lea    0x14(%ebp),%eax
  800405:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800409:	8b 45 10             	mov    0x10(%ebp),%eax
  80040c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800410:	8b 45 0c             	mov    0xc(%ebp),%eax
  800413:	89 44 24 04          	mov    %eax,0x4(%esp)
  800417:	8b 45 08             	mov    0x8(%ebp),%eax
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	e8 02 00 00 00       	call   800424 <vprintfmt>
	va_end(ap);
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 4c             	sub    $0x4c,%esp
  80042d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800430:	8b 75 10             	mov    0x10(%ebp),%esi
  800433:	eb 12                	jmp    800447 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800435:	85 c0                	test   %eax,%eax
  800437:	0f 84 98 03 00 00    	je     8007d5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80043d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800441:	89 04 24             	mov    %eax,(%esp)
  800444:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800447:	0f b6 06             	movzbl (%esi),%eax
  80044a:	83 c6 01             	add    $0x1,%esi
  80044d:	83 f8 25             	cmp    $0x25,%eax
  800450:	75 e3                	jne    800435 <vprintfmt+0x11>
  800452:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800456:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80045d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800462:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800469:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800471:	eb 2b                	jmp    80049e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800476:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80047a:	eb 22                	jmp    80049e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80047f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800483:	eb 19                	jmp    80049e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800488:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80048f:	eb 0d                	jmp    80049e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800491:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800497:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	0f b6 06             	movzbl (%esi),%eax
  8004a1:	0f b6 d0             	movzbl %al,%edx
  8004a4:	8d 7e 01             	lea    0x1(%esi),%edi
  8004a7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004aa:	83 e8 23             	sub    $0x23,%eax
  8004ad:	3c 55                	cmp    $0x55,%al
  8004af:	0f 87 fa 02 00 00    	ja     8007af <vprintfmt+0x38b>
  8004b5:	0f b6 c0             	movzbl %al,%eax
  8004b8:	ff 24 85 2c 11 80 00 	jmp    *0x80112c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bf:	83 ea 30             	sub    $0x30,%edx
  8004c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004c5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004c9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004cf:	83 fa 09             	cmp    $0x9,%edx
  8004d2:	77 4a                	ja     80051e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004da:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004dd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004e4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004e7:	83 fa 09             	cmp    $0x9,%edx
  8004ea:	76 eb                	jbe    8004d7 <vprintfmt+0xb3>
  8004ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ef:	eb 2d                	jmp    80051e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800502:	eb 1a                	jmp    80051e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050b:	79 91                	jns    80049e <vprintfmt+0x7a>
  80050d:	e9 73 ff ff ff       	jmp    800485 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800515:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80051c:	eb 80                	jmp    80049e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80051e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800522:	0f 89 76 ff ff ff    	jns    80049e <vprintfmt+0x7a>
  800528:	e9 64 ff ff ff       	jmp    800491 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800533:	e9 66 ff ff ff       	jmp    80049e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800545:	8b 00                	mov    (%eax),%eax
  800547:	89 04 24             	mov    %eax,(%esp)
  80054a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800550:	e9 f2 fe ff ff       	jmp    800447 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 04             	lea    0x4(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	8b 00                	mov    (%eax),%eax
  800560:	89 c2                	mov    %eax,%edx
  800562:	c1 fa 1f             	sar    $0x1f,%edx
  800565:	31 d0                	xor    %edx,%eax
  800567:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800569:	83 f8 06             	cmp    $0x6,%eax
  80056c:	7f 0b                	jg     800579 <vprintfmt+0x155>
  80056e:	8b 14 85 84 12 80 00 	mov    0x801284(,%eax,4),%edx
  800575:	85 d2                	test   %edx,%edx
  800577:	75 23                	jne    80059c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800579:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057d:	c7 44 24 08 b7 10 80 	movl   $0x8010b7,0x8(%esp)
  800584:	00 
  800585:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800589:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058c:	89 3c 24             	mov    %edi,(%esp)
  80058f:	e8 68 fe ff ff       	call   8003fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800597:	e9 ab fe ff ff       	jmp    800447 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80059c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a0:	c7 44 24 08 c0 10 80 	movl   $0x8010c0,0x8(%esp)
  8005a7:	00 
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005af:	89 3c 24             	mov    %edi,(%esp)
  8005b2:	e8 45 fe ff ff       	call   8003fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ba:	e9 88 fe ff ff       	jmp    800447 <vprintfmt+0x23>
  8005bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005d3:	85 f6                	test   %esi,%esi
  8005d5:	ba b0 10 80 00       	mov    $0x8010b0,%edx
  8005da:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005dd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e1:	7e 06                	jle    8005e9 <vprintfmt+0x1c5>
  8005e3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005e7:	75 10                	jne    8005f9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e9:	0f be 06             	movsbl (%esi),%eax
  8005ec:	83 c6 01             	add    $0x1,%esi
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	0f 85 86 00 00 00    	jne    80067d <vprintfmt+0x259>
  8005f7:	eb 76                	jmp    80066f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fd:	89 34 24             	mov    %esi,(%esp)
  800600:	e8 76 02 00 00       	call   80087b <strnlen>
  800605:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800608:	29 c2                	sub    %eax,%edx
  80060a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80060d:	85 d2                	test   %edx,%edx
  80060f:	7e d8                	jle    8005e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800611:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800615:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800618:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80061b:	89 d6                	mov    %edx,%esi
  80061d:	89 c7                	mov    %eax,%edi
  80061f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800623:	89 3c 24             	mov    %edi,(%esp)
  800626:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800629:	83 ee 01             	sub    $0x1,%esi
  80062c:	75 f1                	jne    80061f <vprintfmt+0x1fb>
  80062e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800631:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800634:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800637:	eb b0                	jmp    8005e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063d:	74 18                	je     800657 <vprintfmt+0x233>
  80063f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800642:	83 fa 5e             	cmp    $0x5e,%edx
  800645:	76 10                	jbe    800657 <vprintfmt+0x233>
					putch('?', putdat);
  800647:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800652:	ff 55 08             	call   *0x8(%ebp)
  800655:	eb 0a                	jmp    800661 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800657:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065b:	89 04 24             	mov    %eax,(%esp)
  80065e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800661:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800665:	0f be 06             	movsbl (%esi),%eax
  800668:	83 c6 01             	add    $0x1,%esi
  80066b:	85 c0                	test   %eax,%eax
  80066d:	75 0e                	jne    80067d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800672:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800676:	7f 11                	jg     800689 <vprintfmt+0x265>
  800678:	e9 ca fd ff ff       	jmp    800447 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067d:	85 ff                	test   %edi,%edi
  80067f:	90                   	nop
  800680:	78 b7                	js     800639 <vprintfmt+0x215>
  800682:	83 ef 01             	sub    $0x1,%edi
  800685:	79 b2                	jns    800639 <vprintfmt+0x215>
  800687:	eb e6                	jmp    80066f <vprintfmt+0x24b>
  800689:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80068c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800693:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80069a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069c:	83 ee 01             	sub    $0x1,%esi
  80069f:	75 ee                	jne    80068f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a4:	e9 9e fd ff ff       	jmp    800447 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006a9:	89 ca                	mov    %ecx,%edx
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 f2 fc ff ff       	call   8003a5 <getint>
  8006b3:	89 c6                	mov    %eax,%esi
  8006b5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006bc:	85 d2                	test   %edx,%edx
  8006be:	0f 89 ad 00 00 00    	jns    800771 <vprintfmt+0x34d>
				putch('-', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006d2:	f7 de                	neg    %esi
  8006d4:	83 d7 00             	adc    $0x0,%edi
  8006d7:	f7 df                	neg    %edi
			}
			base = 10;
  8006d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006de:	e9 8e 00 00 00       	jmp    800771 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e3:	89 ca                	mov    %ecx,%edx
  8006e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e8:	e8 7e fc ff ff       	call   80036b <getuint>
  8006ed:	89 c6                	mov    %eax,%esi
  8006ef:	89 d7                	mov    %edx,%edi
			base = 10;
  8006f1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006f6:	eb 79                	jmp    800771 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  8006f8:	89 ca                	mov    %ecx,%edx
  8006fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fd:	e8 a3 fc ff ff       	call   8003a5 <getint>
  800702:	89 c6                	mov    %eax,%esi
  800704:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800706:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80070b:	85 d2                	test   %edx,%edx
  80070d:	79 62                	jns    800771 <vprintfmt+0x34d>
				putch('-', putdat);
  80070f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800713:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80071d:	f7 de                	neg    %esi
  80071f:	83 d7 00             	adc    $0x0,%edi
  800722:	f7 df                	neg    %edi
			}
			base = 8;
  800724:	b8 08 00 00 00       	mov    $0x8,%eax
  800729:	eb 46                	jmp    800771 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80072b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800736:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800739:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800744:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 50 04             	lea    0x4(%eax),%edx
  80074d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800750:	8b 30                	mov    (%eax),%esi
  800752:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800757:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80075c:	eb 13                	jmp    800771 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075e:	89 ca                	mov    %ecx,%edx
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
  800763:	e8 03 fc ff ff       	call   80036b <getuint>
  800768:	89 c6                	mov    %eax,%esi
  80076a:	89 d7                	mov    %edx,%edi
			base = 16;
  80076c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800771:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800775:	89 54 24 10          	mov    %edx,0x10(%esp)
  800779:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80077c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800780:	89 44 24 08          	mov    %eax,0x8(%esp)
  800784:	89 34 24             	mov    %esi,(%esp)
  800787:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078b:	89 da                	mov    %ebx,%edx
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	e8 fb fa ff ff       	call   800290 <printnum>
			break;
  800795:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800798:	e9 aa fc ff ff       	jmp    800447 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a1:	89 14 24             	mov    %edx,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007aa:	e9 98 fc ff ff       	jmp    800447 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007ba:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007bd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007c1:	0f 84 80 fc ff ff    	je     800447 <vprintfmt+0x23>
  8007c7:	83 ee 01             	sub    $0x1,%esi
  8007ca:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ce:	75 f7                	jne    8007c7 <vprintfmt+0x3a3>
  8007d0:	e9 72 fc ff ff       	jmp    800447 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007d5:	83 c4 4c             	add    $0x4c,%esp
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5f                   	pop    %edi
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	83 ec 28             	sub    $0x28,%esp
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	74 30                	je     80082e <vsnprintf+0x51>
  8007fe:	85 d2                	test   %edx,%edx
  800800:	7e 2c                	jle    80082e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800809:	8b 45 10             	mov    0x10(%ebp),%eax
  80080c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800810:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800813:	89 44 24 04          	mov    %eax,0x4(%esp)
  800817:	c7 04 24 df 03 80 00 	movl   $0x8003df,(%esp)
  80081e:	e8 01 fc ff ff       	call   800424 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800823:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800826:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082c:	eb 05                	jmp    800833 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80082e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	89 04 24             	mov    %eax,(%esp)
  800856:	e8 82 ff ff ff       	call   8007dd <vsnprintf>
	va_end(ap);

	return rc;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    
  80085d:	00 00                	add    %al,(%eax)
	...

00800860 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	80 3a 00             	cmpb   $0x0,(%edx)
  80086e:	74 09                	je     800879 <strlen+0x19>
		n++;
  800870:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800873:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800877:	75 f7                	jne    800870 <strlen+0x10>
		n++;
	return n;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 1a                	je     8008a8 <strnlen+0x2d>
  80088e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800891:	74 15                	je     8008a8 <strnlen+0x2d>
  800893:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800898:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089a:	39 ca                	cmp    %ecx,%edx
  80089c:	74 0a                	je     8008a8 <strnlen+0x2d>
  80089e:	83 c2 01             	add    $0x1,%edx
  8008a1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008a6:	75 f0                	jne    800898 <strnlen+0x1d>
		n++;
	return n;
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ba:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008be:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	84 c9                	test   %cl,%cl
  8008c6:	75 f2                	jne    8008ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d9:	85 f6                	test   %esi,%esi
  8008db:	74 18                	je     8008f5 <strncpy+0x2a>
  8008dd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008e2:	0f b6 1a             	movzbl (%edx),%ebx
  8008e5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e8:	80 3a 01             	cmpb   $0x1,(%edx)
  8008eb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ee:	83 c1 01             	add    $0x1,%ecx
  8008f1:	39 f1                	cmp    %esi,%ecx
  8008f3:	75 ed                	jne    8008e2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	57                   	push   %edi
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800905:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800908:	89 f8                	mov    %edi,%eax
  80090a:	85 f6                	test   %esi,%esi
  80090c:	74 2b                	je     800939 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80090e:	83 fe 01             	cmp    $0x1,%esi
  800911:	74 23                	je     800936 <strlcpy+0x3d>
  800913:	0f b6 0b             	movzbl (%ebx),%ecx
  800916:	84 c9                	test   %cl,%cl
  800918:	74 1c                	je     800936 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80091a:	83 ee 02             	sub    $0x2,%esi
  80091d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800922:	88 08                	mov    %cl,(%eax)
  800924:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800927:	39 f2                	cmp    %esi,%edx
  800929:	74 0b                	je     800936 <strlcpy+0x3d>
  80092b:	83 c2 01             	add    $0x1,%edx
  80092e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800932:	84 c9                	test   %cl,%cl
  800934:	75 ec                	jne    800922 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800936:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800939:	29 f8                	sub    %edi,%eax
}
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5f                   	pop    %edi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	84 c0                	test   %al,%al
  80094e:	74 16                	je     800966 <strcmp+0x26>
  800950:	3a 02                	cmp    (%edx),%al
  800952:	75 12                	jne    800966 <strcmp+0x26>
		p++, q++;
  800954:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800957:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80095b:	84 c0                	test   %al,%al
  80095d:	74 07                	je     800966 <strcmp+0x26>
  80095f:	83 c1 01             	add    $0x1,%ecx
  800962:	3a 02                	cmp    (%edx),%al
  800964:	74 ee                	je     800954 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800966:	0f b6 c0             	movzbl %al,%eax
  800969:	0f b6 12             	movzbl (%edx),%edx
  80096c:	29 d0                	sub    %edx,%eax
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800977:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80097a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800982:	85 d2                	test   %edx,%edx
  800984:	74 28                	je     8009ae <strncmp+0x3e>
  800986:	0f b6 01             	movzbl (%ecx),%eax
  800989:	84 c0                	test   %al,%al
  80098b:	74 24                	je     8009b1 <strncmp+0x41>
  80098d:	3a 03                	cmp    (%ebx),%al
  80098f:	75 20                	jne    8009b1 <strncmp+0x41>
  800991:	83 ea 01             	sub    $0x1,%edx
  800994:	74 13                	je     8009a9 <strncmp+0x39>
		n--, p++, q++;
  800996:	83 c1 01             	add    $0x1,%ecx
  800999:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	84 c0                	test   %al,%al
  8009a1:	74 0e                	je     8009b1 <strncmp+0x41>
  8009a3:	3a 03                	cmp    (%ebx),%al
  8009a5:	74 ea                	je     800991 <strncmp+0x21>
  8009a7:	eb 08                	jmp    8009b1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ae:	5b                   	pop    %ebx
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b1:	0f b6 01             	movzbl (%ecx),%eax
  8009b4:	0f b6 13             	movzbl (%ebx),%edx
  8009b7:	29 d0                	sub    %edx,%eax
  8009b9:	eb f3                	jmp    8009ae <strncmp+0x3e>

008009bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c5:	0f b6 10             	movzbl (%eax),%edx
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	74 1c                	je     8009e8 <strchr+0x2d>
		if (*s == c)
  8009cc:	38 ca                	cmp    %cl,%dl
  8009ce:	75 09                	jne    8009d9 <strchr+0x1e>
  8009d0:	eb 1b                	jmp    8009ed <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009d5:	38 ca                	cmp    %cl,%dl
  8009d7:	74 14                	je     8009ed <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009dd:	84 d2                	test   %dl,%dl
  8009df:	75 f1                	jne    8009d2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	eb 05                	jmp    8009ed <strchr+0x32>
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f9:	0f b6 10             	movzbl (%eax),%edx
  8009fc:	84 d2                	test   %dl,%dl
  8009fe:	74 14                	je     800a14 <strfind+0x25>
		if (*s == c)
  800a00:	38 ca                	cmp    %cl,%dl
  800a02:	75 06                	jne    800a0a <strfind+0x1b>
  800a04:	eb 0e                	jmp    800a14 <strfind+0x25>
  800a06:	38 ca                	cmp    %cl,%dl
  800a08:	74 0a                	je     800a14 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 f2                	jne    800a06 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a23:	89 da                	mov    %ebx,%edx
  800a25:	83 ea 01             	sub    $0x1,%edx
  800a28:	78 0d                	js     800a37 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a2a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800a2c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a2e:	88 0a                	mov    %cl,(%edx)
  800a30:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	75 f7                	jne    800a2e <memset+0x18>
		*p++ = c;

	return v;
}
  800a37:	5b                   	pop    %ebx
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 45 08             	mov    0x8(%ebp),%eax
  800a43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a49:	39 c6                	cmp    %eax,%esi
  800a4b:	72 0b                	jb     800a58 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	75 29                	jne    800a7f <memmove+0x45>
  800a56:	eb 35                	jmp    800a8d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a58:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800a5b:	39 c8                	cmp    %ecx,%eax
  800a5d:	73 ee                	jae    800a4d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	74 2a                	je     800a8d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a63:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800a66:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800a68:	f7 db                	neg    %ebx
  800a6a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800a6d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800a6f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a74:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a78:	83 ea 01             	sub    $0x1,%edx
  800a7b:	75 f2                	jne    800a6f <memmove+0x35>
  800a7d:	eb 0e                	jmp    800a8d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a7f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a83:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a86:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a89:	39 d3                	cmp    %edx,%ebx
  800a8b:	75 f2                	jne    800a7f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a98:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	89 04 24             	mov    %eax,(%esp)
  800aac:	e8 89 ff ff ff       	call   800a3a <memmove>
}
  800ab1:	c9                   	leave  
  800ab2:	c3                   	ret    

00800ab3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abf:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac7:	85 ff                	test   %edi,%edi
  800ac9:	74 37                	je     800b02 <memcmp+0x4f>
		if (*s1 != *s2)
  800acb:	0f b6 03             	movzbl (%ebx),%eax
  800ace:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad1:	83 ef 01             	sub    $0x1,%edi
  800ad4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800ad9:	38 c8                	cmp    %cl,%al
  800adb:	74 1c                	je     800af9 <memcmp+0x46>
  800add:	eb 10                	jmp    800aef <memcmp+0x3c>
  800adf:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ae4:	83 c2 01             	add    $0x1,%edx
  800ae7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800aeb:	38 c8                	cmp    %cl,%al
  800aed:	74 0a                	je     800af9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800aef:	0f b6 c0             	movzbl %al,%eax
  800af2:	0f b6 c9             	movzbl %cl,%ecx
  800af5:	29 c8                	sub    %ecx,%eax
  800af7:	eb 09                	jmp    800b02 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 fa                	cmp    %edi,%edx
  800afb:	75 e2                	jne    800adf <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0d:	89 c2                	mov    %eax,%edx
  800b0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b12:	39 d0                	cmp    %edx,%eax
  800b14:	73 15                	jae    800b2b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b16:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b1a:	38 08                	cmp    %cl,(%eax)
  800b1c:	75 06                	jne    800b24 <memfind+0x1d>
  800b1e:	eb 0b                	jmp    800b2b <memfind+0x24>
  800b20:	38 08                	cmp    %cl,(%eax)
  800b22:	74 07                	je     800b2b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	39 d0                	cmp    %edx,%eax
  800b29:	75 f5                	jne    800b20 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	0f b6 02             	movzbl (%edx),%eax
  800b3c:	3c 20                	cmp    $0x20,%al
  800b3e:	74 04                	je     800b44 <strtol+0x17>
  800b40:	3c 09                	cmp    $0x9,%al
  800b42:	75 0e                	jne    800b52 <strtol+0x25>
		s++;
  800b44:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b47:	0f b6 02             	movzbl (%edx),%eax
  800b4a:	3c 20                	cmp    $0x20,%al
  800b4c:	74 f6                	je     800b44 <strtol+0x17>
  800b4e:	3c 09                	cmp    $0x9,%al
  800b50:	74 f2                	je     800b44 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b52:	3c 2b                	cmp    $0x2b,%al
  800b54:	75 0a                	jne    800b60 <strtol+0x33>
		s++;
  800b56:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b59:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5e:	eb 10                	jmp    800b70 <strtol+0x43>
  800b60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b65:	3c 2d                	cmp    $0x2d,%al
  800b67:	75 07                	jne    800b70 <strtol+0x43>
		s++, neg = 1;
  800b69:	83 c2 01             	add    $0x1,%edx
  800b6c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b70:	85 db                	test   %ebx,%ebx
  800b72:	0f 94 c0             	sete   %al
  800b75:	74 05                	je     800b7c <strtol+0x4f>
  800b77:	83 fb 10             	cmp    $0x10,%ebx
  800b7a:	75 15                	jne    800b91 <strtol+0x64>
  800b7c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7f:	75 10                	jne    800b91 <strtol+0x64>
  800b81:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b85:	75 0a                	jne    800b91 <strtol+0x64>
		s += 2, base = 16;
  800b87:	83 c2 02             	add    $0x2,%edx
  800b8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b8f:	eb 13                	jmp    800ba4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b91:	84 c0                	test   %al,%al
  800b93:	74 0f                	je     800ba4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9d:	75 05                	jne    800ba4 <strtol+0x77>
		s++, base = 8;
  800b9f:	83 c2 01             	add    $0x1,%edx
  800ba2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bab:	0f b6 0a             	movzbl (%edx),%ecx
  800bae:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bb1:	80 fb 09             	cmp    $0x9,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0x91>
			dig = *s - '0';
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 30             	sub    $0x30,%ecx
  800bbc:	eb 1e                	jmp    800bdc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bbe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 08                	ja     800bce <strtol+0xa1>
			dig = *s - 'a' + 10;
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 57             	sub    $0x57,%ecx
  800bcc:	eb 0e                	jmp    800bdc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800bce:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bd1:	80 fb 19             	cmp    $0x19,%bl
  800bd4:	77 14                	ja     800bea <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bd6:	0f be c9             	movsbl %cl,%ecx
  800bd9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bdc:	39 f1                	cmp    %esi,%ecx
  800bde:	7d 0e                	jge    800bee <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800be0:	83 c2 01             	add    $0x1,%edx
  800be3:	0f af c6             	imul   %esi,%eax
  800be6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800be8:	eb c1                	jmp    800bab <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bea:	89 c1                	mov    %eax,%ecx
  800bec:	eb 02                	jmp    800bf0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bee:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf4:	74 05                	je     800bfb <strtol+0xce>
		*endptr = (char *) s;
  800bf6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bfb:	89 ca                	mov    %ecx,%edx
  800bfd:	f7 da                	neg    %edx
  800bff:	85 ff                	test   %edi,%edi
  800c01:	0f 45 c2             	cmovne %edx,%eax
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    
  800c09:	00 00                	add    %al,(%eax)
	...

00800c0c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	89 c3                	mov    %eax,%ebx
  800c28:	89 c7                	mov    %eax,%edi
  800c2a:	89 c6                	mov    %eax,%esi
  800c2c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c37:	89 ec                	mov    %ebp,%esp
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	83 ec 0c             	sub    $0xc,%esp
  800c41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	89 d3                	mov    %edx,%ebx
  800c58:	89 d7                	mov    %edx,%edi
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c67:	89 ec                	mov    %ebp,%esp
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	83 ec 38             	sub    $0x38,%esp
  800c71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	89 cb                	mov    %ecx,%ebx
  800c89:	89 cf                	mov    %ecx,%edi
  800c8b:	89 ce                	mov    %ecx,%esi
  800c8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 28                	jle    800cbb <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 08 a0 12 80 	movl   $0x8012a0,0x8(%esp)
  800ca6:	00 
  800ca7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cae:	00 
  800caf:	c7 04 24 bd 12 80 00 	movl   $0x8012bd,(%esp)
  800cb6:	e8 b1 f4 ff ff       	call   80016c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cbb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cbe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc4:	89 ec                	mov    %ebp,%esp
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdc:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce1:	89 d1                	mov    %edx,%ecx
  800ce3:	89 d3                	mov    %edx,%ebx
  800ce5:	89 d7                	mov    %edx,%edi
  800ce7:	89 d6                	mov    %edx,%esi
  800ce9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ceb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cf4:	89 ec                	mov    %ebp,%esp
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    
	...

00800d00 <__udivdi3>:
  800d00:	83 ec 1c             	sub    $0x1c,%esp
  800d03:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800d07:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800d0b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800d0f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d13:	89 74 24 10          	mov    %esi,0x10(%esp)
  800d17:	8b 74 24 24          	mov    0x24(%esp),%esi
  800d1b:	85 ff                	test   %edi,%edi
  800d1d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800d21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d25:	89 cd                	mov    %ecx,%ebp
  800d27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2b:	75 33                	jne    800d60 <__udivdi3+0x60>
  800d2d:	39 f1                	cmp    %esi,%ecx
  800d2f:	77 57                	ja     800d88 <__udivdi3+0x88>
  800d31:	85 c9                	test   %ecx,%ecx
  800d33:	75 0b                	jne    800d40 <__udivdi3+0x40>
  800d35:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3a:	31 d2                	xor    %edx,%edx
  800d3c:	f7 f1                	div    %ecx
  800d3e:	89 c1                	mov    %eax,%ecx
  800d40:	89 f0                	mov    %esi,%eax
  800d42:	31 d2                	xor    %edx,%edx
  800d44:	f7 f1                	div    %ecx
  800d46:	89 c6                	mov    %eax,%esi
  800d48:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d4c:	f7 f1                	div    %ecx
  800d4e:	89 f2                	mov    %esi,%edx
  800d50:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d54:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800d58:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800d5c:	83 c4 1c             	add    $0x1c,%esp
  800d5f:	c3                   	ret    
  800d60:	31 d2                	xor    %edx,%edx
  800d62:	31 c0                	xor    %eax,%eax
  800d64:	39 f7                	cmp    %esi,%edi
  800d66:	77 e8                	ja     800d50 <__udivdi3+0x50>
  800d68:	0f bd cf             	bsr    %edi,%ecx
  800d6b:	83 f1 1f             	xor    $0x1f,%ecx
  800d6e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d72:	75 2c                	jne    800da0 <__udivdi3+0xa0>
  800d74:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800d78:	76 04                	jbe    800d7e <__udivdi3+0x7e>
  800d7a:	39 f7                	cmp    %esi,%edi
  800d7c:	73 d2                	jae    800d50 <__udivdi3+0x50>
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	b8 01 00 00 00       	mov    $0x1,%eax
  800d85:	eb c9                	jmp    800d50 <__udivdi3+0x50>
  800d87:	90                   	nop
  800d88:	89 f2                	mov    %esi,%edx
  800d8a:	f7 f1                	div    %ecx
  800d8c:	31 d2                	xor    %edx,%edx
  800d8e:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d92:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800d96:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800d9a:	83 c4 1c             	add    $0x1c,%esp
  800d9d:	c3                   	ret    
  800d9e:	66 90                	xchg   %ax,%ax
  800da0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800da5:	b8 20 00 00 00       	mov    $0x20,%eax
  800daa:	89 ea                	mov    %ebp,%edx
  800dac:	2b 44 24 04          	sub    0x4(%esp),%eax
  800db0:	d3 e7                	shl    %cl,%edi
  800db2:	89 c1                	mov    %eax,%ecx
  800db4:	d3 ea                	shr    %cl,%edx
  800db6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dbb:	09 fa                	or     %edi,%edx
  800dbd:	89 f7                	mov    %esi,%edi
  800dbf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dc3:	89 f2                	mov    %esi,%edx
  800dc5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dc9:	d3 e5                	shl    %cl,%ebp
  800dcb:	89 c1                	mov    %eax,%ecx
  800dcd:	d3 ef                	shr    %cl,%edi
  800dcf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dd4:	d3 e2                	shl    %cl,%edx
  800dd6:	89 c1                	mov    %eax,%ecx
  800dd8:	d3 ee                	shr    %cl,%esi
  800dda:	09 d6                	or     %edx,%esi
  800ddc:	89 fa                	mov    %edi,%edx
  800dde:	89 f0                	mov    %esi,%eax
  800de0:	f7 74 24 0c          	divl   0xc(%esp)
  800de4:	89 d7                	mov    %edx,%edi
  800de6:	89 c6                	mov    %eax,%esi
  800de8:	f7 e5                	mul    %ebp
  800dea:	39 d7                	cmp    %edx,%edi
  800dec:	72 22                	jb     800e10 <__udivdi3+0x110>
  800dee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800df2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800df7:	d3 e5                	shl    %cl,%ebp
  800df9:	39 c5                	cmp    %eax,%ebp
  800dfb:	73 04                	jae    800e01 <__udivdi3+0x101>
  800dfd:	39 d7                	cmp    %edx,%edi
  800dff:	74 0f                	je     800e10 <__udivdi3+0x110>
  800e01:	89 f0                	mov    %esi,%eax
  800e03:	31 d2                	xor    %edx,%edx
  800e05:	e9 46 ff ff ff       	jmp    800d50 <__udivdi3+0x50>
  800e0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e10:	8d 46 ff             	lea    -0x1(%esi),%eax
  800e13:	31 d2                	xor    %edx,%edx
  800e15:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e19:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e1d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e21:	83 c4 1c             	add    $0x1c,%esp
  800e24:	c3                   	ret    
	...

00800e30 <__umoddi3>:
  800e30:	83 ec 1c             	sub    $0x1c,%esp
  800e33:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800e37:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800e3b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800e3f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800e43:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e47:	8b 74 24 24          	mov    0x24(%esp),%esi
  800e4b:	85 ed                	test   %ebp,%ebp
  800e4d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800e51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e55:	89 cf                	mov    %ecx,%edi
  800e57:	89 04 24             	mov    %eax,(%esp)
  800e5a:	89 f2                	mov    %esi,%edx
  800e5c:	75 1a                	jne    800e78 <__umoddi3+0x48>
  800e5e:	39 f1                	cmp    %esi,%ecx
  800e60:	76 4e                	jbe    800eb0 <__umoddi3+0x80>
  800e62:	f7 f1                	div    %ecx
  800e64:	89 d0                	mov    %edx,%eax
  800e66:	31 d2                	xor    %edx,%edx
  800e68:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e6c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e70:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e74:	83 c4 1c             	add    $0x1c,%esp
  800e77:	c3                   	ret    
  800e78:	39 f5                	cmp    %esi,%ebp
  800e7a:	77 54                	ja     800ed0 <__umoddi3+0xa0>
  800e7c:	0f bd c5             	bsr    %ebp,%eax
  800e7f:	83 f0 1f             	xor    $0x1f,%eax
  800e82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e86:	75 60                	jne    800ee8 <__umoddi3+0xb8>
  800e88:	3b 0c 24             	cmp    (%esp),%ecx
  800e8b:	0f 87 07 01 00 00    	ja     800f98 <__umoddi3+0x168>
  800e91:	89 f2                	mov    %esi,%edx
  800e93:	8b 34 24             	mov    (%esp),%esi
  800e96:	29 ce                	sub    %ecx,%esi
  800e98:	19 ea                	sbb    %ebp,%edx
  800e9a:	89 34 24             	mov    %esi,(%esp)
  800e9d:	8b 04 24             	mov    (%esp),%eax
  800ea0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ea4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ea8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800eac:	83 c4 1c             	add    $0x1c,%esp
  800eaf:	c3                   	ret    
  800eb0:	85 c9                	test   %ecx,%ecx
  800eb2:	75 0b                	jne    800ebf <__umoddi3+0x8f>
  800eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb9:	31 d2                	xor    %edx,%edx
  800ebb:	f7 f1                	div    %ecx
  800ebd:	89 c1                	mov    %eax,%ecx
  800ebf:	89 f0                	mov    %esi,%eax
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	f7 f1                	div    %ecx
  800ec5:	8b 04 24             	mov    (%esp),%eax
  800ec8:	f7 f1                	div    %ecx
  800eca:	eb 98                	jmp    800e64 <__umoddi3+0x34>
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	89 f2                	mov    %esi,%edx
  800ed2:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ed6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800eda:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ede:	83 c4 1c             	add    $0x1c,%esp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eed:	89 e8                	mov    %ebp,%eax
  800eef:	bd 20 00 00 00       	mov    $0x20,%ebp
  800ef4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	d3 e0                	shl    %cl,%eax
  800efc:	89 e9                	mov    %ebp,%ecx
  800efe:	d3 ea                	shr    %cl,%edx
  800f00:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f05:	09 c2                	or     %eax,%edx
  800f07:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f0b:	89 14 24             	mov    %edx,(%esp)
  800f0e:	89 f2                	mov    %esi,%edx
  800f10:	d3 e7                	shl    %cl,%edi
  800f12:	89 e9                	mov    %ebp,%ecx
  800f14:	d3 ea                	shr    %cl,%edx
  800f16:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f1b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f1f:	d3 e6                	shl    %cl,%esi
  800f21:	89 e9                	mov    %ebp,%ecx
  800f23:	d3 e8                	shr    %cl,%eax
  800f25:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f2a:	09 f0                	or     %esi,%eax
  800f2c:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f30:	f7 34 24             	divl   (%esp)
  800f33:	d3 e6                	shl    %cl,%esi
  800f35:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f39:	89 d6                	mov    %edx,%esi
  800f3b:	f7 e7                	mul    %edi
  800f3d:	39 d6                	cmp    %edx,%esi
  800f3f:	89 c1                	mov    %eax,%ecx
  800f41:	89 d7                	mov    %edx,%edi
  800f43:	72 3f                	jb     800f84 <__umoddi3+0x154>
  800f45:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f49:	72 35                	jb     800f80 <__umoddi3+0x150>
  800f4b:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f4f:	29 c8                	sub    %ecx,%eax
  800f51:	19 fe                	sbb    %edi,%esi
  800f53:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f58:	89 f2                	mov    %esi,%edx
  800f5a:	d3 e8                	shr    %cl,%eax
  800f5c:	89 e9                	mov    %ebp,%ecx
  800f5e:	d3 e2                	shl    %cl,%edx
  800f60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f65:	09 d0                	or     %edx,%eax
  800f67:	89 f2                	mov    %esi,%edx
  800f69:	d3 ea                	shr    %cl,%edx
  800f6b:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f6f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f73:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f77:	83 c4 1c             	add    $0x1c,%esp
  800f7a:	c3                   	ret    
  800f7b:	90                   	nop
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	39 d6                	cmp    %edx,%esi
  800f82:	75 c7                	jne    800f4b <__umoddi3+0x11b>
  800f84:	89 d7                	mov    %edx,%edi
  800f86:	89 c1                	mov    %eax,%ecx
  800f88:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  800f8c:	1b 3c 24             	sbb    (%esp),%edi
  800f8f:	eb ba                	jmp    800f4b <__umoddi3+0x11b>
  800f91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f98:	39 f5                	cmp    %esi,%ebp
  800f9a:	0f 82 f1 fe ff ff    	jb     800e91 <__umoddi3+0x61>
  800fa0:	e9 f8 fe ff ff       	jmp    800e9d <__umoddi3+0x6d>
