
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
f0100015:	0f 01 15 18 20 11 00 	lgdtl  0x112018

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
f0100033:	bc 00 20 11 f0       	mov    $0xf0112000,%esp

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
f0100046:	b8 10 2a 11 f0       	mov    $0xf0112a10,%eax
f010004b:	2d 70 23 11 f0       	sub    $0xf0112370,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 70 23 11 f0 	movl   $0xf0112370,(%esp)
f0100063:	e8 0e 1a 00 00       	call   f0101a76 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 24 06 00 00       	call   f0100691 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 20 1f 10 f0 	movl   $0xf0101f20,(%esp)
f010007c:	e8 dd 0e 00 00       	call   f0100f5e <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100081:	e8 30 09 00 00       	call   f01009b6 <i386_detect_memory>
	i386_vm_init();
f0100086:	e8 c2 09 00 00       	call   f0100a4d <i386_vm_init>
	// seems that it won`t work, because I never see 6828 on the screen.
	// okay, it is the problem caused by wrong version of bochs. Maybe another way to handle?

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100092:	e8 aa 07 00 00       	call   f0100841 <monitor>
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
f010009f:	83 3d 80 23 11 f0 00 	cmpl   $0x0,0xf0112380
f01000a6:	75 40                	jne    f01000e8 <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f01000a8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000ab:	a3 80 23 11 f0       	mov    %eax,0xf0112380

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000be:	c7 04 24 3b 1f 10 f0 	movl   $0xf0101f3b,(%esp)
f01000c5:	e8 94 0e 00 00       	call   f0100f5e <cprintf>
	vcprintf(fmt, ap);
f01000ca:	8d 45 14             	lea    0x14(%ebp),%eax
f01000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000d1:	8b 45 10             	mov    0x10(%ebp),%eax
f01000d4:	89 04 24             	mov    %eax,(%esp)
f01000d7:	e8 4f 0e 00 00       	call   f0100f2b <vcprintf>
	cprintf("\n");
f01000dc:	c7 04 24 77 1f 10 f0 	movl   $0xf0101f77,(%esp)
f01000e3:	e8 76 0e 00 00       	call   f0100f5e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ef:	e8 4d 07 00 00       	call   f0100841 <monitor>
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
f010010a:	c7 04 24 53 1f 10 f0 	movl   $0xf0101f53,(%esp)
f0100111:	e8 48 0e 00 00       	call   f0100f5e <cprintf>
	vcprintf(fmt, ap);
f0100116:	8d 45 14             	lea    0x14(%ebp),%eax
f0100119:	89 44 24 04          	mov    %eax,0x4(%esp)
f010011d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100120:	89 04 24             	mov    %eax,(%esp)
f0100123:	e8 03 0e 00 00       	call   f0100f2b <vcprintf>
	cprintf("\n");
f0100128:	c7 04 24 77 1f 10 f0 	movl   $0xf0101f77,(%esp)
f010012f:	e8 2a 0e 00 00       	call   f0100f5e <cprintf>
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
f0100177:	83 0d b0 23 11 f0 40 	orl    $0x40,0xf01123b0
		return 0;
f010017e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100183:	e9 c4 00 00 00       	jmp    f010024c <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f0100188:	84 c0                	test   %al,%al
f010018a:	79 37                	jns    f01001c3 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010018c:	8b 0d b0 23 11 f0    	mov    0xf01123b0,%ecx
f0100192:	89 cb                	mov    %ecx,%ebx
f0100194:	83 e3 40             	and    $0x40,%ebx
f0100197:	83 e0 7f             	and    $0x7f,%eax
f010019a:	85 db                	test   %ebx,%ebx
f010019c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010019f:	0f b6 d2             	movzbl %dl,%edx
f01001a2:	0f b6 82 80 21 10 f0 	movzbl -0xfefde80(%edx),%eax
f01001a9:	83 c8 40             	or     $0x40,%eax
f01001ac:	0f b6 c0             	movzbl %al,%eax
f01001af:	f7 d0                	not    %eax
f01001b1:	21 c1                	and    %eax,%ecx
f01001b3:	89 0d b0 23 11 f0    	mov    %ecx,0xf01123b0
		return 0;
f01001b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001be:	e9 89 00 00 00       	jmp    f010024c <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01001c3:	8b 0d b0 23 11 f0    	mov    0xf01123b0,%ecx
f01001c9:	f6 c1 40             	test   $0x40,%cl
f01001cc:	74 0e                	je     f01001dc <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ce:	89 c2                	mov    %eax,%edx
f01001d0:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01001d3:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001d6:	89 0d b0 23 11 f0    	mov    %ecx,0xf01123b0
	}

	shift |= shiftcode[data];
f01001dc:	0f b6 d2             	movzbl %dl,%edx
f01001df:	0f b6 82 80 21 10 f0 	movzbl -0xfefde80(%edx),%eax
f01001e6:	0b 05 b0 23 11 f0    	or     0xf01123b0,%eax
	shift ^= togglecode[data];
f01001ec:	0f b6 8a 80 22 10 f0 	movzbl -0xfefdd80(%edx),%ecx
f01001f3:	31 c8                	xor    %ecx,%eax
f01001f5:	a3 b0 23 11 f0       	mov    %eax,0xf01123b0

	c = charcode[shift & (CTL | SHIFT)][data];
f01001fa:	89 c1                	mov    %eax,%ecx
f01001fc:	83 e1 03             	and    $0x3,%ecx
f01001ff:	8b 0c 8d 80 23 10 f0 	mov    -0xfefdc80(,%ecx,4),%ecx
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
f0100235:	c7 04 24 6d 1f 10 f0 	movl   $0xf0101f6d,(%esp)
f010023c:	e8 1d 0d 00 00       	call   f0100f5e <cprintf>
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
f01002a5:	a3 a0 23 11 f0       	mov    %eax,0xf01123a0
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
f01002df:	c7 05 a4 23 11 f0 b4 	movl   $0x3b4,0xf01123a4
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
f01002f7:	c7 05 a4 23 11 f0 d4 	movl   $0x3d4,0xf01123a4
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
f0100306:	8b 0d a4 23 11 f0    	mov    0xf01123a4,%ecx
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
f010032b:	89 35 a8 23 11 f0    	mov    %esi,0xf01123a8
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100331:	0f b6 d8             	movzbl %al,%ebx
f0100334:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100336:	66 89 3d ac 23 11 f0 	mov    %di,0xf01123ac
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
f010035f:	8b 15 c4 25 11 f0    	mov    0xf01125c4,%edx
f0100365:	88 82 c0 23 11 f0    	mov    %al,-0xfeedc40(%edx)
f010036b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010036e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100373:	ba 00 00 00 00       	mov    $0x0,%edx
f0100378:	0f 44 c2             	cmove  %edx,%eax
f010037b:	a3 c4 25 11 f0       	mov    %eax,0xf01125c4
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
f01003a7:	83 3d a0 23 11 f0 00 	cmpl   $0x0,0xf01123a0
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
f01003ce:	8b 15 c0 25 11 f0    	mov    0xf01125c0,%edx
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
f01003d9:	3b 15 c4 25 11 f0    	cmp    0xf01125c4,%edx
f01003df:	74 1e                	je     f01003ff <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01003e1:	0f b6 82 c0 23 11 f0 	movzbl -0xfeedc40(%edx),%eax
f01003e8:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f01003eb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01003f6:	0f 44 d1             	cmove  %ecx,%edx
f01003f9:	89 15 c0 25 11 f0    	mov    %edx,0xf01125c0
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
f010048a:	ff 24 95 a0 1f 10 f0 	jmp    *-0xfefe060(,%edx,4)
	case '\b':
		if (crt_pos > 0) {
f0100491:	0f b7 15 ac 23 11 f0 	movzwl 0xf01123ac,%edx
f0100498:	66 85 d2             	test   %dx,%dx
f010049b:	0f 84 bb 01 00 00    	je     f010065c <cga_putc+0x1fe>
			crt_pos--;
f01004a1:	83 ea 01             	sub    $0x1,%edx
f01004a4:	66 89 15 ac 23 11 f0 	mov    %dx,0xf01123ac
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ab:	0f b7 d2             	movzwl %dx,%edx
f01004ae:	b0 00                	mov    $0x0,%al
f01004b0:	89 c1                	mov    %eax,%ecx
f01004b2:	83 c9 20             	or     $0x20,%ecx
f01004b5:	a1 a8 23 11 f0       	mov    0xf01123a8,%eax
f01004ba:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01004be:	e9 4c 01 00 00       	jmp    f010060f <cga_putc+0x1b1>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004c3:	66 83 05 ac 23 11 f0 	addw   $0x50,0xf01123ac
f01004ca:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004cb:	0f b7 05 ac 23 11 f0 	movzwl 0xf01123ac,%eax
f01004d2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d8:	c1 e8 16             	shr    $0x16,%eax
f01004db:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004de:	c1 e0 04             	shl    $0x4,%eax
f01004e1:	66 a3 ac 23 11 f0    	mov    %ax,0xf01123ac
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
f010052d:	0f b7 15 ac 23 11 f0 	movzwl 0xf01123ac,%edx
f0100534:	0f b7 da             	movzwl %dx,%ebx
f0100537:	80 e4 f0             	and    $0xf0,%ah
f010053a:	80 cc 0c             	or     $0xc,%ah
f010053d:	8b 0d a8 23 11 f0    	mov    0xf01123a8,%ecx
f0100543:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100547:	83 c2 01             	add    $0x1,%edx
f010054a:	66 89 15 ac 23 11 f0 	mov    %dx,0xf01123ac
		break;
f0100551:	e9 b9 00 00 00       	jmp    f010060f <cga_putc+0x1b1>
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0900;
f0100556:	0f b7 15 ac 23 11 f0 	movzwl 0xf01123ac,%edx
f010055d:	0f b7 da             	movzwl %dx,%ebx
f0100560:	80 e4 f0             	and    $0xf0,%ah
f0100563:	80 cc 09             	or     $0x9,%ah
f0100566:	8b 0d a8 23 11 f0    	mov    0xf01123a8,%ecx
f010056c:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100570:	83 c2 01             	add    $0x1,%edx
f0100573:	66 89 15 ac 23 11 f0 	mov    %dx,0xf01123ac
		break;
f010057a:	e9 90 00 00 00       	jmp    f010060f <cga_putc+0x1b1>
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0100;
f010057f:	0f b7 15 ac 23 11 f0 	movzwl 0xf01123ac,%edx
f0100586:	0f b7 da             	movzwl %dx,%ebx
f0100589:	80 e4 f0             	and    $0xf0,%ah
f010058c:	80 cc 01             	or     $0x1,%ah
f010058f:	8b 0d a8 23 11 f0    	mov    0xf01123a8,%ecx
f0100595:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100599:	83 c2 01             	add    $0x1,%edx
f010059c:	66 89 15 ac 23 11 f0 	mov    %dx,0xf01123ac
		break;
f01005a3:	eb 6a                	jmp    f010060f <cga_putc+0x1b1>
	case '%':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0e00;
f01005a5:	0f b7 15 ac 23 11 f0 	movzwl 0xf01123ac,%edx
f01005ac:	0f b7 da             	movzwl %dx,%ebx
f01005af:	80 e4 f0             	and    $0xf0,%ah
f01005b2:	80 cc 0e             	or     $0xe,%ah
f01005b5:	8b 0d a8 23 11 f0    	mov    0xf01123a8,%ecx
f01005bb:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005bf:	83 c2 01             	add    $0x1,%edx
f01005c2:	66 89 15 ac 23 11 f0 	mov    %dx,0xf01123ac
		break;
f01005c9:	eb 44                	jmp    f010060f <cga_putc+0x1b1>
	case '&':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0d00;
f01005cb:	0f b7 15 ac 23 11 f0 	movzwl 0xf01123ac,%edx
f01005d2:	0f b7 da             	movzwl %dx,%ebx
f01005d5:	80 e4 f0             	and    $0xf0,%ah
f01005d8:	80 cc 0d             	or     $0xd,%ah
f01005db:	8b 0d a8 23 11 f0    	mov    0xf01123a8,%ecx
f01005e1:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005e5:	83 c2 01             	add    $0x1,%edx
f01005e8:	66 89 15 ac 23 11 f0 	mov    %dx,0xf01123ac
		break;
f01005ef:	eb 1e                	jmp    f010060f <cga_putc+0x1b1>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005f1:	0f b7 15 ac 23 11 f0 	movzwl 0xf01123ac,%edx
f01005f8:	0f b7 da             	movzwl %dx,%ebx
f01005fb:	8b 0d a8 23 11 f0    	mov    0xf01123a8,%ecx
f0100601:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100605:	83 c2 01             	add    $0x1,%edx
f0100608:	66 89 15 ac 23 11 f0 	mov    %dx,0xf01123ac
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010060f:	66 81 3d ac 23 11 f0 	cmpw   $0x7cf,0xf01123ac
f0100616:	cf 07 
f0100618:	76 42                	jbe    f010065c <cga_putc+0x1fe>
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010061a:	a1 a8 23 11 f0       	mov    0xf01123a8,%eax
f010061f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100626:	00 
f0100627:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010062d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100631:	89 04 24             	mov    %eax,(%esp)
f0100634:	e8 61 14 00 00       	call   f0101a9a <memmove>
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0c00 | ' ';
f0100639:	8b 15 a8 23 11 f0    	mov    0xf01123a8,%edx
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
f0100654:	66 83 2d ac 23 11 f0 	subw   $0x50,0xf01123ac
f010065b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010065c:	8b 0d a4 23 11 f0    	mov    0xf01123a4,%ecx
f0100662:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100667:	89 ca                	mov    %ecx,%edx
f0100669:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010066a:	0f b7 35 ac 23 11 f0 	movzwl 0xf01123ac,%esi
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
f01006a1:	83 3d a0 23 11 f0 00 	cmpl   $0x0,0xf01123a0
f01006a8:	75 0c                	jne    f01006b6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01006aa:	c7 04 24 79 1f 10 f0 	movl   $0xf0101f79,(%esp)
f01006b1:	e8 a8 08 00 00       	call   f0100f5e <cprintf>
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

f01006f0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006f0:	55                   	push   %ebp
f01006f1:	89 e5                	mov    %esp,%ebp
f01006f3:	56                   	push   %esi
f01006f4:	53                   	push   %ebx
f01006f5:	83 ec 20             	sub    $0x20,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01006f8:	89 eb                	mov    %ebp,%ebx
f01006fa:	89 de                	mov    %ebx,%esi
	// Your code here.
	unsigned int ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f01006fc:	c7 04 24 90 23 10 f0 	movl   $0xf0102390,(%esp)
f0100703:	e8 56 08 00 00       	call   f0100f5e <cprintf>
	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f0100708:	85 db                	test   %ebx,%ebx
f010070a:	74 39                	je     f0100745 <mon_backtrace+0x55>
	{
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
f010070c:	8b 46 14             	mov    0x14(%esi),%eax
f010070f:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100713:	8b 46 10             	mov    0x10(%esi),%eax
f0100716:	89 44 24 14          	mov    %eax,0x14(%esp)
f010071a:	8b 46 0c             	mov    0xc(%esi),%eax
f010071d:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100721:	8b 46 08             	mov    0x8(%esi),%eax
f0100724:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100728:	8b 46 04             	mov    0x4(%esi),%eax
f010072b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010072f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100733:	c7 04 24 38 24 10 f0 	movl   $0xf0102438,(%esp)
f010073a:	e8 1f 08 00 00       	call   f0100f5e <cprintf>
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		ebp = *(unsigned int *)ebp;
f010073f:	8b 36                	mov    (%esi),%esi
{
	// Your code here.
	unsigned int ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f0100741:	85 f6                	test   %esi,%esi
f0100743:	75 c7                	jne    f010070c <mon_backtrace+0x1c>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		ebp = *(unsigned int *)ebp;
	}
	return 0;
}
f0100745:	b8 00 00 00 00       	mov    $0x0,%eax
f010074a:	83 c4 20             	add    $0x20,%esp
f010074d:	5b                   	pop    %ebx
f010074e:	5e                   	pop    %esi
f010074f:	5d                   	pop    %ebp
f0100750:	c3                   	ret    

f0100751 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100757:	c7 04 24 a2 23 10 f0 	movl   $0xf01023a2,(%esp)
f010075e:	e8 fb 07 00 00       	call   f0100f5e <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100763:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010076a:	00 
f010076b:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100772:	f0 
f0100773:	c7 04 24 68 24 10 f0 	movl   $0xf0102468,(%esp)
f010077a:	e8 df 07 00 00       	call   f0100f5e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010077f:	c7 44 24 08 15 1f 10 	movl   $0x101f15,0x8(%esp)
f0100786:	00 
f0100787:	c7 44 24 04 15 1f 10 	movl   $0xf0101f15,0x4(%esp)
f010078e:	f0 
f010078f:	c7 04 24 8c 24 10 f0 	movl   $0xf010248c,(%esp)
f0100796:	e8 c3 07 00 00       	call   f0100f5e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010079b:	c7 44 24 08 70 23 11 	movl   $0x112370,0x8(%esp)
f01007a2:	00 
f01007a3:	c7 44 24 04 70 23 11 	movl   $0xf0112370,0x4(%esp)
f01007aa:	f0 
f01007ab:	c7 04 24 b0 24 10 f0 	movl   $0xf01024b0,(%esp)
f01007b2:	e8 a7 07 00 00       	call   f0100f5e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007b7:	c7 44 24 08 10 2a 11 	movl   $0x112a10,0x8(%esp)
f01007be:	00 
f01007bf:	c7 44 24 04 10 2a 11 	movl   $0xf0112a10,0x4(%esp)
f01007c6:	f0 
f01007c7:	c7 04 24 d4 24 10 f0 	movl   $0xf01024d4,(%esp)
f01007ce:	e8 8b 07 00 00       	call   f0100f5e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f01007d3:	b8 0f 2e 11 f0       	mov    $0xf0112e0f,%eax
f01007d8:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007dd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007e3:	85 c0                	test   %eax,%eax
f01007e5:	0f 48 c2             	cmovs  %edx,%eax
f01007e8:	c1 f8 0a             	sar    $0xa,%eax
f01007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ef:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f01007f6:	e8 63 07 00 00       	call   f0100f5e <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f01007fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100800:	c9                   	leave  
f0100801:	c3                   	ret    

f0100802 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100802:	55                   	push   %ebp
f0100803:	89 e5                	mov    %esp,%ebp
f0100805:	53                   	push   %ebx
f0100806:	83 ec 14             	sub    $0x14,%esp
f0100809:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010080e:	8b 83 c4 25 10 f0    	mov    -0xfefda3c(%ebx),%eax
f0100814:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100818:	8b 83 c0 25 10 f0    	mov    -0xfefda40(%ebx),%eax
f010081e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100822:	c7 04 24 bb 23 10 f0 	movl   $0xf01023bb,(%esp)
f0100829:	e8 30 07 00 00       	call   f0100f5e <cprintf>
f010082e:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100831:	83 fb 24             	cmp    $0x24,%ebx
f0100834:	75 d8                	jne    f010080e <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100836:	b8 00 00 00 00       	mov    $0x0,%eax
f010083b:	83 c4 14             	add    $0x14,%esp
f010083e:	5b                   	pop    %ebx
f010083f:	5d                   	pop    %ebp
f0100840:	c3                   	ret    

f0100841 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100841:	55                   	push   %ebp
f0100842:	89 e5                	mov    %esp,%ebp
f0100844:	57                   	push   %edi
f0100845:	56                   	push   %esi
f0100846:	53                   	push   %ebx
f0100847:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010084a:	c7 04 24 24 25 10 f0 	movl   $0xf0102524,(%esp)
f0100851:	e8 08 07 00 00       	call   f0100f5e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100856:	c7 04 24 48 25 10 f0 	movl   $0xf0102548,(%esp)
f010085d:	e8 fc 06 00 00       	call   f0100f5e <cprintf>


	while (1) {
		buf = readline("K> ");
f0100862:	c7 04 24 c4 23 10 f0 	movl   $0xf01023c4,(%esp)
f0100869:	e8 92 0f 00 00       	call   f0101800 <readline>
f010086e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100870:	85 c0                	test   %eax,%eax
f0100872:	74 ee                	je     f0100862 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100874:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010087b:	be 00 00 00 00       	mov    $0x0,%esi
f0100880:	eb 06                	jmp    f0100888 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100882:	c6 03 00             	movb   $0x0,(%ebx)
f0100885:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100888:	0f b6 03             	movzbl (%ebx),%eax
f010088b:	84 c0                	test   %al,%al
f010088d:	74 6c                	je     f01008fb <monitor+0xba>
f010088f:	0f be c0             	movsbl %al,%eax
f0100892:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100896:	c7 04 24 c8 23 10 f0 	movl   $0xf01023c8,(%esp)
f010089d:	e8 79 11 00 00       	call   f0101a1b <strchr>
f01008a2:	85 c0                	test   %eax,%eax
f01008a4:	75 dc                	jne    f0100882 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f01008a6:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008a9:	74 50                	je     f01008fb <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008ab:	83 fe 0f             	cmp    $0xf,%esi
f01008ae:	66 90                	xchg   %ax,%ax
f01008b0:	75 16                	jne    f01008c8 <monitor+0x87>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008b2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008b9:	00 
f01008ba:	c7 04 24 cd 23 10 f0 	movl   $0xf01023cd,(%esp)
f01008c1:	e8 98 06 00 00       	call   f0100f5e <cprintf>
f01008c6:	eb 9a                	jmp    f0100862 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f01008c8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008cc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008cf:	0f b6 03             	movzbl (%ebx),%eax
f01008d2:	84 c0                	test   %al,%al
f01008d4:	75 0c                	jne    f01008e2 <monitor+0xa1>
f01008d6:	eb b0                	jmp    f0100888 <monitor+0x47>
			buf++;
f01008d8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008db:	0f b6 03             	movzbl (%ebx),%eax
f01008de:	84 c0                	test   %al,%al
f01008e0:	74 a6                	je     f0100888 <monitor+0x47>
f01008e2:	0f be c0             	movsbl %al,%eax
f01008e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e9:	c7 04 24 c8 23 10 f0 	movl   $0xf01023c8,(%esp)
f01008f0:	e8 26 11 00 00       	call   f0101a1b <strchr>
f01008f5:	85 c0                	test   %eax,%eax
f01008f7:	74 df                	je     f01008d8 <monitor+0x97>
f01008f9:	eb 8d                	jmp    f0100888 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f01008fb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100902:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100903:	85 f6                	test   %esi,%esi
f0100905:	0f 84 57 ff ff ff    	je     f0100862 <monitor+0x21>
f010090b:	bb c0 25 10 f0       	mov    $0xf01025c0,%ebx
f0100910:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100915:	8b 03                	mov    (%ebx),%eax
f0100917:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010091e:	89 04 24             	mov    %eax,(%esp)
f0100921:	e8 7a 10 00 00       	call   f01019a0 <strcmp>
f0100926:	85 c0                	test   %eax,%eax
f0100928:	75 24                	jne    f010094e <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f010092a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010092d:	8b 55 08             	mov    0x8(%ebp),%edx
f0100930:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100934:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100937:	89 54 24 04          	mov    %edx,0x4(%esp)
f010093b:	89 34 24             	mov    %esi,(%esp)
f010093e:	ff 14 85 c8 25 10 f0 	call   *-0xfefda38(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100945:	85 c0                	test   %eax,%eax
f0100947:	78 28                	js     f0100971 <monitor+0x130>
f0100949:	e9 14 ff ff ff       	jmp    f0100862 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010094e:	83 c7 01             	add    $0x1,%edi
f0100951:	83 c3 0c             	add    $0xc,%ebx
f0100954:	83 ff 03             	cmp    $0x3,%edi
f0100957:	75 bc                	jne    f0100915 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100959:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010095c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100960:	c7 04 24 ea 23 10 f0 	movl   $0xf01023ea,(%esp)
f0100967:	e8 f2 05 00 00       	call   f0100f5e <cprintf>
f010096c:	e9 f1 fe ff ff       	jmp    f0100862 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100971:	83 c4 5c             	add    $0x5c,%esp
f0100974:	5b                   	pop    %ebx
f0100975:	5e                   	pop    %esi
f0100976:	5f                   	pop    %edi
f0100977:	5d                   	pop    %ebp
f0100978:	c3                   	ret    

f0100979 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100979:	55                   	push   %ebp
f010097a:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010097c:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010097f:	5d                   	pop    %ebp
f0100980:	c3                   	ret    
f0100981:	00 00                	add    %al,(%eax)
	...

f0100984 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0100984:	55                   	push   %ebp
f0100985:	89 e5                	mov    %esp,%ebp
f0100987:	83 ec 18             	sub    $0x18,%esp
f010098a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010098d:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100990:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100992:	89 04 24             	mov    %eax,(%esp)
f0100995:	e8 56 05 00 00       	call   f0100ef0 <mc146818_read>
f010099a:	89 c6                	mov    %eax,%esi
f010099c:	83 c3 01             	add    $0x1,%ebx
f010099f:	89 1c 24             	mov    %ebx,(%esp)
f01009a2:	e8 49 05 00 00       	call   f0100ef0 <mc146818_read>
f01009a7:	c1 e0 08             	shl    $0x8,%eax
f01009aa:	09 f0                	or     %esi,%eax
}
f01009ac:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01009af:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01009b2:	89 ec                	mov    %ebp,%esp
f01009b4:	5d                   	pop    %ebp
f01009b5:	c3                   	ret    

f01009b6 <i386_detect_memory>:

void
i386_detect_memory(void)
{
f01009b6:	55                   	push   %ebp
f01009b7:	89 e5                	mov    %esp,%ebp
f01009b9:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f01009bc:	b8 15 00 00 00       	mov    $0x15,%eax
f01009c1:	e8 be ff ff ff       	call   f0100984 <nvram_read>
f01009c6:	c1 e0 0a             	shl    $0xa,%eax
f01009c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009ce:	a3 c8 25 11 f0       	mov    %eax,0xf01125c8
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f01009d3:	b8 17 00 00 00       	mov    $0x17,%eax
f01009d8:	e8 a7 ff ff ff       	call   f0100984 <nvram_read>
f01009dd:	c1 e0 0a             	shl    $0xa,%eax
f01009e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009e5:	a3 cc 25 11 f0       	mov    %eax,0xf01125cc

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f01009ea:	85 c0                	test   %eax,%eax
f01009ec:	74 0c                	je     f01009fa <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f01009ee:	05 00 00 10 00       	add    $0x100000,%eax
f01009f3:	a3 d0 25 11 f0       	mov    %eax,0xf01125d0
f01009f8:	eb 0a                	jmp    f0100a04 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f01009fa:	a1 c8 25 11 f0       	mov    0xf01125c8,%eax
f01009ff:	a3 d0 25 11 f0       	mov    %eax,0xf01125d0

	npage = maxpa / PGSIZE;
f0100a04:	a1 d0 25 11 f0       	mov    0xf01125d0,%eax
f0100a09:	89 c2                	mov    %eax,%edx
f0100a0b:	c1 ea 0c             	shr    $0xc,%edx
f0100a0e:	89 15 00 2a 11 f0    	mov    %edx,0xf0112a00

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100a14:	c1 e8 0a             	shr    $0xa,%eax
f0100a17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a1b:	c7 04 24 e4 25 10 f0 	movl   $0xf01025e4,(%esp)
f0100a22:	e8 37 05 00 00       	call   f0100f5e <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100a27:	a1 cc 25 11 f0       	mov    0xf01125cc,%eax
f0100a2c:	c1 e8 0a             	shr    $0xa,%eax
f0100a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a33:	a1 c8 25 11 f0       	mov    0xf01125c8,%eax
f0100a38:	c1 e8 0a             	shr    $0xa,%eax
f0100a3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a3f:	c7 04 24 35 26 10 f0 	movl   $0xf0102635,(%esp)
f0100a46:	e8 13 05 00 00       	call   f0100f5e <cprintf>
}
f0100a4b:	c9                   	leave  
f0100a4c:	c3                   	ret    

f0100a4d <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0100a4d:	55                   	push   %ebp
f0100a4e:	89 e5                	mov    %esp,%ebp
f0100a50:	83 ec 18             	sub    $0x18,%esp
	pde_t* pgdir;
	uint32_t cr0;
	size_t n;

	// Delete this line:
	panic("i386_vm_init: This function is not finished\n");
f0100a53:	c7 44 24 08 08 26 10 	movl   $0xf0102608,0x8(%esp)
f0100a5a:	f0 
f0100a5b:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
f0100a62:	00 
f0100a63:	c7 04 24 51 26 10 f0 	movl   $0xf0102651,(%esp)
f0100a6a:	e8 2a f6 ff ff       	call   f0100099 <_panic>

f0100a6f <page_init>:
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc()
//
void
page_init(void)
{
f0100a6f:	55                   	push   %ebp
f0100a70:	89 e5                	mov    %esp,%ebp
f0100a72:	56                   	push   %esi
f0100a73:	53                   	push   %ebx
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f0100a74:	c7 05 d4 25 11 f0 00 	movl   $0x0,0xf01125d4
f0100a7b:	00 00 00 
	for (i = 0; i < npage; i++) {
f0100a7e:	83 3d 00 2a 11 f0 00 	cmpl   $0x0,0xf0112a00
f0100a85:	74 5f                	je     f0100ae6 <page_init+0x77>
f0100a87:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a8c:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f0100a91:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0100a94:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
f0100a9b:	8b 1d 0c 2a 11 f0    	mov    0xf0112a0c,%ebx
f0100aa1:	66 c7 44 13 08 00 00 	movw   $0x0,0x8(%ebx,%edx,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100aa8:	8b 0d d4 25 11 f0    	mov    0xf01125d4,%ecx
f0100aae:	89 0c b3             	mov    %ecx,(%ebx,%esi,4)
f0100ab1:	85 c9                	test   %ecx,%ecx
f0100ab3:	74 11                	je     f0100ac6 <page_init+0x57>
f0100ab5:	8b 1d 0c 2a 11 f0    	mov    0xf0112a0c,%ebx
f0100abb:	01 d3                	add    %edx,%ebx
f0100abd:	8b 0d d4 25 11 f0    	mov    0xf01125d4,%ecx
f0100ac3:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100ac6:	03 15 0c 2a 11 f0    	add    0xf0112a0c,%edx
f0100acc:	89 15 d4 25 11 f0    	mov    %edx,0xf01125d4
f0100ad2:	c7 42 04 d4 25 11 f0 	movl   $0xf01125d4,0x4(%edx)
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0100ad9:	83 c0 01             	add    $0x1,%eax
f0100adc:	89 c2                	mov    %eax,%edx
f0100ade:	3b 05 00 2a 11 f0    	cmp    0xf0112a00,%eax
f0100ae4:	72 ab                	jb     f0100a91 <page_init+0x22>
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
}
f0100ae6:	5b                   	pop    %ebx
f0100ae7:	5e                   	pop    %esi
f0100ae8:	5d                   	pop    %ebp
f0100ae9:	c3                   	ret    

f0100aea <page_alloc>:
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented 
int
page_alloc(struct Page **pp_store)
{
f0100aea:	55                   	push   %ebp
f0100aeb:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return -E_NO_MEM;
}
f0100aed:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0100af2:	5d                   	pop    %ebp
f0100af3:	c3                   	ret    

f0100af4 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100af4:	55                   	push   %ebp
f0100af5:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100af7:	5d                   	pop    %ebp
f0100af8:	c3                   	ret    

f0100af9 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100af9:	55                   	push   %ebp
f0100afa:	89 e5                	mov    %esp,%ebp
f0100afc:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100aff:	66 83 68 08 01       	subw   $0x1,0x8(%eax)
		page_free(pp);
}
f0100b04:	5d                   	pop    %ebp
f0100b05:	c3                   	ret    

f0100b06 <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100b06:	55                   	push   %ebp
f0100b07:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100b09:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b0e:	5d                   	pop    %ebp
f0100b0f:	c3                   	ret    

f0100b10 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0100b10:	55                   	push   %ebp
f0100b11:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100b13:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b18:	5d                   	pop    %ebp
f0100b19:	c3                   	ret    

f0100b1a <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100b1a:	55                   	push   %ebp
f0100b1b:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100b1d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b22:	5d                   	pop    %ebp
f0100b23:	c3                   	ret    

f0100b24 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100b24:	55                   	push   %ebp
f0100b25:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0100b27:	5d                   	pop    %ebp
f0100b28:	c3                   	ret    

f0100b29 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100b29:	55                   	push   %ebp
f0100b2a:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b2f:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100b32:	5d                   	pop    %ebp
f0100b33:	c3                   	ret    

f0100b34 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0100b34:	55                   	push   %ebp
f0100b35:	89 e5                	mov    %esp,%ebp
f0100b37:	53                   	push   %ebx
f0100b38:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0100b3e:	85 c0                	test   %eax,%eax
f0100b40:	75 0e                	jne    f0100b50 <envid2env+0x1c>
		*env_store = curenv;
f0100b42:	a1 d8 25 11 f0       	mov    0xf01125d8,%eax
f0100b47:	89 01                	mov    %eax,(%ecx)
		return 0;
f0100b49:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b4e:	eb 54                	jmp    f0100ba4 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0100b50:	89 c2                	mov    %eax,%edx
f0100b52:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b58:	6b d2 64             	imul   $0x64,%edx,%edx
f0100b5b:	03 15 dc 25 11 f0    	add    0xf01125dc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0100b61:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0100b65:	74 05                	je     f0100b6c <envid2env+0x38>
f0100b67:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0100b6a:	74 0d                	je     f0100b79 <envid2env+0x45>
		*env_store = 0;
f0100b6c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0100b72:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0100b77:	eb 2b                	jmp    f0100ba4 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0100b79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100b7d:	74 1e                	je     f0100b9d <envid2env+0x69>
f0100b7f:	a1 d8 25 11 f0       	mov    0xf01125d8,%eax
f0100b84:	39 c2                	cmp    %eax,%edx
f0100b86:	74 15                	je     f0100b9d <envid2env+0x69>
f0100b88:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0100b8b:	39 5a 50             	cmp    %ebx,0x50(%edx)
f0100b8e:	74 0d                	je     f0100b9d <envid2env+0x69>
		*env_store = 0;
f0100b90:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0100b96:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0100b9b:	eb 07                	jmp    f0100ba4 <envid2env+0x70>
	}

	*env_store = e;
f0100b9d:	89 11                	mov    %edx,(%ecx)
	return 0;
f0100b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ba4:	5b                   	pop    %ebx
f0100ba5:	5d                   	pop    %ebp
f0100ba6:	c3                   	ret    

f0100ba7 <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f0100ba7:	55                   	push   %ebp
f0100ba8:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0100baa:	5d                   	pop    %ebp
f0100bab:	c3                   	ret    

f0100bac <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0100bac:	55                   	push   %ebp
f0100bad:	89 e5                	mov    %esp,%ebp
f0100baf:	53                   	push   %ebx
f0100bb0:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f0100bb3:	8b 1d e0 25 11 f0    	mov    0xf01125e0,%ebx
f0100bb9:	85 db                	test   %ebx,%ebx
f0100bbb:	0f 84 f8 00 00 00    	je     f0100cb9 <env_alloc+0x10d>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0100bc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f0100bc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100bcb:	89 04 24             	mov    %eax,(%esp)
f0100bce:	e8 17 ff ff ff       	call   f0100aea <page_alloc>
f0100bd3:	85 c0                	test   %eax,%eax
f0100bd5:	0f 88 e3 00 00 00    	js     f0100cbe <env_alloc+0x112>

	// LAB 3: Your code here.

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0100bdb:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0100bde:	8b 53 60             	mov    0x60(%ebx),%edx
f0100be1:	83 ca 03             	or     $0x3,%edx
f0100be4:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0100bea:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0100bed:	8b 53 60             	mov    0x60(%ebx),%edx
f0100bf0:	83 ca 05             	or     $0x5,%edx
f0100bf3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0100bf9:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0100bfc:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0100c01:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0100c06:	ba 00 10 00 00       	mov    $0x1000,%edx
f0100c0b:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0100c0e:	89 da                	mov    %ebx,%edx
f0100c10:	2b 15 dc 25 11 f0    	sub    0xf01125dc,%edx
f0100c16:	c1 fa 02             	sar    $0x2,%edx
f0100c19:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0100c1f:	09 d0                	or     %edx,%eax
f0100c21:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0100c24:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c27:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0100c2a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0100c31:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0100c38:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0100c3f:	00 
f0100c40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c47:	00 
f0100c48:	89 1c 24             	mov    %ebx,(%esp)
f0100c4b:	e8 26 0e 00 00       	call   f0101a76 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0100c50:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0100c56:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0100c5c:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0100c62:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0100c69:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0100c6f:	8b 43 44             	mov    0x44(%ebx),%eax
f0100c72:	85 c0                	test   %eax,%eax
f0100c74:	74 06                	je     f0100c7c <env_alloc+0xd0>
f0100c76:	8b 53 48             	mov    0x48(%ebx),%edx
f0100c79:	89 50 48             	mov    %edx,0x48(%eax)
f0100c7c:	8b 43 48             	mov    0x48(%ebx),%eax
f0100c7f:	8b 53 44             	mov    0x44(%ebx),%edx
f0100c82:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f0100c84:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c87:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0100c89:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0100c8c:	8b 15 d8 25 11 f0    	mov    0xf01125d8,%edx
f0100c92:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c97:	85 d2                	test   %edx,%edx
f0100c99:	74 03                	je     f0100c9e <env_alloc+0xf2>
f0100c9b:	8b 42 4c             	mov    0x4c(%edx),%eax
f0100c9e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ca6:	c7 04 24 5d 26 10 f0 	movl   $0xf010265d,(%esp)
f0100cad:	e8 ac 02 00 00       	call   f0100f5e <cprintf>
	return 0;
f0100cb2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb7:	eb 05                	jmp    f0100cbe <env_alloc+0x112>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
f0100cb9:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0100cbe:	83 c4 24             	add    $0x24,%esp
f0100cc1:	5b                   	pop    %ebx
f0100cc2:	5d                   	pop    %ebp
f0100cc3:	c3                   	ret    

f0100cc4 <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f0100cc4:	55                   	push   %ebp
f0100cc5:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0100cc7:	5d                   	pop    %ebp
f0100cc8:	c3                   	ret    

f0100cc9 <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0100cc9:	55                   	push   %ebp
f0100cca:	89 e5                	mov    %esp,%ebp
f0100ccc:	57                   	push   %edi
f0100ccd:	56                   	push   %esi
f0100cce:	53                   	push   %ebx
f0100ccf:	83 ec 2c             	sub    $0x2c,%esp
f0100cd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0100cd5:	a1 d8 25 11 f0       	mov    0xf01125d8,%eax
f0100cda:	39 c7                	cmp    %eax,%edi
f0100cdc:	75 09                	jne    f0100ce7 <env_free+0x1e>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100cde:	8b 15 04 2a 11 f0    	mov    0xf0112a04,%edx
f0100ce4:	0f 22 da             	mov    %edx,%cr3
		lcr3(boot_cr3);

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0100ce7:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0100cea:	ba 00 00 00 00       	mov    $0x0,%edx
f0100cef:	85 c0                	test   %eax,%eax
f0100cf1:	74 03                	je     f0100cf6 <env_free+0x2d>
f0100cf3:	8b 50 4c             	mov    0x4c(%eax),%edx
f0100cf6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100cfa:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cfe:	c7 04 24 72 26 10 f0 	movl   $0xf0102672,(%esp)
f0100d05:	e8 54 02 00 00       	call   f0100f5e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0100d0a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0100d11:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d14:	c1 e0 02             	shl    $0x2,%eax
f0100d17:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d1a:	8b 47 5c             	mov    0x5c(%edi),%eax
f0100d1d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d20:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0100d23:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0100d29:	0f 84 bb 00 00 00    	je     f0100dea <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0100d2f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0100d35:	89 f0                	mov    %esi,%eax
f0100d37:	c1 e8 0c             	shr    $0xc,%eax
f0100d3a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100d3d:	3b 05 00 2a 11 f0    	cmp    0xf0112a00,%eax
f0100d43:	72 20                	jb     f0100d65 <env_free+0x9c>
f0100d45:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100d49:	c7 44 24 08 cc 26 10 	movl   $0xf01026cc,0x8(%esp)
f0100d50:	f0 
f0100d51:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0100d58:	00 
f0100d59:	c7 04 24 88 26 10 f0 	movl   $0xf0102688,(%esp)
f0100d60:	e8 34 f3 ff ff       	call   f0100099 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0100d65:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d68:	c1 e2 16             	shl    $0x16,%edx
f0100d6b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0100d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0100d73:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0100d7a:	01 
f0100d7b:	74 17                	je     f0100d94 <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0100d7d:	89 d8                	mov    %ebx,%eax
f0100d7f:	c1 e0 0c             	shl    $0xc,%eax
f0100d82:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0100d85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d89:	8b 47 5c             	mov    0x5c(%edi),%eax
f0100d8c:	89 04 24             	mov    %eax,(%esp)
f0100d8f:	e8 90 fd ff ff       	call   f0100b24 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0100d94:	83 c3 01             	add    $0x1,%ebx
f0100d97:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100d9d:	75 d4                	jne    f0100d73 <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0100d9f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0100da2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100da5:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100dac:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100daf:	3b 05 00 2a 11 f0    	cmp    0xf0112a00,%eax
f0100db5:	72 1c                	jb     f0100dd3 <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0100db7:	c7 44 24 08 f0 26 10 	movl   $0xf01026f0,0x8(%esp)
f0100dbe:	f0 
f0100dbf:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0100dc6:	00 
f0100dc7:	c7 04 24 93 26 10 f0 	movl   $0xf0102693,(%esp)
f0100dce:	e8 c6 f2 ff ff       	call   f0100099 <_panic>
	return &pages[PPN(pa)];
f0100dd3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dd6:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100dd9:	c1 e0 02             	shl    $0x2,%eax
f0100ddc:	03 05 0c 2a 11 f0    	add    0xf0112a0c,%eax
		page_decref(pa2page(pa));
f0100de2:	89 04 24             	mov    %eax,(%esp)
f0100de5:	e8 0f fd ff ff       	call   f0100af9 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0100dea:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0100dee:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0100df5:	0f 85 16 ff ff ff    	jne    f0100d11 <env_free+0x48>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0100dfb:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0100dfe:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0100e05:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100e0c:	c1 e8 0c             	shr    $0xc,%eax
f0100e0f:	3b 05 00 2a 11 f0    	cmp    0xf0112a00,%eax
f0100e15:	72 1c                	jb     f0100e33 <env_free+0x16a>
		panic("pa2page called with invalid pa");
f0100e17:	c7 44 24 08 f0 26 10 	movl   $0xf01026f0,0x8(%esp)
f0100e1e:	f0 
f0100e1f:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0100e26:	00 
f0100e27:	c7 04 24 93 26 10 f0 	movl   $0xf0102693,(%esp)
f0100e2e:	e8 66 f2 ff ff       	call   f0100099 <_panic>
	return &pages[PPN(pa)];
f0100e33:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100e36:	c1 e0 02             	shl    $0x2,%eax
f0100e39:	03 05 0c 2a 11 f0    	add    0xf0112a0c,%eax
	page_decref(pa2page(pa));
f0100e3f:	89 04 24             	mov    %eax,(%esp)
f0100e42:	e8 b2 fc ff ff       	call   f0100af9 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0100e47:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0100e4e:	a1 e0 25 11 f0       	mov    0xf01125e0,%eax
f0100e53:	89 47 44             	mov    %eax,0x44(%edi)
f0100e56:	85 c0                	test   %eax,%eax
f0100e58:	74 06                	je     f0100e60 <env_free+0x197>
f0100e5a:	8d 57 44             	lea    0x44(%edi),%edx
f0100e5d:	89 50 48             	mov    %edx,0x48(%eax)
f0100e60:	89 3d e0 25 11 f0    	mov    %edi,0xf01125e0
f0100e66:	c7 47 48 e0 25 11 f0 	movl   $0xf01125e0,0x48(%edi)
}
f0100e6d:	83 c4 2c             	add    $0x2c,%esp
f0100e70:	5b                   	pop    %ebx
f0100e71:	5e                   	pop    %esi
f0100e72:	5f                   	pop    %edi
f0100e73:	5d                   	pop    %ebp
f0100e74:	c3                   	ret    

f0100e75 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0100e75:	55                   	push   %ebp
f0100e76:	89 e5                	mov    %esp,%ebp
f0100e78:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0100e7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e7e:	89 04 24             	mov    %eax,(%esp)
f0100e81:	e8 43 fe ff ff       	call   f0100cc9 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0100e86:	c7 04 24 10 27 10 f0 	movl   $0xf0102710,(%esp)
f0100e8d:	e8 cc 00 00 00       	call   f0100f5e <cprintf>
	while (1)
		monitor(NULL);
f0100e92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100e99:	e8 a3 f9 ff ff       	call   f0100841 <monitor>
f0100e9e:	eb f2                	jmp    f0100e92 <env_destroy+0x1d>

f0100ea0 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0100ea0:	55                   	push   %ebp
f0100ea1:	89 e5                	mov    %esp,%ebp
f0100ea3:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0100ea6:	8b 65 08             	mov    0x8(%ebp),%esp
f0100ea9:	61                   	popa   
f0100eaa:	07                   	pop    %es
f0100eab:	1f                   	pop    %ds
f0100eac:	83 c4 08             	add    $0x8,%esp
f0100eaf:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0100eb0:	c7 44 24 08 a1 26 10 	movl   $0xf01026a1,0x8(%esp)
f0100eb7:	f0 
f0100eb8:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0100ebf:	00 
f0100ec0:	c7 04 24 88 26 10 f0 	movl   $0xf0102688,(%esp)
f0100ec7:	e8 cd f1 ff ff       	call   f0100099 <_panic>

f0100ecc <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0100ecc:	55                   	push   %ebp
f0100ecd:	89 e5                	mov    %esp,%ebp
f0100ecf:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.

        panic("env_run not yet implemented");
f0100ed2:	c7 44 24 08 ad 26 10 	movl   $0xf01026ad,0x8(%esp)
f0100ed9:	f0 
f0100eda:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f0100ee1:	00 
f0100ee2:	c7 04 24 88 26 10 f0 	movl   $0xf0102688,(%esp)
f0100ee9:	e8 ab f1 ff ff       	call   f0100099 <_panic>
	...

f0100ef0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100ef0:	55                   	push   %ebp
f0100ef1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ef3:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ef8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100efb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100efc:	b2 71                	mov    $0x71,%dl
f0100efe:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100eff:	0f b6 c0             	movzbl %al,%eax
}
f0100f02:	5d                   	pop    %ebp
f0100f03:	c3                   	ret    

f0100f04 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100f04:	55                   	push   %ebp
f0100f05:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100f07:	ba 70 00 00 00       	mov    $0x70,%edx
f0100f0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f0f:	ee                   	out    %al,(%dx)
f0100f10:	b2 71                	mov    $0x71,%dl
f0100f12:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f15:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100f16:	5d                   	pop    %ebp
f0100f17:	c3                   	ret    

f0100f18 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100f18:	55                   	push   %ebp
f0100f19:	89 e5                	mov    %esp,%ebp
f0100f1b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100f1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f21:	89 04 24             	mov    %eax,(%esp)
f0100f24:	e8 8f f7 ff ff       	call   f01006b8 <cputchar>
	*cnt++;
}
f0100f29:	c9                   	leave  
f0100f2a:	c3                   	ret    

f0100f2b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100f2b:	55                   	push   %ebp
f0100f2c:	89 e5                	mov    %esp,%ebp
f0100f2e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100f31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100f38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f42:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f46:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f4d:	c7 04 24 18 0f 10 f0 	movl   $0xf0100f18,(%esp)
f0100f54:	e8 6b 04 00 00       	call   f01013c4 <vprintfmt>
	return cnt;
}
f0100f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f5c:	c9                   	leave  
f0100f5d:	c3                   	ret    

f0100f5e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100f5e:	55                   	push   %ebp
f0100f5f:	89 e5                	mov    %esp,%ebp
f0100f61:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100f64:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100f67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f6e:	89 04 24             	mov    %eax,(%esp)
f0100f71:	e8 b5 ff ff ff       	call   f0100f2b <vcprintf>
	va_end(ap);

	return cnt;
}
f0100f76:	c9                   	leave  
f0100f77:	c3                   	ret    

f0100f78 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100f78:	55                   	push   %ebp
f0100f79:	89 e5                	mov    %esp,%ebp
f0100f7b:	57                   	push   %edi
f0100f7c:	56                   	push   %esi
f0100f7d:	53                   	push   %ebx
f0100f7e:	83 ec 10             	sub    $0x10,%esp
f0100f81:	89 c3                	mov    %eax,%ebx
f0100f83:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100f86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f89:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100f8c:	8b 0a                	mov    (%edx),%ecx
f0100f8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f91:	8b 00                	mov    (%eax),%eax
f0100f93:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f96:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	
	while (l <= r) {
f0100f9d:	eb 77                	jmp    f0101016 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0100f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100fa2:	01 c8                	add    %ecx,%eax
f0100fa4:	bf 02 00 00 00       	mov    $0x2,%edi
f0100fa9:	99                   	cltd   
f0100faa:	f7 ff                	idiv   %edi
f0100fac:	89 c2                	mov    %eax,%edx
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100fae:	eb 01                	jmp    f0100fb1 <stab_binsearch+0x39>
			m--;
f0100fb0:	4a                   	dec    %edx
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100fb1:	39 ca                	cmp    %ecx,%edx
f0100fb3:	7c 1d                	jl     f0100fd2 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100fb5:	6b fa 0c             	imul   $0xc,%edx,%edi
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100fb8:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100fbd:	39 f7                	cmp    %esi,%edi
f0100fbf:	75 ef                	jne    f0100fb0 <stab_binsearch+0x38>
f0100fc1:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100fc4:	6b fa 0c             	imul   $0xc,%edx,%edi
f0100fc7:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100fcb:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100fce:	73 18                	jae    f0100fe8 <stab_binsearch+0x70>
f0100fd0:	eb 05                	jmp    f0100fd7 <stab_binsearch+0x5f>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100fd2:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0100fd5:	eb 3f                	jmp    f0101016 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100fd7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100fda:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0100fdc:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100fdf:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100fe6:	eb 2e                	jmp    f0101016 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100fe8:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100feb:	76 15                	jbe    f0101002 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0100fed:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100ff0:	4f                   	dec    %edi
f0100ff1:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0100ff4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ff7:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100ff9:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101000:	eb 14                	jmp    f0101016 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101002:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0101005:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101008:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f010100a:	ff 45 0c             	incl   0xc(%ebp)
f010100d:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010100f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0101016:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0101019:	7e 84                	jle    f0100f9f <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010101b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010101f:	75 0d                	jne    f010102e <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0101021:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101024:	8b 02                	mov    (%edx),%eax
f0101026:	48                   	dec    %eax
f0101027:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010102a:	89 01                	mov    %eax,(%ecx)
f010102c:	eb 22                	jmp    f0101050 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010102e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101031:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0101033:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101036:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101038:	eb 01                	jmp    f010103b <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010103a:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010103b:	39 c1                	cmp    %eax,%ecx
f010103d:	7d 0c                	jge    f010104b <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010103f:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0101042:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0101047:	39 f2                	cmp    %esi,%edx
f0101049:	75 ef                	jne    f010103a <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f010104b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010104e:	89 02                	mov    %eax,(%edx)
	}
}
f0101050:	83 c4 10             	add    $0x10,%esp
f0101053:	5b                   	pop    %ebx
f0101054:	5e                   	pop    %esi
f0101055:	5f                   	pop    %edi
f0101056:	5d                   	pop    %ebp
f0101057:	c3                   	ret    

f0101058 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101058:	55                   	push   %ebp
f0101059:	89 e5                	mov    %esp,%ebp
f010105b:	83 ec 38             	sub    $0x38,%esp
f010105e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101061:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101064:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101067:	8b 75 08             	mov    0x8(%ebp),%esi
f010106a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010106d:	c7 03 48 27 10 f0    	movl   $0xf0102748,(%ebx)
	info->eip_line = 0;
f0101073:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010107a:	c7 43 08 48 27 10 f0 	movl   $0xf0102748,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101081:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101088:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010108b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101092:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101098:	76 12                	jbe    f01010ac <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010109a:	b8 85 97 10 f0       	mov    $0xf0109785,%eax
f010109f:	3d 31 73 10 f0       	cmp    $0xf0107331,%eax
f01010a4:	0f 86 6c 01 00 00    	jbe    f0101216 <debuginfo_eip+0x1be>
f01010aa:	eb 1c                	jmp    f01010c8 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01010ac:	c7 44 24 08 52 27 10 	movl   $0xf0102752,0x8(%esp)
f01010b3:	f0 
f01010b4:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
f01010bb:	00 
f01010bc:	c7 04 24 5f 27 10 f0 	movl   $0xf010275f,(%esp)
f01010c3:	e8 d1 ef ff ff       	call   f0100099 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01010c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01010cd:	80 3d 84 97 10 f0 00 	cmpb   $0x0,0xf0109784
f01010d4:	0f 85 48 01 00 00    	jne    f0101222 <debuginfo_eip+0x1ca>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01010da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01010e1:	b8 30 73 10 f0       	mov    $0xf0107330,%eax
f01010e6:	2d 80 29 10 f0       	sub    $0xf0102980,%eax
f01010eb:	c1 f8 02             	sar    $0x2,%eax
f01010ee:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01010f4:	83 e8 01             	sub    $0x1,%eax
f01010f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01010fa:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010fe:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0101105:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101108:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010110b:	b8 80 29 10 f0       	mov    $0xf0102980,%eax
f0101110:	e8 63 fe ff ff       	call   f0100f78 <stab_binsearch>
	if (lfile == 0)
f0101115:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0101118:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010111d:	85 d2                	test   %edx,%edx
f010111f:	0f 84 fd 00 00 00    	je     f0101222 <debuginfo_eip+0x1ca>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0101125:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0101128:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010112b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010112e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101132:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0101139:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010113c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010113f:	b8 80 29 10 f0       	mov    $0xf0102980,%eax
f0101144:	e8 2f fe ff ff       	call   f0100f78 <stab_binsearch>

	if (lfun <= rfun) {
f0101149:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010114c:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f010114f:	7f 2e                	jg     f010117f <debuginfo_eip+0x127>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101151:	6b c7 0c             	imul   $0xc,%edi,%eax
f0101154:	8d 90 80 29 10 f0    	lea    -0xfefd680(%eax),%edx
f010115a:	8b 80 80 29 10 f0    	mov    -0xfefd680(%eax),%eax
f0101160:	b9 85 97 10 f0       	mov    $0xf0109785,%ecx
f0101165:	81 e9 31 73 10 f0    	sub    $0xf0107331,%ecx
f010116b:	39 c8                	cmp    %ecx,%eax
f010116d:	73 08                	jae    f0101177 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010116f:	05 31 73 10 f0       	add    $0xf0107331,%eax
f0101174:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0101177:	8b 42 08             	mov    0x8(%edx),%eax
f010117a:	89 43 10             	mov    %eax,0x10(%ebx)
f010117d:	eb 06                	jmp    f0101185 <debuginfo_eip+0x12d>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010117f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101182:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101185:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010118c:	00 
f010118d:	8b 43 08             	mov    0x8(%ebx),%eax
f0101190:	89 04 24             	mov    %eax,(%esp)
f0101193:	e8 b7 08 00 00       	call   f0101a4f <strfind>
f0101198:	2b 43 08             	sub    0x8(%ebx),%eax
f010119b:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010119e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f01011a1:	b8 00 00 00 00       	mov    $0x0,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01011a6:	39 d7                	cmp    %edx,%edi
f01011a8:	7c 78                	jl     f0101222 <debuginfo_eip+0x1ca>
	       && stabs[lline].n_type != N_SOL
f01011aa:	89 f8                	mov    %edi,%eax
f01011ac:	6b cf 0c             	imul   $0xc,%edi,%ecx
f01011af:	80 b9 84 29 10 f0 84 	cmpb   $0x84,-0xfefd67c(%ecx)
f01011b6:	75 18                	jne    f01011d0 <debuginfo_eip+0x178>
f01011b8:	eb 35                	jmp    f01011ef <debuginfo_eip+0x197>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01011ba:	83 ef 01             	sub    $0x1,%edi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01011bd:	39 d7                	cmp    %edx,%edi
f01011bf:	7c 5c                	jl     f010121d <debuginfo_eip+0x1c5>
	       && stabs[lline].n_type != N_SOL
f01011c1:	89 f8                	mov    %edi,%eax
f01011c3:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f01011c6:	80 3c 8d 84 29 10 f0 	cmpb   $0x84,-0xfefd67c(,%ecx,4)
f01011cd:	84 
f01011ce:	74 1f                	je     f01011ef <debuginfo_eip+0x197>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01011d0:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01011d3:	8d 04 85 80 29 10 f0 	lea    -0xfefd680(,%eax,4),%eax
f01011da:	80 78 04 64          	cmpb   $0x64,0x4(%eax)
f01011de:	75 da                	jne    f01011ba <debuginfo_eip+0x162>
f01011e0:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01011e4:	74 d4                	je     f01011ba <debuginfo_eip+0x162>
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f01011e6:	b8 00 00 00 00       	mov    $0x0,%eax
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01011eb:	39 d7                	cmp    %edx,%edi
f01011ed:	7c 33                	jl     f0101222 <debuginfo_eip+0x1ca>
f01011ef:	6b ff 0c             	imul   $0xc,%edi,%edi
f01011f2:	8b 97 80 29 10 f0    	mov    -0xfefd680(%edi),%edx
f01011f8:	b9 85 97 10 f0       	mov    $0xf0109785,%ecx
f01011fd:	81 e9 31 73 10 f0    	sub    $0xf0107331,%ecx
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f0101203:	b8 00 00 00 00       	mov    $0x0,%eax
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101208:	39 ca                	cmp    %ecx,%edx
f010120a:	73 16                	jae    f0101222 <debuginfo_eip+0x1ca>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010120c:	81 c2 31 73 10 f0    	add    $0xf0107331,%edx
f0101212:	89 13                	mov    %edx,(%ebx)
f0101214:	eb 0c                	jmp    f0101222 <debuginfo_eip+0x1ca>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010121b:	eb 05                	jmp    f0101222 <debuginfo_eip+0x1ca>
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f010121d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101222:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101225:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101228:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010122b:	89 ec                	mov    %ebp,%esp
f010122d:	5d                   	pop    %ebp
f010122e:	c3                   	ret    
	...

f0101230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101230:	55                   	push   %ebp
f0101231:	89 e5                	mov    %esp,%ebp
f0101233:	57                   	push   %edi
f0101234:	56                   	push   %esi
f0101235:	53                   	push   %ebx
f0101236:	83 ec 3c             	sub    $0x3c,%esp
f0101239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010123c:	89 d7                	mov    %edx,%edi
f010123e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101241:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101244:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101247:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010124a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010124d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101250:	b8 00 00 00 00       	mov    $0x0,%eax
f0101255:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0101258:	72 11                	jb     f010126b <printnum+0x3b>
f010125a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010125d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0101260:	76 09                	jbe    f010126b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101262:	83 eb 01             	sub    $0x1,%ebx
f0101265:	85 db                	test   %ebx,%ebx
f0101267:	7f 51                	jg     f01012ba <printnum+0x8a>
f0101269:	eb 5e                	jmp    f01012c9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010126b:	89 74 24 10          	mov    %esi,0x10(%esp)
f010126f:	83 eb 01             	sub    $0x1,%ebx
f0101272:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101276:	8b 45 10             	mov    0x10(%ebp),%eax
f0101279:	89 44 24 08          	mov    %eax,0x8(%esp)
f010127d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0101281:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0101285:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010128c:	00 
f010128d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101290:	89 04 24             	mov    %eax,(%esp)
f0101293:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101296:	89 44 24 04          	mov    %eax,0x4(%esp)
f010129a:	e8 d1 09 00 00       	call   f0101c70 <__udivdi3>
f010129f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01012a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01012a7:	89 04 24             	mov    %eax,(%esp)
f01012aa:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012ae:	89 fa                	mov    %edi,%edx
f01012b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012b3:	e8 78 ff ff ff       	call   f0101230 <printnum>
f01012b8:	eb 0f                	jmp    f01012c9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01012ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012be:	89 34 24             	mov    %esi,(%esp)
f01012c1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01012c4:	83 eb 01             	sub    $0x1,%ebx
f01012c7:	75 f1                	jne    f01012ba <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01012c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012cd:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01012d1:	8b 45 10             	mov    0x10(%ebp),%eax
f01012d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01012df:	00 
f01012e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01012e3:	89 04 24             	mov    %eax,(%esp)
f01012e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012ed:	e8 ae 0a 00 00       	call   f0101da0 <__umoddi3>
f01012f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012f6:	0f be 80 6d 27 10 f0 	movsbl -0xfefd893(%eax),%eax
f01012fd:	89 04 24             	mov    %eax,(%esp)
f0101300:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0101303:	83 c4 3c             	add    $0x3c,%esp
f0101306:	5b                   	pop    %ebx
f0101307:	5e                   	pop    %esi
f0101308:	5f                   	pop    %edi
f0101309:	5d                   	pop    %ebp
f010130a:	c3                   	ret    

f010130b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010130b:	55                   	push   %ebp
f010130c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010130e:	83 fa 01             	cmp    $0x1,%edx
f0101311:	7e 0e                	jle    f0101321 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101313:	8b 10                	mov    (%eax),%edx
f0101315:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101318:	89 08                	mov    %ecx,(%eax)
f010131a:	8b 02                	mov    (%edx),%eax
f010131c:	8b 52 04             	mov    0x4(%edx),%edx
f010131f:	eb 22                	jmp    f0101343 <getuint+0x38>
	else if (lflag)
f0101321:	85 d2                	test   %edx,%edx
f0101323:	74 10                	je     f0101335 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101325:	8b 10                	mov    (%eax),%edx
f0101327:	8d 4a 04             	lea    0x4(%edx),%ecx
f010132a:	89 08                	mov    %ecx,(%eax)
f010132c:	8b 02                	mov    (%edx),%eax
f010132e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101333:	eb 0e                	jmp    f0101343 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101335:	8b 10                	mov    (%eax),%edx
f0101337:	8d 4a 04             	lea    0x4(%edx),%ecx
f010133a:	89 08                	mov    %ecx,(%eax)
f010133c:	8b 02                	mov    (%edx),%eax
f010133e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101343:	5d                   	pop    %ebp
f0101344:	c3                   	ret    

f0101345 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0101345:	55                   	push   %ebp
f0101346:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101348:	83 fa 01             	cmp    $0x1,%edx
f010134b:	7e 0e                	jle    f010135b <getint+0x16>
		return va_arg(*ap, long long);
f010134d:	8b 10                	mov    (%eax),%edx
f010134f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101352:	89 08                	mov    %ecx,(%eax)
f0101354:	8b 02                	mov    (%edx),%eax
f0101356:	8b 52 04             	mov    0x4(%edx),%edx
f0101359:	eb 22                	jmp    f010137d <getint+0x38>
	else if (lflag)
f010135b:	85 d2                	test   %edx,%edx
f010135d:	74 10                	je     f010136f <getint+0x2a>
		return va_arg(*ap, long);
f010135f:	8b 10                	mov    (%eax),%edx
f0101361:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101364:	89 08                	mov    %ecx,(%eax)
f0101366:	8b 02                	mov    (%edx),%eax
f0101368:	89 c2                	mov    %eax,%edx
f010136a:	c1 fa 1f             	sar    $0x1f,%edx
f010136d:	eb 0e                	jmp    f010137d <getint+0x38>
	else
		return va_arg(*ap, int);
f010136f:	8b 10                	mov    (%eax),%edx
f0101371:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101374:	89 08                	mov    %ecx,(%eax)
f0101376:	8b 02                	mov    (%edx),%eax
f0101378:	89 c2                	mov    %eax,%edx
f010137a:	c1 fa 1f             	sar    $0x1f,%edx
}
f010137d:	5d                   	pop    %ebp
f010137e:	c3                   	ret    

f010137f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010137f:	55                   	push   %ebp
f0101380:	89 e5                	mov    %esp,%ebp
f0101382:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101385:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101389:	8b 10                	mov    (%eax),%edx
f010138b:	3b 50 04             	cmp    0x4(%eax),%edx
f010138e:	73 0a                	jae    f010139a <sprintputch+0x1b>
		*b->buf++ = ch;
f0101390:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101393:	88 0a                	mov    %cl,(%edx)
f0101395:	83 c2 01             	add    $0x1,%edx
f0101398:	89 10                	mov    %edx,(%eax)
}
f010139a:	5d                   	pop    %ebp
f010139b:	c3                   	ret    

f010139c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010139c:	55                   	push   %ebp
f010139d:	89 e5                	mov    %esp,%ebp
f010139f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01013a2:	8d 45 14             	lea    0x14(%ebp),%eax
f01013a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013a9:	8b 45 10             	mov    0x10(%ebp),%eax
f01013ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ba:	89 04 24             	mov    %eax,(%esp)
f01013bd:	e8 02 00 00 00       	call   f01013c4 <vprintfmt>
	va_end(ap);
}
f01013c2:	c9                   	leave  
f01013c3:	c3                   	ret    

f01013c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01013c4:	55                   	push   %ebp
f01013c5:	89 e5                	mov    %esp,%ebp
f01013c7:	57                   	push   %edi
f01013c8:	56                   	push   %esi
f01013c9:	53                   	push   %ebx
f01013ca:	83 ec 4c             	sub    $0x4c,%esp
f01013cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01013d0:	8b 75 10             	mov    0x10(%ebp),%esi
f01013d3:	eb 12                	jmp    f01013e7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01013d5:	85 c0                	test   %eax,%eax
f01013d7:	0f 84 98 03 00 00    	je     f0101775 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f01013dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013e1:	89 04 24             	mov    %eax,(%esp)
f01013e4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013e7:	0f b6 06             	movzbl (%esi),%eax
f01013ea:	83 c6 01             	add    $0x1,%esi
f01013ed:	83 f8 25             	cmp    $0x25,%eax
f01013f0:	75 e3                	jne    f01013d5 <vprintfmt+0x11>
f01013f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01013f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01013fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0101402:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0101409:	b9 00 00 00 00       	mov    $0x0,%ecx
f010140e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101411:	eb 2b                	jmp    f010143e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101413:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101416:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f010141a:	eb 22                	jmp    f010143e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010141c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010141f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0101423:	eb 19                	jmp    f010143e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101425:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0101428:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010142f:	eb 0d                	jmp    f010143e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101431:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101437:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010143e:	0f b6 06             	movzbl (%esi),%eax
f0101441:	0f b6 d0             	movzbl %al,%edx
f0101444:	8d 7e 01             	lea    0x1(%esi),%edi
f0101447:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010144a:	83 e8 23             	sub    $0x23,%eax
f010144d:	3c 55                	cmp    $0x55,%al
f010144f:	0f 87 fa 02 00 00    	ja     f010174f <vprintfmt+0x38b>
f0101455:	0f b6 c0             	movzbl %al,%eax
f0101458:	ff 24 85 fc 27 10 f0 	jmp    *-0xfefd804(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010145f:	83 ea 30             	sub    $0x30,%edx
f0101462:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0101465:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0101469:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010146c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f010146f:	83 fa 09             	cmp    $0x9,%edx
f0101472:	77 4a                	ja     f01014be <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101474:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101477:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f010147a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010147d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0101481:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0101484:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101487:	83 fa 09             	cmp    $0x9,%edx
f010148a:	76 eb                	jbe    f0101477 <vprintfmt+0xb3>
f010148c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010148f:	eb 2d                	jmp    f01014be <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101491:	8b 45 14             	mov    0x14(%ebp),%eax
f0101494:	8d 50 04             	lea    0x4(%eax),%edx
f0101497:	89 55 14             	mov    %edx,0x14(%ebp)
f010149a:	8b 00                	mov    (%eax),%eax
f010149c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010149f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01014a2:	eb 1a                	jmp    f01014be <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01014a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f01014a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014ab:	79 91                	jns    f010143e <vprintfmt+0x7a>
f01014ad:	e9 73 ff ff ff       	jmp    f0101425 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01014b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01014b5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01014bc:	eb 80                	jmp    f010143e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f01014be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014c2:	0f 89 76 ff ff ff    	jns    f010143e <vprintfmt+0x7a>
f01014c8:	e9 64 ff ff ff       	jmp    f0101431 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01014cd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01014d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01014d3:	e9 66 ff ff ff       	jmp    f010143e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01014d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01014db:	8d 50 04             	lea    0x4(%eax),%edx
f01014de:	89 55 14             	mov    %edx,0x14(%ebp)
f01014e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014e5:	8b 00                	mov    (%eax),%eax
f01014e7:	89 04 24             	mov    %eax,(%esp)
f01014ea:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01014ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01014f0:	e9 f2 fe ff ff       	jmp    f01013e7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01014f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01014f8:	8d 50 04             	lea    0x4(%eax),%edx
f01014fb:	89 55 14             	mov    %edx,0x14(%ebp)
f01014fe:	8b 00                	mov    (%eax),%eax
f0101500:	89 c2                	mov    %eax,%edx
f0101502:	c1 fa 1f             	sar    $0x1f,%edx
f0101505:	31 d0                	xor    %edx,%eax
f0101507:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0101509:	83 f8 06             	cmp    $0x6,%eax
f010150c:	7f 0b                	jg     f0101519 <vprintfmt+0x155>
f010150e:	8b 14 85 54 29 10 f0 	mov    -0xfefd6ac(,%eax,4),%edx
f0101515:	85 d2                	test   %edx,%edx
f0101517:	75 23                	jne    f010153c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0101519:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010151d:	c7 44 24 08 85 27 10 	movl   $0xf0102785,0x8(%esp)
f0101524:	f0 
f0101525:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101529:	8b 7d 08             	mov    0x8(%ebp),%edi
f010152c:	89 3c 24             	mov    %edi,(%esp)
f010152f:	e8 68 fe ff ff       	call   f010139c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101534:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101537:	e9 ab fe ff ff       	jmp    f01013e7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f010153c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101540:	c7 44 24 08 8e 27 10 	movl   $0xf010278e,0x8(%esp)
f0101547:	f0 
f0101548:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010154c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010154f:	89 3c 24             	mov    %edi,(%esp)
f0101552:	e8 45 fe ff ff       	call   f010139c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101557:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010155a:	e9 88 fe ff ff       	jmp    f01013e7 <vprintfmt+0x23>
f010155f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101562:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101565:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101568:	8b 45 14             	mov    0x14(%ebp),%eax
f010156b:	8d 50 04             	lea    0x4(%eax),%edx
f010156e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101571:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0101573:	85 f6                	test   %esi,%esi
f0101575:	ba 7e 27 10 f0       	mov    $0xf010277e,%edx
f010157a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f010157d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101581:	7e 06                	jle    f0101589 <vprintfmt+0x1c5>
f0101583:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0101587:	75 10                	jne    f0101599 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101589:	0f be 06             	movsbl (%esi),%eax
f010158c:	83 c6 01             	add    $0x1,%esi
f010158f:	85 c0                	test   %eax,%eax
f0101591:	0f 85 86 00 00 00    	jne    f010161d <vprintfmt+0x259>
f0101597:	eb 76                	jmp    f010160f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101599:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010159d:	89 34 24             	mov    %esi,(%esp)
f01015a0:	e8 36 03 00 00       	call   f01018db <strnlen>
f01015a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01015a8:	29 c2                	sub    %eax,%edx
f01015aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01015ad:	85 d2                	test   %edx,%edx
f01015af:	7e d8                	jle    f0101589 <vprintfmt+0x1c5>
					putch(padc, putdat);
f01015b1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01015b5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01015b8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01015bb:	89 d6                	mov    %edx,%esi
f01015bd:	89 c7                	mov    %eax,%edi
f01015bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015c3:	89 3c 24             	mov    %edi,(%esp)
f01015c6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01015c9:	83 ee 01             	sub    $0x1,%esi
f01015cc:	75 f1                	jne    f01015bf <vprintfmt+0x1fb>
f01015ce:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01015d1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01015d4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01015d7:	eb b0                	jmp    f0101589 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01015d9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01015dd:	74 18                	je     f01015f7 <vprintfmt+0x233>
f01015df:	8d 50 e0             	lea    -0x20(%eax),%edx
f01015e2:	83 fa 5e             	cmp    $0x5e,%edx
f01015e5:	76 10                	jbe    f01015f7 <vprintfmt+0x233>
					putch('?', putdat);
f01015e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015eb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01015f2:	ff 55 08             	call   *0x8(%ebp)
f01015f5:	eb 0a                	jmp    f0101601 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f01015f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015fb:	89 04 24             	mov    %eax,(%esp)
f01015fe:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101601:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0101605:	0f be 06             	movsbl (%esi),%eax
f0101608:	83 c6 01             	add    $0x1,%esi
f010160b:	85 c0                	test   %eax,%eax
f010160d:	75 0e                	jne    f010161d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010160f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101612:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101616:	7f 11                	jg     f0101629 <vprintfmt+0x265>
f0101618:	e9 ca fd ff ff       	jmp    f01013e7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010161d:	85 ff                	test   %edi,%edi
f010161f:	90                   	nop
f0101620:	78 b7                	js     f01015d9 <vprintfmt+0x215>
f0101622:	83 ef 01             	sub    $0x1,%edi
f0101625:	79 b2                	jns    f01015d9 <vprintfmt+0x215>
f0101627:	eb e6                	jmp    f010160f <vprintfmt+0x24b>
f0101629:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010162c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010162f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101633:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010163a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010163c:	83 ee 01             	sub    $0x1,%esi
f010163f:	75 ee                	jne    f010162f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101641:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101644:	e9 9e fd ff ff       	jmp    f01013e7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101649:	89 ca                	mov    %ecx,%edx
f010164b:	8d 45 14             	lea    0x14(%ebp),%eax
f010164e:	e8 f2 fc ff ff       	call   f0101345 <getint>
f0101653:	89 c6                	mov    %eax,%esi
f0101655:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101657:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010165c:	85 d2                	test   %edx,%edx
f010165e:	0f 89 ad 00 00 00    	jns    f0101711 <vprintfmt+0x34d>
				putch('-', putdat);
f0101664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101668:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010166f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101672:	f7 de                	neg    %esi
f0101674:	83 d7 00             	adc    $0x0,%edi
f0101677:	f7 df                	neg    %edi
			}
			base = 10;
f0101679:	b8 0a 00 00 00       	mov    $0xa,%eax
f010167e:	e9 8e 00 00 00       	jmp    f0101711 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101683:	89 ca                	mov    %ecx,%edx
f0101685:	8d 45 14             	lea    0x14(%ebp),%eax
f0101688:	e8 7e fc ff ff       	call   f010130b <getuint>
f010168d:	89 c6                	mov    %eax,%esi
f010168f:	89 d7                	mov    %edx,%edi
			base = 10;
f0101691:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0101696:	eb 79                	jmp    f0101711 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f0101698:	89 ca                	mov    %ecx,%edx
f010169a:	8d 45 14             	lea    0x14(%ebp),%eax
f010169d:	e8 a3 fc ff ff       	call   f0101345 <getint>
f01016a2:	89 c6                	mov    %eax,%esi
f01016a4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f01016a6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01016ab:	85 d2                	test   %edx,%edx
f01016ad:	79 62                	jns    f0101711 <vprintfmt+0x34d>
				putch('-', putdat);
f01016af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016b3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01016ba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01016bd:	f7 de                	neg    %esi
f01016bf:	83 d7 00             	adc    $0x0,%edi
f01016c2:	f7 df                	neg    %edi
			}
			base = 8;
f01016c4:	b8 08 00 00 00       	mov    $0x8,%eax
f01016c9:	eb 46                	jmp    f0101711 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f01016cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016cf:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01016d6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01016d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016dd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01016e4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01016e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01016ea:	8d 50 04             	lea    0x4(%eax),%edx
f01016ed:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01016f0:	8b 30                	mov    (%eax),%esi
f01016f2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01016f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01016fc:	eb 13                	jmp    f0101711 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01016fe:	89 ca                	mov    %ecx,%edx
f0101700:	8d 45 14             	lea    0x14(%ebp),%eax
f0101703:	e8 03 fc ff ff       	call   f010130b <getuint>
f0101708:	89 c6                	mov    %eax,%esi
f010170a:	89 d7                	mov    %edx,%edi
			base = 16;
f010170c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101711:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0101715:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101719:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010171c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101720:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101724:	89 34 24             	mov    %esi,(%esp)
f0101727:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010172b:	89 da                	mov    %ebx,%edx
f010172d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101730:	e8 fb fa ff ff       	call   f0101230 <printnum>
			break;
f0101735:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101738:	e9 aa fc ff ff       	jmp    f01013e7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010173d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101741:	89 14 24             	mov    %edx,(%esp)
f0101744:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101747:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010174a:	e9 98 fc ff ff       	jmp    f01013e7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010174f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101753:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010175a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010175d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0101761:	0f 84 80 fc ff ff    	je     f01013e7 <vprintfmt+0x23>
f0101767:	83 ee 01             	sub    $0x1,%esi
f010176a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010176e:	75 f7                	jne    f0101767 <vprintfmt+0x3a3>
f0101770:	e9 72 fc ff ff       	jmp    f01013e7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0101775:	83 c4 4c             	add    $0x4c,%esp
f0101778:	5b                   	pop    %ebx
f0101779:	5e                   	pop    %esi
f010177a:	5f                   	pop    %edi
f010177b:	5d                   	pop    %ebp
f010177c:	c3                   	ret    

f010177d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010177d:	55                   	push   %ebp
f010177e:	89 e5                	mov    %esp,%ebp
f0101780:	83 ec 28             	sub    $0x28,%esp
f0101783:	8b 45 08             	mov    0x8(%ebp),%eax
f0101786:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101789:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010178c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101790:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101793:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010179a:	85 c0                	test   %eax,%eax
f010179c:	74 30                	je     f01017ce <vsnprintf+0x51>
f010179e:	85 d2                	test   %edx,%edx
f01017a0:	7e 2c                	jle    f01017ce <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01017a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01017a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017a9:	8b 45 10             	mov    0x10(%ebp),%eax
f01017ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01017b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017b7:	c7 04 24 7f 13 10 f0 	movl   $0xf010137f,(%esp)
f01017be:	e8 01 fc ff ff       	call   f01013c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01017c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01017c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01017cc:	eb 05                	jmp    f01017d3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01017ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01017d3:	c9                   	leave  
f01017d4:	c3                   	ret    

f01017d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01017d5:	55                   	push   %ebp
f01017d6:	89 e5                	mov    %esp,%ebp
f01017d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01017db:	8d 45 14             	lea    0x14(%ebp),%eax
f01017de:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017e2:	8b 45 10             	mov    0x10(%ebp),%eax
f01017e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01017f3:	89 04 24             	mov    %eax,(%esp)
f01017f6:	e8 82 ff ff ff       	call   f010177d <vsnprintf>
	va_end(ap);

	return rc;
}
f01017fb:	c9                   	leave  
f01017fc:	c3                   	ret    
f01017fd:	00 00                	add    %al,(%eax)
	...

f0101800 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101800:	55                   	push   %ebp
f0101801:	89 e5                	mov    %esp,%ebp
f0101803:	57                   	push   %edi
f0101804:	56                   	push   %esi
f0101805:	53                   	push   %ebx
f0101806:	83 ec 1c             	sub    $0x1c,%esp
f0101809:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010180c:	85 c0                	test   %eax,%eax
f010180e:	74 10                	je     f0101820 <readline+0x20>
		cprintf("%s", prompt);
f0101810:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101814:	c7 04 24 8e 27 10 f0 	movl   $0xf010278e,(%esp)
f010181b:	e8 3e f7 ff ff       	call   f0100f5e <cprintf>

	i = 0;
	echoing = iscons(0);
f0101820:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101827:	e8 b0 ee ff ff       	call   f01006dc <iscons>
f010182c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010182e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101833:	e8 93 ee ff ff       	call   f01006cb <getchar>
f0101838:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010183a:	85 c0                	test   %eax,%eax
f010183c:	79 17                	jns    f0101855 <readline+0x55>
			cprintf("read error: %e\n", c);
f010183e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101842:	c7 04 24 70 29 10 f0 	movl   $0xf0102970,(%esp)
f0101849:	e8 10 f7 ff ff       	call   f0100f5e <cprintf>
			return NULL;
f010184e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101853:	eb 61                	jmp    f01018b6 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101855:	83 f8 1f             	cmp    $0x1f,%eax
f0101858:	7e 1f                	jle    f0101879 <readline+0x79>
f010185a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101860:	7f 17                	jg     f0101879 <readline+0x79>
			if (echoing)
f0101862:	85 ff                	test   %edi,%edi
f0101864:	74 08                	je     f010186e <readline+0x6e>
				cputchar(c);
f0101866:	89 04 24             	mov    %eax,(%esp)
f0101869:	e8 4a ee ff ff       	call   f01006b8 <cputchar>
			buf[i++] = c;
f010186e:	88 9e 00 26 11 f0    	mov    %bl,-0xfeeda00(%esi)
f0101874:	83 c6 01             	add    $0x1,%esi
f0101877:	eb ba                	jmp    f0101833 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101879:	83 fb 08             	cmp    $0x8,%ebx
f010187c:	75 15                	jne    f0101893 <readline+0x93>
f010187e:	85 f6                	test   %esi,%esi
f0101880:	7e 11                	jle    f0101893 <readline+0x93>
			if (echoing)
f0101882:	85 ff                	test   %edi,%edi
f0101884:	74 08                	je     f010188e <readline+0x8e>
				cputchar(c);
f0101886:	89 1c 24             	mov    %ebx,(%esp)
f0101889:	e8 2a ee ff ff       	call   f01006b8 <cputchar>
			i--;
f010188e:	83 ee 01             	sub    $0x1,%esi
f0101891:	eb a0                	jmp    f0101833 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101893:	83 fb 0a             	cmp    $0xa,%ebx
f0101896:	74 05                	je     f010189d <readline+0x9d>
f0101898:	83 fb 0d             	cmp    $0xd,%ebx
f010189b:	75 96                	jne    f0101833 <readline+0x33>
			if (echoing)
f010189d:	85 ff                	test   %edi,%edi
f010189f:	90                   	nop
f01018a0:	74 08                	je     f01018aa <readline+0xaa>
				cputchar(c);
f01018a2:	89 1c 24             	mov    %ebx,(%esp)
f01018a5:	e8 0e ee ff ff       	call   f01006b8 <cputchar>
			buf[i] = 0;
f01018aa:	c6 86 00 26 11 f0 00 	movb   $0x0,-0xfeeda00(%esi)
			return buf;
f01018b1:	b8 00 26 11 f0       	mov    $0xf0112600,%eax
		}
	}
}
f01018b6:	83 c4 1c             	add    $0x1c,%esp
f01018b9:	5b                   	pop    %ebx
f01018ba:	5e                   	pop    %esi
f01018bb:	5f                   	pop    %edi
f01018bc:	5d                   	pop    %ebp
f01018bd:	c3                   	ret    
	...

f01018c0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01018c0:	55                   	push   %ebp
f01018c1:	89 e5                	mov    %esp,%ebp
f01018c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01018c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01018cb:	80 3a 00             	cmpb   $0x0,(%edx)
f01018ce:	74 09                	je     f01018d9 <strlen+0x19>
		n++;
f01018d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01018d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01018d7:	75 f7                	jne    f01018d0 <strlen+0x10>
		n++;
	return n;
}
f01018d9:	5d                   	pop    %ebp
f01018da:	c3                   	ret    

f01018db <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01018db:	55                   	push   %ebp
f01018dc:	89 e5                	mov    %esp,%ebp
f01018de:	53                   	push   %ebx
f01018df:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01018e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01018e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01018ea:	85 c9                	test   %ecx,%ecx
f01018ec:	74 1a                	je     f0101908 <strnlen+0x2d>
f01018ee:	80 3b 00             	cmpb   $0x0,(%ebx)
f01018f1:	74 15                	je     f0101908 <strnlen+0x2d>
f01018f3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01018f8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01018fa:	39 ca                	cmp    %ecx,%edx
f01018fc:	74 0a                	je     f0101908 <strnlen+0x2d>
f01018fe:	83 c2 01             	add    $0x1,%edx
f0101901:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0101906:	75 f0                	jne    f01018f8 <strnlen+0x1d>
		n++;
	return n;
}
f0101908:	5b                   	pop    %ebx
f0101909:	5d                   	pop    %ebp
f010190a:	c3                   	ret    

f010190b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010190b:	55                   	push   %ebp
f010190c:	89 e5                	mov    %esp,%ebp
f010190e:	53                   	push   %ebx
f010190f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101912:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101915:	ba 00 00 00 00       	mov    $0x0,%edx
f010191a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010191e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101921:	83 c2 01             	add    $0x1,%edx
f0101924:	84 c9                	test   %cl,%cl
f0101926:	75 f2                	jne    f010191a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101928:	5b                   	pop    %ebx
f0101929:	5d                   	pop    %ebp
f010192a:	c3                   	ret    

f010192b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010192b:	55                   	push   %ebp
f010192c:	89 e5                	mov    %esp,%ebp
f010192e:	56                   	push   %esi
f010192f:	53                   	push   %ebx
f0101930:	8b 45 08             	mov    0x8(%ebp),%eax
f0101933:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101936:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101939:	85 f6                	test   %esi,%esi
f010193b:	74 18                	je     f0101955 <strncpy+0x2a>
f010193d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101942:	0f b6 1a             	movzbl (%edx),%ebx
f0101945:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101948:	80 3a 01             	cmpb   $0x1,(%edx)
f010194b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010194e:	83 c1 01             	add    $0x1,%ecx
f0101951:	39 f1                	cmp    %esi,%ecx
f0101953:	75 ed                	jne    f0101942 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101955:	5b                   	pop    %ebx
f0101956:	5e                   	pop    %esi
f0101957:	5d                   	pop    %ebp
f0101958:	c3                   	ret    

f0101959 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101959:	55                   	push   %ebp
f010195a:	89 e5                	mov    %esp,%ebp
f010195c:	57                   	push   %edi
f010195d:	56                   	push   %esi
f010195e:	53                   	push   %ebx
f010195f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101962:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101965:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101968:	89 f8                	mov    %edi,%eax
f010196a:	85 f6                	test   %esi,%esi
f010196c:	74 2b                	je     f0101999 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f010196e:	83 fe 01             	cmp    $0x1,%esi
f0101971:	74 23                	je     f0101996 <strlcpy+0x3d>
f0101973:	0f b6 0b             	movzbl (%ebx),%ecx
f0101976:	84 c9                	test   %cl,%cl
f0101978:	74 1c                	je     f0101996 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010197a:	83 ee 02             	sub    $0x2,%esi
f010197d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101982:	88 08                	mov    %cl,(%eax)
f0101984:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101987:	39 f2                	cmp    %esi,%edx
f0101989:	74 0b                	je     f0101996 <strlcpy+0x3d>
f010198b:	83 c2 01             	add    $0x1,%edx
f010198e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0101992:	84 c9                	test   %cl,%cl
f0101994:	75 ec                	jne    f0101982 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0101996:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101999:	29 f8                	sub    %edi,%eax
}
f010199b:	5b                   	pop    %ebx
f010199c:	5e                   	pop    %esi
f010199d:	5f                   	pop    %edi
f010199e:	5d                   	pop    %ebp
f010199f:	c3                   	ret    

f01019a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01019a0:	55                   	push   %ebp
f01019a1:	89 e5                	mov    %esp,%ebp
f01019a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01019a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01019a9:	0f b6 01             	movzbl (%ecx),%eax
f01019ac:	84 c0                	test   %al,%al
f01019ae:	74 16                	je     f01019c6 <strcmp+0x26>
f01019b0:	3a 02                	cmp    (%edx),%al
f01019b2:	75 12                	jne    f01019c6 <strcmp+0x26>
		p++, q++;
f01019b4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01019b7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01019bb:	84 c0                	test   %al,%al
f01019bd:	74 07                	je     f01019c6 <strcmp+0x26>
f01019bf:	83 c1 01             	add    $0x1,%ecx
f01019c2:	3a 02                	cmp    (%edx),%al
f01019c4:	74 ee                	je     f01019b4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01019c6:	0f b6 c0             	movzbl %al,%eax
f01019c9:	0f b6 12             	movzbl (%edx),%edx
f01019cc:	29 d0                	sub    %edx,%eax
}
f01019ce:	5d                   	pop    %ebp
f01019cf:	c3                   	ret    

f01019d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01019d0:	55                   	push   %ebp
f01019d1:	89 e5                	mov    %esp,%ebp
f01019d3:	53                   	push   %ebx
f01019d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01019d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01019da:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01019dd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01019e2:	85 d2                	test   %edx,%edx
f01019e4:	74 28                	je     f0101a0e <strncmp+0x3e>
f01019e6:	0f b6 01             	movzbl (%ecx),%eax
f01019e9:	84 c0                	test   %al,%al
f01019eb:	74 24                	je     f0101a11 <strncmp+0x41>
f01019ed:	3a 03                	cmp    (%ebx),%al
f01019ef:	75 20                	jne    f0101a11 <strncmp+0x41>
f01019f1:	83 ea 01             	sub    $0x1,%edx
f01019f4:	74 13                	je     f0101a09 <strncmp+0x39>
		n--, p++, q++;
f01019f6:	83 c1 01             	add    $0x1,%ecx
f01019f9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01019fc:	0f b6 01             	movzbl (%ecx),%eax
f01019ff:	84 c0                	test   %al,%al
f0101a01:	74 0e                	je     f0101a11 <strncmp+0x41>
f0101a03:	3a 03                	cmp    (%ebx),%al
f0101a05:	74 ea                	je     f01019f1 <strncmp+0x21>
f0101a07:	eb 08                	jmp    f0101a11 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101a09:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101a0e:	5b                   	pop    %ebx
f0101a0f:	5d                   	pop    %ebp
f0101a10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101a11:	0f b6 01             	movzbl (%ecx),%eax
f0101a14:	0f b6 13             	movzbl (%ebx),%edx
f0101a17:	29 d0                	sub    %edx,%eax
f0101a19:	eb f3                	jmp    f0101a0e <strncmp+0x3e>

f0101a1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101a1b:	55                   	push   %ebp
f0101a1c:	89 e5                	mov    %esp,%ebp
f0101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a25:	0f b6 10             	movzbl (%eax),%edx
f0101a28:	84 d2                	test   %dl,%dl
f0101a2a:	74 1c                	je     f0101a48 <strchr+0x2d>
		if (*s == c)
f0101a2c:	38 ca                	cmp    %cl,%dl
f0101a2e:	75 09                	jne    f0101a39 <strchr+0x1e>
f0101a30:	eb 1b                	jmp    f0101a4d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101a32:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0101a35:	38 ca                	cmp    %cl,%dl
f0101a37:	74 14                	je     f0101a4d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101a39:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0101a3d:	84 d2                	test   %dl,%dl
f0101a3f:	75 f1                	jne    f0101a32 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0101a41:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a46:	eb 05                	jmp    f0101a4d <strchr+0x32>
f0101a48:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a4d:	5d                   	pop    %ebp
f0101a4e:	c3                   	ret    

f0101a4f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101a4f:	55                   	push   %ebp
f0101a50:	89 e5                	mov    %esp,%ebp
f0101a52:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a55:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101a59:	0f b6 10             	movzbl (%eax),%edx
f0101a5c:	84 d2                	test   %dl,%dl
f0101a5e:	74 14                	je     f0101a74 <strfind+0x25>
		if (*s == c)
f0101a60:	38 ca                	cmp    %cl,%dl
f0101a62:	75 06                	jne    f0101a6a <strfind+0x1b>
f0101a64:	eb 0e                	jmp    f0101a74 <strfind+0x25>
f0101a66:	38 ca                	cmp    %cl,%dl
f0101a68:	74 0a                	je     f0101a74 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101a6a:	83 c0 01             	add    $0x1,%eax
f0101a6d:	0f b6 10             	movzbl (%eax),%edx
f0101a70:	84 d2                	test   %dl,%dl
f0101a72:	75 f2                	jne    f0101a66 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101a74:	5d                   	pop    %ebp
f0101a75:	c3                   	ret    

f0101a76 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101a76:	55                   	push   %ebp
f0101a77:	89 e5                	mov    %esp,%ebp
f0101a79:	53                   	push   %ebx
f0101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101a80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101a83:	89 da                	mov    %ebx,%edx
f0101a85:	83 ea 01             	sub    $0x1,%edx
f0101a88:	78 0d                	js     f0101a97 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f0101a8a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f0101a8c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f0101a8e:	88 0a                	mov    %cl,(%edx)
f0101a90:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101a93:	39 da                	cmp    %ebx,%edx
f0101a95:	75 f7                	jne    f0101a8e <memset+0x18>
		*p++ = c;

	return v;
}
f0101a97:	5b                   	pop    %ebx
f0101a98:	5d                   	pop    %ebp
f0101a99:	c3                   	ret    

f0101a9a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f0101a9a:	55                   	push   %ebp
f0101a9b:	89 e5                	mov    %esp,%ebp
f0101a9d:	57                   	push   %edi
f0101a9e:	56                   	push   %esi
f0101a9f:	53                   	push   %ebx
f0101aa0:	8b 45 08             	mov    0x8(%ebp),%eax
f0101aa3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101aa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101aa9:	39 c6                	cmp    %eax,%esi
f0101aab:	72 0b                	jb     f0101ab8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101aad:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ab2:	85 db                	test   %ebx,%ebx
f0101ab4:	75 29                	jne    f0101adf <memmove+0x45>
f0101ab6:	eb 35                	jmp    f0101aed <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101ab8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f0101abb:	39 c8                	cmp    %ecx,%eax
f0101abd:	73 ee                	jae    f0101aad <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f0101abf:	85 db                	test   %ebx,%ebx
f0101ac1:	74 2a                	je     f0101aed <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0101ac3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f0101ac6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f0101ac8:	f7 db                	neg    %ebx
f0101aca:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f0101acd:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f0101acf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0101ad4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0101ad8:	83 ea 01             	sub    $0x1,%edx
f0101adb:	75 f2                	jne    f0101acf <memmove+0x35>
f0101add:	eb 0e                	jmp    f0101aed <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0101adf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101ae3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101ae6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101ae9:	39 d3                	cmp    %edx,%ebx
f0101aeb:	75 f2                	jne    f0101adf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f0101aed:	5b                   	pop    %ebx
f0101aee:	5e                   	pop    %esi
f0101aef:	5f                   	pop    %edi
f0101af0:	5d                   	pop    %ebp
f0101af1:	c3                   	ret    

f0101af2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101af2:	55                   	push   %ebp
f0101af3:	89 e5                	mov    %esp,%ebp
f0101af5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101af8:	8b 45 10             	mov    0x10(%ebp),%eax
f0101afb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101aff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b06:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b09:	89 04 24             	mov    %eax,(%esp)
f0101b0c:	e8 89 ff ff ff       	call   f0101a9a <memmove>
}
f0101b11:	c9                   	leave  
f0101b12:	c3                   	ret    

f0101b13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101b13:	55                   	push   %ebp
f0101b14:	89 e5                	mov    %esp,%ebp
f0101b16:	57                   	push   %edi
f0101b17:	56                   	push   %esi
f0101b18:	53                   	push   %ebx
f0101b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b1f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101b22:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b27:	85 ff                	test   %edi,%edi
f0101b29:	74 37                	je     f0101b62 <memcmp+0x4f>
		if (*s1 != *s2)
f0101b2b:	0f b6 03             	movzbl (%ebx),%eax
f0101b2e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b31:	83 ef 01             	sub    $0x1,%edi
f0101b34:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0101b39:	38 c8                	cmp    %cl,%al
f0101b3b:	74 1c                	je     f0101b59 <memcmp+0x46>
f0101b3d:	eb 10                	jmp    f0101b4f <memcmp+0x3c>
f0101b3f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0101b44:	83 c2 01             	add    $0x1,%edx
f0101b47:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101b4b:	38 c8                	cmp    %cl,%al
f0101b4d:	74 0a                	je     f0101b59 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0101b4f:	0f b6 c0             	movzbl %al,%eax
f0101b52:	0f b6 c9             	movzbl %cl,%ecx
f0101b55:	29 c8                	sub    %ecx,%eax
f0101b57:	eb 09                	jmp    f0101b62 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101b59:	39 fa                	cmp    %edi,%edx
f0101b5b:	75 e2                	jne    f0101b3f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b62:	5b                   	pop    %ebx
f0101b63:	5e                   	pop    %esi
f0101b64:	5f                   	pop    %edi
f0101b65:	5d                   	pop    %ebp
f0101b66:	c3                   	ret    

f0101b67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101b67:	55                   	push   %ebp
f0101b68:	89 e5                	mov    %esp,%ebp
f0101b6a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101b6d:	89 c2                	mov    %eax,%edx
f0101b6f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101b72:	39 d0                	cmp    %edx,%eax
f0101b74:	73 15                	jae    f0101b8b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101b76:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101b7a:	38 08                	cmp    %cl,(%eax)
f0101b7c:	75 06                	jne    f0101b84 <memfind+0x1d>
f0101b7e:	eb 0b                	jmp    f0101b8b <memfind+0x24>
f0101b80:	38 08                	cmp    %cl,(%eax)
f0101b82:	74 07                	je     f0101b8b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101b84:	83 c0 01             	add    $0x1,%eax
f0101b87:	39 d0                	cmp    %edx,%eax
f0101b89:	75 f5                	jne    f0101b80 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101b8b:	5d                   	pop    %ebp
f0101b8c:	c3                   	ret    

f0101b8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101b8d:	55                   	push   %ebp
f0101b8e:	89 e5                	mov    %esp,%ebp
f0101b90:	57                   	push   %edi
f0101b91:	56                   	push   %esi
f0101b92:	53                   	push   %ebx
f0101b93:	8b 55 08             	mov    0x8(%ebp),%edx
f0101b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101b99:	0f b6 02             	movzbl (%edx),%eax
f0101b9c:	3c 20                	cmp    $0x20,%al
f0101b9e:	74 04                	je     f0101ba4 <strtol+0x17>
f0101ba0:	3c 09                	cmp    $0x9,%al
f0101ba2:	75 0e                	jne    f0101bb2 <strtol+0x25>
		s++;
f0101ba4:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101ba7:	0f b6 02             	movzbl (%edx),%eax
f0101baa:	3c 20                	cmp    $0x20,%al
f0101bac:	74 f6                	je     f0101ba4 <strtol+0x17>
f0101bae:	3c 09                	cmp    $0x9,%al
f0101bb0:	74 f2                	je     f0101ba4 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101bb2:	3c 2b                	cmp    $0x2b,%al
f0101bb4:	75 0a                	jne    f0101bc0 <strtol+0x33>
		s++;
f0101bb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101bb9:	bf 00 00 00 00       	mov    $0x0,%edi
f0101bbe:	eb 10                	jmp    f0101bd0 <strtol+0x43>
f0101bc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101bc5:	3c 2d                	cmp    $0x2d,%al
f0101bc7:	75 07                	jne    f0101bd0 <strtol+0x43>
		s++, neg = 1;
f0101bc9:	83 c2 01             	add    $0x1,%edx
f0101bcc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101bd0:	85 db                	test   %ebx,%ebx
f0101bd2:	0f 94 c0             	sete   %al
f0101bd5:	74 05                	je     f0101bdc <strtol+0x4f>
f0101bd7:	83 fb 10             	cmp    $0x10,%ebx
f0101bda:	75 15                	jne    f0101bf1 <strtol+0x64>
f0101bdc:	80 3a 30             	cmpb   $0x30,(%edx)
f0101bdf:	75 10                	jne    f0101bf1 <strtol+0x64>
f0101be1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101be5:	75 0a                	jne    f0101bf1 <strtol+0x64>
		s += 2, base = 16;
f0101be7:	83 c2 02             	add    $0x2,%edx
f0101bea:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101bef:	eb 13                	jmp    f0101c04 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0101bf1:	84 c0                	test   %al,%al
f0101bf3:	74 0f                	je     f0101c04 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101bf5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101bfa:	80 3a 30             	cmpb   $0x30,(%edx)
f0101bfd:	75 05                	jne    f0101c04 <strtol+0x77>
		s++, base = 8;
f0101bff:	83 c2 01             	add    $0x1,%edx
f0101c02:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0101c04:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c09:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101c0b:	0f b6 0a             	movzbl (%edx),%ecx
f0101c0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101c11:	80 fb 09             	cmp    $0x9,%bl
f0101c14:	77 08                	ja     f0101c1e <strtol+0x91>
			dig = *s - '0';
f0101c16:	0f be c9             	movsbl %cl,%ecx
f0101c19:	83 e9 30             	sub    $0x30,%ecx
f0101c1c:	eb 1e                	jmp    f0101c3c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0101c1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0101c21:	80 fb 19             	cmp    $0x19,%bl
f0101c24:	77 08                	ja     f0101c2e <strtol+0xa1>
			dig = *s - 'a' + 10;
f0101c26:	0f be c9             	movsbl %cl,%ecx
f0101c29:	83 e9 57             	sub    $0x57,%ecx
f0101c2c:	eb 0e                	jmp    f0101c3c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0101c2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0101c31:	80 fb 19             	cmp    $0x19,%bl
f0101c34:	77 14                	ja     f0101c4a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101c36:	0f be c9             	movsbl %cl,%ecx
f0101c39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101c3c:	39 f1                	cmp    %esi,%ecx
f0101c3e:	7d 0e                	jge    f0101c4e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101c40:	83 c2 01             	add    $0x1,%edx
f0101c43:	0f af c6             	imul   %esi,%eax
f0101c46:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0101c48:	eb c1                	jmp    f0101c0b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0101c4a:	89 c1                	mov    %eax,%ecx
f0101c4c:	eb 02                	jmp    f0101c50 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101c4e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0101c50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101c54:	74 05                	je     f0101c5b <strtol+0xce>
		*endptr = (char *) s;
f0101c56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101c59:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101c5b:	89 ca                	mov    %ecx,%edx
f0101c5d:	f7 da                	neg    %edx
f0101c5f:	85 ff                	test   %edi,%edi
f0101c61:	0f 45 c2             	cmovne %edx,%eax
}
f0101c64:	5b                   	pop    %ebx
f0101c65:	5e                   	pop    %esi
f0101c66:	5f                   	pop    %edi
f0101c67:	5d                   	pop    %ebp
f0101c68:	c3                   	ret    
f0101c69:	00 00                	add    %al,(%eax)
f0101c6b:	00 00                	add    %al,(%eax)
f0101c6d:	00 00                	add    %al,(%eax)
	...

f0101c70 <__udivdi3>:
f0101c70:	83 ec 1c             	sub    $0x1c,%esp
f0101c73:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101c77:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0101c7b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0101c7f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101c83:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101c87:	8b 74 24 24          	mov    0x24(%esp),%esi
f0101c8b:	85 ff                	test   %edi,%edi
f0101c8d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101c91:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c95:	89 cd                	mov    %ecx,%ebp
f0101c97:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c9b:	75 33                	jne    f0101cd0 <__udivdi3+0x60>
f0101c9d:	39 f1                	cmp    %esi,%ecx
f0101c9f:	77 57                	ja     f0101cf8 <__udivdi3+0x88>
f0101ca1:	85 c9                	test   %ecx,%ecx
f0101ca3:	75 0b                	jne    f0101cb0 <__udivdi3+0x40>
f0101ca5:	b8 01 00 00 00       	mov    $0x1,%eax
f0101caa:	31 d2                	xor    %edx,%edx
f0101cac:	f7 f1                	div    %ecx
f0101cae:	89 c1                	mov    %eax,%ecx
f0101cb0:	89 f0                	mov    %esi,%eax
f0101cb2:	31 d2                	xor    %edx,%edx
f0101cb4:	f7 f1                	div    %ecx
f0101cb6:	89 c6                	mov    %eax,%esi
f0101cb8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101cbc:	f7 f1                	div    %ecx
f0101cbe:	89 f2                	mov    %esi,%edx
f0101cc0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101cc4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101cc8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101ccc:	83 c4 1c             	add    $0x1c,%esp
f0101ccf:	c3                   	ret    
f0101cd0:	31 d2                	xor    %edx,%edx
f0101cd2:	31 c0                	xor    %eax,%eax
f0101cd4:	39 f7                	cmp    %esi,%edi
f0101cd6:	77 e8                	ja     f0101cc0 <__udivdi3+0x50>
f0101cd8:	0f bd cf             	bsr    %edi,%ecx
f0101cdb:	83 f1 1f             	xor    $0x1f,%ecx
f0101cde:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101ce2:	75 2c                	jne    f0101d10 <__udivdi3+0xa0>
f0101ce4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0101ce8:	76 04                	jbe    f0101cee <__udivdi3+0x7e>
f0101cea:	39 f7                	cmp    %esi,%edi
f0101cec:	73 d2                	jae    f0101cc0 <__udivdi3+0x50>
f0101cee:	31 d2                	xor    %edx,%edx
f0101cf0:	b8 01 00 00 00       	mov    $0x1,%eax
f0101cf5:	eb c9                	jmp    f0101cc0 <__udivdi3+0x50>
f0101cf7:	90                   	nop
f0101cf8:	89 f2                	mov    %esi,%edx
f0101cfa:	f7 f1                	div    %ecx
f0101cfc:	31 d2                	xor    %edx,%edx
f0101cfe:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101d02:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101d06:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101d0a:	83 c4 1c             	add    $0x1c,%esp
f0101d0d:	c3                   	ret    
f0101d0e:	66 90                	xchg   %ax,%ax
f0101d10:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101d15:	b8 20 00 00 00       	mov    $0x20,%eax
f0101d1a:	89 ea                	mov    %ebp,%edx
f0101d1c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101d20:	d3 e7                	shl    %cl,%edi
f0101d22:	89 c1                	mov    %eax,%ecx
f0101d24:	d3 ea                	shr    %cl,%edx
f0101d26:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101d2b:	09 fa                	or     %edi,%edx
f0101d2d:	89 f7                	mov    %esi,%edi
f0101d2f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101d33:	89 f2                	mov    %esi,%edx
f0101d35:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101d39:	d3 e5                	shl    %cl,%ebp
f0101d3b:	89 c1                	mov    %eax,%ecx
f0101d3d:	d3 ef                	shr    %cl,%edi
f0101d3f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101d44:	d3 e2                	shl    %cl,%edx
f0101d46:	89 c1                	mov    %eax,%ecx
f0101d48:	d3 ee                	shr    %cl,%esi
f0101d4a:	09 d6                	or     %edx,%esi
f0101d4c:	89 fa                	mov    %edi,%edx
f0101d4e:	89 f0                	mov    %esi,%eax
f0101d50:	f7 74 24 0c          	divl   0xc(%esp)
f0101d54:	89 d7                	mov    %edx,%edi
f0101d56:	89 c6                	mov    %eax,%esi
f0101d58:	f7 e5                	mul    %ebp
f0101d5a:	39 d7                	cmp    %edx,%edi
f0101d5c:	72 22                	jb     f0101d80 <__udivdi3+0x110>
f0101d5e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0101d62:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101d67:	d3 e5                	shl    %cl,%ebp
f0101d69:	39 c5                	cmp    %eax,%ebp
f0101d6b:	73 04                	jae    f0101d71 <__udivdi3+0x101>
f0101d6d:	39 d7                	cmp    %edx,%edi
f0101d6f:	74 0f                	je     f0101d80 <__udivdi3+0x110>
f0101d71:	89 f0                	mov    %esi,%eax
f0101d73:	31 d2                	xor    %edx,%edx
f0101d75:	e9 46 ff ff ff       	jmp    f0101cc0 <__udivdi3+0x50>
f0101d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101d80:	8d 46 ff             	lea    -0x1(%esi),%eax
f0101d83:	31 d2                	xor    %edx,%edx
f0101d85:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101d89:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101d8d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101d91:	83 c4 1c             	add    $0x1c,%esp
f0101d94:	c3                   	ret    
	...

f0101da0 <__umoddi3>:
f0101da0:	83 ec 1c             	sub    $0x1c,%esp
f0101da3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101da7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0101dab:	8b 44 24 20          	mov    0x20(%esp),%eax
f0101daf:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101db3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101db7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0101dbb:	85 ed                	test   %ebp,%ebp
f0101dbd:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101dc1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101dc5:	89 cf                	mov    %ecx,%edi
f0101dc7:	89 04 24             	mov    %eax,(%esp)
f0101dca:	89 f2                	mov    %esi,%edx
f0101dcc:	75 1a                	jne    f0101de8 <__umoddi3+0x48>
f0101dce:	39 f1                	cmp    %esi,%ecx
f0101dd0:	76 4e                	jbe    f0101e20 <__umoddi3+0x80>
f0101dd2:	f7 f1                	div    %ecx
f0101dd4:	89 d0                	mov    %edx,%eax
f0101dd6:	31 d2                	xor    %edx,%edx
f0101dd8:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101ddc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101de0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101de4:	83 c4 1c             	add    $0x1c,%esp
f0101de7:	c3                   	ret    
f0101de8:	39 f5                	cmp    %esi,%ebp
f0101dea:	77 54                	ja     f0101e40 <__umoddi3+0xa0>
f0101dec:	0f bd c5             	bsr    %ebp,%eax
f0101def:	83 f0 1f             	xor    $0x1f,%eax
f0101df2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101df6:	75 60                	jne    f0101e58 <__umoddi3+0xb8>
f0101df8:	3b 0c 24             	cmp    (%esp),%ecx
f0101dfb:	0f 87 07 01 00 00    	ja     f0101f08 <__umoddi3+0x168>
f0101e01:	89 f2                	mov    %esi,%edx
f0101e03:	8b 34 24             	mov    (%esp),%esi
f0101e06:	29 ce                	sub    %ecx,%esi
f0101e08:	19 ea                	sbb    %ebp,%edx
f0101e0a:	89 34 24             	mov    %esi,(%esp)
f0101e0d:	8b 04 24             	mov    (%esp),%eax
f0101e10:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101e14:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101e18:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101e1c:	83 c4 1c             	add    $0x1c,%esp
f0101e1f:	c3                   	ret    
f0101e20:	85 c9                	test   %ecx,%ecx
f0101e22:	75 0b                	jne    f0101e2f <__umoddi3+0x8f>
f0101e24:	b8 01 00 00 00       	mov    $0x1,%eax
f0101e29:	31 d2                	xor    %edx,%edx
f0101e2b:	f7 f1                	div    %ecx
f0101e2d:	89 c1                	mov    %eax,%ecx
f0101e2f:	89 f0                	mov    %esi,%eax
f0101e31:	31 d2                	xor    %edx,%edx
f0101e33:	f7 f1                	div    %ecx
f0101e35:	8b 04 24             	mov    (%esp),%eax
f0101e38:	f7 f1                	div    %ecx
f0101e3a:	eb 98                	jmp    f0101dd4 <__umoddi3+0x34>
f0101e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101e40:	89 f2                	mov    %esi,%edx
f0101e42:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101e46:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101e4a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101e4e:	83 c4 1c             	add    $0x1c,%esp
f0101e51:	c3                   	ret    
f0101e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101e58:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101e5d:	89 e8                	mov    %ebp,%eax
f0101e5f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0101e64:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0101e68:	89 fa                	mov    %edi,%edx
f0101e6a:	d3 e0                	shl    %cl,%eax
f0101e6c:	89 e9                	mov    %ebp,%ecx
f0101e6e:	d3 ea                	shr    %cl,%edx
f0101e70:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101e75:	09 c2                	or     %eax,%edx
f0101e77:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101e7b:	89 14 24             	mov    %edx,(%esp)
f0101e7e:	89 f2                	mov    %esi,%edx
f0101e80:	d3 e7                	shl    %cl,%edi
f0101e82:	89 e9                	mov    %ebp,%ecx
f0101e84:	d3 ea                	shr    %cl,%edx
f0101e86:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101e8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101e8f:	d3 e6                	shl    %cl,%esi
f0101e91:	89 e9                	mov    %ebp,%ecx
f0101e93:	d3 e8                	shr    %cl,%eax
f0101e95:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101e9a:	09 f0                	or     %esi,%eax
f0101e9c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101ea0:	f7 34 24             	divl   (%esp)
f0101ea3:	d3 e6                	shl    %cl,%esi
f0101ea5:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101ea9:	89 d6                	mov    %edx,%esi
f0101eab:	f7 e7                	mul    %edi
f0101ead:	39 d6                	cmp    %edx,%esi
f0101eaf:	89 c1                	mov    %eax,%ecx
f0101eb1:	89 d7                	mov    %edx,%edi
f0101eb3:	72 3f                	jb     f0101ef4 <__umoddi3+0x154>
f0101eb5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101eb9:	72 35                	jb     f0101ef0 <__umoddi3+0x150>
f0101ebb:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101ebf:	29 c8                	sub    %ecx,%eax
f0101ec1:	19 fe                	sbb    %edi,%esi
f0101ec3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101ec8:	89 f2                	mov    %esi,%edx
f0101eca:	d3 e8                	shr    %cl,%eax
f0101ecc:	89 e9                	mov    %ebp,%ecx
f0101ece:	d3 e2                	shl    %cl,%edx
f0101ed0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101ed5:	09 d0                	or     %edx,%eax
f0101ed7:	89 f2                	mov    %esi,%edx
f0101ed9:	d3 ea                	shr    %cl,%edx
f0101edb:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101edf:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101ee3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101ee7:	83 c4 1c             	add    $0x1c,%esp
f0101eea:	c3                   	ret    
f0101eeb:	90                   	nop
f0101eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ef0:	39 d6                	cmp    %edx,%esi
f0101ef2:	75 c7                	jne    f0101ebb <__umoddi3+0x11b>
f0101ef4:	89 d7                	mov    %edx,%edi
f0101ef6:	89 c1                	mov    %eax,%ecx
f0101ef8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0101efc:	1b 3c 24             	sbb    (%esp),%edi
f0101eff:	eb ba                	jmp    f0101ebb <__umoddi3+0x11b>
f0101f01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101f08:	39 f5                	cmp    %esi,%ebp
f0101f0a:	0f 82 f1 fe ff ff    	jb     f0101e01 <__umoddi3+0x61>
f0101f10:	e9 f8 fe ff ff       	jmp    f0101e0d <__umoddi3+0x6d>
