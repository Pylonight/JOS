
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800044:	c7 04 24 60 13 80 00 	movl   $0x801360,(%esp)
  80004b:	e8 13 02 00 00       	call   800263 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800050:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800057:	00 
  800058:	89 d8                	mov    %ebx,%eax
  80005a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80006a:	e8 a9 0c 00 00       	call   800d18 <sys_page_alloc>
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 24                	jns    800097 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800073:	89 44 24 10          	mov    %eax,0x10(%esp)
  800077:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80007b:	c7 44 24 08 80 13 80 	movl   $0x801380,0x8(%esp)
  800082:	00 
  800083:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80008a:	00 
  80008b:	c7 04 24 6a 13 80 00 	movl   $0x80136a,(%esp)
  800092:	e8 c5 00 00 00       	call   80015c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800097:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80009b:	c7 44 24 08 ac 13 80 	movl   $0x8013ac,0x8(%esp)
  8000a2:	00 
  8000a3:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000aa:	00 
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 72 07 00 00       	call   800825 <snprintf>
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
  8000c6:	e8 15 0f 00 00       	call   800fe0 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000cb:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  8000d2:	de 
  8000d3:	c7 04 24 7c 13 80 00 	movl   $0x80137c,(%esp)
  8000da:	e8 84 01 00 00       	call   800263 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000df:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  8000e6:	ca 
  8000e7:	c7 04 24 7c 13 80 00 	movl   $0x80137c,(%esp)
  8000ee:	e8 70 01 00 00       	call   800263 <cprintf>
}
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  80010a:	e8 a9 0b 00 00       	call   800cb8 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 81 ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 01 0b 00 00       	call   800c5b <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800162:	a1 08 20 80 00       	mov    0x802008,%eax
  800167:	85 c0                	test   %eax,%eax
  800169:	74 10                	je     80017b <_panic+0x1f>
		cprintf("%s: ", argv0);
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	c7 04 24 e4 13 80 00 	movl   $0x8013e4,(%esp)
  800176:	e8 e8 00 00 00       	call   800263 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80017b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800182:	8b 45 08             	mov    0x8(%ebp),%eax
  800185:	89 44 24 08          	mov    %eax,0x8(%esp)
  800189:	a1 00 20 80 00       	mov    0x802000,%eax
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 e9 13 80 00 	movl   $0x8013e9,(%esp)
  800199:	e8 c5 00 00 00       	call   800263 <cprintf>
	vcprintf(fmt, ap);
  80019e:	8d 45 14             	lea    0x14(%ebp),%eax
  8001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 52 00 00 00       	call   800202 <vcprintf>
	cprintf("\n");
  8001b0:	c7 04 24 7e 13 80 00 	movl   $0x80137e,(%esp)
  8001b7:	e8 a7 00 00 00       	call   800263 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bc:	cc                   	int3   
  8001bd:	eb fd                	jmp    8001bc <_panic+0x60>
	...

008001c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 14             	sub    $0x14,%esp
  8001c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ca:	8b 03                	mov    (%ebx),%eax
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001d3:	83 c0 01             	add    $0x1,%eax
  8001d6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001dd:	75 19                	jne    8001f8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001df:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e6:	00 
  8001e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	e8 0a 0a 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  8001f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    

00800202 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80020b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800212:	00 00 00 
	b.cnt = 0;
  800215:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800222:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800233:	89 44 24 04          	mov    %eax,0x4(%esp)
  800237:	c7 04 24 c0 01 80 00 	movl   $0x8001c0,(%esp)
  80023e:	e8 d1 01 00 00       	call   800414 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800243:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	e8 a1 09 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  80025b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800269:	8d 45 0c             	lea    0xc(%ebp),%eax
  80026c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	e8 87 ff ff ff       	call   800202 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    
  80027d:	00 00                	add    %al,(%eax)
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d7                	mov    %edx,%edi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
  800297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002a8:	72 11                	jb     8002bb <printnum+0x3b>
  8002aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b0:	76 09                	jbe    8002bb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f 51                	jg     80030a <printnum+0x8a>
  8002b9:	eb 5e                	jmp    800319 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002bf:	83 eb 01             	sub    $0x1,%ebx
  8002c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002d1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002dc:	00 
  8002dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ea:	e8 b1 0d 00 00       	call   8010a0 <__udivdi3>
  8002ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fe:	89 fa                	mov    %edi,%edx
  800300:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800303:	e8 78 ff ff ff       	call   800280 <printnum>
  800308:	eb 0f                	jmp    800319 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030e:	89 34 24             	mov    %esi,(%esp)
  800311:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800314:	83 eb 01             	sub    $0x1,%ebx
  800317:	75 f1                	jne    80030a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800321:	8b 45 10             	mov    0x10(%ebp),%eax
  800324:	89 44 24 08          	mov    %eax,0x8(%esp)
  800328:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032f:	00 
  800330:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800333:	89 04 24             	mov    %eax,(%esp)
  800336:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	e8 8e 0e 00 00       	call   8011d0 <__umoddi3>
  800342:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800346:	0f be 80 05 14 80 00 	movsbl 0x801405(%eax),%eax
  80034d:	89 04 24             	mov    %eax,(%esp)
  800350:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800353:	83 c4 3c             	add    $0x3c,%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035e:	83 fa 01             	cmp    $0x1,%edx
  800361:	7e 0e                	jle    800371 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800363:	8b 10                	mov    (%eax),%edx
  800365:	8d 4a 08             	lea    0x8(%edx),%ecx
  800368:	89 08                	mov    %ecx,(%eax)
  80036a:	8b 02                	mov    (%edx),%eax
  80036c:	8b 52 04             	mov    0x4(%edx),%edx
  80036f:	eb 22                	jmp    800393 <getuint+0x38>
	else if (lflag)
  800371:	85 d2                	test   %edx,%edx
  800373:	74 10                	je     800385 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800375:	8b 10                	mov    (%eax),%edx
  800377:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037a:	89 08                	mov    %ecx,(%eax)
  80037c:	8b 02                	mov    (%edx),%eax
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
  800383:	eb 0e                	jmp    800393 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800385:	8b 10                	mov    (%eax),%edx
  800387:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 02                	mov    (%edx),%eax
  80038e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800398:	83 fa 01             	cmp    $0x1,%edx
  80039b:	7e 0e                	jle    8003ab <getint+0x16>
		return va_arg(*ap, long long);
  80039d:	8b 10                	mov    (%eax),%edx
  80039f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a2:	89 08                	mov    %ecx,(%eax)
  8003a4:	8b 02                	mov    (%edx),%eax
  8003a6:	8b 52 04             	mov    0x4(%edx),%edx
  8003a9:	eb 22                	jmp    8003cd <getint+0x38>
	else if (lflag)
  8003ab:	85 d2                	test   %edx,%edx
  8003ad:	74 10                	je     8003bf <getint+0x2a>
		return va_arg(*ap, long);
  8003af:	8b 10                	mov    (%eax),%edx
  8003b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b4:	89 08                	mov    %ecx,(%eax)
  8003b6:	8b 02                	mov    (%edx),%eax
  8003b8:	89 c2                	mov    %eax,%edx
  8003ba:	c1 fa 1f             	sar    $0x1f,%edx
  8003bd:	eb 0e                	jmp    8003cd <getint+0x38>
	else
		return va_arg(*ap, int);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 fa 1f             	sar    $0x1f,%edx
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 0a                	jae    8003ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	88 0a                	mov    %cl,(%edx)
  8003e5:	83 c2 01             	add    $0x1,%edx
  8003e8:	89 10                	mov    %edx,(%eax)
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8003f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8003f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800400:	8b 45 0c             	mov    0xc(%ebp),%eax
  800403:	89 44 24 04          	mov    %eax,0x4(%esp)
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	e8 02 00 00 00       	call   800414 <vprintfmt>
	va_end(ap);
}
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	57                   	push   %edi
  800418:	56                   	push   %esi
  800419:	53                   	push   %ebx
  80041a:	83 ec 4c             	sub    $0x4c,%esp
  80041d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800420:	8b 75 10             	mov    0x10(%ebp),%esi
  800423:	eb 12                	jmp    800437 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800425:	85 c0                	test   %eax,%eax
  800427:	0f 84 98 03 00 00    	je     8007c5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80042d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800431:	89 04 24             	mov    %eax,(%esp)
  800434:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800437:	0f b6 06             	movzbl (%esi),%eax
  80043a:	83 c6 01             	add    $0x1,%esi
  80043d:	83 f8 25             	cmp    $0x25,%eax
  800440:	75 e3                	jne    800425 <vprintfmt+0x11>
  800442:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800446:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80044d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800452:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800459:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800461:	eb 2b                	jmp    80048e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800466:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80046a:	eb 22                	jmp    80048e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800473:	eb 19                	jmp    80048e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800478:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80047f:	eb 0d                	jmp    80048e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800481:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	0f b6 06             	movzbl (%esi),%eax
  800491:	0f b6 d0             	movzbl %al,%edx
  800494:	8d 7e 01             	lea    0x1(%esi),%edi
  800497:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80049a:	83 e8 23             	sub    $0x23,%eax
  80049d:	3c 55                	cmp    $0x55,%al
  80049f:	0f 87 fa 02 00 00    	ja     80079f <vprintfmt+0x38b>
  8004a5:	0f b6 c0             	movzbl %al,%eax
  8004a8:	ff 24 85 c0 14 80 00 	jmp    *0x8014c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004af:	83 ea 30             	sub    $0x30,%edx
  8004b2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8004b5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8004b9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8004bf:	83 fa 09             	cmp    $0x9,%edx
  8004c2:	77 4a                	ja     80050e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8004ca:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004cd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004d1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004d4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004d7:	83 fa 09             	cmp    $0x9,%edx
  8004da:	76 eb                	jbe    8004c7 <vprintfmt+0xb3>
  8004dc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004df:	eb 2d                	jmp    80050e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f2:	eb 1a                	jmp    80050e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8004f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fb:	79 91                	jns    80048e <vprintfmt+0x7a>
  8004fd:	e9 73 ff ff ff       	jmp    800475 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800505:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80050c:	eb 80                	jmp    80048e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80050e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800512:	0f 89 76 ff ff ff    	jns    80048e <vprintfmt+0x7a>
  800518:	e9 64 ff ff ff       	jmp    800481 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80051d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800520:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800523:	e9 66 ff ff ff       	jmp    80048e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800535:	8b 00                	mov    (%eax),%eax
  800537:	89 04 24             	mov    %eax,(%esp)
  80053a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800540:	e9 f2 fe ff ff       	jmp    800437 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 c2                	mov    %eax,%edx
  800552:	c1 fa 1f             	sar    $0x1f,%edx
  800555:	31 d0                	xor    %edx,%eax
  800557:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800559:	83 f8 08             	cmp    $0x8,%eax
  80055c:	7f 0b                	jg     800569 <vprintfmt+0x155>
  80055e:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  800565:	85 d2                	test   %edx,%edx
  800567:	75 23                	jne    80058c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800569:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056d:	c7 44 24 08 1d 14 80 	movl   $0x80141d,0x8(%esp)
  800574:	00 
  800575:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800579:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057c:	89 3c 24             	mov    %edi,(%esp)
  80057f:	e8 68 fe ff ff       	call   8003ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800587:	e9 ab fe ff ff       	jmp    800437 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80058c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800590:	c7 44 24 08 26 14 80 	movl   $0x801426,0x8(%esp)
  800597:	00 
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059f:	89 3c 24             	mov    %edi,(%esp)
  8005a2:	e8 45 fe ff ff       	call   8003ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005aa:	e9 88 fe ff ff       	jmp    800437 <vprintfmt+0x23>
  8005af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005c3:	85 f6                	test   %esi,%esi
  8005c5:	ba 16 14 80 00       	mov    $0x801416,%edx
  8005ca:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8005cd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d1:	7e 06                	jle    8005d9 <vprintfmt+0x1c5>
  8005d3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005d7:	75 10                	jne    8005e9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d9:	0f be 06             	movsbl (%esi),%eax
  8005dc:	83 c6 01             	add    $0x1,%esi
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	0f 85 86 00 00 00    	jne    80066d <vprintfmt+0x259>
  8005e7:	eb 76                	jmp    80065f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ed:	89 34 24             	mov    %esi,(%esp)
  8005f0:	e8 76 02 00 00       	call   80086b <strnlen>
  8005f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005f8:	29 c2                	sub    %eax,%edx
  8005fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005fd:	85 d2                	test   %edx,%edx
  8005ff:	7e d8                	jle    8005d9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800601:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800605:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800608:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80060b:	89 d6                	mov    %edx,%esi
  80060d:	89 c7                	mov    %eax,%edi
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	89 3c 24             	mov    %edi,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	83 ee 01             	sub    $0x1,%esi
  80061c:	75 f1                	jne    80060f <vprintfmt+0x1fb>
  80061e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800621:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800624:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800627:	eb b0                	jmp    8005d9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800629:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062d:	74 18                	je     800647 <vprintfmt+0x233>
  80062f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800632:	83 fa 5e             	cmp    $0x5e,%edx
  800635:	76 10                	jbe    800647 <vprintfmt+0x233>
					putch('?', putdat);
  800637:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	eb 0a                	jmp    800651 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800647:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064b:	89 04 24             	mov    %eax,(%esp)
  80064e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800651:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800655:	0f be 06             	movsbl (%esi),%eax
  800658:	83 c6 01             	add    $0x1,%esi
  80065b:	85 c0                	test   %eax,%eax
  80065d:	75 0e                	jne    80066d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800666:	7f 11                	jg     800679 <vprintfmt+0x265>
  800668:	e9 ca fd ff ff       	jmp    800437 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066d:	85 ff                	test   %edi,%edi
  80066f:	90                   	nop
  800670:	78 b7                	js     800629 <vprintfmt+0x215>
  800672:	83 ef 01             	sub    $0x1,%edi
  800675:	79 b2                	jns    800629 <vprintfmt+0x215>
  800677:	eb e6                	jmp    80065f <vprintfmt+0x24b>
  800679:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80067c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800683:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80068a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068c:	83 ee 01             	sub    $0x1,%esi
  80068f:	75 ee                	jne    80067f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800694:	e9 9e fd ff ff       	jmp    800437 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 f2 fc ff ff       	call   800395 <getint>
  8006a3:	89 c6                	mov    %eax,%esi
  8006a5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	0f 89 ad 00 00 00    	jns    800761 <vprintfmt+0x34d>
				putch('-', putdat);
  8006b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c2:	f7 de                	neg    %esi
  8006c4:	83 d7 00             	adc    $0x0,%edi
  8006c7:	f7 df                	neg    %edi
			}
			base = 10;
  8006c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ce:	e9 8e 00 00 00       	jmp    800761 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d3:	89 ca                	mov    %ecx,%edx
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d8:	e8 7e fc ff ff       	call   80035b <getuint>
  8006dd:	89 c6                	mov    %eax,%esi
  8006df:	89 d7                	mov    %edx,%edi
			base = 10;
  8006e1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e6:	eb 79                	jmp    800761 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  8006e8:	89 ca                	mov    %ecx,%edx
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 a3 fc ff ff       	call   800395 <getint>
  8006f2:	89 c6                	mov    %eax,%esi
  8006f4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8006f6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	79 62                	jns    800761 <vprintfmt+0x34d>
				putch('-', putdat);
  8006ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800703:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80070a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80070d:	f7 de                	neg    %esi
  80070f:	83 d7 00             	adc    $0x0,%edi
  800712:	f7 df                	neg    %edi
			}
			base = 8;
  800714:	b8 08 00 00 00       	mov    $0x8,%eax
  800719:	eb 46                	jmp    800761 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80071b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800726:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800729:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800734:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8d 50 04             	lea    0x4(%eax),%edx
  80073d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800740:	8b 30                	mov    (%eax),%esi
  800742:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80074c:	eb 13                	jmp    800761 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80074e:	89 ca                	mov    %ecx,%edx
  800750:	8d 45 14             	lea    0x14(%ebp),%eax
  800753:	e8 03 fc ff ff       	call   80035b <getuint>
  800758:	89 c6                	mov    %eax,%esi
  80075a:	89 d7                	mov    %edx,%edi
			base = 16;
  80075c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800761:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800765:	89 54 24 10          	mov    %edx,0x10(%esp)
  800769:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80076c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800770:	89 44 24 08          	mov    %eax,0x8(%esp)
  800774:	89 34 24             	mov    %esi,(%esp)
  800777:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077b:	89 da                	mov    %ebx,%edx
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	e8 fb fa ff ff       	call   800280 <printnum>
			break;
  800785:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800788:	e9 aa fc ff ff       	jmp    800437 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800791:	89 14 24             	mov    %edx,(%esp)
  800794:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800797:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80079a:	e9 98 fc ff ff       	jmp    800437 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007aa:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ad:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007b1:	0f 84 80 fc ff ff    	je     800437 <vprintfmt+0x23>
  8007b7:	83 ee 01             	sub    $0x1,%esi
  8007ba:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007be:	75 f7                	jne    8007b7 <vprintfmt+0x3a3>
  8007c0:	e9 72 fc ff ff       	jmp    800437 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007c5:	83 c4 4c             	add    $0x4c,%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5f                   	pop    %edi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 28             	sub    $0x28,%esp
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	74 30                	je     80081e <vsnprintf+0x51>
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	7e 2c                	jle    80081e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800800:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800803:	89 44 24 04          	mov    %eax,0x4(%esp)
  800807:	c7 04 24 cf 03 80 00 	movl   $0x8003cf,(%esp)
  80080e:	e8 01 fc ff ff       	call   800414 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800813:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800816:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081c:	eb 05                	jmp    800823 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
  80082e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800832:	8b 45 10             	mov    0x10(%ebp),%eax
  800835:	89 44 24 08          	mov    %eax,0x8(%esp)
  800839:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 82 ff ff ff       	call   8007cd <vsnprintf>
	va_end(ap);

	return rc;
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    
  80084d:	00 00                	add    %al,(%eax)
	...

00800850 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	80 3a 00             	cmpb   $0x0,(%edx)
  80085e:	74 09                	je     800869 <strlen+0x19>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0x10>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	b8 00 00 00 00       	mov    $0x0,%eax
  80087a:	85 c9                	test   %ecx,%ecx
  80087c:	74 1a                	je     800898 <strnlen+0x2d>
  80087e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800881:	74 15                	je     800898 <strnlen+0x2d>
  800883:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800888:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	39 ca                	cmp    %ecx,%edx
  80088c:	74 0a                	je     800898 <strnlen+0x2d>
  80088e:	83 c2 01             	add    $0x1,%edx
  800891:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800896:	75 f0                	jne    800888 <strnlen+0x1d>
		n++;
	return n;
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008aa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b1:	83 c2 01             	add    $0x1,%edx
  8008b4:	84 c9                	test   %cl,%cl
  8008b6:	75 f2                	jne    8008aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	56                   	push   %esi
  8008bf:	53                   	push   %ebx
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c9:	85 f6                	test   %esi,%esi
  8008cb:	74 18                	je     8008e5 <strncpy+0x2a>
  8008cd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008d2:	0f b6 1a             	movzbl (%edx),%ebx
  8008d5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d8:	80 3a 01             	cmpb   $0x1,(%edx)
  8008db:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008de:	83 c1 01             	add    $0x1,%ecx
  8008e1:	39 f1                	cmp    %esi,%ecx
  8008e3:	75 ed                	jne    8008d2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	57                   	push   %edi
  8008ed:	56                   	push   %esi
  8008ee:	53                   	push   %ebx
  8008ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	85 f6                	test   %esi,%esi
  8008fc:	74 2b                	je     800929 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8008fe:	83 fe 01             	cmp    $0x1,%esi
  800901:	74 23                	je     800926 <strlcpy+0x3d>
  800903:	0f b6 0b             	movzbl (%ebx),%ecx
  800906:	84 c9                	test   %cl,%cl
  800908:	74 1c                	je     800926 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80090a:	83 ee 02             	sub    $0x2,%esi
  80090d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800912:	88 08                	mov    %cl,(%eax)
  800914:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800917:	39 f2                	cmp    %esi,%edx
  800919:	74 0b                	je     800926 <strlcpy+0x3d>
  80091b:	83 c2 01             	add    $0x1,%edx
  80091e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800922:	84 c9                	test   %cl,%cl
  800924:	75 ec                	jne    800912 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800926:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800929:	29 f8                	sub    %edi,%eax
}
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800936:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800939:	0f b6 01             	movzbl (%ecx),%eax
  80093c:	84 c0                	test   %al,%al
  80093e:	74 16                	je     800956 <strcmp+0x26>
  800940:	3a 02                	cmp    (%edx),%al
  800942:	75 12                	jne    800956 <strcmp+0x26>
		p++, q++;
  800944:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800947:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80094b:	84 c0                	test   %al,%al
  80094d:	74 07                	je     800956 <strcmp+0x26>
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	3a 02                	cmp    (%edx),%al
  800954:	74 ee                	je     800944 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800956:	0f b6 c0             	movzbl %al,%eax
  800959:	0f b6 12             	movzbl (%edx),%edx
  80095c:	29 d0                	sub    %edx,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80096a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80096d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800972:	85 d2                	test   %edx,%edx
  800974:	74 28                	je     80099e <strncmp+0x3e>
  800976:	0f b6 01             	movzbl (%ecx),%eax
  800979:	84 c0                	test   %al,%al
  80097b:	74 24                	je     8009a1 <strncmp+0x41>
  80097d:	3a 03                	cmp    (%ebx),%al
  80097f:	75 20                	jne    8009a1 <strncmp+0x41>
  800981:	83 ea 01             	sub    $0x1,%edx
  800984:	74 13                	je     800999 <strncmp+0x39>
		n--, p++, q++;
  800986:	83 c1 01             	add    $0x1,%ecx
  800989:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098c:	0f b6 01             	movzbl (%ecx),%eax
  80098f:	84 c0                	test   %al,%al
  800991:	74 0e                	je     8009a1 <strncmp+0x41>
  800993:	3a 03                	cmp    (%ebx),%al
  800995:	74 ea                	je     800981 <strncmp+0x21>
  800997:	eb 08                	jmp    8009a1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099e:	5b                   	pop    %ebx
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a1:	0f b6 01             	movzbl (%ecx),%eax
  8009a4:	0f b6 13             	movzbl (%ebx),%edx
  8009a7:	29 d0                	sub    %edx,%eax
  8009a9:	eb f3                	jmp    80099e <strncmp+0x3e>

008009ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 1c                	je     8009d8 <strchr+0x2d>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 09                	jne    8009c9 <strchr+0x1e>
  8009c0:	eb 1b                	jmp    8009dd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8009c5:	38 ca                	cmp    %cl,%dl
  8009c7:	74 14                	je     8009dd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8009cd:	84 d2                	test   %dl,%dl
  8009cf:	75 f1                	jne    8009c2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d6:	eb 05                	jmp    8009dd <strchr+0x32>
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e9:	0f b6 10             	movzbl (%eax),%edx
  8009ec:	84 d2                	test   %dl,%dl
  8009ee:	74 14                	je     800a04 <strfind+0x25>
		if (*s == c)
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	75 06                	jne    8009fa <strfind+0x1b>
  8009f4:	eb 0e                	jmp    800a04 <strfind+0x25>
  8009f6:	38 ca                	cmp    %cl,%dl
  8009f8:	74 0a                	je     800a04 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 f2                	jne    8009f6 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a13:	89 da                	mov    %ebx,%edx
  800a15:	83 ea 01             	sub    $0x1,%edx
  800a18:	78 0d                	js     800a27 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800a1a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800a1c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800a1e:	88 0a                	mov    %cl,(%edx)
  800a20:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a23:	39 da                	cmp    %ebx,%edx
  800a25:	75 f7                	jne    800a1e <memset+0x18>
		*p++ = c;

	return v;
}
  800a27:	5b                   	pop    %ebx
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a39:	39 c6                	cmp    %eax,%esi
  800a3b:	72 0b                	jb     800a48 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	85 db                	test   %ebx,%ebx
  800a44:	75 29                	jne    800a6f <memmove+0x45>
  800a46:	eb 35                	jmp    800a7d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a48:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800a4b:	39 c8                	cmp    %ecx,%eax
  800a4d:	73 ee                	jae    800a3d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	74 2a                	je     800a7d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800a53:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800a56:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800a58:	f7 db                	neg    %ebx
  800a5a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800a5d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800a5f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a64:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a68:	83 ea 01             	sub    $0x1,%edx
  800a6b:	75 f2                	jne    800a5f <memmove+0x35>
  800a6d:	eb 0e                	jmp    800a7d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a6f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a73:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a76:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a79:	39 d3                	cmp    %edx,%ebx
  800a7b:	75 f2                	jne    800a6f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a88:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	89 04 24             	mov    %eax,(%esp)
  800a9c:	e8 89 ff ff ff       	call   800a2a <memmove>
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab7:	85 ff                	test   %edi,%edi
  800ab9:	74 37                	je     800af2 <memcmp+0x4f>
		if (*s1 != *s2)
  800abb:	0f b6 03             	movzbl (%ebx),%eax
  800abe:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac1:	83 ef 01             	sub    $0x1,%edi
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800ac9:	38 c8                	cmp    %cl,%al
  800acb:	74 1c                	je     800ae9 <memcmp+0x46>
  800acd:	eb 10                	jmp    800adf <memcmp+0x3c>
  800acf:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800ad4:	83 c2 01             	add    $0x1,%edx
  800ad7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800adb:	38 c8                	cmp    %cl,%al
  800add:	74 0a                	je     800ae9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800adf:	0f b6 c0             	movzbl %al,%eax
  800ae2:	0f b6 c9             	movzbl %cl,%ecx
  800ae5:	29 c8                	sub    %ecx,%eax
  800ae7:	eb 09                	jmp    800af2 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae9:	39 fa                	cmp    %edi,%edx
  800aeb:	75 e2                	jne    800acf <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800afd:	89 c2                	mov    %eax,%edx
  800aff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b02:	39 d0                	cmp    %edx,%eax
  800b04:	73 15                	jae    800b1b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b0a:	38 08                	cmp    %cl,(%eax)
  800b0c:	75 06                	jne    800b14 <memfind+0x1d>
  800b0e:	eb 0b                	jmp    800b1b <memfind+0x24>
  800b10:	38 08                	cmp    %cl,(%eax)
  800b12:	74 07                	je     800b1b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	39 d0                	cmp    %edx,%eax
  800b19:	75 f5                	jne    800b10 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b29:	0f b6 02             	movzbl (%edx),%eax
  800b2c:	3c 20                	cmp    $0x20,%al
  800b2e:	74 04                	je     800b34 <strtol+0x17>
  800b30:	3c 09                	cmp    $0x9,%al
  800b32:	75 0e                	jne    800b42 <strtol+0x25>
		s++;
  800b34:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b37:	0f b6 02             	movzbl (%edx),%eax
  800b3a:	3c 20                	cmp    $0x20,%al
  800b3c:	74 f6                	je     800b34 <strtol+0x17>
  800b3e:	3c 09                	cmp    $0x9,%al
  800b40:	74 f2                	je     800b34 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b42:	3c 2b                	cmp    $0x2b,%al
  800b44:	75 0a                	jne    800b50 <strtol+0x33>
		s++;
  800b46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b49:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4e:	eb 10                	jmp    800b60 <strtol+0x43>
  800b50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b55:	3c 2d                	cmp    $0x2d,%al
  800b57:	75 07                	jne    800b60 <strtol+0x43>
		s++, neg = 1;
  800b59:	83 c2 01             	add    $0x1,%edx
  800b5c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b60:	85 db                	test   %ebx,%ebx
  800b62:	0f 94 c0             	sete   %al
  800b65:	74 05                	je     800b6c <strtol+0x4f>
  800b67:	83 fb 10             	cmp    $0x10,%ebx
  800b6a:	75 15                	jne    800b81 <strtol+0x64>
  800b6c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6f:	75 10                	jne    800b81 <strtol+0x64>
  800b71:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b75:	75 0a                	jne    800b81 <strtol+0x64>
		s += 2, base = 16;
  800b77:	83 c2 02             	add    $0x2,%edx
  800b7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7f:	eb 13                	jmp    800b94 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b81:	84 c0                	test   %al,%al
  800b83:	74 0f                	je     800b94 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8d:	75 05                	jne    800b94 <strtol+0x77>
		s++, base = 8;
  800b8f:	83 c2 01             	add    $0x1,%edx
  800b92:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9b:	0f b6 0a             	movzbl (%edx),%ecx
  800b9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba1:	80 fb 09             	cmp    $0x9,%bl
  800ba4:	77 08                	ja     800bae <strtol+0x91>
			dig = *s - '0';
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 30             	sub    $0x30,%ecx
  800bac:	eb 1e                	jmp    800bcc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800bae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0xa1>
			dig = *s - 'a' + 10;
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 57             	sub    $0x57,%ecx
  800bbc:	eb 0e                	jmp    800bcc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 14                	ja     800bda <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcc:	39 f1                	cmp    %esi,%ecx
  800bce:	7d 0e                	jge    800bde <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c2 01             	add    $0x1,%edx
  800bd3:	0f af c6             	imul   %esi,%eax
  800bd6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bd8:	eb c1                	jmp    800b9b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	89 c1                	mov    %eax,%ecx
  800bdc:	eb 02                	jmp    800be0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bde:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800be0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be4:	74 05                	je     800beb <strtol+0xce>
		*endptr = (char *) s;
  800be6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800beb:	89 ca                	mov    %ecx,%edx
  800bed:	f7 da                	neg    %edx
  800bef:	85 ff                	test   %edi,%edi
  800bf1:	0f 45 c2             	cmovne %edx,%eax
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
  800bf9:	00 00                	add    %al,(%eax)
	...

00800bfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	89 c3                	mov    %eax,%ebx
  800c18:	89 c7                	mov    %eax,%edi
  800c1a:	89 c6                	mov    %eax,%esi
  800c1c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c1e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c21:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c24:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c27:	89 ec                	mov    %ebp,%esp
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c37:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c51:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c54:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c57:	89 ec                	mov    %ebp,%esp
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	83 ec 38             	sub    $0x38,%esp
  800c61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c67:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 cb                	mov    %ecx,%ebx
  800c79:	89 cf                	mov    %ecx,%edi
  800c7b:	89 ce                	mov    %ecx,%esi
  800c7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 28                	jle    800cab <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c87:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c8e:	00 
  800c8f:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800c96:	00 
  800c97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9e:	00 
  800c9f:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800ca6:	e8 b1 f4 ff ff       	call   80015c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb4:	89 ec                	mov    %ebp,%esp
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccc:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd1:	89 d1                	mov    %edx,%ecx
  800cd3:	89 d3                	mov    %edx,%ebx
  800cd5:	89 d7                	mov    %edx,%edi
  800cd7:	89 d6                	mov    %edx,%esi
  800cd9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cde:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce4:	89 ec                	mov    %ebp,%esp
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_yield>:

void
sys_yield(void)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d01:	89 d1                	mov    %edx,%ecx
  800d03:	89 d3                	mov    %edx,%ebx
  800d05:	89 d7                	mov    %edx,%edi
  800d07:	89 d6                	mov    %edx,%esi
  800d09:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d14:	89 ec                	mov    %ebp,%esp
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	83 ec 38             	sub    $0x38,%esp
  800d1e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d21:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d24:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	be 00 00 00 00       	mov    $0x0,%esi
  800d2c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	89 f7                	mov    %esi,%edi
  800d3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	7e 28                	jle    800d6a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d46:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800d55:	00 
  800d56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5d:	00 
  800d5e:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800d65:	e8 f2 f3 ff ff       	call   80015c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d73:	89 ec                	mov    %ebp,%esp
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	83 ec 38             	sub    $0x38,%esp
  800d7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d80:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d83:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 28                	jle    800dc8 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dab:	00 
  800dac:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800db3:	00 
  800db4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbb:	00 
  800dbc:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800dc3:	e8 94 f3 ff ff       	call   80015c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dcb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dd1:	89 ec                	mov    %ebp,%esp
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 38             	sub    $0x38,%esp
  800ddb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dde:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de9:	b8 06 00 00 00       	mov    $0x6,%eax
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 df                	mov    %ebx,%edi
  800df6:	89 de                	mov    %ebx,%esi
  800df8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	7e 28                	jle    800e26 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e02:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e09:	00 
  800e0a:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e19:	00 
  800e1a:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800e21:	e8 36 f3 ff ff       	call   80015c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e26:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e29:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e2c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2f:	89 ec                	mov    %ebp,%esp
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	83 ec 38             	sub    $0x38,%esp
  800e39:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e47:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	89 df                	mov    %ebx,%edi
  800e54:	89 de                	mov    %ebx,%esi
  800e56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	7e 28                	jle    800e84 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e60:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e67:	00 
  800e68:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800e6f:	00 
  800e70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e77:	00 
  800e78:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800e7f:	e8 d8 f2 ff ff       	call   80015c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e8d:	89 ec                	mov    %ebp,%esp
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 38             	sub    $0x38,%esp
  800e97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ead:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb0:	89 df                	mov    %ebx,%edi
  800eb2:	89 de                	mov    %ebx,%esi
  800eb4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	7e 28                	jle    800ee2 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebe:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec5:	00 
  800ec6:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800ecd:	00 
  800ece:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed5:	00 
  800ed6:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800edd:	e8 7a f2 ff ff       	call   80015c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eeb:	89 ec                	mov    %ebp,%esp
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 38             	sub    $0x38,%esp
  800ef5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	89 df                	mov    %ebx,%edi
  800f10:	89 de                	mov    %ebx,%esi
  800f12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	7e 28                	jle    800f40 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f23:	00 
  800f24:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800f3b:	e8 1c f2 ff ff       	call   80015c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f40:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f43:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f46:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f49:	89 ec                	mov    %ebp,%esp
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	83 ec 0c             	sub    $0xc,%esp
  800f53:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f56:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f59:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5c:	be 00 00 00 00       	mov    $0x0,%esi
  800f61:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f72:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f74:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f77:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7d:	89 ec                	mov    %ebp,%esp
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 38             	sub    $0x38,%esp
  800f87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9d:	89 cb                	mov    %ecx,%ebx
  800f9f:	89 cf                	mov    %ecx,%edi
  800fa1:	89 ce                	mov    %ecx,%esi
  800fa3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	7e 28                	jle    800fd1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fad:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800fcc:	e8 8b f1 ff ff       	call   80015c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fd1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fd7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fda:	89 ec                	mov    %ebp,%esp
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    
	...

00800fe0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	53                   	push   %ebx
  800fe4:	83 ec 14             	sub    $0x14,%esp
	int r;

	// Set the page fault handler function.
	// If there isn't one yet, _pgfault_handler will be 0.
	if (_pgfault_handler == 0) {
  800fe7:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800fee:	75 77                	jne    801067 <set_pgfault_handler+0x87>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800ff0:	e8 c3 fc ff ff       	call   800cb8 <sys_getenvid>
  800ff5:	89 c3                	mov    %eax,%ebx
		// The first time we register a handler, we need to 
		// allocate an exception stack (one page of memory with its top
		// at UXSTACKTOP). [UXSTACKTOP-PGSIZE, UXSTACKTOP-1]
		// user can read, write
		if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE),
  800ff7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801006:	ee 
  801007:	89 04 24             	mov    %eax,(%esp)
  80100a:	e8 09 fd ff ff       	call   800d18 <sys_page_alloc>
  80100f:	85 c0                	test   %eax,%eax
  801011:	79 20                	jns    801033 <set_pgfault_handler+0x53>
			PTE_W | PTE_U | PTE_P)) < 0)
		{
			panic("sys_page_alloc: %e", r);
  801013:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801017:	c7 44 24 08 6f 16 80 	movl   $0x80166f,0x8(%esp)
  80101e:	00 
  80101f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801026:	00 
  801027:	c7 04 24 82 16 80 00 	movl   $0x801682,(%esp)
  80102e:	e8 29 f1 ff ff       	call   80015c <_panic>
			return;
		}
		// tell the kernel to call the assembly-language
		// _pgfault_upcall routine when a page fault occurs.
		if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801033:	c7 44 24 04 78 10 80 	movl   $0x801078,0x4(%esp)
  80103a:	00 
  80103b:	89 1c 24             	mov    %ebx,(%esp)
  80103e:	e8 ac fe ff ff       	call   800eef <sys_env_set_pgfault_upcall>
  801043:	85 c0                	test   %eax,%eax
  801045:	79 20                	jns    801067 <set_pgfault_handler+0x87>
		{
			panic("sys_env_set_pgfault_upcall: %e", r);
  801047:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80104b:	c7 44 24 08 90 16 80 	movl   $0x801690,0x8(%esp)
  801052:	00 
  801053:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80105a:	00 
  80105b:	c7 04 24 82 16 80 00 	movl   $0x801682,(%esp)
  801062:	e8 f5 f0 ff ff       	call   80015c <_panic>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801067:	8b 45 08             	mov    0x8(%ebp),%eax
  80106a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80106f:	83 c4 14             	add    $0x14,%esp
  801072:	5b                   	pop    %ebx
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    
  801075:	00 00                	add    %al,(%eax)
	...

00801078 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801078:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801079:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80107e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801080:	83 c4 04             	add    $0x4,%esp
	// it means that esp points to fault_va now, esp -> fault_va
	// eax, ecx, edx are saved-by-caller regs, use as wish
	// while edx, esi, edi are saved-by-called regs, save before using
	// and restore before leaving
	// our eip
	movl	40(%esp),	%eax
  801083:	8b 44 24 28          	mov    0x28(%esp),%eax
	// esp, the trap-time stack to return to
	movl	48(%esp),	%ecx
  801087:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// set rip to be out eip
	// there is only one op-num can be memory-accessing
	movl	%eax,	-4(%ecx)
  80108b:	89 41 fc             	mov    %eax,-0x4(%ecx)

	// Restore the trap-time registers.
	// LAB 4: Your code here.
	// esp -> fault_va
	// skip fault_va and tf_err
	addl	$8,	%esp
  80108e:	83 c4 08             	add    $0x8,%esp
	// esp -> trap-time edi
	popal
  801091:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.
	// esp -> trap-time eip
	addl	$4,	%esp
  801092:	83 c4 04             	add    $0x4,%esp
	// esp -> trap-time eflags
	// popfl defined in "inc/x86.h"
	popfl
  801095:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// esp -> trap-time esp
	// as requested
	popl	%esp
  801096:	5c                   	pop    %esp
	// esp -> the first argument
	subl	$4,	%esp
  801097:	83 ec 04             	sub    $0x4,%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// esp -> rip
	// ret will jump to rip, but esp must point to rip
  80109a:	c3                   	ret    
  80109b:	00 00                	add    %al,(%eax)
  80109d:	00 00                	add    %al,(%eax)
	...

008010a0 <__udivdi3>:
  8010a0:	83 ec 1c             	sub    $0x1c,%esp
  8010a3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010a7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  8010ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010af:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010b3:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010bb:	85 ff                	test   %edi,%edi
  8010bd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	89 cd                	mov    %ecx,%ebp
  8010c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cb:	75 33                	jne    801100 <__udivdi3+0x60>
  8010cd:	39 f1                	cmp    %esi,%ecx
  8010cf:	77 57                	ja     801128 <__udivdi3+0x88>
  8010d1:	85 c9                	test   %ecx,%ecx
  8010d3:	75 0b                	jne    8010e0 <__udivdi3+0x40>
  8010d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010da:	31 d2                	xor    %edx,%edx
  8010dc:	f7 f1                	div    %ecx
  8010de:	89 c1                	mov    %eax,%ecx
  8010e0:	89 f0                	mov    %esi,%eax
  8010e2:	31 d2                	xor    %edx,%edx
  8010e4:	f7 f1                	div    %ecx
  8010e6:	89 c6                	mov    %eax,%esi
  8010e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010ec:	f7 f1                	div    %ecx
  8010ee:	89 f2                	mov    %esi,%edx
  8010f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fc:	83 c4 1c             	add    $0x1c,%esp
  8010ff:	c3                   	ret    
  801100:	31 d2                	xor    %edx,%edx
  801102:	31 c0                	xor    %eax,%eax
  801104:	39 f7                	cmp    %esi,%edi
  801106:	77 e8                	ja     8010f0 <__udivdi3+0x50>
  801108:	0f bd cf             	bsr    %edi,%ecx
  80110b:	83 f1 1f             	xor    $0x1f,%ecx
  80110e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801112:	75 2c                	jne    801140 <__udivdi3+0xa0>
  801114:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801118:	76 04                	jbe    80111e <__udivdi3+0x7e>
  80111a:	39 f7                	cmp    %esi,%edi
  80111c:	73 d2                	jae    8010f0 <__udivdi3+0x50>
  80111e:	31 d2                	xor    %edx,%edx
  801120:	b8 01 00 00 00       	mov    $0x1,%eax
  801125:	eb c9                	jmp    8010f0 <__udivdi3+0x50>
  801127:	90                   	nop
  801128:	89 f2                	mov    %esi,%edx
  80112a:	f7 f1                	div    %ecx
  80112c:	31 d2                	xor    %edx,%edx
  80112e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801132:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801136:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80113a:	83 c4 1c             	add    $0x1c,%esp
  80113d:	c3                   	ret    
  80113e:	66 90                	xchg   %ax,%ax
  801140:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801145:	b8 20 00 00 00       	mov    $0x20,%eax
  80114a:	89 ea                	mov    %ebp,%edx
  80114c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801150:	d3 e7                	shl    %cl,%edi
  801152:	89 c1                	mov    %eax,%ecx
  801154:	d3 ea                	shr    %cl,%edx
  801156:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115b:	09 fa                	or     %edi,%edx
  80115d:	89 f7                	mov    %esi,%edi
  80115f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801163:	89 f2                	mov    %esi,%edx
  801165:	8b 74 24 08          	mov    0x8(%esp),%esi
  801169:	d3 e5                	shl    %cl,%ebp
  80116b:	89 c1                	mov    %eax,%ecx
  80116d:	d3 ef                	shr    %cl,%edi
  80116f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801174:	d3 e2                	shl    %cl,%edx
  801176:	89 c1                	mov    %eax,%ecx
  801178:	d3 ee                	shr    %cl,%esi
  80117a:	09 d6                	or     %edx,%esi
  80117c:	89 fa                	mov    %edi,%edx
  80117e:	89 f0                	mov    %esi,%eax
  801180:	f7 74 24 0c          	divl   0xc(%esp)
  801184:	89 d7                	mov    %edx,%edi
  801186:	89 c6                	mov    %eax,%esi
  801188:	f7 e5                	mul    %ebp
  80118a:	39 d7                	cmp    %edx,%edi
  80118c:	72 22                	jb     8011b0 <__udivdi3+0x110>
  80118e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801192:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801197:	d3 e5                	shl    %cl,%ebp
  801199:	39 c5                	cmp    %eax,%ebp
  80119b:	73 04                	jae    8011a1 <__udivdi3+0x101>
  80119d:	39 d7                	cmp    %edx,%edi
  80119f:	74 0f                	je     8011b0 <__udivdi3+0x110>
  8011a1:	89 f0                	mov    %esi,%eax
  8011a3:	31 d2                	xor    %edx,%edx
  8011a5:	e9 46 ff ff ff       	jmp    8010f0 <__udivdi3+0x50>
  8011aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8011b3:	31 d2                	xor    %edx,%edx
  8011b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c1:	83 c4 1c             	add    $0x1c,%esp
  8011c4:	c3                   	ret    
	...

008011d0 <__umoddi3>:
  8011d0:	83 ec 1c             	sub    $0x1c,%esp
  8011d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8011d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8011db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8011df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8011e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8011e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8011eb:	85 ed                	test   %ebp,%ebp
  8011ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8011f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f5:	89 cf                	mov    %ecx,%edi
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	89 f2                	mov    %esi,%edx
  8011fc:	75 1a                	jne    801218 <__umoddi3+0x48>
  8011fe:	39 f1                	cmp    %esi,%ecx
  801200:	76 4e                	jbe    801250 <__umoddi3+0x80>
  801202:	f7 f1                	div    %ecx
  801204:	89 d0                	mov    %edx,%eax
  801206:	31 d2                	xor    %edx,%edx
  801208:	8b 74 24 10          	mov    0x10(%esp),%esi
  80120c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801210:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801214:	83 c4 1c             	add    $0x1c,%esp
  801217:	c3                   	ret    
  801218:	39 f5                	cmp    %esi,%ebp
  80121a:	77 54                	ja     801270 <__umoddi3+0xa0>
  80121c:	0f bd c5             	bsr    %ebp,%eax
  80121f:	83 f0 1f             	xor    $0x1f,%eax
  801222:	89 44 24 04          	mov    %eax,0x4(%esp)
  801226:	75 60                	jne    801288 <__umoddi3+0xb8>
  801228:	3b 0c 24             	cmp    (%esp),%ecx
  80122b:	0f 87 07 01 00 00    	ja     801338 <__umoddi3+0x168>
  801231:	89 f2                	mov    %esi,%edx
  801233:	8b 34 24             	mov    (%esp),%esi
  801236:	29 ce                	sub    %ecx,%esi
  801238:	19 ea                	sbb    %ebp,%edx
  80123a:	89 34 24             	mov    %esi,(%esp)
  80123d:	8b 04 24             	mov    (%esp),%eax
  801240:	8b 74 24 10          	mov    0x10(%esp),%esi
  801244:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801248:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80124c:	83 c4 1c             	add    $0x1c,%esp
  80124f:	c3                   	ret    
  801250:	85 c9                	test   %ecx,%ecx
  801252:	75 0b                	jne    80125f <__umoddi3+0x8f>
  801254:	b8 01 00 00 00       	mov    $0x1,%eax
  801259:	31 d2                	xor    %edx,%edx
  80125b:	f7 f1                	div    %ecx
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 f0                	mov    %esi,%eax
  801261:	31 d2                	xor    %edx,%edx
  801263:	f7 f1                	div    %ecx
  801265:	8b 04 24             	mov    (%esp),%eax
  801268:	f7 f1                	div    %ecx
  80126a:	eb 98                	jmp    801204 <__umoddi3+0x34>
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 f2                	mov    %esi,%edx
  801272:	8b 74 24 10          	mov    0x10(%esp),%esi
  801276:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80127a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80127e:	83 c4 1c             	add    $0x1c,%esp
  801281:	c3                   	ret    
  801282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801288:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80128d:	89 e8                	mov    %ebp,%eax
  80128f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801294:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801298:	89 fa                	mov    %edi,%edx
  80129a:	d3 e0                	shl    %cl,%eax
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	d3 ea                	shr    %cl,%edx
  8012a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a5:	09 c2                	or     %eax,%edx
  8012a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ab:	89 14 24             	mov    %edx,(%esp)
  8012ae:	89 f2                	mov    %esi,%edx
  8012b0:	d3 e7                	shl    %cl,%edi
  8012b2:	89 e9                	mov    %ebp,%ecx
  8012b4:	d3 ea                	shr    %cl,%edx
  8012b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bf:	d3 e6                	shl    %cl,%esi
  8012c1:	89 e9                	mov    %ebp,%ecx
  8012c3:	d3 e8                	shr    %cl,%eax
  8012c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ca:	09 f0                	or     %esi,%eax
  8012cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012d0:	f7 34 24             	divl   (%esp)
  8012d3:	d3 e6                	shl    %cl,%esi
  8012d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8012d9:	89 d6                	mov    %edx,%esi
  8012db:	f7 e7                	mul    %edi
  8012dd:	39 d6                	cmp    %edx,%esi
  8012df:	89 c1                	mov    %eax,%ecx
  8012e1:	89 d7                	mov    %edx,%edi
  8012e3:	72 3f                	jb     801324 <__umoddi3+0x154>
  8012e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012e9:	72 35                	jb     801320 <__umoddi3+0x150>
  8012eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012ef:	29 c8                	sub    %ecx,%eax
  8012f1:	19 fe                	sbb    %edi,%esi
  8012f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012f8:	89 f2                	mov    %esi,%edx
  8012fa:	d3 e8                	shr    %cl,%eax
  8012fc:	89 e9                	mov    %ebp,%ecx
  8012fe:	d3 e2                	shl    %cl,%edx
  801300:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801305:	09 d0                	or     %edx,%eax
  801307:	89 f2                	mov    %esi,%edx
  801309:	d3 ea                	shr    %cl,%edx
  80130b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80130f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801313:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801317:	83 c4 1c             	add    $0x1c,%esp
  80131a:	c3                   	ret    
  80131b:	90                   	nop
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	39 d6                	cmp    %edx,%esi
  801322:	75 c7                	jne    8012eb <__umoddi3+0x11b>
  801324:	89 d7                	mov    %edx,%edi
  801326:	89 c1                	mov    %eax,%ecx
  801328:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80132c:	1b 3c 24             	sbb    (%esp),%edi
  80132f:	eb ba                	jmp    8012eb <__umoddi3+0x11b>
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	39 f5                	cmp    %esi,%ebp
  80133a:	0f 82 f1 fe ff ff    	jb     801231 <__umoddi3+0x61>
  801340:	e9 f8 fe ff ff       	jmp    80123d <__umoddi3+0x6d>
