
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 f0 10 00 	lgdtl  0x10f018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

        # Set the stack pointer
	movl	$(bootstacktop),%esp
f0100033:	bc 00 f0 10 f0       	mov    $0xf010f000,%esp

	# now to C code
	call	i386_init
f0100038:	e8 fd 00 00 00       	call   f010013a <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
f010003f:	90                   	nop

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f0100046:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100049:	89 44 24 08          	mov    %eax,0x8(%esp)
f010004d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100050:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100054:	c7 04 24 c0 16 10 f0 	movl   $0xf01016c0,(%esp)
f010005b:	e8 e8 08 00 00       	call   f0100948 <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 a3 08 00 00       	call   f0100915 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 6b 17 10 f0 	movl   $0xf010176b,(%esp)
f0100079:	e8 ca 08 00 00       	call   f0100948 <cprintf>
	va_end(ap);
}
f010007e:	c9                   	leave  
f010007f:	c3                   	ret    

f0100080 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100080:	55                   	push   %ebp
f0100081:	89 e5                	mov    %esp,%ebp
f0100083:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f0100086:	83 3d 20 f3 10 f0 00 	cmpl   $0x0,0xf010f320
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 20 f3 10 f0       	mov    %eax,0xf010f320

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 da 16 10 f0 	movl   $0xf01016da,(%esp)
f01000ac:	e8 97 08 00 00       	call   f0100948 <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 52 08 00 00       	call   f0100915 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 6b 17 10 f0 	movl   $0xf010176b,(%esp)
f01000ca:	e8 79 08 00 00       	call   f0100948 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 f1 06 00 00       	call   f01007cc <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	53                   	push   %ebx
f01000e1:	83 ec 14             	sub    $0x14,%esp
f01000e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000eb:	c7 04 24 f2 16 10 f0 	movl   $0xf01016f2,(%esp)
f01000f2:	e8 51 08 00 00       	call   f0100948 <cprintf>
	if (x > 0)
f01000f7:	85 db                	test   %ebx,%ebx
f01000f9:	7e 0d                	jle    f0100108 <test_backtrace+0x2b>
		test_backtrace(x-1);
f01000fb:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01000fe:	89 04 24             	mov    %eax,(%esp)
f0100101:	e8 d7 ff ff ff       	call   f01000dd <test_backtrace>
f0100106:	eb 1c                	jmp    f0100124 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f0100108:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010010f:	00 
f0100110:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100117:	00 
f0100118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010011f:	e8 9c 05 00 00       	call   f01006c0 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100128:	c7 04 24 0e 17 10 f0 	movl   $0xf010170e,(%esp)
f010012f:	e8 14 08 00 00       	call   f0100948 <cprintf>
}
f0100134:	83 c4 14             	add    $0x14,%esp
f0100137:	5b                   	pop    %ebx
f0100138:	5d                   	pop    %ebp
f0100139:	c3                   	ret    

f010013a <i386_init>:

void
i386_init(void)
{
f010013a:	55                   	push   %ebp
f010013b:	89 e5                	mov    %esp,%ebp
f010013d:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100140:	b8 80 f9 10 f0       	mov    $0xf010f980,%eax
f0100145:	2d 20 f3 10 f0       	sub    $0xf010f320,%eax
f010014a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010014e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100155:	00 
f0100156:	c7 04 24 20 f3 10 f0 	movl   $0xf010f320,(%esp)
f010015d:	e8 d4 10 00 00       	call   f0101236 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100162:	e8 24 02 00 00       	call   f010038b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100167:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010016e:	00 
f010016f:	c7 04 24 29 17 10 f0 	movl   $0xf0101729,(%esp)
f0100176:	e8 cd 07 00 00       	call   f0100948 <cprintf>




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010017b:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100182:	e8 56 ff ff ff       	call   f01000dd <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100187:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010018e:	e8 39 06 00 00       	call   f01007cc <monitor>
f0100193:	eb f2                	jmp    f0100187 <i386_init+0x4d>
f0100195:	66 90                	xchg   %ax,%ax
f0100197:	66 90                	xchg   %ax,%ax
f0100199:	66 90                	xchg   %ax,%ax
f010019b:	66 90                	xchg   %ax,%ax
f010019d:	66 90                	xchg   %ax,%ax
f010019f:	90                   	nop

f01001a0 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001b0:	f6 c2 01             	test   $0x1,%dl
f01001b3:	74 09                	je     f01001be <serial_proc_data+0x1e>
f01001b5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001ba:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001bb:	0f b6 c0             	movzbl %al,%eax
}
f01001be:	5d                   	pop    %ebp
f01001bf:	c3                   	ret    

f01001c0 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp
f01001c3:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001c4:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01001c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ce:	89 da                	mov    %ebx,%edx
f01001d0:	ee                   	out    %al,(%dx)
f01001d1:	b2 fb                	mov    $0xfb,%dl
f01001d3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01001d8:	ee                   	out    %al,(%dx)
f01001d9:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01001de:	b8 0c 00 00 00       	mov    $0xc,%eax
f01001e3:	89 ca                	mov    %ecx,%edx
f01001e5:	ee                   	out    %al,(%dx)
f01001e6:	b2 f9                	mov    $0xf9,%dl
f01001e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ed:	ee                   	out    %al,(%dx)
f01001ee:	b2 fb                	mov    $0xfb,%dl
f01001f0:	b8 03 00 00 00       	mov    $0x3,%eax
f01001f5:	ee                   	out    %al,(%dx)
f01001f6:	b2 fc                	mov    $0xfc,%dl
f01001f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001fd:	ee                   	out    %al,(%dx)
f01001fe:	b2 f9                	mov    $0xf9,%dl
f0100200:	b8 01 00 00 00       	mov    $0x1,%eax
f0100205:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100206:	b2 fd                	mov    $0xfd,%dl
f0100208:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100209:	3c ff                	cmp    $0xff,%al
f010020b:	0f 95 c0             	setne  %al
f010020e:	0f b6 c0             	movzbl %al,%eax
f0100211:	a3 44 f3 10 f0       	mov    %eax,0xf010f344
f0100216:	89 da                	mov    %ebx,%edx
f0100218:	ec                   	in     (%dx),%al
f0100219:	89 ca                	mov    %ecx,%edx
f010021b:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010021c:	5b                   	pop    %ebx
f010021d:	5d                   	pop    %ebp
f010021e:	c3                   	ret    

f010021f <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010021f:	55                   	push   %ebp
f0100220:	89 e5                	mov    %esp,%ebp
f0100222:	83 ec 0c             	sub    $0xc,%esp
f0100225:	89 1c 24             	mov    %ebx,(%esp)
f0100228:	89 74 24 04          	mov    %esi,0x4(%esp)
f010022c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100230:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100235:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100238:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010023d:	0f b7 00             	movzwl (%eax),%eax
f0100240:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100244:	74 11                	je     f0100257 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100246:	c7 05 48 f3 10 f0 b4 	movl   $0x3b4,0xf010f348
f010024d:	03 00 00 
f0100250:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100255:	eb 16                	jmp    f010026d <cga_init+0x4e>
	} else {
		*cp = was;
f0100257:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010025e:	c7 05 48 f3 10 f0 d4 	movl   $0x3d4,0xf010f348
f0100265:	03 00 00 
f0100268:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010026d:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f0100273:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100275:	b8 0e 00 00 00       	mov    $0xe,%eax
f010027a:	89 ca                	mov    %ecx,%edx
f010027c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010027d:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100280:	89 ca                	mov    %ecx,%edx
f0100282:	ec                   	in     (%dx),%al
f0100283:	0f b6 f8             	movzbl %al,%edi
f0100286:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100289:	b8 0f 00 00 00       	mov    $0xf,%eax
f010028e:	89 da                	mov    %ebx,%edx
f0100290:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100291:	89 ca                	mov    %ecx,%edx
f0100293:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100294:	89 35 4c f3 10 f0    	mov    %esi,0xf010f34c
	crt_pos = pos;
f010029a:	0f b6 c8             	movzbl %al,%ecx
f010029d:	09 cf                	or     %ecx,%edi
f010029f:	66 89 3d 50 f3 10 f0 	mov    %di,0xf010f350
}
f01002a6:	8b 1c 24             	mov    (%esp),%ebx
f01002a9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01002ad:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01002b1:	89 ec                	mov    %ebp,%esp
f01002b3:	5d                   	pop    %ebp
f01002b4:	c3                   	ret    

f01002b5 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f01002b5:	55                   	push   %ebp
f01002b6:	89 e5                	mov    %esp,%ebp
}
f01002b8:	5d                   	pop    %ebp
f01002b9:	c3                   	ret    

f01002ba <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01002ba:	55                   	push   %ebp
f01002bb:	89 e5                	mov    %esp,%ebp
f01002bd:	57                   	push   %edi
f01002be:	56                   	push   %esi
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002c6:	bb 64 f5 10 f0       	mov    $0xf010f564,%ebx
f01002cb:	bf 60 f3 10 f0       	mov    $0xf010f360,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002d0:	eb 1b                	jmp    f01002ed <cons_intr+0x33>
		if (c == 0)
f01002d2:	85 c0                	test   %eax,%eax
f01002d4:	74 17                	je     f01002ed <cons_intr+0x33>
			continue;
		cons.buf[cons.wpos++] = c;
f01002d6:	8b 13                	mov    (%ebx),%edx
f01002d8:	88 04 3a             	mov    %al,(%edx,%edi,1)
f01002db:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002de:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01002e8:	0f 44 c2             	cmove  %edx,%eax
f01002eb:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002ed:	ff d6                	call   *%esi
f01002ef:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002f2:	75 de                	jne    f01002d2 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002f4:	83 c4 0c             	add    $0xc,%esp
f01002f7:	5b                   	pop    %ebx
f01002f8:	5e                   	pop    %esi
f01002f9:	5f                   	pop    %edi
f01002fa:	5d                   	pop    %ebp
f01002fb:	c3                   	ret    

f01002fc <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01002fc:	55                   	push   %ebp
f01002fd:	89 e5                	mov    %esp,%ebp
f01002ff:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100302:	c7 04 24 b2 03 10 f0 	movl   $0xf01003b2,(%esp)
f0100309:	e8 ac ff ff ff       	call   f01002ba <cons_intr>
}
f010030e:	c9                   	leave  
f010030f:	c3                   	ret    

f0100310 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100310:	55                   	push   %ebp
f0100311:	89 e5                	mov    %esp,%ebp
f0100313:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100316:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f010031d:	74 0c                	je     f010032b <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f010031f:	c7 04 24 a0 01 10 f0 	movl   $0xf01001a0,(%esp)
f0100326:	e8 8f ff ff ff       	call   f01002ba <cons_intr>
}
f010032b:	c9                   	leave  
f010032c:	c3                   	ret    

f010032d <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010032d:	55                   	push   %ebp
f010032e:	89 e5                	mov    %esp,%ebp
f0100330:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100333:	e8 d8 ff ff ff       	call   f0100310 <serial_intr>
	kbd_intr();
f0100338:	e8 bf ff ff ff       	call   f01002fc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010033d:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
f0100343:	b8 00 00 00 00       	mov    $0x0,%eax
f0100348:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f010034e:	74 1e                	je     f010036e <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100350:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f0100357:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010035a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100360:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100365:	0f 44 d1             	cmove  %ecx,%edx
f0100368:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f010036e:	c9                   	leave  
f010036f:	c3                   	ret    

f0100370 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100370:	55                   	push   %ebp
f0100371:	89 e5                	mov    %esp,%ebp
f0100373:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100376:	e8 b2 ff ff ff       	call   f010032d <cons_getc>
f010037b:	85 c0                	test   %eax,%eax
f010037d:	74 f7                	je     f0100376 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010037f:	c9                   	leave  
f0100380:	c3                   	ret    

f0100381 <iscons>:

int
iscons(int fdnum)
{
f0100381:	55                   	push   %ebp
f0100382:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100384:	b8 01 00 00 00       	mov    $0x1,%eax
f0100389:	5d                   	pop    %ebp
f010038a:	c3                   	ret    

f010038b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010038b:	55                   	push   %ebp
f010038c:	89 e5                	mov    %esp,%ebp
f010038e:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100391:	e8 89 fe ff ff       	call   f010021f <cga_init>
	kbd_init();
	serial_init();
f0100396:	e8 25 fe ff ff       	call   f01001c0 <serial_init>

	if (!serial_exists)
f010039b:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f01003a2:	75 0c                	jne    f01003b0 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01003a4:	c7 04 24 44 17 10 f0 	movl   $0xf0101744,(%esp)
f01003ab:	e8 98 05 00 00       	call   f0100948 <cprintf>
}
f01003b0:	c9                   	leave  
f01003b1:	c3                   	ret    

f01003b2 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003b2:	55                   	push   %ebp
f01003b3:	89 e5                	mov    %esp,%ebp
f01003b5:	53                   	push   %ebx
f01003b6:	83 ec 14             	sub    $0x14,%esp
f01003b9:	ba 64 00 00 00       	mov    $0x64,%edx
f01003be:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003bf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003c4:	a8 01                	test   $0x1,%al
f01003c6:	0f 84 dd 00 00 00    	je     f01004a9 <kbd_proc_data+0xf7>
f01003cc:	b2 60                	mov    $0x60,%dl
f01003ce:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003cf:	3c e0                	cmp    $0xe0,%al
f01003d1:	75 11                	jne    f01003e4 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01003d3:	83 0d 40 f3 10 f0 40 	orl    $0x40,0xf010f340
f01003da:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01003df:	e9 c5 00 00 00       	jmp    f01004a9 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f01003e4:	84 c0                	test   %al,%al
f01003e6:	79 35                	jns    f010041d <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003e8:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f01003ee:	89 c1                	mov    %eax,%ecx
f01003f0:	83 e1 7f             	and    $0x7f,%ecx
f01003f3:	f6 c2 40             	test   $0x40,%dl
f01003f6:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01003f9:	0f b6 c0             	movzbl %al,%eax
f01003fc:	0f b6 80 80 17 10 f0 	movzbl -0xfefe880(%eax),%eax
f0100403:	83 c8 40             	or     $0x40,%eax
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	f7 d0                	not    %eax
f010040b:	21 c2                	and    %eax,%edx
f010040d:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
f0100413:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100418:	e9 8c 00 00 00       	jmp    f01004a9 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f010041d:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100423:	f6 c2 40             	test   $0x40,%dl
f0100426:	74 0c                	je     f0100434 <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100428:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010042b:	83 e2 bf             	and    $0xffffffbf,%edx
f010042e:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
	}

	shift |= shiftcode[data];
f0100434:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f0100437:	0f b6 90 80 17 10 f0 	movzbl -0xfefe880(%eax),%edx
f010043e:	0b 15 40 f3 10 f0    	or     0xf010f340,%edx
f0100444:	0f b6 88 80 18 10 f0 	movzbl -0xfefe780(%eax),%ecx
f010044b:	31 ca                	xor    %ecx,%edx
f010044d:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340

	c = charcode[shift & (CTL | SHIFT)][data];
f0100453:	89 d1                	mov    %edx,%ecx
f0100455:	83 e1 03             	and    $0x3,%ecx
f0100458:	8b 0c 8d 80 19 10 f0 	mov    -0xfefe680(,%ecx,4),%ecx
f010045f:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100463:	f6 c2 08             	test   $0x8,%dl
f0100466:	74 1b                	je     f0100483 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100468:	89 d9                	mov    %ebx,%ecx
f010046a:	8d 43 9f             	lea    -0x61(%ebx),%eax
f010046d:	83 f8 19             	cmp    $0x19,%eax
f0100470:	77 05                	ja     f0100477 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100472:	83 eb 20             	sub    $0x20,%ebx
f0100475:	eb 0c                	jmp    f0100483 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100477:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f010047a:	8d 43 20             	lea    0x20(%ebx),%eax
f010047d:	83 f9 19             	cmp    $0x19,%ecx
f0100480:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100483:	f7 d2                	not    %edx
f0100485:	f6 c2 06             	test   $0x6,%dl
f0100488:	75 1f                	jne    f01004a9 <kbd_proc_data+0xf7>
f010048a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100490:	75 17                	jne    f01004a9 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f0100492:	c7 04 24 61 17 10 f0 	movl   $0xf0101761,(%esp)
f0100499:	e8 aa 04 00 00       	call   f0100948 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010049e:	ba 92 00 00 00       	mov    $0x92,%edx
f01004a3:	b8 03 00 00 00       	mov    $0x3,%eax
f01004a8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004a9:	89 d8                	mov    %ebx,%eax
f01004ab:	83 c4 14             	add    $0x14,%esp
f01004ae:	5b                   	pop    %ebx
f01004af:	5d                   	pop    %ebp
f01004b0:	c3                   	ret    

f01004b1 <cga_putc>:



void
cga_putc(int c)
{
f01004b1:	55                   	push   %ebp
f01004b2:	89 e5                	mov    %esp,%ebp
f01004b4:	56                   	push   %esi
f01004b5:	53                   	push   %ebx
f01004b6:	83 ec 10             	sub    $0x10,%esp
f01004b9:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f01004bc:	89 c2                	mov    %eax,%edx
f01004be:	80 ce 07             	or     $0x7,%dh
f01004c1:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01004c6:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f01004c9:	0f b6 d0             	movzbl %al,%edx
f01004cc:	83 fa 09             	cmp    $0x9,%edx
f01004cf:	0f 84 88 00 00 00    	je     f010055d <cga_putc+0xac>
f01004d5:	83 fa 09             	cmp    $0x9,%edx
f01004d8:	7f 10                	jg     f01004ea <cga_putc+0x39>
f01004da:	83 fa 08             	cmp    $0x8,%edx
f01004dd:	0f 85 b8 00 00 00    	jne    f010059b <cga_putc+0xea>
f01004e3:	90                   	nop
f01004e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004e8:	eb 18                	jmp    f0100502 <cga_putc+0x51>
f01004ea:	83 fa 0a             	cmp    $0xa,%edx
f01004ed:	8d 76 00             	lea    0x0(%esi),%esi
f01004f0:	74 41                	je     f0100533 <cga_putc+0x82>
f01004f2:	83 fa 0d             	cmp    $0xd,%edx
f01004f5:	8d 76 00             	lea    0x0(%esi),%esi
f01004f8:	0f 85 9d 00 00 00    	jne    f010059b <cga_putc+0xea>
f01004fe:	66 90                	xchg   %ax,%ax
f0100500:	eb 39                	jmp    f010053b <cga_putc+0x8a>
	case '\b':
		if (crt_pos > 0) {
f0100502:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f0100509:	66 85 d2             	test   %dx,%dx
f010050c:	0f 84 f4 00 00 00    	je     f0100606 <cga_putc+0x155>
			crt_pos--;
f0100512:	83 ea 01             	sub    $0x1,%edx
f0100515:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010051c:	0f b7 d2             	movzwl %dx,%edx
f010051f:	b0 00                	mov    $0x0,%al
f0100521:	83 c8 20             	or     $0x20,%eax
f0100524:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f010052a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010052e:	e9 86 00 00 00       	jmp    f01005b9 <cga_putc+0x108>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100533:	66 83 05 50 f3 10 f0 	addw   $0x50,0xf010f350
f010053a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010053b:	0f b7 05 50 f3 10 f0 	movzwl 0xf010f350,%eax
f0100542:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100548:	c1 e8 10             	shr    $0x10,%eax
f010054b:	66 c1 e8 06          	shr    $0x6,%ax
f010054f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100552:	c1 e0 04             	shl    $0x4,%eax
f0100555:	66 a3 50 f3 10 f0    	mov    %ax,0xf010f350
		break;
f010055b:	eb 5c                	jmp    f01005b9 <cga_putc+0x108>
	case '\t':
		cons_putc(' ');
f010055d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100564:	e8 d4 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100569:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100570:	e8 c8 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100575:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010057c:	e8 bc 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f0100581:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100588:	e8 b0 00 00 00       	call   f010063d <cons_putc>
		cons_putc(' ');
f010058d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100594:	e8 a4 00 00 00       	call   f010063d <cons_putc>
		break;
f0100599:	eb 1e                	jmp    f01005b9 <cga_putc+0x108>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010059b:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f01005a2:	0f b7 da             	movzwl %dx,%ebx
f01005a5:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f01005ab:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005af:	83 c2 01             	add    $0x1,%edx
f01005b2:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005b9:	66 81 3d 50 f3 10 f0 	cmpw   $0x7cf,0xf010f350
f01005c0:	cf 07 
f01005c2:	76 42                	jbe    f0100606 <cga_putc+0x155>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005c4:	a1 4c f3 10 f0       	mov    0xf010f34c,%eax
f01005c9:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005d0:	00 
f01005d1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005d7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005db:	89 04 24             	mov    %eax,(%esp)
f01005de:	e8 77 0c 00 00       	call   f010125a <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005e3:	8b 15 4c f3 10 f0    	mov    0xf010f34c,%edx
f01005e9:	b8 80 07 00 00       	mov    $0x780,%eax
f01005ee:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005f4:	83 c0 01             	add    $0x1,%eax
f01005f7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005fc:	75 f0                	jne    f01005ee <cga_putc+0x13d>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005fe:	66 83 2d 50 f3 10 f0 	subw   $0x50,0xf010f350
f0100605:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100606:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010060c:	89 cb                	mov    %ecx,%ebx
f010060e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100616:	0f b7 35 50 f3 10 f0 	movzwl 0xf010f350,%esi
f010061d:	83 c1 01             	add    $0x1,%ecx
f0100620:	89 f0                	mov    %esi,%eax
f0100622:	66 c1 e8 08          	shr    $0x8,%ax
f0100626:	89 ca                	mov    %ecx,%edx
f0100628:	ee                   	out    %al,(%dx)
f0100629:	b8 0f 00 00 00       	mov    $0xf,%eax
f010062e:	89 da                	mov    %ebx,%edx
f0100630:	ee                   	out    %al,(%dx)
f0100631:	89 f0                	mov    %esi,%eax
f0100633:	89 ca                	mov    %ecx,%edx
f0100635:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100636:	83 c4 10             	add    $0x10,%esp
f0100639:	5b                   	pop    %ebx
f010063a:	5e                   	pop    %esi
f010063b:	5d                   	pop    %ebp
f010063c:	c3                   	ret    

f010063d <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f010063d:	55                   	push   %ebp
f010063e:	89 e5                	mov    %esp,%ebp
f0100640:	57                   	push   %edi
f0100641:	56                   	push   %esi
f0100642:	53                   	push   %ebx
f0100643:	83 ec 1c             	sub    $0x1c,%esp
f0100646:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100649:	ba 79 03 00 00       	mov    $0x379,%edx
f010064e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010064f:	84 c0                	test   %al,%al
f0100651:	78 27                	js     f010067a <cons_putc+0x3d>
f0100653:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100658:	b9 84 00 00 00       	mov    $0x84,%ecx
f010065d:	be 79 03 00 00       	mov    $0x379,%esi
f0100662:	89 ca                	mov    %ecx,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	ec                   	in     (%dx),%al
f0100666:	ec                   	in     (%dx),%al
f0100667:	ec                   	in     (%dx),%al
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	84 c0                	test   %al,%al
f010066d:	78 0b                	js     f010067a <cons_putc+0x3d>
f010066f:	83 c3 01             	add    $0x1,%ebx
f0100672:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100678:	75 e8                	jne    f0100662 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010067a:	ba 78 03 00 00       	mov    $0x378,%edx
f010067f:	89 f8                	mov    %edi,%eax
f0100681:	ee                   	out    %al,(%dx)
f0100682:	b2 7a                	mov    $0x7a,%dl
f0100684:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100689:	ee                   	out    %al,(%dx)
f010068a:	b8 08 00 00 00       	mov    $0x8,%eax
f010068f:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f0100690:	89 3c 24             	mov    %edi,(%esp)
f0100693:	e8 19 fe ff ff       	call   f01004b1 <cga_putc>
}
f0100698:	83 c4 1c             	add    $0x1c,%esp
f010069b:	5b                   	pop    %ebx
f010069c:	5e                   	pop    %esi
f010069d:	5f                   	pop    %edi
f010069e:	5d                   	pop    %ebp
f010069f:	c3                   	ret    

f01006a0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006a0:	55                   	push   %ebp
f01006a1:	89 e5                	mov    %esp,%ebp
f01006a3:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a9:	89 04 24             	mov    %eax,(%esp)
f01006ac:	e8 8c ff ff ff       	call   f010063d <cons_putc>
}
f01006b1:	c9                   	leave  
f01006b2:	c3                   	ret    
f01006b3:	66 90                	xchg   %ax,%ax
f01006b5:	66 90                	xchg   %ax,%ax
f01006b7:	66 90                	xchg   %ax,%ax
f01006b9:	66 90                	xchg   %ax,%ax
f01006bb:	66 90                	xchg   %ax,%ax
f01006bd:	66 90                	xchg   %ax,%ax
f01006bf:	90                   	nop

f01006c0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01006c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c8:	5d                   	pop    %ebp
f01006c9:	c3                   	ret    

f01006ca <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006ca:	55                   	push   %ebp
f01006cb:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006cd:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006d0:	5d                   	pop    %ebp
f01006d1:	c3                   	ret    

f01006d2 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006d2:	55                   	push   %ebp
f01006d3:	89 e5                	mov    %esp,%ebp
f01006d5:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006d8:	c7 04 24 90 19 10 f0 	movl   $0xf0101990,(%esp)
f01006df:	e8 64 02 00 00       	call   f0100948 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01006e4:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006eb:	00 
f01006ec:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006f3:	f0 
f01006f4:	c7 04 24 1c 1a 10 f0 	movl   $0xf0101a1c,(%esp)
f01006fb:	e8 48 02 00 00       	call   f0100948 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100700:	c7 44 24 08 a5 16 10 	movl   $0x1016a5,0x8(%esp)
f0100707:	00 
f0100708:	c7 44 24 04 a5 16 10 	movl   $0xf01016a5,0x4(%esp)
f010070f:	f0 
f0100710:	c7 04 24 40 1a 10 f0 	movl   $0xf0101a40,(%esp)
f0100717:	e8 2c 02 00 00       	call   f0100948 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010071c:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f0100723:	00 
f0100724:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f010072b:	f0 
f010072c:	c7 04 24 64 1a 10 f0 	movl   $0xf0101a64,(%esp)
f0100733:	e8 10 02 00 00       	call   f0100948 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100738:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f010073f:	00 
f0100740:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f0100747:	f0 
f0100748:	c7 04 24 88 1a 10 f0 	movl   $0xf0101a88,(%esp)
f010074f:	e8 f4 01 00 00       	call   f0100948 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100754:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f0100759:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010075e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100764:	85 c0                	test   %eax,%eax
f0100766:	0f 48 c2             	cmovs  %edx,%eax
f0100769:	c1 f8 0a             	sar    $0xa,%eax
f010076c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100770:	c7 04 24 ac 1a 10 f0 	movl   $0xf0101aac,(%esp)
f0100777:	e8 cc 01 00 00       	call   f0100948 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010077c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100781:	c9                   	leave  
f0100782:	c3                   	ret    

f0100783 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100783:	55                   	push   %ebp
f0100784:	89 e5                	mov    %esp,%ebp
f0100786:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100789:	a1 50 1b 10 f0       	mov    0xf0101b50,%eax
f010078e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100792:	a1 4c 1b 10 f0       	mov    0xf0101b4c,%eax
f0100797:	89 44 24 04          	mov    %eax,0x4(%esp)
f010079b:	c7 04 24 a9 19 10 f0 	movl   $0xf01019a9,(%esp)
f01007a2:	e8 a1 01 00 00       	call   f0100948 <cprintf>
f01007a7:	a1 5c 1b 10 f0       	mov    0xf0101b5c,%eax
f01007ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007b0:	a1 58 1b 10 f0       	mov    0xf0101b58,%eax
f01007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007b9:	c7 04 24 a9 19 10 f0 	movl   $0xf01019a9,(%esp)
f01007c0:	e8 83 01 00 00       	call   f0100948 <cprintf>
	return 0;
}
f01007c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ca:	c9                   	leave  
f01007cb:	c3                   	ret    

f01007cc <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007cc:	55                   	push   %ebp
f01007cd:	89 e5                	mov    %esp,%ebp
f01007cf:	57                   	push   %edi
f01007d0:	56                   	push   %esi
f01007d1:	53                   	push   %ebx
f01007d2:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007d5:	c7 04 24 d8 1a 10 f0 	movl   $0xf0101ad8,(%esp)
f01007dc:	e8 67 01 00 00       	call   f0100948 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007e1:	c7 04 24 fc 1a 10 f0 	movl   $0xf0101afc,(%esp)
f01007e8:	e8 5b 01 00 00       	call   f0100948 <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01007ed:	bf 4c 1b 10 f0       	mov    $0xf0101b4c,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f01007f2:	c7 04 24 b2 19 10 f0 	movl   $0xf01019b2,(%esp)
f01007f9:	e8 c2 07 00 00       	call   f0100fc0 <readline>
f01007fe:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100800:	85 c0                	test   %eax,%eax
f0100802:	74 ee                	je     f01007f2 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100804:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010080b:	be 00 00 00 00       	mov    $0x0,%esi
f0100810:	eb 06                	jmp    f0100818 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100812:	c6 03 00             	movb   $0x0,(%ebx)
f0100815:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100818:	0f b6 03             	movzbl (%ebx),%eax
f010081b:	84 c0                	test   %al,%al
f010081d:	74 6c                	je     f010088b <monitor+0xbf>
f010081f:	0f be c0             	movsbl %al,%eax
f0100822:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100826:	c7 04 24 b6 19 10 f0 	movl   $0xf01019b6,(%esp)
f010082d:	e8 ac 09 00 00       	call   f01011de <strchr>
f0100832:	85 c0                	test   %eax,%eax
f0100834:	75 dc                	jne    f0100812 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100836:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100839:	74 50                	je     f010088b <monitor+0xbf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010083b:	83 fe 0f             	cmp    $0xf,%esi
f010083e:	66 90                	xchg   %ax,%ax
f0100840:	75 16                	jne    f0100858 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100842:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100849:	00 
f010084a:	c7 04 24 bb 19 10 f0 	movl   $0xf01019bb,(%esp)
f0100851:	e8 f2 00 00 00       	call   f0100948 <cprintf>
f0100856:	eb 9a                	jmp    f01007f2 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f0100858:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010085c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010085f:	0f b6 03             	movzbl (%ebx),%eax
f0100862:	84 c0                	test   %al,%al
f0100864:	75 0c                	jne    f0100872 <monitor+0xa6>
f0100866:	eb b0                	jmp    f0100818 <monitor+0x4c>
			buf++;
f0100868:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010086b:	0f b6 03             	movzbl (%ebx),%eax
f010086e:	84 c0                	test   %al,%al
f0100870:	74 a6                	je     f0100818 <monitor+0x4c>
f0100872:	0f be c0             	movsbl %al,%eax
f0100875:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100879:	c7 04 24 b6 19 10 f0 	movl   $0xf01019b6,(%esp)
f0100880:	e8 59 09 00 00       	call   f01011de <strchr>
f0100885:	85 c0                	test   %eax,%eax
f0100887:	74 df                	je     f0100868 <monitor+0x9c>
f0100889:	eb 8d                	jmp    f0100818 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f010088b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100892:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100893:	85 f6                	test   %esi,%esi
f0100895:	0f 84 57 ff ff ff    	je     f01007f2 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010089b:	8b 07                	mov    (%edi),%eax
f010089d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008a4:	89 04 24             	mov    %eax,(%esp)
f01008a7:	e8 bd 08 00 00       	call   f0101169 <strcmp>
f01008ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01008b1:	85 c0                	test   %eax,%eax
f01008b3:	74 1d                	je     f01008d2 <monitor+0x106>
f01008b5:	a1 58 1b 10 f0       	mov    0xf0101b58,%eax
f01008ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008be:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c1:	89 04 24             	mov    %eax,(%esp)
f01008c4:	e8 a0 08 00 00       	call   f0101169 <strcmp>
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	75 28                	jne    f01008f5 <monitor+0x129>
f01008cd:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01008d2:	6b d2 0c             	imul   $0xc,%edx,%edx
f01008d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01008d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008dc:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e3:	89 34 24             	mov    %esi,(%esp)
f01008e6:	ff 92 54 1b 10 f0    	call   *-0xfefe4ac(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008ec:	85 c0                	test   %eax,%eax
f01008ee:	78 1d                	js     f010090d <monitor+0x141>
f01008f0:	e9 fd fe ff ff       	jmp    f01007f2 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008f5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008fc:	c7 04 24 d8 19 10 f0 	movl   $0xf01019d8,(%esp)
f0100903:	e8 40 00 00 00       	call   f0100948 <cprintf>
f0100908:	e9 e5 fe ff ff       	jmp    f01007f2 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010090d:	83 c4 5c             	add    $0x5c,%esp
f0100910:	5b                   	pop    %ebx
f0100911:	5e                   	pop    %esi
f0100912:	5f                   	pop    %edi
f0100913:	5d                   	pop    %ebp
f0100914:	c3                   	ret    

f0100915 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100915:	55                   	push   %ebp
f0100916:	89 e5                	mov    %esp,%ebp
f0100918:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010091b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100922:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100925:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100929:	8b 45 08             	mov    0x8(%ebp),%eax
f010092c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100930:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100933:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100937:	c7 04 24 62 09 10 f0 	movl   $0xf0100962,(%esp)
f010093e:	e8 8d 01 00 00       	call   f0100ad0 <vprintfmt>
	return cnt;
}
f0100943:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100946:	c9                   	leave  
f0100947:	c3                   	ret    

f0100948 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100948:	55                   	push   %ebp
f0100949:	89 e5                	mov    %esp,%ebp
f010094b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f010094e:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100951:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100955:	8b 45 08             	mov    0x8(%ebp),%eax
f0100958:	89 04 24             	mov    %eax,(%esp)
f010095b:	e8 b5 ff ff ff       	call   f0100915 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100960:	c9                   	leave  
f0100961:	c3                   	ret    

f0100962 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100962:	55                   	push   %ebp
f0100963:	89 e5                	mov    %esp,%ebp
f0100965:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100968:	8b 45 08             	mov    0x8(%ebp),%eax
f010096b:	89 04 24             	mov    %eax,(%esp)
f010096e:	e8 2d fd ff ff       	call   f01006a0 <cputchar>
	*cnt++;
}
f0100973:	c9                   	leave  
f0100974:	c3                   	ret    
f0100975:	66 90                	xchg   %ax,%ax
f0100977:	66 90                	xchg   %ax,%ax
f0100979:	66 90                	xchg   %ax,%ax
f010097b:	66 90                	xchg   %ax,%ax
f010097d:	66 90                	xchg   %ax,%ax
f010097f:	90                   	nop

f0100980 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100980:	55                   	push   %ebp
f0100981:	89 e5                	mov    %esp,%ebp
f0100983:	57                   	push   %edi
f0100984:	56                   	push   %esi
f0100985:	53                   	push   %ebx
f0100986:	83 ec 4c             	sub    $0x4c,%esp
f0100989:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010098c:	89 d6                	mov    %edx,%esi
f010098e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100991:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100994:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100997:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010099a:	8b 45 10             	mov    0x10(%ebp),%eax
f010099d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01009a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01009a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01009a6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01009ab:	39 d1                	cmp    %edx,%ecx
f01009ad:	72 15                	jb     f01009c4 <printnum+0x44>
f01009af:	77 07                	ja     f01009b8 <printnum+0x38>
f01009b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01009b4:	39 d0                	cmp    %edx,%eax
f01009b6:	76 0c                	jbe    f01009c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01009b8:	83 eb 01             	sub    $0x1,%ebx
f01009bb:	85 db                	test   %ebx,%ebx
f01009bd:	8d 76 00             	lea    0x0(%esi),%esi
f01009c0:	7f 61                	jg     f0100a23 <printnum+0xa3>
f01009c2:	eb 70                	jmp    f0100a34 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01009c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01009c8:	83 eb 01             	sub    $0x1,%ebx
f01009cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01009d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f01009db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01009de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01009e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01009e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01009e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01009ef:	00 
f01009f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009f3:	89 04 24             	mov    %eax,(%esp)
f01009f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01009f9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009fd:	e8 3e 0a 00 00       	call   f0101440 <__udivdi3>
f0100a02:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100a05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100a08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a0c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a10:	89 04 24             	mov    %eax,(%esp)
f0100a13:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a17:	89 f2                	mov    %esi,%edx
f0100a19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1c:	e8 5f ff ff ff       	call   f0100980 <printnum>
f0100a21:	eb 11                	jmp    f0100a34 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100a23:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a27:	89 3c 24             	mov    %edi,(%esp)
f0100a2a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a2d:	83 eb 01             	sub    $0x1,%ebx
f0100a30:	85 db                	test   %ebx,%ebx
f0100a32:	7f ef                	jg     f0100a23 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100a34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a38:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100a3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a3f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a4a:	00 
f0100a4b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a4e:	89 14 24             	mov    %edx,(%esp)
f0100a51:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100a54:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100a58:	e8 13 0b 00 00       	call   f0101570 <__umoddi3>
f0100a5d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a61:	0f be 80 64 1b 10 f0 	movsbl -0xfefe49c(%eax),%eax
f0100a68:	89 04 24             	mov    %eax,(%esp)
f0100a6b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100a6e:	83 c4 4c             	add    $0x4c,%esp
f0100a71:	5b                   	pop    %ebx
f0100a72:	5e                   	pop    %esi
f0100a73:	5f                   	pop    %edi
f0100a74:	5d                   	pop    %ebp
f0100a75:	c3                   	ret    

f0100a76 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100a76:	55                   	push   %ebp
f0100a77:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100a79:	83 fa 01             	cmp    $0x1,%edx
f0100a7c:	7e 0f                	jle    f0100a8d <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f0100a7e:	8b 10                	mov    (%eax),%edx
f0100a80:	83 c2 08             	add    $0x8,%edx
f0100a83:	89 10                	mov    %edx,(%eax)
f0100a85:	8b 42 f8             	mov    -0x8(%edx),%eax
f0100a88:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100a8b:	eb 24                	jmp    f0100ab1 <getuint+0x3b>
	else if (lflag)
f0100a8d:	85 d2                	test   %edx,%edx
f0100a8f:	74 11                	je     f0100aa2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0100a91:	8b 10                	mov    (%eax),%edx
f0100a93:	83 c2 04             	add    $0x4,%edx
f0100a96:	89 10                	mov    %edx,(%eax)
f0100a98:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100a9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100aa0:	eb 0f                	jmp    f0100ab1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0100aa2:	8b 10                	mov    (%eax),%edx
f0100aa4:	83 c2 04             	add    $0x4,%edx
f0100aa7:	89 10                	mov    %edx,(%eax)
f0100aa9:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100aac:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100ab1:	5d                   	pop    %ebp
f0100ab2:	c3                   	ret    

f0100ab3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ab3:	55                   	push   %ebp
f0100ab4:	89 e5                	mov    %esp,%ebp
f0100ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ab9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100abd:	8b 10                	mov    (%eax),%edx
f0100abf:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ac2:	73 0a                	jae    f0100ace <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100ac7:	88 0a                	mov    %cl,(%edx)
f0100ac9:	83 c2 01             	add    $0x1,%edx
f0100acc:	89 10                	mov    %edx,(%eax)
}
f0100ace:	5d                   	pop    %ebp
f0100acf:	c3                   	ret    

f0100ad0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100ad0:	55                   	push   %ebp
f0100ad1:	89 e5                	mov    %esp,%ebp
f0100ad3:	57                   	push   %edi
f0100ad4:	56                   	push   %esi
f0100ad5:	53                   	push   %ebx
f0100ad6:	83 ec 5c             	sub    $0x5c,%esp
f0100ad9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100adc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100ae2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0100ae9:	eb 11                	jmp    f0100afc <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100aeb:	85 c0                	test   %eax,%eax
f0100aed:	0f 84 1a 04 00 00    	je     f0100f0d <vprintfmt+0x43d>
				return;
			putch(ch, putdat);
f0100af3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100af7:	89 04 24             	mov    %eax,(%esp)
f0100afa:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100afc:	0f b6 03             	movzbl (%ebx),%eax
f0100aff:	83 c3 01             	add    $0x1,%ebx
f0100b02:	83 f8 25             	cmp    $0x25,%eax
f0100b05:	75 e4                	jne    f0100aeb <vprintfmt+0x1b>
f0100b07:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f0100b0b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0100b12:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0100b19:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100b20:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b25:	eb 06                	jmp    f0100b2d <vprintfmt+0x5d>
f0100b27:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0100b2b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b2d:	0f b6 13             	movzbl (%ebx),%edx
f0100b30:	0f b6 c2             	movzbl %dl,%eax
f0100b33:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100b36:	8d 43 01             	lea    0x1(%ebx),%eax
f0100b39:	83 ea 23             	sub    $0x23,%edx
f0100b3c:	80 fa 55             	cmp    $0x55,%dl
f0100b3f:	0f 87 ab 03 00 00    	ja     f0100ef0 <vprintfmt+0x420>
f0100b45:	0f b6 d2             	movzbl %dl,%edx
f0100b48:	ff 24 95 f4 1b 10 f0 	jmp    *-0xfefe40c(,%edx,4)
f0100b4f:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0100b53:	eb d6                	jmp    f0100b2b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100b55:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100b58:	83 ea 30             	sub    $0x30,%edx
f0100b5b:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f0100b5e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100b61:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100b64:	83 fb 09             	cmp    $0x9,%ebx
f0100b67:	77 55                	ja     f0100bbe <vprintfmt+0xee>
f0100b69:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b6c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100b6f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0100b72:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100b75:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0100b79:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100b7c:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100b7f:	83 fb 09             	cmp    $0x9,%ebx
f0100b82:	76 eb                	jbe    f0100b6f <vprintfmt+0x9f>
f0100b84:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100b87:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100b8a:	eb 32                	jmp    f0100bbe <vprintfmt+0xee>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100b8c:	8b 55 14             	mov    0x14(%ebp),%edx
f0100b8f:	83 c2 04             	add    $0x4,%edx
f0100b92:	89 55 14             	mov    %edx,0x14(%ebp)
f0100b95:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100b98:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f0100b9b:	eb 21                	jmp    f0100bbe <vprintfmt+0xee>

		case '.':
			if (width < 0)
f0100b9d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ba1:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ba6:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
f0100baa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100bad:	e9 79 ff ff ff       	jmp    f0100b2b <vprintfmt+0x5b>
f0100bb2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0100bb9:	e9 6d ff ff ff       	jmp    f0100b2b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0100bbe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100bc2:	0f 89 63 ff ff ff    	jns    f0100b2b <vprintfmt+0x5b>
f0100bc8:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100bcb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100bce:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0100bd1:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0100bd4:	e9 52 ff ff ff       	jmp    f0100b2b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100bd9:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0100bdc:	e9 4a ff ff ff       	jmp    f0100b2b <vprintfmt+0x5b>
f0100be1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100be4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100be7:	83 c0 04             	add    $0x4,%eax
f0100bea:	89 45 14             	mov    %eax,0x14(%ebp)
f0100bed:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bf1:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100bf4:	89 04 24             	mov    %eax,(%esp)
f0100bf7:	ff d7                	call   *%edi
f0100bf9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0100bfc:	e9 fb fe ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100c01:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100c04:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c07:	83 c0 04             	add    $0x4,%eax
f0100c0a:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c0d:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c10:	89 c2                	mov    %eax,%edx
f0100c12:	c1 fa 1f             	sar    $0x1f,%edx
f0100c15:	31 d0                	xor    %edx,%eax
f0100c17:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c19:	83 f8 06             	cmp    $0x6,%eax
f0100c1c:	7f 0b                	jg     f0100c29 <vprintfmt+0x159>
f0100c1e:	8b 14 85 4c 1d 10 f0 	mov    -0xfefe2b4(,%eax,4),%edx
f0100c25:	85 d2                	test   %edx,%edx
f0100c27:	75 20                	jne    f0100c49 <vprintfmt+0x179>
				printfmt(putch, putdat, "error %d", err);
f0100c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c2d:	c7 44 24 08 75 1b 10 	movl   $0xf0101b75,0x8(%esp)
f0100c34:	f0 
f0100c35:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c39:	89 3c 24             	mov    %edi,(%esp)
f0100c3c:	e8 54 03 00 00       	call   f0100f95 <printfmt>
f0100c41:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c44:	e9 b3 fe ff ff       	jmp    f0100afc <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0100c49:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c4d:	c7 44 24 08 7e 1b 10 	movl   $0xf0101b7e,0x8(%esp)
f0100c54:	f0 
f0100c55:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c59:	89 3c 24             	mov    %edi,(%esp)
f0100c5c:	e8 34 03 00 00       	call   f0100f95 <printfmt>
f0100c61:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100c64:	e9 93 fe ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100c69:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100c6c:	89 c3                	mov    %eax,%ebx
f0100c6e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100c71:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100c74:	89 4d c0             	mov    %ecx,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100c77:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c7a:	83 c0 04             	add    $0x4,%eax
f0100c7d:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c80:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c83:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c86:	85 c0                	test   %eax,%eax
f0100c88:	b8 81 1b 10 f0       	mov    $0xf0101b81,%eax
f0100c8d:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
f0100c91:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0100c94:	85 c9                	test   %ecx,%ecx
f0100c96:	7e 06                	jle    f0100c9e <vprintfmt+0x1ce>
f0100c98:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f0100c9c:	75 13                	jne    f0100cb1 <vprintfmt+0x1e1>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100c9e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100ca1:	0f be 02             	movsbl (%edx),%eax
f0100ca4:	85 c0                	test   %eax,%eax
f0100ca6:	0f 85 99 00 00 00    	jne    f0100d45 <vprintfmt+0x275>
f0100cac:	e9 86 00 00 00       	jmp    f0100d37 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100cb1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cb5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100cb8:	89 0c 24             	mov    %ecx,(%esp)
f0100cbb:	e8 eb 03 00 00       	call   f01010ab <strnlen>
f0100cc0:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100cc3:	29 c2                	sub    %eax,%edx
f0100cc5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100cc8:	85 d2                	test   %edx,%edx
f0100cca:	7e d2                	jle    f0100c9e <vprintfmt+0x1ce>
					putch(padc, putdat);
f0100ccc:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
f0100cd0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100cd3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0100cd6:	89 d3                	mov    %edx,%ebx
f0100cd8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cdf:	89 04 24             	mov    %eax,(%esp)
f0100ce2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ce4:	83 eb 01             	sub    $0x1,%ebx
f0100ce7:	85 db                	test   %ebx,%ebx
f0100ce9:	7f ed                	jg     f0100cd8 <vprintfmt+0x208>
f0100ceb:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0100cee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100cf5:	eb a7                	jmp    f0100c9e <vprintfmt+0x1ce>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100cf7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100cfb:	74 18                	je     f0100d15 <vprintfmt+0x245>
f0100cfd:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d00:	83 fa 5e             	cmp    $0x5e,%edx
f0100d03:	76 10                	jbe    f0100d15 <vprintfmt+0x245>
					putch('?', putdat);
f0100d05:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d09:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100d10:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d13:	eb 0a                	jmp    f0100d1f <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0100d15:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d19:	89 04 24             	mov    %eax,(%esp)
f0100d1c:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d1f:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100d23:	0f be 03             	movsbl (%ebx),%eax
f0100d26:	85 c0                	test   %eax,%eax
f0100d28:	74 05                	je     f0100d2f <vprintfmt+0x25f>
f0100d2a:	83 c3 01             	add    $0x1,%ebx
f0100d2d:	eb 29                	jmp    f0100d58 <vprintfmt+0x288>
f0100d2f:	89 fe                	mov    %edi,%esi
f0100d31:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100d34:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100d3b:	7f 2e                	jg     f0100d6b <vprintfmt+0x29b>
f0100d3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100d40:	e9 b7 fd ff ff       	jmp    f0100afc <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d45:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100d48:	83 c2 01             	add    $0x1,%edx
f0100d4b:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0100d4e:	89 f7                	mov    %esi,%edi
f0100d50:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100d53:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100d56:	89 d3                	mov    %edx,%ebx
f0100d58:	85 f6                	test   %esi,%esi
f0100d5a:	78 9b                	js     f0100cf7 <vprintfmt+0x227>
f0100d5c:	83 ee 01             	sub    $0x1,%esi
f0100d5f:	79 96                	jns    f0100cf7 <vprintfmt+0x227>
f0100d61:	89 fe                	mov    %edi,%esi
f0100d63:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100d66:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100d69:	eb cc                	jmp    f0100d37 <vprintfmt+0x267>
f0100d6b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100d6e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100d71:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d75:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100d7c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d7e:	83 eb 01             	sub    $0x1,%ebx
f0100d81:	85 db                	test   %ebx,%ebx
f0100d83:	7f ec                	jg     f0100d71 <vprintfmt+0x2a1>
f0100d85:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100d88:	e9 6f fd ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100d8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100d90:	83 f9 01             	cmp    $0x1,%ecx
f0100d93:	7e 17                	jle    f0100dac <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
f0100d95:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d98:	83 c0 08             	add    $0x8,%eax
f0100d9b:	89 45 14             	mov    %eax,0x14(%ebp)
f0100d9e:	8b 50 f8             	mov    -0x8(%eax),%edx
f0100da1:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100da4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100da7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100daa:	eb 34                	jmp    f0100de0 <vprintfmt+0x310>
	else if (lflag)
f0100dac:	85 c9                	test   %ecx,%ecx
f0100dae:	74 19                	je     f0100dc9 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
f0100db0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100db3:	83 c0 04             	add    $0x4,%eax
f0100db6:	89 45 14             	mov    %eax,0x14(%ebp)
f0100db9:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100dbc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dbf:	89 c1                	mov    %eax,%ecx
f0100dc1:	c1 f9 1f             	sar    $0x1f,%ecx
f0100dc4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100dc7:	eb 17                	jmp    f0100de0 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
f0100dc9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dcc:	83 c0 04             	add    $0x4,%eax
f0100dcf:	89 45 14             	mov    %eax,0x14(%ebp)
f0100dd2:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100dd5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dd8:	89 c2                	mov    %eax,%edx
f0100dda:	c1 fa 1f             	sar    $0x1f,%edx
f0100ddd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100de0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100de3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100de6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100deb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100def:	0f 89 b9 00 00 00    	jns    f0100eae <vprintfmt+0x3de>
				putch('-', putdat);
f0100df5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100df9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100e00:	ff d7                	call   *%edi
				num = -(long long) num;
f0100e02:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100e05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e08:	f7 d9                	neg    %ecx
f0100e0a:	83 d3 00             	adc    $0x0,%ebx
f0100e0d:	f7 db                	neg    %ebx
f0100e0f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100e14:	e9 95 00 00 00       	jmp    f0100eae <vprintfmt+0x3de>
f0100e19:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100e1c:	89 ca                	mov    %ecx,%edx
f0100e1e:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e21:	e8 50 fc ff ff       	call   f0100a76 <getuint>
f0100e26:	89 c1                	mov    %eax,%ecx
f0100e28:	89 d3                	mov    %edx,%ebx
f0100e2a:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0100e2f:	eb 7d                	jmp    f0100eae <vprintfmt+0x3de>
f0100e31:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0100e34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e38:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100e3f:	ff d7                	call   *%edi
			putch('X', putdat);
f0100e41:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e45:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100e4c:	ff d7                	call   *%edi
			putch('X', putdat);
f0100e4e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e52:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100e59:	ff d7                	call   *%edi
f0100e5b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0100e5e:	e9 99 fc ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100e63:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0100e66:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e6a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100e71:	ff d7                	call   *%edi
			putch('x', putdat);
f0100e73:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e77:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100e7e:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100e80:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e83:	83 c0 04             	add    $0x4,%eax
f0100e86:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100e89:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100e8c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e91:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0100e96:	eb 16                	jmp    f0100eae <vprintfmt+0x3de>
f0100e98:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100e9b:	89 ca                	mov    %ecx,%edx
f0100e9d:	8d 45 14             	lea    0x14(%ebp),%eax
f0100ea0:	e8 d1 fb ff ff       	call   f0100a76 <getuint>
f0100ea5:	89 c1                	mov    %eax,%ecx
f0100ea7:	89 d3                	mov    %edx,%ebx
f0100ea9:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100eae:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0100eb2:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100eb6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100eb9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ebd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ec1:	89 0c 24             	mov    %ecx,(%esp)
f0100ec4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ec8:	89 f2                	mov    %esi,%edx
f0100eca:	89 f8                	mov    %edi,%eax
f0100ecc:	e8 af fa ff ff       	call   f0100980 <printnum>
f0100ed1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0100ed4:	e9 23 fc ff ff       	jmp    f0100afc <vprintfmt+0x2c>
f0100ed9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100edc:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100edf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ee3:	89 14 24             	mov    %edx,(%esp)
f0100ee6:	ff d7                	call   *%edi
f0100ee8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0100eeb:	e9 0c fc ff ff       	jmp    f0100afc <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100ef0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ef4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100efb:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100efd:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100f00:	80 38 25             	cmpb   $0x25,(%eax)
f0100f03:	0f 84 f3 fb ff ff    	je     f0100afc <vprintfmt+0x2c>
f0100f09:	89 c3                	mov    %eax,%ebx
f0100f0b:	eb f0                	jmp    f0100efd <vprintfmt+0x42d>
				/* do nothing */;
			break;
		}
	}
}
f0100f0d:	83 c4 5c             	add    $0x5c,%esp
f0100f10:	5b                   	pop    %ebx
f0100f11:	5e                   	pop    %esi
f0100f12:	5f                   	pop    %edi
f0100f13:	5d                   	pop    %ebp
f0100f14:	c3                   	ret    

f0100f15 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100f15:	55                   	push   %ebp
f0100f16:	89 e5                	mov    %esp,%ebp
f0100f18:	83 ec 28             	sub    $0x28,%esp
f0100f1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0100f21:	85 c0                	test   %eax,%eax
f0100f23:	74 04                	je     f0100f29 <vsnprintf+0x14>
f0100f25:	85 d2                	test   %edx,%edx
f0100f27:	7f 07                	jg     f0100f30 <vsnprintf+0x1b>
f0100f29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100f2e:	eb 3b                	jmp    f0100f6b <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100f30:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100f33:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0100f37:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100f41:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f44:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f48:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f4b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f4f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100f52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f56:	c7 04 24 b3 0a 10 f0 	movl   $0xf0100ab3,(%esp)
f0100f5d:	e8 6e fb ff ff       	call   f0100ad0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f65:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100f6b:	c9                   	leave  
f0100f6c:	c3                   	ret    

f0100f6d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100f6d:	55                   	push   %ebp
f0100f6e:	89 e5                	mov    %esp,%ebp
f0100f70:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100f73:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f76:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f7a:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f7d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f81:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f88:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f8b:	89 04 24             	mov    %eax,(%esp)
f0100f8e:	e8 82 ff ff ff       	call   f0100f15 <vsnprintf>
	va_end(ap);

	return rc;
}
f0100f93:	c9                   	leave  
f0100f94:	c3                   	ret    

f0100f95 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100f95:	55                   	push   %ebp
f0100f96:	89 e5                	mov    %esp,%ebp
f0100f98:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100f9b:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fa2:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fa5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fb3:	89 04 24             	mov    %eax,(%esp)
f0100fb6:	e8 15 fb ff ff       	call   f0100ad0 <vprintfmt>
	va_end(ap);
}
f0100fbb:	c9                   	leave  
f0100fbc:	c3                   	ret    
f0100fbd:	66 90                	xchg   %ax,%ax
f0100fbf:	90                   	nop

f0100fc0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0100fc0:	55                   	push   %ebp
f0100fc1:	89 e5                	mov    %esp,%ebp
f0100fc3:	57                   	push   %edi
f0100fc4:	56                   	push   %esi
f0100fc5:	53                   	push   %ebx
f0100fc6:	83 ec 1c             	sub    $0x1c,%esp
f0100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0100fcc:	85 c0                	test   %eax,%eax
f0100fce:	74 10                	je     f0100fe0 <readline+0x20>
		cprintf("%s", prompt);
f0100fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fd4:	c7 04 24 7e 1b 10 f0 	movl   $0xf0101b7e,(%esp)
f0100fdb:	e8 68 f9 ff ff       	call   f0100948 <cprintf>

	i = 0;
	echoing = iscons(0);
f0100fe0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100fe7:	e8 95 f3 ff ff       	call   f0100381 <iscons>
f0100fec:	89 c7                	mov    %eax,%edi
f0100fee:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0100ff3:	e8 78 f3 ff ff       	call   f0100370 <getchar>
f0100ff8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0100ffa:	85 c0                	test   %eax,%eax
f0100ffc:	79 17                	jns    f0101015 <readline+0x55>
			cprintf("read error: %e\n", c);
f0100ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101002:	c7 04 24 68 1d 10 f0 	movl   $0xf0101d68,(%esp)
f0101009:	e8 3a f9 ff ff       	call   f0100948 <cprintf>
f010100e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101013:	eb 65                	jmp    f010107a <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101015:	83 f8 1f             	cmp    $0x1f,%eax
f0101018:	7e 1f                	jle    f0101039 <readline+0x79>
f010101a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101020:	7f 17                	jg     f0101039 <readline+0x79>
			if (echoing)
f0101022:	85 ff                	test   %edi,%edi
f0101024:	74 08                	je     f010102e <readline+0x6e>
				cputchar(c);
f0101026:	89 04 24             	mov    %eax,(%esp)
f0101029:	e8 72 f6 ff ff       	call   f01006a0 <cputchar>
			buf[i++] = c;
f010102e:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0101034:	83 c6 01             	add    $0x1,%esi
f0101037:	eb ba                	jmp    f0100ff3 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101039:	83 fb 08             	cmp    $0x8,%ebx
f010103c:	75 15                	jne    f0101053 <readline+0x93>
f010103e:	85 f6                	test   %esi,%esi
f0101040:	7e 11                	jle    f0101053 <readline+0x93>
			if (echoing)
f0101042:	85 ff                	test   %edi,%edi
f0101044:	74 08                	je     f010104e <readline+0x8e>
				cputchar(c);
f0101046:	89 1c 24             	mov    %ebx,(%esp)
f0101049:	e8 52 f6 ff ff       	call   f01006a0 <cputchar>
			i--;
f010104e:	83 ee 01             	sub    $0x1,%esi
f0101051:	eb a0                	jmp    f0100ff3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101053:	83 fb 0a             	cmp    $0xa,%ebx
f0101056:	74 0a                	je     f0101062 <readline+0xa2>
f0101058:	83 fb 0d             	cmp    $0xd,%ebx
f010105b:	90                   	nop
f010105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101060:	75 91                	jne    f0100ff3 <readline+0x33>
			if (echoing)
f0101062:	85 ff                	test   %edi,%edi
f0101064:	74 08                	je     f010106e <readline+0xae>
				cputchar(c);
f0101066:	89 1c 24             	mov    %ebx,(%esp)
f0101069:	e8 32 f6 ff ff       	call   f01006a0 <cputchar>
			buf[i] = 0;
f010106e:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
f0101075:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
			return buf;
		}
	}
}
f010107a:	83 c4 1c             	add    $0x1c,%esp
f010107d:	5b                   	pop    %ebx
f010107e:	5e                   	pop    %esi
f010107f:	5f                   	pop    %edi
f0101080:	5d                   	pop    %ebp
f0101081:	c3                   	ret    
f0101082:	66 90                	xchg   %ax,%ax
f0101084:	66 90                	xchg   %ax,%ax
f0101086:	66 90                	xchg   %ax,%ax
f0101088:	66 90                	xchg   %ax,%ax
f010108a:	66 90                	xchg   %ax,%ax
f010108c:	66 90                	xchg   %ax,%ax
f010108e:	66 90                	xchg   %ax,%ax

f0101090 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0101090:	55                   	push   %ebp
f0101091:	89 e5                	mov    %esp,%ebp
f0101093:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101096:	b8 00 00 00 00       	mov    $0x0,%eax
f010109b:	80 3a 00             	cmpb   $0x0,(%edx)
f010109e:	74 09                	je     f01010a9 <strlen+0x19>
		n++;
f01010a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01010a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01010a7:	75 f7                	jne    f01010a0 <strlen+0x10>
		n++;
	return n;
}
f01010a9:	5d                   	pop    %ebp
f01010aa:	c3                   	ret    

f01010ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01010ab:	55                   	push   %ebp
f01010ac:	89 e5                	mov    %esp,%ebp
f01010ae:	53                   	push   %ebx
f01010af:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010b5:	85 c9                	test   %ecx,%ecx
f01010b7:	74 19                	je     f01010d2 <strnlen+0x27>
f01010b9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010bc:	74 14                	je     f01010d2 <strnlen+0x27>
f01010be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01010c3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010c6:	39 c8                	cmp    %ecx,%eax
f01010c8:	74 0d                	je     f01010d7 <strnlen+0x2c>
f01010ca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01010ce:	75 f3                	jne    f01010c3 <strnlen+0x18>
f01010d0:	eb 05                	jmp    f01010d7 <strnlen+0x2c>
f01010d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01010d7:	5b                   	pop    %ebx
f01010d8:	5d                   	pop    %ebp
f01010d9:	c3                   	ret    

f01010da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01010da:	55                   	push   %ebp
f01010db:	89 e5                	mov    %esp,%ebp
f01010dd:	53                   	push   %ebx
f01010de:	8b 45 08             	mov    0x8(%ebp),%eax
f01010e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010e4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01010e9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01010ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01010f0:	83 c2 01             	add    $0x1,%edx
f01010f3:	84 c9                	test   %cl,%cl
f01010f5:	75 f2                	jne    f01010e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01010f7:	5b                   	pop    %ebx
f01010f8:	5d                   	pop    %ebp
f01010f9:	c3                   	ret    

f01010fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01010fa:	55                   	push   %ebp
f01010fb:	89 e5                	mov    %esp,%ebp
f01010fd:	56                   	push   %esi
f01010fe:	53                   	push   %ebx
f01010ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101102:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101105:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101108:	85 f6                	test   %esi,%esi
f010110a:	74 18                	je     f0101124 <strncpy+0x2a>
f010110c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101111:	0f b6 1a             	movzbl (%edx),%ebx
f0101114:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101117:	80 3a 01             	cmpb   $0x1,(%edx)
f010111a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010111d:	83 c1 01             	add    $0x1,%ecx
f0101120:	39 ce                	cmp    %ecx,%esi
f0101122:	77 ed                	ja     f0101111 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101124:	5b                   	pop    %ebx
f0101125:	5e                   	pop    %esi
f0101126:	5d                   	pop    %ebp
f0101127:	c3                   	ret    

f0101128 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101128:	55                   	push   %ebp
f0101129:	89 e5                	mov    %esp,%ebp
f010112b:	56                   	push   %esi
f010112c:	53                   	push   %ebx
f010112d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101130:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101133:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101136:	89 f0                	mov    %esi,%eax
f0101138:	85 c9                	test   %ecx,%ecx
f010113a:	74 27                	je     f0101163 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f010113c:	83 e9 01             	sub    $0x1,%ecx
f010113f:	74 1d                	je     f010115e <strlcpy+0x36>
f0101141:	0f b6 1a             	movzbl (%edx),%ebx
f0101144:	84 db                	test   %bl,%bl
f0101146:	74 16                	je     f010115e <strlcpy+0x36>
			*dst++ = *src++;
f0101148:	88 18                	mov    %bl,(%eax)
f010114a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010114d:	83 e9 01             	sub    $0x1,%ecx
f0101150:	74 0e                	je     f0101160 <strlcpy+0x38>
			*dst++ = *src++;
f0101152:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101155:	0f b6 1a             	movzbl (%edx),%ebx
f0101158:	84 db                	test   %bl,%bl
f010115a:	75 ec                	jne    f0101148 <strlcpy+0x20>
f010115c:	eb 02                	jmp    f0101160 <strlcpy+0x38>
f010115e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101160:	c6 00 00             	movb   $0x0,(%eax)
f0101163:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101165:	5b                   	pop    %ebx
f0101166:	5e                   	pop    %esi
f0101167:	5d                   	pop    %ebp
f0101168:	c3                   	ret    

f0101169 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101169:	55                   	push   %ebp
f010116a:	89 e5                	mov    %esp,%ebp
f010116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010116f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101172:	0f b6 01             	movzbl (%ecx),%eax
f0101175:	84 c0                	test   %al,%al
f0101177:	74 15                	je     f010118e <strcmp+0x25>
f0101179:	3a 02                	cmp    (%edx),%al
f010117b:	75 11                	jne    f010118e <strcmp+0x25>
		p++, q++;
f010117d:	83 c1 01             	add    $0x1,%ecx
f0101180:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101183:	0f b6 01             	movzbl (%ecx),%eax
f0101186:	84 c0                	test   %al,%al
f0101188:	74 04                	je     f010118e <strcmp+0x25>
f010118a:	3a 02                	cmp    (%edx),%al
f010118c:	74 ef                	je     f010117d <strcmp+0x14>
f010118e:	0f b6 c0             	movzbl %al,%eax
f0101191:	0f b6 12             	movzbl (%edx),%edx
f0101194:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101196:	5d                   	pop    %ebp
f0101197:	c3                   	ret    

f0101198 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101198:	55                   	push   %ebp
f0101199:	89 e5                	mov    %esp,%ebp
f010119b:	53                   	push   %ebx
f010119c:	8b 55 08             	mov    0x8(%ebp),%edx
f010119f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01011a2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01011a5:	85 c0                	test   %eax,%eax
f01011a7:	74 23                	je     f01011cc <strncmp+0x34>
f01011a9:	0f b6 1a             	movzbl (%edx),%ebx
f01011ac:	84 db                	test   %bl,%bl
f01011ae:	74 24                	je     f01011d4 <strncmp+0x3c>
f01011b0:	3a 19                	cmp    (%ecx),%bl
f01011b2:	75 20                	jne    f01011d4 <strncmp+0x3c>
f01011b4:	83 e8 01             	sub    $0x1,%eax
f01011b7:	74 13                	je     f01011cc <strncmp+0x34>
		n--, p++, q++;
f01011b9:	83 c2 01             	add    $0x1,%edx
f01011bc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01011bf:	0f b6 1a             	movzbl (%edx),%ebx
f01011c2:	84 db                	test   %bl,%bl
f01011c4:	74 0e                	je     f01011d4 <strncmp+0x3c>
f01011c6:	3a 19                	cmp    (%ecx),%bl
f01011c8:	74 ea                	je     f01011b4 <strncmp+0x1c>
f01011ca:	eb 08                	jmp    f01011d4 <strncmp+0x3c>
f01011cc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01011d1:	5b                   	pop    %ebx
f01011d2:	5d                   	pop    %ebp
f01011d3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01011d4:	0f b6 02             	movzbl (%edx),%eax
f01011d7:	0f b6 11             	movzbl (%ecx),%edx
f01011da:	29 d0                	sub    %edx,%eax
f01011dc:	eb f3                	jmp    f01011d1 <strncmp+0x39>

f01011de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01011de:	55                   	push   %ebp
f01011df:	89 e5                	mov    %esp,%ebp
f01011e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01011e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01011e8:	0f b6 10             	movzbl (%eax),%edx
f01011eb:	84 d2                	test   %dl,%dl
f01011ed:	74 15                	je     f0101204 <strchr+0x26>
		if (*s == c)
f01011ef:	38 ca                	cmp    %cl,%dl
f01011f1:	75 07                	jne    f01011fa <strchr+0x1c>
f01011f3:	eb 14                	jmp    f0101209 <strchr+0x2b>
f01011f5:	38 ca                	cmp    %cl,%dl
f01011f7:	90                   	nop
f01011f8:	74 0f                	je     f0101209 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01011fa:	83 c0 01             	add    $0x1,%eax
f01011fd:	0f b6 10             	movzbl (%eax),%edx
f0101200:	84 d2                	test   %dl,%dl
f0101202:	75 f1                	jne    f01011f5 <strchr+0x17>
f0101204:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101209:	5d                   	pop    %ebp
f010120a:	c3                   	ret    

f010120b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010120b:	55                   	push   %ebp
f010120c:	89 e5                	mov    %esp,%ebp
f010120e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101211:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101215:	0f b6 10             	movzbl (%eax),%edx
f0101218:	84 d2                	test   %dl,%dl
f010121a:	74 18                	je     f0101234 <strfind+0x29>
		if (*s == c)
f010121c:	38 ca                	cmp    %cl,%dl
f010121e:	75 0a                	jne    f010122a <strfind+0x1f>
f0101220:	eb 12                	jmp    f0101234 <strfind+0x29>
f0101222:	38 ca                	cmp    %cl,%dl
f0101224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101228:	74 0a                	je     f0101234 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010122a:	83 c0 01             	add    $0x1,%eax
f010122d:	0f b6 10             	movzbl (%eax),%edx
f0101230:	84 d2                	test   %dl,%dl
f0101232:	75 ee                	jne    f0101222 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101234:	5d                   	pop    %ebp
f0101235:	c3                   	ret    

f0101236 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101236:	55                   	push   %ebp
f0101237:	89 e5                	mov    %esp,%ebp
f0101239:	53                   	push   %ebx
f010123a:	8b 45 08             	mov    0x8(%ebp),%eax
f010123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101240:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101243:	89 da                	mov    %ebx,%edx
f0101245:	83 ea 01             	sub    $0x1,%edx
f0101248:	78 0d                	js     f0101257 <memset+0x21>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f010124a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f010124c:	01 c3                	add    %eax,%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f010124e:	88 0a                	mov    %cl,(%edx)
f0101250:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101253:	39 da                	cmp    %ebx,%edx
f0101255:	75 f7                	jne    f010124e <memset+0x18>
		*p++ = c;

	return v;
}
f0101257:	5b                   	pop    %ebx
f0101258:	5d                   	pop    %ebp
f0101259:	c3                   	ret    

f010125a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f010125a:	55                   	push   %ebp
f010125b:	89 e5                	mov    %esp,%ebp
f010125d:	57                   	push   %edi
f010125e:	56                   	push   %esi
f010125f:	53                   	push   %ebx
f0101260:	8b 45 08             	mov    0x8(%ebp),%eax
f0101263:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101266:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f0101269:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f010126b:	39 c6                	cmp    %eax,%esi
f010126d:	72 0b                	jb     f010127a <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f010126f:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f0101274:	85 db                	test   %ebx,%ebx
f0101276:	75 2b                	jne    f01012a3 <memmove+0x49>
f0101278:	eb 37                	jmp    f01012b1 <memmove+0x57>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010127a:	01 df                	add    %ebx,%edi
f010127c:	39 f8                	cmp    %edi,%eax
f010127e:	66 90                	xchg   %ax,%ax
f0101280:	73 ed                	jae    f010126f <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f0101282:	85 db                	test   %ebx,%ebx
f0101284:	74 2b                	je     f01012b1 <memmove+0x57>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0101286:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f0101289:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f010128e:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f0101293:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f0101297:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f010129a:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f010129d:	85 c9                	test   %ecx,%ecx
f010129f:	75 ed                	jne    f010128e <memmove+0x34>
f01012a1:	eb 0e                	jmp    f01012b1 <memmove+0x57>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f01012a3:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01012a7:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012aa:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f01012ad:	39 d3                	cmp    %edx,%ebx
f01012af:	75 f2                	jne    f01012a3 <memmove+0x49>
			*d++ = *s++;

	return dst;
}
f01012b1:	5b                   	pop    %ebx
f01012b2:	5e                   	pop    %esi
f01012b3:	5f                   	pop    %edi
f01012b4:	5d                   	pop    %ebp
f01012b5:	c3                   	ret    

f01012b6 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01012b6:	55                   	push   %ebp
f01012b7:	89 e5                	mov    %esp,%ebp
f01012b9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01012bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01012bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01012cd:	89 04 24             	mov    %eax,(%esp)
f01012d0:	e8 85 ff ff ff       	call   f010125a <memmove>
}
f01012d5:	c9                   	leave  
f01012d6:	c3                   	ret    

f01012d7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01012d7:	55                   	push   %ebp
f01012d8:	89 e5                	mov    %esp,%ebp
f01012da:	57                   	push   %edi
f01012db:	56                   	push   %esi
f01012dc:	53                   	push   %ebx
f01012dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01012e0:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01012e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01012e6:	85 c9                	test   %ecx,%ecx
f01012e8:	74 36                	je     f0101320 <memcmp+0x49>
		if (*s1 != *s2)
f01012ea:	0f b6 06             	movzbl (%esi),%eax
f01012ed:	0f b6 1f             	movzbl (%edi),%ebx
f01012f0:	38 d8                	cmp    %bl,%al
f01012f2:	74 20                	je     f0101314 <memcmp+0x3d>
f01012f4:	eb 14                	jmp    f010130a <memcmp+0x33>
f01012f6:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f01012fb:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0101300:	83 c2 01             	add    $0x1,%edx
f0101303:	83 e9 01             	sub    $0x1,%ecx
f0101306:	38 d8                	cmp    %bl,%al
f0101308:	74 12                	je     f010131c <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f010130a:	0f b6 c0             	movzbl %al,%eax
f010130d:	0f b6 db             	movzbl %bl,%ebx
f0101310:	29 d8                	sub    %ebx,%eax
f0101312:	eb 11                	jmp    f0101325 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101314:	83 e9 01             	sub    $0x1,%ecx
f0101317:	ba 00 00 00 00       	mov    $0x0,%edx
f010131c:	85 c9                	test   %ecx,%ecx
f010131e:	75 d6                	jne    f01012f6 <memcmp+0x1f>
f0101320:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101325:	5b                   	pop    %ebx
f0101326:	5e                   	pop    %esi
f0101327:	5f                   	pop    %edi
f0101328:	5d                   	pop    %ebp
f0101329:	c3                   	ret    

f010132a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010132a:	55                   	push   %ebp
f010132b:	89 e5                	mov    %esp,%ebp
f010132d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101330:	89 c2                	mov    %eax,%edx
f0101332:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101335:	39 d0                	cmp    %edx,%eax
f0101337:	73 19                	jae    f0101352 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101339:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010133d:	38 08                	cmp    %cl,(%eax)
f010133f:	75 06                	jne    f0101347 <memfind+0x1d>
f0101341:	eb 0f                	jmp    f0101352 <memfind+0x28>
f0101343:	38 08                	cmp    %cl,(%eax)
f0101345:	74 0b                	je     f0101352 <memfind+0x28>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101347:	83 c0 01             	add    $0x1,%eax
f010134a:	39 c2                	cmp    %eax,%edx
f010134c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101350:	77 f1                	ja     f0101343 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101352:	5d                   	pop    %ebp
f0101353:	c3                   	ret    

f0101354 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101354:	55                   	push   %ebp
f0101355:	89 e5                	mov    %esp,%ebp
f0101357:	57                   	push   %edi
f0101358:	56                   	push   %esi
f0101359:	53                   	push   %ebx
f010135a:	83 ec 04             	sub    $0x4,%esp
f010135d:	8b 55 08             	mov    0x8(%ebp),%edx
f0101360:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101363:	0f b6 02             	movzbl (%edx),%eax
f0101366:	3c 20                	cmp    $0x20,%al
f0101368:	74 04                	je     f010136e <strtol+0x1a>
f010136a:	3c 09                	cmp    $0x9,%al
f010136c:	75 0e                	jne    f010137c <strtol+0x28>
		s++;
f010136e:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101371:	0f b6 02             	movzbl (%edx),%eax
f0101374:	3c 20                	cmp    $0x20,%al
f0101376:	74 f6                	je     f010136e <strtol+0x1a>
f0101378:	3c 09                	cmp    $0x9,%al
f010137a:	74 f2                	je     f010136e <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f010137c:	3c 2b                	cmp    $0x2b,%al
f010137e:	75 0c                	jne    f010138c <strtol+0x38>
		s++;
f0101380:	83 c2 01             	add    $0x1,%edx
f0101383:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010138a:	eb 15                	jmp    f01013a1 <strtol+0x4d>
	else if (*s == '-')
f010138c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101393:	3c 2d                	cmp    $0x2d,%al
f0101395:	75 0a                	jne    f01013a1 <strtol+0x4d>
		s++, neg = 1;
f0101397:	83 c2 01             	add    $0x1,%edx
f010139a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013a1:	85 db                	test   %ebx,%ebx
f01013a3:	0f 94 c0             	sete   %al
f01013a6:	74 05                	je     f01013ad <strtol+0x59>
f01013a8:	83 fb 10             	cmp    $0x10,%ebx
f01013ab:	75 15                	jne    f01013c2 <strtol+0x6e>
f01013ad:	80 3a 30             	cmpb   $0x30,(%edx)
f01013b0:	75 10                	jne    f01013c2 <strtol+0x6e>
f01013b2:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01013b6:	75 0a                	jne    f01013c2 <strtol+0x6e>
		s += 2, base = 16;
f01013b8:	83 c2 02             	add    $0x2,%edx
f01013bb:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013c0:	eb 13                	jmp    f01013d5 <strtol+0x81>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01013c2:	84 c0                	test   %al,%al
f01013c4:	74 0f                	je     f01013d5 <strtol+0x81>
f01013c6:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01013cb:	80 3a 30             	cmpb   $0x30,(%edx)
f01013ce:	75 05                	jne    f01013d5 <strtol+0x81>
		s++, base = 8;
f01013d0:	83 c2 01             	add    $0x1,%edx
f01013d3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01013d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01013da:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01013dc:	0f b6 0a             	movzbl (%edx),%ecx
f01013df:	89 cf                	mov    %ecx,%edi
f01013e1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01013e4:	80 fb 09             	cmp    $0x9,%bl
f01013e7:	77 08                	ja     f01013f1 <strtol+0x9d>
			dig = *s - '0';
f01013e9:	0f be c9             	movsbl %cl,%ecx
f01013ec:	83 e9 30             	sub    $0x30,%ecx
f01013ef:	eb 1e                	jmp    f010140f <strtol+0xbb>
		else if (*s >= 'a' && *s <= 'z')
f01013f1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f01013f4:	80 fb 19             	cmp    $0x19,%bl
f01013f7:	77 08                	ja     f0101401 <strtol+0xad>
			dig = *s - 'a' + 10;
f01013f9:	0f be c9             	movsbl %cl,%ecx
f01013fc:	83 e9 57             	sub    $0x57,%ecx
f01013ff:	eb 0e                	jmp    f010140f <strtol+0xbb>
		else if (*s >= 'A' && *s <= 'Z')
f0101401:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101404:	80 fb 19             	cmp    $0x19,%bl
f0101407:	77 15                	ja     f010141e <strtol+0xca>
			dig = *s - 'A' + 10;
f0101409:	0f be c9             	movsbl %cl,%ecx
f010140c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010140f:	39 f1                	cmp    %esi,%ecx
f0101411:	7d 0b                	jge    f010141e <strtol+0xca>
			break;
		s++, val = (val * base) + dig;
f0101413:	83 c2 01             	add    $0x1,%edx
f0101416:	0f af c6             	imul   %esi,%eax
f0101419:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f010141c:	eb be                	jmp    f01013dc <strtol+0x88>
f010141e:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0101420:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101424:	74 05                	je     f010142b <strtol+0xd7>
		*endptr = (char *) s;
f0101426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101429:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010142b:	89 ca                	mov    %ecx,%edx
f010142d:	f7 da                	neg    %edx
f010142f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0101433:	0f 45 c2             	cmovne %edx,%eax
}
f0101436:	83 c4 04             	add    $0x4,%esp
f0101439:	5b                   	pop    %ebx
f010143a:	5e                   	pop    %esi
f010143b:	5f                   	pop    %edi
f010143c:	5d                   	pop    %ebp
f010143d:	c3                   	ret    
f010143e:	66 90                	xchg   %ax,%ax

f0101440 <__udivdi3>:
f0101440:	55                   	push   %ebp
f0101441:	89 e5                	mov    %esp,%ebp
f0101443:	57                   	push   %edi
f0101444:	56                   	push   %esi
f0101445:	83 ec 10             	sub    $0x10,%esp
f0101448:	8b 45 14             	mov    0x14(%ebp),%eax
f010144b:	8b 55 08             	mov    0x8(%ebp),%edx
f010144e:	8b 75 10             	mov    0x10(%ebp),%esi
f0101451:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101454:	85 c0                	test   %eax,%eax
f0101456:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101459:	75 35                	jne    f0101490 <__udivdi3+0x50>
f010145b:	39 fe                	cmp    %edi,%esi
f010145d:	77 61                	ja     f01014c0 <__udivdi3+0x80>
f010145f:	85 f6                	test   %esi,%esi
f0101461:	75 0b                	jne    f010146e <__udivdi3+0x2e>
f0101463:	b8 01 00 00 00       	mov    $0x1,%eax
f0101468:	31 d2                	xor    %edx,%edx
f010146a:	f7 f6                	div    %esi
f010146c:	89 c6                	mov    %eax,%esi
f010146e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101471:	31 d2                	xor    %edx,%edx
f0101473:	89 f8                	mov    %edi,%eax
f0101475:	f7 f6                	div    %esi
f0101477:	89 c7                	mov    %eax,%edi
f0101479:	89 c8                	mov    %ecx,%eax
f010147b:	f7 f6                	div    %esi
f010147d:	89 c1                	mov    %eax,%ecx
f010147f:	89 fa                	mov    %edi,%edx
f0101481:	89 c8                	mov    %ecx,%eax
f0101483:	83 c4 10             	add    $0x10,%esp
f0101486:	5e                   	pop    %esi
f0101487:	5f                   	pop    %edi
f0101488:	5d                   	pop    %ebp
f0101489:	c3                   	ret    
f010148a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101490:	39 f8                	cmp    %edi,%eax
f0101492:	77 1c                	ja     f01014b0 <__udivdi3+0x70>
f0101494:	0f bd d0             	bsr    %eax,%edx
f0101497:	83 f2 1f             	xor    $0x1f,%edx
f010149a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010149d:	75 39                	jne    f01014d8 <__udivdi3+0x98>
f010149f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01014a2:	0f 86 a0 00 00 00    	jbe    f0101548 <__udivdi3+0x108>
f01014a8:	39 f8                	cmp    %edi,%eax
f01014aa:	0f 82 98 00 00 00    	jb     f0101548 <__udivdi3+0x108>
f01014b0:	31 ff                	xor    %edi,%edi
f01014b2:	31 c9                	xor    %ecx,%ecx
f01014b4:	89 c8                	mov    %ecx,%eax
f01014b6:	89 fa                	mov    %edi,%edx
f01014b8:	83 c4 10             	add    $0x10,%esp
f01014bb:	5e                   	pop    %esi
f01014bc:	5f                   	pop    %edi
f01014bd:	5d                   	pop    %ebp
f01014be:	c3                   	ret    
f01014bf:	90                   	nop
f01014c0:	89 d1                	mov    %edx,%ecx
f01014c2:	89 fa                	mov    %edi,%edx
f01014c4:	89 c8                	mov    %ecx,%eax
f01014c6:	31 ff                	xor    %edi,%edi
f01014c8:	f7 f6                	div    %esi
f01014ca:	89 c1                	mov    %eax,%ecx
f01014cc:	89 fa                	mov    %edi,%edx
f01014ce:	89 c8                	mov    %ecx,%eax
f01014d0:	83 c4 10             	add    $0x10,%esp
f01014d3:	5e                   	pop    %esi
f01014d4:	5f                   	pop    %edi
f01014d5:	5d                   	pop    %ebp
f01014d6:	c3                   	ret    
f01014d7:	90                   	nop
f01014d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01014dc:	89 f2                	mov    %esi,%edx
f01014de:	d3 e0                	shl    %cl,%eax
f01014e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01014e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f01014eb:	89 c1                	mov    %eax,%ecx
f01014ed:	d3 ea                	shr    %cl,%edx
f01014ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01014f3:	0b 55 ec             	or     -0x14(%ebp),%edx
f01014f6:	d3 e6                	shl    %cl,%esi
f01014f8:	89 c1                	mov    %eax,%ecx
f01014fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
f01014fd:	89 fe                	mov    %edi,%esi
f01014ff:	d3 ee                	shr    %cl,%esi
f0101501:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101505:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101508:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010150b:	d3 e7                	shl    %cl,%edi
f010150d:	89 c1                	mov    %eax,%ecx
f010150f:	d3 ea                	shr    %cl,%edx
f0101511:	09 d7                	or     %edx,%edi
f0101513:	89 f2                	mov    %esi,%edx
f0101515:	89 f8                	mov    %edi,%eax
f0101517:	f7 75 ec             	divl   -0x14(%ebp)
f010151a:	89 d6                	mov    %edx,%esi
f010151c:	89 c7                	mov    %eax,%edi
f010151e:	f7 65 e8             	mull   -0x18(%ebp)
f0101521:	39 d6                	cmp    %edx,%esi
f0101523:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101526:	72 30                	jb     f0101558 <__udivdi3+0x118>
f0101528:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010152b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010152f:	d3 e2                	shl    %cl,%edx
f0101531:	39 c2                	cmp    %eax,%edx
f0101533:	73 05                	jae    f010153a <__udivdi3+0xfa>
f0101535:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101538:	74 1e                	je     f0101558 <__udivdi3+0x118>
f010153a:	89 f9                	mov    %edi,%ecx
f010153c:	31 ff                	xor    %edi,%edi
f010153e:	e9 71 ff ff ff       	jmp    f01014b4 <__udivdi3+0x74>
f0101543:	90                   	nop
f0101544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101548:	31 ff                	xor    %edi,%edi
f010154a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010154f:	e9 60 ff ff ff       	jmp    f01014b4 <__udivdi3+0x74>
f0101554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101558:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010155b:	31 ff                	xor    %edi,%edi
f010155d:	89 c8                	mov    %ecx,%eax
f010155f:	89 fa                	mov    %edi,%edx
f0101561:	83 c4 10             	add    $0x10,%esp
f0101564:	5e                   	pop    %esi
f0101565:	5f                   	pop    %edi
f0101566:	5d                   	pop    %ebp
f0101567:	c3                   	ret    
f0101568:	66 90                	xchg   %ax,%ax
f010156a:	66 90                	xchg   %ax,%ax
f010156c:	66 90                	xchg   %ax,%ax
f010156e:	66 90                	xchg   %ax,%ax

f0101570 <__umoddi3>:
f0101570:	55                   	push   %ebp
f0101571:	89 e5                	mov    %esp,%ebp
f0101573:	57                   	push   %edi
f0101574:	56                   	push   %esi
f0101575:	83 ec 20             	sub    $0x20,%esp
f0101578:	8b 55 14             	mov    0x14(%ebp),%edx
f010157b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010157e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101581:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101584:	85 d2                	test   %edx,%edx
f0101586:	89 c8                	mov    %ecx,%eax
f0101588:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010158b:	75 13                	jne    f01015a0 <__umoddi3+0x30>
f010158d:	39 f7                	cmp    %esi,%edi
f010158f:	76 3f                	jbe    f01015d0 <__umoddi3+0x60>
f0101591:	89 f2                	mov    %esi,%edx
f0101593:	f7 f7                	div    %edi
f0101595:	89 d0                	mov    %edx,%eax
f0101597:	31 d2                	xor    %edx,%edx
f0101599:	83 c4 20             	add    $0x20,%esp
f010159c:	5e                   	pop    %esi
f010159d:	5f                   	pop    %edi
f010159e:	5d                   	pop    %ebp
f010159f:	c3                   	ret    
f01015a0:	39 f2                	cmp    %esi,%edx
f01015a2:	77 4c                	ja     f01015f0 <__umoddi3+0x80>
f01015a4:	0f bd ca             	bsr    %edx,%ecx
f01015a7:	83 f1 1f             	xor    $0x1f,%ecx
f01015aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01015ad:	75 51                	jne    f0101600 <__umoddi3+0x90>
f01015af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01015b2:	0f 87 e0 00 00 00    	ja     f0101698 <__umoddi3+0x128>
f01015b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015bb:	29 f8                	sub    %edi,%eax
f01015bd:	19 d6                	sbb    %edx,%esi
f01015bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01015c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015c5:	89 f2                	mov    %esi,%edx
f01015c7:	83 c4 20             	add    $0x20,%esp
f01015ca:	5e                   	pop    %esi
f01015cb:	5f                   	pop    %edi
f01015cc:	5d                   	pop    %ebp
f01015cd:	c3                   	ret    
f01015ce:	66 90                	xchg   %ax,%ax
f01015d0:	85 ff                	test   %edi,%edi
f01015d2:	75 0b                	jne    f01015df <__umoddi3+0x6f>
f01015d4:	b8 01 00 00 00       	mov    $0x1,%eax
f01015d9:	31 d2                	xor    %edx,%edx
f01015db:	f7 f7                	div    %edi
f01015dd:	89 c7                	mov    %eax,%edi
f01015df:	89 f0                	mov    %esi,%eax
f01015e1:	31 d2                	xor    %edx,%edx
f01015e3:	f7 f7                	div    %edi
f01015e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015e8:	f7 f7                	div    %edi
f01015ea:	eb a9                	jmp    f0101595 <__umoddi3+0x25>
f01015ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01015f0:	89 c8                	mov    %ecx,%eax
f01015f2:	89 f2                	mov    %esi,%edx
f01015f4:	83 c4 20             	add    $0x20,%esp
f01015f7:	5e                   	pop    %esi
f01015f8:	5f                   	pop    %edi
f01015f9:	5d                   	pop    %ebp
f01015fa:	c3                   	ret    
f01015fb:	90                   	nop
f01015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101600:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101604:	d3 e2                	shl    %cl,%edx
f0101606:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101609:	ba 20 00 00 00       	mov    $0x20,%edx
f010160e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101611:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101614:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101618:	89 fa                	mov    %edi,%edx
f010161a:	d3 ea                	shr    %cl,%edx
f010161c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101620:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101623:	d3 e7                	shl    %cl,%edi
f0101625:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101629:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010162c:	89 f2                	mov    %esi,%edx
f010162e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101631:	89 c7                	mov    %eax,%edi
f0101633:	d3 ea                	shr    %cl,%edx
f0101635:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101639:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010163c:	89 c2                	mov    %eax,%edx
f010163e:	d3 e6                	shl    %cl,%esi
f0101640:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101644:	d3 ea                	shr    %cl,%edx
f0101646:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010164a:	09 d6                	or     %edx,%esi
f010164c:	89 f0                	mov    %esi,%eax
f010164e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101651:	d3 e7                	shl    %cl,%edi
f0101653:	89 f2                	mov    %esi,%edx
f0101655:	f7 75 f4             	divl   -0xc(%ebp)
f0101658:	89 d6                	mov    %edx,%esi
f010165a:	f7 65 e8             	mull   -0x18(%ebp)
f010165d:	39 d6                	cmp    %edx,%esi
f010165f:	72 2b                	jb     f010168c <__umoddi3+0x11c>
f0101661:	39 c7                	cmp    %eax,%edi
f0101663:	72 23                	jb     f0101688 <__umoddi3+0x118>
f0101665:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101669:	29 c7                	sub    %eax,%edi
f010166b:	19 d6                	sbb    %edx,%esi
f010166d:	89 f0                	mov    %esi,%eax
f010166f:	89 f2                	mov    %esi,%edx
f0101671:	d3 ef                	shr    %cl,%edi
f0101673:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101677:	d3 e0                	shl    %cl,%eax
f0101679:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010167d:	09 f8                	or     %edi,%eax
f010167f:	d3 ea                	shr    %cl,%edx
f0101681:	83 c4 20             	add    $0x20,%esp
f0101684:	5e                   	pop    %esi
f0101685:	5f                   	pop    %edi
f0101686:	5d                   	pop    %ebp
f0101687:	c3                   	ret    
f0101688:	39 d6                	cmp    %edx,%esi
f010168a:	75 d9                	jne    f0101665 <__umoddi3+0xf5>
f010168c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010168f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0101692:	eb d1                	jmp    f0101665 <__umoddi3+0xf5>
f0101694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101698:	39 f2                	cmp    %esi,%edx
f010169a:	0f 82 18 ff ff ff    	jb     f01015b8 <__umoddi3+0x48>
f01016a0:	e9 1d ff ff ff       	jmp    f01015c2 <__umoddi3+0x52>
