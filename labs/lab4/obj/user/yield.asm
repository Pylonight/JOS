
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", env->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 4c             	mov    0x4c(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  80004e:	e8 54 01 00 00       	call   8001a7 <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 db 0b 00 00       	call   800c38 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			env->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", env->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 4c             	mov    0x4c(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 80 12 80 00 	movl   $0x801280,(%esp)
  800074:	e8 2e 01 00 00       	call   8001a7 <cprintf>
umain(void)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", env->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			env->env_id, i);
	}
	cprintf("All done in environment %08x.\n", env->env_id);
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 40 4c             	mov    0x4c(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 ac 12 80 00 	movl   $0x8012ac,(%esp)
  800094:	e8 0e 01 00 00       	call   8001a7 <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  8000b2:	e8 51 0b 00 00       	call   800c08 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 f6                	test   %esi,%esi
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 03                	mov    (%ebx),%eax
  8000cf:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 a9 0a 00 00       	call   800bab <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	53                   	push   %ebx
  800108:	83 ec 14             	sub    $0x14,%esp
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010e:	8b 03                	mov    (%ebx),%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800117:	83 c0 01             	add    $0x1,%eax
  80011a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80011c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800121:	75 19                	jne    80013c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800123:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80012a:	00 
  80012b:	8d 43 08             	lea    0x8(%ebx),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 16 0a 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  800136:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	83 c4 14             	add    $0x14,%esp
  800143:	5b                   	pop    %ebx
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80014f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800156:	00 00 00 
	b.cnt = 0;
  800159:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800160:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800163:	8b 45 0c             	mov    0xc(%ebp),%eax
  800166:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800171:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017b:	c7 04 24 04 01 80 00 	movl   $0x800104,(%esp)
  800182:	e8 dd 01 00 00       	call   800364 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 ad 09 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  80019f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 87 ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 3c             	sub    $0x3c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d7                	mov    %edx,%edi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001ed:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001f8:	72 11                	jb     80020b <printnum+0x3b>
  8001fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800200:	76 09                	jbe    80020b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800202:	83 eb 01             	sub    $0x1,%ebx
  800205:	85 db                	test   %ebx,%ebx
  800207:	7f 51                	jg     80025a <printnum+0x8a>
  800209:	eb 5e                	jmp    800269 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80020f:	83 eb 01             	sub    $0x1,%ebx
  800212:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800216:	8b 45 10             	mov    0x10(%ebp),%eax
  800219:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800221:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800225:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022c:	00 
  80022d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	e8 61 0d 00 00       	call   800fa0 <__udivdi3>
  80023f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800243:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800247:	89 04 24             	mov    %eax,(%esp)
  80024a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024e:	89 fa                	mov    %edi,%edx
  800250:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800253:	e8 78 ff ff ff       	call   8001d0 <printnum>
  800258:	eb 0f                	jmp    800269 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80025a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025e:	89 34 24             	mov    %esi,(%esp)
  800261:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800264:	83 eb 01             	sub    $0x1,%ebx
  800267:	75 f1                	jne    80025a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800269:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800271:	8b 45 10             	mov    0x10(%ebp),%eax
  800274:	89 44 24 08          	mov    %eax,0x8(%esp)
  800278:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027f:	00 
  800280:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800289:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028d:	e8 3e 0e 00 00       	call   8010d0 <__umoddi3>
  800292:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800296:	0f be 80 e3 12 80 00 	movsbl 0x8012e3(%eax),%eax
  80029d:	89 04 24             	mov    %eax,(%esp)
  8002a0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002a3:	83 c4 3c             	add    $0x3c,%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5e                   	pop    %esi
  8002a8:	5f                   	pop    %edi
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ae:	83 fa 01             	cmp    $0x1,%edx
  8002b1:	7e 0e                	jle    8002c1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 02                	mov    (%edx),%eax
  8002bc:	8b 52 04             	mov    0x4(%edx),%edx
  8002bf:	eb 22                	jmp    8002e3 <getuint+0x38>
	else if (lflag)
  8002c1:	85 d2                	test   %edx,%edx
  8002c3:	74 10                	je     8002d5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 02                	mov    (%edx),%eax
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d3:	eb 0e                	jmp    8002e3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 02                	mov    (%edx),%eax
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e8:	83 fa 01             	cmp    $0x1,%edx
  8002eb:	7e 0e                	jle    8002fb <getint+0x16>
		return va_arg(*ap, long long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	8b 52 04             	mov    0x4(%edx),%edx
  8002f9:	eb 22                	jmp    80031d <getint+0x38>
	else if (lflag)
  8002fb:	85 d2                	test   %edx,%edx
  8002fd:	74 10                	je     80030f <getint+0x2a>
		return va_arg(*ap, long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	89 c2                	mov    %eax,%edx
  80030a:	c1 fa 1f             	sar    $0x1f,%edx
  80030d:	eb 0e                	jmp    80031d <getint+0x38>
	else
		return va_arg(*ap, int);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	89 c2                	mov    %eax,%edx
  80031a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800325:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	3b 50 04             	cmp    0x4(%eax),%edx
  80032e:	73 0a                	jae    80033a <sprintputch+0x1b>
		*b->buf++ = ch;
  800330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800333:	88 0a                	mov    %cl,(%edx)
  800335:	83 c2 01             	add    $0x1,%edx
  800338:	89 10                	mov    %edx,(%eax)
}
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800342:	8d 45 14             	lea    0x14(%ebp),%eax
  800345:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800349:	8b 45 10             	mov    0x10(%ebp),%eax
  80034c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800350:	8b 45 0c             	mov    0xc(%ebp),%eax
  800353:	89 44 24 04          	mov    %eax,0x4(%esp)
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	89 04 24             	mov    %eax,(%esp)
  80035d:	e8 02 00 00 00       	call   800364 <vprintfmt>
	va_end(ap);
}
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
  80036a:	83 ec 4c             	sub    $0x4c,%esp
  80036d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800370:	8b 75 10             	mov    0x10(%ebp),%esi
  800373:	eb 12                	jmp    800387 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800375:	85 c0                	test   %eax,%eax
  800377:	0f 84 98 03 00 00    	je     800715 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80037d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800381:	89 04 24             	mov    %eax,(%esp)
  800384:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800387:	0f b6 06             	movzbl (%esi),%eax
  80038a:	83 c6 01             	add    $0x1,%esi
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e3                	jne    800375 <vprintfmt+0x11>
  800392:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800396:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80039d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003b1:	eb 2b                	jmp    8003de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ba:	eb 22                	jmp    8003de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bf:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003c3:	eb 19                	jmp    8003de <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003cf:	eb 0d                	jmp    8003de <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	0f b6 06             	movzbl (%esi),%eax
  8003e1:	0f b6 d0             	movzbl %al,%edx
  8003e4:	8d 7e 01             	lea    0x1(%esi),%edi
  8003e7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8003ea:	83 e8 23             	sub    $0x23,%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 fa 02 00 00    	ja     8006ef <vprintfmt+0x38b>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	ff 24 85 a0 13 80 00 	jmp    *0x8013a0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ff:	83 ea 30             	sub    $0x30,%edx
  800402:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800405:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800409:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80040f:	83 fa 09             	cmp    $0x9,%edx
  800412:	77 4a                	ja     80045e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800417:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80041a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80041d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800421:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800424:	8d 50 d0             	lea    -0x30(%eax),%edx
  800427:	83 fa 09             	cmp    $0x9,%edx
  80042a:	76 eb                	jbe    800417 <vprintfmt+0xb3>
  80042c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80042f:	eb 2d                	jmp    80045e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8d 50 04             	lea    0x4(%eax),%edx
  800437:	89 55 14             	mov    %edx,0x14(%ebp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800442:	eb 1a                	jmp    80045e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800447:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044b:	79 91                	jns    8003de <vprintfmt+0x7a>
  80044d:	e9 73 ff ff ff       	jmp    8003c5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800455:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80045c:	eb 80                	jmp    8003de <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80045e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800462:	0f 89 76 ff ff ff    	jns    8003de <vprintfmt+0x7a>
  800468:	e9 64 ff ff ff       	jmp    8003d1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800473:	e9 66 ff ff ff       	jmp    8003de <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800485:	8b 00                	mov    (%eax),%eax
  800487:	89 04 24             	mov    %eax,(%esp)
  80048a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800490:	e9 f2 fe ff ff       	jmp    800387 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 c2                	mov    %eax,%edx
  8004a2:	c1 fa 1f             	sar    $0x1f,%edx
  8004a5:	31 d0                	xor    %edx,%eax
  8004a7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004a9:	83 f8 08             	cmp    $0x8,%eax
  8004ac:	7f 0b                	jg     8004b9 <vprintfmt+0x155>
  8004ae:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  8004b5:	85 d2                	test   %edx,%edx
  8004b7:	75 23                	jne    8004dc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004bd:	c7 44 24 08 fb 12 80 	movl   $0x8012fb,0x8(%esp)
  8004c4:	00 
  8004c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004cc:	89 3c 24             	mov    %edi,(%esp)
  8004cf:	e8 68 fe ff ff       	call   80033c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d7:	e9 ab fe ff ff       	jmp    800387 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e0:	c7 44 24 08 04 13 80 	movl   $0x801304,0x8(%esp)
  8004e7:	00 
  8004e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ef:	89 3c 24             	mov    %edi,(%esp)
  8004f2:	e8 45 fe ff ff       	call   80033c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004fa:	e9 88 fe ff ff       	jmp    800387 <vprintfmt+0x23>
  8004ff:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800502:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800505:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800513:	85 f6                	test   %esi,%esi
  800515:	ba f4 12 80 00       	mov    $0x8012f4,%edx
  80051a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80051d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800521:	7e 06                	jle    800529 <vprintfmt+0x1c5>
  800523:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800527:	75 10                	jne    800539 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800529:	0f be 06             	movsbl (%esi),%eax
  80052c:	83 c6 01             	add    $0x1,%esi
  80052f:	85 c0                	test   %eax,%eax
  800531:	0f 85 86 00 00 00    	jne    8005bd <vprintfmt+0x259>
  800537:	eb 76                	jmp    8005af <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053d:	89 34 24             	mov    %esi,(%esp)
  800540:	e8 76 02 00 00       	call   8007bb <strnlen>
  800545:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800548:	29 c2                	sub    %eax,%edx
  80054a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054d:	85 d2                	test   %edx,%edx
  80054f:	7e d8                	jle    800529 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800551:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800555:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800558:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80055b:	89 d6                	mov    %edx,%esi
  80055d:	89 c7                	mov    %eax,%edi
  80055f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800563:	89 3c 24             	mov    %edi,(%esp)
  800566:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	83 ee 01             	sub    $0x1,%esi
  80056c:	75 f1                	jne    80055f <vprintfmt+0x1fb>
  80056e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800571:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800574:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800577:	eb b0                	jmp    800529 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800579:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057d:	74 18                	je     800597 <vprintfmt+0x233>
  80057f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800582:	83 fa 5e             	cmp    $0x5e,%edx
  800585:	76 10                	jbe    800597 <vprintfmt+0x233>
					putch('?', putdat);
  800587:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800592:	ff 55 08             	call   *0x8(%ebp)
  800595:	eb 0a                	jmp    8005a1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800597:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059b:	89 04 24             	mov    %eax,(%esp)
  80059e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005a5:	0f be 06             	movsbl (%esi),%eax
  8005a8:	83 c6 01             	add    $0x1,%esi
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	75 0e                	jne    8005bd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b6:	7f 11                	jg     8005c9 <vprintfmt+0x265>
  8005b8:	e9 ca fd ff ff       	jmp    800387 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bd:	85 ff                	test   %edi,%edi
  8005bf:	90                   	nop
  8005c0:	78 b7                	js     800579 <vprintfmt+0x215>
  8005c2:	83 ef 01             	sub    $0x1,%edi
  8005c5:	79 b2                	jns    800579 <vprintfmt+0x215>
  8005c7:	eb e6                	jmp    8005af <vprintfmt+0x24b>
  8005c9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005cc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005da:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005dc:	83 ee 01             	sub    $0x1,%esi
  8005df:	75 ee                	jne    8005cf <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e4:	e9 9e fd ff ff       	jmp    800387 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 f2 fc ff ff       	call   8002e5 <getint>
  8005f3:	89 c6                	mov    %eax,%esi
  8005f5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fc:	85 d2                	test   %edx,%edx
  8005fe:	0f 89 ad 00 00 00    	jns    8006b1 <vprintfmt+0x34d>
				putch('-', putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800612:	f7 de                	neg    %esi
  800614:	83 d7 00             	adc    $0x0,%edi
  800617:	f7 df                	neg    %edi
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 8e 00 00 00       	jmp    8006b1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800623:	89 ca                	mov    %ecx,%edx
  800625:	8d 45 14             	lea    0x14(%ebp),%eax
  800628:	e8 7e fc ff ff       	call   8002ab <getuint>
  80062d:	89 c6                	mov    %eax,%esi
  80062f:	89 d7                	mov    %edx,%edi
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800636:	eb 79                	jmp    8006b1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800638:	89 ca                	mov    %ecx,%edx
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 a3 fc ff ff       	call   8002e5 <getint>
  800642:	89 c6                	mov    %eax,%esi
  800644:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800646:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064b:	85 d2                	test   %edx,%edx
  80064d:	79 62                	jns    8006b1 <vprintfmt+0x34d>
				putch('-', putdat);
  80064f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800653:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065d:	f7 de                	neg    %esi
  80065f:	83 d7 00             	adc    $0x0,%edi
  800662:	f7 df                	neg    %edi
			}
			base = 8;
  800664:	b8 08 00 00 00       	mov    $0x8,%eax
  800669:	eb 46                	jmp    8006b1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80066b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800676:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800679:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800684:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800690:	8b 30                	mov    (%eax),%esi
  800692:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800697:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069c:	eb 13                	jmp    8006b1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069e:	89 ca                	mov    %ecx,%edx
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a3:	e8 03 fc ff ff       	call   8002ab <getuint>
  8006a8:	89 c6                	mov    %eax,%esi
  8006aa:	89 d7                	mov    %edx,%edi
			base = 16;
  8006ac:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c4:	89 34 24             	mov    %esi,(%esp)
  8006c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cb:	89 da                	mov    %ebx,%edx
  8006cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d0:	e8 fb fa ff ff       	call   8001d0 <printnum>
			break;
  8006d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d8:	e9 aa fc ff ff       	jmp    800387 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e1:	89 14 24             	mov    %edx,(%esp)
  8006e4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ea:	e9 98 fc ff ff       	jmp    800387 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006fa:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800701:	0f 84 80 fc ff ff    	je     800387 <vprintfmt+0x23>
  800707:	83 ee 01             	sub    $0x1,%esi
  80070a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80070e:	75 f7                	jne    800707 <vprintfmt+0x3a3>
  800710:	e9 72 fc ff ff       	jmp    800387 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800715:	83 c4 4c             	add    $0x4c,%esp
  800718:	5b                   	pop    %ebx
  800719:	5e                   	pop    %esi
  80071a:	5f                   	pop    %edi
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 28             	sub    $0x28,%esp
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800729:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800730:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800733:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073a:	85 c0                	test   %eax,%eax
  80073c:	74 30                	je     80076e <vsnprintf+0x51>
  80073e:	85 d2                	test   %edx,%edx
  800740:	7e 2c                	jle    80076e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800749:	8b 45 10             	mov    0x10(%ebp),%eax
  80074c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800750:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800753:	89 44 24 04          	mov    %eax,0x4(%esp)
  800757:	c7 04 24 1f 03 80 00 	movl   $0x80031f,(%esp)
  80075e:	e8 01 fc ff ff       	call   800364 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800766:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076c:	eb 05                	jmp    800773 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800782:	8b 45 10             	mov    0x10(%ebp),%eax
  800785:	89 44 24 08          	mov    %eax,0x8(%esp)
  800789:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	e8 82 ff ff ff       	call   80071d <vsnprintf>
	va_end(ap);

	return rc;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    
  80079d:	00 00                	add    %al,(%eax)
	...

008007a0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ae:	74 09                	je     8007b9 <strlen+0x19>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0x10>
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ca:	85 c9                	test   %ecx,%ecx
  8007cc:	74 1a                	je     8007e8 <strnlen+0x2d>
  8007ce:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007d1:	74 15                	je     8007e8 <strnlen+0x2d>
  8007d3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007d8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	39 ca                	cmp    %ecx,%edx
  8007dc:	74 0a                	je     8007e8 <strnlen+0x2d>
  8007de:	83 c2 01             	add    $0x1,%edx
  8007e1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8007e6:	75 f0                	jne    8007d8 <strnlen+0x1d>
		n++;
	return n;
}
  8007e8:	5b                   	pop    %ebx
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007fe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	84 c9                	test   %cl,%cl
  800806:	75 f2                	jne    8007fa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800808:	5b                   	pop    %ebx
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800819:	85 f6                	test   %esi,%esi
  80081b:	74 18                	je     800835 <strncpy+0x2a>
  80081d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800822:	0f b6 1a             	movzbl (%edx),%ebx
  800825:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800828:	80 3a 01             	cmpb   $0x1,(%edx)
  80082b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082e:	83 c1 01             	add    $0x1,%ecx
  800831:	39 f1                	cmp    %esi,%ecx
  800833:	75 ed                	jne    800822 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	57                   	push   %edi
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800845:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	89 f8                	mov    %edi,%eax
  80084a:	85 f6                	test   %esi,%esi
  80084c:	74 2b                	je     800879 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80084e:	83 fe 01             	cmp    $0x1,%esi
  800851:	74 23                	je     800876 <strlcpy+0x3d>
  800853:	0f b6 0b             	movzbl (%ebx),%ecx
  800856:	84 c9                	test   %cl,%cl
  800858:	74 1c                	je     800876 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80085a:	83 ee 02             	sub    $0x2,%esi
  80085d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800862:	88 08                	mov    %cl,(%eax)
  800864:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800867:	39 f2                	cmp    %esi,%edx
  800869:	74 0b                	je     800876 <strlcpy+0x3d>
  80086b:	83 c2 01             	add    $0x1,%edx
  80086e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800872:	84 c9                	test   %cl,%cl
  800874:	75 ec                	jne    800862 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800876:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800879:	29 f8                	sub    %edi,%eax
}
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800889:	0f b6 01             	movzbl (%ecx),%eax
  80088c:	84 c0                	test   %al,%al
  80088e:	74 16                	je     8008a6 <strcmp+0x26>
  800890:	3a 02                	cmp    (%edx),%al
  800892:	75 12                	jne    8008a6 <strcmp+0x26>
		p++, q++;
  800894:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800897:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  80089b:	84 c0                	test   %al,%al
  80089d:	74 07                	je     8008a6 <strcmp+0x26>
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	3a 02                	cmp    (%edx),%al
  8008a4:	74 ee                	je     800894 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a6:	0f b6 c0             	movzbl %al,%eax
  8008a9:	0f b6 12             	movzbl (%edx),%edx
  8008ac:	29 d0                	sub    %edx,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008ba:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c2:	85 d2                	test   %edx,%edx
  8008c4:	74 28                	je     8008ee <strncmp+0x3e>
  8008c6:	0f b6 01             	movzbl (%ecx),%eax
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 24                	je     8008f1 <strncmp+0x41>
  8008cd:	3a 03                	cmp    (%ebx),%al
  8008cf:	75 20                	jne    8008f1 <strncmp+0x41>
  8008d1:	83 ea 01             	sub    $0x1,%edx
  8008d4:	74 13                	je     8008e9 <strncmp+0x39>
		n--, p++, q++;
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dc:	0f b6 01             	movzbl (%ecx),%eax
  8008df:	84 c0                	test   %al,%al
  8008e1:	74 0e                	je     8008f1 <strncmp+0x41>
  8008e3:	3a 03                	cmp    (%ebx),%al
  8008e5:	74 ea                	je     8008d1 <strncmp+0x21>
  8008e7:	eb 08                	jmp    8008f1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	0f b6 13             	movzbl (%ebx),%edx
  8008f7:	29 d0                	sub    %edx,%eax
  8008f9:	eb f3                	jmp    8008ee <strncmp+0x3e>

008008fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	0f b6 10             	movzbl (%eax),%edx
  800908:	84 d2                	test   %dl,%dl
  80090a:	74 1c                	je     800928 <strchr+0x2d>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	75 09                	jne    800919 <strchr+0x1e>
  800910:	eb 1b                	jmp    80092d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800912:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800915:	38 ca                	cmp    %cl,%dl
  800917:	74 14                	je     80092d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800919:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  80091d:	84 d2                	test   %dl,%dl
  80091f:	75 f1                	jne    800912 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	eb 05                	jmp    80092d <strchr+0x32>
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800939:	0f b6 10             	movzbl (%eax),%edx
  80093c:	84 d2                	test   %dl,%dl
  80093e:	74 14                	je     800954 <strfind+0x25>
		if (*s == c)
  800940:	38 ca                	cmp    %cl,%dl
  800942:	75 06                	jne    80094a <strfind+0x1b>
  800944:	eb 0e                	jmp    800954 <strfind+0x25>
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 0a                	je     800954 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	0f b6 10             	movzbl (%eax),%edx
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	53                   	push   %ebx
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800960:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800963:	89 da                	mov    %ebx,%edx
  800965:	83 ea 01             	sub    $0x1,%edx
  800968:	78 0d                	js     800977 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80096a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  80096c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  80096e:	88 0a                	mov    %cl,(%edx)
  800970:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800973:	39 da                	cmp    %ebx,%edx
  800975:	75 f7                	jne    80096e <memset+0x18>
		*p++ = c;

	return v;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 75 0c             	mov    0xc(%ebp),%esi
  800986:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800989:	39 c6                	cmp    %eax,%esi
  80098b:	72 0b                	jb     800998 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	85 db                	test   %ebx,%ebx
  800994:	75 29                	jne    8009bf <memmove+0x45>
  800996:	eb 35                	jmp    8009cd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800998:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  80099b:	39 c8                	cmp    %ecx,%eax
  80099d:	73 ee                	jae    80098d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  80099f:	85 db                	test   %ebx,%ebx
  8009a1:	74 2a                	je     8009cd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  8009a3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  8009a6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  8009a8:	f7 db                	neg    %ebx
  8009aa:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  8009ad:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  8009af:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  8009b4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  8009b8:	83 ea 01             	sub    $0x1,%edx
  8009bb:	75 f2                	jne    8009af <memmove+0x35>
  8009bd:	eb 0e                	jmp    8009cd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  8009bf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009c3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009c6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  8009c9:	39 d3                	cmp    %edx,%ebx
  8009cb:	75 f2                	jne    8009bf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	89 04 24             	mov    %eax,(%esp)
  8009ec:	e8 89 ff ff ff       	call   80097a <memmove>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	85 ff                	test   %edi,%edi
  800a09:	74 37                	je     800a42 <memcmp+0x4f>
		if (*s1 != *s2)
  800a0b:	0f b6 03             	movzbl (%ebx),%eax
  800a0e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	83 ef 01             	sub    $0x1,%edi
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a19:	38 c8                	cmp    %cl,%al
  800a1b:	74 1c                	je     800a39 <memcmp+0x46>
  800a1d:	eb 10                	jmp    800a2f <memcmp+0x3c>
  800a1f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a24:	83 c2 01             	add    $0x1,%edx
  800a27:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a2b:	38 c8                	cmp    %cl,%al
  800a2d:	74 0a                	je     800a39 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800a2f:	0f b6 c0             	movzbl %al,%eax
  800a32:	0f b6 c9             	movzbl %cl,%ecx
  800a35:	29 c8                	sub    %ecx,%eax
  800a37:	eb 09                	jmp    800a42 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a39:	39 fa                	cmp    %edi,%edx
  800a3b:	75 e2                	jne    800a1f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4d:	89 c2                	mov    %eax,%edx
  800a4f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a52:	39 d0                	cmp    %edx,%eax
  800a54:	73 15                	jae    800a6b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a5a:	38 08                	cmp    %cl,(%eax)
  800a5c:	75 06                	jne    800a64 <memfind+0x1d>
  800a5e:	eb 0b                	jmp    800a6b <memfind+0x24>
  800a60:	38 08                	cmp    %cl,(%eax)
  800a62:	74 07                	je     800a6b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a64:	83 c0 01             	add    $0x1,%eax
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	75 f5                	jne    800a60 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	0f b6 02             	movzbl (%edx),%eax
  800a7c:	3c 20                	cmp    $0x20,%al
  800a7e:	74 04                	je     800a84 <strtol+0x17>
  800a80:	3c 09                	cmp    $0x9,%al
  800a82:	75 0e                	jne    800a92 <strtol+0x25>
		s++;
  800a84:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a87:	0f b6 02             	movzbl (%edx),%eax
  800a8a:	3c 20                	cmp    $0x20,%al
  800a8c:	74 f6                	je     800a84 <strtol+0x17>
  800a8e:	3c 09                	cmp    $0x9,%al
  800a90:	74 f2                	je     800a84 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a92:	3c 2b                	cmp    $0x2b,%al
  800a94:	75 0a                	jne    800aa0 <strtol+0x33>
		s++;
  800a96:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a99:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9e:	eb 10                	jmp    800ab0 <strtol+0x43>
  800aa0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa5:	3c 2d                	cmp    $0x2d,%al
  800aa7:	75 07                	jne    800ab0 <strtol+0x43>
		s++, neg = 1;
  800aa9:	83 c2 01             	add    $0x1,%edx
  800aac:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	0f 94 c0             	sete   %al
  800ab5:	74 05                	je     800abc <strtol+0x4f>
  800ab7:	83 fb 10             	cmp    $0x10,%ebx
  800aba:	75 15                	jne    800ad1 <strtol+0x64>
  800abc:	80 3a 30             	cmpb   $0x30,(%edx)
  800abf:	75 10                	jne    800ad1 <strtol+0x64>
  800ac1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac5:	75 0a                	jne    800ad1 <strtol+0x64>
		s += 2, base = 16;
  800ac7:	83 c2 02             	add    $0x2,%edx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb 13                	jmp    800ae4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ad1:	84 c0                	test   %al,%al
  800ad3:	74 0f                	je     800ae4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ada:	80 3a 30             	cmpb   $0x30,(%edx)
  800add:	75 05                	jne    800ae4 <strtol+0x77>
		s++, base = 8;
  800adf:	83 c2 01             	add    $0x1,%edx
  800ae2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aeb:	0f b6 0a             	movzbl (%edx),%ecx
  800aee:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800af1:	80 fb 09             	cmp    $0x9,%bl
  800af4:	77 08                	ja     800afe <strtol+0x91>
			dig = *s - '0';
  800af6:	0f be c9             	movsbl %cl,%ecx
  800af9:	83 e9 30             	sub    $0x30,%ecx
  800afc:	eb 1e                	jmp    800b1c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800afe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b01:	80 fb 19             	cmp    $0x19,%bl
  800b04:	77 08                	ja     800b0e <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b06:	0f be c9             	movsbl %cl,%ecx
  800b09:	83 e9 57             	sub    $0x57,%ecx
  800b0c:	eb 0e                	jmp    800b1c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b0e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b11:	80 fb 19             	cmp    $0x19,%bl
  800b14:	77 14                	ja     800b2a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b16:	0f be c9             	movsbl %cl,%ecx
  800b19:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b1c:	39 f1                	cmp    %esi,%ecx
  800b1e:	7d 0e                	jge    800b2e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b20:	83 c2 01             	add    $0x1,%edx
  800b23:	0f af c6             	imul   %esi,%eax
  800b26:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b28:	eb c1                	jmp    800aeb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b2a:	89 c1                	mov    %eax,%ecx
  800b2c:	eb 02                	jmp    800b30 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b34:	74 05                	je     800b3b <strtol+0xce>
		*endptr = (char *) s;
  800b36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b39:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b3b:	89 ca                	mov    %ecx,%edx
  800b3d:	f7 da                	neg    %edx
  800b3f:	85 ff                	test   %edi,%edi
  800b41:	0f 45 c2             	cmovne %edx,%eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    
  800b49:	00 00                	add    %al,(%eax)
	...

00800b4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b58:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	89 c7                	mov    %eax,%edi
  800b6a:	89 c6                	mov    %eax,%esi
  800b6c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b71:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b74:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b77:	89 ec                	mov    %ebp,%esp
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b84:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b87:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ba1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ba4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ba7:	89 ec                	mov    %ebp,%esp
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	83 ec 38             	sub    $0x38,%esp
  800bb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	89 cb                	mov    %ecx,%ebx
  800bc9:	89 cf                	mov    %ecx,%edi
  800bcb:	89 ce                	mov    %ecx,%esi
  800bcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 28                	jle    800bfb <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bde:	00 
  800bdf:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800be6:	00 
  800be7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bee:	00 
  800bef:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800bf6:	e8 35 03 00 00       	call   800f30 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bfe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c04:	89 ec                	mov    %ebp,%esp
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c11:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c14:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c17:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c21:	89 d1                	mov    %edx,%ecx
  800c23:	89 d3                	mov    %edx,%ebx
  800c25:	89 d7                	mov    %edx,%edi
  800c27:	89 d6                	mov    %edx,%esi
  800c29:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c34:	89 ec                	mov    %ebp,%esp
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_yield>:

void
sys_yield(void)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c41:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c44:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c51:	89 d1                	mov    %edx,%ecx
  800c53:	89 d3                	mov    %edx,%ebx
  800c55:	89 d7                	mov    %edx,%edi
  800c57:	89 d6                	mov    %edx,%esi
  800c59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c5e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c61:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c64:	89 ec                	mov    %ebp,%esp
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	83 ec 38             	sub    $0x38,%esp
  800c6e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c71:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c74:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c77:	be 00 00 00 00       	mov    $0x0,%esi
  800c7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	89 f7                	mov    %esi,%edi
  800c8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 28                	jle    800cba <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c96:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c9d:	00 
  800c9e:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800ca5:	00 
  800ca6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cad:	00 
  800cae:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800cb5:	e8 76 02 00 00       	call   800f30 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cba:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cbd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cc3:	89 ec                	mov    %ebp,%esp
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 38             	sub    $0x38,%esp
  800ccd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7e 28                	jle    800d18 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cfb:	00 
  800cfc:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800d03:	00 
  800d04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0b:	00 
  800d0c:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800d13:	e8 18 02 00 00       	call   800f30 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d18:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d1b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d1e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d21:	89 ec                	mov    %ebp,%esp
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	83 ec 38             	sub    $0x38,%esp
  800d2b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d2e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d31:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d39:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	89 df                	mov    %ebx,%edi
  800d46:	89 de                	mov    %ebx,%esi
  800d48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 28                	jle    800d76 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d52:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d59:	00 
  800d5a:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800d61:	00 
  800d62:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d69:	00 
  800d6a:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800d71:	e8 ba 01 00 00       	call   800f30 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d76:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d79:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d7c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d7f:	89 ec                	mov    %ebp,%esp
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	83 ec 38             	sub    $0x38,%esp
  800d89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d97:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 df                	mov    %ebx,%edi
  800da4:	89 de                	mov    %ebx,%esi
  800da6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 28                	jle    800dd4 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db0:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800db7:	00 
  800db8:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc7:	00 
  800dc8:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800dcf:	e8 5c 01 00 00       	call   800f30 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dda:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ddd:	89 ec                	mov    %ebp,%esp
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 38             	sub    $0x38,%esp
  800de7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dea:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ded:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	89 df                	mov    %ebx,%edi
  800e02:	89 de                	mov    %ebx,%esi
  800e04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 28                	jle    800e32 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e0e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e15:	00 
  800e16:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800e1d:	00 
  800e1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e25:	00 
  800e26:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800e2d:	e8 fe 00 00 00       	call   800f30 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e32:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e35:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e38:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3b:	89 ec                	mov    %ebp,%esp
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 38             	sub    $0x38,%esp
  800e45:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e48:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	89 df                	mov    %ebx,%edi
  800e60:	89 de                	mov    %ebx,%esi
  800e62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e64:	85 c0                	test   %eax,%eax
  800e66:	7e 28                	jle    800e90 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e68:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e73:	00 
  800e74:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e83:	00 
  800e84:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800e8b:	e8 a0 00 00 00       	call   800f30 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e90:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e93:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e96:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e99:	89 ec                	mov    %ebp,%esp
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 0c             	sub    $0xc,%esp
  800ea3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eac:	be 00 00 00 00       	mov    $0x0,%esi
  800eb1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ecd:	89 ec                	mov    %ebp,%esp
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 38             	sub    $0x38,%esp
  800ed7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eda:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800edd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	89 cb                	mov    %ecx,%ebx
  800eef:	89 cf                	mov    %ecx,%edi
  800ef1:	89 ce                	mov    %ecx,%esi
  800ef3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	7e 28                	jle    800f21 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f04:	00 
  800f05:	c7 44 24 08 24 15 80 	movl   $0x801524,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 41 15 80 00 	movl   $0x801541,(%esp)
  800f1c:	e8 0f 00 00 00       	call   800f30 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f21:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f24:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f27:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f2a:	89 ec                	mov    %ebp,%esp
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    
	...

00800f30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800f36:	a1 08 20 80 00       	mov    0x802008,%eax
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	74 10                	je     800f4f <_panic+0x1f>
		cprintf("%s: ", argv0);
  800f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f43:	c7 04 24 4f 15 80 00 	movl   $0x80154f,(%esp)
  800f4a:	e8 58 f2 ff ff       	call   8001a7 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f56:	8b 45 08             	mov    0x8(%ebp),%eax
  800f59:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5d:	a1 00 20 80 00       	mov    0x802000,%eax
  800f62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f66:	c7 04 24 54 15 80 00 	movl   $0x801554,(%esp)
  800f6d:	e8 35 f2 ff ff       	call   8001a7 <cprintf>
	vcprintf(fmt, ap);
  800f72:	8d 45 14             	lea    0x14(%ebp),%eax
  800f75:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f79:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7c:	89 04 24             	mov    %eax,(%esp)
  800f7f:	e8 c2 f1 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800f84:	c7 04 24 70 15 80 00 	movl   $0x801570,(%esp)
  800f8b:	e8 17 f2 ff ff       	call   8001a7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f90:	cc                   	int3   
  800f91:	eb fd                	jmp    800f90 <_panic+0x60>
	...

00800fa0 <__udivdi3>:
  800fa0:	83 ec 1c             	sub    $0x1c,%esp
  800fa3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fa7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800fab:	8b 44 24 20          	mov    0x20(%esp),%eax
  800faf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fb3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fb7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800fbb:	85 ff                	test   %edi,%edi
  800fbd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc5:	89 cd                	mov    %ecx,%ebp
  800fc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fcb:	75 33                	jne    801000 <__udivdi3+0x60>
  800fcd:	39 f1                	cmp    %esi,%ecx
  800fcf:	77 57                	ja     801028 <__udivdi3+0x88>
  800fd1:	85 c9                	test   %ecx,%ecx
  800fd3:	75 0b                	jne    800fe0 <__udivdi3+0x40>
  800fd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fda:	31 d2                	xor    %edx,%edx
  800fdc:	f7 f1                	div    %ecx
  800fde:	89 c1                	mov    %eax,%ecx
  800fe0:	89 f0                	mov    %esi,%eax
  800fe2:	31 d2                	xor    %edx,%edx
  800fe4:	f7 f1                	div    %ecx
  800fe6:	89 c6                	mov    %eax,%esi
  800fe8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fec:	f7 f1                	div    %ecx
  800fee:	89 f2                	mov    %esi,%edx
  800ff0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ff4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ff8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ffc:	83 c4 1c             	add    $0x1c,%esp
  800fff:	c3                   	ret    
  801000:	31 d2                	xor    %edx,%edx
  801002:	31 c0                	xor    %eax,%eax
  801004:	39 f7                	cmp    %esi,%edi
  801006:	77 e8                	ja     800ff0 <__udivdi3+0x50>
  801008:	0f bd cf             	bsr    %edi,%ecx
  80100b:	83 f1 1f             	xor    $0x1f,%ecx
  80100e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801012:	75 2c                	jne    801040 <__udivdi3+0xa0>
  801014:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801018:	76 04                	jbe    80101e <__udivdi3+0x7e>
  80101a:	39 f7                	cmp    %esi,%edi
  80101c:	73 d2                	jae    800ff0 <__udivdi3+0x50>
  80101e:	31 d2                	xor    %edx,%edx
  801020:	b8 01 00 00 00       	mov    $0x1,%eax
  801025:	eb c9                	jmp    800ff0 <__udivdi3+0x50>
  801027:	90                   	nop
  801028:	89 f2                	mov    %esi,%edx
  80102a:	f7 f1                	div    %ecx
  80102c:	31 d2                	xor    %edx,%edx
  80102e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801032:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801036:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80103a:	83 c4 1c             	add    $0x1c,%esp
  80103d:	c3                   	ret    
  80103e:	66 90                	xchg   %ax,%ax
  801040:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801045:	b8 20 00 00 00       	mov    $0x20,%eax
  80104a:	89 ea                	mov    %ebp,%edx
  80104c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801050:	d3 e7                	shl    %cl,%edi
  801052:	89 c1                	mov    %eax,%ecx
  801054:	d3 ea                	shr    %cl,%edx
  801056:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80105b:	09 fa                	or     %edi,%edx
  80105d:	89 f7                	mov    %esi,%edi
  80105f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801063:	89 f2                	mov    %esi,%edx
  801065:	8b 74 24 08          	mov    0x8(%esp),%esi
  801069:	d3 e5                	shl    %cl,%ebp
  80106b:	89 c1                	mov    %eax,%ecx
  80106d:	d3 ef                	shr    %cl,%edi
  80106f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801074:	d3 e2                	shl    %cl,%edx
  801076:	89 c1                	mov    %eax,%ecx
  801078:	d3 ee                	shr    %cl,%esi
  80107a:	09 d6                	or     %edx,%esi
  80107c:	89 fa                	mov    %edi,%edx
  80107e:	89 f0                	mov    %esi,%eax
  801080:	f7 74 24 0c          	divl   0xc(%esp)
  801084:	89 d7                	mov    %edx,%edi
  801086:	89 c6                	mov    %eax,%esi
  801088:	f7 e5                	mul    %ebp
  80108a:	39 d7                	cmp    %edx,%edi
  80108c:	72 22                	jb     8010b0 <__udivdi3+0x110>
  80108e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801092:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801097:	d3 e5                	shl    %cl,%ebp
  801099:	39 c5                	cmp    %eax,%ebp
  80109b:	73 04                	jae    8010a1 <__udivdi3+0x101>
  80109d:	39 d7                	cmp    %edx,%edi
  80109f:	74 0f                	je     8010b0 <__udivdi3+0x110>
  8010a1:	89 f0                	mov    %esi,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	e9 46 ff ff ff       	jmp    800ff0 <__udivdi3+0x50>
  8010aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8010b3:	31 d2                	xor    %edx,%edx
  8010b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010c1:	83 c4 1c             	add    $0x1c,%esp
  8010c4:	c3                   	ret    
	...

008010d0 <__umoddi3>:
  8010d0:	83 ec 1c             	sub    $0x1c,%esp
  8010d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8010db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010eb:	85 ed                	test   %ebp,%ebp
  8010ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f5:	89 cf                	mov    %ecx,%edi
  8010f7:	89 04 24             	mov    %eax,(%esp)
  8010fa:	89 f2                	mov    %esi,%edx
  8010fc:	75 1a                	jne    801118 <__umoddi3+0x48>
  8010fe:	39 f1                	cmp    %esi,%ecx
  801100:	76 4e                	jbe    801150 <__umoddi3+0x80>
  801102:	f7 f1                	div    %ecx
  801104:	89 d0                	mov    %edx,%eax
  801106:	31 d2                	xor    %edx,%edx
  801108:	8b 74 24 10          	mov    0x10(%esp),%esi
  80110c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801110:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801114:	83 c4 1c             	add    $0x1c,%esp
  801117:	c3                   	ret    
  801118:	39 f5                	cmp    %esi,%ebp
  80111a:	77 54                	ja     801170 <__umoddi3+0xa0>
  80111c:	0f bd c5             	bsr    %ebp,%eax
  80111f:	83 f0 1f             	xor    $0x1f,%eax
  801122:	89 44 24 04          	mov    %eax,0x4(%esp)
  801126:	75 60                	jne    801188 <__umoddi3+0xb8>
  801128:	3b 0c 24             	cmp    (%esp),%ecx
  80112b:	0f 87 07 01 00 00    	ja     801238 <__umoddi3+0x168>
  801131:	89 f2                	mov    %esi,%edx
  801133:	8b 34 24             	mov    (%esp),%esi
  801136:	29 ce                	sub    %ecx,%esi
  801138:	19 ea                	sbb    %ebp,%edx
  80113a:	89 34 24             	mov    %esi,(%esp)
  80113d:	8b 04 24             	mov    (%esp),%eax
  801140:	8b 74 24 10          	mov    0x10(%esp),%esi
  801144:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801148:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80114c:	83 c4 1c             	add    $0x1c,%esp
  80114f:	c3                   	ret    
  801150:	85 c9                	test   %ecx,%ecx
  801152:	75 0b                	jne    80115f <__umoddi3+0x8f>
  801154:	b8 01 00 00 00       	mov    $0x1,%eax
  801159:	31 d2                	xor    %edx,%edx
  80115b:	f7 f1                	div    %ecx
  80115d:	89 c1                	mov    %eax,%ecx
  80115f:	89 f0                	mov    %esi,%eax
  801161:	31 d2                	xor    %edx,%edx
  801163:	f7 f1                	div    %ecx
  801165:	8b 04 24             	mov    (%esp),%eax
  801168:	f7 f1                	div    %ecx
  80116a:	eb 98                	jmp    801104 <__umoddi3+0x34>
  80116c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801170:	89 f2                	mov    %esi,%edx
  801172:	8b 74 24 10          	mov    0x10(%esp),%esi
  801176:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80117a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80117e:	83 c4 1c             	add    $0x1c,%esp
  801181:	c3                   	ret    
  801182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801188:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80118d:	89 e8                	mov    %ebp,%eax
  80118f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801194:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801198:	89 fa                	mov    %edi,%edx
  80119a:	d3 e0                	shl    %cl,%eax
  80119c:	89 e9                	mov    %ebp,%ecx
  80119e:	d3 ea                	shr    %cl,%edx
  8011a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a5:	09 c2                	or     %eax,%edx
  8011a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011ab:	89 14 24             	mov    %edx,(%esp)
  8011ae:	89 f2                	mov    %esi,%edx
  8011b0:	d3 e7                	shl    %cl,%edi
  8011b2:	89 e9                	mov    %ebp,%ecx
  8011b4:	d3 ea                	shr    %cl,%edx
  8011b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011bf:	d3 e6                	shl    %cl,%esi
  8011c1:	89 e9                	mov    %ebp,%ecx
  8011c3:	d3 e8                	shr    %cl,%eax
  8011c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011ca:	09 f0                	or     %esi,%eax
  8011cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011d0:	f7 34 24             	divl   (%esp)
  8011d3:	d3 e6                	shl    %cl,%esi
  8011d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011d9:	89 d6                	mov    %edx,%esi
  8011db:	f7 e7                	mul    %edi
  8011dd:	39 d6                	cmp    %edx,%esi
  8011df:	89 c1                	mov    %eax,%ecx
  8011e1:	89 d7                	mov    %edx,%edi
  8011e3:	72 3f                	jb     801224 <__umoddi3+0x154>
  8011e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8011e9:	72 35                	jb     801220 <__umoddi3+0x150>
  8011eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011ef:	29 c8                	sub    %ecx,%eax
  8011f1:	19 fe                	sbb    %edi,%esi
  8011f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011f8:	89 f2                	mov    %esi,%edx
  8011fa:	d3 e8                	shr    %cl,%eax
  8011fc:	89 e9                	mov    %ebp,%ecx
  8011fe:	d3 e2                	shl    %cl,%edx
  801200:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801205:	09 d0                	or     %edx,%eax
  801207:	89 f2                	mov    %esi,%edx
  801209:	d3 ea                	shr    %cl,%edx
  80120b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80120f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801213:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801217:	83 c4 1c             	add    $0x1c,%esp
  80121a:	c3                   	ret    
  80121b:	90                   	nop
  80121c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801220:	39 d6                	cmp    %edx,%esi
  801222:	75 c7                	jne    8011eb <__umoddi3+0x11b>
  801224:	89 d7                	mov    %edx,%edi
  801226:	89 c1                	mov    %eax,%ecx
  801228:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80122c:	1b 3c 24             	sbb    (%esp),%edi
  80122f:	eb ba                	jmp    8011eb <__umoddi3+0x11b>
  801231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801238:	39 f5                	cmp    %esi,%ebp
  80123a:	0f 82 f1 fe ff ff    	jb     801131 <__umoddi3+0x61>
  801240:	e9 f8 fe ff ff       	jmp    80113d <__umoddi3+0x6d>
