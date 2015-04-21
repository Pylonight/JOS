
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
f0100015:	0f 01 15 18 80 11 00 	lgdtl  0x118018

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

        # Leave a few words on the stack for the user trap frame
	movl	$(bootstacktop-SIZEOF_STRUCT_TRAPFRAME),%esp
f0100033:	bc bc 7f 11 f0       	mov    $0xf0117fbc,%esp

	# now to C code
	call	i386_init
f0100038:	e8 03 00 00 00       	call   f0100040 <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <i386_init>:
#include <kern/trap.h>


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
f0100046:	b8 10 3a 17 f0       	mov    $0xf0173a10,%eax
f010004b:	2d e5 2a 17 f0       	sub    $0xf0172ae5,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 e5 2a 17 f0 	movl   $0xf0172ae5,(%esp)
f0100063:	e8 fe 42 00 00       	call   f0104366 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 44 06 00 00       	call   f01006b1 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 20 48 10 f0 	movl   $0xf0104820,(%esp)
f010007c:	e8 e5 2e 00 00       	call   f0102f66 <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100081:	e8 d2 0a 00 00       	call   f0100b58 <i386_detect_memory>
	i386_vm_init();
f0100086:	e8 78 10 00 00       	call   f0101103 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 9e 28 00 00       	call   f0102933 <env_init>
	idt_init();
f0100095:	e8 ec 2e 00 00       	call   f0102f86 <idt_init>


	// Temporary test code specific to LAB 3
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE);
f010009a:	c7 44 24 04 96 78 00 	movl   $0x7896,0x4(%esp)
f01000a1:	00 
f01000a2:	c7 04 24 78 83 11 f0 	movl   $0xf0118378,(%esp)
f01000a9:	e8 be 2a 00 00       	call   f0102b6c <env_create>
	ENV_CREATE(user_hello);
#endif // TEST*


	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000ae:	a1 60 2d 17 f0       	mov    0xf0172d60,%eax
f01000b3:	89 04 24             	mov    %eax,(%esp)
f01000b6:	e8 ee 2d 00 00       	call   f0102ea9 <env_run>

f01000bb <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000bb:	55                   	push   %ebp
f01000bc:	89 e5                	mov    %esp,%ebp
f01000be:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f01000c1:	83 3d 00 2b 17 f0 00 	cmpl   $0x0,0xf0172b00
f01000c8:	75 40                	jne    f010010a <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f01000ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01000cd:	a3 00 2b 17 f0       	mov    %eax,0xf0172b00

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000e0:	c7 04 24 3b 48 10 f0 	movl   $0xf010483b,(%esp)
f01000e7:	e8 7a 2e 00 00       	call   f0102f66 <cprintf>
	vcprintf(fmt, ap);
f01000ec:	8d 45 14             	lea    0x14(%ebp),%eax
f01000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000f3:	8b 45 10             	mov    0x10(%ebp),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 35 2e 00 00       	call   f0102f33 <vcprintf>
	cprintf("\n");
f01000fe:	c7 04 24 6d 56 10 f0 	movl   $0xf010566d,(%esp)
f0100105:	e8 5c 2e 00 00       	call   f0102f66 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010010a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100111:	e8 ea 06 00 00       	call   f0100800 <monitor>
f0100116:	eb f2                	jmp    f010010a <_panic+0x4f>

f0100118 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100118:	55                   	push   %ebp
f0100119:	89 e5                	mov    %esp,%ebp
f010011b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010011e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100121:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100125:	8b 45 08             	mov    0x8(%ebp),%eax
f0100128:	89 44 24 04          	mov    %eax,0x4(%esp)
f010012c:	c7 04 24 53 48 10 f0 	movl   $0xf0104853,(%esp)
f0100133:	e8 2e 2e 00 00       	call   f0102f66 <cprintf>
	vcprintf(fmt, ap);
f0100138:	8d 45 14             	lea    0x14(%ebp),%eax
f010013b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010013f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100142:	89 04 24             	mov    %eax,(%esp)
f0100145:	e8 e9 2d 00 00       	call   f0102f33 <vcprintf>
	cprintf("\n");
f010014a:	c7 04 24 6d 56 10 f0 	movl   $0xf010566d,(%esp)
f0100151:	e8 10 2e 00 00       	call   f0102f66 <cprintf>
	va_end(ap);
}
f0100156:	c9                   	leave  
f0100157:	c3                   	ret    

f0100158 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100158:	55                   	push   %ebp
f0100159:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010015b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100160:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100161:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100166:	a8 01                	test   $0x1,%al
f0100168:	74 06                	je     f0100170 <serial_proc_data+0x18>
f010016a:	b2 f8                	mov    $0xf8,%dl
f010016c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010016d:	0f b6 c8             	movzbl %al,%ecx
}
f0100170:	89 c8                	mov    %ecx,%eax
f0100172:	5d                   	pop    %ebp
f0100173:	c3                   	ret    

f0100174 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100174:	55                   	push   %ebp
f0100175:	89 e5                	mov    %esp,%ebp
f0100177:	53                   	push   %ebx
f0100178:	83 ec 14             	sub    $0x14,%esp
f010017b:	ba 64 00 00 00       	mov    $0x64,%edx
f0100180:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100181:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100186:	a8 01                	test   $0x1,%al
f0100188:	0f 84 de 00 00 00    	je     f010026c <kbd_proc_data+0xf8>
f010018e:	b2 60                	mov    $0x60,%dl
f0100190:	ec                   	in     (%dx),%al
f0100191:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100193:	3c e0                	cmp    $0xe0,%al
f0100195:	75 11                	jne    f01001a8 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f0100197:	83 0d 30 2b 17 f0 40 	orl    $0x40,0xf0172b30
		return 0;
f010019e:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001a3:	e9 c4 00 00 00       	jmp    f010026c <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01001a8:	84 c0                	test   %al,%al
f01001aa:	79 37                	jns    f01001e3 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ac:	8b 0d 30 2b 17 f0    	mov    0xf0172b30,%ecx
f01001b2:	89 cb                	mov    %ecx,%ebx
f01001b4:	83 e3 40             	and    $0x40,%ebx
f01001b7:	83 e0 7f             	and    $0x7f,%eax
f01001ba:	85 db                	test   %ebx,%ebx
f01001bc:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001bf:	0f b6 d2             	movzbl %dl,%edx
f01001c2:	0f b6 82 80 4a 10 f0 	movzbl -0xfefb580(%edx),%eax
f01001c9:	83 c8 40             	or     $0x40,%eax
f01001cc:	0f b6 c0             	movzbl %al,%eax
f01001cf:	f7 d0                	not    %eax
f01001d1:	21 c1                	and    %eax,%ecx
f01001d3:	89 0d 30 2b 17 f0    	mov    %ecx,0xf0172b30
		return 0;
f01001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001de:	e9 89 00 00 00       	jmp    f010026c <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01001e3:	8b 0d 30 2b 17 f0    	mov    0xf0172b30,%ecx
f01001e9:	f6 c1 40             	test   $0x40,%cl
f01001ec:	74 0e                	je     f01001fc <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ee:	89 c2                	mov    %eax,%edx
f01001f0:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01001f3:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f6:	89 0d 30 2b 17 f0    	mov    %ecx,0xf0172b30
	}

	shift |= shiftcode[data];
f01001fc:	0f b6 d2             	movzbl %dl,%edx
f01001ff:	0f b6 82 80 4a 10 f0 	movzbl -0xfefb580(%edx),%eax
f0100206:	0b 05 30 2b 17 f0    	or     0xf0172b30,%eax
	shift ^= togglecode[data];
f010020c:	0f b6 8a 80 4b 10 f0 	movzbl -0xfefb480(%edx),%ecx
f0100213:	31 c8                	xor    %ecx,%eax
f0100215:	a3 30 2b 17 f0       	mov    %eax,0xf0172b30

	c = charcode[shift & (CTL | SHIFT)][data];
f010021a:	89 c1                	mov    %eax,%ecx
f010021c:	83 e1 03             	and    $0x3,%ecx
f010021f:	8b 0c 8d 80 4c 10 f0 	mov    -0xfefb380(,%ecx,4),%ecx
f0100226:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010022a:	a8 08                	test   $0x8,%al
f010022c:	74 19                	je     f0100247 <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f010022e:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100231:	83 fa 19             	cmp    $0x19,%edx
f0100234:	77 05                	ja     f010023b <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f0100236:	83 eb 20             	sub    $0x20,%ebx
f0100239:	eb 0c                	jmp    f0100247 <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f010023b:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f010023e:	8d 53 20             	lea    0x20(%ebx),%edx
f0100241:	83 f9 19             	cmp    $0x19,%ecx
f0100244:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100247:	f7 d0                	not    %eax
f0100249:	a8 06                	test   $0x6,%al
f010024b:	75 1f                	jne    f010026c <kbd_proc_data+0xf8>
f010024d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100253:	75 17                	jne    f010026c <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f0100255:	c7 04 24 6d 48 10 f0 	movl   $0xf010486d,(%esp)
f010025c:	e8 05 2d 00 00       	call   f0102f66 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100261:	ba 92 00 00 00       	mov    $0x92,%edx
f0100266:	b8 03 00 00 00       	mov    $0x3,%eax
f010026b:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010026c:	89 d8                	mov    %ebx,%eax
f010026e:	83 c4 14             	add    $0x14,%esp
f0100271:	5b                   	pop    %ebx
f0100272:	5d                   	pop    %ebp
f0100273:	c3                   	ret    

f0100274 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f0100274:	55                   	push   %ebp
f0100275:	89 e5                	mov    %esp,%ebp
f0100277:	53                   	push   %ebx
f0100278:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010027d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100282:	89 da                	mov    %ebx,%edx
f0100284:	ee                   	out    %al,(%dx)
f0100285:	b2 fb                	mov    $0xfb,%dl
f0100287:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010028c:	ee                   	out    %al,(%dx)
f010028d:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100292:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100297:	89 ca                	mov    %ecx,%edx
f0100299:	ee                   	out    %al,(%dx)
f010029a:	b2 f9                	mov    $0xf9,%dl
f010029c:	b8 00 00 00 00       	mov    $0x0,%eax
f01002a1:	ee                   	out    %al,(%dx)
f01002a2:	b2 fb                	mov    $0xfb,%dl
f01002a4:	b8 03 00 00 00       	mov    $0x3,%eax
f01002a9:	ee                   	out    %al,(%dx)
f01002aa:	b2 fc                	mov    $0xfc,%dl
f01002ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01002b1:	ee                   	out    %al,(%dx)
f01002b2:	b2 f9                	mov    $0xf9,%dl
f01002b4:	b8 01 00 00 00       	mov    $0x1,%eax
f01002b9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ba:	b2 fd                	mov    $0xfd,%dl
f01002bc:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01002bd:	3c ff                	cmp    $0xff,%al
f01002bf:	0f 95 c0             	setne  %al
f01002c2:	0f b6 c0             	movzbl %al,%eax
f01002c5:	a3 20 2b 17 f0       	mov    %eax,0xf0172b20
f01002ca:	89 da                	mov    %ebx,%edx
f01002cc:	ec                   	in     (%dx),%al
f01002cd:	89 ca                	mov    %ecx,%edx
f01002cf:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f01002d0:	5b                   	pop    %ebx
f01002d1:	5d                   	pop    %ebp
f01002d2:	c3                   	ret    

f01002d3 <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f01002d3:	55                   	push   %ebp
f01002d4:	89 e5                	mov    %esp,%ebp
f01002d6:	83 ec 0c             	sub    $0xc,%esp
f01002d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01002dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01002df:	89 7d fc             	mov    %edi,-0x4(%ebp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01002e2:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01002e9:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01002f0:	5a a5 
	if (*cp != 0xA55A) {
f01002f2:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01002f9:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01002fd:	74 11                	je     f0100310 <cga_init+0x3d>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01002ff:	c7 05 24 2b 17 f0 b4 	movl   $0x3b4,0xf0172b24
f0100306:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100309:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010030e:	eb 16                	jmp    f0100326 <cga_init+0x53>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100310:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100317:	c7 05 24 2b 17 f0 d4 	movl   $0x3d4,0xf0172b24
f010031e:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100321:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100326:	8b 0d 24 2b 17 f0    	mov    0xf0172b24,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100331:	89 ca                	mov    %ecx,%edx
f0100333:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100334:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100337:	89 da                	mov    %ebx,%edx
f0100339:	ec                   	in     (%dx),%al
f010033a:	0f b6 f8             	movzbl %al,%edi
f010033d:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100340:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100345:	89 ca                	mov    %ecx,%edx
f0100347:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100348:	89 da                	mov    %ebx,%edx
f010034a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010034b:	89 35 28 2b 17 f0    	mov    %esi,0xf0172b28
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100351:	0f b6 d8             	movzbl %al,%ebx
f0100354:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100356:	66 89 3d 2c 2b 17 f0 	mov    %di,0xf0172b2c
}
f010035d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100360:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100363:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100366:	89 ec                	mov    %ebp,%esp
f0100368:	5d                   	pop    %ebp
f0100369:	c3                   	ret    

f010036a <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f010036a:	55                   	push   %ebp
f010036b:	89 e5                	mov    %esp,%ebp
}
f010036d:	5d                   	pop    %ebp
f010036e:	c3                   	ret    

f010036f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f010036f:	55                   	push   %ebp
f0100370:	89 e5                	mov    %esp,%ebp
f0100372:	53                   	push   %ebx
f0100373:	83 ec 04             	sub    $0x4,%esp
f0100376:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100379:	eb 25                	jmp    f01003a0 <cons_intr+0x31>
		if (c == 0)
f010037b:	85 c0                	test   %eax,%eax
f010037d:	74 21                	je     f01003a0 <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f010037f:	8b 15 44 2d 17 f0    	mov    0xf0172d44,%edx
f0100385:	88 82 40 2b 17 f0    	mov    %al,-0xfe8d4c0(%edx)
f010038b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010038e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100393:	ba 00 00 00 00       	mov    $0x0,%edx
f0100398:	0f 44 c2             	cmove  %edx,%eax
f010039b:	a3 44 2d 17 f0       	mov    %eax,0xf0172d44
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01003a0:	ff d3                	call   *%ebx
f01003a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01003a5:	75 d4                	jne    f010037b <cons_intr+0xc>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01003a7:	83 c4 04             	add    $0x4,%esp
f01003aa:	5b                   	pop    %ebx
f01003ab:	5d                   	pop    %ebp
f01003ac:	c3                   	ret    

f01003ad <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01003ad:	55                   	push   %ebp
f01003ae:	89 e5                	mov    %esp,%ebp
f01003b0:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f01003b3:	c7 04 24 74 01 10 f0 	movl   $0xf0100174,(%esp)
f01003ba:	e8 b0 ff ff ff       	call   f010036f <cons_intr>
}
f01003bf:	c9                   	leave  
f01003c0:	c3                   	ret    

f01003c1 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01003c1:	55                   	push   %ebp
f01003c2:	89 e5                	mov    %esp,%ebp
f01003c4:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f01003c7:	83 3d 20 2b 17 f0 00 	cmpl   $0x0,0xf0172b20
f01003ce:	74 0c                	je     f01003dc <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f01003d0:	c7 04 24 58 01 10 f0 	movl   $0xf0100158,(%esp)
f01003d7:	e8 93 ff ff ff       	call   f010036f <cons_intr>
}
f01003dc:	c9                   	leave  
f01003dd:	c3                   	ret    

f01003de <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01003de:	55                   	push   %ebp
f01003df:	89 e5                	mov    %esp,%ebp
f01003e1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01003e4:	e8 d8 ff ff ff       	call   f01003c1 <serial_intr>
	kbd_intr();
f01003e9:	e8 bf ff ff ff       	call   f01003ad <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01003ee:	8b 15 40 2d 17 f0    	mov    0xf0172d40,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f01003f4:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01003f9:	3b 15 44 2d 17 f0    	cmp    0xf0172d44,%edx
f01003ff:	74 1e                	je     f010041f <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100401:	0f b6 82 40 2b 17 f0 	movzbl -0xfe8d4c0(%edx),%eax
f0100408:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f010040b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100411:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100416:	0f 44 d1             	cmove  %ecx,%edx
f0100419:	89 15 40 2d 17 f0    	mov    %edx,0xf0172d40
		return c;
	}
	return 0;
}
f010041f:	c9                   	leave  
f0100420:	c3                   	ret    

f0100421 <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f0100421:	55                   	push   %ebp
f0100422:	89 e5                	mov    %esp,%ebp
f0100424:	57                   	push   %edi
f0100425:	56                   	push   %esi
f0100426:	53                   	push   %ebx
f0100427:	83 ec 1c             	sub    $0x1c,%esp
f010042a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010042d:	ba 79 03 00 00       	mov    $0x379,%edx
f0100432:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100433:	84 c0                	test   %al,%al
f0100435:	78 21                	js     f0100458 <cons_putc+0x37>
f0100437:	bb 00 32 00 00       	mov    $0x3200,%ebx
f010043c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100441:	be 79 03 00 00       	mov    $0x379,%esi
f0100446:	89 ca                	mov    %ecx,%edx
f0100448:	ec                   	in     (%dx),%al
f0100449:	ec                   	in     (%dx),%al
f010044a:	ec                   	in     (%dx),%al
f010044b:	ec                   	in     (%dx),%al
f010044c:	89 f2                	mov    %esi,%edx
f010044e:	ec                   	in     (%dx),%al
f010044f:	84 c0                	test   %al,%al
f0100451:	78 05                	js     f0100458 <cons_putc+0x37>
f0100453:	83 eb 01             	sub    $0x1,%ebx
f0100456:	75 ee                	jne    f0100446 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100458:	ba 78 03 00 00       	mov    $0x378,%edx
f010045d:	89 f8                	mov    %edi,%eax
f010045f:	ee                   	out    %al,(%dx)
f0100460:	b2 7a                	mov    $0x7a,%dl
f0100462:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100467:	ee                   	out    %al,(%dx)
f0100468:	b8 08 00 00 00       	mov    $0x8,%eax
f010046d:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f010046e:	89 3c 24             	mov    %edi,(%esp)
f0100471:	e8 08 00 00 00       	call   f010047e <cga_putc>
}
f0100476:	83 c4 1c             	add    $0x1c,%esp
f0100479:	5b                   	pop    %ebx
f010047a:	5e                   	pop    %esi
f010047b:	5f                   	pop    %edi
f010047c:	5d                   	pop    %ebp
f010047d:	c3                   	ret    

f010047e <cga_putc>:



void
cga_putc(int c)
{
f010047e:	55                   	push   %ebp
f010047f:	89 e5                	mov    %esp,%ebp
f0100481:	56                   	push   %esi
f0100482:	53                   	push   %ebx
f0100483:	83 ec 10             	sub    $0x10,%esp
f0100486:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	// whether are 15-8 bits zero?If they are set 8,9,10 bit 1,If not continue.
	if (!(c & ~0xFF))
f0100489:	89 c1                	mov    %eax,%ecx
f010048b:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0a00;
f0100491:	89 c2                	mov    %eax,%edx
f0100493:	80 ce 0a             	or     $0xa,%dh
f0100496:	85 c9                	test   %ecx,%ecx
f0100498:	0f 44 c2             	cmove  %edx,%eax

	// whether are low 8 bits '\b','\n','\r','\t'?If they are,preform corresponding operation.
	switch (c & 0xff) {
f010049b:	0f b6 d0             	movzbl %al,%edx
f010049e:	83 ea 08             	sub    $0x8,%edx
f01004a1:	83 fa 72             	cmp    $0x72,%edx
f01004a4:	0f 87 67 01 00 00    	ja     f0100611 <cga_putc+0x193>
f01004aa:	ff 24 95 a0 48 10 f0 	jmp    *-0xfefb760(,%edx,4)
	case '\b':
		if (crt_pos > 0) {
f01004b1:	0f b7 15 2c 2b 17 f0 	movzwl 0xf0172b2c,%edx
f01004b8:	66 85 d2             	test   %dx,%dx
f01004bb:	0f 84 bb 01 00 00    	je     f010067c <cga_putc+0x1fe>
			crt_pos--;
f01004c1:	83 ea 01             	sub    $0x1,%edx
f01004c4:	66 89 15 2c 2b 17 f0 	mov    %dx,0xf0172b2c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004cb:	0f b7 d2             	movzwl %dx,%edx
f01004ce:	b0 00                	mov    $0x0,%al
f01004d0:	89 c1                	mov    %eax,%ecx
f01004d2:	83 c9 20             	or     $0x20,%ecx
f01004d5:	a1 28 2b 17 f0       	mov    0xf0172b28,%eax
f01004da:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01004de:	e9 4c 01 00 00       	jmp    f010062f <cga_putc+0x1b1>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e3:	66 83 05 2c 2b 17 f0 	addw   $0x50,0xf0172b2c
f01004ea:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004eb:	0f b7 05 2c 2b 17 f0 	movzwl 0xf0172b2c,%eax
f01004f2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f8:	c1 e8 16             	shr    $0x16,%eax
f01004fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fe:	c1 e0 04             	shl    $0x4,%eax
f0100501:	66 a3 2c 2b 17 f0    	mov    %ax,0xf0172b2c
		break;
f0100507:	e9 23 01 00 00       	jmp    f010062f <cga_putc+0x1b1>
	case '\t':
		cons_putc(' ');
f010050c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100513:	e8 09 ff ff ff       	call   f0100421 <cons_putc>
		cons_putc(' ');
f0100518:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010051f:	e8 fd fe ff ff       	call   f0100421 <cons_putc>
		cons_putc(' ');
f0100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010052b:	e8 f1 fe ff ff       	call   f0100421 <cons_putc>
		cons_putc(' ');
f0100530:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100537:	e8 e5 fe ff ff       	call   f0100421 <cons_putc>
		cons_putc(' ');
f010053c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100543:	e8 d9 fe ff ff       	call   f0100421 <cons_putc>
		break;
f0100548:	e9 e2 00 00 00       	jmp    f010062f <cga_putc+0x1b1>
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0c00;
f010054d:	0f b7 15 2c 2b 17 f0 	movzwl 0xf0172b2c,%edx
f0100554:	0f b7 da             	movzwl %dx,%ebx
f0100557:	80 e4 f0             	and    $0xf0,%ah
f010055a:	80 cc 0c             	or     $0xc,%ah
f010055d:	8b 0d 28 2b 17 f0    	mov    0xf0172b28,%ecx
f0100563:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100567:	83 c2 01             	add    $0x1,%edx
f010056a:	66 89 15 2c 2b 17 f0 	mov    %dx,0xf0172b2c
		break;
f0100571:	e9 b9 00 00 00       	jmp    f010062f <cga_putc+0x1b1>
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0900;
f0100576:	0f b7 15 2c 2b 17 f0 	movzwl 0xf0172b2c,%edx
f010057d:	0f b7 da             	movzwl %dx,%ebx
f0100580:	80 e4 f0             	and    $0xf0,%ah
f0100583:	80 cc 09             	or     $0x9,%ah
f0100586:	8b 0d 28 2b 17 f0    	mov    0xf0172b28,%ecx
f010058c:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100590:	83 c2 01             	add    $0x1,%edx
f0100593:	66 89 15 2c 2b 17 f0 	mov    %dx,0xf0172b2c
		break;
f010059a:	e9 90 00 00 00       	jmp    f010062f <cga_putc+0x1b1>
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0100;
f010059f:	0f b7 15 2c 2b 17 f0 	movzwl 0xf0172b2c,%edx
f01005a6:	0f b7 da             	movzwl %dx,%ebx
f01005a9:	80 e4 f0             	and    $0xf0,%ah
f01005ac:	80 cc 01             	or     $0x1,%ah
f01005af:	8b 0d 28 2b 17 f0    	mov    0xf0172b28,%ecx
f01005b5:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005b9:	83 c2 01             	add    $0x1,%edx
f01005bc:	66 89 15 2c 2b 17 f0 	mov    %dx,0xf0172b2c
		break;
f01005c3:	eb 6a                	jmp    f010062f <cga_putc+0x1b1>
	case '%':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0e00;
f01005c5:	0f b7 15 2c 2b 17 f0 	movzwl 0xf0172b2c,%edx
f01005cc:	0f b7 da             	movzwl %dx,%ebx
f01005cf:	80 e4 f0             	and    $0xf0,%ah
f01005d2:	80 cc 0e             	or     $0xe,%ah
f01005d5:	8b 0d 28 2b 17 f0    	mov    0xf0172b28,%ecx
f01005db:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005df:	83 c2 01             	add    $0x1,%edx
f01005e2:	66 89 15 2c 2b 17 f0 	mov    %dx,0xf0172b2c
		break;
f01005e9:	eb 44                	jmp    f010062f <cga_putc+0x1b1>
	case '&':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0d00;
f01005eb:	0f b7 15 2c 2b 17 f0 	movzwl 0xf0172b2c,%edx
f01005f2:	0f b7 da             	movzwl %dx,%ebx
f01005f5:	80 e4 f0             	and    $0xf0,%ah
f01005f8:	80 cc 0d             	or     $0xd,%ah
f01005fb:	8b 0d 28 2b 17 f0    	mov    0xf0172b28,%ecx
f0100601:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100605:	83 c2 01             	add    $0x1,%edx
f0100608:	66 89 15 2c 2b 17 f0 	mov    %dx,0xf0172b2c
		break;
f010060f:	eb 1e                	jmp    f010062f <cga_putc+0x1b1>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100611:	0f b7 15 2c 2b 17 f0 	movzwl 0xf0172b2c,%edx
f0100618:	0f b7 da             	movzwl %dx,%ebx
f010061b:	8b 0d 28 2b 17 f0    	mov    0xf0172b28,%ecx
f0100621:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100625:	83 c2 01             	add    $0x1,%edx
f0100628:	66 89 15 2c 2b 17 f0 	mov    %dx,0xf0172b2c
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010062f:	66 81 3d 2c 2b 17 f0 	cmpw   $0x7cf,0xf0172b2c
f0100636:	cf 07 
f0100638:	76 42                	jbe    f010067c <cga_putc+0x1fe>
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010063a:	a1 28 2b 17 f0       	mov    0xf0172b28,%eax
f010063f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100646:	00 
f0100647:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010064d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100651:	89 04 24             	mov    %eax,(%esp)
f0100654:	e8 31 3d 00 00       	call   f010438a <memmove>
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0c00 | ' ';
f0100659:	8b 15 28 2b 17 f0    	mov    0xf0172b28,%edx
	if (crt_pos >= CRT_SIZE) {
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010065f:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0c00 | ' ';
f0100664:	66 c7 04 42 20 0c    	movw   $0xc20,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) {
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010066a:	83 c0 01             	add    $0x1,%eax
f010066d:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100672:	75 f0                	jne    f0100664 <cga_putc+0x1e6>
			crt_buf[i] = 0x0c00 | ' ';
		// Fix the position of screen;[Comment out this line and the screen will turn pure black]
		crt_pos -= CRT_COLS;
f0100674:	66 83 2d 2c 2b 17 f0 	subw   $0x50,0xf0172b2c
f010067b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010067c:	8b 0d 24 2b 17 f0    	mov    0xf0172b24,%ecx
f0100682:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100687:	89 ca                	mov    %ecx,%edx
f0100689:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010068a:	0f b7 35 2c 2b 17 f0 	movzwl 0xf0172b2c,%esi
f0100691:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100694:	89 f0                	mov    %esi,%eax
f0100696:	66 c1 e8 08          	shr    $0x8,%ax
f010069a:	89 da                	mov    %ebx,%edx
f010069c:	ee                   	out    %al,(%dx)
f010069d:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a2:	89 ca                	mov    %ecx,%edx
f01006a4:	ee                   	out    %al,(%dx)
f01006a5:	89 f0                	mov    %esi,%eax
f01006a7:	89 da                	mov    %ebx,%edx
f01006a9:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f01006aa:	83 c4 10             	add    $0x10,%esp
f01006ad:	5b                   	pop    %ebx
f01006ae:	5e                   	pop    %esi
f01006af:	5d                   	pop    %ebp
f01006b0:	c3                   	ret    

f01006b1 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006b1:	55                   	push   %ebp
f01006b2:	89 e5                	mov    %esp,%ebp
f01006b4:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f01006b7:	e8 17 fc ff ff       	call   f01002d3 <cga_init>
	kbd_init();
	serial_init();
f01006bc:	e8 b3 fb ff ff       	call   f0100274 <serial_init>

	if (!serial_exists)
f01006c1:	83 3d 20 2b 17 f0 00 	cmpl   $0x0,0xf0172b20
f01006c8:	75 0c                	jne    f01006d6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01006ca:	c7 04 24 79 48 10 f0 	movl   $0xf0104879,(%esp)
f01006d1:	e8 90 28 00 00       	call   f0102f66 <cprintf>
}
f01006d6:	c9                   	leave  
f01006d7:	c3                   	ret    

f01006d8 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006d8:	55                   	push   %ebp
f01006d9:	89 e5                	mov    %esp,%ebp
f01006db:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006de:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e1:	89 04 24             	mov    %eax,(%esp)
f01006e4:	e8 38 fd ff ff       	call   f0100421 <cons_putc>
}
f01006e9:	c9                   	leave  
f01006ea:	c3                   	ret    

f01006eb <getchar>:

int
getchar(void)
{
f01006eb:	55                   	push   %ebp
f01006ec:	89 e5                	mov    %esp,%ebp
f01006ee:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006f1:	e8 e8 fc ff ff       	call   f01003de <cons_getc>
f01006f6:	85 c0                	test   %eax,%eax
f01006f8:	74 f7                	je     f01006f1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006fa:	c9                   	leave  
f01006fb:	c3                   	ret    

f01006fc <iscons>:

int
iscons(int fdnum)
{
f01006fc:	55                   	push   %ebp
f01006fd:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006ff:	b8 01 00 00 00       	mov    $0x1,%eax
f0100704:	5d                   	pop    %ebp
f0100705:	c3                   	ret    
	...

f0100710 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100710:	55                   	push   %ebp
f0100711:	89 e5                	mov    %esp,%ebp
f0100713:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100716:	c7 04 24 90 4c 10 f0 	movl   $0xf0104c90,(%esp)
f010071d:	e8 44 28 00 00       	call   f0102f66 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100722:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100729:	00 
f010072a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100731:	f0 
f0100732:	c7 04 24 5c 4d 10 f0 	movl   $0xf0104d5c,(%esp)
f0100739:	e8 28 28 00 00       	call   f0102f66 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010073e:	c7 44 24 08 05 48 10 	movl   $0x104805,0x8(%esp)
f0100745:	00 
f0100746:	c7 44 24 04 05 48 10 	movl   $0xf0104805,0x4(%esp)
f010074d:	f0 
f010074e:	c7 04 24 80 4d 10 f0 	movl   $0xf0104d80,(%esp)
f0100755:	e8 0c 28 00 00       	call   f0102f66 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010075a:	c7 44 24 08 e5 2a 17 	movl   $0x172ae5,0x8(%esp)
f0100761:	00 
f0100762:	c7 44 24 04 e5 2a 17 	movl   $0xf0172ae5,0x4(%esp)
f0100769:	f0 
f010076a:	c7 04 24 a4 4d 10 f0 	movl   $0xf0104da4,(%esp)
f0100771:	e8 f0 27 00 00       	call   f0102f66 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100776:	c7 44 24 08 10 3a 17 	movl   $0x173a10,0x8(%esp)
f010077d:	00 
f010077e:	c7 44 24 04 10 3a 17 	movl   $0xf0173a10,0x4(%esp)
f0100785:	f0 
f0100786:	c7 04 24 c8 4d 10 f0 	movl   $0xf0104dc8,(%esp)
f010078d:	e8 d4 27 00 00       	call   f0102f66 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f0100792:	b8 0f 3e 17 f0       	mov    $0xf0173e0f,%eax
f0100797:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010079c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007a2:	85 c0                	test   %eax,%eax
f01007a4:	0f 48 c2             	cmovs  %edx,%eax
f01007a7:	c1 f8 0a             	sar    $0xa,%eax
f01007aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ae:	c7 04 24 ec 4d 10 f0 	movl   $0xf0104dec,(%esp)
f01007b5:	e8 ac 27 00 00       	call   f0102f66 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f01007ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bf:	c9                   	leave  
f01007c0:	c3                   	ret    

f01007c1 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c1:	55                   	push   %ebp
f01007c2:	89 e5                	mov    %esp,%ebp
f01007c4:	53                   	push   %ebx
f01007c5:	83 ec 14             	sub    $0x14,%esp
f01007c8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007cd:	8b 83 e4 4e 10 f0    	mov    -0xfefb11c(%ebx),%eax
f01007d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d7:	8b 83 e0 4e 10 f0    	mov    -0xfefb120(%ebx),%eax
f01007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007e1:	c7 04 24 a9 4c 10 f0 	movl   $0xf0104ca9,(%esp)
f01007e8:	e8 79 27 00 00       	call   f0102f66 <cprintf>
f01007ed:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01007f0:	83 fb 24             	cmp    $0x24,%ebx
f01007f3:	75 d8                	jne    f01007cd <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01007f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fa:	83 c4 14             	add    $0x14,%esp
f01007fd:	5b                   	pop    %ebx
f01007fe:	5d                   	pop    %ebp
f01007ff:	c3                   	ret    

f0100800 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100800:	55                   	push   %ebp
f0100801:	89 e5                	mov    %esp,%ebp
f0100803:	57                   	push   %edi
f0100804:	56                   	push   %esi
f0100805:	53                   	push   %ebx
f0100806:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100809:	c7 04 24 18 4e 10 f0 	movl   $0xf0104e18,(%esp)
f0100810:	e8 51 27 00 00       	call   f0102f66 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100815:	c7 04 24 3c 4e 10 f0 	movl   $0xf0104e3c,(%esp)
f010081c:	e8 45 27 00 00       	call   f0102f66 <cprintf>

	if (tf != NULL)
f0100821:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100825:	74 0b                	je     f0100832 <monitor+0x32>
		print_trapframe(tf);
f0100827:	8b 45 08             	mov    0x8(%ebp),%eax
f010082a:	89 04 24             	mov    %eax,(%esp)
f010082d:	e8 88 2b 00 00       	call   f01033ba <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100832:	c7 04 24 b2 4c 10 f0 	movl   $0xf0104cb2,(%esp)
f0100839:	e8 b2 38 00 00       	call   f01040f0 <readline>
f010083e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100840:	85 c0                	test   %eax,%eax
f0100842:	74 ee                	je     f0100832 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100844:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010084b:	be 00 00 00 00       	mov    $0x0,%esi
f0100850:	eb 06                	jmp    f0100858 <monitor+0x58>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100852:	c6 03 00             	movb   $0x0,(%ebx)
f0100855:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100858:	0f b6 03             	movzbl (%ebx),%eax
f010085b:	84 c0                	test   %al,%al
f010085d:	74 6c                	je     f01008cb <monitor+0xcb>
f010085f:	0f be c0             	movsbl %al,%eax
f0100862:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100866:	c7 04 24 b6 4c 10 f0 	movl   $0xf0104cb6,(%esp)
f010086d:	e8 99 3a 00 00       	call   f010430b <strchr>
f0100872:	85 c0                	test   %eax,%eax
f0100874:	75 dc                	jne    f0100852 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100876:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100879:	74 50                	je     f01008cb <monitor+0xcb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010087b:	83 fe 0f             	cmp    $0xf,%esi
f010087e:	66 90                	xchg   %ax,%ax
f0100880:	75 16                	jne    f0100898 <monitor+0x98>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100882:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100889:	00 
f010088a:	c7 04 24 bb 4c 10 f0 	movl   $0xf0104cbb,(%esp)
f0100891:	e8 d0 26 00 00       	call   f0102f66 <cprintf>
f0100896:	eb 9a                	jmp    f0100832 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100898:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010089c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010089f:	0f b6 03             	movzbl (%ebx),%eax
f01008a2:	84 c0                	test   %al,%al
f01008a4:	75 0c                	jne    f01008b2 <monitor+0xb2>
f01008a6:	eb b0                	jmp    f0100858 <monitor+0x58>
			buf++;
f01008a8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ab:	0f b6 03             	movzbl (%ebx),%eax
f01008ae:	84 c0                	test   %al,%al
f01008b0:	74 a6                	je     f0100858 <monitor+0x58>
f01008b2:	0f be c0             	movsbl %al,%eax
f01008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b9:	c7 04 24 b6 4c 10 f0 	movl   $0xf0104cb6,(%esp)
f01008c0:	e8 46 3a 00 00       	call   f010430b <strchr>
f01008c5:	85 c0                	test   %eax,%eax
f01008c7:	74 df                	je     f01008a8 <monitor+0xa8>
f01008c9:	eb 8d                	jmp    f0100858 <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f01008cb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008d2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008d3:	85 f6                	test   %esi,%esi
f01008d5:	0f 84 57 ff ff ff    	je     f0100832 <monitor+0x32>
f01008db:	bb e0 4e 10 f0       	mov    $0xf0104ee0,%ebx
f01008e0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e5:	8b 03                	mov    (%ebx),%eax
f01008e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008eb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ee:	89 04 24             	mov    %eax,(%esp)
f01008f1:	e8 9a 39 00 00       	call   f0104290 <strcmp>
f01008f6:	85 c0                	test   %eax,%eax
f01008f8:	75 24                	jne    f010091e <monitor+0x11e>
			return commands[i].func(argc, argv, tf);
f01008fa:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008fd:	8b 55 08             	mov    0x8(%ebp),%edx
f0100900:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100904:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100907:	89 54 24 04          	mov    %edx,0x4(%esp)
f010090b:	89 34 24             	mov    %esi,(%esp)
f010090e:	ff 14 85 e8 4e 10 f0 	call   *-0xfefb118(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100915:	85 c0                	test   %eax,%eax
f0100917:	78 28                	js     f0100941 <monitor+0x141>
f0100919:	e9 14 ff ff ff       	jmp    f0100832 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010091e:	83 c7 01             	add    $0x1,%edi
f0100921:	83 c3 0c             	add    $0xc,%ebx
f0100924:	83 ff 03             	cmp    $0x3,%edi
f0100927:	75 bc                	jne    f01008e5 <monitor+0xe5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100929:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010092c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100930:	c7 04 24 d8 4c 10 f0 	movl   $0xf0104cd8,(%esp)
f0100937:	e8 2a 26 00 00       	call   f0102f66 <cprintf>
f010093c:	e9 f1 fe ff ff       	jmp    f0100832 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100941:	83 c4 5c             	add    $0x5c,%esp
f0100944:	5b                   	pop    %ebx
f0100945:	5e                   	pop    %esi
f0100946:	5f                   	pop    %edi
f0100947:	5d                   	pop    %ebp
f0100948:	c3                   	ret    

f0100949 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100949:	55                   	push   %ebp
f010094a:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010094c:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010094f:	5d                   	pop    %ebp
f0100950:	c3                   	ret    

f0100951 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100951:	55                   	push   %ebp
f0100952:	89 e5                	mov    %esp,%ebp
f0100954:	57                   	push   %edi
f0100955:	56                   	push   %esi
f0100956:	53                   	push   %ebx
f0100957:	83 ec 4c             	sub    $0x4c,%esp
	unsigned int ebp;
	unsigned int eip;
	struct Eipdebuginfo debug_info;
	int i;	// loop

	cprintf("Stack backtrace:\n");
f010095a:	c7 04 24 ee 4c 10 f0 	movl   $0xf0104cee,(%esp)
f0100961:	e8 00 26 00 00       	call   f0102f66 <cprintf>
	// current eip and print current function.
	// cprintf is a function so init after it in case.
	eip = read_eip();
f0100966:	e8 de ff ff ff       	call   f0100949 <read_eip>
f010096b:	89 c7                	mov    %eax,%edi

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010096d:	89 ea                	mov    %ebp,%edx
f010096f:	89 d6                	mov    %edx,%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
f0100971:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf is a function so init after it in case.
	eip = read_eip();
	ebp = read_ebp();

	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f0100976:	85 d2                	test   %edx,%edx
f0100978:	0f 84 cd 00 00 00    	je     f0100a4b <mon_backtrace+0xfa>
	{
		if (debuginfo_eip(eip, &debug_info) >= 0)
f010097e:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100981:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100985:	89 3c 24             	mov    %edi,(%esp)
f0100988:	e8 41 2f 00 00       	call   f01038ce <debuginfo_eip>
f010098d:	85 c0                	test   %eax,%eax
f010098f:	0f 88 a5 00 00 00    	js     f0100a3a <mon_backtrace+0xe9>
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
f0100995:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100998:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010099f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a3:	c7 04 24 4b 48 10 f0 	movl   $0xf010484b,(%esp)
f01009aa:	e8 b7 25 00 00       	call   f0102f66 <cprintf>
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f01009af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01009b3:	7e 24                	jle    f01009d9 <mon_backtrace+0x88>
f01009b5:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
f01009ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009bd:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f01009c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009c5:	c7 04 24 00 4d 10 f0 	movl   $0xf0104d00,(%esp)
f01009cc:	e8 95 25 00 00       	call   f0102f66 <cprintf>
	while (ebp != 0)
	{
		if (debuginfo_eip(eip, &debug_info) >= 0)
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f01009d1:	83 c3 01             	add    $0x1,%ebx
f01009d4:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01009d7:	7f e1                	jg     f01009ba <mon_backtrace+0x69>
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
			}
			cprintf("+%x -%d\n", eip-debug_info.eip_fn_addr, debug_info.eip_fn_narg);
f01009d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009e0:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01009e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01009e7:	c7 04 24 03 4d 10 f0 	movl   $0xf0104d03,(%esp)
f01009ee:	e8 73 25 00 00       	call   f0102f66 <cprintf>
		{
			cprintf("debuginfo_eip() failed\n");
			return -1;
		}

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
f01009f3:	8b 46 14             	mov    0x14(%esi),%eax
f01009f6:	89 44 24 18          	mov    %eax,0x18(%esp)
f01009fa:	8b 46 10             	mov    0x10(%esi),%eax
f01009fd:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100a01:	8b 46 0c             	mov    0xc(%esi),%eax
f0100a04:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100a08:	8b 46 08             	mov    0x8(%esi),%eax
f0100a0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a0f:	8b 46 04             	mov    0x4(%esi),%eax
f0100a12:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a16:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a1a:	c7 04 24 64 4e 10 f0 	movl   $0xf0104e64,(%esp)
f0100a21:	e8 40 25 00 00       	call   f0102f66 <cprintf>
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
f0100a26:	8b 7e 04             	mov    0x4(%esi),%edi
		ebp = *(unsigned int *)ebp;
f0100a29:	8b 36                	mov    (%esi),%esi
	// cprintf is a function so init after it in case.
	eip = read_eip();
	ebp = read_ebp();

	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f0100a2b:	85 f6                	test   %esi,%esi
f0100a2d:	0f 85 4b ff ff ff    	jne    f010097e <mon_backtrace+0x2d>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
f0100a33:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a38:	eb 11                	jmp    f0100a4b <mon_backtrace+0xfa>
			}
			cprintf("+%x -%d\n", eip-debug_info.eip_fn_addr, debug_info.eip_fn_narg);
		}
		else
		{
			cprintf("debuginfo_eip() failed\n");
f0100a3a:	c7 04 24 0c 4d 10 f0 	movl   $0xf0104d0c,(%esp)
f0100a41:	e8 20 25 00 00       	call   f0102f66 <cprintf>
			return -1;
f0100a46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
}
f0100a4b:	83 c4 4c             	add    $0x4c,%esp
f0100a4e:	5b                   	pop    %ebx
f0100a4f:	5e                   	pop    %esi
f0100a50:	5f                   	pop    %edi
f0100a51:	5d                   	pop    %ebp
f0100a52:	c3                   	ret    
	...

f0100a60 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0100a60:	55                   	push   %ebp
f0100a61:	89 e5                	mov    %esp,%ebp
f0100a63:	83 ec 08             	sub    $0x8,%esp
f0100a66:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100a69:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100a6c:	89 c6                	mov    %eax,%esi
f0100a6e:	89 d1                	mov    %edx,%ecx
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
		boot_freemem = end;
f0100a70:	83 3d 54 2d 17 f0 00 	cmpl   $0x0,0xf0172d54

	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	boot_freemem = ROUNDUP(boot_freemem, align);
f0100a77:	b8 10 3a 17 f0       	mov    $0xf0173a10,%eax
f0100a7c:	0f 45 05 54 2d 17 f0 	cmovne 0xf0172d54,%eax
f0100a83:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
f0100a87:	89 d8                	mov    %ebx,%eax
f0100a89:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a8e:	f7 f1                	div    %ecx
f0100a90:	29 d3                	sub    %edx,%ebx
	//	Step 2: save current value of boot_freemem as allocated chunk
	v = boot_freemem;
	//	Step 3: increase boot_freemem to record allocation
	boot_freemem += ROUNDUP(n, align);
f0100a92:	8d 74 0e ff          	lea    -0x1(%esi,%ecx,1),%esi
f0100a96:	89 f0                	mov    %esi,%eax
f0100a98:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a9d:	f7 f1                	div    %ecx
f0100a9f:	29 d6                	sub    %edx,%esi
f0100aa1:	01 de                	add    %ebx,%esi
f0100aa3:	89 35 54 2d 17 f0    	mov    %esi,0xf0172d54
	//	Step 4: return allocated chunk
	return v;
}
f0100aa9:	89 d8                	mov    %ebx,%eax
f0100aab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100aae:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100ab1:	89 ec                	mov    %ebp,%esp
f0100ab3:	5d                   	pop    %ebp
f0100ab4:	c3                   	ret    

f0100ab5 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ab5:	55                   	push   %ebp
f0100ab6:	89 e5                	mov    %esp,%ebp
f0100ab8:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100abb:	89 d1                	mov    %edx,%ecx
f0100abd:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ac0:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ac8:	f6 c1 01             	test   $0x1,%cl
f0100acb:	74 57                	je     f0100b24 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100acd:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100ad3:	89 c8                	mov    %ecx,%eax
f0100ad5:	c1 e8 0c             	shr    $0xc,%eax
f0100ad8:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0100ade:	72 20                	jb     f0100b00 <check_va2pa+0x4b>
f0100ae0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100ae4:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f0100aeb:	f0 
f0100aec:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0100af3:	00 
f0100af4:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0100afb:	e8 bb f5 ff ff       	call   f01000bb <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b00:	c1 ea 0c             	shr    $0xc,%edx
f0100b03:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b09:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100b10:	89 c2                	mov    %eax,%edx
f0100b12:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b1a:	85 d2                	test   %edx,%edx
f0100b1c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b21:	0f 44 c2             	cmove  %edx,%eax
}
f0100b24:	c9                   	leave  
f0100b25:	c3                   	ret    

f0100b26 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0100b26:	55                   	push   %ebp
f0100b27:	89 e5                	mov    %esp,%ebp
f0100b29:	83 ec 18             	sub    $0x18,%esp
f0100b2c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100b2f:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100b32:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b34:	89 04 24             	mov    %eax,(%esp)
f0100b37:	e8 bc 23 00 00       	call   f0102ef8 <mc146818_read>
f0100b3c:	89 c6                	mov    %eax,%esi
f0100b3e:	83 c3 01             	add    $0x1,%ebx
f0100b41:	89 1c 24             	mov    %ebx,(%esp)
f0100b44:	e8 af 23 00 00       	call   f0102ef8 <mc146818_read>
f0100b49:	c1 e0 08             	shl    $0x8,%eax
f0100b4c:	09 f0                	or     %esi,%eax
}
f0100b4e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100b51:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100b54:	89 ec                	mov    %ebp,%esp
f0100b56:	5d                   	pop    %ebp
f0100b57:	c3                   	ret    

f0100b58 <i386_detect_memory>:

void
i386_detect_memory(void)
{
f0100b58:	55                   	push   %ebp
f0100b59:	89 e5                	mov    %esp,%ebp
f0100b5b:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0100b5e:	b8 15 00 00 00       	mov    $0x15,%eax
f0100b63:	e8 be ff ff ff       	call   f0100b26 <nvram_read>
f0100b68:	c1 e0 0a             	shl    $0xa,%eax
f0100b6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b70:	a3 48 2d 17 f0       	mov    %eax,0xf0172d48
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0100b75:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b7a:	e8 a7 ff ff ff       	call   f0100b26 <nvram_read>
f0100b7f:	c1 e0 0a             	shl    $0xa,%eax
f0100b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b87:	a3 4c 2d 17 f0       	mov    %eax,0xf0172d4c

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0100b8c:	85 c0                	test   %eax,%eax
f0100b8e:	74 0c                	je     f0100b9c <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0100b90:	05 00 00 10 00       	add    $0x100000,%eax
f0100b95:	a3 50 2d 17 f0       	mov    %eax,0xf0172d50
f0100b9a:	eb 0a                	jmp    f0100ba6 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0100b9c:	a1 48 2d 17 f0       	mov    0xf0172d48,%eax
f0100ba1:	a3 50 2d 17 f0       	mov    %eax,0xf0172d50

	npage = maxpa / PGSIZE;
f0100ba6:	a1 50 2d 17 f0       	mov    0xf0172d50,%eax
f0100bab:	89 c2                	mov    %eax,%edx
f0100bad:	c1 ea 0c             	shr    $0xc,%edx
f0100bb0:	89 15 00 3a 17 f0    	mov    %edx,0xf0173a00

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100bb6:	c1 e8 0a             	shr    $0xa,%eax
f0100bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bbd:	c7 04 24 28 4f 10 f0 	movl   $0xf0104f28,(%esp)
f0100bc4:	e8 9d 23 00 00       	call   f0102f66 <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100bc9:	a1 4c 2d 17 f0       	mov    0xf0172d4c,%eax
f0100bce:	c1 e8 0a             	shr    $0xa,%eax
f0100bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bd5:	a1 48 2d 17 f0       	mov    0xf0172d48,%eax
f0100bda:	c1 e8 0a             	shr    $0xa,%eax
f0100bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100be1:	c7 04 24 bd 54 10 f0 	movl   $0xf01054bd,(%esp)
f0100be8:	e8 79 23 00 00       	call   f0102f66 <cprintf>
}
f0100bed:	c9                   	leave  
f0100bee:	c3                   	ret    

f0100bef <page_init>:
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc()
//
void
page_init(void)
{
f0100bef:	55                   	push   %ebp
f0100bf0:	89 e5                	mov    %esp,%ebp
f0100bf2:	56                   	push   %esi
f0100bf3:	53                   	push   %ebx
f0100bf4:	83 ec 10             	sub    $0x10,%esp
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f0100bf7:	c7 05 58 2d 17 f0 00 	movl   $0x0,0xf0172d58
f0100bfe:	00 00 00 
	for (i = 0; i < npage; i++) {
f0100c01:	83 3d 00 3a 17 f0 00 	cmpl   $0x0,0xf0173a00
f0100c08:	74 5f                	je     f0100c69 <page_init+0x7a>
f0100c0a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c0f:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f0100c14:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0100c17:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
f0100c1e:	8b 1d 0c 3a 17 f0    	mov    0xf0173a0c,%ebx
f0100c24:	66 c7 44 13 08 00 00 	movw   $0x0,0x8(%ebx,%edx,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100c2b:	8b 0d 58 2d 17 f0    	mov    0xf0172d58,%ecx
f0100c31:	89 0c b3             	mov    %ecx,(%ebx,%esi,4)
f0100c34:	85 c9                	test   %ecx,%ecx
f0100c36:	74 11                	je     f0100c49 <page_init+0x5a>
f0100c38:	8b 1d 0c 3a 17 f0    	mov    0xf0173a0c,%ebx
f0100c3e:	01 d3                	add    %edx,%ebx
f0100c40:	8b 0d 58 2d 17 f0    	mov    0xf0172d58,%ecx
f0100c46:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100c49:	03 15 0c 3a 17 f0    	add    0xf0173a0c,%edx
f0100c4f:	89 15 58 2d 17 f0    	mov    %edx,0xf0172d58
f0100c55:	c7 42 04 58 2d 17 f0 	movl   $0xf0172d58,0x4(%edx)
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0100c5c:	83 c0 01             	add    $0x1,%eax
f0100c5f:	89 c2                	mov    %eax,%edx
f0100c61:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0100c67:	72 ab                	jb     f0100c14 <page_init+0x25>
	// --pgstart;	// protect IOPHYSMEM
	// pgend->pp_link = pgstart;

	// the second method, slow
	// but can edit the .ref to 1
	pages[0].pp_ref = 1;
f0100c69:	a1 0c 3a 17 f0       	mov    0xf0173a0c,%eax
f0100c6e:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	// remove the first page, where holds Real Mode IDT
	LIST_REMOVE(&pages[0], pp_link);
f0100c74:	8b 10                	mov    (%eax),%edx
f0100c76:	85 d2                	test   %edx,%edx
f0100c78:	74 06                	je     f0100c80 <page_init+0x91>
f0100c7a:	8b 48 04             	mov    0x4(%eax),%ecx
f0100c7d:	89 4a 04             	mov    %ecx,0x4(%edx)
f0100c80:	8b 50 04             	mov    0x4(%eax),%edx
f0100c83:	8b 00                	mov    (%eax),%eax
f0100c85:	89 02                	mov    %eax,(%edx)
	// remove IO hole and kernel, they are tightly connected
	// notice boot_freemem points to the next byte of free mem, and points to higher mem!
	// so after the last calling "boot_alloc", boot_freemem remains the addr of the end addr of kernel pages plus 1
	for (i = IOPHYSMEM; i < PADDR((unsigned int) boot_freemem); i += PGSIZE)
f0100c87:	8b 1d 54 2d 17 f0    	mov    0xf0172d54,%ebx
f0100c8d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100c93:	76 52                	jbe    f0100ce7 <page_init+0xf8>
f0100c95:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0100c9b:	81 fb 00 00 0a 00    	cmp    $0xa0000,%ebx
f0100ca1:	76 64                	jbe    f0100d07 <page_init+0x118>
f0100ca3:	ba 00 00 0a 00       	mov    $0xa0000,%edx
	{
		pages[i / PGSIZE].pp_ref = 1;
f0100ca8:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax
f0100cae:	85 d2                	test   %edx,%edx
f0100cb0:	0f 49 c2             	cmovns %edx,%eax
f0100cb3:	c1 f8 0c             	sar    $0xc,%eax
f0100cb6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100cb9:	c1 e0 02             	shl    $0x2,%eax
f0100cbc:	03 05 0c 3a 17 f0    	add    0xf0173a0c,%eax
f0100cc2:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
		LIST_REMOVE(&pages[i / PGSIZE], pp_link);
f0100cc8:	8b 08                	mov    (%eax),%ecx
f0100cca:	85 c9                	test   %ecx,%ecx
f0100ccc:	74 06                	je     f0100cd4 <page_init+0xe5>
f0100cce:	8b 70 04             	mov    0x4(%eax),%esi
f0100cd1:	89 71 04             	mov    %esi,0x4(%ecx)
f0100cd4:	8b 48 04             	mov    0x4(%eax),%ecx
f0100cd7:	8b 00                	mov    (%eax),%eax
f0100cd9:	89 01                	mov    %eax,(%ecx)
	// remove the first page, where holds Real Mode IDT
	LIST_REMOVE(&pages[0], pp_link);
	// remove IO hole and kernel, they are tightly connected
	// notice boot_freemem points to the next byte of free mem, and points to higher mem!
	// so after the last calling "boot_alloc", boot_freemem remains the addr of the end addr of kernel pages plus 1
	for (i = IOPHYSMEM; i < PADDR((unsigned int) boot_freemem); i += PGSIZE)
f0100cdb:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100ce1:	39 da                	cmp    %ebx,%edx
f0100ce3:	72 c3                	jb     f0100ca8 <page_init+0xb9>
f0100ce5:	eb 20                	jmp    f0100d07 <page_init+0x118>
f0100ce7:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100ceb:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f0100cf2:	f0 
f0100cf3:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
f0100cfa:	00 
f0100cfb:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0100d02:	e8 b4 f3 ff ff       	call   f01000bb <_panic>
	{
		pages[i / PGSIZE].pp_ref = 1;
		LIST_REMOVE(&pages[i / PGSIZE], pp_link);
	}
}
f0100d07:	83 c4 10             	add    $0x10,%esp
f0100d0a:	5b                   	pop    %ebx
f0100d0b:	5e                   	pop    %esi
f0100d0c:	5d                   	pop    %ebp
f0100d0d:	c3                   	ret    

f0100d0e <page_alloc>:
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented 
int
page_alloc(struct Page **pp_store)
{
f0100d0e:	55                   	push   %ebp
f0100d0f:	89 e5                	mov    %esp,%ebp
f0100d11:	83 ec 18             	sub    $0x18,%esp
f0100d14:	8b 55 08             	mov    0x8(%ebp),%edx
	// Fill this function in
	if (LIST_FIRST(&page_free_list) != NULL)
f0100d17:	a1 58 2d 17 f0       	mov    0xf0172d58,%eax
f0100d1c:	85 c0                	test   %eax,%eax
f0100d1e:	74 38                	je     f0100d58 <page_alloc+0x4a>
	{
		// obtain the first page in page_free_list
		*pp_store = LIST_FIRST(&page_free_list);
f0100d20:	89 02                	mov    %eax,(%edx)
		// remove the obtained page in page_free_list
		LIST_REMOVE(*pp_store, pp_link);
f0100d22:	8b 08                	mov    (%eax),%ecx
f0100d24:	85 c9                	test   %ecx,%ecx
f0100d26:	74 06                	je     f0100d2e <page_alloc+0x20>
f0100d28:	8b 40 04             	mov    0x4(%eax),%eax
f0100d2b:	89 41 04             	mov    %eax,0x4(%ecx)
f0100d2e:	8b 02                	mov    (%edx),%eax
f0100d30:	8b 48 04             	mov    0x4(%eax),%ecx
f0100d33:	8b 00                	mov    (%eax),%eax
f0100d35:	89 01                	mov    %eax,(%ecx)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f0100d37:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0100d3e:	00 
f0100d3f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d46:	00 
f0100d47:	8b 02                	mov    (%edx),%eax
f0100d49:	89 04 24             	mov    %eax,(%esp)
f0100d4c:	e8 15 36 00 00       	call   f0104366 <memset>
		*pp_store = LIST_FIRST(&page_free_list);
		// remove the obtained page in page_free_list
		LIST_REMOVE(*pp_store, pp_link);
		// init the page structure
		page_initpp(*pp_store);
		return 0;
f0100d51:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d56:	eb 05                	jmp    f0100d5d <page_alloc+0x4f>
	}
	else
	{
		return -E_NO_MEM;
f0100d58:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
}
f0100d5d:	c9                   	leave  
f0100d5e:	c3                   	ret    

f0100d5f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100d5f:	55                   	push   %ebp
f0100d60:	89 e5                	mov    %esp,%ebp
f0100d62:	83 ec 18             	sub    $0x18,%esp
f0100d65:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0100d68:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0100d6d:	74 1c                	je     f0100d8b <page_free+0x2c>
	{
		// in case
		panic("pp->pp_ref != 0, but page_free called");
f0100d6f:	c7 44 24 08 70 4f 10 	movl   $0xf0104f70,0x8(%esp)
f0100d76:	f0 
f0100d77:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
f0100d7e:	00 
f0100d7f:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0100d86:	e8 30 f3 ff ff       	call   f01000bb <_panic>
	}
	else
	{
		LIST_INSERT_HEAD(&page_free_list, pp, pp_link);
f0100d8b:	8b 15 58 2d 17 f0    	mov    0xf0172d58,%edx
f0100d91:	89 10                	mov    %edx,(%eax)
f0100d93:	85 d2                	test   %edx,%edx
f0100d95:	74 09                	je     f0100da0 <page_free+0x41>
f0100d97:	8b 15 58 2d 17 f0    	mov    0xf0172d58,%edx
f0100d9d:	89 42 04             	mov    %eax,0x4(%edx)
f0100da0:	a3 58 2d 17 f0       	mov    %eax,0xf0172d58
f0100da5:	c7 40 04 58 2d 17 f0 	movl   $0xf0172d58,0x4(%eax)
	}
}
f0100dac:	c9                   	leave  
f0100dad:	c3                   	ret    

f0100dae <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100dae:	55                   	push   %ebp
f0100daf:	89 e5                	mov    %esp,%ebp
f0100db1:	83 ec 18             	sub    $0x18,%esp
f0100db4:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100db7:	0f b7 50 08          	movzwl 0x8(%eax),%edx
f0100dbb:	83 ea 01             	sub    $0x1,%edx
f0100dbe:	66 89 50 08          	mov    %dx,0x8(%eax)
f0100dc2:	66 85 d2             	test   %dx,%dx
f0100dc5:	75 08                	jne    f0100dcf <page_decref+0x21>
		page_free(pp);
f0100dc7:	89 04 24             	mov    %eax,(%esp)
f0100dca:	e8 90 ff ff ff       	call   f0100d5f <page_free>
}
f0100dcf:	c9                   	leave  
f0100dd0:	c3                   	ret    

f0100dd1 <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100dd1:	55                   	push   %ebp
f0100dd2:	89 e5                	mov    %esp,%ebp
f0100dd4:	56                   	push   %esi
f0100dd5:	53                   	push   %ebx
f0100dd6:	83 ec 20             	sub    $0x20,%esp
f0100dd9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// new_pg doesn't need an initialization, because
	// it will be casted to the existing space
	struct Page *new_pt;
	// attention to the priority of operations
	// PTE_P means whether it is there in memory
	if ((pgdir[PDX(va)] & PTE_P) != 0)
f0100ddc:	89 f3                	mov    %esi,%ebx
f0100dde:	c1 eb 16             	shr    $0x16,%ebx
f0100de1:	c1 e3 02             	shl    $0x2,%ebx
f0100de4:	03 5d 08             	add    0x8(%ebp),%ebx
f0100de7:	8b 03                	mov    (%ebx),%eax
f0100de9:	a8 01                	test   $0x1,%al
f0100deb:	74 47                	je     f0100e34 <pgdir_walk+0x63>
		// and page dir is a page itself, so PTE_ADDR is
		// needed to get the addr of phys page va pointing to.
		// that is the addr of page table
		// remember, pt_addr is a ptr to pte
		// we got ptr to pte through va, and got va through ptr to pte.
		pt_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100ded:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100df2:	89 c2                	mov    %eax,%edx
f0100df4:	c1 ea 0c             	shr    $0xc,%edx
f0100df7:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f0100dfd:	72 20                	jb     f0100e1f <pgdir_walk+0x4e>
f0100dff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e03:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f0100e0a:	f0 
f0100e0b:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
f0100e12:	00 
f0100e13:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0100e1a:	e8 9c f2 ff ff       	call   f01000bb <_panic>
		// now it's time to get final pa through va
		// and remember, pt_addr is an array of pointer to phsy pages
		return &pt_addr[PTX(va)];
f0100e1f:	c1 ee 0a             	shr    $0xa,%esi
f0100e22:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100e28:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100e2f:	e9 ec 00 00 00       	jmp    f0100f20 <pgdir_walk+0x14f>
	}
	else
	{
		if (create == 0)
f0100e34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e38:	0f 84 d6 00 00 00    	je     f0100f14 <pgdir_walk+0x143>
			return NULL;
		}
		else
		{
			// allocate a new page table
			if (page_alloc(&new_pt) == 0)
f0100e3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100e41:	89 04 24             	mov    %eax,(%esp)
f0100e44:	e8 c5 fe ff ff       	call   f0100d0e <page_alloc>
f0100e49:	85 c0                	test   %eax,%eax
f0100e4b:	0f 85 ca 00 00 00    	jne    f0100f1b <pgdir_walk+0x14a>
			{
				new_pt->pp_ref = 1;
f0100e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e54:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100e5a:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f0100e60:	c1 f8 02             	sar    $0x2,%eax
f0100e63:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100e69:	c1 e0 0c             	shl    $0xc,%eax
				// new page table need to be cleared or a "pa2page" panic
				// or an assertion failed about "check that new page tables get cleared"
				memset(KADDR(page2pa(new_pt)), 0, PGSIZE);
f0100e6c:	89 c2                	mov    %eax,%edx
f0100e6e:	c1 ea 0c             	shr    $0xc,%edx
f0100e71:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f0100e77:	72 20                	jb     f0100e99 <pgdir_walk+0xc8>
f0100e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e7d:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0100e8c:	00 
f0100e8d:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0100e94:	e8 22 f2 ff ff       	call   f01000bb <_panic>
f0100e99:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ea0:	00 
f0100ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ea8:	00 
f0100ea9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100eae:	89 04 24             	mov    %eax,(%esp)
f0100eb1:	e8 b0 34 00 00       	call   f0104366 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100eb9:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f0100ebf:	c1 f8 02             	sar    $0x2,%eax
f0100ec2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100ec8:	c1 e0 0c             	shl    $0xc,%eax
				// update the pgdir
				// P, present in the memory
				// W, writable; U, user
				// PTE_U must be here; or GP arises when debuggin user process
				pgdir[PDX(va)] = page2pa(new_pt) | PTE_P | PTE_W | PTE_U;
f0100ecb:	83 c8 07             	or     $0x7,%eax
f0100ece:	89 03                	mov    %eax,(%ebx)
				// then the same with the condition when page table exists in the dir
				pt_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100ed0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ed5:	89 c2                	mov    %eax,%edx
f0100ed7:	c1 ea 0c             	shr    $0xc,%edx
f0100eda:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f0100ee0:	72 20                	jb     f0100f02 <pgdir_walk+0x131>
f0100ee2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee6:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f0100eed:	f0 
f0100eee:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100ef5:	00 
f0100ef6:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0100efd:	e8 b9 f1 ff ff       	call   f01000bb <_panic>
				return &pt_addr[PTX(va)];
f0100f02:	c1 ee 0a             	shr    $0xa,%esi
f0100f05:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100f0b:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100f12:	eb 0c                	jmp    f0100f20 <pgdir_walk+0x14f>
	}
	else
	{
		if (create == 0)
		{
			return NULL;
f0100f14:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f19:	eb 05                	jmp    f0100f20 <pgdir_walk+0x14f>
				pt_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
				return &pt_addr[PTX(va)];
			}
			else
			{
				return NULL;
f0100f1b:	b8 00 00 00 00       	mov    $0x0,%eax
			}
		}
	}
}
f0100f20:	83 c4 20             	add    $0x20,%esp
f0100f23:	5b                   	pop    %ebx
f0100f24:	5e                   	pop    %esi
f0100f25:	5d                   	pop    %ebp
f0100f26:	c3                   	ret    

f0100f27 <boot_map_segment>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0100f27:	55                   	push   %ebp
f0100f28:	89 e5                	mov    %esp,%ebp
f0100f2a:	57                   	push   %edi
f0100f2b:	56                   	push   %esi
f0100f2c:	53                   	push   %ebx
f0100f2d:	83 ec 2c             	sub    $0x2c,%esp
f0100f30:	89 c7                	mov    %eax,%edi
f0100f32:	89 d6                	mov    %edx,%esi
	// Fill this function in
	// better than int i; no worry about overflow.
	unsigned int i;
	pte_t *pt_addr;
	// size in stack, no worry.
	size = ROUNDUP(size, PGSIZE);
f0100f34:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
	// never be reached. the reason is that it is called by boot,
	// there should not be any protected la allocated, and
	// the os programmer should be very careful so that 
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
f0100f3a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100f40:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f43:	74 5a                	je     f0100f9f <boot_map_segment+0x78>
f0100f45:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (pt_addr == NULL)
		{
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pt_addr = (pa+i) | perm | PTE_P;
f0100f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f4d:	83 c8 01             	or     $0x1,%eax
f0100f50:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
	{
		// get the page addr
		pt_addr = pgdir_walk(pgdir, (void *)(la+i), 1);
f0100f53:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100f5a:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
f0100f5b:	8d 04 33             	lea    (%ebx,%esi,1),%eax
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
	{
		// get the page addr
		pt_addr = pgdir_walk(pgdir, (void *)(la+i), 1);
f0100f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f62:	89 3c 24             	mov    %edi,(%esp)
f0100f65:	e8 67 fe ff ff       	call   f0100dd1 <pgdir_walk>
		if (pt_addr == NULL)
f0100f6a:	85 c0                	test   %eax,%eax
f0100f6c:	75 1c                	jne    f0100f8a <boot_map_segment+0x63>
		{
			panic("failed to map la to pa in boot_map_segment()");
f0100f6e:	c7 44 24 08 98 4f 10 	movl   $0xf0104f98,0x8(%esp)
f0100f75:	f0 
f0100f76:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100f7d:	00 
f0100f7e:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0100f85:	e8 31 f1 ff ff       	call   f01000bb <_panic>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
f0100f8a:	8b 55 08             	mov    0x8(%ebp),%edx
f0100f8d:	01 da                	add    %ebx,%edx
		if (pt_addr == NULL)
		{
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pt_addr = (pa+i) | perm | PTE_P;
f0100f8f:	0b 55 e0             	or     -0x20(%ebp),%edx
f0100f92:	89 10                	mov    %edx,(%eax)
	// never be reached. the reason is that it is called by boot,
	// there should not be any protected la allocated, and
	// the os programmer should be very careful so that 
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
f0100f94:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100f9a:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0100f9d:	77 b4                	ja     f0100f53 <boot_map_segment+0x2c>
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pt_addr = (pa+i) | perm | PTE_P;
	}
}
f0100f9f:	83 c4 2c             	add    $0x2c,%esp
f0100fa2:	5b                   	pop    %ebx
f0100fa3:	5e                   	pop    %esi
f0100fa4:	5f                   	pop    %edi
f0100fa5:	5d                   	pop    %ebp
f0100fa6:	c3                   	ret    

f0100fa7 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fa7:	55                   	push   %ebp
f0100fa8:	89 e5                	mov    %esp,%ebp
f0100faa:	53                   	push   %ebx
f0100fab:	83 ec 14             	sub    $0x14,%esp
f0100fae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	// never create a new page table
	pte_t *pt_addr = pgdir_walk(pgdir, va, 0);
f0100fb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100fb8:	00 
f0100fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fc3:	89 04 24             	mov    %eax,(%esp)
f0100fc6:	e8 06 fe ff ff       	call   f0100dd1 <pgdir_walk>
	if (pt_addr == NULL)
f0100fcb:	85 c0                	test   %eax,%eax
f0100fcd:	74 3d                	je     f010100c <page_lookup+0x65>
	{
		return NULL;
	}
	else
	{
		if (pte_store)
f0100fcf:	85 db                	test   %ebx,%ebx
f0100fd1:	74 02                	je     f0100fd5 <page_lookup+0x2e>
		{
			// be careful to read the header comment
			*pte_store = pt_addr;
f0100fd3:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100fd5:	8b 00                	mov    (%eax),%eax
f0100fd7:	c1 e8 0c             	shr    $0xc,%eax
f0100fda:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0100fe0:	72 1c                	jb     f0100ffe <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0100fe2:	c7 44 24 08 c8 4f 10 	movl   $0xf0104fc8,0x8(%esp)
f0100fe9:	f0 
f0100fea:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0100ff1:	00 
f0100ff2:	c7 04 24 d9 54 10 f0 	movl   $0xf01054d9,(%esp)
f0100ff9:	e8 bd f0 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0100ffe:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101001:	c1 e0 02             	shl    $0x2,%eax
f0101004:	03 05 0c 3a 17 f0    	add    0xf0173a0c,%eax
		}
		// pt_addr is ptr to pte, not phsy page addr
		// we need to get pa through ptr to pte, (* is okay)
		// and then get PPN through pa (1), and get page addr
		// through PPN (2); (1) and (2) are done by "pa2page"
		return pa2page(*pt_addr);
f010100a:	eb 05                	jmp    f0101011 <page_lookup+0x6a>
	// Fill this function in
	// never create a new page table
	pte_t *pt_addr = pgdir_walk(pgdir, va, 0);
	if (pt_addr == NULL)
	{
		return NULL;
f010100c:	b8 00 00 00 00       	mov    $0x0,%eax
		// and then get PPN through pa (1), and get page addr
		// through PPN (2); (1) and (2) are done by "pa2page"
		return pa2page(*pt_addr);
		// "pa2page(phsyaddr_t pa)" returns &pages[PPN(pa)];
	}
}
f0101011:	83 c4 14             	add    $0x14,%esp
f0101014:	5b                   	pop    %ebx
f0101015:	5d                   	pop    %ebp
f0101016:	c3                   	ret    

f0101017 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101017:	55                   	push   %ebp
f0101018:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010101a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010101d:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101020:	5d                   	pop    %ebp
f0101021:	c3                   	ret    

f0101022 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101022:	55                   	push   %ebp
f0101023:	89 e5                	mov    %esp,%ebp
f0101025:	83 ec 28             	sub    $0x28,%esp
f0101028:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010102b:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010102e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101031:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// the corresponding pte to set
	pte_t *pt2set;
	// the page found and to unmap
	// and &pg2um is an addr and never equal to 0
	// or it will crash IDT
	struct Page *pg = page_lookup(pgdir, va, &pt2set);
f0101034:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101037:	89 44 24 08          	mov    %eax,0x8(%esp)
f010103b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010103f:	89 34 24             	mov    %esi,(%esp)
f0101042:	e8 60 ff ff ff       	call   f0100fa7 <page_lookup>
	if (pg == NULL)
f0101047:	85 c0                	test   %eax,%eax
f0101049:	74 1d                	je     f0101068 <page_remove+0x46>
		return;
	}
	else
	{
		// --ref and if ref == 0 then page_free it
		page_decref(pg);
f010104b:	89 04 24             	mov    %eax,(%esp)
f010104e:	e8 5b fd ff ff       	call   f0100dae <page_decref>
		// set the pte to zero as asked
		// if code runs here, pte must exist, as pg exists
		*pt2set = 0;
f0101053:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101056:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f010105c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101060:	89 34 24             	mov    %esi,(%esp)
f0101063:	e8 af ff ff ff       	call   f0101017 <tlb_invalidate>
	}
}
f0101068:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f010106b:	8b 75 fc             	mov    -0x4(%ebp),%esi
f010106e:	89 ec                	mov    %ebp,%esp
f0101070:	5d                   	pop    %ebp
f0101071:	c3                   	ret    

f0101072 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0101072:	55                   	push   %ebp
f0101073:	89 e5                	mov    %esp,%ebp
f0101075:	83 ec 28             	sub    $0x28,%esp
f0101078:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010107b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010107e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101081:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101084:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	// always create a new page table if there isn't
	// which is "necessary, on demand" in the comment
	pte_t *pt_addr = pgdir_walk(pgdir, va, 1);
f0101087:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010108e:	00 
f010108f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101093:	8b 45 08             	mov    0x8(%ebp),%eax
f0101096:	89 04 24             	mov    %eax,(%esp)
f0101099:	e8 33 fd ff ff       	call   f0100dd1 <pgdir_walk>
f010109e:	89 c3                	mov    %eax,%ebx
	if (pt_addr == NULL)
f01010a0:	85 c0                	test   %eax,%eax
f01010a2:	74 4d                	je     f01010f1 <page_insert+0x7f>
		return -E_NO_MEM;
	}
	else
	{
		// increase pp_ref as insertion succeeds
		++(pp->pp_ref);
f01010a4:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
		// REMEMBER, pt_addr is a ptr to pte
		// *pt_addr will get the value addressed at pt_addr
		// already a page mapped at va, remove it
		if ((*pt_addr & PTE_P) != 0)
f01010a9:	f6 00 01             	testb  $0x1,(%eax)
f01010ac:	74 1e                	je     f01010cc <page_insert+0x5a>
		{
			page_remove(pgdir, va);
f01010ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01010b5:	89 04 24             	mov    %eax,(%esp)
f01010b8:	e8 65 ff ff ff       	call   f0101022 <page_remove>
			// The TLB must be invalidated 
			// if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f01010bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01010c4:	89 04 24             	mov    %eax,(%esp)
f01010c7:	e8 4b ff ff ff       	call   f0101017 <tlb_invalidate>
		}
		// again, through pt_addr we should get pa
		*pt_addr = page2pa(pp) | perm | PTE_P;
f01010cc:	8b 55 14             	mov    0x14(%ebp),%edx
f01010cf:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01010d2:	2b 35 0c 3a 17 f0    	sub    0xf0173a0c,%esi
f01010d8:	c1 fe 02             	sar    $0x2,%esi
f01010db:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01010e1:	c1 e0 0c             	shl    $0xc,%eax
f01010e4:	89 d6                	mov    %edx,%esi
f01010e6:	09 c6                	or     %eax,%esi
f01010e8:	89 33                	mov    %esi,(%ebx)
		return 0;
f01010ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ef:	eb 05                	jmp    f01010f6 <page_insert+0x84>
	// always create a new page table if there isn't
	// which is "necessary, on demand" in the comment
	pte_t *pt_addr = pgdir_walk(pgdir, va, 1);
	if (pt_addr == NULL)
	{
		return -E_NO_MEM;
f01010f1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		}
		// again, through pt_addr we should get pa
		*pt_addr = page2pa(pp) | perm | PTE_P;
		return 0;
	}
}
f01010f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01010f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01010fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01010ff:	89 ec                	mov    %ebp,%esp
f0101101:	5d                   	pop    %ebp
f0101102:	c3                   	ret    

f0101103 <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0101103:	55                   	push   %ebp
f0101104:	89 e5                	mov    %esp,%ebp
f0101106:	57                   	push   %edi
f0101107:	56                   	push   %esi
f0101108:	53                   	push   %ebx
f0101109:	83 ec 4c             	sub    $0x4c,%esp
	// Delete this line:
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f010110c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101111:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101116:	e8 45 f9 ff ff       	call   f0100a60 <boot_alloc>
f010111b:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f010111d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101124:	00 
f0101125:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010112c:	00 
f010112d:	89 04 24             	mov    %eax,(%esp)
f0101130:	e8 31 32 00 00       	call   f0104366 <memset>
	boot_pgdir = pgdir;
f0101135:	89 1d 08 3a 17 f0    	mov    %ebx,0xf0173a08
	boot_cr3 = PADDR(pgdir);
f010113b:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101141:	77 20                	ja     f0101163 <i386_vm_init+0x60>
f0101143:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101147:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f010114e:	f0 
f010114f:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
f0101156:	00 
f0101157:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010115e:	e8 58 ef ff ff       	call   f01000bb <_panic>
f0101163:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0101169:	a3 04 3a 17 f0       	mov    %eax,0xf0173a04
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f010116e:	89 c2                	mov    %eax,%edx
f0101170:	83 ca 03             	or     $0x3,%edx
f0101173:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f0101179:	83 c8 05             	or     $0x5,%eax
f010117c:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// The kernel uses this structure to keep track of physical pages;
	// 'npage' equals the number of physical pages in memory.  User-level
	// programs will get read-only access to the array as well.
	// You must allocate the array yourself.
	// Your code goes here: 
	pages = (struct Page *)boot_alloc(npage*sizeof(struct Page), PGSIZE);
f0101182:	a1 00 3a 17 f0       	mov    0xf0173a00,%eax
f0101187:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010118a:	c1 e0 02             	shl    $0x2,%eax
f010118d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101192:	e8 c9 f8 ff ff       	call   f0100a60 <boot_alloc>
f0101197:	a3 0c 3a 17 f0       	mov    %eax,0xf0173a0c

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV*sizeof(struct Env), PGSIZE);
f010119c:	ba 00 10 00 00       	mov    $0x1000,%edx
f01011a1:	b8 00 90 01 00       	mov    $0x19000,%eax
f01011a6:	e8 b5 f8 ff ff       	call   f0100a60 <boot_alloc>
f01011ab:	a3 60 2d 17 f0       	mov    %eax,0xf0172d60
	//////////////////////////////////////////////////////////////////////
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_segment or page_insert
	page_init();
f01011b0:	e8 3a fa ff ff       	call   f0100bef <page_init>
	struct Page_list fl;
	
        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f01011b5:	a1 58 2d 17 f0       	mov    0xf0172d58,%eax
f01011ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011bd:	85 c0                	test   %eax,%eax
f01011bf:	0f 84 89 00 00 00    	je     f010124e <i386_vm_init+0x14b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01011c5:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f01011cb:	c1 f8 02             	sar    $0x2,%eax
f01011ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01011d4:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01011d7:	89 c2                	mov    %eax,%edx
f01011d9:	c1 ea 0c             	shr    $0xc,%edx
f01011dc:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f01011e2:	72 41                	jb     f0101225 <i386_vm_init+0x122>
f01011e4:	eb 1f                	jmp    f0101205 <i386_vm_init+0x102>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01011e6:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f01011ec:	c1 f8 02             	sar    $0x2,%eax
f01011ef:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01011f5:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01011f8:	89 c2                	mov    %eax,%edx
f01011fa:	c1 ea 0c             	shr    $0xc,%edx
f01011fd:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f0101203:	72 20                	jb     f0101225 <i386_vm_init+0x122>
f0101205:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101209:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f0101210:	f0 
f0101211:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101218:	00 
f0101219:	c7 04 24 d9 54 10 f0 	movl   $0xf01054d9,(%esp)
f0101220:	e8 96 ee ff ff       	call   f01000bb <_panic>
		memset(page2kva(pp0), 0x97, 128);
f0101225:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010122c:	00 
f010122d:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101234:	00 
f0101235:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010123a:	89 04 24             	mov    %eax,(%esp)
f010123d:	e8 24 31 00 00       	call   f0104366 <memset>
	struct Page_list fl;
	
        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f0101242:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101245:	8b 00                	mov    (%eax),%eax
f0101247:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010124a:	85 c0                	test   %eax,%eax
f010124c:	75 98                	jne    f01011e6 <i386_vm_init+0xe3>
		memset(page2kva(pp0), 0x97, 128);

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f010124e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101255:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010125c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101263:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101266:	89 04 24             	mov    %eax,(%esp)
f0101269:	e8 a0 fa ff ff       	call   f0100d0e <page_alloc>
f010126e:	85 c0                	test   %eax,%eax
f0101270:	74 24                	je     f0101296 <i386_vm_init+0x193>
f0101272:	c7 44 24 0c e7 54 10 	movl   $0xf01054e7,0xc(%esp)
f0101279:	f0 
f010127a:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101281:	f0 
f0101282:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f0101289:	00 
f010128a:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101291:	e8 25 ee ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f0101296:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101299:	89 04 24             	mov    %eax,(%esp)
f010129c:	e8 6d fa ff ff       	call   f0100d0e <page_alloc>
f01012a1:	85 c0                	test   %eax,%eax
f01012a3:	74 24                	je     f01012c9 <i386_vm_init+0x1c6>
f01012a5:	c7 44 24 0c 12 55 10 	movl   $0xf0105512,0xc(%esp)
f01012ac:	f0 
f01012ad:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01012b4:	f0 
f01012b5:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f01012bc:	00 
f01012bd:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01012c4:	e8 f2 ed ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f01012c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01012cc:	89 04 24             	mov    %eax,(%esp)
f01012cf:	e8 3a fa ff ff       	call   f0100d0e <page_alloc>
f01012d4:	85 c0                	test   %eax,%eax
f01012d6:	74 24                	je     f01012fc <i386_vm_init+0x1f9>
f01012d8:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f01012df:	f0 
f01012e0:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01012e7:	f0 
f01012e8:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f01012ef:	00 
f01012f0:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01012f7:	e8 bf ed ff ff       	call   f01000bb <_panic>

	assert(pp0);
f01012fc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012ff:	85 c9                	test   %ecx,%ecx
f0101301:	75 24                	jne    f0101327 <i386_vm_init+0x224>
f0101303:	c7 44 24 0c 4c 55 10 	movl   $0xf010554c,0xc(%esp)
f010130a:	f0 
f010130b:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101312:	f0 
f0101313:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f010131a:	00 
f010131b:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101322:	e8 94 ed ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f0101327:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010132a:	85 d2                	test   %edx,%edx
f010132c:	74 04                	je     f0101332 <i386_vm_init+0x22f>
f010132e:	39 d1                	cmp    %edx,%ecx
f0101330:	75 24                	jne    f0101356 <i386_vm_init+0x253>
f0101332:	c7 44 24 0c 3e 55 10 	movl   $0xf010553e,0xc(%esp)
f0101339:	f0 
f010133a:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101341:	f0 
f0101342:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0101349:	00 
f010134a:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101351:	e8 65 ed ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101356:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101359:	85 c0                	test   %eax,%eax
f010135b:	74 08                	je     f0101365 <i386_vm_init+0x262>
f010135d:	39 c2                	cmp    %eax,%edx
f010135f:	74 04                	je     f0101365 <i386_vm_init+0x262>
f0101361:	39 c1                	cmp    %eax,%ecx
f0101363:	75 24                	jne    f0101389 <i386_vm_init+0x286>
f0101365:	c7 44 24 0c e8 4f 10 	movl   $0xf0104fe8,0xc(%esp)
f010136c:	f0 
f010136d:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101374:	f0 
f0101375:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f010137c:	00 
f010137d:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101384:	e8 32 ed ff ff       	call   f01000bb <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101389:	8b 3d 0c 3a 17 f0    	mov    0xf0173a0c,%edi
        assert(page2pa(pp0) < npage*PGSIZE);
f010138f:	8b 35 00 3a 17 f0    	mov    0xf0173a00,%esi
f0101395:	c1 e6 0c             	shl    $0xc,%esi
f0101398:	29 f9                	sub    %edi,%ecx
f010139a:	c1 f9 02             	sar    $0x2,%ecx
f010139d:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01013a3:	c1 e1 0c             	shl    $0xc,%ecx
f01013a6:	39 f1                	cmp    %esi,%ecx
f01013a8:	72 24                	jb     f01013ce <i386_vm_init+0x2cb>
f01013aa:	c7 44 24 0c 50 55 10 	movl   $0xf0105550,0xc(%esp)
f01013b1:	f0 
f01013b2:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01013b9:	f0 
f01013ba:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f01013c1:	00 
f01013c2:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01013c9:	e8 ed ec ff ff       	call   f01000bb <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01013ce:	29 fa                	sub    %edi,%edx
f01013d0:	c1 fa 02             	sar    $0x2,%edx
f01013d3:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01013d9:	c1 e2 0c             	shl    $0xc,%edx
        assert(page2pa(pp1) < npage*PGSIZE);
f01013dc:	39 d6                	cmp    %edx,%esi
f01013de:	77 24                	ja     f0101404 <i386_vm_init+0x301>
f01013e0:	c7 44 24 0c 6c 55 10 	movl   $0xf010556c,0xc(%esp)
f01013e7:	f0 
f01013e8:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01013ef:	f0 
f01013f0:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f01013f7:	00 
f01013f8:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01013ff:	e8 b7 ec ff ff       	call   f01000bb <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101404:	29 f8                	sub    %edi,%eax
f0101406:	c1 f8 02             	sar    $0x2,%eax
f0101409:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010140f:	c1 e0 0c             	shl    $0xc,%eax
        assert(page2pa(pp2) < npage*PGSIZE);
f0101412:	39 c6                	cmp    %eax,%esi
f0101414:	77 24                	ja     f010143a <i386_vm_init+0x337>
f0101416:	c7 44 24 0c 88 55 10 	movl   $0xf0105588,0xc(%esp)
f010141d:	f0 
f010141e:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101425:	f0 
f0101426:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f010142d:	00 
f010142e:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101435:	e8 81 ec ff ff       	call   f01000bb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010143a:	8b 35 58 2d 17 f0    	mov    0xf0172d58,%esi
	LIST_INIT(&page_free_list);
f0101440:	c7 05 58 2d 17 f0 00 	movl   $0x0,0xf0172d58
f0101447:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010144a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f010144d:	89 04 24             	mov    %eax,(%esp)
f0101450:	e8 b9 f8 ff ff       	call   f0100d0e <page_alloc>
f0101455:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101458:	74 24                	je     f010147e <i386_vm_init+0x37b>
f010145a:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f0101461:	f0 
f0101462:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101469:	f0 
f010146a:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0101471:	00 
f0101472:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101479:	e8 3d ec ff ff       	call   f01000bb <_panic>

        // free and re-allocate?
        page_free(pp0);
f010147e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101481:	89 04 24             	mov    %eax,(%esp)
f0101484:	e8 d6 f8 ff ff       	call   f0100d5f <page_free>
        page_free(pp1);
f0101489:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010148c:	89 04 24             	mov    %eax,(%esp)
f010148f:	e8 cb f8 ff ff       	call   f0100d5f <page_free>
        page_free(pp2);
f0101494:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101497:	89 04 24             	mov    %eax,(%esp)
f010149a:	e8 c0 f8 ff ff       	call   f0100d5f <page_free>
	pp0 = pp1 = pp2 = 0;
f010149f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01014a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01014ad:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	assert(page_alloc(&pp0) == 0);
f01014b4:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01014b7:	89 04 24             	mov    %eax,(%esp)
f01014ba:	e8 4f f8 ff ff       	call   f0100d0e <page_alloc>
f01014bf:	85 c0                	test   %eax,%eax
f01014c1:	74 24                	je     f01014e7 <i386_vm_init+0x3e4>
f01014c3:	c7 44 24 0c e7 54 10 	movl   $0xf01054e7,0xc(%esp)
f01014ca:	f0 
f01014cb:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01014d2:	f0 
f01014d3:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f01014da:	00 
f01014db:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01014e2:	e8 d4 eb ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f01014e7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01014ea:	89 04 24             	mov    %eax,(%esp)
f01014ed:	e8 1c f8 ff ff       	call   f0100d0e <page_alloc>
f01014f2:	85 c0                	test   %eax,%eax
f01014f4:	74 24                	je     f010151a <i386_vm_init+0x417>
f01014f6:	c7 44 24 0c 12 55 10 	movl   $0xf0105512,0xc(%esp)
f01014fd:	f0 
f01014fe:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101505:	f0 
f0101506:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f010150d:	00 
f010150e:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101515:	e8 a1 eb ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f010151a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010151d:	89 04 24             	mov    %eax,(%esp)
f0101520:	e8 e9 f7 ff ff       	call   f0100d0e <page_alloc>
f0101525:	85 c0                	test   %eax,%eax
f0101527:	74 24                	je     f010154d <i386_vm_init+0x44a>
f0101529:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f0101530:	f0 
f0101531:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101538:	f0 
f0101539:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f0101540:	00 
f0101541:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101548:	e8 6e eb ff ff       	call   f01000bb <_panic>
	assert(pp0);
f010154d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101550:	85 d2                	test   %edx,%edx
f0101552:	75 24                	jne    f0101578 <i386_vm_init+0x475>
f0101554:	c7 44 24 0c 4c 55 10 	movl   $0xf010554c,0xc(%esp)
f010155b:	f0 
f010155c:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101563:	f0 
f0101564:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
f010156b:	00 
f010156c:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101573:	e8 43 eb ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f0101578:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010157b:	85 c9                	test   %ecx,%ecx
f010157d:	74 04                	je     f0101583 <i386_vm_init+0x480>
f010157f:	39 ca                	cmp    %ecx,%edx
f0101581:	75 24                	jne    f01015a7 <i386_vm_init+0x4a4>
f0101583:	c7 44 24 0c 3e 55 10 	movl   $0xf010553e,0xc(%esp)
f010158a:	f0 
f010158b:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101592:	f0 
f0101593:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
f010159a:	00 
f010159b:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01015a2:	e8 14 eb ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	74 08                	je     f01015b6 <i386_vm_init+0x4b3>
f01015ae:	39 c1                	cmp    %eax,%ecx
f01015b0:	74 04                	je     f01015b6 <i386_vm_init+0x4b3>
f01015b2:	39 c2                	cmp    %eax,%edx
f01015b4:	75 24                	jne    f01015da <i386_vm_init+0x4d7>
f01015b6:	c7 44 24 0c e8 4f 10 	movl   $0xf0104fe8,0xc(%esp)
f01015bd:	f0 
f01015be:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01015c5:	f0 
f01015c6:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f01015cd:	00 
f01015ce:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01015d5:	e8 e1 ea ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f01015da:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01015dd:	89 04 24             	mov    %eax,(%esp)
f01015e0:	e8 29 f7 ff ff       	call   f0100d0e <page_alloc>
f01015e5:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01015e8:	74 24                	je     f010160e <i386_vm_init+0x50b>
f01015ea:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f01015f1:	f0 
f01015f2:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01015f9:	f0 
f01015fa:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0101601:	00 
f0101602:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101609:	e8 ad ea ff ff       	call   f01000bb <_panic>

	// give free list back
	page_free_list = fl;
f010160e:	89 35 58 2d 17 f0    	mov    %esi,0xf0172d58

	// free the pages we took
	page_free(pp0);
f0101614:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101617:	89 04 24             	mov    %eax,(%esp)
f010161a:	e8 40 f7 ff ff       	call   f0100d5f <page_free>
	page_free(pp1);
f010161f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101622:	89 04 24             	mov    %eax,(%esp)
f0101625:	e8 35 f7 ff ff       	call   f0100d5f <page_free>
	page_free(pp2);
f010162a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010162d:	89 04 24             	mov    %eax,(%esp)
f0101630:	e8 2a f7 ff ff       	call   f0100d5f <page_free>

	cprintf("check_page_alloc() succeeded!\n");
f0101635:	c7 04 24 08 50 10 f0 	movl   $0xf0105008,(%esp)
f010163c:	e8 25 19 00 00       	call   f0102f66 <cprintf>
	pte_t *ptep, *ptep1;
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0101641:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101648:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010164f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101656:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101659:	89 04 24             	mov    %eax,(%esp)
f010165c:	e8 ad f6 ff ff       	call   f0100d0e <page_alloc>
f0101661:	85 c0                	test   %eax,%eax
f0101663:	74 24                	je     f0101689 <i386_vm_init+0x586>
f0101665:	c7 44 24 0c e7 54 10 	movl   $0xf01054e7,0xc(%esp)
f010166c:	f0 
f010166d:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101674:	f0 
f0101675:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010167c:	00 
f010167d:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101684:	e8 32 ea ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f0101689:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010168c:	89 04 24             	mov    %eax,(%esp)
f010168f:	e8 7a f6 ff ff       	call   f0100d0e <page_alloc>
f0101694:	85 c0                	test   %eax,%eax
f0101696:	74 24                	je     f01016bc <i386_vm_init+0x5b9>
f0101698:	c7 44 24 0c 12 55 10 	movl   $0xf0105512,0xc(%esp)
f010169f:	f0 
f01016a0:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01016a7:	f0 
f01016a8:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f01016af:	00 
f01016b0:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01016b7:	e8 ff e9 ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f01016bc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01016bf:	89 04 24             	mov    %eax,(%esp)
f01016c2:	e8 47 f6 ff ff       	call   f0100d0e <page_alloc>
f01016c7:	85 c0                	test   %eax,%eax
f01016c9:	74 24                	je     f01016ef <i386_vm_init+0x5ec>
f01016cb:	c7 44 24 0c 28 55 10 	movl   $0xf0105528,0xc(%esp)
f01016d2:	f0 
f01016d3:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01016da:	f0 
f01016db:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f01016e2:	00 
f01016e3:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01016ea:	e8 cc e9 ff ff       	call   f01000bb <_panic>

	assert(pp0);
f01016ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01016f2:	85 d2                	test   %edx,%edx
f01016f4:	75 24                	jne    f010171a <i386_vm_init+0x617>
f01016f6:	c7 44 24 0c 4c 55 10 	movl   $0xf010554c,0xc(%esp)
f01016fd:	f0 
f01016fe:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101705:	f0 
f0101706:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f010170d:	00 
f010170e:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101715:	e8 a1 e9 ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f010171a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010171d:	85 c9                	test   %ecx,%ecx
f010171f:	74 04                	je     f0101725 <i386_vm_init+0x622>
f0101721:	39 ca                	cmp    %ecx,%edx
f0101723:	75 24                	jne    f0101749 <i386_vm_init+0x646>
f0101725:	c7 44 24 0c 3e 55 10 	movl   $0xf010553e,0xc(%esp)
f010172c:	f0 
f010172d:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101734:	f0 
f0101735:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f010173c:	00 
f010173d:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101744:	e8 72 e9 ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101749:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010174c:	85 c0                	test   %eax,%eax
f010174e:	74 08                	je     f0101758 <i386_vm_init+0x655>
f0101750:	39 c1                	cmp    %eax,%ecx
f0101752:	74 04                	je     f0101758 <i386_vm_init+0x655>
f0101754:	39 c2                	cmp    %eax,%edx
f0101756:	75 24                	jne    f010177c <i386_vm_init+0x679>
f0101758:	c7 44 24 0c e8 4f 10 	movl   $0xf0104fe8,0xc(%esp)
f010175f:	f0 
f0101760:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101767:	f0 
f0101768:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f010176f:	00 
f0101770:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101777:	e8 3f e9 ff ff       	call   f01000bb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010177c:	a1 58 2d 17 f0       	mov    0xf0172d58,%eax
f0101781:	89 45 c0             	mov    %eax,-0x40(%ebp)
	LIST_INIT(&page_free_list);
f0101784:	c7 05 58 2d 17 f0 00 	movl   $0x0,0xf0172d58
f010178b:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010178e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101791:	89 04 24             	mov    %eax,(%esp)
f0101794:	e8 75 f5 ff ff       	call   f0100d0e <page_alloc>
f0101799:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010179c:	74 24                	je     f01017c2 <i386_vm_init+0x6bf>
f010179e:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f01017a5:	f0 
f01017a6:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01017ad:	f0 
f01017ae:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f01017b5:	00 
f01017b6:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01017bd:	e8 f9 e8 ff ff       	call   f01000bb <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f01017c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01017c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017d0:	00 
f01017d1:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f01017d6:	89 04 24             	mov    %eax,(%esp)
f01017d9:	e8 c9 f7 ff ff       	call   f0100fa7 <page_lookup>
f01017de:	85 c0                	test   %eax,%eax
f01017e0:	74 24                	je     f0101806 <i386_vm_init+0x703>
f01017e2:	c7 44 24 0c 28 50 10 	movl   $0xf0105028,0xc(%esp)
f01017e9:	f0 
f01017ea:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01017f1:	f0 
f01017f2:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f01017f9:	00 
f01017fa:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101801:	e8 b5 e8 ff ff       	call   f01000bb <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0101806:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010180d:	00 
f010180e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101815:	00 
f0101816:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101819:	89 44 24 04          	mov    %eax,0x4(%esp)
f010181d:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0101822:	89 04 24             	mov    %eax,(%esp)
f0101825:	e8 48 f8 ff ff       	call   f0101072 <page_insert>
f010182a:	85 c0                	test   %eax,%eax
f010182c:	78 24                	js     f0101852 <i386_vm_init+0x74f>
f010182e:	c7 44 24 0c 60 50 10 	movl   $0xf0105060,0xc(%esp)
f0101835:	f0 
f0101836:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f010183d:	f0 
f010183e:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101845:	00 
f0101846:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010184d:	e8 69 e8 ff ff       	call   f01000bb <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101852:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101855:	89 04 24             	mov    %eax,(%esp)
f0101858:	e8 02 f5 ff ff       	call   f0100d5f <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f010185d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101864:	00 
f0101865:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010186c:	00 
f010186d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101870:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101874:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0101879:	89 04 24             	mov    %eax,(%esp)
f010187c:	e8 f1 f7 ff ff       	call   f0101072 <page_insert>
f0101881:	85 c0                	test   %eax,%eax
f0101883:	74 24                	je     f01018a9 <i386_vm_init+0x7a6>
f0101885:	c7 44 24 0c 8c 50 10 	movl   $0xf010508c,0xc(%esp)
f010188c:	f0 
f010188d:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101894:	f0 
f0101895:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f010189c:	00 
f010189d:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01018a4:	e8 12 e8 ff ff       	call   f01000bb <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01018a9:	8b 35 08 3a 17 f0    	mov    0xf0173a08,%esi
f01018af:	8b 7d dc             	mov    -0x24(%ebp),%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01018b2:	8b 15 0c 3a 17 f0    	mov    0xf0173a0c,%edx
f01018b8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01018bb:	8b 16                	mov    (%esi),%edx
f01018bd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018c3:	89 f8                	mov    %edi,%eax
f01018c5:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f01018c8:	c1 f8 02             	sar    $0x2,%eax
f01018cb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01018d1:	c1 e0 0c             	shl    $0xc,%eax
f01018d4:	39 c2                	cmp    %eax,%edx
f01018d6:	74 24                	je     f01018fc <i386_vm_init+0x7f9>
f01018d8:	c7 44 24 0c b8 50 10 	movl   $0xf01050b8,0xc(%esp)
f01018df:	f0 
f01018e0:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01018e7:	f0 
f01018e8:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f01018ef:	00 
f01018f0:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01018f7:	e8 bf e7 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f01018fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101901:	89 f0                	mov    %esi,%eax
f0101903:	e8 ad f1 ff ff       	call   f0100ab5 <check_va2pa>
f0101908:	8b 55 d8             	mov    -0x28(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010190b:	89 d1                	mov    %edx,%ecx
f010190d:	2b 4d c4             	sub    -0x3c(%ebp),%ecx
f0101910:	c1 f9 02             	sar    $0x2,%ecx
f0101913:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101919:	c1 e1 0c             	shl    $0xc,%ecx
f010191c:	39 c8                	cmp    %ecx,%eax
f010191e:	74 24                	je     f0101944 <i386_vm_init+0x841>
f0101920:	c7 44 24 0c e0 50 10 	movl   $0xf01050e0,0xc(%esp)
f0101927:	f0 
f0101928:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f010192f:	f0 
f0101930:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101937:	00 
f0101938:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010193f:	e8 77 e7 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 1);
f0101944:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101949:	74 24                	je     f010196f <i386_vm_init+0x86c>
f010194b:	c7 44 24 0c c1 55 10 	movl   $0xf01055c1,0xc(%esp)
f0101952:	f0 
f0101953:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f010195a:	f0 
f010195b:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101962:	00 
f0101963:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010196a:	e8 4c e7 ff ff       	call   f01000bb <_panic>
	assert(pp0->pp_ref == 1);
f010196f:	66 83 7f 08 01       	cmpw   $0x1,0x8(%edi)
f0101974:	74 24                	je     f010199a <i386_vm_init+0x897>
f0101976:	c7 44 24 0c d2 55 10 	movl   $0xf01055d2,0xc(%esp)
f010197d:	f0 
f010197e:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101985:	f0 
f0101986:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f010198d:	00 
f010198e:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101995:	e8 21 e7 ff ff       	call   f01000bb <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f010199a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01019a1:	00 
f01019a2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019a9:	00 
f01019aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019b1:	89 34 24             	mov    %esi,(%esp)
f01019b4:	e8 b9 f6 ff ff       	call   f0101072 <page_insert>
f01019b9:	85 c0                	test   %eax,%eax
f01019bb:	74 24                	je     f01019e1 <i386_vm_init+0x8de>
f01019bd:	c7 44 24 0c 10 51 10 	movl   $0xf0105110,0xc(%esp)
f01019c4:	f0 
f01019c5:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01019cc:	f0 
f01019cd:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f01019d4:	00 
f01019d5:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01019dc:	e8 da e6 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01019e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019e6:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f01019eb:	e8 c5 f0 ff ff       	call   f0100ab5 <check_va2pa>
f01019f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01019f3:	89 d1                	mov    %edx,%ecx
f01019f5:	2b 0d 0c 3a 17 f0    	sub    0xf0173a0c,%ecx
f01019fb:	c1 f9 02             	sar    $0x2,%ecx
f01019fe:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101a04:	c1 e1 0c             	shl    $0xc,%ecx
f0101a07:	39 c8                	cmp    %ecx,%eax
f0101a09:	74 24                	je     f0101a2f <i386_vm_init+0x92c>
f0101a0b:	c7 44 24 0c 48 51 10 	movl   $0xf0105148,0xc(%esp)
f0101a12:	f0 
f0101a13:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101a1a:	f0 
f0101a1b:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101a22:	00 
f0101a23:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101a2a:	e8 8c e6 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101a2f:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101a34:	74 24                	je     f0101a5a <i386_vm_init+0x957>
f0101a36:	c7 44 24 0c e3 55 10 	movl   $0xf01055e3,0xc(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101a4d:	00 
f0101a4e:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101a55:	e8 61 e6 ff ff       	call   f01000bb <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101a5a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101a5d:	89 04 24             	mov    %eax,(%esp)
f0101a60:	e8 a9 f2 ff ff       	call   f0100d0e <page_alloc>
f0101a65:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101a68:	74 24                	je     f0101a8e <i386_vm_init+0x98b>
f0101a6a:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101a79:	f0 
f0101a7a:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101a81:	00 
f0101a82:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101a89:	e8 2d e6 ff ff       	call   f01000bb <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101a8e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101a95:	00 
f0101a96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a9d:	00 
f0101a9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101aa5:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0101aaa:	89 04 24             	mov    %eax,(%esp)
f0101aad:	e8 c0 f5 ff ff       	call   f0101072 <page_insert>
f0101ab2:	85 c0                	test   %eax,%eax
f0101ab4:	74 24                	je     f0101ada <i386_vm_init+0x9d7>
f0101ab6:	c7 44 24 0c 10 51 10 	movl   $0xf0105110,0xc(%esp)
f0101abd:	f0 
f0101abe:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101ac5:	f0 
f0101ac6:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101acd:	00 
f0101ace:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101ad5:	e8 e1 e5 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101ada:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101adf:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0101ae4:	e8 cc ef ff ff       	call   f0100ab5 <check_va2pa>
f0101ae9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101aec:	89 d1                	mov    %edx,%ecx
f0101aee:	2b 0d 0c 3a 17 f0    	sub    0xf0173a0c,%ecx
f0101af4:	c1 f9 02             	sar    $0x2,%ecx
f0101af7:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101afd:	c1 e1 0c             	shl    $0xc,%ecx
f0101b00:	39 c8                	cmp    %ecx,%eax
f0101b02:	74 24                	je     f0101b28 <i386_vm_init+0xa25>
f0101b04:	c7 44 24 0c 48 51 10 	movl   $0xf0105148,0xc(%esp)
f0101b0b:	f0 
f0101b0c:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101b13:	f0 
f0101b14:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0101b1b:	00 
f0101b1c:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101b23:	e8 93 e5 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101b28:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101b2d:	74 24                	je     f0101b53 <i386_vm_init+0xa50>
f0101b2f:	c7 44 24 0c e3 55 10 	movl   $0xf01055e3,0xc(%esp)
f0101b36:	f0 
f0101b37:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101b3e:	f0 
f0101b3f:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101b46:	00 
f0101b47:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101b4e:	e8 68 e5 ff ff       	call   f01000bb <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101b53:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101b56:	89 04 24             	mov    %eax,(%esp)
f0101b59:	e8 b0 f1 ff ff       	call   f0100d0e <page_alloc>
f0101b5e:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101b61:	74 24                	je     f0101b87 <i386_vm_init+0xa84>
f0101b63:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f0101b6a:	f0 
f0101b6b:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101b72:	f0 
f0101b73:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0101b7a:	00 
f0101b7b:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101b82:	e8 34 e5 ff ff       	call   f01000bb <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0101b87:	8b 15 08 3a 17 f0    	mov    0xf0173a08,%edx
f0101b8d:	8b 02                	mov    (%edx),%eax
f0101b8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101b94:	89 c1                	mov    %eax,%ecx
f0101b96:	c1 e9 0c             	shr    $0xc,%ecx
f0101b99:	3b 0d 00 3a 17 f0    	cmp    0xf0173a00,%ecx
f0101b9f:	72 20                	jb     f0101bc1 <i386_vm_init+0xabe>
f0101ba1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ba5:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f0101bac:	f0 
f0101bad:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0101bb4:	00 
f0101bb5:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101bbc:	e8 fa e4 ff ff       	call   f01000bb <_panic>
f0101bc1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101bc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(boot_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bc9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bd0:	00 
f0101bd1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101bd8:	00 
f0101bd9:	89 14 24             	mov    %edx,(%esp)
f0101bdc:	e8 f0 f1 ff ff       	call   f0100dd1 <pgdir_walk>
f0101be1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101be4:	83 c2 04             	add    $0x4,%edx
f0101be7:	39 d0                	cmp    %edx,%eax
f0101be9:	74 24                	je     f0101c0f <i386_vm_init+0xb0c>
f0101beb:	c7 44 24 0c 78 51 10 	movl   $0xf0105178,0xc(%esp)
f0101bf2:	f0 
f0101bf3:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101bfa:	f0 
f0101bfb:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101c02:	00 
f0101c03:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101c0a:	e8 ac e4 ff ff       	call   f01000bb <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0101c0f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0101c16:	00 
f0101c17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c1e:	00 
f0101c1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c26:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0101c2b:	89 04 24             	mov    %eax,(%esp)
f0101c2e:	e8 3f f4 ff ff       	call   f0101072 <page_insert>
f0101c33:	85 c0                	test   %eax,%eax
f0101c35:	74 24                	je     f0101c5b <i386_vm_init+0xb58>
f0101c37:	c7 44 24 0c b8 51 10 	movl   $0xf01051b8,0xc(%esp)
f0101c3e:	f0 
f0101c3f:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101c46:	f0 
f0101c47:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0101c4e:	00 
f0101c4f:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101c56:	e8 60 e4 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101c5b:	8b 35 08 3a 17 f0    	mov    0xf0173a08,%esi
f0101c61:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c66:	89 f0                	mov    %esi,%eax
f0101c68:	e8 48 ee ff ff       	call   f0100ab5 <check_va2pa>
f0101c6d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101c70:	89 d1                	mov    %edx,%ecx
f0101c72:	2b 0d 0c 3a 17 f0    	sub    0xf0173a0c,%ecx
f0101c78:	c1 f9 02             	sar    $0x2,%ecx
f0101c7b:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101c81:	c1 e1 0c             	shl    $0xc,%ecx
f0101c84:	39 c8                	cmp    %ecx,%eax
f0101c86:	74 24                	je     f0101cac <i386_vm_init+0xba9>
f0101c88:	c7 44 24 0c 48 51 10 	movl   $0xf0105148,0xc(%esp)
f0101c8f:	f0 
f0101c90:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101c97:	f0 
f0101c98:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0101c9f:	00 
f0101ca0:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101ca7:	e8 0f e4 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101cac:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101cb1:	74 24                	je     f0101cd7 <i386_vm_init+0xbd4>
f0101cb3:	c7 44 24 0c e3 55 10 	movl   $0xf01055e3,0xc(%esp)
f0101cba:	f0 
f0101cbb:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101cc2:	f0 
f0101cc3:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0101cca:	00 
f0101ccb:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101cd2:	e8 e4 e3 ff ff       	call   f01000bb <_panic>
	assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cd7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cde:	00 
f0101cdf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ce6:	00 
f0101ce7:	89 34 24             	mov    %esi,(%esp)
f0101cea:	e8 e2 f0 ff ff       	call   f0100dd1 <pgdir_walk>
f0101cef:	f6 00 04             	testb  $0x4,(%eax)
f0101cf2:	75 24                	jne    f0101d18 <i386_vm_init+0xc15>
f0101cf4:	c7 44 24 0c f4 51 10 	movl   $0xf01051f4,0xc(%esp)
f0101cfb:	f0 
f0101cfc:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101d03:	f0 
f0101d04:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0101d0b:	00 
f0101d0c:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101d13:	e8 a3 e3 ff ff       	call   f01000bb <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101d18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101d1f:	00 
f0101d20:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101d27:	00 
f0101d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d2f:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0101d34:	89 04 24             	mov    %eax,(%esp)
f0101d37:	e8 36 f3 ff ff       	call   f0101072 <page_insert>
f0101d3c:	85 c0                	test   %eax,%eax
f0101d3e:	78 24                	js     f0101d64 <i386_vm_init+0xc61>
f0101d40:	c7 44 24 0c 28 52 10 	movl   $0xf0105228,0xc(%esp)
f0101d47:	f0 
f0101d48:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101d4f:	f0 
f0101d50:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101d57:	00 
f0101d58:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101d5f:	e8 57 e3 ff ff       	call   f01000bb <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d64:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101d6b:	00 
f0101d6c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d73:	00 
f0101d74:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d7b:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0101d80:	89 04 24             	mov    %eax,(%esp)
f0101d83:	e8 ea f2 ff ff       	call   f0101072 <page_insert>
f0101d88:	85 c0                	test   %eax,%eax
f0101d8a:	74 24                	je     f0101db0 <i386_vm_init+0xcad>
f0101d8c:	c7 44 24 0c 5c 52 10 	movl   $0xf010525c,0xc(%esp)
f0101d93:	f0 
f0101d94:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101d9b:	f0 
f0101d9c:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101da3:	00 
f0101da4:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101dab:	e8 0b e3 ff ff       	call   f01000bb <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0101db0:	8b 3d 08 3a 17 f0    	mov    0xf0173a08,%edi
f0101db6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dbb:	89 f8                	mov    %edi,%eax
f0101dbd:	e8 f3 ec ff ff       	call   f0100ab5 <check_va2pa>
f0101dc2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101dc5:	8b 75 d8             	mov    -0x28(%ebp),%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101dc8:	89 f0                	mov    %esi,%eax
f0101dca:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f0101dd0:	c1 f8 02             	sar    $0x2,%eax
f0101dd3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101dd9:	c1 e0 0c             	shl    $0xc,%eax
f0101ddc:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101ddf:	74 24                	je     f0101e05 <i386_vm_init+0xd02>
f0101de1:	c7 44 24 0c 94 52 10 	movl   $0xf0105294,0xc(%esp)
f0101de8:	f0 
f0101de9:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101df0:	f0 
f0101df1:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0101df8:	00 
f0101df9:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101e00:	e8 b6 e2 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101e05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e0a:	89 f8                	mov    %edi,%eax
f0101e0c:	e8 a4 ec ff ff       	call   f0100ab5 <check_va2pa>
f0101e11:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101e14:	74 24                	je     f0101e3a <i386_vm_init+0xd37>
f0101e16:	c7 44 24 0c c0 52 10 	movl   $0xf01052c0,0xc(%esp)
f0101e1d:	f0 
f0101e1e:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101e25:	f0 
f0101e26:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101e2d:	00 
f0101e2e:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101e35:	e8 81 e2 ff ff       	call   f01000bb <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e3a:	66 83 7e 08 02       	cmpw   $0x2,0x8(%esi)
f0101e3f:	74 24                	je     f0101e65 <i386_vm_init+0xd62>
f0101e41:	c7 44 24 0c f4 55 10 	movl   $0xf01055f4,0xc(%esp)
f0101e48:	f0 
f0101e49:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101e50:	f0 
f0101e51:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101e58:	00 
f0101e59:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101e60:	e8 56 e2 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0101e65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e68:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101e6d:	74 24                	je     f0101e93 <i386_vm_init+0xd90>
f0101e6f:	c7 44 24 0c 05 56 10 	movl   $0xf0105605,0xc(%esp)
f0101e76:	f0 
f0101e77:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101e7e:	f0 
f0101e7f:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0101e86:	00 
f0101e87:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101e8e:	e8 28 e2 ff ff       	call   f01000bb <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f0101e93:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101e96:	89 04 24             	mov    %eax,(%esp)
f0101e99:	e8 70 ee ff ff       	call   f0100d0e <page_alloc>
f0101e9e:	85 c0                	test   %eax,%eax
f0101ea0:	75 08                	jne    f0101eaa <i386_vm_init+0xda7>
f0101ea2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ea5:	39 4d e0             	cmp    %ecx,-0x20(%ebp)
f0101ea8:	74 24                	je     f0101ece <i386_vm_init+0xdcb>
f0101eaa:	c7 44 24 0c f0 52 10 	movl   $0xf01052f0,0xc(%esp)
f0101eb1:	f0 
f0101eb2:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101eb9:	f0 
f0101eba:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101ec1:	00 
f0101ec2:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101ec9:	e8 ed e1 ff ff       	call   f01000bb <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0101ece:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ed5:	00 
f0101ed6:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0101edb:	89 04 24             	mov    %eax,(%esp)
f0101ede:	e8 3f f1 ff ff       	call   f0101022 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101ee3:	8b 35 08 3a 17 f0    	mov    0xf0173a08,%esi
f0101ee9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eee:	89 f0                	mov    %esi,%eax
f0101ef0:	e8 c0 eb ff ff       	call   f0100ab5 <check_va2pa>
f0101ef5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ef8:	74 24                	je     f0101f1e <i386_vm_init+0xe1b>
f0101efa:	c7 44 24 0c 14 53 10 	movl   $0xf0105314,0xc(%esp)
f0101f01:	f0 
f0101f02:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101f11:	00 
f0101f12:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101f19:	e8 9d e1 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101f1e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f23:	89 f0                	mov    %esi,%eax
f0101f25:	e8 8b eb ff ff       	call   f0100ab5 <check_va2pa>
f0101f2a:	8b 55 d8             	mov    -0x28(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101f2d:	89 d1                	mov    %edx,%ecx
f0101f2f:	2b 0d 0c 3a 17 f0    	sub    0xf0173a0c,%ecx
f0101f35:	c1 f9 02             	sar    $0x2,%ecx
f0101f38:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101f3e:	c1 e1 0c             	shl    $0xc,%ecx
f0101f41:	39 c8                	cmp    %ecx,%eax
f0101f43:	74 24                	je     f0101f69 <i386_vm_init+0xe66>
f0101f45:	c7 44 24 0c c0 52 10 	movl   $0xf01052c0,0xc(%esp)
f0101f4c:	f0 
f0101f4d:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101f54:	f0 
f0101f55:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101f5c:	00 
f0101f5d:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101f64:	e8 52 e1 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 1);
f0101f69:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101f6e:	74 24                	je     f0101f94 <i386_vm_init+0xe91>
f0101f70:	c7 44 24 0c c1 55 10 	movl   $0xf01055c1,0xc(%esp)
f0101f77:	f0 
f0101f78:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101f7f:	f0 
f0101f80:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101f87:	00 
f0101f88:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101f8f:	e8 27 e1 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0101f94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f97:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101f9c:	74 24                	je     f0101fc2 <i386_vm_init+0xebf>
f0101f9e:	c7 44 24 0c 05 56 10 	movl   $0xf0105605,0xc(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101fb5:	00 
f0101fb6:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0101fbd:	e8 f9 e0 ff ff       	call   f01000bb <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0101fc2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fc9:	00 
f0101fca:	89 34 24             	mov    %esi,(%esp)
f0101fcd:	e8 50 f0 ff ff       	call   f0101022 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101fd2:	8b 35 08 3a 17 f0    	mov    0xf0173a08,%esi
f0101fd8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fdd:	89 f0                	mov    %esi,%eax
f0101fdf:	e8 d1 ea ff ff       	call   f0100ab5 <check_va2pa>
f0101fe4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fe7:	74 24                	je     f010200d <i386_vm_init+0xf0a>
f0101fe9:	c7 44 24 0c 14 53 10 	movl   $0xf0105314,0xc(%esp)
f0101ff0:	f0 
f0101ff1:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0101ff8:	f0 
f0101ff9:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0102000:	00 
f0102001:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102008:	e8 ae e0 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f010200d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102012:	89 f0                	mov    %esi,%eax
f0102014:	e8 9c ea ff ff       	call   f0100ab5 <check_va2pa>
f0102019:	83 f8 ff             	cmp    $0xffffffff,%eax
f010201c:	74 24                	je     f0102042 <i386_vm_init+0xf3f>
f010201e:	c7 44 24 0c 38 53 10 	movl   $0xf0105338,0xc(%esp)
f0102025:	f0 
f0102026:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f010202d:	f0 
f010202e:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102035:	00 
f0102036:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010203d:	e8 79 e0 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 0);
f0102042:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102045:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010204a:	74 24                	je     f0102070 <i386_vm_init+0xf6d>
f010204c:	c7 44 24 0c 16 56 10 	movl   $0xf0105616,0xc(%esp)
f0102053:	f0 
f0102054:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f010205b:	f0 
f010205c:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102063:	00 
f0102064:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010206b:	e8 4b e0 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0102070:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102073:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102078:	74 24                	je     f010209e <i386_vm_init+0xf9b>
f010207a:	c7 44 24 0c 05 56 10 	movl   $0xf0105605,0xc(%esp)
f0102081:	f0 
f0102082:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0102089:	f0 
f010208a:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102091:	00 
f0102092:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102099:	e8 1d e0 ff ff       	call   f01000bb <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f010209e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01020a1:	89 04 24             	mov    %eax,(%esp)
f01020a4:	e8 65 ec ff ff       	call   f0100d0e <page_alloc>
f01020a9:	85 c0                	test   %eax,%eax
f01020ab:	75 08                	jne    f01020b5 <i386_vm_init+0xfb2>
f01020ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01020b0:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f01020b3:	74 24                	je     f01020d9 <i386_vm_init+0xfd6>
f01020b5:	c7 44 24 0c 60 53 10 	movl   $0xf0105360,0xc(%esp)
f01020bc:	f0 
f01020bd:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01020c4:	f0 
f01020c5:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01020cc:	00 
f01020cd:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01020d4:	e8 e2 df ff ff       	call   f01000bb <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01020d9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01020dc:	89 04 24             	mov    %eax,(%esp)
f01020df:	e8 2a ec ff ff       	call   f0100d0e <page_alloc>
f01020e4:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01020e7:	74 24                	je     f010210d <i386_vm_init+0x100a>
f01020e9:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f01020f0:	f0 
f01020f1:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01020f8:	f0 
f01020f9:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102100:	00 
f0102101:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102108:	e8 ae df ff ff       	call   f01000bb <_panic>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f010210d:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f0102112:	8b 08                	mov    (%eax),%ecx
f0102114:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010211a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010211d:	2b 15 0c 3a 17 f0    	sub    0xf0173a0c,%edx
f0102123:	c1 fa 02             	sar    $0x2,%edx
f0102126:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010212c:	c1 e2 0c             	shl    $0xc,%edx
f010212f:	39 d1                	cmp    %edx,%ecx
f0102131:	74 24                	je     f0102157 <i386_vm_init+0x1054>
f0102133:	c7 44 24 0c b8 50 10 	movl   $0xf01050b8,0xc(%esp)
f010213a:	f0 
f010213b:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0102142:	f0 
f0102143:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f010214a:	00 
f010214b:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102152:	e8 64 df ff ff       	call   f01000bb <_panic>
	boot_pgdir[0] = 0;
f0102157:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010215d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102160:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102165:	74 24                	je     f010218b <i386_vm_init+0x1088>
f0102167:	c7 44 24 0c d2 55 10 	movl   $0xf01055d2,0xc(%esp)
f010216e:	f0 
f010216f:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0102176:	f0 
f0102177:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f010217e:	00 
f010217f:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102186:	e8 30 df ff ff       	call   f01000bb <_panic>
	pp0->pp_ref = 0;
f010218b:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102191:	89 04 24             	mov    %eax,(%esp)
f0102194:	e8 c6 eb ff ff       	call   f0100d5f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(boot_pgdir, va, 1);
f0102199:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01021a0:	00 
f01021a1:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01021a8:	00 
f01021a9:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f01021ae:	89 04 24             	mov    %eax,(%esp)
f01021b1:	e8 1b ec ff ff       	call   f0100dd1 <pgdir_walk>
f01021b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f01021b9:	8b 35 08 3a 17 f0    	mov    0xf0173a08,%esi
f01021bf:	8b 56 04             	mov    0x4(%esi),%edx
f01021c2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021c8:	8b 0d 00 3a 17 f0    	mov    0xf0173a00,%ecx
f01021ce:	89 d7                	mov    %edx,%edi
f01021d0:	c1 ef 0c             	shr    $0xc,%edi
f01021d3:	39 cf                	cmp    %ecx,%edi
f01021d5:	72 20                	jb     f01021f7 <i386_vm_init+0x10f4>
f01021d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01021db:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01021f2:	e8 c4 de ff ff       	call   f01000bb <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021f7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01021fd:	39 d0                	cmp    %edx,%eax
f01021ff:	74 24                	je     f0102225 <i386_vm_init+0x1122>
f0102201:	c7 44 24 0c 27 56 10 	movl   $0xf0105627,0xc(%esp)
f0102208:	f0 
f0102209:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0102210:	f0 
f0102211:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102218:	00 
f0102219:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102220:	e8 96 de ff ff       	call   f01000bb <_panic>
	boot_pgdir[PDX(va)] = 0;
f0102225:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	pp0->pp_ref = 0;
f010222c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010222f:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102235:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f010223b:	c1 f8 02             	sar    $0x2,%eax
f010223e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102244:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102247:	89 c2                	mov    %eax,%edx
f0102249:	c1 ea 0c             	shr    $0xc,%edx
f010224c:	39 d1                	cmp    %edx,%ecx
f010224e:	77 20                	ja     f0102270 <i386_vm_init+0x116d>
f0102250:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102254:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f010225b:	f0 
f010225c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102263:	00 
f0102264:	c7 04 24 d9 54 10 f0 	movl   $0xf01054d9,(%esp)
f010226b:	e8 4b de ff ff       	call   f01000bb <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102270:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102277:	00 
f0102278:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010227f:	00 
f0102280:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102285:	89 04 24             	mov    %eax,(%esp)
f0102288:	e8 d9 20 00 00       	call   f0104366 <memset>
	page_free(pp0);
f010228d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102290:	89 04 24             	mov    %eax,(%esp)
f0102293:	e8 c7 ea ff ff       	call   f0100d5f <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f0102298:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010229f:	00 
f01022a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022a7:	00 
f01022a8:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f01022ad:	89 04 24             	mov    %eax,(%esp)
f01022b0:	e8 1c eb ff ff       	call   f0100dd1 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01022b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01022b8:	2b 15 0c 3a 17 f0    	sub    0xf0173a0c,%edx
f01022be:	c1 fa 02             	sar    $0x2,%edx
f01022c1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01022c7:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01022ca:	89 d0                	mov    %edx,%eax
f01022cc:	c1 e8 0c             	shr    $0xc,%eax
f01022cf:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f01022d5:	72 20                	jb     f01022f7 <i386_vm_init+0x11f4>
f01022d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01022db:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f01022e2:	f0 
f01022e3:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01022ea:	00 
f01022eb:	c7 04 24 d9 54 10 f0 	movl   $0xf01054d9,(%esp)
f01022f2:	e8 c4 dd ff ff       	call   f01000bb <_panic>
f01022f7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = page2kva(pp0);
f01022fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102300:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102307:	75 11                	jne    f010231a <i386_vm_init+0x1217>
f0102309:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f010230f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102315:	f6 00 01             	testb  $0x1,(%eax)
f0102318:	74 24                	je     f010233e <i386_vm_init+0x123b>
f010231a:	c7 44 24 0c 3f 56 10 	movl   $0xf010563f,0xc(%esp)
f0102321:	f0 
f0102322:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0102329:	f0 
f010232a:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102331:	00 
f0102332:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102339:	e8 7d dd ff ff       	call   f01000bb <_panic>
f010233e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102341:	39 d0                	cmp    %edx,%eax
f0102343:	75 d0                	jne    f0102315 <i386_vm_init+0x1212>
		assert((ptep[i] & PTE_P) == 0);
	boot_pgdir[0] = 0;
f0102345:	a1 08 3a 17 f0       	mov    0xf0173a08,%eax
f010234a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102350:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102353:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0102359:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010235c:	89 15 58 2d 17 f0    	mov    %edx,0xf0172d58

	// free the pages we took
	page_free(pp0);
f0102362:	89 04 24             	mov    %eax,(%esp)
f0102365:	e8 f5 e9 ff ff       	call   f0100d5f <page_free>
	page_free(pp1);
f010236a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010236d:	89 04 24             	mov    %eax,(%esp)
f0102370:	e8 ea e9 ff ff       	call   f0100d5f <page_free>
	page_free(pp2);
f0102375:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102378:	89 04 24             	mov    %eax,(%esp)
f010237b:	e8 df e9 ff ff       	call   f0100d5f <page_free>
	
	cprintf("page_check() succeeded!\n");
f0102380:	c7 04 24 56 56 10 f0 	movl   $0xf0105656,(%esp)
f0102387:	e8 da 0b 00 00       	call   f0102f66 <cprintf>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here:
	// [UPAGES, sizeof(PAGES) ] => [pages, sizeof(PAGES)]
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f010238c:	8b 15 00 3a 17 f0    	mov    0xf0173a00,%edx
	boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f0102392:	a1 0c 3a 17 f0       	mov    0xf0173a0c,%eax
f0102397:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010239c:	77 20                	ja     f01023be <i386_vm_init+0x12bb>
f010239e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023a2:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01023b9:	e8 fd dc ff ff       	call   f01000bb <_panic>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here:
	// [UPAGES, sizeof(PAGES) ] => [pages, sizeof(PAGES)]
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f01023be:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01023c1:	8d 0c 95 ff 0f 00 00 	lea    0xfff(,%edx,4),%ecx
f01023c8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f01023ce:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01023d5:	00 
f01023d6:	05 00 00 00 10       	add    $0x10000000,%eax
f01023db:	89 04 24             	mov    %eax,(%esp)
f01023de:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01023e3:	89 d8                	mov    %ebx,%eax
f01023e5:	e8 3d eb ff ff       	call   f0100f27 <boot_map_segment>
	// Permissions:
	//    - envs itself -- kernel RW, user NONE
	//    - the image of envs mapped at UENVS  -- kernel R, user R
	// Lab3: Your code goes here:
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	boot_map_segment(pgdir, UENVS, n, PADDR(envs), PTE_U | PTE_P);
f01023ea:	a1 60 2d 17 f0       	mov    0xf0172d60,%eax
f01023ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023f4:	77 20                	ja     f0102416 <i386_vm_init+0x1313>
f01023f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023fa:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f0102401:	f0 
f0102402:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102409:	00 
f010240a:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102411:	e8 a5 dc ff ff       	call   f01000bb <_panic>
f0102416:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f010241d:	00 
f010241e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102423:	89 04 24             	mov    %eax,(%esp)
f0102426:	b9 00 90 01 00       	mov    $0x19000,%ecx
f010242b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102430:	89 d8                	mov    %ebx,%eax
f0102432:	e8 f0 ea ff ff       	call   f0100f27 <boot_map_segment>
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed => faults
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// [KSTACKTOP – KSTKSIZE, 8] => [bootstack, 8]
	boot_map_segment(pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0102437:	be 00 00 11 f0       	mov    $0xf0110000,%esi
f010243c:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102442:	77 20                	ja     f0102464 <i386_vm_init+0x1361>
f0102444:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102448:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f010244f:	f0 
f0102450:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f0102457:	00 
f0102458:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010245f:	e8 57 dc ff ff       	call   f01000bb <_panic>
f0102464:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010246b:	00 
f010246c:	c7 04 24 00 00 11 00 	movl   $0x110000,(%esp)
f0102473:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102478:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010247d:	89 d8                	mov    %ebx,%eax
f010247f:	e8 a3 ea ff ff       	call   f0100f27 <boot_map_segment>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the amapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	// [KERNBASE, pages in the memory] => [0, pages in the memory]
	boot_map_segment(pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_W | PTE_P);
f0102484:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010248b:	00 
f010248c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102493:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102498:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010249d:	89 d8                	mov    %ebx,%eax
f010249f:	e8 83 ea ff ff       	call   f0100f27 <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f01024a4:	8b 3d 08 3a 17 f0    	mov    0xf0173a08,%edi

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f01024aa:	8b 0d 00 3a 17 f0    	mov    0xf0173a00,%ecx
f01024b0:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f01024b3:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01024b6:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
	for (i = 0; i < n; i += PGSIZE)
f01024bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01024c2:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01024c5:	0f 84 8f 00 00 00    	je     f010255a <i386_vm_init+0x1457>
f01024cb:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f01024d2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01024d5:	81 ea 00 00 00 11    	sub    $0x11000000,%edx
	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01024db:	89 f8                	mov    %edi,%eax
f01024dd:	e8 d3 e5 ff ff       	call   f0100ab5 <check_va2pa>
f01024e2:	8b 15 0c 3a 17 f0    	mov    0xf0173a0c,%edx
f01024e8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01024ee:	77 20                	ja     f0102510 <i386_vm_init+0x140d>
f01024f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024f4:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f01024fb:	f0 
f01024fc:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102503:	00 
f0102504:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010250b:	e8 ab db ff ff       	call   f01000bb <_panic>
f0102510:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102513:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f010251a:	39 d0                	cmp    %edx,%eax
f010251c:	74 24                	je     f0102542 <i386_vm_init+0x143f>
f010251e:	c7 44 24 0c 84 53 10 	movl   $0xf0105384,0xc(%esp)
f0102525:	f0 
f0102526:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f010252d:	f0 
f010252e:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102535:	00 
f0102536:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010253d:	e8 79 db ff ff       	call   f01000bb <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102542:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f0102549:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010254c:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f010254f:	77 81                	ja     f01024d2 <i386_vm_init+0x13cf>
f0102551:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
f0102558:	eb 07                	jmp    f0102561 <i386_vm_init+0x145e>
f010255a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f0102561:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102564:	81 ea 00 00 40 11    	sub    $0x11400000,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010256a:	89 f8                	mov    %edi,%eax
f010256c:	e8 44 e5 ff ff       	call   f0100ab5 <check_va2pa>
f0102571:	8b 15 60 2d 17 f0    	mov    0xf0172d60,%edx
f0102577:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010257d:	77 20                	ja     f010259f <i386_vm_init+0x149c>
f010257f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102583:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f010258a:	f0 
f010258b:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0102592:	00 
f0102593:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f010259a:	e8 1c db ff ff       	call   f01000bb <_panic>
f010259f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01025a2:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f01025a9:	39 d0                	cmp    %edx,%eax
f01025ab:	74 24                	je     f01025d1 <i386_vm_init+0x14ce>
f01025ad:	c7 44 24 0c b8 53 10 	movl   $0xf01053b8,0xc(%esp)
f01025b4:	f0 
f01025b5:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f01025c4:	00 
f01025c5:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01025cc:	e8 ea da ff ff       	call   f01000bb <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025d1:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f01025d8:	81 7d c4 00 90 01 00 	cmpl   $0x19000,-0x3c(%ebp)
f01025df:	75 80                	jne    f0102561 <i386_vm_init+0x145e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
f01025e1:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f01025e5:	74 4f                	je     f0102636 <i386_vm_init+0x1533>
f01025e7:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f01025ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01025f1:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01025f7:	89 f8                	mov    %edi,%eax
f01025f9:	e8 b7 e4 ff ff       	call   f0100ab5 <check_va2pa>
f01025fe:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0102601:	74 24                	je     f0102627 <i386_vm_init+0x1524>
f0102603:	c7 44 24 0c ec 53 10 	movl   $0xf01053ec,0xc(%esp)
f010260a:	f0 
f010260b:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0102612:	f0 
f0102613:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f010261a:	00 
f010261b:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102622:	e8 94 da ff ff       	call   f01000bb <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
f0102627:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f010262e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102631:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0102634:	77 b8                	ja     f01025ee <i386_vm_init+0x14eb>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102636:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010263b:	89 f8                	mov    %edi,%eax
f010263d:	e8 73 e4 ff ff       	call   f0100ab5 <check_va2pa>
f0102642:	c7 45 c4 00 90 bf ef 	movl   $0xefbf9000,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f0102649:	81 c6 00 70 40 20    	add    $0x20407000,%esi
f010264f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102652:	01 f2                	add    %esi,%edx
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102654:	39 d0                	cmp    %edx,%eax
f0102656:	74 24                	je     f010267c <i386_vm_init+0x1579>
f0102658:	c7 44 24 0c 14 54 10 	movl   $0xf0105414,0xc(%esp)
f010265f:	f0 
f0102660:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0102667:	f0 
f0102668:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f010266f:	00 
f0102670:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102677:	e8 3f da ff ff       	call   f01000bb <_panic>
	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010267c:	81 7d c4 00 00 c0 ef 	cmpl   $0xefc00000,-0x3c(%ebp)
f0102683:	0f 85 07 01 00 00    	jne    f0102790 <i386_vm_init+0x168d>
f0102689:	b8 00 00 00 00       	mov    $0x0,%eax
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010268e:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102694:	83 fa 04             	cmp    $0x4,%edx
f0102697:	77 2a                	ja     f01026c3 <i386_vm_init+0x15c0>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i]);
f0102699:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010269d:	75 7f                	jne    f010271e <i386_vm_init+0x161b>
f010269f:	c7 44 24 0c 6f 56 10 	movl   $0xf010566f,0xc(%esp)
f01026a6:	f0 
f01026a7:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01026ae:	f0 
f01026af:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f01026b6:	00 
f01026b7:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01026be:	e8 f8 d9 ff ff       	call   f01000bb <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f01026c3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01026c8:	76 2a                	jbe    f01026f4 <i386_vm_init+0x15f1>
				assert(pgdir[i]);
f01026ca:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026ce:	75 4e                	jne    f010271e <i386_vm_init+0x161b>
f01026d0:	c7 44 24 0c 6f 56 10 	movl   $0xf010566f,0xc(%esp)
f01026d7:	f0 
f01026d8:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
f01026e7:	00 
f01026e8:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f01026ef:	e8 c7 d9 ff ff       	call   f01000bb <_panic>
			else
				assert(pgdir[i] == 0);
f01026f4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026f8:	74 24                	je     f010271e <i386_vm_init+0x161b>
f01026fa:	c7 44 24 0c 78 56 10 	movl   $0xf0105678,0xc(%esp)
f0102701:	f0 
f0102702:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0102709:	f0 
f010270a:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0102711:	00 
f0102712:	c7 04 24 b1 54 10 f0 	movl   $0xf01054b1,(%esp)
f0102719:	e8 9d d9 ff ff       	call   f01000bb <_panic>
	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f010271e:	83 c0 01             	add    $0x1,%eax
f0102721:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102726:	0f 85 62 ff ff ff    	jne    f010268e <i386_vm_init+0x158b>
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f010272c:	c7 04 24 5c 54 10 f0 	movl   $0xf010545c,(%esp)
f0102733:	e8 2e 08 00 00       	call   f0102f66 <cprintf>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f0102738:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f010273e:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102740:	a1 04 3a 17 f0       	mov    0xf0173a04,%eax
f0102745:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102748:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f010274b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102750:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102753:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0102756:	0f 01 15 20 83 11 f0 	lgdtl  0xf0118320
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010275d:	b8 23 00 00 00       	mov    $0x23,%eax
f0102762:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102764:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102766:	b0 10                	mov    $0x10,%al
f0102768:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010276a:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010276c:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f010276e:	ea 75 27 10 f0 08 00 	ljmp   $0x8,$0xf0102775
	asm volatile("lldt %%ax" :: "a" (0));
f0102775:	b0 00                	mov    $0x0,%al
f0102777:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f010277a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102780:	a1 04 3a 17 f0       	mov    0xf0173a04,%eax
f0102785:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}
f0102788:	83 c4 4c             	add    $0x4c,%esp
f010278b:	5b                   	pop    %ebx
f010278c:	5e                   	pop    %esi
f010278d:	5f                   	pop    %edi
f010278e:	5d                   	pop    %ebp
f010278f:	c3                   	ret    
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102790:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102793:	89 f8                	mov    %edi,%eax
f0102795:	e8 1b e3 ff ff       	call   f0100ab5 <check_va2pa>
f010279a:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f01027a1:	e9 a9 fe ff ff       	jmp    f010264f <i386_vm_init+0x154c>

f01027a6 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01027a6:	55                   	push   %ebp
f01027a7:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here. 

	return 0;
}
f01027a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01027ae:	5d                   	pop    %ebp
f01027af:	c3                   	ret    

f01027b0 <user_mem_assert>:
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01027b0:	55                   	push   %ebp
f01027b1:	89 e5                	mov    %esp,%ebp
f01027b3:	53                   	push   %ebx
f01027b4:	83 ec 14             	sub    $0x14,%esp
f01027b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01027ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01027bd:	83 c8 04             	or     $0x4,%eax
f01027c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027c4:	8b 45 10             	mov    0x10(%ebp),%eax
f01027c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01027cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027d2:	89 1c 24             	mov    %ebx,(%esp)
f01027d5:	e8 cc ff ff ff       	call   f01027a6 <user_mem_check>
f01027da:	85 c0                	test   %eax,%eax
f01027dc:	79 28                	jns    f0102806 <user_mem_assert+0x56>
		cprintf("[%08x] user_mem_check assertion failure for "
f01027de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027e5:	00 
			"va %08x\n", curenv->env_id, user_mem_check_addr);
f01027e6:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
f01027eb:	8b 40 4c             	mov    0x4c(%eax),%eax
f01027ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027f2:	c7 04 24 7c 54 10 f0 	movl   $0xf010547c,(%esp)
f01027f9:	e8 68 07 00 00       	call   f0102f66 <cprintf>
			"va %08x\n", curenv->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01027fe:	89 1c 24             	mov    %ebx,(%esp)
f0102801:	e8 4c 06 00 00       	call   f0102e52 <env_destroy>
	}
}
f0102806:	83 c4 14             	add    $0x14,%esp
f0102809:	5b                   	pop    %ebx
f010280a:	5d                   	pop    %ebp
f010280b:	c3                   	ret    

f010280c <segment_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
segment_alloc(struct Env *e, void *va, size_t len)
{
f010280c:	55                   	push   %ebp
f010280d:	89 e5                	mov    %esp,%ebp
f010280f:	57                   	push   %edi
f0102810:	56                   	push   %esi
f0102811:	53                   	push   %ebx
f0102812:	83 ec 3c             	sub    $0x3c,%esp
f0102815:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use segment_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round len up.
	// this function will allocates and maps physical memory for an environment.
	va = ROUNDDOWN(va, PGSIZE);
f0102817:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010281d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	len = ROUNDUP(len, PGSIZE);
f0102820:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
	struct Page *new_pg;
	int i;
	for (i = 0; i < len; i += PGSIZE)
f0102826:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010282c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010282f:	0f 84 83 00 00 00    	je     f01028b8 <segment_alloc+0xac>
f0102835:	bf 00 00 00 00       	mov    $0x0,%edi
f010283a:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		// allocate a new page
		if (page_alloc(&new_pg) < 0)
f010283f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102842:	89 04 24             	mov    %eax,(%esp)
f0102845:	e8 c4 e4 ff ff       	call   f0100d0e <page_alloc>
f010284a:	85 c0                	test   %eax,%eax
f010284c:	79 1c                	jns    f010286a <segment_alloc+0x5e>
		{
			panic("segment_alloc(): out of memory\n");
f010284e:	c7 44 24 08 88 56 10 	movl   $0xf0105688,0x8(%esp)
f0102855:	f0 
f0102856:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f010285d:	00 
f010285e:	c7 04 24 32 57 10 f0 	movl   $0xf0105732,(%esp)
f0102865:	e8 51 d8 ff ff       	call   f01000bb <_panic>
		}
		// must be e->env_pgdir, not pgdir
		// it is allocated according to env pg dir, as it is allocating pages
		// for user process env
		// User, Writable
		if (page_insert(e->env_pgdir, new_pg, va+i, PTE_U | PTE_W) < 0)
f010286a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102871:	00 
f0102872:	03 7d d4             	add    -0x2c(%ebp),%edi
f0102875:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102879:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010287c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102880:	8b 46 5c             	mov    0x5c(%esi),%eax
f0102883:	89 04 24             	mov    %eax,(%esp)
f0102886:	e8 e7 e7 ff ff       	call   f0101072 <page_insert>
f010288b:	85 c0                	test   %eax,%eax
f010288d:	79 1c                	jns    f01028ab <segment_alloc+0x9f>
		{
			panic("segment_alloc(): page table cannot be allocated\n");
f010288f:	c7 44 24 08 a8 56 10 	movl   $0xf01056a8,0x8(%esp)
f0102896:	f0 
f0102897:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
f010289e:	00 
f010289f:	c7 04 24 32 57 10 f0 	movl   $0xf0105732,(%esp)
f01028a6:	e8 10 d8 ff ff       	call   f01000bb <_panic>
	// this function will allocates and maps physical memory for an environment.
	va = ROUNDDOWN(va, PGSIZE);
	len = ROUNDUP(len, PGSIZE);
	struct Page *new_pg;
	int i;
	for (i = 0; i < len; i += PGSIZE)
f01028ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028b1:	89 df                	mov    %ebx,%edi
f01028b3:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f01028b6:	77 87                	ja     f010283f <segment_alloc+0x33>
		if (page_insert(e->env_pgdir, new_pg, va+i, PTE_U | PTE_W) < 0)
		{
			panic("segment_alloc(): page table cannot be allocated\n");
		}
	}
}
f01028b8:	83 c4 3c             	add    $0x3c,%esp
f01028bb:	5b                   	pop    %ebx
f01028bc:	5e                   	pop    %esi
f01028bd:	5f                   	pop    %edi
f01028be:	5d                   	pop    %ebp
f01028bf:	c3                   	ret    

f01028c0 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01028c0:	55                   	push   %ebp
f01028c1:	89 e5                	mov    %esp,%ebp
f01028c3:	53                   	push   %ebx
f01028c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01028c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01028ca:	85 c0                	test   %eax,%eax
f01028cc:	75 0e                	jne    f01028dc <envid2env+0x1c>
		*env_store = curenv;
f01028ce:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f01028d3:	89 01                	mov    %eax,(%ecx)
		return 0;
f01028d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01028da:	eb 54                	jmp    f0102930 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01028dc:	89 c2                	mov    %eax,%edx
f01028de:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01028e4:	6b d2 64             	imul   $0x64,%edx,%edx
f01028e7:	03 15 60 2d 17 f0    	add    0xf0172d60,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01028ed:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01028f1:	74 05                	je     f01028f8 <envid2env+0x38>
f01028f3:	39 42 4c             	cmp    %eax,0x4c(%edx)
f01028f6:	74 0d                	je     f0102905 <envid2env+0x45>
		*env_store = 0;
f01028f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01028fe:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102903:	eb 2b                	jmp    f0102930 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102905:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102909:	74 1e                	je     f0102929 <envid2env+0x69>
f010290b:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f0102910:	39 c2                	cmp    %eax,%edx
f0102912:	74 15                	je     f0102929 <envid2env+0x69>
f0102914:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0102917:	39 5a 50             	cmp    %ebx,0x50(%edx)
f010291a:	74 0d                	je     f0102929 <envid2env+0x69>
		*env_store = 0;
f010291c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102922:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102927:	eb 07                	jmp    f0102930 <envid2env+0x70>
	}

	*env_store = e;
f0102929:	89 11                	mov    %edx,(%ecx)
	return 0;
f010292b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102930:	5b                   	pop    %ebx
f0102931:	5d                   	pop    %ebp
f0102932:	c3                   	ret    

f0102933 <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f0102933:	55                   	push   %ebp
f0102934:	89 e5                	mov    %esp,%ebp
f0102936:	57                   	push   %edi
f0102937:	56                   	push   %esi
f0102938:	53                   	push   %ebx
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
f0102939:	8b 3d 60 2d 17 f0    	mov    0xf0172d60,%edi
f010293f:	8b 15 64 2d 17 f0    	mov    0xf0172d64,%edx
// and insert them into the env_free_list.
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
f0102945:	8d 87 9c 8f 01 00    	lea    0x18f9c(%edi),%eax
f010294b:	b9 00 04 00 00       	mov    $0x400,%ecx
f0102950:	eb 02                	jmp    f0102954 <env_init+0x21>
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f0102952:	89 da                	mov    %ebx,%edx
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
f0102954:	89 c3                	mov    %eax,%ebx
f0102956:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f010295d:	89 50 44             	mov    %edx,0x44(%eax)
f0102960:	85 d2                	test   %edx,%edx
f0102962:	74 06                	je     f010296a <env_init+0x37>
f0102964:	8d 70 44             	lea    0x44(%eax),%esi
f0102967:	89 72 48             	mov    %esi,0x48(%edx)
f010296a:	c7 43 48 64 2d 17 f0 	movl   $0xf0172d64,0x48(%ebx)
f0102971:	83 e8 64             	sub    $0x64,%eax
	// this function will initialize all of the Env structures
	// in the envs array and add them to the env_free_list.
	// just like page_init()
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
f0102974:	83 e9 01             	sub    $0x1,%ecx
f0102977:	75 d9                	jne    f0102952 <env_init+0x1f>
f0102979:	89 3d 64 2d 17 f0    	mov    %edi,0xf0172d64
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
	}
}
f010297f:	5b                   	pop    %ebx
f0102980:	5e                   	pop    %esi
f0102981:	5f                   	pop    %edi
f0102982:	5d                   	pop    %ebp
f0102983:	c3                   	ret    

f0102984 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102984:	55                   	push   %ebp
f0102985:	89 e5                	mov    %esp,%ebp
f0102987:	53                   	push   %ebx
f0102988:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f010298b:	8b 1d 64 2d 17 f0    	mov    0xf0172d64,%ebx
f0102991:	85 db                	test   %ebx,%ebx
f0102993:	0f 84 c8 01 00 00    	je     f0102b61 <env_alloc+0x1dd>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0102999:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f01029a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01029a3:	89 04 24             	mov    %eax,(%esp)
f01029a6:	e8 63 e3 ff ff       	call   f0100d0e <page_alloc>
f01029ab:	85 c0                	test   %eax,%eax
f01029ad:	0f 88 b3 01 00 00    	js     f0102b66 <env_alloc+0x1e2>

	// LAB 3: Your code here.
	// this function will allocate a page directory for a new environment
	// and initialize the kernel portion of the new environment's address space.
	// increase pp_ref
	++(p->pp_ref);
f01029b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01029b6:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01029bb:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f01029c1:	c1 f8 02             	sar    $0x2,%eax
f01029c4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01029ca:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01029cd:	89 c2                	mov    %eax,%edx
f01029cf:	c1 ea 0c             	shr    $0xc,%edx
f01029d2:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f01029d8:	72 20                	jb     f01029fa <env_alloc+0x76>
f01029da:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029de:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f01029e5:	f0 
f01029e6:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01029ed:	00 
f01029ee:	c7 04 24 d9 54 10 f0 	movl   $0xf01054d9,(%esp)
f01029f5:	e8 c1 d6 ff ff       	call   f01000bb <_panic>
	// Attention: need to clear the memory pointed by the page's va,
	// as it holds the process's pg dir.
	// page2kva is the combination of page2pa and KADDR
	// what will happen if "memset" is commented out? have a try.
	memset(page2kva(p), 0, PGSIZE);
f01029fa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a01:	00 
f0102a02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a09:	00 
f0102a0a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a0f:	89 04 24             	mov    %eax,(%esp)
f0102a12:	e8 4f 19 00 00       	call   f0104366 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a1a:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f0102a20:	c1 f8 02             	sar    $0x2,%eax
f0102a23:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102a29:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102a2c:	89 c2                	mov    %eax,%edx
f0102a2e:	c1 ea 0c             	shr    $0xc,%edx
f0102a31:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f0102a37:	72 20                	jb     f0102a59 <env_alloc+0xd5>
f0102a39:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a3d:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f0102a44:	f0 
f0102a45:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102a4c:	00 
f0102a4d:	c7 04 24 d9 54 10 f0 	movl   $0xf01054d9,(%esp)
f0102a54:	e8 62 d6 ff ff       	call   f01000bb <_panic>
f0102a59:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0102a5f:	89 53 5c             	mov    %edx,0x5c(%ebx)
	// set e->env_pgdir to this pg's va
	e->env_pgdir = page2kva(p);
	// set e->env_cr3 to this pg's pa
	e->env_cr3 = page2pa(p);
f0102a62:	89 43 60             	mov    %eax,0x60(%ebx)
f0102a65:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	// Page directory and page table constants.
	// NPDENTRIES = 1024	// page directory entries per page directory
	// NPTENTRIES = 1024	// page table entries per page table
	for (i = PDX(UTOP); i < NPDENTRIES; ++i)
	{
		e->env_pgdir[i] = boot_pgdir[i];
f0102a6a:	8b 15 08 3a 17 f0    	mov    0xf0173a08,%edx
f0102a70:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102a73:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102a76:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102a79:	83 c0 04             	add    $0x4,%eax
	// So just copy boot_pgdir to env_pgdir for this part.
	// And UTOP equals UENVS
	// Page directory and page table constants.
	// NPDENTRIES = 1024	// page directory entries per page directory
	// NPTENTRIES = 1024	// page table entries per page table
	for (i = PDX(UTOP); i < NPDENTRIES; ++i)
f0102a7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a81:	75 e7                	jne    f0102a6a <env_alloc+0xe6>
		e->env_pgdir[i] = boot_pgdir[i];
	}

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0102a83:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102a86:	8b 53 60             	mov    0x60(%ebx),%edx
f0102a89:	83 ca 03             	or     $0x3,%edx
f0102a8c:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0102a92:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102a95:	8b 53 60             	mov    0x60(%ebx),%edx
f0102a98:	83 ca 05             	or     $0x5,%edx
f0102a9b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102aa1:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0102aa4:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102aa9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102aae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ab3:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102ab6:	89 da                	mov    %ebx,%edx
f0102ab8:	2b 15 60 2d 17 f0    	sub    0xf0172d60,%edx
f0102abe:	c1 fa 02             	sar    $0x2,%edx
f0102ac1:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0102ac7:	09 d0                	or     %edx,%eax
f0102ac9:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102acc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102acf:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102ad2:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102ad9:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102ae0:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102ae7:	00 
f0102ae8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102aef:	00 
f0102af0:	89 1c 24             	mov    %ebx,(%esp)
f0102af3:	e8 6e 18 00 00       	call   f0104366 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0102af8:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102afe:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102b04:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102b0a:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102b11:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0102b17:	8b 43 44             	mov    0x44(%ebx),%eax
f0102b1a:	85 c0                	test   %eax,%eax
f0102b1c:	74 06                	je     f0102b24 <env_alloc+0x1a0>
f0102b1e:	8b 53 48             	mov    0x48(%ebx),%edx
f0102b21:	89 50 48             	mov    %edx,0x48(%eax)
f0102b24:	8b 43 48             	mov    0x48(%ebx),%eax
f0102b27:	8b 53 44             	mov    0x44(%ebx),%edx
f0102b2a:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f0102b2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b2f:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102b31:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0102b34:	8b 15 5c 2d 17 f0    	mov    0xf0172d5c,%edx
f0102b3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b3f:	85 d2                	test   %edx,%edx
f0102b41:	74 03                	je     f0102b46 <env_alloc+0x1c2>
f0102b43:	8b 42 4c             	mov    0x4c(%edx),%eax
f0102b46:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b4e:	c7 04 24 3d 57 10 f0 	movl   $0xf010573d,(%esp)
f0102b55:	e8 0c 04 00 00       	call   f0102f66 <cprintf>
	return 0;
f0102b5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b5f:	eb 05                	jmp    f0102b66 <env_alloc+0x1e2>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
f0102b61:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102b66:	83 c4 24             	add    $0x24,%esp
f0102b69:	5b                   	pop    %ebx
f0102b6a:	5d                   	pop    %ebp
f0102b6b:	c3                   	ret    

f0102b6c <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f0102b6c:	55                   	push   %ebp
f0102b6d:	89 e5                	mov    %esp,%ebp
f0102b6f:	57                   	push   %edi
f0102b70:	56                   	push   %esi
f0102b71:	53                   	push   %ebx
f0102b72:	83 ec 3c             	sub    $0x3c,%esp
f0102b75:	8b 7d 08             	mov    0x8(%ebp),%edi
	// about env_alloc(struct Env **newenv_store, envid_t parent_id):
	// Allocates and initializes a new environment.
	// On success, the new environment is stored in *newenv_store.
	struct Env *env;
	// The new env's parent ID is set to 0, as the first.
	int env_alloc_info = env_alloc(&env, 0);
f0102b78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b7f:	00 
f0102b80:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102b83:	89 04 24             	mov    %eax,(%esp)
f0102b86:	e8 f9 fd ff ff       	call   f0102984 <env_alloc>
	if (env_alloc_info < 0)
f0102b8b:	85 c0                	test   %eax,%eax
f0102b8d:	79 20                	jns    f0102baf <env_create+0x43>
	{
		panic("env_alloc: %e", env_alloc_info);
f0102b8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b93:	c7 44 24 08 52 57 10 	movl   $0xf0105752,0x8(%esp)
f0102b9a:	f0 
f0102b9b:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
f0102ba2:	00 
f0102ba3:	c7 04 24 32 57 10 f0 	movl   $0xf0105732,(%esp)
f0102baa:	e8 0c d5 ff ff       	call   f01000bb <_panic>
	}
	load_icode(env, binary, size);
f0102baf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bb2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// only load segments with ph->p_type == ELF_PROG_LOAD.
	struct Elf *env_elf;
	struct Proghdr *ph, *eph;
	env_elf = (struct Elf *)binary;
	// magic number check
	if(env_elf->e_magic != ELF_MAGIC)
f0102bb5:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102bbb:	74 1c                	je     f0102bd9 <env_create+0x6d>
	{
		panic("load_icode(): Not a valid ELF!\n");
f0102bbd:	c7 44 24 08 dc 56 10 	movl   $0xf01056dc,0x8(%esp)
f0102bc4:	f0 
f0102bc5:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f0102bcc:	00 
f0102bcd:	c7 04 24 32 57 10 f0 	movl   $0xf0105732,(%esp)
f0102bd4:	e8 e2 d4 ff ff       	call   f01000bb <_panic>
	}	
	// load each program segment (ignores ph flags)
	// e_phoff means program header table offset
	// the start position
	ph = (struct Proghdr *)((uint8_t *)(env_elf)+env_elf->e_phoff);
f0102bd9:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	// the end position, e_phnum means the number of program
	// header table entries
	eph = ph+env_elf->e_phnum;
f0102bdc:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0102be0:	0f 20 da             	mov    %cr3,%edx
f0102be3:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// save old cr3, cr3 stores the page dir addr(pa)
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
f0102be6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102be9:	8b 42 5c             	mov    0x5c(%edx),%eax
f0102bec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bf1:	77 20                	ja     f0102c13 <env_create+0xa7>
f0102bf3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bf7:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f0102bfe:	f0 
f0102bff:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
f0102c06:	00 
f0102c07:	c7 04 24 32 57 10 f0 	movl   $0xf0105732,(%esp)
f0102c0e:	e8 a8 d4 ff ff       	call   f01000bb <_panic>
		panic("load_icode(): Not a valid ELF!\n");
	}	
	// load each program segment (ignores ph flags)
	// e_phoff means program header table offset
	// the start position
	ph = (struct Proghdr *)((uint8_t *)(env_elf)+env_elf->e_phoff);
f0102c13:	01 fb                	add    %edi,%ebx
	// the end position, e_phnum means the number of program
	// header table entries
	eph = ph+env_elf->e_phnum;
f0102c15:	0f b7 f6             	movzwl %si,%esi
f0102c18:	c1 e6 05             	shl    $0x5,%esi
f0102c1b:	01 de                	add    %ebx,%esi
	// save old cr3, cr3 stores the page dir addr(pa)
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
f0102c1d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102c22:	0f 22 d8             	mov    %eax,%cr3
	for (; ph < eph; ++ph)
f0102c25:	39 f3                	cmp    %esi,%ebx
f0102c27:	73 54                	jae    f0102c7d <env_create+0x111>
	{
		// only load segments with ph->p_type == ELF_PROG_LOAD.
		if (ph->p_type == ELF_PROG_LOAD)
f0102c29:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102c2c:	75 48                	jne    f0102c76 <env_create+0x10a>
		{
			// Each segment's virtual address can be found in ph->p_va
			//  and its size in memory can be found in ph->p_memsz.
			segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102c2e:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102c31:	8b 53 08             	mov    0x8(%ebx),%edx
f0102c34:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c37:	e8 d0 fb ff ff       	call   f010280c <segment_alloc>
			//  The ph->p_filesz bytes from the ELF binary, starting at
			//  'binary + ph->p_offset', should be copied to virtual address
			//  ph->p_va.
			memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102c3c:	8b 43 10             	mov    0x10(%ebx),%eax
f0102c3f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102c43:	89 f8                	mov    %edi,%eax
f0102c45:	03 43 04             	add    0x4(%ebx),%eax
f0102c48:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c4c:	8b 43 08             	mov    0x8(%ebx),%eax
f0102c4f:	89 04 24             	mov    %eax,(%esp)
f0102c52:	e8 33 17 00 00       	call   f010438a <memmove>
			//Any remaining memory bytes should be cleared to zero.
			// REMEMBER that ph->p_filesz <= ph->p_memsz.
			memset((void *)(ph->p_va+ph->p_filesz), 0, ph->p_memsz-ph->p_filesz);
f0102c57:	8b 43 10             	mov    0x10(%ebx),%eax
f0102c5a:	8b 53 14             	mov    0x14(%ebx),%edx
f0102c5d:	29 c2                	sub    %eax,%edx
f0102c5f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102c63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c6a:	00 
f0102c6b:	03 43 08             	add    0x8(%ebx),%eax
f0102c6e:	89 04 24             	mov    %eax,(%esp)
f0102c71:	e8 f0 16 00 00       	call   f0104366 <memset>
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ++ph)
f0102c76:	83 c3 20             	add    $0x20,%ebx
f0102c79:	39 de                	cmp    %ebx,%esi
f0102c7b:	77 ac                	ja     f0102c29 <env_create+0xbd>
f0102c7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c80:	0f 22 d8             	mov    %eax,%cr3
		}
	}
	// restore the old cr3
	lcr3(old_cr3);
	// Set the program's entry point.
	e->env_tf.tf_eip = env_elf->e_entry;
f0102c83:	8b 47 18             	mov    0x18(%edi),%eax
f0102c86:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c89:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	segment_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f0102c8c:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102c91:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102c96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c99:	e8 6e fb ff ff       	call   f010280c <segment_alloc>
	if (env_alloc_info < 0)
	{
		panic("env_alloc: %e", env_alloc_info);
	}
	load_icode(env, binary, size);
}
f0102c9e:	83 c4 3c             	add    $0x3c,%esp
f0102ca1:	5b                   	pop    %ebx
f0102ca2:	5e                   	pop    %esi
f0102ca3:	5f                   	pop    %edi
f0102ca4:	5d                   	pop    %ebp
f0102ca5:	c3                   	ret    

f0102ca6 <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0102ca6:	55                   	push   %ebp
f0102ca7:	89 e5                	mov    %esp,%ebp
f0102ca9:	57                   	push   %edi
f0102caa:	56                   	push   %esi
f0102cab:	53                   	push   %ebx
f0102cac:	83 ec 2c             	sub    $0x2c,%esp
f0102caf:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102cb2:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f0102cb7:	39 c7                	cmp    %eax,%edi
f0102cb9:	75 09                	jne    f0102cc4 <env_free+0x1e>
f0102cbb:	8b 15 04 3a 17 f0    	mov    0xf0173a04,%edx
f0102cc1:	0f 22 da             	mov    %edx,%cr3
		lcr3(boot_cr3);

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102cc4:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0102cc7:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ccc:	85 c0                	test   %eax,%eax
f0102cce:	74 03                	je     f0102cd3 <env_free+0x2d>
f0102cd0:	8b 50 4c             	mov    0x4c(%eax),%edx
f0102cd3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102cd7:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102cdb:	c7 04 24 60 57 10 f0 	movl   $0xf0105760,(%esp)
f0102ce2:	e8 7f 02 00 00       	call   f0102f66 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ce7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102cee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102cf1:	c1 e0 02             	shl    $0x2,%eax
f0102cf4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102cf7:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102cfa:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102cfd:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102d00:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102d06:	0f 84 bb 00 00 00    	je     f0102dc7 <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102d0c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0102d12:	89 f0                	mov    %esi,%eax
f0102d14:	c1 e8 0c             	shr    $0xc,%eax
f0102d17:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102d1a:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0102d20:	72 20                	jb     f0102d42 <env_free+0x9c>
f0102d22:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102d26:	c7 44 24 08 04 4f 10 	movl   $0xf0104f04,0x8(%esp)
f0102d2d:	f0 
f0102d2e:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
f0102d35:	00 
f0102d36:	c7 04 24 32 57 10 f0 	movl   $0xf0105732,(%esp)
f0102d3d:	e8 79 d3 ff ff       	call   f01000bb <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d42:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d45:	c1 e2 16             	shl    $0x16,%edx
f0102d48:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d4b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102d50:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102d57:	01 
f0102d58:	74 17                	je     f0102d71 <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d5a:	89 d8                	mov    %ebx,%eax
f0102d5c:	c1 e0 0c             	shl    $0xc,%eax
f0102d5f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102d62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d66:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d69:	89 04 24             	mov    %eax,(%esp)
f0102d6c:	e8 b1 e2 ff ff       	call   f0101022 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d71:	83 c3 01             	add    $0x1,%ebx
f0102d74:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102d7a:	75 d4                	jne    f0102d50 <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102d7c:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d7f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d82:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102d89:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d8c:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0102d92:	72 1c                	jb     f0102db0 <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0102d94:	c7 44 24 08 c8 4f 10 	movl   $0xf0104fc8,0x8(%esp)
f0102d9b:	f0 
f0102d9c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102da3:	00 
f0102da4:	c7 04 24 d9 54 10 f0 	movl   $0xf01054d9,(%esp)
f0102dab:	e8 0b d3 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0102db0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102db3:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102db6:	c1 e0 02             	shl    $0x2,%eax
f0102db9:	03 05 0c 3a 17 f0    	add    0xf0173a0c,%eax
		page_decref(pa2page(pa));
f0102dbf:	89 04 24             	mov    %eax,(%esp)
f0102dc2:	e8 e7 df ff ff       	call   f0100dae <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102dc7:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102dcb:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102dd2:	0f 85 16 ff ff ff    	jne    f0102cee <env_free+0x48>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0102dd8:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0102ddb:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0102de2:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102de9:	c1 e8 0c             	shr    $0xc,%eax
f0102dec:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0102df2:	72 1c                	jb     f0102e10 <env_free+0x16a>
		panic("pa2page called with invalid pa");
f0102df4:	c7 44 24 08 c8 4f 10 	movl   $0xf0104fc8,0x8(%esp)
f0102dfb:	f0 
f0102dfc:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102e03:	00 
f0102e04:	c7 04 24 d9 54 10 f0 	movl   $0xf01054d9,(%esp)
f0102e0b:	e8 ab d2 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0102e10:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102e13:	c1 e0 02             	shl    $0x2,%eax
f0102e16:	03 05 0c 3a 17 f0    	add    0xf0173a0c,%eax
	page_decref(pa2page(pa));
f0102e1c:	89 04 24             	mov    %eax,(%esp)
f0102e1f:	e8 8a df ff ff       	call   f0100dae <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102e24:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0102e2b:	a1 64 2d 17 f0       	mov    0xf0172d64,%eax
f0102e30:	89 47 44             	mov    %eax,0x44(%edi)
f0102e33:	85 c0                	test   %eax,%eax
f0102e35:	74 06                	je     f0102e3d <env_free+0x197>
f0102e37:	8d 57 44             	lea    0x44(%edi),%edx
f0102e3a:	89 50 48             	mov    %edx,0x48(%eax)
f0102e3d:	89 3d 64 2d 17 f0    	mov    %edi,0xf0172d64
f0102e43:	c7 47 48 64 2d 17 f0 	movl   $0xf0172d64,0x48(%edi)
}
f0102e4a:	83 c4 2c             	add    $0x2c,%esp
f0102e4d:	5b                   	pop    %ebx
f0102e4e:	5e                   	pop    %esi
f0102e4f:	5f                   	pop    %edi
f0102e50:	5d                   	pop    %ebp
f0102e51:	c3                   	ret    

f0102e52 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102e52:	55                   	push   %ebp
f0102e53:	89 e5                	mov    %esp,%ebp
f0102e55:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0102e58:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e5b:	89 04 24             	mov    %eax,(%esp)
f0102e5e:	e8 43 fe ff ff       	call   f0102ca6 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102e63:	c7 04 24 fc 56 10 f0 	movl   $0xf01056fc,(%esp)
f0102e6a:	e8 f7 00 00 00       	call   f0102f66 <cprintf>
	while (1)
		monitor(NULL);
f0102e6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e76:	e8 85 d9 ff ff       	call   f0100800 <monitor>
f0102e7b:	eb f2                	jmp    f0102e6f <env_destroy+0x1d>

f0102e7d <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102e7d:	55                   	push   %ebp
f0102e7e:	89 e5                	mov    %esp,%ebp
f0102e80:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102e83:	8b 65 08             	mov    0x8(%ebp),%esp
f0102e86:	61                   	popa   
f0102e87:	07                   	pop    %es
f0102e88:	1f                   	pop    %ds
f0102e89:	83 c4 08             	add    $0x8,%esp
f0102e8c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102e8d:	c7 44 24 08 76 57 10 	movl   $0xf0105776,0x8(%esp)
f0102e94:	f0 
f0102e95:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
f0102e9c:	00 
f0102e9d:	c7 04 24 32 57 10 f0 	movl   $0xf0105732,(%esp)
f0102ea4:	e8 12 d2 ff ff       	call   f01000bb <_panic>

f0102ea9 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0102ea9:	55                   	push   %ebp
f0102eaa:	89 e5                	mov    %esp,%ebp
f0102eac:	83 ec 18             	sub    $0x18,%esp
f0102eaf:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.
	// To start a given environment running in user mode.
	// PART 1
	// switch, and the original status may not be stored as the function 
	// NEVER RETURNS!
	curenv = e;
f0102eb2:	a3 5c 2d 17 f0       	mov    %eax,0xf0172d5c
	// update its 'env_runs' counter
	++(curenv->env_runs);
f0102eb7:	83 40 58 01          	addl   $0x1,0x58(%eax)
	// switch to its address space
	lcr3(PADDR(curenv->env_pgdir));
f0102ebb:	8b 50 5c             	mov    0x5c(%eax),%edx
f0102ebe:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102ec4:	77 20                	ja     f0102ee6 <env_run+0x3d>
f0102ec6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102eca:	c7 44 24 08 4c 4f 10 	movl   $0xf0104f4c,0x8(%esp)
f0102ed1:	f0 
f0102ed2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
f0102ed9:	00 
f0102eda:	c7 04 24 32 57 10 f0 	movl   $0xf0105732,(%esp)
f0102ee1:	e8 d5 d1 ff ff       	call   f01000bb <_panic>
f0102ee6:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102eec:	0f 22 da             	mov    %edx,%cr3
	// PART 2
	// restore the environment's registers and
	// drop into user mode in the environment.
	env_pop_tf(&(e->env_tf));
f0102eef:	89 04 24             	mov    %eax,(%esp)
f0102ef2:	e8 86 ff ff ff       	call   f0102e7d <env_pop_tf>
	...

f0102ef8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ef8:	55                   	push   %ebp
f0102ef9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102efb:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f00:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f03:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f04:	b2 71                	mov    $0x71,%dl
f0102f06:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f07:	0f b6 c0             	movzbl %al,%eax
}
f0102f0a:	5d                   	pop    %ebp
f0102f0b:	c3                   	ret    

f0102f0c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f0c:	55                   	push   %ebp
f0102f0d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f0f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f14:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f17:	ee                   	out    %al,(%dx)
f0102f18:	b2 71                	mov    $0x71,%dl
f0102f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f1d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f1e:	5d                   	pop    %ebp
f0102f1f:	c3                   	ret    

f0102f20 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f20:	55                   	push   %ebp
f0102f21:	89 e5                	mov    %esp,%ebp
f0102f23:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102f26:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f29:	89 04 24             	mov    %eax,(%esp)
f0102f2c:	e8 a7 d7 ff ff       	call   f01006d8 <cputchar>
	*cnt++;
}
f0102f31:	c9                   	leave  
f0102f32:	c3                   	ret    

f0102f33 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f33:	55                   	push   %ebp
f0102f34:	89 e5                	mov    %esp,%ebp
f0102f36:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102f39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f40:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f47:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f55:	c7 04 24 20 2f 10 f0 	movl   $0xf0102f20,(%esp)
f0102f5c:	e8 53 0d 00 00       	call   f0103cb4 <vprintfmt>
	return cnt;
}
f0102f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f64:	c9                   	leave  
f0102f65:	c3                   	ret    

f0102f66 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f66:	55                   	push   %ebp
f0102f67:	89 e5                	mov    %esp,%ebp
f0102f69:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0102f6c:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f73:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f76:	89 04 24             	mov    %eax,(%esp)
f0102f79:	e8 b5 ff ff ff       	call   f0102f33 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f7e:	c9                   	leave  
f0102f7f:	c3                   	ret    

f0102f80 <breakpoint>:
static __inline void cpuid(uint32_t info, uint32_t *eaxp, uint32_t *ebxp, uint32_t *ecxp, uint32_t *edxp);
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
f0102f80:	55                   	push   %ebp
f0102f81:	89 e5                	mov    %esp,%ebp
	__asm __volatile("int3");
f0102f83:	cc                   	int3   
}
f0102f84:	5d                   	pop    %ebp
f0102f85:	c3                   	ret    

f0102f86 <idt_init>:
}


void
idt_init(void)
{
f0102f86:	55                   	push   %ebp
f0102f87:	89 e5                	mov    %esp,%ebp
	// istrap: 1 for excp, and 0 for intr.
	// sel: segment selector, should be 0x8 or GD_KT, kernel text.
	// off: offset in code segment for interrupt/trap handler,
	// which should be the handler function entry points.
	// dpl: Descriptor Privilege Level, will be compared with cpl
	SETGATE(idt[T_DIVIDE], 0, GD_KT, divide_error, 0);
f0102f89:	b8 54 36 10 f0       	mov    $0xf0103654,%eax
f0102f8e:	66 a3 80 2d 17 f0    	mov    %ax,0xf0172d80
f0102f94:	66 c7 05 82 2d 17 f0 	movw   $0x8,0xf0172d82
f0102f9b:	08 00 
f0102f9d:	c6 05 84 2d 17 f0 00 	movb   $0x0,0xf0172d84
f0102fa4:	c6 05 85 2d 17 f0 8e 	movb   $0x8e,0xf0172d85
f0102fab:	c1 e8 10             	shr    $0x10,%eax
f0102fae:	66 a3 86 2d 17 f0    	mov    %ax,0xf0172d86
	SETGATE(idt[T_DEBUG], 0, GD_KT, debug_exception, 0);
f0102fb4:	b8 5a 36 10 f0       	mov    $0xf010365a,%eax
f0102fb9:	66 a3 88 2d 17 f0    	mov    %ax,0xf0172d88
f0102fbf:	66 c7 05 8a 2d 17 f0 	movw   $0x8,0xf0172d8a
f0102fc6:	08 00 
f0102fc8:	c6 05 8c 2d 17 f0 00 	movb   $0x0,0xf0172d8c
f0102fcf:	c6 05 8d 2d 17 f0 8e 	movb   $0x8e,0xf0172d8d
f0102fd6:	c1 e8 10             	shr    $0x10,%eax
f0102fd9:	66 a3 8e 2d 17 f0    	mov    %ax,0xf0172d8e
	SETGATE(idt[T_NMI], 0, GD_KT, nmi_interrupt, 0);
f0102fdf:	b8 60 36 10 f0       	mov    $0xf0103660,%eax
f0102fe4:	66 a3 90 2d 17 f0    	mov    %ax,0xf0172d90
f0102fea:	66 c7 05 92 2d 17 f0 	movw   $0x8,0xf0172d92
f0102ff1:	08 00 
f0102ff3:	c6 05 94 2d 17 f0 00 	movb   $0x0,0xf0172d94
f0102ffa:	c6 05 95 2d 17 f0 8e 	movb   $0x8e,0xf0172d95
f0103001:	c1 e8 10             	shr    $0x10,%eax
f0103004:	66 a3 96 2d 17 f0    	mov    %ax,0xf0172d96
	SETGATE(idt[T_BRKPT], 0, GD_KT, breakpoint, 3);
f010300a:	b8 80 2f 10 f0       	mov    $0xf0102f80,%eax
f010300f:	66 a3 98 2d 17 f0    	mov    %ax,0xf0172d98
f0103015:	66 c7 05 9a 2d 17 f0 	movw   $0x8,0xf0172d9a
f010301c:	08 00 
f010301e:	c6 05 9c 2d 17 f0 00 	movb   $0x0,0xf0172d9c
f0103025:	c6 05 9d 2d 17 f0 ee 	movb   $0xee,0xf0172d9d
f010302c:	c1 e8 10             	shr    $0x10,%eax
f010302f:	66 a3 9e 2d 17 f0    	mov    %ax,0xf0172d9e
	SETGATE(idt[T_OFLOW], 1, GD_KT, overflow, 3);
f0103035:	b8 6c 36 10 f0       	mov    $0xf010366c,%eax
f010303a:	66 a3 a0 2d 17 f0    	mov    %ax,0xf0172da0
f0103040:	66 c7 05 a2 2d 17 f0 	movw   $0x8,0xf0172da2
f0103047:	08 00 
f0103049:	c6 05 a4 2d 17 f0 00 	movb   $0x0,0xf0172da4
f0103050:	c6 05 a5 2d 17 f0 ef 	movb   $0xef,0xf0172da5
f0103057:	c1 e8 10             	shr    $0x10,%eax
f010305a:	66 a3 a6 2d 17 f0    	mov    %ax,0xf0172da6
	SETGATE(idt[T_BOUND], 1, GD_KT, bound_check, 3);
f0103060:	b8 72 36 10 f0       	mov    $0xf0103672,%eax
f0103065:	66 a3 a8 2d 17 f0    	mov    %ax,0xf0172da8
f010306b:	66 c7 05 aa 2d 17 f0 	movw   $0x8,0xf0172daa
f0103072:	08 00 
f0103074:	c6 05 ac 2d 17 f0 00 	movb   $0x0,0xf0172dac
f010307b:	c6 05 ad 2d 17 f0 ef 	movb   $0xef,0xf0172dad
f0103082:	c1 e8 10             	shr    $0x10,%eax
f0103085:	66 a3 ae 2d 17 f0    	mov    %ax,0xf0172dae
	SETGATE(idt[T_ILLOP], 0, GD_KT, illegal_opcode, 0);
f010308b:	b8 78 36 10 f0       	mov    $0xf0103678,%eax
f0103090:	66 a3 b0 2d 17 f0    	mov    %ax,0xf0172db0
f0103096:	66 c7 05 b2 2d 17 f0 	movw   $0x8,0xf0172db2
f010309d:	08 00 
f010309f:	c6 05 b4 2d 17 f0 00 	movb   $0x0,0xf0172db4
f01030a6:	c6 05 b5 2d 17 f0 8e 	movb   $0x8e,0xf0172db5
f01030ad:	c1 e8 10             	shr    $0x10,%eax
f01030b0:	66 a3 b6 2d 17 f0    	mov    %ax,0xf0172db6
	SETGATE(idt[T_DEVICE], 0, GD_KT, device_not_available, 0);
f01030b6:	b8 7e 36 10 f0       	mov    $0xf010367e,%eax
f01030bb:	66 a3 b8 2d 17 f0    	mov    %ax,0xf0172db8
f01030c1:	66 c7 05 ba 2d 17 f0 	movw   $0x8,0xf0172dba
f01030c8:	08 00 
f01030ca:	c6 05 bc 2d 17 f0 00 	movb   $0x0,0xf0172dbc
f01030d1:	c6 05 bd 2d 17 f0 8e 	movb   $0x8e,0xf0172dbd
f01030d8:	c1 e8 10             	shr    $0x10,%eax
f01030db:	66 a3 be 2d 17 f0    	mov    %ax,0xf0172dbe
	// I just cannot set the gate's type to 0101B, which states a task gate
	// Don't know why. May be modified later?
	SETGATE(idt[T_DBLFLT], 0, GD_KT, double_fault, 0);
f01030e1:	b8 84 36 10 f0       	mov    $0xf0103684,%eax
f01030e6:	66 a3 c0 2d 17 f0    	mov    %ax,0xf0172dc0
f01030ec:	66 c7 05 c2 2d 17 f0 	movw   $0x8,0xf0172dc2
f01030f3:	08 00 
f01030f5:	c6 05 c4 2d 17 f0 00 	movb   $0x0,0xf0172dc4
f01030fc:	c6 05 c5 2d 17 f0 8e 	movb   $0x8e,0xf0172dc5
f0103103:	c1 e8 10             	shr    $0x10,%eax
f0103106:	66 a3 c6 2d 17 f0    	mov    %ax,0xf0172dc6
	SETGATE(idt[T_TSS], 0, GD_KT, invalid_tss, 0);
f010310c:	b8 88 36 10 f0       	mov    $0xf0103688,%eax
f0103111:	66 a3 d0 2d 17 f0    	mov    %ax,0xf0172dd0
f0103117:	66 c7 05 d2 2d 17 f0 	movw   $0x8,0xf0172dd2
f010311e:	08 00 
f0103120:	c6 05 d4 2d 17 f0 00 	movb   $0x0,0xf0172dd4
f0103127:	c6 05 d5 2d 17 f0 8e 	movb   $0x8e,0xf0172dd5
f010312e:	c1 e8 10             	shr    $0x10,%eax
f0103131:	66 a3 d6 2d 17 f0    	mov    %ax,0xf0172dd6
	SETGATE(idt[T_SEGNP], 0, GD_KT, segment_not_present, 0);
f0103137:	b8 8c 36 10 f0       	mov    $0xf010368c,%eax
f010313c:	66 a3 d8 2d 17 f0    	mov    %ax,0xf0172dd8
f0103142:	66 c7 05 da 2d 17 f0 	movw   $0x8,0xf0172dda
f0103149:	08 00 
f010314b:	c6 05 dc 2d 17 f0 00 	movb   $0x0,0xf0172ddc
f0103152:	c6 05 dd 2d 17 f0 8e 	movb   $0x8e,0xf0172ddd
f0103159:	c1 e8 10             	shr    $0x10,%eax
f010315c:	66 a3 de 2d 17 f0    	mov    %ax,0xf0172dde
	SETGATE(idt[T_STACK], 0, GD_KT, stack_exception, 0);
f0103162:	b8 90 36 10 f0       	mov    $0xf0103690,%eax
f0103167:	66 a3 e0 2d 17 f0    	mov    %ax,0xf0172de0
f010316d:	66 c7 05 e2 2d 17 f0 	movw   $0x8,0xf0172de2
f0103174:	08 00 
f0103176:	c6 05 e4 2d 17 f0 00 	movb   $0x0,0xf0172de4
f010317d:	c6 05 e5 2d 17 f0 8e 	movb   $0x8e,0xf0172de5
f0103184:	c1 e8 10             	shr    $0x10,%eax
f0103187:	66 a3 e6 2d 17 f0    	mov    %ax,0xf0172de6
	SETGATE(idt[T_GPFLT], 1, GD_KT, general_protection_fault, 0);
f010318d:	b8 94 36 10 f0       	mov    $0xf0103694,%eax
f0103192:	66 a3 e8 2d 17 f0    	mov    %ax,0xf0172de8
f0103198:	66 c7 05 ea 2d 17 f0 	movw   $0x8,0xf0172dea
f010319f:	08 00 
f01031a1:	c6 05 ec 2d 17 f0 00 	movb   $0x0,0xf0172dec
f01031a8:	c6 05 ed 2d 17 f0 8f 	movb   $0x8f,0xf0172ded
f01031af:	c1 e8 10             	shr    $0x10,%eax
f01031b2:	66 a3 ee 2d 17 f0    	mov    %ax,0xf0172dee
	SETGATE(idt[T_PGFLT], 0, GD_KT, page_fault, 0);
f01031b8:	b8 98 36 10 f0       	mov    $0xf0103698,%eax
f01031bd:	66 a3 f0 2d 17 f0    	mov    %ax,0xf0172df0
f01031c3:	66 c7 05 f2 2d 17 f0 	movw   $0x8,0xf0172df2
f01031ca:	08 00 
f01031cc:	c6 05 f4 2d 17 f0 00 	movb   $0x0,0xf0172df4
f01031d3:	c6 05 f5 2d 17 f0 8e 	movb   $0x8e,0xf0172df5
f01031da:	c1 e8 10             	shr    $0x10,%eax
f01031dd:	66 a3 f6 2d 17 f0    	mov    %ax,0xf0172df6
	SETGATE(idt[T_FPERR], 0, GD_KT, floating_point_error, 0);
f01031e3:	b8 9c 36 10 f0       	mov    $0xf010369c,%eax
f01031e8:	66 a3 00 2e 17 f0    	mov    %ax,0xf0172e00
f01031ee:	66 c7 05 02 2e 17 f0 	movw   $0x8,0xf0172e02
f01031f5:	08 00 
f01031f7:	c6 05 04 2e 17 f0 00 	movb   $0x0,0xf0172e04
f01031fe:	c6 05 05 2e 17 f0 8e 	movb   $0x8e,0xf0172e05
f0103205:	c1 e8 10             	shr    $0x10,%eax
f0103208:	66 a3 06 2e 17 f0    	mov    %ax,0xf0172e06
	SETGATE(idt[T_ALIGN], 0, GD_KT, aligment_check, 0);
f010320e:	b8 a2 36 10 f0       	mov    $0xf01036a2,%eax
f0103213:	66 a3 08 2e 17 f0    	mov    %ax,0xf0172e08
f0103219:	66 c7 05 0a 2e 17 f0 	movw   $0x8,0xf0172e0a
f0103220:	08 00 
f0103222:	c6 05 0c 2e 17 f0 00 	movb   $0x0,0xf0172e0c
f0103229:	c6 05 0d 2e 17 f0 8e 	movb   $0x8e,0xf0172e0d
f0103230:	c1 e8 10             	shr    $0x10,%eax
f0103233:	66 a3 0e 2e 17 f0    	mov    %ax,0xf0172e0e
	SETGATE(idt[T_MCHK], 0, GD_KT, machine_check, 0);
f0103239:	b8 a6 36 10 f0       	mov    $0xf01036a6,%eax
f010323e:	66 a3 10 2e 17 f0    	mov    %ax,0xf0172e10
f0103244:	66 c7 05 12 2e 17 f0 	movw   $0x8,0xf0172e12
f010324b:	08 00 
f010324d:	c6 05 14 2e 17 f0 00 	movb   $0x0,0xf0172e14
f0103254:	c6 05 15 2e 17 f0 8e 	movb   $0x8e,0xf0172e15
f010325b:	c1 e8 10             	shr    $0x10,%eax
f010325e:	66 a3 16 2e 17 f0    	mov    %ax,0xf0172e16
	SETGATE(idt[T_SIMDERR], 0, GD_KT, simd_floating_point_error, 0);
f0103264:	b8 ac 36 10 f0       	mov    $0xf01036ac,%eax
f0103269:	66 a3 18 2e 17 f0    	mov    %ax,0xf0172e18
f010326f:	66 c7 05 1a 2e 17 f0 	movw   $0x8,0xf0172e1a
f0103276:	08 00 
f0103278:	c6 05 1c 2e 17 f0 00 	movb   $0x0,0xf0172e1c
f010327f:	c6 05 1d 2e 17 f0 8e 	movb   $0x8e,0xf0172e1d
f0103286:	c1 e8 10             	shr    $0x10,%eax
f0103289:	66 a3 1e 2e 17 f0    	mov    %ax,0xf0172e1e
	SETGATE(idt[T_SYSCALL], 1, GD_KT, system_call, 3);
f010328f:	b8 b2 36 10 f0       	mov    $0xf01036b2,%eax
f0103294:	66 a3 00 2f 17 f0    	mov    %ax,0xf0172f00
f010329a:	66 c7 05 02 2f 17 f0 	movw   $0x8,0xf0172f02
f01032a1:	08 00 
f01032a3:	c6 05 04 2f 17 f0 00 	movb   $0x0,0xf0172f04
f01032aa:	c6 05 05 2f 17 f0 ef 	movb   $0xef,0xf0172f05
f01032b1:	c1 e8 10             	shr    $0x10,%eax
f01032b4:	66 a3 06 2f 17 f0    	mov    %ax,0xf0172f06

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01032ba:	c7 05 84 35 17 f0 00 	movl   $0xefc00000,0xf0173584
f01032c1:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f01032c4:	66 c7 05 88 35 17 f0 	movw   $0x10,0xf0173588
f01032cb:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01032cd:	66 c7 05 68 83 11 f0 	movw   $0x68,0xf0118368
f01032d4:	68 00 
f01032d6:	b8 80 35 17 f0       	mov    $0xf0173580,%eax
f01032db:	66 a3 6a 83 11 f0    	mov    %ax,0xf011836a
f01032e1:	89 c2                	mov    %eax,%edx
f01032e3:	c1 ea 10             	shr    $0x10,%edx
f01032e6:	88 15 6c 83 11 f0    	mov    %dl,0xf011836c
f01032ec:	c6 05 6e 83 11 f0 40 	movb   $0x40,0xf011836e
f01032f3:	c1 e8 18             	shr    $0x18,%eax
f01032f6:	a2 6f 83 11 f0       	mov    %al,0xf011836f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f01032fb:	c6 05 6d 83 11 f0 89 	movb   $0x89,0xf011836d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103302:	b8 28 00 00 00       	mov    $0x28,%eax
f0103307:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f010330a:	0f 01 1d 70 83 11 f0 	lidtl  0xf0118370
}
f0103311:	5d                   	pop    %ebp
f0103312:	c3                   	ret    

f0103313 <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0103313:	55                   	push   %ebp
f0103314:	89 e5                	mov    %esp,%ebp
f0103316:	53                   	push   %ebx
f0103317:	83 ec 14             	sub    $0x14,%esp
f010331a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010331d:	8b 03                	mov    (%ebx),%eax
f010331f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103323:	c7 04 24 82 57 10 f0 	movl   $0xf0105782,(%esp)
f010332a:	e8 37 fc ff ff       	call   f0102f66 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010332f:	8b 43 04             	mov    0x4(%ebx),%eax
f0103332:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103336:	c7 04 24 91 57 10 f0 	movl   $0xf0105791,(%esp)
f010333d:	e8 24 fc ff ff       	call   f0102f66 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103342:	8b 43 08             	mov    0x8(%ebx),%eax
f0103345:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103349:	c7 04 24 a0 57 10 f0 	movl   $0xf01057a0,(%esp)
f0103350:	e8 11 fc ff ff       	call   f0102f66 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103355:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103358:	89 44 24 04          	mov    %eax,0x4(%esp)
f010335c:	c7 04 24 af 57 10 f0 	movl   $0xf01057af,(%esp)
f0103363:	e8 fe fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103368:	8b 43 10             	mov    0x10(%ebx),%eax
f010336b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010336f:	c7 04 24 be 57 10 f0 	movl   $0xf01057be,(%esp)
f0103376:	e8 eb fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010337b:	8b 43 14             	mov    0x14(%ebx),%eax
f010337e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103382:	c7 04 24 cd 57 10 f0 	movl   $0xf01057cd,(%esp)
f0103389:	e8 d8 fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010338e:	8b 43 18             	mov    0x18(%ebx),%eax
f0103391:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103395:	c7 04 24 dc 57 10 f0 	movl   $0xf01057dc,(%esp)
f010339c:	e8 c5 fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01033a1:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01033a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033a8:	c7 04 24 eb 57 10 f0 	movl   $0xf01057eb,(%esp)
f01033af:	e8 b2 fb ff ff       	call   f0102f66 <cprintf>
}
f01033b4:	83 c4 14             	add    $0x14,%esp
f01033b7:	5b                   	pop    %ebx
f01033b8:	5d                   	pop    %ebp
f01033b9:	c3                   	ret    

f01033ba <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f01033ba:	55                   	push   %ebp
f01033bb:	89 e5                	mov    %esp,%ebp
f01033bd:	53                   	push   %ebx
f01033be:	83 ec 14             	sub    $0x14,%esp
f01033c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01033c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033c8:	c7 04 24 d9 58 10 f0 	movl   $0xf01058d9,(%esp)
f01033cf:	e8 92 fb ff ff       	call   f0102f66 <cprintf>
	print_regs(&tf->tf_regs);
f01033d4:	89 1c 24             	mov    %ebx,(%esp)
f01033d7:	e8 37 ff ff ff       	call   f0103313 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01033dc:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01033e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033e4:	c7 04 24 15 58 10 f0 	movl   $0xf0105815,(%esp)
f01033eb:	e8 76 fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01033f0:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01033f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033f8:	c7 04 24 28 58 10 f0 	movl   $0xf0105828,(%esp)
f01033ff:	e8 62 fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103404:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103407:	83 f8 13             	cmp    $0x13,%eax
f010340a:	77 09                	ja     f0103415 <print_trapframe+0x5b>
		return excnames[trapno];
f010340c:	8b 14 85 c0 5a 10 f0 	mov    -0xfefa540(,%eax,4),%edx
f0103413:	eb 10                	jmp    f0103425 <print_trapframe+0x6b>
	if (trapno == T_SYSCALL)
f0103415:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
f0103418:	ba fa 57 10 f0       	mov    $0xf01057fa,%edx
f010341d:	b9 06 58 10 f0       	mov    $0xf0105806,%ecx
f0103422:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103425:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103429:	89 44 24 04          	mov    %eax,0x4(%esp)
f010342d:	c7 04 24 3b 58 10 f0 	movl   $0xf010583b,(%esp)
f0103434:	e8 2d fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f0103439:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010343c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103440:	c7 04 24 4d 58 10 f0 	movl   $0xf010584d,(%esp)
f0103447:	e8 1a fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010344c:	8b 43 30             	mov    0x30(%ebx),%eax
f010344f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103453:	c7 04 24 5c 58 10 f0 	movl   $0xf010585c,(%esp)
f010345a:	e8 07 fb ff ff       	call   f0102f66 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010345f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103463:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103467:	c7 04 24 6b 58 10 f0 	movl   $0xf010586b,(%esp)
f010346e:	e8 f3 fa ff ff       	call   f0102f66 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103473:	8b 43 38             	mov    0x38(%ebx),%eax
f0103476:	89 44 24 04          	mov    %eax,0x4(%esp)
f010347a:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f0103481:	e8 e0 fa ff ff       	call   f0102f66 <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103486:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103489:	89 44 24 04          	mov    %eax,0x4(%esp)
f010348d:	c7 04 24 8d 58 10 f0 	movl   $0xf010588d,(%esp)
f0103494:	e8 cd fa ff ff       	call   f0102f66 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103499:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010349d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034a1:	c7 04 24 9c 58 10 f0 	movl   $0xf010589c,(%esp)
f01034a8:	e8 b9 fa ff ff       	call   f0102f66 <cprintf>
}
f01034ad:	83 c4 14             	add    $0x14,%esp
f01034b0:	5b                   	pop    %ebx
f01034b1:	5d                   	pop    %ebp
f01034b2:	c3                   	ret    

f01034b3 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01034b3:	55                   	push   %ebp
f01034b4:	89 e5                	mov    %esp,%ebp
f01034b6:	53                   	push   %ebx
f01034b7:	83 ec 14             	sub    $0x14,%esp
f01034ba:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01034bd:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f01034c0:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01034c4:	75 1c                	jne    f01034e2 <page_fault_handler+0x2f>
	{
        		panic("Page fault in kernel");  
f01034c6:	c7 44 24 08 af 58 10 	movl   $0xf01058af,0x8(%esp)
f01034cd:	f0 
f01034ce:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
f01034d5:	00 
f01034d6:	c7 04 24 c4 58 10 f0 	movl   $0xf01058c4,(%esp)
f01034dd:	e8 d9 cb ff ff       	call   f01000bb <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01034e2:	8b 53 30             	mov    0x30(%ebx),%edx
f01034e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01034e9:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01034ed:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01034f2:	8b 40 4c             	mov    0x4c(%eax),%eax
f01034f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034f9:	c7 04 24 50 5a 10 f0 	movl   $0xf0105a50,(%esp)
f0103500:	e8 61 fa ff ff       	call   f0102f66 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103505:	89 1c 24             	mov    %ebx,(%esp)
f0103508:	e8 ad fe ff ff       	call   f01033ba <print_trapframe>
	env_destroy(curenv);
f010350d:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f0103512:	89 04 24             	mov    %eax,(%esp)
f0103515:	e8 38 f9 ff ff       	call   f0102e52 <env_destroy>
}
f010351a:	83 c4 14             	add    $0x14,%esp
f010351d:	5b                   	pop    %ebx
f010351e:	5d                   	pop    %ebp
f010351f:	c3                   	ret    

f0103520 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103520:	55                   	push   %ebp
f0103521:	89 e5                	mov    %esp,%ebp
f0103523:	57                   	push   %edi
f0103524:	56                   	push   %esi
f0103525:	83 ec 20             	sub    $0x20,%esp
f0103528:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("Incoming TRAP frame at %p\n", tf);
f010352b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010352f:	c7 04 24 d0 58 10 f0 	movl   $0xf01058d0,(%esp)
f0103536:	e8 2b fa ff ff       	call   f0102f66 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f010353b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010353f:	83 e0 03             	and    $0x3,%eax
f0103542:	83 f8 03             	cmp    $0x3,%eax
f0103545:	75 3c                	jne    f0103583 <trap+0x63>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103547:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f010354c:	85 c0                	test   %eax,%eax
f010354e:	75 24                	jne    f0103574 <trap+0x54>
f0103550:	c7 44 24 0c eb 58 10 	movl   $0xf01058eb,0xc(%esp)
f0103557:	f0 
f0103558:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f010355f:	f0 
f0103560:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0103567:	00 
f0103568:	c7 04 24 c4 58 10 f0 	movl   $0xf01058c4,(%esp)
f010356f:	e8 47 cb ff ff       	call   f01000bb <_panic>
		curenv->env_tf = *tf;
f0103574:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103579:	89 c7                	mov    %eax,%edi
f010357b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010357d:	8b 35 5c 2d 17 f0    	mov    0xf0172d5c,%esi
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno)
f0103583:	8b 46 28             	mov    0x28(%esi),%eax
f0103586:	83 f8 0e             	cmp    $0xe,%eax
f0103589:	74 0c                	je     f0103597 <trap+0x77>
f010358b:	83 f8 30             	cmp    $0x30,%eax
f010358e:	74 1c                	je     f01035ac <trap+0x8c>
f0103590:	83 f8 03             	cmp    $0x3,%eax
f0103593:	75 49                	jne    f01035de <trap+0xbe>
f0103595:	eb 0b                	jmp    f01035a2 <trap+0x82>
	{
		case T_PGFLT:
			// dispatch page fault exceptions to page_fault_handler()
			page_fault_handler(tf);
f0103597:	89 34 24             	mov    %esi,(%esp)
f010359a:	e8 14 ff ff ff       	call   f01034b3 <page_fault_handler>
f010359f:	90                   	nop
f01035a0:	eb 74                	jmp    f0103616 <trap+0xf6>
			return;
		case T_BRKPT:
			// invoke kernel monitor
			monitor(tf);
f01035a2:	89 34 24             	mov    %esi,(%esp)
f01035a5:	e8 56 d2 ff ff       	call   f0100800 <monitor>
f01035aa:	eb 6a                	jmp    f0103616 <trap+0xf6>
			return;
		case T_SYSCALL:
			// arrange for the return value to be
			// passed back to the user process in %eax
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f01035ac:	8b 06                	mov    (%esi),%eax
f01035ae:	89 44 24 14          	mov    %eax,0x14(%esp)
f01035b2:	8b 46 04             	mov    0x4(%esi),%eax
f01035b5:	89 44 24 10          	mov    %eax,0x10(%esp)
f01035b9:	8b 46 10             	mov    0x10(%esi),%eax
f01035bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035c0:	8b 46 14             	mov    0x14(%esi),%eax
f01035c3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035c7:	8b 46 18             	mov    0x18(%esi),%eax
f01035ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035ce:	8b 46 1c             	mov    0x1c(%esi),%eax
f01035d1:	89 04 24             	mov    %eax,(%esp)
f01035d4:	e8 f7 00 00 00       	call   f01036d0 <syscall>
f01035d9:	89 46 1c             	mov    %eax,0x1c(%esi)
f01035dc:	eb 38                	jmp    f0103616 <trap+0xf6>
				tf->tf_regs.reg_edi);
			return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01035de:	89 34 24             	mov    %esi,(%esp)
f01035e1:	e8 d4 fd ff ff       	call   f01033ba <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01035e6:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01035eb:	75 1c                	jne    f0103609 <trap+0xe9>
		panic("unhandled trap in kernel");
f01035ed:	c7 44 24 08 f2 58 10 	movl   $0xf01058f2,0x8(%esp)
f01035f4:	f0 
f01035f5:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f01035fc:	00 
f01035fd:	c7 04 24 c4 58 10 f0 	movl   $0xf01058c4,(%esp)
f0103604:	e8 b2 ca ff ff       	call   f01000bb <_panic>
	else {
		env_destroy(curenv);
f0103609:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f010360e:	89 04 24             	mov    %eax,(%esp)
f0103611:	e8 3c f8 ff ff       	call   f0102e52 <env_destroy>
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f0103616:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f010361b:	85 c0                	test   %eax,%eax
f010361d:	74 06                	je     f0103625 <trap+0x105>
f010361f:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103623:	74 24                	je     f0103649 <trap+0x129>
f0103625:	c7 44 24 0c 74 5a 10 	movl   $0xf0105a74,0xc(%esp)
f010362c:	f0 
f010362d:	c7 44 24 08 fd 54 10 	movl   $0xf01054fd,0x8(%esp)
f0103634:	f0 
f0103635:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
f010363c:	00 
f010363d:	c7 04 24 c4 58 10 f0 	movl   $0xf01058c4,(%esp)
f0103644:	e8 72 ca ff ff       	call   f01000bb <_panic>
        env_run(curenv);
f0103649:	89 04 24             	mov    %eax,(%esp)
f010364c:	e8 58 f8 ff ff       	call   f0102ea9 <env_run>
f0103651:	00 00                	add    %al,(%eax)
	...

f0103654 <divide_error>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(divide_error, T_DIVIDE)
f0103654:	6a 00                	push   $0x0
f0103656:	6a 00                	push   $0x0
f0103658:	eb 5e                	jmp    f01036b8 <_alltraps>

f010365a <debug_exception>:
	TRAPHANDLER_NOEC(debug_exception, T_DEBUG)
f010365a:	6a 00                	push   $0x0
f010365c:	6a 01                	push   $0x1
f010365e:	eb 58                	jmp    f01036b8 <_alltraps>

f0103660 <nmi_interrupt>:
	TRAPHANDLER_NOEC(nmi_interrupt, T_NMI)
f0103660:	6a 00                	push   $0x0
f0103662:	6a 02                	push   $0x2
f0103664:	eb 52                	jmp    f01036b8 <_alltraps>

f0103666 <breakpoint>:
	TRAPHANDLER_NOEC(breakpoint, T_BRKPT)
f0103666:	6a 00                	push   $0x0
f0103668:	6a 03                	push   $0x3
f010366a:	eb 4c                	jmp    f01036b8 <_alltraps>

f010366c <overflow>:
	TRAPHANDLER_NOEC(overflow, T_OFLOW)
f010366c:	6a 00                	push   $0x0
f010366e:	6a 04                	push   $0x4
f0103670:	eb 46                	jmp    f01036b8 <_alltraps>

f0103672 <bound_check>:
	TRAPHANDLER_NOEC(bound_check, T_BOUND)
f0103672:	6a 00                	push   $0x0
f0103674:	6a 05                	push   $0x5
f0103676:	eb 40                	jmp    f01036b8 <_alltraps>

f0103678 <illegal_opcode>:
	TRAPHANDLER_NOEC(illegal_opcode, T_ILLOP)
f0103678:	6a 00                	push   $0x0
f010367a:	6a 06                	push   $0x6
f010367c:	eb 3a                	jmp    f01036b8 <_alltraps>

f010367e <device_not_available>:
	TRAPHANDLER_NOEC(device_not_available, T_DEVICE)
f010367e:	6a 00                	push   $0x0
f0103680:	6a 07                	push   $0x7
f0103682:	eb 34                	jmp    f01036b8 <_alltraps>

f0103684 <double_fault>:
	TRAPHANDLER(double_fault, T_DBLFLT)
f0103684:	6a 08                	push   $0x8
f0103686:	eb 30                	jmp    f01036b8 <_alltraps>

f0103688 <invalid_tss>:

	TRAPHANDLER(invalid_tss, T_TSS)
f0103688:	6a 0a                	push   $0xa
f010368a:	eb 2c                	jmp    f01036b8 <_alltraps>

f010368c <segment_not_present>:
	TRAPHANDLER(segment_not_present, T_SEGNP)
f010368c:	6a 0b                	push   $0xb
f010368e:	eb 28                	jmp    f01036b8 <_alltraps>

f0103690 <stack_exception>:
	TRAPHANDLER(stack_exception, T_STACK)
f0103690:	6a 0c                	push   $0xc
f0103692:	eb 24                	jmp    f01036b8 <_alltraps>

f0103694 <general_protection_fault>:
	TRAPHANDLER(general_protection_fault, T_GPFLT)
f0103694:	6a 0d                	push   $0xd
f0103696:	eb 20                	jmp    f01036b8 <_alltraps>

f0103698 <page_fault>:
	TRAPHANDLER(page_fault, T_PGFLT)
f0103698:	6a 0e                	push   $0xe
f010369a:	eb 1c                	jmp    f01036b8 <_alltraps>

f010369c <floating_point_error>:

	TRAPHANDLER_NOEC(floating_point_error, T_FPERR)
f010369c:	6a 00                	push   $0x0
f010369e:	6a 10                	push   $0x10
f01036a0:	eb 16                	jmp    f01036b8 <_alltraps>

f01036a2 <aligment_check>:
	TRAPHANDLER(aligment_check, T_ALIGN)
f01036a2:	6a 11                	push   $0x11
f01036a4:	eb 12                	jmp    f01036b8 <_alltraps>

f01036a6 <machine_check>:
	TRAPHANDLER_NOEC(machine_check, T_MCHK)
f01036a6:	6a 00                	push   $0x0
f01036a8:	6a 12                	push   $0x12
f01036aa:	eb 0c                	jmp    f01036b8 <_alltraps>

f01036ac <simd_floating_point_error>:
	TRAPHANDLER_NOEC(simd_floating_point_error, T_SIMDERR)
f01036ac:	6a 00                	push   $0x0
f01036ae:	6a 13                	push   $0x13
f01036b0:	eb 06                	jmp    f01036b8 <_alltraps>

f01036b2 <system_call>:
	TRAPHANDLER_NOEC(system_call, T_SYSCALL)
f01036b2:	6a 00                	push   $0x0
f01036b4:	6a 30                	push   $0x30
f01036b6:	eb 00                	jmp    f01036b8 <_alltraps>

f01036b8 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	/* push values to make the stack look like a struct Trapframe */
	pushl	%ds
f01036b8:	1e                   	push   %ds
	pushl	%es
f01036b9:	06                   	push   %es
	/* push all regs in */
	pushal
f01036ba:	60                   	pusha  

	/* load GD_KD into %ds and %es */
	/* notice that ds and es are 16 bits width */
	movl	$GD_KD,	%eax
f01036bb:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,	%ds
f01036c0:	8e d8                	mov    %eax,%ds
	movw	%ax,	%es
f01036c2:	8e c0                	mov    %eax,%es

	/* pushl %esp to pass a pointer to the Trapframe
	as an argument to trap() and call trap() */
	pushl	%esp
f01036c4:	54                   	push   %esp
	call trap
f01036c5:	e8 56 fe ff ff       	call   f0103520 <trap>

	/* pop the values pushed in steps 1-3 and iret*/
	popl	%esp
f01036ca:	5c                   	pop    %esp
	popal
f01036cb:	61                   	popa   
	popl	%es
f01036cc:	07                   	pop    %es
	popl	%ds
f01036cd:	1f                   	pop    %ds
f01036ce:	cf                   	iret   
	...

f01036d0 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01036d0:	55                   	push   %ebp
f01036d1:	89 e5                	mov    %esp,%ebp
f01036d3:	83 ec 28             	sub    $0x28,%esp
f01036d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno)
f01036dc:	83 f8 01             	cmp    $0x1,%eax
f01036df:	74 38                	je     f0103719 <syscall+0x49>
f01036e1:	83 f8 01             	cmp    $0x1,%eax
f01036e4:	72 12                	jb     f01036f8 <syscall+0x28>
f01036e6:	83 f8 02             	cmp    $0x2,%eax
f01036e9:	74 39                	je     f0103724 <syscall+0x54>
f01036eb:	83 f8 03             	cmp    $0x3,%eax
f01036ee:	66 90                	xchg   %ax,%ax
f01036f0:	0f 85 a1 00 00 00    	jne    f0103797 <syscall+0xc7>
f01036f6:	eb 36                	jmp    f010372e <syscall+0x5e>
	// Destroy the environment if not.
	
	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01036f8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01036fc:	8b 45 10             	mov    0x10(%ebp),%eax
f01036ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103703:	c7 04 24 10 5b 10 f0 	movl   $0xf0105b10,(%esp)
f010370a:	e8 57 f8 ff ff       	call   f0102f66 <cprintf>
	// LAB 3: Your code here.
	switch (syscallno)
	{
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
f010370f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103714:	e9 83 00 00 00       	jmp    f010379c <syscall+0xcc>
{
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f0103719:	e8 c0 cc ff ff       	call   f01003de <cons_getc>
f010371e:	85 c0                	test   %eax,%eax
f0103720:	74 f7                	je     f0103719 <syscall+0x49>
f0103722:	eb 78                	jmp    f010379c <syscall+0xcc>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103724:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f0103729:	8b 40 4c             	mov    0x4c(%eax),%eax
			sys_cputs((const char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return (int32_t)sys_cgetc();
		case SYS_getenvid:
			return (int32_t)sys_getenvid();
f010372c:	eb 6e                	jmp    f010379c <syscall+0xcc>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010372e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103735:	00 
f0103736:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103739:	89 44 24 04          	mov    %eax,0x4(%esp)
f010373d:	89 14 24             	mov    %edx,(%esp)
f0103740:	e8 7b f1 ff ff       	call   f01028c0 <envid2env>
f0103745:	85 c0                	test   %eax,%eax
f0103747:	78 53                	js     f010379c <syscall+0xcc>
		return r;
	if (e == curenv)
f0103749:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010374c:	8b 15 5c 2d 17 f0    	mov    0xf0172d5c,%edx
f0103752:	39 d0                	cmp    %edx,%eax
f0103754:	75 15                	jne    f010376b <syscall+0x9b>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103756:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103759:	89 44 24 04          	mov    %eax,0x4(%esp)
f010375d:	c7 04 24 15 5b 10 f0 	movl   $0xf0105b15,(%esp)
f0103764:	e8 fd f7 ff ff       	call   f0102f66 <cprintf>
f0103769:	eb 1a                	jmp    f0103785 <syscall+0xb5>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010376b:	8b 40 4c             	mov    0x4c(%eax),%eax
f010376e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103772:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103775:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103779:	c7 04 24 30 5b 10 f0 	movl   $0xf0105b30,(%esp)
f0103780:	e8 e1 f7 ff ff       	call   f0102f66 <cprintf>
	env_destroy(e);
f0103785:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103788:	89 04 24             	mov    %eax,(%esp)
f010378b:	e8 c2 f6 ff ff       	call   f0102e52 <env_destroy>
	return 0;
f0103790:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cgetc:
			return (int32_t)sys_cgetc();
		case SYS_getenvid:
			return (int32_t)sys_getenvid();
		case SYS_env_destroy:
			return (int32_t)sys_env_destroy((envid_t)a1);
f0103795:	eb 05                	jmp    f010379c <syscall+0xcc>
		default:	//NSYSCALLS means non-syscalls
			return -E_INVAL;
f0103797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	//panic("syscall not implemented");
}
f010379c:	c9                   	leave  
f010379d:	c3                   	ret    
	...

f01037a0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01037a0:	55                   	push   %ebp
f01037a1:	89 e5                	mov    %esp,%ebp
f01037a3:	57                   	push   %edi
f01037a4:	56                   	push   %esi
f01037a5:	53                   	push   %ebx
f01037a6:	83 ec 14             	sub    $0x14,%esp
f01037a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01037ac:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01037af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01037b2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01037b5:	8b 1a                	mov    (%edx),%ebx
f01037b7:	8b 01                	mov    (%ecx),%eax
f01037b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f01037bc:	39 c3                	cmp    %eax,%ebx
f01037be:	0f 8f 9c 00 00 00    	jg     f0103860 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f01037c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01037cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01037ce:	01 d8                	add    %ebx,%eax
f01037d0:	89 c7                	mov    %eax,%edi
f01037d2:	c1 ef 1f             	shr    $0x1f,%edi
f01037d5:	01 c7                	add    %eax,%edi
f01037d7:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01037d9:	39 df                	cmp    %ebx,%edi
f01037db:	7c 33                	jl     f0103810 <stab_binsearch+0x70>
f01037dd:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01037e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01037e3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01037e8:	39 f0                	cmp    %esi,%eax
f01037ea:	0f 84 bc 00 00 00    	je     f01038ac <stab_binsearch+0x10c>
f01037f0:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01037f4:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01037f8:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01037fa:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01037fd:	39 d8                	cmp    %ebx,%eax
f01037ff:	7c 0f                	jl     f0103810 <stab_binsearch+0x70>
f0103801:	0f b6 0a             	movzbl (%edx),%ecx
f0103804:	83 ea 0c             	sub    $0xc,%edx
f0103807:	39 f1                	cmp    %esi,%ecx
f0103809:	75 ef                	jne    f01037fa <stab_binsearch+0x5a>
f010380b:	e9 9e 00 00 00       	jmp    f01038ae <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103810:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103813:	eb 3c                	jmp    f0103851 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103815:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103818:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010381a:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010381d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103824:	eb 2b                	jmp    f0103851 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103826:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103829:	76 14                	jbe    f010383f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010382b:	83 e8 01             	sub    $0x1,%eax
f010382e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103831:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103834:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103836:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010383d:	eb 12                	jmp    f0103851 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010383f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103842:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0103844:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103848:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010384a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103851:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103854:	0f 8d 71 ff ff ff    	jge    f01037cb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010385a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010385e:	75 0f                	jne    f010386f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103860:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103863:	8b 02                	mov    (%edx),%eax
f0103865:	83 e8 01             	sub    $0x1,%eax
f0103868:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010386b:	89 01                	mov    %eax,(%ecx)
f010386d:	eb 57                	jmp    f01038c6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010386f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103872:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103874:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103877:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103879:	39 c1                	cmp    %eax,%ecx
f010387b:	7d 28                	jge    f01038a5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010387d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103880:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103883:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103888:	39 f2                	cmp    %esi,%edx
f010388a:	74 19                	je     f01038a5 <stab_binsearch+0x105>
f010388c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103890:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103894:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103897:	39 c1                	cmp    %eax,%ecx
f0103899:	7d 0a                	jge    f01038a5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010389b:	0f b6 1a             	movzbl (%edx),%ebx
f010389e:	83 ea 0c             	sub    $0xc,%edx
f01038a1:	39 f3                	cmp    %esi,%ebx
f01038a3:	75 ef                	jne    f0103894 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f01038a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01038a8:	89 02                	mov    %eax,(%edx)
f01038aa:	eb 1a                	jmp    f01038c6 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01038ac:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01038ae:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01038b1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01038b4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01038b8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01038bb:	0f 82 54 ff ff ff    	jb     f0103815 <stab_binsearch+0x75>
f01038c1:	e9 60 ff ff ff       	jmp    f0103826 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01038c6:	83 c4 14             	add    $0x14,%esp
f01038c9:	5b                   	pop    %ebx
f01038ca:	5e                   	pop    %esi
f01038cb:	5f                   	pop    %edi
f01038cc:	5d                   	pop    %ebp
f01038cd:	c3                   	ret    

f01038ce <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01038ce:	55                   	push   %ebp
f01038cf:	89 e5                	mov    %esp,%ebp
f01038d1:	57                   	push   %edi
f01038d2:	56                   	push   %esi
f01038d3:	53                   	push   %ebx
f01038d4:	83 ec 5c             	sub    $0x5c,%esp
f01038d7:	8b 75 08             	mov    0x8(%ebp),%esi
f01038da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01038dd:	c7 03 48 5b 10 f0    	movl   $0xf0105b48,(%ebx)
	info->eip_line = 0;
f01038e3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01038ea:	c7 43 08 48 5b 10 f0 	movl   $0xf0105b48,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01038f1:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01038f8:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01038fb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103902:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103908:	77 23                	ja     f010392d <debuginfo_eip+0x5f>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f010390a:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0103910:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0103913:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0103919:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010391f:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0103922:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103928:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010392b:	eb 1a                	jmp    f0103947 <debuginfo_eip+0x79>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010392d:	c7 45 c0 50 fe 10 f0 	movl   $0xf010fe50,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103934:	c7 45 b8 7d d4 10 f0 	movl   $0xf010d47d,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010393b:	ba 7c d4 10 f0       	mov    $0xf010d47c,%edx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103940:	c7 45 c4 60 5d 10 f0 	movl   $0xf0105d60,-0x3c(%ebp)
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010394c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010394f:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f0103952:	0f 83 be 01 00 00    	jae    f0103b16 <debuginfo_eip+0x248>
f0103958:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010395c:	0f 85 b4 01 00 00    	jne    f0103b16 <debuginfo_eip+0x248>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103962:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103969:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f010396c:	c1 fa 02             	sar    $0x2,%edx
f010396f:	69 c2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%eax
f0103975:	83 e8 01             	sub    $0x1,%eax
f0103978:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010397b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010397f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103986:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103989:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010398c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010398f:	e8 0c fe ff ff       	call   f01037a0 <stab_binsearch>
	if (lfile == 0)
f0103994:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0103997:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f010399c:	85 d2                	test   %edx,%edx
f010399e:	0f 84 72 01 00 00    	je     f0103b16 <debuginfo_eip+0x248>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01039a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01039a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01039ad:	89 74 24 04          	mov    %esi,0x4(%esp)
f01039b1:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01039b8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01039bb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01039be:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01039c1:	e8 da fd ff ff       	call   f01037a0 <stab_binsearch>

	if (lfun <= rfun) {
f01039c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01039c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01039cc:	39 d0                	cmp    %edx,%eax
f01039ce:	7f 32                	jg     f0103a02 <debuginfo_eip+0x134>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01039d0:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01039d3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01039d6:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01039d9:	8b 39                	mov    (%ecx),%edi
f01039db:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01039de:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01039e1:	2b 7d b8             	sub    -0x48(%ebp),%edi
f01039e4:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01039e7:	73 09                	jae    f01039f2 <debuginfo_eip+0x124>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01039e9:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01039ec:	03 7d b8             	add    -0x48(%ebp),%edi
f01039ef:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01039f2:	8b 49 08             	mov    0x8(%ecx),%ecx
f01039f5:	89 4b 10             	mov    %ecx,0x10(%ebx)
		// This "n_value" is the function's first addr, but when it comes to SLINE,
		// "n_value" describes the offset, so we need to minus "n_value" fro addr
		// to get the offset of the line.
		addr -= info->eip_fn_addr;
f01039f8:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01039fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01039fd:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103a00:	eb 0f                	jmp    f0103a11 <debuginfo_eip+0x143>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103a02:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103a05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a08:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103a0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a0e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103a11:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103a18:	00 
f0103a19:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a1c:	89 04 24             	mov    %eax,(%esp)
f0103a1f:	e8 1b 09 00 00       	call   f010433f <strfind>
f0103a24:	2b 43 08             	sub    0x8(%ebx),%eax
f0103a27:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103a2a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a2e:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103a35:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103a38:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103a3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103a3e:	e8 5d fd ff ff       	call   f01037a0 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0103a43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a46:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103a49:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103a4c:	0f b7 54 96 06       	movzwl 0x6(%esi,%edx,4),%edx
f0103a51:	89 53 04             	mov    %edx,0x4(%ebx)
	if (rline < lline)
f0103a54:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103a57:	7e 07                	jle    f0103a60 <debuginfo_eip+0x192>
	{
		info->eip_line = -1;
f0103a59:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a66:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0103a69:	39 f8                	cmp    %edi,%eax
f0103a6b:	7c 78                	jl     f0103ae5 <debuginfo_eip+0x217>
	       && stabs[lline].n_type != N_SOL
f0103a6d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103a70:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103a73:	8d 34 97             	lea    (%edi,%edx,4),%esi
f0103a76:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f0103a7a:	80 f9 84             	cmp    $0x84,%cl
f0103a7d:	74 4e                	je     f0103acd <debuginfo_eip+0x1ff>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103a7f:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0103a83:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103a86:	89 c7                	mov    %eax,%edi
f0103a88:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f0103a8b:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0103a8e:	eb 27                	jmp    f0103ab7 <debuginfo_eip+0x1e9>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103a90:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a93:	39 c3                	cmp    %eax,%ebx
f0103a95:	7e 08                	jle    f0103a9f <debuginfo_eip+0x1d1>
f0103a97:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0103a9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103a9d:	eb 46                	jmp    f0103ae5 <debuginfo_eip+0x217>
	       && stabs[lline].n_type != N_SOL
f0103a9f:	89 d6                	mov    %edx,%esi
f0103aa1:	83 ea 0c             	sub    $0xc,%edx
f0103aa4:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f0103aa8:	80 f9 84             	cmp    $0x84,%cl
f0103aab:	75 08                	jne    f0103ab5 <debuginfo_eip+0x1e7>
f0103aad:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0103ab0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103ab3:	eb 18                	jmp    f0103acd <debuginfo_eip+0x1ff>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103ab5:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103ab7:	80 f9 64             	cmp    $0x64,%cl
f0103aba:	75 d4                	jne    f0103a90 <debuginfo_eip+0x1c2>
f0103abc:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0103ac0:	74 ce                	je     f0103a90 <debuginfo_eip+0x1c2>
f0103ac2:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0103ac5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103ac8:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0103acb:	7f 18                	jg     f0103ae5 <debuginfo_eip+0x217>
f0103acd:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103ad0:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103ad3:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0103ad6:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103ad9:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0103adc:	39 d0                	cmp    %edx,%eax
f0103ade:	73 05                	jae    f0103ae5 <debuginfo_eip+0x217>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103ae0:	03 45 b8             	add    -0x48(%ebp),%eax
f0103ae3:	89 03                	mov    %eax,(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0103ae5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103ae8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0103aeb:	b8 00 00 00 00       	mov    $0x0,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0103af0:	39 d1                	cmp    %edx,%ecx
f0103af2:	7c 22                	jl     f0103b16 <debuginfo_eip+0x248>
	{
		if (stabs[i].n_type == N_PSYM)
f0103af4:	8d 04 52             	lea    (%edx,%edx,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103af7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103afa:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
	{
		if (stabs[i].n_type == N_PSYM)
f0103afe:	80 38 a0             	cmpb   $0xa0,(%eax)
f0103b01:	75 04                	jne    f0103b07 <debuginfo_eip+0x239>
		{
			++(info->eip_fn_narg);
f0103b03:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0103b07:	83 c2 01             	add    $0x1,%edx
f0103b0a:	83 c0 0c             	add    $0xc,%eax
f0103b0d:	39 d1                	cmp    %edx,%ecx
f0103b0f:	7d ed                	jge    f0103afe <debuginfo_eip+0x230>
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0103b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b16:	83 c4 5c             	add    $0x5c,%esp
f0103b19:	5b                   	pop    %ebx
f0103b1a:	5e                   	pop    %esi
f0103b1b:	5f                   	pop    %edi
f0103b1c:	5d                   	pop    %ebp
f0103b1d:	c3                   	ret    
	...

f0103b20 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103b20:	55                   	push   %ebp
f0103b21:	89 e5                	mov    %esp,%ebp
f0103b23:	57                   	push   %edi
f0103b24:	56                   	push   %esi
f0103b25:	53                   	push   %ebx
f0103b26:	83 ec 3c             	sub    $0x3c,%esp
f0103b29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103b2c:	89 d7                	mov    %edx,%edi
f0103b2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b31:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103b34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b37:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103b3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103b3d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103b40:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b45:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0103b48:	72 11                	jb     f0103b5b <printnum+0x3b>
f0103b4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b4d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103b50:	76 09                	jbe    f0103b5b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103b52:	83 eb 01             	sub    $0x1,%ebx
f0103b55:	85 db                	test   %ebx,%ebx
f0103b57:	7f 51                	jg     f0103baa <printnum+0x8a>
f0103b59:	eb 5e                	jmp    f0103bb9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103b5b:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103b5f:	83 eb 01             	sub    $0x1,%ebx
f0103b62:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103b66:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b69:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b6d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0103b71:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0103b75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103b7c:	00 
f0103b7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b80:	89 04 24             	mov    %eax,(%esp)
f0103b83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b8a:	e8 d1 09 00 00       	call   f0104560 <__udivdi3>
f0103b8f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b93:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b97:	89 04 24             	mov    %eax,(%esp)
f0103b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103b9e:	89 fa                	mov    %edi,%edx
f0103ba0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ba3:	e8 78 ff ff ff       	call   f0103b20 <printnum>
f0103ba8:	eb 0f                	jmp    f0103bb9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103baa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103bae:	89 34 24             	mov    %esi,(%esp)
f0103bb1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103bb4:	83 eb 01             	sub    $0x1,%ebx
f0103bb7:	75 f1                	jne    f0103baa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103bb9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103bbd:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103bc1:	8b 45 10             	mov    0x10(%ebp),%eax
f0103bc4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103bc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103bcf:	00 
f0103bd0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103bd3:	89 04 24             	mov    %eax,(%esp)
f0103bd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bdd:	e8 ae 0a 00 00       	call   f0104690 <__umoddi3>
f0103be2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103be6:	0f be 80 52 5b 10 f0 	movsbl -0xfefa4ae(%eax),%eax
f0103bed:	89 04 24             	mov    %eax,(%esp)
f0103bf0:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0103bf3:	83 c4 3c             	add    $0x3c,%esp
f0103bf6:	5b                   	pop    %ebx
f0103bf7:	5e                   	pop    %esi
f0103bf8:	5f                   	pop    %edi
f0103bf9:	5d                   	pop    %ebp
f0103bfa:	c3                   	ret    

f0103bfb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103bfb:	55                   	push   %ebp
f0103bfc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103bfe:	83 fa 01             	cmp    $0x1,%edx
f0103c01:	7e 0e                	jle    f0103c11 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103c03:	8b 10                	mov    (%eax),%edx
f0103c05:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103c08:	89 08                	mov    %ecx,(%eax)
f0103c0a:	8b 02                	mov    (%edx),%eax
f0103c0c:	8b 52 04             	mov    0x4(%edx),%edx
f0103c0f:	eb 22                	jmp    f0103c33 <getuint+0x38>
	else if (lflag)
f0103c11:	85 d2                	test   %edx,%edx
f0103c13:	74 10                	je     f0103c25 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103c15:	8b 10                	mov    (%eax),%edx
f0103c17:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103c1a:	89 08                	mov    %ecx,(%eax)
f0103c1c:	8b 02                	mov    (%edx),%eax
f0103c1e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c23:	eb 0e                	jmp    f0103c33 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103c25:	8b 10                	mov    (%eax),%edx
f0103c27:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103c2a:	89 08                	mov    %ecx,(%eax)
f0103c2c:	8b 02                	mov    (%edx),%eax
f0103c2e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103c33:	5d                   	pop    %ebp
f0103c34:	c3                   	ret    

f0103c35 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103c35:	55                   	push   %ebp
f0103c36:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103c38:	83 fa 01             	cmp    $0x1,%edx
f0103c3b:	7e 0e                	jle    f0103c4b <getint+0x16>
		return va_arg(*ap, long long);
f0103c3d:	8b 10                	mov    (%eax),%edx
f0103c3f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103c42:	89 08                	mov    %ecx,(%eax)
f0103c44:	8b 02                	mov    (%edx),%eax
f0103c46:	8b 52 04             	mov    0x4(%edx),%edx
f0103c49:	eb 22                	jmp    f0103c6d <getint+0x38>
	else if (lflag)
f0103c4b:	85 d2                	test   %edx,%edx
f0103c4d:	74 10                	je     f0103c5f <getint+0x2a>
		return va_arg(*ap, long);
f0103c4f:	8b 10                	mov    (%eax),%edx
f0103c51:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103c54:	89 08                	mov    %ecx,(%eax)
f0103c56:	8b 02                	mov    (%edx),%eax
f0103c58:	89 c2                	mov    %eax,%edx
f0103c5a:	c1 fa 1f             	sar    $0x1f,%edx
f0103c5d:	eb 0e                	jmp    f0103c6d <getint+0x38>
	else
		return va_arg(*ap, int);
f0103c5f:	8b 10                	mov    (%eax),%edx
f0103c61:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103c64:	89 08                	mov    %ecx,(%eax)
f0103c66:	8b 02                	mov    (%edx),%eax
f0103c68:	89 c2                	mov    %eax,%edx
f0103c6a:	c1 fa 1f             	sar    $0x1f,%edx
}
f0103c6d:	5d                   	pop    %ebp
f0103c6e:	c3                   	ret    

f0103c6f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103c6f:	55                   	push   %ebp
f0103c70:	89 e5                	mov    %esp,%ebp
f0103c72:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103c75:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103c79:	8b 10                	mov    (%eax),%edx
f0103c7b:	3b 50 04             	cmp    0x4(%eax),%edx
f0103c7e:	73 0a                	jae    f0103c8a <sprintputch+0x1b>
		*b->buf++ = ch;
f0103c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c83:	88 0a                	mov    %cl,(%edx)
f0103c85:	83 c2 01             	add    $0x1,%edx
f0103c88:	89 10                	mov    %edx,(%eax)
}
f0103c8a:	5d                   	pop    %ebp
f0103c8b:	c3                   	ret    

f0103c8c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103c8c:	55                   	push   %ebp
f0103c8d:	89 e5                	mov    %esp,%ebp
f0103c8f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0103c92:	8d 45 14             	lea    0x14(%ebp),%eax
f0103c95:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c99:	8b 45 10             	mov    0x10(%ebp),%eax
f0103c9c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ca7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103caa:	89 04 24             	mov    %eax,(%esp)
f0103cad:	e8 02 00 00 00       	call   f0103cb4 <vprintfmt>
	va_end(ap);
}
f0103cb2:	c9                   	leave  
f0103cb3:	c3                   	ret    

f0103cb4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103cb4:	55                   	push   %ebp
f0103cb5:	89 e5                	mov    %esp,%ebp
f0103cb7:	57                   	push   %edi
f0103cb8:	56                   	push   %esi
f0103cb9:	53                   	push   %ebx
f0103cba:	83 ec 4c             	sub    $0x4c,%esp
f0103cbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103cc0:	8b 75 10             	mov    0x10(%ebp),%esi
f0103cc3:	eb 12                	jmp    f0103cd7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103cc5:	85 c0                	test   %eax,%eax
f0103cc7:	0f 84 98 03 00 00    	je     f0104065 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f0103ccd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103cd1:	89 04 24             	mov    %eax,(%esp)
f0103cd4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103cd7:	0f b6 06             	movzbl (%esi),%eax
f0103cda:	83 c6 01             	add    $0x1,%esi
f0103cdd:	83 f8 25             	cmp    $0x25,%eax
f0103ce0:	75 e3                	jne    f0103cc5 <vprintfmt+0x11>
f0103ce2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0103ce6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103ced:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0103cf2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103cfe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103d01:	eb 2b                	jmp    f0103d2e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d03:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103d06:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0103d0a:	eb 22                	jmp    f0103d2e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d0c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103d0f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0103d13:	eb 19                	jmp    f0103d2e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d15:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103d18:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103d1f:	eb 0d                	jmp    f0103d2e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103d21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103d27:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d2e:	0f b6 06             	movzbl (%esi),%eax
f0103d31:	0f b6 d0             	movzbl %al,%edx
f0103d34:	8d 7e 01             	lea    0x1(%esi),%edi
f0103d37:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0103d3a:	83 e8 23             	sub    $0x23,%eax
f0103d3d:	3c 55                	cmp    $0x55,%al
f0103d3f:	0f 87 fa 02 00 00    	ja     f010403f <vprintfmt+0x38b>
f0103d45:	0f b6 c0             	movzbl %al,%eax
f0103d48:	ff 24 85 dc 5b 10 f0 	jmp    *-0xfefa424(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103d4f:	83 ea 30             	sub    $0x30,%edx
f0103d52:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103d55:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0103d59:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d5c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0103d5f:	83 fa 09             	cmp    $0x9,%edx
f0103d62:	77 4a                	ja     f0103dae <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d64:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103d67:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0103d6a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0103d6d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0103d71:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103d74:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103d77:	83 fa 09             	cmp    $0x9,%edx
f0103d7a:	76 eb                	jbe    f0103d67 <vprintfmt+0xb3>
f0103d7c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103d7f:	eb 2d                	jmp    f0103dae <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103d81:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d84:	8d 50 04             	lea    0x4(%eax),%edx
f0103d87:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d8a:	8b 00                	mov    (%eax),%eax
f0103d8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d8f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103d92:	eb 1a                	jmp    f0103dae <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d94:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0103d97:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d9b:	79 91                	jns    f0103d2e <vprintfmt+0x7a>
f0103d9d:	e9 73 ff ff ff       	jmp    f0103d15 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103da2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103da5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103dac:	eb 80                	jmp    f0103d2e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0103dae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103db2:	0f 89 76 ff ff ff    	jns    f0103d2e <vprintfmt+0x7a>
f0103db8:	e9 64 ff ff ff       	jmp    f0103d21 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103dbd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103dc0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103dc3:	e9 66 ff ff ff       	jmp    f0103d2e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103dc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103dcb:	8d 50 04             	lea    0x4(%eax),%edx
f0103dce:	89 55 14             	mov    %edx,0x14(%ebp)
f0103dd1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103dd5:	8b 00                	mov    (%eax),%eax
f0103dd7:	89 04 24             	mov    %eax,(%esp)
f0103dda:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ddd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103de0:	e9 f2 fe ff ff       	jmp    f0103cd7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103de5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103de8:	8d 50 04             	lea    0x4(%eax),%edx
f0103deb:	89 55 14             	mov    %edx,0x14(%ebp)
f0103dee:	8b 00                	mov    (%eax),%eax
f0103df0:	89 c2                	mov    %eax,%edx
f0103df2:	c1 fa 1f             	sar    $0x1f,%edx
f0103df5:	31 d0                	xor    %edx,%eax
f0103df7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0103df9:	83 f8 06             	cmp    $0x6,%eax
f0103dfc:	7f 0b                	jg     f0103e09 <vprintfmt+0x155>
f0103dfe:	8b 14 85 34 5d 10 f0 	mov    -0xfefa2cc(,%eax,4),%edx
f0103e05:	85 d2                	test   %edx,%edx
f0103e07:	75 23                	jne    f0103e2c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0103e09:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e0d:	c7 44 24 08 6a 5b 10 	movl   $0xf0105b6a,0x8(%esp)
f0103e14:	f0 
f0103e15:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e19:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103e1c:	89 3c 24             	mov    %edi,(%esp)
f0103e1f:	e8 68 fe ff ff       	call   f0103c8c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e24:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103e27:	e9 ab fe ff ff       	jmp    f0103cd7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0103e2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103e30:	c7 44 24 08 0f 55 10 	movl   $0xf010550f,0x8(%esp)
f0103e37:	f0 
f0103e38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e3c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103e3f:	89 3c 24             	mov    %edi,(%esp)
f0103e42:	e8 45 fe ff ff       	call   f0103c8c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e47:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103e4a:	e9 88 fe ff ff       	jmp    f0103cd7 <vprintfmt+0x23>
f0103e4f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e55:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103e58:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e5b:	8d 50 04             	lea    0x4(%eax),%edx
f0103e5e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103e61:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103e63:	85 f6                	test   %esi,%esi
f0103e65:	ba 63 5b 10 f0       	mov    $0xf0105b63,%edx
f0103e6a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0103e6d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103e71:	7e 06                	jle    f0103e79 <vprintfmt+0x1c5>
f0103e73:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0103e77:	75 10                	jne    f0103e89 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e79:	0f be 06             	movsbl (%esi),%eax
f0103e7c:	83 c6 01             	add    $0x1,%esi
f0103e7f:	85 c0                	test   %eax,%eax
f0103e81:	0f 85 86 00 00 00    	jne    f0103f0d <vprintfmt+0x259>
f0103e87:	eb 76                	jmp    f0103eff <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103e89:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e8d:	89 34 24             	mov    %esi,(%esp)
f0103e90:	e8 36 03 00 00       	call   f01041cb <strnlen>
f0103e95:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103e98:	29 c2                	sub    %eax,%edx
f0103e9a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103e9d:	85 d2                	test   %edx,%edx
f0103e9f:	7e d8                	jle    f0103e79 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0103ea1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0103ea5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103ea8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0103eab:	89 d6                	mov    %edx,%esi
f0103ead:	89 c7                	mov    %eax,%edi
f0103eaf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eb3:	89 3c 24             	mov    %edi,(%esp)
f0103eb6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103eb9:	83 ee 01             	sub    $0x1,%esi
f0103ebc:	75 f1                	jne    f0103eaf <vprintfmt+0x1fb>
f0103ebe:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103ec1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0103ec4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103ec7:	eb b0                	jmp    f0103e79 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103ec9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103ecd:	74 18                	je     f0103ee7 <vprintfmt+0x233>
f0103ecf:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103ed2:	83 fa 5e             	cmp    $0x5e,%edx
f0103ed5:	76 10                	jbe    f0103ee7 <vprintfmt+0x233>
					putch('?', putdat);
f0103ed7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103edb:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103ee2:	ff 55 08             	call   *0x8(%ebp)
f0103ee5:	eb 0a                	jmp    f0103ef1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f0103ee7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eeb:	89 04 24             	mov    %eax,(%esp)
f0103eee:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103ef1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0103ef5:	0f be 06             	movsbl (%esi),%eax
f0103ef8:	83 c6 01             	add    $0x1,%esi
f0103efb:	85 c0                	test   %eax,%eax
f0103efd:	75 0e                	jne    f0103f0d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103f02:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f06:	7f 11                	jg     f0103f19 <vprintfmt+0x265>
f0103f08:	e9 ca fd ff ff       	jmp    f0103cd7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103f0d:	85 ff                	test   %edi,%edi
f0103f0f:	90                   	nop
f0103f10:	78 b7                	js     f0103ec9 <vprintfmt+0x215>
f0103f12:	83 ef 01             	sub    $0x1,%edi
f0103f15:	79 b2                	jns    f0103ec9 <vprintfmt+0x215>
f0103f17:	eb e6                	jmp    f0103eff <vprintfmt+0x24b>
f0103f19:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103f1c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103f1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f23:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103f2a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103f2c:	83 ee 01             	sub    $0x1,%esi
f0103f2f:	75 ee                	jne    f0103f1f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f31:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103f34:	e9 9e fd ff ff       	jmp    f0103cd7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103f39:	89 ca                	mov    %ecx,%edx
f0103f3b:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f3e:	e8 f2 fc ff ff       	call   f0103c35 <getint>
f0103f43:	89 c6                	mov    %eax,%esi
f0103f45:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103f47:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103f4c:	85 d2                	test   %edx,%edx
f0103f4e:	0f 89 ad 00 00 00    	jns    f0104001 <vprintfmt+0x34d>
				putch('-', putdat);
f0103f54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f58:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103f5f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103f62:	f7 de                	neg    %esi
f0103f64:	83 d7 00             	adc    $0x0,%edi
f0103f67:	f7 df                	neg    %edi
			}
			base = 10;
f0103f69:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f6e:	e9 8e 00 00 00       	jmp    f0104001 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103f73:	89 ca                	mov    %ecx,%edx
f0103f75:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f78:	e8 7e fc ff ff       	call   f0103bfb <getuint>
f0103f7d:	89 c6                	mov    %eax,%esi
f0103f7f:	89 d7                	mov    %edx,%edi
			base = 10;
f0103f81:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103f86:	eb 79                	jmp    f0104001 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f0103f88:	89 ca                	mov    %ecx,%edx
f0103f8a:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f8d:	e8 a3 fc ff ff       	call   f0103c35 <getint>
f0103f92:	89 c6                	mov    %eax,%esi
f0103f94:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f0103f96:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103f9b:	85 d2                	test   %edx,%edx
f0103f9d:	79 62                	jns    f0104001 <vprintfmt+0x34d>
				putch('-', putdat);
f0103f9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fa3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103faa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103fad:	f7 de                	neg    %esi
f0103faf:	83 d7 00             	adc    $0x0,%edi
f0103fb2:	f7 df                	neg    %edi
			}
			base = 8;
f0103fb4:	b8 08 00 00 00       	mov    $0x8,%eax
f0103fb9:	eb 46                	jmp    f0104001 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f0103fbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fbf:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103fc6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103fc9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fcd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103fd4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103fd7:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fda:	8d 50 04             	lea    0x4(%eax),%edx
f0103fdd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103fe0:	8b 30                	mov    (%eax),%esi
f0103fe2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103fe7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103fec:	eb 13                	jmp    f0104001 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103fee:	89 ca                	mov    %ecx,%edx
f0103ff0:	8d 45 14             	lea    0x14(%ebp),%eax
f0103ff3:	e8 03 fc ff ff       	call   f0103bfb <getuint>
f0103ff8:	89 c6                	mov    %eax,%esi
f0103ffa:	89 d7                	mov    %edx,%edi
			base = 16;
f0103ffc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104001:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0104005:	89 54 24 10          	mov    %edx,0x10(%esp)
f0104009:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010400c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104010:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104014:	89 34 24             	mov    %esi,(%esp)
f0104017:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010401b:	89 da                	mov    %ebx,%edx
f010401d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104020:	e8 fb fa ff ff       	call   f0103b20 <printnum>
			break;
f0104025:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104028:	e9 aa fc ff ff       	jmp    f0103cd7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010402d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104031:	89 14 24             	mov    %edx,(%esp)
f0104034:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104037:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010403a:	e9 98 fc ff ff       	jmp    f0103cd7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010403f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104043:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010404a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010404d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104051:	0f 84 80 fc ff ff    	je     f0103cd7 <vprintfmt+0x23>
f0104057:	83 ee 01             	sub    $0x1,%esi
f010405a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010405e:	75 f7                	jne    f0104057 <vprintfmt+0x3a3>
f0104060:	e9 72 fc ff ff       	jmp    f0103cd7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0104065:	83 c4 4c             	add    $0x4c,%esp
f0104068:	5b                   	pop    %ebx
f0104069:	5e                   	pop    %esi
f010406a:	5f                   	pop    %edi
f010406b:	5d                   	pop    %ebp
f010406c:	c3                   	ret    

f010406d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010406d:	55                   	push   %ebp
f010406e:	89 e5                	mov    %esp,%ebp
f0104070:	83 ec 28             	sub    $0x28,%esp
f0104073:	8b 45 08             	mov    0x8(%ebp),%eax
f0104076:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104079:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010407c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104080:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104083:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010408a:	85 c0                	test   %eax,%eax
f010408c:	74 30                	je     f01040be <vsnprintf+0x51>
f010408e:	85 d2                	test   %edx,%edx
f0104090:	7e 2c                	jle    f01040be <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104092:	8b 45 14             	mov    0x14(%ebp),%eax
f0104095:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104099:	8b 45 10             	mov    0x10(%ebp),%eax
f010409c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01040a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040a7:	c7 04 24 6f 3c 10 f0 	movl   $0xf0103c6f,(%esp)
f01040ae:	e8 01 fc ff ff       	call   f0103cb4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01040b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01040b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01040b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01040bc:	eb 05                	jmp    f01040c3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01040be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01040c3:	c9                   	leave  
f01040c4:	c3                   	ret    

f01040c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01040c5:	55                   	push   %ebp
f01040c6:	89 e5                	mov    %esp,%ebp
f01040c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01040cb:	8d 45 14             	lea    0x14(%ebp),%eax
f01040ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040d2:	8b 45 10             	mov    0x10(%ebp),%eax
f01040d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01040dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01040e3:	89 04 24             	mov    %eax,(%esp)
f01040e6:	e8 82 ff ff ff       	call   f010406d <vsnprintf>
	va_end(ap);

	return rc;
}
f01040eb:	c9                   	leave  
f01040ec:	c3                   	ret    
f01040ed:	00 00                	add    %al,(%eax)
	...

f01040f0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01040f0:	55                   	push   %ebp
f01040f1:	89 e5                	mov    %esp,%ebp
f01040f3:	57                   	push   %edi
f01040f4:	56                   	push   %esi
f01040f5:	53                   	push   %ebx
f01040f6:	83 ec 1c             	sub    $0x1c,%esp
f01040f9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01040fc:	85 c0                	test   %eax,%eax
f01040fe:	74 10                	je     f0104110 <readline+0x20>
		cprintf("%s", prompt);
f0104100:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104104:	c7 04 24 0f 55 10 f0 	movl   $0xf010550f,(%esp)
f010410b:	e8 56 ee ff ff       	call   f0102f66 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104110:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104117:	e8 e0 c5 ff ff       	call   f01006fc <iscons>
f010411c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010411e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104123:	e8 c3 c5 ff ff       	call   f01006eb <getchar>
f0104128:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010412a:	85 c0                	test   %eax,%eax
f010412c:	79 17                	jns    f0104145 <readline+0x55>
			cprintf("read error: %e\n", c);
f010412e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104132:	c7 04 24 50 5d 10 f0 	movl   $0xf0105d50,(%esp)
f0104139:	e8 28 ee ff ff       	call   f0102f66 <cprintf>
			return NULL;
f010413e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104143:	eb 61                	jmp    f01041a6 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104145:	83 f8 1f             	cmp    $0x1f,%eax
f0104148:	7e 1f                	jle    f0104169 <readline+0x79>
f010414a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104150:	7f 17                	jg     f0104169 <readline+0x79>
			if (echoing)
f0104152:	85 ff                	test   %edi,%edi
f0104154:	74 08                	je     f010415e <readline+0x6e>
				cputchar(c);
f0104156:	89 04 24             	mov    %eax,(%esp)
f0104159:	e8 7a c5 ff ff       	call   f01006d8 <cputchar>
			buf[i++] = c;
f010415e:	88 9e 00 36 17 f0    	mov    %bl,-0xfe8ca00(%esi)
f0104164:	83 c6 01             	add    $0x1,%esi
f0104167:	eb ba                	jmp    f0104123 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0104169:	83 fb 08             	cmp    $0x8,%ebx
f010416c:	75 15                	jne    f0104183 <readline+0x93>
f010416e:	85 f6                	test   %esi,%esi
f0104170:	7e 11                	jle    f0104183 <readline+0x93>
			if (echoing)
f0104172:	85 ff                	test   %edi,%edi
f0104174:	74 08                	je     f010417e <readline+0x8e>
				cputchar(c);
f0104176:	89 1c 24             	mov    %ebx,(%esp)
f0104179:	e8 5a c5 ff ff       	call   f01006d8 <cputchar>
			i--;
f010417e:	83 ee 01             	sub    $0x1,%esi
f0104181:	eb a0                	jmp    f0104123 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104183:	83 fb 0a             	cmp    $0xa,%ebx
f0104186:	74 05                	je     f010418d <readline+0x9d>
f0104188:	83 fb 0d             	cmp    $0xd,%ebx
f010418b:	75 96                	jne    f0104123 <readline+0x33>
			if (echoing)
f010418d:	85 ff                	test   %edi,%edi
f010418f:	90                   	nop
f0104190:	74 08                	je     f010419a <readline+0xaa>
				cputchar(c);
f0104192:	89 1c 24             	mov    %ebx,(%esp)
f0104195:	e8 3e c5 ff ff       	call   f01006d8 <cputchar>
			buf[i] = 0;
f010419a:	c6 86 00 36 17 f0 00 	movb   $0x0,-0xfe8ca00(%esi)
			return buf;
f01041a1:	b8 00 36 17 f0       	mov    $0xf0173600,%eax
		}
	}
}
f01041a6:	83 c4 1c             	add    $0x1c,%esp
f01041a9:	5b                   	pop    %ebx
f01041aa:	5e                   	pop    %esi
f01041ab:	5f                   	pop    %edi
f01041ac:	5d                   	pop    %ebp
f01041ad:	c3                   	ret    
	...

f01041b0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01041b0:	55                   	push   %ebp
f01041b1:	89 e5                	mov    %esp,%ebp
f01041b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01041b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01041bb:	80 3a 00             	cmpb   $0x0,(%edx)
f01041be:	74 09                	je     f01041c9 <strlen+0x19>
		n++;
f01041c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01041c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01041c7:	75 f7                	jne    f01041c0 <strlen+0x10>
		n++;
	return n;
}
f01041c9:	5d                   	pop    %ebp
f01041ca:	c3                   	ret    

f01041cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01041cb:	55                   	push   %ebp
f01041cc:	89 e5                	mov    %esp,%ebp
f01041ce:	53                   	push   %ebx
f01041cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01041d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01041d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01041da:	85 c9                	test   %ecx,%ecx
f01041dc:	74 1a                	je     f01041f8 <strnlen+0x2d>
f01041de:	80 3b 00             	cmpb   $0x0,(%ebx)
f01041e1:	74 15                	je     f01041f8 <strnlen+0x2d>
f01041e3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01041e8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01041ea:	39 ca                	cmp    %ecx,%edx
f01041ec:	74 0a                	je     f01041f8 <strnlen+0x2d>
f01041ee:	83 c2 01             	add    $0x1,%edx
f01041f1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01041f6:	75 f0                	jne    f01041e8 <strnlen+0x1d>
		n++;
	return n;
}
f01041f8:	5b                   	pop    %ebx
f01041f9:	5d                   	pop    %ebp
f01041fa:	c3                   	ret    

f01041fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01041fb:	55                   	push   %ebp
f01041fc:	89 e5                	mov    %esp,%ebp
f01041fe:	53                   	push   %ebx
f01041ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0104202:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104205:	ba 00 00 00 00       	mov    $0x0,%edx
f010420a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010420e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104211:	83 c2 01             	add    $0x1,%edx
f0104214:	84 c9                	test   %cl,%cl
f0104216:	75 f2                	jne    f010420a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104218:	5b                   	pop    %ebx
f0104219:	5d                   	pop    %ebp
f010421a:	c3                   	ret    

f010421b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010421b:	55                   	push   %ebp
f010421c:	89 e5                	mov    %esp,%ebp
f010421e:	56                   	push   %esi
f010421f:	53                   	push   %ebx
f0104220:	8b 45 08             	mov    0x8(%ebp),%eax
f0104223:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104226:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104229:	85 f6                	test   %esi,%esi
f010422b:	74 18                	je     f0104245 <strncpy+0x2a>
f010422d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0104232:	0f b6 1a             	movzbl (%edx),%ebx
f0104235:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104238:	80 3a 01             	cmpb   $0x1,(%edx)
f010423b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010423e:	83 c1 01             	add    $0x1,%ecx
f0104241:	39 f1                	cmp    %esi,%ecx
f0104243:	75 ed                	jne    f0104232 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104245:	5b                   	pop    %ebx
f0104246:	5e                   	pop    %esi
f0104247:	5d                   	pop    %ebp
f0104248:	c3                   	ret    

f0104249 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104249:	55                   	push   %ebp
f010424a:	89 e5                	mov    %esp,%ebp
f010424c:	57                   	push   %edi
f010424d:	56                   	push   %esi
f010424e:	53                   	push   %ebx
f010424f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104252:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104255:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104258:	89 f8                	mov    %edi,%eax
f010425a:	85 f6                	test   %esi,%esi
f010425c:	74 2b                	je     f0104289 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f010425e:	83 fe 01             	cmp    $0x1,%esi
f0104261:	74 23                	je     f0104286 <strlcpy+0x3d>
f0104263:	0f b6 0b             	movzbl (%ebx),%ecx
f0104266:	84 c9                	test   %cl,%cl
f0104268:	74 1c                	je     f0104286 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f010426a:	83 ee 02             	sub    $0x2,%esi
f010426d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104272:	88 08                	mov    %cl,(%eax)
f0104274:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104277:	39 f2                	cmp    %esi,%edx
f0104279:	74 0b                	je     f0104286 <strlcpy+0x3d>
f010427b:	83 c2 01             	add    $0x1,%edx
f010427e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0104282:	84 c9                	test   %cl,%cl
f0104284:	75 ec                	jne    f0104272 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0104286:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104289:	29 f8                	sub    %edi,%eax
}
f010428b:	5b                   	pop    %ebx
f010428c:	5e                   	pop    %esi
f010428d:	5f                   	pop    %edi
f010428e:	5d                   	pop    %ebp
f010428f:	c3                   	ret    

f0104290 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104290:	55                   	push   %ebp
f0104291:	89 e5                	mov    %esp,%ebp
f0104293:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104296:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104299:	0f b6 01             	movzbl (%ecx),%eax
f010429c:	84 c0                	test   %al,%al
f010429e:	74 16                	je     f01042b6 <strcmp+0x26>
f01042a0:	3a 02                	cmp    (%edx),%al
f01042a2:	75 12                	jne    f01042b6 <strcmp+0x26>
		p++, q++;
f01042a4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01042a7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f01042ab:	84 c0                	test   %al,%al
f01042ad:	74 07                	je     f01042b6 <strcmp+0x26>
f01042af:	83 c1 01             	add    $0x1,%ecx
f01042b2:	3a 02                	cmp    (%edx),%al
f01042b4:	74 ee                	je     f01042a4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01042b6:	0f b6 c0             	movzbl %al,%eax
f01042b9:	0f b6 12             	movzbl (%edx),%edx
f01042bc:	29 d0                	sub    %edx,%eax
}
f01042be:	5d                   	pop    %ebp
f01042bf:	c3                   	ret    

f01042c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01042c0:	55                   	push   %ebp
f01042c1:	89 e5                	mov    %esp,%ebp
f01042c3:	53                   	push   %ebx
f01042c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01042c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01042ca:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01042cd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01042d2:	85 d2                	test   %edx,%edx
f01042d4:	74 28                	je     f01042fe <strncmp+0x3e>
f01042d6:	0f b6 01             	movzbl (%ecx),%eax
f01042d9:	84 c0                	test   %al,%al
f01042db:	74 24                	je     f0104301 <strncmp+0x41>
f01042dd:	3a 03                	cmp    (%ebx),%al
f01042df:	75 20                	jne    f0104301 <strncmp+0x41>
f01042e1:	83 ea 01             	sub    $0x1,%edx
f01042e4:	74 13                	je     f01042f9 <strncmp+0x39>
		n--, p++, q++;
f01042e6:	83 c1 01             	add    $0x1,%ecx
f01042e9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01042ec:	0f b6 01             	movzbl (%ecx),%eax
f01042ef:	84 c0                	test   %al,%al
f01042f1:	74 0e                	je     f0104301 <strncmp+0x41>
f01042f3:	3a 03                	cmp    (%ebx),%al
f01042f5:	74 ea                	je     f01042e1 <strncmp+0x21>
f01042f7:	eb 08                	jmp    f0104301 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f01042f9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01042fe:	5b                   	pop    %ebx
f01042ff:	5d                   	pop    %ebp
f0104300:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104301:	0f b6 01             	movzbl (%ecx),%eax
f0104304:	0f b6 13             	movzbl (%ebx),%edx
f0104307:	29 d0                	sub    %edx,%eax
f0104309:	eb f3                	jmp    f01042fe <strncmp+0x3e>

f010430b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010430b:	55                   	push   %ebp
f010430c:	89 e5                	mov    %esp,%ebp
f010430e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104311:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104315:	0f b6 10             	movzbl (%eax),%edx
f0104318:	84 d2                	test   %dl,%dl
f010431a:	74 1c                	je     f0104338 <strchr+0x2d>
		if (*s == c)
f010431c:	38 ca                	cmp    %cl,%dl
f010431e:	75 09                	jne    f0104329 <strchr+0x1e>
f0104320:	eb 1b                	jmp    f010433d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104322:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0104325:	38 ca                	cmp    %cl,%dl
f0104327:	74 14                	je     f010433d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104329:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f010432d:	84 d2                	test   %dl,%dl
f010432f:	75 f1                	jne    f0104322 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0104331:	b8 00 00 00 00       	mov    $0x0,%eax
f0104336:	eb 05                	jmp    f010433d <strchr+0x32>
f0104338:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010433d:	5d                   	pop    %ebp
f010433e:	c3                   	ret    

f010433f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010433f:	55                   	push   %ebp
f0104340:	89 e5                	mov    %esp,%ebp
f0104342:	8b 45 08             	mov    0x8(%ebp),%eax
f0104345:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104349:	0f b6 10             	movzbl (%eax),%edx
f010434c:	84 d2                	test   %dl,%dl
f010434e:	74 14                	je     f0104364 <strfind+0x25>
		if (*s == c)
f0104350:	38 ca                	cmp    %cl,%dl
f0104352:	75 06                	jne    f010435a <strfind+0x1b>
f0104354:	eb 0e                	jmp    f0104364 <strfind+0x25>
f0104356:	38 ca                	cmp    %cl,%dl
f0104358:	74 0a                	je     f0104364 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010435a:	83 c0 01             	add    $0x1,%eax
f010435d:	0f b6 10             	movzbl (%eax),%edx
f0104360:	84 d2                	test   %dl,%dl
f0104362:	75 f2                	jne    f0104356 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0104364:	5d                   	pop    %ebp
f0104365:	c3                   	ret    

f0104366 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0104366:	55                   	push   %ebp
f0104367:	89 e5                	mov    %esp,%ebp
f0104369:	53                   	push   %ebx
f010436a:	8b 45 08             	mov    0x8(%ebp),%eax
f010436d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104370:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0104373:	89 da                	mov    %ebx,%edx
f0104375:	83 ea 01             	sub    $0x1,%edx
f0104378:	78 0d                	js     f0104387 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f010437a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f010437c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f010437e:	88 0a                	mov    %cl,(%edx)
f0104380:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0104383:	39 da                	cmp    %ebx,%edx
f0104385:	75 f7                	jne    f010437e <memset+0x18>
		*p++ = c;

	return v;
}
f0104387:	5b                   	pop    %ebx
f0104388:	5d                   	pop    %ebp
f0104389:	c3                   	ret    

f010438a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f010438a:	55                   	push   %ebp
f010438b:	89 e5                	mov    %esp,%ebp
f010438d:	57                   	push   %edi
f010438e:	56                   	push   %esi
f010438f:	53                   	push   %ebx
f0104390:	8b 45 08             	mov    0x8(%ebp),%eax
f0104393:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104396:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104399:	39 c6                	cmp    %eax,%esi
f010439b:	72 0b                	jb     f01043a8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f010439d:	ba 00 00 00 00       	mov    $0x0,%edx
f01043a2:	85 db                	test   %ebx,%ebx
f01043a4:	75 29                	jne    f01043cf <memmove+0x45>
f01043a6:	eb 35                	jmp    f01043dd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01043a8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f01043ab:	39 c8                	cmp    %ecx,%eax
f01043ad:	73 ee                	jae    f010439d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f01043af:	85 db                	test   %ebx,%ebx
f01043b1:	74 2a                	je     f01043dd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f01043b3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f01043b6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f01043b8:	f7 db                	neg    %ebx
f01043ba:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f01043bd:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f01043bf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f01043c4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f01043c8:	83 ea 01             	sub    $0x1,%edx
f01043cb:	75 f2                	jne    f01043bf <memmove+0x35>
f01043cd:	eb 0e                	jmp    f01043dd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f01043cf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01043d3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01043d6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f01043d9:	39 d3                	cmp    %edx,%ebx
f01043db:	75 f2                	jne    f01043cf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f01043dd:	5b                   	pop    %ebx
f01043de:	5e                   	pop    %esi
f01043df:	5f                   	pop    %edi
f01043e0:	5d                   	pop    %ebp
f01043e1:	c3                   	ret    

f01043e2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f01043e2:	55                   	push   %ebp
f01043e3:	89 e5                	mov    %esp,%ebp
f01043e5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01043e8:	8b 45 10             	mov    0x10(%ebp),%eax
f01043eb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043ef:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01043f9:	89 04 24             	mov    %eax,(%esp)
f01043fc:	e8 89 ff ff ff       	call   f010438a <memmove>
}
f0104401:	c9                   	leave  
f0104402:	c3                   	ret    

f0104403 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104403:	55                   	push   %ebp
f0104404:	89 e5                	mov    %esp,%ebp
f0104406:	57                   	push   %edi
f0104407:	56                   	push   %esi
f0104408:	53                   	push   %ebx
f0104409:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010440c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010440f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104412:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104417:	85 ff                	test   %edi,%edi
f0104419:	74 37                	je     f0104452 <memcmp+0x4f>
		if (*s1 != *s2)
f010441b:	0f b6 03             	movzbl (%ebx),%eax
f010441e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104421:	83 ef 01             	sub    $0x1,%edi
f0104424:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0104429:	38 c8                	cmp    %cl,%al
f010442b:	74 1c                	je     f0104449 <memcmp+0x46>
f010442d:	eb 10                	jmp    f010443f <memcmp+0x3c>
f010442f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0104434:	83 c2 01             	add    $0x1,%edx
f0104437:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010443b:	38 c8                	cmp    %cl,%al
f010443d:	74 0a                	je     f0104449 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f010443f:	0f b6 c0             	movzbl %al,%eax
f0104442:	0f b6 c9             	movzbl %cl,%ecx
f0104445:	29 c8                	sub    %ecx,%eax
f0104447:	eb 09                	jmp    f0104452 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104449:	39 fa                	cmp    %edi,%edx
f010444b:	75 e2                	jne    f010442f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010444d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104452:	5b                   	pop    %ebx
f0104453:	5e                   	pop    %esi
f0104454:	5f                   	pop    %edi
f0104455:	5d                   	pop    %ebp
f0104456:	c3                   	ret    

f0104457 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104457:	55                   	push   %ebp
f0104458:	89 e5                	mov    %esp,%ebp
f010445a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010445d:	89 c2                	mov    %eax,%edx
f010445f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104462:	39 d0                	cmp    %edx,%eax
f0104464:	73 15                	jae    f010447b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104466:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f010446a:	38 08                	cmp    %cl,(%eax)
f010446c:	75 06                	jne    f0104474 <memfind+0x1d>
f010446e:	eb 0b                	jmp    f010447b <memfind+0x24>
f0104470:	38 08                	cmp    %cl,(%eax)
f0104472:	74 07                	je     f010447b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104474:	83 c0 01             	add    $0x1,%eax
f0104477:	39 d0                	cmp    %edx,%eax
f0104479:	75 f5                	jne    f0104470 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010447b:	5d                   	pop    %ebp
f010447c:	c3                   	ret    

f010447d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010447d:	55                   	push   %ebp
f010447e:	89 e5                	mov    %esp,%ebp
f0104480:	57                   	push   %edi
f0104481:	56                   	push   %esi
f0104482:	53                   	push   %ebx
f0104483:	8b 55 08             	mov    0x8(%ebp),%edx
f0104486:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104489:	0f b6 02             	movzbl (%edx),%eax
f010448c:	3c 20                	cmp    $0x20,%al
f010448e:	74 04                	je     f0104494 <strtol+0x17>
f0104490:	3c 09                	cmp    $0x9,%al
f0104492:	75 0e                	jne    f01044a2 <strtol+0x25>
		s++;
f0104494:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104497:	0f b6 02             	movzbl (%edx),%eax
f010449a:	3c 20                	cmp    $0x20,%al
f010449c:	74 f6                	je     f0104494 <strtol+0x17>
f010449e:	3c 09                	cmp    $0x9,%al
f01044a0:	74 f2                	je     f0104494 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f01044a2:	3c 2b                	cmp    $0x2b,%al
f01044a4:	75 0a                	jne    f01044b0 <strtol+0x33>
		s++;
f01044a6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01044a9:	bf 00 00 00 00       	mov    $0x0,%edi
f01044ae:	eb 10                	jmp    f01044c0 <strtol+0x43>
f01044b0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01044b5:	3c 2d                	cmp    $0x2d,%al
f01044b7:	75 07                	jne    f01044c0 <strtol+0x43>
		s++, neg = 1;
f01044b9:	83 c2 01             	add    $0x1,%edx
f01044bc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01044c0:	85 db                	test   %ebx,%ebx
f01044c2:	0f 94 c0             	sete   %al
f01044c5:	74 05                	je     f01044cc <strtol+0x4f>
f01044c7:	83 fb 10             	cmp    $0x10,%ebx
f01044ca:	75 15                	jne    f01044e1 <strtol+0x64>
f01044cc:	80 3a 30             	cmpb   $0x30,(%edx)
f01044cf:	75 10                	jne    f01044e1 <strtol+0x64>
f01044d1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01044d5:	75 0a                	jne    f01044e1 <strtol+0x64>
		s += 2, base = 16;
f01044d7:	83 c2 02             	add    $0x2,%edx
f01044da:	bb 10 00 00 00       	mov    $0x10,%ebx
f01044df:	eb 13                	jmp    f01044f4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f01044e1:	84 c0                	test   %al,%al
f01044e3:	74 0f                	je     f01044f4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01044e5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01044ea:	80 3a 30             	cmpb   $0x30,(%edx)
f01044ed:	75 05                	jne    f01044f4 <strtol+0x77>
		s++, base = 8;
f01044ef:	83 c2 01             	add    $0x1,%edx
f01044f2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01044f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01044f9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01044fb:	0f b6 0a             	movzbl (%edx),%ecx
f01044fe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104501:	80 fb 09             	cmp    $0x9,%bl
f0104504:	77 08                	ja     f010450e <strtol+0x91>
			dig = *s - '0';
f0104506:	0f be c9             	movsbl %cl,%ecx
f0104509:	83 e9 30             	sub    $0x30,%ecx
f010450c:	eb 1e                	jmp    f010452c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f010450e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104511:	80 fb 19             	cmp    $0x19,%bl
f0104514:	77 08                	ja     f010451e <strtol+0xa1>
			dig = *s - 'a' + 10;
f0104516:	0f be c9             	movsbl %cl,%ecx
f0104519:	83 e9 57             	sub    $0x57,%ecx
f010451c:	eb 0e                	jmp    f010452c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f010451e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104521:	80 fb 19             	cmp    $0x19,%bl
f0104524:	77 14                	ja     f010453a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104526:	0f be c9             	movsbl %cl,%ecx
f0104529:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010452c:	39 f1                	cmp    %esi,%ecx
f010452e:	7d 0e                	jge    f010453e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104530:	83 c2 01             	add    $0x1,%edx
f0104533:	0f af c6             	imul   %esi,%eax
f0104536:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104538:	eb c1                	jmp    f01044fb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010453a:	89 c1                	mov    %eax,%ecx
f010453c:	eb 02                	jmp    f0104540 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010453e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104540:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104544:	74 05                	je     f010454b <strtol+0xce>
		*endptr = (char *) s;
f0104546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104549:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010454b:	89 ca                	mov    %ecx,%edx
f010454d:	f7 da                	neg    %edx
f010454f:	85 ff                	test   %edi,%edi
f0104551:	0f 45 c2             	cmovne %edx,%eax
}
f0104554:	5b                   	pop    %ebx
f0104555:	5e                   	pop    %esi
f0104556:	5f                   	pop    %edi
f0104557:	5d                   	pop    %ebp
f0104558:	c3                   	ret    
f0104559:	00 00                	add    %al,(%eax)
f010455b:	00 00                	add    %al,(%eax)
f010455d:	00 00                	add    %al,(%eax)
	...

f0104560 <__udivdi3>:
f0104560:	83 ec 1c             	sub    $0x1c,%esp
f0104563:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104567:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f010456b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010456f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104573:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104577:	8b 74 24 24          	mov    0x24(%esp),%esi
f010457b:	85 ff                	test   %edi,%edi
f010457d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104581:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104585:	89 cd                	mov    %ecx,%ebp
f0104587:	89 44 24 04          	mov    %eax,0x4(%esp)
f010458b:	75 33                	jne    f01045c0 <__udivdi3+0x60>
f010458d:	39 f1                	cmp    %esi,%ecx
f010458f:	77 57                	ja     f01045e8 <__udivdi3+0x88>
f0104591:	85 c9                	test   %ecx,%ecx
f0104593:	75 0b                	jne    f01045a0 <__udivdi3+0x40>
f0104595:	b8 01 00 00 00       	mov    $0x1,%eax
f010459a:	31 d2                	xor    %edx,%edx
f010459c:	f7 f1                	div    %ecx
f010459e:	89 c1                	mov    %eax,%ecx
f01045a0:	89 f0                	mov    %esi,%eax
f01045a2:	31 d2                	xor    %edx,%edx
f01045a4:	f7 f1                	div    %ecx
f01045a6:	89 c6                	mov    %eax,%esi
f01045a8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01045ac:	f7 f1                	div    %ecx
f01045ae:	89 f2                	mov    %esi,%edx
f01045b0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01045b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01045b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01045bc:	83 c4 1c             	add    $0x1c,%esp
f01045bf:	c3                   	ret    
f01045c0:	31 d2                	xor    %edx,%edx
f01045c2:	31 c0                	xor    %eax,%eax
f01045c4:	39 f7                	cmp    %esi,%edi
f01045c6:	77 e8                	ja     f01045b0 <__udivdi3+0x50>
f01045c8:	0f bd cf             	bsr    %edi,%ecx
f01045cb:	83 f1 1f             	xor    $0x1f,%ecx
f01045ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01045d2:	75 2c                	jne    f0104600 <__udivdi3+0xa0>
f01045d4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f01045d8:	76 04                	jbe    f01045de <__udivdi3+0x7e>
f01045da:	39 f7                	cmp    %esi,%edi
f01045dc:	73 d2                	jae    f01045b0 <__udivdi3+0x50>
f01045de:	31 d2                	xor    %edx,%edx
f01045e0:	b8 01 00 00 00       	mov    $0x1,%eax
f01045e5:	eb c9                	jmp    f01045b0 <__udivdi3+0x50>
f01045e7:	90                   	nop
f01045e8:	89 f2                	mov    %esi,%edx
f01045ea:	f7 f1                	div    %ecx
f01045ec:	31 d2                	xor    %edx,%edx
f01045ee:	8b 74 24 10          	mov    0x10(%esp),%esi
f01045f2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01045f6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01045fa:	83 c4 1c             	add    $0x1c,%esp
f01045fd:	c3                   	ret    
f01045fe:	66 90                	xchg   %ax,%ax
f0104600:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104605:	b8 20 00 00 00       	mov    $0x20,%eax
f010460a:	89 ea                	mov    %ebp,%edx
f010460c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104610:	d3 e7                	shl    %cl,%edi
f0104612:	89 c1                	mov    %eax,%ecx
f0104614:	d3 ea                	shr    %cl,%edx
f0104616:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010461b:	09 fa                	or     %edi,%edx
f010461d:	89 f7                	mov    %esi,%edi
f010461f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104623:	89 f2                	mov    %esi,%edx
f0104625:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104629:	d3 e5                	shl    %cl,%ebp
f010462b:	89 c1                	mov    %eax,%ecx
f010462d:	d3 ef                	shr    %cl,%edi
f010462f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104634:	d3 e2                	shl    %cl,%edx
f0104636:	89 c1                	mov    %eax,%ecx
f0104638:	d3 ee                	shr    %cl,%esi
f010463a:	09 d6                	or     %edx,%esi
f010463c:	89 fa                	mov    %edi,%edx
f010463e:	89 f0                	mov    %esi,%eax
f0104640:	f7 74 24 0c          	divl   0xc(%esp)
f0104644:	89 d7                	mov    %edx,%edi
f0104646:	89 c6                	mov    %eax,%esi
f0104648:	f7 e5                	mul    %ebp
f010464a:	39 d7                	cmp    %edx,%edi
f010464c:	72 22                	jb     f0104670 <__udivdi3+0x110>
f010464e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0104652:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104657:	d3 e5                	shl    %cl,%ebp
f0104659:	39 c5                	cmp    %eax,%ebp
f010465b:	73 04                	jae    f0104661 <__udivdi3+0x101>
f010465d:	39 d7                	cmp    %edx,%edi
f010465f:	74 0f                	je     f0104670 <__udivdi3+0x110>
f0104661:	89 f0                	mov    %esi,%eax
f0104663:	31 d2                	xor    %edx,%edx
f0104665:	e9 46 ff ff ff       	jmp    f01045b0 <__udivdi3+0x50>
f010466a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104670:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104673:	31 d2                	xor    %edx,%edx
f0104675:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104679:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010467d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104681:	83 c4 1c             	add    $0x1c,%esp
f0104684:	c3                   	ret    
	...

f0104690 <__umoddi3>:
f0104690:	83 ec 1c             	sub    $0x1c,%esp
f0104693:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104697:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010469b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010469f:	89 74 24 10          	mov    %esi,0x10(%esp)
f01046a3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01046a7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01046ab:	85 ed                	test   %ebp,%ebp
f01046ad:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01046b1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046b5:	89 cf                	mov    %ecx,%edi
f01046b7:	89 04 24             	mov    %eax,(%esp)
f01046ba:	89 f2                	mov    %esi,%edx
f01046bc:	75 1a                	jne    f01046d8 <__umoddi3+0x48>
f01046be:	39 f1                	cmp    %esi,%ecx
f01046c0:	76 4e                	jbe    f0104710 <__umoddi3+0x80>
f01046c2:	f7 f1                	div    %ecx
f01046c4:	89 d0                	mov    %edx,%eax
f01046c6:	31 d2                	xor    %edx,%edx
f01046c8:	8b 74 24 10          	mov    0x10(%esp),%esi
f01046cc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01046d0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01046d4:	83 c4 1c             	add    $0x1c,%esp
f01046d7:	c3                   	ret    
f01046d8:	39 f5                	cmp    %esi,%ebp
f01046da:	77 54                	ja     f0104730 <__umoddi3+0xa0>
f01046dc:	0f bd c5             	bsr    %ebp,%eax
f01046df:	83 f0 1f             	xor    $0x1f,%eax
f01046e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046e6:	75 60                	jne    f0104748 <__umoddi3+0xb8>
f01046e8:	3b 0c 24             	cmp    (%esp),%ecx
f01046eb:	0f 87 07 01 00 00    	ja     f01047f8 <__umoddi3+0x168>
f01046f1:	89 f2                	mov    %esi,%edx
f01046f3:	8b 34 24             	mov    (%esp),%esi
f01046f6:	29 ce                	sub    %ecx,%esi
f01046f8:	19 ea                	sbb    %ebp,%edx
f01046fa:	89 34 24             	mov    %esi,(%esp)
f01046fd:	8b 04 24             	mov    (%esp),%eax
f0104700:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104704:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104708:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010470c:	83 c4 1c             	add    $0x1c,%esp
f010470f:	c3                   	ret    
f0104710:	85 c9                	test   %ecx,%ecx
f0104712:	75 0b                	jne    f010471f <__umoddi3+0x8f>
f0104714:	b8 01 00 00 00       	mov    $0x1,%eax
f0104719:	31 d2                	xor    %edx,%edx
f010471b:	f7 f1                	div    %ecx
f010471d:	89 c1                	mov    %eax,%ecx
f010471f:	89 f0                	mov    %esi,%eax
f0104721:	31 d2                	xor    %edx,%edx
f0104723:	f7 f1                	div    %ecx
f0104725:	8b 04 24             	mov    (%esp),%eax
f0104728:	f7 f1                	div    %ecx
f010472a:	eb 98                	jmp    f01046c4 <__umoddi3+0x34>
f010472c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104730:	89 f2                	mov    %esi,%edx
f0104732:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104736:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010473a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010473e:	83 c4 1c             	add    $0x1c,%esp
f0104741:	c3                   	ret    
f0104742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104748:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010474d:	89 e8                	mov    %ebp,%eax
f010474f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0104754:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0104758:	89 fa                	mov    %edi,%edx
f010475a:	d3 e0                	shl    %cl,%eax
f010475c:	89 e9                	mov    %ebp,%ecx
f010475e:	d3 ea                	shr    %cl,%edx
f0104760:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104765:	09 c2                	or     %eax,%edx
f0104767:	8b 44 24 08          	mov    0x8(%esp),%eax
f010476b:	89 14 24             	mov    %edx,(%esp)
f010476e:	89 f2                	mov    %esi,%edx
f0104770:	d3 e7                	shl    %cl,%edi
f0104772:	89 e9                	mov    %ebp,%ecx
f0104774:	d3 ea                	shr    %cl,%edx
f0104776:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010477b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010477f:	d3 e6                	shl    %cl,%esi
f0104781:	89 e9                	mov    %ebp,%ecx
f0104783:	d3 e8                	shr    %cl,%eax
f0104785:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010478a:	09 f0                	or     %esi,%eax
f010478c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104790:	f7 34 24             	divl   (%esp)
f0104793:	d3 e6                	shl    %cl,%esi
f0104795:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104799:	89 d6                	mov    %edx,%esi
f010479b:	f7 e7                	mul    %edi
f010479d:	39 d6                	cmp    %edx,%esi
f010479f:	89 c1                	mov    %eax,%ecx
f01047a1:	89 d7                	mov    %edx,%edi
f01047a3:	72 3f                	jb     f01047e4 <__umoddi3+0x154>
f01047a5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01047a9:	72 35                	jb     f01047e0 <__umoddi3+0x150>
f01047ab:	8b 44 24 08          	mov    0x8(%esp),%eax
f01047af:	29 c8                	sub    %ecx,%eax
f01047b1:	19 fe                	sbb    %edi,%esi
f01047b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01047b8:	89 f2                	mov    %esi,%edx
f01047ba:	d3 e8                	shr    %cl,%eax
f01047bc:	89 e9                	mov    %ebp,%ecx
f01047be:	d3 e2                	shl    %cl,%edx
f01047c0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01047c5:	09 d0                	or     %edx,%eax
f01047c7:	89 f2                	mov    %esi,%edx
f01047c9:	d3 ea                	shr    %cl,%edx
f01047cb:	8b 74 24 10          	mov    0x10(%esp),%esi
f01047cf:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01047d3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01047d7:	83 c4 1c             	add    $0x1c,%esp
f01047da:	c3                   	ret    
f01047db:	90                   	nop
f01047dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01047e0:	39 d6                	cmp    %edx,%esi
f01047e2:	75 c7                	jne    f01047ab <__umoddi3+0x11b>
f01047e4:	89 d7                	mov    %edx,%edi
f01047e6:	89 c1                	mov    %eax,%ecx
f01047e8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f01047ec:	1b 3c 24             	sbb    (%esp),%edi
f01047ef:	eb ba                	jmp    f01047ab <__umoddi3+0x11b>
f01047f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01047f8:	39 f5                	cmp    %esi,%ebp
f01047fa:	0f 82 f1 fe ff ff    	jb     f01046f1 <__umoddi3+0x61>
f0104800:	e9 f8 fe ff ff       	jmp    f01046fd <__umoddi3+0x6d>
