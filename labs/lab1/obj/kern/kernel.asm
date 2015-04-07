
obj/kern/kernel:     file format elf32-i386


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
f0100038:	e8 60 00 00 00       	call   f010009d <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 40 17 10 f0 	movl   $0xf0101740,(%esp)
f0100055:	e8 d0 09 00 00       	call   f0100a2a <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 c9 06 00 00       	call   f0100750 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 5c 17 10 f0 	movl   $0xf010175c,(%esp)
f0100092:	e8 93 09 00 00       	call   f0100a2a <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 80 f9 10 f0       	mov    $0xf010f980,%eax
f01000a8:	2d 20 f3 10 f0       	sub    $0xf010f320,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 20 f3 10 f0 	movl   $0xf010f320,(%esp)
f01000c0:	e8 d1 11 00 00       	call   f0101296 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 27 06 00 00       	call   f01006f1 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 77 17 10 f0 	movl   $0xf0101777,(%esp)
f01000d9:	e8 4c 09 00 00       	call   f0100a2a <cprintf>
	// seems that it won`t work, because I never see 6828 on the screen.
	// okay, it is the problem caused by wrong version of bochs. Maybe another way to handle?


	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 ab 07 00 00       	call   f01008a1 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f01000fe:	83 3d 20 f3 10 f0 00 	cmpl   $0x0,0xf010f320
f0100105:	75 40                	jne    f0100147 <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f0100107:	8b 45 10             	mov    0x10(%ebp),%eax
f010010a:	a3 20 f3 10 f0       	mov    %eax,0xf010f320

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f010010f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100112:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100116:	8b 45 08             	mov    0x8(%ebp),%eax
f0100119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010011d:	c7 04 24 92 17 10 f0 	movl   $0xf0101792,(%esp)
f0100124:	e8 01 09 00 00       	call   f0100a2a <cprintf>
	vcprintf(fmt, ap);
f0100129:	8d 45 14             	lea    0x14(%ebp),%eax
f010012c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100130:	8b 45 10             	mov    0x10(%ebp),%eax
f0100133:	89 04 24             	mov    %eax,(%esp)
f0100136:	e8 bc 08 00 00       	call   f01009f7 <vcprintf>
	cprintf("\n");
f010013b:	c7 04 24 ce 17 10 f0 	movl   $0xf01017ce,(%esp)
f0100142:	e8 e3 08 00 00       	call   f0100a2a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010014e:	e8 4e 07 00 00       	call   f01008a1 <monitor>
f0100153:	eb f2                	jmp    f0100147 <_panic+0x4f>

f0100155 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100155:	55                   	push   %ebp
f0100156:	89 e5                	mov    %esp,%ebp
f0100158:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010015b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010015e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100162:	8b 45 08             	mov    0x8(%ebp),%eax
f0100165:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100169:	c7 04 24 aa 17 10 f0 	movl   $0xf01017aa,(%esp)
f0100170:	e8 b5 08 00 00       	call   f0100a2a <cprintf>
	vcprintf(fmt, ap);
f0100175:	8d 45 14             	lea    0x14(%ebp),%eax
f0100178:	89 44 24 04          	mov    %eax,0x4(%esp)
f010017c:	8b 45 10             	mov    0x10(%ebp),%eax
f010017f:	89 04 24             	mov    %eax,(%esp)
f0100182:	e8 70 08 00 00       	call   f01009f7 <vcprintf>
	cprintf("\n");
f0100187:	c7 04 24 ce 17 10 f0 	movl   $0xf01017ce,(%esp)
f010018e:	e8 97 08 00 00       	call   f0100a2a <cprintf>
	va_end(ap);
}
f0100193:	c9                   	leave  
f0100194:	c3                   	ret    
f0100195:	00 00                	add    %al,(%eax)
	...

f0100198 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100198:	55                   	push   %ebp
f0100199:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010019b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a0:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001a1:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001a6:	a8 01                	test   $0x1,%al
f01001a8:	74 06                	je     f01001b0 <serial_proc_data+0x18>
f01001aa:	b2 f8                	mov    $0xf8,%dl
f01001ac:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ad:	0f b6 c8             	movzbl %al,%ecx
}
f01001b0:	89 c8                	mov    %ecx,%eax
f01001b2:	5d                   	pop    %ebp
f01001b3:	c3                   	ret    

f01001b4 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001b4:	55                   	push   %ebp
f01001b5:	89 e5                	mov    %esp,%ebp
f01001b7:	53                   	push   %ebx
f01001b8:	83 ec 14             	sub    $0x14,%esp
f01001bb:	ba 64 00 00 00       	mov    $0x64,%edx
f01001c0:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01001c1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	0f 84 de 00 00 00    	je     f01002ac <kbd_proc_data+0xf8>
f01001ce:	b2 60                	mov    $0x60,%dl
f01001d0:	ec                   	in     (%dx),%al
f01001d1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001d3:	3c e0                	cmp    $0xe0,%al
f01001d5:	75 11                	jne    f01001e8 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f01001d7:	83 0d 50 f3 10 f0 40 	orl    $0x40,0xf010f350
		return 0;
f01001de:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001e3:	e9 c4 00 00 00       	jmp    f01002ac <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01001e8:	84 c0                	test   %al,%al
f01001ea:	79 37                	jns    f0100223 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ec:	8b 0d 50 f3 10 f0    	mov    0xf010f350,%ecx
f01001f2:	89 cb                	mov    %ecx,%ebx
f01001f4:	83 e3 40             	and    $0x40,%ebx
f01001f7:	83 e0 7f             	and    $0x7f,%eax
f01001fa:	85 db                	test   %ebx,%ebx
f01001fc:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001ff:	0f b6 d2             	movzbl %dl,%edx
f0100202:	0f b6 82 e0 19 10 f0 	movzbl -0xfefe620(%edx),%eax
f0100209:	83 c8 40             	or     $0x40,%eax
f010020c:	0f b6 c0             	movzbl %al,%eax
f010020f:	f7 d0                	not    %eax
f0100211:	21 c1                	and    %eax,%ecx
f0100213:	89 0d 50 f3 10 f0    	mov    %ecx,0xf010f350
		return 0;
f0100219:	bb 00 00 00 00       	mov    $0x0,%ebx
f010021e:	e9 89 00 00 00       	jmp    f01002ac <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f0100223:	8b 0d 50 f3 10 f0    	mov    0xf010f350,%ecx
f0100229:	f6 c1 40             	test   $0x40,%cl
f010022c:	74 0e                	je     f010023c <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010022e:	89 c2                	mov    %eax,%edx
f0100230:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100233:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100236:	89 0d 50 f3 10 f0    	mov    %ecx,0xf010f350
	}

	shift |= shiftcode[data];
f010023c:	0f b6 d2             	movzbl %dl,%edx
f010023f:	0f b6 82 e0 19 10 f0 	movzbl -0xfefe620(%edx),%eax
f0100246:	0b 05 50 f3 10 f0    	or     0xf010f350,%eax
	shift ^= togglecode[data];
f010024c:	0f b6 8a e0 1a 10 f0 	movzbl -0xfefe520(%edx),%ecx
f0100253:	31 c8                	xor    %ecx,%eax
f0100255:	a3 50 f3 10 f0       	mov    %eax,0xf010f350

	c = charcode[shift & (CTL | SHIFT)][data];
f010025a:	89 c1                	mov    %eax,%ecx
f010025c:	83 e1 03             	and    $0x3,%ecx
f010025f:	8b 0c 8d e0 1b 10 f0 	mov    -0xfefe420(,%ecx,4),%ecx
f0100266:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010026a:	a8 08                	test   $0x8,%al
f010026c:	74 19                	je     f0100287 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f010026e:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100271:	83 fa 19             	cmp    $0x19,%edx
f0100274:	77 05                	ja     f010027b <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f0100276:	83 eb 20             	sub    $0x20,%ebx
f0100279:	eb 0c                	jmp    f0100287 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f010027b:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f010027e:	8d 53 20             	lea    0x20(%ebx),%edx
f0100281:	83 f9 19             	cmp    $0x19,%ecx
f0100284:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100287:	f7 d0                	not    %eax
f0100289:	a8 06                	test   $0x6,%al
f010028b:	75 1f                	jne    f01002ac <kbd_proc_data+0xf8>
f010028d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100293:	75 17                	jne    f01002ac <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f0100295:	c7 04 24 c4 17 10 f0 	movl   $0xf01017c4,(%esp)
f010029c:	e8 89 07 00 00       	call   f0100a2a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002a1:	ba 92 00 00 00       	mov    $0x92,%edx
f01002a6:	b8 03 00 00 00       	mov    $0x3,%eax
f01002ab:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002ac:	89 d8                	mov    %ebx,%eax
f01002ae:	83 c4 14             	add    $0x14,%esp
f01002b1:	5b                   	pop    %ebx
f01002b2:	5d                   	pop    %ebp
f01002b3:	c3                   	ret    

f01002b4 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f01002b4:	55                   	push   %ebp
f01002b5:	89 e5                	mov    %esp,%ebp
f01002b7:	53                   	push   %ebx
f01002b8:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01002bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01002c2:	89 da                	mov    %ebx,%edx
f01002c4:	ee                   	out    %al,(%dx)
f01002c5:	b2 fb                	mov    $0xfb,%dl
f01002c7:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01002cc:	ee                   	out    %al,(%dx)
f01002cd:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01002d2:	b8 0c 00 00 00       	mov    $0xc,%eax
f01002d7:	89 ca                	mov    %ecx,%edx
f01002d9:	ee                   	out    %al,(%dx)
f01002da:	b2 f9                	mov    $0xf9,%dl
f01002dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01002e1:	ee                   	out    %al,(%dx)
f01002e2:	b2 fb                	mov    $0xfb,%dl
f01002e4:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e9:	ee                   	out    %al,(%dx)
f01002ea:	b2 fc                	mov    $0xfc,%dl
f01002ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f1:	ee                   	out    %al,(%dx)
f01002f2:	b2 f9                	mov    $0xf9,%dl
f01002f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01002f9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002fa:	b2 fd                	mov    $0xfd,%dl
f01002fc:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01002fd:	3c ff                	cmp    $0xff,%al
f01002ff:	0f 95 c0             	setne  %al
f0100302:	0f b6 c0             	movzbl %al,%eax
f0100305:	a3 40 f3 10 f0       	mov    %eax,0xf010f340
f010030a:	89 da                	mov    %ebx,%edx
f010030c:	ec                   	in     (%dx),%al
f010030d:	89 ca                	mov    %ecx,%edx
f010030f:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f0100310:	5b                   	pop    %ebx
f0100311:	5d                   	pop    %ebp
f0100312:	c3                   	ret    

f0100313 <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f0100313:	55                   	push   %ebp
f0100314:	89 e5                	mov    %esp,%ebp
f0100316:	83 ec 0c             	sub    $0xc,%esp
f0100319:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010031c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010031f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100322:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100329:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100330:	5a a5 
	if (*cp != 0xA55A) {
f0100332:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100339:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010033d:	74 11                	je     f0100350 <cga_init+0x3d>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010033f:	c7 05 44 f3 10 f0 b4 	movl   $0x3b4,0xf010f344
f0100346:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100349:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010034e:	eb 16                	jmp    f0100366 <cga_init+0x53>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100350:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100357:	c7 05 44 f3 10 f0 d4 	movl   $0x3d4,0xf010f344
f010035e:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100361:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100366:	8b 0d 44 f3 10 f0    	mov    0xf010f344,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100371:	89 ca                	mov    %ecx,%edx
f0100373:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100374:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100377:	89 da                	mov    %ebx,%edx
f0100379:	ec                   	in     (%dx),%al
f010037a:	0f b6 f8             	movzbl %al,%edi
f010037d:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100380:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100385:	89 ca                	mov    %ecx,%edx
f0100387:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100388:	89 da                	mov    %ebx,%edx
f010038a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010038b:	89 35 48 f3 10 f0    	mov    %esi,0xf010f348
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100391:	0f b6 d8             	movzbl %al,%ebx
f0100394:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100396:	66 89 3d 4c f3 10 f0 	mov    %di,0xf010f34c
}
f010039d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01003a0:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01003a3:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01003a6:	89 ec                	mov    %ebp,%esp
f01003a8:	5d                   	pop    %ebp
f01003a9:	c3                   	ret    

f01003aa <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f01003aa:	55                   	push   %ebp
f01003ab:	89 e5                	mov    %esp,%ebp
}
f01003ad:	5d                   	pop    %ebp
f01003ae:	c3                   	ret    

f01003af <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01003af:	55                   	push   %ebp
f01003b0:	89 e5                	mov    %esp,%ebp
f01003b2:	53                   	push   %ebx
f01003b3:	83 ec 04             	sub    $0x4,%esp
f01003b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01003b9:	eb 25                	jmp    f01003e0 <cons_intr+0x31>
		if (c == 0)
f01003bb:	85 c0                	test   %eax,%eax
f01003bd:	74 21                	je     f01003e0 <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f01003bf:	8b 15 64 f5 10 f0    	mov    0xf010f564,%edx
f01003c5:	88 82 60 f3 10 f0    	mov    %al,-0xfef0ca0(%edx)
f01003cb:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01003ce:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01003d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01003d8:	0f 44 c2             	cmove  %edx,%eax
f01003db:	a3 64 f5 10 f0       	mov    %eax,0xf010f564
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01003e0:	ff d3                	call   *%ebx
f01003e2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01003e5:	75 d4                	jne    f01003bb <cons_intr+0xc>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01003e7:	83 c4 04             	add    $0x4,%esp
f01003ea:	5b                   	pop    %ebx
f01003eb:	5d                   	pop    %ebp
f01003ec:	c3                   	ret    

f01003ed <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01003ed:	55                   	push   %ebp
f01003ee:	89 e5                	mov    %esp,%ebp
f01003f0:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f01003f3:	c7 04 24 b4 01 10 f0 	movl   $0xf01001b4,(%esp)
f01003fa:	e8 b0 ff ff ff       	call   f01003af <cons_intr>
}
f01003ff:	c9                   	leave  
f0100400:	c3                   	ret    

f0100401 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100401:	55                   	push   %ebp
f0100402:	89 e5                	mov    %esp,%ebp
f0100404:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100407:	83 3d 40 f3 10 f0 00 	cmpl   $0x0,0xf010f340
f010040e:	74 0c                	je     f010041c <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f0100410:	c7 04 24 98 01 10 f0 	movl   $0xf0100198,(%esp)
f0100417:	e8 93 ff ff ff       	call   f01003af <cons_intr>
}
f010041c:	c9                   	leave  
f010041d:	c3                   	ret    

f010041e <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010041e:	55                   	push   %ebp
f010041f:	89 e5                	mov    %esp,%ebp
f0100421:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100424:	e8 d8 ff ff ff       	call   f0100401 <serial_intr>
	kbd_intr();
f0100429:	e8 bf ff ff ff       	call   f01003ed <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010042e:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100434:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100439:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f010043f:	74 1e                	je     f010045f <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100441:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f0100448:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f010044b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100451:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100456:	0f 44 d1             	cmove  %ecx,%edx
f0100459:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f010045f:	c9                   	leave  
f0100460:	c3                   	ret    

f0100461 <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f0100461:	55                   	push   %ebp
f0100462:	89 e5                	mov    %esp,%ebp
f0100464:	57                   	push   %edi
f0100465:	56                   	push   %esi
f0100466:	53                   	push   %ebx
f0100467:	83 ec 1c             	sub    $0x1c,%esp
f010046a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010046d:	ba 79 03 00 00       	mov    $0x379,%edx
f0100472:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100473:	84 c0                	test   %al,%al
f0100475:	78 21                	js     f0100498 <cons_putc+0x37>
f0100477:	bb 00 32 00 00       	mov    $0x3200,%ebx
f010047c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100481:	be 79 03 00 00       	mov    $0x379,%esi
f0100486:	89 ca                	mov    %ecx,%edx
f0100488:	ec                   	in     (%dx),%al
f0100489:	ec                   	in     (%dx),%al
f010048a:	ec                   	in     (%dx),%al
f010048b:	ec                   	in     (%dx),%al
f010048c:	89 f2                	mov    %esi,%edx
f010048e:	ec                   	in     (%dx),%al
f010048f:	84 c0                	test   %al,%al
f0100491:	78 05                	js     f0100498 <cons_putc+0x37>
f0100493:	83 eb 01             	sub    $0x1,%ebx
f0100496:	75 ee                	jne    f0100486 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100498:	ba 78 03 00 00       	mov    $0x378,%edx
f010049d:	89 f8                	mov    %edi,%eax
f010049f:	ee                   	out    %al,(%dx)
f01004a0:	b2 7a                	mov    $0x7a,%dl
f01004a2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004a7:	ee                   	out    %al,(%dx)
f01004a8:	b8 08 00 00 00       	mov    $0x8,%eax
f01004ad:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f01004ae:	89 3c 24             	mov    %edi,(%esp)
f01004b1:	e8 08 00 00 00       	call   f01004be <cga_putc>
}
f01004b6:	83 c4 1c             	add    $0x1c,%esp
f01004b9:	5b                   	pop    %ebx
f01004ba:	5e                   	pop    %esi
f01004bb:	5f                   	pop    %edi
f01004bc:	5d                   	pop    %ebp
f01004bd:	c3                   	ret    

f01004be <cga_putc>:



void
cga_putc(int c)
{
f01004be:	55                   	push   %ebp
f01004bf:	89 e5                	mov    %esp,%ebp
f01004c1:	56                   	push   %esi
f01004c2:	53                   	push   %ebx
f01004c3:	83 ec 10             	sub    $0x10,%esp
f01004c6:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	// whether are 15-8 bits zero?If they are set 8,9,10 bit 1,If not continue.
	if (!(c & ~0xFF))
f01004c9:	89 c1                	mov    %eax,%ecx
f01004cb:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0a00;
f01004d1:	89 c2                	mov    %eax,%edx
f01004d3:	80 ce 0a             	or     $0xa,%dh
f01004d6:	85 c9                	test   %ecx,%ecx
f01004d8:	0f 44 c2             	cmove  %edx,%eax

	// whether are low 8 bits '\b','\n','\r','\t'?If they are,preform corresponding operation.
	switch (c & 0xff) {
f01004db:	0f b6 d0             	movzbl %al,%edx
f01004de:	83 ea 08             	sub    $0x8,%edx
f01004e1:	83 fa 72             	cmp    $0x72,%edx
f01004e4:	0f 87 67 01 00 00    	ja     f0100651 <cga_putc+0x193>
f01004ea:	ff 24 95 00 18 10 f0 	jmp    *-0xfefe800(,%edx,4)
	case '\b':
		if (crt_pos > 0) {
f01004f1:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f01004f8:	66 85 d2             	test   %dx,%dx
f01004fb:	0f 84 bb 01 00 00    	je     f01006bc <cga_putc+0x1fe>
			crt_pos--;
f0100501:	83 ea 01             	sub    $0x1,%edx
f0100504:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010050b:	0f b7 d2             	movzwl %dx,%edx
f010050e:	b0 00                	mov    $0x0,%al
f0100510:	89 c1                	mov    %eax,%ecx
f0100512:	83 c9 20             	or     $0x20,%ecx
f0100515:	a1 48 f3 10 f0       	mov    0xf010f348,%eax
f010051a:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f010051e:	e9 4c 01 00 00       	jmp    f010066f <cga_putc+0x1b1>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100523:	66 83 05 4c f3 10 f0 	addw   $0x50,0xf010f34c
f010052a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010052b:	0f b7 05 4c f3 10 f0 	movzwl 0xf010f34c,%eax
f0100532:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100538:	c1 e8 16             	shr    $0x16,%eax
f010053b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010053e:	c1 e0 04             	shl    $0x4,%eax
f0100541:	66 a3 4c f3 10 f0    	mov    %ax,0xf010f34c
		break;
f0100547:	e9 23 01 00 00       	jmp    f010066f <cga_putc+0x1b1>
	case '\t':
		cons_putc(' ');
f010054c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100553:	e8 09 ff ff ff       	call   f0100461 <cons_putc>
		cons_putc(' ');
f0100558:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010055f:	e8 fd fe ff ff       	call   f0100461 <cons_putc>
		cons_putc(' ');
f0100564:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010056b:	e8 f1 fe ff ff       	call   f0100461 <cons_putc>
		cons_putc(' ');
f0100570:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100577:	e8 e5 fe ff ff       	call   f0100461 <cons_putc>
		cons_putc(' ');
f010057c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100583:	e8 d9 fe ff ff       	call   f0100461 <cons_putc>
		break;
f0100588:	e9 e2 00 00 00       	jmp    f010066f <cga_putc+0x1b1>
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0c00;
f010058d:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f0100594:	0f b7 da             	movzwl %dx,%ebx
f0100597:	80 e4 f0             	and    $0xf0,%ah
f010059a:	80 cc 0c             	or     $0xc,%ah
f010059d:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f01005a3:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005a7:	83 c2 01             	add    $0x1,%edx
f01005aa:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
		break;
f01005b1:	e9 b9 00 00 00       	jmp    f010066f <cga_putc+0x1b1>
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0900;
f01005b6:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f01005bd:	0f b7 da             	movzwl %dx,%ebx
f01005c0:	80 e4 f0             	and    $0xf0,%ah
f01005c3:	80 cc 09             	or     $0x9,%ah
f01005c6:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f01005cc:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005d0:	83 c2 01             	add    $0x1,%edx
f01005d3:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
		break;
f01005da:	e9 90 00 00 00       	jmp    f010066f <cga_putc+0x1b1>
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0100;
f01005df:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f01005e6:	0f b7 da             	movzwl %dx,%ebx
f01005e9:	80 e4 f0             	and    $0xf0,%ah
f01005ec:	80 cc 01             	or     $0x1,%ah
f01005ef:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f01005f5:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005f9:	83 c2 01             	add    $0x1,%edx
f01005fc:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
		break;
f0100603:	eb 6a                	jmp    f010066f <cga_putc+0x1b1>
	case '%':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0e00;
f0100605:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f010060c:	0f b7 da             	movzwl %dx,%ebx
f010060f:	80 e4 f0             	and    $0xf0,%ah
f0100612:	80 cc 0e             	or     $0xe,%ah
f0100615:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010061b:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010061f:	83 c2 01             	add    $0x1,%edx
f0100622:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
		break;
f0100629:	eb 44                	jmp    f010066f <cga_putc+0x1b1>
	case '&':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0d00;
f010062b:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f0100632:	0f b7 da             	movzwl %dx,%ebx
f0100635:	80 e4 f0             	and    $0xf0,%ah
f0100638:	80 cc 0d             	or     $0xd,%ah
f010063b:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f0100641:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100645:	83 c2 01             	add    $0x1,%edx
f0100648:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
		break;
f010064f:	eb 1e                	jmp    f010066f <cga_putc+0x1b1>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100651:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f0100658:	0f b7 da             	movzwl %dx,%ebx
f010065b:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f0100661:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100665:	83 c2 01             	add    $0x1,%edx
f0100668:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010066f:	66 81 3d 4c f3 10 f0 	cmpw   $0x7cf,0xf010f34c
f0100676:	cf 07 
f0100678:	76 42                	jbe    f01006bc <cga_putc+0x1fe>
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010067a:	a1 48 f3 10 f0       	mov    0xf010f348,%eax
f010067f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100686:	00 
f0100687:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010068d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100691:	89 04 24             	mov    %eax,(%esp)
f0100694:	e8 21 0c 00 00       	call   f01012ba <memmove>
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0c00 | ' ';
f0100699:	8b 15 48 f3 10 f0    	mov    0xf010f348,%edx
	if (crt_pos >= CRT_SIZE) {
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010069f:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0c00 | ' ';
f01006a4:	66 c7 04 42 20 0c    	movw   $0xc20,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) {
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006aa:	83 c0 01             	add    $0x1,%eax
f01006ad:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01006b2:	75 f0                	jne    f01006a4 <cga_putc+0x1e6>
			crt_buf[i] = 0x0c00 | ' ';
		// Fix the position of screen;[Comment out this line and the screen will turn pure black]
		crt_pos -= CRT_COLS;
f01006b4:	66 83 2d 4c f3 10 f0 	subw   $0x50,0xf010f34c
f01006bb:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006bc:	8b 0d 44 f3 10 f0    	mov    0xf010f344,%ecx
f01006c2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c7:	89 ca                	mov    %ecx,%edx
f01006c9:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006ca:	0f b7 35 4c f3 10 f0 	movzwl 0xf010f34c,%esi
f01006d1:	8d 59 01             	lea    0x1(%ecx),%ebx
f01006d4:	89 f0                	mov    %esi,%eax
f01006d6:	66 c1 e8 08          	shr    $0x8,%ax
f01006da:	89 da                	mov    %ebx,%edx
f01006dc:	ee                   	out    %al,(%dx)
f01006dd:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006e2:	89 ca                	mov    %ecx,%edx
f01006e4:	ee                   	out    %al,(%dx)
f01006e5:	89 f0                	mov    %esi,%eax
f01006e7:	89 da                	mov    %ebx,%edx
f01006e9:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f01006ea:	83 c4 10             	add    $0x10,%esp
f01006ed:	5b                   	pop    %ebx
f01006ee:	5e                   	pop    %esi
f01006ef:	5d                   	pop    %ebp
f01006f0:	c3                   	ret    

f01006f1 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006f1:	55                   	push   %ebp
f01006f2:	89 e5                	mov    %esp,%ebp
f01006f4:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f01006f7:	e8 17 fc ff ff       	call   f0100313 <cga_init>
	kbd_init();
	serial_init();
f01006fc:	e8 b3 fb ff ff       	call   f01002b4 <serial_init>

	if (!serial_exists)
f0100701:	83 3d 40 f3 10 f0 00 	cmpl   $0x0,0xf010f340
f0100708:	75 0c                	jne    f0100716 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f010070a:	c7 04 24 d0 17 10 f0 	movl   $0xf01017d0,(%esp)
f0100711:	e8 14 03 00 00       	call   f0100a2a <cprintf>
}
f0100716:	c9                   	leave  
f0100717:	c3                   	ret    

f0100718 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100718:	55                   	push   %ebp
f0100719:	89 e5                	mov    %esp,%ebp
f010071b:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f010071e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100721:	89 04 24             	mov    %eax,(%esp)
f0100724:	e8 38 fd ff ff       	call   f0100461 <cons_putc>
}
f0100729:	c9                   	leave  
f010072a:	c3                   	ret    

f010072b <getchar>:

int
getchar(void)
{
f010072b:	55                   	push   %ebp
f010072c:	89 e5                	mov    %esp,%ebp
f010072e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100731:	e8 e8 fc ff ff       	call   f010041e <cons_getc>
f0100736:	85 c0                	test   %eax,%eax
f0100738:	74 f7                	je     f0100731 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010073a:	c9                   	leave  
f010073b:	c3                   	ret    

f010073c <iscons>:

int
iscons(int fdnum)
{
f010073c:	55                   	push   %ebp
f010073d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010073f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100744:	5d                   	pop    %ebp
f0100745:	c3                   	ret    
	...

f0100750 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100750:	55                   	push   %ebp
f0100751:	89 e5                	mov    %esp,%ebp
f0100753:	56                   	push   %esi
f0100754:	53                   	push   %ebx
f0100755:	83 ec 20             	sub    $0x20,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100758:	89 eb                	mov    %ebp,%ebx
f010075a:	89 de                	mov    %ebx,%esi
	// Your code here.
	unsigned int ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f010075c:	c7 04 24 f0 1b 10 f0 	movl   $0xf0101bf0,(%esp)
f0100763:	e8 c2 02 00 00       	call   f0100a2a <cprintf>
	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f0100768:	85 db                	test   %ebx,%ebx
f010076a:	74 39                	je     f01007a5 <mon_backtrace+0x55>
	{
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
f010076c:	8b 46 14             	mov    0x14(%esi),%eax
f010076f:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100773:	8b 46 10             	mov    0x10(%esi),%eax
f0100776:	89 44 24 14          	mov    %eax,0x14(%esp)
f010077a:	8b 46 0c             	mov    0xc(%esi),%eax
f010077d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100781:	8b 46 08             	mov    0x8(%esi),%eax
f0100784:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100788:	8b 46 04             	mov    0x4(%esi),%eax
f010078b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010078f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100793:	c7 04 24 98 1c 10 f0 	movl   $0xf0101c98,(%esp)
f010079a:	e8 8b 02 00 00       	call   f0100a2a <cprintf>
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		ebp = *(unsigned int *)ebp;
f010079f:	8b 36                	mov    (%esi),%esi
{
	// Your code here.
	unsigned int ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f01007a1:	85 f6                	test   %esi,%esi
f01007a3:	75 c7                	jne    f010076c <mon_backtrace+0x1c>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		ebp = *(unsigned int *)ebp;
	}
	return 0;
}
f01007a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007aa:	83 c4 20             	add    $0x20,%esp
f01007ad:	5b                   	pop    %ebx
f01007ae:	5e                   	pop    %esi
f01007af:	5d                   	pop    %ebp
f01007b0:	c3                   	ret    

f01007b1 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b1:	55                   	push   %ebp
f01007b2:	89 e5                	mov    %esp,%ebp
f01007b4:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b7:	c7 04 24 02 1c 10 f0 	movl   $0xf0101c02,(%esp)
f01007be:	e8 67 02 00 00       	call   f0100a2a <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01007c3:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007ca:	00 
f01007cb:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007d2:	f0 
f01007d3:	c7 04 24 c8 1c 10 f0 	movl   $0xf0101cc8,(%esp)
f01007da:	e8 4b 02 00 00       	call   f0100a2a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007df:	c7 44 24 08 35 17 10 	movl   $0x101735,0x8(%esp)
f01007e6:	00 
f01007e7:	c7 44 24 04 35 17 10 	movl   $0xf0101735,0x4(%esp)
f01007ee:	f0 
f01007ef:	c7 04 24 ec 1c 10 f0 	movl   $0xf0101cec,(%esp)
f01007f6:	e8 2f 02 00 00       	call   f0100a2a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007fb:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f0100802:	00 
f0100803:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f010080a:	f0 
f010080b:	c7 04 24 10 1d 10 f0 	movl   $0xf0101d10,(%esp)
f0100812:	e8 13 02 00 00       	call   f0100a2a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100817:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f010081e:	00 
f010081f:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f0100826:	f0 
f0100827:	c7 04 24 34 1d 10 f0 	movl   $0xf0101d34,(%esp)
f010082e:	e8 f7 01 00 00       	call   f0100a2a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f0100833:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f0100838:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010083d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100843:	85 c0                	test   %eax,%eax
f0100845:	0f 48 c2             	cmovs  %edx,%eax
f0100848:	c1 f8 0a             	sar    $0xa,%eax
f010084b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010084f:	c7 04 24 58 1d 10 f0 	movl   $0xf0101d58,(%esp)
f0100856:	e8 cf 01 00 00       	call   f0100a2a <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010085b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100860:	c9                   	leave  
f0100861:	c3                   	ret    

f0100862 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100862:	55                   	push   %ebp
f0100863:	89 e5                	mov    %esp,%ebp
f0100865:	53                   	push   %ebx
f0100866:	83 ec 14             	sub    $0x14,%esp
f0100869:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010086e:	8b 83 24 1e 10 f0    	mov    -0xfefe1dc(%ebx),%eax
f0100874:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100878:	8b 83 20 1e 10 f0    	mov    -0xfefe1e0(%ebx),%eax
f010087e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100882:	c7 04 24 1b 1c 10 f0 	movl   $0xf0101c1b,(%esp)
f0100889:	e8 9c 01 00 00       	call   f0100a2a <cprintf>
f010088e:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100891:	83 fb 24             	cmp    $0x24,%ebx
f0100894:	75 d8                	jne    f010086e <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100896:	b8 00 00 00 00       	mov    $0x0,%eax
f010089b:	83 c4 14             	add    $0x14,%esp
f010089e:	5b                   	pop    %ebx
f010089f:	5d                   	pop    %ebp
f01008a0:	c3                   	ret    

f01008a1 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008a1:	55                   	push   %ebp
f01008a2:	89 e5                	mov    %esp,%ebp
f01008a4:	57                   	push   %edi
f01008a5:	56                   	push   %esi
f01008a6:	53                   	push   %ebx
f01008a7:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008aa:	c7 04 24 84 1d 10 f0 	movl   $0xf0101d84,(%esp)
f01008b1:	e8 74 01 00 00       	call   f0100a2a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008b6:	c7 04 24 a8 1d 10 f0 	movl   $0xf0101da8,(%esp)
f01008bd:	e8 68 01 00 00       	call   f0100a2a <cprintf>


	while (1) {
		buf = readline("K> ");
f01008c2:	c7 04 24 24 1c 10 f0 	movl   $0xf0101c24,(%esp)
f01008c9:	e8 52 07 00 00       	call   f0101020 <readline>
f01008ce:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008d0:	85 c0                	test   %eax,%eax
f01008d2:	74 ee                	je     f01008c2 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008d4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008db:	be 00 00 00 00       	mov    $0x0,%esi
f01008e0:	eb 06                	jmp    f01008e8 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008e2:	c6 03 00             	movb   $0x0,(%ebx)
f01008e5:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008e8:	0f b6 03             	movzbl (%ebx),%eax
f01008eb:	84 c0                	test   %al,%al
f01008ed:	74 6c                	je     f010095b <monitor+0xba>
f01008ef:	0f be c0             	movsbl %al,%eax
f01008f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f6:	c7 04 24 28 1c 10 f0 	movl   $0xf0101c28,(%esp)
f01008fd:	e8 39 09 00 00       	call   f010123b <strchr>
f0100902:	85 c0                	test   %eax,%eax
f0100904:	75 dc                	jne    f01008e2 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100906:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100909:	74 50                	je     f010095b <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010090b:	83 fe 0f             	cmp    $0xf,%esi
f010090e:	66 90                	xchg   %ax,%ax
f0100910:	75 16                	jne    f0100928 <monitor+0x87>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100912:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100919:	00 
f010091a:	c7 04 24 2d 1c 10 f0 	movl   $0xf0101c2d,(%esp)
f0100921:	e8 04 01 00 00       	call   f0100a2a <cprintf>
f0100926:	eb 9a                	jmp    f01008c2 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100928:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010092c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010092f:	0f b6 03             	movzbl (%ebx),%eax
f0100932:	84 c0                	test   %al,%al
f0100934:	75 0c                	jne    f0100942 <monitor+0xa1>
f0100936:	eb b0                	jmp    f01008e8 <monitor+0x47>
			buf++;
f0100938:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010093b:	0f b6 03             	movzbl (%ebx),%eax
f010093e:	84 c0                	test   %al,%al
f0100940:	74 a6                	je     f01008e8 <monitor+0x47>
f0100942:	0f be c0             	movsbl %al,%eax
f0100945:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100949:	c7 04 24 28 1c 10 f0 	movl   $0xf0101c28,(%esp)
f0100950:	e8 e6 08 00 00       	call   f010123b <strchr>
f0100955:	85 c0                	test   %eax,%eax
f0100957:	74 df                	je     f0100938 <monitor+0x97>
f0100959:	eb 8d                	jmp    f01008e8 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f010095b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100962:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100963:	85 f6                	test   %esi,%esi
f0100965:	0f 84 57 ff ff ff    	je     f01008c2 <monitor+0x21>
f010096b:	bb 20 1e 10 f0       	mov    $0xf0101e20,%ebx
f0100970:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100975:	8b 03                	mov    (%ebx),%eax
f0100977:	89 44 24 04          	mov    %eax,0x4(%esp)
f010097b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010097e:	89 04 24             	mov    %eax,(%esp)
f0100981:	e8 3a 08 00 00       	call   f01011c0 <strcmp>
f0100986:	85 c0                	test   %eax,%eax
f0100988:	75 24                	jne    f01009ae <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f010098a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010098d:	8b 55 08             	mov    0x8(%ebp),%edx
f0100990:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100994:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100997:	89 54 24 04          	mov    %edx,0x4(%esp)
f010099b:	89 34 24             	mov    %esi,(%esp)
f010099e:	ff 14 85 28 1e 10 f0 	call   *-0xfefe1d8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009a5:	85 c0                	test   %eax,%eax
f01009a7:	78 28                	js     f01009d1 <monitor+0x130>
f01009a9:	e9 14 ff ff ff       	jmp    f01008c2 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009ae:	83 c7 01             	add    $0x1,%edi
f01009b1:	83 c3 0c             	add    $0xc,%ebx
f01009b4:	83 ff 03             	cmp    $0x3,%edi
f01009b7:	75 bc                	jne    f0100975 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009b9:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009c0:	c7 04 24 4a 1c 10 f0 	movl   $0xf0101c4a,(%esp)
f01009c7:	e8 5e 00 00 00       	call   f0100a2a <cprintf>
f01009cc:	e9 f1 fe ff ff       	jmp    f01008c2 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009d1:	83 c4 5c             	add    $0x5c,%esp
f01009d4:	5b                   	pop    %ebx
f01009d5:	5e                   	pop    %esi
f01009d6:	5f                   	pop    %edi
f01009d7:	5d                   	pop    %ebp
f01009d8:	c3                   	ret    

f01009d9 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01009d9:	55                   	push   %ebp
f01009da:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01009dc:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01009df:	5d                   	pop    %ebp
f01009e0:	c3                   	ret    
f01009e1:	00 00                	add    %al,(%eax)
	...

f01009e4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009e4:	55                   	push   %ebp
f01009e5:	89 e5                	mov    %esp,%ebp
f01009e7:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01009ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01009ed:	89 04 24             	mov    %eax,(%esp)
f01009f0:	e8 23 fd ff ff       	call   f0100718 <cputchar>
	*cnt++;
}
f01009f5:	c9                   	leave  
f01009f6:	c3                   	ret    

f01009f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009f7:	55                   	push   %ebp
f01009f8:	89 e5                	mov    %esp,%ebp
f01009fa:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01009fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a04:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a07:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a0e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a12:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a15:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a19:	c7 04 24 e4 09 10 f0 	movl   $0xf01009e4,(%esp)
f0100a20:	e8 bf 01 00 00       	call   f0100be4 <vprintfmt>
	return cnt;
}
f0100a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a28:	c9                   	leave  
f0100a29:	c3                   	ret    

f0100a2a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a2a:	55                   	push   %ebp
f0100a2b:	89 e5                	mov    %esp,%ebp
f0100a2d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100a30:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100a33:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a37:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a3a:	89 04 24             	mov    %eax,(%esp)
f0100a3d:	e8 b5 ff ff ff       	call   f01009f7 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a42:	c9                   	leave  
f0100a43:	c3                   	ret    
	...

f0100a50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100a50:	55                   	push   %ebp
f0100a51:	89 e5                	mov    %esp,%ebp
f0100a53:	57                   	push   %edi
f0100a54:	56                   	push   %esi
f0100a55:	53                   	push   %ebx
f0100a56:	83 ec 3c             	sub    $0x3c,%esp
f0100a59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100a5c:	89 d7                	mov    %edx,%edi
f0100a5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a61:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100a64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a67:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100a6a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100a6d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100a70:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a75:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100a78:	72 11                	jb     f0100a8b <printnum+0x3b>
f0100a7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a7d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100a80:	76 09                	jbe    f0100a8b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a82:	83 eb 01             	sub    $0x1,%ebx
f0100a85:	85 db                	test   %ebx,%ebx
f0100a87:	7f 51                	jg     f0100ada <printnum+0x8a>
f0100a89:	eb 5e                	jmp    f0100ae9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100a8b:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100a8f:	83 eb 01             	sub    $0x1,%ebx
f0100a92:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a96:	8b 45 10             	mov    0x10(%ebp),%eax
f0100a99:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a9d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100aa1:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100aa5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100aac:	00 
f0100aad:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ab0:	89 04 24             	mov    %eax,(%esp)
f0100ab3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aba:	e8 d1 09 00 00       	call   f0101490 <__udivdi3>
f0100abf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100ac3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100ac7:	89 04 24             	mov    %eax,(%esp)
f0100aca:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ace:	89 fa                	mov    %edi,%edx
f0100ad0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ad3:	e8 78 ff ff ff       	call   f0100a50 <printnum>
f0100ad8:	eb 0f                	jmp    f0100ae9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100ada:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ade:	89 34 24             	mov    %esi,(%esp)
f0100ae1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100ae4:	83 eb 01             	sub    $0x1,%ebx
f0100ae7:	75 f1                	jne    f0100ada <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ae9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100aed:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100af1:	8b 45 10             	mov    0x10(%ebp),%eax
f0100af4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100af8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100aff:	00 
f0100b00:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b03:	89 04 24             	mov    %eax,(%esp)
f0100b06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b0d:	e8 ae 0a 00 00       	call   f01015c0 <__umoddi3>
f0100b12:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100b16:	0f be 80 44 1e 10 f0 	movsbl -0xfefe1bc(%eax),%eax
f0100b1d:	89 04 24             	mov    %eax,(%esp)
f0100b20:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100b23:	83 c4 3c             	add    $0x3c,%esp
f0100b26:	5b                   	pop    %ebx
f0100b27:	5e                   	pop    %esi
f0100b28:	5f                   	pop    %edi
f0100b29:	5d                   	pop    %ebp
f0100b2a:	c3                   	ret    

f0100b2b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100b2b:	55                   	push   %ebp
f0100b2c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100b2e:	83 fa 01             	cmp    $0x1,%edx
f0100b31:	7e 0e                	jle    f0100b41 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100b33:	8b 10                	mov    (%eax),%edx
f0100b35:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100b38:	89 08                	mov    %ecx,(%eax)
f0100b3a:	8b 02                	mov    (%edx),%eax
f0100b3c:	8b 52 04             	mov    0x4(%edx),%edx
f0100b3f:	eb 22                	jmp    f0100b63 <getuint+0x38>
	else if (lflag)
f0100b41:	85 d2                	test   %edx,%edx
f0100b43:	74 10                	je     f0100b55 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100b45:	8b 10                	mov    (%eax),%edx
f0100b47:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100b4a:	89 08                	mov    %ecx,(%eax)
f0100b4c:	8b 02                	mov    (%edx),%eax
f0100b4e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100b53:	eb 0e                	jmp    f0100b63 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100b55:	8b 10                	mov    (%eax),%edx
f0100b57:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100b5a:	89 08                	mov    %ecx,(%eax)
f0100b5c:	8b 02                	mov    (%edx),%eax
f0100b5e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100b63:	5d                   	pop    %ebp
f0100b64:	c3                   	ret    

f0100b65 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0100b65:	55                   	push   %ebp
f0100b66:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100b68:	83 fa 01             	cmp    $0x1,%edx
f0100b6b:	7e 0e                	jle    f0100b7b <getint+0x16>
		return va_arg(*ap, long long);
f0100b6d:	8b 10                	mov    (%eax),%edx
f0100b6f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100b72:	89 08                	mov    %ecx,(%eax)
f0100b74:	8b 02                	mov    (%edx),%eax
f0100b76:	8b 52 04             	mov    0x4(%edx),%edx
f0100b79:	eb 22                	jmp    f0100b9d <getint+0x38>
	else if (lflag)
f0100b7b:	85 d2                	test   %edx,%edx
f0100b7d:	74 10                	je     f0100b8f <getint+0x2a>
		return va_arg(*ap, long);
f0100b7f:	8b 10                	mov    (%eax),%edx
f0100b81:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100b84:	89 08                	mov    %ecx,(%eax)
f0100b86:	8b 02                	mov    (%edx),%eax
f0100b88:	89 c2                	mov    %eax,%edx
f0100b8a:	c1 fa 1f             	sar    $0x1f,%edx
f0100b8d:	eb 0e                	jmp    f0100b9d <getint+0x38>
	else
		return va_arg(*ap, int);
f0100b8f:	8b 10                	mov    (%eax),%edx
f0100b91:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100b94:	89 08                	mov    %ecx,(%eax)
f0100b96:	8b 02                	mov    (%edx),%eax
f0100b98:	89 c2                	mov    %eax,%edx
f0100b9a:	c1 fa 1f             	sar    $0x1f,%edx
}
f0100b9d:	5d                   	pop    %ebp
f0100b9e:	c3                   	ret    

f0100b9f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100b9f:	55                   	push   %ebp
f0100ba0:	89 e5                	mov    %esp,%ebp
f0100ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ba5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ba9:	8b 10                	mov    (%eax),%edx
f0100bab:	3b 50 04             	cmp    0x4(%eax),%edx
f0100bae:	73 0a                	jae    f0100bba <sprintputch+0x1b>
		*b->buf++ = ch;
f0100bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100bb3:	88 0a                	mov    %cl,(%edx)
f0100bb5:	83 c2 01             	add    $0x1,%edx
f0100bb8:	89 10                	mov    %edx,(%eax)
}
f0100bba:	5d                   	pop    %ebp
f0100bbb:	c3                   	ret    

f0100bbc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100bbc:	55                   	push   %ebp
f0100bbd:	89 e5                	mov    %esp,%ebp
f0100bbf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100bc2:	8d 45 14             	lea    0x14(%ebp),%eax
f0100bc5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bc9:	8b 45 10             	mov    0x10(%ebp),%eax
f0100bcc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bd0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bd3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bd7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bda:	89 04 24             	mov    %eax,(%esp)
f0100bdd:	e8 02 00 00 00       	call   f0100be4 <vprintfmt>
	va_end(ap);
}
f0100be2:	c9                   	leave  
f0100be3:	c3                   	ret    

f0100be4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100be4:	55                   	push   %ebp
f0100be5:	89 e5                	mov    %esp,%ebp
f0100be7:	57                   	push   %edi
f0100be8:	56                   	push   %esi
f0100be9:	53                   	push   %ebx
f0100bea:	83 ec 4c             	sub    $0x4c,%esp
f0100bed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100bf0:	8b 75 10             	mov    0x10(%ebp),%esi
f0100bf3:	eb 12                	jmp    f0100c07 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100bf5:	85 c0                	test   %eax,%eax
f0100bf7:	0f 84 98 03 00 00    	je     f0100f95 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f0100bfd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c01:	89 04 24             	mov    %eax,(%esp)
f0100c04:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100c07:	0f b6 06             	movzbl (%esi),%eax
f0100c0a:	83 c6 01             	add    $0x1,%esi
f0100c0d:	83 f8 25             	cmp    $0x25,%eax
f0100c10:	75 e3                	jne    f0100bf5 <vprintfmt+0x11>
f0100c12:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100c16:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100c1d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100c22:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100c29:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c2e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100c31:	eb 2b                	jmp    f0100c5e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100c33:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100c36:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100c3a:	eb 22                	jmp    f0100c5e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100c3c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100c3f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100c43:	eb 19                	jmp    f0100c5e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100c45:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100c48:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100c4f:	eb 0d                	jmp    f0100c5e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100c51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c57:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100c5e:	0f b6 06             	movzbl (%esi),%eax
f0100c61:	0f b6 d0             	movzbl %al,%edx
f0100c64:	8d 7e 01             	lea    0x1(%esi),%edi
f0100c67:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100c6a:	83 e8 23             	sub    $0x23,%eax
f0100c6d:	3c 55                	cmp    $0x55,%al
f0100c6f:	0f 87 fa 02 00 00    	ja     f0100f6f <vprintfmt+0x38b>
f0100c75:	0f b6 c0             	movzbl %al,%eax
f0100c78:	ff 24 85 d4 1e 10 f0 	jmp    *-0xfefe12c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100c7f:	83 ea 30             	sub    $0x30,%edx
f0100c82:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0100c85:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0100c89:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100c8c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0100c8f:	83 fa 09             	cmp    $0x9,%edx
f0100c92:	77 4a                	ja     f0100cde <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100c94:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100c97:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0100c9a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0100c9d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0100ca1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100ca4:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100ca7:	83 fa 09             	cmp    $0x9,%edx
f0100caa:	76 eb                	jbe    f0100c97 <vprintfmt+0xb3>
f0100cac:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100caf:	eb 2d                	jmp    f0100cde <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100cb1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cb4:	8d 50 04             	lea    0x4(%eax),%edx
f0100cb7:	89 55 14             	mov    %edx,0x14(%ebp)
f0100cba:	8b 00                	mov    (%eax),%eax
f0100cbc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100cbf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100cc2:	eb 1a                	jmp    f0100cde <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100cc4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0100cc7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ccb:	79 91                	jns    f0100c5e <vprintfmt+0x7a>
f0100ccd:	e9 73 ff ff ff       	jmp    f0100c45 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100cd2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100cd5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0100cdc:	eb 80                	jmp    f0100c5e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0100cde:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ce2:	0f 89 76 ff ff ff    	jns    f0100c5e <vprintfmt+0x7a>
f0100ce8:	e9 64 ff ff ff       	jmp    f0100c51 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ced:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100cf0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100cf3:	e9 66 ff ff ff       	jmp    f0100c5e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100cf8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cfb:	8d 50 04             	lea    0x4(%eax),%edx
f0100cfe:	89 55 14             	mov    %edx,0x14(%ebp)
f0100d01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d05:	8b 00                	mov    (%eax),%eax
f0100d07:	89 04 24             	mov    %eax,(%esp)
f0100d0a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d0d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100d10:	e9 f2 fe ff ff       	jmp    f0100c07 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100d15:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d18:	8d 50 04             	lea    0x4(%eax),%edx
f0100d1b:	89 55 14             	mov    %edx,0x14(%ebp)
f0100d1e:	8b 00                	mov    (%eax),%eax
f0100d20:	89 c2                	mov    %eax,%edx
f0100d22:	c1 fa 1f             	sar    $0x1f,%edx
f0100d25:	31 d0                	xor    %edx,%eax
f0100d27:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100d29:	83 f8 06             	cmp    $0x6,%eax
f0100d2c:	7f 0b                	jg     f0100d39 <vprintfmt+0x155>
f0100d2e:	8b 14 85 2c 20 10 f0 	mov    -0xfefdfd4(,%eax,4),%edx
f0100d35:	85 d2                	test   %edx,%edx
f0100d37:	75 23                	jne    f0100d5c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0100d39:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d3d:	c7 44 24 08 5c 1e 10 	movl   $0xf0101e5c,0x8(%esp)
f0100d44:	f0 
f0100d45:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d49:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100d4c:	89 3c 24             	mov    %edi,(%esp)
f0100d4f:	e8 68 fe ff ff       	call   f0100bbc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d54:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100d57:	e9 ab fe ff ff       	jmp    f0100c07 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0100d5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d60:	c7 44 24 08 65 1e 10 	movl   $0xf0101e65,0x8(%esp)
f0100d67:	f0 
f0100d68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d6c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100d6f:	89 3c 24             	mov    %edi,(%esp)
f0100d72:	e8 45 fe ff ff       	call   f0100bbc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d77:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100d7a:	e9 88 fe ff ff       	jmp    f0100c07 <vprintfmt+0x23>
f0100d7f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d85:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100d88:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d8b:	8d 50 04             	lea    0x4(%eax),%edx
f0100d8e:	89 55 14             	mov    %edx,0x14(%ebp)
f0100d91:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0100d93:	85 f6                	test   %esi,%esi
f0100d95:	ba 55 1e 10 f0       	mov    $0xf0101e55,%edx
f0100d9a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0100d9d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100da1:	7e 06                	jle    f0100da9 <vprintfmt+0x1c5>
f0100da3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0100da7:	75 10                	jne    f0100db9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100da9:	0f be 06             	movsbl (%esi),%eax
f0100dac:	83 c6 01             	add    $0x1,%esi
f0100daf:	85 c0                	test   %eax,%eax
f0100db1:	0f 85 86 00 00 00    	jne    f0100e3d <vprintfmt+0x259>
f0100db7:	eb 76                	jmp    f0100e2f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100db9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100dbd:	89 34 24             	mov    %esi,(%esp)
f0100dc0:	e8 36 03 00 00       	call   f01010fb <strnlen>
f0100dc5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100dc8:	29 c2                	sub    %eax,%edx
f0100dca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100dcd:	85 d2                	test   %edx,%edx
f0100dcf:	7e d8                	jle    f0100da9 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0100dd1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0100dd5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100dd8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0100ddb:	89 d6                	mov    %edx,%esi
f0100ddd:	89 c7                	mov    %eax,%edi
f0100ddf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100de3:	89 3c 24             	mov    %edi,(%esp)
f0100de6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100de9:	83 ee 01             	sub    $0x1,%esi
f0100dec:	75 f1                	jne    f0100ddf <vprintfmt+0x1fb>
f0100dee:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0100df1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0100df4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100df7:	eb b0                	jmp    f0100da9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100df9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100dfd:	74 18                	je     f0100e17 <vprintfmt+0x233>
f0100dff:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100e02:	83 fa 5e             	cmp    $0x5e,%edx
f0100e05:	76 10                	jbe    f0100e17 <vprintfmt+0x233>
					putch('?', putdat);
f0100e07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e0b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100e12:	ff 55 08             	call   *0x8(%ebp)
f0100e15:	eb 0a                	jmp    f0100e21 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f0100e17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e1b:	89 04 24             	mov    %eax,(%esp)
f0100e1e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100e21:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100e25:	0f be 06             	movsbl (%esi),%eax
f0100e28:	83 c6 01             	add    $0x1,%esi
f0100e2b:	85 c0                	test   %eax,%eax
f0100e2d:	75 0e                	jne    f0100e3d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e2f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100e32:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e36:	7f 11                	jg     f0100e49 <vprintfmt+0x265>
f0100e38:	e9 ca fd ff ff       	jmp    f0100c07 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100e3d:	85 ff                	test   %edi,%edi
f0100e3f:	90                   	nop
f0100e40:	78 b7                	js     f0100df9 <vprintfmt+0x215>
f0100e42:	83 ef 01             	sub    $0x1,%edi
f0100e45:	79 b2                	jns    f0100df9 <vprintfmt+0x215>
f0100e47:	eb e6                	jmp    f0100e2f <vprintfmt+0x24b>
f0100e49:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100e4c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100e4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e53:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100e5a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100e5c:	83 ee 01             	sub    $0x1,%esi
f0100e5f:	75 ee                	jne    f0100e4f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e61:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100e64:	e9 9e fd ff ff       	jmp    f0100c07 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100e69:	89 ca                	mov    %ecx,%edx
f0100e6b:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e6e:	e8 f2 fc ff ff       	call   f0100b65 <getint>
f0100e73:	89 c6                	mov    %eax,%esi
f0100e75:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0100e77:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0100e7c:	85 d2                	test   %edx,%edx
f0100e7e:	0f 89 ad 00 00 00    	jns    f0100f31 <vprintfmt+0x34d>
				putch('-', putdat);
f0100e84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e88:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100e8f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0100e92:	f7 de                	neg    %esi
f0100e94:	83 d7 00             	adc    $0x0,%edi
f0100e97:	f7 df                	neg    %edi
			}
			base = 10;
f0100e99:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100e9e:	e9 8e 00 00 00       	jmp    f0100f31 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100ea3:	89 ca                	mov    %ecx,%edx
f0100ea5:	8d 45 14             	lea    0x14(%ebp),%eax
f0100ea8:	e8 7e fc ff ff       	call   f0100b2b <getuint>
f0100ead:	89 c6                	mov    %eax,%esi
f0100eaf:	89 d7                	mov    %edx,%edi
			base = 10;
f0100eb1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0100eb6:	eb 79                	jmp    f0100f31 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f0100eb8:	89 ca                	mov    %ecx,%edx
f0100eba:	8d 45 14             	lea    0x14(%ebp),%eax
f0100ebd:	e8 a3 fc ff ff       	call   f0100b65 <getint>
f0100ec2:	89 c6                	mov    %eax,%esi
f0100ec4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f0100ec6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0100ecb:	85 d2                	test   %edx,%edx
f0100ecd:	79 62                	jns    f0100f31 <vprintfmt+0x34d>
				putch('-', putdat);
f0100ecf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ed3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100eda:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0100edd:	f7 de                	neg    %esi
f0100edf:	83 d7 00             	adc    $0x0,%edi
f0100ee2:	f7 df                	neg    %edi
			}
			base = 8;
f0100ee4:	b8 08 00 00 00       	mov    $0x8,%eax
f0100ee9:	eb 46                	jmp    f0100f31 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f0100eeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100eef:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100ef6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0100ef9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100efd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100f04:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100f07:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f0a:	8d 50 04             	lea    0x4(%eax),%edx
f0100f0d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100f10:	8b 30                	mov    (%eax),%esi
f0100f12:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0100f17:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0100f1c:	eb 13                	jmp    f0100f31 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100f1e:	89 ca                	mov    %ecx,%edx
f0100f20:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f23:	e8 03 fc ff ff       	call   f0100b2b <getuint>
f0100f28:	89 c6                	mov    %eax,%esi
f0100f2a:	89 d7                	mov    %edx,%edi
			base = 16;
f0100f2c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100f31:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0100f35:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100f39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f3c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f40:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f44:	89 34 24             	mov    %esi,(%esp)
f0100f47:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f4b:	89 da                	mov    %ebx,%edx
f0100f4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f50:	e8 fb fa ff ff       	call   f0100a50 <printnum>
			break;
f0100f55:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100f58:	e9 aa fc ff ff       	jmp    f0100c07 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100f5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f61:	89 14 24             	mov    %edx,(%esp)
f0100f64:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f67:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0100f6a:	e9 98 fc ff ff       	jmp    f0100c07 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100f6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f73:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100f7a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100f7d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0100f81:	0f 84 80 fc ff ff    	je     f0100c07 <vprintfmt+0x23>
f0100f87:	83 ee 01             	sub    $0x1,%esi
f0100f8a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0100f8e:	75 f7                	jne    f0100f87 <vprintfmt+0x3a3>
f0100f90:	e9 72 fc ff ff       	jmp    f0100c07 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0100f95:	83 c4 4c             	add    $0x4c,%esp
f0100f98:	5b                   	pop    %ebx
f0100f99:	5e                   	pop    %esi
f0100f9a:	5f                   	pop    %edi
f0100f9b:	5d                   	pop    %ebp
f0100f9c:	c3                   	ret    

f0100f9d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100f9d:	55                   	push   %ebp
f0100f9e:	89 e5                	mov    %esp,%ebp
f0100fa0:	83 ec 28             	sub    $0x28,%esp
f0100fa3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100fa9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100fac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0100fb0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0100fb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0100fba:	85 c0                	test   %eax,%eax
f0100fbc:	74 30                	je     f0100fee <vsnprintf+0x51>
f0100fbe:	85 d2                	test   %edx,%edx
f0100fc0:	7e 2c                	jle    f0100fee <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100fc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fc5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fc9:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fcc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fd0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fd7:	c7 04 24 9f 0b 10 f0 	movl   $0xf0100b9f,(%esp)
f0100fde:	e8 01 fc ff ff       	call   f0100be4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100fe6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fec:	eb 05                	jmp    f0100ff3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0100fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0100ff3:	c9                   	leave  
f0100ff4:	c3                   	ret    

f0100ff5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100ff5:	55                   	push   %ebp
f0100ff6:	89 e5                	mov    %esp,%ebp
f0100ff8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100ffb:	8d 45 14             	lea    0x14(%ebp),%eax
f0100ffe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101002:	8b 45 10             	mov    0x10(%ebp),%eax
f0101005:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101009:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101010:	8b 45 08             	mov    0x8(%ebp),%eax
f0101013:	89 04 24             	mov    %eax,(%esp)
f0101016:	e8 82 ff ff ff       	call   f0100f9d <vsnprintf>
	va_end(ap);

	return rc;
}
f010101b:	c9                   	leave  
f010101c:	c3                   	ret    
f010101d:	00 00                	add    %al,(%eax)
	...

f0101020 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101020:	55                   	push   %ebp
f0101021:	89 e5                	mov    %esp,%ebp
f0101023:	57                   	push   %edi
f0101024:	56                   	push   %esi
f0101025:	53                   	push   %ebx
f0101026:	83 ec 1c             	sub    $0x1c,%esp
f0101029:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010102c:	85 c0                	test   %eax,%eax
f010102e:	74 10                	je     f0101040 <readline+0x20>
		cprintf("%s", prompt);
f0101030:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101034:	c7 04 24 65 1e 10 f0 	movl   $0xf0101e65,(%esp)
f010103b:	e8 ea f9 ff ff       	call   f0100a2a <cprintf>

	i = 0;
	echoing = iscons(0);
f0101040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101047:	e8 f0 f6 ff ff       	call   f010073c <iscons>
f010104c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010104e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101053:	e8 d3 f6 ff ff       	call   f010072b <getchar>
f0101058:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010105a:	85 c0                	test   %eax,%eax
f010105c:	79 17                	jns    f0101075 <readline+0x55>
			cprintf("read error: %e\n", c);
f010105e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101062:	c7 04 24 48 20 10 f0 	movl   $0xf0102048,(%esp)
f0101069:	e8 bc f9 ff ff       	call   f0100a2a <cprintf>
			return NULL;
f010106e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101073:	eb 61                	jmp    f01010d6 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101075:	83 f8 1f             	cmp    $0x1f,%eax
f0101078:	7e 1f                	jle    f0101099 <readline+0x79>
f010107a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101080:	7f 17                	jg     f0101099 <readline+0x79>
			if (echoing)
f0101082:	85 ff                	test   %edi,%edi
f0101084:	74 08                	je     f010108e <readline+0x6e>
				cputchar(c);
f0101086:	89 04 24             	mov    %eax,(%esp)
f0101089:	e8 8a f6 ff ff       	call   f0100718 <cputchar>
			buf[i++] = c;
f010108e:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0101094:	83 c6 01             	add    $0x1,%esi
f0101097:	eb ba                	jmp    f0101053 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101099:	83 fb 08             	cmp    $0x8,%ebx
f010109c:	75 15                	jne    f01010b3 <readline+0x93>
f010109e:	85 f6                	test   %esi,%esi
f01010a0:	7e 11                	jle    f01010b3 <readline+0x93>
			if (echoing)
f01010a2:	85 ff                	test   %edi,%edi
f01010a4:	74 08                	je     f01010ae <readline+0x8e>
				cputchar(c);
f01010a6:	89 1c 24             	mov    %ebx,(%esp)
f01010a9:	e8 6a f6 ff ff       	call   f0100718 <cputchar>
			i--;
f01010ae:	83 ee 01             	sub    $0x1,%esi
f01010b1:	eb a0                	jmp    f0101053 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01010b3:	83 fb 0a             	cmp    $0xa,%ebx
f01010b6:	74 05                	je     f01010bd <readline+0x9d>
f01010b8:	83 fb 0d             	cmp    $0xd,%ebx
f01010bb:	75 96                	jne    f0101053 <readline+0x33>
			if (echoing)
f01010bd:	85 ff                	test   %edi,%edi
f01010bf:	90                   	nop
f01010c0:	74 08                	je     f01010ca <readline+0xaa>
				cputchar(c);
f01010c2:	89 1c 24             	mov    %ebx,(%esp)
f01010c5:	e8 4e f6 ff ff       	call   f0100718 <cputchar>
			buf[i] = 0;
f01010ca:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
			return buf;
f01010d1:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
		}
	}
}
f01010d6:	83 c4 1c             	add    $0x1c,%esp
f01010d9:	5b                   	pop    %ebx
f01010da:	5e                   	pop    %esi
f01010db:	5f                   	pop    %edi
f01010dc:	5d                   	pop    %ebp
f01010dd:	c3                   	ret    
	...

f01010e0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01010e0:	55                   	push   %ebp
f01010e1:	89 e5                	mov    %esp,%ebp
f01010e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01010e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010eb:	80 3a 00             	cmpb   $0x0,(%edx)
f01010ee:	74 09                	je     f01010f9 <strlen+0x19>
		n++;
f01010f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01010f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01010f7:	75 f7                	jne    f01010f0 <strlen+0x10>
		n++;
	return n;
}
f01010f9:	5d                   	pop    %ebp
f01010fa:	c3                   	ret    

f01010fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01010fb:	55                   	push   %ebp
f01010fc:	89 e5                	mov    %esp,%ebp
f01010fe:	53                   	push   %ebx
f01010ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101102:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101105:	b8 00 00 00 00       	mov    $0x0,%eax
f010110a:	85 c9                	test   %ecx,%ecx
f010110c:	74 1a                	je     f0101128 <strnlen+0x2d>
f010110e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101111:	74 15                	je     f0101128 <strnlen+0x2d>
f0101113:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0101118:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010111a:	39 ca                	cmp    %ecx,%edx
f010111c:	74 0a                	je     f0101128 <strnlen+0x2d>
f010111e:	83 c2 01             	add    $0x1,%edx
f0101121:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0101126:	75 f0                	jne    f0101118 <strnlen+0x1d>
		n++;
	return n;
}
f0101128:	5b                   	pop    %ebx
f0101129:	5d                   	pop    %ebp
f010112a:	c3                   	ret    

f010112b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010112b:	55                   	push   %ebp
f010112c:	89 e5                	mov    %esp,%ebp
f010112e:	53                   	push   %ebx
f010112f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101132:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101135:	ba 00 00 00 00       	mov    $0x0,%edx
f010113a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010113e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101141:	83 c2 01             	add    $0x1,%edx
f0101144:	84 c9                	test   %cl,%cl
f0101146:	75 f2                	jne    f010113a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101148:	5b                   	pop    %ebx
f0101149:	5d                   	pop    %ebp
f010114a:	c3                   	ret    

f010114b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010114b:	55                   	push   %ebp
f010114c:	89 e5                	mov    %esp,%ebp
f010114e:	56                   	push   %esi
f010114f:	53                   	push   %ebx
f0101150:	8b 45 08             	mov    0x8(%ebp),%eax
f0101153:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101156:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101159:	85 f6                	test   %esi,%esi
f010115b:	74 18                	je     f0101175 <strncpy+0x2a>
f010115d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101162:	0f b6 1a             	movzbl (%edx),%ebx
f0101165:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101168:	80 3a 01             	cmpb   $0x1,(%edx)
f010116b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010116e:	83 c1 01             	add    $0x1,%ecx
f0101171:	39 f1                	cmp    %esi,%ecx
f0101173:	75 ed                	jne    f0101162 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101175:	5b                   	pop    %ebx
f0101176:	5e                   	pop    %esi
f0101177:	5d                   	pop    %ebp
f0101178:	c3                   	ret    

f0101179 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101179:	55                   	push   %ebp
f010117a:	89 e5                	mov    %esp,%ebp
f010117c:	57                   	push   %edi
f010117d:	56                   	push   %esi
f010117e:	53                   	push   %ebx
f010117f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101182:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101185:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101188:	89 f8                	mov    %edi,%eax
f010118a:	85 f6                	test   %esi,%esi
f010118c:	74 2b                	je     f01011b9 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f010118e:	83 fe 01             	cmp    $0x1,%esi
f0101191:	74 23                	je     f01011b6 <strlcpy+0x3d>
f0101193:	0f b6 0b             	movzbl (%ebx),%ecx
f0101196:	84 c9                	test   %cl,%cl
f0101198:	74 1c                	je     f01011b6 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010119a:	83 ee 02             	sub    $0x2,%esi
f010119d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01011a2:	88 08                	mov    %cl,(%eax)
f01011a4:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01011a7:	39 f2                	cmp    %esi,%edx
f01011a9:	74 0b                	je     f01011b6 <strlcpy+0x3d>
f01011ab:	83 c2 01             	add    $0x1,%edx
f01011ae:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01011b2:	84 c9                	test   %cl,%cl
f01011b4:	75 ec                	jne    f01011a2 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01011b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01011b9:	29 f8                	sub    %edi,%eax
}
f01011bb:	5b                   	pop    %ebx
f01011bc:	5e                   	pop    %esi
f01011bd:	5f                   	pop    %edi
f01011be:	5d                   	pop    %ebp
f01011bf:	c3                   	ret    

f01011c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01011c0:	55                   	push   %ebp
f01011c1:	89 e5                	mov    %esp,%ebp
f01011c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01011c9:	0f b6 01             	movzbl (%ecx),%eax
f01011cc:	84 c0                	test   %al,%al
f01011ce:	74 16                	je     f01011e6 <strcmp+0x26>
f01011d0:	3a 02                	cmp    (%edx),%al
f01011d2:	75 12                	jne    f01011e6 <strcmp+0x26>
		p++, q++;
f01011d4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01011d7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01011db:	84 c0                	test   %al,%al
f01011dd:	74 07                	je     f01011e6 <strcmp+0x26>
f01011df:	83 c1 01             	add    $0x1,%ecx
f01011e2:	3a 02                	cmp    (%edx),%al
f01011e4:	74 ee                	je     f01011d4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01011e6:	0f b6 c0             	movzbl %al,%eax
f01011e9:	0f b6 12             	movzbl (%edx),%edx
f01011ec:	29 d0                	sub    %edx,%eax
}
f01011ee:	5d                   	pop    %ebp
f01011ef:	c3                   	ret    

f01011f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01011f0:	55                   	push   %ebp
f01011f1:	89 e5                	mov    %esp,%ebp
f01011f3:	53                   	push   %ebx
f01011f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011fa:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01011fd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101202:	85 d2                	test   %edx,%edx
f0101204:	74 28                	je     f010122e <strncmp+0x3e>
f0101206:	0f b6 01             	movzbl (%ecx),%eax
f0101209:	84 c0                	test   %al,%al
f010120b:	74 24                	je     f0101231 <strncmp+0x41>
f010120d:	3a 03                	cmp    (%ebx),%al
f010120f:	75 20                	jne    f0101231 <strncmp+0x41>
f0101211:	83 ea 01             	sub    $0x1,%edx
f0101214:	74 13                	je     f0101229 <strncmp+0x39>
		n--, p++, q++;
f0101216:	83 c1 01             	add    $0x1,%ecx
f0101219:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010121c:	0f b6 01             	movzbl (%ecx),%eax
f010121f:	84 c0                	test   %al,%al
f0101221:	74 0e                	je     f0101231 <strncmp+0x41>
f0101223:	3a 03                	cmp    (%ebx),%al
f0101225:	74 ea                	je     f0101211 <strncmp+0x21>
f0101227:	eb 08                	jmp    f0101231 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101229:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010122e:	5b                   	pop    %ebx
f010122f:	5d                   	pop    %ebp
f0101230:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101231:	0f b6 01             	movzbl (%ecx),%eax
f0101234:	0f b6 13             	movzbl (%ebx),%edx
f0101237:	29 d0                	sub    %edx,%eax
f0101239:	eb f3                	jmp    f010122e <strncmp+0x3e>

f010123b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010123b:	55                   	push   %ebp
f010123c:	89 e5                	mov    %esp,%ebp
f010123e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101241:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101245:	0f b6 10             	movzbl (%eax),%edx
f0101248:	84 d2                	test   %dl,%dl
f010124a:	74 1c                	je     f0101268 <strchr+0x2d>
		if (*s == c)
f010124c:	38 ca                	cmp    %cl,%dl
f010124e:	75 09                	jne    f0101259 <strchr+0x1e>
f0101250:	eb 1b                	jmp    f010126d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101252:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0101255:	38 ca                	cmp    %cl,%dl
f0101257:	74 14                	je     f010126d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101259:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f010125d:	84 d2                	test   %dl,%dl
f010125f:	75 f1                	jne    f0101252 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0101261:	b8 00 00 00 00       	mov    $0x0,%eax
f0101266:	eb 05                	jmp    f010126d <strchr+0x32>
f0101268:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010126d:	5d                   	pop    %ebp
f010126e:	c3                   	ret    

f010126f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010126f:	55                   	push   %ebp
f0101270:	89 e5                	mov    %esp,%ebp
f0101272:	8b 45 08             	mov    0x8(%ebp),%eax
f0101275:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101279:	0f b6 10             	movzbl (%eax),%edx
f010127c:	84 d2                	test   %dl,%dl
f010127e:	74 14                	je     f0101294 <strfind+0x25>
		if (*s == c)
f0101280:	38 ca                	cmp    %cl,%dl
f0101282:	75 06                	jne    f010128a <strfind+0x1b>
f0101284:	eb 0e                	jmp    f0101294 <strfind+0x25>
f0101286:	38 ca                	cmp    %cl,%dl
f0101288:	74 0a                	je     f0101294 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010128a:	83 c0 01             	add    $0x1,%eax
f010128d:	0f b6 10             	movzbl (%eax),%edx
f0101290:	84 d2                	test   %dl,%dl
f0101292:	75 f2                	jne    f0101286 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101294:	5d                   	pop    %ebp
f0101295:	c3                   	ret    

f0101296 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101296:	55                   	push   %ebp
f0101297:	89 e5                	mov    %esp,%ebp
f0101299:	53                   	push   %ebx
f010129a:	8b 45 08             	mov    0x8(%ebp),%eax
f010129d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01012a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01012a3:	89 da                	mov    %ebx,%edx
f01012a5:	83 ea 01             	sub    $0x1,%edx
f01012a8:	78 0d                	js     f01012b7 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f01012aa:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f01012ac:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f01012ae:	88 0a                	mov    %cl,(%edx)
f01012b0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01012b3:	39 da                	cmp    %ebx,%edx
f01012b5:	75 f7                	jne    f01012ae <memset+0x18>
		*p++ = c;

	return v;
}
f01012b7:	5b                   	pop    %ebx
f01012b8:	5d                   	pop    %ebp
f01012b9:	c3                   	ret    

f01012ba <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f01012ba:	55                   	push   %ebp
f01012bb:	89 e5                	mov    %esp,%ebp
f01012bd:	57                   	push   %edi
f01012be:	56                   	push   %esi
f01012bf:	53                   	push   %ebx
f01012c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01012c3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01012c9:	39 c6                	cmp    %eax,%esi
f01012cb:	72 0b                	jb     f01012d8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f01012cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01012d2:	85 db                	test   %ebx,%ebx
f01012d4:	75 29                	jne    f01012ff <memmove+0x45>
f01012d6:	eb 35                	jmp    f010130d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01012d8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f01012db:	39 c8                	cmp    %ecx,%eax
f01012dd:	73 ee                	jae    f01012cd <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f01012df:	85 db                	test   %ebx,%ebx
f01012e1:	74 2a                	je     f010130d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f01012e3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f01012e6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f01012e8:	f7 db                	neg    %ebx
f01012ea:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f01012ed:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f01012ef:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f01012f4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f01012f8:	83 ea 01             	sub    $0x1,%edx
f01012fb:	75 f2                	jne    f01012ef <memmove+0x35>
f01012fd:	eb 0e                	jmp    f010130d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f01012ff:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101303:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101306:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101309:	39 d3                	cmp    %edx,%ebx
f010130b:	75 f2                	jne    f01012ff <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f010130d:	5b                   	pop    %ebx
f010130e:	5e                   	pop    %esi
f010130f:	5f                   	pop    %edi
f0101310:	5d                   	pop    %ebp
f0101311:	c3                   	ret    

f0101312 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101312:	55                   	push   %ebp
f0101313:	89 e5                	mov    %esp,%ebp
f0101315:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101318:	8b 45 10             	mov    0x10(%ebp),%eax
f010131b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010131f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101322:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101326:	8b 45 08             	mov    0x8(%ebp),%eax
f0101329:	89 04 24             	mov    %eax,(%esp)
f010132c:	e8 89 ff ff ff       	call   f01012ba <memmove>
}
f0101331:	c9                   	leave  
f0101332:	c3                   	ret    

f0101333 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101333:	55                   	push   %ebp
f0101334:	89 e5                	mov    %esp,%ebp
f0101336:	57                   	push   %edi
f0101337:	56                   	push   %esi
f0101338:	53                   	push   %ebx
f0101339:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010133c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010133f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101342:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101347:	85 ff                	test   %edi,%edi
f0101349:	74 37                	je     f0101382 <memcmp+0x4f>
		if (*s1 != *s2)
f010134b:	0f b6 03             	movzbl (%ebx),%eax
f010134e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101351:	83 ef 01             	sub    $0x1,%edi
f0101354:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0101359:	38 c8                	cmp    %cl,%al
f010135b:	74 1c                	je     f0101379 <memcmp+0x46>
f010135d:	eb 10                	jmp    f010136f <memcmp+0x3c>
f010135f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0101364:	83 c2 01             	add    $0x1,%edx
f0101367:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010136b:	38 c8                	cmp    %cl,%al
f010136d:	74 0a                	je     f0101379 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f010136f:	0f b6 c0             	movzbl %al,%eax
f0101372:	0f b6 c9             	movzbl %cl,%ecx
f0101375:	29 c8                	sub    %ecx,%eax
f0101377:	eb 09                	jmp    f0101382 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101379:	39 fa                	cmp    %edi,%edx
f010137b:	75 e2                	jne    f010135f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010137d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101382:	5b                   	pop    %ebx
f0101383:	5e                   	pop    %esi
f0101384:	5f                   	pop    %edi
f0101385:	5d                   	pop    %ebp
f0101386:	c3                   	ret    

f0101387 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101387:	55                   	push   %ebp
f0101388:	89 e5                	mov    %esp,%ebp
f010138a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010138d:	89 c2                	mov    %eax,%edx
f010138f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101392:	39 d0                	cmp    %edx,%eax
f0101394:	73 15                	jae    f01013ab <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101396:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010139a:	38 08                	cmp    %cl,(%eax)
f010139c:	75 06                	jne    f01013a4 <memfind+0x1d>
f010139e:	eb 0b                	jmp    f01013ab <memfind+0x24>
f01013a0:	38 08                	cmp    %cl,(%eax)
f01013a2:	74 07                	je     f01013ab <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01013a4:	83 c0 01             	add    $0x1,%eax
f01013a7:	39 d0                	cmp    %edx,%eax
f01013a9:	75 f5                	jne    f01013a0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01013ab:	5d                   	pop    %ebp
f01013ac:	c3                   	ret    

f01013ad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01013ad:	55                   	push   %ebp
f01013ae:	89 e5                	mov    %esp,%ebp
f01013b0:	57                   	push   %edi
f01013b1:	56                   	push   %esi
f01013b2:	53                   	push   %ebx
f01013b3:	8b 55 08             	mov    0x8(%ebp),%edx
f01013b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01013b9:	0f b6 02             	movzbl (%edx),%eax
f01013bc:	3c 20                	cmp    $0x20,%al
f01013be:	74 04                	je     f01013c4 <strtol+0x17>
f01013c0:	3c 09                	cmp    $0x9,%al
f01013c2:	75 0e                	jne    f01013d2 <strtol+0x25>
		s++;
f01013c4:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01013c7:	0f b6 02             	movzbl (%edx),%eax
f01013ca:	3c 20                	cmp    $0x20,%al
f01013cc:	74 f6                	je     f01013c4 <strtol+0x17>
f01013ce:	3c 09                	cmp    $0x9,%al
f01013d0:	74 f2                	je     f01013c4 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f01013d2:	3c 2b                	cmp    $0x2b,%al
f01013d4:	75 0a                	jne    f01013e0 <strtol+0x33>
		s++;
f01013d6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01013d9:	bf 00 00 00 00       	mov    $0x0,%edi
f01013de:	eb 10                	jmp    f01013f0 <strtol+0x43>
f01013e0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01013e5:	3c 2d                	cmp    $0x2d,%al
f01013e7:	75 07                	jne    f01013f0 <strtol+0x43>
		s++, neg = 1;
f01013e9:	83 c2 01             	add    $0x1,%edx
f01013ec:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013f0:	85 db                	test   %ebx,%ebx
f01013f2:	0f 94 c0             	sete   %al
f01013f5:	74 05                	je     f01013fc <strtol+0x4f>
f01013f7:	83 fb 10             	cmp    $0x10,%ebx
f01013fa:	75 15                	jne    f0101411 <strtol+0x64>
f01013fc:	80 3a 30             	cmpb   $0x30,(%edx)
f01013ff:	75 10                	jne    f0101411 <strtol+0x64>
f0101401:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101405:	75 0a                	jne    f0101411 <strtol+0x64>
		s += 2, base = 16;
f0101407:	83 c2 02             	add    $0x2,%edx
f010140a:	bb 10 00 00 00       	mov    $0x10,%ebx
f010140f:	eb 13                	jmp    f0101424 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0101411:	84 c0                	test   %al,%al
f0101413:	74 0f                	je     f0101424 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101415:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010141a:	80 3a 30             	cmpb   $0x30,(%edx)
f010141d:	75 05                	jne    f0101424 <strtol+0x77>
		s++, base = 8;
f010141f:	83 c2 01             	add    $0x1,%edx
f0101422:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0101424:	b8 00 00 00 00       	mov    $0x0,%eax
f0101429:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010142b:	0f b6 0a             	movzbl (%edx),%ecx
f010142e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101431:	80 fb 09             	cmp    $0x9,%bl
f0101434:	77 08                	ja     f010143e <strtol+0x91>
			dig = *s - '0';
f0101436:	0f be c9             	movsbl %cl,%ecx
f0101439:	83 e9 30             	sub    $0x30,%ecx
f010143c:	eb 1e                	jmp    f010145c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f010143e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0101441:	80 fb 19             	cmp    $0x19,%bl
f0101444:	77 08                	ja     f010144e <strtol+0xa1>
			dig = *s - 'a' + 10;
f0101446:	0f be c9             	movsbl %cl,%ecx
f0101449:	83 e9 57             	sub    $0x57,%ecx
f010144c:	eb 0e                	jmp    f010145c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f010144e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0101451:	80 fb 19             	cmp    $0x19,%bl
f0101454:	77 14                	ja     f010146a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101456:	0f be c9             	movsbl %cl,%ecx
f0101459:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010145c:	39 f1                	cmp    %esi,%ecx
f010145e:	7d 0e                	jge    f010146e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101460:	83 c2 01             	add    $0x1,%edx
f0101463:	0f af c6             	imul   %esi,%eax
f0101466:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0101468:	eb c1                	jmp    f010142b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010146a:	89 c1                	mov    %eax,%ecx
f010146c:	eb 02                	jmp    f0101470 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010146e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0101470:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101474:	74 05                	je     f010147b <strtol+0xce>
		*endptr = (char *) s;
f0101476:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101479:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010147b:	89 ca                	mov    %ecx,%edx
f010147d:	f7 da                	neg    %edx
f010147f:	85 ff                	test   %edi,%edi
f0101481:	0f 45 c2             	cmovne %edx,%eax
}
f0101484:	5b                   	pop    %ebx
f0101485:	5e                   	pop    %esi
f0101486:	5f                   	pop    %edi
f0101487:	5d                   	pop    %ebp
f0101488:	c3                   	ret    
f0101489:	00 00                	add    %al,(%eax)
f010148b:	00 00                	add    %al,(%eax)
f010148d:	00 00                	add    %al,(%eax)
	...

f0101490 <__udivdi3>:
f0101490:	83 ec 1c             	sub    $0x1c,%esp
f0101493:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101497:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010149b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010149f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01014a3:	89 74 24 10          	mov    %esi,0x10(%esp)
f01014a7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01014ab:	85 ff                	test   %edi,%edi
f01014ad:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01014b1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014b5:	89 cd                	mov    %ecx,%ebp
f01014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014bb:	75 33                	jne    f01014f0 <__udivdi3+0x60>
f01014bd:	39 f1                	cmp    %esi,%ecx
f01014bf:	77 57                	ja     f0101518 <__udivdi3+0x88>
f01014c1:	85 c9                	test   %ecx,%ecx
f01014c3:	75 0b                	jne    f01014d0 <__udivdi3+0x40>
f01014c5:	b8 01 00 00 00       	mov    $0x1,%eax
f01014ca:	31 d2                	xor    %edx,%edx
f01014cc:	f7 f1                	div    %ecx
f01014ce:	89 c1                	mov    %eax,%ecx
f01014d0:	89 f0                	mov    %esi,%eax
f01014d2:	31 d2                	xor    %edx,%edx
f01014d4:	f7 f1                	div    %ecx
f01014d6:	89 c6                	mov    %eax,%esi
f01014d8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01014dc:	f7 f1                	div    %ecx
f01014de:	89 f2                	mov    %esi,%edx
f01014e0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01014e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01014e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01014ec:	83 c4 1c             	add    $0x1c,%esp
f01014ef:	c3                   	ret    
f01014f0:	31 d2                	xor    %edx,%edx
f01014f2:	31 c0                	xor    %eax,%eax
f01014f4:	39 f7                	cmp    %esi,%edi
f01014f6:	77 e8                	ja     f01014e0 <__udivdi3+0x50>
f01014f8:	0f bd cf             	bsr    %edi,%ecx
f01014fb:	83 f1 1f             	xor    $0x1f,%ecx
f01014fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101502:	75 2c                	jne    f0101530 <__udivdi3+0xa0>
f0101504:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0101508:	76 04                	jbe    f010150e <__udivdi3+0x7e>
f010150a:	39 f7                	cmp    %esi,%edi
f010150c:	73 d2                	jae    f01014e0 <__udivdi3+0x50>
f010150e:	31 d2                	xor    %edx,%edx
f0101510:	b8 01 00 00 00       	mov    $0x1,%eax
f0101515:	eb c9                	jmp    f01014e0 <__udivdi3+0x50>
f0101517:	90                   	nop
f0101518:	89 f2                	mov    %esi,%edx
f010151a:	f7 f1                	div    %ecx
f010151c:	31 d2                	xor    %edx,%edx
f010151e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101522:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101526:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010152a:	83 c4 1c             	add    $0x1c,%esp
f010152d:	c3                   	ret    
f010152e:	66 90                	xchg   %ax,%ax
f0101530:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101535:	b8 20 00 00 00       	mov    $0x20,%eax
f010153a:	89 ea                	mov    %ebp,%edx
f010153c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101540:	d3 e7                	shl    %cl,%edi
f0101542:	89 c1                	mov    %eax,%ecx
f0101544:	d3 ea                	shr    %cl,%edx
f0101546:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010154b:	09 fa                	or     %edi,%edx
f010154d:	89 f7                	mov    %esi,%edi
f010154f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101553:	89 f2                	mov    %esi,%edx
f0101555:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101559:	d3 e5                	shl    %cl,%ebp
f010155b:	89 c1                	mov    %eax,%ecx
f010155d:	d3 ef                	shr    %cl,%edi
f010155f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101564:	d3 e2                	shl    %cl,%edx
f0101566:	89 c1                	mov    %eax,%ecx
f0101568:	d3 ee                	shr    %cl,%esi
f010156a:	09 d6                	or     %edx,%esi
f010156c:	89 fa                	mov    %edi,%edx
f010156e:	89 f0                	mov    %esi,%eax
f0101570:	f7 74 24 0c          	divl   0xc(%esp)
f0101574:	89 d7                	mov    %edx,%edi
f0101576:	89 c6                	mov    %eax,%esi
f0101578:	f7 e5                	mul    %ebp
f010157a:	39 d7                	cmp    %edx,%edi
f010157c:	72 22                	jb     f01015a0 <__udivdi3+0x110>
f010157e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0101582:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101587:	d3 e5                	shl    %cl,%ebp
f0101589:	39 c5                	cmp    %eax,%ebp
f010158b:	73 04                	jae    f0101591 <__udivdi3+0x101>
f010158d:	39 d7                	cmp    %edx,%edi
f010158f:	74 0f                	je     f01015a0 <__udivdi3+0x110>
f0101591:	89 f0                	mov    %esi,%eax
f0101593:	31 d2                	xor    %edx,%edx
f0101595:	e9 46 ff ff ff       	jmp    f01014e0 <__udivdi3+0x50>
f010159a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01015a0:	8d 46 ff             	lea    -0x1(%esi),%eax
f01015a3:	31 d2                	xor    %edx,%edx
f01015a5:	8b 74 24 10          	mov    0x10(%esp),%esi
f01015a9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01015ad:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01015b1:	83 c4 1c             	add    $0x1c,%esp
f01015b4:	c3                   	ret    
	...

f01015c0 <__umoddi3>:
f01015c0:	83 ec 1c             	sub    $0x1c,%esp
f01015c3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01015c7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f01015cb:	8b 44 24 20          	mov    0x20(%esp),%eax
f01015cf:	89 74 24 10          	mov    %esi,0x10(%esp)
f01015d3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01015d7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01015db:	85 ed                	test   %ebp,%ebp
f01015dd:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01015e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01015e5:	89 cf                	mov    %ecx,%edi
f01015e7:	89 04 24             	mov    %eax,(%esp)
f01015ea:	89 f2                	mov    %esi,%edx
f01015ec:	75 1a                	jne    f0101608 <__umoddi3+0x48>
f01015ee:	39 f1                	cmp    %esi,%ecx
f01015f0:	76 4e                	jbe    f0101640 <__umoddi3+0x80>
f01015f2:	f7 f1                	div    %ecx
f01015f4:	89 d0                	mov    %edx,%eax
f01015f6:	31 d2                	xor    %edx,%edx
f01015f8:	8b 74 24 10          	mov    0x10(%esp),%esi
f01015fc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101600:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101604:	83 c4 1c             	add    $0x1c,%esp
f0101607:	c3                   	ret    
f0101608:	39 f5                	cmp    %esi,%ebp
f010160a:	77 54                	ja     f0101660 <__umoddi3+0xa0>
f010160c:	0f bd c5             	bsr    %ebp,%eax
f010160f:	83 f0 1f             	xor    $0x1f,%eax
f0101612:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101616:	75 60                	jne    f0101678 <__umoddi3+0xb8>
f0101618:	3b 0c 24             	cmp    (%esp),%ecx
f010161b:	0f 87 07 01 00 00    	ja     f0101728 <__umoddi3+0x168>
f0101621:	89 f2                	mov    %esi,%edx
f0101623:	8b 34 24             	mov    (%esp),%esi
f0101626:	29 ce                	sub    %ecx,%esi
f0101628:	19 ea                	sbb    %ebp,%edx
f010162a:	89 34 24             	mov    %esi,(%esp)
f010162d:	8b 04 24             	mov    (%esp),%eax
f0101630:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101634:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101638:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010163c:	83 c4 1c             	add    $0x1c,%esp
f010163f:	c3                   	ret    
f0101640:	85 c9                	test   %ecx,%ecx
f0101642:	75 0b                	jne    f010164f <__umoddi3+0x8f>
f0101644:	b8 01 00 00 00       	mov    $0x1,%eax
f0101649:	31 d2                	xor    %edx,%edx
f010164b:	f7 f1                	div    %ecx
f010164d:	89 c1                	mov    %eax,%ecx
f010164f:	89 f0                	mov    %esi,%eax
f0101651:	31 d2                	xor    %edx,%edx
f0101653:	f7 f1                	div    %ecx
f0101655:	8b 04 24             	mov    (%esp),%eax
f0101658:	f7 f1                	div    %ecx
f010165a:	eb 98                	jmp    f01015f4 <__umoddi3+0x34>
f010165c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101660:	89 f2                	mov    %esi,%edx
f0101662:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101666:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010166a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010166e:	83 c4 1c             	add    $0x1c,%esp
f0101671:	c3                   	ret    
f0101672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101678:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010167d:	89 e8                	mov    %ebp,%eax
f010167f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0101684:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0101688:	89 fa                	mov    %edi,%edx
f010168a:	d3 e0                	shl    %cl,%eax
f010168c:	89 e9                	mov    %ebp,%ecx
f010168e:	d3 ea                	shr    %cl,%edx
f0101690:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101695:	09 c2                	or     %eax,%edx
f0101697:	8b 44 24 08          	mov    0x8(%esp),%eax
f010169b:	89 14 24             	mov    %edx,(%esp)
f010169e:	89 f2                	mov    %esi,%edx
f01016a0:	d3 e7                	shl    %cl,%edi
f01016a2:	89 e9                	mov    %ebp,%ecx
f01016a4:	d3 ea                	shr    %cl,%edx
f01016a6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01016ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01016af:	d3 e6                	shl    %cl,%esi
f01016b1:	89 e9                	mov    %ebp,%ecx
f01016b3:	d3 e8                	shr    %cl,%eax
f01016b5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01016ba:	09 f0                	or     %esi,%eax
f01016bc:	8b 74 24 08          	mov    0x8(%esp),%esi
f01016c0:	f7 34 24             	divl   (%esp)
f01016c3:	d3 e6                	shl    %cl,%esi
f01016c5:	89 74 24 08          	mov    %esi,0x8(%esp)
f01016c9:	89 d6                	mov    %edx,%esi
f01016cb:	f7 e7                	mul    %edi
f01016cd:	39 d6                	cmp    %edx,%esi
f01016cf:	89 c1                	mov    %eax,%ecx
f01016d1:	89 d7                	mov    %edx,%edi
f01016d3:	72 3f                	jb     f0101714 <__umoddi3+0x154>
f01016d5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01016d9:	72 35                	jb     f0101710 <__umoddi3+0x150>
f01016db:	8b 44 24 08          	mov    0x8(%esp),%eax
f01016df:	29 c8                	sub    %ecx,%eax
f01016e1:	19 fe                	sbb    %edi,%esi
f01016e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01016e8:	89 f2                	mov    %esi,%edx
f01016ea:	d3 e8                	shr    %cl,%eax
f01016ec:	89 e9                	mov    %ebp,%ecx
f01016ee:	d3 e2                	shl    %cl,%edx
f01016f0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01016f5:	09 d0                	or     %edx,%eax
f01016f7:	89 f2                	mov    %esi,%edx
f01016f9:	d3 ea                	shr    %cl,%edx
f01016fb:	8b 74 24 10          	mov    0x10(%esp),%esi
f01016ff:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101703:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101707:	83 c4 1c             	add    $0x1c,%esp
f010170a:	c3                   	ret    
f010170b:	90                   	nop
f010170c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101710:	39 d6                	cmp    %edx,%esi
f0101712:	75 c7                	jne    f01016db <__umoddi3+0x11b>
f0101714:	89 d7                	mov    %edx,%edi
f0101716:	89 c1                	mov    %eax,%ecx
f0101718:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010171c:	1b 3c 24             	sbb    (%esp),%edi
f010171f:	eb ba                	jmp    f01016db <__umoddi3+0x11b>
f0101721:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101728:	39 f5                	cmp    %esi,%ebp
f010172a:	0f 82 f1 fe ff ff    	jb     f0101621 <__umoddi3+0x61>
f0101730:	e9 f8 fe ff ff       	jmp    f010162d <__umoddi3+0x6d>
