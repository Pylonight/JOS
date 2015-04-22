
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 e7 0b 00 00       	call   800c28 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (env == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 e6 0e 00 00       	call   800f50 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  80007c:	e8 4a 01 00 00       	call   8001cb <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 d1 12 80 00 	movl   $0x8012d1,(%esp)
  800097:	e8 2f 01 00 00       	call   8001cb <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 b1 0e 00 00       	call   800f72 <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 18             	sub    $0x18,%esp
  8000ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  8000d6:	e8 4d 0b 00 00       	call   800c28 <sys_getenvid>
  8000db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 f6                	test   %esi,%esi
  8000ef:	7e 07                	jle    8000f8 <libmain+0x34>
		binaryname = argv[0];
  8000f1:	8b 03                	mov    (%ebx),%eax
  8000f3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000fc:	89 34 24             	mov    %esi,(%esp)
  8000ff:	e8 30 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800104:	e8 0b 00 00 00       	call   800114 <exit>
}
  800109:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80010c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010f:	89 ec                	mov    %ebp,%esp
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
	...

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800121:	e8 a5 0a 00 00       	call   800bcb <sys_env_destroy>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 14             	sub    $0x14,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 03                	mov    (%ebx),%eax
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013b:	83 c0 01             	add    $0x1,%eax
  80013e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	75 19                	jne    800160 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800147:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014e:	00 
  80014f:	8d 43 08             	lea    0x8(%ebx),%eax
  800152:	89 04 24             	mov    %eax,(%esp)
  800155:	e8 12 0a 00 00       	call   800b6c <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800160:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800164:	83 c4 14             	add    $0x14,%esp
  800167:	5b                   	pop    %ebx
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800173:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017a:	00 00 00 
	b.cnt = 0;
  80017d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800184:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 44 24 08          	mov    %eax,0x8(%esp)
  800195:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019f:	c7 04 24 28 01 80 00 	movl   $0x800128,(%esp)
  8001a6:	e8 d9 01 00 00       	call   800384 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ab:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bb:	89 04 24             	mov    %eax,(%esp)
  8001be:	e8 a9 09 00 00       	call   800b6c <sys_cputs>

	return b.cnt;
}
  8001c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001d1:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 87 ff ff ff       	call   80016a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 3c             	sub    $0x3c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d7                	mov    %edx,%edi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800210:	b8 00 00 00 00       	mov    $0x0,%eax
  800215:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800218:	72 11                	jb     80022b <printnum+0x3b>
  80021a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800220:	76 09                	jbe    80022b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800222:	83 eb 01             	sub    $0x1,%ebx
  800225:	85 db                	test   %ebx,%ebx
  800227:	7f 51                	jg     80027a <printnum+0x8a>
  800229:	eb 5e                	jmp    800289 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800236:	8b 45 10             	mov    0x10(%ebp),%eax
  800239:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800241:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800245:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024c:	00 
  80024d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	e8 a1 0d 00 00       	call   801000 <__udivdi3>
  80025f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800263:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026e:	89 fa                	mov    %edi,%edx
  800270:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800273:	e8 78 ff ff ff       	call   8001f0 <printnum>
  800278:	eb 0f                	jmp    800289 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027e:	89 34 24             	mov    %esi,(%esp)
  800281:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800284:	83 eb 01             	sub    $0x1,%ebx
  800287:	75 f1                	jne    80027a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800291:	8b 45 10             	mov    0x10(%ebp),%eax
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029f:	00 
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	e8 7e 0e 00 00       	call   801130 <__umoddi3>
  8002b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b6:	0f be 80 ff 12 80 00 	movsbl 0x8012ff(%eax),%eax
  8002bd:	89 04 24             	mov    %eax,(%esp)
  8002c0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002c3:	83 c4 3c             	add    $0x3c,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ce:	83 fa 01             	cmp    $0x1,%edx
  8002d1:	7e 0e                	jle    8002e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	8b 52 04             	mov    0x4(%edx),%edx
  8002df:	eb 22                	jmp    800303 <getuint+0x38>
	else if (lflag)
  8002e1:	85 d2                	test   %edx,%edx
  8002e3:	74 10                	je     8002f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f3:	eb 0e                	jmp    800303 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800308:	83 fa 01             	cmp    $0x1,%edx
  80030b:	7e 0e                	jle    80031b <getint+0x16>
		return va_arg(*ap, long long);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	8b 52 04             	mov    0x4(%edx),%edx
  800319:	eb 22                	jmp    80033d <getint+0x38>
	else if (lflag)
  80031b:	85 d2                	test   %edx,%edx
  80031d:	74 10                	je     80032f <getint+0x2a>
		return va_arg(*ap, long);
  80031f:	8b 10                	mov    (%eax),%edx
  800321:	8d 4a 04             	lea    0x4(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 02                	mov    (%edx),%eax
  800328:	89 c2                	mov    %eax,%edx
  80032a:	c1 fa 1f             	sar    $0x1f,%edx
  80032d:	eb 0e                	jmp    80033d <getint+0x38>
	else
		return va_arg(*ap, int);
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	8d 4a 04             	lea    0x4(%edx),%ecx
  800334:	89 08                	mov    %ecx,(%eax)
  800336:	8b 02                	mov    (%edx),%eax
  800338:	89 c2                	mov    %eax,%edx
  80033a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800345:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	3b 50 04             	cmp    0x4(%eax),%edx
  80034e:	73 0a                	jae    80035a <sprintputch+0x1b>
		*b->buf++ = ch;
  800350:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800353:	88 0a                	mov    %cl,(%edx)
  800355:	83 c2 01             	add    $0x1,%edx
  800358:	89 10                	mov    %edx,(%eax)
}
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800362:	8d 45 14             	lea    0x14(%ebp),%eax
  800365:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	89 44 24 04          	mov    %eax,0x4(%esp)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	e8 02 00 00 00       	call   800384 <vprintfmt>
	va_end(ap);
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 4c             	sub    $0x4c,%esp
  80038d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800390:	8b 75 10             	mov    0x10(%ebp),%esi
  800393:	eb 12                	jmp    8003a7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800395:	85 c0                	test   %eax,%eax
  800397:	0f 84 98 03 00 00    	je     800735 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80039d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003a1:	89 04 24             	mov    %eax,(%esp)
  8003a4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a7:	0f b6 06             	movzbl (%esi),%eax
  8003aa:	83 c6 01             	add    $0x1,%esi
  8003ad:	83 f8 25             	cmp    $0x25,%eax
  8003b0:	75 e3                	jne    800395 <vprintfmt+0x11>
  8003b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003d1:	eb 2b                	jmp    8003fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003d6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003da:	eb 22                	jmp    8003fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003df:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003e3:	eb 19                	jmp    8003fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003ef:	eb 0d                	jmp    8003fe <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	0f b6 06             	movzbl (%esi),%eax
  800401:	0f b6 d0             	movzbl %al,%edx
  800404:	8d 7e 01             	lea    0x1(%esi),%edi
  800407:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80040a:	83 e8 23             	sub    $0x23,%eax
  80040d:	3c 55                	cmp    $0x55,%al
  80040f:	0f 87 fa 02 00 00    	ja     80070f <vprintfmt+0x38b>
  800415:	0f b6 c0             	movzbl %al,%eax
  800418:	ff 24 85 c0 13 80 00 	jmp    *0x8013c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041f:	83 ea 30             	sub    $0x30,%edx
  800422:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800425:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800429:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80042f:	83 fa 09             	cmp    $0x9,%edx
  800432:	77 4a                	ja     80047e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800437:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80043a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80043d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800441:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800444:	8d 50 d0             	lea    -0x30(%eax),%edx
  800447:	83 fa 09             	cmp    $0x9,%edx
  80044a:	76 eb                	jbe    800437 <vprintfmt+0xb3>
  80044c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80044f:	eb 2d                	jmp    80047e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 00                	mov    (%eax),%eax
  80045c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800462:	eb 1a                	jmp    80047e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800467:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046b:	79 91                	jns    8003fe <vprintfmt+0x7a>
  80046d:	e9 73 ff ff ff       	jmp    8003e5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800475:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80047c:	eb 80                	jmp    8003fe <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80047e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800482:	0f 89 76 ff ff ff    	jns    8003fe <vprintfmt+0x7a>
  800488:	e9 64 ff ff ff       	jmp    8003f1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800493:	e9 66 ff ff ff       	jmp    8003fe <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 50 04             	lea    0x4(%eax),%edx
  80049e:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a5:	8b 00                	mov    (%eax),%eax
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b0:	e9 f2 fe ff ff       	jmp    8003a7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 c2                	mov    %eax,%edx
  8004c2:	c1 fa 1f             	sar    $0x1f,%edx
  8004c5:	31 d0                	xor    %edx,%eax
  8004c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004c9:	83 f8 08             	cmp    $0x8,%eax
  8004cc:	7f 0b                	jg     8004d9 <vprintfmt+0x155>
  8004ce:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	75 23                	jne    8004fc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8004d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004dd:	c7 44 24 08 17 13 80 	movl   $0x801317,0x8(%esp)
  8004e4:	00 
  8004e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004ec:	89 3c 24             	mov    %edi,(%esp)
  8004ef:	e8 68 fe ff ff       	call   80035c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f7:	e9 ab fe ff ff       	jmp    8003a7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800500:	c7 44 24 08 20 13 80 	movl   $0x801320,0x8(%esp)
  800507:	00 
  800508:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80050f:	89 3c 24             	mov    %edi,(%esp)
  800512:	e8 45 fe ff ff       	call   80035c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051a:	e9 88 fe ff ff       	jmp    8003a7 <vprintfmt+0x23>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800525:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800533:	85 f6                	test   %esi,%esi
  800535:	ba 10 13 80 00       	mov    $0x801310,%edx
  80053a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80053d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800541:	7e 06                	jle    800549 <vprintfmt+0x1c5>
  800543:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800547:	75 10                	jne    800559 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800549:	0f be 06             	movsbl (%esi),%eax
  80054c:	83 c6 01             	add    $0x1,%esi
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 85 86 00 00 00    	jne    8005dd <vprintfmt+0x259>
  800557:	eb 76                	jmp    8005cf <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	e8 76 02 00 00       	call   8007db <strnlen>
  800565:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800568:	29 c2                	sub    %eax,%edx
  80056a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80056d:	85 d2                	test   %edx,%edx
  80056f:	7e d8                	jle    800549 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800571:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800575:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800578:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80057b:	89 d6                	mov    %edx,%esi
  80057d:	89 c7                	mov    %eax,%edi
  80057f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800583:	89 3c 24             	mov    %edi,(%esp)
  800586:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	83 ee 01             	sub    $0x1,%esi
  80058c:	75 f1                	jne    80057f <vprintfmt+0x1fb>
  80058e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800591:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800594:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800597:	eb b0                	jmp    800549 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800599:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059d:	74 18                	je     8005b7 <vprintfmt+0x233>
  80059f:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a2:	83 fa 5e             	cmp    $0x5e,%edx
  8005a5:	76 10                	jbe    8005b7 <vprintfmt+0x233>
					putch('?', putdat);
  8005a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ab:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b2:	ff 55 08             	call   *0x8(%ebp)
  8005b5:	eb 0a                	jmp    8005c1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8005b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005c5:	0f be 06             	movsbl (%esi),%eax
  8005c8:	83 c6 01             	add    $0x1,%esi
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	75 0e                	jne    8005dd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d6:	7f 11                	jg     8005e9 <vprintfmt+0x265>
  8005d8:	e9 ca fd ff ff       	jmp    8003a7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	90                   	nop
  8005e0:	78 b7                	js     800599 <vprintfmt+0x215>
  8005e2:	83 ef 01             	sub    $0x1,%edi
  8005e5:	79 b2                	jns    800599 <vprintfmt+0x215>
  8005e7:	eb e6                	jmp    8005cf <vprintfmt+0x24b>
  8005e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8005ec:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fa:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fc:	83 ee 01             	sub    $0x1,%esi
  8005ff:	75 ee                	jne    8005ef <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800604:	e9 9e fd ff ff       	jmp    8003a7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800609:	89 ca                	mov    %ecx,%edx
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 f2 fc ff ff       	call   800305 <getint>
  800613:	89 c6                	mov    %eax,%esi
  800615:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061c:	85 d2                	test   %edx,%edx
  80061e:	0f 89 ad 00 00 00    	jns    8006d1 <vprintfmt+0x34d>
				putch('-', putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80062f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800632:	f7 de                	neg    %esi
  800634:	83 d7 00             	adc    $0x0,%edi
  800637:	f7 df                	neg    %edi
			}
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063e:	e9 8e 00 00 00       	jmp    8006d1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800643:	89 ca                	mov    %ecx,%edx
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 7e fc ff ff       	call   8002cb <getuint>
  80064d:	89 c6                	mov    %eax,%esi
  80064f:	89 d7                	mov    %edx,%edi
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800656:	eb 79                	jmp    8006d1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800658:	89 ca                	mov    %ecx,%edx
  80065a:	8d 45 14             	lea    0x14(%ebp),%eax
  80065d:	e8 a3 fc ff ff       	call   800305 <getint>
  800662:	89 c6                	mov    %eax,%esi
  800664:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800666:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80066b:	85 d2                	test   %edx,%edx
  80066d:	79 62                	jns    8006d1 <vprintfmt+0x34d>
				putch('-', putdat);
  80066f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800673:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80067d:	f7 de                	neg    %esi
  80067f:	83 d7 00             	adc    $0x0,%edi
  800682:	f7 df                	neg    %edi
			}
			base = 8;
  800684:	b8 08 00 00 00       	mov    $0x8,%eax
  800689:	eb 46                	jmp    8006d1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  80068b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800696:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800699:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 50 04             	lea    0x4(%eax),%edx
  8006ad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b0:	8b 30                	mov    (%eax),%esi
  8006b2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bc:	eb 13                	jmp    8006d1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006be:	89 ca                	mov    %ecx,%edx
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c3:	e8 03 fc ff ff       	call   8002cb <getuint>
  8006c8:	89 c6                	mov    %eax,%esi
  8006ca:	89 d7                	mov    %edx,%edi
			base = 16;
  8006cc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e4:	89 34 24             	mov    %esi,(%esp)
  8006e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006eb:	89 da                	mov    %ebx,%edx
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	e8 fb fa ff ff       	call   8001f0 <printnum>
			break;
  8006f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f8:	e9 aa fc ff ff       	jmp    8003a7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800701:	89 14 24             	mov    %edx,(%esp)
  800704:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800707:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070a:	e9 98 fc ff ff       	jmp    8003a7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800713:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800721:	0f 84 80 fc ff ff    	je     8003a7 <vprintfmt+0x23>
  800727:	83 ee 01             	sub    $0x1,%esi
  80072a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072e:	75 f7                	jne    800727 <vprintfmt+0x3a3>
  800730:	e9 72 fc ff ff       	jmp    8003a7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800735:	83 c4 4c             	add    $0x4c,%esp
  800738:	5b                   	pop    %ebx
  800739:	5e                   	pop    %esi
  80073a:	5f                   	pop    %edi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 28             	sub    $0x28,%esp
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800749:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800750:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800753:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075a:	85 c0                	test   %eax,%eax
  80075c:	74 30                	je     80078e <vsnprintf+0x51>
  80075e:	85 d2                	test   %edx,%edx
  800760:	7e 2c                	jle    80078e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800769:	8b 45 10             	mov    0x10(%ebp),%eax
  80076c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800770:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800773:	89 44 24 04          	mov    %eax,0x4(%esp)
  800777:	c7 04 24 3f 03 80 00 	movl   $0x80033f,(%esp)
  80077e:	e8 01 fc ff ff       	call   800384 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800783:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800786:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078c:	eb 05                	jmp    800793 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	89 04 24             	mov    %eax,(%esp)
  8007b6:	e8 82 ff ff ff       	call   80073d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    
  8007bd:	00 00                	add    %al,(%eax)
	...

008007c0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ce:	74 09                	je     8007d9 <strlen+0x19>
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0x10>
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ea:	85 c9                	test   %ecx,%ecx
  8007ec:	74 1a                	je     800808 <strnlen+0x2d>
  8007ee:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007f1:	74 15                	je     800808 <strnlen+0x2d>
  8007f3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8007f8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fa:	39 ca                	cmp    %ecx,%edx
  8007fc:	74 0a                	je     800808 <strnlen+0x2d>
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800806:	75 f0                	jne    8007f8 <strnlen+0x1d>
		n++;
	return n;
}
  800808:	5b                   	pop    %ebx
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800815:	ba 00 00 00 00       	mov    $0x0,%edx
  80081a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80081e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800821:	83 c2 01             	add    $0x1,%edx
  800824:	84 c9                	test   %cl,%cl
  800826:	75 f2                	jne    80081a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800828:	5b                   	pop    %ebx
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
  800836:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800839:	85 f6                	test   %esi,%esi
  80083b:	74 18                	je     800855 <strncpy+0x2a>
  80083d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800842:	0f b6 1a             	movzbl (%edx),%ebx
  800845:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800848:	80 3a 01             	cmpb   $0x1,(%edx)
  80084b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	39 f1                	cmp    %esi,%ecx
  800853:	75 ed                	jne    800842 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	57                   	push   %edi
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800865:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	89 f8                	mov    %edi,%eax
  80086a:	85 f6                	test   %esi,%esi
  80086c:	74 2b                	je     800899 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80086e:	83 fe 01             	cmp    $0x1,%esi
  800871:	74 23                	je     800896 <strlcpy+0x3d>
  800873:	0f b6 0b             	movzbl (%ebx),%ecx
  800876:	84 c9                	test   %cl,%cl
  800878:	74 1c                	je     800896 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  80087a:	83 ee 02             	sub    $0x2,%esi
  80087d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800882:	88 08                	mov    %cl,(%eax)
  800884:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800887:	39 f2                	cmp    %esi,%edx
  800889:	74 0b                	je     800896 <strlcpy+0x3d>
  80088b:	83 c2 01             	add    $0x1,%edx
  80088e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800892:	84 c9                	test   %cl,%cl
  800894:	75 ec                	jne    800882 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800896:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800899:	29 f8                	sub    %edi,%eax
}
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5f                   	pop    %edi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a9:	0f b6 01             	movzbl (%ecx),%eax
  8008ac:	84 c0                	test   %al,%al
  8008ae:	74 16                	je     8008c6 <strcmp+0x26>
  8008b0:	3a 02                	cmp    (%edx),%al
  8008b2:	75 12                	jne    8008c6 <strcmp+0x26>
		p++, q++;
  8008b4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8008bb:	84 c0                	test   %al,%al
  8008bd:	74 07                	je     8008c6 <strcmp+0x26>
  8008bf:	83 c1 01             	add    $0x1,%ecx
  8008c2:	3a 02                	cmp    (%edx),%al
  8008c4:	74 ee                	je     8008b4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 c0             	movzbl %al,%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008da:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	74 28                	je     80090e <strncmp+0x3e>
  8008e6:	0f b6 01             	movzbl (%ecx),%eax
  8008e9:	84 c0                	test   %al,%al
  8008eb:	74 24                	je     800911 <strncmp+0x41>
  8008ed:	3a 03                	cmp    (%ebx),%al
  8008ef:	75 20                	jne    800911 <strncmp+0x41>
  8008f1:	83 ea 01             	sub    $0x1,%edx
  8008f4:	74 13                	je     800909 <strncmp+0x39>
		n--, p++, q++;
  8008f6:	83 c1 01             	add    $0x1,%ecx
  8008f9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008fc:	0f b6 01             	movzbl (%ecx),%eax
  8008ff:	84 c0                	test   %al,%al
  800901:	74 0e                	je     800911 <strncmp+0x41>
  800903:	3a 03                	cmp    (%ebx),%al
  800905:	74 ea                	je     8008f1 <strncmp+0x21>
  800907:	eb 08                	jmp    800911 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090e:	5b                   	pop    %ebx
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800911:	0f b6 01             	movzbl (%ecx),%eax
  800914:	0f b6 13             	movzbl (%ebx),%edx
  800917:	29 d0                	sub    %edx,%eax
  800919:	eb f3                	jmp    80090e <strncmp+0x3e>

0080091b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	0f b6 10             	movzbl (%eax),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 1c                	je     800948 <strchr+0x2d>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	75 09                	jne    800939 <strchr+0x1e>
  800930:	eb 1b                	jmp    80094d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800932:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 14                	je     80094d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800939:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  80093d:	84 d2                	test   %dl,%dl
  80093f:	75 f1                	jne    800932 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
  800946:	eb 05                	jmp    80094d <strchr+0x32>
  800948:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800959:	0f b6 10             	movzbl (%eax),%edx
  80095c:	84 d2                	test   %dl,%dl
  80095e:	74 14                	je     800974 <strfind+0x25>
		if (*s == c)
  800960:	38 ca                	cmp    %cl,%dl
  800962:	75 06                	jne    80096a <strfind+0x1b>
  800964:	eb 0e                	jmp    800974 <strfind+0x25>
  800966:	38 ca                	cmp    %cl,%dl
  800968:	74 0a                	je     800974 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
  800970:	84 d2                	test   %dl,%dl
  800972:	75 f2                	jne    800966 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800980:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800983:	89 da                	mov    %ebx,%edx
  800985:	83 ea 01             	sub    $0x1,%edx
  800988:	78 0d                	js     800997 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  80098a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  80098c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  80098e:	88 0a                	mov    %cl,(%edx)
  800990:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800993:	39 da                	cmp    %ebx,%edx
  800995:	75 f7                	jne    80098e <memset+0x18>
		*p++ = c;

	return v;
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	57                   	push   %edi
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a9:	39 c6                	cmp    %eax,%esi
  8009ab:	72 0b                	jb     8009b8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  8009ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b2:	85 db                	test   %ebx,%ebx
  8009b4:	75 29                	jne    8009df <memmove+0x45>
  8009b6:	eb 35                	jmp    8009ed <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  8009bb:	39 c8                	cmp    %ecx,%eax
  8009bd:	73 ee                	jae    8009ad <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  8009bf:	85 db                	test   %ebx,%ebx
  8009c1:	74 2a                	je     8009ed <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  8009c3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  8009c6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  8009c8:	f7 db                	neg    %ebx
  8009ca:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  8009cd:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  8009cf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  8009d4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  8009d8:	83 ea 01             	sub    $0x1,%edx
  8009db:	75 f2                	jne    8009cf <memmove+0x35>
  8009dd:	eb 0e                	jmp    8009ed <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  8009df:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  8009e3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009e6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  8009e9:	39 d3                	cmp    %edx,%ebx
  8009eb:	75 f2                	jne    8009df <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 89 ff ff ff       	call   80099a <memmove>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	85 ff                	test   %edi,%edi
  800a29:	74 37                	je     800a62 <memcmp+0x4f>
		if (*s1 != *s2)
  800a2b:	0f b6 03             	movzbl (%ebx),%eax
  800a2e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a31:	83 ef 01             	sub    $0x1,%edi
  800a34:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a39:	38 c8                	cmp    %cl,%al
  800a3b:	74 1c                	je     800a59 <memcmp+0x46>
  800a3d:	eb 10                	jmp    800a4f <memcmp+0x3c>
  800a3f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a44:	83 c2 01             	add    $0x1,%edx
  800a47:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a4b:	38 c8                	cmp    %cl,%al
  800a4d:	74 0a                	je     800a59 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800a4f:	0f b6 c0             	movzbl %al,%eax
  800a52:	0f b6 c9             	movzbl %cl,%ecx
  800a55:	29 c8                	sub    %ecx,%eax
  800a57:	eb 09                	jmp    800a62 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a59:	39 fa                	cmp    %edi,%edx
  800a5b:	75 e2                	jne    800a3f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a6d:	89 c2                	mov    %eax,%edx
  800a6f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a72:	39 d0                	cmp    %edx,%eax
  800a74:	73 15                	jae    800a8b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a76:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800a7a:	38 08                	cmp    %cl,(%eax)
  800a7c:	75 06                	jne    800a84 <memfind+0x1d>
  800a7e:	eb 0b                	jmp    800a8b <memfind+0x24>
  800a80:	38 08                	cmp    %cl,(%eax)
  800a82:	74 07                	je     800a8b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a84:	83 c0 01             	add    $0x1,%eax
  800a87:	39 d0                	cmp    %edx,%eax
  800a89:	75 f5                	jne    800a80 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
  800a96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a99:	0f b6 02             	movzbl (%edx),%eax
  800a9c:	3c 20                	cmp    $0x20,%al
  800a9e:	74 04                	je     800aa4 <strtol+0x17>
  800aa0:	3c 09                	cmp    $0x9,%al
  800aa2:	75 0e                	jne    800ab2 <strtol+0x25>
		s++;
  800aa4:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa7:	0f b6 02             	movzbl (%edx),%eax
  800aaa:	3c 20                	cmp    $0x20,%al
  800aac:	74 f6                	je     800aa4 <strtol+0x17>
  800aae:	3c 09                	cmp    $0x9,%al
  800ab0:	74 f2                	je     800aa4 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab2:	3c 2b                	cmp    $0x2b,%al
  800ab4:	75 0a                	jne    800ac0 <strtol+0x33>
		s++;
  800ab6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab9:	bf 00 00 00 00       	mov    $0x0,%edi
  800abe:	eb 10                	jmp    800ad0 <strtol+0x43>
  800ac0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac5:	3c 2d                	cmp    $0x2d,%al
  800ac7:	75 07                	jne    800ad0 <strtol+0x43>
		s++, neg = 1;
  800ac9:	83 c2 01             	add    $0x1,%edx
  800acc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad0:	85 db                	test   %ebx,%ebx
  800ad2:	0f 94 c0             	sete   %al
  800ad5:	74 05                	je     800adc <strtol+0x4f>
  800ad7:	83 fb 10             	cmp    $0x10,%ebx
  800ada:	75 15                	jne    800af1 <strtol+0x64>
  800adc:	80 3a 30             	cmpb   $0x30,(%edx)
  800adf:	75 10                	jne    800af1 <strtol+0x64>
  800ae1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ae5:	75 0a                	jne    800af1 <strtol+0x64>
		s += 2, base = 16;
  800ae7:	83 c2 02             	add    $0x2,%edx
  800aea:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aef:	eb 13                	jmp    800b04 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800af1:	84 c0                	test   %al,%al
  800af3:	74 0f                	je     800b04 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afa:	80 3a 30             	cmpb   $0x30,(%edx)
  800afd:	75 05                	jne    800b04 <strtol+0x77>
		s++, base = 8;
  800aff:	83 c2 01             	add    $0x1,%edx
  800b02:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b0b:	0f b6 0a             	movzbl (%edx),%ecx
  800b0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b11:	80 fb 09             	cmp    $0x9,%bl
  800b14:	77 08                	ja     800b1e <strtol+0x91>
			dig = *s - '0';
  800b16:	0f be c9             	movsbl %cl,%ecx
  800b19:	83 e9 30             	sub    $0x30,%ecx
  800b1c:	eb 1e                	jmp    800b3c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b21:	80 fb 19             	cmp    $0x19,%bl
  800b24:	77 08                	ja     800b2e <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b26:	0f be c9             	movsbl %cl,%ecx
  800b29:	83 e9 57             	sub    $0x57,%ecx
  800b2c:	eb 0e                	jmp    800b3c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b31:	80 fb 19             	cmp    $0x19,%bl
  800b34:	77 14                	ja     800b4a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b36:	0f be c9             	movsbl %cl,%ecx
  800b39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b3c:	39 f1                	cmp    %esi,%ecx
  800b3e:	7d 0e                	jge    800b4e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b40:	83 c2 01             	add    $0x1,%edx
  800b43:	0f af c6             	imul   %esi,%eax
  800b46:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b48:	eb c1                	jmp    800b0b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b4a:	89 c1                	mov    %eax,%ecx
  800b4c:	eb 02                	jmp    800b50 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b4e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b54:	74 05                	je     800b5b <strtol+0xce>
		*endptr = (char *) s;
  800b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b59:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b5b:	89 ca                	mov    %ecx,%edx
  800b5d:	f7 da                	neg    %edx
  800b5f:	85 ff                	test   %edi,%edi
  800b61:	0f 45 c2             	cmovne %edx,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    
  800b69:	00 00                	add    %al,(%eax)
	...

00800b6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 0c             	sub    $0xc,%esp
  800b72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b78:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	89 c3                	mov    %eax,%ebx
  800b88:	89 c7                	mov    %eax,%edi
  800b8a:	89 c6                	mov    %eax,%esi
  800b8c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b91:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b94:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b97:	89 ec                	mov    %ebp,%esp
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ba4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ba7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc7:	89 ec                	mov    %ebp,%esp
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 38             	sub    $0x38,%esp
  800bd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 cb                	mov    %ecx,%ebx
  800be9:	89 cf                	mov    %ecx,%edi
  800beb:	89 ce                	mov    %ecx,%esi
  800bed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 28                	jle    800c1b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bfe:	00 
  800bff:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800c16:	e8 79 03 00 00       	call   800f94 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c24:	89 ec                	mov    %ebp,%esp
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800c3c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c41:	89 d1                	mov    %edx,%ecx
  800c43:	89 d3                	mov    %edx,%ebx
  800c45:	89 d7                	mov    %edx,%edi
  800c47:	89 d6                	mov    %edx,%esi
  800c49:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c54:	89 ec                	mov    %ebp,%esp
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_yield>:

void
sys_yield(void)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c61:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c64:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c71:	89 d1                	mov    %edx,%ecx
  800c73:	89 d3                	mov    %edx,%ebx
  800c75:	89 d7                	mov    %edx,%edi
  800c77:	89 d6                	mov    %edx,%esi
  800c79:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c7e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c81:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c84:	89 ec                	mov    %ebp,%esp
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 38             	sub    $0x38,%esp
  800c8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c91:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c94:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	be 00 00 00 00       	mov    $0x0,%esi
  800c9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	89 f7                	mov    %esi,%edi
  800cac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 28                	jle    800cda <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cbd:	00 
  800cbe:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800cc5:	00 
  800cc6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ccd:	00 
  800cce:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800cd5:	e8 ba 02 00 00       	call   800f94 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cda:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cdd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce3:	89 ec                	mov    %ebp,%esp
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 38             	sub    $0x38,%esp
  800ced:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	7e 28                	jle    800d38 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d14:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d1b:	00 
  800d1c:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800d23:	00 
  800d24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2b:	00 
  800d2c:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800d33:	e8 5c 02 00 00       	call   800f94 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d38:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d41:	89 ec                	mov    %ebp,%esp
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 38             	sub    $0x38,%esp
  800d4b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d51:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d59:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	89 df                	mov    %ebx,%edi
  800d66:	89 de                	mov    %ebx,%esi
  800d68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7e 28                	jle    800d96 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d72:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d79:	00 
  800d7a:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800d81:	00 
  800d82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d89:	00 
  800d8a:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800d91:	e8 fe 01 00 00       	call   800f94 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9f:	89 ec                	mov    %ebp,%esp
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 38             	sub    $0x38,%esp
  800da9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800daf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db7:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 28                	jle    800df4 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd0:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800ddf:	00 
  800de0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de7:	00 
  800de8:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800def:	e8 a0 01 00 00       	call   800f94 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfd:	89 ec                	mov    %ebp,%esp
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 38             	sub    $0x38,%esp
  800e07:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e4d:	e8 42 01 00 00       	call   800f94 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e52:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e55:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e58:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5b:	89 ec                	mov    %ebp,%esp
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	83 ec 38             	sub    $0x38,%esp
  800e65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	7e 28                	jle    800eb0 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e93:	00 
  800e94:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea3:	00 
  800ea4:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800eab:	e8 e4 00 00 00       	call   800f94 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eb9:	89 ec                	mov    %ebp,%esp
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ec9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	be 00 00 00 00       	mov    $0x0,%esi
  800ed1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ed6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ee4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eed:	89 ec                	mov    %ebp,%esp
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 38             	sub    $0x38,%esp
  800ef7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800efa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f05:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0d:	89 cb                	mov    %ecx,%ebx
  800f0f:	89 cf                	mov    %ecx,%edi
  800f11:	89 ce                	mov    %ecx,%esi
  800f13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	7e 28                	jle    800f41 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f24:	00 
  800f25:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800f3c:	e8 53 00 00 00       	call   800f94 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f41:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f44:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f47:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4a:	89 ec                	mov    %ebp,%esp
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    
	...

00800f50 <ipc_recv>:
//   Use 'env' to discover the value and who sent it.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f56:	c7 44 24 08 6f 15 80 	movl   $0x80156f,0x8(%esp)
  800f5d:	00 
  800f5e:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800f65:	00 
  800f66:	c7 04 24 88 15 80 00 	movl   $0x801588,(%esp)
  800f6d:	e8 22 00 00 00       	call   800f94 <_panic>

00800f72 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800f78:	c7 44 24 08 92 15 80 	movl   $0x801592,0x8(%esp)
  800f7f:	00 
  800f80:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800f87:	00 
  800f88:	c7 04 24 88 15 80 00 	movl   $0x801588,(%esp)
  800f8f:	e8 00 00 00 00       	call   800f94 <_panic>

00800f94 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800f9a:	a1 08 20 80 00       	mov    0x802008,%eax
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	74 10                	je     800fb3 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa7:	c7 04 24 ab 15 80 00 	movl   $0x8015ab,(%esp)
  800fae:	e8 18 f2 ff ff       	call   8001cb <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc1:	a1 00 20 80 00       	mov    0x802000,%eax
  800fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fca:	c7 04 24 b0 15 80 00 	movl   $0x8015b0,(%esp)
  800fd1:	e8 f5 f1 ff ff       	call   8001cb <cprintf>
	vcprintf(fmt, ap);
  800fd6:	8d 45 14             	lea    0x14(%ebp),%eax
  800fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe0:	89 04 24             	mov    %eax,(%esp)
  800fe3:	e8 82 f1 ff ff       	call   80016a <vcprintf>
	cprintf("\n");
  800fe8:	c7 04 24 cf 12 80 00 	movl   $0x8012cf,(%esp)
  800fef:	e8 d7 f1 ff ff       	call   8001cb <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ff4:	cc                   	int3   
  800ff5:	eb fd                	jmp    800ff4 <_panic+0x60>
	...

00801000 <__udivdi3>:
  801000:	83 ec 1c             	sub    $0x1c,%esp
  801003:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801007:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80100b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80100f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801013:	89 74 24 10          	mov    %esi,0x10(%esp)
  801017:	8b 74 24 24          	mov    0x24(%esp),%esi
  80101b:	85 ff                	test   %edi,%edi
  80101d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801021:	89 44 24 08          	mov    %eax,0x8(%esp)
  801025:	89 cd                	mov    %ecx,%ebp
  801027:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102b:	75 33                	jne    801060 <__udivdi3+0x60>
  80102d:	39 f1                	cmp    %esi,%ecx
  80102f:	77 57                	ja     801088 <__udivdi3+0x88>
  801031:	85 c9                	test   %ecx,%ecx
  801033:	75 0b                	jne    801040 <__udivdi3+0x40>
  801035:	b8 01 00 00 00       	mov    $0x1,%eax
  80103a:	31 d2                	xor    %edx,%edx
  80103c:	f7 f1                	div    %ecx
  80103e:	89 c1                	mov    %eax,%ecx
  801040:	89 f0                	mov    %esi,%eax
  801042:	31 d2                	xor    %edx,%edx
  801044:	f7 f1                	div    %ecx
  801046:	89 c6                	mov    %eax,%esi
  801048:	8b 44 24 04          	mov    0x4(%esp),%eax
  80104c:	f7 f1                	div    %ecx
  80104e:	89 f2                	mov    %esi,%edx
  801050:	8b 74 24 10          	mov    0x10(%esp),%esi
  801054:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801058:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80105c:	83 c4 1c             	add    $0x1c,%esp
  80105f:	c3                   	ret    
  801060:	31 d2                	xor    %edx,%edx
  801062:	31 c0                	xor    %eax,%eax
  801064:	39 f7                	cmp    %esi,%edi
  801066:	77 e8                	ja     801050 <__udivdi3+0x50>
  801068:	0f bd cf             	bsr    %edi,%ecx
  80106b:	83 f1 1f             	xor    $0x1f,%ecx
  80106e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801072:	75 2c                	jne    8010a0 <__udivdi3+0xa0>
  801074:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801078:	76 04                	jbe    80107e <__udivdi3+0x7e>
  80107a:	39 f7                	cmp    %esi,%edi
  80107c:	73 d2                	jae    801050 <__udivdi3+0x50>
  80107e:	31 d2                	xor    %edx,%edx
  801080:	b8 01 00 00 00       	mov    $0x1,%eax
  801085:	eb c9                	jmp    801050 <__udivdi3+0x50>
  801087:	90                   	nop
  801088:	89 f2                	mov    %esi,%edx
  80108a:	f7 f1                	div    %ecx
  80108c:	31 d2                	xor    %edx,%edx
  80108e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801092:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801096:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80109a:	83 c4 1c             	add    $0x1c,%esp
  80109d:	c3                   	ret    
  80109e:	66 90                	xchg   %ax,%ax
  8010a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010a5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010aa:	89 ea                	mov    %ebp,%edx
  8010ac:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010b0:	d3 e7                	shl    %cl,%edi
  8010b2:	89 c1                	mov    %eax,%ecx
  8010b4:	d3 ea                	shr    %cl,%edx
  8010b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010bb:	09 fa                	or     %edi,%edx
  8010bd:	89 f7                	mov    %esi,%edi
  8010bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010c3:	89 f2                	mov    %esi,%edx
  8010c5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010c9:	d3 e5                	shl    %cl,%ebp
  8010cb:	89 c1                	mov    %eax,%ecx
  8010cd:	d3 ef                	shr    %cl,%edi
  8010cf:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010d4:	d3 e2                	shl    %cl,%edx
  8010d6:	89 c1                	mov    %eax,%ecx
  8010d8:	d3 ee                	shr    %cl,%esi
  8010da:	09 d6                	or     %edx,%esi
  8010dc:	89 fa                	mov    %edi,%edx
  8010de:	89 f0                	mov    %esi,%eax
  8010e0:	f7 74 24 0c          	divl   0xc(%esp)
  8010e4:	89 d7                	mov    %edx,%edi
  8010e6:	89 c6                	mov    %eax,%esi
  8010e8:	f7 e5                	mul    %ebp
  8010ea:	39 d7                	cmp    %edx,%edi
  8010ec:	72 22                	jb     801110 <__udivdi3+0x110>
  8010ee:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  8010f2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010f7:	d3 e5                	shl    %cl,%ebp
  8010f9:	39 c5                	cmp    %eax,%ebp
  8010fb:	73 04                	jae    801101 <__udivdi3+0x101>
  8010fd:	39 d7                	cmp    %edx,%edi
  8010ff:	74 0f                	je     801110 <__udivdi3+0x110>
  801101:	89 f0                	mov    %esi,%eax
  801103:	31 d2                	xor    %edx,%edx
  801105:	e9 46 ff ff ff       	jmp    801050 <__udivdi3+0x50>
  80110a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801110:	8d 46 ff             	lea    -0x1(%esi),%eax
  801113:	31 d2                	xor    %edx,%edx
  801115:	8b 74 24 10          	mov    0x10(%esp),%esi
  801119:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80111d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801121:	83 c4 1c             	add    $0x1c,%esp
  801124:	c3                   	ret    
	...

00801130 <__umoddi3>:
  801130:	83 ec 1c             	sub    $0x1c,%esp
  801133:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801137:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80113b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80113f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801143:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801147:	8b 74 24 24          	mov    0x24(%esp),%esi
  80114b:	85 ed                	test   %ebp,%ebp
  80114d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801151:	89 44 24 08          	mov    %eax,0x8(%esp)
  801155:	89 cf                	mov    %ecx,%edi
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	89 f2                	mov    %esi,%edx
  80115c:	75 1a                	jne    801178 <__umoddi3+0x48>
  80115e:	39 f1                	cmp    %esi,%ecx
  801160:	76 4e                	jbe    8011b0 <__umoddi3+0x80>
  801162:	f7 f1                	div    %ecx
  801164:	89 d0                	mov    %edx,%eax
  801166:	31 d2                	xor    %edx,%edx
  801168:	8b 74 24 10          	mov    0x10(%esp),%esi
  80116c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801170:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801174:	83 c4 1c             	add    $0x1c,%esp
  801177:	c3                   	ret    
  801178:	39 f5                	cmp    %esi,%ebp
  80117a:	77 54                	ja     8011d0 <__umoddi3+0xa0>
  80117c:	0f bd c5             	bsr    %ebp,%eax
  80117f:	83 f0 1f             	xor    $0x1f,%eax
  801182:	89 44 24 04          	mov    %eax,0x4(%esp)
  801186:	75 60                	jne    8011e8 <__umoddi3+0xb8>
  801188:	3b 0c 24             	cmp    (%esp),%ecx
  80118b:	0f 87 07 01 00 00    	ja     801298 <__umoddi3+0x168>
  801191:	89 f2                	mov    %esi,%edx
  801193:	8b 34 24             	mov    (%esp),%esi
  801196:	29 ce                	sub    %ecx,%esi
  801198:	19 ea                	sbb    %ebp,%edx
  80119a:	89 34 24             	mov    %esi,(%esp)
  80119d:	8b 04 24             	mov    (%esp),%eax
  8011a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011a4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011a8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ac:	83 c4 1c             	add    $0x1c,%esp
  8011af:	c3                   	ret    
  8011b0:	85 c9                	test   %ecx,%ecx
  8011b2:	75 0b                	jne    8011bf <__umoddi3+0x8f>
  8011b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b9:	31 d2                	xor    %edx,%edx
  8011bb:	f7 f1                	div    %ecx
  8011bd:	89 c1                	mov    %eax,%ecx
  8011bf:	89 f0                	mov    %esi,%eax
  8011c1:	31 d2                	xor    %edx,%edx
  8011c3:	f7 f1                	div    %ecx
  8011c5:	8b 04 24             	mov    (%esp),%eax
  8011c8:	f7 f1                	div    %ecx
  8011ca:	eb 98                	jmp    801164 <__umoddi3+0x34>
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	89 f2                	mov    %esi,%edx
  8011d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011d6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011da:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011de:	83 c4 1c             	add    $0x1c,%esp
  8011e1:	c3                   	ret    
  8011e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011e8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011ed:	89 e8                	mov    %ebp,%eax
  8011ef:	bd 20 00 00 00       	mov    $0x20,%ebp
  8011f4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  8011f8:	89 fa                	mov    %edi,%edx
  8011fa:	d3 e0                	shl    %cl,%eax
  8011fc:	89 e9                	mov    %ebp,%ecx
  8011fe:	d3 ea                	shr    %cl,%edx
  801200:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801205:	09 c2                	or     %eax,%edx
  801207:	8b 44 24 08          	mov    0x8(%esp),%eax
  80120b:	89 14 24             	mov    %edx,(%esp)
  80120e:	89 f2                	mov    %esi,%edx
  801210:	d3 e7                	shl    %cl,%edi
  801212:	89 e9                	mov    %ebp,%ecx
  801214:	d3 ea                	shr    %cl,%edx
  801216:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80121b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80121f:	d3 e6                	shl    %cl,%esi
  801221:	89 e9                	mov    %ebp,%ecx
  801223:	d3 e8                	shr    %cl,%eax
  801225:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80122a:	09 f0                	or     %esi,%eax
  80122c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801230:	f7 34 24             	divl   (%esp)
  801233:	d3 e6                	shl    %cl,%esi
  801235:	89 74 24 08          	mov    %esi,0x8(%esp)
  801239:	89 d6                	mov    %edx,%esi
  80123b:	f7 e7                	mul    %edi
  80123d:	39 d6                	cmp    %edx,%esi
  80123f:	89 c1                	mov    %eax,%ecx
  801241:	89 d7                	mov    %edx,%edi
  801243:	72 3f                	jb     801284 <__umoddi3+0x154>
  801245:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801249:	72 35                	jb     801280 <__umoddi3+0x150>
  80124b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80124f:	29 c8                	sub    %ecx,%eax
  801251:	19 fe                	sbb    %edi,%esi
  801253:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801258:	89 f2                	mov    %esi,%edx
  80125a:	d3 e8                	shr    %cl,%eax
  80125c:	89 e9                	mov    %ebp,%ecx
  80125e:	d3 e2                	shl    %cl,%edx
  801260:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801265:	09 d0                	or     %edx,%eax
  801267:	89 f2                	mov    %esi,%edx
  801269:	d3 ea                	shr    %cl,%edx
  80126b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80126f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801273:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801277:	83 c4 1c             	add    $0x1c,%esp
  80127a:	c3                   	ret    
  80127b:	90                   	nop
  80127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801280:	39 d6                	cmp    %edx,%esi
  801282:	75 c7                	jne    80124b <__umoddi3+0x11b>
  801284:	89 d7                	mov    %edx,%edi
  801286:	89 c1                	mov    %eax,%ecx
  801288:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80128c:	1b 3c 24             	sbb    (%esp),%edi
  80128f:	eb ba                	jmp    80124b <__umoddi3+0x11b>
  801291:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801298:	39 f5                	cmp    %esi,%ebp
  80129a:	0f 82 f1 fe ff ff    	jb     801191 <__umoddi3+0x61>
  8012a0:	e9 f8 fe ff ff       	jmp    80119d <__umoddi3+0x6d>
