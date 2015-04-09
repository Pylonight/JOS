
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 e8 0e 80 00 	movl   $0x800ee8,(%esp)
  800041:	e8 09 01 00 00       	call   80014f <cprintf>
	cprintf("i am environment %08x\n", env->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 4c             	mov    0x4c(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 f6 0e 80 00 	movl   $0x800ef6,(%esp)
  800059:	e8 f1 00 00 00       	call   80014f <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = 0;
  80006c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	89 54 24 04          	mov    %edx,0x4(%esp)
  800086:	89 04 24             	mov    %eax,(%esp)
  800089:	e8 a6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008e:	e8 05 00 00 00       	call   800098 <exit>
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 a1 0a 00 00       	call   800b4b <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 14             	sub    $0x14,%esp
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b6:	8b 03                	mov    (%ebx),%eax
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000bf:	83 c0 01             	add    $0x1,%eax
  8000c2:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c9:	75 19                	jne    8000e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d6:	89 04 24             	mov    %eax,(%esp)
  8000d9:	e8 0e 0a 00 00       	call   800aec <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e8:	83 c4 14             	add    $0x14,%esp
  8000eb:	5b                   	pop    %ebx
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fe:	00 00 00 
	b.cnt = 0;
  800101:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800108:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800112:	8b 45 08             	mov    0x8(%ebp),%eax
  800115:	89 44 24 08          	mov    %eax,0x8(%esp)
  800119:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800123:	c7 04 24 ac 00 80 00 	movl   $0x8000ac,(%esp)
  80012a:	e8 d5 01 00 00       	call   800304 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013f:	89 04 24             	mov    %eax,(%esp)
  800142:	e8 a5 09 00 00       	call   800aec <sys_cputs>

	return b.cnt;
}
  800147:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800155:	8d 45 0c             	lea    0xc(%ebp),%eax
  800158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	e8 87 ff ff ff       	call   8000ee <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
  80016b:	00 00                	add    %al,(%eax)
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 3c             	sub    $0x3c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80018a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80018d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800190:	b8 00 00 00 00       	mov    $0x0,%eax
  800195:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800198:	72 11                	jb     8001ab <printnum+0x3b>
  80019a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80019d:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a0:	76 09                	jbe    8001ab <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001a2:	83 eb 01             	sub    $0x1,%ebx
  8001a5:	85 db                	test   %ebx,%ebx
  8001a7:	7f 51                	jg     8001fa <printnum+0x8a>
  8001a9:	eb 5e                	jmp    800209 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ab:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001af:	83 eb 01             	sub    $0x1,%ebx
  8001b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001c1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cc:	00 
  8001cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001da:	e8 61 0a 00 00       	call   800c40 <__udivdi3>
  8001df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e7:	89 04 24             	mov    %eax,(%esp)
  8001ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ee:	89 fa                	mov    %edi,%edx
  8001f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f3:	e8 78 ff ff ff       	call   800170 <printnum>
  8001f8:	eb 0f                	jmp    800209 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001fe:	89 34 24             	mov    %esi,(%esp)
  800201:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800204:	83 eb 01             	sub    $0x1,%ebx
  800207:	75 f1                	jne    8001fa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800209:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800211:	8b 45 10             	mov    0x10(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021f:	00 
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	e8 3e 0b 00 00       	call   800d70 <__umoddi3>
  800232:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800236:	0f be 80 24 0f 80 00 	movsbl 0x800f24(%eax),%eax
  80023d:	89 04 24             	mov    %eax,(%esp)
  800240:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800243:	83 c4 3c             	add    $0x3c,%esp
  800246:	5b                   	pop    %ebx
  800247:	5e                   	pop    %esi
  800248:	5f                   	pop    %edi
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024e:	83 fa 01             	cmp    $0x1,%edx
  800251:	7e 0e                	jle    800261 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800253:	8b 10                	mov    (%eax),%edx
  800255:	8d 4a 08             	lea    0x8(%edx),%ecx
  800258:	89 08                	mov    %ecx,(%eax)
  80025a:	8b 02                	mov    (%edx),%eax
  80025c:	8b 52 04             	mov    0x4(%edx),%edx
  80025f:	eb 22                	jmp    800283 <getuint+0x38>
	else if (lflag)
  800261:	85 d2                	test   %edx,%edx
  800263:	74 10                	je     800275 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800265:	8b 10                	mov    (%eax),%edx
  800267:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 02                	mov    (%edx),%eax
  80026e:	ba 00 00 00 00       	mov    $0x0,%edx
  800273:	eb 0e                	jmp    800283 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800275:	8b 10                	mov    (%eax),%edx
  800277:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027a:	89 08                	mov    %ecx,(%eax)
  80027c:	8b 02                	mov    (%edx),%eax
  80027e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800288:	83 fa 01             	cmp    $0x1,%edx
  80028b:	7e 0e                	jle    80029b <getint+0x16>
		return va_arg(*ap, long long);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	8b 52 04             	mov    0x4(%edx),%edx
  800299:	eb 22                	jmp    8002bd <getint+0x38>
	else if (lflag)
  80029b:	85 d2                	test   %edx,%edx
  80029d:	74 10                	je     8002af <getint+0x2a>
		return va_arg(*ap, long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	89 c2                	mov    %eax,%edx
  8002aa:	c1 fa 1f             	sar    $0x1f,%edx
  8002ad:	eb 0e                	jmp    8002bd <getint+0x38>
	else
		return va_arg(*ap, int);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	89 c2                	mov    %eax,%edx
  8002ba:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c9:	8b 10                	mov    (%eax),%edx
  8002cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ce:	73 0a                	jae    8002da <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d3:	88 0a                	mov    %cl,(%edx)
  8002d5:	83 c2 01             	add    $0x1,%edx
  8002d8:	89 10                	mov    %edx,(%eax)
}
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8002e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8002e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	e8 02 00 00 00       	call   800304 <vprintfmt>
	va_end(ap);
}
  800302:	c9                   	leave  
  800303:	c3                   	ret    

00800304 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 4c             	sub    $0x4c,%esp
  80030d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800310:	8b 75 10             	mov    0x10(%ebp),%esi
  800313:	eb 12                	jmp    800327 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800315:	85 c0                	test   %eax,%eax
  800317:	0f 84 98 03 00 00    	je     8006b5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80031d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800327:	0f b6 06             	movzbl (%esi),%eax
  80032a:	83 c6 01             	add    $0x1,%esi
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e3                	jne    800315 <vprintfmt+0x11>
  800332:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800336:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80033d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800342:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800349:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800351:	eb 2b                	jmp    80037e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800356:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80035a:	eb 22                	jmp    80037e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800363:	eb 19                	jmp    80037e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800368:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036f:	eb 0d                	jmp    80037e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800371:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800374:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800377:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	0f b6 06             	movzbl (%esi),%eax
  800381:	0f b6 d0             	movzbl %al,%edx
  800384:	8d 7e 01             	lea    0x1(%esi),%edi
  800387:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80038a:	83 e8 23             	sub    $0x23,%eax
  80038d:	3c 55                	cmp    $0x55,%al
  80038f:	0f 87 fa 02 00 00    	ja     80068f <vprintfmt+0x38b>
  800395:	0f b6 c0             	movzbl %al,%eax
  800398:	ff 24 85 b4 0f 80 00 	jmp    *0x800fb4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039f:	83 ea 30             	sub    $0x30,%edx
  8003a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003a5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003a9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003af:	83 fa 09             	cmp    $0x9,%edx
  8003b2:	77 4a                	ja     8003fe <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003ba:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003bd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003c1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c7:	83 fa 09             	cmp    $0x9,%edx
  8003ca:	76 eb                	jbe    8003b7 <vprintfmt+0xb3>
  8003cc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003cf:	eb 2d                	jmp    8003fe <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e2:	eb 1a                	jmp    8003fe <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  8003e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003eb:	79 91                	jns    80037e <vprintfmt+0x7a>
  8003ed:	e9 73 ff ff ff       	jmp    800365 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003fc:	eb 80                	jmp    80037e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8003fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800402:	0f 89 76 ff ff ff    	jns    80037e <vprintfmt+0x7a>
  800408:	e9 64 ff ff ff       	jmp    800371 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800413:	e9 66 ff ff ff       	jmp    80037e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8d 50 04             	lea    0x4(%eax),%edx
  80041e:	89 55 14             	mov    %edx,0x14(%ebp)
  800421:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800425:	8b 00                	mov    (%eax),%eax
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800430:	e9 f2 fe ff ff       	jmp    800327 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	89 c2                	mov    %eax,%edx
  800442:	c1 fa 1f             	sar    $0x1f,%edx
  800445:	31 d0                	xor    %edx,%eax
  800447:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800449:	83 f8 06             	cmp    $0x6,%eax
  80044c:	7f 0b                	jg     800459 <vprintfmt+0x155>
  80044e:	8b 14 85 0c 11 80 00 	mov    0x80110c(,%eax,4),%edx
  800455:	85 d2                	test   %edx,%edx
  800457:	75 23                	jne    80047c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800459:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045d:	c7 44 24 08 3c 0f 80 	movl   $0x800f3c,0x8(%esp)
  800464:	00 
  800465:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800469:	8b 7d 08             	mov    0x8(%ebp),%edi
  80046c:	89 3c 24             	mov    %edi,(%esp)
  80046f:	e8 68 fe ff ff       	call   8002dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800477:	e9 ab fe ff ff       	jmp    800327 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80047c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800480:	c7 44 24 08 45 0f 80 	movl   $0x800f45,0x8(%esp)
  800487:	00 
  800488:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80048f:	89 3c 24             	mov    %edi,(%esp)
  800492:	e8 45 fe ff ff       	call   8002dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049a:	e9 88 fe ff ff       	jmp    800327 <vprintfmt+0x23>
  80049f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8d 50 04             	lea    0x4(%eax),%edx
  8004ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004b3:	85 f6                	test   %esi,%esi
  8004b5:	ba 35 0f 80 00       	mov    $0x800f35,%edx
  8004ba:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004bd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c1:	7e 06                	jle    8004c9 <vprintfmt+0x1c5>
  8004c3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004c7:	75 10                	jne    8004d9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c9:	0f be 06             	movsbl (%esi),%eax
  8004cc:	83 c6 01             	add    $0x1,%esi
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	0f 85 86 00 00 00    	jne    80055d <vprintfmt+0x259>
  8004d7:	eb 76                	jmp    80054f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004dd:	89 34 24             	mov    %esi,(%esp)
  8004e0:	e8 76 02 00 00       	call   80075b <strnlen>
  8004e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004e8:	29 c2                	sub    %eax,%edx
  8004ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	7e d8                	jle    8004c9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  8004f1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004f5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004f8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8004fb:	89 d6                	mov    %edx,%esi
  8004fd:	89 c7                	mov    %eax,%edi
  8004ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800503:	89 3c 24             	mov    %edi,(%esp)
  800506:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	83 ee 01             	sub    $0x1,%esi
  80050c:	75 f1                	jne    8004ff <vprintfmt+0x1fb>
  80050e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800511:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800514:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800517:	eb b0                	jmp    8004c9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051d:	74 18                	je     800537 <vprintfmt+0x233>
  80051f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800522:	83 fa 5e             	cmp    $0x5e,%edx
  800525:	76 10                	jbe    800537 <vprintfmt+0x233>
					putch('?', putdat);
  800527:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	eb 0a                	jmp    800541 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800537:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053b:	89 04 24             	mov    %eax,(%esp)
  80053e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800541:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800545:	0f be 06             	movsbl (%esi),%eax
  800548:	83 c6 01             	add    $0x1,%esi
  80054b:	85 c0                	test   %eax,%eax
  80054d:	75 0e                	jne    80055d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800552:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800556:	7f 11                	jg     800569 <vprintfmt+0x265>
  800558:	e9 ca fd ff ff       	jmp    800327 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055d:	85 ff                	test   %edi,%edi
  80055f:	90                   	nop
  800560:	78 b7                	js     800519 <vprintfmt+0x215>
  800562:	83 ef 01             	sub    $0x1,%edi
  800565:	79 b2                	jns    800519 <vprintfmt+0x215>
  800567:	eb e6                	jmp    80054f <vprintfmt+0x24b>
  800569:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80056c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800573:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057c:	83 ee 01             	sub    $0x1,%esi
  80057f:	75 ee                	jne    80056f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800584:	e9 9e fd ff ff       	jmp    800327 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800589:	89 ca                	mov    %ecx,%edx
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	e8 f2 fc ff ff       	call   800285 <getint>
  800593:	89 c6                	mov    %eax,%esi
  800595:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059c:	85 d2                	test   %edx,%edx
  80059e:	0f 89 ad 00 00 00    	jns    800651 <vprintfmt+0x34d>
				putch('-', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b2:	f7 de                	neg    %esi
  8005b4:	83 d7 00             	adc    $0x0,%edi
  8005b7:	f7 df                	neg    %edi
			}
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	e9 8e 00 00 00       	jmp    800651 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c3:	89 ca                	mov    %ecx,%edx
  8005c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c8:	e8 7e fc ff ff       	call   80024b <getuint>
  8005cd:	89 c6                	mov    %eax,%esi
  8005cf:	89 d7                	mov    %edx,%edi
			base = 10;
  8005d1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005d6:	eb 79                	jmp    800651 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  8005d8:	89 ca                	mov    %ecx,%edx
  8005da:	8d 45 14             	lea    0x14(%ebp),%eax
  8005dd:	e8 a3 fc ff ff       	call   800285 <getint>
  8005e2:	89 c6                	mov    %eax,%esi
  8005e4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8005e6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	79 62                	jns    800651 <vprintfmt+0x34d>
				putch('-', putdat);
  8005ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005fd:	f7 de                	neg    %esi
  8005ff:	83 d7 00             	adc    $0x0,%edi
  800602:	f7 df                	neg    %edi
			}
			base = 8;
  800604:	b8 08 00 00 00       	mov    $0x8,%eax
  800609:	eb 46                	jmp    800651 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800619:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800624:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 50 04             	lea    0x4(%eax),%edx
  80062d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800630:	8b 30                	mov    (%eax),%esi
  800632:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063c:	eb 13                	jmp    800651 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063e:	89 ca                	mov    %ecx,%edx
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
  800643:	e8 03 fc ff ff       	call   80024b <getuint>
  800648:	89 c6                	mov    %eax,%esi
  80064a:	89 d7                	mov    %edx,%edi
			base = 16;
  80064c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800651:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800655:	89 54 24 10          	mov    %edx,0x10(%esp)
  800659:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800660:	89 44 24 08          	mov    %eax,0x8(%esp)
  800664:	89 34 24             	mov    %esi,(%esp)
  800667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066b:	89 da                	mov    %ebx,%edx
  80066d:	8b 45 08             	mov    0x8(%ebp),%eax
  800670:	e8 fb fa ff ff       	call   800170 <printnum>
			break;
  800675:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800678:	e9 aa fc ff ff       	jmp    800327 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800681:	89 14 24             	mov    %edx,(%esp)
  800684:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068a:	e9 98 fc ff ff       	jmp    800327 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800693:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80069a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006a1:	0f 84 80 fc ff ff    	je     800327 <vprintfmt+0x23>
  8006a7:	83 ee 01             	sub    $0x1,%esi
  8006aa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ae:	75 f7                	jne    8006a7 <vprintfmt+0x3a3>
  8006b0:	e9 72 fc ff ff       	jmp    800327 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006b5:	83 c4 4c             	add    $0x4c,%esp
  8006b8:	5b                   	pop    %ebx
  8006b9:	5e                   	pop    %esi
  8006ba:	5f                   	pop    %edi
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 28             	sub    $0x28,%esp
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	74 30                	je     80070e <vsnprintf+0x51>
  8006de:	85 d2                	test   %edx,%edx
  8006e0:	7e 2c                	jle    80070e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	c7 04 24 bf 02 80 00 	movl   $0x8002bf,(%esp)
  8006fe:	e8 01 fc ff ff       	call   800304 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800703:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800706:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070c:	eb 05                	jmp    800713 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800713:	c9                   	leave  
  800714:	c3                   	ret    

00800715 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800722:	8b 45 10             	mov    0x10(%ebp),%eax
  800725:	89 44 24 08          	mov    %eax,0x8(%esp)
  800729:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	89 04 24             	mov    %eax,(%esp)
  800736:	e8 82 ff ff ff       	call   8006bd <vsnprintf>
	va_end(ap);

	return rc;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    
  80073d:	00 00                	add    %al,(%eax)
	...

00800740 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	80 3a 00             	cmpb   $0x0,(%edx)
  80074e:	74 09                	je     800759 <strlen+0x19>
		n++;
  800750:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800753:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800757:	75 f7                	jne    800750 <strlen+0x10>
		n++;
	return n;
}
  800759:	5d                   	pop    %ebp
  80075a:	c3                   	ret    

0080075b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075b:	55                   	push   %ebp
  80075c:	89 e5                	mov    %esp,%ebp
  80075e:	53                   	push   %ebx
  80075f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
  80076a:	85 c9                	test   %ecx,%ecx
  80076c:	74 1a                	je     800788 <strnlen+0x2d>
  80076e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800771:	74 15                	je     800788 <strnlen+0x2d>
  800773:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800778:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077a:	39 ca                	cmp    %ecx,%edx
  80077c:	74 0a                	je     800788 <strnlen+0x2d>
  80077e:	83 c2 01             	add    $0x1,%edx
  800781:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800786:	75 f0                	jne    800778 <strnlen+0x1d>
		n++;
	return n;
}
  800788:	5b                   	pop    %ebx
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800795:	ba 00 00 00 00       	mov    $0x0,%edx
  80079a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80079e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007a1:	83 c2 01             	add    $0x1,%edx
  8007a4:	84 c9                	test   %cl,%cl
  8007a6:	75 f2                	jne    80079a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	85 f6                	test   %esi,%esi
  8007bb:	74 18                	je     8007d5 <strncpy+0x2a>
  8007bd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007c2:	0f b6 1a             	movzbl (%edx),%ebx
  8007c5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c8:	80 3a 01             	cmpb   $0x1,(%edx)
  8007cb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ce:	83 c1 01             	add    $0x1,%ecx
  8007d1:	39 f1                	cmp    %esi,%ecx
  8007d3:	75 ed                	jne    8007c2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	57                   	push   %edi
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e8:	89 f8                	mov    %edi,%eax
  8007ea:	85 f6                	test   %esi,%esi
  8007ec:	74 2b                	je     800819 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  8007ee:	83 fe 01             	cmp    $0x1,%esi
  8007f1:	74 23                	je     800816 <strlcpy+0x3d>
  8007f3:	0f b6 0b             	movzbl (%ebx),%ecx
  8007f6:	84 c9                	test   %cl,%cl
  8007f8:	74 1c                	je     800816 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8007fa:	83 ee 02             	sub    $0x2,%esi
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800802:	88 08                	mov    %cl,(%eax)
  800804:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800807:	39 f2                	cmp    %esi,%edx
  800809:	74 0b                	je     800816 <strlcpy+0x3d>
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800812:	84 c9                	test   %cl,%cl
  800814:	75 ec                	jne    800802 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800816:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800819:	29 f8                	sub    %edi,%eax
}
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5f                   	pop    %edi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800829:	0f b6 01             	movzbl (%ecx),%eax
  80082c:	84 c0                	test   %al,%al
  80082e:	74 16                	je     800846 <strcmp+0x26>
  800830:	3a 02                	cmp    (%edx),%al
  800832:	75 12                	jne    800846 <strcmp+0x26>
		p++, q++;
  800834:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800837:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80083b:	84 c0                	test   %al,%al
  80083d:	74 07                	je     800846 <strcmp+0x26>
  80083f:	83 c1 01             	add    $0x1,%ecx
  800842:	3a 02                	cmp    (%edx),%al
  800844:	74 ee                	je     800834 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800846:	0f b6 c0             	movzbl %al,%eax
  800849:	0f b6 12             	movzbl (%edx),%edx
  80084c:	29 d0                	sub    %edx,%eax
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800857:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80085a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800862:	85 d2                	test   %edx,%edx
  800864:	74 28                	je     80088e <strncmp+0x3e>
  800866:	0f b6 01             	movzbl (%ecx),%eax
  800869:	84 c0                	test   %al,%al
  80086b:	74 24                	je     800891 <strncmp+0x41>
  80086d:	3a 03                	cmp    (%ebx),%al
  80086f:	75 20                	jne    800891 <strncmp+0x41>
  800871:	83 ea 01             	sub    $0x1,%edx
  800874:	74 13                	je     800889 <strncmp+0x39>
		n--, p++, q++;
  800876:	83 c1 01             	add    $0x1,%ecx
  800879:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087c:	0f b6 01             	movzbl (%ecx),%eax
  80087f:	84 c0                	test   %al,%al
  800881:	74 0e                	je     800891 <strncmp+0x41>
  800883:	3a 03                	cmp    (%ebx),%al
  800885:	74 ea                	je     800871 <strncmp+0x21>
  800887:	eb 08                	jmp    800891 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800891:	0f b6 01             	movzbl (%ecx),%eax
  800894:	0f b6 13             	movzbl (%ebx),%edx
  800897:	29 d0                	sub    %edx,%eax
  800899:	eb f3                	jmp    80088e <strncmp+0x3e>

0080089b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a5:	0f b6 10             	movzbl (%eax),%edx
  8008a8:	84 d2                	test   %dl,%dl
  8008aa:	74 1c                	je     8008c8 <strchr+0x2d>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	75 09                	jne    8008b9 <strchr+0x1e>
  8008b0:	eb 1b                	jmp    8008cd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8008b5:	38 ca                	cmp    %cl,%dl
  8008b7:	74 14                	je     8008cd <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	75 f1                	jne    8008b2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c6:	eb 05                	jmp    8008cd <strchr+0x32>
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d9:	0f b6 10             	movzbl (%eax),%edx
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	74 14                	je     8008f4 <strfind+0x25>
		if (*s == c)
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	75 06                	jne    8008ea <strfind+0x1b>
  8008e4:	eb 0e                	jmp    8008f4 <strfind+0x25>
  8008e6:	38 ca                	cmp    %cl,%dl
  8008e8:	74 0a                	je     8008f4 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f2                	jne    8008e6 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memset>:


void *
memset(void *v, int c, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800900:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800903:	89 da                	mov    %ebx,%edx
  800905:	83 ea 01             	sub    $0x1,%edx
  800908:	78 0d                	js     800917 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80090a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  80090c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  80090e:	88 0a                	mov    %cl,(%edx)
  800910:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800913:	39 da                	cmp    %ebx,%edx
  800915:	75 f7                	jne    80090e <memset+0x18>
		*p++ = c;

	return v;
}
  800917:	5b                   	pop    %ebx
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 75 0c             	mov    0xc(%ebp),%esi
  800926:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800929:	39 c6                	cmp    %eax,%esi
  80092b:	72 0b                	jb     800938 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  80092d:	ba 00 00 00 00       	mov    $0x0,%edx
  800932:	85 db                	test   %ebx,%ebx
  800934:	75 29                	jne    80095f <memmove+0x45>
  800936:	eb 35                	jmp    80096d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800938:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  80093b:	39 c8                	cmp    %ecx,%eax
  80093d:	73 ee                	jae    80092d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  80093f:	85 db                	test   %ebx,%ebx
  800941:	74 2a                	je     80096d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800943:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800946:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800948:	f7 db                	neg    %ebx
  80094a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  80094d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  80094f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800954:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800958:	83 ea 01             	sub    $0x1,%edx
  80095b:	75 f2                	jne    80094f <memmove+0x35>
  80095d:	eb 0e                	jmp    80096d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  80095f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800963:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800966:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800969:	39 d3                	cmp    %edx,%ebx
  80096b:	75 f2                	jne    80095f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800978:	8b 45 10             	mov    0x10(%ebp),%eax
  80097b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800982:	89 44 24 04          	mov    %eax,0x4(%esp)
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	89 04 24             	mov    %eax,(%esp)
  80098c:	e8 89 ff ff ff       	call   80091a <memmove>
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a7:	85 ff                	test   %edi,%edi
  8009a9:	74 37                	je     8009e2 <memcmp+0x4f>
		if (*s1 != *s2)
  8009ab:	0f b6 03             	movzbl (%ebx),%eax
  8009ae:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b1:	83 ef 01             	sub    $0x1,%edi
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8009b9:	38 c8                	cmp    %cl,%al
  8009bb:	74 1c                	je     8009d9 <memcmp+0x46>
  8009bd:	eb 10                	jmp    8009cf <memcmp+0x3c>
  8009bf:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8009c4:	83 c2 01             	add    $0x1,%edx
  8009c7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009cb:	38 c8                	cmp    %cl,%al
  8009cd:	74 0a                	je     8009d9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  8009cf:	0f b6 c0             	movzbl %al,%eax
  8009d2:	0f b6 c9             	movzbl %cl,%ecx
  8009d5:	29 c8                	sub    %ecx,%eax
  8009d7:	eb 09                	jmp    8009e2 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d9:	39 fa                	cmp    %edi,%edx
  8009db:	75 e2                	jne    8009bf <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ed:	89 c2                	mov    %eax,%edx
  8009ef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f2:	39 d0                	cmp    %edx,%eax
  8009f4:	73 15                	jae    800a0b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8009fa:	38 08                	cmp    %cl,(%eax)
  8009fc:	75 06                	jne    800a04 <memfind+0x1d>
  8009fe:	eb 0b                	jmp    800a0b <memfind+0x24>
  800a00:	38 08                	cmp    %cl,(%eax)
  800a02:	74 07                	je     800a0b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a04:	83 c0 01             	add    $0x1,%eax
  800a07:	39 d0                	cmp    %edx,%eax
  800a09:	75 f5                	jne    800a00 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	57                   	push   %edi
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
  800a16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a19:	0f b6 02             	movzbl (%edx),%eax
  800a1c:	3c 20                	cmp    $0x20,%al
  800a1e:	74 04                	je     800a24 <strtol+0x17>
  800a20:	3c 09                	cmp    $0x9,%al
  800a22:	75 0e                	jne    800a32 <strtol+0x25>
		s++;
  800a24:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a27:	0f b6 02             	movzbl (%edx),%eax
  800a2a:	3c 20                	cmp    $0x20,%al
  800a2c:	74 f6                	je     800a24 <strtol+0x17>
  800a2e:	3c 09                	cmp    $0x9,%al
  800a30:	74 f2                	je     800a24 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a32:	3c 2b                	cmp    $0x2b,%al
  800a34:	75 0a                	jne    800a40 <strtol+0x33>
		s++;
  800a36:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a39:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3e:	eb 10                	jmp    800a50 <strtol+0x43>
  800a40:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a45:	3c 2d                	cmp    $0x2d,%al
  800a47:	75 07                	jne    800a50 <strtol+0x43>
		s++, neg = 1;
  800a49:	83 c2 01             	add    $0x1,%edx
  800a4c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a50:	85 db                	test   %ebx,%ebx
  800a52:	0f 94 c0             	sete   %al
  800a55:	74 05                	je     800a5c <strtol+0x4f>
  800a57:	83 fb 10             	cmp    $0x10,%ebx
  800a5a:	75 15                	jne    800a71 <strtol+0x64>
  800a5c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5f:	75 10                	jne    800a71 <strtol+0x64>
  800a61:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a65:	75 0a                	jne    800a71 <strtol+0x64>
		s += 2, base = 16;
  800a67:	83 c2 02             	add    $0x2,%edx
  800a6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6f:	eb 13                	jmp    800a84 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800a71:	84 c0                	test   %al,%al
  800a73:	74 0f                	je     800a84 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a75:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7d:	75 05                	jne    800a84 <strtol+0x77>
		s++, base = 8;
  800a7f:	83 c2 01             	add    $0x1,%edx
  800a82:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
  800a89:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8b:	0f b6 0a             	movzbl (%edx),%ecx
  800a8e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a91:	80 fb 09             	cmp    $0x9,%bl
  800a94:	77 08                	ja     800a9e <strtol+0x91>
			dig = *s - '0';
  800a96:	0f be c9             	movsbl %cl,%ecx
  800a99:	83 e9 30             	sub    $0x30,%ecx
  800a9c:	eb 1e                	jmp    800abc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800a9e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 08                	ja     800aae <strtol+0xa1>
			dig = *s - 'a' + 10;
  800aa6:	0f be c9             	movsbl %cl,%ecx
  800aa9:	83 e9 57             	sub    $0x57,%ecx
  800aac:	eb 0e                	jmp    800abc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800aae:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 14                	ja     800aca <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab6:	0f be c9             	movsbl %cl,%ecx
  800ab9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800abc:	39 f1                	cmp    %esi,%ecx
  800abe:	7d 0e                	jge    800ace <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ac0:	83 c2 01             	add    $0x1,%edx
  800ac3:	0f af c6             	imul   %esi,%eax
  800ac6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ac8:	eb c1                	jmp    800a8b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aca:	89 c1                	mov    %eax,%ecx
  800acc:	eb 02                	jmp    800ad0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ace:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad4:	74 05                	je     800adb <strtol+0xce>
		*endptr = (char *) s;
  800ad6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800adb:	89 ca                	mov    %ecx,%edx
  800add:	f7 da                	neg    %edx
  800adf:	85 ff                	test   %edi,%edi
  800ae1:	0f 45 c2             	cmovne %edx,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    
  800ae9:	00 00                	add    %al,(%eax)
	...

00800aec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800af5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800af8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	8b 55 08             	mov    0x8(%ebp),%edx
  800b06:	89 c3                	mov    %eax,%ebx
  800b08:	89 c7                	mov    %eax,%edi
  800b0a:	89 c6                	mov    %eax,%esi
  800b0c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b11:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b14:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b17:	89 ec                	mov    %ebp,%esp
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b27:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b41:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b44:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b47:	89 ec                	mov    %ebp,%esp
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 38             	sub    $0x38,%esp
  800b51:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b57:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 cb                	mov    %ecx,%ebx
  800b69:	89 cf                	mov    %ecx,%edi
  800b6b:	89 ce                	mov    %ecx,%esi
  800b6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 28                	jle    800b9b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b7e:	00 
  800b7f:	c7 44 24 08 28 11 80 	movl   $0x801128,0x8(%esp)
  800b86:	00 
  800b87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8e:	00 
  800b8f:	c7 04 24 45 11 80 00 	movl   $0x801145,(%esp)
  800b96:	e8 3d 00 00 00       	call   800bd8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b9e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ba1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ba4:	89 ec                	mov    %ebp,%esp
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bb1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bb4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc1:	89 d1                	mov    %edx,%ecx
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	89 d7                	mov    %edx,%edi
  800bc7:	89 d6                	mov    %edx,%esi
  800bc9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bce:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bd1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bd4:	89 ec                	mov    %ebp,%esp
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800bde:	a1 08 20 80 00       	mov    0x802008,%eax
  800be3:	85 c0                	test   %eax,%eax
  800be5:	74 10                	je     800bf7 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800be7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800beb:	c7 04 24 53 11 80 00 	movl   $0x801153,(%esp)
  800bf2:	e8 58 f5 ff ff       	call   80014f <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c05:	a1 00 20 80 00       	mov    0x802000,%eax
  800c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0e:	c7 04 24 58 11 80 00 	movl   $0x801158,(%esp)
  800c15:	e8 35 f5 ff ff       	call   80014f <cprintf>
	vcprintf(fmt, ap);
  800c1a:	8d 45 14             	lea    0x14(%ebp),%eax
  800c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c21:	8b 45 10             	mov    0x10(%ebp),%eax
  800c24:	89 04 24             	mov    %eax,(%esp)
  800c27:	e8 c2 f4 ff ff       	call   8000ee <vcprintf>
	cprintf("\n");
  800c2c:	c7 04 24 f4 0e 80 00 	movl   $0x800ef4,(%esp)
  800c33:	e8 17 f5 ff ff       	call   80014f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c38:	cc                   	int3   
  800c39:	eb fd                	jmp    800c38 <_panic+0x60>
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
