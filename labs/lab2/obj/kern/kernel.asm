
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
f0100015:	0f 01 15 18 40 11 00 	lgdtl  0x114018

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
f0100033:	bc 00 40 11 f0       	mov    $0xf0114000,%esp

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
f0100046:	b8 10 4a 11 f0       	mov    $0xf0114a10,%eax
f010004b:	2d 70 43 11 f0       	sub    $0xf0114370,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 70 43 11 f0 	movl   $0xf0114370,(%esp)
f0100063:	e8 1e 2a 00 00       	call   f0102a86 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 24 06 00 00       	call   f0100691 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 40 2f 10 f0 	movl   $0xf0102f40,(%esp)
f010007c:	e8 7d 1e 00 00       	call   f0101efe <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100081:	e8 a2 0a 00 00       	call   f0100b28 <i386_detect_memory>
	i386_vm_init();
f0100086:	e8 33 0d 00 00       	call   f0100dbe <i386_vm_init>
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
f010009f:	83 3d 80 43 11 f0 00 	cmpl   $0x0,0xf0114380
f01000a6:	75 40                	jne    f01000e8 <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f01000a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000ab:	a3 80 43 11 f0       	mov    %eax,0xf0114380

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000be:	c7 04 24 5b 2f 10 f0 	movl   $0xf0102f5b,(%esp)
f01000c5:	e8 34 1e 00 00       	call   f0101efe <cprintf>
	vcprintf(fmt, ap);
f01000ca:	8d 45 14             	lea    0x14(%ebp),%eax
f01000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000d1:	8b 45 10             	mov    0x10(%ebp),%eax
f01000d4:	89 04 24             	mov    %eax,(%esp)
f01000d7:	e8 ef 1d 00 00       	call   f0101ecb <vcprintf>
	cprintf("\n");
f01000dc:	c7 04 24 97 2f 10 f0 	movl   $0xf0102f97,(%esp)
f01000e3:	e8 16 1e 00 00       	call   f0101efe <cprintf>
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
f010010a:	c7 04 24 73 2f 10 f0 	movl   $0xf0102f73,(%esp)
f0100111:	e8 e8 1d 00 00       	call   f0101efe <cprintf>
	vcprintf(fmt, ap);
f0100116:	8d 45 14             	lea    0x14(%ebp),%eax
f0100119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010011d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100120:	89 04 24             	mov    %eax,(%esp)
f0100123:	e8 a3 1d 00 00       	call   f0101ecb <vcprintf>
	cprintf("\n");
f0100128:	c7 04 24 97 2f 10 f0 	movl   $0xf0102f97,(%esp)
f010012f:	e8 ca 1d 00 00       	call   f0101efe <cprintf>
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
f0100177:	83 0d b0 43 11 f0 40 	orl    $0x40,0xf01143b0
		return 0;
f010017e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100183:	e9 c4 00 00 00       	jmp    f010024c <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100188:	84 c0                	test   %al,%al
f010018a:	79 37                	jns    f01001c3 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010018c:	8b 0d b0 43 11 f0    	mov    0xf01143b0,%ecx
f0100192:	89 cb                	mov    %ecx,%ebx
f0100194:	83 e3 40             	and    $0x40,%ebx
f0100197:	83 e0 7f             	and    $0x7f,%eax
f010019a:	85 db                	test   %ebx,%ebx
f010019c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010019f:	0f b6 d2             	movzbl %dl,%edx
f01001a2:	0f b6 82 a0 31 10 f0 	movzbl -0xfefce60(%edx),%eax
f01001a9:	83 c8 40             	or     $0x40,%eax
f01001ac:	0f b6 c0             	movzbl %al,%eax
f01001af:	f7 d0                	not    %eax
f01001b1:	21 c1                	and    %eax,%ecx
f01001b3:	89 0d b0 43 11 f0    	mov    %ecx,0xf01143b0
		return 0;
f01001b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001be:	e9 89 00 00 00       	jmp    f010024c <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01001c3:	8b 0d b0 43 11 f0    	mov    0xf01143b0,%ecx
f01001c9:	f6 c1 40             	test   $0x40,%cl
f01001cc:	74 0e                	je     f01001dc <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ce:	89 c2                	mov    %eax,%edx
f01001d0:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01001d3:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001d6:	89 0d b0 43 11 f0    	mov    %ecx,0xf01143b0
	}

	shift |= shiftcode[data];
f01001dc:	0f b6 d2             	movzbl %dl,%edx
f01001df:	0f b6 82 a0 31 10 f0 	movzbl -0xfefce60(%edx),%eax
f01001e6:	0b 05 b0 43 11 f0    	or     0xf01143b0,%eax
	shift ^= togglecode[data];
f01001ec:	0f b6 8a a0 32 10 f0 	movzbl -0xfefcd60(%edx),%ecx
f01001f3:	31 c8                	xor    %ecx,%eax
f01001f5:	a3 b0 43 11 f0       	mov    %eax,0xf01143b0

	c = charcode[shift & (CTL | SHIFT)][data];
f01001fa:	89 c1                	mov    %eax,%ecx
f01001fc:	83 e1 03             	and    $0x3,%ecx
f01001ff:	8b 0c 8d a0 33 10 f0 	mov    -0xfefcc60(,%ecx,4),%ecx
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
f0100235:	c7 04 24 8d 2f 10 f0 	movl   $0xf0102f8d,(%esp)
f010023c:	e8 bd 1c 00 00       	call   f0101efe <cprintf>
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
f01002a5:	a3 a0 43 11 f0       	mov    %eax,0xf01143a0
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
f01002df:	c7 05 a4 43 11 f0 b4 	movl   $0x3b4,0xf01143a4
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
f01002f7:	c7 05 a4 43 11 f0 d4 	movl   $0x3d4,0xf01143a4
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
f0100306:	8b 0d a4 43 11 f0    	mov    0xf01143a4,%ecx
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
f010032b:	89 35 a8 43 11 f0    	mov    %esi,0xf01143a8
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100331:	0f b6 d8             	movzbl %al,%ebx
f0100334:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100336:	66 89 3d ac 43 11 f0 	mov    %di,0xf01143ac
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
f010035f:	8b 15 c4 45 11 f0    	mov    0xf01145c4,%edx
f0100365:	88 82 c0 43 11 f0    	mov    %al,-0xfeebc40(%edx)
f010036b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010036e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100373:	ba 00 00 00 00       	mov    $0x0,%edx
f0100378:	0f 44 c2             	cmove  %edx,%eax
f010037b:	a3 c4 45 11 f0       	mov    %eax,0xf01145c4
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
f01003a7:	83 3d a0 43 11 f0 00 	cmpl   $0x0,0xf01143a0
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
f01003ce:	8b 15 c0 45 11 f0    	mov    0xf01145c0,%edx
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
f01003d9:	3b 15 c4 45 11 f0    	cmp    0xf01145c4,%edx
f01003df:	74 1e                	je     f01003ff <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01003e1:	0f b6 82 c0 43 11 f0 	movzbl -0xfeebc40(%edx),%eax
f01003e8:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01003eb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01003f6:	0f 44 d1             	cmove  %ecx,%edx
f01003f9:	89 15 c0 45 11 f0    	mov    %edx,0xf01145c0
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
f010048a:	ff 24 95 c0 2f 10 f0 	jmp    *-0xfefd040(,%edx,4)
	case '\b':
		if (crt_pos > 0) {
f0100491:	0f b7 15 ac 43 11 f0 	movzwl 0xf01143ac,%edx
f0100498:	66 85 d2             	test   %dx,%dx
f010049b:	0f 84 bb 01 00 00    	je     f010065c <cga_putc+0x1fe>
			crt_pos--;
f01004a1:	83 ea 01             	sub    $0x1,%edx
f01004a4:	66 89 15 ac 43 11 f0 	mov    %dx,0xf01143ac
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ab:	0f b7 d2             	movzwl %dx,%edx
f01004ae:	b0 00                	mov    $0x0,%al
f01004b0:	89 c1                	mov    %eax,%ecx
f01004b2:	83 c9 20             	or     $0x20,%ecx
f01004b5:	a1 a8 43 11 f0       	mov    0xf01143a8,%eax
f01004ba:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01004be:	e9 4c 01 00 00       	jmp    f010060f <cga_putc+0x1b1>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004c3:	66 83 05 ac 43 11 f0 	addw   $0x50,0xf01143ac
f01004ca:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004cb:	0f b7 05 ac 43 11 f0 	movzwl 0xf01143ac,%eax
f01004d2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d8:	c1 e8 16             	shr    $0x16,%eax
f01004db:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004de:	c1 e0 04             	shl    $0x4,%eax
f01004e1:	66 a3 ac 43 11 f0    	mov    %ax,0xf01143ac
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
f010052d:	0f b7 15 ac 43 11 f0 	movzwl 0xf01143ac,%edx
f0100534:	0f b7 da             	movzwl %dx,%ebx
f0100537:	80 e4 f0             	and    $0xf0,%ah
f010053a:	80 cc 0c             	or     $0xc,%ah
f010053d:	8b 0d a8 43 11 f0    	mov    0xf01143a8,%ecx
f0100543:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100547:	83 c2 01             	add    $0x1,%edx
f010054a:	66 89 15 ac 43 11 f0 	mov    %dx,0xf01143ac
		break;
f0100551:	e9 b9 00 00 00       	jmp    f010060f <cga_putc+0x1b1>
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0900;
f0100556:	0f b7 15 ac 43 11 f0 	movzwl 0xf01143ac,%edx
f010055d:	0f b7 da             	movzwl %dx,%ebx
f0100560:	80 e4 f0             	and    $0xf0,%ah
f0100563:	80 cc 09             	or     $0x9,%ah
f0100566:	8b 0d a8 43 11 f0    	mov    0xf01143a8,%ecx
f010056c:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100570:	83 c2 01             	add    $0x1,%edx
f0100573:	66 89 15 ac 43 11 f0 	mov    %dx,0xf01143ac
		break;
f010057a:	e9 90 00 00 00       	jmp    f010060f <cga_putc+0x1b1>
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0100;
f010057f:	0f b7 15 ac 43 11 f0 	movzwl 0xf01143ac,%edx
f0100586:	0f b7 da             	movzwl %dx,%ebx
f0100589:	80 e4 f0             	and    $0xf0,%ah
f010058c:	80 cc 01             	or     $0x1,%ah
f010058f:	8b 0d a8 43 11 f0    	mov    0xf01143a8,%ecx
f0100595:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100599:	83 c2 01             	add    $0x1,%edx
f010059c:	66 89 15 ac 43 11 f0 	mov    %dx,0xf01143ac
		break;
f01005a3:	eb 6a                	jmp    f010060f <cga_putc+0x1b1>
	case '%':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0e00;
f01005a5:	0f b7 15 ac 43 11 f0 	movzwl 0xf01143ac,%edx
f01005ac:	0f b7 da             	movzwl %dx,%ebx
f01005af:	80 e4 f0             	and    $0xf0,%ah
f01005b2:	80 cc 0e             	or     $0xe,%ah
f01005b5:	8b 0d a8 43 11 f0    	mov    0xf01143a8,%ecx
f01005bb:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005bf:	83 c2 01             	add    $0x1,%edx
f01005c2:	66 89 15 ac 43 11 f0 	mov    %dx,0xf01143ac
		break;
f01005c9:	eb 44                	jmp    f010060f <cga_putc+0x1b1>
	case '&':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0d00;
f01005cb:	0f b7 15 ac 43 11 f0 	movzwl 0xf01143ac,%edx
f01005d2:	0f b7 da             	movzwl %dx,%ebx
f01005d5:	80 e4 f0             	and    $0xf0,%ah
f01005d8:	80 cc 0d             	or     $0xd,%ah
f01005db:	8b 0d a8 43 11 f0    	mov    0xf01143a8,%ecx
f01005e1:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005e5:	83 c2 01             	add    $0x1,%edx
f01005e8:	66 89 15 ac 43 11 f0 	mov    %dx,0xf01143ac
		break;
f01005ef:	eb 1e                	jmp    f010060f <cga_putc+0x1b1>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005f1:	0f b7 15 ac 43 11 f0 	movzwl 0xf01143ac,%edx
f01005f8:	0f b7 da             	movzwl %dx,%ebx
f01005fb:	8b 0d a8 43 11 f0    	mov    0xf01143a8,%ecx
f0100601:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100605:	83 c2 01             	add    $0x1,%edx
f0100608:	66 89 15 ac 43 11 f0 	mov    %dx,0xf01143ac
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010060f:	66 81 3d ac 43 11 f0 	cmpw   $0x7cf,0xf01143ac
f0100616:	cf 07 
f0100618:	76 42                	jbe    f010065c <cga_putc+0x1fe>
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010061a:	a1 a8 43 11 f0       	mov    0xf01143a8,%eax
f010061f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100626:	00 
f0100627:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010062d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100631:	89 04 24             	mov    %eax,(%esp)
f0100634:	e8 71 24 00 00       	call   f0102aaa <memmove>
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0c00 | ' ';
f0100639:	8b 15 a8 43 11 f0    	mov    0xf01143a8,%edx
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
f0100654:	66 83 2d ac 43 11 f0 	subw   $0x50,0xf01143ac
f010065b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010065c:	8b 0d a4 43 11 f0    	mov    0xf01143a4,%ecx
f0100662:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100667:	89 ca                	mov    %ecx,%edx
f0100669:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010066a:	0f b7 35 ac 43 11 f0 	movzwl 0xf01143ac,%esi
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
f01006a1:	83 3d a0 43 11 f0 00 	cmpl   $0x0,0xf01143a0
f01006a8:	75 0c                	jne    f01006b6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01006aa:	c7 04 24 99 2f 10 f0 	movl   $0xf0102f99,(%esp)
f01006b1:	e8 48 18 00 00       	call   f0101efe <cprintf>
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
f01006f6:	c7 04 24 b0 33 10 f0 	movl   $0xf01033b0,(%esp)
f01006fd:	e8 fc 17 00 00       	call   f0101efe <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100702:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100709:	00 
f010070a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100711:	f0 
f0100712:	c7 04 24 7c 34 10 f0 	movl   $0xf010347c,(%esp)
f0100719:	e8 e0 17 00 00       	call   f0101efe <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010071e:	c7 44 24 08 25 2f 10 	movl   $0x102f25,0x8(%esp)
f0100725:	00 
f0100726:	c7 44 24 04 25 2f 10 	movl   $0xf0102f25,0x4(%esp)
f010072d:	f0 
f010072e:	c7 04 24 a0 34 10 f0 	movl   $0xf01034a0,(%esp)
f0100735:	e8 c4 17 00 00       	call   f0101efe <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010073a:	c7 44 24 08 70 43 11 	movl   $0x114370,0x8(%esp)
f0100741:	00 
f0100742:	c7 44 24 04 70 43 11 	movl   $0xf0114370,0x4(%esp)
f0100749:	f0 
f010074a:	c7 04 24 c4 34 10 f0 	movl   $0xf01034c4,(%esp)
f0100751:	e8 a8 17 00 00       	call   f0101efe <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100756:	c7 44 24 08 10 4a 11 	movl   $0x114a10,0x8(%esp)
f010075d:	00 
f010075e:	c7 44 24 04 10 4a 11 	movl   $0xf0114a10,0x4(%esp)
f0100765:	f0 
f0100766:	c7 04 24 e8 34 10 f0 	movl   $0xf01034e8,(%esp)
f010076d:	e8 8c 17 00 00       	call   f0101efe <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f0100772:	b8 0f 4e 11 f0       	mov    $0xf0114e0f,%eax
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
f010078e:	c7 04 24 0c 35 10 f0 	movl   $0xf010350c,(%esp)
f0100795:	e8 64 17 00 00       	call   f0101efe <cprintf>
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
f01007ad:	8b 83 04 36 10 f0    	mov    -0xfefc9fc(%ebx),%eax
f01007b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007b7:	8b 83 00 36 10 f0    	mov    -0xfefca00(%ebx),%eax
f01007bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c1:	c7 04 24 c9 33 10 f0 	movl   $0xf01033c9,(%esp)
f01007c8:	e8 31 17 00 00       	call   f0101efe <cprintf>
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
f01007e9:	c7 04 24 38 35 10 f0 	movl   $0xf0103538,(%esp)
f01007f0:	e8 09 17 00 00       	call   f0101efe <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007f5:	c7 04 24 5c 35 10 f0 	movl   $0xf010355c,(%esp)
f01007fc:	e8 fd 16 00 00       	call   f0101efe <cprintf>


	while (1) {
		buf = readline("K> ");
f0100801:	c7 04 24 d2 33 10 f0 	movl   $0xf01033d2,(%esp)
f0100808:	e8 03 20 00 00       	call   f0102810 <readline>
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
f0100835:	c7 04 24 d6 33 10 f0 	movl   $0xf01033d6,(%esp)
f010083c:	e8 ea 21 00 00       	call   f0102a2b <strchr>
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
f010085a:	c7 04 24 db 33 10 f0 	movl   $0xf01033db,(%esp)
f0100861:	e8 98 16 00 00       	call   f0101efe <cprintf>
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
f0100889:	c7 04 24 d6 33 10 f0 	movl   $0xf01033d6,(%esp)
f0100890:	e8 96 21 00 00       	call   f0102a2b <strchr>
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
f01008ab:	bb 00 36 10 f0       	mov    $0xf0103600,%ebx
f01008b0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008b5:	8b 03                	mov    (%ebx),%eax
f01008b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008bb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008be:	89 04 24             	mov    %eax,(%esp)
f01008c1:	e8 ea 20 00 00       	call   f01029b0 <strcmp>
f01008c6:	85 c0                	test   %eax,%eax
f01008c8:	75 24                	jne    f01008ee <monitor+0x10e>
			return commands[i].func(argc, argv, tf);
f01008ca:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008cd:	8b 55 08             	mov    0x8(%ebp),%edx
f01008d0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008d4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008d7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008db:	89 34 24             	mov    %esi,(%esp)
f01008de:	ff 14 85 08 36 10 f0 	call   *-0xfefc9f8(,%eax,4)


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
f0100900:	c7 04 24 f8 33 10 f0 	movl   $0xf01033f8,(%esp)
f0100907:	e8 f2 15 00 00       	call   f0101efe <cprintf>
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
f010092a:	c7 04 24 0e 34 10 f0 	movl   $0xf010340e,(%esp)
f0100931:	e8 c8 15 00 00       	call   f0101efe <cprintf>
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
f0100958:	e8 9b 16 00 00       	call   f0101ff8 <debuginfo_eip>
f010095d:	85 c0                	test   %eax,%eax
f010095f:	0f 88 a5 00 00 00    	js     f0100a0a <mon_backtrace+0xe9>
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
f0100965:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100968:	89 44 24 08          	mov    %eax,0x8(%esp)
f010096c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010096f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100973:	c7 04 24 6b 2f 10 f0 	movl   $0xf0102f6b,(%esp)
f010097a:	e8 7f 15 00 00       	call   f0101efe <cprintf>
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f010097f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100983:	7e 24                	jle    f01009a9 <mon_backtrace+0x88>
f0100985:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
f010098a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010098d:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100991:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100995:	c7 04 24 20 34 10 f0 	movl   $0xf0103420,(%esp)
f010099c:	e8 5d 15 00 00       	call   f0101efe <cprintf>
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
f01009b7:	c7 04 24 23 34 10 f0 	movl   $0xf0103423,(%esp)
f01009be:	e8 3b 15 00 00       	call   f0101efe <cprintf>
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
f01009ea:	c7 04 24 84 35 10 f0 	movl   $0xf0103584,(%esp)
f01009f1:	e8 08 15 00 00       	call   f0101efe <cprintf>
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
f0100a0a:	c7 04 24 2c 34 10 f0 	movl   $0xf010342c,(%esp)
f0100a11:	e8 e8 14 00 00       	call   f0101efe <cprintf>
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
f0100a40:	83 3d d4 45 11 f0 00 	cmpl   $0x0,0xf01145d4

	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	boot_freemem = ROUNDUP(boot_freemem, align);
f0100a47:	b8 10 4a 11 f0       	mov    $0xf0114a10,%eax
f0100a4c:	0f 45 05 d4 45 11 f0 	cmovne 0xf01145d4,%eax
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
f0100a73:	89 35 d4 45 11 f0    	mov    %esi,0xf01145d4
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
f0100aa8:	3b 05 00 4a 11 f0    	cmp    0xf0114a00,%eax
f0100aae:	72 20                	jb     f0100ad0 <check_va2pa+0x4b>
f0100ab0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100ab4:	c7 44 24 08 24 36 10 	movl   $0xf0103624,0x8(%esp)
f0100abb:	f0 
f0100abc:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f0100ac3:	00 
f0100ac4:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
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
f0100b07:	e8 84 13 00 00       	call   f0101e90 <mc146818_read>
f0100b0c:	89 c6                	mov    %eax,%esi
f0100b0e:	83 c3 01             	add    $0x1,%ebx
f0100b11:	89 1c 24             	mov    %ebx,(%esp)
f0100b14:	e8 77 13 00 00       	call   f0101e90 <mc146818_read>
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
f0100b40:	a3 c8 45 11 f0       	mov    %eax,0xf01145c8
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0100b45:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b4a:	e8 a7 ff ff ff       	call   f0100af6 <nvram_read>
f0100b4f:	c1 e0 0a             	shl    $0xa,%eax
f0100b52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b57:	a3 cc 45 11 f0       	mov    %eax,0xf01145cc

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0100b5c:	85 c0                	test   %eax,%eax
f0100b5e:	74 0c                	je     f0100b6c <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0100b60:	05 00 00 10 00       	add    $0x100000,%eax
f0100b65:	a3 d0 45 11 f0       	mov    %eax,0xf01145d0
f0100b6a:	eb 0a                	jmp    f0100b76 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0100b6c:	a1 c8 45 11 f0       	mov    0xf01145c8,%eax
f0100b71:	a3 d0 45 11 f0       	mov    %eax,0xf01145d0

	npage = maxpa / PGSIZE;
f0100b76:	a1 d0 45 11 f0       	mov    0xf01145d0,%eax
f0100b7b:	89 c2                	mov    %eax,%edx
f0100b7d:	c1 ea 0c             	shr    $0xc,%edx
f0100b80:	89 15 00 4a 11 f0    	mov    %edx,0xf0114a00

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100b86:	c1 e8 0a             	shr    $0xa,%eax
f0100b89:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b8d:	c7 04 24 48 36 10 f0 	movl   $0xf0103648,(%esp)
f0100b94:	e8 65 13 00 00       	call   f0101efe <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100b99:	a1 cc 45 11 f0       	mov    0xf01145cc,%eax
f0100b9e:	c1 e8 0a             	shr    $0xa,%eax
f0100ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ba5:	a1 c8 45 11 f0       	mov    0xf01145c8,%eax
f0100baa:	c1 e8 0a             	shr    $0xa,%eax
f0100bad:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bb1:	c7 04 24 cc 39 10 f0 	movl   $0xf01039cc,(%esp)
f0100bb8:	e8 41 13 00 00       	call   f0101efe <cprintf>
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
f0100bc7:	c7 05 d8 45 11 f0 00 	movl   $0x0,0xf01145d8
f0100bce:	00 00 00 
	for (i = 0; i < npage; i++) {
f0100bd1:	83 3d 00 4a 11 f0 00 	cmpl   $0x0,0xf0114a00
f0100bd8:	74 5f                	je     f0100c39 <page_init+0x7a>
f0100bda:	ba 00 00 00 00       	mov    $0x0,%edx
f0100bdf:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f0100be4:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0100be7:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
f0100bee:	8b 1d 0c 4a 11 f0    	mov    0xf0114a0c,%ebx
f0100bf4:	66 c7 44 13 08 00 00 	movw   $0x0,0x8(%ebx,%edx,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100bfb:	8b 0d d8 45 11 f0    	mov    0xf01145d8,%ecx
f0100c01:	89 0c b3             	mov    %ecx,(%ebx,%esi,4)
f0100c04:	85 c9                	test   %ecx,%ecx
f0100c06:	74 11                	je     f0100c19 <page_init+0x5a>
f0100c08:	8b 1d 0c 4a 11 f0    	mov    0xf0114a0c,%ebx
f0100c0e:	01 d3                	add    %edx,%ebx
f0100c10:	8b 0d d8 45 11 f0    	mov    0xf01145d8,%ecx
f0100c16:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100c19:	03 15 0c 4a 11 f0    	add    0xf0114a0c,%edx
f0100c1f:	89 15 d8 45 11 f0    	mov    %edx,0xf01145d8
f0100c25:	c7 42 04 d8 45 11 f0 	movl   $0xf01145d8,0x4(%edx)
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0100c2c:	83 c0 01             	add    $0x1,%eax
f0100c2f:	89 c2                	mov    %eax,%edx
f0100c31:	3b 05 00 4a 11 f0    	cmp    0xf0114a00,%eax
f0100c37:	72 ab                	jb     f0100be4 <page_init+0x25>
	// --pgstart;	// protect IOPHYSMEM
	// pgend->pp_link = pgstart;

	// the second method, slow
	// but can edit the .ref to 1
	pages[0].pp_ref = 1;
f0100c39:	a1 0c 4a 11 f0       	mov    0xf0114a0c,%eax
f0100c3e:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	// remove the first page
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
f0100c57:	8b 1d d4 45 11 f0    	mov    0xf01145d4,%ebx
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
f0100c8c:	03 05 0c 4a 11 f0    	add    0xf0114a0c,%eax
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
	// remove the first page
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
f0100cbb:	c7 44 24 08 6c 36 10 	movl   $0xf010366c,0x8(%esp)
f0100cc2:	f0 
f0100cc3:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f0100cca:	00 
f0100ccb:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
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
f0100ce1:	8b 55 08             	mov    0x8(%ebp),%edx
	// Fill this function in
	if (LIST_FIRST(&page_free_list) != NULL)
f0100ce4:	a1 d8 45 11 f0       	mov    0xf01145d8,%eax
f0100ce9:	85 c0                	test   %eax,%eax
f0100ceb:	74 1e                	je     f0100d0b <page_alloc+0x2d>
	{
		// obtain the first page in page_free_list
		*pp_store = LIST_FIRST(&page_free_list);
f0100ced:	89 02                	mov    %eax,(%edx)
		// remove the obtained page in page_free_list
		LIST_REMOVE(*pp_store, pp_link);
f0100cef:	8b 08                	mov    (%eax),%ecx
f0100cf1:	85 c9                	test   %ecx,%ecx
f0100cf3:	74 06                	je     f0100cfb <page_alloc+0x1d>
f0100cf5:	8b 40 04             	mov    0x4(%eax),%eax
f0100cf8:	89 41 04             	mov    %eax,0x4(%ecx)
f0100cfb:	8b 02                	mov    (%edx),%eax
f0100cfd:	8b 50 04             	mov    0x4(%eax),%edx
f0100d00:	8b 00                	mov    (%eax),%eax
f0100d02:	89 02                	mov    %eax,(%edx)
		return 0;
f0100d04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d09:	eb 05                	jmp    f0100d10 <page_alloc+0x32>
	}
	else
	{
		return -E_NO_MEM;
f0100d0b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
}
f0100d10:	5d                   	pop    %ebp
f0100d11:	c3                   	ret    

f0100d12 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100d12:	55                   	push   %ebp
f0100d13:	89 e5                	mov    %esp,%ebp
f0100d15:	53                   	push   %ebx
f0100d16:	83 ec 14             	sub    $0x14,%esp
f0100d19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pp->pp_ref)
f0100d1c:	66 83 7b 08 00       	cmpw   $0x0,0x8(%ebx)
f0100d21:	74 1c                	je     f0100d3f <page_free+0x2d>
	{
		// in case
		panic("pp->pp_ref != 0, but page_free called");
f0100d23:	c7 44 24 08 90 36 10 	movl   $0xf0103690,0x8(%esp)
f0100d2a:	f0 
f0100d2b:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0100d32:	00 
f0100d33:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0100d3a:	e8 5a f3 ff ff       	call   f0100099 <_panic>
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f0100d3f:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0100d46:	00 
f0100d47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d4e:	00 
f0100d4f:	89 1c 24             	mov    %ebx,(%esp)
f0100d52:	e8 2f 1d 00 00       	call   f0102a86 <memset>
		panic("pp->pp_ref != 0, but page_free called");
	}
	else
	{
		page_initpp(pp);
		LIST_INSERT_HEAD(&page_free_list, pp, pp_link);
f0100d57:	a1 d8 45 11 f0       	mov    0xf01145d8,%eax
f0100d5c:	89 03                	mov    %eax,(%ebx)
f0100d5e:	85 c0                	test   %eax,%eax
f0100d60:	74 08                	je     f0100d6a <page_free+0x58>
f0100d62:	a1 d8 45 11 f0       	mov    0xf01145d8,%eax
f0100d67:	89 58 04             	mov    %ebx,0x4(%eax)
f0100d6a:	89 1d d8 45 11 f0    	mov    %ebx,0xf01145d8
f0100d70:	c7 43 04 d8 45 11 f0 	movl   $0xf01145d8,0x4(%ebx)
	}
}
f0100d77:	83 c4 14             	add    $0x14,%esp
f0100d7a:	5b                   	pop    %ebx
f0100d7b:	5d                   	pop    %ebp
f0100d7c:	c3                   	ret    

f0100d7d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100d7d:	55                   	push   %ebp
f0100d7e:	89 e5                	mov    %esp,%ebp
f0100d80:	83 ec 18             	sub    $0x18,%esp
f0100d83:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100d86:	0f b7 50 08          	movzwl 0x8(%eax),%edx
f0100d8a:	83 ea 01             	sub    $0x1,%edx
f0100d8d:	66 89 50 08          	mov    %dx,0x8(%eax)
f0100d91:	66 85 d2             	test   %dx,%dx
f0100d94:	75 08                	jne    f0100d9e <page_decref+0x21>
		page_free(pp);
f0100d96:	89 04 24             	mov    %eax,(%esp)
f0100d99:	e8 74 ff ff ff       	call   f0100d12 <page_free>
}
f0100d9e:	c9                   	leave  
f0100d9f:	c3                   	ret    

f0100da0 <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100da0:	55                   	push   %ebp
f0100da1:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100da3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100da8:	5d                   	pop    %ebp
f0100da9:	c3                   	ret    

f0100daa <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0100daa:	55                   	push   %ebp
f0100dab:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100dad:	b8 00 00 00 00       	mov    $0x0,%eax
f0100db2:	5d                   	pop    %ebp
f0100db3:	c3                   	ret    

f0100db4 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100db4:	55                   	push   %ebp
f0100db5:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100db7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dbc:	5d                   	pop    %ebp
f0100dbd:	c3                   	ret    

f0100dbe <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0100dbe:	55                   	push   %ebp
f0100dbf:	89 e5                	mov    %esp,%ebp
f0100dc1:	57                   	push   %edi
f0100dc2:	56                   	push   %esi
f0100dc3:	53                   	push   %ebx
f0100dc4:	83 ec 4c             	sub    $0x4c,%esp
	// Delete this line:
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f0100dc7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0100dcc:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100dd1:	e8 5a fc ff ff       	call   f0100a30 <boot_alloc>
f0100dd6:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f0100dd8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ddf:	00 
f0100de0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100de7:	00 
f0100de8:	89 04 24             	mov    %eax,(%esp)
f0100deb:	e8 96 1c 00 00       	call   f0102a86 <memset>
	boot_pgdir = pgdir;
f0100df0:	89 1d 08 4a 11 f0    	mov    %ebx,0xf0114a08
	boot_cr3 = PADDR(pgdir);
f0100df6:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100dfc:	77 20                	ja     f0100e1e <i386_vm_init+0x60>
f0100dfe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100e02:	c7 44 24 08 6c 36 10 	movl   $0xf010366c,0x8(%esp)
f0100e09:	f0 
f0100e0a:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
f0100e11:	00 
f0100e12:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0100e19:	e8 7b f2 ff ff       	call   f0100099 <_panic>
f0100e1e:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0100e24:	a3 04 4a 11 f0       	mov    %eax,0xf0114a04
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f0100e29:	89 c2                	mov    %eax,%edx
f0100e2b:	83 ca 03             	or     $0x3,%edx
f0100e2e:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f0100e34:	83 c8 05             	or     $0x5,%eax
f0100e37:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// The kernel uses this structure to keep track of physical pages;
	// 'npage' equals the number of physical pages in memory.  User-level
	// programs will get read-only access to the array as well.
	// You must allocate the array yourself.
	// Your code goes here: 
	pages = (struct Page *)boot_alloc(npage*sizeof(struct Page), PGSIZE);
f0100e3d:	a1 00 4a 11 f0       	mov    0xf0114a00,%eax
f0100e42:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100e45:	c1 e0 02             	shl    $0x2,%eax
f0100e48:	ba 00 10 00 00       	mov    $0x1000,%edx
f0100e4d:	e8 de fb ff ff       	call   f0100a30 <boot_alloc>
f0100e52:	a3 0c 4a 11 f0       	mov    %eax,0xf0114a0c
	//////////////////////////////////////////////////////////////////////
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_segment or page_insert
	page_init();
f0100e57:	e8 63 fd ff ff       	call   f0100bbf <page_init>
	struct Page_list fl;
	
        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f0100e5c:	a1 d8 45 11 f0       	mov    0xf01145d8,%eax
f0100e61:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e64:	85 c0                	test   %eax,%eax
f0100e66:	0f 84 89 00 00 00    	je     f0100ef5 <i386_vm_init+0x137>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100e6c:	2b 05 0c 4a 11 f0    	sub    0xf0114a0c,%eax
f0100e72:	c1 f8 02             	sar    $0x2,%eax
f0100e75:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100e7b:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0100e7e:	89 c2                	mov    %eax,%edx
f0100e80:	c1 ea 0c             	shr    $0xc,%edx
f0100e83:	39 15 00 4a 11 f0    	cmp    %edx,0xf0114a00
f0100e89:	77 41                	ja     f0100ecc <i386_vm_init+0x10e>
f0100e8b:	eb 1f                	jmp    f0100eac <i386_vm_init+0xee>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100e8d:	2b 05 0c 4a 11 f0    	sub    0xf0114a0c,%eax
f0100e93:	c1 f8 02             	sar    $0x2,%eax
f0100e96:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100e9c:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0100e9f:	89 c2                	mov    %eax,%edx
f0100ea1:	c1 ea 0c             	shr    $0xc,%edx
f0100ea4:	3b 15 00 4a 11 f0    	cmp    0xf0114a00,%edx
f0100eaa:	72 20                	jb     f0100ecc <i386_vm_init+0x10e>
f0100eac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100eb0:	c7 44 24 08 24 36 10 	movl   $0xf0103624,0x8(%esp)
f0100eb7:	f0 
f0100eb8:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100ebf:	00 
f0100ec0:	c7 04 24 e8 39 10 f0 	movl   $0xf01039e8,(%esp)
f0100ec7:	e8 cd f1 ff ff       	call   f0100099 <_panic>
		memset(page2kva(pp0), 0x97, 128);
f0100ecc:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100ed3:	00 
f0100ed4:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100edb:	00 
f0100edc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ee1:	89 04 24             	mov    %eax,(%esp)
f0100ee4:	e8 9d 1b 00 00       	call   f0102a86 <memset>
	struct Page_list fl;
	
        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f0100ee9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100eec:	8b 00                	mov    (%eax),%eax
f0100eee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ef1:	85 c0                	test   %eax,%eax
f0100ef3:	75 98                	jne    f0100e8d <i386_vm_init+0xcf>
		memset(page2kva(pp0), 0x97, 128);

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0100ef5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100efc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100f03:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	assert(page_alloc(&pp0) == 0);
f0100f0a:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0100f0d:	89 04 24             	mov    %eax,(%esp)
f0100f10:	e8 c9 fd ff ff       	call   f0100cde <page_alloc>
f0100f15:	85 c0                	test   %eax,%eax
f0100f17:	74 24                	je     f0100f3d <i386_vm_init+0x17f>
f0100f19:	c7 44 24 0c f6 39 10 	movl   $0xf01039f6,0xc(%esp)
f0100f20:	f0 
f0100f21:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0100f28:	f0 
f0100f29:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f0100f30:	00 
f0100f31:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0100f38:	e8 5c f1 ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp1) == 0);
f0100f3d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0100f40:	89 04 24             	mov    %eax,(%esp)
f0100f43:	e8 96 fd ff ff       	call   f0100cde <page_alloc>
f0100f48:	85 c0                	test   %eax,%eax
f0100f4a:	74 24                	je     f0100f70 <i386_vm_init+0x1b2>
f0100f4c:	c7 44 24 0c 21 3a 10 	movl   $0xf0103a21,0xc(%esp)
f0100f53:	f0 
f0100f54:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0100f5b:	f0 
f0100f5c:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
f0100f63:	00 
f0100f64:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0100f6b:	e8 29 f1 ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp2) == 0);
f0100f70:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100f73:	89 04 24             	mov    %eax,(%esp)
f0100f76:	e8 63 fd ff ff       	call   f0100cde <page_alloc>
f0100f7b:	85 c0                	test   %eax,%eax
f0100f7d:	74 24                	je     f0100fa3 <i386_vm_init+0x1e5>
f0100f7f:	c7 44 24 0c 37 3a 10 	movl   $0xf0103a37,0xc(%esp)
f0100f86:	f0 
f0100f87:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0100f8e:	f0 
f0100f8f:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f0100f96:	00 
f0100f97:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0100f9e:	e8 f6 f0 ff ff       	call   f0100099 <_panic>

	assert(pp0);
f0100fa3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100fa6:	85 c9                	test   %ecx,%ecx
f0100fa8:	75 24                	jne    f0100fce <i386_vm_init+0x210>
f0100faa:	c7 44 24 0c 5b 3a 10 	movl   $0xf0103a5b,0xc(%esp)
f0100fb1:	f0 
f0100fb2:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0100fb9:	f0 
f0100fba:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
f0100fc1:	00 
f0100fc2:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0100fc9:	e8 cb f0 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f0100fce:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fd1:	85 d2                	test   %edx,%edx
f0100fd3:	74 04                	je     f0100fd9 <i386_vm_init+0x21b>
f0100fd5:	39 d1                	cmp    %edx,%ecx
f0100fd7:	75 24                	jne    f0100ffd <i386_vm_init+0x23f>
f0100fd9:	c7 44 24 0c 4d 3a 10 	movl   $0xf0103a4d,0xc(%esp)
f0100fe0:	f0 
f0100fe1:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0100fe8:	f0 
f0100fe9:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
f0100ff0:	00 
f0100ff1:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0100ff8:	e8 9c f0 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0100ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101000:	85 c0                	test   %eax,%eax
f0101002:	74 08                	je     f010100c <i386_vm_init+0x24e>
f0101004:	39 c2                	cmp    %eax,%edx
f0101006:	74 04                	je     f010100c <i386_vm_init+0x24e>
f0101008:	39 c1                	cmp    %eax,%ecx
f010100a:	75 24                	jne    f0101030 <i386_vm_init+0x272>
f010100c:	c7 44 24 0c b8 36 10 	movl   $0xf01036b8,0xc(%esp)
f0101013:	f0 
f0101014:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010101b:	f0 
f010101c:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
f0101023:	00 
f0101024:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010102b:	e8 69 f0 ff ff       	call   f0100099 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101030:	8b 35 0c 4a 11 f0    	mov    0xf0114a0c,%esi
        assert(page2pa(pp0) < npage*PGSIZE);
f0101036:	8b 1d 00 4a 11 f0    	mov    0xf0114a00,%ebx
f010103c:	c1 e3 0c             	shl    $0xc,%ebx
f010103f:	29 f1                	sub    %esi,%ecx
f0101041:	c1 f9 02             	sar    $0x2,%ecx
f0101044:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010104a:	c1 e1 0c             	shl    $0xc,%ecx
f010104d:	39 d9                	cmp    %ebx,%ecx
f010104f:	72 24                	jb     f0101075 <i386_vm_init+0x2b7>
f0101051:	c7 44 24 0c 5f 3a 10 	movl   $0xf0103a5f,0xc(%esp)
f0101058:	f0 
f0101059:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101060:	f0 
f0101061:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f0101068:	00 
f0101069:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101070:	e8 24 f0 ff ff       	call   f0100099 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101075:	29 f2                	sub    %esi,%edx
f0101077:	c1 fa 02             	sar    $0x2,%edx
f010107a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101080:	c1 e2 0c             	shl    $0xc,%edx
        assert(page2pa(pp1) < npage*PGSIZE);
f0101083:	39 d3                	cmp    %edx,%ebx
f0101085:	77 24                	ja     f01010ab <i386_vm_init+0x2ed>
f0101087:	c7 44 24 0c 7b 3a 10 	movl   $0xf0103a7b,0xc(%esp)
f010108e:	f0 
f010108f:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101096:	f0 
f0101097:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f010109e:	00 
f010109f:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01010a6:	e8 ee ef ff ff       	call   f0100099 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01010ab:	29 f0                	sub    %esi,%eax
f01010ad:	c1 f8 02             	sar    $0x2,%eax
f01010b0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01010b6:	c1 e0 0c             	shl    $0xc,%eax
        assert(page2pa(pp2) < npage*PGSIZE);
f01010b9:	39 c3                	cmp    %eax,%ebx
f01010bb:	77 24                	ja     f01010e1 <i386_vm_init+0x323>
f01010bd:	c7 44 24 0c 97 3a 10 	movl   $0xf0103a97,0xc(%esp)
f01010c4:	f0 
f01010c5:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01010cc:	f0 
f01010cd:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f01010d4:	00 
f01010d5:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01010dc:	e8 b8 ef ff ff       	call   f0100099 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01010e1:	8b 1d d8 45 11 f0    	mov    0xf01145d8,%ebx
	LIST_INIT(&page_free_list);
f01010e7:	c7 05 d8 45 11 f0 00 	movl   $0x0,0xf01145d8
f01010ee:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01010f1:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01010f4:	89 04 24             	mov    %eax,(%esp)
f01010f7:	e8 e2 fb ff ff       	call   f0100cde <page_alloc>
f01010fc:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01010ff:	74 24                	je     f0101125 <i386_vm_init+0x367>
f0101101:	c7 44 24 0c b3 3a 10 	movl   $0xf0103ab3,0xc(%esp)
f0101108:	f0 
f0101109:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101110:	f0 
f0101111:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f0101118:	00 
f0101119:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101120:	e8 74 ef ff ff       	call   f0100099 <_panic>

        // free and re-allocate?
        page_free(pp0);
f0101125:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101128:	89 04 24             	mov    %eax,(%esp)
f010112b:	e8 e2 fb ff ff       	call   f0100d12 <page_free>
        page_free(pp1);
f0101130:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101133:	89 04 24             	mov    %eax,(%esp)
f0101136:	e8 d7 fb ff ff       	call   f0100d12 <page_free>
        page_free(pp2);
f010113b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010113e:	89 04 24             	mov    %eax,(%esp)
f0101141:	e8 cc fb ff ff       	call   f0100d12 <page_free>
	pp0 = pp1 = pp2 = 0;
f0101146:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010114d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0101154:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	assert(page_alloc(&pp0) == 0);
f010115b:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010115e:	89 04 24             	mov    %eax,(%esp)
f0101161:	e8 78 fb ff ff       	call   f0100cde <page_alloc>
f0101166:	85 c0                	test   %eax,%eax
f0101168:	74 24                	je     f010118e <i386_vm_init+0x3d0>
f010116a:	c7 44 24 0c f6 39 10 	movl   $0xf01039f6,0xc(%esp)
f0101171:	f0 
f0101172:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101179:	f0 
f010117a:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f0101181:	00 
f0101182:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101189:	e8 0b ef ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp1) == 0);
f010118e:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101191:	89 04 24             	mov    %eax,(%esp)
f0101194:	e8 45 fb ff ff       	call   f0100cde <page_alloc>
f0101199:	85 c0                	test   %eax,%eax
f010119b:	74 24                	je     f01011c1 <i386_vm_init+0x403>
f010119d:	c7 44 24 0c 21 3a 10 	movl   $0xf0103a21,0xc(%esp)
f01011a4:	f0 
f01011a5:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01011ac:	f0 
f01011ad:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f01011b4:	00 
f01011b5:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01011bc:	e8 d8 ee ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp2) == 0);
f01011c1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01011c4:	89 04 24             	mov    %eax,(%esp)
f01011c7:	e8 12 fb ff ff       	call   f0100cde <page_alloc>
f01011cc:	85 c0                	test   %eax,%eax
f01011ce:	74 24                	je     f01011f4 <i386_vm_init+0x436>
f01011d0:	c7 44 24 0c 37 3a 10 	movl   $0xf0103a37,0xc(%esp)
f01011d7:	f0 
f01011d8:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01011df:	f0 
f01011e0:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f01011e7:	00 
f01011e8:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01011ef:	e8 a5 ee ff ff       	call   f0100099 <_panic>
	assert(pp0);
f01011f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01011f7:	85 d2                	test   %edx,%edx
f01011f9:	75 24                	jne    f010121f <i386_vm_init+0x461>
f01011fb:	c7 44 24 0c 5b 3a 10 	movl   $0xf0103a5b,0xc(%esp)
f0101202:	f0 
f0101203:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010120a:	f0 
f010120b:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0101212:	00 
f0101213:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010121a:	e8 7a ee ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f010121f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101222:	85 c9                	test   %ecx,%ecx
f0101224:	74 04                	je     f010122a <i386_vm_init+0x46c>
f0101226:	39 ca                	cmp    %ecx,%edx
f0101228:	75 24                	jne    f010124e <i386_vm_init+0x490>
f010122a:	c7 44 24 0c 4d 3a 10 	movl   $0xf0103a4d,0xc(%esp)
f0101231:	f0 
f0101232:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101239:	f0 
f010123a:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f0101241:	00 
f0101242:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101249:	e8 4b ee ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010124e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101251:	85 c0                	test   %eax,%eax
f0101253:	74 08                	je     f010125d <i386_vm_init+0x49f>
f0101255:	39 c1                	cmp    %eax,%ecx
f0101257:	74 04                	je     f010125d <i386_vm_init+0x49f>
f0101259:	39 c2                	cmp    %eax,%edx
f010125b:	75 24                	jne    f0101281 <i386_vm_init+0x4c3>
f010125d:	c7 44 24 0c b8 36 10 	movl   $0xf01036b8,0xc(%esp)
f0101264:	f0 
f0101265:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010126c:	f0 
f010126d:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f0101274:	00 
f0101275:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010127c:	e8 18 ee ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101281:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0101284:	89 04 24             	mov    %eax,(%esp)
f0101287:	e8 52 fa ff ff       	call   f0100cde <page_alloc>
f010128c:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010128f:	74 24                	je     f01012b5 <i386_vm_init+0x4f7>
f0101291:	c7 44 24 0c b3 3a 10 	movl   $0xf0103ab3,0xc(%esp)
f0101298:	f0 
f0101299:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01012a0:	f0 
f01012a1:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f01012a8:	00 
f01012a9:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01012b0:	e8 e4 ed ff ff       	call   f0100099 <_panic>

	// give free list back
	page_free_list = fl;
f01012b5:	89 1d d8 45 11 f0    	mov    %ebx,0xf01145d8

	// free the pages we took
	page_free(pp0);
f01012bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01012be:	89 04 24             	mov    %eax,(%esp)
f01012c1:	e8 4c fa ff ff       	call   f0100d12 <page_free>
	page_free(pp1);
f01012c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01012c9:	89 04 24             	mov    %eax,(%esp)
f01012cc:	e8 41 fa ff ff       	call   f0100d12 <page_free>
	page_free(pp2);
f01012d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012d4:	89 04 24             	mov    %eax,(%esp)
f01012d7:	e8 36 fa ff ff       	call   f0100d12 <page_free>

	cprintf("check_page_alloc() succeeded!\n");
f01012dc:	c7 04 24 d8 36 10 f0 	movl   $0xf01036d8,(%esp)
f01012e3:	e8 16 0c 00 00       	call   f0101efe <cprintf>
	pte_t *ptep, *ptep1;
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f01012e8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01012ef:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01012f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	assert(page_alloc(&pp0) == 0);
f01012fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101300:	89 04 24             	mov    %eax,(%esp)
f0101303:	e8 d6 f9 ff ff       	call   f0100cde <page_alloc>
f0101308:	85 c0                	test   %eax,%eax
f010130a:	74 24                	je     f0101330 <i386_vm_init+0x572>
f010130c:	c7 44 24 0c f6 39 10 	movl   $0xf01039f6,0xc(%esp)
f0101313:	f0 
f0101314:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010131b:	f0 
f010131c:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f0101323:	00 
f0101324:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010132b:	e8 69 ed ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101330:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101333:	89 04 24             	mov    %eax,(%esp)
f0101336:	e8 a3 f9 ff ff       	call   f0100cde <page_alloc>
f010133b:	85 c0                	test   %eax,%eax
f010133d:	74 24                	je     f0101363 <i386_vm_init+0x5a5>
f010133f:	c7 44 24 0c 21 3a 10 	movl   $0xf0103a21,0xc(%esp)
f0101346:	f0 
f0101347:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010134e:	f0 
f010134f:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f0101356:	00 
f0101357:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010135e:	e8 36 ed ff ff       	call   f0100099 <_panic>
	assert(page_alloc(&pp2) == 0);
f0101363:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0101366:	89 04 24             	mov    %eax,(%esp)
f0101369:	e8 70 f9 ff ff       	call   f0100cde <page_alloc>
f010136e:	85 c0                	test   %eax,%eax
f0101370:	74 24                	je     f0101396 <i386_vm_init+0x5d8>
f0101372:	c7 44 24 0c 37 3a 10 	movl   $0xf0103a37,0xc(%esp)
f0101379:	f0 
f010137a:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101381:	f0 
f0101382:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f0101389:	00 
f010138a:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101391:	e8 03 ed ff ff       	call   f0100099 <_panic>

	assert(pp0);
f0101396:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101399:	85 d2                	test   %edx,%edx
f010139b:	75 24                	jne    f01013c1 <i386_vm_init+0x603>
f010139d:	c7 44 24 0c 5b 3a 10 	movl   $0xf0103a5b,0xc(%esp)
f01013a4:	f0 
f01013a5:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01013ac:	f0 
f01013ad:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f01013b4:	00 
f01013b5:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01013bc:	e8 d8 ec ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01013c1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01013c4:	85 c9                	test   %ecx,%ecx
f01013c6:	74 04                	je     f01013cc <i386_vm_init+0x60e>
f01013c8:	39 ca                	cmp    %ecx,%edx
f01013ca:	75 24                	jne    f01013f0 <i386_vm_init+0x632>
f01013cc:	c7 44 24 0c 4d 3a 10 	movl   $0xf0103a4d,0xc(%esp)
f01013d3:	f0 
f01013d4:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01013db:	f0 
f01013dc:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f01013e3:	00 
f01013e4:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01013eb:	e8 a9 ec ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013f3:	85 c0                	test   %eax,%eax
f01013f5:	74 08                	je     f01013ff <i386_vm_init+0x641>
f01013f7:	39 c1                	cmp    %eax,%ecx
f01013f9:	74 04                	je     f01013ff <i386_vm_init+0x641>
f01013fb:	39 c2                	cmp    %eax,%edx
f01013fd:	75 24                	jne    f0101423 <i386_vm_init+0x665>
f01013ff:	c7 44 24 0c b8 36 10 	movl   $0xf01036b8,0xc(%esp)
f0101406:	f0 
f0101407:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010140e:	f0 
f010140f:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f0101416:	00 
f0101417:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010141e:	e8 76 ec ff ff       	call   f0100099 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	LIST_INIT(&page_free_list);
f0101423:	c7 05 d8 45 11 f0 00 	movl   $0x0,0xf01145d8
f010142a:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010142d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101430:	89 04 24             	mov    %eax,(%esp)
f0101433:	e8 a6 f8 ff ff       	call   f0100cde <page_alloc>
f0101438:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010143b:	74 24                	je     f0101461 <i386_vm_init+0x6a3>
f010143d:	c7 44 24 0c b3 3a 10 	movl   $0xf0103ab3,0xc(%esp)
f0101444:	f0 
f0101445:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010144c:	f0 
f010144d:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f0101454:	00 
f0101455:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010145c:	e8 38 ec ff ff       	call   f0100099 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f0101461:	8b 1d 08 4a 11 f0    	mov    0xf0114a08,%ebx
f0101467:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010146a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010146e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101475:	00 
f0101476:	89 1c 24             	mov    %ebx,(%esp)
f0101479:	e8 36 f9 ff ff       	call   f0100db4 <page_lookup>
f010147e:	85 c0                	test   %eax,%eax
f0101480:	74 24                	je     f01014a6 <i386_vm_init+0x6e8>
f0101482:	c7 44 24 0c f8 36 10 	movl   $0xf01036f8,0xc(%esp)
f0101489:	f0 
f010148a:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101491:	f0 
f0101492:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
f0101499:	00 
f010149a:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01014a1:	e8 f3 eb ff ff       	call   f0100099 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f01014a6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01014ad:	00 
f01014ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01014b5:	00 
f01014b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01014b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014bd:	89 1c 24             	mov    %ebx,(%esp)
f01014c0:	e8 e5 f8 ff ff       	call   f0100daa <page_insert>
f01014c5:	85 c0                	test   %eax,%eax
f01014c7:	78 24                	js     f01014ed <i386_vm_init+0x72f>
f01014c9:	c7 44 24 0c 30 37 10 	movl   $0xf0103730,0xc(%esp)
f01014d0:	f0 
f01014d1:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01014d8:	f0 
f01014d9:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f01014e0:	00 
f01014e1:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01014e8:	e8 ac eb ff ff       	call   f0100099 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01014ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01014f0:	89 04 24             	mov    %eax,(%esp)
f01014f3:	e8 1a f8 ff ff       	call   f0100d12 <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f01014f8:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01014fb:	8b 1d 08 4a 11 f0    	mov    0xf0114a08,%ebx
f0101501:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101508:	00 
f0101509:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101510:	00 
f0101511:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101515:	89 1c 24             	mov    %ebx,(%esp)
f0101518:	e8 8d f8 ff ff       	call   f0100daa <page_insert>
f010151d:	85 c0                	test   %eax,%eax
f010151f:	74 24                	je     f0101545 <i386_vm_init+0x787>
f0101521:	c7 44 24 0c 5c 37 10 	movl   $0xf010375c,0xc(%esp)
f0101528:	f0 
f0101529:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101530:	f0 
f0101531:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f0101538:	00 
f0101539:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101540:	e8 54 eb ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f0101545:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101548:	89 45 c4             	mov    %eax,-0x3c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010154b:	8b 3d 0c 4a 11 f0    	mov    0xf0114a0c,%edi
f0101551:	8b 13                	mov    (%ebx),%edx
f0101553:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101559:	29 f8                	sub    %edi,%eax
f010155b:	c1 f8 02             	sar    $0x2,%eax
f010155e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101564:	c1 e0 0c             	shl    $0xc,%eax
f0101567:	39 c2                	cmp    %eax,%edx
f0101569:	74 24                	je     f010158f <i386_vm_init+0x7d1>
f010156b:	c7 44 24 0c 88 37 10 	movl   $0xf0103788,0xc(%esp)
f0101572:	f0 
f0101573:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010157a:	f0 
f010157b:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0101582:	00 
f0101583:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010158a:	e8 0a eb ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f010158f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101594:	89 d8                	mov    %ebx,%eax
f0101596:	e8 ea f4 ff ff       	call   f0100a85 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010159b:	89 f2                	mov    %esi,%edx
f010159d:	29 fa                	sub    %edi,%edx
f010159f:	c1 fa 02             	sar    $0x2,%edx
f01015a2:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01015a8:	c1 e2 0c             	shl    $0xc,%edx
f01015ab:	39 d0                	cmp    %edx,%eax
f01015ad:	74 24                	je     f01015d3 <i386_vm_init+0x815>
f01015af:	c7 44 24 0c b0 37 10 	movl   $0xf01037b0,0xc(%esp)
f01015b6:	f0 
f01015b7:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01015be:	f0 
f01015bf:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f01015c6:	00 
f01015c7:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01015ce:	e8 c6 ea ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f01015d3:	66 83 7e 08 01       	cmpw   $0x1,0x8(%esi)
f01015d8:	74 24                	je     f01015fe <i386_vm_init+0x840>
f01015da:	c7 44 24 0c d0 3a 10 	movl   $0xf0103ad0,0xc(%esp)
f01015e1:	f0 
f01015e2:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01015e9:	f0 
f01015ea:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f01015f1:	00 
f01015f2:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01015f9:	e8 9b ea ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f01015fe:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101601:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0101606:	74 24                	je     f010162c <i386_vm_init+0x86e>
f0101608:	c7 44 24 0c e1 3a 10 	movl   $0xf0103ae1,0xc(%esp)
f010160f:	f0 
f0101610:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101617:	f0 
f0101618:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
f010161f:	00 
f0101620:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101627:	e8 6d ea ff ff       	call   f0100099 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f010162c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010162f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101636:	00 
f0101637:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010163e:	00 
f010163f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101643:	89 1c 24             	mov    %ebx,(%esp)
f0101646:	e8 5f f7 ff ff       	call   f0100daa <page_insert>
f010164b:	85 c0                	test   %eax,%eax
f010164d:	74 24                	je     f0101673 <i386_vm_init+0x8b5>
f010164f:	c7 44 24 0c e0 37 10 	movl   $0xf01037e0,0xc(%esp)
f0101656:	f0 
f0101657:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010165e:	f0 
f010165f:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f0101666:	00 
f0101667:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010166e:	e8 26 ea ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101673:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101678:	89 d8                	mov    %ebx,%eax
f010167a:	e8 06 f4 ff ff       	call   f0100a85 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010167f:	89 f2                	mov    %esi,%edx
f0101681:	29 fa                	sub    %edi,%edx
f0101683:	c1 fa 02             	sar    $0x2,%edx
f0101686:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010168c:	c1 e2 0c             	shl    $0xc,%edx
f010168f:	39 d0                	cmp    %edx,%eax
f0101691:	74 24                	je     f01016b7 <i386_vm_init+0x8f9>
f0101693:	c7 44 24 0c 18 38 10 	movl   $0xf0103818,0xc(%esp)
f010169a:	f0 
f010169b:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01016a2:	f0 
f01016a3:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f01016aa:	00 
f01016ab:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01016b2:	e8 e2 e9 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f01016b7:	66 83 7e 08 01       	cmpw   $0x1,0x8(%esi)
f01016bc:	74 24                	je     f01016e2 <i386_vm_init+0x924>
f01016be:	c7 44 24 0c f2 3a 10 	movl   $0xf0103af2,0xc(%esp)
f01016c5:	f0 
f01016c6:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01016cd:	f0 
f01016ce:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f01016d5:	00 
f01016d6:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01016dd:	e8 b7 e9 ff ff       	call   f0100099 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01016e2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01016e5:	89 04 24             	mov    %eax,(%esp)
f01016e8:	e8 f1 f5 ff ff       	call   f0100cde <page_alloc>
f01016ed:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01016f0:	74 24                	je     f0101716 <i386_vm_init+0x958>
f01016f2:	c7 44 24 0c b3 3a 10 	movl   $0xf0103ab3,0xc(%esp)
f01016f9:	f0 
f01016fa:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101701:	f0 
f0101702:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f0101709:	00 
f010170a:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101711:	e8 83 e9 ff ff       	call   f0100099 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101716:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101719:	8b 35 08 4a 11 f0    	mov    0xf0114a08,%esi
f010171f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101726:	00 
f0101727:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010172e:	00 
f010172f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101733:	89 34 24             	mov    %esi,(%esp)
f0101736:	e8 6f f6 ff ff       	call   f0100daa <page_insert>
f010173b:	85 c0                	test   %eax,%eax
f010173d:	74 24                	je     f0101763 <i386_vm_init+0x9a5>
f010173f:	c7 44 24 0c e0 37 10 	movl   $0xf01037e0,0xc(%esp)
f0101746:	f0 
f0101747:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010174e:	f0 
f010174f:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f0101756:	00 
f0101757:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010175e:	e8 36 e9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101763:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101768:	89 f0                	mov    %esi,%eax
f010176a:	e8 16 f3 ff ff       	call   f0100a85 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010176f:	89 da                	mov    %ebx,%edx
f0101771:	2b 15 0c 4a 11 f0    	sub    0xf0114a0c,%edx
f0101777:	c1 fa 02             	sar    $0x2,%edx
f010177a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101780:	c1 e2 0c             	shl    $0xc,%edx
f0101783:	39 d0                	cmp    %edx,%eax
f0101785:	74 24                	je     f01017ab <i386_vm_init+0x9ed>
f0101787:	c7 44 24 0c 18 38 10 	movl   $0xf0103818,0xc(%esp)
f010178e:	f0 
f010178f:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101796:	f0 
f0101797:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f010179e:	00 
f010179f:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01017a6:	e8 ee e8 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f01017ab:	66 83 7b 08 01       	cmpw   $0x1,0x8(%ebx)
f01017b0:	74 24                	je     f01017d6 <i386_vm_init+0xa18>
f01017b2:	c7 44 24 0c f2 3a 10 	movl   $0xf0103af2,0xc(%esp)
f01017b9:	f0 
f01017ba:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01017c1:	f0 
f01017c2:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
f01017c9:	00 
f01017ca:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01017d1:	e8 c3 e8 ff ff       	call   f0100099 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f01017d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01017d9:	89 04 24             	mov    %eax,(%esp)
f01017dc:	e8 fd f4 ff ff       	call   f0100cde <page_alloc>
f01017e1:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01017e4:	74 24                	je     f010180a <i386_vm_init+0xa4c>
f01017e6:	c7 44 24 0c b3 3a 10 	movl   $0xf0103ab3,0xc(%esp)
f01017ed:	f0 
f01017ee:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01017f5:	f0 
f01017f6:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
f01017fd:	00 
f01017fe:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101805:	e8 8f e8 ff ff       	call   f0100099 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f010180a:	8b 1d 08 4a 11 f0    	mov    0xf0114a08,%ebx
f0101810:	8b 33                	mov    (%ebx),%esi
f0101812:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0101818:	89 f0                	mov    %esi,%eax
f010181a:	c1 e8 0c             	shr    $0xc,%eax
f010181d:	3b 05 00 4a 11 f0    	cmp    0xf0114a00,%eax
f0101823:	72 20                	jb     f0101845 <i386_vm_init+0xa87>
f0101825:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101829:	c7 44 24 08 24 36 10 	movl   $0xf0103624,0x8(%esp)
f0101830:	f0 
f0101831:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0101838:	00 
f0101839:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101840:	e8 54 e8 ff ff       	call   f0100099 <_panic>
	assert(pgdir_walk(boot_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101845:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010184c:	00 
f010184d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101854:	00 
f0101855:	89 1c 24             	mov    %ebx,(%esp)
f0101858:	e8 43 f5 ff ff       	call   f0100da0 <pgdir_walk>
f010185d:	89 c7                	mov    %eax,%edi
f010185f:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101865:	39 f0                	cmp    %esi,%eax
f0101867:	74 24                	je     f010188d <i386_vm_init+0xacf>
f0101869:	c7 44 24 0c 48 38 10 	movl   $0xf0103848,0xc(%esp)
f0101870:	f0 
f0101871:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101878:	f0 
f0101879:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101880:	00 
f0101881:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101888:	e8 0c e8 ff ff       	call   f0100099 <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f010188d:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101890:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0101897:	00 
f0101898:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010189f:	00 
f01018a0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018a4:	89 1c 24             	mov    %ebx,(%esp)
f01018a7:	e8 fe f4 ff ff       	call   f0100daa <page_insert>
f01018ac:	85 c0                	test   %eax,%eax
f01018ae:	74 24                	je     f01018d4 <i386_vm_init+0xb16>
f01018b0:	c7 44 24 0c 88 38 10 	movl   $0xf0103888,0xc(%esp)
f01018b7:	f0 
f01018b8:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01018bf:	f0 
f01018c0:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f01018c7:	00 
f01018c8:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01018cf:	e8 c5 e7 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01018d4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018d9:	89 d8                	mov    %ebx,%eax
f01018db:	e8 a5 f1 ff ff       	call   f0100a85 <check_va2pa>
f01018e0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01018e3:	a1 0c 4a 11 f0       	mov    0xf0114a0c,%eax
f01018e8:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01018eb:	89 f0                	mov    %esi,%eax
f01018ed:	2b 45 c0             	sub    -0x40(%ebp),%eax
f01018f0:	c1 f8 02             	sar    $0x2,%eax
f01018f3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01018f9:	c1 e0 0c             	shl    $0xc,%eax
f01018fc:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f01018ff:	74 24                	je     f0101925 <i386_vm_init+0xb67>
f0101901:	c7 44 24 0c 18 38 10 	movl   $0xf0103818,0xc(%esp)
f0101908:	f0 
f0101909:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101910:	f0 
f0101911:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0101918:	00 
f0101919:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101920:	e8 74 e7 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0101925:	66 83 7e 08 01       	cmpw   $0x1,0x8(%esi)
f010192a:	74 24                	je     f0101950 <i386_vm_init+0xb92>
f010192c:	c7 44 24 0c f2 3a 10 	movl   $0xf0103af2,0xc(%esp)
f0101933:	f0 
f0101934:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f010193b:	f0 
f010193c:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0101943:	00 
f0101944:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f010194b:	e8 49 e7 ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101950:	f6 07 04             	testb  $0x4,(%edi)
f0101953:	75 24                	jne    f0101979 <i386_vm_init+0xbbb>
f0101955:	c7 44 24 0c c4 38 10 	movl   $0xf01038c4,0xc(%esp)
f010195c:	f0 
f010195d:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101964:	f0 
f0101965:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f010196c:	00 
f010196d:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101974:	e8 20 e7 ff ff       	call   f0100099 <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101979:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101980:	00 
f0101981:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101988:	00 
f0101989:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010198c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101990:	89 1c 24             	mov    %ebx,(%esp)
f0101993:	e8 12 f4 ff ff       	call   f0100daa <page_insert>
f0101998:	85 c0                	test   %eax,%eax
f010199a:	78 24                	js     f01019c0 <i386_vm_init+0xc02>
f010199c:	c7 44 24 0c f8 38 10 	movl   $0xf01038f8,0xc(%esp)
f01019a3:	f0 
f01019a4:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01019ab:	f0 
f01019ac:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f01019b3:	00 
f01019b4:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f01019bb:	e8 d9 e6 ff ff       	call   f0100099 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01019c0:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01019c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01019ca:	00 
f01019cb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019d2:	00 
f01019d3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01019d7:	89 1c 24             	mov    %ebx,(%esp)
f01019da:	e8 cb f3 ff ff       	call   f0100daa <page_insert>
f01019df:	85 c0                	test   %eax,%eax
f01019e1:	74 24                	je     f0101a07 <i386_vm_init+0xc49>
f01019e3:	c7 44 24 0c 2c 39 10 	movl   $0xf010392c,0xc(%esp)
f01019ea:	f0 
f01019eb:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f01019f2:	f0 
f01019f3:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f01019fa:	00 
f01019fb:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101a02:	e8 92 e6 ff ff       	call   f0100099 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0101a07:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a0c:	89 d8                	mov    %ebx,%eax
f0101a0e:	e8 72 f0 ff ff       	call   f0100a85 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101a13:	89 f2                	mov    %esi,%edx
f0101a15:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0101a18:	c1 fa 02             	sar    $0x2,%edx
f0101a1b:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101a21:	c1 e2 0c             	shl    $0xc,%edx
f0101a24:	39 d0                	cmp    %edx,%eax
f0101a26:	74 24                	je     f0101a4c <i386_vm_init+0xc8e>
f0101a28:	c7 44 24 0c 64 39 10 	movl   $0xf0103964,0xc(%esp)
f0101a2f:	f0 
f0101a30:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101a37:	f0 
f0101a38:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0101a3f:	00 
f0101a40:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101a47:	e8 4d e6 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101a4c:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101a4f:	74 24                	je     f0101a75 <i386_vm_init+0xcb7>
f0101a51:	c7 44 24 0c 90 39 10 	movl   $0xf0103990,0xc(%esp)
f0101a58:	f0 
f0101a59:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101a60:	f0 
f0101a61:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0101a68:	00 
f0101a69:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101a70:	e8 24 e6 ff ff       	call   f0100099 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101a75:	66 83 7e 08 02       	cmpw   $0x2,0x8(%esi)
f0101a7a:	74 24                	je     f0101aa0 <i386_vm_init+0xce2>
f0101a7c:	c7 44 24 0c 03 3b 10 	movl   $0xf0103b03,0xc(%esp)
f0101a83:	f0 
f0101a84:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101a8b:	f0 
f0101a8c:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0101a93:	00 
f0101a94:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101a9b:	e8 f9 e5 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0101aa0:	c7 44 24 0c 14 3b 10 	movl   $0xf0103b14,0xc(%esp)
f0101aa7:	f0 
f0101aa8:	c7 44 24 08 0c 3a 10 	movl   $0xf0103a0c,0x8(%esp)
f0101aaf:	f0 
f0101ab0:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0101ab7:	00 
f0101ab8:	c7 04 24 c0 39 10 f0 	movl   $0xf01039c0,(%esp)
f0101abf:	e8 d5 e5 ff ff       	call   f0100099 <_panic>

f0101ac4 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101ac4:	55                   	push   %ebp
f0101ac5:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0101ac7:	5d                   	pop    %ebp
f0101ac8:	c3                   	ret    

f0101ac9 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101ac9:	55                   	push   %ebp
f0101aca:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101acc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101acf:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101ad2:	5d                   	pop    %ebp
f0101ad3:	c3                   	ret    

f0101ad4 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0101ad4:	55                   	push   %ebp
f0101ad5:	89 e5                	mov    %esp,%ebp
f0101ad7:	53                   	push   %ebx
f0101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
f0101adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0101ade:	85 c0                	test   %eax,%eax
f0101ae0:	75 0e                	jne    f0101af0 <envid2env+0x1c>
		*env_store = curenv;
f0101ae2:	a1 dc 45 11 f0       	mov    0xf01145dc,%eax
f0101ae7:	89 01                	mov    %eax,(%ecx)
		return 0;
f0101ae9:	b8 00 00 00 00       	mov    $0x0,%eax
f0101aee:	eb 54                	jmp    f0101b44 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0101af0:	89 c2                	mov    %eax,%edx
f0101af2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101af8:	6b d2 64             	imul   $0x64,%edx,%edx
f0101afb:	03 15 e0 45 11 f0    	add    0xf01145e0,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0101b01:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0101b05:	74 05                	je     f0101b0c <envid2env+0x38>
f0101b07:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0101b0a:	74 0d                	je     f0101b19 <envid2env+0x45>
		*env_store = 0;
f0101b0c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0101b12:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0101b17:	eb 2b                	jmp    f0101b44 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0101b19:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101b1d:	74 1e                	je     f0101b3d <envid2env+0x69>
f0101b1f:	a1 dc 45 11 f0       	mov    0xf01145dc,%eax
f0101b24:	39 c2                	cmp    %eax,%edx
f0101b26:	74 15                	je     f0101b3d <envid2env+0x69>
f0101b28:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0101b2b:	39 5a 50             	cmp    %ebx,0x50(%edx)
f0101b2e:	74 0d                	je     f0101b3d <envid2env+0x69>
		*env_store = 0;
f0101b30:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0101b36:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0101b3b:	eb 07                	jmp    f0101b44 <envid2env+0x70>
	}

	*env_store = e;
f0101b3d:	89 11                	mov    %edx,(%ecx)
	return 0;
f0101b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b44:	5b                   	pop    %ebx
f0101b45:	5d                   	pop    %ebp
f0101b46:	c3                   	ret    

f0101b47 <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f0101b47:	55                   	push   %ebp
f0101b48:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0101b4a:	5d                   	pop    %ebp
f0101b4b:	c3                   	ret    

f0101b4c <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0101b4c:	55                   	push   %ebp
f0101b4d:	89 e5                	mov    %esp,%ebp
f0101b4f:	53                   	push   %ebx
f0101b50:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f0101b53:	8b 1d e4 45 11 f0    	mov    0xf01145e4,%ebx
f0101b59:	85 db                	test   %ebx,%ebx
f0101b5b:	0f 84 f8 00 00 00    	je     f0101c59 <env_alloc+0x10d>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0101b61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f0101b68:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101b6b:	89 04 24             	mov    %eax,(%esp)
f0101b6e:	e8 6b f1 ff ff       	call   f0100cde <page_alloc>
f0101b73:	85 c0                	test   %eax,%eax
f0101b75:	0f 88 e3 00 00 00    	js     f0101c5e <env_alloc+0x112>

	// LAB 3: Your code here.

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0101b7b:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0101b7e:	8b 53 60             	mov    0x60(%ebx),%edx
f0101b81:	83 ca 03             	or     $0x3,%edx
f0101b84:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0101b8a:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0101b8d:	8b 53 60             	mov    0x60(%ebx),%edx
f0101b90:	83 ca 05             	or     $0x5,%edx
f0101b93:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0101b99:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0101b9c:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0101ba1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0101ba6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bab:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0101bae:	89 da                	mov    %ebx,%edx
f0101bb0:	2b 15 e0 45 11 f0    	sub    0xf01145e0,%edx
f0101bb6:	c1 fa 02             	sar    $0x2,%edx
f0101bb9:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0101bbf:	09 d0                	or     %edx,%eax
f0101bc1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0101bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101bc7:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0101bca:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0101bd1:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0101bd8:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0101bdf:	00 
f0101be0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101be7:	00 
f0101be8:	89 1c 24             	mov    %ebx,(%esp)
f0101beb:	e8 96 0e 00 00       	call   f0102a86 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0101bf0:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0101bf6:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0101bfc:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0101c02:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0101c09:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0101c0f:	8b 43 44             	mov    0x44(%ebx),%eax
f0101c12:	85 c0                	test   %eax,%eax
f0101c14:	74 06                	je     f0101c1c <env_alloc+0xd0>
f0101c16:	8b 53 48             	mov    0x48(%ebx),%edx
f0101c19:	89 50 48             	mov    %edx,0x48(%eax)
f0101c1c:	8b 43 48             	mov    0x48(%ebx),%eax
f0101c1f:	8b 53 44             	mov    0x44(%ebx),%edx
f0101c22:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f0101c24:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c27:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0101c29:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0101c2c:	8b 15 dc 45 11 f0    	mov    0xf01145dc,%edx
f0101c32:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c37:	85 d2                	test   %edx,%edx
f0101c39:	74 03                	je     f0101c3e <env_alloc+0xf2>
f0101c3b:	8b 42 4c             	mov    0x4c(%edx),%eax
f0101c3e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101c42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c46:	c7 04 24 25 3b 10 f0 	movl   $0xf0103b25,(%esp)
f0101c4d:	e8 ac 02 00 00       	call   f0101efe <cprintf>
	return 0;
f0101c52:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c57:	eb 05                	jmp    f0101c5e <env_alloc+0x112>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
f0101c59:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0101c5e:	83 c4 24             	add    $0x24,%esp
f0101c61:	5b                   	pop    %ebx
f0101c62:	5d                   	pop    %ebp
f0101c63:	c3                   	ret    

f0101c64 <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f0101c64:	55                   	push   %ebp
f0101c65:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0101c67:	5d                   	pop    %ebp
f0101c68:	c3                   	ret    

f0101c69 <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0101c69:	55                   	push   %ebp
f0101c6a:	89 e5                	mov    %esp,%ebp
f0101c6c:	57                   	push   %edi
f0101c6d:	56                   	push   %esi
f0101c6e:	53                   	push   %ebx
f0101c6f:	83 ec 2c             	sub    $0x2c,%esp
f0101c72:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0101c75:	a1 dc 45 11 f0       	mov    0xf01145dc,%eax
f0101c7a:	39 c7                	cmp    %eax,%edi
f0101c7c:	75 09                	jne    f0101c87 <env_free+0x1e>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101c7e:	8b 15 04 4a 11 f0    	mov    0xf0114a04,%edx
f0101c84:	0f 22 da             	mov    %edx,%cr3
		lcr3(boot_cr3);

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0101c87:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0101c8a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c8f:	85 c0                	test   %eax,%eax
f0101c91:	74 03                	je     f0101c96 <env_free+0x2d>
f0101c93:	8b 50 4c             	mov    0x4c(%eax),%edx
f0101c96:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101c9a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101c9e:	c7 04 24 3a 3b 10 f0 	movl   $0xf0103b3a,(%esp)
f0101ca5:	e8 54 02 00 00       	call   f0101efe <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0101caa:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0101cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101cb4:	c1 e0 02             	shl    $0x2,%eax
f0101cb7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101cba:	8b 47 5c             	mov    0x5c(%edi),%eax
f0101cbd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101cc0:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0101cc3:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0101cc9:	0f 84 bb 00 00 00    	je     f0101d8a <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0101ccf:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0101cd5:	89 f0                	mov    %esi,%eax
f0101cd7:	c1 e8 0c             	shr    $0xc,%eax
f0101cda:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101cdd:	3b 05 00 4a 11 f0    	cmp    0xf0114a00,%eax
f0101ce3:	72 20                	jb     f0101d05 <env_free+0x9c>
f0101ce5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101ce9:	c7 44 24 08 24 36 10 	movl   $0xf0103624,0x8(%esp)
f0101cf0:	f0 
f0101cf1:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0101cf8:	00 
f0101cf9:	c7 04 24 50 3b 10 f0 	movl   $0xf0103b50,(%esp)
f0101d00:	e8 94 e3 ff ff       	call   f0100099 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0101d05:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101d08:	c1 e2 16             	shl    $0x16,%edx
f0101d0b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0101d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0101d13:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0101d1a:	01 
f0101d1b:	74 17                	je     f0101d34 <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0101d1d:	89 d8                	mov    %ebx,%eax
f0101d1f:	c1 e0 0c             	shl    $0xc,%eax
f0101d22:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0101d25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d29:	8b 47 5c             	mov    0x5c(%edi),%eax
f0101d2c:	89 04 24             	mov    %eax,(%esp)
f0101d2f:	e8 90 fd ff ff       	call   f0101ac4 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0101d34:	83 c3 01             	add    $0x1,%ebx
f0101d37:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0101d3d:	75 d4                	jne    f0101d13 <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0101d3f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0101d42:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101d45:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101d4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101d4f:	3b 05 00 4a 11 f0    	cmp    0xf0114a00,%eax
f0101d55:	72 1c                	jb     f0101d73 <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0101d57:	c7 44 24 08 84 3b 10 	movl   $0xf0103b84,0x8(%esp)
f0101d5e:	f0 
f0101d5f:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101d66:	00 
f0101d67:	c7 04 24 e8 39 10 f0 	movl   $0xf01039e8,(%esp)
f0101d6e:	e8 26 e3 ff ff       	call   f0100099 <_panic>
	return &pages[PPN(pa)];
f0101d73:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101d76:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101d79:	c1 e0 02             	shl    $0x2,%eax
f0101d7c:	03 05 0c 4a 11 f0    	add    0xf0114a0c,%eax
		page_decref(pa2page(pa));
f0101d82:	89 04 24             	mov    %eax,(%esp)
f0101d85:	e8 f3 ef ff ff       	call   f0100d7d <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0101d8a:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0101d8e:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0101d95:	0f 85 16 ff ff ff    	jne    f0101cb1 <env_free+0x48>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0101d9b:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0101d9e:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0101da5:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101dac:	c1 e8 0c             	shr    $0xc,%eax
f0101daf:	3b 05 00 4a 11 f0    	cmp    0xf0114a00,%eax
f0101db5:	72 1c                	jb     f0101dd3 <env_free+0x16a>
		panic("pa2page called with invalid pa");
f0101db7:	c7 44 24 08 84 3b 10 	movl   $0xf0103b84,0x8(%esp)
f0101dbe:	f0 
f0101dbf:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101dc6:	00 
f0101dc7:	c7 04 24 e8 39 10 f0 	movl   $0xf01039e8,(%esp)
f0101dce:	e8 c6 e2 ff ff       	call   f0100099 <_panic>
	return &pages[PPN(pa)];
f0101dd3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101dd6:	c1 e0 02             	shl    $0x2,%eax
f0101dd9:	03 05 0c 4a 11 f0    	add    0xf0114a0c,%eax
	page_decref(pa2page(pa));
f0101ddf:	89 04 24             	mov    %eax,(%esp)
f0101de2:	e8 96 ef ff ff       	call   f0100d7d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0101de7:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0101dee:	a1 e4 45 11 f0       	mov    0xf01145e4,%eax
f0101df3:	89 47 44             	mov    %eax,0x44(%edi)
f0101df6:	85 c0                	test   %eax,%eax
f0101df8:	74 06                	je     f0101e00 <env_free+0x197>
f0101dfa:	8d 57 44             	lea    0x44(%edi),%edx
f0101dfd:	89 50 48             	mov    %edx,0x48(%eax)
f0101e00:	89 3d e4 45 11 f0    	mov    %edi,0xf01145e4
f0101e06:	c7 47 48 e4 45 11 f0 	movl   $0xf01145e4,0x48(%edi)
}
f0101e0d:	83 c4 2c             	add    $0x2c,%esp
f0101e10:	5b                   	pop    %ebx
f0101e11:	5e                   	pop    %esi
f0101e12:	5f                   	pop    %edi
f0101e13:	5d                   	pop    %ebp
f0101e14:	c3                   	ret    

f0101e15 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0101e15:	55                   	push   %ebp
f0101e16:	89 e5                	mov    %esp,%ebp
f0101e18:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0101e1b:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e1e:	89 04 24             	mov    %eax,(%esp)
f0101e21:	e8 43 fe ff ff       	call   f0101c69 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0101e26:	c7 04 24 a4 3b 10 f0 	movl   $0xf0103ba4,(%esp)
f0101e2d:	e8 cc 00 00 00       	call   f0101efe <cprintf>
	while (1)
		monitor(NULL);
f0101e32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e39:	e8 a2 e9 ff ff       	call   f01007e0 <monitor>
f0101e3e:	eb f2                	jmp    f0101e32 <env_destroy+0x1d>

f0101e40 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0101e40:	55                   	push   %ebp
f0101e41:	89 e5                	mov    %esp,%ebp
f0101e43:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0101e46:	8b 65 08             	mov    0x8(%ebp),%esp
f0101e49:	61                   	popa   
f0101e4a:	07                   	pop    %es
f0101e4b:	1f                   	pop    %ds
f0101e4c:	83 c4 08             	add    $0x8,%esp
f0101e4f:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0101e50:	c7 44 24 08 5b 3b 10 	movl   $0xf0103b5b,0x8(%esp)
f0101e57:	f0 
f0101e58:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0101e5f:	00 
f0101e60:	c7 04 24 50 3b 10 f0 	movl   $0xf0103b50,(%esp)
f0101e67:	e8 2d e2 ff ff       	call   f0100099 <_panic>

f0101e6c <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0101e6c:	55                   	push   %ebp
f0101e6d:	89 e5                	mov    %esp,%ebp
f0101e6f:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.

        panic("env_run not yet implemented");
f0101e72:	c7 44 24 08 67 3b 10 	movl   $0xf0103b67,0x8(%esp)
f0101e79:	f0 
f0101e7a:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f0101e81:	00 
f0101e82:	c7 04 24 50 3b 10 f0 	movl   $0xf0103b50,(%esp)
f0101e89:	e8 0b e2 ff ff       	call   f0100099 <_panic>
	...

f0101e90 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0101e90:	55                   	push   %ebp
f0101e91:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101e93:	ba 70 00 00 00       	mov    $0x70,%edx
f0101e98:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e9b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101e9c:	b2 71                	mov    $0x71,%dl
f0101e9e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101e9f:	0f b6 c0             	movzbl %al,%eax
}
f0101ea2:	5d                   	pop    %ebp
f0101ea3:	c3                   	ret    

f0101ea4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0101ea4:	55                   	push   %ebp
f0101ea5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101ea7:	ba 70 00 00 00       	mov    $0x70,%edx
f0101eac:	8b 45 08             	mov    0x8(%ebp),%eax
f0101eaf:	ee                   	out    %al,(%dx)
f0101eb0:	b2 71                	mov    $0x71,%dl
f0101eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101eb5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101eb6:	5d                   	pop    %ebp
f0101eb7:	c3                   	ret    

f0101eb8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101eb8:	55                   	push   %ebp
f0101eb9:	89 e5                	mov    %esp,%ebp
f0101ebb:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0101ebe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ec1:	89 04 24             	mov    %eax,(%esp)
f0101ec4:	e8 ef e7 ff ff       	call   f01006b8 <cputchar>
	*cnt++;
}
f0101ec9:	c9                   	leave  
f0101eca:	c3                   	ret    

f0101ecb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101ecb:	55                   	push   %ebp
f0101ecc:	89 e5                	mov    %esp,%ebp
f0101ece:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0101ed1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101edb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101edf:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ee2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ee6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101eed:	c7 04 24 b8 1e 10 f0 	movl   $0xf0101eb8,(%esp)
f0101ef4:	e8 db 04 00 00       	call   f01023d4 <vprintfmt>
	return cnt;
}
f0101ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101efc:	c9                   	leave  
f0101efd:	c3                   	ret    

f0101efe <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0101efe:	55                   	push   %ebp
f0101eff:	89 e5                	mov    %esp,%ebp
f0101f01:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0101f04:	8d 45 0c             	lea    0xc(%ebp),%eax
f0101f07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101f0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f0e:	89 04 24             	mov    %eax,(%esp)
f0101f11:	e8 b5 ff ff ff       	call   f0101ecb <vcprintf>
	va_end(ap);

	return cnt;
}
f0101f16:	c9                   	leave  
f0101f17:	c3                   	ret    

f0101f18 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101f18:	55                   	push   %ebp
f0101f19:	89 e5                	mov    %esp,%ebp
f0101f1b:	57                   	push   %edi
f0101f1c:	56                   	push   %esi
f0101f1d:	53                   	push   %ebx
f0101f1e:	83 ec 10             	sub    $0x10,%esp
f0101f21:	89 c3                	mov    %eax,%ebx
f0101f23:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101f26:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101f29:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101f2c:	8b 0a                	mov    (%edx),%ecx
f0101f2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101f31:	8b 00                	mov    (%eax),%eax
f0101f33:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101f36:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	
	while (l <= r) {
f0101f3d:	eb 77                	jmp    f0101fb6 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0101f3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101f42:	01 c8                	add    %ecx,%eax
f0101f44:	bf 02 00 00 00       	mov    $0x2,%edi
f0101f49:	99                   	cltd   
f0101f4a:	f7 ff                	idiv   %edi
f0101f4c:	89 c2                	mov    %eax,%edx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101f4e:	eb 01                	jmp    f0101f51 <stab_binsearch+0x39>
			m--;
f0101f50:	4a                   	dec    %edx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101f51:	39 ca                	cmp    %ecx,%edx
f0101f53:	7c 1d                	jl     f0101f72 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0101f55:	6b fa 0c             	imul   $0xc,%edx,%edi
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101f58:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0101f5d:	39 f7                	cmp    %esi,%edi
f0101f5f:	75 ef                	jne    f0101f50 <stab_binsearch+0x38>
f0101f61:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0101f64:	6b fa 0c             	imul   $0xc,%edx,%edi
f0101f67:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0101f6b:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0101f6e:	73 18                	jae    f0101f88 <stab_binsearch+0x70>
f0101f70:	eb 05                	jmp    f0101f77 <stab_binsearch+0x5f>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0101f72:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0101f75:	eb 3f                	jmp    f0101fb6 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0101f77:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101f7a:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0101f7c:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101f7f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101f86:	eb 2e                	jmp    f0101fb6 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0101f88:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0101f8b:	76 15                	jbe    f0101fa2 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0101f8d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0101f90:	4f                   	dec    %edi
f0101f91:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0101f94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101f97:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101f99:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101fa0:	eb 14                	jmp    f0101fb6 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101fa2:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0101fa5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101fa8:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0101faa:	ff 45 0c             	incl   0xc(%ebp)
f0101fad:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101faf:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0101fb6:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0101fb9:	7e 84                	jle    f0101f3f <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0101fbb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0101fbf:	75 0d                	jne    f0101fce <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0101fc1:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101fc4:	8b 02                	mov    (%edx),%eax
f0101fc6:	48                   	dec    %eax
f0101fc7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101fca:	89 01                	mov    %eax,(%ecx)
f0101fcc:	eb 22                	jmp    f0101ff0 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101fce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101fd1:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0101fd3:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101fd6:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101fd8:	eb 01                	jmp    f0101fdb <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101fda:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101fdb:	39 c1                	cmp    %eax,%ecx
f0101fdd:	7d 0c                	jge    f0101feb <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0101fdf:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0101fe2:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0101fe7:	39 f2                	cmp    %esi,%edx
f0101fe9:	75 ef                	jne    f0101fda <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101feb:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101fee:	89 02                	mov    %eax,(%edx)
	}
}
f0101ff0:	83 c4 10             	add    $0x10,%esp
f0101ff3:	5b                   	pop    %ebx
f0101ff4:	5e                   	pop    %esi
f0101ff5:	5f                   	pop    %edi
f0101ff6:	5d                   	pop    %ebp
f0101ff7:	c3                   	ret    

f0101ff8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101ff8:	55                   	push   %ebp
f0101ff9:	89 e5                	mov    %esp,%ebp
f0101ffb:	83 ec 58             	sub    $0x58,%esp
f0101ffe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0102001:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0102004:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0102007:	8b 75 08             	mov    0x8(%ebp),%esi
f010200a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010200d:	c7 03 dc 3b 10 f0    	movl   $0xf0103bdc,(%ebx)
	info->eip_line = 0;
f0102013:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010201a:	c7 43 08 dc 3b 10 f0 	movl   $0xf0103bdc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102021:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102028:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010202b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102032:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102038:	76 12                	jbe    f010204c <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010203a:	b8 fd b8 10 f0       	mov    $0xf010b8fd,%eax
f010203f:	3d a9 93 10 f0       	cmp    $0xf01093a9,%eax
f0102044:	0f 86 dc 01 00 00    	jbe    f0102226 <debuginfo_eip+0x22e>
f010204a:	eb 1c                	jmp    f0102068 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010204c:	c7 44 24 08 e6 3b 10 	movl   $0xf0103be6,0x8(%esp)
f0102053:	f0 
f0102054:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
f010205b:	00 
f010205c:	c7 04 24 f3 3b 10 f0 	movl   $0xf0103bf3,(%esp)
f0102063:	e8 31 e0 ff ff       	call   f0100099 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010206d:	80 3d fc b8 10 f0 00 	cmpb   $0x0,0xf010b8fc
f0102074:	0f 85 b1 01 00 00    	jne    f010222b <debuginfo_eip+0x233>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010207a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102081:	b8 a8 93 10 f0       	mov    $0xf01093a8,%eax
f0102086:	2d 10 3e 10 f0       	sub    $0xf0103e10,%eax
f010208b:	c1 f8 02             	sar    $0x2,%eax
f010208e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102094:	83 e8 01             	sub    $0x1,%eax
f0102097:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010209a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010209e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01020a5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01020a8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01020ab:	b8 10 3e 10 f0       	mov    $0xf0103e10,%eax
f01020b0:	e8 63 fe ff ff       	call   f0101f18 <stab_binsearch>
	if (lfile == 0)
f01020b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01020b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01020bd:	85 d2                	test   %edx,%edx
f01020bf:	0f 84 66 01 00 00    	je     f010222b <debuginfo_eip+0x233>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01020c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01020c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01020cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01020ce:	89 74 24 04          	mov    %esi,0x4(%esp)
f01020d2:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01020d9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01020dc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01020df:	b8 10 3e 10 f0       	mov    $0xf0103e10,%eax
f01020e4:	e8 2f fe ff ff       	call   f0101f18 <stab_binsearch>

	if (lfun <= rfun) {
f01020e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01020ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01020ef:	39 d0                	cmp    %edx,%eax
f01020f1:	7f 3d                	jg     f0102130 <debuginfo_eip+0x138>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01020f3:	6b c8 0c             	imul   $0xc,%eax,%ecx
f01020f6:	8d b9 10 3e 10 f0    	lea    -0xfefc1f0(%ecx),%edi
f01020fc:	89 7d c0             	mov    %edi,-0x40(%ebp)
f01020ff:	8b 89 10 3e 10 f0    	mov    -0xfefc1f0(%ecx),%ecx
f0102105:	bf fd b8 10 f0       	mov    $0xf010b8fd,%edi
f010210a:	81 ef a9 93 10 f0    	sub    $0xf01093a9,%edi
f0102110:	39 f9                	cmp    %edi,%ecx
f0102112:	73 09                	jae    f010211d <debuginfo_eip+0x125>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102114:	81 c1 a9 93 10 f0    	add    $0xf01093a9,%ecx
f010211a:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010211d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102120:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102123:	89 4b 10             	mov    %ecx,0x10(%ebx)
		// This "n_value" is the function's first addr, but when it comes to SLINE,
		// "n_value" describes the offset, so we need to minus "n_value" fro addr
		// to get the offset of the line.
		addr -= info->eip_fn_addr;
f0102126:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102128:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010212b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010212e:	eb 0f                	jmp    f010213f <debuginfo_eip+0x147>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102130:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102133:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102136:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102139:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010213c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010213f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102146:	00 
f0102147:	8b 43 08             	mov    0x8(%ebx),%eax
f010214a:	89 04 24             	mov    %eax,(%esp)
f010214d:	e8 0d 09 00 00       	call   f0102a5f <strfind>
f0102152:	2b 43 08             	sub    0x8(%ebx),%eax
f0102155:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102158:	89 74 24 04          	mov    %esi,0x4(%esp)
f010215c:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0102163:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102166:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102169:	b8 10 3e 10 f0       	mov    $0xf0103e10,%eax
f010216e:	e8 a5 fd ff ff       	call   f0101f18 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0102173:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102176:	6b d0 0c             	imul   $0xc,%eax,%edx
f0102179:	0f b7 92 16 3e 10 f0 	movzwl -0xfefc1ea(%edx),%edx
f0102180:	89 53 04             	mov    %edx,0x4(%ebx)
	if (rline < lline)
f0102183:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0102186:	7e 07                	jle    f010218f <debuginfo_eip+0x197>
	{
		info->eip_line = -1;
f0102188:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010218f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102192:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102195:	39 c8                	cmp    %ecx,%eax
f0102197:	7c 5f                	jl     f01021f8 <debuginfo_eip+0x200>
	       && stabs[lline].n_type != N_SOL
f0102199:	89 c2                	mov    %eax,%edx
f010219b:	6b f0 0c             	imul   $0xc,%eax,%esi
f010219e:	80 be 14 3e 10 f0 84 	cmpb   $0x84,-0xfefc1ec(%esi)
f01021a5:	75 18                	jne    f01021bf <debuginfo_eip+0x1c7>
f01021a7:	eb 30                	jmp    f01021d9 <debuginfo_eip+0x1e1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01021a9:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01021ac:	39 c1                	cmp    %eax,%ecx
f01021ae:	7f 48                	jg     f01021f8 <debuginfo_eip+0x200>
	       && stabs[lline].n_type != N_SOL
f01021b0:	89 c2                	mov    %eax,%edx
f01021b2:	8d 34 40             	lea    (%eax,%eax,2),%esi
f01021b5:	80 3c b5 14 3e 10 f0 	cmpb   $0x84,-0xfefc1ec(,%esi,4)
f01021bc:	84 
f01021bd:	74 1a                	je     f01021d9 <debuginfo_eip+0x1e1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01021bf:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01021c2:	8d 14 95 10 3e 10 f0 	lea    -0xfefc1f0(,%edx,4),%edx
f01021c9:	80 7a 04 64          	cmpb   $0x64,0x4(%edx)
f01021cd:	75 da                	jne    f01021a9 <debuginfo_eip+0x1b1>
f01021cf:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01021d3:	74 d4                	je     f01021a9 <debuginfo_eip+0x1b1>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01021d5:	39 c8                	cmp    %ecx,%eax
f01021d7:	7c 1f                	jl     f01021f8 <debuginfo_eip+0x200>
f01021d9:	6b c0 0c             	imul   $0xc,%eax,%eax
f01021dc:	8b 80 10 3e 10 f0    	mov    -0xfefc1f0(%eax),%eax
f01021e2:	ba fd b8 10 f0       	mov    $0xf010b8fd,%edx
f01021e7:	81 ea a9 93 10 f0    	sub    $0xf01093a9,%edx
f01021ed:	39 d0                	cmp    %edx,%eax
f01021ef:	73 07                	jae    f01021f8 <debuginfo_eip+0x200>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01021f1:	05 a9 93 10 f0       	add    $0xf01093a9,%eax
f01021f6:	89 03                	mov    %eax,(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f01021f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01021fb:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f01021fe:	b8 00 00 00 00       	mov    $0x0,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0102203:	39 d1                	cmp    %edx,%ecx
f0102205:	7c 24                	jl     f010222b <debuginfo_eip+0x233>
	{
		if (stabs[i].n_type == N_PSYM)
f0102207:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010220a:	80 3c 85 14 3e 10 f0 	cmpb   $0xa0,-0xfefc1ec(,%eax,4)
f0102211:	a0 
f0102212:	75 04                	jne    f0102218 <debuginfo_eip+0x220>
		{
			++(info->eip_fn_narg);
f0102214:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0102218:	83 c2 01             	add    $0x1,%edx
f010221b:	39 d1                	cmp    %edx,%ecx
f010221d:	7d e8                	jge    f0102207 <debuginfo_eip+0x20f>
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f010221f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102224:	eb 05                	jmp    f010222b <debuginfo_eip+0x233>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102226:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		}
	}

	
	return 0;
}
f010222b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010222e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0102231:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0102234:	89 ec                	mov    %ebp,%esp
f0102236:	5d                   	pop    %ebp
f0102237:	c3                   	ret    
	...

f0102240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102240:	55                   	push   %ebp
f0102241:	89 e5                	mov    %esp,%ebp
f0102243:	57                   	push   %edi
f0102244:	56                   	push   %esi
f0102245:	53                   	push   %ebx
f0102246:	83 ec 3c             	sub    $0x3c,%esp
f0102249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010224c:	89 d7                	mov    %edx,%edi
f010224e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102251:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102254:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102257:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010225a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010225d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102260:	b8 00 00 00 00       	mov    $0x0,%eax
f0102265:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0102268:	72 11                	jb     f010227b <printnum+0x3b>
f010226a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010226d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102270:	76 09                	jbe    f010227b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102272:	83 eb 01             	sub    $0x1,%ebx
f0102275:	85 db                	test   %ebx,%ebx
f0102277:	7f 51                	jg     f01022ca <printnum+0x8a>
f0102279:	eb 5e                	jmp    f01022d9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010227b:	89 74 24 10          	mov    %esi,0x10(%esp)
f010227f:	83 eb 01             	sub    $0x1,%ebx
f0102282:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102286:	8b 45 10             	mov    0x10(%ebp),%eax
f0102289:	89 44 24 08          	mov    %eax,0x8(%esp)
f010228d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0102291:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0102295:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010229c:	00 
f010229d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01022a0:	89 04 24             	mov    %eax,(%esp)
f01022a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01022a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022aa:	e8 d1 09 00 00       	call   f0102c80 <__udivdi3>
f01022af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01022b3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01022b7:	89 04 24             	mov    %eax,(%esp)
f01022ba:	89 54 24 04          	mov    %edx,0x4(%esp)
f01022be:	89 fa                	mov    %edi,%edx
f01022c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01022c3:	e8 78 ff ff ff       	call   f0102240 <printnum>
f01022c8:	eb 0f                	jmp    f01022d9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01022ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01022ce:	89 34 24             	mov    %esi,(%esp)
f01022d1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01022d4:	83 eb 01             	sub    $0x1,%ebx
f01022d7:	75 f1                	jne    f01022ca <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01022d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01022dd:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01022e1:	8b 45 10             	mov    0x10(%ebp),%eax
f01022e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01022ef:	00 
f01022f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01022f3:	89 04 24             	mov    %eax,(%esp)
f01022f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01022f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022fd:	e8 ae 0a 00 00       	call   f0102db0 <__umoddi3>
f0102302:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102306:	0f be 80 01 3c 10 f0 	movsbl -0xfefc3ff(%eax),%eax
f010230d:	89 04 24             	mov    %eax,(%esp)
f0102310:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0102313:	83 c4 3c             	add    $0x3c,%esp
f0102316:	5b                   	pop    %ebx
f0102317:	5e                   	pop    %esi
f0102318:	5f                   	pop    %edi
f0102319:	5d                   	pop    %ebp
f010231a:	c3                   	ret    

f010231b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010231b:	55                   	push   %ebp
f010231c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010231e:	83 fa 01             	cmp    $0x1,%edx
f0102321:	7e 0e                	jle    f0102331 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102323:	8b 10                	mov    (%eax),%edx
f0102325:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102328:	89 08                	mov    %ecx,(%eax)
f010232a:	8b 02                	mov    (%edx),%eax
f010232c:	8b 52 04             	mov    0x4(%edx),%edx
f010232f:	eb 22                	jmp    f0102353 <getuint+0x38>
	else if (lflag)
f0102331:	85 d2                	test   %edx,%edx
f0102333:	74 10                	je     f0102345 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102335:	8b 10                	mov    (%eax),%edx
f0102337:	8d 4a 04             	lea    0x4(%edx),%ecx
f010233a:	89 08                	mov    %ecx,(%eax)
f010233c:	8b 02                	mov    (%edx),%eax
f010233e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102343:	eb 0e                	jmp    f0102353 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102345:	8b 10                	mov    (%eax),%edx
f0102347:	8d 4a 04             	lea    0x4(%edx),%ecx
f010234a:	89 08                	mov    %ecx,(%eax)
f010234c:	8b 02                	mov    (%edx),%eax
f010234e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102353:	5d                   	pop    %ebp
f0102354:	c3                   	ret    

f0102355 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0102355:	55                   	push   %ebp
f0102356:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102358:	83 fa 01             	cmp    $0x1,%edx
f010235b:	7e 0e                	jle    f010236b <getint+0x16>
		return va_arg(*ap, long long);
f010235d:	8b 10                	mov    (%eax),%edx
f010235f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102362:	89 08                	mov    %ecx,(%eax)
f0102364:	8b 02                	mov    (%edx),%eax
f0102366:	8b 52 04             	mov    0x4(%edx),%edx
f0102369:	eb 22                	jmp    f010238d <getint+0x38>
	else if (lflag)
f010236b:	85 d2                	test   %edx,%edx
f010236d:	74 10                	je     f010237f <getint+0x2a>
		return va_arg(*ap, long);
f010236f:	8b 10                	mov    (%eax),%edx
f0102371:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102374:	89 08                	mov    %ecx,(%eax)
f0102376:	8b 02                	mov    (%edx),%eax
f0102378:	89 c2                	mov    %eax,%edx
f010237a:	c1 fa 1f             	sar    $0x1f,%edx
f010237d:	eb 0e                	jmp    f010238d <getint+0x38>
	else
		return va_arg(*ap, int);
f010237f:	8b 10                	mov    (%eax),%edx
f0102381:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102384:	89 08                	mov    %ecx,(%eax)
f0102386:	8b 02                	mov    (%edx),%eax
f0102388:	89 c2                	mov    %eax,%edx
f010238a:	c1 fa 1f             	sar    $0x1f,%edx
}
f010238d:	5d                   	pop    %ebp
f010238e:	c3                   	ret    

f010238f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010238f:	55                   	push   %ebp
f0102390:	89 e5                	mov    %esp,%ebp
f0102392:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102395:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102399:	8b 10                	mov    (%eax),%edx
f010239b:	3b 50 04             	cmp    0x4(%eax),%edx
f010239e:	73 0a                	jae    f01023aa <sprintputch+0x1b>
		*b->buf++ = ch;
f01023a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01023a3:	88 0a                	mov    %cl,(%edx)
f01023a5:	83 c2 01             	add    $0x1,%edx
f01023a8:	89 10                	mov    %edx,(%eax)
}
f01023aa:	5d                   	pop    %ebp
f01023ab:	c3                   	ret    

f01023ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01023ac:	55                   	push   %ebp
f01023ad:	89 e5                	mov    %esp,%ebp
f01023af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01023b2:	8d 45 14             	lea    0x14(%ebp),%eax
f01023b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023b9:	8b 45 10             	mov    0x10(%ebp),%eax
f01023bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01023c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01023c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01023c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01023ca:	89 04 24             	mov    %eax,(%esp)
f01023cd:	e8 02 00 00 00       	call   f01023d4 <vprintfmt>
	va_end(ap);
}
f01023d2:	c9                   	leave  
f01023d3:	c3                   	ret    

f01023d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01023d4:	55                   	push   %ebp
f01023d5:	89 e5                	mov    %esp,%ebp
f01023d7:	57                   	push   %edi
f01023d8:	56                   	push   %esi
f01023d9:	53                   	push   %ebx
f01023da:	83 ec 4c             	sub    $0x4c,%esp
f01023dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01023e0:	8b 75 10             	mov    0x10(%ebp),%esi
f01023e3:	eb 12                	jmp    f01023f7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01023e5:	85 c0                	test   %eax,%eax
f01023e7:	0f 84 98 03 00 00    	je     f0102785 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f01023ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023f1:	89 04 24             	mov    %eax,(%esp)
f01023f4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01023f7:	0f b6 06             	movzbl (%esi),%eax
f01023fa:	83 c6 01             	add    $0x1,%esi
f01023fd:	83 f8 25             	cmp    $0x25,%eax
f0102400:	75 e3                	jne    f01023e5 <vprintfmt+0x11>
f0102402:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0102406:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010240d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0102412:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0102419:	b9 00 00 00 00       	mov    $0x0,%ecx
f010241e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102421:	eb 2b                	jmp    f010244e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102423:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102426:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f010242a:	eb 22                	jmp    f010244e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010242c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010242f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0102433:	eb 19                	jmp    f010244e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102435:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0102438:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010243f:	eb 0d                	jmp    f010244e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0102441:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102447:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010244e:	0f b6 06             	movzbl (%esi),%eax
f0102451:	0f b6 d0             	movzbl %al,%edx
f0102454:	8d 7e 01             	lea    0x1(%esi),%edi
f0102457:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010245a:	83 e8 23             	sub    $0x23,%eax
f010245d:	3c 55                	cmp    $0x55,%al
f010245f:	0f 87 fa 02 00 00    	ja     f010275f <vprintfmt+0x38b>
f0102465:	0f b6 c0             	movzbl %al,%eax
f0102468:	ff 24 85 8c 3c 10 f0 	jmp    *-0xfefc374(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010246f:	83 ea 30             	sub    $0x30,%edx
f0102472:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0102475:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0102479:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010247c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f010247f:	83 fa 09             	cmp    $0x9,%edx
f0102482:	77 4a                	ja     f01024ce <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102484:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102487:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f010248a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010248d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0102491:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0102494:	8d 50 d0             	lea    -0x30(%eax),%edx
f0102497:	83 fa 09             	cmp    $0x9,%edx
f010249a:	76 eb                	jbe    f0102487 <vprintfmt+0xb3>
f010249c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010249f:	eb 2d                	jmp    f01024ce <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01024a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01024a4:	8d 50 04             	lea    0x4(%eax),%edx
f01024a7:	89 55 14             	mov    %edx,0x14(%ebp)
f01024aa:	8b 00                	mov    (%eax),%eax
f01024ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01024af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01024b2:	eb 1a                	jmp    f01024ce <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01024b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f01024b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01024bb:	79 91                	jns    f010244e <vprintfmt+0x7a>
f01024bd:	e9 73 ff ff ff       	jmp    f0102435 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01024c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01024c5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01024cc:	eb 80                	jmp    f010244e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f01024ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01024d2:	0f 89 76 ff ff ff    	jns    f010244e <vprintfmt+0x7a>
f01024d8:	e9 64 ff ff ff       	jmp    f0102441 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01024dd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01024e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01024e3:	e9 66 ff ff ff       	jmp    f010244e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01024e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01024eb:	8d 50 04             	lea    0x4(%eax),%edx
f01024ee:	89 55 14             	mov    %edx,0x14(%ebp)
f01024f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024f5:	8b 00                	mov    (%eax),%eax
f01024f7:	89 04 24             	mov    %eax,(%esp)
f01024fa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01024fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102500:	e9 f2 fe ff ff       	jmp    f01023f7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102505:	8b 45 14             	mov    0x14(%ebp),%eax
f0102508:	8d 50 04             	lea    0x4(%eax),%edx
f010250b:	89 55 14             	mov    %edx,0x14(%ebp)
f010250e:	8b 00                	mov    (%eax),%eax
f0102510:	89 c2                	mov    %eax,%edx
f0102512:	c1 fa 1f             	sar    $0x1f,%edx
f0102515:	31 d0                	xor    %edx,%eax
f0102517:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0102519:	83 f8 06             	cmp    $0x6,%eax
f010251c:	7f 0b                	jg     f0102529 <vprintfmt+0x155>
f010251e:	8b 14 85 e4 3d 10 f0 	mov    -0xfefc21c(,%eax,4),%edx
f0102525:	85 d2                	test   %edx,%edx
f0102527:	75 23                	jne    f010254c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0102529:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010252d:	c7 44 24 08 19 3c 10 	movl   $0xf0103c19,0x8(%esp)
f0102534:	f0 
f0102535:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102539:	8b 7d 08             	mov    0x8(%ebp),%edi
f010253c:	89 3c 24             	mov    %edi,(%esp)
f010253f:	e8 68 fe ff ff       	call   f01023ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102544:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102547:	e9 ab fe ff ff       	jmp    f01023f7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f010254c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102550:	c7 44 24 08 1e 3a 10 	movl   $0xf0103a1e,0x8(%esp)
f0102557:	f0 
f0102558:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010255c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010255f:	89 3c 24             	mov    %edi,(%esp)
f0102562:	e8 45 fe ff ff       	call   f01023ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102567:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010256a:	e9 88 fe ff ff       	jmp    f01023f7 <vprintfmt+0x23>
f010256f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102575:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102578:	8b 45 14             	mov    0x14(%ebp),%eax
f010257b:	8d 50 04             	lea    0x4(%eax),%edx
f010257e:	89 55 14             	mov    %edx,0x14(%ebp)
f0102581:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0102583:	85 f6                	test   %esi,%esi
f0102585:	ba 12 3c 10 f0       	mov    $0xf0103c12,%edx
f010258a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f010258d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0102591:	7e 06                	jle    f0102599 <vprintfmt+0x1c5>
f0102593:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0102597:	75 10                	jne    f01025a9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102599:	0f be 06             	movsbl (%esi),%eax
f010259c:	83 c6 01             	add    $0x1,%esi
f010259f:	85 c0                	test   %eax,%eax
f01025a1:	0f 85 86 00 00 00    	jne    f010262d <vprintfmt+0x259>
f01025a7:	eb 76                	jmp    f010261f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01025a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01025ad:	89 34 24             	mov    %esi,(%esp)
f01025b0:	e8 36 03 00 00       	call   f01028eb <strnlen>
f01025b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01025b8:	29 c2                	sub    %eax,%edx
f01025ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01025bd:	85 d2                	test   %edx,%edx
f01025bf:	7e d8                	jle    f0102599 <vprintfmt+0x1c5>
					putch(padc, putdat);
f01025c1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01025c5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01025c8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01025cb:	89 d6                	mov    %edx,%esi
f01025cd:	89 c7                	mov    %eax,%edi
f01025cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025d3:	89 3c 24             	mov    %edi,(%esp)
f01025d6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01025d9:	83 ee 01             	sub    $0x1,%esi
f01025dc:	75 f1                	jne    f01025cf <vprintfmt+0x1fb>
f01025de:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01025e1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01025e4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01025e7:	eb b0                	jmp    f0102599 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01025e9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01025ed:	74 18                	je     f0102607 <vprintfmt+0x233>
f01025ef:	8d 50 e0             	lea    -0x20(%eax),%edx
f01025f2:	83 fa 5e             	cmp    $0x5e,%edx
f01025f5:	76 10                	jbe    f0102607 <vprintfmt+0x233>
					putch('?', putdat);
f01025f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025fb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0102602:	ff 55 08             	call   *0x8(%ebp)
f0102605:	eb 0a                	jmp    f0102611 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f0102607:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010260b:	89 04 24             	mov    %eax,(%esp)
f010260e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102611:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0102615:	0f be 06             	movsbl (%esi),%eax
f0102618:	83 c6 01             	add    $0x1,%esi
f010261b:	85 c0                	test   %eax,%eax
f010261d:	75 0e                	jne    f010262d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010261f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102622:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0102626:	7f 11                	jg     f0102639 <vprintfmt+0x265>
f0102628:	e9 ca fd ff ff       	jmp    f01023f7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010262d:	85 ff                	test   %edi,%edi
f010262f:	90                   	nop
f0102630:	78 b7                	js     f01025e9 <vprintfmt+0x215>
f0102632:	83 ef 01             	sub    $0x1,%edi
f0102635:	79 b2                	jns    f01025e9 <vprintfmt+0x215>
f0102637:	eb e6                	jmp    f010261f <vprintfmt+0x24b>
f0102639:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010263c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010263f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102643:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010264a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010264c:	83 ee 01             	sub    $0x1,%esi
f010264f:	75 ee                	jne    f010263f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102651:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102654:	e9 9e fd ff ff       	jmp    f01023f7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102659:	89 ca                	mov    %ecx,%edx
f010265b:	8d 45 14             	lea    0x14(%ebp),%eax
f010265e:	e8 f2 fc ff ff       	call   f0102355 <getint>
f0102663:	89 c6                	mov    %eax,%esi
f0102665:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102667:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010266c:	85 d2                	test   %edx,%edx
f010266e:	0f 89 ad 00 00 00    	jns    f0102721 <vprintfmt+0x34d>
				putch('-', putdat);
f0102674:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102678:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010267f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0102682:	f7 de                	neg    %esi
f0102684:	83 d7 00             	adc    $0x0,%edi
f0102687:	f7 df                	neg    %edi
			}
			base = 10;
f0102689:	b8 0a 00 00 00       	mov    $0xa,%eax
f010268e:	e9 8e 00 00 00       	jmp    f0102721 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102693:	89 ca                	mov    %ecx,%edx
f0102695:	8d 45 14             	lea    0x14(%ebp),%eax
f0102698:	e8 7e fc ff ff       	call   f010231b <getuint>
f010269d:	89 c6                	mov    %eax,%esi
f010269f:	89 d7                	mov    %edx,%edi
			base = 10;
f01026a1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01026a6:	eb 79                	jmp    f0102721 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f01026a8:	89 ca                	mov    %ecx,%edx
f01026aa:	8d 45 14             	lea    0x14(%ebp),%eax
f01026ad:	e8 a3 fc ff ff       	call   f0102355 <getint>
f01026b2:	89 c6                	mov    %eax,%esi
f01026b4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f01026b6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01026bb:	85 d2                	test   %edx,%edx
f01026bd:	79 62                	jns    f0102721 <vprintfmt+0x34d>
				putch('-', putdat);
f01026bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01026c3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01026ca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01026cd:	f7 de                	neg    %esi
f01026cf:	83 d7 00             	adc    $0x0,%edi
f01026d2:	f7 df                	neg    %edi
			}
			base = 8;
f01026d4:	b8 08 00 00 00       	mov    $0x8,%eax
f01026d9:	eb 46                	jmp    f0102721 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f01026db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01026df:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01026e6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01026e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01026ed:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01026f4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01026f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01026fa:	8d 50 04             	lea    0x4(%eax),%edx
f01026fd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102700:	8b 30                	mov    (%eax),%esi
f0102702:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102707:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010270c:	eb 13                	jmp    f0102721 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010270e:	89 ca                	mov    %ecx,%edx
f0102710:	8d 45 14             	lea    0x14(%ebp),%eax
f0102713:	e8 03 fc ff ff       	call   f010231b <getuint>
f0102718:	89 c6                	mov    %eax,%esi
f010271a:	89 d7                	mov    %edx,%edi
			base = 16;
f010271c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102721:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0102725:	89 54 24 10          	mov    %edx,0x10(%esp)
f0102729:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010272c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102730:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102734:	89 34 24             	mov    %esi,(%esp)
f0102737:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010273b:	89 da                	mov    %ebx,%edx
f010273d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102740:	e8 fb fa ff ff       	call   f0102240 <printnum>
			break;
f0102745:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102748:	e9 aa fc ff ff       	jmp    f01023f7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010274d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102751:	89 14 24             	mov    %edx,(%esp)
f0102754:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102757:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010275a:	e9 98 fc ff ff       	jmp    f01023f7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010275f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102763:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010276a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010276d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0102771:	0f 84 80 fc ff ff    	je     f01023f7 <vprintfmt+0x23>
f0102777:	83 ee 01             	sub    $0x1,%esi
f010277a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010277e:	75 f7                	jne    f0102777 <vprintfmt+0x3a3>
f0102780:	e9 72 fc ff ff       	jmp    f01023f7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0102785:	83 c4 4c             	add    $0x4c,%esp
f0102788:	5b                   	pop    %ebx
f0102789:	5e                   	pop    %esi
f010278a:	5f                   	pop    %edi
f010278b:	5d                   	pop    %ebp
f010278c:	c3                   	ret    

f010278d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010278d:	55                   	push   %ebp
f010278e:	89 e5                	mov    %esp,%ebp
f0102790:	83 ec 28             	sub    $0x28,%esp
f0102793:	8b 45 08             	mov    0x8(%ebp),%eax
f0102796:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102799:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010279c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01027a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01027a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01027aa:	85 c0                	test   %eax,%eax
f01027ac:	74 30                	je     f01027de <vsnprintf+0x51>
f01027ae:	85 d2                	test   %edx,%edx
f01027b0:	7e 2c                	jle    f01027de <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01027b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01027b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027b9:	8b 45 10             	mov    0x10(%ebp),%eax
f01027bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01027c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01027c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027c7:	c7 04 24 8f 23 10 f0 	movl   $0xf010238f,(%esp)
f01027ce:	e8 01 fc ff ff       	call   f01023d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01027d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01027d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01027d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01027dc:	eb 05                	jmp    f01027e3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01027de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01027e3:	c9                   	leave  
f01027e4:	c3                   	ret    

f01027e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01027e5:	55                   	push   %ebp
f01027e6:	89 e5                	mov    %esp,%ebp
f01027e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01027eb:	8d 45 14             	lea    0x14(%ebp),%eax
f01027ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027f2:	8b 45 10             	mov    0x10(%ebp),%eax
f01027f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01027f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102800:	8b 45 08             	mov    0x8(%ebp),%eax
f0102803:	89 04 24             	mov    %eax,(%esp)
f0102806:	e8 82 ff ff ff       	call   f010278d <vsnprintf>
	va_end(ap);

	return rc;
}
f010280b:	c9                   	leave  
f010280c:	c3                   	ret    
f010280d:	00 00                	add    %al,(%eax)
	...

f0102810 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102810:	55                   	push   %ebp
f0102811:	89 e5                	mov    %esp,%ebp
f0102813:	57                   	push   %edi
f0102814:	56                   	push   %esi
f0102815:	53                   	push   %ebx
f0102816:	83 ec 1c             	sub    $0x1c,%esp
f0102819:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010281c:	85 c0                	test   %eax,%eax
f010281e:	74 10                	je     f0102830 <readline+0x20>
		cprintf("%s", prompt);
f0102820:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102824:	c7 04 24 1e 3a 10 f0 	movl   $0xf0103a1e,(%esp)
f010282b:	e8 ce f6 ff ff       	call   f0101efe <cprintf>

	i = 0;
	echoing = iscons(0);
f0102830:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102837:	e8 a0 de ff ff       	call   f01006dc <iscons>
f010283c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010283e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102843:	e8 83 de ff ff       	call   f01006cb <getchar>
f0102848:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010284a:	85 c0                	test   %eax,%eax
f010284c:	79 17                	jns    f0102865 <readline+0x55>
			cprintf("read error: %e\n", c);
f010284e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102852:	c7 04 24 00 3e 10 f0 	movl   $0xf0103e00,(%esp)
f0102859:	e8 a0 f6 ff ff       	call   f0101efe <cprintf>
			return NULL;
f010285e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102863:	eb 61                	jmp    f01028c6 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102865:	83 f8 1f             	cmp    $0x1f,%eax
f0102868:	7e 1f                	jle    f0102889 <readline+0x79>
f010286a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102870:	7f 17                	jg     f0102889 <readline+0x79>
			if (echoing)
f0102872:	85 ff                	test   %edi,%edi
f0102874:	74 08                	je     f010287e <readline+0x6e>
				cputchar(c);
f0102876:	89 04 24             	mov    %eax,(%esp)
f0102879:	e8 3a de ff ff       	call   f01006b8 <cputchar>
			buf[i++] = c;
f010287e:	88 9e 00 46 11 f0    	mov    %bl,-0xfeeba00(%esi)
f0102884:	83 c6 01             	add    $0x1,%esi
f0102887:	eb ba                	jmp    f0102843 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0102889:	83 fb 08             	cmp    $0x8,%ebx
f010288c:	75 15                	jne    f01028a3 <readline+0x93>
f010288e:	85 f6                	test   %esi,%esi
f0102890:	7e 11                	jle    f01028a3 <readline+0x93>
			if (echoing)
f0102892:	85 ff                	test   %edi,%edi
f0102894:	74 08                	je     f010289e <readline+0x8e>
				cputchar(c);
f0102896:	89 1c 24             	mov    %ebx,(%esp)
f0102899:	e8 1a de ff ff       	call   f01006b8 <cputchar>
			i--;
f010289e:	83 ee 01             	sub    $0x1,%esi
f01028a1:	eb a0                	jmp    f0102843 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01028a3:	83 fb 0a             	cmp    $0xa,%ebx
f01028a6:	74 05                	je     f01028ad <readline+0x9d>
f01028a8:	83 fb 0d             	cmp    $0xd,%ebx
f01028ab:	75 96                	jne    f0102843 <readline+0x33>
			if (echoing)
f01028ad:	85 ff                	test   %edi,%edi
f01028af:	90                   	nop
f01028b0:	74 08                	je     f01028ba <readline+0xaa>
				cputchar(c);
f01028b2:	89 1c 24             	mov    %ebx,(%esp)
f01028b5:	e8 fe dd ff ff       	call   f01006b8 <cputchar>
			buf[i] = 0;
f01028ba:	c6 86 00 46 11 f0 00 	movb   $0x0,-0xfeeba00(%esi)
			return buf;
f01028c1:	b8 00 46 11 f0       	mov    $0xf0114600,%eax
		}
	}
}
f01028c6:	83 c4 1c             	add    $0x1c,%esp
f01028c9:	5b                   	pop    %ebx
f01028ca:	5e                   	pop    %esi
f01028cb:	5f                   	pop    %edi
f01028cc:	5d                   	pop    %ebp
f01028cd:	c3                   	ret    
	...

f01028d0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01028d0:	55                   	push   %ebp
f01028d1:	89 e5                	mov    %esp,%ebp
f01028d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01028d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01028db:	80 3a 00             	cmpb   $0x0,(%edx)
f01028de:	74 09                	je     f01028e9 <strlen+0x19>
		n++;
f01028e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01028e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01028e7:	75 f7                	jne    f01028e0 <strlen+0x10>
		n++;
	return n;
}
f01028e9:	5d                   	pop    %ebp
f01028ea:	c3                   	ret    

f01028eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01028eb:	55                   	push   %ebp
f01028ec:	89 e5                	mov    %esp,%ebp
f01028ee:	53                   	push   %ebx
f01028ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01028f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01028f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01028fa:	85 c9                	test   %ecx,%ecx
f01028fc:	74 1a                	je     f0102918 <strnlen+0x2d>
f01028fe:	80 3b 00             	cmpb   $0x0,(%ebx)
f0102901:	74 15                	je     f0102918 <strnlen+0x2d>
f0102903:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0102908:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010290a:	39 ca                	cmp    %ecx,%edx
f010290c:	74 0a                	je     f0102918 <strnlen+0x2d>
f010290e:	83 c2 01             	add    $0x1,%edx
f0102911:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0102916:	75 f0                	jne    f0102908 <strnlen+0x1d>
		n++;
	return n;
}
f0102918:	5b                   	pop    %ebx
f0102919:	5d                   	pop    %ebp
f010291a:	c3                   	ret    

f010291b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010291b:	55                   	push   %ebp
f010291c:	89 e5                	mov    %esp,%ebp
f010291e:	53                   	push   %ebx
f010291f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102925:	ba 00 00 00 00       	mov    $0x0,%edx
f010292a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010292e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102931:	83 c2 01             	add    $0x1,%edx
f0102934:	84 c9                	test   %cl,%cl
f0102936:	75 f2                	jne    f010292a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0102938:	5b                   	pop    %ebx
f0102939:	5d                   	pop    %ebp
f010293a:	c3                   	ret    

f010293b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010293b:	55                   	push   %ebp
f010293c:	89 e5                	mov    %esp,%ebp
f010293e:	56                   	push   %esi
f010293f:	53                   	push   %ebx
f0102940:	8b 45 08             	mov    0x8(%ebp),%eax
f0102943:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102946:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102949:	85 f6                	test   %esi,%esi
f010294b:	74 18                	je     f0102965 <strncpy+0x2a>
f010294d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0102952:	0f b6 1a             	movzbl (%edx),%ebx
f0102955:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0102958:	80 3a 01             	cmpb   $0x1,(%edx)
f010295b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010295e:	83 c1 01             	add    $0x1,%ecx
f0102961:	39 f1                	cmp    %esi,%ecx
f0102963:	75 ed                	jne    f0102952 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0102965:	5b                   	pop    %ebx
f0102966:	5e                   	pop    %esi
f0102967:	5d                   	pop    %ebp
f0102968:	c3                   	ret    

f0102969 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0102969:	55                   	push   %ebp
f010296a:	89 e5                	mov    %esp,%ebp
f010296c:	57                   	push   %edi
f010296d:	56                   	push   %esi
f010296e:	53                   	push   %ebx
f010296f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102975:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102978:	89 f8                	mov    %edi,%eax
f010297a:	85 f6                	test   %esi,%esi
f010297c:	74 2b                	je     f01029a9 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f010297e:	83 fe 01             	cmp    $0x1,%esi
f0102981:	74 23                	je     f01029a6 <strlcpy+0x3d>
f0102983:	0f b6 0b             	movzbl (%ebx),%ecx
f0102986:	84 c9                	test   %cl,%cl
f0102988:	74 1c                	je     f01029a6 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010298a:	83 ee 02             	sub    $0x2,%esi
f010298d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0102992:	88 08                	mov    %cl,(%eax)
f0102994:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0102997:	39 f2                	cmp    %esi,%edx
f0102999:	74 0b                	je     f01029a6 <strlcpy+0x3d>
f010299b:	83 c2 01             	add    $0x1,%edx
f010299e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01029a2:	84 c9                	test   %cl,%cl
f01029a4:	75 ec                	jne    f0102992 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01029a6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01029a9:	29 f8                	sub    %edi,%eax
}
f01029ab:	5b                   	pop    %ebx
f01029ac:	5e                   	pop    %esi
f01029ad:	5f                   	pop    %edi
f01029ae:	5d                   	pop    %ebp
f01029af:	c3                   	ret    

f01029b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01029b0:	55                   	push   %ebp
f01029b1:	89 e5                	mov    %esp,%ebp
f01029b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01029b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01029b9:	0f b6 01             	movzbl (%ecx),%eax
f01029bc:	84 c0                	test   %al,%al
f01029be:	74 16                	je     f01029d6 <strcmp+0x26>
f01029c0:	3a 02                	cmp    (%edx),%al
f01029c2:	75 12                	jne    f01029d6 <strcmp+0x26>
		p++, q++;
f01029c4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01029c7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01029cb:	84 c0                	test   %al,%al
f01029cd:	74 07                	je     f01029d6 <strcmp+0x26>
f01029cf:	83 c1 01             	add    $0x1,%ecx
f01029d2:	3a 02                	cmp    (%edx),%al
f01029d4:	74 ee                	je     f01029c4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01029d6:	0f b6 c0             	movzbl %al,%eax
f01029d9:	0f b6 12             	movzbl (%edx),%edx
f01029dc:	29 d0                	sub    %edx,%eax
}
f01029de:	5d                   	pop    %ebp
f01029df:	c3                   	ret    

f01029e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01029e0:	55                   	push   %ebp
f01029e1:	89 e5                	mov    %esp,%ebp
f01029e3:	53                   	push   %ebx
f01029e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01029e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01029ea:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01029ed:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01029f2:	85 d2                	test   %edx,%edx
f01029f4:	74 28                	je     f0102a1e <strncmp+0x3e>
f01029f6:	0f b6 01             	movzbl (%ecx),%eax
f01029f9:	84 c0                	test   %al,%al
f01029fb:	74 24                	je     f0102a21 <strncmp+0x41>
f01029fd:	3a 03                	cmp    (%ebx),%al
f01029ff:	75 20                	jne    f0102a21 <strncmp+0x41>
f0102a01:	83 ea 01             	sub    $0x1,%edx
f0102a04:	74 13                	je     f0102a19 <strncmp+0x39>
		n--, p++, q++;
f0102a06:	83 c1 01             	add    $0x1,%ecx
f0102a09:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102a0c:	0f b6 01             	movzbl (%ecx),%eax
f0102a0f:	84 c0                	test   %al,%al
f0102a11:	74 0e                	je     f0102a21 <strncmp+0x41>
f0102a13:	3a 03                	cmp    (%ebx),%al
f0102a15:	74 ea                	je     f0102a01 <strncmp+0x21>
f0102a17:	eb 08                	jmp    f0102a21 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102a19:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102a1e:	5b                   	pop    %ebx
f0102a1f:	5d                   	pop    %ebp
f0102a20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102a21:	0f b6 01             	movzbl (%ecx),%eax
f0102a24:	0f b6 13             	movzbl (%ebx),%edx
f0102a27:	29 d0                	sub    %edx,%eax
f0102a29:	eb f3                	jmp    f0102a1e <strncmp+0x3e>

f0102a2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0102a2b:	55                   	push   %ebp
f0102a2c:	89 e5                	mov    %esp,%ebp
f0102a2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102a35:	0f b6 10             	movzbl (%eax),%edx
f0102a38:	84 d2                	test   %dl,%dl
f0102a3a:	74 1c                	je     f0102a58 <strchr+0x2d>
		if (*s == c)
f0102a3c:	38 ca                	cmp    %cl,%dl
f0102a3e:	75 09                	jne    f0102a49 <strchr+0x1e>
f0102a40:	eb 1b                	jmp    f0102a5d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0102a42:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0102a45:	38 ca                	cmp    %cl,%dl
f0102a47:	74 14                	je     f0102a5d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0102a49:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0102a4d:	84 d2                	test   %dl,%dl
f0102a4f:	75 f1                	jne    f0102a42 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0102a51:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a56:	eb 05                	jmp    f0102a5d <strchr+0x32>
f0102a58:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a5d:	5d                   	pop    %ebp
f0102a5e:	c3                   	ret    

f0102a5f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0102a5f:	55                   	push   %ebp
f0102a60:	89 e5                	mov    %esp,%ebp
f0102a62:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a65:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102a69:	0f b6 10             	movzbl (%eax),%edx
f0102a6c:	84 d2                	test   %dl,%dl
f0102a6e:	74 14                	je     f0102a84 <strfind+0x25>
		if (*s == c)
f0102a70:	38 ca                	cmp    %cl,%dl
f0102a72:	75 06                	jne    f0102a7a <strfind+0x1b>
f0102a74:	eb 0e                	jmp    f0102a84 <strfind+0x25>
f0102a76:	38 ca                	cmp    %cl,%dl
f0102a78:	74 0a                	je     f0102a84 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0102a7a:	83 c0 01             	add    $0x1,%eax
f0102a7d:	0f b6 10             	movzbl (%eax),%edx
f0102a80:	84 d2                	test   %dl,%dl
f0102a82:	75 f2                	jne    f0102a76 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0102a84:	5d                   	pop    %ebp
f0102a85:	c3                   	ret    

f0102a86 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0102a86:	55                   	push   %ebp
f0102a87:	89 e5                	mov    %esp,%ebp
f0102a89:	53                   	push   %ebx
f0102a8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102a90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0102a93:	89 da                	mov    %ebx,%edx
f0102a95:	83 ea 01             	sub    $0x1,%edx
f0102a98:	78 0d                	js     f0102aa7 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f0102a9a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f0102a9c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f0102a9e:	88 0a                	mov    %cl,(%edx)
f0102aa0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0102aa3:	39 da                	cmp    %ebx,%edx
f0102aa5:	75 f7                	jne    f0102a9e <memset+0x18>
		*p++ = c;

	return v;
}
f0102aa7:	5b                   	pop    %ebx
f0102aa8:	5d                   	pop    %ebp
f0102aa9:	c3                   	ret    

f0102aaa <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f0102aaa:	55                   	push   %ebp
f0102aab:	89 e5                	mov    %esp,%ebp
f0102aad:	57                   	push   %edi
f0102aae:	56                   	push   %esi
f0102aaf:	53                   	push   %ebx
f0102ab0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ab3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102ab6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0102ab9:	39 c6                	cmp    %eax,%esi
f0102abb:	72 0b                	jb     f0102ac8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0102abd:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ac2:	85 db                	test   %ebx,%ebx
f0102ac4:	75 29                	jne    f0102aef <memmove+0x45>
f0102ac6:	eb 35                	jmp    f0102afd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0102ac8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f0102acb:	39 c8                	cmp    %ecx,%eax
f0102acd:	73 ee                	jae    f0102abd <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f0102acf:	85 db                	test   %ebx,%ebx
f0102ad1:	74 2a                	je     f0102afd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0102ad3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f0102ad6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f0102ad8:	f7 db                	neg    %ebx
f0102ada:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f0102add:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f0102adf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0102ae4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0102ae8:	83 ea 01             	sub    $0x1,%edx
f0102aeb:	75 f2                	jne    f0102adf <memmove+0x35>
f0102aed:	eb 0e                	jmp    f0102afd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0102aef:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0102af3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102af6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0102af9:	39 d3                	cmp    %edx,%ebx
f0102afb:	75 f2                	jne    f0102aef <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f0102afd:	5b                   	pop    %ebx
f0102afe:	5e                   	pop    %esi
f0102aff:	5f                   	pop    %edi
f0102b00:	5d                   	pop    %ebp
f0102b01:	c3                   	ret    

f0102b02 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0102b02:	55                   	push   %ebp
f0102b03:	89 e5                	mov    %esp,%ebp
f0102b05:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0102b08:	8b 45 10             	mov    0x10(%ebp),%eax
f0102b0b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b16:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b19:	89 04 24             	mov    %eax,(%esp)
f0102b1c:	e8 89 ff ff ff       	call   f0102aaa <memmove>
}
f0102b21:	c9                   	leave  
f0102b22:	c3                   	ret    

f0102b23 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0102b23:	55                   	push   %ebp
f0102b24:	89 e5                	mov    %esp,%ebp
f0102b26:	57                   	push   %edi
f0102b27:	56                   	push   %esi
f0102b28:	53                   	push   %ebx
f0102b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0102b2c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102b2f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102b32:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102b37:	85 ff                	test   %edi,%edi
f0102b39:	74 37                	je     f0102b72 <memcmp+0x4f>
		if (*s1 != *s2)
f0102b3b:	0f b6 03             	movzbl (%ebx),%eax
f0102b3e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102b41:	83 ef 01             	sub    $0x1,%edi
f0102b44:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0102b49:	38 c8                	cmp    %cl,%al
f0102b4b:	74 1c                	je     f0102b69 <memcmp+0x46>
f0102b4d:	eb 10                	jmp    f0102b5f <memcmp+0x3c>
f0102b4f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0102b54:	83 c2 01             	add    $0x1,%edx
f0102b57:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0102b5b:	38 c8                	cmp    %cl,%al
f0102b5d:	74 0a                	je     f0102b69 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0102b5f:	0f b6 c0             	movzbl %al,%eax
f0102b62:	0f b6 c9             	movzbl %cl,%ecx
f0102b65:	29 c8                	sub    %ecx,%eax
f0102b67:	eb 09                	jmp    f0102b72 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102b69:	39 fa                	cmp    %edi,%edx
f0102b6b:	75 e2                	jne    f0102b4f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102b6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102b72:	5b                   	pop    %ebx
f0102b73:	5e                   	pop    %esi
f0102b74:	5f                   	pop    %edi
f0102b75:	5d                   	pop    %ebp
f0102b76:	c3                   	ret    

f0102b77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102b77:	55                   	push   %ebp
f0102b78:	89 e5                	mov    %esp,%ebp
f0102b7a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0102b7d:	89 c2                	mov    %eax,%edx
f0102b7f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0102b82:	39 d0                	cmp    %edx,%eax
f0102b84:	73 15                	jae    f0102b9b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102b86:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0102b8a:	38 08                	cmp    %cl,(%eax)
f0102b8c:	75 06                	jne    f0102b94 <memfind+0x1d>
f0102b8e:	eb 0b                	jmp    f0102b9b <memfind+0x24>
f0102b90:	38 08                	cmp    %cl,(%eax)
f0102b92:	74 07                	je     f0102b9b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102b94:	83 c0 01             	add    $0x1,%eax
f0102b97:	39 d0                	cmp    %edx,%eax
f0102b99:	75 f5                	jne    f0102b90 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102b9b:	5d                   	pop    %ebp
f0102b9c:	c3                   	ret    

f0102b9d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102b9d:	55                   	push   %ebp
f0102b9e:	89 e5                	mov    %esp,%ebp
f0102ba0:	57                   	push   %edi
f0102ba1:	56                   	push   %esi
f0102ba2:	53                   	push   %ebx
f0102ba3:	8b 55 08             	mov    0x8(%ebp),%edx
f0102ba6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102ba9:	0f b6 02             	movzbl (%edx),%eax
f0102bac:	3c 20                	cmp    $0x20,%al
f0102bae:	74 04                	je     f0102bb4 <strtol+0x17>
f0102bb0:	3c 09                	cmp    $0x9,%al
f0102bb2:	75 0e                	jne    f0102bc2 <strtol+0x25>
		s++;
f0102bb4:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102bb7:	0f b6 02             	movzbl (%edx),%eax
f0102bba:	3c 20                	cmp    $0x20,%al
f0102bbc:	74 f6                	je     f0102bb4 <strtol+0x17>
f0102bbe:	3c 09                	cmp    $0x9,%al
f0102bc0:	74 f2                	je     f0102bb4 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102bc2:	3c 2b                	cmp    $0x2b,%al
f0102bc4:	75 0a                	jne    f0102bd0 <strtol+0x33>
		s++;
f0102bc6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102bc9:	bf 00 00 00 00       	mov    $0x0,%edi
f0102bce:	eb 10                	jmp    f0102be0 <strtol+0x43>
f0102bd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0102bd5:	3c 2d                	cmp    $0x2d,%al
f0102bd7:	75 07                	jne    f0102be0 <strtol+0x43>
		s++, neg = 1;
f0102bd9:	83 c2 01             	add    $0x1,%edx
f0102bdc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0102be0:	85 db                	test   %ebx,%ebx
f0102be2:	0f 94 c0             	sete   %al
f0102be5:	74 05                	je     f0102bec <strtol+0x4f>
f0102be7:	83 fb 10             	cmp    $0x10,%ebx
f0102bea:	75 15                	jne    f0102c01 <strtol+0x64>
f0102bec:	80 3a 30             	cmpb   $0x30,(%edx)
f0102bef:	75 10                	jne    f0102c01 <strtol+0x64>
f0102bf1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0102bf5:	75 0a                	jne    f0102c01 <strtol+0x64>
		s += 2, base = 16;
f0102bf7:	83 c2 02             	add    $0x2,%edx
f0102bfa:	bb 10 00 00 00       	mov    $0x10,%ebx
f0102bff:	eb 13                	jmp    f0102c14 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0102c01:	84 c0                	test   %al,%al
f0102c03:	74 0f                	je     f0102c14 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0102c05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102c0a:	80 3a 30             	cmpb   $0x30,(%edx)
f0102c0d:	75 05                	jne    f0102c14 <strtol+0x77>
		s++, base = 8;
f0102c0f:	83 c2 01             	add    $0x1,%edx
f0102c12:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0102c14:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c19:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102c1b:	0f b6 0a             	movzbl (%edx),%ecx
f0102c1e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0102c21:	80 fb 09             	cmp    $0x9,%bl
f0102c24:	77 08                	ja     f0102c2e <strtol+0x91>
			dig = *s - '0';
f0102c26:	0f be c9             	movsbl %cl,%ecx
f0102c29:	83 e9 30             	sub    $0x30,%ecx
f0102c2c:	eb 1e                	jmp    f0102c4c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0102c2e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0102c31:	80 fb 19             	cmp    $0x19,%bl
f0102c34:	77 08                	ja     f0102c3e <strtol+0xa1>
			dig = *s - 'a' + 10;
f0102c36:	0f be c9             	movsbl %cl,%ecx
f0102c39:	83 e9 57             	sub    $0x57,%ecx
f0102c3c:	eb 0e                	jmp    f0102c4c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0102c3e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0102c41:	80 fb 19             	cmp    $0x19,%bl
f0102c44:	77 14                	ja     f0102c5a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0102c46:	0f be c9             	movsbl %cl,%ecx
f0102c49:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0102c4c:	39 f1                	cmp    %esi,%ecx
f0102c4e:	7d 0e                	jge    f0102c5e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0102c50:	83 c2 01             	add    $0x1,%edx
f0102c53:	0f af c6             	imul   %esi,%eax
f0102c56:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0102c58:	eb c1                	jmp    f0102c1b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0102c5a:	89 c1                	mov    %eax,%ecx
f0102c5c:	eb 02                	jmp    f0102c60 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0102c5e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0102c60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0102c64:	74 05                	je     f0102c6b <strtol+0xce>
		*endptr = (char *) s;
f0102c66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102c69:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0102c6b:	89 ca                	mov    %ecx,%edx
f0102c6d:	f7 da                	neg    %edx
f0102c6f:	85 ff                	test   %edi,%edi
f0102c71:	0f 45 c2             	cmovne %edx,%eax
}
f0102c74:	5b                   	pop    %ebx
f0102c75:	5e                   	pop    %esi
f0102c76:	5f                   	pop    %edi
f0102c77:	5d                   	pop    %ebp
f0102c78:	c3                   	ret    
f0102c79:	00 00                	add    %al,(%eax)
f0102c7b:	00 00                	add    %al,(%eax)
f0102c7d:	00 00                	add    %al,(%eax)
	...

f0102c80 <__udivdi3>:
f0102c80:	83 ec 1c             	sub    $0x1c,%esp
f0102c83:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0102c87:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0102c8b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0102c8f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102c93:	89 74 24 10          	mov    %esi,0x10(%esp)
f0102c97:	8b 74 24 24          	mov    0x24(%esp),%esi
f0102c9b:	85 ff                	test   %edi,%edi
f0102c9d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0102ca1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ca5:	89 cd                	mov    %ecx,%ebp
f0102ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102cab:	75 33                	jne    f0102ce0 <__udivdi3+0x60>
f0102cad:	39 f1                	cmp    %esi,%ecx
f0102caf:	77 57                	ja     f0102d08 <__udivdi3+0x88>
f0102cb1:	85 c9                	test   %ecx,%ecx
f0102cb3:	75 0b                	jne    f0102cc0 <__udivdi3+0x40>
f0102cb5:	b8 01 00 00 00       	mov    $0x1,%eax
f0102cba:	31 d2                	xor    %edx,%edx
f0102cbc:	f7 f1                	div    %ecx
f0102cbe:	89 c1                	mov    %eax,%ecx
f0102cc0:	89 f0                	mov    %esi,%eax
f0102cc2:	31 d2                	xor    %edx,%edx
f0102cc4:	f7 f1                	div    %ecx
f0102cc6:	89 c6                	mov    %eax,%esi
f0102cc8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0102ccc:	f7 f1                	div    %ecx
f0102cce:	89 f2                	mov    %esi,%edx
f0102cd0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102cd4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102cd8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102cdc:	83 c4 1c             	add    $0x1c,%esp
f0102cdf:	c3                   	ret    
f0102ce0:	31 d2                	xor    %edx,%edx
f0102ce2:	31 c0                	xor    %eax,%eax
f0102ce4:	39 f7                	cmp    %esi,%edi
f0102ce6:	77 e8                	ja     f0102cd0 <__udivdi3+0x50>
f0102ce8:	0f bd cf             	bsr    %edi,%ecx
f0102ceb:	83 f1 1f             	xor    $0x1f,%ecx
f0102cee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0102cf2:	75 2c                	jne    f0102d20 <__udivdi3+0xa0>
f0102cf4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0102cf8:	76 04                	jbe    f0102cfe <__udivdi3+0x7e>
f0102cfa:	39 f7                	cmp    %esi,%edi
f0102cfc:	73 d2                	jae    f0102cd0 <__udivdi3+0x50>
f0102cfe:	31 d2                	xor    %edx,%edx
f0102d00:	b8 01 00 00 00       	mov    $0x1,%eax
f0102d05:	eb c9                	jmp    f0102cd0 <__udivdi3+0x50>
f0102d07:	90                   	nop
f0102d08:	89 f2                	mov    %esi,%edx
f0102d0a:	f7 f1                	div    %ecx
f0102d0c:	31 d2                	xor    %edx,%edx
f0102d0e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102d12:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102d16:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102d1a:	83 c4 1c             	add    $0x1c,%esp
f0102d1d:	c3                   	ret    
f0102d1e:	66 90                	xchg   %ax,%ax
f0102d20:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102d25:	b8 20 00 00 00       	mov    $0x20,%eax
f0102d2a:	89 ea                	mov    %ebp,%edx
f0102d2c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0102d30:	d3 e7                	shl    %cl,%edi
f0102d32:	89 c1                	mov    %eax,%ecx
f0102d34:	d3 ea                	shr    %cl,%edx
f0102d36:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102d3b:	09 fa                	or     %edi,%edx
f0102d3d:	89 f7                	mov    %esi,%edi
f0102d3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d43:	89 f2                	mov    %esi,%edx
f0102d45:	8b 74 24 08          	mov    0x8(%esp),%esi
f0102d49:	d3 e5                	shl    %cl,%ebp
f0102d4b:	89 c1                	mov    %eax,%ecx
f0102d4d:	d3 ef                	shr    %cl,%edi
f0102d4f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102d54:	d3 e2                	shl    %cl,%edx
f0102d56:	89 c1                	mov    %eax,%ecx
f0102d58:	d3 ee                	shr    %cl,%esi
f0102d5a:	09 d6                	or     %edx,%esi
f0102d5c:	89 fa                	mov    %edi,%edx
f0102d5e:	89 f0                	mov    %esi,%eax
f0102d60:	f7 74 24 0c          	divl   0xc(%esp)
f0102d64:	89 d7                	mov    %edx,%edi
f0102d66:	89 c6                	mov    %eax,%esi
f0102d68:	f7 e5                	mul    %ebp
f0102d6a:	39 d7                	cmp    %edx,%edi
f0102d6c:	72 22                	jb     f0102d90 <__udivdi3+0x110>
f0102d6e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0102d72:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102d77:	d3 e5                	shl    %cl,%ebp
f0102d79:	39 c5                	cmp    %eax,%ebp
f0102d7b:	73 04                	jae    f0102d81 <__udivdi3+0x101>
f0102d7d:	39 d7                	cmp    %edx,%edi
f0102d7f:	74 0f                	je     f0102d90 <__udivdi3+0x110>
f0102d81:	89 f0                	mov    %esi,%eax
f0102d83:	31 d2                	xor    %edx,%edx
f0102d85:	e9 46 ff ff ff       	jmp    f0102cd0 <__udivdi3+0x50>
f0102d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102d90:	8d 46 ff             	lea    -0x1(%esi),%eax
f0102d93:	31 d2                	xor    %edx,%edx
f0102d95:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102d99:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102d9d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102da1:	83 c4 1c             	add    $0x1c,%esp
f0102da4:	c3                   	ret    
	...

f0102db0 <__umoddi3>:
f0102db0:	83 ec 1c             	sub    $0x1c,%esp
f0102db3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0102db7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0102dbb:	8b 44 24 20          	mov    0x20(%esp),%eax
f0102dbf:	89 74 24 10          	mov    %esi,0x10(%esp)
f0102dc3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102dc7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0102dcb:	85 ed                	test   %ebp,%ebp
f0102dcd:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0102dd1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102dd5:	89 cf                	mov    %ecx,%edi
f0102dd7:	89 04 24             	mov    %eax,(%esp)
f0102dda:	89 f2                	mov    %esi,%edx
f0102ddc:	75 1a                	jne    f0102df8 <__umoddi3+0x48>
f0102dde:	39 f1                	cmp    %esi,%ecx
f0102de0:	76 4e                	jbe    f0102e30 <__umoddi3+0x80>
f0102de2:	f7 f1                	div    %ecx
f0102de4:	89 d0                	mov    %edx,%eax
f0102de6:	31 d2                	xor    %edx,%edx
f0102de8:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102dec:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102df0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102df4:	83 c4 1c             	add    $0x1c,%esp
f0102df7:	c3                   	ret    
f0102df8:	39 f5                	cmp    %esi,%ebp
f0102dfa:	77 54                	ja     f0102e50 <__umoddi3+0xa0>
f0102dfc:	0f bd c5             	bsr    %ebp,%eax
f0102dff:	83 f0 1f             	xor    $0x1f,%eax
f0102e02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e06:	75 60                	jne    f0102e68 <__umoddi3+0xb8>
f0102e08:	3b 0c 24             	cmp    (%esp),%ecx
f0102e0b:	0f 87 07 01 00 00    	ja     f0102f18 <__umoddi3+0x168>
f0102e11:	89 f2                	mov    %esi,%edx
f0102e13:	8b 34 24             	mov    (%esp),%esi
f0102e16:	29 ce                	sub    %ecx,%esi
f0102e18:	19 ea                	sbb    %ebp,%edx
f0102e1a:	89 34 24             	mov    %esi,(%esp)
f0102e1d:	8b 04 24             	mov    (%esp),%eax
f0102e20:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102e24:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102e28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102e2c:	83 c4 1c             	add    $0x1c,%esp
f0102e2f:	c3                   	ret    
f0102e30:	85 c9                	test   %ecx,%ecx
f0102e32:	75 0b                	jne    f0102e3f <__umoddi3+0x8f>
f0102e34:	b8 01 00 00 00       	mov    $0x1,%eax
f0102e39:	31 d2                	xor    %edx,%edx
f0102e3b:	f7 f1                	div    %ecx
f0102e3d:	89 c1                	mov    %eax,%ecx
f0102e3f:	89 f0                	mov    %esi,%eax
f0102e41:	31 d2                	xor    %edx,%edx
f0102e43:	f7 f1                	div    %ecx
f0102e45:	8b 04 24             	mov    (%esp),%eax
f0102e48:	f7 f1                	div    %ecx
f0102e4a:	eb 98                	jmp    f0102de4 <__umoddi3+0x34>
f0102e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102e50:	89 f2                	mov    %esi,%edx
f0102e52:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102e56:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102e5a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102e5e:	83 c4 1c             	add    $0x1c,%esp
f0102e61:	c3                   	ret    
f0102e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102e68:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102e6d:	89 e8                	mov    %ebp,%eax
f0102e6f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0102e74:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0102e78:	89 fa                	mov    %edi,%edx
f0102e7a:	d3 e0                	shl    %cl,%eax
f0102e7c:	89 e9                	mov    %ebp,%ecx
f0102e7e:	d3 ea                	shr    %cl,%edx
f0102e80:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102e85:	09 c2                	or     %eax,%edx
f0102e87:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102e8b:	89 14 24             	mov    %edx,(%esp)
f0102e8e:	89 f2                	mov    %esi,%edx
f0102e90:	d3 e7                	shl    %cl,%edi
f0102e92:	89 e9                	mov    %ebp,%ecx
f0102e94:	d3 ea                	shr    %cl,%edx
f0102e96:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102e9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102e9f:	d3 e6                	shl    %cl,%esi
f0102ea1:	89 e9                	mov    %ebp,%ecx
f0102ea3:	d3 e8                	shr    %cl,%eax
f0102ea5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102eaa:	09 f0                	or     %esi,%eax
f0102eac:	8b 74 24 08          	mov    0x8(%esp),%esi
f0102eb0:	f7 34 24             	divl   (%esp)
f0102eb3:	d3 e6                	shl    %cl,%esi
f0102eb5:	89 74 24 08          	mov    %esi,0x8(%esp)
f0102eb9:	89 d6                	mov    %edx,%esi
f0102ebb:	f7 e7                	mul    %edi
f0102ebd:	39 d6                	cmp    %edx,%esi
f0102ebf:	89 c1                	mov    %eax,%ecx
f0102ec1:	89 d7                	mov    %edx,%edi
f0102ec3:	72 3f                	jb     f0102f04 <__umoddi3+0x154>
f0102ec5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0102ec9:	72 35                	jb     f0102f00 <__umoddi3+0x150>
f0102ecb:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102ecf:	29 c8                	sub    %ecx,%eax
f0102ed1:	19 fe                	sbb    %edi,%esi
f0102ed3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102ed8:	89 f2                	mov    %esi,%edx
f0102eda:	d3 e8                	shr    %cl,%eax
f0102edc:	89 e9                	mov    %ebp,%ecx
f0102ede:	d3 e2                	shl    %cl,%edx
f0102ee0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0102ee5:	09 d0                	or     %edx,%eax
f0102ee7:	89 f2                	mov    %esi,%edx
f0102ee9:	d3 ea                	shr    %cl,%edx
f0102eeb:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102eef:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0102ef3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0102ef7:	83 c4 1c             	add    $0x1c,%esp
f0102efa:	c3                   	ret    
f0102efb:	90                   	nop
f0102efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102f00:	39 d6                	cmp    %edx,%esi
f0102f02:	75 c7                	jne    f0102ecb <__umoddi3+0x11b>
f0102f04:	89 d7                	mov    %edx,%edi
f0102f06:	89 c1                	mov    %eax,%ecx
f0102f08:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0102f0c:	1b 3c 24             	sbb    (%esp),%edi
f0102f0f:	eb ba                	jmp    f0102ecb <__umoddi3+0x11b>
f0102f11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102f18:	39 f5                	cmp    %esi,%ebp
f0102f1a:	0f 82 f1 fe ff ff    	jb     f0102e11 <__umoddi3+0x61>
f0102f20:	e9 f8 fe ff ff       	jmp    f0102e1d <__umoddi3+0x6d>
