
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800049:	8b 50 04             	mov    0x4(%eax),%edx
  80004c:	83 e2 07             	and    $0x7,%edx
  80004f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800053:	8b 00                	mov    (%eax),%eax
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 00 13 80 00 	movl   $0x801300,(%esp)
  800060:	e8 36 01 00 00       	call   80019b <cprintf>
	sys_env_destroy(sys_getenvid());
  800065:	e8 8e 0b 00 00       	call   800bf8 <sys_getenvid>
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 29 0b 00 00       	call   800b9b <sys_env_destroy>
}
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <umain>:

void
umain(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80007a:	c7 04 24 40 00 80 00 	movl   $0x800040,(%esp)
  800081:	e8 9a 0e 00 00       	call   800f20 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800086:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  80008d:	00 00 00 
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  8000a6:	e8 4d 0b 00 00       	call   800bf8 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cc:	89 34 24             	mov    %esi,(%esp)
  8000cf:	e8 a0 ff ff ff       	call   800074 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 a5 0a 00 00       	call   800b9b <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 14             	sub    $0x14,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 03                	mov    (%ebx),%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010b:	83 c0 01             	add    $0x1,%eax
  80010e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800110:	3d ff 00 00 00       	cmp    $0xff,%eax
  800115:	75 19                	jne    800130 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800117:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80011e:	00 
  80011f:	8d 43 08             	lea    0x8(%ebx),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 12 0a 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800130:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800134:	83 c4 14             	add    $0x14,%esp
  800137:	5b                   	pop    %ebx
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800143:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014a:	00 00 00 
	b.cnt = 0;
  80014d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800154:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800157:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015e:	8b 45 08             	mov    0x8(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016f:	c7 04 24 f8 00 80 00 	movl   $0x8000f8,(%esp)
  800176:	e8 d9 01 00 00       	call   800354 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018b:	89 04 24             	mov    %eax,(%esp)
  80018e:	e8 a9 09 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  800193:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001a1:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	89 04 24             	mov    %eax,(%esp)
  8001ae:	e8 87 ff ff ff       	call   80013a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 3c             	sub    $0x3c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d7                	mov    %edx,%edi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001e8:	72 11                	jb     8001fb <printnum+0x3b>
  8001ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ed:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f0:	76 09                	jbe    8001fb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f2:	83 eb 01             	sub    $0x1,%ebx
  8001f5:	85 db                	test   %ebx,%ebx
  8001f7:	7f 51                	jg     80024a <printnum+0x8a>
  8001f9:	eb 5e                	jmp    800259 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	8b 45 10             	mov    0x10(%ebp),%eax
  800209:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800211:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800215:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021c:	00 
  80021d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	e8 11 0e 00 00       	call   801040 <__udivdi3>
  80022f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800233:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800237:	89 04 24             	mov    %eax,(%esp)
  80023a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023e:	89 fa                	mov    %edi,%edx
  800240:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800243:	e8 78 ff ff ff       	call   8001c0 <printnum>
  800248:	eb 0f                	jmp    800259 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024e:	89 34 24             	mov    %esi,(%esp)
  800251:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800254:	83 eb 01             	sub    $0x1,%ebx
  800257:	75 f1                	jne    80024a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800259:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800261:	8b 45 10             	mov    0x10(%ebp),%eax
  800264:	89 44 24 08          	mov    %eax,0x8(%esp)
  800268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026f:	00 
  800270:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	e8 ee 0e 00 00       	call   801170 <__umoddi3>
  800282:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800286:	0f be 80 33 13 80 00 	movsbl 0x801333(%eax),%eax
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800293:	83 c4 3c             	add    $0x3c,%esp
  800296:	5b                   	pop    %ebx
  800297:	5e                   	pop    %esi
  800298:	5f                   	pop    %edi
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029e:	83 fa 01             	cmp    $0x1,%edx
  8002a1:	7e 0e                	jle    8002b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	8b 52 04             	mov    0x4(%edx),%edx
  8002af:	eb 22                	jmp    8002d3 <getuint+0x38>
	else if (lflag)
  8002b1:	85 d2                	test   %edx,%edx
  8002b3:	74 10                	je     8002c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b5:	8b 10                	mov    (%eax),%edx
  8002b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 02                	mov    (%edx),%eax
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	eb 0e                	jmp    8002d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 02                	mov    (%edx),%eax
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d8:	83 fa 01             	cmp    $0x1,%edx
  8002db:	7e 0e                	jle    8002eb <getint+0x16>
		return va_arg(*ap, long long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	8b 52 04             	mov    0x4(%edx),%edx
  8002e9:	eb 22                	jmp    80030d <getint+0x38>
	else if (lflag)
  8002eb:	85 d2                	test   %edx,%edx
  8002ed:	74 10                	je     8002ff <getint+0x2a>
		return va_arg(*ap, long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	89 c2                	mov    %eax,%edx
  8002fa:	c1 fa 1f             	sar    $0x1f,%edx
  8002fd:	eb 0e                	jmp    80030d <getint+0x38>
	else
		return va_arg(*ap, int);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	89 c2                	mov    %eax,%edx
  80030a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800315:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	3b 50 04             	cmp    0x4(%eax),%edx
  80031e:	73 0a                	jae    80032a <sprintputch+0x1b>
		*b->buf++ = ch;
  800320:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800323:	88 0a                	mov    %cl,(%edx)
  800325:	83 c2 01             	add    $0x1,%edx
  800328:	89 10                	mov    %edx,(%eax)
}
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    

0080032c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800332:	8d 45 14             	lea    0x14(%ebp),%eax
  800335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
  800343:	89 44 24 04          	mov    %eax,0x4(%esp)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	89 04 24             	mov    %eax,(%esp)
  80034d:	e8 02 00 00 00       	call   800354 <vprintfmt>
	va_end(ap);
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 4c             	sub    $0x4c,%esp
  80035d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800360:	8b 75 10             	mov    0x10(%ebp),%esi
  800363:	eb 12                	jmp    800377 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800365:	85 c0                	test   %eax,%eax
  800367:	0f 84 98 03 00 00    	je     800705 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80036d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800371:	89 04 24             	mov    %eax,(%esp)
  800374:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800377:	0f b6 06             	movzbl (%esi),%eax
  80037a:	83 c6 01             	add    $0x1,%esi
  80037d:	83 f8 25             	cmp    $0x25,%eax
  800380:	75 e3                	jne    800365 <vprintfmt+0x11>
  800382:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800386:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80038d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800392:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800399:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003a1:	eb 2b                	jmp    8003ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003aa:	eb 22                	jmp    8003ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003af:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003b3:	eb 19                	jmp    8003ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003bf:	eb 0d                	jmp    8003ce <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	0f b6 06             	movzbl (%esi),%eax
  8003d1:	0f b6 d0             	movzbl %al,%edx
  8003d4:	8d 7e 01             	lea    0x1(%esi),%edi
  8003d7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003da:	83 e8 23             	sub    $0x23,%eax
  8003dd:	3c 55                	cmp    $0x55,%al
  8003df:	0f 87 fa 02 00 00    	ja     8006df <vprintfmt+0x38b>
  8003e5:	0f b6 c0             	movzbl %al,%eax
  8003e8:	ff 24 85 00 14 80 00 	jmp    *0x801400(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ef:	83 ea 30             	sub    $0x30,%edx
  8003f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003f5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003f9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003ff:	83 fa 09             	cmp    $0x9,%edx
  800402:	77 4a                	ja     80044e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800407:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80040a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80040d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800411:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800414:	8d 50 d0             	lea    -0x30(%eax),%edx
  800417:	83 fa 09             	cmp    $0x9,%edx
  80041a:	76 eb                	jbe    800407 <vprintfmt+0xb3>
  80041c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80041f:	eb 2d                	jmp    80044e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 50 04             	lea    0x4(%eax),%edx
  800427:	89 55 14             	mov    %edx,0x14(%ebp)
  80042a:	8b 00                	mov    (%eax),%eax
  80042c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800432:	eb 1a                	jmp    80044e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800437:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043b:	79 91                	jns    8003ce <vprintfmt+0x7a>
  80043d:	e9 73 ff ff ff       	jmp    8003b5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800445:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80044c:	eb 80                	jmp    8003ce <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80044e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800452:	0f 89 76 ff ff ff    	jns    8003ce <vprintfmt+0x7a>
  800458:	e9 64 ff ff ff       	jmp    8003c1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800463:	e9 66 ff ff ff       	jmp    8003ce <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800475:	8b 00                	mov    (%eax),%eax
  800477:	89 04 24             	mov    %eax,(%esp)
  80047a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800480:	e9 f2 fe ff ff       	jmp    800377 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	8d 50 04             	lea    0x4(%eax),%edx
  80048b:	89 55 14             	mov    %edx,0x14(%ebp)
  80048e:	8b 00                	mov    (%eax),%eax
  800490:	89 c2                	mov    %eax,%edx
  800492:	c1 fa 1f             	sar    $0x1f,%edx
  800495:	31 d0                	xor    %edx,%eax
  800497:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800499:	83 f8 08             	cmp    $0x8,%eax
  80049c:	7f 0b                	jg     8004a9 <vprintfmt+0x155>
  80049e:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	75 23                	jne    8004cc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ad:	c7 44 24 08 4b 13 80 	movl   $0x80134b,0x8(%esp)
  8004b4:	00 
  8004b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004bc:	89 3c 24             	mov    %edi,(%esp)
  8004bf:	e8 68 fe ff ff       	call   80032c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c7:	e9 ab fe ff ff       	jmp    800377 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d0:	c7 44 24 08 54 13 80 	movl   $0x801354,0x8(%esp)
  8004d7:	00 
  8004d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004df:	89 3c 24             	mov    %edi,(%esp)
  8004e2:	e8 45 fe ff ff       	call   80032c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ea:	e9 88 fe ff ff       	jmp    800377 <vprintfmt+0x23>
  8004ef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 50 04             	lea    0x4(%eax),%edx
  8004fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800501:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800503:	85 f6                	test   %esi,%esi
  800505:	ba 44 13 80 00       	mov    $0x801344,%edx
  80050a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80050d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800511:	7e 06                	jle    800519 <vprintfmt+0x1c5>
  800513:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800517:	75 10                	jne    800529 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800519:	0f be 06             	movsbl (%esi),%eax
  80051c:	83 c6 01             	add    $0x1,%esi
  80051f:	85 c0                	test   %eax,%eax
  800521:	0f 85 86 00 00 00    	jne    8005ad <vprintfmt+0x259>
  800527:	eb 76                	jmp    80059f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052d:	89 34 24             	mov    %esi,(%esp)
  800530:	e8 76 02 00 00       	call   8007ab <strnlen>
  800535:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800538:	29 c2                	sub    %eax,%edx
  80053a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80053d:	85 d2                	test   %edx,%edx
  80053f:	7e d8                	jle    800519 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800541:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800545:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800548:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80054b:	89 d6                	mov    %edx,%esi
  80054d:	89 c7                	mov    %eax,%edi
  80054f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800553:	89 3c 24             	mov    %edi,(%esp)
  800556:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800559:	83 ee 01             	sub    $0x1,%esi
  80055c:	75 f1                	jne    80054f <vprintfmt+0x1fb>
  80055e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800561:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800564:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800567:	eb b0                	jmp    800519 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800569:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056d:	74 18                	je     800587 <vprintfmt+0x233>
  80056f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800572:	83 fa 5e             	cmp    $0x5e,%edx
  800575:	76 10                	jbe    800587 <vprintfmt+0x233>
					putch('?', putdat);
  800577:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	eb 0a                	jmp    800591 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800587:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058b:	89 04 24             	mov    %eax,(%esp)
  80058e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800591:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800595:	0f be 06             	movsbl (%esi),%eax
  800598:	83 c6 01             	add    $0x1,%esi
  80059b:	85 c0                	test   %eax,%eax
  80059d:	75 0e                	jne    8005ad <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a6:	7f 11                	jg     8005b9 <vprintfmt+0x265>
  8005a8:	e9 ca fd ff ff       	jmp    800377 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ad:	85 ff                	test   %edi,%edi
  8005af:	90                   	nop
  8005b0:	78 b7                	js     800569 <vprintfmt+0x215>
  8005b2:	83 ef 01             	sub    $0x1,%edi
  8005b5:	79 b2                	jns    800569 <vprintfmt+0x215>
  8005b7:	eb e6                	jmp    80059f <vprintfmt+0x24b>
  8005b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005bc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ca:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cc:	83 ee 01             	sub    $0x1,%esi
  8005cf:	75 ee                	jne    8005bf <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005d4:	e9 9e fd ff ff       	jmp    800377 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d9:	89 ca                	mov    %ecx,%edx
  8005db:	8d 45 14             	lea    0x14(%ebp),%eax
  8005de:	e8 f2 fc ff ff       	call   8002d5 <getint>
  8005e3:	89 c6                	mov    %eax,%esi
  8005e5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	0f 89 ad 00 00 00    	jns    8006a1 <vprintfmt+0x34d>
				putch('-', putdat);
  8005f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800602:	f7 de                	neg    %esi
  800604:	83 d7 00             	adc    $0x0,%edi
  800607:	f7 df                	neg    %edi
			}
			base = 10;
  800609:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060e:	e9 8e 00 00 00       	jmp    8006a1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800613:	89 ca                	mov    %ecx,%edx
  800615:	8d 45 14             	lea    0x14(%ebp),%eax
  800618:	e8 7e fc ff ff       	call   80029b <getuint>
  80061d:	89 c6                	mov    %eax,%esi
  80061f:	89 d7                	mov    %edx,%edi
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800626:	eb 79                	jmp    8006a1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800628:	89 ca                	mov    %ecx,%edx
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 a3 fc ff ff       	call   8002d5 <getint>
  800632:	89 c6                	mov    %eax,%esi
  800634:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800636:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063b:	85 d2                	test   %edx,%edx
  80063d:	79 62                	jns    8006a1 <vprintfmt+0x34d>
				putch('-', putdat);
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064d:	f7 de                	neg    %esi
  80064f:	83 d7 00             	adc    $0x0,%edi
  800652:	f7 df                	neg    %edi
			}
			base = 8;
  800654:	b8 08 00 00 00       	mov    $0x8,%eax
  800659:	eb 46                	jmp    8006a1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80065b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800666:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800669:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800674:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 04             	lea    0x4(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800680:	8b 30                	mov    (%eax),%esi
  800682:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068c:	eb 13                	jmp    8006a1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068e:	89 ca                	mov    %ecx,%edx
  800690:	8d 45 14             	lea    0x14(%ebp),%eax
  800693:	e8 03 fc ff ff       	call   80029b <getuint>
  800698:	89 c6                	mov    %eax,%esi
  80069a:	89 d7                	mov    %edx,%edi
			base = 16;
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b4:	89 34 24             	mov    %esi,(%esp)
  8006b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006bb:	89 da                	mov    %ebx,%edx
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	e8 fb fa ff ff       	call   8001c0 <printnum>
			break;
  8006c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c8:	e9 aa fc ff ff       	jmp    800377 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d1:	89 14 24             	mov    %edx,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006da:	e9 98 fc ff ff       	jmp    800377 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ea:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ed:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006f1:	0f 84 80 fc ff ff    	je     800377 <vprintfmt+0x23>
  8006f7:	83 ee 01             	sub    $0x1,%esi
  8006fa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006fe:	75 f7                	jne    8006f7 <vprintfmt+0x3a3>
  800700:	e9 72 fc ff ff       	jmp    800377 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800705:	83 c4 4c             	add    $0x4c,%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 28             	sub    $0x28,%esp
  800713:	8b 45 08             	mov    0x8(%ebp),%eax
  800716:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800719:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800720:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800723:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072a:	85 c0                	test   %eax,%eax
  80072c:	74 30                	je     80075e <vsnprintf+0x51>
  80072e:	85 d2                	test   %edx,%edx
  800730:	7e 2c                	jle    80075e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800739:	8b 45 10             	mov    0x10(%ebp),%eax
  80073c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800740:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	c7 04 24 0f 03 80 00 	movl   $0x80030f,(%esp)
  80074e:	e8 01 fc ff ff       	call   800354 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800753:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800756:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075c:	eb 05                	jmp    800763 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800772:	8b 45 10             	mov    0x10(%ebp),%eax
  800775:	89 44 24 08          	mov    %eax,0x8(%esp)
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	89 04 24             	mov    %eax,(%esp)
  800786:	e8 82 ff ff ff       	call   80070d <vsnprintf>
	va_end(ap);

	return rc;
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    
  80078d:	00 00                	add    %al,(%eax)
	...

00800790 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	80 3a 00             	cmpb   $0x0,(%edx)
  80079e:	74 09                	je     8007a9 <strlen+0x19>
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a7:	75 f7                	jne    8007a0 <strlen+0x10>
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ba:	85 c9                	test   %ecx,%ecx
  8007bc:	74 1a                	je     8007d8 <strnlen+0x2d>
  8007be:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007c1:	74 15                	je     8007d8 <strnlen+0x2d>
  8007c3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007c8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ca:	39 ca                	cmp    %ecx,%edx
  8007cc:	74 0a                	je     8007d8 <strnlen+0x2d>
  8007ce:	83 c2 01             	add    $0x1,%edx
  8007d1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007d6:	75 f0                	jne    8007c8 <strnlen+0x1d>
		n++;
	return n;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007ee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007f1:	83 c2 01             	add    $0x1,%edx
  8007f4:	84 c9                	test   %cl,%cl
  8007f6:	75 f2                	jne    8007ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 45 08             	mov    0x8(%ebp),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	85 f6                	test   %esi,%esi
  80080b:	74 18                	je     800825 <strncpy+0x2a>
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800812:	0f b6 1a             	movzbl (%edx),%ebx
  800815:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800818:	80 3a 01             	cmpb   $0x1,(%edx)
  80081b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	83 c1 01             	add    $0x1,%ecx
  800821:	39 f1                	cmp    %esi,%ecx
  800823:	75 ed                	jne    800812 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	57                   	push   %edi
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800835:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	89 f8                	mov    %edi,%eax
  80083a:	85 f6                	test   %esi,%esi
  80083c:	74 2b                	je     800869 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80083e:	83 fe 01             	cmp    $0x1,%esi
  800841:	74 23                	je     800866 <strlcpy+0x3d>
  800843:	0f b6 0b             	movzbl (%ebx),%ecx
  800846:	84 c9                	test   %cl,%cl
  800848:	74 1c                	je     800866 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80084a:	83 ee 02             	sub    $0x2,%esi
  80084d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800852:	88 08                	mov    %cl,(%eax)
  800854:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800857:	39 f2                	cmp    %esi,%edx
  800859:	74 0b                	je     800866 <strlcpy+0x3d>
  80085b:	83 c2 01             	add    $0x1,%edx
  80085e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800862:	84 c9                	test   %cl,%cl
  800864:	75 ec                	jne    800852 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800866:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800869:	29 f8                	sub    %edi,%eax
}
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5f                   	pop    %edi
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800879:	0f b6 01             	movzbl (%ecx),%eax
  80087c:	84 c0                	test   %al,%al
  80087e:	74 16                	je     800896 <strcmp+0x26>
  800880:	3a 02                	cmp    (%edx),%al
  800882:	75 12                	jne    800896 <strcmp+0x26>
		p++, q++;
  800884:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800887:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80088b:	84 c0                	test   %al,%al
  80088d:	74 07                	je     800896 <strcmp+0x26>
  80088f:	83 c1 01             	add    $0x1,%ecx
  800892:	3a 02                	cmp    (%edx),%al
  800894:	74 ee                	je     800884 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800896:	0f b6 c0             	movzbl %al,%eax
  800899:	0f b6 12             	movzbl (%edx),%edx
  80089c:	29 d0                	sub    %edx,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008aa:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b2:	85 d2                	test   %edx,%edx
  8008b4:	74 28                	je     8008de <strncmp+0x3e>
  8008b6:	0f b6 01             	movzbl (%ecx),%eax
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 24                	je     8008e1 <strncmp+0x41>
  8008bd:	3a 03                	cmp    (%ebx),%al
  8008bf:	75 20                	jne    8008e1 <strncmp+0x41>
  8008c1:	83 ea 01             	sub    $0x1,%edx
  8008c4:	74 13                	je     8008d9 <strncmp+0x39>
		n--, p++, q++;
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cc:	0f b6 01             	movzbl (%ecx),%eax
  8008cf:	84 c0                	test   %al,%al
  8008d1:	74 0e                	je     8008e1 <strncmp+0x41>
  8008d3:	3a 03                	cmp    (%ebx),%al
  8008d5:	74 ea                	je     8008c1 <strncmp+0x21>
  8008d7:	eb 08                	jmp    8008e1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008de:	5b                   	pop    %ebx
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 01             	movzbl (%ecx),%eax
  8008e4:	0f b6 13             	movzbl (%ebx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
  8008e9:	eb f3                	jmp    8008de <strncmp+0x3e>

008008eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f5:	0f b6 10             	movzbl (%eax),%edx
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	74 1c                	je     800918 <strchr+0x2d>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	75 09                	jne    800909 <strchr+0x1e>
  800900:	eb 1b                	jmp    80091d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800902:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 14                	je     80091d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800909:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  80090d:	84 d2                	test   %dl,%dl
  80090f:	75 f1                	jne    800902 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb 05                	jmp    80091d <strchr+0x32>
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800929:	0f b6 10             	movzbl (%eax),%edx
  80092c:	84 d2                	test   %dl,%dl
  80092e:	74 14                	je     800944 <strfind+0x25>
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	75 06                	jne    80093a <strfind+0x1b>
  800934:	eb 0e                	jmp    800944 <strfind+0x25>
  800936:	38 ca                	cmp    %cl,%dl
  800938:	74 0a                	je     800944 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 10             	movzbl (%eax),%edx
  800940:	84 d2                	test   %dl,%dl
  800942:	75 f2                	jne    800936 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800950:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800953:	89 da                	mov    %ebx,%edx
  800955:	83 ea 01             	sub    $0x1,%edx
  800958:	78 0d                	js     800967 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80095a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  80095c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  80095e:	88 0a                	mov    %cl,(%edx)
  800960:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800963:	39 da                	cmp    %ebx,%edx
  800965:	75 f7                	jne    80095e <memset+0x18>
		*p++ = c;

	return v;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 75 0c             	mov    0xc(%ebp),%esi
  800976:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800979:	39 c6                	cmp    %eax,%esi
  80097b:	72 0b                	jb     800988 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  80097d:	ba 00 00 00 00       	mov    $0x0,%edx
  800982:	85 db                	test   %ebx,%ebx
  800984:	75 29                	jne    8009af <memmove+0x45>
  800986:	eb 35                	jmp    8009bd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800988:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  80098b:	39 c8                	cmp    %ecx,%eax
  80098d:	73 ee                	jae    80097d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  80098f:	85 db                	test   %ebx,%ebx
  800991:	74 2a                	je     8009bd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800993:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800996:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800998:	f7 db                	neg    %ebx
  80099a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  80099d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  80099f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  8009a4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  8009a8:	83 ea 01             	sub    $0x1,%edx
  8009ab:	75 f2                	jne    80099f <memmove+0x35>
  8009ad:	eb 0e                	jmp    8009bd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  8009af:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009b3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009b6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  8009b9:	39 d3                	cmp    %edx,%ebx
  8009bb:	75 f2                	jne    8009af <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	89 04 24             	mov    %eax,(%esp)
  8009dc:	e8 89 ff ff ff       	call   80096a <memmove>
}
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ef:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	85 ff                	test   %edi,%edi
  8009f9:	74 37                	je     800a32 <memcmp+0x4f>
		if (*s1 != *s2)
  8009fb:	0f b6 03             	movzbl (%ebx),%eax
  8009fe:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a01:	83 ef 01             	sub    $0x1,%edi
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a09:	38 c8                	cmp    %cl,%al
  800a0b:	74 1c                	je     800a29 <memcmp+0x46>
  800a0d:	eb 10                	jmp    800a1f <memcmp+0x3c>
  800a0f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a14:	83 c2 01             	add    $0x1,%edx
  800a17:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a1b:	38 c8                	cmp    %cl,%al
  800a1d:	74 0a                	je     800a29 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800a1f:	0f b6 c0             	movzbl %al,%eax
  800a22:	0f b6 c9             	movzbl %cl,%ecx
  800a25:	29 c8                	sub    %ecx,%eax
  800a27:	eb 09                	jmp    800a32 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a29:	39 fa                	cmp    %edi,%edx
  800a2b:	75 e2                	jne    800a0f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	73 15                	jae    800a5b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a4a:	38 08                	cmp    %cl,(%eax)
  800a4c:	75 06                	jne    800a54 <memfind+0x1d>
  800a4e:	eb 0b                	jmp    800a5b <memfind+0x24>
  800a50:	38 08                	cmp    %cl,(%eax)
  800a52:	74 07                	je     800a5b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a54:	83 c0 01             	add    $0x1,%eax
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	75 f5                	jne    800a50 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
  800a66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a69:	0f b6 02             	movzbl (%edx),%eax
  800a6c:	3c 20                	cmp    $0x20,%al
  800a6e:	74 04                	je     800a74 <strtol+0x17>
  800a70:	3c 09                	cmp    $0x9,%al
  800a72:	75 0e                	jne    800a82 <strtol+0x25>
		s++;
  800a74:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	0f b6 02             	movzbl (%edx),%eax
  800a7a:	3c 20                	cmp    $0x20,%al
  800a7c:	74 f6                	je     800a74 <strtol+0x17>
  800a7e:	3c 09                	cmp    $0x9,%al
  800a80:	74 f2                	je     800a74 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a82:	3c 2b                	cmp    $0x2b,%al
  800a84:	75 0a                	jne    800a90 <strtol+0x33>
		s++;
  800a86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	eb 10                	jmp    800aa0 <strtol+0x43>
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a95:	3c 2d                	cmp    $0x2d,%al
  800a97:	75 07                	jne    800aa0 <strtol+0x43>
		s++, neg = 1;
  800a99:	83 c2 01             	add    $0x1,%edx
  800a9c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa0:	85 db                	test   %ebx,%ebx
  800aa2:	0f 94 c0             	sete   %al
  800aa5:	74 05                	je     800aac <strtol+0x4f>
  800aa7:	83 fb 10             	cmp    $0x10,%ebx
  800aaa:	75 15                	jne    800ac1 <strtol+0x64>
  800aac:	80 3a 30             	cmpb   $0x30,(%edx)
  800aaf:	75 10                	jne    800ac1 <strtol+0x64>
  800ab1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab5:	75 0a                	jne    800ac1 <strtol+0x64>
		s += 2, base = 16;
  800ab7:	83 c2 02             	add    $0x2,%edx
  800aba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abf:	eb 13                	jmp    800ad4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ac1:	84 c0                	test   %al,%al
  800ac3:	74 0f                	je     800ad4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	80 3a 30             	cmpb   $0x30,(%edx)
  800acd:	75 05                	jne    800ad4 <strtol+0x77>
		s++, base = 8;
  800acf:	83 c2 01             	add    $0x1,%edx
  800ad2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adb:	0f b6 0a             	movzbl (%edx),%ecx
  800ade:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x91>
			dig = *s - '0';
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 30             	sub    $0x30,%ecx
  800aec:	eb 1e                	jmp    800b0c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 08                	ja     800afe <strtol+0xa1>
			dig = *s - 'a' + 10;
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 57             	sub    $0x57,%ecx
  800afc:	eb 0e                	jmp    800b0c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800afe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 14                	ja     800b1a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b06:	0f be c9             	movsbl %cl,%ecx
  800b09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b0c:	39 f1                	cmp    %esi,%ecx
  800b0e:	7d 0e                	jge    800b1e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b10:	83 c2 01             	add    $0x1,%edx
  800b13:	0f af c6             	imul   %esi,%eax
  800b16:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b18:	eb c1                	jmp    800adb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b1a:	89 c1                	mov    %eax,%ecx
  800b1c:	eb 02                	jmp    800b20 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b24:	74 05                	je     800b2b <strtol+0xce>
		*endptr = (char *) s;
  800b26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b29:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b2b:	89 ca                	mov    %ecx,%edx
  800b2d:	f7 da                	neg    %edx
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	0f 45 c2             	cmovne %edx,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    
  800b39:	00 00                	add    %al,(%eax)
	...

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b48:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	89 c3                	mov    %eax,%ebx
  800b58:	89 c7                	mov    %eax,%edi
  800b5a:	89 c6                	mov    %eax,%esi
  800b5c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b67:	89 ec                	mov    %ebp,%esp
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b84:	89 d1                	mov    %edx,%ecx
  800b86:	89 d3                	mov    %edx,%ebx
  800b88:	89 d7                	mov    %edx,%edi
  800b8a:	89 d6                	mov    %edx,%esi
  800b8c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b91:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b94:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b97:	89 ec                	mov    %ebp,%esp
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	83 ec 38             	sub    $0x38,%esp
  800ba1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ba4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ba7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800baf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 cb                	mov    %ecx,%ebx
  800bb9:	89 cf                	mov    %ecx,%edi
  800bbb:	89 ce                	mov    %ecx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 28                	jle    800beb <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bce:	00 
  800bcf:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800bd6:	00 
  800bd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bde:	00 
  800bdf:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800be6:	e8 f1 03 00 00       	call   800fdc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800beb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bf1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bf4:	89 ec                	mov    %ebp,%esp
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c01:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c04:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c11:	89 d1                	mov    %edx,%ecx
  800c13:	89 d3                	mov    %edx,%ebx
  800c15:	89 d7                	mov    %edx,%edi
  800c17:	89 d6                	mov    %edx,%esi
  800c19:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c24:	89 ec                	mov    %ebp,%esp
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_yield>:

void
sys_yield(void)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c34:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c41:	89 d1                	mov    %edx,%ecx
  800c43:	89 d3                	mov    %edx,%ebx
  800c45:	89 d7                	mov    %edx,%edi
  800c47:	89 d6                	mov    %edx,%esi
  800c49:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c54:	89 ec                	mov    %ebp,%esp
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 38             	sub    $0x38,%esp
  800c5e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c61:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c64:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	be 00 00 00 00       	mov    $0x0,%esi
  800c6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 f7                	mov    %esi,%edi
  800c7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 28                	jle    800caa <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c86:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800c95:	00 
  800c96:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9d:	00 
  800c9e:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800ca5:	e8 32 03 00 00       	call   800fdc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800caa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cad:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb3:	89 ec                	mov    %ebp,%esp
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 38             	sub    $0x38,%esp
  800cbd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ccb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 28                	jle    800d08 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ceb:	00 
  800cec:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800cf3:	00 
  800cf4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfb:	00 
  800cfc:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800d03:	e8 d4 02 00 00       	call   800fdc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d08:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d0e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d11:	89 ec                	mov    %ebp,%esp
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	83 ec 38             	sub    $0x38,%esp
  800d1b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d1e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d21:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d29:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	89 df                	mov    %ebx,%edi
  800d36:	89 de                	mov    %ebx,%esi
  800d38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	7e 28                	jle    800d66 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d42:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d49:	00 
  800d4a:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800d51:	00 
  800d52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d59:	00 
  800d5a:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800d61:	e8 76 02 00 00       	call   800fdc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d66:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d69:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d6c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6f:	89 ec                	mov    %ebp,%esp
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 38             	sub    $0x38,%esp
  800d79:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d7c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d87:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 df                	mov    %ebx,%edi
  800d94:	89 de                	mov    %ebx,%esi
  800d96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 28                	jle    800dc4 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da0:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800da7:	00 
  800da8:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800daf:	00 
  800db0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db7:	00 
  800db8:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800dbf:	e8 18 02 00 00       	call   800fdc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcd:	89 ec                	mov    %ebp,%esp
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	83 ec 38             	sub    $0x38,%esp
  800dd7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dda:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	89 df                	mov    %ebx,%edi
  800df2:	89 de                	mov    %ebx,%esi
  800df4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800df6:	85 c0                	test   %eax,%eax
  800df8:	7e 28                	jle    800e22 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfe:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e05:	00 
  800e06:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e1d:	e8 ba 01 00 00       	call   800fdc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e22:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e25:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e28:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2b:	89 ec                	mov    %ebp,%esp
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 38             	sub    $0x38,%esp
  800e35:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e38:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e43:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4e:	89 df                	mov    %ebx,%edi
  800e50:	89 de                	mov    %ebx,%esi
  800e52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e54:	85 c0                	test   %eax,%eax
  800e56:	7e 28                	jle    800e80 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e63:	00 
  800e64:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e6b:	00 
  800e6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e73:	00 
  800e74:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e7b:	e8 5c 01 00 00       	call   800fdc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e80:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e83:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e86:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e89:	89 ec                	mov    %ebp,%esp
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e96:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e99:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ea1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ebd:	89 ec                	mov    %ebp,%esp
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 38             	sub    $0x38,%esp
  800ec7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ecd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	89 cb                	mov    %ecx,%ebx
  800edf:	89 cf                	mov    %ecx,%edi
  800ee1:	89 ce                	mov    %ecx,%esi
  800ee3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 28                	jle    800f11 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eed:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800efc:	00 
  800efd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f04:	00 
  800f05:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800f0c:	e8 cb 00 00 00       	call   800fdc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f11:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f14:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f17:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1a:	89 ec                	mov    %ebp,%esp
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    
	...

00800f20 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	53                   	push   %ebx
  800f24:	83 ec 14             	sub    $0x14,%esp
	int r;

	// Set the page fault handler function.
	// If there isn't one yet, _pgfault_handler will be 0.
	if (_pgfault_handler == 0) {
  800f27:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f2e:	75 77                	jne    800fa7 <set_pgfault_handler+0x87>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800f30:	e8 c3 fc ff ff       	call   800bf8 <sys_getenvid>
  800f35:	89 c3                	mov    %eax,%ebx
		// The first time we register a handler, we need to 
		// allocate an exception stack (one page of memory with its top
		// at UXSTACKTOP). [UXSTACKTOP-PGSIZE, UXSTACKTOP-1]
		// user can read, write
		if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE),
  800f37:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f46:	ee 
  800f47:	89 04 24             	mov    %eax,(%esp)
  800f4a:	e8 09 fd ff ff       	call   800c58 <sys_page_alloc>
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 20                	jns    800f73 <set_pgfault_handler+0x53>
			PTE_W | PTE_U | PTE_P)) < 0)
		{
			panic("set_pgfault_handler: %e", r);
  800f53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f57:	c7 44 24 08 af 15 80 	movl   $0x8015af,0x8(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f66:	00 
  800f67:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800f6e:	e8 69 00 00 00       	call   800fdc <_panic>
			return;
		}
		// tell the kernel to call the assembly-language
		// _pgfault_upcall routine when a page fault occurs.
		if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  800f73:	c7 44 24 04 b8 0f 80 	movl   $0x800fb8,0x4(%esp)
  800f7a:	00 
  800f7b:	89 1c 24             	mov    %ebx,(%esp)
  800f7e:	e8 ac fe ff ff       	call   800e2f <sys_env_set_pgfault_upcall>
  800f83:	85 c0                	test   %eax,%eax
  800f85:	79 20                	jns    800fa7 <set_pgfault_handler+0x87>
		{
			panic("set_pgfault_handler: %e", r);
  800f87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f8b:	c7 44 24 08 af 15 80 	movl   $0x8015af,0x8(%esp)
  800f92:	00 
  800f93:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f9a:	00 
  800f9b:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  800fa2:	e8 35 00 00 00       	call   800fdc <_panic>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800faf:	83 c4 14             	add    $0x14,%esp
  800fb2:	5b                   	pop    %ebx
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	00 00                	add    %al,(%eax)
	...

00800fb8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800fb8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800fb9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800fbe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800fc0:	83 c4 04             	add    $0x4,%esp
	// it means that esp points to fault_va now, esp -> fault_va
	// eax, ecx, edx are saved-by-caller regs, use as wish
	// while edx, esi, edi are saved-by-called regs, save before using
	// and restore before leaving
	// our eip
	movl	40(%esp),	%eax
  800fc3:	8b 44 24 28          	mov    0x28(%esp),%eax
	// esp, the trap-time stack to return to
	movl	48(%esp),	%ecx
  800fc7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// set rip to be out eip
	// there is only one op-num can be memory-accessing
	movl	%eax,	-4(%ecx)
  800fcb:	89 41 fc             	mov    %eax,-0x4(%ecx)

	// Restore the trap-time registers.
	// LAB 4: Your code here.
	// esp -> fault_va
	// skip fault_va and tf_err
	addl	$8,	%esp
  800fce:	83 c4 08             	add    $0x8,%esp
	// esp -> trap-time edi
	popal
  800fd1:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.
	// esp -> trap-time eip
	addl	$4,	%esp
  800fd2:	83 c4 04             	add    $0x4,%esp
	// esp -> trap-time eflags
	// popfl defined in "inc/x86.h"
	popfl
  800fd5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// esp -> trap-time esp
	// as requested
	popl	%esp
  800fd6:	5c                   	pop    %esp
	// esp -> the first argument
	subl	$4,	%esp
  800fd7:	83 ec 04             	sub    $0x4,%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// esp -> rip
	// ret will jump to rip, but esp must point to rip
  800fda:	c3                   	ret    
	...

00800fdc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800fe2:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	74 10                	je     800ffb <_panic+0x1f>
		cprintf("%s: ", argv0);
  800feb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fef:	c7 04 24 d5 15 80 00 	movl   $0x8015d5,(%esp)
  800ff6:	e8 a0 f1 ff ff       	call   80019b <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801002:	8b 45 08             	mov    0x8(%ebp),%eax
  801005:	89 44 24 08          	mov    %eax,0x8(%esp)
  801009:	a1 00 20 80 00       	mov    0x802000,%eax
  80100e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801012:	c7 04 24 da 15 80 00 	movl   $0x8015da,(%esp)
  801019:	e8 7d f1 ff ff       	call   80019b <cprintf>
	vcprintf(fmt, ap);
  80101e:	8d 45 14             	lea    0x14(%ebp),%eax
  801021:	89 44 24 04          	mov    %eax,0x4(%esp)
  801025:	8b 45 10             	mov    0x10(%ebp),%eax
  801028:	89 04 24             	mov    %eax,(%esp)
  80102b:	e8 0a f1 ff ff       	call   80013a <vcprintf>
	cprintf("\n");
  801030:	c7 04 24 1a 13 80 00 	movl   $0x80131a,(%esp)
  801037:	e8 5f f1 ff ff       	call   80019b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80103c:	cc                   	int3   
  80103d:	eb fd                	jmp    80103c <_panic+0x60>
	...

00801040 <__udivdi3>:
  801040:	83 ec 1c             	sub    $0x1c,%esp
  801043:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801047:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80104b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80104f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801053:	89 74 24 10          	mov    %esi,0x10(%esp)
  801057:	8b 74 24 24          	mov    0x24(%esp),%esi
  80105b:	85 ff                	test   %edi,%edi
  80105d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801061:	89 44 24 08          	mov    %eax,0x8(%esp)
  801065:	89 cd                	mov    %ecx,%ebp
  801067:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106b:	75 33                	jne    8010a0 <__udivdi3+0x60>
  80106d:	39 f1                	cmp    %esi,%ecx
  80106f:	77 57                	ja     8010c8 <__udivdi3+0x88>
  801071:	85 c9                	test   %ecx,%ecx
  801073:	75 0b                	jne    801080 <__udivdi3+0x40>
  801075:	b8 01 00 00 00       	mov    $0x1,%eax
  80107a:	31 d2                	xor    %edx,%edx
  80107c:	f7 f1                	div    %ecx
  80107e:	89 c1                	mov    %eax,%ecx
  801080:	89 f0                	mov    %esi,%eax
  801082:	31 d2                	xor    %edx,%edx
  801084:	f7 f1                	div    %ecx
  801086:	89 c6                	mov    %eax,%esi
  801088:	8b 44 24 04          	mov    0x4(%esp),%eax
  80108c:	f7 f1                	div    %ecx
  80108e:	89 f2                	mov    %esi,%edx
  801090:	8b 74 24 10          	mov    0x10(%esp),%esi
  801094:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801098:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80109c:	83 c4 1c             	add    $0x1c,%esp
  80109f:	c3                   	ret    
  8010a0:	31 d2                	xor    %edx,%edx
  8010a2:	31 c0                	xor    %eax,%eax
  8010a4:	39 f7                	cmp    %esi,%edi
  8010a6:	77 e8                	ja     801090 <__udivdi3+0x50>
  8010a8:	0f bd cf             	bsr    %edi,%ecx
  8010ab:	83 f1 1f             	xor    $0x1f,%ecx
  8010ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010b2:	75 2c                	jne    8010e0 <__udivdi3+0xa0>
  8010b4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010b8:	76 04                	jbe    8010be <__udivdi3+0x7e>
  8010ba:	39 f7                	cmp    %esi,%edi
  8010bc:	73 d2                	jae    801090 <__udivdi3+0x50>
  8010be:	31 d2                	xor    %edx,%edx
  8010c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c5:	eb c9                	jmp    801090 <__udivdi3+0x50>
  8010c7:	90                   	nop
  8010c8:	89 f2                	mov    %esi,%edx
  8010ca:	f7 f1                	div    %ecx
  8010cc:	31 d2                	xor    %edx,%edx
  8010ce:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010da:	83 c4 1c             	add    $0x1c,%esp
  8010dd:	c3                   	ret    
  8010de:	66 90                	xchg   %ax,%ax
  8010e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010e5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010ea:	89 ea                	mov    %ebp,%edx
  8010ec:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010f0:	d3 e7                	shl    %cl,%edi
  8010f2:	89 c1                	mov    %eax,%ecx
  8010f4:	d3 ea                	shr    %cl,%edx
  8010f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010fb:	09 fa                	or     %edi,%edx
  8010fd:	89 f7                	mov    %esi,%edi
  8010ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801103:	89 f2                	mov    %esi,%edx
  801105:	8b 74 24 08          	mov    0x8(%esp),%esi
  801109:	d3 e5                	shl    %cl,%ebp
  80110b:	89 c1                	mov    %eax,%ecx
  80110d:	d3 ef                	shr    %cl,%edi
  80110f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801114:	d3 e2                	shl    %cl,%edx
  801116:	89 c1                	mov    %eax,%ecx
  801118:	d3 ee                	shr    %cl,%esi
  80111a:	09 d6                	or     %edx,%esi
  80111c:	89 fa                	mov    %edi,%edx
  80111e:	89 f0                	mov    %esi,%eax
  801120:	f7 74 24 0c          	divl   0xc(%esp)
  801124:	89 d7                	mov    %edx,%edi
  801126:	89 c6                	mov    %eax,%esi
  801128:	f7 e5                	mul    %ebp
  80112a:	39 d7                	cmp    %edx,%edi
  80112c:	72 22                	jb     801150 <__udivdi3+0x110>
  80112e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801132:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801137:	d3 e5                	shl    %cl,%ebp
  801139:	39 c5                	cmp    %eax,%ebp
  80113b:	73 04                	jae    801141 <__udivdi3+0x101>
  80113d:	39 d7                	cmp    %edx,%edi
  80113f:	74 0f                	je     801150 <__udivdi3+0x110>
  801141:	89 f0                	mov    %esi,%eax
  801143:	31 d2                	xor    %edx,%edx
  801145:	e9 46 ff ff ff       	jmp    801090 <__udivdi3+0x50>
  80114a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801150:	8d 46 ff             	lea    -0x1(%esi),%eax
  801153:	31 d2                	xor    %edx,%edx
  801155:	8b 74 24 10          	mov    0x10(%esp),%esi
  801159:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80115d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801161:	83 c4 1c             	add    $0x1c,%esp
  801164:	c3                   	ret    
	...

00801170 <__umoddi3>:
  801170:	83 ec 1c             	sub    $0x1c,%esp
  801173:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801177:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80117b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80117f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801183:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801187:	8b 74 24 24          	mov    0x24(%esp),%esi
  80118b:	85 ed                	test   %ebp,%ebp
  80118d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801191:	89 44 24 08          	mov    %eax,0x8(%esp)
  801195:	89 cf                	mov    %ecx,%edi
  801197:	89 04 24             	mov    %eax,(%esp)
  80119a:	89 f2                	mov    %esi,%edx
  80119c:	75 1a                	jne    8011b8 <__umoddi3+0x48>
  80119e:	39 f1                	cmp    %esi,%ecx
  8011a0:	76 4e                	jbe    8011f0 <__umoddi3+0x80>
  8011a2:	f7 f1                	div    %ecx
  8011a4:	89 d0                	mov    %edx,%eax
  8011a6:	31 d2                	xor    %edx,%edx
  8011a8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011b4:	83 c4 1c             	add    $0x1c,%esp
  8011b7:	c3                   	ret    
  8011b8:	39 f5                	cmp    %esi,%ebp
  8011ba:	77 54                	ja     801210 <__umoddi3+0xa0>
  8011bc:	0f bd c5             	bsr    %ebp,%eax
  8011bf:	83 f0 1f             	xor    $0x1f,%eax
  8011c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c6:	75 60                	jne    801228 <__umoddi3+0xb8>
  8011c8:	3b 0c 24             	cmp    (%esp),%ecx
  8011cb:	0f 87 07 01 00 00    	ja     8012d8 <__umoddi3+0x168>
  8011d1:	89 f2                	mov    %esi,%edx
  8011d3:	8b 34 24             	mov    (%esp),%esi
  8011d6:	29 ce                	sub    %ecx,%esi
  8011d8:	19 ea                	sbb    %ebp,%edx
  8011da:	89 34 24             	mov    %esi,(%esp)
  8011dd:	8b 04 24             	mov    (%esp),%eax
  8011e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ec:	83 c4 1c             	add    $0x1c,%esp
  8011ef:	c3                   	ret    
  8011f0:	85 c9                	test   %ecx,%ecx
  8011f2:	75 0b                	jne    8011ff <__umoddi3+0x8f>
  8011f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f9:	31 d2                	xor    %edx,%edx
  8011fb:	f7 f1                	div    %ecx
  8011fd:	89 c1                	mov    %eax,%ecx
  8011ff:	89 f0                	mov    %esi,%eax
  801201:	31 d2                	xor    %edx,%edx
  801203:	f7 f1                	div    %ecx
  801205:	8b 04 24             	mov    (%esp),%eax
  801208:	f7 f1                	div    %ecx
  80120a:	eb 98                	jmp    8011a4 <__umoddi3+0x34>
  80120c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801210:	89 f2                	mov    %esi,%edx
  801212:	8b 74 24 10          	mov    0x10(%esp),%esi
  801216:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80121a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80121e:	83 c4 1c             	add    $0x1c,%esp
  801221:	c3                   	ret    
  801222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801228:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80122d:	89 e8                	mov    %ebp,%eax
  80122f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801234:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801238:	89 fa                	mov    %edi,%edx
  80123a:	d3 e0                	shl    %cl,%eax
  80123c:	89 e9                	mov    %ebp,%ecx
  80123e:	d3 ea                	shr    %cl,%edx
  801240:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801245:	09 c2                	or     %eax,%edx
  801247:	8b 44 24 08          	mov    0x8(%esp),%eax
  80124b:	89 14 24             	mov    %edx,(%esp)
  80124e:	89 f2                	mov    %esi,%edx
  801250:	d3 e7                	shl    %cl,%edi
  801252:	89 e9                	mov    %ebp,%ecx
  801254:	d3 ea                	shr    %cl,%edx
  801256:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80125b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80125f:	d3 e6                	shl    %cl,%esi
  801261:	89 e9                	mov    %ebp,%ecx
  801263:	d3 e8                	shr    %cl,%eax
  801265:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126a:	09 f0                	or     %esi,%eax
  80126c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801270:	f7 34 24             	divl   (%esp)
  801273:	d3 e6                	shl    %cl,%esi
  801275:	89 74 24 08          	mov    %esi,0x8(%esp)
  801279:	89 d6                	mov    %edx,%esi
  80127b:	f7 e7                	mul    %edi
  80127d:	39 d6                	cmp    %edx,%esi
  80127f:	89 c1                	mov    %eax,%ecx
  801281:	89 d7                	mov    %edx,%edi
  801283:	72 3f                	jb     8012c4 <__umoddi3+0x154>
  801285:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801289:	72 35                	jb     8012c0 <__umoddi3+0x150>
  80128b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80128f:	29 c8                	sub    %ecx,%eax
  801291:	19 fe                	sbb    %edi,%esi
  801293:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801298:	89 f2                	mov    %esi,%edx
  80129a:	d3 e8                	shr    %cl,%eax
  80129c:	89 e9                	mov    %ebp,%ecx
  80129e:	d3 e2                	shl    %cl,%edx
  8012a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012a5:	09 d0                	or     %edx,%eax
  8012a7:	89 f2                	mov    %esi,%edx
  8012a9:	d3 ea                	shr    %cl,%edx
  8012ab:	8b 74 24 10          	mov    0x10(%esp),%esi
  8012af:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012b7:	83 c4 1c             	add    $0x1c,%esp
  8012ba:	c3                   	ret    
  8012bb:	90                   	nop
  8012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	39 d6                	cmp    %edx,%esi
  8012c2:	75 c7                	jne    80128b <__umoddi3+0x11b>
  8012c4:	89 d7                	mov    %edx,%edi
  8012c6:	89 c1                	mov    %eax,%ecx
  8012c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012cc:	1b 3c 24             	sbb    (%esp),%edi
  8012cf:	eb ba                	jmp    80128b <__umoddi3+0x11b>
  8012d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	39 f5                	cmp    %esi,%ebp
  8012da:	0f 82 f1 fe ff ff    	jb     8011d1 <__umoddi3+0x61>
  8012e0:	e9 f8 fe ff ff       	jmp    8011dd <__umoddi3+0x6d>
