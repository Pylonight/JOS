
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 15 0c 00 00       	call   800c58 <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  800052:	e8 ac 01 00 00       	call   800203 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 38             	sub    $0x38,%esp
  800083:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800086:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800089:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80008c:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800090:	89 1c 24             	mov    %ebx,(%esp)
  800093:	e8 58 07 00 00       	call   8007f0 <strlen>
  800098:	83 f8 02             	cmp    $0x2,%eax
  80009b:	7f 41                	jg     8000de <forkchild+0x61>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000aa:	c7 44 24 08 f1 12 80 	movl   $0x8012f1,0x8(%esp)
  8000b1:	00 
  8000b2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b9:	00 
  8000ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000bd:	89 04 24             	mov    %eax,(%esp)
  8000c0:	e8 00 07 00 00       	call   8007c5 <snprintf>
	if (fork() == 0) {
  8000c5:	e8 b6 0e 00 00       	call   800f80 <fork>
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	75 10                	jne    8000de <forkchild+0x61>
		forktree(nxt);
  8000ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000d1:	89 04 24             	mov    %eax,(%esp)
  8000d4:	e8 5b ff ff ff       	call   800034 <forktree>
		exit();
  8000d9:	e8 6e 00 00 00       	call   80014c <exit>
	}
}
  8000de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e1:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e4:	89 ec                	mov    %ebp,%esp
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <umain>:
	forkchild(cur, '1');
}

void
umain(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000ee:	c7 04 24 f0 12 80 00 	movl   $0x8012f0,(%esp)
  8000f5:	e8 3a ff ff ff       	call   800034 <forktree>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800105:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800108:	8b 75 08             	mov    0x8(%ebp),%esi
  80010b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  80010e:	e8 45 0b 00 00       	call   800c58 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 f6                	test   %esi,%esi
  800127:	7e 07                	jle    800130 <libmain+0x34>
		binaryname = argv[0];
  800129:	8b 03                	mov    (%ebx),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800134:	89 34 24             	mov    %esi,(%esp)
  800137:	e8 ac ff ff ff       	call   8000e8 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0b 00 00 00       	call   80014c <exit>
}
  800141:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800144:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 9d 0a 00 00       	call   800bfb <sys_env_destroy>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 14             	sub    $0x14,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 03                	mov    (%ebx),%eax
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800173:	83 c0 01             	add    $0x1,%eax
  800176:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800178:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017d:	75 19                	jne    800198 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80017f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800186:	00 
  800187:	8d 43 08             	lea    0x8(%ebx),%eax
  80018a:	89 04 24             	mov    %eax,(%esp)
  80018d:	e8 0a 0a 00 00       	call   800b9c <sys_cputs>
		b->idx = 0;
  800192:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800198:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019c:	83 c4 14             	add    $0x14,%esp
  80019f:	5b                   	pop    %ebx
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    

008001a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b2:	00 00 00 
	b.cnt = 0;
  8001b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	c7 04 24 60 01 80 00 	movl   $0x800160,(%esp)
  8001de:	e8 d1 01 00 00       	call   8003b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 a1 09 00 00       	call   800b9c <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	8b 45 08             	mov    0x8(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 87 ff ff ff       	call   8001a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 3c             	sub    $0x3c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d7                	mov    %edx,%edi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
  800237:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80023d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	b8 00 00 00 00       	mov    $0x0,%eax
  800245:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800248:	72 11                	jb     80025b <printnum+0x3b>
  80024a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800250:	76 09                	jbe    80025b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800252:	83 eb 01             	sub    $0x1,%ebx
  800255:	85 db                	test   %ebx,%ebx
  800257:	7f 51                	jg     8002aa <printnum+0x8a>
  800259:	eb 5e                	jmp    8002b9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800266:	8b 45 10             	mov    0x10(%ebp),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800271:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800275:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027c:	00 
  80027d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028a:	e8 a1 0d 00 00       	call   801030 <__udivdi3>
  80028f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800293:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800297:	89 04 24             	mov    %eax,(%esp)
  80029a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80029e:	89 fa                	mov    %edi,%edx
  8002a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002a3:	e8 78 ff ff ff       	call   800220 <printnum>
  8002a8:	eb 0f                	jmp    8002b9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ae:	89 34 24             	mov    %esi,(%esp)
  8002b1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b4:	83 eb 01             	sub    $0x1,%ebx
  8002b7:	75 f1                	jne    8002aa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cf:	00 
  8002d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dd:	e8 7e 0e 00 00       	call   801160 <__umoddi3>
  8002e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e6:	0f be 80 0d 13 80 00 	movsbl 0x80130d(%eax),%eax
  8002ed:	89 04 24             	mov    %eax,(%esp)
  8002f0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002f3:	83 c4 3c             	add    $0x3c,%esp
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fe:	83 fa 01             	cmp    $0x1,%edx
  800301:	7e 0e                	jle    800311 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800303:	8b 10                	mov    (%eax),%edx
  800305:	8d 4a 08             	lea    0x8(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 02                	mov    (%edx),%eax
  80030c:	8b 52 04             	mov    0x4(%edx),%edx
  80030f:	eb 22                	jmp    800333 <getuint+0x38>
	else if (lflag)
  800311:	85 d2                	test   %edx,%edx
  800313:	74 10                	je     800325 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800315:	8b 10                	mov    (%eax),%edx
  800317:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031a:	89 08                	mov    %ecx,(%eax)
  80031c:	8b 02                	mov    (%edx),%eax
  80031e:	ba 00 00 00 00       	mov    $0x0,%edx
  800323:	eb 0e                	jmp    800333 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800325:	8b 10                	mov    (%eax),%edx
  800327:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 02                	mov    (%edx),%eax
  80032e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800338:	83 fa 01             	cmp    $0x1,%edx
  80033b:	7e 0e                	jle    80034b <getint+0x16>
		return va_arg(*ap, long long);
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 02                	mov    (%edx),%eax
  800346:	8b 52 04             	mov    0x4(%edx),%edx
  800349:	eb 22                	jmp    80036d <getint+0x38>
	else if (lflag)
  80034b:	85 d2                	test   %edx,%edx
  80034d:	74 10                	je     80035f <getint+0x2a>
		return va_arg(*ap, long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 04             	lea    0x4(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	89 c2                	mov    %eax,%edx
  80035a:	c1 fa 1f             	sar    $0x1f,%edx
  80035d:	eb 0e                	jmp    80036d <getint+0x38>
	else
		return va_arg(*ap, int);
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	8d 4a 04             	lea    0x4(%edx),%ecx
  800364:	89 08                	mov    %ecx,(%eax)
  800366:	8b 02                	mov    (%edx),%eax
  800368:	89 c2                	mov    %eax,%edx
  80036a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800375:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 0a                	jae    80038a <sprintputch+0x1b>
		*b->buf++ = ch;
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 0a                	mov    %cl,(%edx)
  800385:	83 c2 01             	add    $0x1,%edx
  800388:	89 10                	mov    %edx,(%eax)
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800392:	8d 45 14             	lea    0x14(%ebp),%eax
  800395:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800399:	8b 45 10             	mov    0x10(%ebp),%eax
  80039c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	e8 02 00 00 00       	call   8003b4 <vprintfmt>
	va_end(ap);
}
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 4c             	sub    $0x4c,%esp
  8003bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003c0:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c3:	eb 12                	jmp    8003d7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	0f 84 98 03 00 00    	je     800765 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  8003cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d1:	89 04 24             	mov    %eax,(%esp)
  8003d4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d7:	0f b6 06             	movzbl (%esi),%eax
  8003da:	83 c6 01             	add    $0x1,%esi
  8003dd:	83 f8 25             	cmp    $0x25,%eax
  8003e0:	75 e3                	jne    8003c5 <vprintfmt+0x11>
  8003e2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003e6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003ed:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003f2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800401:	eb 2b                	jmp    80042e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800406:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80040a:	eb 22                	jmp    80042e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80040f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800413:	eb 19                	jmp    80042e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800418:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80041f:	eb 0d                	jmp    80042e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800421:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800424:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800427:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	0f b6 06             	movzbl (%esi),%eax
  800431:	0f b6 d0             	movzbl %al,%edx
  800434:	8d 7e 01             	lea    0x1(%esi),%edi
  800437:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80043a:	83 e8 23             	sub    $0x23,%eax
  80043d:	3c 55                	cmp    $0x55,%al
  80043f:	0f 87 fa 02 00 00    	ja     80073f <vprintfmt+0x38b>
  800445:	0f b6 c0             	movzbl %al,%eax
  800448:	ff 24 85 e0 13 80 00 	jmp    *0x8013e0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044f:	83 ea 30             	sub    $0x30,%edx
  800452:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800455:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800459:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80045f:	83 fa 09             	cmp    $0x9,%edx
  800462:	77 4a                	ja     8004ae <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800467:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80046a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80046d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800471:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800474:	8d 50 d0             	lea    -0x30(%eax),%edx
  800477:	83 fa 09             	cmp    $0x9,%edx
  80047a:	76 eb                	jbe    800467 <vprintfmt+0xb3>
  80047c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047f:	eb 2d                	jmp    8004ae <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800492:	eb 1a                	jmp    8004ae <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049b:	79 91                	jns    80042e <vprintfmt+0x7a>
  80049d:	e9 73 ff ff ff       	jmp    800415 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004a5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004ac:	eb 80                	jmp    80042e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  8004ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b2:	0f 89 76 ff ff ff    	jns    80042e <vprintfmt+0x7a>
  8004b8:	e9 64 ff ff ff       	jmp    800421 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004bd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c3:	e9 66 ff ff ff       	jmp    80042e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	89 04 24             	mov    %eax,(%esp)
  8004da:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e0:	e9 f2 fe ff ff       	jmp    8003d7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	89 c2                	mov    %eax,%edx
  8004f2:	c1 fa 1f             	sar    $0x1f,%edx
  8004f5:	31 d0                	xor    %edx,%eax
  8004f7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004f9:	83 f8 08             	cmp    $0x8,%eax
  8004fc:	7f 0b                	jg     800509 <vprintfmt+0x155>
  8004fe:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	75 23                	jne    80052c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800509:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050d:	c7 44 24 08 25 13 80 	movl   $0x801325,0x8(%esp)
  800514:	00 
  800515:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800519:	8b 7d 08             	mov    0x8(%ebp),%edi
  80051c:	89 3c 24             	mov    %edi,(%esp)
  80051f:	e8 68 fe ff ff       	call   80038c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800527:	e9 ab fe ff ff       	jmp    8003d7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80052c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800530:	c7 44 24 08 2e 13 80 	movl   $0x80132e,0x8(%esp)
  800537:	00 
  800538:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053f:	89 3c 24             	mov    %edi,(%esp)
  800542:	e8 45 fe ff ff       	call   80038c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054a:	e9 88 fe ff ff       	jmp    8003d7 <vprintfmt+0x23>
  80054f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800552:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800555:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 04             	lea    0x4(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800563:	85 f6                	test   %esi,%esi
  800565:	ba 1e 13 80 00       	mov    $0x80131e,%edx
  80056a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80056d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800571:	7e 06                	jle    800579 <vprintfmt+0x1c5>
  800573:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800577:	75 10                	jne    800589 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800579:	0f be 06             	movsbl (%esi),%eax
  80057c:	83 c6 01             	add    $0x1,%esi
  80057f:	85 c0                	test   %eax,%eax
  800581:	0f 85 86 00 00 00    	jne    80060d <vprintfmt+0x259>
  800587:	eb 76                	jmp    8005ff <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058d:	89 34 24             	mov    %esi,(%esp)
  800590:	e8 76 02 00 00       	call   80080b <strnlen>
  800595:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800598:	29 c2                	sub    %eax,%edx
  80059a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80059d:	85 d2                	test   %edx,%edx
  80059f:	7e d8                	jle    800579 <vprintfmt+0x1c5>
					putch(padc, putdat);
  8005a1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005a5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005a8:	89 7d d0             	mov    %edi,-0x30(%ebp)
  8005ab:	89 d6                	mov    %edx,%esi
  8005ad:	89 c7                	mov    %eax,%edi
  8005af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b3:	89 3c 24             	mov    %edi,(%esp)
  8005b6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	75 f1                	jne    8005af <vprintfmt+0x1fb>
  8005be:	8b 7d d0             	mov    -0x30(%ebp),%edi
  8005c1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8005c4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005c7:	eb b0                	jmp    800579 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cd:	74 18                	je     8005e7 <vprintfmt+0x233>
  8005cf:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005d2:	83 fa 5e             	cmp    $0x5e,%edx
  8005d5:	76 10                	jbe    8005e7 <vprintfmt+0x233>
					putch('?', putdat);
  8005d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005db:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005e2:	ff 55 08             	call   *0x8(%ebp)
  8005e5:	eb 0a                	jmp    8005f1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8005e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005f5:	0f be 06             	movsbl (%esi),%eax
  8005f8:	83 c6 01             	add    $0x1,%esi
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	75 0e                	jne    80060d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800602:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800606:	7f 11                	jg     800619 <vprintfmt+0x265>
  800608:	e9 ca fd ff ff       	jmp    8003d7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060d:	85 ff                	test   %edi,%edi
  80060f:	90                   	nop
  800610:	78 b7                	js     8005c9 <vprintfmt+0x215>
  800612:	83 ef 01             	sub    $0x1,%edi
  800615:	79 b2                	jns    8005c9 <vprintfmt+0x215>
  800617:	eb e6                	jmp    8005ff <vprintfmt+0x24b>
  800619:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80061c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800623:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80062a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062c:	83 ee 01             	sub    $0x1,%esi
  80062f:	75 ee                	jne    80061f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800631:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800634:	e9 9e fd ff ff       	jmp    8003d7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 f2 fc ff ff       	call   800335 <getint>
  800643:	89 c6                	mov    %eax,%esi
  800645:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064c:	85 d2                	test   %edx,%edx
  80064e:	0f 89 ad 00 00 00    	jns    800701 <vprintfmt+0x34d>
				putch('-', putdat);
  800654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800658:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800662:	f7 de                	neg    %esi
  800664:	83 d7 00             	adc    $0x0,%edi
  800667:	f7 df                	neg    %edi
			}
			base = 10;
  800669:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066e:	e9 8e 00 00 00       	jmp    800701 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800673:	89 ca                	mov    %ecx,%edx
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 7e fc ff ff       	call   8002fb <getuint>
  80067d:	89 c6                	mov    %eax,%esi
  80067f:	89 d7                	mov    %edx,%edi
			base = 10;
  800681:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800686:	eb 79                	jmp    800701 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800688:	89 ca                	mov    %ecx,%edx
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 a3 fc ff ff       	call   800335 <getint>
  800692:	89 c6                	mov    %eax,%esi
  800694:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800696:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069b:	85 d2                	test   %edx,%edx
  80069d:	79 62                	jns    800701 <vprintfmt+0x34d>
				putch('-', putdat);
  80069f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006aa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ad:	f7 de                	neg    %esi
  8006af:	83 d7 00             	adc    $0x0,%edi
  8006b2:	f7 df                	neg    %edi
			}
			base = 8;
  8006b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b9:	eb 46                	jmp    800701 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  8006bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bf:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 50 04             	lea    0x4(%eax),%edx
  8006dd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e0:	8b 30                	mov    (%eax),%esi
  8006e2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ec:	eb 13                	jmp    800701 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ee:	89 ca                	mov    %ecx,%edx
  8006f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f3:	e8 03 fc ff ff       	call   8002fb <getuint>
  8006f8:	89 c6                	mov    %eax,%esi
  8006fa:	89 d7                	mov    %edx,%edi
			base = 16;
  8006fc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800701:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800705:	89 54 24 10          	mov    %edx,0x10(%esp)
  800709:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800710:	89 44 24 08          	mov    %eax,0x8(%esp)
  800714:	89 34 24             	mov    %esi,(%esp)
  800717:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071b:	89 da                	mov    %ebx,%edx
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	e8 fb fa ff ff       	call   800220 <printnum>
			break;
  800725:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800728:	e9 aa fc ff ff       	jmp    8003d7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800731:	89 14 24             	mov    %edx,(%esp)
  800734:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800737:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073a:	e9 98 fc ff ff       	jmp    8003d7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800743:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80074a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800751:	0f 84 80 fc ff ff    	je     8003d7 <vprintfmt+0x23>
  800757:	83 ee 01             	sub    $0x1,%esi
  80075a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80075e:	75 f7                	jne    800757 <vprintfmt+0x3a3>
  800760:	e9 72 fc ff ff       	jmp    8003d7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800765:	83 c4 4c             	add    $0x4c,%esp
  800768:	5b                   	pop    %ebx
  800769:	5e                   	pop    %esi
  80076a:	5f                   	pop    %edi
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 28             	sub    $0x28,%esp
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800779:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800780:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800783:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078a:	85 c0                	test   %eax,%eax
  80078c:	74 30                	je     8007be <vsnprintf+0x51>
  80078e:	85 d2                	test   %edx,%edx
  800790:	7e 2c                	jle    8007be <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800799:	8b 45 10             	mov    0x10(%ebp),%eax
  80079c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a7:	c7 04 24 6f 03 80 00 	movl   $0x80036f,(%esp)
  8007ae:	e8 01 fc ff ff       	call   8003b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bc:	eb 05                	jmp    8007c3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	89 04 24             	mov    %eax,(%esp)
  8007e6:	e8 82 ff ff ff       	call   80076d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007eb:	c9                   	leave  
  8007ec:	c3                   	ret    
  8007ed:	00 00                	add    %al,(%eax)
	...

008007f0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007fe:	74 09                	je     800809 <strlen+0x19>
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800803:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800807:	75 f7                	jne    800800 <strlen+0x10>
		n++;
	return n;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800812:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
  80081a:	85 c9                	test   %ecx,%ecx
  80081c:	74 1a                	je     800838 <strnlen+0x2d>
  80081e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800821:	74 15                	je     800838 <strnlen+0x2d>
  800823:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800828:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082a:	39 ca                	cmp    %ecx,%edx
  80082c:	74 0a                	je     800838 <strnlen+0x2d>
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800836:	75 f0                	jne    800828 <strnlen+0x1d>
		n++;
	return n;
}
  800838:	5b                   	pop    %ebx
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800845:	ba 00 00 00 00       	mov    $0x0,%edx
  80084a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80084e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800851:	83 c2 01             	add    $0x1,%edx
  800854:	84 c9                	test   %cl,%cl
  800856:	75 f2                	jne    80084a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800858:	5b                   	pop    %ebx
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
  800866:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	85 f6                	test   %esi,%esi
  80086b:	74 18                	je     800885 <strncpy+0x2a>
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800872:	0f b6 1a             	movzbl (%edx),%ebx
  800875:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800878:	80 3a 01             	cmpb   $0x1,(%edx)
  80087b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087e:	83 c1 01             	add    $0x1,%ecx
  800881:	39 f1                	cmp    %esi,%ecx
  800883:	75 ed                	jne    800872 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	57                   	push   %edi
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800895:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800898:	89 f8                	mov    %edi,%eax
  80089a:	85 f6                	test   %esi,%esi
  80089c:	74 2b                	je     8008c9 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  80089e:	83 fe 01             	cmp    $0x1,%esi
  8008a1:	74 23                	je     8008c6 <strlcpy+0x3d>
  8008a3:	0f b6 0b             	movzbl (%ebx),%ecx
  8008a6:	84 c9                	test   %cl,%cl
  8008a8:	74 1c                	je     8008c6 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  8008aa:	83 ee 02             	sub    $0x2,%esi
  8008ad:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b2:	88 08                	mov    %cl,(%eax)
  8008b4:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b7:	39 f2                	cmp    %esi,%edx
  8008b9:	74 0b                	je     8008c6 <strlcpy+0x3d>
  8008bb:	83 c2 01             	add    $0x1,%edx
  8008be:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008c2:	84 c9                	test   %cl,%cl
  8008c4:	75 ec                	jne    8008b2 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  8008c6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c9:	29 f8                	sub    %edi,%eax
}
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d9:	0f b6 01             	movzbl (%ecx),%eax
  8008dc:	84 c0                	test   %al,%al
  8008de:	74 16                	je     8008f6 <strcmp+0x26>
  8008e0:	3a 02                	cmp    (%edx),%al
  8008e2:	75 12                	jne    8008f6 <strcmp+0x26>
		p++, q++;
  8008e4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  8008eb:	84 c0                	test   %al,%al
  8008ed:	74 07                	je     8008f6 <strcmp+0x26>
  8008ef:	83 c1 01             	add    $0x1,%ecx
  8008f2:	3a 02                	cmp    (%edx),%al
  8008f4:	74 ee                	je     8008e4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f6:	0f b6 c0             	movzbl %al,%eax
  8008f9:	0f b6 12             	movzbl (%edx),%edx
  8008fc:	29 d0                	sub    %edx,%eax
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	53                   	push   %ebx
  800904:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800907:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80090a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800912:	85 d2                	test   %edx,%edx
  800914:	74 28                	je     80093e <strncmp+0x3e>
  800916:	0f b6 01             	movzbl (%ecx),%eax
  800919:	84 c0                	test   %al,%al
  80091b:	74 24                	je     800941 <strncmp+0x41>
  80091d:	3a 03                	cmp    (%ebx),%al
  80091f:	75 20                	jne    800941 <strncmp+0x41>
  800921:	83 ea 01             	sub    $0x1,%edx
  800924:	74 13                	je     800939 <strncmp+0x39>
		n--, p++, q++;
  800926:	83 c1 01             	add    $0x1,%ecx
  800929:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092c:	0f b6 01             	movzbl (%ecx),%eax
  80092f:	84 c0                	test   %al,%al
  800931:	74 0e                	je     800941 <strncmp+0x41>
  800933:	3a 03                	cmp    (%ebx),%al
  800935:	74 ea                	je     800921 <strncmp+0x21>
  800937:	eb 08                	jmp    800941 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800941:	0f b6 01             	movzbl (%ecx),%eax
  800944:	0f b6 13             	movzbl (%ebx),%edx
  800947:	29 d0                	sub    %edx,%eax
  800949:	eb f3                	jmp    80093e <strncmp+0x3e>

0080094b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	0f b6 10             	movzbl (%eax),%edx
  800958:	84 d2                	test   %dl,%dl
  80095a:	74 1c                	je     800978 <strchr+0x2d>
		if (*s == c)
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	75 09                	jne    800969 <strchr+0x1e>
  800960:	eb 1b                	jmp    80097d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800962:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 14                	je     80097d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800969:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  80096d:	84 d2                	test   %dl,%dl
  80096f:	75 f1                	jne    800962 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
  800976:	eb 05                	jmp    80097d <strchr+0x32>
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800989:	0f b6 10             	movzbl (%eax),%edx
  80098c:	84 d2                	test   %dl,%dl
  80098e:	74 14                	je     8009a4 <strfind+0x25>
		if (*s == c)
  800990:	38 ca                	cmp    %cl,%dl
  800992:	75 06                	jne    80099a <strfind+0x1b>
  800994:	eb 0e                	jmp    8009a4 <strfind+0x25>
  800996:	38 ca                	cmp    %cl,%dl
  800998:	74 0a                	je     8009a4 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 f2                	jne    800996 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memset>:


void *
memset(void *v, int c, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009b3:	89 da                	mov    %ebx,%edx
  8009b5:	83 ea 01             	sub    $0x1,%edx
  8009b8:	78 0d                	js     8009c7 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  8009ba:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  8009bc:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  8009be:	88 0a                	mov    %cl,(%edx)
  8009c0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009c3:	39 da                	cmp    %ebx,%edx
  8009c5:	75 f7                	jne    8009be <memset+0x18>
		*p++ = c;

	return v;
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d9:	39 c6                	cmp    %eax,%esi
  8009db:	72 0b                	jb     8009e8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	85 db                	test   %ebx,%ebx
  8009e4:	75 29                	jne    800a0f <memmove+0x45>
  8009e6:	eb 35                	jmp    800a1d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  8009eb:	39 c8                	cmp    %ecx,%eax
  8009ed:	73 ee                	jae    8009dd <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  8009ef:	85 db                	test   %ebx,%ebx
  8009f1:	74 2a                	je     800a1d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  8009f3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  8009f6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  8009f8:	f7 db                	neg    %ebx
  8009fa:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  8009fd:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  8009ff:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800a04:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a08:	83 ea 01             	sub    $0x1,%edx
  800a0b:	75 f2                	jne    8009ff <memmove+0x35>
  800a0d:	eb 0e                	jmp    800a1d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a0f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a13:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a16:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a19:	39 d3                	cmp    %edx,%ebx
  800a1b:	75 f2                	jne    800a0f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a28:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	89 04 24             	mov    %eax,(%esp)
  800a3c:	e8 89 ff ff ff       	call   8009ca <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a57:	85 ff                	test   %edi,%edi
  800a59:	74 37                	je     800a92 <memcmp+0x4f>
		if (*s1 != *s2)
  800a5b:	0f b6 03             	movzbl (%ebx),%eax
  800a5e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800a69:	38 c8                	cmp    %cl,%al
  800a6b:	74 1c                	je     800a89 <memcmp+0x46>
  800a6d:	eb 10                	jmp    800a7f <memcmp+0x3c>
  800a6f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800a74:	83 c2 01             	add    $0x1,%edx
  800a77:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800a7b:	38 c8                	cmp    %cl,%al
  800a7d:	74 0a                	je     800a89 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800a7f:	0f b6 c0             	movzbl %al,%eax
  800a82:	0f b6 c9             	movzbl %cl,%ecx
  800a85:	29 c8                	sub    %ecx,%eax
  800a87:	eb 09                	jmp    800a92 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a89:	39 fa                	cmp    %edi,%edx
  800a8b:	75 e2                	jne    800a6f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa2:	39 d0                	cmp    %edx,%eax
  800aa4:	73 15                	jae    800abb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800aaa:	38 08                	cmp    %cl,(%eax)
  800aac:	75 06                	jne    800ab4 <memfind+0x1d>
  800aae:	eb 0b                	jmp    800abb <memfind+0x24>
  800ab0:	38 08                	cmp    %cl,(%eax)
  800ab2:	74 07                	je     800abb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab4:	83 c0 01             	add    $0x1,%eax
  800ab7:	39 d0                	cmp    %edx,%eax
  800ab9:	75 f5                	jne    800ab0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac9:	0f b6 02             	movzbl (%edx),%eax
  800acc:	3c 20                	cmp    $0x20,%al
  800ace:	74 04                	je     800ad4 <strtol+0x17>
  800ad0:	3c 09                	cmp    $0x9,%al
  800ad2:	75 0e                	jne    800ae2 <strtol+0x25>
		s++;
  800ad4:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad7:	0f b6 02             	movzbl (%edx),%eax
  800ada:	3c 20                	cmp    $0x20,%al
  800adc:	74 f6                	je     800ad4 <strtol+0x17>
  800ade:	3c 09                	cmp    $0x9,%al
  800ae0:	74 f2                	je     800ad4 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae2:	3c 2b                	cmp    $0x2b,%al
  800ae4:	75 0a                	jne    800af0 <strtol+0x33>
		s++;
  800ae6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae9:	bf 00 00 00 00       	mov    $0x0,%edi
  800aee:	eb 10                	jmp    800b00 <strtol+0x43>
  800af0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af5:	3c 2d                	cmp    $0x2d,%al
  800af7:	75 07                	jne    800b00 <strtol+0x43>
		s++, neg = 1;
  800af9:	83 c2 01             	add    $0x1,%edx
  800afc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b00:	85 db                	test   %ebx,%ebx
  800b02:	0f 94 c0             	sete   %al
  800b05:	74 05                	je     800b0c <strtol+0x4f>
  800b07:	83 fb 10             	cmp    $0x10,%ebx
  800b0a:	75 15                	jne    800b21 <strtol+0x64>
  800b0c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b0f:	75 10                	jne    800b21 <strtol+0x64>
  800b11:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b15:	75 0a                	jne    800b21 <strtol+0x64>
		s += 2, base = 16;
  800b17:	83 c2 02             	add    $0x2,%edx
  800b1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1f:	eb 13                	jmp    800b34 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800b21:	84 c0                	test   %al,%al
  800b23:	74 0f                	je     800b34 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b25:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2d:	75 05                	jne    800b34 <strtol+0x77>
		s++, base = 8;
  800b2f:	83 c2 01             	add    $0x1,%edx
  800b32:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
  800b39:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b3b:	0f b6 0a             	movzbl (%edx),%ecx
  800b3e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	77 08                	ja     800b4e <strtol+0x91>
			dig = *s - '0';
  800b46:	0f be c9             	movsbl %cl,%ecx
  800b49:	83 e9 30             	sub    $0x30,%ecx
  800b4c:	eb 1e                	jmp    800b6c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800b4e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 08                	ja     800b5e <strtol+0xa1>
			dig = *s - 'a' + 10;
  800b56:	0f be c9             	movsbl %cl,%ecx
  800b59:	83 e9 57             	sub    $0x57,%ecx
  800b5c:	eb 0e                	jmp    800b6c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800b5e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b61:	80 fb 19             	cmp    $0x19,%bl
  800b64:	77 14                	ja     800b7a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b66:	0f be c9             	movsbl %cl,%ecx
  800b69:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b6c:	39 f1                	cmp    %esi,%ecx
  800b6e:	7d 0e                	jge    800b7e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b70:	83 c2 01             	add    $0x1,%edx
  800b73:	0f af c6             	imul   %esi,%eax
  800b76:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b78:	eb c1                	jmp    800b3b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b7a:	89 c1                	mov    %eax,%ecx
  800b7c:	eb 02                	jmp    800b80 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b84:	74 05                	je     800b8b <strtol+0xce>
		*endptr = (char *) s;
  800b86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b89:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b8b:	89 ca                	mov    %ecx,%edx
  800b8d:	f7 da                	neg    %edx
  800b8f:	85 ff                	test   %edi,%edi
  800b91:	0f 45 c2             	cmovne %edx,%eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    
  800b99:	00 00                	add    %al,(%eax)
	...

00800b9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ba5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ba8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	89 c3                	mov    %eax,%ebx
  800bb8:	89 c7                	mov    %eax,%edi
  800bba:	89 c6                	mov    %eax,%esi
  800bbc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bc1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bc4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bc7:	89 ec                	mov    %ebp,%esp
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	b8 01 00 00 00       	mov    $0x1,%eax
  800be4:	89 d1                	mov    %edx,%ecx
  800be6:	89 d3                	mov    %edx,%ebx
  800be8:	89 d7                	mov    %edx,%edi
  800bea:	89 d6                	mov    %edx,%esi
  800bec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bf1:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bf4:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bf7:	89 ec                	mov    %ebp,%esp
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	83 ec 38             	sub    $0x38,%esp
  800c01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c07:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	89 cb                	mov    %ecx,%ebx
  800c19:	89 cf                	mov    %ecx,%edi
  800c1b:	89 ce                	mov    %ecx,%esi
  800c1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 28                	jle    800c4b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c27:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c2e:	00 
  800c2f:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800c36:	00 
  800c37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3e:	00 
  800c3f:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800c46:	e8 79 03 00 00       	call   800fc4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c4e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c51:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c54:	89 ec                	mov    %ebp,%esp
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800c6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c71:	89 d1                	mov    %edx,%ecx
  800c73:	89 d3                	mov    %edx,%ebx
  800c75:	89 d7                	mov    %edx,%edi
  800c77:	89 d6                	mov    %edx,%esi
  800c79:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c7b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c7e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c81:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c84:	89 ec                	mov    %ebp,%esp
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_yield>:

void
sys_yield(void)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c91:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c94:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca1:	89 d1                	mov    %edx,%ecx
  800ca3:	89 d3                	mov    %edx,%ebx
  800ca5:	89 d7                	mov    %edx,%edi
  800ca7:	89 d6                	mov    %edx,%esi
  800ca9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb4:	89 ec                	mov    %ebp,%esp
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	83 ec 38             	sub    $0x38,%esp
  800cbe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	be 00 00 00 00       	mov    $0x0,%esi
  800ccc:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 f7                	mov    %esi,%edi
  800cdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 28                	jle    800d0a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ced:	00 
  800cee:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800cf5:	00 
  800cf6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfd:	00 
  800cfe:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800d05:	e8 ba 02 00 00       	call   800fc4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d10:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d13:	89 ec                	mov    %ebp,%esp
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	83 ec 38             	sub    $0x38,%esp
  800d1d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d20:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d23:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d37:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 28                	jle    800d68 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d44:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d4b:	00 
  800d4c:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800d53:	00 
  800d54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5b:	00 
  800d5c:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800d63:	e8 5c 02 00 00       	call   800fc4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d68:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d6b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d6e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d71:	89 ec                	mov    %ebp,%esp
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 38             	sub    $0x38,%esp
  800d7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d81:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d89:	b8 06 00 00 00       	mov    $0x6,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 df                	mov    %ebx,%edi
  800d96:	89 de                	mov    %ebx,%esi
  800d98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7e 28                	jle    800dc6 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800da9:	00 
  800daa:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800db1:	00 
  800db2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db9:	00 
  800dba:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800dc1:	e8 fe 01 00 00       	call   800fc4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dcc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcf:	89 ec                	mov    %ebp,%esp
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	83 ec 38             	sub    $0x38,%esp
  800dd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ddc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ddf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de7:	b8 08 00 00 00       	mov    $0x8,%eax
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	89 df                	mov    %ebx,%edi
  800df4:	89 de                	mov    %ebx,%esi
  800df6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	7e 28                	jle    800e24 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e00:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e07:	00 
  800e08:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800e0f:	00 
  800e10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e17:	00 
  800e18:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800e1f:	e8 a0 01 00 00       	call   800fc4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e24:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e27:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e2a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2d:	89 ec                	mov    %ebp,%esp
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 38             	sub    $0x38,%esp
  800e37:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e3a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e3d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e45:	b8 09 00 00 00       	mov    $0x9,%eax
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e50:	89 df                	mov    %ebx,%edi
  800e52:	89 de                	mov    %ebx,%esi
  800e54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800e56:	85 c0                	test   %eax,%eax
  800e58:	7e 28                	jle    800e82 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e5e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e65:	00 
  800e66:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800e6d:	00 
  800e6e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e75:	00 
  800e76:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800e7d:	e8 42 01 00 00       	call   800fc4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e82:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e85:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e88:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e8b:	89 ec                	mov    %ebp,%esp
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 38             	sub    $0x38,%esp
  800e95:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e98:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	89 df                	mov    %ebx,%edi
  800eb0:	89 de                	mov    %ebx,%esi
  800eb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	7e 28                	jle    800ee0 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ec3:	00 
  800ec4:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed3:	00 
  800ed4:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800edb:	e8 e4 00 00 00       	call   800fc4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ee0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee9:	89 ec                	mov    %ebp,%esp
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	83 ec 0c             	sub    $0xc,%esp
  800ef3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efc:	be 00 00 00 00       	mov    $0x0,%esi
  800f01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f14:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f17:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f1a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1d:	89 ec                	mov    %ebp,%esp
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	83 ec 38             	sub    $0x38,%esp
  800f27:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f2a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f35:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3d:	89 cb                	mov    %ecx,%ebx
  800f3f:	89 cf                	mov    %ecx,%edi
  800f41:	89 ce                	mov    %ecx,%esi
  800f43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	7e 28                	jle    800f71 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f54:	00 
  800f55:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 81 15 80 00 	movl   $0x801581,(%esp)
  800f6c:	e8 53 00 00 00       	call   800fc4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f71:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f74:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f77:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f7a:	89 ec                	mov    %ebp,%esp
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
	...

00800f80 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f86:	c7 44 24 08 9b 15 80 	movl   $0x80159b,0x8(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800f95:	00 
  800f96:	c7 04 24 8f 15 80 00 	movl   $0x80158f,(%esp)
  800f9d:	e8 22 00 00 00       	call   800fc4 <_panic>

00800fa2 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800fa8:	c7 44 24 08 9a 15 80 	movl   $0x80159a,0x8(%esp)
  800faf:	00 
  800fb0:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800fb7:	00 
  800fb8:	c7 04 24 8f 15 80 00 	movl   $0x80158f,(%esp)
  800fbf:	e8 00 00 00 00       	call   800fc4 <_panic>

00800fc4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800fca:	a1 08 20 80 00       	mov    0x802008,%eax
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	74 10                	je     800fe3 <_panic+0x1f>
		cprintf("%s: ", argv0);
  800fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd7:	c7 04 24 b0 15 80 00 	movl   $0x8015b0,(%esp)
  800fde:	e8 20 f2 ff ff       	call   800203 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  800fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
  800fed:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff1:	a1 00 20 80 00       	mov    0x802000,%eax
  800ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffa:	c7 04 24 b5 15 80 00 	movl   $0x8015b5,(%esp)
  801001:	e8 fd f1 ff ff       	call   800203 <cprintf>
	vcprintf(fmt, ap);
  801006:	8d 45 14             	lea    0x14(%ebp),%eax
  801009:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100d:	8b 45 10             	mov    0x10(%ebp),%eax
  801010:	89 04 24             	mov    %eax,(%esp)
  801013:	e8 8a f1 ff ff       	call   8001a2 <vcprintf>
	cprintf("\n");
  801018:	c7 04 24 ef 12 80 00 	movl   $0x8012ef,(%esp)
  80101f:	e8 df f1 ff ff       	call   800203 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801024:	cc                   	int3   
  801025:	eb fd                	jmp    801024 <_panic+0x60>
	...

00801030 <__udivdi3>:
  801030:	83 ec 1c             	sub    $0x1c,%esp
  801033:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801037:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80103b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80103f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801043:	89 74 24 10          	mov    %esi,0x10(%esp)
  801047:	8b 74 24 24          	mov    0x24(%esp),%esi
  80104b:	85 ff                	test   %edi,%edi
  80104d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801051:	89 44 24 08          	mov    %eax,0x8(%esp)
  801055:	89 cd                	mov    %ecx,%ebp
  801057:	89 44 24 04          	mov    %eax,0x4(%esp)
  80105b:	75 33                	jne    801090 <__udivdi3+0x60>
  80105d:	39 f1                	cmp    %esi,%ecx
  80105f:	77 57                	ja     8010b8 <__udivdi3+0x88>
  801061:	85 c9                	test   %ecx,%ecx
  801063:	75 0b                	jne    801070 <__udivdi3+0x40>
  801065:	b8 01 00 00 00       	mov    $0x1,%eax
  80106a:	31 d2                	xor    %edx,%edx
  80106c:	f7 f1                	div    %ecx
  80106e:	89 c1                	mov    %eax,%ecx
  801070:	89 f0                	mov    %esi,%eax
  801072:	31 d2                	xor    %edx,%edx
  801074:	f7 f1                	div    %ecx
  801076:	89 c6                	mov    %eax,%esi
  801078:	8b 44 24 04          	mov    0x4(%esp),%eax
  80107c:	f7 f1                	div    %ecx
  80107e:	89 f2                	mov    %esi,%edx
  801080:	8b 74 24 10          	mov    0x10(%esp),%esi
  801084:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801088:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80108c:	83 c4 1c             	add    $0x1c,%esp
  80108f:	c3                   	ret    
  801090:	31 d2                	xor    %edx,%edx
  801092:	31 c0                	xor    %eax,%eax
  801094:	39 f7                	cmp    %esi,%edi
  801096:	77 e8                	ja     801080 <__udivdi3+0x50>
  801098:	0f bd cf             	bsr    %edi,%ecx
  80109b:	83 f1 1f             	xor    $0x1f,%ecx
  80109e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010a2:	75 2c                	jne    8010d0 <__udivdi3+0xa0>
  8010a4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  8010a8:	76 04                	jbe    8010ae <__udivdi3+0x7e>
  8010aa:	39 f7                	cmp    %esi,%edi
  8010ac:	73 d2                	jae    801080 <__udivdi3+0x50>
  8010ae:	31 d2                	xor    %edx,%edx
  8010b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b5:	eb c9                	jmp    801080 <__udivdi3+0x50>
  8010b7:	90                   	nop
  8010b8:	89 f2                	mov    %esi,%edx
  8010ba:	f7 f1                	div    %ecx
  8010bc:	31 d2                	xor    %edx,%edx
  8010be:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010c2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010c6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ca:	83 c4 1c             	add    $0x1c,%esp
  8010cd:	c3                   	ret    
  8010ce:	66 90                	xchg   %ax,%ax
  8010d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010d5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010da:	89 ea                	mov    %ebp,%edx
  8010dc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010e0:	d3 e7                	shl    %cl,%edi
  8010e2:	89 c1                	mov    %eax,%ecx
  8010e4:	d3 ea                	shr    %cl,%edx
  8010e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010eb:	09 fa                	or     %edi,%edx
  8010ed:	89 f7                	mov    %esi,%edi
  8010ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010f3:	89 f2                	mov    %esi,%edx
  8010f5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010f9:	d3 e5                	shl    %cl,%ebp
  8010fb:	89 c1                	mov    %eax,%ecx
  8010fd:	d3 ef                	shr    %cl,%edi
  8010ff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801104:	d3 e2                	shl    %cl,%edx
  801106:	89 c1                	mov    %eax,%ecx
  801108:	d3 ee                	shr    %cl,%esi
  80110a:	09 d6                	or     %edx,%esi
  80110c:	89 fa                	mov    %edi,%edx
  80110e:	89 f0                	mov    %esi,%eax
  801110:	f7 74 24 0c          	divl   0xc(%esp)
  801114:	89 d7                	mov    %edx,%edi
  801116:	89 c6                	mov    %eax,%esi
  801118:	f7 e5                	mul    %ebp
  80111a:	39 d7                	cmp    %edx,%edi
  80111c:	72 22                	jb     801140 <__udivdi3+0x110>
  80111e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801122:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801127:	d3 e5                	shl    %cl,%ebp
  801129:	39 c5                	cmp    %eax,%ebp
  80112b:	73 04                	jae    801131 <__udivdi3+0x101>
  80112d:	39 d7                	cmp    %edx,%edi
  80112f:	74 0f                	je     801140 <__udivdi3+0x110>
  801131:	89 f0                	mov    %esi,%eax
  801133:	31 d2                	xor    %edx,%edx
  801135:	e9 46 ff ff ff       	jmp    801080 <__udivdi3+0x50>
  80113a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801140:	8d 46 ff             	lea    -0x1(%esi),%eax
  801143:	31 d2                	xor    %edx,%edx
  801145:	8b 74 24 10          	mov    0x10(%esp),%esi
  801149:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80114d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801151:	83 c4 1c             	add    $0x1c,%esp
  801154:	c3                   	ret    
	...

00801160 <__umoddi3>:
  801160:	83 ec 1c             	sub    $0x1c,%esp
  801163:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801167:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80116b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80116f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801173:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801177:	8b 74 24 24          	mov    0x24(%esp),%esi
  80117b:	85 ed                	test   %ebp,%ebp
  80117d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801181:	89 44 24 08          	mov    %eax,0x8(%esp)
  801185:	89 cf                	mov    %ecx,%edi
  801187:	89 04 24             	mov    %eax,(%esp)
  80118a:	89 f2                	mov    %esi,%edx
  80118c:	75 1a                	jne    8011a8 <__umoddi3+0x48>
  80118e:	39 f1                	cmp    %esi,%ecx
  801190:	76 4e                	jbe    8011e0 <__umoddi3+0x80>
  801192:	f7 f1                	div    %ecx
  801194:	89 d0                	mov    %edx,%eax
  801196:	31 d2                	xor    %edx,%edx
  801198:	8b 74 24 10          	mov    0x10(%esp),%esi
  80119c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011a4:	83 c4 1c             	add    $0x1c,%esp
  8011a7:	c3                   	ret    
  8011a8:	39 f5                	cmp    %esi,%ebp
  8011aa:	77 54                	ja     801200 <__umoddi3+0xa0>
  8011ac:	0f bd c5             	bsr    %ebp,%eax
  8011af:	83 f0 1f             	xor    $0x1f,%eax
  8011b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b6:	75 60                	jne    801218 <__umoddi3+0xb8>
  8011b8:	3b 0c 24             	cmp    (%esp),%ecx
  8011bb:	0f 87 07 01 00 00    	ja     8012c8 <__umoddi3+0x168>
  8011c1:	89 f2                	mov    %esi,%edx
  8011c3:	8b 34 24             	mov    (%esp),%esi
  8011c6:	29 ce                	sub    %ecx,%esi
  8011c8:	19 ea                	sbb    %ebp,%edx
  8011ca:	89 34 24             	mov    %esi,(%esp)
  8011cd:	8b 04 24             	mov    (%esp),%eax
  8011d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011dc:	83 c4 1c             	add    $0x1c,%esp
  8011df:	c3                   	ret    
  8011e0:	85 c9                	test   %ecx,%ecx
  8011e2:	75 0b                	jne    8011ef <__umoddi3+0x8f>
  8011e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e9:	31 d2                	xor    %edx,%edx
  8011eb:	f7 f1                	div    %ecx
  8011ed:	89 c1                	mov    %eax,%ecx
  8011ef:	89 f0                	mov    %esi,%eax
  8011f1:	31 d2                	xor    %edx,%edx
  8011f3:	f7 f1                	div    %ecx
  8011f5:	8b 04 24             	mov    (%esp),%eax
  8011f8:	f7 f1                	div    %ecx
  8011fa:	eb 98                	jmp    801194 <__umoddi3+0x34>
  8011fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801200:	89 f2                	mov    %esi,%edx
  801202:	8b 74 24 10          	mov    0x10(%esp),%esi
  801206:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80120a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80120e:	83 c4 1c             	add    $0x1c,%esp
  801211:	c3                   	ret    
  801212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801218:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80121d:	89 e8                	mov    %ebp,%eax
  80121f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801224:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801228:	89 fa                	mov    %edi,%edx
  80122a:	d3 e0                	shl    %cl,%eax
  80122c:	89 e9                	mov    %ebp,%ecx
  80122e:	d3 ea                	shr    %cl,%edx
  801230:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801235:	09 c2                	or     %eax,%edx
  801237:	8b 44 24 08          	mov    0x8(%esp),%eax
  80123b:	89 14 24             	mov    %edx,(%esp)
  80123e:	89 f2                	mov    %esi,%edx
  801240:	d3 e7                	shl    %cl,%edi
  801242:	89 e9                	mov    %ebp,%ecx
  801244:	d3 ea                	shr    %cl,%edx
  801246:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80124b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80124f:	d3 e6                	shl    %cl,%esi
  801251:	89 e9                	mov    %ebp,%ecx
  801253:	d3 e8                	shr    %cl,%eax
  801255:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80125a:	09 f0                	or     %esi,%eax
  80125c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801260:	f7 34 24             	divl   (%esp)
  801263:	d3 e6                	shl    %cl,%esi
  801265:	89 74 24 08          	mov    %esi,0x8(%esp)
  801269:	89 d6                	mov    %edx,%esi
  80126b:	f7 e7                	mul    %edi
  80126d:	39 d6                	cmp    %edx,%esi
  80126f:	89 c1                	mov    %eax,%ecx
  801271:	89 d7                	mov    %edx,%edi
  801273:	72 3f                	jb     8012b4 <__umoddi3+0x154>
  801275:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801279:	72 35                	jb     8012b0 <__umoddi3+0x150>
  80127b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80127f:	29 c8                	sub    %ecx,%eax
  801281:	19 fe                	sbb    %edi,%esi
  801283:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801288:	89 f2                	mov    %esi,%edx
  80128a:	d3 e8                	shr    %cl,%eax
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	d3 e2                	shl    %cl,%edx
  801290:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801295:	09 d0                	or     %edx,%eax
  801297:	89 f2                	mov    %esi,%edx
  801299:	d3 ea                	shr    %cl,%edx
  80129b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80129f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8012a3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8012a7:	83 c4 1c             	add    $0x1c,%esp
  8012aa:	c3                   	ret    
  8012ab:	90                   	nop
  8012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	39 d6                	cmp    %edx,%esi
  8012b2:	75 c7                	jne    80127b <__umoddi3+0x11b>
  8012b4:	89 d7                	mov    %edx,%edi
  8012b6:	89 c1                	mov    %eax,%ecx
  8012b8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8012bc:	1b 3c 24             	sbb    (%esp),%edi
  8012bf:	eb ba                	jmp    80127b <__umoddi3+0x11b>
  8012c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	39 f5                	cmp    %esi,%ebp
  8012ca:	0f 82 f1 fe ff ff    	jb     8011c1 <__umoddi3+0x61>
  8012d0:	e9 f8 fe ff ff       	jmp    8011cd <__umoddi3+0x6d>
