
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
f0100015:	0f 01 15 18 60 11 00 	lgdtl  0x116018

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
f0100033:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100038:	e8 03 00 00 00       	call   f0100040 <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 10 6a 11 f0       	mov    $0xf0116a10,%eax
f010004b:	2d 70 63 11 f0       	sub    $0xf0116370,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 70 63 11 f0 	movl   $0xf0116370,(%esp)
f0100063:	e8 ce 35 00 00       	call   f0103636 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 24 06 00 00       	call   f0100691 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 e0 3a 10 f0 	movl   $0xf0103ae0,(%esp)
f010007c:	e8 31 2a 00 00       	call   f0102ab2 <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100081:	e8 a2 0a 00 00       	call   f0100b28 <i386_detect_memory>
	i386_vm_init();
f0100086:	e8 48 10 00 00       	call   f01010d3 <i386_vm_init>
	// seems that it won`t work, because I never see 6828 on the screen.
	// okay, it is the problem caused by wrong version of bochs. Maybe another way to handle?

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100092:	e8 49 07 00 00       	call   f01007e0 <monitor>
f0100097:	eb f2                	jmp    f010008b <i386_init+0x4b>

f0100099 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100099:	55                   	push   %ebp
f010009a:	89 e5                	mov    %esp,%ebp
f010009c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f010009f:	83 3d 80 63 11 f0 00 	cmpl   $0x0,0xf0116380
f01000a6:	75 40                	jne    f01000e8 <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f01000a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000ab:	a3 80 63 11 f0       	mov    %eax,0xf0116380

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000be:	c7 04 24 fb 3a 10 f0 	movl   $0xf0103afb,(%esp)
f01000c5:	e8 e8 29 00 00       	call   f0102ab2 <cprintf>
	vcprintf(fmt, ap);
f01000ca:	8d 45 14             	lea    0x14(%ebp),%eax
f01000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000d1:	8b 45 10             	mov    0x10(%ebp),%eax
f01000d4:	89 04 24             	mov    %eax,(%esp)
f01000d7:	e8 a3 29 00 00       	call   f0102a7f <vcprintf>
	cprintf("\n");
f01000dc:	c7 04 24 c3 48 10 f0 	movl   $0xf01048c3,(%esp)
f01000e3:	e8 ca 29 00 00       	call   f0102ab2 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ef:	e8 ec 06 00 00       	call   f01007e0 <monitor>
f01000f4:	eb f2                	jmp    f01000e8 <_panic+0x4f>

f01000f6 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f6:	55                   	push   %ebp
f01000f7:	89 e5                	mov    %esp,%ebp
f01000f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f01000fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100103:	8b 45 08             	mov    0x8(%ebp),%eax
f0100106:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010a:	c7 04 24 13 3b 10 f0 	movl   $0xf0103b13,(%esp)
f0100111:	e8 9c 29 00 00       	call   f0102ab2 <cprintf>
	vcprintf(fmt, ap);
f0100116:	8d 45 14             	lea    0x14(%ebp),%eax
f0100119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010011d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100120:	89 04 24             	mov    %eax,(%esp)
f0100123:	e8 57 29 00 00       	call   f0102a7f <vcprintf>
	cprintf("\n");
f0100128:	c7 04 24 c3 48 10 f0 	movl   $0xf01048c3,(%esp)
f010012f:	e8 7e 29 00 00       	call   f0102ab2 <cprintf>
	va_end(ap);
}
f0100134:	c9                   	leave  
f0100135:	c3                   	ret    
	...

f0100138 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100138:	55                   	push   %ebp
f0100139:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010013b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100140:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100141:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100146:	a8 01                	test   $0x1,%al
f0100148:	74 06                	je     f0100150 <serial_proc_data+0x18>
f010014a:	b2 f8                	mov    $0xf8,%dl
f010014c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010014d:	0f b6 c8             	movzbl %al,%ecx
}
f0100150:	89 c8                	mov    %ecx,%eax
f0100152:	5d                   	pop    %ebp
f0100153:	c3                   	ret    

f0100154 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100154:	55                   	push   %ebp
f0100155:	89 e5                	mov    %esp,%ebp
f0100157:	53                   	push   %ebx
f0100158:	83 ec 14             	sub    $0x14,%esp
f010015b:	ba 64 00 00 00       	mov    $0x64,%edx
f0100160:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100161:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100166:	a8 01                	test   $0x1,%al
f0100168:	0f 84 de 00 00 00    	je     f010024c <kbd_proc_data+0xf8>
f010016e:	b2 60                	mov    $0x60,%dl
f0100170:	ec                   	in     (%dx),%al
f0100171:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100173:	3c e0                	cmp    $0xe0,%al
f0100175:	75 11                	jne    f0100188 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f0100177:	83 0d b0 63 11 f0 40 	orl    $0x40,0xf01163b0
		return 0;
f010017e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100183:	e9 c4 00 00 00       	jmp    f010024c <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100188:	84 c0                	test   %al,%al
f010018a:	79 37                	jns    f01001c3 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010018c:	8b 0d b0 63 11 f0    	mov    0xf01163b0,%ecx
f0100192:	89 cb                	mov    %ecx,%ebx
f0100194:	83 e3 40             	and    $0x40,%ebx
f0100197:	83 e0 7f             	and    $0x7f,%eax
f010019a:	85 db                	test   %ebx,%ebx
f010019c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010019f:	0f b6 d2             	movzbl %dl,%edx
f01001a2:	0f b6 82 40 3d 10 f0 	movzbl -0xfefc2c0(%edx),%eax
f01001a9:	83 c8 40             	or     $0x40,%eax
f01001ac:	0f b6 c0             	movzbl %al,%eax
f01001af:	f7 d0                	not    %eax
f01001b1:	21 c1                	and    %eax,%ecx
f01001b3:	89 0d b0 63 11 f0    	mov    %ecx,0xf01163b0
		return 0;
f01001b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001be:	e9 89 00 00 00       	jmp    f010024c <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01001c3:	8b 0d b0 63 11 f0    	mov    0xf01163b0,%ecx
f01001c9:	f6 c1 40             	test   $0x40,%cl
f01001cc:	74 0e                	je     f01001dc <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ce:	89 c2                	mov    %eax,%edx
f01001d0:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01001d3:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001d6:	89 0d b0 63 11 f0    	mov    %ecx,0xf01163b0
	}

	shift |= shiftcode[data];
f01001dc:	0f b6 d2             	movzbl %dl,%edx
f01001df:	0f b6 82 40 3d 10 f0 	movzbl -0xfefc2c0(%edx),%eax
f01001e6:	0b 05 b0 63 11 f0    	or     0xf01163b0,%eax
	shift ^= togglecode[data];
f01001ec:	0f b6 8a 40 3e 10 f0 	movzbl -0xfefc1c0(%edx),%ecx
f01001f3:	31 c8                	xor    %ecx,%eax
f01001f5:	a3 b0 63 11 f0       	mov    %eax,0xf01163b0

	c = charcode[shift & (CTL | SHIFT)][data];
f01001fa:	89 c1                	mov    %eax,%ecx
f01001fc:	83 e1 03             	and    $0x3,%ecx
f01001ff:	8b 0c 8d 40 3f 10 f0 	mov    -0xfefc0c0(,%ecx,4),%ecx
f0100206:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010020a:	a8 08                	test   $0x8,%al
f010020c:	74 19                	je     f0100227 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f010020e:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100211:	83 fa 19             	cmp    $0x19,%edx
f0100214:	77 05                	ja     f010021b <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f0100216:	83 eb 20             	sub    $0x20,%ebx
f0100219:	eb 0c                	jmp    f0100227 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f010021b:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f010021e:	8d 53 20             	lea    0x20(%ebx),%edx
f0100221:	83 f9 19             	cmp    $0x19,%ecx
f0100224:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100227:	f7 d0                	not    %eax
f0100229:	a8 06                	test   $0x6,%al
f010022b:	75 1f                	jne    f010024c <kbd_proc_data+0xf8>
f010022d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100233:	75 17                	jne    f010024c <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f0100235:	c7 04 24 2d 3b 10 f0 	movl   $0xf0103b2d,(%esp)
f010023c:	e8 71 28 00 00       	call   f0102ab2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100241:	ba 92 00 00 00       	mov    $0x92,%edx
f0100246:	b8 03 00 00 00       	mov    $0x3,%eax
f010024b:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010024c:	89 d8                	mov    %ebx,%eax
f010024e:	83 c4 14             	add    $0x14,%esp
f0100251:	5b                   	pop    %ebx
f0100252:	5d                   	pop    %ebp
f0100253:	c3                   	ret    

f0100254 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	53                   	push   %ebx
f0100258:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010025d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100262:	89 da                	mov    %ebx,%edx
f0100264:	ee                   	out    %al,(%dx)
f0100265:	b2 fb                	mov    $0xfb,%dl
f0100267:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010026c:	ee                   	out    %al,(%dx)
f010026d:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100272:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100277:	89 ca                	mov    %ecx,%edx
f0100279:	ee                   	out    %al,(%dx)
f010027a:	b2 f9                	mov    $0xf9,%dl
f010027c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100281:	ee                   	out    %al,(%dx)
f0100282:	b2 fb                	mov    $0xfb,%dl
f0100284:	b8 03 00 00 00       	mov    $0x3,%eax
f0100289:	ee                   	out    %al,(%dx)
f010028a:	b2 fc                	mov    $0xfc,%dl
f010028c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100291:	ee                   	out    %al,(%dx)
f0100292:	b2 f9                	mov    $0xf9,%dl
f0100294:	b8 01 00 00 00       	mov    $0x1,%eax
f0100299:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010029a:	b2 fd                	mov    $0xfd,%dl
f010029c:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010029d:	3c ff                	cmp    $0xff,%al
f010029f:	0f 95 c0             	setne  %al
f01002a2:	0f b6 c0             	movzbl %al,%eax
f01002a5:	a3 a0 63 11 f0       	mov    %eax,0xf01163a0
f01002aa:	89 da                	mov    %ebx,%edx
f01002ac:	ec                   	in     (%dx),%al
f01002ad:	89 ca                	mov    %ecx,%edx
f01002af:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f01002b0:	5b                   	pop    %ebx
f01002b1:	5d                   	pop    %ebp
f01002b2:	c3                   	ret    

f01002b3 <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f01002b3:	55                   	push   %ebp
f01002b4:	89 e5                	mov    %esp,%ebp
f01002b6:	83 ec 0c             	sub    $0xc,%esp
f01002b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01002bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01002bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01002c2:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01002c9:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01002d0:	5a a5 
	if (*cp != 0xA55A) {
f01002d2:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01002d9:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01002dd:	74 11                	je     f01002f0 <cga_init+0x3d>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01002df:	c7 05 a4 63 11 f0 b4 	movl   $0x3b4,0xf01163a4
f01002e6:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01002e9:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01002ee:	eb 16                	jmp    f0100306 <cga_init+0x53>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01002f0:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01002f7:	c7 05 a4 63 11 f0 d4 	movl   $0x3d4,0xf01163a4
f01002fe:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100301:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100306:	8b 0d a4 63 11 f0    	mov    0xf01163a4,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010030c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100311:	89 ca                	mov    %ecx,%edx
f0100313:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100314:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100317:	89 da                	mov    %ebx,%edx
f0100319:	ec                   	in     (%dx),%al
f010031a:	0f b6 f8             	movzbl %al,%edi
f010031d:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100320:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100325:	89 ca                	mov    %ecx,%edx
f0100327:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100328:	89 da                	mov    %ebx,%edx
f010032a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010032b:	89 35 a8 63 11 f0    	mov    %esi,0xf01163a8
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100331:	0f b6 d8             	movzbl %al,%ebx
f0100334:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100336:	66 89 3d ac 63 11 f0 	mov    %di,0xf01163ac
}
f010033d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100340:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100343:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100346:	89 ec                	mov    %ebp,%esp
f0100348:	5d                   	pop    %ebp
f0100349:	c3                   	ret    

f010034a <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f010034a:	55                   	push   %ebp
f010034b:	89 e5                	mov    %esp,%ebp
}
f010034d:	5d                   	pop    %ebp
f010034e:	c3                   	ret    

f010034f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f010034f:	55                   	push   %ebp
f0100350:	89 e5                	mov    %esp,%ebp
f0100352:	53                   	push   %ebx
f0100353:	83 ec 04             	sub    $0x4,%esp
f0100356:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100359:	eb 25                	jmp    f0100380 <cons_intr+0x31>
		if (c == 0)
f010035b:	85 c0                	test   %eax,%eax
f010035d:	74 21                	je     f0100380 <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f010035f:	8b 15 c4 65 11 f0    	mov    0xf01165c4,%edx
f0100365:	88 82 c0 63 11 f0    	mov    %al,-0xfee9c40(%edx)
f010036b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010036e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100373:	ba 00 00 00 00       	mov    $0x0,%edx
f0100378:	0f 44 c2             	cmove  %edx,%eax
f010037b:	a3 c4 65 11 f0       	mov    %eax,0xf01165c4
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100380:	ff d3                	call   *%ebx
f0100382:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100385:	75 d4                	jne    f010035b <cons_intr+0xc>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100387:	83 c4 04             	add    $0x4,%esp
f010038a:	5b                   	pop    %ebx
f010038b:	5d                   	pop    %ebp
f010038c:	c3                   	ret    

f010038d <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010038d:	55                   	push   %ebp
f010038e:	89 e5                	mov    %esp,%ebp
f0100390:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100393:	c7 04 24 54 01 10 f0 	movl   $0xf0100154,(%esp)
f010039a:	e8 b0 ff ff ff       	call   f010034f <cons_intr>
}
f010039f:	c9                   	leave  
f01003a0:	c3                   	ret    

f01003a1 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01003a1:	55                   	push   %ebp
f01003a2:	89 e5                	mov    %esp,%ebp
f01003a4:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f01003a7:	83 3d a0 63 11 f0 00 	cmpl   $0x0,0xf01163a0
f01003ae:	74 0c                	je     f01003bc <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f01003b0:	c7 04 24 38 01 10 f0 	movl   $0xf0100138,(%esp)
f01003b7:	e8 93 ff ff ff       	call   f010034f <cons_intr>
}
f01003bc:	c9                   	leave  
f01003bd:	c3                   	ret    

f01003be <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01003be:	55                   	push   %ebp
f01003bf:	89 e5                	mov    %esp,%ebp
f01003c1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01003c4:	e8 d8 ff ff ff       	call   f01003a1 <serial_intr>
	kbd_intr();
f01003c9:	e8 bf ff ff ff       	call   f010038d <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01003ce:	8b 15 c0 65 11 f0    	mov    0xf01165c0,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01003d4:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01003d9:	3b 15 c4 65 11 f0    	cmp    0xf01165c4,%edx
f01003df:	74 1e                	je     f01003ff <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01003e1:	0f b6 82 c0 63 11 f0 	movzbl -0xfee9c40(%edx),%eax
f01003e8:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01003eb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01003f6:	0f 44 d1             	cmove  %ecx,%edx
f01003f9:	89 15 c0 65 11 f0    	mov    %edx,0xf01165c0
		return c;
	}
	return 0;
}
f01003ff:	c9                   	leave  
f0100400:	c3                   	ret    

f0100401 <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f0100401:	55                   	push   %ebp
f0100402:	89 e5                	mov    %esp,%ebp
f0100404:	57                   	push   %edi
f0100405:	56                   	push   %esi
f0100406:	53                   	push   %ebx
f0100407:	83 ec 1c             	sub    $0x1c,%esp
f010040a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010040d:	ba 79 03 00 00       	mov    $0x379,%edx
f0100412:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100413:	84 c0                	test   %al,%al
f0100415:	78 21                	js     f0100438 <cons_putc+0x37>
f0100417:	bb 00 32 00 00       	mov    $0x3200,%ebx
f010041c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100421:	be 79 03 00 00       	mov    $0x379,%esi
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ec                   	in     (%dx),%al
f0100429:	ec                   	in     (%dx),%al
f010042a:	ec                   	in     (%dx),%al
f010042b:	ec                   	in     (%dx),%al
f010042c:	89 f2                	mov    %esi,%edx
f010042e:	ec                   	in     (%dx),%al
f010042f:	84 c0                	test   %al,%al
f0100431:	78 05                	js     f0100438 <cons_putc+0x37>
f0100433:	83 eb 01             	sub    $0x1,%ebx
f0100436:	75 ee                	jne    f0100426 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100438:	ba 78 03 00 00       	mov    $0x378,%edx
f010043d:	89 f8                	mov    %edi,%eax
f010043f:	ee                   	out    %al,(%dx)
f0100440:	b2 7a                	mov    $0x7a,%dl
f0100442:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100447:	ee                   	out    %al,(%dx)
f0100448:	b8 08 00 00 00       	mov    $0x8,%eax
f010044d:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f010044e:	89 3c 24             	mov    %edi,(%esp)
f0100451:	e8 08 00 00 00       	call   f010045e <cga_putc>
}
f0100456:	83 c4 1c             	add    $0x1c,%esp
f0100459:	5b                   	pop    %ebx
f010045a:	5e                   	pop    %esi
f010045b:	5f                   	pop    %edi
f010045c:	5d                   	pop    %ebp
f010045d:	c3                   	ret    

f010045e <cga_putc>:



void
cga_putc(int c)
{
f010045e:	55                   	push   %ebp
f010045f:	89 e5                	mov    %esp,%ebp
f0100461:	56                   	push   %esi
f0100462:	53                   	push   %ebx
f0100463:	83 ec 10             	sub    $0x10,%esp
f0100466:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	// whether are 15-8 bits zero?If they are set 8,9,10 bit 1,If not continue.
	if (!(c & ~0xFF))
f0100469:	89 c1                	mov    %eax,%ecx
f010046b:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0a00;
f0100471:	89 c2                	mov    %eax,%edx
f0100473:	80 ce 0a             	or     $0xa,%dh
f0100476:	85 c9                	test   %ecx,%ecx
f0100478:	0f 44 c2             	cmove  %edx,%eax

	// whether are low 8 bits '\b','\n','\r','\t'?If they are,preform corresponding operation.
	switch (c & 0xff) {
f010047b:	0f b6 d0             	movzbl %al,%edx
f010047e:	83 ea 08             	sub    $0x8,%edx
f0100481:	83 fa 72             	cmp    $0x72,%edx
f0100484:	0f 87 67 01 00 00    	ja     f01005f1 <cga_putc+0x193>
f010048a:	ff 24 95 60 3b 10 f0 	jmp    *-0xfefc4a0(,%edx,4)
	case '\b':
		if (crt_pos > 0) {
f0100491:	0f b7 15 ac 63 11 f0 	movzwl 0xf01163ac,%edx
f0100498:	66 85 d2             	test   %dx,%dx
f010049b:	0f 84 bb 01 00 00    	je     f010065c <cga_putc+0x1fe>
			crt_pos--;
f01004a1:	83 ea 01             	sub    $0x1,%edx
f01004a4:	66 89 15 ac 63 11 f0 	mov    %dx,0xf01163ac
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ab:	0f b7 d2             	movzwl %dx,%edx
f01004ae:	b0 00                	mov    $0x0,%al
f01004b0:	89 c1                	mov    %eax,%ecx
f01004b2:	83 c9 20             	or     $0x20,%ecx
f01004b5:	a1 a8 63 11 f0       	mov    0xf01163a8,%eax
f01004ba:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01004be:	e9 4c 01 00 00       	jmp    f010060f <cga_putc+0x1b1>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004c3:	66 83 05 ac 63 11 f0 	addw   $0x50,0xf01163ac
f01004ca:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004cb:	0f b7 05 ac 63 11 f0 	movzwl 0xf01163ac,%eax
f01004d2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d8:	c1 e8 16             	shr    $0x16,%eax
f01004db:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004de:	c1 e0 04             	shl    $0x4,%eax
f01004e1:	66 a3 ac 63 11 f0    	mov    %ax,0xf01163ac
		break;
f01004e7:	e9 23 01 00 00       	jmp    f010060f <cga_putc+0x1b1>
	case '\t':
		cons_putc(' ');
f01004ec:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01004f3:	e8 09 ff ff ff       	call   f0100401 <cons_putc>
		cons_putc(' ');
f01004f8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01004ff:	e8 fd fe ff ff       	call   f0100401 <cons_putc>
		cons_putc(' ');
f0100504:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010050b:	e8 f1 fe ff ff       	call   f0100401 <cons_putc>
		cons_putc(' ');
f0100510:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100517:	e8 e5 fe ff ff       	call   f0100401 <cons_putc>
		cons_putc(' ');
f010051c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100523:	e8 d9 fe ff ff       	call   f0100401 <cons_putc>
		break;
f0100528:	e9 e2 00 00 00       	jmp    f010060f <cga_putc+0x1b1>
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0c00;
f010052d:	0f b7 15 ac 63 11 f0 	movzwl 0xf01163ac,%edx
f0100534:	0f b7 da             	movzwl %dx,%ebx
f0100537:	80 e4 f0             	and    $0xf0,%ah
f010053a:	80 cc 0c             	or     $0xc,%ah
f010053d:	8b 0d a8 63 11 f0    	mov    0xf01163a8,%ecx
f0100543:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100547:	83 c2 01             	add    $0x1,%edx
f010054a:	66 89 15 ac 63 11 f0 	mov    %dx,0xf01163ac
		break;
f0100551:	e9 b9 00 00 00       	jmp    f010060f <cga_putc+0x1b1>
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0900;
f0100556:	0f b7 15 ac 63 11 f0 	movzwl 0xf01163ac,%edx
f010055d:	0f b7 da             	movzwl %dx,%ebx
f0100560:	80 e4 f0             	and    $0xf0,%ah
f0100563:	80 cc 09             	or     $0x9,%ah
f0100566:	8b 0d a8 63 11 f0    	mov    0xf01163a8,%ecx
f010056c:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100570:	83 c2 01             	add    $0x1,%edx
f0100573:	66 89 15 ac 63 11 f0 	mov    %dx,0xf01163ac
		break;
f010057a:	e9 90 00 00 00       	jmp    f010060f <cga_putc+0x1b1>
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0100;
f010057f:	0f b7 15 ac 63 11 f0 	movzwl 0xf01163ac,%edx
f0100586:	0f b7 da             	movzwl %dx,%ebx
f0100589:	80 e4 f0             	and    $0xf0,%ah
f010058c:	80 cc 01             	or     $0x1,%ah
f010058f:	8b 0d a8 63 11 f0    	mov    0xf01163a8,%ecx
f0100595:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100599:	83 c2 01             	add    $0x1,%edx
f010059c:	66 89 15 ac 63 11 f0 	mov    %dx,0xf01163ac
		break;
f01005a3:	eb 6a                	jmp    f010060f <cga_putc+0x1b1>
	case '%':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0e00;
f01005a5:	0f b7 15 ac 63 11 f0 	movzwl 0xf01163ac,%edx
f01005ac:	0f b7 da             	movzwl %dx,%ebx
f01005af:	80 e4 f0             	and    $0xf0,%ah
f01005b2:	80 cc 0e             	or     $0xe,%ah
f01005b5:	8b 0d a8 63 11 f0    	mov    0xf01163a8,%ecx
f01005bb:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005bf:	83 c2 01             	add    $0x1,%edx
f01005c2:	66 89 15 ac 63 11 f0 	mov    %dx,0xf01163ac
		break;
f01005c9:	eb 44                	jmp    f010060f <cga_putc+0x1b1>
	case '&':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0d00;
f01005cb:	0f b7 15 ac 63 11 f0 	movzwl 0xf01163ac,%edx
f01005d2:	0f b7 da             	movzwl %dx,%ebx
f01005d5:	80 e4 f0             	and    $0xf0,%ah
f01005d8:	80 cc 0d             	or     $0xd,%ah
f01005db:	8b 0d a8 63 11 f0    	mov    0xf01163a8,%ecx
f01005e1:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005e5:	83 c2 01             	add    $0x1,%edx
f01005e8:	66 89 15 ac 63 11 f0 	mov    %dx,0xf01163ac
		break;
f01005ef:	eb 1e                	jmp    f010060f <cga_putc+0x1b1>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005f1:	0f b7 15 ac 63 11 f0 	movzwl 0xf01163ac,%edx
f01005f8:	0f b7 da             	movzwl %dx,%ebx
f01005fb:	8b 0d a8 63 11 f0    	mov    0xf01163a8,%ecx
f0100601:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100605:	83 c2 01             	add    $0x1,%edx
f0100608:	66 89 15 ac 63 11 f0 	mov    %dx,0xf01163ac
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010060f:	66 81 3d ac 63 11 f0 	cmpw   $0x7cf,0xf01163ac
f0100616:	cf 07 
f0100618:	76 42                	jbe    f010065c <cga_putc+0x1fe>
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010061a:	a1 a8 63 11 f0       	mov    0xf01163a8,%eax
f010061f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100626:	00 
f0100627:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010062d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100631:	89 04 24             	mov    %eax,(%esp)
f0100634:	e8 21 30 00 00       	call   f010365a <memmove>
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0c00 | ' ';
f0100639:	8b 15 a8 63 11 f0    	mov    0xf01163a8,%edx
	if (crt_pos >= CRT_SIZE) {
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010063f:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0c00 | ' ';
f0100644:	66 c7 04 42 20 0c    	movw   $0xc20,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) {
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010064a:	83 c0 01             	add    $0x1,%eax
f010064d:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100652:	75 f0                	jne    f0100644 <cga_putc+0x1e6>
			crt_buf[i] = 0x0c00 | ' ';
		// Fix the position of screen;[Comment out this line and the screen will turn pure black]
		crt_pos -= CRT_COLS;
f0100654:	66 83 2d ac 63 11 f0 	subw   $0x50,0xf01163ac
f010065b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010065c:	8b 0d a4 63 11 f0    	mov    0xf01163a4,%ecx
f0100662:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100667:	89 ca                	mov    %ecx,%edx
f0100669:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010066a:	0f b7 35 ac 63 11 f0 	movzwl 0xf01163ac,%esi
f0100671:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100674:	89 f0                	mov    %esi,%eax
f0100676:	66 c1 e8 08          	shr    $0x8,%ax
f010067a:	89 da                	mov    %ebx,%edx
f010067c:	ee                   	out    %al,(%dx)
f010067d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ee                   	out    %al,(%dx)
f0100685:	89 f0                	mov    %esi,%eax
f0100687:	89 da                	mov    %ebx,%edx
f0100689:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f010068a:	83 c4 10             	add    $0x10,%esp
f010068d:	5b                   	pop    %ebx
f010068e:	5e                   	pop    %esi
f010068f:	5d                   	pop    %ebp
f0100690:	c3                   	ret    

f0100691 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100691:	55                   	push   %ebp
f0100692:	89 e5                	mov    %esp,%ebp
f0100694:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100697:	e8 17 fc ff ff       	call   f01002b3 <cga_init>
	kbd_init();
	serial_init();
f010069c:	e8 b3 fb ff ff       	call   f0100254 <serial_init>

	if (!serial_exists)
f01006a1:	83 3d a0 63 11 f0 00 	cmpl   $0x0,0xf01163a0
f01006a8:	75 0c                	jne    f01006b6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01006aa:	c7 04 24 39 3b 10 f0 	movl   $0xf0103b39,(%esp)
f01006b1:	e8 fc 23 00 00       	call   f0102ab2 <cprintf>
}
f01006b6:	c9                   	leave  
f01006b7:	c3                   	ret    

f01006b8 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006b8:	55                   	push   %ebp
f01006b9:	89 e5                	mov    %esp,%ebp
f01006bb:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006be:	8b 45 08             	mov    0x8(%ebp),%eax
f01006c1:	89 04 24             	mov    %eax,(%esp)
f01006c4:	e8 38 fd ff ff       	call   f0100401 <cons_putc>
}
f01006c9:	c9                   	leave  
f01006ca:	c3                   	ret    

f01006cb <getchar>:

int
getchar(void)
{
f01006cb:	55                   	push   %ebp
f01006cc:	89 e5                	mov    %esp,%ebp
f01006ce:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006d1:	e8 e8 fc ff ff       	call   f01003be <cons_getc>
f01006d6:	85 c0                	test   %eax,%eax
f01006d8:	74 f7                	je     f01006d1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006da:	c9                   	leave  
f01006db:	c3                   	ret    

f01006dc <iscons>:

int
iscons(int fdnum)
{
f01006dc:	55                   	push   %ebp
f01006dd:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006df:	b8 01 00 00 00       	mov    $0x1,%eax
f01006e4:	5d                   	pop    %ebp
f01006e5:	c3                   	ret    
	...

f01006f0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006f0:	55                   	push   %ebp
f01006f1:	89 e5                	mov    %esp,%ebp
f01006f3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006f6:	c7 04 24 50 3f 10 f0 	movl   $0xf0103f50,(%esp)
f01006fd:	e8 b0 23 00 00       	call   f0102ab2 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100702:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100709:	00 
f010070a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100711:	f0 
f0100712:	c7 04 24 1c 40 10 f0 	movl   $0xf010401c,(%esp)
f0100719:	e8 94 23 00 00       	call   f0102ab2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010071e:	c7 44 24 08 d5 3a 10 	movl   $0x103ad5,0x8(%esp)
f0100725:	00 
f0100726:	c7 44 24 04 d5 3a 10 	movl   $0xf0103ad5,0x4(%esp)
f010072d:	f0 
f010072e:	c7 04 24 40 40 10 f0 	movl   $0xf0104040,(%esp)
f0100735:	e8 78 23 00 00       	call   f0102ab2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010073a:	c7 44 24 08 70 63 11 	movl   $0x116370,0x8(%esp)
f0100741:	00 
f0100742:	c7 44 24 04 70 63 11 	movl   $0xf0116370,0x4(%esp)
f0100749:	f0 
f010074a:	c7 04 24 64 40 10 f0 	movl   $0xf0104064,(%esp)
f0100751:	e8 5c 23 00 00       	call   f0102ab2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100756:	c7 44 24 08 10 6a 11 	movl   $0x116a10,0x8(%esp)
f010075d:	00 
f010075e:	c7 44 24 04 10 6a 11 	movl   $0xf0116a10,0x4(%esp)
f0100765:	f0 
f0100766:	c7 04 24 88 40 10 f0 	movl   $0xf0104088,(%esp)
f010076d:	e8 40 23 00 00       	call   f0102ab2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f0100772:	b8 0f 6e 11 f0       	mov    $0xf0116e0f,%eax
f0100777:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010077c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100782:	85 c0                	test   %eax,%eax
f0100784:	0f 48 c2             	cmovs  %edx,%eax
f0100787:	c1 f8 0a             	sar    $0xa,%eax
f010078a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010078e:	c7 04 24 ac 40 10 f0 	movl   $0xf01040ac,(%esp)
f0100795:	e8 18 23 00 00       	call   f0102ab2 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010079a:	b8 00 00 00 00       	mov    $0x0,%eax
f010079f:	c9                   	leave  
f01007a0:	c3                   	ret    

f01007a1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a1:	55                   	push   %ebp
f01007a2:	89 e5                	mov    %esp,%ebp
f01007a4:	53                   	push   %ebx
f01007a5:	83 ec 14             	sub    $0x14,%esp
f01007a8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007ad:	8b 83 a4 41 10 f0    	mov    -0xfefbe5c(%ebx),%eax
f01007b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007b7:	8b 83 a0 41 10 f0    	mov    -0xfefbe60(%ebx),%eax
f01007bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c1:	c7 04 24 69 3f 10 f0 	movl   $0xf0103f69,(%esp)
f01007c8:	e8 e5 22 00 00       	call   f0102ab2 <cprintf>
f01007cd:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01007d0:	83 fb 24             	cmp    $0x24,%ebx
f01007d3:	75 d8                	jne    f01007ad <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01007d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007da:	83 c4 14             	add    $0x14,%esp
f01007dd:	5b                   	pop    %ebx
f01007de:	5d                   	pop    %ebp
f01007df:	c3                   	ret    

f01007e0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007e0:	55                   	push   %ebp
f01007e1:	89 e5                	mov    %esp,%ebp
f01007e3:	57                   	push   %edi
f01007e4:	56                   	push   %esi
f01007e5:	53                   	push   %ebx
f01007e6:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007e9:	c7 04 24 d8 40 10 f0 	movl   $0xf01040d8,(%esp)
f01007f0:	e8 bd 22 00 00       	call   f0102ab2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007f5:	c7 04 24 fc 40 10 f0 	movl   $0xf01040fc,(%esp)
f01007fc:	e8 b1 22 00 00       	call   f0102ab2 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100801:	c7 04 24 72 3f 10 f0 	movl   $0xf0103f72,(%esp)
f0100808:	e8 b3 2b 00 00       	call   f01033c0 <readline>
f010080d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010080f:	85 c0                	test   %eax,%eax
f0100811:	74 ee                	je     f0100801 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100813:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010081a:	be 00 00 00 00       	mov    $0x0,%esi
f010081f:	eb 06                	jmp    f0100827 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100821:	c6 03 00             	movb   $0x0,(%ebx)
f0100824:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100827:	0f b6 03             	movzbl (%ebx),%eax
f010082a:	84 c0                	test   %al,%al
f010082c:	74 6d                	je     f010089b <monitor+0xbb>
f010082e:	0f be c0             	movsbl %al,%eax
f0100831:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100835:	c7 04 24 76 3f 10 f0 	movl   $0xf0103f76,(%esp)
f010083c:	e8 9a 2d 00 00       	call   f01035db <strchr>
f0100841:	85 c0                	test   %eax,%eax
f0100843:	75 dc                	jne    f0100821 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100845:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100848:	74 51                	je     f010089b <monitor+0xbb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010084a:	83 fe 0f             	cmp    $0xf,%esi
f010084d:	8d 76 00             	lea    0x0(%esi),%esi
f0100850:	75 16                	jne    f0100868 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100852:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100859:	00 
f010085a:	c7 04 24 7b 3f 10 f0 	movl   $0xf0103f7b,(%esp)
f0100861:	e8 4c 22 00 00       	call   f0102ab2 <cprintf>
f0100866:	eb 99                	jmp    f0100801 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100868:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010086c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010086f:	0f b6 03             	movzbl (%ebx),%eax
f0100872:	84 c0                	test   %al,%al
f0100874:	75 0c                	jne    f0100882 <monitor+0xa2>
f0100876:	eb af                	jmp    f0100827 <monitor+0x47>
			buf++;
f0100878:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010087b:	0f b6 03             	movzbl (%ebx),%eax
f010087e:	84 c0                	test   %al,%al
f0100880:	74 a5                	je     f0100827 <monitor+0x47>
f0100882:	0f be c0             	movsbl %al,%eax
f0100885:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100889:	c7 04 24 76 3f 10 f0 	movl   $0xf0103f76,(%esp)
f0100890:	e8 46 2d 00 00       	call   f01035db <strchr>
f0100895:	85 c0                	test   %eax,%eax
f0100897:	74 df                	je     f0100878 <monitor+0x98>
f0100899:	eb 8c                	jmp    f0100827 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f010089b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008a2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008a3:	85 f6                	test   %esi,%esi
f01008a5:	0f 84 56 ff ff ff    	je     f0100801 <monitor+0x21>
f01008ab:	bb a0 41 10 f0       	mov    $0xf01041a0,%ebx
f01008b0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008b5:	8b 03                	mov    (%ebx),%eax
f01008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008bb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008be:	89 04 24             	mov    %eax,(%esp)
f01008c1:	e8 9a 2c 00 00       	call   f0103560 <strcmp>
f01008c6:	85 c0                	test   %eax,%eax
f01008c8:	75 24                	jne    f01008ee <monitor+0x10e>
			return commands[i].func(argc, argv, tf);
f01008ca:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008cd:	8b 55 08             	mov    0x8(%ebp),%edx
f01008d0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008d4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008d7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008db:	89 34 24             	mov    %esi,(%esp)
f01008de:	ff 14 85 a8 41 10 f0 	call   *-0xfefbe58(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008e5:	85 c0                	test   %eax,%eax
f01008e7:	78 28                	js     f0100911 <monitor+0x131>
f01008e9:	e9 13 ff ff ff       	jmp    f0100801 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008ee:	83 c7 01             	add    $0x1,%edi
f01008f1:	83 c3 0c             	add    $0xc,%ebx
f01008f4:	83 ff 03             	cmp    $0x3,%edi
f01008f7:	75 bc                	jne    f01008b5 <monitor+0xd5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008f9:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100900:	c7 04 24 98 3f 10 f0 	movl   $0xf0103f98,(%esp)
f0100907:	e8 a6 21 00 00       	call   f0102ab2 <cprintf>
f010090c:	e9 f0 fe ff ff       	jmp    f0100801 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100911:	83 c4 5c             	add    $0x5c,%esp
f0100914:	5b                   	pop    %ebx
f0100915:	5e                   	pop    %esi
f0100916:	5f                   	pop    %edi
f0100917:	5d                   	pop    %ebp
f0100918:	c3                   	ret    

f0100919 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100919:	55                   	push   %ebp
f010091a:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010091c:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010091f:	5d                   	pop    %ebp
f0100920:	c3                   	ret    

f0100921 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100921:	55                   	push   %ebp
f0100922:	89 e5                	mov    %esp,%ebp
f0100924:	57                   	push   %edi
f0100925:	56                   	push   %esi
f0100926:	53                   	push   %ebx
f0100927:	83 ec 4c             	sub    $0x4c,%esp
	unsigned int ebp;
	unsigned int eip;
	struct Eipdebuginfo debug_info;
	int i;	// loop

	cprintf("Stack backtrace:\n");
f010092a:	c7 04 24 ae 3f 10 f0 	movl   $0xf0103fae,(%esp)
f0100931:	e8 7c 21 00 00       	call   f0102ab2 <cprintf>
	// current eip and print current function.
	// cprintf is a function so init after it in case.
	eip = read_eip();
f0100936:	e8 de ff ff ff       	call   f0100919 <read_eip>
f010093b:	89 c7                	mov    %eax,%edi

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010093d:	89 ea                	mov    %ebp,%edx
f010093f:	89 d6                	mov    %edx,%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
f0100941:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf is a function so init after it in case.
	eip = read_eip();
	ebp = read_ebp();

	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f0100946:	85 d2                	test   %edx,%edx
f0100948:	0f 84 cd 00 00 00    	je     f0100a1b <mon_backtrace+0xfa>
	{
		if (debuginfo_eip(eip, &debug_info) >= 0)
f010094e:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100951:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100955:	89 3c 24             	mov    %edi,(%esp)
f0100958:	e8 4f 22 00 00       	call   f0102bac <debuginfo_eip>
f010095d:	85 c0                	test   %eax,%eax
f010095f:	0f 88 a5 00 00 00    	js     f0100a0a <mon_backtrace+0xe9>
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
f0100965:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100968:	89 44 24 08          	mov    %eax,0x8(%esp)
f010096c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010096f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100973:	c7 04 24 0b 3b 10 f0 	movl   $0xf0103b0b,(%esp)
f010097a:	e8 33 21 00 00       	call   f0102ab2 <cprintf>
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f010097f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100983:	7e 24                	jle    f01009a9 <mon_backtrace+0x88>
f0100985:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
f010098a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010098d:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100991:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100995:	c7 04 24 c0 3f 10 f0 	movl   $0xf0103fc0,(%esp)
f010099c:	e8 11 21 00 00       	call   f0102ab2 <cprintf>
	while (ebp != 0)
	{
		if (debuginfo_eip(eip, &debug_info) >= 0)
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f01009a1:	83 c3 01             	add    $0x1,%ebx
f01009a4:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01009a7:	7f e1                	jg     f010098a <mon_backtrace+0x69>
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
			}
			cprintf("+%x -%d\n", eip-debug_info.eip_fn_addr, debug_info.eip_fn_narg);
f01009a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009b0:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01009b3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01009b7:	c7 04 24 c3 3f 10 f0 	movl   $0xf0103fc3,(%esp)
f01009be:	e8 ef 20 00 00       	call   f0102ab2 <cprintf>
		{
			cprintf("debuginfo_eip() failed\n");
			return -1;
		}

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
f01009c3:	8b 46 14             	mov    0x14(%esi),%eax
f01009c6:	89 44 24 18          	mov    %eax,0x18(%esp)
f01009ca:	8b 46 10             	mov    0x10(%esi),%eax
f01009cd:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009d1:	8b 46 0c             	mov    0xc(%esi),%eax
f01009d4:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009d8:	8b 46 08             	mov    0x8(%esi),%eax
f01009db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009df:	8b 46 04             	mov    0x4(%esi),%eax
f01009e2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009ea:	c7 04 24 24 41 10 f0 	movl   $0xf0104124,(%esp)
f01009f1:	e8 bc 20 00 00       	call   f0102ab2 <cprintf>
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
f01009f6:	8b 7e 04             	mov    0x4(%esi),%edi
		ebp = *(unsigned int *)ebp;
f01009f9:	8b 36                	mov    (%esi),%esi
	// cprintf is a function so init after it in case.
	eip = read_eip();
	ebp = read_ebp();

	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f01009fb:	85 f6                	test   %esi,%esi
f01009fd:	0f 85 4b ff ff ff    	jne    f010094e <mon_backtrace+0x2d>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
f0100a03:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a08:	eb 11                	jmp    f0100a1b <mon_backtrace+0xfa>
			}
			cprintf("+%x -%d\n", eip-debug_info.eip_fn_addr, debug_info.eip_fn_narg);
		}
		else
		{
			cprintf("debuginfo_eip() failed\n");
f0100a0a:	c7 04 24 cc 3f 10 f0 	movl   $0xf0103fcc,(%esp)
f0100a11:	e8 9c 20 00 00       	call   f0102ab2 <cprintf>
			return -1;
f0100a16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
}
f0100a1b:	83 c4 4c             	add    $0x4c,%esp
f0100a1e:	5b                   	pop    %ebx
f0100a1f:	5e                   	pop    %esi
f0100a20:	5f                   	pop    %edi
f0100a21:	5d                   	pop    %ebp
f0100a22:	c3                   	ret    
	...

f0100a30 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0100a30:	55                   	push   %ebp
f0100a31:	89 e5                	mov    %esp,%ebp
f0100a33:	83 ec 08             	sub    $0x8,%esp
f0100a36:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100a39:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100a3c:	89 c6                	mov    %eax,%esi
f0100a3e:	89 d1                	mov    %edx,%ecx
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
		boot_freemem = end;
f0100a40:	83 3d d4 65 11 f0 00 	cmpl   $0x0,0xf01165d4

	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	boot_freemem = ROUNDUP(boot_freemem, align);
f0100a47:	b8 10 6a 11 f0       	mov    $0xf0116a10,%eax
f0100a4c:	0f 45 05 d4 65 11 f0 	cmovne 0xf01165d4,%eax
f0100a53:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
f0100a57:	89 d8                	mov    %ebx,%eax
f0100a59:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a5e:	f7 f1                	div    %ecx
f0100a60:	29 d3                	sub    %edx,%ebx
	//	Step 2: save current value of boot_freemem as allocated chunk
	v = boot_freemem;
	//	Step 3: increase boot_freemem to record allocation
	boot_freemem += ROUNDUP(n, align);
f0100a62:	8d 74 0e ff          	lea    -0x1(%esi,%ecx,1),%esi
f0100a66:	89 f0                	mov    %esi,%eax
f0100a68:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a6d:	f7 f1                	div    %ecx
f0100a6f:	29 d6                	sub    %edx,%esi
f0100a71:	01 de                	add    %ebx,%esi
f0100a73:	89 35 d4 65 11 f0    	mov    %esi,0xf01165d4
	//	Step 4: return allocated chunk
	return v;
}
f0100a79:	89 d8                	mov    %ebx,%eax
f0100a7b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100a7e:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100a81:	89 ec                	mov    %ebp,%esp
f0100a83:	5d                   	pop    %ebp
f0100a84:	c3                   	ret    

f0100a85 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a85:	55                   	push   %ebp
f0100a86:	89 e5                	mov    %esp,%ebp
f0100a88:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a8b:	89 d1                	mov    %edx,%ecx
f0100a8d:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a90:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a98:	f6 c1 01             	test   $0x1,%cl
f0100a9b:	74 57                	je     f0100af4 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a9d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100aa3:	89 c8                	mov    %ecx,%eax
f0100aa5:	c1 e8 0c             	shr    $0xc,%eax
f0100aa8:	3b 05 00 6a 11 f0    	cmp    0xf0116a00,%eax
f0100aae:	72 20                	jb     f0100ad0 <check_va2pa+0x4b>
f0100ab0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100ab4:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f0100abb:	f0 
f0100abc:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0100ac3:	00 
f0100ac4:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0100acb:	e8 c9 f5 ff ff       	call   f0100099 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100ad0:	c1 ea 0c             	shr    $0xc,%edx
f0100ad3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ad9:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100ae0:	89 c2                	mov    %eax,%edx
f0100ae2:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ae5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aea:	85 d2                	test   %edx,%edx
f0100aec:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100af1:	0f 44 c2             	cmove  %edx,%eax
}
f0100af4:	c9                   	leave  
f0100af5:	c3                   	ret    

f0100af6 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0100af6:	55                   	push   %ebp
f0100af7:	89 e5                	mov    %esp,%ebp
f0100af9:	83 ec 18             	sub    $0x18,%esp
f0100afc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100aff:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100b02:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b04:	89 04 24             	mov    %eax,(%esp)
f0100b07:	e8 38 1f 00 00       	call   f0102a44 <mc146818_read>
f0100b0c:	89 c6                	mov    %eax,%esi
f0100b0e:	83 c3 01             	add    $0x1,%ebx
f0100b11:	89 1c 24             	mov    %ebx,(%esp)
f0100b14:	e8 2b 1f 00 00       	call   f0102a44 <mc146818_read>
f0100b19:	c1 e0 08             	shl    $0x8,%eax
f0100b1c:	09 f0                	or     %esi,%eax
}
f0100b1e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100b21:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100b24:	89 ec                	mov    %ebp,%esp
f0100b26:	5d                   	pop    %ebp
f0100b27:	c3                   	ret    

f0100b28 <i386_detect_memory>:

void
i386_detect_memory(void)
{
f0100b28:	55                   	push   %ebp
f0100b29:	89 e5                	mov    %esp,%ebp
f0100b2b:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0100b2e:	b8 15 00 00 00       	mov    $0x15,%eax
f0100b33:	e8 be ff ff ff       	call   f0100af6 <nvram_read>
f0100b38:	c1 e0 0a             	shl    $0xa,%eax
f0100b3b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b40:	a3 c8 65 11 f0       	mov    %eax,0xf01165c8
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0100b45:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b4a:	e8 a7 ff ff ff       	call   f0100af6 <nvram_read>
f0100b4f:	c1 e0 0a             	shl    $0xa,%eax
f0100b52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b57:	a3 cc 65 11 f0       	mov    %eax,0xf01165cc

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0100b5c:	85 c0                	test   %eax,%eax
f0100b5e:	74 0c                	je     f0100b6c <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0100b60:	05 00 00 10 00       	add    $0x100000,%eax
f0100b65:	a3 d0 65 11 f0       	mov    %eax,0xf01165d0
f0100b6a:	eb 0a                	jmp    f0100b76 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0100b6c:	a1 c8 65 11 f0       	mov    0xf01165c8,%eax
f0100b71:	a3 d0 65 11 f0       	mov    %eax,0xf01165d0

	npage = maxpa / PGSIZE;
f0100b76:	a1 d0 65 11 f0       	mov    0xf01165d0,%eax
f0100b7b:	89 c2                	mov    %eax,%edx
f0100b7d:	c1 ea 0c             	shr    $0xc,%edx
f0100b80:	89 15 00 6a 11 f0    	mov    %edx,0xf0116a00

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100b86:	c1 e8 0a             	shr    $0xa,%eax
f0100b89:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b8d:	c7 04 24 e8 41 10 f0 	movl   $0xf01041e8,(%esp)
f0100b94:	e8 19 1f 00 00       	call   f0102ab2 <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100b99:	a1 cc 65 11 f0       	mov    0xf01165cc,%eax
f0100b9e:	c1 e8 0a             	shr    $0xa,%eax
f0100ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ba5:	a1 c8 65 11 f0       	mov    0xf01165c8,%eax
f0100baa:	c1 e8 0a             	shr    $0xa,%eax
f0100bad:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bb1:	c7 04 24 13 47 10 f0 	movl   $0xf0104713,(%esp)
f0100bb8:	e8 f5 1e 00 00       	call   f0102ab2 <cprintf>
}
f0100bbd:	c9                   	leave  
f0100bbe:	c3                   	ret    

f0100bbf <page_init>:
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc()
//
void
page_init(void)
{
f0100bbf:	55                   	push   %ebp
f0100bc0:	89 e5                	mov    %esp,%ebp
f0100bc2:	56                   	push   %esi
f0100bc3:	53                   	push   %ebx
f0100bc4:	83 ec 10             	sub    $0x10,%esp
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f0100bc7:	c7 05 d8 65 11 f0 00 	movl   $0x0,0xf01165d8
f0100bce:	00 00 00 
	for (i = 0; i < npage; i++) {
f0100bd1:	83 3d 00 6a 11 f0 00 	cmpl   $0x0,0xf0116a00
f0100bd8:	74 5f                	je     f0100c39 <page_init+0x7a>
f0100bda:	ba 00 00 00 00       	mov    $0x0,%edx
f0100bdf:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f0100be4:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0100be7:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
f0100bee:	8b 1d 0c 6a 11 f0    	mov    0xf0116a0c,%ebx
f0100bf4:	66 c7 44 13 08 00 00 	movw   $0x0,0x8(%ebx,%edx,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100bfb:	8b 0d d8 65 11 f0    	mov    0xf01165d8,%ecx
f0100c01:	89 0c b3             	mov    %ecx,(%ebx,%esi,4)
f0100c04:	85 c9                	test   %ecx,%ecx
f0100c06:	74 11                	je     f0100c19 <page_init+0x5a>
f0100c08:	8b 1d 0c 6a 11 f0    	mov    0xf0116a0c,%ebx
f0100c0e:	01 d3                	add    %edx,%ebx
f0100c10:	8b 0d d8 65 11 f0    	mov    0xf01165d8,%ecx
f0100c16:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100c19:	03 15 0c 6a 11 f0    	add    0xf0116a0c,%edx
f0100c1f:	89 15 d8 65 11 f0    	mov    %edx,0xf01165d8
f0100c25:	c7 42 04 d8 65 11 f0 	movl   $0xf01165d8,0x4(%edx)
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0100c2c:	83 c0 01             	add    $0x1,%eax
f0100c2f:	89 c2                	mov    %eax,%edx
f0100c31:	3b 05 00 6a 11 f0    	cmp    0xf0116a00,%eax
f0100c37:	72 ab                	jb     f0100be4 <page_init+0x25>
	// --pgstart;	// protect IOPHYSMEM
	// pgend->pp_link = pgstart;

	// the second method, slow
	// but can edit the .ref to 1
	pages[0].pp_ref = 1;
f0100c39:	a1 0c 6a 11 f0       	mov    0xf0116a0c,%eax
f0100c3e:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	// remove the first page, where holds Real Mode IDT
	LIST_REMOVE(&pages[0], pp_link);
f0100c44:	8b 10                	mov    (%eax),%edx
f0100c46:	85 d2                	test   %edx,%edx
f0100c48:	74 06                	je     f0100c50 <page_init+0x91>
f0100c4a:	8b 48 04             	mov    0x4(%eax),%ecx
f0100c4d:	89 4a 04             	mov    %ecx,0x4(%edx)
f0100c50:	8b 50 04             	mov    0x4(%eax),%edx
f0100c53:	8b 00                	mov    (%eax),%eax
f0100c55:	89 02                	mov    %eax,(%edx)
	// remove IO hole and kernel, they are tightly connected
	// notice boot_freemem points to the next byte of free mem, and points to higher mem!
	// so after the last calling "boot_alloc", boot_freemem remains the addr of the end addr of kernel pages plus 1
	for (i = IOPHYSMEM; i < PADDR((unsigned int) boot_freemem); i += PGSIZE)
f0100c57:	8b 1d d4 65 11 f0    	mov    0xf01165d4,%ebx
f0100c5d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100c63:	76 52                	jbe    f0100cb7 <page_init+0xf8>
f0100c65:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0100c6b:	81 fb 00 00 0a 00    	cmp    $0xa0000,%ebx
f0100c71:	76 64                	jbe    f0100cd7 <page_init+0x118>
f0100c73:	ba 00 00 0a 00       	mov    $0xa0000,%edx
	{
		pages[i / PGSIZE].pp_ref = 1;
f0100c78:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax
f0100c7e:	85 d2                	test   %edx,%edx
f0100c80:	0f 49 c2             	cmovns %edx,%eax
f0100c83:	c1 f8 0c             	sar    $0xc,%eax
f0100c86:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c89:	c1 e0 02             	shl    $0x2,%eax
f0100c8c:	03 05 0c 6a 11 f0    	add    0xf0116a0c,%eax
f0100c92:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
		LIST_REMOVE(&pages[i / PGSIZE], pp_link);
f0100c98:	8b 08                	mov    (%eax),%ecx
f0100c9a:	85 c9                	test   %ecx,%ecx
f0100c9c:	74 06                	je     f0100ca4 <page_init+0xe5>
f0100c9e:	8b 70 04             	mov    0x4(%eax),%esi
f0100ca1:	89 71 04             	mov    %esi,0x4(%ecx)
f0100ca4:	8b 48 04             	mov    0x4(%eax),%ecx
f0100ca7:	8b 00                	mov    (%eax),%eax
f0100ca9:	89 01                	mov    %eax,(%ecx)
	// remove the first page, where holds Real Mode IDT
	LIST_REMOVE(&pages[0], pp_link);
	// remove IO hole and kernel, they are tightly connected
	// notice boot_freemem points to the next byte of free mem, and points to higher mem!
	// so after the last calling "boot_alloc", boot_freemem remains the addr of the end addr of kernel pages plus 1
	for (i = IOPHYSMEM; i < PADDR((unsigned int) boot_freemem); i += PGSIZE)
f0100cab:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100cb1:	39 da                	cmp    %ebx,%edx
f0100cb3:	72 c3                	jb     f0100c78 <page_init+0xb9>
f0100cb5:	eb 20                	jmp    f0100cd7 <page_init+0x118>
f0100cb7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100cbb:	c7 44 24 08 0c 42 10 	movl   $0xf010420c,0x8(%esp)
f0100cc2:	f0 
f0100cc3:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
f0100cca:	00 
f0100ccb:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0100cd2:	e8 c2 f3 ff ff       	call   f0100099 <_panic>
	{
		pages[i / PGSIZE].pp_ref = 1;
		LIST_REMOVE(&pages[i / PGSIZE], pp_link);
	}
}
f0100cd7:	83 c4 10             	add    $0x10,%esp
f0100cda:	5b                   	pop    %ebx
f0100cdb:	5e                   	pop    %esi
f0100cdc:	5d                   	pop    %ebp
f0100cdd:	c3                   	ret    

f0100cde <page_alloc>:
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented 
int
page_alloc(struct Page **pp_store)
{
f0100cde:	55                   	push   %ebp
f0100cdf:	89 e5                	mov    %esp,%ebp
f0100ce1:	83 ec 18             	sub    $0x18,%esp
f0100ce4:	8b 55 08             	mov    0x8(%ebp),%edx
	// Fill this function in
	if (LIST_FIRST(&page_free_list) != NULL)
f0100ce7:	a1 d8 65 11 f0       	mov    0xf01165d8,%eax
f0100cec:	85 c0                	test   %eax,%eax
f0100cee:	74 38                	je     f0100d28 <page_alloc+0x4a>
	{
		// obtain the first page in page_free_list
		*pp_store = LIST_FIRST(&page_free_list);
f0100cf0:	89 02                	mov    %eax,(%edx)
		// remove the obtained page in page_free_list
		LIST_REMOVE(*pp_store, pp_link);
f0100cf2:	8b 08                	mov    (%eax),%ecx
f0100cf4:	85 c9                	test   %ecx,%ecx
f0100cf6:	74 06                	je     f0100cfe <page_alloc+0x20>
f0100cf8:	8b 40 04             	mov    0x4(%eax),%eax
f0100cfb:	89 41 04             	mov    %eax,0x4(%ecx)
f0100cfe:	8b 02                	mov    (%edx),%eax
f0100d00:	8b 48 04             	mov    0x4(%eax),%ecx
f0100d03:	8b 00                	mov    (%eax),%eax
f0100d05:	89 01                	mov    %eax,(%ecx)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f0100d07:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0100d0e:	00 
f0100d0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d16:	00 
f0100d17:	8b 02                	mov    (%edx),%eax
f0100d19:	89 04 24             	mov    %eax,(%esp)
f0100d1c:	e8 15 29 00 00       	call   f0103636 <memset>
		*pp_store = LIST_FIRST(&page_free_list);
		// remove the obtained page in page_free_list
		LIST_REMOVE(*pp_store, pp_link);
		// init the page structure
		page_initpp(*pp_store);
		return 0;
f0100d21:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d26:	eb 05                	jmp    f0100d2d <page_alloc+0x4f>
	}
	else
	{
		return -E_NO_MEM;
f0100d28:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
}
f0100d2d:	c9                   	leave  
f0100d2e:	c3                   	ret    

f0100d2f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100d2f:	55                   	push   %ebp
f0100d30:	89 e5                	mov    %esp,%ebp
f0100d32:	83 ec 18             	sub    $0x18,%esp
f0100d35:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0100d38:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0100d3d:	74 1c                	je     f0100d5b <page_free+0x2c>
	{
		// in case
		panic("pp->pp_ref != 0, but page_free called");
f0100d3f:	c7 44 24 08 30 42 10 	movl   $0xf0104230,0x8(%esp)
f0100d46:	f0 
f0100d47:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
f0100d4e:	00 
f0100d4f:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0100d56:	e8 3e f3 ff ff       	call   f0100099 <_panic>
	}
	else
	{
		LIST_INSERT_HEAD(&page_free_list, pp, pp_link);
f0100d5b:	8b 15 d8 65 11 f0    	mov    0xf01165d8,%edx
f0100d61:	89 10                	mov    %edx,(%eax)
f0100d63:	85 d2                	test   %edx,%edx
f0100d65:	74 09                	je     f0100d70 <page_free+0x41>
f0100d67:	8b 15 d8 65 11 f0    	mov    0xf01165d8,%edx
f0100d6d:	89 42 04             	mov    %eax,0x4(%edx)
f0100d70:	a3 d8 65 11 f0       	mov    %eax,0xf01165d8
f0100d75:	c7 40 04 d8 65 11 f0 	movl   $0xf01165d8,0x4(%eax)
	}
}
f0100d7c:	c9                   	leave  
f0100d7d:	c3                   	ret    

f0100d7e <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100d7e:	55                   	push   %ebp
f0100d7f:	89 e5                	mov    %esp,%ebp
f0100d81:	83 ec 18             	sub    $0x18,%esp
f0100d84:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100d87:	0f b7 50 08          	movzwl 0x8(%eax),%edx
f0100d8b:	83 ea 01             	sub    $0x1,%edx
f0100d8e:	66 89 50 08          	mov    %dx,0x8(%eax)
f0100d92:	66 85 d2             	test   %dx,%dx
f0100d95:	75 08                	jne    f0100d9f <page_decref+0x21>
		page_free(pp);
f0100d97:	89 04 24             	mov    %eax,(%esp)
f0100d9a:	e8 90 ff ff ff       	call   f0100d2f <page_free>
}
f0100d9f:	c9                   	leave  
f0100da0:	c3                   	ret    

f0100da1 <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100da1:	55                   	push   %ebp
f0100da2:	89 e5                	mov    %esp,%ebp
f0100da4:	56                   	push   %esi
f0100da5:	53                   	push   %ebx
f0100da6:	83 ec 20             	sub    $0x20,%esp
f0100da9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// new_pg doesn't need an initialization, because
	// it will be casted to the existing space
	struct Page *new_pt;
	// attention to the priority of operations
	// PTE_P means whether it is there in memory
	if ((pgdir[PDX(va)] & PTE_P) != 0)
f0100dac:	89 f3                	mov    %esi,%ebx
f0100dae:	c1 eb 16             	shr    $0x16,%ebx
f0100db1:	c1 e3 02             	shl    $0x2,%ebx
f0100db4:	03 5d 08             	add    0x8(%ebp),%ebx
f0100db7:	8b 03                	mov    (%ebx),%eax
f0100db9:	a8 01                	test   $0x1,%al
f0100dbb:	74 47                	je     f0100e04 <pgdir_walk+0x63>
		// and page dir is a page itself, so PTE_ADDR is
		// needed to get the addr of phys page va pointing to.
		// that is the addr of page table
		// remember, pt_addr is a ptr to pte
		// we got ptr to pte through va, and got va through ptr to pte.
		pt_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100dbd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100dc2:	89 c2                	mov    %eax,%edx
f0100dc4:	c1 ea 0c             	shr    $0xc,%edx
f0100dc7:	3b 15 00 6a 11 f0    	cmp    0xf0116a00,%edx
f0100dcd:	72 20                	jb     f0100def <pgdir_walk+0x4e>
f0100dcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dd3:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f0100dda:	f0 
f0100ddb:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
f0100de2:	00 
f0100de3:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0100dea:	e8 aa f2 ff ff       	call   f0100099 <_panic>
		// now it's time to get final pa through va
		// and remember, pt_addr is an array of pointer to phsy pages
		return &pt_addr[PTX(va)];
f0100def:	c1 ee 0a             	shr    $0xa,%esi
f0100df2:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100df8:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100dff:	e9 ec 00 00 00       	jmp    f0100ef0 <pgdir_walk+0x14f>
	}
	else
	{
		if (create == 0)
f0100e04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e08:	0f 84 d6 00 00 00    	je     f0100ee4 <pgdir_walk+0x143>
			return NULL;
		}
		else
		{
			// allocate a new page table
			if (page_alloc(&new_pt) == 0)
f0100e0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100e11:	89 04 24             	mov    %eax,(%esp)
f0100e14:	e8 c5 fe ff ff       	call   f0100cde <page_alloc>
f0100e19:	85 c0                	test   %eax,%eax
f0100e1b:	0f 85 ca 00 00 00    	jne    f0100eeb <pgdir_walk+0x14a>
			{
				new_pt->pp_ref = 1;
f0100e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e24:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100e2a:	2b 05 0c 6a 11 f0    	sub    0xf0116a0c,%eax
f0100e30:	c1 f8 02             	sar    $0x2,%eax
f0100e33:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100e39:	c1 e0 0c             	shl    $0xc,%eax
				// new page table need to be cleared or a "pa2page" panic
				// or an assertion failed about "check that new page tables get cleared"
				memset(KADDR(page2pa(new_pt)), 0, PGSIZE);
f0100e3c:	89 c2                	mov    %eax,%edx
f0100e3e:	c1 ea 0c             	shr    $0xc,%edx
f0100e41:	3b 15 00 6a 11 f0    	cmp    0xf0116a00,%edx
f0100e47:	72 20                	jb     f0100e69 <pgdir_walk+0xc8>
f0100e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e4d:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f0100e54:	f0 
f0100e55:	c7 44 24 04 5a 02 00 	movl   $0x25a,0x4(%esp)
f0100e5c:	00 
f0100e5d:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0100e64:	e8 30 f2 ff ff       	call   f0100099 <_panic>
f0100e69:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e70:	00 
f0100e71:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e78:	00 
f0100e79:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e7e:	89 04 24             	mov    %eax,(%esp)
f0100e81:	e8 b0 27 00 00       	call   f0103636 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e89:	2b 05 0c 6a 11 f0    	sub    0xf0116a0c,%eax
f0100e8f:	c1 f8 02             	sar    $0x2,%eax
f0100e92:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100e98:	c1 e0 0c             	shl    $0xc,%eax
				// update the pgdir
				// P, present in the memory
				// W, writable; U, user
				// PTE_U must be here; or GP arises when debuggin user process
				pgdir[PDX(va)] = page2pa(new_pt) | PTE_P | PTE_W | PTE_U;
f0100e9b:	83 c8 07             	or     $0x7,%eax
f0100e9e:	89 03                	mov    %eax,(%ebx)
				// then the same with the condition when page table exists in the dir
				pt_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100ea0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ea5:	89 c2                	mov    %eax,%edx
f0100ea7:	c1 ea 0c             	shr    $0xc,%edx
f0100eaa:	3b 15 00 6a 11 f0    	cmp    0xf0116a00,%edx
f0100eb0:	72 20                	jb     f0100ed2 <pgdir_walk+0x131>
f0100eb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100eb6:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f0100ebd:	f0 
f0100ebe:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
f0100ec5:	00 
f0100ec6:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0100ecd:	e8 c7 f1 ff ff       	call   f0100099 <_panic>
				return &pt_addr[PTX(va)];
f0100ed2:	c1 ee 0a             	shr    $0xa,%esi
f0100ed5:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100edb:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100ee2:	eb 0c                	jmp    f0100ef0 <pgdir_walk+0x14f>
	}
	else
	{
		if (create == 0)
		{
			return NULL;
f0100ee4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee9:	eb 05                	jmp    f0100ef0 <pgdir_walk+0x14f>
				pt_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
				return &pt_addr[PTX(va)];
			}
			else
			{
				return NULL;
f0100eeb:	b8 00 00 00 00       	mov    $0x0,%eax
			}
		}
	}
}
f0100ef0:	83 c4 20             	add    $0x20,%esp
f0100ef3:	5b                   	pop    %ebx
f0100ef4:	5e                   	pop    %esi
f0100ef5:	5d                   	pop    %ebp
f0100ef6:	c3                   	ret    

f0100ef7 <boot_map_segment>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0100ef7:	55                   	push   %ebp
f0100ef8:	89 e5                	mov    %esp,%ebp
f0100efa:	57                   	push   %edi
f0100efb:	56                   	push   %esi
f0100efc:	53                   	push   %ebx
f0100efd:	83 ec 2c             	sub    $0x2c,%esp
f0100f00:	89 c7                	mov    %eax,%edi
f0100f02:	89 d6                	mov    %edx,%esi
	// Fill this function in
	// better than int i; no worry about overflow.
	unsigned int i;
	pte_t *pt_addr;
	// size in stack, no worry.
	size = ROUNDUP(size, PGSIZE);
f0100f04:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
	// never be reached. the reason is that it is called by boot,
	// there should not be any protected la allocated, and
	// the os programmer should be very careful so that 
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
f0100f0a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100f10:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f13:	74 5a                	je     f0100f6f <boot_map_segment+0x78>
f0100f15:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (pt_addr == NULL)
		{
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pt_addr = (pa+i) | perm | PTE_P;
f0100f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f1d:	83 c8 01             	or     $0x1,%eax
f0100f20:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
	{
		// get the page addr
		pt_addr = pgdir_walk(pgdir, (void *)(la+i), 1);
f0100f23:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100f2a:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
f0100f2b:	8d 04 33             	lea    (%ebx,%esi,1),%eax
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
	{
		// get the page addr
		pt_addr = pgdir_walk(pgdir, (void *)(la+i), 1);
f0100f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f32:	89 3c 24             	mov    %edi,(%esp)
f0100f35:	e8 67 fe ff ff       	call   f0100da1 <pgdir_walk>
		if (pt_addr == NULL)
f0100f3a:	85 c0                	test   %eax,%eax
f0100f3c:	75 1c                	jne    f0100f5a <boot_map_segment+0x63>
		{
			panic("failed to map la to pa in boot_map_segment()");
f0100f3e:	c7 44 24 08 58 42 10 	movl   $0xf0104258,0x8(%esp)
f0100f45:	f0 
f0100f46:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f0100f4d:	00 
f0100f4e:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0100f55:	e8 3f f1 ff ff       	call   f0100099 <_panic>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
f0100f5a:	8b 55 08             	mov    0x8(%ebp),%edx
f0100f5d:	01 da                	add    %ebx,%edx
		if (pt_addr == NULL)
		{
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pt_addr = (pa+i) | perm | PTE_P;
f0100f5f:	0b 55 e0             	or     -0x20(%ebp),%edx
f0100f62:	89 10                	mov    %edx,(%eax)
	// never be reached. the reason is that it is called by boot,
	// there should not be any protected la allocated, and
	// the os programmer should be very careful so that 
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
f0100f64:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100f6a:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0100f6d:	77 b4                	ja     f0100f23 <boot_map_segment+0x2c>
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pt_addr = (pa+i) | perm | PTE_P;
	}
}
f0100f6f:	83 c4 2c             	add    $0x2c,%esp
f0100f72:	5b                   	pop    %ebx
f0100f73:	5e                   	pop    %esi
f0100f74:	5f                   	pop    %edi
f0100f75:	5d                   	pop    %ebp
f0100f76:	c3                   	ret    

f0100f77 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f77:	55                   	push   %ebp
f0100f78:	89 e5                	mov    %esp,%ebp
f0100f7a:	53                   	push   %ebx
f0100f7b:	83 ec 14             	sub    $0x14,%esp
f0100f7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	// never create a new page table
	pte_t *pt_addr = pgdir_walk(pgdir, va, 0);
f0100f81:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f88:	00 
f0100f89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f90:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f93:	89 04 24             	mov    %eax,(%esp)
f0100f96:	e8 06 fe ff ff       	call   f0100da1 <pgdir_walk>
	if (pt_addr == NULL)
f0100f9b:	85 c0                	test   %eax,%eax
f0100f9d:	74 3d                	je     f0100fdc <page_lookup+0x65>
	{
		return NULL;
	}
	else
	{
		if (pte_store)
f0100f9f:	85 db                	test   %ebx,%ebx
f0100fa1:	74 02                	je     f0100fa5 <page_lookup+0x2e>
		{
			// be careful to read the header comment
			*pte_store = pt_addr;
f0100fa3:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100fa5:	8b 00                	mov    (%eax),%eax
f0100fa7:	c1 e8 0c             	shr    $0xc,%eax
f0100faa:	3b 05 00 6a 11 f0    	cmp    0xf0116a00,%eax
f0100fb0:	72 1c                	jb     f0100fce <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0100fb2:	c7 44 24 08 88 42 10 	movl   $0xf0104288,0x8(%esp)
f0100fb9:	f0 
f0100fba:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0100fc1:	00 
f0100fc2:	c7 04 24 2f 47 10 f0 	movl   $0xf010472f,(%esp)
f0100fc9:	e8 cb f0 ff ff       	call   f0100099 <_panic>
	return &pages[PPN(pa)];
f0100fce:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100fd1:	c1 e0 02             	shl    $0x2,%eax
f0100fd4:	03 05 0c 6a 11 f0    	add    0xf0116a0c,%eax
		}
		// pt_addr is ptr to pte, not phsy page addr
		// we need to get pa through ptr to pte, (* is okay)
		// and then get PPN through pa (1), and get page addr
		// through PPN (2); (1) and (2) are done by "pa2page"
		return pa2page(*pt_addr);
f0100fda:	eb 05                	jmp    f0100fe1 <page_lookup+0x6a>
	// Fill this function in
	// never create a new page table
	pte_t *pt_addr = pgdir_walk(pgdir, va, 0);
	if (pt_addr == NULL)
	{
		return NULL;
f0100fdc:	b8 00 00 00 00       	mov    $0x0,%eax
		// and then get PPN through pa (1), and get page addr
		// through PPN (2); (1) and (2) are done by "pa2page"
		return pa2page(*pt_addr);
		// "pa2page(phsyaddr_t pa)" returns &pages[PPN(pa)];
	}
}
f0100fe1:	83 c4 14             	add    $0x14,%esp
f0100fe4:	5b                   	pop    %ebx
f0100fe5:	5d                   	pop    %ebp
f0100fe6:	c3                   	ret    

f0100fe7 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100fe7:	55                   	push   %ebp
f0100fe8:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100fea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fed:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100ff0:	5d                   	pop    %ebp
f0100ff1:	c3                   	ret    

f0100ff2 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100ff2:	55                   	push   %ebp
f0100ff3:	89 e5                	mov    %esp,%ebp
f0100ff5:	83 ec 28             	sub    $0x28,%esp
f0100ff8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100ffb:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100ffe:	8b 75 08             	mov    0x8(%ebp),%esi
f0101001:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// the corresponding pte to set
	pte_t *pt2set;
	// the page found and to unmap
	// and &pg2um is an addr and never equal to 0
	// or it will crash IDT
	struct Page *pg = page_lookup(pgdir, va, &pt2set);
f0101004:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101007:	89 44 24 08          	mov    %eax,0x8(%esp)
f010100b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010100f:	89 34 24             	mov    %esi,(%esp)
f0101012:	e8 60 ff ff ff       	call   f0100f77 <page_lookup>
	if (pg == NULL)
f0101017:	85 c0                	test   %eax,%eax
f0101019:	74 1d                	je     f0101038 <page_remove+0x46>
		return;
	}
	else
	{
		// --ref and if ref == 0 then page_free it
		page_decref(pg);
f010101b:	89 04 24             	mov    %eax,(%esp)
f010101e:	e8 5b fd ff ff       	call   f0100d7e <page_decref>
		// set the pte to zero as asked
		// if code runs here, pte must exist, as pg exists
		*pt2set = 0;
f0101023:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101026:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f010102c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101030:	89 34 24             	mov    %esi,(%esp)
f0101033:	e8 af ff ff ff       	call   f0100fe7 <tlb_invalidate>
	}
}
f0101038:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010103b:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010103e:	89 ec                	mov    %ebp,%esp
f0101040:	5d                   	pop    %ebp
f0101041:	c3                   	ret    

f0101042 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0101042:	55                   	push   %ebp
f0101043:	89 e5                	mov    %esp,%ebp
f0101045:	83 ec 28             	sub    $0x28,%esp
f0101048:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010104b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010104e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101051:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101054:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	// always create a new page table if there isn't
	// which is "necessary, on demand" in the comment
	pte_t *pt_addr = pgdir_walk(pgdir, va, 1);
f0101057:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010105e:	00 
f010105f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101063:	8b 45 08             	mov    0x8(%ebp),%eax
f0101066:	89 04 24             	mov    %eax,(%esp)
f0101069:	e8 33 fd ff ff       	call   f0100da1 <pgdir_walk>
f010106e:	89 c3                	mov    %eax,%ebx
	if (pt_addr == NULL)
f0101070:	85 c0                	test   %eax,%eax
f0101072:	74 4d                	je     f01010c1 <page_insert+0x7f>
		return -E_NO_MEM;
	}
	else
	{
		// increase pp_ref as insertion succeeds
		++(pp->pp_ref);
f0101074:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
		// REMEMBER, pt_addr is a ptr to pte
		// *pt_addr will get the value addressed at pt_addr
		// already a page mapped at va, remove it
		if ((*pt_addr & PTE_P) != 0)
f0101079:	f6 00 01             	testb  $0x1,(%eax)
f010107c:	74 1e                	je     f010109c <page_insert+0x5a>
		{
			page_remove(pgdir, va);
f010107e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101082:	8b 45 08             	mov    0x8(%ebp),%eax
f0101085:	89 04 24             	mov    %eax,(%esp)
f0101088:	e8 65 ff ff ff       	call   f0100ff2 <page_remove>
			// The TLB must be invalidated 
			// if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f010108d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101091:	8b 45 08             	mov    0x8(%ebp),%eax
f0101094:	89 04 24             	mov    %eax,(%esp)
f0101097:	e8 4b ff ff ff       	call   f0100fe7 <tlb_invalidate>
		}
		// again, through pt_addr we should get pa
		*pt_addr = page2pa(pp) | perm | PTE_P;
f010109c:	8b 55 14             	mov    0x14(%ebp),%edx
f010109f:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01010a2:	2b 35 0c 6a 11 f0    	sub    0xf0116a0c,%esi
f01010a8:	c1 fe 02             	sar    $0x2,%esi
f01010ab:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01010b1:	c1 e0 0c             	shl    $0xc,%eax
f01010b4:	89 d6                	mov    %edx,%esi
f01010b6:	09 c6                	or     %eax,%esi
f01010b8:	89 33                	mov    %esi,(%ebx)
		return 0;
f01010ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01010bf:	eb 05                	jmp    f01010c6 <page_insert+0x84>
	// always create a new page table if there isn't
	// which is "necessary, on demand" in the comment
	pte_t *pt_addr = pgdir_walk(pgdir, va, 1);
	if (pt_addr == NULL)
	{
		return -E_NO_MEM;
f01010c1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		}
		// again, through pt_addr we should get pa
		*pt_addr = page2pa(pp) | perm | PTE_P;
		return 0;
	}
}
f01010c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01010c9:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01010cc:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01010cf:	89 ec                	mov    %ebp,%esp
f01010d1:	5d                   	pop    %ebp
f01010d2:	c3                   	ret    

f01010d3 <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f01010d3:	55                   	push   %ebp
f01010d4:	89 e5                	mov    %esp,%ebp
f01010d6:	57                   	push   %edi
f01010d7:	56                   	push   %esi
f01010d8:	53                   	push   %ebx
f01010d9:	83 ec 4c             	sub    $0x4c,%esp
	// Delete this line:
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f01010dc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01010e1:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010e6:	e8 45 f9 ff ff       	call   f0100a30 <boot_alloc>
f01010eb:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f01010ed:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01010f4:	00 
f01010f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01010fc:	00 
f01010fd:	89 04 24             	mov    %eax,(%esp)
f0101100:	e8 31 25 00 00       	call   f0103636 <memset>
	boot_pgdir = pgdir;
f0101105:	89 1d 08 6a 11 f0    	mov    %ebx,0xf0116a08
	boot_cr3 = PADDR(pgdir);
f010110b:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101111:	77 20                	ja     f0101133 <i386_vm_init+0x60>
f0101113:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101117:	c7 44 24 08 0c 42 10 	movl   $0xf010420c,0x8(%esp)
f010111e:	f0 
f010111f:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
f0101126:	00 
f0101127:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010112e:	e8 66 ef ff ff       	call   f0100099 <_panic>
f0101133:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0101139:	a3 04 6a 11 f0       	mov    %eax,0xf0116a04
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f010113e:	89 c2                	mov    %eax,%edx
f0101140:	83 ca 03             	or     $0x3,%edx
f0101143:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f0101149:	83 c8 05             	or     $0x5,%eax
f010114c:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// The kernel uses this structure to keep track of physical pages;
	// 'npage' equals the number of physical pages in memory.  User-level
	// programs will get read-only access to the array as well.
	// You must allocate the array yourself.
	// Your code goes here: 
	pages = (struct Page *)boot_alloc(npage*sizeof(struct Page), PGSIZE);
f0101152:	a1 00 6a 11 f0       	mov    0xf0116a00,%eax
f0101157:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010115a:	c1 e0 02             	shl    $0x2,%eax
f010115d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101162:	e8 c9 f8 ff ff       	call   f0100a30 <boot_alloc>
f0101167:	a3 0c 6a 11 f0       	mov    %eax,0xf0116a0c
	//////////////////////////////////////////////////////////////////////
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_segment or page_insert
	page_init();
f010116c:	e8 4e fa ff ff       	call   f0100bbf <page_init>
	struct Page_list fl;
	
        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f0101171:	a1 d8 65 11 f0       	mov    0xf01165d8,%eax
f0101176:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101179:	85 c0                	test   %eax,%eax
f010117b:	0f 84 89 00 00 00    	je     f010120a <i386_vm_init+0x137>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101181:	2b 05 0c 6a 11 f0    	sub    0xf0116a0c,%eax
f0101187:	c1 f8 02             	sar    $0x2,%eax
f010118a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101190:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101193:	89 c2                	mov    %eax,%edx
f0101195:	c1 ea 0c             	shr    $0xc,%edx
f0101198:	3b 15 00 6a 11 f0    	cmp    0xf0116a00,%edx
f010119e:	72 41                	jb     f01011e1 <i386_vm_init+0x10e>
f01011a0:	eb 1f                	jmp    f01011c1 <i386_vm_init+0xee>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01011a2:	2b 05 0c 6a 11 f0    	sub    0xf0116a0c,%eax
f01011a8:	c1 f8 02             	sar    $0x2,%eax
f01011ab:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01011b1:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01011b4:	89 c2                	mov    %eax,%edx
f01011b6:	c1 ea 0c             	shr    $0xc,%edx
f01011b9:	3b 15 00 6a 11 f0    	cmp    0xf0116a00,%edx
f01011bf:	72 20                	jb     f01011e1 <i386_vm_init+0x10e>
f01011c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011c5:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f01011cc:	f0 
f01011cd:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01011d4:	00 
f01011d5:	c7 04 24 2f 47 10 f0 	movl   $0xf010472f,(%esp)
f01011dc:	e8 b8 ee ff ff       	call   f0100099 <_panic>
		memset(page2kva(pp0), 0x97, 128);
f01011e1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01011e8:	00 
f01011e9:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01011f0:	00 
f01011f1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011f6:	89 04 24             	mov    %eax,(%esp)
f01011f9:	e8 38 24 00 00       	call   f0103636 <memset>
	struct Page_list fl;
	
        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f01011fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101201:	8b 00                	mov    (%eax),%eax
f0101203:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101206:	85 c0                	test   %eax,%eax
f0101208:	75 98                	jne    f01011a2 <i386_vm_init+0xcf>
		memset(page2kva(pp0), 0x97, 128);

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f010120a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101211:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0101218:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	assert(page_alloc(&pp0) == 0);
f010121f:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101222:	89 04 24             	mov    %eax,(%esp)
f0101225:	e8 b4 fa ff ff       	call   f0100cde <page_alloc>
f010122a:	85 c0                	test   %eax,%eax
f010122c:	74 24                	je     f0101252 <i386_vm_init+0x17f>
f010122e:	c7 44 24 0c 3d 47 10 	movl   $0xf010473d,0xc(%esp)
f0101235:	f0 
f0101236:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f010123d:	f0 
f010123e:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
f0101245:	00 
f0101246:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010124d:	e8 47 ee ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101252:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101255:	89 04 24             	mov    %eax,(%esp)
f0101258:	e8 81 fa ff ff       	call   f0100cde <page_alloc>
f010125d:	85 c0                	test   %eax,%eax
f010125f:	74 24                	je     f0101285 <i386_vm_init+0x1b2>
f0101261:	c7 44 24 0c 68 47 10 	movl   $0xf0104768,0xc(%esp)
f0101268:	f0 
f0101269:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101270:	f0 
f0101271:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0101278:	00 
f0101279:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101280:	e8 14 ee ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101285:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101288:	89 04 24             	mov    %eax,(%esp)
f010128b:	e8 4e fa ff ff       	call   f0100cde <page_alloc>
f0101290:	85 c0                	test   %eax,%eax
f0101292:	74 24                	je     f01012b8 <i386_vm_init+0x1e5>
f0101294:	c7 44 24 0c 7e 47 10 	movl   $0xf010477e,0xc(%esp)
f010129b:	f0 
f010129c:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01012a3:	f0 
f01012a4:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f01012ab:	00 
f01012ac:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01012b3:	e8 e1 ed ff ff       	call   f0100099 <_panic>

	assert(pp0);
f01012b8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012bb:	85 c9                	test   %ecx,%ecx
f01012bd:	75 24                	jne    f01012e3 <i386_vm_init+0x210>
f01012bf:	c7 44 24 0c a2 47 10 	movl   $0xf01047a2,0xc(%esp)
f01012c6:	f0 
f01012c7:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01012ce:	f0 
f01012cf:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f01012d6:	00 
f01012d7:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01012de:	e8 b6 ed ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01012e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012e6:	85 d2                	test   %edx,%edx
f01012e8:	74 04                	je     f01012ee <i386_vm_init+0x21b>
f01012ea:	39 d1                	cmp    %edx,%ecx
f01012ec:	75 24                	jne    f0101312 <i386_vm_init+0x23f>
f01012ee:	c7 44 24 0c 94 47 10 	movl   $0xf0104794,0xc(%esp)
f01012f5:	f0 
f01012f6:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01012fd:	f0 
f01012fe:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
f0101305:	00 
f0101306:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010130d:	e8 87 ed ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101312:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101315:	85 c0                	test   %eax,%eax
f0101317:	74 09                	je     f0101322 <i386_vm_init+0x24f>
f0101319:	39 c2                	cmp    %eax,%edx
f010131b:	74 05                	je     f0101322 <i386_vm_init+0x24f>
f010131d:	39 c1                	cmp    %eax,%ecx
f010131f:	90                   	nop
f0101320:	75 24                	jne    f0101346 <i386_vm_init+0x273>
f0101322:	c7 44 24 0c a8 42 10 	movl   $0xf01042a8,0xc(%esp)
f0101329:	f0 
f010132a:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101331:	f0 
f0101332:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0101339:	00 
f010133a:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101341:	e8 53 ed ff ff       	call   f0100099 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101346:	8b 3d 0c 6a 11 f0    	mov    0xf0116a0c,%edi
        assert(page2pa(pp0) < npage*PGSIZE);
f010134c:	8b 35 00 6a 11 f0    	mov    0xf0116a00,%esi
f0101352:	c1 e6 0c             	shl    $0xc,%esi
f0101355:	29 f9                	sub    %edi,%ecx
f0101357:	c1 f9 02             	sar    $0x2,%ecx
f010135a:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101360:	c1 e1 0c             	shl    $0xc,%ecx
f0101363:	39 f1                	cmp    %esi,%ecx
f0101365:	72 24                	jb     f010138b <i386_vm_init+0x2b8>
f0101367:	c7 44 24 0c a6 47 10 	movl   $0xf01047a6,0xc(%esp)
f010136e:	f0 
f010136f:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101376:	f0 
f0101377:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f010137e:	00 
f010137f:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101386:	e8 0e ed ff ff       	call   f0100099 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010138b:	29 fa                	sub    %edi,%edx
f010138d:	c1 fa 02             	sar    $0x2,%edx
f0101390:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101396:	c1 e2 0c             	shl    $0xc,%edx
        assert(page2pa(pp1) < npage*PGSIZE);
f0101399:	39 d6                	cmp    %edx,%esi
f010139b:	77 24                	ja     f01013c1 <i386_vm_init+0x2ee>
f010139d:	c7 44 24 0c c2 47 10 	movl   $0xf01047c2,0xc(%esp)
f01013a4:	f0 
f01013a5:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01013ac:	f0 
f01013ad:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
f01013b4:	00 
f01013b5:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01013bc:	e8 d8 ec ff ff       	call   f0100099 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01013c1:	29 f8                	sub    %edi,%eax
f01013c3:	c1 f8 02             	sar    $0x2,%eax
f01013c6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01013cc:	c1 e0 0c             	shl    $0xc,%eax
        assert(page2pa(pp2) < npage*PGSIZE);
f01013cf:	39 c6                	cmp    %eax,%esi
f01013d1:	77 24                	ja     f01013f7 <i386_vm_init+0x324>
f01013d3:	c7 44 24 0c de 47 10 	movl   $0xf01047de,0xc(%esp)
f01013da:	f0 
f01013db:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01013e2:	f0 
f01013e3:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f01013ea:	00 
f01013eb:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01013f2:	e8 a2 ec ff ff       	call   f0100099 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013f7:	8b 35 d8 65 11 f0    	mov    0xf01165d8,%esi
	LIST_INIT(&page_free_list);
f01013fd:	c7 05 d8 65 11 f0 00 	movl   $0x0,0xf01165d8
f0101404:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101407:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f010140a:	89 04 24             	mov    %eax,(%esp)
f010140d:	e8 cc f8 ff ff       	call   f0100cde <page_alloc>
f0101412:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101415:	74 24                	je     f010143b <i386_vm_init+0x368>
f0101417:	c7 44 24 0c fa 47 10 	movl   $0xf01047fa,0xc(%esp)
f010141e:	f0 
f010141f:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101426:	f0 
f0101427:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f010142e:	00 
f010142f:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101436:	e8 5e ec ff ff       	call   f0100099 <_panic>

        // free and re-allocate?
        page_free(pp0);
f010143b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010143e:	89 04 24             	mov    %eax,(%esp)
f0101441:	e8 e9 f8 ff ff       	call   f0100d2f <page_free>
        page_free(pp1);
f0101446:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101449:	89 04 24             	mov    %eax,(%esp)
f010144c:	e8 de f8 ff ff       	call   f0100d2f <page_free>
        page_free(pp2);
f0101451:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101454:	89 04 24             	mov    %eax,(%esp)
f0101457:	e8 d3 f8 ff ff       	call   f0100d2f <page_free>
	pp0 = pp1 = pp2 = 0;
f010145c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101463:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010146a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101471:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101474:	89 04 24             	mov    %eax,(%esp)
f0101477:	e8 62 f8 ff ff       	call   f0100cde <page_alloc>
f010147c:	85 c0                	test   %eax,%eax
f010147e:	74 24                	je     f01014a4 <i386_vm_init+0x3d1>
f0101480:	c7 44 24 0c 3d 47 10 	movl   $0xf010473d,0xc(%esp)
f0101487:	f0 
f0101488:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f010148f:	f0 
f0101490:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f0101497:	00 
f0101498:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010149f:	e8 f5 eb ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp1) == 0);
f01014a4:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01014a7:	89 04 24             	mov    %eax,(%esp)
f01014aa:	e8 2f f8 ff ff       	call   f0100cde <page_alloc>
f01014af:	85 c0                	test   %eax,%eax
f01014b1:	74 24                	je     f01014d7 <i386_vm_init+0x404>
f01014b3:	c7 44 24 0c 68 47 10 	movl   $0xf0104768,0xc(%esp)
f01014ba:	f0 
f01014bb:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01014c2:	f0 
f01014c3:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f01014ca:	00 
f01014cb:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01014d2:	e8 c2 eb ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp2) == 0);
f01014d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01014da:	89 04 24             	mov    %eax,(%esp)
f01014dd:	e8 fc f7 ff ff       	call   f0100cde <page_alloc>
f01014e2:	85 c0                	test   %eax,%eax
f01014e4:	74 24                	je     f010150a <i386_vm_init+0x437>
f01014e6:	c7 44 24 0c 7e 47 10 	movl   $0xf010477e,0xc(%esp)
f01014ed:	f0 
f01014ee:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01014f5:	f0 
f01014f6:	c7 44 24 04 45 01 00 	movl   $0x145,0x4(%esp)
f01014fd:	00 
f01014fe:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101505:	e8 8f eb ff ff       	call   f0100099 <_panic>
	assert(pp0);
f010150a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010150d:	85 d2                	test   %edx,%edx
f010150f:	75 24                	jne    f0101535 <i386_vm_init+0x462>
f0101511:	c7 44 24 0c a2 47 10 	movl   $0xf01047a2,0xc(%esp)
f0101518:	f0 
f0101519:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101520:	f0 
f0101521:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
f0101528:	00 
f0101529:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101530:	e8 64 eb ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f0101535:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101538:	85 c9                	test   %ecx,%ecx
f010153a:	74 04                	je     f0101540 <i386_vm_init+0x46d>
f010153c:	39 ca                	cmp    %ecx,%edx
f010153e:	75 24                	jne    f0101564 <i386_vm_init+0x491>
f0101540:	c7 44 24 0c 94 47 10 	movl   $0xf0104794,0xc(%esp)
f0101547:	f0 
f0101548:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f010154f:	f0 
f0101550:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
f0101557:	00 
f0101558:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010155f:	e8 35 eb ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101564:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101567:	85 c0                	test   %eax,%eax
f0101569:	74 08                	je     f0101573 <i386_vm_init+0x4a0>
f010156b:	39 c1                	cmp    %eax,%ecx
f010156d:	74 04                	je     f0101573 <i386_vm_init+0x4a0>
f010156f:	39 c2                	cmp    %eax,%edx
f0101571:	75 24                	jne    f0101597 <i386_vm_init+0x4c4>
f0101573:	c7 44 24 0c a8 42 10 	movl   $0xf01042a8,0xc(%esp)
f010157a:	f0 
f010157b:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101582:	f0 
f0101583:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f010158a:	00 
f010158b:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101592:	e8 02 eb ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101597:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f010159a:	89 04 24             	mov    %eax,(%esp)
f010159d:	e8 3c f7 ff ff       	call   f0100cde <page_alloc>
f01015a2:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01015a5:	74 24                	je     f01015cb <i386_vm_init+0x4f8>
f01015a7:	c7 44 24 0c fa 47 10 	movl   $0xf01047fa,0xc(%esp)
f01015ae:	f0 
f01015af:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01015b6:	f0 
f01015b7:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
f01015be:	00 
f01015bf:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01015c6:	e8 ce ea ff ff       	call   f0100099 <_panic>

	// give free list back
	page_free_list = fl;
f01015cb:	89 35 d8 65 11 f0    	mov    %esi,0xf01165d8

	// free the pages we took
	page_free(pp0);
f01015d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01015d4:	89 04 24             	mov    %eax,(%esp)
f01015d7:	e8 53 f7 ff ff       	call   f0100d2f <page_free>
	page_free(pp1);
f01015dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01015df:	89 04 24             	mov    %eax,(%esp)
f01015e2:	e8 48 f7 ff ff       	call   f0100d2f <page_free>
	page_free(pp2);
f01015e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015ea:	89 04 24             	mov    %eax,(%esp)
f01015ed:	e8 3d f7 ff ff       	call   f0100d2f <page_free>

	cprintf("check_page_alloc() succeeded!\n");
f01015f2:	c7 04 24 c8 42 10 f0 	movl   $0xf01042c8,(%esp)
f01015f9:	e8 b4 14 00 00       	call   f0102ab2 <cprintf>
	pte_t *ptep, *ptep1;
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f01015fe:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101605:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010160c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101613:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101616:	89 04 24             	mov    %eax,(%esp)
f0101619:	e8 c0 f6 ff ff       	call   f0100cde <page_alloc>
f010161e:	85 c0                	test   %eax,%eax
f0101620:	74 24                	je     f0101646 <i386_vm_init+0x573>
f0101622:	c7 44 24 0c 3d 47 10 	movl   $0xf010473d,0xc(%esp)
f0101629:	f0 
f010162a:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101631:	f0 
f0101632:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101639:	00 
f010163a:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101641:	e8 53 ea ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101646:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101649:	89 04 24             	mov    %eax,(%esp)
f010164c:	e8 8d f6 ff ff       	call   f0100cde <page_alloc>
f0101651:	85 c0                	test   %eax,%eax
f0101653:	74 24                	je     f0101679 <i386_vm_init+0x5a6>
f0101655:	c7 44 24 0c 68 47 10 	movl   $0xf0104768,0xc(%esp)
f010165c:	f0 
f010165d:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101664:	f0 
f0101665:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f010166c:	00 
f010166d:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101674:	e8 20 ea ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101679:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f010167c:	89 04 24             	mov    %eax,(%esp)
f010167f:	e8 5a f6 ff ff       	call   f0100cde <page_alloc>
f0101684:	85 c0                	test   %eax,%eax
f0101686:	74 24                	je     f01016ac <i386_vm_init+0x5d9>
f0101688:	c7 44 24 0c 7e 47 10 	movl   $0xf010477e,0xc(%esp)
f010168f:	f0 
f0101690:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101697:	f0 
f0101698:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f010169f:	00 
f01016a0:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01016a7:	e8 ed e9 ff ff       	call   f0100099 <_panic>

	assert(pp0);
f01016ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01016af:	85 d2                	test   %edx,%edx
f01016b1:	75 24                	jne    f01016d7 <i386_vm_init+0x604>
f01016b3:	c7 44 24 0c a2 47 10 	movl   $0xf01047a2,0xc(%esp)
f01016ba:	f0 
f01016bb:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01016c2:	f0 
f01016c3:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01016ca:	00 
f01016cb:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01016d2:	e8 c2 e9 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01016d7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01016da:	85 c9                	test   %ecx,%ecx
f01016dc:	74 04                	je     f01016e2 <i386_vm_init+0x60f>
f01016de:	39 ca                	cmp    %ecx,%edx
f01016e0:	75 24                	jne    f0101706 <i386_vm_init+0x633>
f01016e2:	c7 44 24 0c 94 47 10 	movl   $0xf0104794,0xc(%esp)
f01016e9:	f0 
f01016ea:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01016f1:	f0 
f01016f2:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f01016f9:	00 
f01016fa:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101701:	e8 93 e9 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101706:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101709:	85 c0                	test   %eax,%eax
f010170b:	74 08                	je     f0101715 <i386_vm_init+0x642>
f010170d:	39 c1                	cmp    %eax,%ecx
f010170f:	74 04                	je     f0101715 <i386_vm_init+0x642>
f0101711:	39 c2                	cmp    %eax,%edx
f0101713:	75 24                	jne    f0101739 <i386_vm_init+0x666>
f0101715:	c7 44 24 0c a8 42 10 	movl   $0xf01042a8,0xc(%esp)
f010171c:	f0 
f010171d:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101724:	f0 
f0101725:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f010172c:	00 
f010172d:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101734:	e8 60 e9 ff ff       	call   f0100099 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101739:	a1 d8 65 11 f0       	mov    0xf01165d8,%eax
f010173e:	89 45 c0             	mov    %eax,-0x40(%ebp)
	LIST_INIT(&page_free_list);
f0101741:	c7 05 d8 65 11 f0 00 	movl   $0x0,0xf01165d8
f0101748:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010174b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010174e:	89 04 24             	mov    %eax,(%esp)
f0101751:	e8 88 f5 ff ff       	call   f0100cde <page_alloc>
f0101756:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101759:	74 24                	je     f010177f <i386_vm_init+0x6ac>
f010175b:	c7 44 24 0c fa 47 10 	movl   $0xf01047fa,0xc(%esp)
f0101762:	f0 
f0101763:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f010176a:	f0 
f010176b:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0101772:	00 
f0101773:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010177a:	e8 1a e9 ff ff       	call   f0100099 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f010177f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101782:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101786:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010178d:	00 
f010178e:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0101793:	89 04 24             	mov    %eax,(%esp)
f0101796:	e8 dc f7 ff ff       	call   f0100f77 <page_lookup>
f010179b:	85 c0                	test   %eax,%eax
f010179d:	74 24                	je     f01017c3 <i386_vm_init+0x6f0>
f010179f:	c7 44 24 0c e8 42 10 	movl   $0xf01042e8,0xc(%esp)
f01017a6:	f0 
f01017a7:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01017ae:	f0 
f01017af:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f01017b6:	00 
f01017b7:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01017be:	e8 d6 e8 ff ff       	call   f0100099 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f01017c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01017ca:	00 
f01017cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01017d2:	00 
f01017d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017da:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f01017df:	89 04 24             	mov    %eax,(%esp)
f01017e2:	e8 5b f8 ff ff       	call   f0101042 <page_insert>
f01017e7:	85 c0                	test   %eax,%eax
f01017e9:	78 24                	js     f010180f <i386_vm_init+0x73c>
f01017eb:	c7 44 24 0c 20 43 10 	movl   $0xf0104320,0xc(%esp)
f01017f2:	f0 
f01017f3:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01017fa:	f0 
f01017fb:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101802:	00 
f0101803:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010180a:	e8 8a e8 ff ff       	call   f0100099 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010180f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101812:	89 04 24             	mov    %eax,(%esp)
f0101815:	e8 15 f5 ff ff       	call   f0100d2f <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f010181a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101821:	00 
f0101822:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101829:	00 
f010182a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010182d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101831:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0101836:	89 04 24             	mov    %eax,(%esp)
f0101839:	e8 04 f8 ff ff       	call   f0101042 <page_insert>
f010183e:	85 c0                	test   %eax,%eax
f0101840:	74 24                	je     f0101866 <i386_vm_init+0x793>
f0101842:	c7 44 24 0c 4c 43 10 	movl   $0xf010434c,0xc(%esp)
f0101849:	f0 
f010184a:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101851:	f0 
f0101852:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101859:	00 
f010185a:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101861:	e8 33 e8 ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0101866:	8b 35 08 6a 11 f0    	mov    0xf0116a08,%esi
f010186c:	8b 7d dc             	mov    -0x24(%ebp),%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010186f:	8b 15 0c 6a 11 f0    	mov    0xf0116a0c,%edx
f0101875:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0101878:	8b 16                	mov    (%esi),%edx
f010187a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101880:	89 f8                	mov    %edi,%eax
f0101882:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f0101885:	c1 f8 02             	sar    $0x2,%eax
f0101888:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010188e:	c1 e0 0c             	shl    $0xc,%eax
f0101891:	39 c2                	cmp    %eax,%edx
f0101893:	74 24                	je     f01018b9 <i386_vm_init+0x7e6>
f0101895:	c7 44 24 0c 78 43 10 	movl   $0xf0104378,0xc(%esp)
f010189c:	f0 
f010189d:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01018a4:	f0 
f01018a5:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f01018ac:	00 
f01018ad:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01018b4:	e8 e0 e7 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f01018b9:	ba 00 00 00 00       	mov    $0x0,%edx
f01018be:	89 f0                	mov    %esi,%eax
f01018c0:	e8 c0 f1 ff ff       	call   f0100a85 <check_va2pa>
f01018c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01018c8:	89 d1                	mov    %edx,%ecx
f01018ca:	2b 4d c4             	sub    -0x3c(%ebp),%ecx
f01018cd:	c1 f9 02             	sar    $0x2,%ecx
f01018d0:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01018d6:	c1 e1 0c             	shl    $0xc,%ecx
f01018d9:	39 c8                	cmp    %ecx,%eax
f01018db:	74 24                	je     f0101901 <i386_vm_init+0x82e>
f01018dd:	c7 44 24 0c a0 43 10 	movl   $0xf01043a0,0xc(%esp)
f01018e4:	f0 
f01018e5:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01018ec:	f0 
f01018ed:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01018f4:	00 
f01018f5:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01018fc:	e8 98 e7 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f0101901:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101906:	74 24                	je     f010192c <i386_vm_init+0x859>
f0101908:	c7 44 24 0c 17 48 10 	movl   $0xf0104817,0xc(%esp)
f010190f:	f0 
f0101910:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101917:	f0 
f0101918:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f010191f:	00 
f0101920:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101927:	e8 6d e7 ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f010192c:	66 83 7f 08 01       	cmpw   $0x1,0x8(%edi)
f0101931:	74 24                	je     f0101957 <i386_vm_init+0x884>
f0101933:	c7 44 24 0c 28 48 10 	movl   $0xf0104828,0xc(%esp)
f010193a:	f0 
f010193b:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101942:	f0 
f0101943:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f010194a:	00 
f010194b:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101952:	e8 42 e7 ff ff       	call   f0100099 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101957:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010195e:	00 
f010195f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101966:	00 
f0101967:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010196a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010196e:	89 34 24             	mov    %esi,(%esp)
f0101971:	e8 cc f6 ff ff       	call   f0101042 <page_insert>
f0101976:	85 c0                	test   %eax,%eax
f0101978:	74 24                	je     f010199e <i386_vm_init+0x8cb>
f010197a:	c7 44 24 0c d0 43 10 	movl   $0xf01043d0,0xc(%esp)
f0101981:	f0 
f0101982:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101989:	f0 
f010198a:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101991:	00 
f0101992:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101999:	e8 fb e6 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f010199e:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019a3:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f01019a8:	e8 d8 f0 ff ff       	call   f0100a85 <check_va2pa>
f01019ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01019b0:	89 d1                	mov    %edx,%ecx
f01019b2:	2b 0d 0c 6a 11 f0    	sub    0xf0116a0c,%ecx
f01019b8:	c1 f9 02             	sar    $0x2,%ecx
f01019bb:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01019c1:	c1 e1 0c             	shl    $0xc,%ecx
f01019c4:	39 c8                	cmp    %ecx,%eax
f01019c6:	74 24                	je     f01019ec <i386_vm_init+0x919>
f01019c8:	c7 44 24 0c 08 44 10 	movl   $0xf0104408,0xc(%esp)
f01019cf:	f0 
f01019d0:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01019d7:	f0 
f01019d8:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f01019df:	00 
f01019e0:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01019e7:	e8 ad e6 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f01019ec:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f01019f1:	74 24                	je     f0101a17 <i386_vm_init+0x944>
f01019f3:	c7 44 24 0c 39 48 10 	movl   $0xf0104839,0xc(%esp)
f01019fa:	f0 
f01019fb:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101a02:	f0 
f0101a03:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101a0a:	00 
f0101a0b:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101a12:	e8 82 e6 ff ff       	call   f0100099 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101a17:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101a1a:	89 04 24             	mov    %eax,(%esp)
f0101a1d:	e8 bc f2 ff ff       	call   f0100cde <page_alloc>
f0101a22:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101a25:	74 24                	je     f0101a4b <i386_vm_init+0x978>
f0101a27:	c7 44 24 0c fa 47 10 	movl   $0xf01047fa,0xc(%esp)
f0101a2e:	f0 
f0101a2f:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101a36:	f0 
f0101a37:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101a3e:	00 
f0101a3f:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101a46:	e8 4e e6 ff ff       	call   f0100099 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101a4b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101a52:	00 
f0101a53:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a5a:	00 
f0101a5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a62:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0101a67:	89 04 24             	mov    %eax,(%esp)
f0101a6a:	e8 d3 f5 ff ff       	call   f0101042 <page_insert>
f0101a6f:	85 c0                	test   %eax,%eax
f0101a71:	74 24                	je     f0101a97 <i386_vm_init+0x9c4>
f0101a73:	c7 44 24 0c d0 43 10 	movl   $0xf01043d0,0xc(%esp)
f0101a7a:	f0 
f0101a7b:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101a82:	f0 
f0101a83:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101a8a:	00 
f0101a8b:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101a92:	e8 02 e6 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101a97:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a9c:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0101aa1:	e8 df ef ff ff       	call   f0100a85 <check_va2pa>
f0101aa6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101aa9:	89 d1                	mov    %edx,%ecx
f0101aab:	2b 0d 0c 6a 11 f0    	sub    0xf0116a0c,%ecx
f0101ab1:	c1 f9 02             	sar    $0x2,%ecx
f0101ab4:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101aba:	c1 e1 0c             	shl    $0xc,%ecx
f0101abd:	39 c8                	cmp    %ecx,%eax
f0101abf:	74 24                	je     f0101ae5 <i386_vm_init+0xa12>
f0101ac1:	c7 44 24 0c 08 44 10 	movl   $0xf0104408,0xc(%esp)
f0101ac8:	f0 
f0101ac9:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101ad0:	f0 
f0101ad1:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101ad8:	00 
f0101ad9:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101ae0:	e8 b4 e5 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0101ae5:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101aea:	74 24                	je     f0101b10 <i386_vm_init+0xa3d>
f0101aec:	c7 44 24 0c 39 48 10 	movl   $0xf0104839,0xc(%esp)
f0101af3:	f0 
f0101af4:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101afb:	f0 
f0101afc:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101b03:	00 
f0101b04:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101b0b:	e8 89 e5 ff ff       	call   f0100099 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101b10:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101b13:	89 04 24             	mov    %eax,(%esp)
f0101b16:	e8 c3 f1 ff ff       	call   f0100cde <page_alloc>
f0101b1b:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101b1e:	74 24                	je     f0101b44 <i386_vm_init+0xa71>
f0101b20:	c7 44 24 0c fa 47 10 	movl   $0xf01047fa,0xc(%esp)
f0101b27:	f0 
f0101b28:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101b2f:	f0 
f0101b30:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101b37:	00 
f0101b38:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101b3f:	e8 55 e5 ff ff       	call   f0100099 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0101b44:	8b 15 08 6a 11 f0    	mov    0xf0116a08,%edx
f0101b4a:	8b 02                	mov    (%edx),%eax
f0101b4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101b51:	89 c1                	mov    %eax,%ecx
f0101b53:	c1 e9 0c             	shr    $0xc,%ecx
f0101b56:	3b 0d 00 6a 11 f0    	cmp    0xf0116a00,%ecx
f0101b5c:	72 20                	jb     f0101b7e <i386_vm_init+0xaab>
f0101b5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b62:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f0101b69:	f0 
f0101b6a:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101b71:	00 
f0101b72:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101b79:	e8 1b e5 ff ff       	call   f0100099 <_panic>
f0101b7e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(boot_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b8d:	00 
f0101b8e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101b95:	00 
f0101b96:	89 14 24             	mov    %edx,(%esp)
f0101b99:	e8 03 f2 ff ff       	call   f0100da1 <pgdir_walk>
f0101b9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ba1:	83 c2 04             	add    $0x4,%edx
f0101ba4:	39 d0                	cmp    %edx,%eax
f0101ba6:	74 24                	je     f0101bcc <i386_vm_init+0xaf9>
f0101ba8:	c7 44 24 0c 38 44 10 	movl   $0xf0104438,0xc(%esp)
f0101baf:	f0 
f0101bb0:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101bb7:	f0 
f0101bb8:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101bbf:	00 
f0101bc0:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101bc7:	e8 cd e4 ff ff       	call   f0100099 <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0101bcc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0101bd3:	00 
f0101bd4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bdb:	00 
f0101bdc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101be3:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0101be8:	89 04 24             	mov    %eax,(%esp)
f0101beb:	e8 52 f4 ff ff       	call   f0101042 <page_insert>
f0101bf0:	85 c0                	test   %eax,%eax
f0101bf2:	74 24                	je     f0101c18 <i386_vm_init+0xb45>
f0101bf4:	c7 44 24 0c 78 44 10 	movl   $0xf0104478,0xc(%esp)
f0101bfb:	f0 
f0101bfc:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101c03:	f0 
f0101c04:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101c0b:	00 
f0101c0c:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101c13:	e8 81 e4 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101c18:	8b 35 08 6a 11 f0    	mov    0xf0116a08,%esi
f0101c1e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c23:	89 f0                	mov    %esi,%eax
f0101c25:	e8 5b ee ff ff       	call   f0100a85 <check_va2pa>
f0101c2a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101c2d:	89 d1                	mov    %edx,%ecx
f0101c2f:	2b 0d 0c 6a 11 f0    	sub    0xf0116a0c,%ecx
f0101c35:	c1 f9 02             	sar    $0x2,%ecx
f0101c38:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101c3e:	c1 e1 0c             	shl    $0xc,%ecx
f0101c41:	39 c8                	cmp    %ecx,%eax
f0101c43:	74 24                	je     f0101c69 <i386_vm_init+0xb96>
f0101c45:	c7 44 24 0c 08 44 10 	movl   $0xf0104408,0xc(%esp)
f0101c4c:	f0 
f0101c4d:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101c54:	f0 
f0101c55:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101c5c:	00 
f0101c5d:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101c64:	e8 30 e4 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0101c69:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101c6e:	74 24                	je     f0101c94 <i386_vm_init+0xbc1>
f0101c70:	c7 44 24 0c 39 48 10 	movl   $0xf0104839,0xc(%esp)
f0101c77:	f0 
f0101c78:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101c7f:	f0 
f0101c80:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0101c87:	00 
f0101c88:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101c8f:	e8 05 e4 ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c9b:	00 
f0101c9c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ca3:	00 
f0101ca4:	89 34 24             	mov    %esi,(%esp)
f0101ca7:	e8 f5 f0 ff ff       	call   f0100da1 <pgdir_walk>
f0101cac:	f6 00 04             	testb  $0x4,(%eax)
f0101caf:	75 24                	jne    f0101cd5 <i386_vm_init+0xc02>
f0101cb1:	c7 44 24 0c b4 44 10 	movl   $0xf01044b4,0xc(%esp)
f0101cb8:	f0 
f0101cb9:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101cc0:	f0 
f0101cc1:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101cc8:	00 
f0101cc9:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101cd0:	e8 c4 e3 ff ff       	call   f0100099 <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101cd5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101cdc:	00 
f0101cdd:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101ce4:	00 
f0101ce5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101ce8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101cec:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0101cf1:	89 04 24             	mov    %eax,(%esp)
f0101cf4:	e8 49 f3 ff ff       	call   f0101042 <page_insert>
f0101cf9:	85 c0                	test   %eax,%eax
f0101cfb:	78 24                	js     f0101d21 <i386_vm_init+0xc4e>
f0101cfd:	c7 44 24 0c e8 44 10 	movl   $0xf01044e8,0xc(%esp)
f0101d04:	f0 
f0101d05:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101d0c:	f0 
f0101d0d:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0101d14:	00 
f0101d15:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101d1c:	e8 78 e3 ff ff       	call   f0100099 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d21:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101d28:	00 
f0101d29:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d30:	00 
f0101d31:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d38:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0101d3d:	89 04 24             	mov    %eax,(%esp)
f0101d40:	e8 fd f2 ff ff       	call   f0101042 <page_insert>
f0101d45:	85 c0                	test   %eax,%eax
f0101d47:	74 24                	je     f0101d6d <i386_vm_init+0xc9a>
f0101d49:	c7 44 24 0c 1c 45 10 	movl   $0xf010451c,0xc(%esp)
f0101d50:	f0 
f0101d51:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101d58:	f0 
f0101d59:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101d60:	00 
f0101d61:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101d68:	e8 2c e3 ff ff       	call   f0100099 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0101d6d:	8b 3d 08 6a 11 f0    	mov    0xf0116a08,%edi
f0101d73:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d78:	89 f8                	mov    %edi,%eax
f0101d7a:	e8 06 ed ff ff       	call   f0100a85 <check_va2pa>
f0101d7f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101d82:	8b 75 d8             	mov    -0x28(%ebp),%esi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101d85:	89 f0                	mov    %esi,%eax
f0101d87:	2b 05 0c 6a 11 f0    	sub    0xf0116a0c,%eax
f0101d8d:	c1 f8 02             	sar    $0x2,%eax
f0101d90:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101d96:	c1 e0 0c             	shl    $0xc,%eax
f0101d99:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101d9c:	74 24                	je     f0101dc2 <i386_vm_init+0xcef>
f0101d9e:	c7 44 24 0c 54 45 10 	movl   $0xf0104554,0xc(%esp)
f0101da5:	f0 
f0101da6:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101dad:	f0 
f0101dae:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101db5:	00 
f0101db6:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101dbd:	e8 d7 e2 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101dc2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dc7:	89 f8                	mov    %edi,%eax
f0101dc9:	e8 b7 ec ff ff       	call   f0100a85 <check_va2pa>
f0101dce:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101dd1:	74 24                	je     f0101df7 <i386_vm_init+0xd24>
f0101dd3:	c7 44 24 0c 80 45 10 	movl   $0xf0104580,0xc(%esp)
f0101dda:	f0 
f0101ddb:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101de2:	f0 
f0101de3:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101dea:	00 
f0101deb:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101df2:	e8 a2 e2 ff ff       	call   f0100099 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101df7:	66 83 7e 08 02       	cmpw   $0x2,0x8(%esi)
f0101dfc:	74 24                	je     f0101e22 <i386_vm_init+0xd4f>
f0101dfe:	c7 44 24 0c 4a 48 10 	movl   $0xf010484a,0xc(%esp)
f0101e05:	f0 
f0101e06:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101e0d:	f0 
f0101e0e:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0101e15:	00 
f0101e16:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101e1d:	e8 77 e2 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0101e22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e25:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101e2a:	74 24                	je     f0101e50 <i386_vm_init+0xd7d>
f0101e2c:	c7 44 24 0c 5b 48 10 	movl   $0xf010485b,0xc(%esp)
f0101e33:	f0 
f0101e34:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101e3b:	f0 
f0101e3c:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101e43:	00 
f0101e44:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101e4b:	e8 49 e2 ff ff       	call   f0100099 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f0101e50:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101e53:	89 04 24             	mov    %eax,(%esp)
f0101e56:	e8 83 ee ff ff       	call   f0100cde <page_alloc>
f0101e5b:	85 c0                	test   %eax,%eax
f0101e5d:	75 08                	jne    f0101e67 <i386_vm_init+0xd94>
f0101e5f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e62:	39 4d e0             	cmp    %ecx,-0x20(%ebp)
f0101e65:	74 24                	je     f0101e8b <i386_vm_init+0xdb8>
f0101e67:	c7 44 24 0c b0 45 10 	movl   $0xf01045b0,0xc(%esp)
f0101e6e:	f0 
f0101e6f:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101e76:	f0 
f0101e77:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101e7e:	00 
f0101e7f:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101e86:	e8 0e e2 ff ff       	call   f0100099 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0101e8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101e92:	00 
f0101e93:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0101e98:	89 04 24             	mov    %eax,(%esp)
f0101e9b:	e8 52 f1 ff ff       	call   f0100ff2 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101ea0:	8b 35 08 6a 11 f0    	mov    0xf0116a08,%esi
f0101ea6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eab:	89 f0                	mov    %esi,%eax
f0101ead:	e8 d3 eb ff ff       	call   f0100a85 <check_va2pa>
f0101eb2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb5:	74 24                	je     f0101edb <i386_vm_init+0xe08>
f0101eb7:	c7 44 24 0c d4 45 10 	movl   $0xf01045d4,0xc(%esp)
f0101ebe:	f0 
f0101ebf:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101ec6:	f0 
f0101ec7:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101ece:	00 
f0101ecf:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101ed6:	e8 be e1 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101edb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ee0:	89 f0                	mov    %esi,%eax
f0101ee2:	e8 9e eb ff ff       	call   f0100a85 <check_va2pa>
f0101ee7:	8b 55 d8             	mov    -0x28(%ebp),%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101eea:	89 d1                	mov    %edx,%ecx
f0101eec:	2b 0d 0c 6a 11 f0    	sub    0xf0116a0c,%ecx
f0101ef2:	c1 f9 02             	sar    $0x2,%ecx
f0101ef5:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101efb:	c1 e1 0c             	shl    $0xc,%ecx
f0101efe:	39 c8                	cmp    %ecx,%eax
f0101f00:	74 24                	je     f0101f26 <i386_vm_init+0xe53>
f0101f02:	c7 44 24 0c 80 45 10 	movl   $0xf0104580,0xc(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101f11:	f0 
f0101f12:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101f19:	00 
f0101f1a:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101f21:	e8 73 e1 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f0101f26:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101f2b:	74 24                	je     f0101f51 <i386_vm_init+0xe7e>
f0101f2d:	c7 44 24 0c 17 48 10 	movl   $0xf0104817,0xc(%esp)
f0101f34:	f0 
f0101f35:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101f3c:	f0 
f0101f3d:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101f44:	00 
f0101f45:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101f4c:	e8 48 e1 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0101f51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f54:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101f59:	74 24                	je     f0101f7f <i386_vm_init+0xeac>
f0101f5b:	c7 44 24 0c 5b 48 10 	movl   $0xf010485b,0xc(%esp)
f0101f62:	f0 
f0101f63:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101f6a:	f0 
f0101f6b:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101f72:	00 
f0101f73:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101f7a:	e8 1a e1 ff ff       	call   f0100099 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0101f7f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f86:	00 
f0101f87:	89 34 24             	mov    %esi,(%esp)
f0101f8a:	e8 63 f0 ff ff       	call   f0100ff2 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101f8f:	8b 35 08 6a 11 f0    	mov    0xf0116a08,%esi
f0101f95:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f9a:	89 f0                	mov    %esi,%eax
f0101f9c:	e8 e4 ea ff ff       	call   f0100a85 <check_va2pa>
f0101fa1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa4:	74 24                	je     f0101fca <i386_vm_init+0xef7>
f0101fa6:	c7 44 24 0c d4 45 10 	movl   $0xf01045d4,0xc(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101fb5:	f0 
f0101fb6:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101fbd:	00 
f0101fbe:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101fc5:	e8 cf e0 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f0101fca:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fcf:	89 f0                	mov    %esi,%eax
f0101fd1:	e8 af ea ff ff       	call   f0100a85 <check_va2pa>
f0101fd6:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fd9:	74 24                	je     f0101fff <i386_vm_init+0xf2c>
f0101fdb:	c7 44 24 0c f8 45 10 	movl   $0xf01045f8,0xc(%esp)
f0101fe2:	f0 
f0101fe3:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0101fea:	f0 
f0101feb:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101ff2:	00 
f0101ff3:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0101ffa:	e8 9a e0 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f0101fff:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102002:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102007:	74 24                	je     f010202d <i386_vm_init+0xf5a>
f0102009:	c7 44 24 0c 6c 48 10 	movl   $0xf010486c,0xc(%esp)
f0102010:	f0 
f0102011:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0102018:	f0 
f0102019:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0102020:	00 
f0102021:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0102028:	e8 6c e0 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f010202d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102030:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102035:	74 24                	je     f010205b <i386_vm_init+0xf88>
f0102037:	c7 44 24 0c 5b 48 10 	movl   $0xf010485b,0xc(%esp)
f010203e:	f0 
f010203f:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0102046:	f0 
f0102047:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f010204e:	00 
f010204f:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0102056:	e8 3e e0 ff ff       	call   f0100099 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f010205b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010205e:	89 04 24             	mov    %eax,(%esp)
f0102061:	e8 78 ec ff ff       	call   f0100cde <page_alloc>
f0102066:	85 c0                	test   %eax,%eax
f0102068:	75 08                	jne    f0102072 <i386_vm_init+0xf9f>
f010206a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010206d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f0102070:	74 24                	je     f0102096 <i386_vm_init+0xfc3>
f0102072:	c7 44 24 0c 20 46 10 	movl   $0xf0104620,0xc(%esp)
f0102079:	f0 
f010207a:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0102081:	f0 
f0102082:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102089:	00 
f010208a:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0102091:	e8 03 e0 ff ff       	call   f0100099 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0102096:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0102099:	89 04 24             	mov    %eax,(%esp)
f010209c:	e8 3d ec ff ff       	call   f0100cde <page_alloc>
f01020a1:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01020a4:	74 24                	je     f01020ca <i386_vm_init+0xff7>
f01020a6:	c7 44 24 0c fa 47 10 	movl   $0xf01047fa,0xc(%esp)
f01020ad:	f0 
f01020ae:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01020b5:	f0 
f01020b6:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f01020bd:	00 
f01020be:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01020c5:	e8 cf df ff ff       	call   f0100099 <_panic>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01020ca:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f01020cf:	8b 08                	mov    (%eax),%ecx
f01020d1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01020d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01020da:	2b 15 0c 6a 11 f0    	sub    0xf0116a0c,%edx
f01020e0:	c1 fa 02             	sar    $0x2,%edx
f01020e3:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01020e9:	c1 e2 0c             	shl    $0xc,%edx
f01020ec:	39 d1                	cmp    %edx,%ecx
f01020ee:	74 24                	je     f0102114 <i386_vm_init+0x1041>
f01020f0:	c7 44 24 0c 78 43 10 	movl   $0xf0104378,0xc(%esp)
f01020f7:	f0 
f01020f8:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01020ff:	f0 
f0102100:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0102107:	00 
f0102108:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010210f:	e8 85 df ff ff       	call   f0100099 <_panic>
	boot_pgdir[0] = 0;
f0102114:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010211a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010211d:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102122:	74 24                	je     f0102148 <i386_vm_init+0x1075>
f0102124:	c7 44 24 0c 28 48 10 	movl   $0xf0104828,0xc(%esp)
f010212b:	f0 
f010212c:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0102133:	f0 
f0102134:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f010213b:	00 
f010213c:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0102143:	e8 51 df ff ff       	call   f0100099 <_panic>
	pp0->pp_ref = 0;
f0102148:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010214e:	89 04 24             	mov    %eax,(%esp)
f0102151:	e8 d9 eb ff ff       	call   f0100d2f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(boot_pgdir, va, 1);
f0102156:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010215d:	00 
f010215e:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102165:	00 
f0102166:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f010216b:	89 04 24             	mov    %eax,(%esp)
f010216e:	e8 2e ec ff ff       	call   f0100da1 <pgdir_walk>
f0102173:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f0102176:	8b 35 08 6a 11 f0    	mov    0xf0116a08,%esi
f010217c:	8b 56 04             	mov    0x4(%esi),%edx
f010217f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102185:	8b 0d 00 6a 11 f0    	mov    0xf0116a00,%ecx
f010218b:	89 d7                	mov    %edx,%edi
f010218d:	c1 ef 0c             	shr    $0xc,%edi
f0102190:	39 cf                	cmp    %ecx,%edi
f0102192:	72 20                	jb     f01021b4 <i386_vm_init+0x10e1>
f0102194:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102198:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f010219f:	f0 
f01021a0:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f01021a7:	00 
f01021a8:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01021af:	e8 e5 de ff ff       	call   f0100099 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021b4:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01021ba:	39 d0                	cmp    %edx,%eax
f01021bc:	74 24                	je     f01021e2 <i386_vm_init+0x110f>
f01021be:	c7 44 24 0c 7d 48 10 	movl   $0xf010487d,0xc(%esp)
f01021c5:	f0 
f01021c6:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01021cd:	f0 
f01021ce:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f01021d5:	00 
f01021d6:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01021dd:	e8 b7 de ff ff       	call   f0100099 <_panic>
	boot_pgdir[PDX(va)] = 0;
f01021e2:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	pp0->pp_ref = 0;
f01021e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01021ec:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01021f2:	2b 05 0c 6a 11 f0    	sub    0xf0116a0c,%eax
f01021f8:	c1 f8 02             	sar    $0x2,%eax
f01021fb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102201:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102204:	89 c2                	mov    %eax,%edx
f0102206:	c1 ea 0c             	shr    $0xc,%edx
f0102209:	39 d1                	cmp    %edx,%ecx
f010220b:	77 20                	ja     f010222d <i386_vm_init+0x115a>
f010220d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102211:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f0102218:	f0 
f0102219:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102220:	00 
f0102221:	c7 04 24 2f 47 10 f0 	movl   $0xf010472f,(%esp)
f0102228:	e8 6c de ff ff       	call   f0100099 <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010222d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102234:	00 
f0102235:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010223c:	00 
f010223d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102242:	89 04 24             	mov    %eax,(%esp)
f0102245:	e8 ec 13 00 00       	call   f0103636 <memset>
	page_free(pp0);
f010224a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010224d:	89 04 24             	mov    %eax,(%esp)
f0102250:	e8 da ea ff ff       	call   f0100d2f <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f0102255:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010225c:	00 
f010225d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102264:	00 
f0102265:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f010226a:	89 04 24             	mov    %eax,(%esp)
f010226d:	e8 2f eb ff ff       	call   f0100da1 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102272:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102275:	2b 15 0c 6a 11 f0    	sub    0xf0116a0c,%edx
f010227b:	c1 fa 02             	sar    $0x2,%edx
f010227e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102284:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102287:	89 d0                	mov    %edx,%eax
f0102289:	c1 e8 0c             	shr    $0xc,%eax
f010228c:	3b 05 00 6a 11 f0    	cmp    0xf0116a00,%eax
f0102292:	72 20                	jb     f01022b4 <i386_vm_init+0x11e1>
f0102294:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102298:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f010229f:	f0 
f01022a0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01022a7:	00 
f01022a8:	c7 04 24 2f 47 10 f0 	movl   $0xf010472f,(%esp)
f01022af:	e8 e5 dd ff ff       	call   f0100099 <_panic>
f01022b4:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = page2kva(pp0);
f01022ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022bd:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f01022c4:	75 11                	jne    f01022d7 <i386_vm_init+0x1204>
f01022c6:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f01022cc:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022d2:	f6 00 01             	testb  $0x1,(%eax)
f01022d5:	74 24                	je     f01022fb <i386_vm_init+0x1228>
f01022d7:	c7 44 24 0c 95 48 10 	movl   $0xf0104895,0xc(%esp)
f01022de:	f0 
f01022df:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01022e6:	f0 
f01022e7:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f01022ee:	00 
f01022ef:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01022f6:	e8 9e dd ff ff       	call   f0100099 <_panic>
f01022fb:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01022fe:	39 d0                	cmp    %edx,%eax
f0102300:	75 d0                	jne    f01022d2 <i386_vm_init+0x11ff>
		assert((ptep[i] & PTE_P) == 0);
	boot_pgdir[0] = 0;
f0102302:	a1 08 6a 11 f0       	mov    0xf0116a08,%eax
f0102307:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010230d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102310:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0102316:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0102319:	89 15 d8 65 11 f0    	mov    %edx,0xf01165d8

	// free the pages we took
	page_free(pp0);
f010231f:	89 04 24             	mov    %eax,(%esp)
f0102322:	e8 08 ea ff ff       	call   f0100d2f <page_free>
	page_free(pp1);
f0102327:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010232a:	89 04 24             	mov    %eax,(%esp)
f010232d:	e8 fd e9 ff ff       	call   f0100d2f <page_free>
	page_free(pp2);
f0102332:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102335:	89 04 24             	mov    %eax,(%esp)
f0102338:	e8 f2 e9 ff ff       	call   f0100d2f <page_free>
	
	cprintf("page_check() succeeded!\n");
f010233d:	c7 04 24 ac 48 10 f0 	movl   $0xf01048ac,(%esp)
f0102344:	e8 69 07 00 00       	call   f0102ab2 <cprintf>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here:
	// [UPAGES, sizeof(PAGES) ] => [pages, sizeof(PAGES)]
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f0102349:	8b 15 00 6a 11 f0    	mov    0xf0116a00,%edx
	boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f010234f:	a1 0c 6a 11 f0       	mov    0xf0116a0c,%eax
f0102354:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102359:	77 20                	ja     f010237b <i386_vm_init+0x12a8>
f010235b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010235f:	c7 44 24 08 0c 42 10 	movl   $0xf010420c,0x8(%esp)
f0102366:	f0 
f0102367:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f010236e:	00 
f010236f:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0102376:	e8 1e dd ff ff       	call   f0100099 <_panic>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here:
	// [UPAGES, sizeof(PAGES) ] => [pages, sizeof(PAGES)]
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f010237b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010237e:	8d 0c 95 ff 0f 00 00 	lea    0xfff(,%edx,4),%ecx
f0102385:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f010238b:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102392:	00 
f0102393:	05 00 00 00 10       	add    $0x10000000,%eax
f0102398:	89 04 24             	mov    %eax,(%esp)
f010239b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01023a0:	89 d8                	mov    %ebx,%eax
f01023a2:	e8 50 eb ff ff       	call   f0100ef7 <boot_map_segment>
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed => faults
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// [KSTACKTOP – KSTKSIZE, 8] => [bootstack, 8]
	boot_map_segment(pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01023a7:	be 00 e0 10 f0       	mov    $0xf010e000,%esi
f01023ac:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01023b2:	77 20                	ja     f01023d4 <i386_vm_init+0x1301>
f01023b4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01023b8:	c7 44 24 08 0c 42 10 	movl   $0xf010420c,0x8(%esp)
f01023bf:	f0 
f01023c0:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
f01023c7:	00 
f01023c8:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01023cf:	e8 c5 dc ff ff       	call   f0100099 <_panic>
f01023d4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01023db:	00 
f01023dc:	c7 04 24 00 e0 10 00 	movl   $0x10e000,(%esp)
f01023e3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01023e8:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01023ed:	89 d8                	mov    %ebx,%eax
f01023ef:	e8 03 eb ff ff       	call   f0100ef7 <boot_map_segment>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the amapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	// [KERNBASE, pages in the memory] => [0, pages in the memory]
	boot_map_segment(pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_W | PTE_P);
f01023f4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01023fb:	00 
f01023fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102403:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102408:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010240d:	89 d8                	mov    %ebx,%eax
f010240f:	e8 e3 ea ff ff       	call   f0100ef7 <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f0102414:	8b 3d 08 6a 11 f0    	mov    0xf0116a08,%edi

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f010241a:	8b 0d 00 6a 11 f0    	mov    0xf0116a00,%ecx
f0102420:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0102423:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0102426:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
	for (i = 0; i < n; i += PGSIZE)
f010242d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102432:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102435:	0f 84 86 00 00 00    	je     f01024c1 <i386_vm_init+0x13ee>
f010243b:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f0102442:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102445:	81 ea 00 00 00 11    	sub    $0x11000000,%edx
	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010244b:	89 f8                	mov    %edi,%eax
f010244d:	e8 33 e6 ff ff       	call   f0100a85 <check_va2pa>
f0102452:	8b 15 0c 6a 11 f0    	mov    0xf0116a0c,%edx
f0102458:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010245e:	77 20                	ja     f0102480 <i386_vm_init+0x13ad>
f0102460:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102464:	c7 44 24 08 0c 42 10 	movl   $0xf010420c,0x8(%esp)
f010246b:	f0 
f010246c:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
f0102473:	00 
f0102474:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010247b:	e8 19 dc ff ff       	call   f0100099 <_panic>
f0102480:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102483:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f010248a:	39 d0                	cmp    %edx,%eax
f010248c:	74 24                	je     f01024b2 <i386_vm_init+0x13df>
f010248e:	c7 44 24 0c 44 46 10 	movl   $0xf0104644,0xc(%esp)
f0102495:	f0 
f0102496:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f010249d:	f0 
f010249e:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
f01024a5:	00 
f01024a6:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01024ad:	e8 e7 db ff ff       	call   f0100099 <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01024b2:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f01024b9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01024bc:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f01024bf:	77 81                	ja     f0102442 <i386_vm_init+0x136f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
f01024c1:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f01024c5:	74 4f                	je     f0102516 <i386_vm_init+0x1443>
f01024c7:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f01024ce:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01024d1:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01024d7:	89 f8                	mov    %edi,%eax
f01024d9:	e8 a7 e5 ff ff       	call   f0100a85 <check_va2pa>
f01024de:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f01024e1:	74 24                	je     f0102507 <i386_vm_init+0x1434>
f01024e3:	c7 44 24 0c 78 46 10 	movl   $0xf0104678,0xc(%esp)
f01024ea:	f0 
f01024eb:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01024f2:	f0 
f01024f3:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f01024fa:	00 
f01024fb:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0102502:	e8 92 db ff ff       	call   f0100099 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
f0102507:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f010250e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102511:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0102514:	77 b8                	ja     f01024ce <i386_vm_init+0x13fb>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102516:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010251b:	89 f8                	mov    %edi,%eax
f010251d:	e8 63 e5 ff ff       	call   f0100a85 <check_va2pa>
f0102522:	c7 45 c4 00 90 bf ef 	movl   $0xefbf9000,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f0102529:	81 c6 00 70 40 20    	add    $0x20407000,%esi
f010252f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102532:	01 f2                	add    %esi,%edx
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102534:	39 d0                	cmp    %edx,%eax
f0102536:	74 24                	je     f010255c <i386_vm_init+0x1489>
f0102538:	c7 44 24 0c a0 46 10 	movl   $0xf01046a0,0xc(%esp)
f010253f:	f0 
f0102540:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f0102547:	f0 
f0102548:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f010254f:	00 
f0102550:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f0102557:	e8 3d db ff ff       	call   f0100099 <_panic>
	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010255c:	81 7d c4 00 00 c0 ef 	cmpl   $0xefc00000,-0x3c(%ebp)
f0102563:	0f 85 07 01 00 00    	jne    f0102670 <i386_vm_init+0x159d>
f0102569:	b8 00 00 00 00       	mov    $0x0,%eax
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010256e:	8d 90 44 fc ff ff    	lea    -0x3bc(%eax),%edx
f0102574:	83 fa 03             	cmp    $0x3,%edx
f0102577:	77 2a                	ja     f01025a3 <i386_vm_init+0x14d0>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i]);
f0102579:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010257d:	75 7f                	jne    f01025fe <i386_vm_init+0x152b>
f010257f:	c7 44 24 0c c5 48 10 	movl   $0xf01048c5,0xc(%esp)
f0102586:	f0 
f0102587:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f010258e:	f0 
f010258f:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f0102596:	00 
f0102597:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f010259e:	e8 f6 da ff ff       	call   f0100099 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f01025a3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01025a8:	76 2a                	jbe    f01025d4 <i386_vm_init+0x1501>
				assert(pgdir[i]);
f01025aa:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01025ae:	75 4e                	jne    f01025fe <i386_vm_init+0x152b>
f01025b0:	c7 44 24 0c c5 48 10 	movl   $0xf01048c5,0xc(%esp)
f01025b7:	f0 
f01025b8:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01025bf:	f0 
f01025c0:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f01025c7:	00 
f01025c8:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01025cf:	e8 c5 da ff ff       	call   f0100099 <_panic>
			else
				assert(pgdir[i] == 0);
f01025d4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01025d8:	74 24                	je     f01025fe <i386_vm_init+0x152b>
f01025da:	c7 44 24 0c ce 48 10 	movl   $0xf01048ce,0xc(%esp)
f01025e1:	f0 
f01025e2:	c7 44 24 08 53 47 10 	movl   $0xf0104753,0x8(%esp)
f01025e9:	f0 
f01025ea:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f01025f1:	00 
f01025f2:	c7 04 24 07 47 10 f0 	movl   $0xf0104707,(%esp)
f01025f9:	e8 9b da ff ff       	call   f0100099 <_panic>
	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f01025fe:	83 c0 01             	add    $0x1,%eax
f0102601:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102606:	0f 85 62 ff ff ff    	jne    f010256e <i386_vm_init+0x149b>
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f010260c:	c7 04 24 e8 46 10 f0 	movl   $0xf01046e8,(%esp)
f0102613:	e8 9a 04 00 00       	call   f0102ab2 <cprintf>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f0102618:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f010261e:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102620:	a1 04 6a 11 f0       	mov    0xf0116a04,%eax
f0102625:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102628:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f010262b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102630:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102633:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0102636:	0f 01 15 20 63 11 f0 	lgdtl  0xf0116320
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010263d:	b8 23 00 00 00       	mov    $0x23,%eax
f0102642:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102644:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102646:	b0 10                	mov    $0x10,%al
f0102648:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010264a:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010264c:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f010264e:	ea 55 26 10 f0 08 00 	ljmp   $0x8,$0xf0102655
	asm volatile("lldt %%ax" :: "a" (0));
f0102655:	b0 00                	mov    $0x0,%al
f0102657:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f010265a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102660:	a1 04 6a 11 f0       	mov    0xf0116a04,%eax
f0102665:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}
f0102668:	83 c4 4c             	add    $0x4c,%esp
f010266b:	5b                   	pop    %ebx
f010266c:	5e                   	pop    %esi
f010266d:	5f                   	pop    %edi
f010266e:	5d                   	pop    %ebp
f010266f:	c3                   	ret    
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102670:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102673:	89 f8                	mov    %edi,%eax
f0102675:	e8 0b e4 ff ff       	call   f0100a85 <check_va2pa>
f010267a:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f0102681:	e9 a9 fe ff ff       	jmp    f010252f <i386_vm_init+0x145c>
	...

f0102688 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102688:	55                   	push   %ebp
f0102689:	89 e5                	mov    %esp,%ebp
f010268b:	53                   	push   %ebx
f010268c:	8b 45 08             	mov    0x8(%ebp),%eax
f010268f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102692:	85 c0                	test   %eax,%eax
f0102694:	75 0e                	jne    f01026a4 <envid2env+0x1c>
		*env_store = curenv;
f0102696:	a1 dc 65 11 f0       	mov    0xf01165dc,%eax
f010269b:	89 01                	mov    %eax,(%ecx)
		return 0;
f010269d:	b8 00 00 00 00       	mov    $0x0,%eax
f01026a2:	eb 54                	jmp    f01026f8 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01026a4:	89 c2                	mov    %eax,%edx
f01026a6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01026ac:	6b d2 64             	imul   $0x64,%edx,%edx
f01026af:	03 15 e0 65 11 f0    	add    0xf01165e0,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01026b5:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01026b9:	74 05                	je     f01026c0 <envid2env+0x38>
f01026bb:	39 42 4c             	cmp    %eax,0x4c(%edx)
f01026be:	74 0d                	je     f01026cd <envid2env+0x45>
		*env_store = 0;
f01026c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01026c6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01026cb:	eb 2b                	jmp    f01026f8 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01026cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01026d1:	74 1e                	je     f01026f1 <envid2env+0x69>
f01026d3:	a1 dc 65 11 f0       	mov    0xf01165dc,%eax
f01026d8:	39 c2                	cmp    %eax,%edx
f01026da:	74 15                	je     f01026f1 <envid2env+0x69>
f01026dc:	8b 58 4c             	mov    0x4c(%eax),%ebx
f01026df:	39 5a 50             	cmp    %ebx,0x50(%edx)
f01026e2:	74 0d                	je     f01026f1 <envid2env+0x69>
		*env_store = 0;
f01026e4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01026ea:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01026ef:	eb 07                	jmp    f01026f8 <envid2env+0x70>
	}

	*env_store = e;
f01026f1:	89 11                	mov    %edx,(%ecx)
	return 0;
f01026f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01026f8:	5b                   	pop    %ebx
f01026f9:	5d                   	pop    %ebp
f01026fa:	c3                   	ret    

f01026fb <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f01026fb:	55                   	push   %ebp
f01026fc:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f01026fe:	5d                   	pop    %ebp
f01026ff:	c3                   	ret    

f0102700 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102700:	55                   	push   %ebp
f0102701:	89 e5                	mov    %esp,%ebp
f0102703:	53                   	push   %ebx
f0102704:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f0102707:	8b 1d e4 65 11 f0    	mov    0xf01165e4,%ebx
f010270d:	85 db                	test   %ebx,%ebx
f010270f:	0f 84 f8 00 00 00    	je     f010280d <env_alloc+0x10d>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0102715:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f010271c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010271f:	89 04 24             	mov    %eax,(%esp)
f0102722:	e8 b7 e5 ff ff       	call   f0100cde <page_alloc>
f0102727:	85 c0                	test   %eax,%eax
f0102729:	0f 88 e3 00 00 00    	js     f0102812 <env_alloc+0x112>

	// LAB 3: Your code here.

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f010272f:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102732:	8b 53 60             	mov    0x60(%ebx),%edx
f0102735:	83 ca 03             	or     $0x3,%edx
f0102738:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f010273e:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102741:	8b 53 60             	mov    0x60(%ebx),%edx
f0102744:	83 ca 05             	or     $0x5,%edx
f0102747:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010274d:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0102750:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102755:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010275a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010275f:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102762:	89 da                	mov    %ebx,%edx
f0102764:	2b 15 e0 65 11 f0    	sub    0xf01165e0,%edx
f010276a:	c1 fa 02             	sar    $0x2,%edx
f010276d:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0102773:	09 d0                	or     %edx,%eax
f0102775:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102778:	8b 45 0c             	mov    0xc(%ebp),%eax
f010277b:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010277e:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102785:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010278c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102793:	00 
f0102794:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010279b:	00 
f010279c:	89 1c 24             	mov    %ebx,(%esp)
f010279f:	e8 92 0e 00 00       	call   f0103636 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f01027a4:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01027aa:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01027b0:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01027b6:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01027bd:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f01027c3:	8b 43 44             	mov    0x44(%ebx),%eax
f01027c6:	85 c0                	test   %eax,%eax
f01027c8:	74 06                	je     f01027d0 <env_alloc+0xd0>
f01027ca:	8b 53 48             	mov    0x48(%ebx),%edx
f01027cd:	89 50 48             	mov    %edx,0x48(%eax)
f01027d0:	8b 43 48             	mov    0x48(%ebx),%eax
f01027d3:	8b 53 44             	mov    0x44(%ebx),%edx
f01027d6:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f01027d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01027db:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01027dd:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f01027e0:	8b 15 dc 65 11 f0    	mov    0xf01165dc,%edx
f01027e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01027eb:	85 d2                	test   %edx,%edx
f01027ed:	74 03                	je     f01027f2 <env_alloc+0xf2>
f01027ef:	8b 42 4c             	mov    0x4c(%edx),%eax
f01027f2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01027f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027fa:	c7 04 24 dc 48 10 f0 	movl   $0xf01048dc,(%esp)
f0102801:	e8 ac 02 00 00       	call   f0102ab2 <cprintf>
	return 0;
f0102806:	b8 00 00 00 00       	mov    $0x0,%eax
f010280b:	eb 05                	jmp    f0102812 <env_alloc+0x112>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
f010280d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102812:	83 c4 24             	add    $0x24,%esp
f0102815:	5b                   	pop    %ebx
f0102816:	5d                   	pop    %ebp
f0102817:	c3                   	ret    

f0102818 <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f0102818:	55                   	push   %ebp
f0102819:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f010281b:	5d                   	pop    %ebp
f010281c:	c3                   	ret    

f010281d <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f010281d:	55                   	push   %ebp
f010281e:	89 e5                	mov    %esp,%ebp
f0102820:	57                   	push   %edi
f0102821:	56                   	push   %esi
f0102822:	53                   	push   %ebx
f0102823:	83 ec 2c             	sub    $0x2c,%esp
f0102826:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102829:	a1 dc 65 11 f0       	mov    0xf01165dc,%eax
f010282e:	39 c7                	cmp    %eax,%edi
f0102830:	75 09                	jne    f010283b <env_free+0x1e>
f0102832:	8b 15 04 6a 11 f0    	mov    0xf0116a04,%edx
f0102838:	0f 22 da             	mov    %edx,%cr3
		lcr3(boot_cr3);

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010283b:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f010283e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102843:	85 c0                	test   %eax,%eax
f0102845:	74 03                	je     f010284a <env_free+0x2d>
f0102847:	8b 50 4c             	mov    0x4c(%eax),%edx
f010284a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010284e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102852:	c7 04 24 f1 48 10 f0 	movl   $0xf01048f1,(%esp)
f0102859:	e8 54 02 00 00       	call   f0102ab2 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010285e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102865:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102868:	c1 e0 02             	shl    $0x2,%eax
f010286b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010286e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102871:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102874:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102877:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010287d:	0f 84 bb 00 00 00    	je     f010293e <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102883:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0102889:	89 f0                	mov    %esi,%eax
f010288b:	c1 e8 0c             	shr    $0xc,%eax
f010288e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102891:	3b 05 00 6a 11 f0    	cmp    0xf0116a00,%eax
f0102897:	72 20                	jb     f01028b9 <env_free+0x9c>
f0102899:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010289d:	c7 44 24 08 c4 41 10 	movl   $0xf01041c4,0x8(%esp)
f01028a4:	f0 
f01028a5:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f01028ac:	00 
f01028ad:	c7 04 24 07 49 10 f0 	movl   $0xf0104907,(%esp)
f01028b4:	e8 e0 d7 ff ff       	call   f0100099 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01028b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01028bc:	c1 e2 16             	shl    $0x16,%edx
f01028bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01028c2:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01028c7:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01028ce:	01 
f01028cf:	74 17                	je     f01028e8 <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01028d1:	89 d8                	mov    %ebx,%eax
f01028d3:	c1 e0 0c             	shl    $0xc,%eax
f01028d6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01028d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01028dd:	8b 47 5c             	mov    0x5c(%edi),%eax
f01028e0:	89 04 24             	mov    %eax,(%esp)
f01028e3:	e8 0a e7 ff ff       	call   f0100ff2 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01028e8:	83 c3 01             	add    $0x1,%ebx
f01028eb:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01028f1:	75 d4                	jne    f01028c7 <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01028f3:	8b 47 5c             	mov    0x5c(%edi),%eax
f01028f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01028f9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102900:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102903:	3b 05 00 6a 11 f0    	cmp    0xf0116a00,%eax
f0102909:	72 1c                	jb     f0102927 <env_free+0x10a>
		panic("pa2page called with invalid pa");
f010290b:	c7 44 24 08 88 42 10 	movl   $0xf0104288,0x8(%esp)
f0102912:	f0 
f0102913:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010291a:	00 
f010291b:	c7 04 24 2f 47 10 f0 	movl   $0xf010472f,(%esp)
f0102922:	e8 72 d7 ff ff       	call   f0100099 <_panic>
	return &pages[PPN(pa)];
f0102927:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010292a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010292d:	c1 e0 02             	shl    $0x2,%eax
f0102930:	03 05 0c 6a 11 f0    	add    0xf0116a0c,%eax
		page_decref(pa2page(pa));
f0102936:	89 04 24             	mov    %eax,(%esp)
f0102939:	e8 40 e4 ff ff       	call   f0100d7e <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010293e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102942:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102949:	0f 85 16 ff ff ff    	jne    f0102865 <env_free+0x48>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f010294f:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0102952:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0102959:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102960:	c1 e8 0c             	shr    $0xc,%eax
f0102963:	3b 05 00 6a 11 f0    	cmp    0xf0116a00,%eax
f0102969:	72 1c                	jb     f0102987 <env_free+0x16a>
		panic("pa2page called with invalid pa");
f010296b:	c7 44 24 08 88 42 10 	movl   $0xf0104288,0x8(%esp)
f0102972:	f0 
f0102973:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010297a:	00 
f010297b:	c7 04 24 2f 47 10 f0 	movl   $0xf010472f,(%esp)
f0102982:	e8 12 d7 ff ff       	call   f0100099 <_panic>
	return &pages[PPN(pa)];
f0102987:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010298a:	c1 e0 02             	shl    $0x2,%eax
f010298d:	03 05 0c 6a 11 f0    	add    0xf0116a0c,%eax
	page_decref(pa2page(pa));
f0102993:	89 04 24             	mov    %eax,(%esp)
f0102996:	e8 e3 e3 ff ff       	call   f0100d7e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010299b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f01029a2:	a1 e4 65 11 f0       	mov    0xf01165e4,%eax
f01029a7:	89 47 44             	mov    %eax,0x44(%edi)
f01029aa:	85 c0                	test   %eax,%eax
f01029ac:	74 06                	je     f01029b4 <env_free+0x197>
f01029ae:	8d 57 44             	lea    0x44(%edi),%edx
f01029b1:	89 50 48             	mov    %edx,0x48(%eax)
f01029b4:	89 3d e4 65 11 f0    	mov    %edi,0xf01165e4
f01029ba:	c7 47 48 e4 65 11 f0 	movl   $0xf01165e4,0x48(%edi)
}
f01029c1:	83 c4 2c             	add    $0x2c,%esp
f01029c4:	5b                   	pop    %ebx
f01029c5:	5e                   	pop    %esi
f01029c6:	5f                   	pop    %edi
f01029c7:	5d                   	pop    %ebp
f01029c8:	c3                   	ret    

f01029c9 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f01029c9:	55                   	push   %ebp
f01029ca:	89 e5                	mov    %esp,%ebp
f01029cc:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01029cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01029d2:	89 04 24             	mov    %eax,(%esp)
f01029d5:	e8 43 fe ff ff       	call   f010281d <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01029da:	c7 04 24 3c 49 10 f0 	movl   $0xf010493c,(%esp)
f01029e1:	e8 cc 00 00 00       	call   f0102ab2 <cprintf>
	while (1)
		monitor(NULL);
f01029e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029ed:	e8 ee dd ff ff       	call   f01007e0 <monitor>
f01029f2:	eb f2                	jmp    f01029e6 <env_destroy+0x1d>

f01029f4 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01029f4:	55                   	push   %ebp
f01029f5:	89 e5                	mov    %esp,%ebp
f01029f7:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01029fa:	8b 65 08             	mov    0x8(%ebp),%esp
f01029fd:	61                   	popa   
f01029fe:	07                   	pop    %es
f01029ff:	1f                   	pop    %ds
f0102a00:	83 c4 08             	add    $0x8,%esp
f0102a03:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102a04:	c7 44 24 08 12 49 10 	movl   $0xf0104912,0x8(%esp)
f0102a0b:	f0 
f0102a0c:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0102a13:	00 
f0102a14:	c7 04 24 07 49 10 f0 	movl   $0xf0104907,(%esp)
f0102a1b:	e8 79 d6 ff ff       	call   f0100099 <_panic>

f0102a20 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0102a20:	55                   	push   %ebp
f0102a21:	89 e5                	mov    %esp,%ebp
f0102a23:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.

        panic("env_run not yet implemented");
f0102a26:	c7 44 24 08 1e 49 10 	movl   $0xf010491e,0x8(%esp)
f0102a2d:	f0 
f0102a2e:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f0102a35:	00 
f0102a36:	c7 04 24 07 49 10 f0 	movl   $0xf0104907,(%esp)
f0102a3d:	e8 57 d6 ff ff       	call   f0100099 <_panic>
	...

f0102a44 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102a44:	55                   	push   %ebp
f0102a45:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102a47:	ba 70 00 00 00       	mov    $0x70,%edx
f0102a4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a4f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102a50:	b2 71                	mov    $0x71,%dl
f0102a52:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102a53:	0f b6 c0             	movzbl %al,%eax
}
f0102a56:	5d                   	pop    %ebp
f0102a57:	c3                   	ret    

f0102a58 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102a58:	55                   	push   %ebp
f0102a59:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102a5b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102a60:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a63:	ee                   	out    %al,(%dx)
f0102a64:	b2 71                	mov    $0x71,%dl
f0102a66:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a69:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102a6a:	5d                   	pop    %ebp
f0102a6b:	c3                   	ret    

f0102a6c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102a6c:	55                   	push   %ebp
f0102a6d:	89 e5                	mov    %esp,%ebp
f0102a6f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102a72:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a75:	89 04 24             	mov    %eax,(%esp)
f0102a78:	e8 3b dc ff ff       	call   f01006b8 <cputchar>
	*cnt++;
}
f0102a7d:	c9                   	leave  
f0102a7e:	c3                   	ret    

f0102a7f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102a7f:	55                   	push   %ebp
f0102a80:	89 e5                	mov    %esp,%ebp
f0102a82:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102a85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a93:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a96:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102a9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102aa1:	c7 04 24 6c 2a 10 f0 	movl   $0xf0102a6c,(%esp)
f0102aa8:	e8 d7 04 00 00       	call   f0102f84 <vprintfmt>
	return cnt;
}
f0102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ab0:	c9                   	leave  
f0102ab1:	c3                   	ret    

f0102ab2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102ab2:	55                   	push   %ebp
f0102ab3:	89 e5                	mov    %esp,%ebp
f0102ab5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0102ab8:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102abb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102abf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ac2:	89 04 24             	mov    %eax,(%esp)
f0102ac5:	e8 b5 ff ff ff       	call   f0102a7f <vcprintf>
	va_end(ap);

	return cnt;
}
f0102aca:	c9                   	leave  
f0102acb:	c3                   	ret    

f0102acc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102acc:	55                   	push   %ebp
f0102acd:	89 e5                	mov    %esp,%ebp
f0102acf:	57                   	push   %edi
f0102ad0:	56                   	push   %esi
f0102ad1:	53                   	push   %ebx
f0102ad2:	83 ec 10             	sub    $0x10,%esp
f0102ad5:	89 c3                	mov    %eax,%ebx
f0102ad7:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102ada:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102add:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102ae0:	8b 0a                	mov    (%edx),%ecx
f0102ae2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102ae5:	8b 00                	mov    (%eax),%eax
f0102ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102aea:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	
	while (l <= r) {
f0102af1:	eb 77                	jmp    f0102b6a <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0102af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102af6:	01 c8                	add    %ecx,%eax
f0102af8:	bf 02 00 00 00       	mov    $0x2,%edi
f0102afd:	99                   	cltd   
f0102afe:	f7 ff                	idiv   %edi
f0102b00:	89 c2                	mov    %eax,%edx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102b02:	eb 01                	jmp    f0102b05 <stab_binsearch+0x39>
			m--;
f0102b04:	4a                   	dec    %edx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102b05:	39 ca                	cmp    %ecx,%edx
f0102b07:	7c 1d                	jl     f0102b26 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102b09:	6b fa 0c             	imul   $0xc,%edx,%edi
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102b0c:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0102b11:	39 f7                	cmp    %esi,%edi
f0102b13:	75 ef                	jne    f0102b04 <stab_binsearch+0x38>
f0102b15:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102b18:	6b fa 0c             	imul   $0xc,%edx,%edi
f0102b1b:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0102b1f:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102b22:	73 18                	jae    f0102b3c <stab_binsearch+0x70>
f0102b24:	eb 05                	jmp    f0102b2b <stab_binsearch+0x5f>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102b26:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0102b29:	eb 3f                	jmp    f0102b6a <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102b2b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102b2e:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0102b30:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102b33:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102b3a:	eb 2e                	jmp    f0102b6a <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102b3c:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102b3f:	76 15                	jbe    f0102b56 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0102b41:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102b44:	4f                   	dec    %edi
f0102b45:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0102b48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b4b:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102b4d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102b54:	eb 14                	jmp    f0102b6a <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102b56:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102b59:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102b5c:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0102b5e:	ff 45 0c             	incl   0xc(%ebp)
f0102b61:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102b63:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0102b6a:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0102b6d:	7e 84                	jle    f0102af3 <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102b6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102b73:	75 0d                	jne    f0102b82 <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0102b75:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102b78:	8b 02                	mov    (%edx),%eax
f0102b7a:	48                   	dec    %eax
f0102b7b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102b7e:	89 01                	mov    %eax,(%ecx)
f0102b80:	eb 22                	jmp    f0102ba4 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102b82:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102b85:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102b87:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102b8a:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102b8c:	eb 01                	jmp    f0102b8f <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102b8e:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102b8f:	39 c1                	cmp    %eax,%ecx
f0102b91:	7d 0c                	jge    f0102b9f <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102b93:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0102b96:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0102b9b:	39 f2                	cmp    %esi,%edx
f0102b9d:	75 ef                	jne    f0102b8e <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102b9f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102ba2:	89 02                	mov    %eax,(%edx)
	}
}
f0102ba4:	83 c4 10             	add    $0x10,%esp
f0102ba7:	5b                   	pop    %ebx
f0102ba8:	5e                   	pop    %esi
f0102ba9:	5f                   	pop    %edi
f0102baa:	5d                   	pop    %ebp
f0102bab:	c3                   	ret    

f0102bac <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102bac:	55                   	push   %ebp
f0102bad:	89 e5                	mov    %esp,%ebp
f0102baf:	83 ec 58             	sub    $0x58,%esp
f0102bb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0102bb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0102bb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0102bbb:	8b 75 08             	mov    0x8(%ebp),%esi
f0102bbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102bc1:	c7 03 74 49 10 f0    	movl   $0xf0104974,(%ebx)
	info->eip_line = 0;
f0102bc7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102bce:	c7 43 08 74 49 10 f0 	movl   $0xf0104974,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102bd5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102bdc:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102bdf:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102be6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102bec:	76 12                	jbe    f0102c00 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102bee:	b8 26 d4 10 f0       	mov    $0xf010d426,%eax
f0102bf3:	3d 19 ae 10 f0       	cmp    $0xf010ae19,%eax
f0102bf8:	0f 86 dc 01 00 00    	jbe    f0102dda <debuginfo_eip+0x22e>
f0102bfe:	eb 1c                	jmp    f0102c1c <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102c00:	c7 44 24 08 7e 49 10 	movl   $0xf010497e,0x8(%esp)
f0102c07:	f0 
f0102c08:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
f0102c0f:	00 
f0102c10:	c7 04 24 8b 49 10 f0 	movl   $0xf010498b,(%esp)
f0102c17:	e8 7d d4 ff ff       	call   f0100099 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102c1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102c21:	80 3d 25 d4 10 f0 00 	cmpb   $0x0,0xf010d425
f0102c28:	0f 85 b1 01 00 00    	jne    f0102ddf <debuginfo_eip+0x233>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102c2e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102c35:	b8 18 ae 10 f0       	mov    $0xf010ae18,%eax
f0102c3a:	2d a8 4b 10 f0       	sub    $0xf0104ba8,%eax
f0102c3f:	c1 f8 02             	sar    $0x2,%eax
f0102c42:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102c48:	83 e8 01             	sub    $0x1,%eax
f0102c4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102c4e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c52:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102c59:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102c5c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102c5f:	b8 a8 4b 10 f0       	mov    $0xf0104ba8,%eax
f0102c64:	e8 63 fe ff ff       	call   f0102acc <stab_binsearch>
	if (lfile == 0)
f0102c69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0102c6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102c71:	85 d2                	test   %edx,%edx
f0102c73:	0f 84 66 01 00 00    	je     f0102ddf <debuginfo_eip+0x233>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102c79:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102c7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102c82:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c86:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102c8d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102c90:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102c93:	b8 a8 4b 10 f0       	mov    $0xf0104ba8,%eax
f0102c98:	e8 2f fe ff ff       	call   f0102acc <stab_binsearch>

	if (lfun <= rfun) {
f0102c9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102ca0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102ca3:	39 d0                	cmp    %edx,%eax
f0102ca5:	7f 3d                	jg     f0102ce4 <debuginfo_eip+0x138>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102ca7:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0102caa:	8d b9 a8 4b 10 f0    	lea    -0xfefb458(%ecx),%edi
f0102cb0:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0102cb3:	8b 89 a8 4b 10 f0    	mov    -0xfefb458(%ecx),%ecx
f0102cb9:	bf 26 d4 10 f0       	mov    $0xf010d426,%edi
f0102cbe:	81 ef 19 ae 10 f0    	sub    $0xf010ae19,%edi
f0102cc4:	39 f9                	cmp    %edi,%ecx
f0102cc6:	73 09                	jae    f0102cd1 <debuginfo_eip+0x125>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102cc8:	81 c1 19 ae 10 f0    	add    $0xf010ae19,%ecx
f0102cce:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102cd1:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102cd4:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102cd7:	89 4b 10             	mov    %ecx,0x10(%ebx)
		// This "n_value" is the function's first addr, but when it comes to SLINE,
		// "n_value" describes the offset, so we need to minus "n_value" fro addr
		// to get the offset of the line.
		addr -= info->eip_fn_addr;
f0102cda:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102cdc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102cdf:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102ce2:	eb 0f                	jmp    f0102cf3 <debuginfo_eip+0x147>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102ce4:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102ce7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102cf0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102cf3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102cfa:	00 
f0102cfb:	8b 43 08             	mov    0x8(%ebx),%eax
f0102cfe:	89 04 24             	mov    %eax,(%esp)
f0102d01:	e8 09 09 00 00       	call   f010360f <strfind>
f0102d06:	2b 43 08             	sub    0x8(%ebx),%eax
f0102d09:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102d0c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102d10:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0102d17:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102d1a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102d1d:	b8 a8 4b 10 f0       	mov    $0xf0104ba8,%eax
f0102d22:	e8 a5 fd ff ff       	call   f0102acc <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0102d27:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d2a:	6b d0 0c             	imul   $0xc,%eax,%edx
f0102d2d:	0f b7 92 ae 4b 10 f0 	movzwl -0xfefb452(%edx),%edx
f0102d34:	89 53 04             	mov    %edx,0x4(%ebx)
	if (rline < lline)
f0102d37:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0102d3a:	7e 07                	jle    f0102d43 <debuginfo_eip+0x197>
	{
		info->eip_line = -1;
f0102d3c:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102d43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d46:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102d49:	39 c8                	cmp    %ecx,%eax
f0102d4b:	7c 5f                	jl     f0102dac <debuginfo_eip+0x200>
	       && stabs[lline].n_type != N_SOL
f0102d4d:	89 c2                	mov    %eax,%edx
f0102d4f:	6b f0 0c             	imul   $0xc,%eax,%esi
f0102d52:	80 be ac 4b 10 f0 84 	cmpb   $0x84,-0xfefb454(%esi)
f0102d59:	75 18                	jne    f0102d73 <debuginfo_eip+0x1c7>
f0102d5b:	eb 30                	jmp    f0102d8d <debuginfo_eip+0x1e1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0102d5d:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102d60:	39 c1                	cmp    %eax,%ecx
f0102d62:	7f 48                	jg     f0102dac <debuginfo_eip+0x200>
	       && stabs[lline].n_type != N_SOL
f0102d64:	89 c2                	mov    %eax,%edx
f0102d66:	8d 34 40             	lea    (%eax,%eax,2),%esi
f0102d69:	80 3c b5 ac 4b 10 f0 	cmpb   $0x84,-0xfefb454(,%esi,4)
f0102d70:	84 
f0102d71:	74 1a                	je     f0102d8d <debuginfo_eip+0x1e1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102d73:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102d76:	8d 14 95 a8 4b 10 f0 	lea    -0xfefb458(,%edx,4),%edx
f0102d7d:	80 7a 04 64          	cmpb   $0x64,0x4(%edx)
f0102d81:	75 da                	jne    f0102d5d <debuginfo_eip+0x1b1>
f0102d83:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0102d87:	74 d4                	je     f0102d5d <debuginfo_eip+0x1b1>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102d89:	39 c8                	cmp    %ecx,%eax
f0102d8b:	7c 1f                	jl     f0102dac <debuginfo_eip+0x200>
f0102d8d:	6b c0 0c             	imul   $0xc,%eax,%eax
f0102d90:	8b 80 a8 4b 10 f0    	mov    -0xfefb458(%eax),%eax
f0102d96:	ba 26 d4 10 f0       	mov    $0xf010d426,%edx
f0102d9b:	81 ea 19 ae 10 f0    	sub    $0xf010ae19,%edx
f0102da1:	39 d0                	cmp    %edx,%eax
f0102da3:	73 07                	jae    f0102dac <debuginfo_eip+0x200>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102da5:	05 19 ae 10 f0       	add    $0xf010ae19,%eax
f0102daa:	89 03                	mov    %eax,(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0102dac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102daf:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0102db2:	b8 00 00 00 00       	mov    $0x0,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0102db7:	39 d1                	cmp    %edx,%ecx
f0102db9:	7c 24                	jl     f0102ddf <debuginfo_eip+0x233>
	{
		if (stabs[i].n_type == N_PSYM)
f0102dbb:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102dbe:	80 3c 85 ac 4b 10 f0 	cmpb   $0xa0,-0xfefb454(,%eax,4)
f0102dc5:	a0 
f0102dc6:	75 04                	jne    f0102dcc <debuginfo_eip+0x220>
		{
			++(info->eip_fn_narg);
f0102dc8:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0102dcc:	83 c2 01             	add    $0x1,%edx
f0102dcf:	39 d1                	cmp    %edx,%ecx
f0102dd1:	7d e8                	jge    f0102dbb <debuginfo_eip+0x20f>
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0102dd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dd8:	eb 05                	jmp    f0102ddf <debuginfo_eip+0x233>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102dda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		}
	}

	
	return 0;
}
f0102ddf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0102de2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102de5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0102de8:	89 ec                	mov    %ebp,%esp
f0102dea:	5d                   	pop    %ebp
f0102deb:	c3                   	ret    
f0102dec:	00 00                	add    %al,(%eax)
	...

f0102df0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102df0:	55                   	push   %ebp
f0102df1:	89 e5                	mov    %esp,%ebp
f0102df3:	57                   	push   %edi
f0102df4:	56                   	push   %esi
f0102df5:	53                   	push   %ebx
f0102df6:	83 ec 3c             	sub    $0x3c,%esp
f0102df9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102dfc:	89 d7                	mov    %edx,%edi
f0102dfe:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e01:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102e04:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e07:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102e0a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102e0d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102e10:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e15:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102e18:	72 11                	jb     f0102e2b <printnum+0x3b>
f0102e1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102e1d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102e20:	76 09                	jbe    f0102e2b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102e22:	83 eb 01             	sub    $0x1,%ebx
f0102e25:	85 db                	test   %ebx,%ebx
f0102e27:	7f 51                	jg     f0102e7a <printnum+0x8a>
f0102e29:	eb 5e                	jmp    f0102e89 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102e2b:	89 74 24 10          	mov    %esi,0x10(%esp)
f0102e2f:	83 eb 01             	sub    $0x1,%ebx
f0102e32:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e36:	8b 45 10             	mov    0x10(%ebp),%eax
f0102e39:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102e3d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0102e41:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0102e45:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102e4c:	00 
f0102e4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102e50:	89 04 24             	mov    %eax,(%esp)
f0102e53:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e5a:	e8 d1 09 00 00       	call   f0103830 <__udivdi3>
f0102e5f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102e63:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102e67:	89 04 24             	mov    %eax,(%esp)
f0102e6a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102e6e:	89 fa                	mov    %edi,%edx
f0102e70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e73:	e8 78 ff ff ff       	call   f0102df0 <printnum>
f0102e78:	eb 0f                	jmp    f0102e89 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102e7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102e7e:	89 34 24             	mov    %esi,(%esp)
f0102e81:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102e84:	83 eb 01             	sub    $0x1,%ebx
f0102e87:	75 f1                	jne    f0102e7a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102e89:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102e8d:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102e91:	8b 45 10             	mov    0x10(%ebp),%eax
f0102e94:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102e98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102e9f:	00 
f0102ea0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102ea3:	89 04 24             	mov    %eax,(%esp)
f0102ea6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ead:	e8 ae 0a 00 00       	call   f0103960 <__umoddi3>
f0102eb2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102eb6:	0f be 80 99 49 10 f0 	movsbl -0xfefb667(%eax),%eax
f0102ebd:	89 04 24             	mov    %eax,(%esp)
f0102ec0:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0102ec3:	83 c4 3c             	add    $0x3c,%esp
f0102ec6:	5b                   	pop    %ebx
f0102ec7:	5e                   	pop    %esi
f0102ec8:	5f                   	pop    %edi
f0102ec9:	5d                   	pop    %ebp
f0102eca:	c3                   	ret    

f0102ecb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102ecb:	55                   	push   %ebp
f0102ecc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102ece:	83 fa 01             	cmp    $0x1,%edx
f0102ed1:	7e 0e                	jle    f0102ee1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102ed3:	8b 10                	mov    (%eax),%edx
f0102ed5:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102ed8:	89 08                	mov    %ecx,(%eax)
f0102eda:	8b 02                	mov    (%edx),%eax
f0102edc:	8b 52 04             	mov    0x4(%edx),%edx
f0102edf:	eb 22                	jmp    f0102f03 <getuint+0x38>
	else if (lflag)
f0102ee1:	85 d2                	test   %edx,%edx
f0102ee3:	74 10                	je     f0102ef5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102ee5:	8b 10                	mov    (%eax),%edx
f0102ee7:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102eea:	89 08                	mov    %ecx,(%eax)
f0102eec:	8b 02                	mov    (%edx),%eax
f0102eee:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ef3:	eb 0e                	jmp    f0102f03 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102ef5:	8b 10                	mov    (%eax),%edx
f0102ef7:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102efa:	89 08                	mov    %ecx,(%eax)
f0102efc:	8b 02                	mov    (%edx),%eax
f0102efe:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102f03:	5d                   	pop    %ebp
f0102f04:	c3                   	ret    

f0102f05 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0102f05:	55                   	push   %ebp
f0102f06:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102f08:	83 fa 01             	cmp    $0x1,%edx
f0102f0b:	7e 0e                	jle    f0102f1b <getint+0x16>
		return va_arg(*ap, long long);
f0102f0d:	8b 10                	mov    (%eax),%edx
f0102f0f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102f12:	89 08                	mov    %ecx,(%eax)
f0102f14:	8b 02                	mov    (%edx),%eax
f0102f16:	8b 52 04             	mov    0x4(%edx),%edx
f0102f19:	eb 22                	jmp    f0102f3d <getint+0x38>
	else if (lflag)
f0102f1b:	85 d2                	test   %edx,%edx
f0102f1d:	74 10                	je     f0102f2f <getint+0x2a>
		return va_arg(*ap, long);
f0102f1f:	8b 10                	mov    (%eax),%edx
f0102f21:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102f24:	89 08                	mov    %ecx,(%eax)
f0102f26:	8b 02                	mov    (%edx),%eax
f0102f28:	89 c2                	mov    %eax,%edx
f0102f2a:	c1 fa 1f             	sar    $0x1f,%edx
f0102f2d:	eb 0e                	jmp    f0102f3d <getint+0x38>
	else
		return va_arg(*ap, int);
f0102f2f:	8b 10                	mov    (%eax),%edx
f0102f31:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102f34:	89 08                	mov    %ecx,(%eax)
f0102f36:	8b 02                	mov    (%edx),%eax
f0102f38:	89 c2                	mov    %eax,%edx
f0102f3a:	c1 fa 1f             	sar    $0x1f,%edx
}
f0102f3d:	5d                   	pop    %ebp
f0102f3e:	c3                   	ret    

f0102f3f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102f3f:	55                   	push   %ebp
f0102f40:	89 e5                	mov    %esp,%ebp
f0102f42:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102f45:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102f49:	8b 10                	mov    (%eax),%edx
f0102f4b:	3b 50 04             	cmp    0x4(%eax),%edx
f0102f4e:	73 0a                	jae    f0102f5a <sprintputch+0x1b>
		*b->buf++ = ch;
f0102f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102f53:	88 0a                	mov    %cl,(%edx)
f0102f55:	83 c2 01             	add    $0x1,%edx
f0102f58:	89 10                	mov    %edx,(%eax)
}
f0102f5a:	5d                   	pop    %ebp
f0102f5b:	c3                   	ret    

f0102f5c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102f5c:	55                   	push   %ebp
f0102f5d:	89 e5                	mov    %esp,%ebp
f0102f5f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0102f62:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f65:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f69:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f6c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f77:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f7a:	89 04 24             	mov    %eax,(%esp)
f0102f7d:	e8 02 00 00 00       	call   f0102f84 <vprintfmt>
	va_end(ap);
}
f0102f82:	c9                   	leave  
f0102f83:	c3                   	ret    

f0102f84 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102f84:	55                   	push   %ebp
f0102f85:	89 e5                	mov    %esp,%ebp
f0102f87:	57                   	push   %edi
f0102f88:	56                   	push   %esi
f0102f89:	53                   	push   %ebx
f0102f8a:	83 ec 4c             	sub    $0x4c,%esp
f0102f8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f90:	8b 75 10             	mov    0x10(%ebp),%esi
f0102f93:	eb 12                	jmp    f0102fa7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102f95:	85 c0                	test   %eax,%eax
f0102f97:	0f 84 98 03 00 00    	je     f0103335 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f0102f9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102fa1:	89 04 24             	mov    %eax,(%esp)
f0102fa4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102fa7:	0f b6 06             	movzbl (%esi),%eax
f0102faa:	83 c6 01             	add    $0x1,%esi
f0102fad:	83 f8 25             	cmp    $0x25,%eax
f0102fb0:	75 e3                	jne    f0102f95 <vprintfmt+0x11>
f0102fb2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0102fb6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0102fbd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0102fc2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0102fc9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102fce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102fd1:	eb 2b                	jmp    f0102ffe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102fd3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102fd6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0102fda:	eb 22                	jmp    f0102ffe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102fdc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102fdf:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0102fe3:	eb 19                	jmp    f0102ffe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102fe5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0102fe8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102fef:	eb 0d                	jmp    f0102ffe <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0102ff1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ff4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102ff7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ffe:	0f b6 06             	movzbl (%esi),%eax
f0103001:	0f b6 d0             	movzbl %al,%edx
f0103004:	8d 7e 01             	lea    0x1(%esi),%edi
f0103007:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010300a:	83 e8 23             	sub    $0x23,%eax
f010300d:	3c 55                	cmp    $0x55,%al
f010300f:	0f 87 fa 02 00 00    	ja     f010330f <vprintfmt+0x38b>
f0103015:	0f b6 c0             	movzbl %al,%eax
f0103018:	ff 24 85 24 4a 10 f0 	jmp    *-0xfefb5dc(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010301f:	83 ea 30             	sub    $0x30,%edx
f0103022:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103025:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0103029:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010302c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f010302f:	83 fa 09             	cmp    $0x9,%edx
f0103032:	77 4a                	ja     f010307e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103034:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103037:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f010303a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010303d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0103041:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103044:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103047:	83 fa 09             	cmp    $0x9,%edx
f010304a:	76 eb                	jbe    f0103037 <vprintfmt+0xb3>
f010304c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010304f:	eb 2d                	jmp    f010307e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103051:	8b 45 14             	mov    0x14(%ebp),%eax
f0103054:	8d 50 04             	lea    0x4(%eax),%edx
f0103057:	89 55 14             	mov    %edx,0x14(%ebp)
f010305a:	8b 00                	mov    (%eax),%eax
f010305c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010305f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103062:	eb 1a                	jmp    f010307e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103064:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0103067:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010306b:	79 91                	jns    f0102ffe <vprintfmt+0x7a>
f010306d:	e9 73 ff ff ff       	jmp    f0102fe5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103072:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103075:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f010307c:	eb 80                	jmp    f0102ffe <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f010307e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103082:	0f 89 76 ff ff ff    	jns    f0102ffe <vprintfmt+0x7a>
f0103088:	e9 64 ff ff ff       	jmp    f0102ff1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010308d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103090:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103093:	e9 66 ff ff ff       	jmp    f0102ffe <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103098:	8b 45 14             	mov    0x14(%ebp),%eax
f010309b:	8d 50 04             	lea    0x4(%eax),%edx
f010309e:	89 55 14             	mov    %edx,0x14(%ebp)
f01030a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01030a5:	8b 00                	mov    (%eax),%eax
f01030a7:	89 04 24             	mov    %eax,(%esp)
f01030aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01030ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01030b0:	e9 f2 fe ff ff       	jmp    f0102fa7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01030b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01030b8:	8d 50 04             	lea    0x4(%eax),%edx
f01030bb:	89 55 14             	mov    %edx,0x14(%ebp)
f01030be:	8b 00                	mov    (%eax),%eax
f01030c0:	89 c2                	mov    %eax,%edx
f01030c2:	c1 fa 1f             	sar    $0x1f,%edx
f01030c5:	31 d0                	xor    %edx,%eax
f01030c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f01030c9:	83 f8 06             	cmp    $0x6,%eax
f01030cc:	7f 0b                	jg     f01030d9 <vprintfmt+0x155>
f01030ce:	8b 14 85 7c 4b 10 f0 	mov    -0xfefb484(,%eax,4),%edx
f01030d5:	85 d2                	test   %edx,%edx
f01030d7:	75 23                	jne    f01030fc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f01030d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030dd:	c7 44 24 08 b1 49 10 	movl   $0xf01049b1,0x8(%esp)
f01030e4:	f0 
f01030e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01030e9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01030ec:	89 3c 24             	mov    %edi,(%esp)
f01030ef:	e8 68 fe ff ff       	call   f0102f5c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01030f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01030f7:	e9 ab fe ff ff       	jmp    f0102fa7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01030fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103100:	c7 44 24 08 65 47 10 	movl   $0xf0104765,0x8(%esp)
f0103107:	f0 
f0103108:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010310c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010310f:	89 3c 24             	mov    %edi,(%esp)
f0103112:	e8 45 fe ff ff       	call   f0102f5c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103117:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010311a:	e9 88 fe ff ff       	jmp    f0102fa7 <vprintfmt+0x23>
f010311f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103122:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103125:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103128:	8b 45 14             	mov    0x14(%ebp),%eax
f010312b:	8d 50 04             	lea    0x4(%eax),%edx
f010312e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103131:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103133:	85 f6                	test   %esi,%esi
f0103135:	ba aa 49 10 f0       	mov    $0xf01049aa,%edx
f010313a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f010313d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103141:	7e 06                	jle    f0103149 <vprintfmt+0x1c5>
f0103143:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0103147:	75 10                	jne    f0103159 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103149:	0f be 06             	movsbl (%esi),%eax
f010314c:	83 c6 01             	add    $0x1,%esi
f010314f:	85 c0                	test   %eax,%eax
f0103151:	0f 85 86 00 00 00    	jne    f01031dd <vprintfmt+0x259>
f0103157:	eb 76                	jmp    f01031cf <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103159:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010315d:	89 34 24             	mov    %esi,(%esp)
f0103160:	e8 36 03 00 00       	call   f010349b <strnlen>
f0103165:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103168:	29 c2                	sub    %eax,%edx
f010316a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010316d:	85 d2                	test   %edx,%edx
f010316f:	7e d8                	jle    f0103149 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0103171:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0103175:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103178:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010317b:	89 d6                	mov    %edx,%esi
f010317d:	89 c7                	mov    %eax,%edi
f010317f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103183:	89 3c 24             	mov    %edi,(%esp)
f0103186:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103189:	83 ee 01             	sub    $0x1,%esi
f010318c:	75 f1                	jne    f010317f <vprintfmt+0x1fb>
f010318e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103191:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0103194:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103197:	eb b0                	jmp    f0103149 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103199:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010319d:	74 18                	je     f01031b7 <vprintfmt+0x233>
f010319f:	8d 50 e0             	lea    -0x20(%eax),%edx
f01031a2:	83 fa 5e             	cmp    $0x5e,%edx
f01031a5:	76 10                	jbe    f01031b7 <vprintfmt+0x233>
					putch('?', putdat);
f01031a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031ab:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01031b2:	ff 55 08             	call   *0x8(%ebp)
f01031b5:	eb 0a                	jmp    f01031c1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f01031b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031bb:	89 04 24             	mov    %eax,(%esp)
f01031be:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01031c1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01031c5:	0f be 06             	movsbl (%esi),%eax
f01031c8:	83 c6 01             	add    $0x1,%esi
f01031cb:	85 c0                	test   %eax,%eax
f01031cd:	75 0e                	jne    f01031dd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01031d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01031d6:	7f 11                	jg     f01031e9 <vprintfmt+0x265>
f01031d8:	e9 ca fd ff ff       	jmp    f0102fa7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01031dd:	85 ff                	test   %edi,%edi
f01031df:	90                   	nop
f01031e0:	78 b7                	js     f0103199 <vprintfmt+0x215>
f01031e2:	83 ef 01             	sub    $0x1,%edi
f01031e5:	79 b2                	jns    f0103199 <vprintfmt+0x215>
f01031e7:	eb e6                	jmp    f01031cf <vprintfmt+0x24b>
f01031e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01031ec:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01031ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031f3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01031fa:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01031fc:	83 ee 01             	sub    $0x1,%esi
f01031ff:	75 ee                	jne    f01031ef <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103201:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103204:	e9 9e fd ff ff       	jmp    f0102fa7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103209:	89 ca                	mov    %ecx,%edx
f010320b:	8d 45 14             	lea    0x14(%ebp),%eax
f010320e:	e8 f2 fc ff ff       	call   f0102f05 <getint>
f0103213:	89 c6                	mov    %eax,%esi
f0103215:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103217:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010321c:	85 d2                	test   %edx,%edx
f010321e:	0f 89 ad 00 00 00    	jns    f01032d1 <vprintfmt+0x34d>
				putch('-', putdat);
f0103224:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103228:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010322f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103232:	f7 de                	neg    %esi
f0103234:	83 d7 00             	adc    $0x0,%edi
f0103237:	f7 df                	neg    %edi
			}
			base = 10;
f0103239:	b8 0a 00 00 00       	mov    $0xa,%eax
f010323e:	e9 8e 00 00 00       	jmp    f01032d1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103243:	89 ca                	mov    %ecx,%edx
f0103245:	8d 45 14             	lea    0x14(%ebp),%eax
f0103248:	e8 7e fc ff ff       	call   f0102ecb <getuint>
f010324d:	89 c6                	mov    %eax,%esi
f010324f:	89 d7                	mov    %edx,%edi
			base = 10;
f0103251:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103256:	eb 79                	jmp    f01032d1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f0103258:	89 ca                	mov    %ecx,%edx
f010325a:	8d 45 14             	lea    0x14(%ebp),%eax
f010325d:	e8 a3 fc ff ff       	call   f0102f05 <getint>
f0103262:	89 c6                	mov    %eax,%esi
f0103264:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f0103266:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010326b:	85 d2                	test   %edx,%edx
f010326d:	79 62                	jns    f01032d1 <vprintfmt+0x34d>
				putch('-', putdat);
f010326f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103273:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010327a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010327d:	f7 de                	neg    %esi
f010327f:	83 d7 00             	adc    $0x0,%edi
f0103282:	f7 df                	neg    %edi
			}
			base = 8;
f0103284:	b8 08 00 00 00       	mov    $0x8,%eax
f0103289:	eb 46                	jmp    f01032d1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f010328b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010328f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103296:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103299:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010329d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01032a4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01032a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01032aa:	8d 50 04             	lea    0x4(%eax),%edx
f01032ad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01032b0:	8b 30                	mov    (%eax),%esi
f01032b2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01032b7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01032bc:	eb 13                	jmp    f01032d1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01032be:	89 ca                	mov    %ecx,%edx
f01032c0:	8d 45 14             	lea    0x14(%ebp),%eax
f01032c3:	e8 03 fc ff ff       	call   f0102ecb <getuint>
f01032c8:	89 c6                	mov    %eax,%esi
f01032ca:	89 d7                	mov    %edx,%edi
			base = 16;
f01032cc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01032d1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01032d5:	89 54 24 10          	mov    %edx,0x10(%esp)
f01032d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01032dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01032e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01032e4:	89 34 24             	mov    %esi,(%esp)
f01032e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01032eb:	89 da                	mov    %ebx,%edx
f01032ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f0:	e8 fb fa ff ff       	call   f0102df0 <printnum>
			break;
f01032f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01032f8:	e9 aa fc ff ff       	jmp    f0102fa7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01032fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103301:	89 14 24             	mov    %edx,(%esp)
f0103304:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103307:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010330a:	e9 98 fc ff ff       	jmp    f0102fa7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010330f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103313:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010331a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010331d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103321:	0f 84 80 fc ff ff    	je     f0102fa7 <vprintfmt+0x23>
f0103327:	83 ee 01             	sub    $0x1,%esi
f010332a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010332e:	75 f7                	jne    f0103327 <vprintfmt+0x3a3>
f0103330:	e9 72 fc ff ff       	jmp    f0102fa7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0103335:	83 c4 4c             	add    $0x4c,%esp
f0103338:	5b                   	pop    %ebx
f0103339:	5e                   	pop    %esi
f010333a:	5f                   	pop    %edi
f010333b:	5d                   	pop    %ebp
f010333c:	c3                   	ret    

f010333d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010333d:	55                   	push   %ebp
f010333e:	89 e5                	mov    %esp,%ebp
f0103340:	83 ec 28             	sub    $0x28,%esp
f0103343:	8b 45 08             	mov    0x8(%ebp),%eax
f0103346:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103349:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010334c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103350:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103353:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010335a:	85 c0                	test   %eax,%eax
f010335c:	74 30                	je     f010338e <vsnprintf+0x51>
f010335e:	85 d2                	test   %edx,%edx
f0103360:	7e 2c                	jle    f010338e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103362:	8b 45 14             	mov    0x14(%ebp),%eax
f0103365:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103369:	8b 45 10             	mov    0x10(%ebp),%eax
f010336c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103370:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103373:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103377:	c7 04 24 3f 2f 10 f0 	movl   $0xf0102f3f,(%esp)
f010337e:	e8 01 fc ff ff       	call   f0102f84 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103383:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103386:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103389:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010338c:	eb 05                	jmp    f0103393 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010338e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103393:	c9                   	leave  
f0103394:	c3                   	ret    

f0103395 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103395:	55                   	push   %ebp
f0103396:	89 e5                	mov    %esp,%ebp
f0103398:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f010339b:	8d 45 14             	lea    0x14(%ebp),%eax
f010339e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033a2:	8b 45 10             	mov    0x10(%ebp),%eax
f01033a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b3:	89 04 24             	mov    %eax,(%esp)
f01033b6:	e8 82 ff ff ff       	call   f010333d <vsnprintf>
	va_end(ap);

	return rc;
}
f01033bb:	c9                   	leave  
f01033bc:	c3                   	ret    
f01033bd:	00 00                	add    %al,(%eax)
	...

f01033c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01033c0:	55                   	push   %ebp
f01033c1:	89 e5                	mov    %esp,%ebp
f01033c3:	57                   	push   %edi
f01033c4:	56                   	push   %esi
f01033c5:	53                   	push   %ebx
f01033c6:	83 ec 1c             	sub    $0x1c,%esp
f01033c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01033cc:	85 c0                	test   %eax,%eax
f01033ce:	74 10                	je     f01033e0 <readline+0x20>
		cprintf("%s", prompt);
f01033d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033d4:	c7 04 24 65 47 10 f0 	movl   $0xf0104765,(%esp)
f01033db:	e8 d2 f6 ff ff       	call   f0102ab2 <cprintf>

	i = 0;
	echoing = iscons(0);
f01033e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01033e7:	e8 f0 d2 ff ff       	call   f01006dc <iscons>
f01033ec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01033ee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01033f3:	e8 d3 d2 ff ff       	call   f01006cb <getchar>
f01033f8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01033fa:	85 c0                	test   %eax,%eax
f01033fc:	79 17                	jns    f0103415 <readline+0x55>
			cprintf("read error: %e\n", c);
f01033fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103402:	c7 04 24 98 4b 10 f0 	movl   $0xf0104b98,(%esp)
f0103409:	e8 a4 f6 ff ff       	call   f0102ab2 <cprintf>
			return NULL;
f010340e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103413:	eb 61                	jmp    f0103476 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103415:	83 f8 1f             	cmp    $0x1f,%eax
f0103418:	7e 1f                	jle    f0103439 <readline+0x79>
f010341a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103420:	7f 17                	jg     f0103439 <readline+0x79>
			if (echoing)
f0103422:	85 ff                	test   %edi,%edi
f0103424:	74 08                	je     f010342e <readline+0x6e>
				cputchar(c);
f0103426:	89 04 24             	mov    %eax,(%esp)
f0103429:	e8 8a d2 ff ff       	call   f01006b8 <cputchar>
			buf[i++] = c;
f010342e:	88 9e 00 66 11 f0    	mov    %bl,-0xfee9a00(%esi)
f0103434:	83 c6 01             	add    $0x1,%esi
f0103437:	eb ba                	jmp    f01033f3 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0103439:	83 fb 08             	cmp    $0x8,%ebx
f010343c:	75 15                	jne    f0103453 <readline+0x93>
f010343e:	85 f6                	test   %esi,%esi
f0103440:	7e 11                	jle    f0103453 <readline+0x93>
			if (echoing)
f0103442:	85 ff                	test   %edi,%edi
f0103444:	74 08                	je     f010344e <readline+0x8e>
				cputchar(c);
f0103446:	89 1c 24             	mov    %ebx,(%esp)
f0103449:	e8 6a d2 ff ff       	call   f01006b8 <cputchar>
			i--;
f010344e:	83 ee 01             	sub    $0x1,%esi
f0103451:	eb a0                	jmp    f01033f3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103453:	83 fb 0a             	cmp    $0xa,%ebx
f0103456:	74 05                	je     f010345d <readline+0x9d>
f0103458:	83 fb 0d             	cmp    $0xd,%ebx
f010345b:	75 96                	jne    f01033f3 <readline+0x33>
			if (echoing)
f010345d:	85 ff                	test   %edi,%edi
f010345f:	90                   	nop
f0103460:	74 08                	je     f010346a <readline+0xaa>
				cputchar(c);
f0103462:	89 1c 24             	mov    %ebx,(%esp)
f0103465:	e8 4e d2 ff ff       	call   f01006b8 <cputchar>
			buf[i] = 0;
f010346a:	c6 86 00 66 11 f0 00 	movb   $0x0,-0xfee9a00(%esi)
			return buf;
f0103471:	b8 00 66 11 f0       	mov    $0xf0116600,%eax
		}
	}
}
f0103476:	83 c4 1c             	add    $0x1c,%esp
f0103479:	5b                   	pop    %ebx
f010347a:	5e                   	pop    %esi
f010347b:	5f                   	pop    %edi
f010347c:	5d                   	pop    %ebp
f010347d:	c3                   	ret    
	...

f0103480 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0103480:	55                   	push   %ebp
f0103481:	89 e5                	mov    %esp,%ebp
f0103483:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103486:	b8 00 00 00 00       	mov    $0x0,%eax
f010348b:	80 3a 00             	cmpb   $0x0,(%edx)
f010348e:	74 09                	je     f0103499 <strlen+0x19>
		n++;
f0103490:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103493:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103497:	75 f7                	jne    f0103490 <strlen+0x10>
		n++;
	return n;
}
f0103499:	5d                   	pop    %ebp
f010349a:	c3                   	ret    

f010349b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010349b:	55                   	push   %ebp
f010349c:	89 e5                	mov    %esp,%ebp
f010349e:	53                   	push   %ebx
f010349f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01034a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01034a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01034aa:	85 c9                	test   %ecx,%ecx
f01034ac:	74 1a                	je     f01034c8 <strnlen+0x2d>
f01034ae:	80 3b 00             	cmpb   $0x0,(%ebx)
f01034b1:	74 15                	je     f01034c8 <strnlen+0x2d>
f01034b3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01034b8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01034ba:	39 ca                	cmp    %ecx,%edx
f01034bc:	74 0a                	je     f01034c8 <strnlen+0x2d>
f01034be:	83 c2 01             	add    $0x1,%edx
f01034c1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01034c6:	75 f0                	jne    f01034b8 <strnlen+0x1d>
		n++;
	return n;
}
f01034c8:	5b                   	pop    %ebx
f01034c9:	5d                   	pop    %ebp
f01034ca:	c3                   	ret    

f01034cb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01034cb:	55                   	push   %ebp
f01034cc:	89 e5                	mov    %esp,%ebp
f01034ce:	53                   	push   %ebx
f01034cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01034d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01034da:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01034de:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01034e1:	83 c2 01             	add    $0x1,%edx
f01034e4:	84 c9                	test   %cl,%cl
f01034e6:	75 f2                	jne    f01034da <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01034e8:	5b                   	pop    %ebx
f01034e9:	5d                   	pop    %ebp
f01034ea:	c3                   	ret    

f01034eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01034eb:	55                   	push   %ebp
f01034ec:	89 e5                	mov    %esp,%ebp
f01034ee:	56                   	push   %esi
f01034ef:	53                   	push   %ebx
f01034f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034f6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01034f9:	85 f6                	test   %esi,%esi
f01034fb:	74 18                	je     f0103515 <strncpy+0x2a>
f01034fd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103502:	0f b6 1a             	movzbl (%edx),%ebx
f0103505:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103508:	80 3a 01             	cmpb   $0x1,(%edx)
f010350b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010350e:	83 c1 01             	add    $0x1,%ecx
f0103511:	39 f1                	cmp    %esi,%ecx
f0103513:	75 ed                	jne    f0103502 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103515:	5b                   	pop    %ebx
f0103516:	5e                   	pop    %esi
f0103517:	5d                   	pop    %ebp
f0103518:	c3                   	ret    

f0103519 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103519:	55                   	push   %ebp
f010351a:	89 e5                	mov    %esp,%ebp
f010351c:	57                   	push   %edi
f010351d:	56                   	push   %esi
f010351e:	53                   	push   %ebx
f010351f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103525:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103528:	89 f8                	mov    %edi,%eax
f010352a:	85 f6                	test   %esi,%esi
f010352c:	74 2b                	je     f0103559 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f010352e:	83 fe 01             	cmp    $0x1,%esi
f0103531:	74 23                	je     f0103556 <strlcpy+0x3d>
f0103533:	0f b6 0b             	movzbl (%ebx),%ecx
f0103536:	84 c9                	test   %cl,%cl
f0103538:	74 1c                	je     f0103556 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010353a:	83 ee 02             	sub    $0x2,%esi
f010353d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103542:	88 08                	mov    %cl,(%eax)
f0103544:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103547:	39 f2                	cmp    %esi,%edx
f0103549:	74 0b                	je     f0103556 <strlcpy+0x3d>
f010354b:	83 c2 01             	add    $0x1,%edx
f010354e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103552:	84 c9                	test   %cl,%cl
f0103554:	75 ec                	jne    f0103542 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0103556:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103559:	29 f8                	sub    %edi,%eax
}
f010355b:	5b                   	pop    %ebx
f010355c:	5e                   	pop    %esi
f010355d:	5f                   	pop    %edi
f010355e:	5d                   	pop    %ebp
f010355f:	c3                   	ret    

f0103560 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103560:	55                   	push   %ebp
f0103561:	89 e5                	mov    %esp,%ebp
f0103563:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103566:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103569:	0f b6 01             	movzbl (%ecx),%eax
f010356c:	84 c0                	test   %al,%al
f010356e:	74 16                	je     f0103586 <strcmp+0x26>
f0103570:	3a 02                	cmp    (%edx),%al
f0103572:	75 12                	jne    f0103586 <strcmp+0x26>
		p++, q++;
f0103574:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103577:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f010357b:	84 c0                	test   %al,%al
f010357d:	74 07                	je     f0103586 <strcmp+0x26>
f010357f:	83 c1 01             	add    $0x1,%ecx
f0103582:	3a 02                	cmp    (%edx),%al
f0103584:	74 ee                	je     f0103574 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103586:	0f b6 c0             	movzbl %al,%eax
f0103589:	0f b6 12             	movzbl (%edx),%edx
f010358c:	29 d0                	sub    %edx,%eax
}
f010358e:	5d                   	pop    %ebp
f010358f:	c3                   	ret    

f0103590 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103590:	55                   	push   %ebp
f0103591:	89 e5                	mov    %esp,%ebp
f0103593:	53                   	push   %ebx
f0103594:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010359a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010359d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01035a2:	85 d2                	test   %edx,%edx
f01035a4:	74 28                	je     f01035ce <strncmp+0x3e>
f01035a6:	0f b6 01             	movzbl (%ecx),%eax
f01035a9:	84 c0                	test   %al,%al
f01035ab:	74 24                	je     f01035d1 <strncmp+0x41>
f01035ad:	3a 03                	cmp    (%ebx),%al
f01035af:	75 20                	jne    f01035d1 <strncmp+0x41>
f01035b1:	83 ea 01             	sub    $0x1,%edx
f01035b4:	74 13                	je     f01035c9 <strncmp+0x39>
		n--, p++, q++;
f01035b6:	83 c1 01             	add    $0x1,%ecx
f01035b9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01035bc:	0f b6 01             	movzbl (%ecx),%eax
f01035bf:	84 c0                	test   %al,%al
f01035c1:	74 0e                	je     f01035d1 <strncmp+0x41>
f01035c3:	3a 03                	cmp    (%ebx),%al
f01035c5:	74 ea                	je     f01035b1 <strncmp+0x21>
f01035c7:	eb 08                	jmp    f01035d1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01035c9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01035ce:	5b                   	pop    %ebx
f01035cf:	5d                   	pop    %ebp
f01035d0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01035d1:	0f b6 01             	movzbl (%ecx),%eax
f01035d4:	0f b6 13             	movzbl (%ebx),%edx
f01035d7:	29 d0                	sub    %edx,%eax
f01035d9:	eb f3                	jmp    f01035ce <strncmp+0x3e>

f01035db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01035db:	55                   	push   %ebp
f01035dc:	89 e5                	mov    %esp,%ebp
f01035de:	8b 45 08             	mov    0x8(%ebp),%eax
f01035e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01035e5:	0f b6 10             	movzbl (%eax),%edx
f01035e8:	84 d2                	test   %dl,%dl
f01035ea:	74 1c                	je     f0103608 <strchr+0x2d>
		if (*s == c)
f01035ec:	38 ca                	cmp    %cl,%dl
f01035ee:	75 09                	jne    f01035f9 <strchr+0x1e>
f01035f0:	eb 1b                	jmp    f010360d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01035f2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f01035f5:	38 ca                	cmp    %cl,%dl
f01035f7:	74 14                	je     f010360d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01035f9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f01035fd:	84 d2                	test   %dl,%dl
f01035ff:	75 f1                	jne    f01035f2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0103601:	b8 00 00 00 00       	mov    $0x0,%eax
f0103606:	eb 05                	jmp    f010360d <strchr+0x32>
f0103608:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010360d:	5d                   	pop    %ebp
f010360e:	c3                   	ret    

f010360f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010360f:	55                   	push   %ebp
f0103610:	89 e5                	mov    %esp,%ebp
f0103612:	8b 45 08             	mov    0x8(%ebp),%eax
f0103615:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103619:	0f b6 10             	movzbl (%eax),%edx
f010361c:	84 d2                	test   %dl,%dl
f010361e:	74 14                	je     f0103634 <strfind+0x25>
		if (*s == c)
f0103620:	38 ca                	cmp    %cl,%dl
f0103622:	75 06                	jne    f010362a <strfind+0x1b>
f0103624:	eb 0e                	jmp    f0103634 <strfind+0x25>
f0103626:	38 ca                	cmp    %cl,%dl
f0103628:	74 0a                	je     f0103634 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010362a:	83 c0 01             	add    $0x1,%eax
f010362d:	0f b6 10             	movzbl (%eax),%edx
f0103630:	84 d2                	test   %dl,%dl
f0103632:	75 f2                	jne    f0103626 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0103634:	5d                   	pop    %ebp
f0103635:	c3                   	ret    

f0103636 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0103636:	55                   	push   %ebp
f0103637:	89 e5                	mov    %esp,%ebp
f0103639:	53                   	push   %ebx
f010363a:	8b 45 08             	mov    0x8(%ebp),%eax
f010363d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103640:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0103643:	89 da                	mov    %ebx,%edx
f0103645:	83 ea 01             	sub    $0x1,%edx
f0103648:	78 0d                	js     f0103657 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f010364a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f010364c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f010364e:	88 0a                	mov    %cl,(%edx)
f0103650:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0103653:	39 da                	cmp    %ebx,%edx
f0103655:	75 f7                	jne    f010364e <memset+0x18>
		*p++ = c;

	return v;
}
f0103657:	5b                   	pop    %ebx
f0103658:	5d                   	pop    %ebp
f0103659:	c3                   	ret    

f010365a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f010365a:	55                   	push   %ebp
f010365b:	89 e5                	mov    %esp,%ebp
f010365d:	57                   	push   %edi
f010365e:	56                   	push   %esi
f010365f:	53                   	push   %ebx
f0103660:	8b 45 08             	mov    0x8(%ebp),%eax
f0103663:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103666:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103669:	39 c6                	cmp    %eax,%esi
f010366b:	72 0b                	jb     f0103678 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f010366d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103672:	85 db                	test   %ebx,%ebx
f0103674:	75 29                	jne    f010369f <memmove+0x45>
f0103676:	eb 35                	jmp    f01036ad <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103678:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f010367b:	39 c8                	cmp    %ecx,%eax
f010367d:	73 ee                	jae    f010366d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f010367f:	85 db                	test   %ebx,%ebx
f0103681:	74 2a                	je     f01036ad <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0103683:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f0103686:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f0103688:	f7 db                	neg    %ebx
f010368a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f010368d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f010368f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0103694:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0103698:	83 ea 01             	sub    $0x1,%edx
f010369b:	75 f2                	jne    f010368f <memmove+0x35>
f010369d:	eb 0e                	jmp    f01036ad <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f010369f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01036a3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01036a6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f01036a9:	39 d3                	cmp    %edx,%ebx
f01036ab:	75 f2                	jne    f010369f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f01036ad:	5b                   	pop    %ebx
f01036ae:	5e                   	pop    %esi
f01036af:	5f                   	pop    %edi
f01036b0:	5d                   	pop    %ebp
f01036b1:	c3                   	ret    

f01036b2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01036b2:	55                   	push   %ebp
f01036b3:	89 e5                	mov    %esp,%ebp
f01036b5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01036b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01036bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036bf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036c9:	89 04 24             	mov    %eax,(%esp)
f01036cc:	e8 89 ff ff ff       	call   f010365a <memmove>
}
f01036d1:	c9                   	leave  
f01036d2:	c3                   	ret    

f01036d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01036d3:	55                   	push   %ebp
f01036d4:	89 e5                	mov    %esp,%ebp
f01036d6:	57                   	push   %edi
f01036d7:	56                   	push   %esi
f01036d8:	53                   	push   %ebx
f01036d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01036dc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01036df:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01036e2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01036e7:	85 ff                	test   %edi,%edi
f01036e9:	74 37                	je     f0103722 <memcmp+0x4f>
		if (*s1 != *s2)
f01036eb:	0f b6 03             	movzbl (%ebx),%eax
f01036ee:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01036f1:	83 ef 01             	sub    $0x1,%edi
f01036f4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f01036f9:	38 c8                	cmp    %cl,%al
f01036fb:	74 1c                	je     f0103719 <memcmp+0x46>
f01036fd:	eb 10                	jmp    f010370f <memcmp+0x3c>
f01036ff:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0103704:	83 c2 01             	add    $0x1,%edx
f0103707:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010370b:	38 c8                	cmp    %cl,%al
f010370d:	74 0a                	je     f0103719 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f010370f:	0f b6 c0             	movzbl %al,%eax
f0103712:	0f b6 c9             	movzbl %cl,%ecx
f0103715:	29 c8                	sub    %ecx,%eax
f0103717:	eb 09                	jmp    f0103722 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103719:	39 fa                	cmp    %edi,%edx
f010371b:	75 e2                	jne    f01036ff <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010371d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103722:	5b                   	pop    %ebx
f0103723:	5e                   	pop    %esi
f0103724:	5f                   	pop    %edi
f0103725:	5d                   	pop    %ebp
f0103726:	c3                   	ret    

f0103727 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103727:	55                   	push   %ebp
f0103728:	89 e5                	mov    %esp,%ebp
f010372a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010372d:	89 c2                	mov    %eax,%edx
f010372f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103732:	39 d0                	cmp    %edx,%eax
f0103734:	73 15                	jae    f010374b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103736:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010373a:	38 08                	cmp    %cl,(%eax)
f010373c:	75 06                	jne    f0103744 <memfind+0x1d>
f010373e:	eb 0b                	jmp    f010374b <memfind+0x24>
f0103740:	38 08                	cmp    %cl,(%eax)
f0103742:	74 07                	je     f010374b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103744:	83 c0 01             	add    $0x1,%eax
f0103747:	39 d0                	cmp    %edx,%eax
f0103749:	75 f5                	jne    f0103740 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010374b:	5d                   	pop    %ebp
f010374c:	c3                   	ret    

f010374d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010374d:	55                   	push   %ebp
f010374e:	89 e5                	mov    %esp,%ebp
f0103750:	57                   	push   %edi
f0103751:	56                   	push   %esi
f0103752:	53                   	push   %ebx
f0103753:	8b 55 08             	mov    0x8(%ebp),%edx
f0103756:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103759:	0f b6 02             	movzbl (%edx),%eax
f010375c:	3c 20                	cmp    $0x20,%al
f010375e:	74 04                	je     f0103764 <strtol+0x17>
f0103760:	3c 09                	cmp    $0x9,%al
f0103762:	75 0e                	jne    f0103772 <strtol+0x25>
		s++;
f0103764:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103767:	0f b6 02             	movzbl (%edx),%eax
f010376a:	3c 20                	cmp    $0x20,%al
f010376c:	74 f6                	je     f0103764 <strtol+0x17>
f010376e:	3c 09                	cmp    $0x9,%al
f0103770:	74 f2                	je     f0103764 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103772:	3c 2b                	cmp    $0x2b,%al
f0103774:	75 0a                	jne    f0103780 <strtol+0x33>
		s++;
f0103776:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103779:	bf 00 00 00 00       	mov    $0x0,%edi
f010377e:	eb 10                	jmp    f0103790 <strtol+0x43>
f0103780:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103785:	3c 2d                	cmp    $0x2d,%al
f0103787:	75 07                	jne    f0103790 <strtol+0x43>
		s++, neg = 1;
f0103789:	83 c2 01             	add    $0x1,%edx
f010378c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103790:	85 db                	test   %ebx,%ebx
f0103792:	0f 94 c0             	sete   %al
f0103795:	74 05                	je     f010379c <strtol+0x4f>
f0103797:	83 fb 10             	cmp    $0x10,%ebx
f010379a:	75 15                	jne    f01037b1 <strtol+0x64>
f010379c:	80 3a 30             	cmpb   $0x30,(%edx)
f010379f:	75 10                	jne    f01037b1 <strtol+0x64>
f01037a1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01037a5:	75 0a                	jne    f01037b1 <strtol+0x64>
		s += 2, base = 16;
f01037a7:	83 c2 02             	add    $0x2,%edx
f01037aa:	bb 10 00 00 00       	mov    $0x10,%ebx
f01037af:	eb 13                	jmp    f01037c4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f01037b1:	84 c0                	test   %al,%al
f01037b3:	74 0f                	je     f01037c4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01037b5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01037ba:	80 3a 30             	cmpb   $0x30,(%edx)
f01037bd:	75 05                	jne    f01037c4 <strtol+0x77>
		s++, base = 8;
f01037bf:	83 c2 01             	add    $0x1,%edx
f01037c2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01037c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01037c9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01037cb:	0f b6 0a             	movzbl (%edx),%ecx
f01037ce:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01037d1:	80 fb 09             	cmp    $0x9,%bl
f01037d4:	77 08                	ja     f01037de <strtol+0x91>
			dig = *s - '0';
f01037d6:	0f be c9             	movsbl %cl,%ecx
f01037d9:	83 e9 30             	sub    $0x30,%ecx
f01037dc:	eb 1e                	jmp    f01037fc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f01037de:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01037e1:	80 fb 19             	cmp    $0x19,%bl
f01037e4:	77 08                	ja     f01037ee <strtol+0xa1>
			dig = *s - 'a' + 10;
f01037e6:	0f be c9             	movsbl %cl,%ecx
f01037e9:	83 e9 57             	sub    $0x57,%ecx
f01037ec:	eb 0e                	jmp    f01037fc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f01037ee:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01037f1:	80 fb 19             	cmp    $0x19,%bl
f01037f4:	77 14                	ja     f010380a <strtol+0xbd>
			dig = *s - 'A' + 10;
f01037f6:	0f be c9             	movsbl %cl,%ecx
f01037f9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01037fc:	39 f1                	cmp    %esi,%ecx
f01037fe:	7d 0e                	jge    f010380e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103800:	83 c2 01             	add    $0x1,%edx
f0103803:	0f af c6             	imul   %esi,%eax
f0103806:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0103808:	eb c1                	jmp    f01037cb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010380a:	89 c1                	mov    %eax,%ecx
f010380c:	eb 02                	jmp    f0103810 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010380e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103810:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103814:	74 05                	je     f010381b <strtol+0xce>
		*endptr = (char *) s;
f0103816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103819:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010381b:	89 ca                	mov    %ecx,%edx
f010381d:	f7 da                	neg    %edx
f010381f:	85 ff                	test   %edi,%edi
f0103821:	0f 45 c2             	cmovne %edx,%eax
}
f0103824:	5b                   	pop    %ebx
f0103825:	5e                   	pop    %esi
f0103826:	5f                   	pop    %edi
f0103827:	5d                   	pop    %ebp
f0103828:	c3                   	ret    
f0103829:	00 00                	add    %al,(%eax)
f010382b:	00 00                	add    %al,(%eax)
f010382d:	00 00                	add    %al,(%eax)
	...

f0103830 <__udivdi3>:
f0103830:	83 ec 1c             	sub    $0x1c,%esp
f0103833:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0103837:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010383b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010383f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103843:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103847:	8b 74 24 24          	mov    0x24(%esp),%esi
f010384b:	85 ff                	test   %edi,%edi
f010384d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0103851:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103855:	89 cd                	mov    %ecx,%ebp
f0103857:	89 44 24 04          	mov    %eax,0x4(%esp)
f010385b:	75 33                	jne    f0103890 <__udivdi3+0x60>
f010385d:	39 f1                	cmp    %esi,%ecx
f010385f:	77 57                	ja     f01038b8 <__udivdi3+0x88>
f0103861:	85 c9                	test   %ecx,%ecx
f0103863:	75 0b                	jne    f0103870 <__udivdi3+0x40>
f0103865:	b8 01 00 00 00       	mov    $0x1,%eax
f010386a:	31 d2                	xor    %edx,%edx
f010386c:	f7 f1                	div    %ecx
f010386e:	89 c1                	mov    %eax,%ecx
f0103870:	89 f0                	mov    %esi,%eax
f0103872:	31 d2                	xor    %edx,%edx
f0103874:	f7 f1                	div    %ecx
f0103876:	89 c6                	mov    %eax,%esi
f0103878:	8b 44 24 04          	mov    0x4(%esp),%eax
f010387c:	f7 f1                	div    %ecx
f010387e:	89 f2                	mov    %esi,%edx
f0103880:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103884:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103888:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010388c:	83 c4 1c             	add    $0x1c,%esp
f010388f:	c3                   	ret    
f0103890:	31 d2                	xor    %edx,%edx
f0103892:	31 c0                	xor    %eax,%eax
f0103894:	39 f7                	cmp    %esi,%edi
f0103896:	77 e8                	ja     f0103880 <__udivdi3+0x50>
f0103898:	0f bd cf             	bsr    %edi,%ecx
f010389b:	83 f1 1f             	xor    $0x1f,%ecx
f010389e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01038a2:	75 2c                	jne    f01038d0 <__udivdi3+0xa0>
f01038a4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f01038a8:	76 04                	jbe    f01038ae <__udivdi3+0x7e>
f01038aa:	39 f7                	cmp    %esi,%edi
f01038ac:	73 d2                	jae    f0103880 <__udivdi3+0x50>
f01038ae:	31 d2                	xor    %edx,%edx
f01038b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01038b5:	eb c9                	jmp    f0103880 <__udivdi3+0x50>
f01038b7:	90                   	nop
f01038b8:	89 f2                	mov    %esi,%edx
f01038ba:	f7 f1                	div    %ecx
f01038bc:	31 d2                	xor    %edx,%edx
f01038be:	8b 74 24 10          	mov    0x10(%esp),%esi
f01038c2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01038c6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01038ca:	83 c4 1c             	add    $0x1c,%esp
f01038cd:	c3                   	ret    
f01038ce:	66 90                	xchg   %ax,%ax
f01038d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01038d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01038da:	89 ea                	mov    %ebp,%edx
f01038dc:	2b 44 24 04          	sub    0x4(%esp),%eax
f01038e0:	d3 e7                	shl    %cl,%edi
f01038e2:	89 c1                	mov    %eax,%ecx
f01038e4:	d3 ea                	shr    %cl,%edx
f01038e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01038eb:	09 fa                	or     %edi,%edx
f01038ed:	89 f7                	mov    %esi,%edi
f01038ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01038f3:	89 f2                	mov    %esi,%edx
f01038f5:	8b 74 24 08          	mov    0x8(%esp),%esi
f01038f9:	d3 e5                	shl    %cl,%ebp
f01038fb:	89 c1                	mov    %eax,%ecx
f01038fd:	d3 ef                	shr    %cl,%edi
f01038ff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103904:	d3 e2                	shl    %cl,%edx
f0103906:	89 c1                	mov    %eax,%ecx
f0103908:	d3 ee                	shr    %cl,%esi
f010390a:	09 d6                	or     %edx,%esi
f010390c:	89 fa                	mov    %edi,%edx
f010390e:	89 f0                	mov    %esi,%eax
f0103910:	f7 74 24 0c          	divl   0xc(%esp)
f0103914:	89 d7                	mov    %edx,%edi
f0103916:	89 c6                	mov    %eax,%esi
f0103918:	f7 e5                	mul    %ebp
f010391a:	39 d7                	cmp    %edx,%edi
f010391c:	72 22                	jb     f0103940 <__udivdi3+0x110>
f010391e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0103922:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103927:	d3 e5                	shl    %cl,%ebp
f0103929:	39 c5                	cmp    %eax,%ebp
f010392b:	73 04                	jae    f0103931 <__udivdi3+0x101>
f010392d:	39 d7                	cmp    %edx,%edi
f010392f:	74 0f                	je     f0103940 <__udivdi3+0x110>
f0103931:	89 f0                	mov    %esi,%eax
f0103933:	31 d2                	xor    %edx,%edx
f0103935:	e9 46 ff ff ff       	jmp    f0103880 <__udivdi3+0x50>
f010393a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103940:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103943:	31 d2                	xor    %edx,%edx
f0103945:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103949:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010394d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103951:	83 c4 1c             	add    $0x1c,%esp
f0103954:	c3                   	ret    
	...

f0103960 <__umoddi3>:
f0103960:	83 ec 1c             	sub    $0x1c,%esp
f0103963:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0103967:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010396b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010396f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103973:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103977:	8b 74 24 24          	mov    0x24(%esp),%esi
f010397b:	85 ed                	test   %ebp,%ebp
f010397d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0103981:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103985:	89 cf                	mov    %ecx,%edi
f0103987:	89 04 24             	mov    %eax,(%esp)
f010398a:	89 f2                	mov    %esi,%edx
f010398c:	75 1a                	jne    f01039a8 <__umoddi3+0x48>
f010398e:	39 f1                	cmp    %esi,%ecx
f0103990:	76 4e                	jbe    f01039e0 <__umoddi3+0x80>
f0103992:	f7 f1                	div    %ecx
f0103994:	89 d0                	mov    %edx,%eax
f0103996:	31 d2                	xor    %edx,%edx
f0103998:	8b 74 24 10          	mov    0x10(%esp),%esi
f010399c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01039a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01039a4:	83 c4 1c             	add    $0x1c,%esp
f01039a7:	c3                   	ret    
f01039a8:	39 f5                	cmp    %esi,%ebp
f01039aa:	77 54                	ja     f0103a00 <__umoddi3+0xa0>
f01039ac:	0f bd c5             	bsr    %ebp,%eax
f01039af:	83 f0 1f             	xor    $0x1f,%eax
f01039b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039b6:	75 60                	jne    f0103a18 <__umoddi3+0xb8>
f01039b8:	3b 0c 24             	cmp    (%esp),%ecx
f01039bb:	0f 87 07 01 00 00    	ja     f0103ac8 <__umoddi3+0x168>
f01039c1:	89 f2                	mov    %esi,%edx
f01039c3:	8b 34 24             	mov    (%esp),%esi
f01039c6:	29 ce                	sub    %ecx,%esi
f01039c8:	19 ea                	sbb    %ebp,%edx
f01039ca:	89 34 24             	mov    %esi,(%esp)
f01039cd:	8b 04 24             	mov    (%esp),%eax
f01039d0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01039d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01039d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01039dc:	83 c4 1c             	add    $0x1c,%esp
f01039df:	c3                   	ret    
f01039e0:	85 c9                	test   %ecx,%ecx
f01039e2:	75 0b                	jne    f01039ef <__umoddi3+0x8f>
f01039e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01039e9:	31 d2                	xor    %edx,%edx
f01039eb:	f7 f1                	div    %ecx
f01039ed:	89 c1                	mov    %eax,%ecx
f01039ef:	89 f0                	mov    %esi,%eax
f01039f1:	31 d2                	xor    %edx,%edx
f01039f3:	f7 f1                	div    %ecx
f01039f5:	8b 04 24             	mov    (%esp),%eax
f01039f8:	f7 f1                	div    %ecx
f01039fa:	eb 98                	jmp    f0103994 <__umoddi3+0x34>
f01039fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103a00:	89 f2                	mov    %esi,%edx
f0103a02:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103a06:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103a0a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103a0e:	83 c4 1c             	add    $0x1c,%esp
f0103a11:	c3                   	ret    
f0103a12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103a18:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103a1d:	89 e8                	mov    %ebp,%eax
f0103a1f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0103a24:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0103a28:	89 fa                	mov    %edi,%edx
f0103a2a:	d3 e0                	shl    %cl,%eax
f0103a2c:	89 e9                	mov    %ebp,%ecx
f0103a2e:	d3 ea                	shr    %cl,%edx
f0103a30:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103a35:	09 c2                	or     %eax,%edx
f0103a37:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103a3b:	89 14 24             	mov    %edx,(%esp)
f0103a3e:	89 f2                	mov    %esi,%edx
f0103a40:	d3 e7                	shl    %cl,%edi
f0103a42:	89 e9                	mov    %ebp,%ecx
f0103a44:	d3 ea                	shr    %cl,%edx
f0103a46:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103a4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103a4f:	d3 e6                	shl    %cl,%esi
f0103a51:	89 e9                	mov    %ebp,%ecx
f0103a53:	d3 e8                	shr    %cl,%eax
f0103a55:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103a5a:	09 f0                	or     %esi,%eax
f0103a5c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103a60:	f7 34 24             	divl   (%esp)
f0103a63:	d3 e6                	shl    %cl,%esi
f0103a65:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103a69:	89 d6                	mov    %edx,%esi
f0103a6b:	f7 e7                	mul    %edi
f0103a6d:	39 d6                	cmp    %edx,%esi
f0103a6f:	89 c1                	mov    %eax,%ecx
f0103a71:	89 d7                	mov    %edx,%edi
f0103a73:	72 3f                	jb     f0103ab4 <__umoddi3+0x154>
f0103a75:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0103a79:	72 35                	jb     f0103ab0 <__umoddi3+0x150>
f0103a7b:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103a7f:	29 c8                	sub    %ecx,%eax
f0103a81:	19 fe                	sbb    %edi,%esi
f0103a83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103a88:	89 f2                	mov    %esi,%edx
f0103a8a:	d3 e8                	shr    %cl,%eax
f0103a8c:	89 e9                	mov    %ebp,%ecx
f0103a8e:	d3 e2                	shl    %cl,%edx
f0103a90:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103a95:	09 d0                	or     %edx,%eax
f0103a97:	89 f2                	mov    %esi,%edx
f0103a99:	d3 ea                	shr    %cl,%edx
f0103a9b:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103a9f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103aa3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103aa7:	83 c4 1c             	add    $0x1c,%esp
f0103aaa:	c3                   	ret    
f0103aab:	90                   	nop
f0103aac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ab0:	39 d6                	cmp    %edx,%esi
f0103ab2:	75 c7                	jne    f0103a7b <__umoddi3+0x11b>
f0103ab4:	89 d7                	mov    %edx,%edi
f0103ab6:	89 c1                	mov    %eax,%ecx
f0103ab8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0103abc:	1b 3c 24             	sbb    (%esp),%edi
f0103abf:	eb ba                	jmp    f0103a7b <__umoddi3+0x11b>
f0103ac1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ac8:	39 f5                	cmp    %esi,%ebp
f0103aca:	0f 82 f1 fe ff ff    	jb     f01039c1 <__umoddi3+0x61>
f0103ad0:	e9 f8 fe ff ff       	jmp    f01039cd <__umoddi3+0x6d>
