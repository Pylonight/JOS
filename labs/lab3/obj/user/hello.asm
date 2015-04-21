
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
  80003a:	c7 04 24 08 0f 80 00 	movl   $0x800f08,(%esp)
  800041:	e8 21 01 00 00       	call   800167 <cprintf>
	cprintf("i am environment %08x\n", env->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 4c             	mov    0x4c(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 16 0f 80 00 	movl   $0x800f16,(%esp)
  800059:	e8 09 01 00 00       	call   800167 <cprintf>
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
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  800072:	e8 51 0b 00 00       	call   800bc8 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	6b c0 64             	imul   $0x64,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 a9 0a 00 00       	call   800b6b <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ce:	8b 03                	mov    (%ebx),%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000d7:	83 c0 01             	add    $0x1,%eax
  8000da:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e1:	75 19                	jne    8000fc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ea:	00 
  8000eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ee:	89 04 24             	mov    %eax,(%esp)
  8000f1:	e8 16 0a 00 00       	call   800b0c <sys_cputs>
		b->idx = 0;
  8000f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800100:	83 c4 14             	add    $0x14,%esp
  800103:	5b                   	pop    %ebx
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800116:	00 00 00 
	b.cnt = 0;
  800119:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800120:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800123:	8b 45 0c             	mov    0xc(%ebp),%eax
  800126:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012a:	8b 45 08             	mov    0x8(%ebp),%eax
  80012d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800131:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800137:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013b:	c7 04 24 c4 00 80 00 	movl   $0x8000c4,(%esp)
  800142:	e8 dd 01 00 00       	call   800324 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800157:	89 04 24             	mov    %eax,(%esp)
  80015a:	e8 ad 09 00 00       	call   800b0c <sys_cputs>

	return b.cnt;
}
  80015f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80016d:	8d 45 0c             	lea    0xc(%ebp),%eax
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	89 04 24             	mov    %eax,(%esp)
  80017a:	e8 87 ff ff ff       	call   800106 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001b8:	72 11                	jb     8001cb <printnum+0x3b>
  8001ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c0:	76 09                	jbe    8001cb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c2:	83 eb 01             	sub    $0x1,%ebx
  8001c5:	85 db                	test   %ebx,%ebx
  8001c7:	7f 51                	jg     80021a <printnum+0x8a>
  8001c9:	eb 5e                	jmp    800229 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001cf:	83 eb 01             	sub    $0x1,%ebx
  8001d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001e1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ec:	00 
  8001ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	e8 61 0a 00 00       	call   800c60 <__udivdi3>
  8001ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800203:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020e:	89 fa                	mov    %edi,%edx
  800210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800213:	e8 78 ff ff ff       	call   800190 <printnum>
  800218:	eb 0f                	jmp    800229 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021e:	89 34 24             	mov    %esi,(%esp)
  800221:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800224:	83 eb 01             	sub    $0x1,%ebx
  800227:	75 f1                	jne    80021a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800229:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800231:	8b 45 10             	mov    0x10(%ebp),%eax
  800234:	89 44 24 08          	mov    %eax,0x8(%esp)
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024d:	e8 3e 0b 00 00       	call   800d90 <__umoddi3>
  800252:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800256:	0f be 80 44 0f 80 00 	movsbl 0x800f44(%eax),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800263:	83 c4 3c             	add    $0x3c,%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a8:	83 fa 01             	cmp    $0x1,%edx
  8002ab:	7e 0e                	jle    8002bb <getint+0x16>
		return va_arg(*ap, long long);
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b2:	89 08                	mov    %ecx,(%eax)
  8002b4:	8b 02                	mov    (%edx),%eax
  8002b6:	8b 52 04             	mov    0x4(%edx),%edx
  8002b9:	eb 22                	jmp    8002dd <getint+0x38>
	else if (lflag)
  8002bb:	85 d2                	test   %edx,%edx
  8002bd:	74 10                	je     8002cf <getint+0x2a>
		return va_arg(*ap, long);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	89 c2                	mov    %eax,%edx
  8002ca:	c1 fa 1f             	sar    $0x1f,%edx
  8002cd:	eb 0e                	jmp    8002dd <getint+0x38>
	else
		return va_arg(*ap, int);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	89 c2                	mov    %eax,%edx
  8002da:	c1 fa 1f             	sar    $0x1f,%edx
}
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 0a                	jae    8002fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 0a                	mov    %cl,(%edx)
  8002f5:	83 c2 01             	add    $0x1,%edx
  8002f8:	89 10                	mov    %edx,(%eax)
}
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800302:	8d 45 14             	lea    0x14(%ebp),%eax
  800305:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800309:	8b 45 10             	mov    0x10(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
  800313:	89 44 24 04          	mov    %eax,0x4(%esp)
  800317:	8b 45 08             	mov    0x8(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	e8 02 00 00 00       	call   800324 <vprintfmt>
	va_end(ap);
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	53                   	push   %ebx
  80032a:	83 ec 4c             	sub    $0x4c,%esp
  80032d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800330:	8b 75 10             	mov    0x10(%ebp),%esi
  800333:	eb 12                	jmp    800347 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800335:	85 c0                	test   %eax,%eax
  800337:	0f 84 98 03 00 00    	je     8006d5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80033d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800341:	89 04 24             	mov    %eax,(%esp)
  800344:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800347:	0f b6 06             	movzbl (%esi),%eax
  80034a:	83 c6 01             	add    $0x1,%esi
  80034d:	83 f8 25             	cmp    $0x25,%eax
  800350:	75 e3                	jne    800335 <vprintfmt+0x11>
  800352:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800356:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80035d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800362:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800369:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800371:	eb 2b                	jmp    80039e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800373:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800376:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80037a:	eb 22                	jmp    80039e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800383:	eb 19                	jmp    80039e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800388:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80038f:	eb 0d                	jmp    80039e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800391:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800394:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800397:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	0f b6 06             	movzbl (%esi),%eax
  8003a1:	0f b6 d0             	movzbl %al,%edx
  8003a4:	8d 7e 01             	lea    0x1(%esi),%edi
  8003a7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003aa:	83 e8 23             	sub    $0x23,%eax
  8003ad:	3c 55                	cmp    $0x55,%al
  8003af:	0f 87 fa 02 00 00    	ja     8006af <vprintfmt+0x38b>
  8003b5:	0f b6 c0             	movzbl %al,%eax
  8003b8:	ff 24 85 d4 0f 80 00 	jmp    *0x800fd4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bf:	83 ea 30             	sub    $0x30,%edx
  8003c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8003c5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003c9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8003cf:	83 fa 09             	cmp    $0x9,%edx
  8003d2:	77 4a                	ja     80041e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8003da:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003dd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003e4:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003e7:	83 fa 09             	cmp    $0x9,%edx
  8003ea:	76 eb                	jbe    8003d7 <vprintfmt+0xb3>
  8003ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003ef:	eb 2d                	jmp    80041e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 1a                	jmp    80041e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800407:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040b:	79 91                	jns    80039e <vprintfmt+0x7a>
  80040d:	e9 73 ff ff ff       	jmp    800385 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800415:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80041c:	eb 80                	jmp    80039e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80041e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800422:	0f 89 76 ff ff ff    	jns    80039e <vprintfmt+0x7a>
  800428:	e9 64 ff ff ff       	jmp    800391 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800433:	e9 66 ff ff ff       	jmp    80039e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800445:	8b 00                	mov    (%eax),%eax
  800447:	89 04 24             	mov    %eax,(%esp)
  80044a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800450:	e9 f2 fe ff ff       	jmp    800347 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	89 c2                	mov    %eax,%edx
  800462:	c1 fa 1f             	sar    $0x1f,%edx
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 06             	cmp    $0x6,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x155>
  80046e:	8b 14 85 2c 11 80 00 	mov    0x80112c(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 23                	jne    80049c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800479:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047d:	c7 44 24 08 5c 0f 80 	movl   $0x800f5c,0x8(%esp)
  800484:	00 
  800485:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800489:	8b 7d 08             	mov    0x8(%ebp),%edi
  80048c:	89 3c 24             	mov    %edi,(%esp)
  80048f:	e8 68 fe ff ff       	call   8002fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800497:	e9 ab fe ff ff       	jmp    800347 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80049c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a0:	c7 44 24 08 65 0f 80 	movl   $0x800f65,0x8(%esp)
  8004a7:	00 
  8004a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004af:	89 3c 24             	mov    %edi,(%esp)
  8004b2:	e8 45 fe ff ff       	call   8002fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ba:	e9 88 fe ff ff       	jmp    800347 <vprintfmt+0x23>
  8004bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004d3:	85 f6                	test   %esi,%esi
  8004d5:	ba 55 0f 80 00       	mov    $0x800f55,%edx
  8004da:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8004dd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e1:	7e 06                	jle    8004e9 <vprintfmt+0x1c5>
  8004e3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004e7:	75 10                	jne    8004f9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	0f be 06             	movsbl (%esi),%eax
  8004ec:	83 c6 01             	add    $0x1,%esi
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	0f 85 86 00 00 00    	jne    80057d <vprintfmt+0x259>
  8004f7:	eb 76                	jmp    80056f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004fd:	89 34 24             	mov    %esi,(%esp)
  800500:	e8 76 02 00 00       	call   80077b <strnlen>
  800505:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800508:	29 c2                	sub    %eax,%edx
  80050a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80050d:	85 d2                	test   %edx,%edx
  80050f:	7e d8                	jle    8004e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800511:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800515:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800518:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80051b:	89 d6                	mov    %edx,%esi
  80051d:	89 c7                	mov    %eax,%edi
  80051f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800523:	89 3c 24             	mov    %edi,(%esp)
  800526:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 ee 01             	sub    $0x1,%esi
  80052c:	75 f1                	jne    80051f <vprintfmt+0x1fb>
  80052e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800531:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800534:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800537:	eb b0                	jmp    8004e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800539:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053d:	74 18                	je     800557 <vprintfmt+0x233>
  80053f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800542:	83 fa 5e             	cmp    $0x5e,%edx
  800545:	76 10                	jbe    800557 <vprintfmt+0x233>
					putch('?', putdat);
  800547:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800552:	ff 55 08             	call   *0x8(%ebp)
  800555:	eb 0a                	jmp    800561 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800557:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055b:	89 04 24             	mov    %eax,(%esp)
  80055e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800561:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800565:	0f be 06             	movsbl (%esi),%eax
  800568:	83 c6 01             	add    $0x1,%esi
  80056b:	85 c0                	test   %eax,%eax
  80056d:	75 0e                	jne    80057d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800572:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800576:	7f 11                	jg     800589 <vprintfmt+0x265>
  800578:	e9 ca fd ff ff       	jmp    800347 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057d:	85 ff                	test   %edi,%edi
  80057f:	90                   	nop
  800580:	78 b7                	js     800539 <vprintfmt+0x215>
  800582:	83 ef 01             	sub    $0x1,%edi
  800585:	79 b2                	jns    800539 <vprintfmt+0x215>
  800587:	eb e6                	jmp    80056f <vprintfmt+0x24b>
  800589:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80058c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800593:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80059a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	75 ee                	jne    80058f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a4:	e9 9e fd ff ff       	jmp    800347 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a9:	89 ca                	mov    %ecx,%edx
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 f2 fc ff ff       	call   8002a5 <getint>
  8005b3:	89 c6                	mov    %eax,%esi
  8005b5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bc:	85 d2                	test   %edx,%edx
  8005be:	0f 89 ad 00 00 00    	jns    800671 <vprintfmt+0x34d>
				putch('-', putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d2:	f7 de                	neg    %esi
  8005d4:	83 d7 00             	adc    $0x0,%edi
  8005d7:	f7 df                	neg    %edi
			}
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005de:	e9 8e 00 00 00       	jmp    800671 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e3:	89 ca                	mov    %ecx,%edx
  8005e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e8:	e8 7e fc ff ff       	call   80026b <getuint>
  8005ed:	89 c6                	mov    %eax,%esi
  8005ef:	89 d7                	mov    %edx,%edi
			base = 10;
  8005f1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005f6:	eb 79                	jmp    800671 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  8005f8:	89 ca                	mov    %ecx,%edx
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 a3 fc ff ff       	call   8002a5 <getint>
  800602:	89 c6                	mov    %eax,%esi
  800604:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800606:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060b:	85 d2                	test   %edx,%edx
  80060d:	79 62                	jns    800671 <vprintfmt+0x34d>
				putch('-', putdat);
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80061a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80061d:	f7 de                	neg    %esi
  80061f:	83 d7 00             	adc    $0x0,%edi
  800622:	f7 df                	neg    %edi
			}
			base = 8;
  800624:	b8 08 00 00 00       	mov    $0x8,%eax
  800629:	eb 46                	jmp    800671 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80062b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80062f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800636:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800639:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800644:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800650:	8b 30                	mov    (%eax),%esi
  800652:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800657:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80065c:	eb 13                	jmp    800671 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80065e:	89 ca                	mov    %ecx,%edx
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 03 fc ff ff       	call   80026b <getuint>
  800668:	89 c6                	mov    %eax,%esi
  80066a:	89 d7                	mov    %edx,%edi
			base = 16;
  80066c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800671:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800675:	89 54 24 10          	mov    %edx,0x10(%esp)
  800679:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800680:	89 44 24 08          	mov    %eax,0x8(%esp)
  800684:	89 34 24             	mov    %esi,(%esp)
  800687:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068b:	89 da                	mov    %ebx,%edx
  80068d:	8b 45 08             	mov    0x8(%ebp),%eax
  800690:	e8 fb fa ff ff       	call   800190 <printnum>
			break;
  800695:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800698:	e9 aa fc ff ff       	jmp    800347 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80069d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a1:	89 14 24             	mov    %edx,(%esp)
  8006a4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006aa:	e9 98 fc ff ff       	jmp    800347 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ba:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006c1:	0f 84 80 fc ff ff    	je     800347 <vprintfmt+0x23>
  8006c7:	83 ee 01             	sub    $0x1,%esi
  8006ca:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006ce:	75 f7                	jne    8006c7 <vprintfmt+0x3a3>
  8006d0:	e9 72 fc ff ff       	jmp    800347 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006d5:	83 c4 4c             	add    $0x4c,%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5f                   	pop    %edi
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 28             	sub    $0x28,%esp
  8006e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	74 30                	je     80072e <vsnprintf+0x51>
  8006fe:	85 d2                	test   %edx,%edx
  800700:	7e 2c                	jle    80072e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800709:	8b 45 10             	mov    0x10(%ebp),%eax
  80070c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800710:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800713:	89 44 24 04          	mov    %eax,0x4(%esp)
  800717:	c7 04 24 df 02 80 00 	movl   $0x8002df,(%esp)
  80071e:	e8 01 fc ff ff       	call   800324 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800723:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800726:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072c:	eb 05                	jmp    800733 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800742:	8b 45 10             	mov    0x10(%ebp),%eax
  800745:	89 44 24 08          	mov    %eax,0x8(%esp)
  800749:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 82 ff ff ff       	call   8006dd <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    
  80075d:	00 00                	add    %al,(%eax)
	...

00800760 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	80 3a 00             	cmpb   $0x0,(%edx)
  80076e:	74 09                	je     800779 <strlen+0x19>
		n++;
  800770:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800773:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800777:	75 f7                	jne    800770 <strlen+0x10>
		n++;
	return n;
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	85 c9                	test   %ecx,%ecx
  80078c:	74 1a                	je     8007a8 <strnlen+0x2d>
  80078e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800791:	74 15                	je     8007a8 <strnlen+0x2d>
  800793:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800798:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079a:	39 ca                	cmp    %ecx,%edx
  80079c:	74 0a                	je     8007a8 <strnlen+0x2d>
  80079e:	83 c2 01             	add    $0x1,%edx
  8007a1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007a6:	75 f0                	jne    800798 <strnlen+0x1d>
		n++;
	return n;
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ba:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007be:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	84 c9                	test   %cl,%cl
  8007c6:	75 f2                	jne    8007ba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	85 f6                	test   %esi,%esi
  8007db:	74 18                	je     8007f5 <strncpy+0x2a>
  8007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8007e2:	0f b6 1a             	movzbl (%edx),%ebx
  8007e5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e8:	80 3a 01             	cmpb   $0x1,(%edx)
  8007eb:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ee:	83 c1 01             	add    $0x1,%ecx
  8007f1:	39 f1                	cmp    %esi,%ecx
  8007f3:	75 ed                	jne    8007e2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5e                   	pop    %esi
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	57                   	push   %edi
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800805:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800808:	89 f8                	mov    %edi,%eax
  80080a:	85 f6                	test   %esi,%esi
  80080c:	74 2b                	je     800839 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80080e:	83 fe 01             	cmp    $0x1,%esi
  800811:	74 23                	je     800836 <strlcpy+0x3d>
  800813:	0f b6 0b             	movzbl (%ebx),%ecx
  800816:	84 c9                	test   %cl,%cl
  800818:	74 1c                	je     800836 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80081a:	83 ee 02             	sub    $0x2,%esi
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	88 08                	mov    %cl,(%eax)
  800824:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800827:	39 f2                	cmp    %esi,%edx
  800829:	74 0b                	je     800836 <strlcpy+0x3d>
  80082b:	83 c2 01             	add    $0x1,%edx
  80082e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800832:	84 c9                	test   %cl,%cl
  800834:	75 ec                	jne    800822 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800836:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800839:	29 f8                	sub    %edi,%eax
}
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5f                   	pop    %edi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	84 c0                	test   %al,%al
  80084e:	74 16                	je     800866 <strcmp+0x26>
  800850:	3a 02                	cmp    (%edx),%al
  800852:	75 12                	jne    800866 <strcmp+0x26>
		p++, q++;
  800854:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800857:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80085b:	84 c0                	test   %al,%al
  80085d:	74 07                	je     800866 <strcmp+0x26>
  80085f:	83 c1 01             	add    $0x1,%ecx
  800862:	3a 02                	cmp    (%edx),%al
  800864:	74 ee                	je     800854 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800866:	0f b6 c0             	movzbl %al,%eax
  800869:	0f b6 12             	movzbl (%edx),%edx
  80086c:	29 d0                	sub    %edx,%eax
}
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800877:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80087a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800882:	85 d2                	test   %edx,%edx
  800884:	74 28                	je     8008ae <strncmp+0x3e>
  800886:	0f b6 01             	movzbl (%ecx),%eax
  800889:	84 c0                	test   %al,%al
  80088b:	74 24                	je     8008b1 <strncmp+0x41>
  80088d:	3a 03                	cmp    (%ebx),%al
  80088f:	75 20                	jne    8008b1 <strncmp+0x41>
  800891:	83 ea 01             	sub    $0x1,%edx
  800894:	74 13                	je     8008a9 <strncmp+0x39>
		n--, p++, q++;
  800896:	83 c1 01             	add    $0x1,%ecx
  800899:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089c:	0f b6 01             	movzbl (%ecx),%eax
  80089f:	84 c0                	test   %al,%al
  8008a1:	74 0e                	je     8008b1 <strncmp+0x41>
  8008a3:	3a 03                	cmp    (%ebx),%al
  8008a5:	74 ea                	je     800891 <strncmp+0x21>
  8008a7:	eb 08                	jmp    8008b1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 01             	movzbl (%ecx),%eax
  8008b4:	0f b6 13             	movzbl (%ebx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
  8008b9:	eb f3                	jmp    8008ae <strncmp+0x3e>

008008bb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	0f b6 10             	movzbl (%eax),%edx
  8008c8:	84 d2                	test   %dl,%dl
  8008ca:	74 1c                	je     8008e8 <strchr+0x2d>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	75 09                	jne    8008d9 <strchr+0x1e>
  8008d0:	eb 1b                	jmp    8008ed <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 14                	je     8008ed <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  8008dd:	84 d2                	test   %dl,%dl
  8008df:	75 f1                	jne    8008d2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	eb 05                	jmp    8008ed <strchr+0x32>
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f9:	0f b6 10             	movzbl (%eax),%edx
  8008fc:	84 d2                	test   %dl,%dl
  8008fe:	74 14                	je     800914 <strfind+0x25>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	75 06                	jne    80090a <strfind+0x1b>
  800904:	eb 0e                	jmp    800914 <strfind+0x25>
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0a                	je     800914 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800920:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800923:	89 da                	mov    %ebx,%edx
  800925:	83 ea 01             	sub    $0x1,%edx
  800928:	78 0d                	js     800937 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80092a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  80092c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  80092e:	88 0a                	mov    %cl,(%edx)
  800930:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800933:	39 da                	cmp    %ebx,%edx
  800935:	75 f7                	jne    80092e <memset+0x18>
		*p++ = c;

	return v;
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 75 0c             	mov    0xc(%ebp),%esi
  800946:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800949:	39 c6                	cmp    %eax,%esi
  80094b:	72 0b                	jb     800958 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	85 db                	test   %ebx,%ebx
  800954:	75 29                	jne    80097f <memmove+0x45>
  800956:	eb 35                	jmp    80098d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800958:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  80095b:	39 c8                	cmp    %ecx,%eax
  80095d:	73 ee                	jae    80094d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  80095f:	85 db                	test   %ebx,%ebx
  800961:	74 2a                	je     80098d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800963:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800966:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800968:	f7 db                	neg    %ebx
  80096a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  80096d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  80096f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800974:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800978:	83 ea 01             	sub    $0x1,%edx
  80097b:	75 f2                	jne    80096f <memmove+0x35>
  80097d:	eb 0e                	jmp    80098d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  80097f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800983:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800986:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800989:	39 d3                	cmp    %edx,%ebx
  80098b:	75 f2                	jne    80097f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800998:	8b 45 10             	mov    0x10(%ebp),%eax
  80099b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	89 04 24             	mov    %eax,(%esp)
  8009ac:	e8 89 ff ff ff       	call   80093a <memmove>
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bf:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c7:	85 ff                	test   %edi,%edi
  8009c9:	74 37                	je     800a02 <memcmp+0x4f>
		if (*s1 != *s2)
  8009cb:	0f b6 03             	movzbl (%ebx),%eax
  8009ce:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d1:	83 ef 01             	sub    $0x1,%edi
  8009d4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  8009d9:	38 c8                	cmp    %cl,%al
  8009db:	74 1c                	je     8009f9 <memcmp+0x46>
  8009dd:	eb 10                	jmp    8009ef <memcmp+0x3c>
  8009df:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  8009e4:	83 c2 01             	add    $0x1,%edx
  8009e7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009eb:	38 c8                	cmp    %cl,%al
  8009ed:	74 0a                	je     8009f9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  8009ef:	0f b6 c0             	movzbl %al,%eax
  8009f2:	0f b6 c9             	movzbl %cl,%ecx
  8009f5:	29 c8                	sub    %ecx,%eax
  8009f7:	eb 09                	jmp    800a02 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 fa                	cmp    %edi,%edx
  8009fb:	75 e2                	jne    8009df <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0d:	89 c2                	mov    %eax,%edx
  800a0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a12:	39 d0                	cmp    %edx,%eax
  800a14:	73 15                	jae    800a2b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a16:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a1a:	38 08                	cmp    %cl,(%eax)
  800a1c:	75 06                	jne    800a24 <memfind+0x1d>
  800a1e:	eb 0b                	jmp    800a2b <memfind+0x24>
  800a20:	38 08                	cmp    %cl,(%eax)
  800a22:	74 07                	je     800a2b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	39 d0                	cmp    %edx,%eax
  800a29:	75 f5                	jne    800a20 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
  800a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a39:	0f b6 02             	movzbl (%edx),%eax
  800a3c:	3c 20                	cmp    $0x20,%al
  800a3e:	74 04                	je     800a44 <strtol+0x17>
  800a40:	3c 09                	cmp    $0x9,%al
  800a42:	75 0e                	jne    800a52 <strtol+0x25>
		s++;
  800a44:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a47:	0f b6 02             	movzbl (%edx),%eax
  800a4a:	3c 20                	cmp    $0x20,%al
  800a4c:	74 f6                	je     800a44 <strtol+0x17>
  800a4e:	3c 09                	cmp    $0x9,%al
  800a50:	74 f2                	je     800a44 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a52:	3c 2b                	cmp    $0x2b,%al
  800a54:	75 0a                	jne    800a60 <strtol+0x33>
		s++;
  800a56:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5e:	eb 10                	jmp    800a70 <strtol+0x43>
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a65:	3c 2d                	cmp    $0x2d,%al
  800a67:	75 07                	jne    800a70 <strtol+0x43>
		s++, neg = 1;
  800a69:	83 c2 01             	add    $0x1,%edx
  800a6c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	85 db                	test   %ebx,%ebx
  800a72:	0f 94 c0             	sete   %al
  800a75:	74 05                	je     800a7c <strtol+0x4f>
  800a77:	83 fb 10             	cmp    $0x10,%ebx
  800a7a:	75 15                	jne    800a91 <strtol+0x64>
  800a7c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7f:	75 10                	jne    800a91 <strtol+0x64>
  800a81:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a85:	75 0a                	jne    800a91 <strtol+0x64>
		s += 2, base = 16;
  800a87:	83 c2 02             	add    $0x2,%edx
  800a8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8f:	eb 13                	jmp    800aa4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800a91:	84 c0                	test   %al,%al
  800a93:	74 0f                	je     800aa4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a9d:	75 05                	jne    800aa4 <strtol+0x77>
		s++, base = 8;
  800a9f:	83 c2 01             	add    $0x1,%edx
  800aa2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aab:	0f b6 0a             	movzbl (%edx),%ecx
  800aae:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab1:	80 fb 09             	cmp    $0x9,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x91>
			dig = *s - '0';
  800ab6:	0f be c9             	movsbl %cl,%ecx
  800ab9:	83 e9 30             	sub    $0x30,%ecx
  800abc:	eb 1e                	jmp    800adc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800abe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 08                	ja     800ace <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ac6:	0f be c9             	movsbl %cl,%ecx
  800ac9:	83 e9 57             	sub    $0x57,%ecx
  800acc:	eb 0e                	jmp    800adc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800ace:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 14                	ja     800aea <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad6:	0f be c9             	movsbl %cl,%ecx
  800ad9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800adc:	39 f1                	cmp    %esi,%ecx
  800ade:	7d 0e                	jge    800aee <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ae0:	83 c2 01             	add    $0x1,%edx
  800ae3:	0f af c6             	imul   %esi,%eax
  800ae6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ae8:	eb c1                	jmp    800aab <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aea:	89 c1                	mov    %eax,%ecx
  800aec:	eb 02                	jmp    800af0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aee:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800af0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af4:	74 05                	je     800afb <strtol+0xce>
		*endptr = (char *) s;
  800af6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800afb:	89 ca                	mov    %ecx,%edx
  800afd:	f7 da                	neg    %edx
  800aff:	85 ff                	test   %edi,%edi
  800b01:	0f 45 c2             	cmovne %edx,%eax
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    
  800b09:	00 00                	add    %al,(%eax)
	...

00800b0c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b18:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	89 c7                	mov    %eax,%edi
  800b2a:	89 c6                	mov    %eax,%esi
  800b2c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b31:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b34:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b37:	89 ec                	mov    %ebp,%esp
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b44:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b47:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b54:	89 d1                	mov    %edx,%ecx
  800b56:	89 d3                	mov    %edx,%ebx
  800b58:	89 d7                	mov    %edx,%edi
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b61:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b64:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b67:	89 ec                	mov    %ebp,%esp
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	83 ec 38             	sub    $0x38,%esp
  800b71:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b74:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b77:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7e 28                	jle    800bbb <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b97:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 08 48 11 80 	movl   $0x801148,0x8(%esp)
  800ba6:	00 
  800ba7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bae:	00 
  800baf:	c7 04 24 65 11 80 00 	movl   $0x801165,(%esp)
  800bb6:	e8 3d 00 00 00       	call   800bf8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bbb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bbe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc4:	89 ec                	mov    %ebp,%esp
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bd1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 02 00 00 00       	mov    $0x2,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800beb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bf1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bf4:	89 ec                	mov    %ebp,%esp
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800bfe:	a1 08 20 80 00       	mov    0x802008,%eax
  800c03:	85 c0                	test   %eax,%eax
  800c05:	74 10                	je     800c17 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800c07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0b:	c7 04 24 73 11 80 00 	movl   $0x801173,(%esp)
  800c12:	e8 50 f5 ff ff       	call   800167 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c25:	a1 00 20 80 00       	mov    0x802000,%eax
  800c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2e:	c7 04 24 78 11 80 00 	movl   $0x801178,(%esp)
  800c35:	e8 2d f5 ff ff       	call   800167 <cprintf>
	vcprintf(fmt, ap);
  800c3a:	8d 45 14             	lea    0x14(%ebp),%eax
  800c3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c41:	8b 45 10             	mov    0x10(%ebp),%eax
  800c44:	89 04 24             	mov    %eax,(%esp)
  800c47:	e8 ba f4 ff ff       	call   800106 <vcprintf>
	cprintf("\n");
  800c4c:	c7 04 24 14 0f 80 00 	movl   $0x800f14,(%esp)
  800c53:	e8 0f f5 ff ff       	call   800167 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c58:	cc                   	int3   
  800c59:	eb fd                	jmp    800c58 <_panic+0x60>
  800c5b:	00 00                	add    %al,(%eax)
  800c5d:	00 00                	add    %al,(%eax)
	...

00800c60 <__udivdi3>:
  800c60:	83 ec 1c             	sub    $0x1c,%esp
  800c63:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800c67:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800c6b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800c6f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800c73:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c77:	8b 74 24 24          	mov    0x24(%esp),%esi
  800c7b:	85 ff                	test   %edi,%edi
  800c7d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800c81:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c85:	89 cd                	mov    %ecx,%ebp
  800c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8b:	75 33                	jne    800cc0 <__udivdi3+0x60>
  800c8d:	39 f1                	cmp    %esi,%ecx
  800c8f:	77 57                	ja     800ce8 <__udivdi3+0x88>
  800c91:	85 c9                	test   %ecx,%ecx
  800c93:	75 0b                	jne    800ca0 <__udivdi3+0x40>
  800c95:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9a:	31 d2                	xor    %edx,%edx
  800c9c:	f7 f1                	div    %ecx
  800c9e:	89 c1                	mov    %eax,%ecx
  800ca0:	89 f0                	mov    %esi,%eax
  800ca2:	31 d2                	xor    %edx,%edx
  800ca4:	f7 f1                	div    %ecx
  800ca6:	89 c6                	mov    %eax,%esi
  800ca8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800cac:	f7 f1                	div    %ecx
  800cae:	89 f2                	mov    %esi,%edx
  800cb0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800cb4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800cb8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800cbc:	83 c4 1c             	add    $0x1c,%esp
  800cbf:	c3                   	ret    
  800cc0:	31 d2                	xor    %edx,%edx
  800cc2:	31 c0                	xor    %eax,%eax
  800cc4:	39 f7                	cmp    %esi,%edi
  800cc6:	77 e8                	ja     800cb0 <__udivdi3+0x50>
  800cc8:	0f bd cf             	bsr    %edi,%ecx
  800ccb:	83 f1 1f             	xor    $0x1f,%ecx
  800cce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cd2:	75 2c                	jne    800d00 <__udivdi3+0xa0>
  800cd4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800cd8:	76 04                	jbe    800cde <__udivdi3+0x7e>
  800cda:	39 f7                	cmp    %esi,%edi
  800cdc:	73 d2                	jae    800cb0 <__udivdi3+0x50>
  800cde:	31 d2                	xor    %edx,%edx
  800ce0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce5:	eb c9                	jmp    800cb0 <__udivdi3+0x50>
  800ce7:	90                   	nop
  800ce8:	89 f2                	mov    %esi,%edx
  800cea:	f7 f1                	div    %ecx
  800cec:	31 d2                	xor    %edx,%edx
  800cee:	8b 74 24 10          	mov    0x10(%esp),%esi
  800cf2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800cf6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800cfa:	83 c4 1c             	add    $0x1c,%esp
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax
  800d00:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d05:	b8 20 00 00 00       	mov    $0x20,%eax
  800d0a:	89 ea                	mov    %ebp,%edx
  800d0c:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d10:	d3 e7                	shl    %cl,%edi
  800d12:	89 c1                	mov    %eax,%ecx
  800d14:	d3 ea                	shr    %cl,%edx
  800d16:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d1b:	09 fa                	or     %edi,%edx
  800d1d:	89 f7                	mov    %esi,%edi
  800d1f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d23:	89 f2                	mov    %esi,%edx
  800d25:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d29:	d3 e5                	shl    %cl,%ebp
  800d2b:	89 c1                	mov    %eax,%ecx
  800d2d:	d3 ef                	shr    %cl,%edi
  800d2f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d34:	d3 e2                	shl    %cl,%edx
  800d36:	89 c1                	mov    %eax,%ecx
  800d38:	d3 ee                	shr    %cl,%esi
  800d3a:	09 d6                	or     %edx,%esi
  800d3c:	89 fa                	mov    %edi,%edx
  800d3e:	89 f0                	mov    %esi,%eax
  800d40:	f7 74 24 0c          	divl   0xc(%esp)
  800d44:	89 d7                	mov    %edx,%edi
  800d46:	89 c6                	mov    %eax,%esi
  800d48:	f7 e5                	mul    %ebp
  800d4a:	39 d7                	cmp    %edx,%edi
  800d4c:	72 22                	jb     800d70 <__udivdi3+0x110>
  800d4e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  800d52:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800d57:	d3 e5                	shl    %cl,%ebp
  800d59:	39 c5                	cmp    %eax,%ebp
  800d5b:	73 04                	jae    800d61 <__udivdi3+0x101>
  800d5d:	39 d7                	cmp    %edx,%edi
  800d5f:	74 0f                	je     800d70 <__udivdi3+0x110>
  800d61:	89 f0                	mov    %esi,%eax
  800d63:	31 d2                	xor    %edx,%edx
  800d65:	e9 46 ff ff ff       	jmp    800cb0 <__udivdi3+0x50>
  800d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d70:	8d 46 ff             	lea    -0x1(%esi),%eax
  800d73:	31 d2                	xor    %edx,%edx
  800d75:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d79:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800d7d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800d81:	83 c4 1c             	add    $0x1c,%esp
  800d84:	c3                   	ret    
	...

00800d90 <__umoddi3>:
  800d90:	83 ec 1c             	sub    $0x1c,%esp
  800d93:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800d97:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  800d9b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800d9f:	89 74 24 10          	mov    %esi,0x10(%esp)
  800da3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800da7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800dab:	85 ed                	test   %ebp,%ebp
  800dad:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800db1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db5:	89 cf                	mov    %ecx,%edi
  800db7:	89 04 24             	mov    %eax,(%esp)
  800dba:	89 f2                	mov    %esi,%edx
  800dbc:	75 1a                	jne    800dd8 <__umoddi3+0x48>
  800dbe:	39 f1                	cmp    %esi,%ecx
  800dc0:	76 4e                	jbe    800e10 <__umoddi3+0x80>
  800dc2:	f7 f1                	div    %ecx
  800dc4:	89 d0                	mov    %edx,%eax
  800dc6:	31 d2                	xor    %edx,%edx
  800dc8:	8b 74 24 10          	mov    0x10(%esp),%esi
  800dcc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800dd0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800dd4:	83 c4 1c             	add    $0x1c,%esp
  800dd7:	c3                   	ret    
  800dd8:	39 f5                	cmp    %esi,%ebp
  800dda:	77 54                	ja     800e30 <__umoddi3+0xa0>
  800ddc:	0f bd c5             	bsr    %ebp,%eax
  800ddf:	83 f0 1f             	xor    $0x1f,%eax
  800de2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de6:	75 60                	jne    800e48 <__umoddi3+0xb8>
  800de8:	3b 0c 24             	cmp    (%esp),%ecx
  800deb:	0f 87 07 01 00 00    	ja     800ef8 <__umoddi3+0x168>
  800df1:	89 f2                	mov    %esi,%edx
  800df3:	8b 34 24             	mov    (%esp),%esi
  800df6:	29 ce                	sub    %ecx,%esi
  800df8:	19 ea                	sbb    %ebp,%edx
  800dfa:	89 34 24             	mov    %esi,(%esp)
  800dfd:	8b 04 24             	mov    (%esp),%eax
  800e00:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e04:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e08:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e0c:	83 c4 1c             	add    $0x1c,%esp
  800e0f:	c3                   	ret    
  800e10:	85 c9                	test   %ecx,%ecx
  800e12:	75 0b                	jne    800e1f <__umoddi3+0x8f>
  800e14:	b8 01 00 00 00       	mov    $0x1,%eax
  800e19:	31 d2                	xor    %edx,%edx
  800e1b:	f7 f1                	div    %ecx
  800e1d:	89 c1                	mov    %eax,%ecx
  800e1f:	89 f0                	mov    %esi,%eax
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	f7 f1                	div    %ecx
  800e25:	8b 04 24             	mov    (%esp),%eax
  800e28:	f7 f1                	div    %ecx
  800e2a:	eb 98                	jmp    800dc4 <__umoddi3+0x34>
  800e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e30:	89 f2                	mov    %esi,%edx
  800e32:	8b 74 24 10          	mov    0x10(%esp),%esi
  800e36:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800e3a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800e3e:	83 c4 1c             	add    $0x1c,%esp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e4d:	89 e8                	mov    %ebp,%eax
  800e4f:	bd 20 00 00 00       	mov    $0x20,%ebp
  800e54:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	d3 e0                	shl    %cl,%eax
  800e5c:	89 e9                	mov    %ebp,%ecx
  800e5e:	d3 ea                	shr    %cl,%edx
  800e60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e65:	09 c2                	or     %eax,%edx
  800e67:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e6b:	89 14 24             	mov    %edx,(%esp)
  800e6e:	89 f2                	mov    %esi,%edx
  800e70:	d3 e7                	shl    %cl,%edi
  800e72:	89 e9                	mov    %ebp,%ecx
  800e74:	d3 ea                	shr    %cl,%edx
  800e76:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e7f:	d3 e6                	shl    %cl,%esi
  800e81:	89 e9                	mov    %ebp,%ecx
  800e83:	d3 e8                	shr    %cl,%eax
  800e85:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e8a:	09 f0                	or     %esi,%eax
  800e8c:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e90:	f7 34 24             	divl   (%esp)
  800e93:	d3 e6                	shl    %cl,%esi
  800e95:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e99:	89 d6                	mov    %edx,%esi
  800e9b:	f7 e7                	mul    %edi
  800e9d:	39 d6                	cmp    %edx,%esi
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 d7                	mov    %edx,%edi
  800ea3:	72 3f                	jb     800ee4 <__umoddi3+0x154>
  800ea5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800ea9:	72 35                	jb     800ee0 <__umoddi3+0x150>
  800eab:	8b 44 24 08          	mov    0x8(%esp),%eax
  800eaf:	29 c8                	sub    %ecx,%eax
  800eb1:	19 fe                	sbb    %edi,%esi
  800eb3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eb8:	89 f2                	mov    %esi,%edx
  800eba:	d3 e8                	shr    %cl,%eax
  800ebc:	89 e9                	mov    %ebp,%ecx
  800ebe:	d3 e2                	shl    %cl,%edx
  800ec0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ec5:	09 d0                	or     %edx,%eax
  800ec7:	89 f2                	mov    %esi,%edx
  800ec9:	d3 ea                	shr    %cl,%edx
  800ecb:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ecf:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ed3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ed7:	83 c4 1c             	add    $0x1c,%esp
  800eda:	c3                   	ret    
  800edb:	90                   	nop
  800edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	39 d6                	cmp    %edx,%esi
  800ee2:	75 c7                	jne    800eab <__umoddi3+0x11b>
  800ee4:	89 d7                	mov    %edx,%edi
  800ee6:	89 c1                	mov    %eax,%ecx
  800ee8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  800eec:	1b 3c 24             	sbb    (%esp),%edi
  800eef:	eb ba                	jmp    800eab <__umoddi3+0x11b>
  800ef1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef8:	39 f5                	cmp    %esi,%ebp
  800efa:	0f 82 f1 fe ff ff    	jb     800df1 <__umoddi3+0x61>
  800f00:	e9 f8 fe ff ff       	jmp    800dfd <__umoddi3+0x6d>
