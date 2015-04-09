
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
  800043:	c7 04 24 d8 0e 80 00 	movl   $0x800ed8,(%esp)
  80004a:	e8 f4 00 00 00       	call   800143 <cprintf>
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
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  800060:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	00 00                	add    %al,(%eax)
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 9d 0a 00 00       	call   800b3b <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 14             	sub    $0x14,%esp
  8000a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000b3:	83 c0 01             	add    $0x1,%eax
  8000b6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000bd:	75 19                	jne    8000d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000c6:	00 
  8000c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ca:	89 04 24             	mov    %eax,(%esp)
  8000cd:	e8 0a 0a 00 00       	call   800adc <sys_cputs>
		b->idx = 0;
  8000d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000dc:	83 c4 14             	add    $0x14,%esp
  8000df:	5b                   	pop    %ebx
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f2:	00 00 00 
	b.cnt = 0;
  8000f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 45 08             	mov    0x8(%ebp),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	89 44 24 04          	mov    %eax,0x4(%esp)
  800117:	c7 04 24 a0 00 80 00 	movl   $0x8000a0,(%esp)
  80011e:	e8 d1 01 00 00       	call   8002f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800123:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	89 04 24             	mov    %eax,(%esp)
  800136:	e8 a1 09 00 00       	call   800adc <sys_cputs>

	return b.cnt;
}
  80013b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800149:	8d 45 0c             	lea    0xc(%ebp),%eax
  80014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800150:	8b 45 08             	mov    0x8(%ebp),%eax
  800153:	89 04 24             	mov    %eax,(%esp)
  800156:	e8 87 ff ff ff       	call   8000e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    
  80015d:	00 00                	add    %al,(%eax)
	...

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 3c             	sub    $0x3c,%esp
  800169:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80016c:	89 d7                	mov    %edx,%edi
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80017a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80017d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	b8 00 00 00 00       	mov    $0x0,%eax
  800185:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800188:	72 11                	jb     80019b <printnum+0x3b>
  80018a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80018d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800190:	76 09                	jbe    80019b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800192:	83 eb 01             	sub    $0x1,%ebx
  800195:	85 db                	test   %ebx,%ebx
  800197:	7f 51                	jg     8001ea <printnum+0x8a>
  800199:	eb 5e                	jmp    8001f9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80019f:	83 eb 01             	sub    $0x1,%ebx
  8001a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ad:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001b1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001bc:	00 
  8001bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ca:	e8 61 0a 00 00       	call   800c30 <__udivdi3>
  8001cf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001de:	89 fa                	mov    %edi,%edx
  8001e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001e3:	e8 78 ff ff ff       	call   800160 <printnum>
  8001e8:	eb 0f                	jmp    8001f9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001ee:	89 34 24             	mov    %esi,(%esp)
  8001f1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f4:	83 eb 01             	sub    $0x1,%ebx
  8001f7:	75 f1                	jne    8001ea <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800201:	8b 45 10             	mov    0x10(%ebp),%eax
  800204:	89 44 24 08          	mov    %eax,0x8(%esp)
  800208:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020f:	00 
  800210:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800219:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021d:	e8 3e 0b 00 00       	call   800d60 <__umoddi3>
  800222:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800226:	0f be 80 0d 0f 80 00 	movsbl 0x800f0d(%eax),%eax
  80022d:	89 04 24             	mov    %eax,(%esp)
  800230:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800233:	83 c4 3c             	add    $0x3c,%esp
  800236:	5b                   	pop    %ebx
  800237:	5e                   	pop    %esi
  800238:	5f                   	pop    %edi
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023e:	83 fa 01             	cmp    $0x1,%edx
  800241:	7e 0e                	jle    800251 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800243:	8b 10                	mov    (%eax),%edx
  800245:	8d 4a 08             	lea    0x8(%edx),%ecx
  800248:	89 08                	mov    %ecx,(%eax)
  80024a:	8b 02                	mov    (%edx),%eax
  80024c:	8b 52 04             	mov    0x4(%edx),%edx
  80024f:	eb 22                	jmp    800273 <getuint+0x38>
	else if (lflag)
  800251:	85 d2                	test   %edx,%edx
  800253:	74 10                	je     800265 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800255:	8b 10                	mov    (%eax),%edx
  800257:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 02                	mov    (%edx),%eax
  80025e:	ba 00 00 00 00       	mov    $0x0,%edx
  800263:	eb 0e                	jmp    800273 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800265:	8b 10                	mov    (%eax),%edx
  800267:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 02                	mov    (%edx),%eax
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800278:	83 fa 01             	cmp    $0x1,%edx
  80027b:	7e 0e                	jle    80028b <getint+0x16>
		return va_arg(*ap, long long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	8b 52 04             	mov    0x4(%edx),%edx
  800289:	eb 22                	jmp    8002ad <getint+0x38>
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 10                	je     80029f <getint+0x2a>
		return va_arg(*ap, long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	89 c2                	mov    %eax,%edx
  80029a:	c1 fa 1f             	sar    $0x1f,%edx
  80029d:	eb 0e                	jmp    8002ad <getint+0x38>
	else
		return va_arg(*ap, int);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	89 c2                	mov    %eax,%edx
  8002aa:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002be:	73 0a                	jae    8002ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c3:	88 0a                	mov    %cl,(%edx)
  8002c5:	83 c2 01             	add    $0x1,%edx
  8002c8:	89 10                	mov    %edx,(%eax)
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8002d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8002d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	89 04 24             	mov    %eax,(%esp)
  8002ed:	e8 02 00 00 00       	call   8002f4 <vprintfmt>
	va_end(ap);
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	57                   	push   %edi
  8002f8:	56                   	push   %esi
  8002f9:	53                   	push   %ebx
  8002fa:	83 ec 4c             	sub    $0x4c,%esp
  8002fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800300:	8b 75 10             	mov    0x10(%ebp),%esi
  800303:	eb 12                	jmp    800317 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800305:	85 c0                	test   %eax,%eax
  800307:	0f 84 98 03 00 00    	je     8006a5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80030d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800311:	89 04 24             	mov    %eax,(%esp)
  800314:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800317:	0f b6 06             	movzbl (%esi),%eax
  80031a:	83 c6 01             	add    $0x1,%esi
  80031d:	83 f8 25             	cmp    $0x25,%eax
  800320:	75 e3                	jne    800305 <vprintfmt+0x11>
  800322:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800326:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80032d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800332:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800341:	eb 2b                	jmp    80036e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800346:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034a:	eb 22                	jmp    80036e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800353:	eb 19                	jmp    80036e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800358:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80035f:	eb 0d                	jmp    80036e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800361:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800364:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800367:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	0f b6 06             	movzbl (%esi),%eax
  800371:	0f b6 d0             	movzbl %al,%edx
  800374:	8d 7e 01             	lea    0x1(%esi),%edi
  800377:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80037a:	83 e8 23             	sub    $0x23,%eax
  80037d:	3c 55                	cmp    $0x55,%al
  80037f:	0f 87 fa 02 00 00    	ja     80067f <vprintfmt+0x38b>
  800385:	0f b6 c0             	movzbl %al,%eax
  800388:	ff 24 85 9c 0f 80 00 	jmp    *0x800f9c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038f:	83 ea 30             	sub    $0x30,%edx
  800392:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800395:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800399:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80039f:	83 fa 09             	cmp    $0x9,%edx
  8003a2:	77 4a                	ja     8003ee <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003aa:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ad:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003b1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b7:	83 fa 09             	cmp    $0x9,%edx
  8003ba:	76 eb                	jbe    8003a7 <vprintfmt+0xb3>
  8003bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003bf:	eb 2d                	jmp    8003ee <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 50 04             	lea    0x4(%eax),%edx
  8003c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d2:	eb 1a                	jmp    8003ee <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003db:	79 91                	jns    80036e <vprintfmt+0x7a>
  8003dd:	e9 73 ff ff ff       	jmp    800355 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003ec:	eb 80                	jmp    80036e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f2:	0f 89 76 ff ff ff    	jns    80036e <vprintfmt+0x7a>
  8003f8:	e9 64 ff ff ff       	jmp    800361 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800403:	e9 66 ff ff ff       	jmp    80036e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800420:	e9 f2 fe ff ff       	jmp    800317 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 50 04             	lea    0x4(%eax),%edx
  80042b:	89 55 14             	mov    %edx,0x14(%ebp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	89 c2                	mov    %eax,%edx
  800432:	c1 fa 1f             	sar    $0x1f,%edx
  800435:	31 d0                	xor    %edx,%eax
  800437:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800439:	83 f8 06             	cmp    $0x6,%eax
  80043c:	7f 0b                	jg     800449 <vprintfmt+0x155>
  80043e:	8b 14 85 f4 10 80 00 	mov    0x8010f4(,%eax,4),%edx
  800445:	85 d2                	test   %edx,%edx
  800447:	75 23                	jne    80046c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800449:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044d:	c7 44 24 08 25 0f 80 	movl   $0x800f25,0x8(%esp)
  800454:	00 
  800455:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800459:	8b 7d 08             	mov    0x8(%ebp),%edi
  80045c:	89 3c 24             	mov    %edi,(%esp)
  80045f:	e8 68 fe ff ff       	call   8002cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800467:	e9 ab fe ff ff       	jmp    800317 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80046c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800470:	c7 44 24 08 2e 0f 80 	movl   $0x800f2e,0x8(%esp)
  800477:	00 
  800478:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80047f:	89 3c 24             	mov    %edi,(%esp)
  800482:	e8 45 fe ff ff       	call   8002cc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80048a:	e9 88 fe ff ff       	jmp    800317 <vprintfmt+0x23>
  80048f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800495:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 50 04             	lea    0x4(%eax),%edx
  80049e:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004a3:	85 f6                	test   %esi,%esi
  8004a5:	ba 1e 0f 80 00       	mov    $0x800f1e,%edx
  8004aa:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004ad:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b1:	7e 06                	jle    8004b9 <vprintfmt+0x1c5>
  8004b3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b7:	75 10                	jne    8004c9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b9:	0f be 06             	movsbl (%esi),%eax
  8004bc:	83 c6 01             	add    $0x1,%esi
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	0f 85 86 00 00 00    	jne    80054d <vprintfmt+0x259>
  8004c7:	eb 76                	jmp    80053f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cd:	89 34 24             	mov    %esi,(%esp)
  8004d0:	e8 76 02 00 00       	call   80074b <strnlen>
  8004d5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004d8:	29 c2                	sub    %eax,%edx
  8004da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	7e d8                	jle    8004b9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  8004e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004e5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004e8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8004eb:	89 d6                	mov    %edx,%esi
  8004ed:	89 c7                	mov    %eax,%edi
  8004ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f3:	89 3c 24             	mov    %edi,(%esp)
  8004f6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	83 ee 01             	sub    $0x1,%esi
  8004fc:	75 f1                	jne    8004ef <vprintfmt+0x1fb>
  8004fe:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800501:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800504:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800507:	eb b0                	jmp    8004b9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800509:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050d:	74 18                	je     800527 <vprintfmt+0x233>
  80050f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800512:	83 fa 5e             	cmp    $0x5e,%edx
  800515:	76 10                	jbe    800527 <vprintfmt+0x233>
					putch('?', putdat);
  800517:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800522:	ff 55 08             	call   *0x8(%ebp)
  800525:	eb 0a                	jmp    800531 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800527:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052b:	89 04 24             	mov    %eax,(%esp)
  80052e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800531:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800535:	0f be 06             	movsbl (%esi),%eax
  800538:	83 c6 01             	add    $0x1,%esi
  80053b:	85 c0                	test   %eax,%eax
  80053d:	75 0e                	jne    80054d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800542:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800546:	7f 11                	jg     800559 <vprintfmt+0x265>
  800548:	e9 ca fd ff ff       	jmp    800317 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054d:	85 ff                	test   %edi,%edi
  80054f:	90                   	nop
  800550:	78 b7                	js     800509 <vprintfmt+0x215>
  800552:	83 ef 01             	sub    $0x1,%edi
  800555:	79 b2                	jns    800509 <vprintfmt+0x215>
  800557:	eb e6                	jmp    80053f <vprintfmt+0x24b>
  800559:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80055c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800563:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056c:	83 ee 01             	sub    $0x1,%esi
  80056f:	75 ee                	jne    80055f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800574:	e9 9e fd ff ff       	jmp    800317 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800579:	89 ca                	mov    %ecx,%edx
  80057b:	8d 45 14             	lea    0x14(%ebp),%eax
  80057e:	e8 f2 fc ff ff       	call   800275 <getint>
  800583:	89 c6                	mov    %eax,%esi
  800585:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058c:	85 d2                	test   %edx,%edx
  80058e:	0f 89 ad 00 00 00    	jns    800641 <vprintfmt+0x34d>
				putch('-', putdat);
  800594:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800598:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80059f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a2:	f7 de                	neg    %esi
  8005a4:	83 d7 00             	adc    $0x0,%edi
  8005a7:	f7 df                	neg    %edi
			}
			base = 10;
  8005a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ae:	e9 8e 00 00 00       	jmp    800641 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b3:	89 ca                	mov    %ecx,%edx
  8005b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b8:	e8 7e fc ff ff       	call   80023b <getuint>
  8005bd:	89 c6                	mov    %eax,%esi
  8005bf:	89 d7                	mov    %edx,%edi
			base = 10;
  8005c1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005c6:	eb 79                	jmp    800641 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  8005c8:	89 ca                	mov    %ecx,%edx
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cd:	e8 a3 fc ff ff       	call   800275 <getint>
  8005d2:	89 c6                	mov    %eax,%esi
  8005d4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8005d6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	79 62                	jns    800641 <vprintfmt+0x34d>
				putch('-', putdat);
  8005df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ea:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ed:	f7 de                	neg    %esi
  8005ef:	83 d7 00             	adc    $0x0,%edi
  8005f2:	f7 df                	neg    %edi
			}
			base = 8;
  8005f4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f9:	eb 46                	jmp    800641 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8005fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ff:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800606:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800609:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800614:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800620:	8b 30                	mov    (%eax),%esi
  800622:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800627:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80062c:	eb 13                	jmp    800641 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062e:	89 ca                	mov    %ecx,%edx
  800630:	8d 45 14             	lea    0x14(%ebp),%eax
  800633:	e8 03 fc ff ff       	call   80023b <getuint>
  800638:	89 c6                	mov    %eax,%esi
  80063a:	89 d7                	mov    %edx,%edi
			base = 16;
  80063c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800641:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800645:	89 54 24 10          	mov    %edx,0x10(%esp)
  800649:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800650:	89 44 24 08          	mov    %eax,0x8(%esp)
  800654:	89 34 24             	mov    %esi,(%esp)
  800657:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065b:	89 da                	mov    %ebx,%edx
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	e8 fb fa ff ff       	call   800160 <printnum>
			break;
  800665:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800668:	e9 aa fc ff ff       	jmp    800317 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800671:	89 14 24             	mov    %edx,(%esp)
  800674:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067a:	e9 98 fc ff ff       	jmp    800317 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80067f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800683:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80068a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800691:	0f 84 80 fc ff ff    	je     800317 <vprintfmt+0x23>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069e:	75 f7                	jne    800697 <vprintfmt+0x3a3>
  8006a0:	e9 72 fc ff ff       	jmp    800317 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006a5:	83 c4 4c             	add    $0x4c,%esp
  8006a8:	5b                   	pop    %ebx
  8006a9:	5e                   	pop    %esi
  8006aa:	5f                   	pop    %edi
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	83 ec 28             	sub    $0x28,%esp
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	74 30                	je     8006fe <vsnprintf+0x51>
  8006ce:	85 d2                	test   %edx,%edx
  8006d0:	7e 2c                	jle    8006fe <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e7:	c7 04 24 af 02 80 00 	movl   $0x8002af,(%esp)
  8006ee:	e8 01 fc ff ff       	call   8002f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fc:	eb 05                	jmp    800703 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800712:	8b 45 10             	mov    0x10(%ebp),%eax
  800715:	89 44 24 08          	mov    %eax,0x8(%esp)
  800719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 82 ff ff ff       	call   8006ad <vsnprintf>
	va_end(ap);

	return rc;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    
  80072d:	00 00                	add    %al,(%eax)
	...

00800730 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	80 3a 00             	cmpb   $0x0,(%edx)
  80073e:	74 09                	je     800749 <strlen+0x19>
		n++;
  800740:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800743:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800747:	75 f7                	jne    800740 <strlen+0x10>
		n++;
	return n;
}
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	53                   	push   %ebx
  80074f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
  80075a:	85 c9                	test   %ecx,%ecx
  80075c:	74 1a                	je     800778 <strnlen+0x2d>
  80075e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800761:	74 15                	je     800778 <strnlen+0x2d>
  800763:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800768:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076a:	39 ca                	cmp    %ecx,%edx
  80076c:	74 0a                	je     800778 <strnlen+0x2d>
  80076e:	83 c2 01             	add    $0x1,%edx
  800771:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800776:	75 f0                	jne    800768 <strnlen+0x1d>
		n++;
	return n;
}
  800778:	5b                   	pop    %ebx
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
  80078a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80078e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800791:	83 c2 01             	add    $0x1,%edx
  800794:	84 c9                	test   %cl,%cl
  800796:	75 f2                	jne    80078a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800798:	5b                   	pop    %ebx
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a9:	85 f6                	test   %esi,%esi
  8007ab:	74 18                	je     8007c5 <strncpy+0x2a>
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007b2:	0f b6 1a             	movzbl (%edx),%ebx
  8007b5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b8:	80 3a 01             	cmpb   $0x1,(%edx)
  8007bb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007be:	83 c1 01             	add    $0x1,%ecx
  8007c1:	39 f1                	cmp    %esi,%ecx
  8007c3:	75 ed                	jne    8007b2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	57                   	push   %edi
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d8:	89 f8                	mov    %edi,%eax
  8007da:	85 f6                	test   %esi,%esi
  8007dc:	74 2b                	je     800809 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8007de:	83 fe 01             	cmp    $0x1,%esi
  8007e1:	74 23                	je     800806 <strlcpy+0x3d>
  8007e3:	0f b6 0b             	movzbl (%ebx),%ecx
  8007e6:	84 c9                	test   %cl,%cl
  8007e8:	74 1c                	je     800806 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007ea:	83 ee 02             	sub    $0x2,%esi
  8007ed:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f2:	88 08                	mov    %cl,(%eax)
  8007f4:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f7:	39 f2                	cmp    %esi,%edx
  8007f9:	74 0b                	je     800806 <strlcpy+0x3d>
  8007fb:	83 c2 01             	add    $0x1,%edx
  8007fe:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800802:	84 c9                	test   %cl,%cl
  800804:	75 ec                	jne    8007f2 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800806:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800809:	29 f8                	sub    %edi,%eax
}
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5f                   	pop    %edi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800819:	0f b6 01             	movzbl (%ecx),%eax
  80081c:	84 c0                	test   %al,%al
  80081e:	74 16                	je     800836 <strcmp+0x26>
  800820:	3a 02                	cmp    (%edx),%al
  800822:	75 12                	jne    800836 <strcmp+0x26>
		p++, q++;
  800824:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800827:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80082b:	84 c0                	test   %al,%al
  80082d:	74 07                	je     800836 <strcmp+0x26>
  80082f:	83 c1 01             	add    $0x1,%ecx
  800832:	3a 02                	cmp    (%edx),%al
  800834:	74 ee                	je     800824 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800836:	0f b6 c0             	movzbl %al,%eax
  800839:	0f b6 12             	movzbl (%edx),%edx
  80083c:	29 d0                	sub    %edx,%eax
}
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	53                   	push   %ebx
  800844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800847:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80084a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800852:	85 d2                	test   %edx,%edx
  800854:	74 28                	je     80087e <strncmp+0x3e>
  800856:	0f b6 01             	movzbl (%ecx),%eax
  800859:	84 c0                	test   %al,%al
  80085b:	74 24                	je     800881 <strncmp+0x41>
  80085d:	3a 03                	cmp    (%ebx),%al
  80085f:	75 20                	jne    800881 <strncmp+0x41>
  800861:	83 ea 01             	sub    $0x1,%edx
  800864:	74 13                	je     800879 <strncmp+0x39>
		n--, p++, q++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	84 c0                	test   %al,%al
  800871:	74 0e                	je     800881 <strncmp+0x41>
  800873:	3a 03                	cmp    (%ebx),%al
  800875:	74 ea                	je     800861 <strncmp+0x21>
  800877:	eb 08                	jmp    800881 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800881:	0f b6 01             	movzbl (%ecx),%eax
  800884:	0f b6 13             	movzbl (%ebx),%edx
  800887:	29 d0                	sub    %edx,%eax
  800889:	eb f3                	jmp    80087e <strncmp+0x3e>

0080088b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800895:	0f b6 10             	movzbl (%eax),%edx
  800898:	84 d2                	test   %dl,%dl
  80089a:	74 1c                	je     8008b8 <strchr+0x2d>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	75 09                	jne    8008a9 <strchr+0x1e>
  8008a0:	eb 1b                	jmp    8008bd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8008a5:	38 ca                	cmp    %cl,%dl
  8008a7:	74 14                	je     8008bd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	75 f1                	jne    8008a2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb 05                	jmp    8008bd <strchr+0x32>
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	0f b6 10             	movzbl (%eax),%edx
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	74 14                	je     8008e4 <strfind+0x25>
		if (*s == c)
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	75 06                	jne    8008da <strfind+0x1b>
  8008d4:	eb 0e                	jmp    8008e4 <strfind+0x25>
  8008d6:	38 ca                	cmp    %cl,%dl
  8008d8:	74 0a                	je     8008e4 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008da:	83 c0 01             	add    $0x1,%eax
  8008dd:	0f b6 10             	movzbl (%eax),%edx
  8008e0:	84 d2                	test   %dl,%dl
  8008e2:	75 f2                	jne    8008d6 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <memset>:


void *
memset(void *v, int c, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	53                   	push   %ebx
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8008f3:	89 da                	mov    %ebx,%edx
  8008f5:	83 ea 01             	sub    $0x1,%edx
  8008f8:	78 0d                	js     800907 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  8008fa:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  8008fc:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  8008fe:	88 0a                	mov    %cl,(%edx)
  800900:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800903:	39 da                	cmp    %ebx,%edx
  800905:	75 f7                	jne    8008fe <memset+0x18>
		*p++ = c;

	return v;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 75 0c             	mov    0xc(%ebp),%esi
  800916:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800919:	39 c6                	cmp    %eax,%esi
  80091b:	72 0b                	jb     800928 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  80091d:	ba 00 00 00 00       	mov    $0x0,%edx
  800922:	85 db                	test   %ebx,%ebx
  800924:	75 29                	jne    80094f <memmove+0x45>
  800926:	eb 35                	jmp    80095d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800928:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  80092b:	39 c8                	cmp    %ecx,%eax
  80092d:	73 ee                	jae    80091d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  80092f:	85 db                	test   %ebx,%ebx
  800931:	74 2a                	je     80095d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800933:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800936:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800938:	f7 db                	neg    %ebx
  80093a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  80093d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  80093f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800944:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800948:	83 ea 01             	sub    $0x1,%edx
  80094b:	75 f2                	jne    80093f <memmove+0x35>
  80094d:	eb 0e                	jmp    80095d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  80094f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800953:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800956:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800959:	39 d3                	cmp    %edx,%ebx
  80095b:	75 f2                	jne    80094f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800968:	8b 45 10             	mov    0x10(%ebp),%eax
  80096b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	89 44 24 04          	mov    %eax,0x4(%esp)
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	89 04 24             	mov    %eax,(%esp)
  80097c:	e8 89 ff ff ff       	call   80090a <memmove>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800997:	85 ff                	test   %edi,%edi
  800999:	74 37                	je     8009d2 <memcmp+0x4f>
		if (*s1 != *s2)
  80099b:	0f b6 03             	movzbl (%ebx),%eax
  80099e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a1:	83 ef 01             	sub    $0x1,%edi
  8009a4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8009a9:	38 c8                	cmp    %cl,%al
  8009ab:	74 1c                	je     8009c9 <memcmp+0x46>
  8009ad:	eb 10                	jmp    8009bf <memcmp+0x3c>
  8009af:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8009b4:	83 c2 01             	add    $0x1,%edx
  8009b7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009bb:	38 c8                	cmp    %cl,%al
  8009bd:	74 0a                	je     8009c9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  8009bf:	0f b6 c0             	movzbl %al,%eax
  8009c2:	0f b6 c9             	movzbl %cl,%ecx
  8009c5:	29 c8                	sub    %ecx,%eax
  8009c7:	eb 09                	jmp    8009d2 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c9:	39 fa                	cmp    %edi,%edx
  8009cb:	75 e2                	jne    8009af <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009dd:	89 c2                	mov    %eax,%edx
  8009df:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e2:	39 d0                	cmp    %edx,%eax
  8009e4:	73 15                	jae    8009fb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8009ea:	38 08                	cmp    %cl,(%eax)
  8009ec:	75 06                	jne    8009f4 <memfind+0x1d>
  8009ee:	eb 0b                	jmp    8009fb <memfind+0x24>
  8009f0:	38 08                	cmp    %cl,(%eax)
  8009f2:	74 07                	je     8009fb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	39 d0                	cmp    %edx,%eax
  8009f9:	75 f5                	jne    8009f0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
  800a06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a09:	0f b6 02             	movzbl (%edx),%eax
  800a0c:	3c 20                	cmp    $0x20,%al
  800a0e:	74 04                	je     800a14 <strtol+0x17>
  800a10:	3c 09                	cmp    $0x9,%al
  800a12:	75 0e                	jne    800a22 <strtol+0x25>
		s++;
  800a14:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a17:	0f b6 02             	movzbl (%edx),%eax
  800a1a:	3c 20                	cmp    $0x20,%al
  800a1c:	74 f6                	je     800a14 <strtol+0x17>
  800a1e:	3c 09                	cmp    $0x9,%al
  800a20:	74 f2                	je     800a14 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a22:	3c 2b                	cmp    $0x2b,%al
  800a24:	75 0a                	jne    800a30 <strtol+0x33>
		s++;
  800a26:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2e:	eb 10                	jmp    800a40 <strtol+0x43>
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a35:	3c 2d                	cmp    $0x2d,%al
  800a37:	75 07                	jne    800a40 <strtol+0x43>
		s++, neg = 1;
  800a39:	83 c2 01             	add    $0x1,%edx
  800a3c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a40:	85 db                	test   %ebx,%ebx
  800a42:	0f 94 c0             	sete   %al
  800a45:	74 05                	je     800a4c <strtol+0x4f>
  800a47:	83 fb 10             	cmp    $0x10,%ebx
  800a4a:	75 15                	jne    800a61 <strtol+0x64>
  800a4c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a4f:	75 10                	jne    800a61 <strtol+0x64>
  800a51:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a55:	75 0a                	jne    800a61 <strtol+0x64>
		s += 2, base = 16;
  800a57:	83 c2 02             	add    $0x2,%edx
  800a5a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5f:	eb 13                	jmp    800a74 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800a61:	84 c0                	test   %al,%al
  800a63:	74 0f                	je     800a74 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a65:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6d:	75 05                	jne    800a74 <strtol+0x77>
		s++, base = 8;
  800a6f:	83 c2 01             	add    $0x1,%edx
  800a72:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7b:	0f b6 0a             	movzbl (%edx),%ecx
  800a7e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a81:	80 fb 09             	cmp    $0x9,%bl
  800a84:	77 08                	ja     800a8e <strtol+0x91>
			dig = *s - '0';
  800a86:	0f be c9             	movsbl %cl,%ecx
  800a89:	83 e9 30             	sub    $0x30,%ecx
  800a8c:	eb 1e                	jmp    800aac <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800a8e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0xa1>
			dig = *s - 'a' + 10;
  800a96:	0f be c9             	movsbl %cl,%ecx
  800a99:	83 e9 57             	sub    $0x57,%ecx
  800a9c:	eb 0e                	jmp    800aac <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 14                	ja     800aba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa6:	0f be c9             	movsbl %cl,%ecx
  800aa9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aac:	39 f1                	cmp    %esi,%ecx
  800aae:	7d 0e                	jge    800abe <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ab0:	83 c2 01             	add    $0x1,%edx
  800ab3:	0f af c6             	imul   %esi,%eax
  800ab6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab8:	eb c1                	jmp    800a7b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aba:	89 c1                	mov    %eax,%ecx
  800abc:	eb 02                	jmp    800ac0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abe:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac4:	74 05                	je     800acb <strtol+0xce>
		*endptr = (char *) s;
  800ac6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800acb:	89 ca                	mov    %ecx,%edx
  800acd:	f7 da                	neg    %edx
  800acf:	85 ff                	test   %edi,%edi
  800ad1:	0f 45 c2             	cmovne %edx,%eax
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    
  800ad9:	00 00                	add    %al,(%eax)
	...

00800adc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ae5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ae8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800af0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
  800af6:	89 c3                	mov    %eax,%ebx
  800af8:	89 c7                	mov    %eax,%edi
  800afa:	89 c6                	mov    %eax,%esi
  800afc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b01:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b04:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b07:	89 ec                	mov    %ebp,%esp
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b17:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b24:	89 d1                	mov    %edx,%ecx
  800b26:	89 d3                	mov    %edx,%ebx
  800b28:	89 d7                	mov    %edx,%edi
  800b2a:	89 d6                	mov    %edx,%esi
  800b2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b37:	89 ec                	mov    %ebp,%esp
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 38             	sub    $0x38,%esp
  800b41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	89 cb                	mov    %ecx,%ebx
  800b59:	89 cf                	mov    %ecx,%edi
  800b5b:	89 ce                	mov    %ecx,%esi
  800b5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	7e 28                	jle    800b8b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b63:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b67:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b6e:	00 
  800b6f:	c7 44 24 08 10 11 80 	movl   $0x801110,0x8(%esp)
  800b76:	00 
  800b77:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b7e:	00 
  800b7f:	c7 04 24 2d 11 80 00 	movl   $0x80112d,(%esp)
  800b86:	e8 3d 00 00 00       	call   800bc8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b8e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b91:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b94:	89 ec                	mov    %ebp,%esp
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ba1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ba4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb1:	89 d1                	mov    %edx,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bbe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc4:	89 ec                	mov    %ebp,%esp
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800bce:	a1 08 20 80 00       	mov    0x802008,%eax
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	74 10                	je     800be7 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdb:	c7 04 24 3b 11 80 00 	movl   $0x80113b,(%esp)
  800be2:	e8 5c f5 ff ff       	call   800143 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf5:	a1 00 20 80 00       	mov    0x802000,%eax
  800bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfe:	c7 04 24 40 11 80 00 	movl   $0x801140,(%esp)
  800c05:	e8 39 f5 ff ff       	call   800143 <cprintf>
	vcprintf(fmt, ap);
  800c0a:	8d 45 14             	lea    0x14(%ebp),%eax
  800c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c11:	8b 45 10             	mov    0x10(%ebp),%eax
  800c14:	89 04 24             	mov    %eax,(%esp)
  800c17:	e8 c6 f4 ff ff       	call   8000e2 <vcprintf>
	cprintf("\n");
  800c1c:	c7 04 24 f4 0e 80 00 	movl   $0x800ef4,(%esp)
  800c23:	e8 1b f5 ff ff       	call   800143 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c28:	cc                   	int3   
  800c29:	eb fd                	jmp    800c28 <_panic+0x60>
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
