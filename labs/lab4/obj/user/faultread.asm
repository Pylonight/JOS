
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 12 80 00 	movl   $0x801200,(%esp)
  80004a:	e8 0c 01 00 00       	call   80015b <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  800066:	e8 4d 0b 00 00       	call   800bb8 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 a5 0a 00 00       	call   800b5b <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 14             	sub    $0x14,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 03                	mov    (%ebx),%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000cb:	83 c0 01             	add    $0x1,%eax
  8000ce:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 19                	jne    8000f0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000de:	00 
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	89 04 24             	mov    %eax,(%esp)
  8000e5:	e8 12 0a 00 00       	call   800afc <sys_cputs>
		b->idx = 0;
  8000ea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000f0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f4:	83 c4 14             	add    $0x14,%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011e:	8b 45 08             	mov    0x8(%ebp),%eax
  800121:	89 44 24 08          	mov    %eax,0x8(%esp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012f:	c7 04 24 b8 00 80 00 	movl   $0x8000b8,(%esp)
  800136:	e8 d9 01 00 00       	call   800314 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800141:	89 44 24 04          	mov    %eax,0x4(%esp)
  800145:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014b:	89 04 24             	mov    %eax,(%esp)
  80014e:	e8 a9 09 00 00       	call   800afc <sys_cputs>

	return b.cnt;
}
  800153:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800161:	8d 45 0c             	lea    0xc(%ebp),%eax
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	8b 45 08             	mov    0x8(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 87 ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  800173:	c9                   	leave  
  800174:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 3c             	sub    $0x3c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d7                	mov    %edx,%edi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800194:	8b 45 0c             	mov    0xc(%ebp),%eax
  800197:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80019d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001a8:	72 11                	jb     8001bb <printnum+0x3b>
  8001aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b0:	76 09                	jbe    8001bb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b2:	83 eb 01             	sub    $0x1,%ebx
  8001b5:	85 db                	test   %ebx,%ebx
  8001b7:	7f 51                	jg     80020a <printnum+0x8a>
  8001b9:	eb 5e                	jmp    800219 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001bf:	83 eb 01             	sub    $0x1,%ebx
  8001c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001d1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001dc:	00 
  8001dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ea:	e8 61 0d 00 00       	call   800f50 <__udivdi3>
  8001ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fe:	89 fa                	mov    %edi,%edx
  800200:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800203:	e8 78 ff ff ff       	call   800180 <printnum>
  800208:	eb 0f                	jmp    800219 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020e:	89 34 24             	mov    %esi,(%esp)
  800211:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800214:	83 eb 01             	sub    $0x1,%ebx
  800217:	75 f1                	jne    80020a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800219:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800221:	8b 45 10             	mov    0x10(%ebp),%eax
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022f:	00 
  800230:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	e8 3e 0e 00 00       	call   801080 <__umoddi3>
  800242:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800246:	0f be 80 35 12 80 00 	movsbl 0x801235(%eax),%eax
  80024d:	89 04 24             	mov    %eax,(%esp)
  800250:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800253:	83 c4 3c             	add    $0x3c,%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025e:	83 fa 01             	cmp    $0x1,%edx
  800261:	7e 0e                	jle    800271 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800263:	8b 10                	mov    (%eax),%edx
  800265:	8d 4a 08             	lea    0x8(%edx),%ecx
  800268:	89 08                	mov    %ecx,(%eax)
  80026a:	8b 02                	mov    (%edx),%eax
  80026c:	8b 52 04             	mov    0x4(%edx),%edx
  80026f:	eb 22                	jmp    800293 <getuint+0x38>
	else if (lflag)
  800271:	85 d2                	test   %edx,%edx
  800273:	74 10                	je     800285 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800275:	8b 10                	mov    (%eax),%edx
  800277:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027a:	89 08                	mov    %ecx,(%eax)
  80027c:	8b 02                	mov    (%edx),%eax
  80027e:	ba 00 00 00 00       	mov    $0x0,%edx
  800283:	eb 0e                	jmp    800293 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800298:	83 fa 01             	cmp    $0x1,%edx
  80029b:	7e 0e                	jle    8002ab <getint+0x16>
		return va_arg(*ap, long long);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	8b 52 04             	mov    0x4(%edx),%edx
  8002a9:	eb 22                	jmp    8002cd <getint+0x38>
	else if (lflag)
  8002ab:	85 d2                	test   %edx,%edx
  8002ad:	74 10                	je     8002bf <getint+0x2a>
		return va_arg(*ap, long);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	89 c2                	mov    %eax,%edx
  8002ba:	c1 fa 1f             	sar    $0x1f,%edx
  8002bd:	eb 0e                	jmp    8002cd <getint+0x38>
	else
		return va_arg(*ap, int);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	89 c2                	mov    %eax,%edx
  8002ca:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	3b 50 04             	cmp    0x4(%eax),%edx
  8002de:	73 0a                	jae    8002ea <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e3:	88 0a                	mov    %cl,(%edx)
  8002e5:	83 c2 01             	add    $0x1,%edx
  8002e8:	89 10                	mov    %edx,(%eax)
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8002f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
  800303:	89 44 24 04          	mov    %eax,0x4(%esp)
  800307:	8b 45 08             	mov    0x8(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	e8 02 00 00 00       	call   800314 <vprintfmt>
	va_end(ap);
}
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 4c             	sub    $0x4c,%esp
  80031d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800320:	8b 75 10             	mov    0x10(%ebp),%esi
  800323:	eb 12                	jmp    800337 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800325:	85 c0                	test   %eax,%eax
  800327:	0f 84 98 03 00 00    	je     8006c5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80032d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800331:	89 04 24             	mov    %eax,(%esp)
  800334:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800337:	0f b6 06             	movzbl (%esi),%eax
  80033a:	83 c6 01             	add    $0x1,%esi
  80033d:	83 f8 25             	cmp    $0x25,%eax
  800340:	75 e3                	jne    800325 <vprintfmt+0x11>
  800342:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800346:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80034d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800352:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800359:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800361:	eb 2b                	jmp    80038e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800366:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80036a:	eb 22                	jmp    80038e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800373:	eb 19                	jmp    80038e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800378:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80037f:	eb 0d                	jmp    80038e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800381:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	0f b6 06             	movzbl (%esi),%eax
  800391:	0f b6 d0             	movzbl %al,%edx
  800394:	8d 7e 01             	lea    0x1(%esi),%edi
  800397:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80039a:	83 e8 23             	sub    $0x23,%eax
  80039d:	3c 55                	cmp    $0x55,%al
  80039f:	0f 87 fa 02 00 00    	ja     80069f <vprintfmt+0x38b>
  8003a5:	0f b6 c0             	movzbl %al,%eax
  8003a8:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003af:	83 ea 30             	sub    $0x30,%edx
  8003b2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003b5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003b9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003bf:	83 fa 09             	cmp    $0x9,%edx
  8003c2:	77 4a                	ja     80040e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003ca:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003cd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003d1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d7:	83 fa 09             	cmp    $0x9,%edx
  8003da:	76 eb                	jbe    8003c7 <vprintfmt+0xb3>
  8003dc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003df:	eb 2d                	jmp    80040e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 50 04             	lea    0x4(%eax),%edx
  8003e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f2:	eb 1a                	jmp    80040e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fb:	79 91                	jns    80038e <vprintfmt+0x7a>
  8003fd:	e9 73 ff ff ff       	jmp    800375 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800405:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80040c:	eb 80                	jmp    80038e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80040e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800412:	0f 89 76 ff ff ff    	jns    80038e <vprintfmt+0x7a>
  800418:	e9 64 ff ff ff       	jmp    800381 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800423:	e9 66 ff ff ff       	jmp    80038e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800435:	8b 00                	mov    (%eax),%eax
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800440:	e9 f2 fe ff ff       	jmp    800337 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 c2                	mov    %eax,%edx
  800452:	c1 fa 1f             	sar    $0x1f,%edx
  800455:	31 d0                	xor    %edx,%eax
  800457:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800459:	83 f8 08             	cmp    $0x8,%eax
  80045c:	7f 0b                	jg     800469 <vprintfmt+0x155>
  80045e:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800465:	85 d2                	test   %edx,%edx
  800467:	75 23                	jne    80048c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800469:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046d:	c7 44 24 08 4d 12 80 	movl   $0x80124d,0x8(%esp)
  800474:	00 
  800475:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800479:	8b 7d 08             	mov    0x8(%ebp),%edi
  80047c:	89 3c 24             	mov    %edi,(%esp)
  80047f:	e8 68 fe ff ff       	call   8002ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800487:	e9 ab fe ff ff       	jmp    800337 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80048c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800490:	c7 44 24 08 56 12 80 	movl   $0x801256,0x8(%esp)
  800497:	00 
  800498:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80049f:	89 3c 24             	mov    %edi,(%esp)
  8004a2:	e8 45 fe ff ff       	call   8002ec <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004aa:	e9 88 fe ff ff       	jmp    800337 <vprintfmt+0x23>
  8004af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004c3:	85 f6                	test   %esi,%esi
  8004c5:	ba 46 12 80 00       	mov    $0x801246,%edx
  8004ca:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004cd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004d1:	7e 06                	jle    8004d9 <vprintfmt+0x1c5>
  8004d3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004d7:	75 10                	jne    8004e9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d9:	0f be 06             	movsbl (%esi),%eax
  8004dc:	83 c6 01             	add    $0x1,%esi
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	0f 85 86 00 00 00    	jne    80056d <vprintfmt+0x259>
  8004e7:	eb 76                	jmp    80055f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ed:	89 34 24             	mov    %esi,(%esp)
  8004f0:	e8 76 02 00 00       	call   80076b <strnlen>
  8004f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004f8:	29 c2                	sub    %eax,%edx
  8004fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004fd:	85 d2                	test   %edx,%edx
  8004ff:	7e d8                	jle    8004d9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800501:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800505:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800508:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80050b:	89 d6                	mov    %edx,%esi
  80050d:	89 c7                	mov    %eax,%edi
  80050f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800513:	89 3c 24             	mov    %edi,(%esp)
  800516:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800519:	83 ee 01             	sub    $0x1,%esi
  80051c:	75 f1                	jne    80050f <vprintfmt+0x1fb>
  80051e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800521:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800524:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800527:	eb b0                	jmp    8004d9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80052d:	74 18                	je     800547 <vprintfmt+0x233>
  80052f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800532:	83 fa 5e             	cmp    $0x5e,%edx
  800535:	76 10                	jbe    800547 <vprintfmt+0x233>
					putch('?', putdat);
  800537:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	eb 0a                	jmp    800551 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800547:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054b:	89 04 24             	mov    %eax,(%esp)
  80054e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800551:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800555:	0f be 06             	movsbl (%esi),%eax
  800558:	83 c6 01             	add    $0x1,%esi
  80055b:	85 c0                	test   %eax,%eax
  80055d:	75 0e                	jne    80056d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800562:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800566:	7f 11                	jg     800579 <vprintfmt+0x265>
  800568:	e9 ca fd ff ff       	jmp    800337 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056d:	85 ff                	test   %edi,%edi
  80056f:	90                   	nop
  800570:	78 b7                	js     800529 <vprintfmt+0x215>
  800572:	83 ef 01             	sub    $0x1,%edi
  800575:	79 b2                	jns    800529 <vprintfmt+0x215>
  800577:	eb e6                	jmp    80055f <vprintfmt+0x24b>
  800579:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80057c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800583:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80058a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058c:	83 ee 01             	sub    $0x1,%esi
  80058f:	75 ee                	jne    80057f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800591:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800594:	e9 9e fd ff ff       	jmp    800337 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800599:	89 ca                	mov    %ecx,%edx
  80059b:	8d 45 14             	lea    0x14(%ebp),%eax
  80059e:	e8 f2 fc ff ff       	call   800295 <getint>
  8005a3:	89 c6                	mov    %eax,%esi
  8005a5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ac:	85 d2                	test   %edx,%edx
  8005ae:	0f 89 ad 00 00 00    	jns    800661 <vprintfmt+0x34d>
				putch('-', putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c2:	f7 de                	neg    %esi
  8005c4:	83 d7 00             	adc    $0x0,%edi
  8005c7:	f7 df                	neg    %edi
			}
			base = 10;
  8005c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ce:	e9 8e 00 00 00       	jmp    800661 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d3:	89 ca                	mov    %ecx,%edx
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 7e fc ff ff       	call   80025b <getuint>
  8005dd:	89 c6                	mov    %eax,%esi
  8005df:	89 d7                	mov    %edx,%edi
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005e6:	eb 79                	jmp    800661 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  8005e8:	89 ca                	mov    %ecx,%edx
  8005ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ed:	e8 a3 fc ff ff       	call   800295 <getint>
  8005f2:	89 c6                	mov    %eax,%esi
  8005f4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8005f6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	79 62                	jns    800661 <vprintfmt+0x34d>
				putch('-', putdat);
  8005ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800603:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80060d:	f7 de                	neg    %esi
  80060f:	83 d7 00             	adc    $0x0,%edi
  800612:	f7 df                	neg    %edi
			}
			base = 8;
  800614:	b8 08 00 00 00       	mov    $0x8,%eax
  800619:	eb 46                	jmp    800661 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80061b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800626:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800629:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800634:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 04             	lea    0x4(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800640:	8b 30                	mov    (%eax),%esi
  800642:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064c:	eb 13                	jmp    800661 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064e:	89 ca                	mov    %ecx,%edx
  800650:	8d 45 14             	lea    0x14(%ebp),%eax
  800653:	e8 03 fc ff ff       	call   80025b <getuint>
  800658:	89 c6                	mov    %eax,%esi
  80065a:	89 d7                	mov    %edx,%edi
			base = 16;
  80065c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800661:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800665:	89 54 24 10          	mov    %edx,0x10(%esp)
  800669:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800670:	89 44 24 08          	mov    %eax,0x8(%esp)
  800674:	89 34 24             	mov    %esi,(%esp)
  800677:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067b:	89 da                	mov    %ebx,%edx
  80067d:	8b 45 08             	mov    0x8(%ebp),%eax
  800680:	e8 fb fa ff ff       	call   800180 <printnum>
			break;
  800685:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800688:	e9 aa fc ff ff       	jmp    800337 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800691:	89 14 24             	mov    %edx,(%esp)
  800694:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80069a:	e9 98 fc ff ff       	jmp    800337 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80069f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006aa:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ad:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006b1:	0f 84 80 fc ff ff    	je     800337 <vprintfmt+0x23>
  8006b7:	83 ee 01             	sub    $0x1,%esi
  8006ba:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006be:	75 f7                	jne    8006b7 <vprintfmt+0x3a3>
  8006c0:	e9 72 fc ff ff       	jmp    800337 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006c5:	83 c4 4c             	add    $0x4c,%esp
  8006c8:	5b                   	pop    %ebx
  8006c9:	5e                   	pop    %esi
  8006ca:	5f                   	pop    %edi
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 28             	sub    $0x28,%esp
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	74 30                	je     80071e <vsnprintf+0x51>
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	7e 2c                	jle    80071e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800700:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800703:	89 44 24 04          	mov    %eax,0x4(%esp)
  800707:	c7 04 24 cf 02 80 00 	movl   $0x8002cf,(%esp)
  80070e:	e8 01 fc ff ff       	call   800314 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800713:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800716:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071c:	eb 05                	jmp    800723 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800732:	8b 45 10             	mov    0x10(%ebp),%eax
  800735:	89 44 24 08          	mov    %eax,0x8(%esp)
  800739:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	89 04 24             	mov    %eax,(%esp)
  800746:	e8 82 ff ff ff       	call   8006cd <vsnprintf>
	va_end(ap);

	return rc;
}
  80074b:	c9                   	leave  
  80074c:	c3                   	ret    
  80074d:	00 00                	add    %al,(%eax)
	...

00800750 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	80 3a 00             	cmpb   $0x0,(%edx)
  80075e:	74 09                	je     800769 <strlen+0x19>
		n++;
  800760:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800767:	75 f7                	jne    800760 <strlen+0x10>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	85 c9                	test   %ecx,%ecx
  80077c:	74 1a                	je     800798 <strnlen+0x2d>
  80077e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800781:	74 15                	je     800798 <strnlen+0x2d>
  800783:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800788:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	39 ca                	cmp    %ecx,%edx
  80078c:	74 0a                	je     800798 <strnlen+0x2d>
  80078e:	83 c2 01             	add    $0x1,%edx
  800791:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800796:	75 f0                	jne    800788 <strnlen+0x1d>
		n++;
	return n;
}
  800798:	5b                   	pop    %ebx
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007aa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007ae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007b1:	83 c2 01             	add    $0x1,%edx
  8007b4:	84 c9                	test   %cl,%cl
  8007b6:	75 f2                	jne    8007aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b8:	5b                   	pop    %ebx
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	85 f6                	test   %esi,%esi
  8007cb:	74 18                	je     8007e5 <strncpy+0x2a>
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007d2:	0f b6 1a             	movzbl (%edx),%ebx
  8007d5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d8:	80 3a 01             	cmpb   $0x1,(%edx)
  8007db:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007de:	83 c1 01             	add    $0x1,%ecx
  8007e1:	39 f1                	cmp    %esi,%ecx
  8007e3:	75 ed                	jne    8007d2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	57                   	push   %edi
  8007ed:	56                   	push   %esi
  8007ee:	53                   	push   %ebx
  8007ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	89 f8                	mov    %edi,%eax
  8007fa:	85 f6                	test   %esi,%esi
  8007fc:	74 2b                	je     800829 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8007fe:	83 fe 01             	cmp    $0x1,%esi
  800801:	74 23                	je     800826 <strlcpy+0x3d>
  800803:	0f b6 0b             	movzbl (%ebx),%ecx
  800806:	84 c9                	test   %cl,%cl
  800808:	74 1c                	je     800826 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80080a:	83 ee 02             	sub    $0x2,%esi
  80080d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800812:	88 08                	mov    %cl,(%eax)
  800814:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800817:	39 f2                	cmp    %esi,%edx
  800819:	74 0b                	je     800826 <strlcpy+0x3d>
  80081b:	83 c2 01             	add    $0x1,%edx
  80081e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800822:	84 c9                	test   %cl,%cl
  800824:	75 ec                	jne    800812 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800826:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800829:	29 f8                	sub    %edi,%eax
}
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5f                   	pop    %edi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800839:	0f b6 01             	movzbl (%ecx),%eax
  80083c:	84 c0                	test   %al,%al
  80083e:	74 16                	je     800856 <strcmp+0x26>
  800840:	3a 02                	cmp    (%edx),%al
  800842:	75 12                	jne    800856 <strcmp+0x26>
		p++, q++;
  800844:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800847:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80084b:	84 c0                	test   %al,%al
  80084d:	74 07                	je     800856 <strcmp+0x26>
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	3a 02                	cmp    (%edx),%al
  800854:	74 ee                	je     800844 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800856:	0f b6 c0             	movzbl %al,%eax
  800859:	0f b6 12             	movzbl (%edx),%edx
  80085c:	29 d0                	sub    %edx,%eax
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	53                   	push   %ebx
  800864:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800867:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800872:	85 d2                	test   %edx,%edx
  800874:	74 28                	je     80089e <strncmp+0x3e>
  800876:	0f b6 01             	movzbl (%ecx),%eax
  800879:	84 c0                	test   %al,%al
  80087b:	74 24                	je     8008a1 <strncmp+0x41>
  80087d:	3a 03                	cmp    (%ebx),%al
  80087f:	75 20                	jne    8008a1 <strncmp+0x41>
  800881:	83 ea 01             	sub    $0x1,%edx
  800884:	74 13                	je     800899 <strncmp+0x39>
		n--, p++, q++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088c:	0f b6 01             	movzbl (%ecx),%eax
  80088f:	84 c0                	test   %al,%al
  800891:	74 0e                	je     8008a1 <strncmp+0x41>
  800893:	3a 03                	cmp    (%ebx),%al
  800895:	74 ea                	je     800881 <strncmp+0x21>
  800897:	eb 08                	jmp    8008a1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 01             	movzbl (%ecx),%eax
  8008a4:	0f b6 13             	movzbl (%ebx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
  8008a9:	eb f3                	jmp    80089e <strncmp+0x3e>

008008ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b5:	0f b6 10             	movzbl (%eax),%edx
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	74 1c                	je     8008d8 <strchr+0x2d>
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	75 09                	jne    8008c9 <strchr+0x1e>
  8008c0:	eb 1b                	jmp    8008dd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8008c5:	38 ca                	cmp    %cl,%dl
  8008c7:	74 14                	je     8008dd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8008cd:	84 d2                	test   %dl,%dl
  8008cf:	75 f1                	jne    8008c2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb 05                	jmp    8008dd <strchr+0x32>
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	0f b6 10             	movzbl (%eax),%edx
  8008ec:	84 d2                	test   %dl,%dl
  8008ee:	74 14                	je     800904 <strfind+0x25>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	75 06                	jne    8008fa <strfind+0x1b>
  8008f4:	eb 0e                	jmp    800904 <strfind+0x25>
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 0a                	je     800904 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 10             	movzbl (%eax),%edx
  800900:	84 d2                	test   %dl,%dl
  800902:	75 f2                	jne    8008f6 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800910:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800913:	89 da                	mov    %ebx,%edx
  800915:	83 ea 01             	sub    $0x1,%edx
  800918:	78 0d                	js     800927 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80091a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  80091c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  80091e:	88 0a                	mov    %cl,(%edx)
  800920:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800923:	39 da                	cmp    %ebx,%edx
  800925:	75 f7                	jne    80091e <memset+0x18>
		*p++ = c;

	return v;
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 75 0c             	mov    0xc(%ebp),%esi
  800936:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800939:	39 c6                	cmp    %eax,%esi
  80093b:	72 0b                	jb     800948 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  80093d:	ba 00 00 00 00       	mov    $0x0,%edx
  800942:	85 db                	test   %ebx,%ebx
  800944:	75 29                	jne    80096f <memmove+0x45>
  800946:	eb 35                	jmp    80097d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800948:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  80094b:	39 c8                	cmp    %ecx,%eax
  80094d:	73 ee                	jae    80093d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  80094f:	85 db                	test   %ebx,%ebx
  800951:	74 2a                	je     80097d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800953:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800956:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800958:	f7 db                	neg    %ebx
  80095a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  80095d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  80095f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800964:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800968:	83 ea 01             	sub    $0x1,%edx
  80096b:	75 f2                	jne    80095f <memmove+0x35>
  80096d:	eb 0e                	jmp    80097d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  80096f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800973:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800976:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800979:	39 d3                	cmp    %edx,%ebx
  80097b:	75 f2                	jne    80096f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800988:	8b 45 10             	mov    0x10(%ebp),%eax
  80098b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800992:	89 44 24 04          	mov    %eax,0x4(%esp)
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	89 04 24             	mov    %eax,(%esp)
  80099c:	e8 89 ff ff ff       	call   80092a <memmove>
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009af:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	85 ff                	test   %edi,%edi
  8009b9:	74 37                	je     8009f2 <memcmp+0x4f>
		if (*s1 != *s2)
  8009bb:	0f b6 03             	movzbl (%ebx),%eax
  8009be:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c1:	83 ef 01             	sub    $0x1,%edi
  8009c4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8009c9:	38 c8                	cmp    %cl,%al
  8009cb:	74 1c                	je     8009e9 <memcmp+0x46>
  8009cd:	eb 10                	jmp    8009df <memcmp+0x3c>
  8009cf:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8009d4:	83 c2 01             	add    $0x1,%edx
  8009d7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009db:	38 c8                	cmp    %cl,%al
  8009dd:	74 0a                	je     8009e9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  8009df:	0f b6 c0             	movzbl %al,%eax
  8009e2:	0f b6 c9             	movzbl %cl,%ecx
  8009e5:	29 c8                	sub    %ecx,%eax
  8009e7:	eb 09                	jmp    8009f2 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e9:	39 fa                	cmp    %edi,%edx
  8009eb:	75 e2                	jne    8009cf <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009fd:	89 c2                	mov    %eax,%edx
  8009ff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	73 15                	jae    800a1b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a0a:	38 08                	cmp    %cl,(%eax)
  800a0c:	75 06                	jne    800a14 <memfind+0x1d>
  800a0e:	eb 0b                	jmp    800a1b <memfind+0x24>
  800a10:	38 08                	cmp    %cl,(%eax)
  800a12:	74 07                	je     800a1b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	39 d0                	cmp    %edx,%eax
  800a19:	75 f5                	jne    800a10 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a29:	0f b6 02             	movzbl (%edx),%eax
  800a2c:	3c 20                	cmp    $0x20,%al
  800a2e:	74 04                	je     800a34 <strtol+0x17>
  800a30:	3c 09                	cmp    $0x9,%al
  800a32:	75 0e                	jne    800a42 <strtol+0x25>
		s++;
  800a34:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a37:	0f b6 02             	movzbl (%edx),%eax
  800a3a:	3c 20                	cmp    $0x20,%al
  800a3c:	74 f6                	je     800a34 <strtol+0x17>
  800a3e:	3c 09                	cmp    $0x9,%al
  800a40:	74 f2                	je     800a34 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a42:	3c 2b                	cmp    $0x2b,%al
  800a44:	75 0a                	jne    800a50 <strtol+0x33>
		s++;
  800a46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4e:	eb 10                	jmp    800a60 <strtol+0x43>
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a55:	3c 2d                	cmp    $0x2d,%al
  800a57:	75 07                	jne    800a60 <strtol+0x43>
		s++, neg = 1;
  800a59:	83 c2 01             	add    $0x1,%edx
  800a5c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	0f 94 c0             	sete   %al
  800a65:	74 05                	je     800a6c <strtol+0x4f>
  800a67:	83 fb 10             	cmp    $0x10,%ebx
  800a6a:	75 15                	jne    800a81 <strtol+0x64>
  800a6c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6f:	75 10                	jne    800a81 <strtol+0x64>
  800a71:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a75:	75 0a                	jne    800a81 <strtol+0x64>
		s += 2, base = 16;
  800a77:	83 c2 02             	add    $0x2,%edx
  800a7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7f:	eb 13                	jmp    800a94 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800a81:	84 c0                	test   %al,%al
  800a83:	74 0f                	je     800a94 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8d:	75 05                	jne    800a94 <strtol+0x77>
		s++, base = 8;
  800a8f:	83 c2 01             	add    $0x1,%edx
  800a92:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
  800a99:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9b:	0f b6 0a             	movzbl (%edx),%ecx
  800a9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aa1:	80 fb 09             	cmp    $0x9,%bl
  800aa4:	77 08                	ja     800aae <strtol+0x91>
			dig = *s - '0';
  800aa6:	0f be c9             	movsbl %cl,%ecx
  800aa9:	83 e9 30             	sub    $0x30,%ecx
  800aac:	eb 1e                	jmp    800acc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800aae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 08                	ja     800abe <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ab6:	0f be c9             	movsbl %cl,%ecx
  800ab9:	83 e9 57             	sub    $0x57,%ecx
  800abc:	eb 0e                	jmp    800acc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 14                	ja     800ada <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac6:	0f be c9             	movsbl %cl,%ecx
  800ac9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800acc:	39 f1                	cmp    %esi,%ecx
  800ace:	7d 0e                	jge    800ade <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ad0:	83 c2 01             	add    $0x1,%edx
  800ad3:	0f af c6             	imul   %esi,%eax
  800ad6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ad8:	eb c1                	jmp    800a9b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	89 c1                	mov    %eax,%ecx
  800adc:	eb 02                	jmp    800ae0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ade:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae4:	74 05                	je     800aeb <strtol+0xce>
		*endptr = (char *) s;
  800ae6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aeb:	89 ca                	mov    %ecx,%edx
  800aed:	f7 da                	neg    %edx
  800aef:	85 ff                	test   %edi,%edi
  800af1:	0f 45 c2             	cmovne %edx,%eax
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    
  800af9:	00 00                	add    %al,(%eax)
	...

00800afc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b08:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	89 c3                	mov    %eax,%ebx
  800b18:	89 c7                	mov    %eax,%edi
  800b1a:	89 c6                	mov    %eax,%esi
  800b1c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b21:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b24:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b27:	89 ec                	mov    %ebp,%esp
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b37:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b51:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b54:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b57:	89 ec                	mov    %ebp,%esp
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	83 ec 38             	sub    $0x38,%esp
  800b61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b67:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	89 cb                	mov    %ecx,%ebx
  800b79:	89 cf                	mov    %ecx,%edi
  800b7b:	89 ce                	mov    %ecx,%esi
  800b7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 28                	jle    800bab <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b87:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b8e:	00 
  800b8f:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800b96:	00 
  800b97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9e:	00 
  800b9f:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800ba6:	e8 35 03 00 00       	call   800ee0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bb1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bb4:	89 ec                	mov    %ebp,%esp
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bc1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bc4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd1:	89 d1                	mov    %edx,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	89 d7                	mov    %edx,%edi
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bde:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800be1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800be4:	89 ec                	mov    %ebp,%esp
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sys_yield>:

void
sys_yield(void)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bf1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bf4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c14:	89 ec                	mov    %ebp,%esp
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 38             	sub    $0x38,%esp
  800c1e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c21:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c24:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	be 00 00 00 00       	mov    $0x0,%esi
  800c2c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	89 f7                	mov    %esi,%edi
  800c3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 28                	jle    800c6a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c46:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c4d:	00 
  800c4e:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800c55:	00 
  800c56:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5d:	00 
  800c5e:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800c65:	e8 76 02 00 00       	call   800ee0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c6d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c70:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c73:	89 ec                	mov    %ebp,%esp
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	83 ec 38             	sub    $0x38,%esp
  800c7d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c80:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c83:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 28                	jle    800cc8 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cab:	00 
  800cac:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800cb3:	00 
  800cb4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cbb:	00 
  800cbc:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800cc3:	e8 18 02 00 00       	call   800ee0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ccb:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cce:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cd1:	89 ec                	mov    %ebp,%esp
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 38             	sub    $0x38,%esp
  800cdb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cde:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ce1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 28                	jle    800d26 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d02:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d09:	00 
  800d0a:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800d11:	00 
  800d12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d19:	00 
  800d1a:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800d21:	e8 ba 01 00 00       	call   800ee0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d26:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d29:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d2c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2f:	89 ec                	mov    %ebp,%esp
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 38             	sub    $0x38,%esp
  800d39:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d47:	b8 08 00 00 00       	mov    $0x8,%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	89 df                	mov    %ebx,%edi
  800d54:	89 de                	mov    %ebx,%esi
  800d56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7e 28                	jle    800d84 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d60:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d67:	00 
  800d68:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800d6f:	00 
  800d70:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d77:	00 
  800d78:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800d7f:	e8 5c 01 00 00       	call   800ee0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8d:	89 ec                	mov    %ebp,%esp
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 38             	sub    $0x38,%esp
  800d97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da5:	b8 09 00 00 00       	mov    $0x9,%eax
  800daa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	89 df                	mov    %ebx,%edi
  800db2:	89 de                	mov    %ebx,%esi
  800db4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7e 28                	jle    800de2 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dba:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbe:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dc5:	00 
  800dc6:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800dcd:	00 
  800dce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd5:	00 
  800dd6:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800ddd:	e8 fe 00 00 00       	call   800ee0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800deb:	89 ec                	mov    %ebp,%esp
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 38             	sub    $0x38,%esp
  800df5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	89 df                	mov    %ebx,%edi
  800e10:	89 de                	mov    %ebx,%esi
  800e12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 28                	jle    800e40 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e23:	00 
  800e24:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e33:	00 
  800e34:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800e3b:	e8 a0 00 00 00       	call   800ee0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e40:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e43:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e46:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e49:	89 ec                	mov    %ebp,%esp
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e56:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e59:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5c:	be 00 00 00 00       	mov    $0x0,%esi
  800e61:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e74:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e77:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7d:	89 ec                	mov    %ebp,%esp
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800e90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	89 cb                	mov    %ecx,%ebx
  800e9f:	89 cf                	mov    %ecx,%edi
  800ea1:	89 ce                	mov    %ecx,%esi
  800ea3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	7e 28                	jle    800ed1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ead:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 08 84 14 80 	movl   $0x801484,0x8(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec4:	00 
  800ec5:	c7 04 24 a1 14 80 00 	movl   $0x8014a1,(%esp)
  800ecc:	e8 0f 00 00 00       	call   800ee0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eda:	89 ec                	mov    %ebp,%esp
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    
	...

00800ee0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800ee6:	a1 08 20 80 00       	mov    0x802008,%eax
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	74 10                	je     800eff <_panic+0x1f>
		cprintf("%s: ", argv0);
  800eef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef3:	c7 04 24 af 14 80 00 	movl   $0x8014af,(%esp)
  800efa:	e8 5c f2 ff ff       	call   80015b <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f06:	8b 45 08             	mov    0x8(%ebp),%eax
  800f09:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0d:	a1 00 20 80 00       	mov    0x802000,%eax
  800f12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f16:	c7 04 24 b4 14 80 00 	movl   $0x8014b4,(%esp)
  800f1d:	e8 39 f2 ff ff       	call   80015b <cprintf>
	vcprintf(fmt, ap);
  800f22:	8d 45 14             	lea    0x14(%ebp),%eax
  800f25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f29:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2c:	89 04 24             	mov    %eax,(%esp)
  800f2f:	e8 c6 f1 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800f34:	c7 04 24 1c 12 80 00 	movl   $0x80121c,(%esp)
  800f3b:	e8 1b f2 ff ff       	call   80015b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f40:	cc                   	int3   
  800f41:	eb fd                	jmp    800f40 <_panic+0x60>
	...

00800f50 <__udivdi3>:
  800f50:	83 ec 1c             	sub    $0x1c,%esp
  800f53:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f57:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f5b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f5f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f63:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f67:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f6b:	85 ff                	test   %edi,%edi
  800f6d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f75:	89 cd                	mov    %ecx,%ebp
  800f77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7b:	75 33                	jne    800fb0 <__udivdi3+0x60>
  800f7d:	39 f1                	cmp    %esi,%ecx
  800f7f:	77 57                	ja     800fd8 <__udivdi3+0x88>
  800f81:	85 c9                	test   %ecx,%ecx
  800f83:	75 0b                	jne    800f90 <__udivdi3+0x40>
  800f85:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8a:	31 d2                	xor    %edx,%edx
  800f8c:	f7 f1                	div    %ecx
  800f8e:	89 c1                	mov    %eax,%ecx
  800f90:	89 f0                	mov    %esi,%eax
  800f92:	31 d2                	xor    %edx,%edx
  800f94:	f7 f1                	div    %ecx
  800f96:	89 c6                	mov    %eax,%esi
  800f98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f9c:	f7 f1                	div    %ecx
  800f9e:	89 f2                	mov    %esi,%edx
  800fa0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fa4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fa8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fac:	83 c4 1c             	add    $0x1c,%esp
  800faf:	c3                   	ret    
  800fb0:	31 d2                	xor    %edx,%edx
  800fb2:	31 c0                	xor    %eax,%eax
  800fb4:	39 f7                	cmp    %esi,%edi
  800fb6:	77 e8                	ja     800fa0 <__udivdi3+0x50>
  800fb8:	0f bd cf             	bsr    %edi,%ecx
  800fbb:	83 f1 1f             	xor    $0x1f,%ecx
  800fbe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fc2:	75 2c                	jne    800ff0 <__udivdi3+0xa0>
  800fc4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fc8:	76 04                	jbe    800fce <__udivdi3+0x7e>
  800fca:	39 f7                	cmp    %esi,%edi
  800fcc:	73 d2                	jae    800fa0 <__udivdi3+0x50>
  800fce:	31 d2                	xor    %edx,%edx
  800fd0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd5:	eb c9                	jmp    800fa0 <__udivdi3+0x50>
  800fd7:	90                   	nop
  800fd8:	89 f2                	mov    %esi,%edx
  800fda:	f7 f1                	div    %ecx
  800fdc:	31 d2                	xor    %edx,%edx
  800fde:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fe2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fe6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fea:	83 c4 1c             	add    $0x1c,%esp
  800fed:	c3                   	ret    
  800fee:	66 90                	xchg   %ax,%ax
  800ff0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ff5:	b8 20 00 00 00       	mov    $0x20,%eax
  800ffa:	89 ea                	mov    %ebp,%edx
  800ffc:	2b 44 24 04          	sub    0x4(%esp),%eax
  801000:	d3 e7                	shl    %cl,%edi
  801002:	89 c1                	mov    %eax,%ecx
  801004:	d3 ea                	shr    %cl,%edx
  801006:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100b:	09 fa                	or     %edi,%edx
  80100d:	89 f7                	mov    %esi,%edi
  80100f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801013:	89 f2                	mov    %esi,%edx
  801015:	8b 74 24 08          	mov    0x8(%esp),%esi
  801019:	d3 e5                	shl    %cl,%ebp
  80101b:	89 c1                	mov    %eax,%ecx
  80101d:	d3 ef                	shr    %cl,%edi
  80101f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801024:	d3 e2                	shl    %cl,%edx
  801026:	89 c1                	mov    %eax,%ecx
  801028:	d3 ee                	shr    %cl,%esi
  80102a:	09 d6                	or     %edx,%esi
  80102c:	89 fa                	mov    %edi,%edx
  80102e:	89 f0                	mov    %esi,%eax
  801030:	f7 74 24 0c          	divl   0xc(%esp)
  801034:	89 d7                	mov    %edx,%edi
  801036:	89 c6                	mov    %eax,%esi
  801038:	f7 e5                	mul    %ebp
  80103a:	39 d7                	cmp    %edx,%edi
  80103c:	72 22                	jb     801060 <__udivdi3+0x110>
  80103e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801042:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801047:	d3 e5                	shl    %cl,%ebp
  801049:	39 c5                	cmp    %eax,%ebp
  80104b:	73 04                	jae    801051 <__udivdi3+0x101>
  80104d:	39 d7                	cmp    %edx,%edi
  80104f:	74 0f                	je     801060 <__udivdi3+0x110>
  801051:	89 f0                	mov    %esi,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	e9 46 ff ff ff       	jmp    800fa0 <__udivdi3+0x50>
  80105a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801060:	8d 46 ff             	lea    -0x1(%esi),%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	8b 74 24 10          	mov    0x10(%esp),%esi
  801069:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80106d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801071:	83 c4 1c             	add    $0x1c,%esp
  801074:	c3                   	ret    
	...

00801080 <__umoddi3>:
  801080:	83 ec 1c             	sub    $0x1c,%esp
  801083:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801087:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80108b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80108f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801093:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801097:	8b 74 24 24          	mov    0x24(%esp),%esi
  80109b:	85 ed                	test   %ebp,%ebp
  80109d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a5:	89 cf                	mov    %ecx,%edi
  8010a7:	89 04 24             	mov    %eax,(%esp)
  8010aa:	89 f2                	mov    %esi,%edx
  8010ac:	75 1a                	jne    8010c8 <__umoddi3+0x48>
  8010ae:	39 f1                	cmp    %esi,%ecx
  8010b0:	76 4e                	jbe    801100 <__umoddi3+0x80>
  8010b2:	f7 f1                	div    %ecx
  8010b4:	89 d0                	mov    %edx,%eax
  8010b6:	31 d2                	xor    %edx,%edx
  8010b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010bc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010c4:	83 c4 1c             	add    $0x1c,%esp
  8010c7:	c3                   	ret    
  8010c8:	39 f5                	cmp    %esi,%ebp
  8010ca:	77 54                	ja     801120 <__umoddi3+0xa0>
  8010cc:	0f bd c5             	bsr    %ebp,%eax
  8010cf:	83 f0 1f             	xor    $0x1f,%eax
  8010d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d6:	75 60                	jne    801138 <__umoddi3+0xb8>
  8010d8:	3b 0c 24             	cmp    (%esp),%ecx
  8010db:	0f 87 07 01 00 00    	ja     8011e8 <__umoddi3+0x168>
  8010e1:	89 f2                	mov    %esi,%edx
  8010e3:	8b 34 24             	mov    (%esp),%esi
  8010e6:	29 ce                	sub    %ecx,%esi
  8010e8:	19 ea                	sbb    %ebp,%edx
  8010ea:	89 34 24             	mov    %esi,(%esp)
  8010ed:	8b 04 24             	mov    (%esp),%eax
  8010f0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010f4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010f8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010fc:	83 c4 1c             	add    $0x1c,%esp
  8010ff:	c3                   	ret    
  801100:	85 c9                	test   %ecx,%ecx
  801102:	75 0b                	jne    80110f <__umoddi3+0x8f>
  801104:	b8 01 00 00 00       	mov    $0x1,%eax
  801109:	31 d2                	xor    %edx,%edx
  80110b:	f7 f1                	div    %ecx
  80110d:	89 c1                	mov    %eax,%ecx
  80110f:	89 f0                	mov    %esi,%eax
  801111:	31 d2                	xor    %edx,%edx
  801113:	f7 f1                	div    %ecx
  801115:	8b 04 24             	mov    (%esp),%eax
  801118:	f7 f1                	div    %ecx
  80111a:	eb 98                	jmp    8010b4 <__umoddi3+0x34>
  80111c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801120:	89 f2                	mov    %esi,%edx
  801122:	8b 74 24 10          	mov    0x10(%esp),%esi
  801126:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80112a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80112e:	83 c4 1c             	add    $0x1c,%esp
  801131:	c3                   	ret    
  801132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801138:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113d:	89 e8                	mov    %ebp,%eax
  80113f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801144:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801148:	89 fa                	mov    %edi,%edx
  80114a:	d3 e0                	shl    %cl,%eax
  80114c:	89 e9                	mov    %ebp,%ecx
  80114e:	d3 ea                	shr    %cl,%edx
  801150:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801155:	09 c2                	or     %eax,%edx
  801157:	8b 44 24 08          	mov    0x8(%esp),%eax
  80115b:	89 14 24             	mov    %edx,(%esp)
  80115e:	89 f2                	mov    %esi,%edx
  801160:	d3 e7                	shl    %cl,%edi
  801162:	89 e9                	mov    %ebp,%ecx
  801164:	d3 ea                	shr    %cl,%edx
  801166:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116f:	d3 e6                	shl    %cl,%esi
  801171:	89 e9                	mov    %ebp,%ecx
  801173:	d3 e8                	shr    %cl,%eax
  801175:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117a:	09 f0                	or     %esi,%eax
  80117c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801180:	f7 34 24             	divl   (%esp)
  801183:	d3 e6                	shl    %cl,%esi
  801185:	89 74 24 08          	mov    %esi,0x8(%esp)
  801189:	89 d6                	mov    %edx,%esi
  80118b:	f7 e7                	mul    %edi
  80118d:	39 d6                	cmp    %edx,%esi
  80118f:	89 c1                	mov    %eax,%ecx
  801191:	89 d7                	mov    %edx,%edi
  801193:	72 3f                	jb     8011d4 <__umoddi3+0x154>
  801195:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801199:	72 35                	jb     8011d0 <__umoddi3+0x150>
  80119b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80119f:	29 c8                	sub    %ecx,%eax
  8011a1:	19 fe                	sbb    %edi,%esi
  8011a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a8:	89 f2                	mov    %esi,%edx
  8011aa:	d3 e8                	shr    %cl,%eax
  8011ac:	89 e9                	mov    %ebp,%ecx
  8011ae:	d3 e2                	shl    %cl,%edx
  8011b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011b5:	09 d0                	or     %edx,%eax
  8011b7:	89 f2                	mov    %esi,%edx
  8011b9:	d3 ea                	shr    %cl,%edx
  8011bb:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011bf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011c3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011c7:	83 c4 1c             	add    $0x1c,%esp
  8011ca:	c3                   	ret    
  8011cb:	90                   	nop
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	39 d6                	cmp    %edx,%esi
  8011d2:	75 c7                	jne    80119b <__umoddi3+0x11b>
  8011d4:	89 d7                	mov    %edx,%edi
  8011d6:	89 c1                	mov    %eax,%ecx
  8011d8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011dc:	1b 3c 24             	sbb    (%esp),%edi
  8011df:	eb ba                	jmp    80119b <__umoddi3+0x11b>
  8011e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	39 f5                	cmp    %esi,%ebp
  8011ea:	0f 82 f1 fe ff ff    	jb     8010e1 <__umoddi3+0x61>
  8011f0:	e9 f8 fe ff ff       	jmp    8010ed <__umoddi3+0x6d>
