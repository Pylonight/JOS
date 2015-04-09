
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
f0100015:	0f 01 15 18 70 11 00 	lgdtl  0x117018

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
f0100033:	bc bc 6f 11 f0       	mov    $0xf0116fbc,%esp

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
f0100046:	b8 10 2a 17 f0       	mov    $0xf0172a10,%eax
f010004b:	2d e5 1a 17 f0       	sub    $0xf0171ae5,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 e5 1a 17 f0 	movl   $0xf0171ae5,(%esp)
f0100063:	e8 fe 3a 00 00       	call   f0103b66 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 44 06 00 00       	call   f01006b1 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 20 40 10 f0 	movl   $0xf0104020,(%esp)
f010007c:	e8 b5 2b 00 00       	call   f0102c36 <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100081:	e8 d2 0a 00 00       	call   f0100b58 <i386_detect_memory>
	i386_vm_init();
f0100086:	e8 78 10 00 00       	call   f0101103 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 ea 27 00 00       	call   f010287f <env_init>
	idt_init();
f0100095:	e8 b6 2b 00 00       	call   f0102c50 <idt_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE);
#else
	// Touch all you want.
	ENV_CREATE(user_hello);
f010009a:	c7 44 24 04 96 78 00 	movl   $0x7896,0x4(%esp)
f01000a1:	00 
f01000a2:	c7 04 24 78 73 11 f0 	movl   $0xf0117378,(%esp)
f01000a9:	e8 ee 28 00 00       	call   f010299c <env_create>
#endif // TEST*


	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000ae:	a1 60 1d 17 f0       	mov    0xf0171d60,%eax
f01000b3:	89 04 24             	mov    %eax,(%esp)
f01000b6:	e8 e9 2a 00 00       	call   f0102ba4 <env_run>

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
f01000c1:	83 3d 00 1b 17 f0 00 	cmpl   $0x0,0xf0171b00
f01000c8:	75 40                	jne    f010010a <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f01000ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01000cd:	a3 00 1b 17 f0       	mov    %eax,0xf0171b00

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000e0:	c7 04 24 3b 40 10 f0 	movl   $0xf010403b,(%esp)
f01000e7:	e8 4a 2b 00 00       	call   f0102c36 <cprintf>
	vcprintf(fmt, ap);
f01000ec:	8d 45 14             	lea    0x14(%ebp),%eax
f01000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000f3:	8b 45 10             	mov    0x10(%ebp),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 05 2b 00 00       	call   f0102c03 <vcprintf>
	cprintf("\n");
f01000fe:	c7 04 24 6d 4e 10 f0 	movl   $0xf0104e6d,(%esp)
f0100105:	e8 2c 2b 00 00       	call   f0102c36 <cprintf>
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
f010012c:	c7 04 24 53 40 10 f0 	movl   $0xf0104053,(%esp)
f0100133:	e8 fe 2a 00 00       	call   f0102c36 <cprintf>
	vcprintf(fmt, ap);
f0100138:	8d 45 14             	lea    0x14(%ebp),%eax
f010013b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010013f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100142:	89 04 24             	mov    %eax,(%esp)
f0100145:	e8 b9 2a 00 00       	call   f0102c03 <vcprintf>
	cprintf("\n");
f010014a:	c7 04 24 6d 4e 10 f0 	movl   $0xf0104e6d,(%esp)
f0100151:	e8 e0 2a 00 00       	call   f0102c36 <cprintf>
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
f0100197:	83 0d 30 1b 17 f0 40 	orl    $0x40,0xf0171b30
		return 0;
f010019e:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001a3:	e9 c4 00 00 00       	jmp    f010026c <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01001a8:	84 c0                	test   %al,%al
f01001aa:	79 37                	jns    f01001e3 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ac:	8b 0d 30 1b 17 f0    	mov    0xf0171b30,%ecx
f01001b2:	89 cb                	mov    %ecx,%ebx
f01001b4:	83 e3 40             	and    $0x40,%ebx
f01001b7:	83 e0 7f             	and    $0x7f,%eax
f01001ba:	85 db                	test   %ebx,%ebx
f01001bc:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001bf:	0f b6 d2             	movzbl %dl,%edx
f01001c2:	0f b6 82 80 42 10 f0 	movzbl -0xfefbd80(%edx),%eax
f01001c9:	83 c8 40             	or     $0x40,%eax
f01001cc:	0f b6 c0             	movzbl %al,%eax
f01001cf:	f7 d0                	not    %eax
f01001d1:	21 c1                	and    %eax,%ecx
f01001d3:	89 0d 30 1b 17 f0    	mov    %ecx,0xf0171b30
		return 0;
f01001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001de:	e9 89 00 00 00       	jmp    f010026c <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01001e3:	8b 0d 30 1b 17 f0    	mov    0xf0171b30,%ecx
f01001e9:	f6 c1 40             	test   $0x40,%cl
f01001ec:	74 0e                	je     f01001fc <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ee:	89 c2                	mov    %eax,%edx
f01001f0:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01001f3:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f6:	89 0d 30 1b 17 f0    	mov    %ecx,0xf0171b30
	}

	shift |= shiftcode[data];
f01001fc:	0f b6 d2             	movzbl %dl,%edx
f01001ff:	0f b6 82 80 42 10 f0 	movzbl -0xfefbd80(%edx),%eax
f0100206:	0b 05 30 1b 17 f0    	or     0xf0171b30,%eax
	shift ^= togglecode[data];
f010020c:	0f b6 8a 80 43 10 f0 	movzbl -0xfefbc80(%edx),%ecx
f0100213:	31 c8                	xor    %ecx,%eax
f0100215:	a3 30 1b 17 f0       	mov    %eax,0xf0171b30

	c = charcode[shift & (CTL | SHIFT)][data];
f010021a:	89 c1                	mov    %eax,%ecx
f010021c:	83 e1 03             	and    $0x3,%ecx
f010021f:	8b 0c 8d 80 44 10 f0 	mov    -0xfefbb80(,%ecx,4),%ecx
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
f0100255:	c7 04 24 6d 40 10 f0 	movl   $0xf010406d,(%esp)
f010025c:	e8 d5 29 00 00       	call   f0102c36 <cprintf>
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
f01002c5:	a3 20 1b 17 f0       	mov    %eax,0xf0171b20
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
f01002ff:	c7 05 24 1b 17 f0 b4 	movl   $0x3b4,0xf0171b24
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
f0100317:	c7 05 24 1b 17 f0 d4 	movl   $0x3d4,0xf0171b24
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
f0100326:	8b 0d 24 1b 17 f0    	mov    0xf0171b24,%ecx
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
f010034b:	89 35 28 1b 17 f0    	mov    %esi,0xf0171b28
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100351:	0f b6 d8             	movzbl %al,%ebx
f0100354:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100356:	66 89 3d 2c 1b 17 f0 	mov    %di,0xf0171b2c
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
f010037f:	8b 15 44 1d 17 f0    	mov    0xf0171d44,%edx
f0100385:	88 82 40 1b 17 f0    	mov    %al,-0xfe8e4c0(%edx)
f010038b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010038e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100393:	ba 00 00 00 00       	mov    $0x0,%edx
f0100398:	0f 44 c2             	cmove  %edx,%eax
f010039b:	a3 44 1d 17 f0       	mov    %eax,0xf0171d44
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
f01003c7:	83 3d 20 1b 17 f0 00 	cmpl   $0x0,0xf0171b20
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
f01003ee:	8b 15 40 1d 17 f0    	mov    0xf0171d40,%edx
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
f01003f9:	3b 15 44 1d 17 f0    	cmp    0xf0171d44,%edx
f01003ff:	74 1e                	je     f010041f <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100401:	0f b6 82 40 1b 17 f0 	movzbl -0xfe8e4c0(%edx),%eax
f0100408:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f010040b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100411:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100416:	0f 44 d1             	cmove  %ecx,%edx
f0100419:	89 15 40 1d 17 f0    	mov    %edx,0xf0171d40
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
f01004aa:	ff 24 95 a0 40 10 f0 	jmp    *-0xfefbf60(,%edx,4)
	case '\b':
		if (crt_pos > 0) {
f01004b1:	0f b7 15 2c 1b 17 f0 	movzwl 0xf0171b2c,%edx
f01004b8:	66 85 d2             	test   %dx,%dx
f01004bb:	0f 84 bb 01 00 00    	je     f010067c <cga_putc+0x1fe>
			crt_pos--;
f01004c1:	83 ea 01             	sub    $0x1,%edx
f01004c4:	66 89 15 2c 1b 17 f0 	mov    %dx,0xf0171b2c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004cb:	0f b7 d2             	movzwl %dx,%edx
f01004ce:	b0 00                	mov    $0x0,%al
f01004d0:	89 c1                	mov    %eax,%ecx
f01004d2:	83 c9 20             	or     $0x20,%ecx
f01004d5:	a1 28 1b 17 f0       	mov    0xf0171b28,%eax
f01004da:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01004de:	e9 4c 01 00 00       	jmp    f010062f <cga_putc+0x1b1>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e3:	66 83 05 2c 1b 17 f0 	addw   $0x50,0xf0171b2c
f01004ea:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004eb:	0f b7 05 2c 1b 17 f0 	movzwl 0xf0171b2c,%eax
f01004f2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f8:	c1 e8 16             	shr    $0x16,%eax
f01004fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fe:	c1 e0 04             	shl    $0x4,%eax
f0100501:	66 a3 2c 1b 17 f0    	mov    %ax,0xf0171b2c
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
f010054d:	0f b7 15 2c 1b 17 f0 	movzwl 0xf0171b2c,%edx
f0100554:	0f b7 da             	movzwl %dx,%ebx
f0100557:	80 e4 f0             	and    $0xf0,%ah
f010055a:	80 cc 0c             	or     $0xc,%ah
f010055d:	8b 0d 28 1b 17 f0    	mov    0xf0171b28,%ecx
f0100563:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100567:	83 c2 01             	add    $0x1,%edx
f010056a:	66 89 15 2c 1b 17 f0 	mov    %dx,0xf0171b2c
		break;
f0100571:	e9 b9 00 00 00       	jmp    f010062f <cga_putc+0x1b1>
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0900;
f0100576:	0f b7 15 2c 1b 17 f0 	movzwl 0xf0171b2c,%edx
f010057d:	0f b7 da             	movzwl %dx,%ebx
f0100580:	80 e4 f0             	and    $0xf0,%ah
f0100583:	80 cc 09             	or     $0x9,%ah
f0100586:	8b 0d 28 1b 17 f0    	mov    0xf0171b28,%ecx
f010058c:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100590:	83 c2 01             	add    $0x1,%edx
f0100593:	66 89 15 2c 1b 17 f0 	mov    %dx,0xf0171b2c
		break;
f010059a:	e9 90 00 00 00       	jmp    f010062f <cga_putc+0x1b1>
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0100;
f010059f:	0f b7 15 2c 1b 17 f0 	movzwl 0xf0171b2c,%edx
f01005a6:	0f b7 da             	movzwl %dx,%ebx
f01005a9:	80 e4 f0             	and    $0xf0,%ah
f01005ac:	80 cc 01             	or     $0x1,%ah
f01005af:	8b 0d 28 1b 17 f0    	mov    0xf0171b28,%ecx
f01005b5:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005b9:	83 c2 01             	add    $0x1,%edx
f01005bc:	66 89 15 2c 1b 17 f0 	mov    %dx,0xf0171b2c
		break;
f01005c3:	eb 6a                	jmp    f010062f <cga_putc+0x1b1>
	case '%':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0e00;
f01005c5:	0f b7 15 2c 1b 17 f0 	movzwl 0xf0171b2c,%edx
f01005cc:	0f b7 da             	movzwl %dx,%ebx
f01005cf:	80 e4 f0             	and    $0xf0,%ah
f01005d2:	80 cc 0e             	or     $0xe,%ah
f01005d5:	8b 0d 28 1b 17 f0    	mov    0xf0171b28,%ecx
f01005db:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005df:	83 c2 01             	add    $0x1,%edx
f01005e2:	66 89 15 2c 1b 17 f0 	mov    %dx,0xf0171b2c
		break;
f01005e9:	eb 44                	jmp    f010062f <cga_putc+0x1b1>
	case '&':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0d00;
f01005eb:	0f b7 15 2c 1b 17 f0 	movzwl 0xf0171b2c,%edx
f01005f2:	0f b7 da             	movzwl %dx,%ebx
f01005f5:	80 e4 f0             	and    $0xf0,%ah
f01005f8:	80 cc 0d             	or     $0xd,%ah
f01005fb:	8b 0d 28 1b 17 f0    	mov    0xf0171b28,%ecx
f0100601:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100605:	83 c2 01             	add    $0x1,%edx
f0100608:	66 89 15 2c 1b 17 f0 	mov    %dx,0xf0171b2c
		break;
f010060f:	eb 1e                	jmp    f010062f <cga_putc+0x1b1>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100611:	0f b7 15 2c 1b 17 f0 	movzwl 0xf0171b2c,%edx
f0100618:	0f b7 da             	movzwl %dx,%ebx
f010061b:	8b 0d 28 1b 17 f0    	mov    0xf0171b28,%ecx
f0100621:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100625:	83 c2 01             	add    $0x1,%edx
f0100628:	66 89 15 2c 1b 17 f0 	mov    %dx,0xf0171b2c
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010062f:	66 81 3d 2c 1b 17 f0 	cmpw   $0x7cf,0xf0171b2c
f0100636:	cf 07 
f0100638:	76 42                	jbe    f010067c <cga_putc+0x1fe>
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010063a:	a1 28 1b 17 f0       	mov    0xf0171b28,%eax
f010063f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100646:	00 
f0100647:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010064d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100651:	89 04 24             	mov    %eax,(%esp)
f0100654:	e8 31 35 00 00       	call   f0103b8a <memmove>
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0c00 | ' ';
f0100659:	8b 15 28 1b 17 f0    	mov    0xf0171b28,%edx
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
f0100674:	66 83 2d 2c 1b 17 f0 	subw   $0x50,0xf0171b2c
f010067b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010067c:	8b 0d 24 1b 17 f0    	mov    0xf0171b24,%ecx
f0100682:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100687:	89 ca                	mov    %ecx,%edx
f0100689:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010068a:	0f b7 35 2c 1b 17 f0 	movzwl 0xf0171b2c,%esi
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
f01006c1:	83 3d 20 1b 17 f0 00 	cmpl   $0x0,0xf0171b20
f01006c8:	75 0c                	jne    f01006d6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01006ca:	c7 04 24 79 40 10 f0 	movl   $0xf0104079,(%esp)
f01006d1:	e8 60 25 00 00       	call   f0102c36 <cprintf>
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
f0100716:	c7 04 24 90 44 10 f0 	movl   $0xf0104490,(%esp)
f010071d:	e8 14 25 00 00       	call   f0102c36 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100722:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100729:	00 
f010072a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100731:	f0 
f0100732:	c7 04 24 5c 45 10 f0 	movl   $0xf010455c,(%esp)
f0100739:	e8 f8 24 00 00       	call   f0102c36 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010073e:	c7 44 24 08 05 40 10 	movl   $0x104005,0x8(%esp)
f0100745:	00 
f0100746:	c7 44 24 04 05 40 10 	movl   $0xf0104005,0x4(%esp)
f010074d:	f0 
f010074e:	c7 04 24 80 45 10 f0 	movl   $0xf0104580,(%esp)
f0100755:	e8 dc 24 00 00       	call   f0102c36 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010075a:	c7 44 24 08 e5 1a 17 	movl   $0x171ae5,0x8(%esp)
f0100761:	00 
f0100762:	c7 44 24 04 e5 1a 17 	movl   $0xf0171ae5,0x4(%esp)
f0100769:	f0 
f010076a:	c7 04 24 a4 45 10 f0 	movl   $0xf01045a4,(%esp)
f0100771:	e8 c0 24 00 00       	call   f0102c36 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100776:	c7 44 24 08 10 2a 17 	movl   $0x172a10,0x8(%esp)
f010077d:	00 
f010077e:	c7 44 24 04 10 2a 17 	movl   $0xf0172a10,0x4(%esp)
f0100785:	f0 
f0100786:	c7 04 24 c8 45 10 f0 	movl   $0xf01045c8,(%esp)
f010078d:	e8 a4 24 00 00       	call   f0102c36 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f0100792:	b8 0f 2e 17 f0       	mov    $0xf0172e0f,%eax
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
f01007ae:	c7 04 24 ec 45 10 f0 	movl   $0xf01045ec,(%esp)
f01007b5:	e8 7c 24 00 00       	call   f0102c36 <cprintf>
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
f01007cd:	8b 83 e4 46 10 f0    	mov    -0xfefb91c(%ebx),%eax
f01007d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d7:	8b 83 e0 46 10 f0    	mov    -0xfefb920(%ebx),%eax
f01007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007e1:	c7 04 24 a9 44 10 f0 	movl   $0xf01044a9,(%esp)
f01007e8:	e8 49 24 00 00       	call   f0102c36 <cprintf>
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
f0100809:	c7 04 24 18 46 10 f0 	movl   $0xf0104618,(%esp)
f0100810:	e8 21 24 00 00       	call   f0102c36 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100815:	c7 04 24 3c 46 10 f0 	movl   $0xf010463c,(%esp)
f010081c:	e8 15 24 00 00       	call   f0102c36 <cprintf>

	if (tf != NULL)
f0100821:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100825:	74 0b                	je     f0100832 <monitor+0x32>
		print_trapframe(tf);
f0100827:	8b 45 08             	mov    0x8(%ebp),%eax
f010082a:	89 04 24             	mov    %eax,(%esp)
f010082d:	e8 21 25 00 00       	call   f0102d53 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100832:	c7 04 24 b2 44 10 f0 	movl   $0xf01044b2,(%esp)
f0100839:	e8 b2 30 00 00       	call   f01038f0 <readline>
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
f0100866:	c7 04 24 b6 44 10 f0 	movl   $0xf01044b6,(%esp)
f010086d:	e8 99 32 00 00       	call   f0103b0b <strchr>
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
f010088a:	c7 04 24 bb 44 10 f0 	movl   $0xf01044bb,(%esp)
f0100891:	e8 a0 23 00 00       	call   f0102c36 <cprintf>
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
f01008b9:	c7 04 24 b6 44 10 f0 	movl   $0xf01044b6,(%esp)
f01008c0:	e8 46 32 00 00       	call   f0103b0b <strchr>
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
f01008db:	bb e0 46 10 f0       	mov    $0xf01046e0,%ebx
f01008e0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e5:	8b 03                	mov    (%ebx),%eax
f01008e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008eb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ee:	89 04 24             	mov    %eax,(%esp)
f01008f1:	e8 9a 31 00 00       	call   f0103a90 <strcmp>
f01008f6:	85 c0                	test   %eax,%eax
f01008f8:	75 24                	jne    f010091e <monitor+0x11e>
			return commands[i].func(argc, argv, tf);
f01008fa:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008fd:	8b 55 08             	mov    0x8(%ebp),%edx
f0100900:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100904:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100907:	89 54 24 04          	mov    %edx,0x4(%esp)
f010090b:	89 34 24             	mov    %esi,(%esp)
f010090e:	ff 14 85 e8 46 10 f0 	call   *-0xfefb918(,%eax,4)
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
f0100930:	c7 04 24 d8 44 10 f0 	movl   $0xf01044d8,(%esp)
f0100937:	e8 fa 22 00 00       	call   f0102c36 <cprintf>
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
f010095a:	c7 04 24 ee 44 10 f0 	movl   $0xf01044ee,(%esp)
f0100961:	e8 d0 22 00 00       	call   f0102c36 <cprintf>
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
f0100988:	e8 35 27 00 00       	call   f01030c2 <debuginfo_eip>
f010098d:	85 c0                	test   %eax,%eax
f010098f:	0f 88 a5 00 00 00    	js     f0100a3a <mon_backtrace+0xe9>
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
f0100995:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100998:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010099f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a3:	c7 04 24 4b 40 10 f0 	movl   $0xf010404b,(%esp)
f01009aa:	e8 87 22 00 00       	call   f0102c36 <cprintf>
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f01009af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01009b3:	7e 24                	jle    f01009d9 <mon_backtrace+0x88>
f01009b5:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
f01009ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009bd:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f01009c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009c5:	c7 04 24 00 45 10 f0 	movl   $0xf0104500,(%esp)
f01009cc:	e8 65 22 00 00       	call   f0102c36 <cprintf>
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
f01009e7:	c7 04 24 03 45 10 f0 	movl   $0xf0104503,(%esp)
f01009ee:	e8 43 22 00 00       	call   f0102c36 <cprintf>
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
f0100a1a:	c7 04 24 64 46 10 f0 	movl   $0xf0104664,(%esp)
f0100a21:	e8 10 22 00 00       	call   f0102c36 <cprintf>
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
f0100a3a:	c7 04 24 0c 45 10 f0 	movl   $0xf010450c,(%esp)
f0100a41:	e8 f0 21 00 00       	call   f0102c36 <cprintf>
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
f0100a70:	83 3d 54 1d 17 f0 00 	cmpl   $0x0,0xf0171d54

	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	boot_freemem = ROUNDUP(boot_freemem, align);
f0100a77:	b8 10 2a 17 f0       	mov    $0xf0172a10,%eax
f0100a7c:	0f 45 05 54 1d 17 f0 	cmovne 0xf0171d54,%eax
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
f0100aa3:	89 35 54 1d 17 f0    	mov    %esi,0xf0171d54
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
f0100ad8:	3b 05 00 2a 17 f0    	cmp    0xf0172a00,%eax
f0100ade:	72 20                	jb     f0100b00 <check_va2pa+0x4b>
f0100ae0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100ae4:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f0100aeb:	f0 
f0100aec:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0100af3:	00 
f0100af4:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0100b37:	e8 8c 20 00 00       	call   f0102bc8 <mc146818_read>
f0100b3c:	89 c6                	mov    %eax,%esi
f0100b3e:	83 c3 01             	add    $0x1,%ebx
f0100b41:	89 1c 24             	mov    %ebx,(%esp)
f0100b44:	e8 7f 20 00 00       	call   f0102bc8 <mc146818_read>
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
f0100b70:	a3 48 1d 17 f0       	mov    %eax,0xf0171d48
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0100b75:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b7a:	e8 a7 ff ff ff       	call   f0100b26 <nvram_read>
f0100b7f:	c1 e0 0a             	shl    $0xa,%eax
f0100b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b87:	a3 4c 1d 17 f0       	mov    %eax,0xf0171d4c

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0100b8c:	85 c0                	test   %eax,%eax
f0100b8e:	74 0c                	je     f0100b9c <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0100b90:	05 00 00 10 00       	add    $0x100000,%eax
f0100b95:	a3 50 1d 17 f0       	mov    %eax,0xf0171d50
f0100b9a:	eb 0a                	jmp    f0100ba6 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0100b9c:	a1 48 1d 17 f0       	mov    0xf0171d48,%eax
f0100ba1:	a3 50 1d 17 f0       	mov    %eax,0xf0171d50

	npage = maxpa / PGSIZE;
f0100ba6:	a1 50 1d 17 f0       	mov    0xf0171d50,%eax
f0100bab:	89 c2                	mov    %eax,%edx
f0100bad:	c1 ea 0c             	shr    $0xc,%edx
f0100bb0:	89 15 00 2a 17 f0    	mov    %edx,0xf0172a00

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100bb6:	c1 e8 0a             	shr    $0xa,%eax
f0100bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bbd:	c7 04 24 28 47 10 f0 	movl   $0xf0104728,(%esp)
f0100bc4:	e8 6d 20 00 00       	call   f0102c36 <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100bc9:	a1 4c 1d 17 f0       	mov    0xf0171d4c,%eax
f0100bce:	c1 e8 0a             	shr    $0xa,%eax
f0100bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bd5:	a1 48 1d 17 f0       	mov    0xf0171d48,%eax
f0100bda:	c1 e8 0a             	shr    $0xa,%eax
f0100bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100be1:	c7 04 24 bd 4c 10 f0 	movl   $0xf0104cbd,(%esp)
f0100be8:	e8 49 20 00 00       	call   f0102c36 <cprintf>
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
f0100bf7:	c7 05 58 1d 17 f0 00 	movl   $0x0,0xf0171d58
f0100bfe:	00 00 00 
	for (i = 0; i < npage; i++) {
f0100c01:	83 3d 00 2a 17 f0 00 	cmpl   $0x0,0xf0172a00
f0100c08:	74 5f                	je     f0100c69 <page_init+0x7a>
f0100c0a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c0f:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f0100c14:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0100c17:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
f0100c1e:	8b 1d 0c 2a 17 f0    	mov    0xf0172a0c,%ebx
f0100c24:	66 c7 44 13 08 00 00 	movw   $0x0,0x8(%ebx,%edx,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100c2b:	8b 0d 58 1d 17 f0    	mov    0xf0171d58,%ecx
f0100c31:	89 0c b3             	mov    %ecx,(%ebx,%esi,4)
f0100c34:	85 c9                	test   %ecx,%ecx
f0100c36:	74 11                	je     f0100c49 <page_init+0x5a>
f0100c38:	8b 1d 0c 2a 17 f0    	mov    0xf0172a0c,%ebx
f0100c3e:	01 d3                	add    %edx,%ebx
f0100c40:	8b 0d 58 1d 17 f0    	mov    0xf0171d58,%ecx
f0100c46:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100c49:	03 15 0c 2a 17 f0    	add    0xf0172a0c,%edx
f0100c4f:	89 15 58 1d 17 f0    	mov    %edx,0xf0171d58
f0100c55:	c7 42 04 58 1d 17 f0 	movl   $0xf0171d58,0x4(%edx)
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0100c5c:	83 c0 01             	add    $0x1,%eax
f0100c5f:	89 c2                	mov    %eax,%edx
f0100c61:	3b 05 00 2a 17 f0    	cmp    0xf0172a00,%eax
f0100c67:	72 ab                	jb     f0100c14 <page_init+0x25>
	// --pgstart;	// protect IOPHYSMEM
	// pgend->pp_link = pgstart;

	// the second method, slow
	// but can edit the .ref to 1
	pages[0].pp_ref = 1;
f0100c69:	a1 0c 2a 17 f0       	mov    0xf0172a0c,%eax
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
f0100c87:	8b 1d 54 1d 17 f0    	mov    0xf0171d54,%ebx
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
f0100cbc:	03 05 0c 2a 17 f0    	add    0xf0172a0c,%eax
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
f0100ceb:	c7 44 24 08 4c 47 10 	movl   $0xf010474c,0x8(%esp)
f0100cf2:	f0 
f0100cf3:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
f0100cfa:	00 
f0100cfb:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0100d17:	a1 58 1d 17 f0       	mov    0xf0171d58,%eax
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
f0100d4c:	e8 15 2e 00 00       	call   f0103b66 <memset>
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
f0100d6f:	c7 44 24 08 70 47 10 	movl   $0xf0104770,0x8(%esp)
f0100d76:	f0 
f0100d77:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
f0100d7e:	00 
f0100d7f:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0100d86:	e8 30 f3 ff ff       	call   f01000bb <_panic>
	}
	else
	{
		LIST_INSERT_HEAD(&page_free_list, pp, pp_link);
f0100d8b:	8b 15 58 1d 17 f0    	mov    0xf0171d58,%edx
f0100d91:	89 10                	mov    %edx,(%eax)
f0100d93:	85 d2                	test   %edx,%edx
f0100d95:	74 09                	je     f0100da0 <page_free+0x41>
f0100d97:	8b 15 58 1d 17 f0    	mov    0xf0171d58,%edx
f0100d9d:	89 42 04             	mov    %eax,0x4(%edx)
f0100da0:	a3 58 1d 17 f0       	mov    %eax,0xf0171d58
f0100da5:	c7 40 04 58 1d 17 f0 	movl   $0xf0171d58,0x4(%eax)
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
f0100df7:	3b 15 00 2a 17 f0    	cmp    0xf0172a00,%edx
f0100dfd:	72 20                	jb     f0100e1f <pgdir_walk+0x4e>
f0100dff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e03:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f0100e0a:	f0 
f0100e0b:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
f0100e12:	00 
f0100e13:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0100e5a:	2b 05 0c 2a 17 f0    	sub    0xf0172a0c,%eax
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
f0100e71:	3b 15 00 2a 17 f0    	cmp    0xf0172a00,%edx
f0100e77:	72 20                	jb     f0100e99 <pgdir_walk+0xc8>
f0100e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e7d:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0100e8c:	00 
f0100e8d:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0100e94:	e8 22 f2 ff ff       	call   f01000bb <_panic>
f0100e99:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ea0:	00 
f0100ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ea8:	00 
f0100ea9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100eae:	89 04 24             	mov    %eax,(%esp)
f0100eb1:	e8 b0 2c 00 00       	call   f0103b66 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100eb9:	2b 05 0c 2a 17 f0    	sub    0xf0172a0c,%eax
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
f0100eda:	3b 15 00 2a 17 f0    	cmp    0xf0172a00,%edx
f0100ee0:	72 20                	jb     f0100f02 <pgdir_walk+0x131>
f0100ee2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee6:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f0100eed:	f0 
f0100eee:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100ef5:	00 
f0100ef6:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0100f6e:	c7 44 24 08 98 47 10 	movl   $0xf0104798,0x8(%esp)
f0100f75:	f0 
f0100f76:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100f7d:	00 
f0100f7e:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0100fda:	3b 05 00 2a 17 f0    	cmp    0xf0172a00,%eax
f0100fe0:	72 1c                	jb     f0100ffe <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0100fe2:	c7 44 24 08 c8 47 10 	movl   $0xf01047c8,0x8(%esp)
f0100fe9:	f0 
f0100fea:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0100ff1:	00 
f0100ff2:	c7 04 24 d9 4c 10 f0 	movl   $0xf0104cd9,(%esp)
f0100ff9:	e8 bd f0 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0100ffe:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101001:	c1 e0 02             	shl    $0x2,%eax
f0101004:	03 05 0c 2a 17 f0    	add    0xf0172a0c,%eax
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
f01010d2:	2b 35 0c 2a 17 f0    	sub    0xf0172a0c,%esi
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
f0101130:	e8 31 2a 00 00       	call   f0103b66 <memset>
	boot_pgdir = pgdir;
f0101135:	89 1d 08 2a 17 f0    	mov    %ebx,0xf0172a08
	boot_cr3 = PADDR(pgdir);
f010113b:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101141:	77 20                	ja     f0101163 <i386_vm_init+0x60>
f0101143:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101147:	c7 44 24 08 4c 47 10 	movl   $0xf010474c,0x8(%esp)
f010114e:	f0 
f010114f:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
f0101156:	00 
f0101157:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f010115e:	e8 58 ef ff ff       	call   f01000bb <_panic>
f0101163:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0101169:	a3 04 2a 17 f0       	mov    %eax,0xf0172a04
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
f0101182:	a1 00 2a 17 f0       	mov    0xf0172a00,%eax
f0101187:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010118a:	c1 e0 02             	shl    $0x2,%eax
f010118d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101192:	e8 c9 f8 ff ff       	call   f0100a60 <boot_alloc>
f0101197:	a3 0c 2a 17 f0       	mov    %eax,0xf0172a0c

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV*sizeof(struct Env), PGSIZE);
f010119c:	ba 00 10 00 00       	mov    $0x1000,%edx
f01011a1:	b8 00 90 01 00       	mov    $0x19000,%eax
f01011a6:	e8 b5 f8 ff ff       	call   f0100a60 <boot_alloc>
f01011ab:	a3 60 1d 17 f0       	mov    %eax,0xf0171d60
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
f01011b5:	a1 58 1d 17 f0       	mov    0xf0171d58,%eax
f01011ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011bd:	85 c0                	test   %eax,%eax
f01011bf:	0f 84 89 00 00 00    	je     f010124e <i386_vm_init+0x14b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01011c5:	2b 05 0c 2a 17 f0    	sub    0xf0172a0c,%eax
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
f01011dc:	3b 15 00 2a 17 f0    	cmp    0xf0172a00,%edx
f01011e2:	72 41                	jb     f0101225 <i386_vm_init+0x122>
f01011e4:	eb 1f                	jmp    f0101205 <i386_vm_init+0x102>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01011e6:	2b 05 0c 2a 17 f0    	sub    0xf0172a0c,%eax
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
f01011fd:	3b 15 00 2a 17 f0    	cmp    0xf0172a00,%edx
f0101203:	72 20                	jb     f0101225 <i386_vm_init+0x122>
f0101205:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101209:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f0101210:	f0 
f0101211:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101218:	00 
f0101219:	c7 04 24 d9 4c 10 f0 	movl   $0xf0104cd9,(%esp)
f0101220:	e8 96 ee ff ff       	call   f01000bb <_panic>
		memset(page2kva(pp0), 0x97, 128);
f0101225:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010122c:	00 
f010122d:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101234:	00 
f0101235:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010123a:	89 04 24             	mov    %eax,(%esp)
f010123d:	e8 24 29 00 00       	call   f0103b66 <memset>
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
f0101272:	c7 44 24 0c e7 4c 10 	movl   $0xf0104ce7,0xc(%esp)
f0101279:	f0 
f010127a:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101281:	f0 
f0101282:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f0101289:	00 
f010128a:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101291:	e8 25 ee ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f0101296:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101299:	89 04 24             	mov    %eax,(%esp)
f010129c:	e8 6d fa ff ff       	call   f0100d0e <page_alloc>
f01012a1:	85 c0                	test   %eax,%eax
f01012a3:	74 24                	je     f01012c9 <i386_vm_init+0x1c6>
f01012a5:	c7 44 24 0c 12 4d 10 	movl   $0xf0104d12,0xc(%esp)
f01012ac:	f0 
f01012ad:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01012b4:	f0 
f01012b5:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f01012bc:	00 
f01012bd:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01012c4:	e8 f2 ed ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f01012c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01012cc:	89 04 24             	mov    %eax,(%esp)
f01012cf:	e8 3a fa ff ff       	call   f0100d0e <page_alloc>
f01012d4:	85 c0                	test   %eax,%eax
f01012d6:	74 24                	je     f01012fc <i386_vm_init+0x1f9>
f01012d8:	c7 44 24 0c 28 4d 10 	movl   $0xf0104d28,0xc(%esp)
f01012df:	f0 
f01012e0:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01012e7:	f0 
f01012e8:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f01012ef:	00 
f01012f0:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01012f7:	e8 bf ed ff ff       	call   f01000bb <_panic>

	assert(pp0);
f01012fc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012ff:	85 c9                	test   %ecx,%ecx
f0101301:	75 24                	jne    f0101327 <i386_vm_init+0x224>
f0101303:	c7 44 24 0c 4c 4d 10 	movl   $0xf0104d4c,0xc(%esp)
f010130a:	f0 
f010130b:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101312:	f0 
f0101313:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f010131a:	00 
f010131b:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101322:	e8 94 ed ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f0101327:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010132a:	85 d2                	test   %edx,%edx
f010132c:	74 04                	je     f0101332 <i386_vm_init+0x22f>
f010132e:	39 d1                	cmp    %edx,%ecx
f0101330:	75 24                	jne    f0101356 <i386_vm_init+0x253>
f0101332:	c7 44 24 0c 3e 4d 10 	movl   $0xf0104d3e,0xc(%esp)
f0101339:	f0 
f010133a:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101341:	f0 
f0101342:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0101349:	00 
f010134a:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101351:	e8 65 ed ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101356:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101359:	85 c0                	test   %eax,%eax
f010135b:	74 08                	je     f0101365 <i386_vm_init+0x262>
f010135d:	39 c2                	cmp    %eax,%edx
f010135f:	74 04                	je     f0101365 <i386_vm_init+0x262>
f0101361:	39 c1                	cmp    %eax,%ecx
f0101363:	75 24                	jne    f0101389 <i386_vm_init+0x286>
f0101365:	c7 44 24 0c e8 47 10 	movl   $0xf01047e8,0xc(%esp)
f010136c:	f0 
f010136d:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101374:	f0 
f0101375:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f010137c:	00 
f010137d:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101384:	e8 32 ed ff ff       	call   f01000bb <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101389:	8b 3d 0c 2a 17 f0    	mov    0xf0172a0c,%edi
        assert(page2pa(pp0) < npage*PGSIZE);
f010138f:	8b 35 00 2a 17 f0    	mov    0xf0172a00,%esi
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
f01013aa:	c7 44 24 0c 50 4d 10 	movl   $0xf0104d50,0xc(%esp)
f01013b1:	f0 
f01013b2:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01013b9:	f0 
f01013ba:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f01013c1:	00 
f01013c2:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f01013e0:	c7 44 24 0c 6c 4d 10 	movl   $0xf0104d6c,0xc(%esp)
f01013e7:	f0 
f01013e8:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01013ef:	f0 
f01013f0:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f01013f7:	00 
f01013f8:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0101416:	c7 44 24 0c 88 4d 10 	movl   $0xf0104d88,0xc(%esp)
f010141d:	f0 
f010141e:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101425:	f0 
f0101426:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f010142d:	00 
f010142e:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101435:	e8 81 ec ff ff       	call   f01000bb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010143a:	8b 35 58 1d 17 f0    	mov    0xf0171d58,%esi
	LIST_INIT(&page_free_list);
f0101440:	c7 05 58 1d 17 f0 00 	movl   $0x0,0xf0171d58
f0101447:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010144a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f010144d:	89 04 24             	mov    %eax,(%esp)
f0101450:	e8 b9 f8 ff ff       	call   f0100d0e <page_alloc>
f0101455:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101458:	74 24                	je     f010147e <i386_vm_init+0x37b>
f010145a:	c7 44 24 0c a4 4d 10 	movl   $0xf0104da4,0xc(%esp)
f0101461:	f0 
f0101462:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101469:	f0 
f010146a:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0101471:	00 
f0101472:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f01014c3:	c7 44 24 0c e7 4c 10 	movl   $0xf0104ce7,0xc(%esp)
f01014ca:	f0 
f01014cb:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01014d2:	f0 
f01014d3:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f01014da:	00 
f01014db:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01014e2:	e8 d4 eb ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f01014e7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01014ea:	89 04 24             	mov    %eax,(%esp)
f01014ed:	e8 1c f8 ff ff       	call   f0100d0e <page_alloc>
f01014f2:	85 c0                	test   %eax,%eax
f01014f4:	74 24                	je     f010151a <i386_vm_init+0x417>
f01014f6:	c7 44 24 0c 12 4d 10 	movl   $0xf0104d12,0xc(%esp)
f01014fd:	f0 
f01014fe:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101505:	f0 
f0101506:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f010150d:	00 
f010150e:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101515:	e8 a1 eb ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f010151a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010151d:	89 04 24             	mov    %eax,(%esp)
f0101520:	e8 e9 f7 ff ff       	call   f0100d0e <page_alloc>
f0101525:	85 c0                	test   %eax,%eax
f0101527:	74 24                	je     f010154d <i386_vm_init+0x44a>
f0101529:	c7 44 24 0c 28 4d 10 	movl   $0xf0104d28,0xc(%esp)
f0101530:	f0 
f0101531:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101538:	f0 
f0101539:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f0101540:	00 
f0101541:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101548:	e8 6e eb ff ff       	call   f01000bb <_panic>
	assert(pp0);
f010154d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101550:	85 d2                	test   %edx,%edx
f0101552:	75 24                	jne    f0101578 <i386_vm_init+0x475>
f0101554:	c7 44 24 0c 4c 4d 10 	movl   $0xf0104d4c,0xc(%esp)
f010155b:	f0 
f010155c:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101563:	f0 
f0101564:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
f010156b:	00 
f010156c:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101573:	e8 43 eb ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f0101578:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010157b:	85 c9                	test   %ecx,%ecx
f010157d:	74 04                	je     f0101583 <i386_vm_init+0x480>
f010157f:	39 ca                	cmp    %ecx,%edx
f0101581:	75 24                	jne    f01015a7 <i386_vm_init+0x4a4>
f0101583:	c7 44 24 0c 3e 4d 10 	movl   $0xf0104d3e,0xc(%esp)
f010158a:	f0 
f010158b:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101592:	f0 
f0101593:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
f010159a:	00 
f010159b:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01015a2:	e8 14 eb ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	74 08                	je     f01015b6 <i386_vm_init+0x4b3>
f01015ae:	39 c1                	cmp    %eax,%ecx
f01015b0:	74 04                	je     f01015b6 <i386_vm_init+0x4b3>
f01015b2:	39 c2                	cmp    %eax,%edx
f01015b4:	75 24                	jne    f01015da <i386_vm_init+0x4d7>
f01015b6:	c7 44 24 0c e8 47 10 	movl   $0xf01047e8,0xc(%esp)
f01015bd:	f0 
f01015be:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01015c5:	f0 
f01015c6:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f01015cd:	00 
f01015ce:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01015d5:	e8 e1 ea ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f01015da:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01015dd:	89 04 24             	mov    %eax,(%esp)
f01015e0:	e8 29 f7 ff ff       	call   f0100d0e <page_alloc>
f01015e5:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01015e8:	74 24                	je     f010160e <i386_vm_init+0x50b>
f01015ea:	c7 44 24 0c a4 4d 10 	movl   $0xf0104da4,0xc(%esp)
f01015f1:	f0 
f01015f2:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01015f9:	f0 
f01015fa:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0101601:	00 
f0101602:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101609:	e8 ad ea ff ff       	call   f01000bb <_panic>

	// give free list back
	page_free_list = fl;
f010160e:	89 35 58 1d 17 f0    	mov    %esi,0xf0171d58

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
f0101635:	c7 04 24 08 48 10 f0 	movl   $0xf0104808,(%esp)
f010163c:	e8 f5 15 00 00       	call   f0102c36 <cprintf>
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
f0101665:	c7 44 24 0c e7 4c 10 	movl   $0xf0104ce7,0xc(%esp)
f010166c:	f0 
f010166d:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101674:	f0 
f0101675:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010167c:	00 
f010167d:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101684:	e8 32 ea ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f0101689:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010168c:	89 04 24             	mov    %eax,(%esp)
f010168f:	e8 7a f6 ff ff       	call   f0100d0e <page_alloc>
f0101694:	85 c0                	test   %eax,%eax
f0101696:	74 24                	je     f01016bc <i386_vm_init+0x5b9>
f0101698:	c7 44 24 0c 12 4d 10 	movl   $0xf0104d12,0xc(%esp)
f010169f:	f0 
f01016a0:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01016a7:	f0 
f01016a8:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f01016af:	00 
f01016b0:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01016b7:	e8 ff e9 ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f01016bc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01016bf:	89 04 24             	mov    %eax,(%esp)
f01016c2:	e8 47 f6 ff ff       	call   f0100d0e <page_alloc>
f01016c7:	85 c0                	test   %eax,%eax
f01016c9:	74 24                	je     f01016ef <i386_vm_init+0x5ec>
f01016cb:	c7 44 24 0c 28 4d 10 	movl   $0xf0104d28,0xc(%esp)
f01016d2:	f0 
f01016d3:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01016da:	f0 
f01016db:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f01016e2:	00 
f01016e3:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01016ea:	e8 cc e9 ff ff       	call   f01000bb <_panic>

	assert(pp0);
f01016ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01016f2:	85 d2                	test   %edx,%edx
f01016f4:	75 24                	jne    f010171a <i386_vm_init+0x617>
f01016f6:	c7 44 24 0c 4c 4d 10 	movl   $0xf0104d4c,0xc(%esp)
f01016fd:	f0 
f01016fe:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101705:	f0 
f0101706:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f010170d:	00 
f010170e:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101715:	e8 a1 e9 ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f010171a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010171d:	85 c9                	test   %ecx,%ecx
f010171f:	74 04                	je     f0101725 <i386_vm_init+0x622>
f0101721:	39 ca                	cmp    %ecx,%edx
f0101723:	75 24                	jne    f0101749 <i386_vm_init+0x646>
f0101725:	c7 44 24 0c 3e 4d 10 	movl   $0xf0104d3e,0xc(%esp)
f010172c:	f0 
f010172d:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101734:	f0 
f0101735:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f010173c:	00 
f010173d:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101744:	e8 72 e9 ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101749:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010174c:	85 c0                	test   %eax,%eax
f010174e:	74 08                	je     f0101758 <i386_vm_init+0x655>
f0101750:	39 c1                	cmp    %eax,%ecx
f0101752:	74 04                	je     f0101758 <i386_vm_init+0x655>
f0101754:	39 c2                	cmp    %eax,%edx
f0101756:	75 24                	jne    f010177c <i386_vm_init+0x679>
f0101758:	c7 44 24 0c e8 47 10 	movl   $0xf01047e8,0xc(%esp)
f010175f:	f0 
f0101760:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101767:	f0 
f0101768:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f010176f:	00 
f0101770:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101777:	e8 3f e9 ff ff       	call   f01000bb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010177c:	a1 58 1d 17 f0       	mov    0xf0171d58,%eax
f0101781:	89 45 c0             	mov    %eax,-0x40(%ebp)
	LIST_INIT(&page_free_list);
f0101784:	c7 05 58 1d 17 f0 00 	movl   $0x0,0xf0171d58
f010178b:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010178e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101791:	89 04 24             	mov    %eax,(%esp)
f0101794:	e8 75 f5 ff ff       	call   f0100d0e <page_alloc>
f0101799:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010179c:	74 24                	je     f01017c2 <i386_vm_init+0x6bf>
f010179e:	c7 44 24 0c a4 4d 10 	movl   $0xf0104da4,0xc(%esp)
f01017a5:	f0 
f01017a6:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01017ad:	f0 
f01017ae:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f01017b5:	00 
f01017b6:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01017bd:	e8 f9 e8 ff ff       	call   f01000bb <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f01017c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01017c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017d0:	00 
f01017d1:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f01017d6:	89 04 24             	mov    %eax,(%esp)
f01017d9:	e8 c9 f7 ff ff       	call   f0100fa7 <page_lookup>
f01017de:	85 c0                	test   %eax,%eax
f01017e0:	74 24                	je     f0101806 <i386_vm_init+0x703>
f01017e2:	c7 44 24 0c 28 48 10 	movl   $0xf0104828,0xc(%esp)
f01017e9:	f0 
f01017ea:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01017f1:	f0 
f01017f2:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f01017f9:	00 
f01017fa:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101801:	e8 b5 e8 ff ff       	call   f01000bb <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0101806:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010180d:	00 
f010180e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101815:	00 
f0101816:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101819:	89 44 24 04          	mov    %eax,0x4(%esp)
f010181d:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0101822:	89 04 24             	mov    %eax,(%esp)
f0101825:	e8 48 f8 ff ff       	call   f0101072 <page_insert>
f010182a:	85 c0                	test   %eax,%eax
f010182c:	78 24                	js     f0101852 <i386_vm_init+0x74f>
f010182e:	c7 44 24 0c 60 48 10 	movl   $0xf0104860,0xc(%esp)
f0101835:	f0 
f0101836:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f010183d:	f0 
f010183e:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101845:	00 
f0101846:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0101874:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0101879:	89 04 24             	mov    %eax,(%esp)
f010187c:	e8 f1 f7 ff ff       	call   f0101072 <page_insert>
f0101881:	85 c0                	test   %eax,%eax
f0101883:	74 24                	je     f01018a9 <i386_vm_init+0x7a6>
f0101885:	c7 44 24 0c 8c 48 10 	movl   $0xf010488c,0xc(%esp)
f010188c:	f0 
f010188d:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101894:	f0 
f0101895:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f010189c:	00 
f010189d:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01018a4:	e8 12 e8 ff ff       	call   f01000bb <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01018a9:	8b 35 08 2a 17 f0    	mov    0xf0172a08,%esi
f01018af:	8b 7d dc             	mov    -0x24(%ebp),%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01018b2:	8b 15 0c 2a 17 f0    	mov    0xf0172a0c,%edx
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
f01018d8:	c7 44 24 0c b8 48 10 	movl   $0xf01048b8,0xc(%esp)
f01018df:	f0 
f01018e0:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01018e7:	f0 
f01018e8:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f01018ef:	00 
f01018f0:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0101920:	c7 44 24 0c e0 48 10 	movl   $0xf01048e0,0xc(%esp)
f0101927:	f0 
f0101928:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f010192f:	f0 
f0101930:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101937:	00 
f0101938:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f010193f:	e8 77 e7 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 1);
f0101944:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101949:	74 24                	je     f010196f <i386_vm_init+0x86c>
f010194b:	c7 44 24 0c c1 4d 10 	movl   $0xf0104dc1,0xc(%esp)
f0101952:	f0 
f0101953:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f010195a:	f0 
f010195b:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101962:	00 
f0101963:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f010196a:	e8 4c e7 ff ff       	call   f01000bb <_panic>
	assert(pp0->pp_ref == 1);
f010196f:	66 83 7f 08 01       	cmpw   $0x1,0x8(%edi)
f0101974:	74 24                	je     f010199a <i386_vm_init+0x897>
f0101976:	c7 44 24 0c d2 4d 10 	movl   $0xf0104dd2,0xc(%esp)
f010197d:	f0 
f010197e:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101985:	f0 
f0101986:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f010198d:	00 
f010198e:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f01019bd:	c7 44 24 0c 10 49 10 	movl   $0xf0104910,0xc(%esp)
f01019c4:	f0 
f01019c5:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01019cc:	f0 
f01019cd:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f01019d4:	00 
f01019d5:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01019dc:	e8 da e6 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01019e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019e6:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f01019eb:	e8 c5 f0 ff ff       	call   f0100ab5 <check_va2pa>
f01019f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01019f3:	89 d1                	mov    %edx,%ecx
f01019f5:	2b 0d 0c 2a 17 f0    	sub    0xf0172a0c,%ecx
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
f0101a0b:	c7 44 24 0c 48 49 10 	movl   $0xf0104948,0xc(%esp)
f0101a12:	f0 
f0101a13:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101a1a:	f0 
f0101a1b:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101a22:	00 
f0101a23:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101a2a:	e8 8c e6 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101a2f:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101a34:	74 24                	je     f0101a5a <i386_vm_init+0x957>
f0101a36:	c7 44 24 0c e3 4d 10 	movl   $0xf0104de3,0xc(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101a4d:	00 
f0101a4e:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101a55:	e8 61 e6 ff ff       	call   f01000bb <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101a5a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101a5d:	89 04 24             	mov    %eax,(%esp)
f0101a60:	e8 a9 f2 ff ff       	call   f0100d0e <page_alloc>
f0101a65:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101a68:	74 24                	je     f0101a8e <i386_vm_init+0x98b>
f0101a6a:	c7 44 24 0c a4 4d 10 	movl   $0xf0104da4,0xc(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101a79:	f0 
f0101a7a:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101a81:	00 
f0101a82:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101a89:	e8 2d e6 ff ff       	call   f01000bb <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101a8e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101a95:	00 
f0101a96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a9d:	00 
f0101a9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101aa5:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0101aaa:	89 04 24             	mov    %eax,(%esp)
f0101aad:	e8 c0 f5 ff ff       	call   f0101072 <page_insert>
f0101ab2:	85 c0                	test   %eax,%eax
f0101ab4:	74 24                	je     f0101ada <i386_vm_init+0x9d7>
f0101ab6:	c7 44 24 0c 10 49 10 	movl   $0xf0104910,0xc(%esp)
f0101abd:	f0 
f0101abe:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101ac5:	f0 
f0101ac6:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101acd:	00 
f0101ace:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101ad5:	e8 e1 e5 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101ada:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101adf:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0101ae4:	e8 cc ef ff ff       	call   f0100ab5 <check_va2pa>
f0101ae9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101aec:	89 d1                	mov    %edx,%ecx
f0101aee:	2b 0d 0c 2a 17 f0    	sub    0xf0172a0c,%ecx
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
f0101b04:	c7 44 24 0c 48 49 10 	movl   $0xf0104948,0xc(%esp)
f0101b0b:	f0 
f0101b0c:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101b13:	f0 
f0101b14:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0101b1b:	00 
f0101b1c:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101b23:	e8 93 e5 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101b28:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101b2d:	74 24                	je     f0101b53 <i386_vm_init+0xa50>
f0101b2f:	c7 44 24 0c e3 4d 10 	movl   $0xf0104de3,0xc(%esp)
f0101b36:	f0 
f0101b37:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101b3e:	f0 
f0101b3f:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101b46:	00 
f0101b47:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101b4e:	e8 68 e5 ff ff       	call   f01000bb <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101b53:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101b56:	89 04 24             	mov    %eax,(%esp)
f0101b59:	e8 b0 f1 ff ff       	call   f0100d0e <page_alloc>
f0101b5e:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101b61:	74 24                	je     f0101b87 <i386_vm_init+0xa84>
f0101b63:	c7 44 24 0c a4 4d 10 	movl   $0xf0104da4,0xc(%esp)
f0101b6a:	f0 
f0101b6b:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101b72:	f0 
f0101b73:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0101b7a:	00 
f0101b7b:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101b82:	e8 34 e5 ff ff       	call   f01000bb <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0101b87:	8b 15 08 2a 17 f0    	mov    0xf0172a08,%edx
f0101b8d:	8b 02                	mov    (%edx),%eax
f0101b8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101b94:	89 c1                	mov    %eax,%ecx
f0101b96:	c1 e9 0c             	shr    $0xc,%ecx
f0101b99:	3b 0d 00 2a 17 f0    	cmp    0xf0172a00,%ecx
f0101b9f:	72 20                	jb     f0101bc1 <i386_vm_init+0xabe>
f0101ba1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ba5:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f0101bac:	f0 
f0101bad:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0101bb4:	00 
f0101bb5:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0101beb:	c7 44 24 0c 78 49 10 	movl   $0xf0104978,0xc(%esp)
f0101bf2:	f0 
f0101bf3:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101bfa:	f0 
f0101bfb:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101c02:	00 
f0101c03:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101c0a:	e8 ac e4 ff ff       	call   f01000bb <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0101c0f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0101c16:	00 
f0101c17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c1e:	00 
f0101c1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c26:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0101c2b:	89 04 24             	mov    %eax,(%esp)
f0101c2e:	e8 3f f4 ff ff       	call   f0101072 <page_insert>
f0101c33:	85 c0                	test   %eax,%eax
f0101c35:	74 24                	je     f0101c5b <i386_vm_init+0xb58>
f0101c37:	c7 44 24 0c b8 49 10 	movl   $0xf01049b8,0xc(%esp)
f0101c3e:	f0 
f0101c3f:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101c46:	f0 
f0101c47:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0101c4e:	00 
f0101c4f:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101c56:	e8 60 e4 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101c5b:	8b 35 08 2a 17 f0    	mov    0xf0172a08,%esi
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
f0101c72:	2b 0d 0c 2a 17 f0    	sub    0xf0172a0c,%ecx
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
f0101c88:	c7 44 24 0c 48 49 10 	movl   $0xf0104948,0xc(%esp)
f0101c8f:	f0 
f0101c90:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101c97:	f0 
f0101c98:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0101c9f:	00 
f0101ca0:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101ca7:	e8 0f e4 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101cac:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101cb1:	74 24                	je     f0101cd7 <i386_vm_init+0xbd4>
f0101cb3:	c7 44 24 0c e3 4d 10 	movl   $0xf0104de3,0xc(%esp)
f0101cba:	f0 
f0101cbb:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101cc2:	f0 
f0101cc3:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0101cca:	00 
f0101ccb:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0101cf4:	c7 44 24 0c f4 49 10 	movl   $0xf01049f4,0xc(%esp)
f0101cfb:	f0 
f0101cfc:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101d03:	f0 
f0101d04:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0101d0b:	00 
f0101d0c:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101d13:	e8 a3 e3 ff ff       	call   f01000bb <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101d18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101d1f:	00 
f0101d20:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101d27:	00 
f0101d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d2f:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0101d34:	89 04 24             	mov    %eax,(%esp)
f0101d37:	e8 36 f3 ff ff       	call   f0101072 <page_insert>
f0101d3c:	85 c0                	test   %eax,%eax
f0101d3e:	78 24                	js     f0101d64 <i386_vm_init+0xc61>
f0101d40:	c7 44 24 0c 28 4a 10 	movl   $0xf0104a28,0xc(%esp)
f0101d47:	f0 
f0101d48:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101d4f:	f0 
f0101d50:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101d57:	00 
f0101d58:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101d5f:	e8 57 e3 ff ff       	call   f01000bb <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d64:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101d6b:	00 
f0101d6c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d73:	00 
f0101d74:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d7b:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0101d80:	89 04 24             	mov    %eax,(%esp)
f0101d83:	e8 ea f2 ff ff       	call   f0101072 <page_insert>
f0101d88:	85 c0                	test   %eax,%eax
f0101d8a:	74 24                	je     f0101db0 <i386_vm_init+0xcad>
f0101d8c:	c7 44 24 0c 5c 4a 10 	movl   $0xf0104a5c,0xc(%esp)
f0101d93:	f0 
f0101d94:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101d9b:	f0 
f0101d9c:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101da3:	00 
f0101da4:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101dab:	e8 0b e3 ff ff       	call   f01000bb <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0101db0:	8b 3d 08 2a 17 f0    	mov    0xf0172a08,%edi
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
f0101dca:	2b 05 0c 2a 17 f0    	sub    0xf0172a0c,%eax
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
f0101de1:	c7 44 24 0c 94 4a 10 	movl   $0xf0104a94,0xc(%esp)
f0101de8:	f0 
f0101de9:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101df0:	f0 
f0101df1:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0101df8:	00 
f0101df9:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101e00:	e8 b6 e2 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101e05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e0a:	89 f8                	mov    %edi,%eax
f0101e0c:	e8 a4 ec ff ff       	call   f0100ab5 <check_va2pa>
f0101e11:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101e14:	74 24                	je     f0101e3a <i386_vm_init+0xd37>
f0101e16:	c7 44 24 0c c0 4a 10 	movl   $0xf0104ac0,0xc(%esp)
f0101e1d:	f0 
f0101e1e:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101e25:	f0 
f0101e26:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101e2d:	00 
f0101e2e:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101e35:	e8 81 e2 ff ff       	call   f01000bb <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e3a:	66 83 7e 08 02       	cmpw   $0x2,0x8(%esi)
f0101e3f:	74 24                	je     f0101e65 <i386_vm_init+0xd62>
f0101e41:	c7 44 24 0c f4 4d 10 	movl   $0xf0104df4,0xc(%esp)
f0101e48:	f0 
f0101e49:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101e50:	f0 
f0101e51:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101e58:	00 
f0101e59:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101e60:	e8 56 e2 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0101e65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e68:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101e6d:	74 24                	je     f0101e93 <i386_vm_init+0xd90>
f0101e6f:	c7 44 24 0c 05 4e 10 	movl   $0xf0104e05,0xc(%esp)
f0101e76:	f0 
f0101e77:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101e7e:	f0 
f0101e7f:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0101e86:	00 
f0101e87:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0101eaa:	c7 44 24 0c f0 4a 10 	movl   $0xf0104af0,0xc(%esp)
f0101eb1:	f0 
f0101eb2:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101eb9:	f0 
f0101eba:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101ec1:	00 
f0101ec2:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101ec9:	e8 ed e1 ff ff       	call   f01000bb <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0101ece:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ed5:	00 
f0101ed6:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0101edb:	89 04 24             	mov    %eax,(%esp)
f0101ede:	e8 3f f1 ff ff       	call   f0101022 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101ee3:	8b 35 08 2a 17 f0    	mov    0xf0172a08,%esi
f0101ee9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eee:	89 f0                	mov    %esi,%eax
f0101ef0:	e8 c0 eb ff ff       	call   f0100ab5 <check_va2pa>
f0101ef5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ef8:	74 24                	je     f0101f1e <i386_vm_init+0xe1b>
f0101efa:	c7 44 24 0c 14 4b 10 	movl   $0xf0104b14,0xc(%esp)
f0101f01:	f0 
f0101f02:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101f11:	00 
f0101f12:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0101f2f:	2b 0d 0c 2a 17 f0    	sub    0xf0172a0c,%ecx
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
f0101f45:	c7 44 24 0c c0 4a 10 	movl   $0xf0104ac0,0xc(%esp)
f0101f4c:	f0 
f0101f4d:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101f54:	f0 
f0101f55:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101f5c:	00 
f0101f5d:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101f64:	e8 52 e1 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 1);
f0101f69:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101f6e:	74 24                	je     f0101f94 <i386_vm_init+0xe91>
f0101f70:	c7 44 24 0c c1 4d 10 	movl   $0xf0104dc1,0xc(%esp)
f0101f77:	f0 
f0101f78:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101f7f:	f0 
f0101f80:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101f87:	00 
f0101f88:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101f8f:	e8 27 e1 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0101f94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f97:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101f9c:	74 24                	je     f0101fc2 <i386_vm_init+0xebf>
f0101f9e:	c7 44 24 0c 05 4e 10 	movl   $0xf0104e05,0xc(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101fb5:	00 
f0101fb6:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0101fbd:	e8 f9 e0 ff ff       	call   f01000bb <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0101fc2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fc9:	00 
f0101fca:	89 34 24             	mov    %esi,(%esp)
f0101fcd:	e8 50 f0 ff ff       	call   f0101022 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101fd2:	8b 35 08 2a 17 f0    	mov    0xf0172a08,%esi
f0101fd8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fdd:	89 f0                	mov    %esi,%eax
f0101fdf:	e8 d1 ea ff ff       	call   f0100ab5 <check_va2pa>
f0101fe4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fe7:	74 24                	je     f010200d <i386_vm_init+0xf0a>
f0101fe9:	c7 44 24 0c 14 4b 10 	movl   $0xf0104b14,0xc(%esp)
f0101ff0:	f0 
f0101ff1:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0101ff8:	f0 
f0101ff9:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0102000:	00 
f0102001:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0102008:	e8 ae e0 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f010200d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102012:	89 f0                	mov    %esi,%eax
f0102014:	e8 9c ea ff ff       	call   f0100ab5 <check_va2pa>
f0102019:	83 f8 ff             	cmp    $0xffffffff,%eax
f010201c:	74 24                	je     f0102042 <i386_vm_init+0xf3f>
f010201e:	c7 44 24 0c 38 4b 10 	movl   $0xf0104b38,0xc(%esp)
f0102025:	f0 
f0102026:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f010202d:	f0 
f010202e:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102035:	00 
f0102036:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f010203d:	e8 79 e0 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 0);
f0102042:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102045:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010204a:	74 24                	je     f0102070 <i386_vm_init+0xf6d>
f010204c:	c7 44 24 0c 16 4e 10 	movl   $0xf0104e16,0xc(%esp)
f0102053:	f0 
f0102054:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f010205b:	f0 
f010205c:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102063:	00 
f0102064:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f010206b:	e8 4b e0 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0102070:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102073:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102078:	74 24                	je     f010209e <i386_vm_init+0xf9b>
f010207a:	c7 44 24 0c 05 4e 10 	movl   $0xf0104e05,0xc(%esp)
f0102081:	f0 
f0102082:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102089:	f0 
f010208a:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102091:	00 
f0102092:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f01020b5:	c7 44 24 0c 60 4b 10 	movl   $0xf0104b60,0xc(%esp)
f01020bc:	f0 
f01020bd:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01020c4:	f0 
f01020c5:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01020cc:	00 
f01020cd:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01020d4:	e8 e2 df ff ff       	call   f01000bb <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01020d9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01020dc:	89 04 24             	mov    %eax,(%esp)
f01020df:	e8 2a ec ff ff       	call   f0100d0e <page_alloc>
f01020e4:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01020e7:	74 24                	je     f010210d <i386_vm_init+0x100a>
f01020e9:	c7 44 24 0c a4 4d 10 	movl   $0xf0104da4,0xc(%esp)
f01020f0:	f0 
f01020f1:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01020f8:	f0 
f01020f9:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102100:	00 
f0102101:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0102108:	e8 ae df ff ff       	call   f01000bb <_panic>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f010210d:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f0102112:	8b 08                	mov    (%eax),%ecx
f0102114:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010211a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010211d:	2b 15 0c 2a 17 f0    	sub    0xf0172a0c,%edx
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
f0102133:	c7 44 24 0c b8 48 10 	movl   $0xf01048b8,0xc(%esp)
f010213a:	f0 
f010213b:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102142:	f0 
f0102143:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f010214a:	00 
f010214b:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f0102152:	e8 64 df ff ff       	call   f01000bb <_panic>
	boot_pgdir[0] = 0;
f0102157:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010215d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102160:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102165:	74 24                	je     f010218b <i386_vm_init+0x1088>
f0102167:	c7 44 24 0c d2 4d 10 	movl   $0xf0104dd2,0xc(%esp)
f010216e:	f0 
f010216f:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102176:	f0 
f0102177:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f010217e:	00 
f010217f:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f01021a9:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f01021ae:	89 04 24             	mov    %eax,(%esp)
f01021b1:	e8 1b ec ff ff       	call   f0100dd1 <pgdir_walk>
f01021b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f01021b9:	8b 35 08 2a 17 f0    	mov    0xf0172a08,%esi
f01021bf:	8b 56 04             	mov    0x4(%esi),%edx
f01021c2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021c8:	8b 0d 00 2a 17 f0    	mov    0xf0172a00,%ecx
f01021ce:	89 d7                	mov    %edx,%edi
f01021d0:	c1 ef 0c             	shr    $0xc,%edi
f01021d3:	39 cf                	cmp    %ecx,%edi
f01021d5:	72 20                	jb     f01021f7 <i386_vm_init+0x10f4>
f01021d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01021db:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01021f2:	e8 c4 de ff ff       	call   f01000bb <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021f7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01021fd:	39 d0                	cmp    %edx,%eax
f01021ff:	74 24                	je     f0102225 <i386_vm_init+0x1122>
f0102201:	c7 44 24 0c 27 4e 10 	movl   $0xf0104e27,0xc(%esp)
f0102208:	f0 
f0102209:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102210:	f0 
f0102211:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102218:	00 
f0102219:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0102235:	2b 05 0c 2a 17 f0    	sub    0xf0172a0c,%eax
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
f0102254:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f010225b:	f0 
f010225c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102263:	00 
f0102264:	c7 04 24 d9 4c 10 f0 	movl   $0xf0104cd9,(%esp)
f010226b:	e8 4b de ff ff       	call   f01000bb <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102270:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102277:	00 
f0102278:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010227f:	00 
f0102280:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102285:	89 04 24             	mov    %eax,(%esp)
f0102288:	e8 d9 18 00 00       	call   f0103b66 <memset>
	page_free(pp0);
f010228d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102290:	89 04 24             	mov    %eax,(%esp)
f0102293:	e8 c7 ea ff ff       	call   f0100d5f <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f0102298:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010229f:	00 
f01022a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022a7:	00 
f01022a8:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f01022ad:	89 04 24             	mov    %eax,(%esp)
f01022b0:	e8 1c eb ff ff       	call   f0100dd1 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01022b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01022b8:	2b 15 0c 2a 17 f0    	sub    0xf0172a0c,%edx
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
f01022cf:	3b 05 00 2a 17 f0    	cmp    0xf0172a00,%eax
f01022d5:	72 20                	jb     f01022f7 <i386_vm_init+0x11f4>
f01022d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01022db:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f01022e2:	f0 
f01022e3:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01022ea:	00 
f01022eb:	c7 04 24 d9 4c 10 f0 	movl   $0xf0104cd9,(%esp)
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
f010231a:	c7 44 24 0c 3f 4e 10 	movl   $0xf0104e3f,0xc(%esp)
f0102321:	f0 
f0102322:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102329:	f0 
f010232a:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102331:	00 
f0102332:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0102345:	a1 08 2a 17 f0       	mov    0xf0172a08,%eax
f010234a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102350:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102353:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0102359:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010235c:	89 15 58 1d 17 f0    	mov    %edx,0xf0171d58

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
f0102380:	c7 04 24 56 4e 10 f0 	movl   $0xf0104e56,(%esp)
f0102387:	e8 aa 08 00 00       	call   f0102c36 <cprintf>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here:
	// [UPAGES, sizeof(PAGES) ] => [pages, sizeof(PAGES)]
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f010238c:	8b 15 00 2a 17 f0    	mov    0xf0172a00,%edx
	boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f0102392:	a1 0c 2a 17 f0       	mov    0xf0172a0c,%eax
f0102397:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010239c:	77 20                	ja     f01023be <i386_vm_init+0x12bb>
f010239e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023a2:	c7 44 24 08 4c 47 10 	movl   $0xf010474c,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f01023ea:	a1 60 1d 17 f0       	mov    0xf0171d60,%eax
f01023ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023f4:	77 20                	ja     f0102416 <i386_vm_init+0x1313>
f01023f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023fa:	c7 44 24 08 4c 47 10 	movl   $0xf010474c,0x8(%esp)
f0102401:	f0 
f0102402:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102409:	00 
f010240a:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0102437:	be 00 f0 10 f0       	mov    $0xf010f000,%esi
f010243c:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102442:	77 20                	ja     f0102464 <i386_vm_init+0x1361>
f0102444:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102448:	c7 44 24 08 4c 47 10 	movl   $0xf010474c,0x8(%esp)
f010244f:	f0 
f0102450:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f0102457:	00 
f0102458:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f010245f:	e8 57 dc ff ff       	call   f01000bb <_panic>
f0102464:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010246b:	00 
f010246c:	c7 04 24 00 f0 10 00 	movl   $0x10f000,(%esp)
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
f01024a4:	8b 3d 08 2a 17 f0    	mov    0xf0172a08,%edi

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f01024aa:	8b 0d 00 2a 17 f0    	mov    0xf0172a00,%ecx
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
f01024e2:	8b 15 0c 2a 17 f0    	mov    0xf0172a0c,%edx
f01024e8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01024ee:	77 20                	ja     f0102510 <i386_vm_init+0x140d>
f01024f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024f4:	c7 44 24 08 4c 47 10 	movl   $0xf010474c,0x8(%esp)
f01024fb:	f0 
f01024fc:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102503:	00 
f0102504:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f010250b:	e8 ab db ff ff       	call   f01000bb <_panic>
f0102510:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102513:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f010251a:	39 d0                	cmp    %edx,%eax
f010251c:	74 24                	je     f0102542 <i386_vm_init+0x143f>
f010251e:	c7 44 24 0c 84 4b 10 	movl   $0xf0104b84,0xc(%esp)
f0102525:	f0 
f0102526:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f010252d:	f0 
f010252e:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102535:	00 
f0102536:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0102571:	8b 15 60 1d 17 f0    	mov    0xf0171d60,%edx
f0102577:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010257d:	77 20                	ja     f010259f <i386_vm_init+0x149c>
f010257f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102583:	c7 44 24 08 4c 47 10 	movl   $0xf010474c,0x8(%esp)
f010258a:	f0 
f010258b:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0102592:	00 
f0102593:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f010259a:	e8 1c db ff ff       	call   f01000bb <_panic>
f010259f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01025a2:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f01025a9:	39 d0                	cmp    %edx,%eax
f01025ab:	74 24                	je     f01025d1 <i386_vm_init+0x14ce>
f01025ad:	c7 44 24 0c b8 4b 10 	movl   $0xf0104bb8,0xc(%esp)
f01025b4:	f0 
f01025b5:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f01025c4:	00 
f01025c5:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0102603:	c7 44 24 0c ec 4b 10 	movl   $0xf0104bec,0xc(%esp)
f010260a:	f0 
f010260b:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102612:	f0 
f0102613:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f010261a:	00 
f010261b:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f0102658:	c7 44 24 0c 14 4c 10 	movl   $0xf0104c14,0xc(%esp)
f010265f:	f0 
f0102660:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102667:	f0 
f0102668:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f010266f:	00 
f0102670:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f010269f:	c7 44 24 0c 6f 4e 10 	movl   $0xf0104e6f,0xc(%esp)
f01026a6:	f0 
f01026a7:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01026ae:	f0 
f01026af:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f01026b6:	00 
f01026b7:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01026be:	e8 f8 d9 ff ff       	call   f01000bb <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f01026c3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01026c8:	76 2a                	jbe    f01026f4 <i386_vm_init+0x15f1>
				assert(pgdir[i]);
f01026ca:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026ce:	75 4e                	jne    f010271e <i386_vm_init+0x161b>
f01026d0:	c7 44 24 0c 6f 4e 10 	movl   $0xf0104e6f,0xc(%esp)
f01026d7:	f0 
f01026d8:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
f01026e7:	00 
f01026e8:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
f01026ef:	e8 c7 d9 ff ff       	call   f01000bb <_panic>
			else
				assert(pgdir[i] == 0);
f01026f4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026f8:	74 24                	je     f010271e <i386_vm_init+0x161b>
f01026fa:	c7 44 24 0c 78 4e 10 	movl   $0xf0104e78,0xc(%esp)
f0102701:	f0 
f0102702:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102709:	f0 
f010270a:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0102711:	00 
f0102712:	c7 04 24 b1 4c 10 f0 	movl   $0xf0104cb1,(%esp)
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
f010272c:	c7 04 24 5c 4c 10 f0 	movl   $0xf0104c5c,(%esp)
f0102733:	e8 fe 04 00 00       	call   f0102c36 <cprintf>
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
f0102740:	a1 04 2a 17 f0       	mov    0xf0172a04,%eax
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
f0102756:	0f 01 15 20 73 11 f0 	lgdtl  0xf0117320
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
f0102780:	a1 04 2a 17 f0       	mov    0xf0172a04,%eax
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
f01027e6:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
f01027eb:	8b 40 4c             	mov    0x4c(%eax),%eax
f01027ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027f2:	c7 04 24 7c 4c 10 f0 	movl   $0xf0104c7c,(%esp)
f01027f9:	e8 38 04 00 00       	call   f0102c36 <cprintf>
			"va %08x\n", curenv->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01027fe:	89 1c 24             	mov    %ebx,(%esp)
f0102801:	e8 47 03 00 00       	call   f0102b4d <env_destroy>
	}
}
f0102806:	83 c4 14             	add    $0x14,%esp
f0102809:	5b                   	pop    %ebx
f010280a:	5d                   	pop    %ebp
f010280b:	c3                   	ret    

f010280c <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010280c:	55                   	push   %ebp
f010280d:	89 e5                	mov    %esp,%ebp
f010280f:	53                   	push   %ebx
f0102810:	8b 45 08             	mov    0x8(%ebp),%eax
f0102813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102816:	85 c0                	test   %eax,%eax
f0102818:	75 0e                	jne    f0102828 <envid2env+0x1c>
		*env_store = curenv;
f010281a:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
f010281f:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102821:	b8 00 00 00 00       	mov    $0x0,%eax
f0102826:	eb 54                	jmp    f010287c <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102828:	89 c2                	mov    %eax,%edx
f010282a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102830:	6b d2 64             	imul   $0x64,%edx,%edx
f0102833:	03 15 60 1d 17 f0    	add    0xf0171d60,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102839:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f010283d:	74 05                	je     f0102844 <envid2env+0x38>
f010283f:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0102842:	74 0d                	je     f0102851 <envid2env+0x45>
		*env_store = 0;
f0102844:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f010284a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010284f:	eb 2b                	jmp    f010287c <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102851:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102855:	74 1e                	je     f0102875 <envid2env+0x69>
f0102857:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
f010285c:	39 c2                	cmp    %eax,%edx
f010285e:	74 15                	je     f0102875 <envid2env+0x69>
f0102860:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0102863:	39 5a 50             	cmp    %ebx,0x50(%edx)
f0102866:	74 0d                	je     f0102875 <envid2env+0x69>
		*env_store = 0;
f0102868:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f010286e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102873:	eb 07                	jmp    f010287c <envid2env+0x70>
	}

	*env_store = e;
f0102875:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102877:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010287c:	5b                   	pop    %ebx
f010287d:	5d                   	pop    %ebp
f010287e:	c3                   	ret    

f010287f <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f010287f:	55                   	push   %ebp
f0102880:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0102882:	5d                   	pop    %ebp
f0102883:	c3                   	ret    

f0102884 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102884:	55                   	push   %ebp
f0102885:	89 e5                	mov    %esp,%ebp
f0102887:	53                   	push   %ebx
f0102888:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f010288b:	8b 1d 64 1d 17 f0    	mov    0xf0171d64,%ebx
f0102891:	85 db                	test   %ebx,%ebx
f0102893:	0f 84 f8 00 00 00    	je     f0102991 <env_alloc+0x10d>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0102899:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f01028a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01028a3:	89 04 24             	mov    %eax,(%esp)
f01028a6:	e8 63 e4 ff ff       	call   f0100d0e <page_alloc>
f01028ab:	85 c0                	test   %eax,%eax
f01028ad:	0f 88 e3 00 00 00    	js     f0102996 <env_alloc+0x112>

	// LAB 3: Your code here.

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f01028b3:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01028b6:	8b 53 60             	mov    0x60(%ebx),%edx
f01028b9:	83 ca 03             	or     $0x3,%edx
f01028bc:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f01028c2:	8b 43 5c             	mov    0x5c(%ebx),%eax
f01028c5:	8b 53 60             	mov    0x60(%ebx),%edx
f01028c8:	83 ca 05             	or     $0x5,%edx
f01028cb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01028d1:	8b 43 4c             	mov    0x4c(%ebx),%eax
f01028d4:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01028d9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01028de:	ba 00 10 00 00       	mov    $0x1000,%edx
f01028e3:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01028e6:	89 da                	mov    %ebx,%edx
f01028e8:	2b 15 60 1d 17 f0    	sub    0xf0171d60,%edx
f01028ee:	c1 fa 02             	sar    $0x2,%edx
f01028f1:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f01028f7:	09 d0                	or     %edx,%eax
f01028f9:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01028fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028ff:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102902:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102909:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102910:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102917:	00 
f0102918:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010291f:	00 
f0102920:	89 1c 24             	mov    %ebx,(%esp)
f0102923:	e8 3e 12 00 00       	call   f0103b66 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0102928:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010292e:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102934:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010293a:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102941:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0102947:	8b 43 44             	mov    0x44(%ebx),%eax
f010294a:	85 c0                	test   %eax,%eax
f010294c:	74 06                	je     f0102954 <env_alloc+0xd0>
f010294e:	8b 53 48             	mov    0x48(%ebx),%edx
f0102951:	89 50 48             	mov    %edx,0x48(%eax)
f0102954:	8b 43 48             	mov    0x48(%ebx),%eax
f0102957:	8b 53 44             	mov    0x44(%ebx),%edx
f010295a:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f010295c:	8b 45 08             	mov    0x8(%ebp),%eax
f010295f:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102961:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0102964:	8b 15 5c 1d 17 f0    	mov    0xf0171d5c,%edx
f010296a:	b8 00 00 00 00       	mov    $0x0,%eax
f010296f:	85 d2                	test   %edx,%edx
f0102971:	74 03                	je     f0102976 <env_alloc+0xf2>
f0102973:	8b 42 4c             	mov    0x4c(%edx),%eax
f0102976:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010297a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010297e:	c7 04 24 86 4e 10 f0 	movl   $0xf0104e86,(%esp)
f0102985:	e8 ac 02 00 00       	call   f0102c36 <cprintf>
	return 0;
f010298a:	b8 00 00 00 00       	mov    $0x0,%eax
f010298f:	eb 05                	jmp    f0102996 <env_alloc+0x112>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
f0102991:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102996:	83 c4 24             	add    $0x24,%esp
f0102999:	5b                   	pop    %ebx
f010299a:	5d                   	pop    %ebp
f010299b:	c3                   	ret    

f010299c <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f010299c:	55                   	push   %ebp
f010299d:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f010299f:	5d                   	pop    %ebp
f01029a0:	c3                   	ret    

f01029a1 <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f01029a1:	55                   	push   %ebp
f01029a2:	89 e5                	mov    %esp,%ebp
f01029a4:	57                   	push   %edi
f01029a5:	56                   	push   %esi
f01029a6:	53                   	push   %ebx
f01029a7:	83 ec 2c             	sub    $0x2c,%esp
f01029aa:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01029ad:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
f01029b2:	39 c7                	cmp    %eax,%edi
f01029b4:	75 09                	jne    f01029bf <env_free+0x1e>
f01029b6:	8b 15 04 2a 17 f0    	mov    0xf0172a04,%edx
f01029bc:	0f 22 da             	mov    %edx,%cr3
		lcr3(boot_cr3);

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01029bf:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f01029c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01029c7:	85 c0                	test   %eax,%eax
f01029c9:	74 03                	je     f01029ce <env_free+0x2d>
f01029cb:	8b 50 4c             	mov    0x4c(%eax),%edx
f01029ce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01029d2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01029d6:	c7 04 24 9b 4e 10 f0 	movl   $0xf0104e9b,(%esp)
f01029dd:	e8 54 02 00 00       	call   f0102c36 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01029e2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01029e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029ec:	c1 e0 02             	shl    $0x2,%eax
f01029ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01029f2:	8b 47 5c             	mov    0x5c(%edi),%eax
f01029f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01029f8:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01029fb:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102a01:	0f 84 bb 00 00 00    	je     f0102ac2 <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102a07:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0102a0d:	89 f0                	mov    %esi,%eax
f0102a0f:	c1 e8 0c             	shr    $0xc,%eax
f0102a12:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102a15:	3b 05 00 2a 17 f0    	cmp    0xf0172a00,%eax
f0102a1b:	72 20                	jb     f0102a3d <env_free+0x9c>
f0102a1d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102a21:	c7 44 24 08 04 47 10 	movl   $0xf0104704,0x8(%esp)
f0102a28:	f0 
f0102a29:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0102a30:	00 
f0102a31:	c7 04 24 b1 4e 10 f0 	movl   $0xf0104eb1,(%esp)
f0102a38:	e8 7e d6 ff ff       	call   f01000bb <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102a3d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102a40:	c1 e2 16             	shl    $0x16,%edx
f0102a43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102a46:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102a4b:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102a52:	01 
f0102a53:	74 17                	je     f0102a6c <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102a55:	89 d8                	mov    %ebx,%eax
f0102a57:	c1 e0 0c             	shl    $0xc,%eax
f0102a5a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a61:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102a64:	89 04 24             	mov    %eax,(%esp)
f0102a67:	e8 b6 e5 ff ff       	call   f0101022 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102a6c:	83 c3 01             	add    $0x1,%ebx
f0102a6f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102a75:	75 d4                	jne    f0102a4b <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102a77:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102a7a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102a7d:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102a84:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102a87:	3b 05 00 2a 17 f0    	cmp    0xf0172a00,%eax
f0102a8d:	72 1c                	jb     f0102aab <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0102a8f:	c7 44 24 08 c8 47 10 	movl   $0xf01047c8,0x8(%esp)
f0102a96:	f0 
f0102a97:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102a9e:	00 
f0102a9f:	c7 04 24 d9 4c 10 f0 	movl   $0xf0104cd9,(%esp)
f0102aa6:	e8 10 d6 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0102aab:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102aae:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102ab1:	c1 e0 02             	shl    $0x2,%eax
f0102ab4:	03 05 0c 2a 17 f0    	add    0xf0172a0c,%eax
		page_decref(pa2page(pa));
f0102aba:	89 04 24             	mov    %eax,(%esp)
f0102abd:	e8 ec e2 ff ff       	call   f0100dae <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ac2:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102ac6:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102acd:	0f 85 16 ff ff ff    	jne    f01029e9 <env_free+0x48>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0102ad3:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0102ad6:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0102add:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102ae4:	c1 e8 0c             	shr    $0xc,%eax
f0102ae7:	3b 05 00 2a 17 f0    	cmp    0xf0172a00,%eax
f0102aed:	72 1c                	jb     f0102b0b <env_free+0x16a>
		panic("pa2page called with invalid pa");
f0102aef:	c7 44 24 08 c8 47 10 	movl   $0xf01047c8,0x8(%esp)
f0102af6:	f0 
f0102af7:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102afe:	00 
f0102aff:	c7 04 24 d9 4c 10 f0 	movl   $0xf0104cd9,(%esp)
f0102b06:	e8 b0 d5 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0102b0b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102b0e:	c1 e0 02             	shl    $0x2,%eax
f0102b11:	03 05 0c 2a 17 f0    	add    0xf0172a0c,%eax
	page_decref(pa2page(pa));
f0102b17:	89 04 24             	mov    %eax,(%esp)
f0102b1a:	e8 8f e2 ff ff       	call   f0100dae <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102b1f:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0102b26:	a1 64 1d 17 f0       	mov    0xf0171d64,%eax
f0102b2b:	89 47 44             	mov    %eax,0x44(%edi)
f0102b2e:	85 c0                	test   %eax,%eax
f0102b30:	74 06                	je     f0102b38 <env_free+0x197>
f0102b32:	8d 57 44             	lea    0x44(%edi),%edx
f0102b35:	89 50 48             	mov    %edx,0x48(%eax)
f0102b38:	89 3d 64 1d 17 f0    	mov    %edi,0xf0171d64
f0102b3e:	c7 47 48 64 1d 17 f0 	movl   $0xf0171d64,0x48(%edi)
}
f0102b45:	83 c4 2c             	add    $0x2c,%esp
f0102b48:	5b                   	pop    %ebx
f0102b49:	5e                   	pop    %esi
f0102b4a:	5f                   	pop    %edi
f0102b4b:	5d                   	pop    %ebp
f0102b4c:	c3                   	ret    

f0102b4d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102b4d:	55                   	push   %ebp
f0102b4e:	89 e5                	mov    %esp,%ebp
f0102b50:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0102b53:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b56:	89 04 24             	mov    %eax,(%esp)
f0102b59:	e8 43 fe ff ff       	call   f01029a1 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102b5e:	c7 04 24 e4 4e 10 f0 	movl   $0xf0104ee4,(%esp)
f0102b65:	e8 cc 00 00 00       	call   f0102c36 <cprintf>
	while (1)
		monitor(NULL);
f0102b6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b71:	e8 8a dc ff ff       	call   f0100800 <monitor>
f0102b76:	eb f2                	jmp    f0102b6a <env_destroy+0x1d>

f0102b78 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102b78:	55                   	push   %ebp
f0102b79:	89 e5                	mov    %esp,%ebp
f0102b7b:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102b7e:	8b 65 08             	mov    0x8(%ebp),%esp
f0102b81:	61                   	popa   
f0102b82:	07                   	pop    %es
f0102b83:	1f                   	pop    %ds
f0102b84:	83 c4 08             	add    $0x8,%esp
f0102b87:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102b88:	c7 44 24 08 bc 4e 10 	movl   $0xf0104ebc,0x8(%esp)
f0102b8f:	f0 
f0102b90:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0102b97:	00 
f0102b98:	c7 04 24 b1 4e 10 f0 	movl   $0xf0104eb1,(%esp)
f0102b9f:	e8 17 d5 ff ff       	call   f01000bb <_panic>

f0102ba4 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0102ba4:	55                   	push   %ebp
f0102ba5:	89 e5                	mov    %esp,%ebp
f0102ba7:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.

        panic("env_run not yet implemented");
f0102baa:	c7 44 24 08 c8 4e 10 	movl   $0xf0104ec8,0x8(%esp)
f0102bb1:	f0 
f0102bb2:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f0102bb9:	00 
f0102bba:	c7 04 24 b1 4e 10 f0 	movl   $0xf0104eb1,(%esp)
f0102bc1:	e8 f5 d4 ff ff       	call   f01000bb <_panic>
	...

f0102bc8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102bc8:	55                   	push   %ebp
f0102bc9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bcb:	ba 70 00 00 00       	mov    $0x70,%edx
f0102bd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bd3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102bd4:	b2 71                	mov    $0x71,%dl
f0102bd6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102bd7:	0f b6 c0             	movzbl %al,%eax
}
f0102bda:	5d                   	pop    %ebp
f0102bdb:	c3                   	ret    

f0102bdc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102bdc:	55                   	push   %ebp
f0102bdd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bdf:	ba 70 00 00 00       	mov    $0x70,%edx
f0102be4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102be7:	ee                   	out    %al,(%dx)
f0102be8:	b2 71                	mov    $0x71,%dl
f0102bea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bed:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102bee:	5d                   	pop    %ebp
f0102bef:	c3                   	ret    

f0102bf0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102bf0:	55                   	push   %ebp
f0102bf1:	89 e5                	mov    %esp,%ebp
f0102bf3:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102bf6:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bf9:	89 04 24             	mov    %eax,(%esp)
f0102bfc:	e8 d7 da ff ff       	call   f01006d8 <cputchar>
	*cnt++;
}
f0102c01:	c9                   	leave  
f0102c02:	c3                   	ret    

f0102c03 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102c03:	55                   	push   %ebp
f0102c04:	89 e5                	mov    %esp,%ebp
f0102c06:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102c09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102c10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c17:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c1a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102c21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c25:	c7 04 24 f0 2b 10 f0 	movl   $0xf0102bf0,(%esp)
f0102c2c:	e8 83 08 00 00       	call   f01034b4 <vprintfmt>
	return cnt;
}
f0102c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c34:	c9                   	leave  
f0102c35:	c3                   	ret    

f0102c36 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102c36:	55                   	push   %ebp
f0102c37:	89 e5                	mov    %esp,%ebp
f0102c39:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0102c3c:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102c3f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c43:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c46:	89 04 24             	mov    %eax,(%esp)
f0102c49:	e8 b5 ff ff ff       	call   f0102c03 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102c4e:	c9                   	leave  
f0102c4f:	c3                   	ret    

f0102c50 <idt_init>:
}


void
idt_init(void)
{
f0102c50:	55                   	push   %ebp
f0102c51:	89 e5                	mov    %esp,%ebp
	
	// LAB 3: Your code here.

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102c53:	c7 05 84 25 17 f0 00 	movl   $0xefc00000,0xf0172584
f0102c5a:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0102c5d:	66 c7 05 88 25 17 f0 	movw   $0x10,0xf0172588
f0102c64:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102c66:	66 c7 05 68 73 11 f0 	movw   $0x68,0xf0117368
f0102c6d:	68 00 
f0102c6f:	b8 80 25 17 f0       	mov    $0xf0172580,%eax
f0102c74:	66 a3 6a 73 11 f0    	mov    %ax,0xf011736a
f0102c7a:	89 c2                	mov    %eax,%edx
f0102c7c:	c1 ea 10             	shr    $0x10,%edx
f0102c7f:	88 15 6c 73 11 f0    	mov    %dl,0xf011736c
f0102c85:	c6 05 6e 73 11 f0 40 	movb   $0x40,0xf011736e
f0102c8c:	c1 e8 18             	shr    $0x18,%eax
f0102c8f:	a2 6f 73 11 f0       	mov    %al,0xf011736f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0102c94:	c6 05 6d 73 11 f0 89 	movb   $0x89,0xf011736d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0102c9b:	b8 28 00 00 00       	mov    $0x28,%eax
f0102ca0:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0102ca3:	0f 01 1d 70 73 11 f0 	lidtl  0xf0117370
}
f0102caa:	5d                   	pop    %ebp
f0102cab:	c3                   	ret    

f0102cac <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0102cac:	55                   	push   %ebp
f0102cad:	89 e5                	mov    %esp,%ebp
f0102caf:	53                   	push   %ebx
f0102cb0:	83 ec 14             	sub    $0x14,%esp
f0102cb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0102cb6:	8b 03                	mov    (%ebx),%eax
f0102cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102cbc:	c7 04 24 1a 4f 10 f0 	movl   $0xf0104f1a,(%esp)
f0102cc3:	e8 6e ff ff ff       	call   f0102c36 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0102cc8:	8b 43 04             	mov    0x4(%ebx),%eax
f0102ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ccf:	c7 04 24 29 4f 10 f0 	movl   $0xf0104f29,(%esp)
f0102cd6:	e8 5b ff ff ff       	call   f0102c36 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0102cdb:	8b 43 08             	mov    0x8(%ebx),%eax
f0102cde:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ce2:	c7 04 24 38 4f 10 f0 	movl   $0xf0104f38,(%esp)
f0102ce9:	e8 48 ff ff ff       	call   f0102c36 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0102cee:	8b 43 0c             	mov    0xc(%ebx),%eax
f0102cf1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102cf5:	c7 04 24 47 4f 10 f0 	movl   $0xf0104f47,(%esp)
f0102cfc:	e8 35 ff ff ff       	call   f0102c36 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0102d01:	8b 43 10             	mov    0x10(%ebx),%eax
f0102d04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d08:	c7 04 24 56 4f 10 f0 	movl   $0xf0104f56,(%esp)
f0102d0f:	e8 22 ff ff ff       	call   f0102c36 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0102d14:	8b 43 14             	mov    0x14(%ebx),%eax
f0102d17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d1b:	c7 04 24 65 4f 10 f0 	movl   $0xf0104f65,(%esp)
f0102d22:	e8 0f ff ff ff       	call   f0102c36 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0102d27:	8b 43 18             	mov    0x18(%ebx),%eax
f0102d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d2e:	c7 04 24 74 4f 10 f0 	movl   $0xf0104f74,(%esp)
f0102d35:	e8 fc fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0102d3a:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0102d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d41:	c7 04 24 83 4f 10 f0 	movl   $0xf0104f83,(%esp)
f0102d48:	e8 e9 fe ff ff       	call   f0102c36 <cprintf>
}
f0102d4d:	83 c4 14             	add    $0x14,%esp
f0102d50:	5b                   	pop    %ebx
f0102d51:	5d                   	pop    %ebp
f0102d52:	c3                   	ret    

f0102d53 <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f0102d53:	55                   	push   %ebp
f0102d54:	89 e5                	mov    %esp,%ebp
f0102d56:	53                   	push   %ebx
f0102d57:	83 ec 14             	sub    $0x14,%esp
f0102d5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0102d5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102d61:	c7 04 24 50 50 10 f0 	movl   $0xf0105050,(%esp)
f0102d68:	e8 c9 fe ff ff       	call   f0102c36 <cprintf>
	print_regs(&tf->tf_regs);
f0102d6d:	89 1c 24             	mov    %ebx,(%esp)
f0102d70:	e8 37 ff ff ff       	call   f0102cac <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0102d75:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0102d79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d7d:	c7 04 24 ad 4f 10 f0 	movl   $0xf0104fad,(%esp)
f0102d84:	e8 ad fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0102d89:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0102d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d91:	c7 04 24 c0 4f 10 f0 	movl   $0xf0104fc0,(%esp)
f0102d98:	e8 99 fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102d9d:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0102da0:	83 f8 13             	cmp    $0x13,%eax
f0102da3:	77 09                	ja     f0102dae <print_trapframe+0x5b>
		return excnames[trapno];
f0102da5:	8b 14 85 40 52 10 f0 	mov    -0xfefadc0(,%eax,4),%edx
f0102dac:	eb 10                	jmp    f0102dbe <print_trapframe+0x6b>
	if (trapno == T_SYSCALL)
f0102dae:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
f0102db1:	ba 92 4f 10 f0       	mov    $0xf0104f92,%edx
f0102db6:	b9 9e 4f 10 f0       	mov    $0xf0104f9e,%ecx
f0102dbb:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102dbe:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dc6:	c7 04 24 d3 4f 10 f0 	movl   $0xf0104fd3,(%esp)
f0102dcd:	e8 64 fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f0102dd2:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0102dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dd9:	c7 04 24 e5 4f 10 f0 	movl   $0xf0104fe5,(%esp)
f0102de0:	e8 51 fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0102de5:	8b 43 30             	mov    0x30(%ebx),%eax
f0102de8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dec:	c7 04 24 f4 4f 10 f0 	movl   $0xf0104ff4,(%esp)
f0102df3:	e8 3e fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0102df8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0102dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e00:	c7 04 24 03 50 10 f0 	movl   $0xf0105003,(%esp)
f0102e07:	e8 2a fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0102e0c:	8b 43 38             	mov    0x38(%ebx),%eax
f0102e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e13:	c7 04 24 16 50 10 f0 	movl   $0xf0105016,(%esp)
f0102e1a:	e8 17 fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0102e1f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0102e22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e26:	c7 04 24 25 50 10 f0 	movl   $0xf0105025,(%esp)
f0102e2d:	e8 04 fe ff ff       	call   f0102c36 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0102e32:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0102e36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e3a:	c7 04 24 34 50 10 f0 	movl   $0xf0105034,(%esp)
f0102e41:	e8 f0 fd ff ff       	call   f0102c36 <cprintf>
}
f0102e46:	83 c4 14             	add    $0x14,%esp
f0102e49:	5b                   	pop    %ebx
f0102e4a:	5d                   	pop    %ebp
f0102e4b:	c3                   	ret    

f0102e4c <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0102e4c:	55                   	push   %ebp
f0102e4d:	89 e5                	mov    %esp,%ebp
f0102e4f:	57                   	push   %edi
f0102e50:	56                   	push   %esi
f0102e51:	83 ec 10             	sub    $0x10,%esp
f0102e54:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("Incoming TRAP frame at %p\n", tf);
f0102e57:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102e5b:	c7 04 24 47 50 10 f0 	movl   $0xf0105047,(%esp)
f0102e62:	e8 cf fd ff ff       	call   f0102c36 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0102e67:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0102e6b:	83 e0 03             	and    $0x3,%eax
f0102e6e:	83 f8 03             	cmp    $0x3,%eax
f0102e71:	75 3c                	jne    f0102eaf <trap+0x63>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0102e73:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
f0102e78:	85 c0                	test   %eax,%eax
f0102e7a:	75 24                	jne    f0102ea0 <trap+0x54>
f0102e7c:	c7 44 24 0c 62 50 10 	movl   $0xf0105062,0xc(%esp)
f0102e83:	f0 
f0102e84:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102e8b:	f0 
f0102e8c:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
f0102e93:	00 
f0102e94:	c7 04 24 69 50 10 f0 	movl   $0xf0105069,(%esp)
f0102e9b:	e8 1b d2 ff ff       	call   f01000bb <_panic>
		curenv->env_tf = *tf;
f0102ea0:	b9 11 00 00 00       	mov    $0x11,%ecx
f0102ea5:	89 c7                	mov    %eax,%edi
f0102ea7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0102ea9:	8b 35 5c 1d 17 f0    	mov    0xf0171d5c,%esi
	// Handle processor exceptions.
	// LAB 3: Your code here.
	

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0102eaf:	89 34 24             	mov    %esi,(%esp)
f0102eb2:	e8 9c fe ff ff       	call   f0102d53 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0102eb7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0102ebc:	75 1c                	jne    f0102eda <trap+0x8e>
		panic("unhandled trap in kernel");
f0102ebe:	c7 44 24 08 75 50 10 	movl   $0xf0105075,0x8(%esp)
f0102ec5:	f0 
f0102ec6:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
f0102ecd:	00 
f0102ece:	c7 04 24 69 50 10 f0 	movl   $0xf0105069,(%esp)
f0102ed5:	e8 e1 d1 ff ff       	call   f01000bb <_panic>
	else {
		env_destroy(curenv);
f0102eda:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
f0102edf:	89 04 24             	mov    %eax,(%esp)
f0102ee2:	e8 66 fc ff ff       	call   f0102b4d <env_destroy>
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f0102ee7:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
f0102eec:	85 c0                	test   %eax,%eax
f0102eee:	74 06                	je     f0102ef6 <trap+0xaa>
f0102ef0:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0102ef4:	74 24                	je     f0102f1a <trap+0xce>
f0102ef6:	c7 44 24 0c d0 51 10 	movl   $0xf01051d0,0xc(%esp)
f0102efd:	f0 
f0102efe:	c7 44 24 08 fd 4c 10 	movl   $0xf0104cfd,0x8(%esp)
f0102f05:	f0 
f0102f06:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
f0102f0d:	00 
f0102f0e:	c7 04 24 69 50 10 f0 	movl   $0xf0105069,(%esp)
f0102f15:	e8 a1 d1 ff ff       	call   f01000bb <_panic>
        env_run(curenv);
f0102f1a:	89 04 24             	mov    %eax,(%esp)
f0102f1d:	e8 82 fc ff ff       	call   f0102ba4 <env_run>

f0102f22 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0102f22:	55                   	push   %ebp
f0102f23:	89 e5                	mov    %esp,%ebp
f0102f25:	53                   	push   %ebx
f0102f26:	83 ec 14             	sub    $0x14,%esp
f0102f29:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0102f2c:	0f 20 d0             	mov    %cr2,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0102f2f:	8b 53 30             	mov    0x30(%ebx),%edx
f0102f32:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f36:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0102f3a:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0102f3f:	8b 40 4c             	mov    0x4c(%eax),%eax
f0102f42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f46:	c7 04 24 00 52 10 f0 	movl   $0xf0105200,(%esp)
f0102f4d:	e8 e4 fc ff ff       	call   f0102c36 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0102f52:	89 1c 24             	mov    %ebx,(%esp)
f0102f55:	e8 f9 fd ff ff       	call   f0102d53 <print_trapframe>
	env_destroy(curenv);
f0102f5a:	a1 5c 1d 17 f0       	mov    0xf0171d5c,%eax
f0102f5f:	89 04 24             	mov    %eax,(%esp)
f0102f62:	e8 e6 fb ff ff       	call   f0102b4d <env_destroy>
}
f0102f67:	83 c4 14             	add    $0x14,%esp
f0102f6a:	5b                   	pop    %ebx
f0102f6b:	5d                   	pop    %ebp
f0102f6c:	c3                   	ret    
f0102f6d:	00 00                	add    %al,(%eax)
	...

f0102f70 <syscall>:
f0102f70:	55                   	push   %ebp
f0102f71:	89 e5                	mov    %esp,%ebp
f0102f73:	83 ec 18             	sub    $0x18,%esp
f0102f76:	c7 44 24 08 90 52 10 	movl   $0xf0105290,0x8(%esp)
f0102f7d:	f0 
f0102f7e:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102f85:	00 
f0102f86:	c7 04 24 a8 52 10 f0 	movl   $0xf01052a8,(%esp)
f0102f8d:	e8 29 d1 ff ff       	call   f01000bb <_panic>
	...

f0102f94 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102f94:	55                   	push   %ebp
f0102f95:	89 e5                	mov    %esp,%ebp
f0102f97:	57                   	push   %edi
f0102f98:	56                   	push   %esi
f0102f99:	53                   	push   %ebx
f0102f9a:	83 ec 14             	sub    $0x14,%esp
f0102f9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102fa0:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102fa3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102fa6:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102fa9:	8b 1a                	mov    (%edx),%ebx
f0102fab:	8b 01                	mov    (%ecx),%eax
f0102fad:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0102fb0:	39 c3                	cmp    %eax,%ebx
f0102fb2:	0f 8f 9c 00 00 00    	jg     f0103054 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0102fb8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102fbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102fc2:	01 d8                	add    %ebx,%eax
f0102fc4:	89 c7                	mov    %eax,%edi
f0102fc6:	c1 ef 1f             	shr    $0x1f,%edi
f0102fc9:	01 c7                	add    %eax,%edi
f0102fcb:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102fcd:	39 df                	cmp    %ebx,%edi
f0102fcf:	7c 33                	jl     f0103004 <stab_binsearch+0x70>
f0102fd1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0102fd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0102fd7:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0102fdc:	39 f0                	cmp    %esi,%eax
f0102fde:	0f 84 bc 00 00 00    	je     f01030a0 <stab_binsearch+0x10c>
f0102fe4:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102fe8:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102fec:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102fee:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102ff1:	39 d8                	cmp    %ebx,%eax
f0102ff3:	7c 0f                	jl     f0103004 <stab_binsearch+0x70>
f0102ff5:	0f b6 0a             	movzbl (%edx),%ecx
f0102ff8:	83 ea 0c             	sub    $0xc,%edx
f0102ffb:	39 f1                	cmp    %esi,%ecx
f0102ffd:	75 ef                	jne    f0102fee <stab_binsearch+0x5a>
f0102fff:	e9 9e 00 00 00       	jmp    f01030a2 <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103004:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103007:	eb 3c                	jmp    f0103045 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103009:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010300c:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010300e:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103011:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103018:	eb 2b                	jmp    f0103045 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010301a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010301d:	76 14                	jbe    f0103033 <stab_binsearch+0x9f>
			*region_right = m - 1;
f010301f:	83 e8 01             	sub    $0x1,%eax
f0103022:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103025:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103028:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010302a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103031:	eb 12                	jmp    f0103045 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103033:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103036:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0103038:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010303c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010303e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103045:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103048:	0f 8d 71 ff ff ff    	jge    f0102fbf <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010304e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103052:	75 0f                	jne    f0103063 <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103054:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103057:	8b 02                	mov    (%edx),%eax
f0103059:	83 e8 01             	sub    $0x1,%eax
f010305c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010305f:	89 01                	mov    %eax,(%ecx)
f0103061:	eb 57                	jmp    f01030ba <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103063:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103066:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103068:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010306b:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010306d:	39 c1                	cmp    %eax,%ecx
f010306f:	7d 28                	jge    f0103099 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103071:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103074:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103077:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f010307c:	39 f2                	cmp    %esi,%edx
f010307e:	74 19                	je     f0103099 <stab_binsearch+0x105>
f0103080:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103084:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103088:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010308b:	39 c1                	cmp    %eax,%ecx
f010308d:	7d 0a                	jge    f0103099 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010308f:	0f b6 1a             	movzbl (%edx),%ebx
f0103092:	83 ea 0c             	sub    $0xc,%edx
f0103095:	39 f3                	cmp    %esi,%ebx
f0103097:	75 ef                	jne    f0103088 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103099:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010309c:	89 02                	mov    %eax,(%edx)
f010309e:	eb 1a                	jmp    f01030ba <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01030a0:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01030a2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01030a5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01030a8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01030ac:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01030af:	0f 82 54 ff ff ff    	jb     f0103009 <stab_binsearch+0x75>
f01030b5:	e9 60 ff ff ff       	jmp    f010301a <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01030ba:	83 c4 14             	add    $0x14,%esp
f01030bd:	5b                   	pop    %ebx
f01030be:	5e                   	pop    %esi
f01030bf:	5f                   	pop    %edi
f01030c0:	5d                   	pop    %ebp
f01030c1:	c3                   	ret    

f01030c2 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01030c2:	55                   	push   %ebp
f01030c3:	89 e5                	mov    %esp,%ebp
f01030c5:	57                   	push   %edi
f01030c6:	56                   	push   %esi
f01030c7:	53                   	push   %ebx
f01030c8:	83 ec 5c             	sub    $0x5c,%esp
f01030cb:	8b 75 08             	mov    0x8(%ebp),%esi
f01030ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01030d1:	c7 03 b7 52 10 f0    	movl   $0xf01052b7,(%ebx)
	info->eip_line = 0;
f01030d7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01030de:	c7 43 08 b7 52 10 f0 	movl   $0xf01052b7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01030e5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01030ec:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01030ef:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01030f6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01030fc:	77 23                	ja     f0103121 <debuginfo_eip+0x5f>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f01030fe:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0103104:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0103107:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f010310d:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103113:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0103116:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f010311c:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010311f:	eb 1a                	jmp    f010313b <debuginfo_eip+0x79>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103121:	c7 45 c0 6a eb 10 f0 	movl   $0xf010eb6a,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103128:	c7 45 b8 81 c2 10 f0 	movl   $0xf010c281,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010312f:	ba 80 c2 10 f0       	mov    $0xf010c280,%edx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103134:	c7 45 c4 d0 54 10 f0 	movl   $0xf01054d0,-0x3c(%ebp)
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010313b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103140:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103143:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f0103146:	0f 83 be 01 00 00    	jae    f010330a <debuginfo_eip+0x248>
f010314c:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103150:	0f 85 b4 01 00 00    	jne    f010330a <debuginfo_eip+0x248>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103156:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010315d:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0103160:	c1 fa 02             	sar    $0x2,%edx
f0103163:	69 c2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%eax
f0103169:	83 e8 01             	sub    $0x1,%eax
f010316c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010316f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103173:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010317a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010317d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103180:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103183:	e8 0c fe ff ff       	call   f0102f94 <stab_binsearch>
	if (lfile == 0)
f0103188:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f010318b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103190:	85 d2                	test   %edx,%edx
f0103192:	0f 84 72 01 00 00    	je     f010330a <debuginfo_eip+0x248>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103198:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f010319b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010319e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01031a1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01031a5:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01031ac:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01031af:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01031b2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01031b5:	e8 da fd ff ff       	call   f0102f94 <stab_binsearch>

	if (lfun <= rfun) {
f01031ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01031bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01031c0:	39 d0                	cmp    %edx,%eax
f01031c2:	7f 32                	jg     f01031f6 <debuginfo_eip+0x134>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01031c4:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01031c7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01031ca:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01031cd:	8b 39                	mov    (%ecx),%edi
f01031cf:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01031d2:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01031d5:	2b 7d b8             	sub    -0x48(%ebp),%edi
f01031d8:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01031db:	73 09                	jae    f01031e6 <debuginfo_eip+0x124>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01031dd:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01031e0:	03 7d b8             	add    -0x48(%ebp),%edi
f01031e3:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01031e6:	8b 49 08             	mov    0x8(%ecx),%ecx
f01031e9:	89 4b 10             	mov    %ecx,0x10(%ebx)
		// This "n_value" is the function's first addr, but when it comes to SLINE,
		// "n_value" describes the offset, so we need to minus "n_value" fro addr
		// to get the offset of the line.
		addr -= info->eip_fn_addr;
f01031ec:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01031ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01031f1:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01031f4:	eb 0f                	jmp    f0103205 <debuginfo_eip+0x143>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01031f6:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01031f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01031ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103202:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103205:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010320c:	00 
f010320d:	8b 43 08             	mov    0x8(%ebx),%eax
f0103210:	89 04 24             	mov    %eax,(%esp)
f0103213:	e8 27 09 00 00       	call   f0103b3f <strfind>
f0103218:	2b 43 08             	sub    0x8(%ebx),%eax
f010321b:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010321e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103222:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103229:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010322c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010322f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103232:	e8 5d fd ff ff       	call   f0102f94 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0103237:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010323a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010323d:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103240:	0f b7 54 96 06       	movzwl 0x6(%esi,%edx,4),%edx
f0103245:	89 53 04             	mov    %edx,0x4(%ebx)
	if (rline < lline)
f0103248:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010324b:	7e 07                	jle    f0103254 <debuginfo_eip+0x192>
	{
		info->eip_line = -1;
f010324d:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103254:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103257:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010325a:	89 7d bc             	mov    %edi,-0x44(%ebp)
f010325d:	39 f8                	cmp    %edi,%eax
f010325f:	7c 78                	jl     f01032d9 <debuginfo_eip+0x217>
	       && stabs[lline].n_type != N_SOL
f0103261:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103264:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103267:	8d 34 97             	lea    (%edi,%edx,4),%esi
f010326a:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f010326e:	80 f9 84             	cmp    $0x84,%cl
f0103271:	74 4e                	je     f01032c1 <debuginfo_eip+0x1ff>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103273:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0103277:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010327a:	89 c7                	mov    %eax,%edi
f010327c:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f010327f:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0103282:	eb 27                	jmp    f01032ab <debuginfo_eip+0x1e9>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103284:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103287:	39 c3                	cmp    %eax,%ebx
f0103289:	7e 08                	jle    f0103293 <debuginfo_eip+0x1d1>
f010328b:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f010328e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103291:	eb 46                	jmp    f01032d9 <debuginfo_eip+0x217>
	       && stabs[lline].n_type != N_SOL
f0103293:	89 d6                	mov    %edx,%esi
f0103295:	83 ea 0c             	sub    $0xc,%edx
f0103298:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f010329c:	80 f9 84             	cmp    $0x84,%cl
f010329f:	75 08                	jne    f01032a9 <debuginfo_eip+0x1e7>
f01032a1:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01032a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01032a7:	eb 18                	jmp    f01032c1 <debuginfo_eip+0x1ff>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01032a9:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01032ab:	80 f9 64             	cmp    $0x64,%cl
f01032ae:	75 d4                	jne    f0103284 <debuginfo_eip+0x1c2>
f01032b0:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f01032b4:	74 ce                	je     f0103284 <debuginfo_eip+0x1c2>
f01032b6:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01032b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01032bc:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f01032bf:	7f 18                	jg     f01032d9 <debuginfo_eip+0x217>
f01032c1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01032c4:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01032c7:	8b 04 86             	mov    (%esi,%eax,4),%eax
f01032ca:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01032cd:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01032d0:	39 d0                	cmp    %edx,%eax
f01032d2:	73 05                	jae    f01032d9 <debuginfo_eip+0x217>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01032d4:	03 45 b8             	add    -0x48(%ebp),%eax
f01032d7:	89 03                	mov    %eax,(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f01032d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032dc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f01032df:	b8 00 00 00 00       	mov    $0x0,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f01032e4:	39 d1                	cmp    %edx,%ecx
f01032e6:	7c 22                	jl     f010330a <debuginfo_eip+0x248>
	{
		if (stabs[i].n_type == N_PSYM)
f01032e8:	8d 04 52             	lea    (%edx,%edx,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01032eb:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01032ee:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
	{
		if (stabs[i].n_type == N_PSYM)
f01032f2:	80 38 a0             	cmpb   $0xa0,(%eax)
f01032f5:	75 04                	jne    f01032fb <debuginfo_eip+0x239>
		{
			++(info->eip_fn_narg);
f01032f7:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f01032fb:	83 c2 01             	add    $0x1,%edx
f01032fe:	83 c0 0c             	add    $0xc,%eax
f0103301:	39 d1                	cmp    %edx,%ecx
f0103303:	7d ed                	jge    f01032f2 <debuginfo_eip+0x230>
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0103305:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010330a:	83 c4 5c             	add    $0x5c,%esp
f010330d:	5b                   	pop    %ebx
f010330e:	5e                   	pop    %esi
f010330f:	5f                   	pop    %edi
f0103310:	5d                   	pop    %ebp
f0103311:	c3                   	ret    
	...

f0103320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103320:	55                   	push   %ebp
f0103321:	89 e5                	mov    %esp,%ebp
f0103323:	57                   	push   %edi
f0103324:	56                   	push   %esi
f0103325:	53                   	push   %ebx
f0103326:	83 ec 3c             	sub    $0x3c,%esp
f0103329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010332c:	89 d7                	mov    %edx,%edi
f010332e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103331:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103334:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103337:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010333a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010333d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103340:	b8 00 00 00 00       	mov    $0x0,%eax
f0103345:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0103348:	72 11                	jb     f010335b <printnum+0x3b>
f010334a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010334d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103350:	76 09                	jbe    f010335b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103352:	83 eb 01             	sub    $0x1,%ebx
f0103355:	85 db                	test   %ebx,%ebx
f0103357:	7f 51                	jg     f01033aa <printnum+0x8a>
f0103359:	eb 5e                	jmp    f01033b9 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010335b:	89 74 24 10          	mov    %esi,0x10(%esp)
f010335f:	83 eb 01             	sub    $0x1,%ebx
f0103362:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103366:	8b 45 10             	mov    0x10(%ebp),%eax
f0103369:	89 44 24 08          	mov    %eax,0x8(%esp)
f010336d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0103371:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0103375:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010337c:	00 
f010337d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103380:	89 04 24             	mov    %eax,(%esp)
f0103383:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103386:	89 44 24 04          	mov    %eax,0x4(%esp)
f010338a:	e8 d1 09 00 00       	call   f0103d60 <__udivdi3>
f010338f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103393:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103397:	89 04 24             	mov    %eax,(%esp)
f010339a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010339e:	89 fa                	mov    %edi,%edx
f01033a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033a3:	e8 78 ff ff ff       	call   f0103320 <printnum>
f01033a8:	eb 0f                	jmp    f01033b9 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01033aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01033ae:	89 34 24             	mov    %esi,(%esp)
f01033b1:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01033b4:	83 eb 01             	sub    $0x1,%ebx
f01033b7:	75 f1                	jne    f01033aa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01033b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01033bd:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01033c1:	8b 45 10             	mov    0x10(%ebp),%eax
f01033c4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01033cf:	00 
f01033d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01033d3:	89 04 24             	mov    %eax,(%esp)
f01033d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033dd:	e8 ae 0a 00 00       	call   f0103e90 <__umoddi3>
f01033e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01033e6:	0f be 80 c1 52 10 f0 	movsbl -0xfefad3f(%eax),%eax
f01033ed:	89 04 24             	mov    %eax,(%esp)
f01033f0:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01033f3:	83 c4 3c             	add    $0x3c,%esp
f01033f6:	5b                   	pop    %ebx
f01033f7:	5e                   	pop    %esi
f01033f8:	5f                   	pop    %edi
f01033f9:	5d                   	pop    %ebp
f01033fa:	c3                   	ret    

f01033fb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01033fb:	55                   	push   %ebp
f01033fc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01033fe:	83 fa 01             	cmp    $0x1,%edx
f0103401:	7e 0e                	jle    f0103411 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103403:	8b 10                	mov    (%eax),%edx
f0103405:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103408:	89 08                	mov    %ecx,(%eax)
f010340a:	8b 02                	mov    (%edx),%eax
f010340c:	8b 52 04             	mov    0x4(%edx),%edx
f010340f:	eb 22                	jmp    f0103433 <getuint+0x38>
	else if (lflag)
f0103411:	85 d2                	test   %edx,%edx
f0103413:	74 10                	je     f0103425 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103415:	8b 10                	mov    (%eax),%edx
f0103417:	8d 4a 04             	lea    0x4(%edx),%ecx
f010341a:	89 08                	mov    %ecx,(%eax)
f010341c:	8b 02                	mov    (%edx),%eax
f010341e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103423:	eb 0e                	jmp    f0103433 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103425:	8b 10                	mov    (%eax),%edx
f0103427:	8d 4a 04             	lea    0x4(%edx),%ecx
f010342a:	89 08                	mov    %ecx,(%eax)
f010342c:	8b 02                	mov    (%edx),%eax
f010342e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103433:	5d                   	pop    %ebp
f0103434:	c3                   	ret    

f0103435 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103435:	55                   	push   %ebp
f0103436:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103438:	83 fa 01             	cmp    $0x1,%edx
f010343b:	7e 0e                	jle    f010344b <getint+0x16>
		return va_arg(*ap, long long);
f010343d:	8b 10                	mov    (%eax),%edx
f010343f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103442:	89 08                	mov    %ecx,(%eax)
f0103444:	8b 02                	mov    (%edx),%eax
f0103446:	8b 52 04             	mov    0x4(%edx),%edx
f0103449:	eb 22                	jmp    f010346d <getint+0x38>
	else if (lflag)
f010344b:	85 d2                	test   %edx,%edx
f010344d:	74 10                	je     f010345f <getint+0x2a>
		return va_arg(*ap, long);
f010344f:	8b 10                	mov    (%eax),%edx
f0103451:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103454:	89 08                	mov    %ecx,(%eax)
f0103456:	8b 02                	mov    (%edx),%eax
f0103458:	89 c2                	mov    %eax,%edx
f010345a:	c1 fa 1f             	sar    $0x1f,%edx
f010345d:	eb 0e                	jmp    f010346d <getint+0x38>
	else
		return va_arg(*ap, int);
f010345f:	8b 10                	mov    (%eax),%edx
f0103461:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103464:	89 08                	mov    %ecx,(%eax)
f0103466:	8b 02                	mov    (%edx),%eax
f0103468:	89 c2                	mov    %eax,%edx
f010346a:	c1 fa 1f             	sar    $0x1f,%edx
}
f010346d:	5d                   	pop    %ebp
f010346e:	c3                   	ret    

f010346f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010346f:	55                   	push   %ebp
f0103470:	89 e5                	mov    %esp,%ebp
f0103472:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103475:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103479:	8b 10                	mov    (%eax),%edx
f010347b:	3b 50 04             	cmp    0x4(%eax),%edx
f010347e:	73 0a                	jae    f010348a <sprintputch+0x1b>
		*b->buf++ = ch;
f0103480:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103483:	88 0a                	mov    %cl,(%edx)
f0103485:	83 c2 01             	add    $0x1,%edx
f0103488:	89 10                	mov    %edx,(%eax)
}
f010348a:	5d                   	pop    %ebp
f010348b:	c3                   	ret    

f010348c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010348c:	55                   	push   %ebp
f010348d:	89 e5                	mov    %esp,%ebp
f010348f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0103492:	8d 45 14             	lea    0x14(%ebp),%eax
f0103495:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103499:	8b 45 10             	mov    0x10(%ebp),%eax
f010349c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01034aa:	89 04 24             	mov    %eax,(%esp)
f01034ad:	e8 02 00 00 00       	call   f01034b4 <vprintfmt>
	va_end(ap);
}
f01034b2:	c9                   	leave  
f01034b3:	c3                   	ret    

f01034b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01034b4:	55                   	push   %ebp
f01034b5:	89 e5                	mov    %esp,%ebp
f01034b7:	57                   	push   %edi
f01034b8:	56                   	push   %esi
f01034b9:	53                   	push   %ebx
f01034ba:	83 ec 4c             	sub    $0x4c,%esp
f01034bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034c0:	8b 75 10             	mov    0x10(%ebp),%esi
f01034c3:	eb 12                	jmp    f01034d7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01034c5:	85 c0                	test   %eax,%eax
f01034c7:	0f 84 98 03 00 00    	je     f0103865 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f01034cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034d1:	89 04 24             	mov    %eax,(%esp)
f01034d4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01034d7:	0f b6 06             	movzbl (%esi),%eax
f01034da:	83 c6 01             	add    $0x1,%esi
f01034dd:	83 f8 25             	cmp    $0x25,%eax
f01034e0:	75 e3                	jne    f01034c5 <vprintfmt+0x11>
f01034e2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01034e6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01034ed:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01034f2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01034f9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01034fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103501:	eb 2b                	jmp    f010352e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103503:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103506:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f010350a:	eb 22                	jmp    f010352e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010350c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010350f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0103513:	eb 19                	jmp    f010352e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103515:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103518:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010351f:	eb 0d                	jmp    f010352e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103521:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103524:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103527:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010352e:	0f b6 06             	movzbl (%esi),%eax
f0103531:	0f b6 d0             	movzbl %al,%edx
f0103534:	8d 7e 01             	lea    0x1(%esi),%edi
f0103537:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010353a:	83 e8 23             	sub    $0x23,%eax
f010353d:	3c 55                	cmp    $0x55,%al
f010353f:	0f 87 fa 02 00 00    	ja     f010383f <vprintfmt+0x38b>
f0103545:	0f b6 c0             	movzbl %al,%eax
f0103548:	ff 24 85 4c 53 10 f0 	jmp    *-0xfefacb4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010354f:	83 ea 30             	sub    $0x30,%edx
f0103552:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103555:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0103559:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010355c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f010355f:	83 fa 09             	cmp    $0x9,%edx
f0103562:	77 4a                	ja     f01035ae <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103564:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103567:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f010356a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010356d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0103571:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103574:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103577:	83 fa 09             	cmp    $0x9,%edx
f010357a:	76 eb                	jbe    f0103567 <vprintfmt+0xb3>
f010357c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010357f:	eb 2d                	jmp    f01035ae <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103581:	8b 45 14             	mov    0x14(%ebp),%eax
f0103584:	8d 50 04             	lea    0x4(%eax),%edx
f0103587:	89 55 14             	mov    %edx,0x14(%ebp)
f010358a:	8b 00                	mov    (%eax),%eax
f010358c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010358f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103592:	eb 1a                	jmp    f01035ae <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103594:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0103597:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010359b:	79 91                	jns    f010352e <vprintfmt+0x7a>
f010359d:	e9 73 ff ff ff       	jmp    f0103515 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01035a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01035a5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01035ac:	eb 80                	jmp    f010352e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f01035ae:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01035b2:	0f 89 76 ff ff ff    	jns    f010352e <vprintfmt+0x7a>
f01035b8:	e9 64 ff ff ff       	jmp    f0103521 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01035bd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01035c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01035c3:	e9 66 ff ff ff       	jmp    f010352e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01035c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01035cb:	8d 50 04             	lea    0x4(%eax),%edx
f01035ce:	89 55 14             	mov    %edx,0x14(%ebp)
f01035d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01035d5:	8b 00                	mov    (%eax),%eax
f01035d7:	89 04 24             	mov    %eax,(%esp)
f01035da:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01035dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01035e0:	e9 f2 fe ff ff       	jmp    f01034d7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01035e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01035e8:	8d 50 04             	lea    0x4(%eax),%edx
f01035eb:	89 55 14             	mov    %edx,0x14(%ebp)
f01035ee:	8b 00                	mov    (%eax),%eax
f01035f0:	89 c2                	mov    %eax,%edx
f01035f2:	c1 fa 1f             	sar    $0x1f,%edx
f01035f5:	31 d0                	xor    %edx,%eax
f01035f7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f01035f9:	83 f8 06             	cmp    $0x6,%eax
f01035fc:	7f 0b                	jg     f0103609 <vprintfmt+0x155>
f01035fe:	8b 14 85 a4 54 10 f0 	mov    -0xfefab5c(,%eax,4),%edx
f0103605:	85 d2                	test   %edx,%edx
f0103607:	75 23                	jne    f010362c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0103609:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010360d:	c7 44 24 08 d9 52 10 	movl   $0xf01052d9,0x8(%esp)
f0103614:	f0 
f0103615:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103619:	8b 7d 08             	mov    0x8(%ebp),%edi
f010361c:	89 3c 24             	mov    %edi,(%esp)
f010361f:	e8 68 fe ff ff       	call   f010348c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103624:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103627:	e9 ab fe ff ff       	jmp    f01034d7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f010362c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103630:	c7 44 24 08 0f 4d 10 	movl   $0xf0104d0f,0x8(%esp)
f0103637:	f0 
f0103638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010363c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010363f:	89 3c 24             	mov    %edi,(%esp)
f0103642:	e8 45 fe ff ff       	call   f010348c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103647:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010364a:	e9 88 fe ff ff       	jmp    f01034d7 <vprintfmt+0x23>
f010364f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103652:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103655:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103658:	8b 45 14             	mov    0x14(%ebp),%eax
f010365b:	8d 50 04             	lea    0x4(%eax),%edx
f010365e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103661:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103663:	85 f6                	test   %esi,%esi
f0103665:	ba d2 52 10 f0       	mov    $0xf01052d2,%edx
f010366a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f010366d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103671:	7e 06                	jle    f0103679 <vprintfmt+0x1c5>
f0103673:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0103677:	75 10                	jne    f0103689 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103679:	0f be 06             	movsbl (%esi),%eax
f010367c:	83 c6 01             	add    $0x1,%esi
f010367f:	85 c0                	test   %eax,%eax
f0103681:	0f 85 86 00 00 00    	jne    f010370d <vprintfmt+0x259>
f0103687:	eb 76                	jmp    f01036ff <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103689:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010368d:	89 34 24             	mov    %esi,(%esp)
f0103690:	e8 36 03 00 00       	call   f01039cb <strnlen>
f0103695:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103698:	29 c2                	sub    %eax,%edx
f010369a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010369d:	85 d2                	test   %edx,%edx
f010369f:	7e d8                	jle    f0103679 <vprintfmt+0x1c5>
					putch(padc, putdat);
f01036a1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01036a5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01036a8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01036ab:	89 d6                	mov    %edx,%esi
f01036ad:	89 c7                	mov    %eax,%edi
f01036af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01036b3:	89 3c 24             	mov    %edi,(%esp)
f01036b6:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01036b9:	83 ee 01             	sub    $0x1,%esi
f01036bc:	75 f1                	jne    f01036af <vprintfmt+0x1fb>
f01036be:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01036c1:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f01036c4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01036c7:	eb b0                	jmp    f0103679 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01036c9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01036cd:	74 18                	je     f01036e7 <vprintfmt+0x233>
f01036cf:	8d 50 e0             	lea    -0x20(%eax),%edx
f01036d2:	83 fa 5e             	cmp    $0x5e,%edx
f01036d5:	76 10                	jbe    f01036e7 <vprintfmt+0x233>
					putch('?', putdat);
f01036d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01036db:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01036e2:	ff 55 08             	call   *0x8(%ebp)
f01036e5:	eb 0a                	jmp    f01036f1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f01036e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01036eb:	89 04 24             	mov    %eax,(%esp)
f01036ee:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01036f1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f01036f5:	0f be 06             	movsbl (%esi),%eax
f01036f8:	83 c6 01             	add    $0x1,%esi
f01036fb:	85 c0                	test   %eax,%eax
f01036fd:	75 0e                	jne    f010370d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103702:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103706:	7f 11                	jg     f0103719 <vprintfmt+0x265>
f0103708:	e9 ca fd ff ff       	jmp    f01034d7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010370d:	85 ff                	test   %edi,%edi
f010370f:	90                   	nop
f0103710:	78 b7                	js     f01036c9 <vprintfmt+0x215>
f0103712:	83 ef 01             	sub    $0x1,%edi
f0103715:	79 b2                	jns    f01036c9 <vprintfmt+0x215>
f0103717:	eb e6                	jmp    f01036ff <vprintfmt+0x24b>
f0103719:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010371c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010371f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103723:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010372a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010372c:	83 ee 01             	sub    $0x1,%esi
f010372f:	75 ee                	jne    f010371f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103731:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103734:	e9 9e fd ff ff       	jmp    f01034d7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103739:	89 ca                	mov    %ecx,%edx
f010373b:	8d 45 14             	lea    0x14(%ebp),%eax
f010373e:	e8 f2 fc ff ff       	call   f0103435 <getint>
f0103743:	89 c6                	mov    %eax,%esi
f0103745:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103747:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010374c:	85 d2                	test   %edx,%edx
f010374e:	0f 89 ad 00 00 00    	jns    f0103801 <vprintfmt+0x34d>
				putch('-', putdat);
f0103754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103758:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010375f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103762:	f7 de                	neg    %esi
f0103764:	83 d7 00             	adc    $0x0,%edi
f0103767:	f7 df                	neg    %edi
			}
			base = 10;
f0103769:	b8 0a 00 00 00       	mov    $0xa,%eax
f010376e:	e9 8e 00 00 00       	jmp    f0103801 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103773:	89 ca                	mov    %ecx,%edx
f0103775:	8d 45 14             	lea    0x14(%ebp),%eax
f0103778:	e8 7e fc ff ff       	call   f01033fb <getuint>
f010377d:	89 c6                	mov    %eax,%esi
f010377f:	89 d7                	mov    %edx,%edi
			base = 10;
f0103781:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103786:	eb 79                	jmp    f0103801 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f0103788:	89 ca                	mov    %ecx,%edx
f010378a:	8d 45 14             	lea    0x14(%ebp),%eax
f010378d:	e8 a3 fc ff ff       	call   f0103435 <getint>
f0103792:	89 c6                	mov    %eax,%esi
f0103794:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f0103796:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010379b:	85 d2                	test   %edx,%edx
f010379d:	79 62                	jns    f0103801 <vprintfmt+0x34d>
				putch('-', putdat);
f010379f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01037a3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01037aa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01037ad:	f7 de                	neg    %esi
f01037af:	83 d7 00             	adc    $0x0,%edi
f01037b2:	f7 df                	neg    %edi
			}
			base = 8;
f01037b4:	b8 08 00 00 00       	mov    $0x8,%eax
f01037b9:	eb 46                	jmp    f0103801 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f01037bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01037bf:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01037c6:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01037c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01037cd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01037d4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01037d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01037da:	8d 50 04             	lea    0x4(%eax),%edx
f01037dd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01037e0:	8b 30                	mov    (%eax),%esi
f01037e2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01037e7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01037ec:	eb 13                	jmp    f0103801 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01037ee:	89 ca                	mov    %ecx,%edx
f01037f0:	8d 45 14             	lea    0x14(%ebp),%eax
f01037f3:	e8 03 fc ff ff       	call   f01033fb <getuint>
f01037f8:	89 c6                	mov    %eax,%esi
f01037fa:	89 d7                	mov    %edx,%edi
			base = 16;
f01037fc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103801:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0103805:	89 54 24 10          	mov    %edx,0x10(%esp)
f0103809:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010380c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103810:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103814:	89 34 24             	mov    %esi,(%esp)
f0103817:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010381b:	89 da                	mov    %ebx,%edx
f010381d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103820:	e8 fb fa ff ff       	call   f0103320 <printnum>
			break;
f0103825:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103828:	e9 aa fc ff ff       	jmp    f01034d7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010382d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103831:	89 14 24             	mov    %edx,(%esp)
f0103834:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103837:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010383a:	e9 98 fc ff ff       	jmp    f01034d7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010383f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103843:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010384a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010384d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103851:	0f 84 80 fc ff ff    	je     f01034d7 <vprintfmt+0x23>
f0103857:	83 ee 01             	sub    $0x1,%esi
f010385a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010385e:	75 f7                	jne    f0103857 <vprintfmt+0x3a3>
f0103860:	e9 72 fc ff ff       	jmp    f01034d7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0103865:	83 c4 4c             	add    $0x4c,%esp
f0103868:	5b                   	pop    %ebx
f0103869:	5e                   	pop    %esi
f010386a:	5f                   	pop    %edi
f010386b:	5d                   	pop    %ebp
f010386c:	c3                   	ret    

f010386d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010386d:	55                   	push   %ebp
f010386e:	89 e5                	mov    %esp,%ebp
f0103870:	83 ec 28             	sub    $0x28,%esp
f0103873:	8b 45 08             	mov    0x8(%ebp),%eax
f0103876:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103879:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010387c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103880:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103883:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010388a:	85 c0                	test   %eax,%eax
f010388c:	74 30                	je     f01038be <vsnprintf+0x51>
f010388e:	85 d2                	test   %edx,%edx
f0103890:	7e 2c                	jle    f01038be <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103892:	8b 45 14             	mov    0x14(%ebp),%eax
f0103895:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103899:	8b 45 10             	mov    0x10(%ebp),%eax
f010389c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01038a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038a7:	c7 04 24 6f 34 10 f0 	movl   $0xf010346f,(%esp)
f01038ae:	e8 01 fc ff ff       	call   f01034b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01038b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01038b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01038b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038bc:	eb 05                	jmp    f01038c3 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01038be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01038c3:	c9                   	leave  
f01038c4:	c3                   	ret    

f01038c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01038c5:	55                   	push   %ebp
f01038c6:	89 e5                	mov    %esp,%ebp
f01038c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01038cb:	8d 45 14             	lea    0x14(%ebp),%eax
f01038ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038d2:	8b 45 10             	mov    0x10(%ebp),%eax
f01038d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038d9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e3:	89 04 24             	mov    %eax,(%esp)
f01038e6:	e8 82 ff ff ff       	call   f010386d <vsnprintf>
	va_end(ap);

	return rc;
}
f01038eb:	c9                   	leave  
f01038ec:	c3                   	ret    
f01038ed:	00 00                	add    %al,(%eax)
	...

f01038f0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01038f0:	55                   	push   %ebp
f01038f1:	89 e5                	mov    %esp,%ebp
f01038f3:	57                   	push   %edi
f01038f4:	56                   	push   %esi
f01038f5:	53                   	push   %ebx
f01038f6:	83 ec 1c             	sub    $0x1c,%esp
f01038f9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01038fc:	85 c0                	test   %eax,%eax
f01038fe:	74 10                	je     f0103910 <readline+0x20>
		cprintf("%s", prompt);
f0103900:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103904:	c7 04 24 0f 4d 10 f0 	movl   $0xf0104d0f,(%esp)
f010390b:	e8 26 f3 ff ff       	call   f0102c36 <cprintf>

	i = 0;
	echoing = iscons(0);
f0103910:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103917:	e8 e0 cd ff ff       	call   f01006fc <iscons>
f010391c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010391e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103923:	e8 c3 cd ff ff       	call   f01006eb <getchar>
f0103928:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010392a:	85 c0                	test   %eax,%eax
f010392c:	79 17                	jns    f0103945 <readline+0x55>
			cprintf("read error: %e\n", c);
f010392e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103932:	c7 04 24 c0 54 10 f0 	movl   $0xf01054c0,(%esp)
f0103939:	e8 f8 f2 ff ff       	call   f0102c36 <cprintf>
			return NULL;
f010393e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103943:	eb 61                	jmp    f01039a6 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103945:	83 f8 1f             	cmp    $0x1f,%eax
f0103948:	7e 1f                	jle    f0103969 <readline+0x79>
f010394a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103950:	7f 17                	jg     f0103969 <readline+0x79>
			if (echoing)
f0103952:	85 ff                	test   %edi,%edi
f0103954:	74 08                	je     f010395e <readline+0x6e>
				cputchar(c);
f0103956:	89 04 24             	mov    %eax,(%esp)
f0103959:	e8 7a cd ff ff       	call   f01006d8 <cputchar>
			buf[i++] = c;
f010395e:	88 9e 00 26 17 f0    	mov    %bl,-0xfe8da00(%esi)
f0103964:	83 c6 01             	add    $0x1,%esi
f0103967:	eb ba                	jmp    f0103923 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0103969:	83 fb 08             	cmp    $0x8,%ebx
f010396c:	75 15                	jne    f0103983 <readline+0x93>
f010396e:	85 f6                	test   %esi,%esi
f0103970:	7e 11                	jle    f0103983 <readline+0x93>
			if (echoing)
f0103972:	85 ff                	test   %edi,%edi
f0103974:	74 08                	je     f010397e <readline+0x8e>
				cputchar(c);
f0103976:	89 1c 24             	mov    %ebx,(%esp)
f0103979:	e8 5a cd ff ff       	call   f01006d8 <cputchar>
			i--;
f010397e:	83 ee 01             	sub    $0x1,%esi
f0103981:	eb a0                	jmp    f0103923 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103983:	83 fb 0a             	cmp    $0xa,%ebx
f0103986:	74 05                	je     f010398d <readline+0x9d>
f0103988:	83 fb 0d             	cmp    $0xd,%ebx
f010398b:	75 96                	jne    f0103923 <readline+0x33>
			if (echoing)
f010398d:	85 ff                	test   %edi,%edi
f010398f:	90                   	nop
f0103990:	74 08                	je     f010399a <readline+0xaa>
				cputchar(c);
f0103992:	89 1c 24             	mov    %ebx,(%esp)
f0103995:	e8 3e cd ff ff       	call   f01006d8 <cputchar>
			buf[i] = 0;
f010399a:	c6 86 00 26 17 f0 00 	movb   $0x0,-0xfe8da00(%esi)
			return buf;
f01039a1:	b8 00 26 17 f0       	mov    $0xf0172600,%eax
		}
	}
}
f01039a6:	83 c4 1c             	add    $0x1c,%esp
f01039a9:	5b                   	pop    %ebx
f01039aa:	5e                   	pop    %esi
f01039ab:	5f                   	pop    %edi
f01039ac:	5d                   	pop    %ebp
f01039ad:	c3                   	ret    
	...

f01039b0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01039b0:	55                   	push   %ebp
f01039b1:	89 e5                	mov    %esp,%ebp
f01039b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01039b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01039bb:	80 3a 00             	cmpb   $0x0,(%edx)
f01039be:	74 09                	je     f01039c9 <strlen+0x19>
		n++;
f01039c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01039c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01039c7:	75 f7                	jne    f01039c0 <strlen+0x10>
		n++;
	return n;
}
f01039c9:	5d                   	pop    %ebp
f01039ca:	c3                   	ret    

f01039cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01039cb:	55                   	push   %ebp
f01039cc:	89 e5                	mov    %esp,%ebp
f01039ce:	53                   	push   %ebx
f01039cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01039d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01039d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01039da:	85 c9                	test   %ecx,%ecx
f01039dc:	74 1a                	je     f01039f8 <strnlen+0x2d>
f01039de:	80 3b 00             	cmpb   $0x0,(%ebx)
f01039e1:	74 15                	je     f01039f8 <strnlen+0x2d>
f01039e3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f01039e8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01039ea:	39 ca                	cmp    %ecx,%edx
f01039ec:	74 0a                	je     f01039f8 <strnlen+0x2d>
f01039ee:	83 c2 01             	add    $0x1,%edx
f01039f1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f01039f6:	75 f0                	jne    f01039e8 <strnlen+0x1d>
		n++;
	return n;
}
f01039f8:	5b                   	pop    %ebx
f01039f9:	5d                   	pop    %ebp
f01039fa:	c3                   	ret    

f01039fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01039fb:	55                   	push   %ebp
f01039fc:	89 e5                	mov    %esp,%ebp
f01039fe:	53                   	push   %ebx
f01039ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103a05:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a0a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103a0e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103a11:	83 c2 01             	add    $0x1,%edx
f0103a14:	84 c9                	test   %cl,%cl
f0103a16:	75 f2                	jne    f0103a0a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103a18:	5b                   	pop    %ebx
f0103a19:	5d                   	pop    %ebp
f0103a1a:	c3                   	ret    

f0103a1b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103a1b:	55                   	push   %ebp
f0103a1c:	89 e5                	mov    %esp,%ebp
f0103a1e:	56                   	push   %esi
f0103a1f:	53                   	push   %ebx
f0103a20:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a23:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a26:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103a29:	85 f6                	test   %esi,%esi
f0103a2b:	74 18                	je     f0103a45 <strncpy+0x2a>
f0103a2d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103a32:	0f b6 1a             	movzbl (%edx),%ebx
f0103a35:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103a38:	80 3a 01             	cmpb   $0x1,(%edx)
f0103a3b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103a3e:	83 c1 01             	add    $0x1,%ecx
f0103a41:	39 f1                	cmp    %esi,%ecx
f0103a43:	75 ed                	jne    f0103a32 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103a45:	5b                   	pop    %ebx
f0103a46:	5e                   	pop    %esi
f0103a47:	5d                   	pop    %ebp
f0103a48:	c3                   	ret    

f0103a49 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103a49:	55                   	push   %ebp
f0103a4a:	89 e5                	mov    %esp,%ebp
f0103a4c:	57                   	push   %edi
f0103a4d:	56                   	push   %esi
f0103a4e:	53                   	push   %ebx
f0103a4f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103a52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a55:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103a58:	89 f8                	mov    %edi,%eax
f0103a5a:	85 f6                	test   %esi,%esi
f0103a5c:	74 2b                	je     f0103a89 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0103a5e:	83 fe 01             	cmp    $0x1,%esi
f0103a61:	74 23                	je     f0103a86 <strlcpy+0x3d>
f0103a63:	0f b6 0b             	movzbl (%ebx),%ecx
f0103a66:	84 c9                	test   %cl,%cl
f0103a68:	74 1c                	je     f0103a86 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103a6a:	83 ee 02             	sub    $0x2,%esi
f0103a6d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103a72:	88 08                	mov    %cl,(%eax)
f0103a74:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103a77:	39 f2                	cmp    %esi,%edx
f0103a79:	74 0b                	je     f0103a86 <strlcpy+0x3d>
f0103a7b:	83 c2 01             	add    $0x1,%edx
f0103a7e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103a82:	84 c9                	test   %cl,%cl
f0103a84:	75 ec                	jne    f0103a72 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0103a86:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103a89:	29 f8                	sub    %edi,%eax
}
f0103a8b:	5b                   	pop    %ebx
f0103a8c:	5e                   	pop    %esi
f0103a8d:	5f                   	pop    %edi
f0103a8e:	5d                   	pop    %ebp
f0103a8f:	c3                   	ret    

f0103a90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103a90:	55                   	push   %ebp
f0103a91:	89 e5                	mov    %esp,%ebp
f0103a93:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103a96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103a99:	0f b6 01             	movzbl (%ecx),%eax
f0103a9c:	84 c0                	test   %al,%al
f0103a9e:	74 16                	je     f0103ab6 <strcmp+0x26>
f0103aa0:	3a 02                	cmp    (%edx),%al
f0103aa2:	75 12                	jne    f0103ab6 <strcmp+0x26>
		p++, q++;
f0103aa4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103aa7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0103aab:	84 c0                	test   %al,%al
f0103aad:	74 07                	je     f0103ab6 <strcmp+0x26>
f0103aaf:	83 c1 01             	add    $0x1,%ecx
f0103ab2:	3a 02                	cmp    (%edx),%al
f0103ab4:	74 ee                	je     f0103aa4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103ab6:	0f b6 c0             	movzbl %al,%eax
f0103ab9:	0f b6 12             	movzbl (%edx),%edx
f0103abc:	29 d0                	sub    %edx,%eax
}
f0103abe:	5d                   	pop    %ebp
f0103abf:	c3                   	ret    

f0103ac0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103ac0:	55                   	push   %ebp
f0103ac1:	89 e5                	mov    %esp,%ebp
f0103ac3:	53                   	push   %ebx
f0103ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103ac7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103aca:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103acd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103ad2:	85 d2                	test   %edx,%edx
f0103ad4:	74 28                	je     f0103afe <strncmp+0x3e>
f0103ad6:	0f b6 01             	movzbl (%ecx),%eax
f0103ad9:	84 c0                	test   %al,%al
f0103adb:	74 24                	je     f0103b01 <strncmp+0x41>
f0103add:	3a 03                	cmp    (%ebx),%al
f0103adf:	75 20                	jne    f0103b01 <strncmp+0x41>
f0103ae1:	83 ea 01             	sub    $0x1,%edx
f0103ae4:	74 13                	je     f0103af9 <strncmp+0x39>
		n--, p++, q++;
f0103ae6:	83 c1 01             	add    $0x1,%ecx
f0103ae9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103aec:	0f b6 01             	movzbl (%ecx),%eax
f0103aef:	84 c0                	test   %al,%al
f0103af1:	74 0e                	je     f0103b01 <strncmp+0x41>
f0103af3:	3a 03                	cmp    (%ebx),%al
f0103af5:	74 ea                	je     f0103ae1 <strncmp+0x21>
f0103af7:	eb 08                	jmp    f0103b01 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103af9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103afe:	5b                   	pop    %ebx
f0103aff:	5d                   	pop    %ebp
f0103b00:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103b01:	0f b6 01             	movzbl (%ecx),%eax
f0103b04:	0f b6 13             	movzbl (%ebx),%edx
f0103b07:	29 d0                	sub    %edx,%eax
f0103b09:	eb f3                	jmp    f0103afe <strncmp+0x3e>

f0103b0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103b0b:	55                   	push   %ebp
f0103b0c:	89 e5                	mov    %esp,%ebp
f0103b0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b15:	0f b6 10             	movzbl (%eax),%edx
f0103b18:	84 d2                	test   %dl,%dl
f0103b1a:	74 1c                	je     f0103b38 <strchr+0x2d>
		if (*s == c)
f0103b1c:	38 ca                	cmp    %cl,%dl
f0103b1e:	75 09                	jne    f0103b29 <strchr+0x1e>
f0103b20:	eb 1b                	jmp    f0103b3d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103b22:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0103b25:	38 ca                	cmp    %cl,%dl
f0103b27:	74 14                	je     f0103b3d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103b29:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0103b2d:	84 d2                	test   %dl,%dl
f0103b2f:	75 f1                	jne    f0103b22 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0103b31:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b36:	eb 05                	jmp    f0103b3d <strchr+0x32>
f0103b38:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b3d:	5d                   	pop    %ebp
f0103b3e:	c3                   	ret    

f0103b3f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103b3f:	55                   	push   %ebp
f0103b40:	89 e5                	mov    %esp,%ebp
f0103b42:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b45:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103b49:	0f b6 10             	movzbl (%eax),%edx
f0103b4c:	84 d2                	test   %dl,%dl
f0103b4e:	74 14                	je     f0103b64 <strfind+0x25>
		if (*s == c)
f0103b50:	38 ca                	cmp    %cl,%dl
f0103b52:	75 06                	jne    f0103b5a <strfind+0x1b>
f0103b54:	eb 0e                	jmp    f0103b64 <strfind+0x25>
f0103b56:	38 ca                	cmp    %cl,%dl
f0103b58:	74 0a                	je     f0103b64 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103b5a:	83 c0 01             	add    $0x1,%eax
f0103b5d:	0f b6 10             	movzbl (%eax),%edx
f0103b60:	84 d2                	test   %dl,%dl
f0103b62:	75 f2                	jne    f0103b56 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0103b64:	5d                   	pop    %ebp
f0103b65:	c3                   	ret    

f0103b66 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0103b66:	55                   	push   %ebp
f0103b67:	89 e5                	mov    %esp,%ebp
f0103b69:	53                   	push   %ebx
f0103b6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0103b73:	89 da                	mov    %ebx,%edx
f0103b75:	83 ea 01             	sub    $0x1,%edx
f0103b78:	78 0d                	js     f0103b87 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f0103b7a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f0103b7c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f0103b7e:	88 0a                	mov    %cl,(%edx)
f0103b80:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0103b83:	39 da                	cmp    %ebx,%edx
f0103b85:	75 f7                	jne    f0103b7e <memset+0x18>
		*p++ = c;

	return v;
}
f0103b87:	5b                   	pop    %ebx
f0103b88:	5d                   	pop    %ebp
f0103b89:	c3                   	ret    

f0103b8a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f0103b8a:	55                   	push   %ebp
f0103b8b:	89 e5                	mov    %esp,%ebp
f0103b8d:	57                   	push   %edi
f0103b8e:	56                   	push   %esi
f0103b8f:	53                   	push   %ebx
f0103b90:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b93:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103b99:	39 c6                	cmp    %eax,%esi
f0103b9b:	72 0b                	jb     f0103ba8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0103b9d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ba2:	85 db                	test   %ebx,%ebx
f0103ba4:	75 29                	jne    f0103bcf <memmove+0x45>
f0103ba6:	eb 35                	jmp    f0103bdd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103ba8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f0103bab:	39 c8                	cmp    %ecx,%eax
f0103bad:	73 ee                	jae    f0103b9d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f0103baf:	85 db                	test   %ebx,%ebx
f0103bb1:	74 2a                	je     f0103bdd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0103bb3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f0103bb6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f0103bb8:	f7 db                	neg    %ebx
f0103bba:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f0103bbd:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f0103bbf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0103bc4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0103bc8:	83 ea 01             	sub    $0x1,%edx
f0103bcb:	75 f2                	jne    f0103bbf <memmove+0x35>
f0103bcd:	eb 0e                	jmp    f0103bdd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0103bcf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0103bd3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103bd6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0103bd9:	39 d3                	cmp    %edx,%ebx
f0103bdb:	75 f2                	jne    f0103bcf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f0103bdd:	5b                   	pop    %ebx
f0103bde:	5e                   	pop    %esi
f0103bdf:	5f                   	pop    %edi
f0103be0:	5d                   	pop    %ebp
f0103be1:	c3                   	ret    

f0103be2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0103be2:	55                   	push   %ebp
f0103be3:	89 e5                	mov    %esp,%ebp
f0103be5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103be8:	8b 45 10             	mov    0x10(%ebp),%eax
f0103beb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103bef:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bf6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bf9:	89 04 24             	mov    %eax,(%esp)
f0103bfc:	e8 89 ff ff ff       	call   f0103b8a <memmove>
}
f0103c01:	c9                   	leave  
f0103c02:	c3                   	ret    

f0103c03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103c03:	55                   	push   %ebp
f0103c04:	89 e5                	mov    %esp,%ebp
f0103c06:	57                   	push   %edi
f0103c07:	56                   	push   %esi
f0103c08:	53                   	push   %ebx
f0103c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103c0c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103c0f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103c12:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c17:	85 ff                	test   %edi,%edi
f0103c19:	74 37                	je     f0103c52 <memcmp+0x4f>
		if (*s1 != *s2)
f0103c1b:	0f b6 03             	movzbl (%ebx),%eax
f0103c1e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c21:	83 ef 01             	sub    $0x1,%edi
f0103c24:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0103c29:	38 c8                	cmp    %cl,%al
f0103c2b:	74 1c                	je     f0103c49 <memcmp+0x46>
f0103c2d:	eb 10                	jmp    f0103c3f <memcmp+0x3c>
f0103c2f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0103c34:	83 c2 01             	add    $0x1,%edx
f0103c37:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0103c3b:	38 c8                	cmp    %cl,%al
f0103c3d:	74 0a                	je     f0103c49 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0103c3f:	0f b6 c0             	movzbl %al,%eax
f0103c42:	0f b6 c9             	movzbl %cl,%ecx
f0103c45:	29 c8                	sub    %ecx,%eax
f0103c47:	eb 09                	jmp    f0103c52 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103c49:	39 fa                	cmp    %edi,%edx
f0103c4b:	75 e2                	jne    f0103c2f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c52:	5b                   	pop    %ebx
f0103c53:	5e                   	pop    %esi
f0103c54:	5f                   	pop    %edi
f0103c55:	5d                   	pop    %ebp
f0103c56:	c3                   	ret    

f0103c57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103c57:	55                   	push   %ebp
f0103c58:	89 e5                	mov    %esp,%ebp
f0103c5a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103c5d:	89 c2                	mov    %eax,%edx
f0103c5f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103c62:	39 d0                	cmp    %edx,%eax
f0103c64:	73 15                	jae    f0103c7b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103c66:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0103c6a:	38 08                	cmp    %cl,(%eax)
f0103c6c:	75 06                	jne    f0103c74 <memfind+0x1d>
f0103c6e:	eb 0b                	jmp    f0103c7b <memfind+0x24>
f0103c70:	38 08                	cmp    %cl,(%eax)
f0103c72:	74 07                	je     f0103c7b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103c74:	83 c0 01             	add    $0x1,%eax
f0103c77:	39 d0                	cmp    %edx,%eax
f0103c79:	75 f5                	jne    f0103c70 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103c7b:	5d                   	pop    %ebp
f0103c7c:	c3                   	ret    

f0103c7d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103c7d:	55                   	push   %ebp
f0103c7e:	89 e5                	mov    %esp,%ebp
f0103c80:	57                   	push   %edi
f0103c81:	56                   	push   %esi
f0103c82:	53                   	push   %ebx
f0103c83:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103c89:	0f b6 02             	movzbl (%edx),%eax
f0103c8c:	3c 20                	cmp    $0x20,%al
f0103c8e:	74 04                	je     f0103c94 <strtol+0x17>
f0103c90:	3c 09                	cmp    $0x9,%al
f0103c92:	75 0e                	jne    f0103ca2 <strtol+0x25>
		s++;
f0103c94:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103c97:	0f b6 02             	movzbl (%edx),%eax
f0103c9a:	3c 20                	cmp    $0x20,%al
f0103c9c:	74 f6                	je     f0103c94 <strtol+0x17>
f0103c9e:	3c 09                	cmp    $0x9,%al
f0103ca0:	74 f2                	je     f0103c94 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103ca2:	3c 2b                	cmp    $0x2b,%al
f0103ca4:	75 0a                	jne    f0103cb0 <strtol+0x33>
		s++;
f0103ca6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103ca9:	bf 00 00 00 00       	mov    $0x0,%edi
f0103cae:	eb 10                	jmp    f0103cc0 <strtol+0x43>
f0103cb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103cb5:	3c 2d                	cmp    $0x2d,%al
f0103cb7:	75 07                	jne    f0103cc0 <strtol+0x43>
		s++, neg = 1;
f0103cb9:	83 c2 01             	add    $0x1,%edx
f0103cbc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103cc0:	85 db                	test   %ebx,%ebx
f0103cc2:	0f 94 c0             	sete   %al
f0103cc5:	74 05                	je     f0103ccc <strtol+0x4f>
f0103cc7:	83 fb 10             	cmp    $0x10,%ebx
f0103cca:	75 15                	jne    f0103ce1 <strtol+0x64>
f0103ccc:	80 3a 30             	cmpb   $0x30,(%edx)
f0103ccf:	75 10                	jne    f0103ce1 <strtol+0x64>
f0103cd1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103cd5:	75 0a                	jne    f0103ce1 <strtol+0x64>
		s += 2, base = 16;
f0103cd7:	83 c2 02             	add    $0x2,%edx
f0103cda:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103cdf:	eb 13                	jmp    f0103cf4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0103ce1:	84 c0                	test   %al,%al
f0103ce3:	74 0f                	je     f0103cf4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103ce5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103cea:	80 3a 30             	cmpb   $0x30,(%edx)
f0103ced:	75 05                	jne    f0103cf4 <strtol+0x77>
		s++, base = 8;
f0103cef:	83 c2 01             	add    $0x1,%edx
f0103cf2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0103cf4:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cf9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103cfb:	0f b6 0a             	movzbl (%edx),%ecx
f0103cfe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103d01:	80 fb 09             	cmp    $0x9,%bl
f0103d04:	77 08                	ja     f0103d0e <strtol+0x91>
			dig = *s - '0';
f0103d06:	0f be c9             	movsbl %cl,%ecx
f0103d09:	83 e9 30             	sub    $0x30,%ecx
f0103d0c:	eb 1e                	jmp    f0103d2c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0103d0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0103d11:	80 fb 19             	cmp    $0x19,%bl
f0103d14:	77 08                	ja     f0103d1e <strtol+0xa1>
			dig = *s - 'a' + 10;
f0103d16:	0f be c9             	movsbl %cl,%ecx
f0103d19:	83 e9 57             	sub    $0x57,%ecx
f0103d1c:	eb 0e                	jmp    f0103d2c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0103d1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103d21:	80 fb 19             	cmp    $0x19,%bl
f0103d24:	77 14                	ja     f0103d3a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103d26:	0f be c9             	movsbl %cl,%ecx
f0103d29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103d2c:	39 f1                	cmp    %esi,%ecx
f0103d2e:	7d 0e                	jge    f0103d3e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103d30:	83 c2 01             	add    $0x1,%edx
f0103d33:	0f af c6             	imul   %esi,%eax
f0103d36:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0103d38:	eb c1                	jmp    f0103cfb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103d3a:	89 c1                	mov    %eax,%ecx
f0103d3c:	eb 02                	jmp    f0103d40 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103d3e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103d40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103d44:	74 05                	je     f0103d4b <strtol+0xce>
		*endptr = (char *) s;
f0103d46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103d49:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103d4b:	89 ca                	mov    %ecx,%edx
f0103d4d:	f7 da                	neg    %edx
f0103d4f:	85 ff                	test   %edi,%edi
f0103d51:	0f 45 c2             	cmovne %edx,%eax
}
f0103d54:	5b                   	pop    %ebx
f0103d55:	5e                   	pop    %esi
f0103d56:	5f                   	pop    %edi
f0103d57:	5d                   	pop    %ebp
f0103d58:	c3                   	ret    
f0103d59:	00 00                	add    %al,(%eax)
f0103d5b:	00 00                	add    %al,(%eax)
f0103d5d:	00 00                	add    %al,(%eax)
	...

f0103d60 <__udivdi3>:
f0103d60:	83 ec 1c             	sub    $0x1c,%esp
f0103d63:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0103d67:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0103d6b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0103d6f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103d73:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103d77:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103d7b:	85 ff                	test   %edi,%edi
f0103d7d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0103d81:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d85:	89 cd                	mov    %ecx,%ebp
f0103d87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d8b:	75 33                	jne    f0103dc0 <__udivdi3+0x60>
f0103d8d:	39 f1                	cmp    %esi,%ecx
f0103d8f:	77 57                	ja     f0103de8 <__udivdi3+0x88>
f0103d91:	85 c9                	test   %ecx,%ecx
f0103d93:	75 0b                	jne    f0103da0 <__udivdi3+0x40>
f0103d95:	b8 01 00 00 00       	mov    $0x1,%eax
f0103d9a:	31 d2                	xor    %edx,%edx
f0103d9c:	f7 f1                	div    %ecx
f0103d9e:	89 c1                	mov    %eax,%ecx
f0103da0:	89 f0                	mov    %esi,%eax
f0103da2:	31 d2                	xor    %edx,%edx
f0103da4:	f7 f1                	div    %ecx
f0103da6:	89 c6                	mov    %eax,%esi
f0103da8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103dac:	f7 f1                	div    %ecx
f0103dae:	89 f2                	mov    %esi,%edx
f0103db0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103db4:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103db8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103dbc:	83 c4 1c             	add    $0x1c,%esp
f0103dbf:	c3                   	ret    
f0103dc0:	31 d2                	xor    %edx,%edx
f0103dc2:	31 c0                	xor    %eax,%eax
f0103dc4:	39 f7                	cmp    %esi,%edi
f0103dc6:	77 e8                	ja     f0103db0 <__udivdi3+0x50>
f0103dc8:	0f bd cf             	bsr    %edi,%ecx
f0103dcb:	83 f1 1f             	xor    $0x1f,%ecx
f0103dce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103dd2:	75 2c                	jne    f0103e00 <__udivdi3+0xa0>
f0103dd4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0103dd8:	76 04                	jbe    f0103dde <__udivdi3+0x7e>
f0103dda:	39 f7                	cmp    %esi,%edi
f0103ddc:	73 d2                	jae    f0103db0 <__udivdi3+0x50>
f0103dde:	31 d2                	xor    %edx,%edx
f0103de0:	b8 01 00 00 00       	mov    $0x1,%eax
f0103de5:	eb c9                	jmp    f0103db0 <__udivdi3+0x50>
f0103de7:	90                   	nop
f0103de8:	89 f2                	mov    %esi,%edx
f0103dea:	f7 f1                	div    %ecx
f0103dec:	31 d2                	xor    %edx,%edx
f0103dee:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103df2:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103df6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103dfa:	83 c4 1c             	add    $0x1c,%esp
f0103dfd:	c3                   	ret    
f0103dfe:	66 90                	xchg   %ax,%ax
f0103e00:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103e05:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e0a:	89 ea                	mov    %ebp,%edx
f0103e0c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103e10:	d3 e7                	shl    %cl,%edi
f0103e12:	89 c1                	mov    %eax,%ecx
f0103e14:	d3 ea                	shr    %cl,%edx
f0103e16:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103e1b:	09 fa                	or     %edi,%edx
f0103e1d:	89 f7                	mov    %esi,%edi
f0103e1f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103e23:	89 f2                	mov    %esi,%edx
f0103e25:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103e29:	d3 e5                	shl    %cl,%ebp
f0103e2b:	89 c1                	mov    %eax,%ecx
f0103e2d:	d3 ef                	shr    %cl,%edi
f0103e2f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103e34:	d3 e2                	shl    %cl,%edx
f0103e36:	89 c1                	mov    %eax,%ecx
f0103e38:	d3 ee                	shr    %cl,%esi
f0103e3a:	09 d6                	or     %edx,%esi
f0103e3c:	89 fa                	mov    %edi,%edx
f0103e3e:	89 f0                	mov    %esi,%eax
f0103e40:	f7 74 24 0c          	divl   0xc(%esp)
f0103e44:	89 d7                	mov    %edx,%edi
f0103e46:	89 c6                	mov    %eax,%esi
f0103e48:	f7 e5                	mul    %ebp
f0103e4a:	39 d7                	cmp    %edx,%edi
f0103e4c:	72 22                	jb     f0103e70 <__udivdi3+0x110>
f0103e4e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0103e52:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103e57:	d3 e5                	shl    %cl,%ebp
f0103e59:	39 c5                	cmp    %eax,%ebp
f0103e5b:	73 04                	jae    f0103e61 <__udivdi3+0x101>
f0103e5d:	39 d7                	cmp    %edx,%edi
f0103e5f:	74 0f                	je     f0103e70 <__udivdi3+0x110>
f0103e61:	89 f0                	mov    %esi,%eax
f0103e63:	31 d2                	xor    %edx,%edx
f0103e65:	e9 46 ff ff ff       	jmp    f0103db0 <__udivdi3+0x50>
f0103e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103e70:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103e73:	31 d2                	xor    %edx,%edx
f0103e75:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103e79:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103e7d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103e81:	83 c4 1c             	add    $0x1c,%esp
f0103e84:	c3                   	ret    
	...

f0103e90 <__umoddi3>:
f0103e90:	83 ec 1c             	sub    $0x1c,%esp
f0103e93:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0103e97:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0103e9b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0103e9f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103ea3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103ea7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103eab:	85 ed                	test   %ebp,%ebp
f0103ead:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0103eb1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103eb5:	89 cf                	mov    %ecx,%edi
f0103eb7:	89 04 24             	mov    %eax,(%esp)
f0103eba:	89 f2                	mov    %esi,%edx
f0103ebc:	75 1a                	jne    f0103ed8 <__umoddi3+0x48>
f0103ebe:	39 f1                	cmp    %esi,%ecx
f0103ec0:	76 4e                	jbe    f0103f10 <__umoddi3+0x80>
f0103ec2:	f7 f1                	div    %ecx
f0103ec4:	89 d0                	mov    %edx,%eax
f0103ec6:	31 d2                	xor    %edx,%edx
f0103ec8:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103ecc:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103ed0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103ed4:	83 c4 1c             	add    $0x1c,%esp
f0103ed7:	c3                   	ret    
f0103ed8:	39 f5                	cmp    %esi,%ebp
f0103eda:	77 54                	ja     f0103f30 <__umoddi3+0xa0>
f0103edc:	0f bd c5             	bsr    %ebp,%eax
f0103edf:	83 f0 1f             	xor    $0x1f,%eax
f0103ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee6:	75 60                	jne    f0103f48 <__umoddi3+0xb8>
f0103ee8:	3b 0c 24             	cmp    (%esp),%ecx
f0103eeb:	0f 87 07 01 00 00    	ja     f0103ff8 <__umoddi3+0x168>
f0103ef1:	89 f2                	mov    %esi,%edx
f0103ef3:	8b 34 24             	mov    (%esp),%esi
f0103ef6:	29 ce                	sub    %ecx,%esi
f0103ef8:	19 ea                	sbb    %ebp,%edx
f0103efa:	89 34 24             	mov    %esi,(%esp)
f0103efd:	8b 04 24             	mov    (%esp),%eax
f0103f00:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103f04:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103f08:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103f0c:	83 c4 1c             	add    $0x1c,%esp
f0103f0f:	c3                   	ret    
f0103f10:	85 c9                	test   %ecx,%ecx
f0103f12:	75 0b                	jne    f0103f1f <__umoddi3+0x8f>
f0103f14:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f19:	31 d2                	xor    %edx,%edx
f0103f1b:	f7 f1                	div    %ecx
f0103f1d:	89 c1                	mov    %eax,%ecx
f0103f1f:	89 f0                	mov    %esi,%eax
f0103f21:	31 d2                	xor    %edx,%edx
f0103f23:	f7 f1                	div    %ecx
f0103f25:	8b 04 24             	mov    (%esp),%eax
f0103f28:	f7 f1                	div    %ecx
f0103f2a:	eb 98                	jmp    f0103ec4 <__umoddi3+0x34>
f0103f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103f30:	89 f2                	mov    %esi,%edx
f0103f32:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103f36:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103f3a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103f3e:	83 c4 1c             	add    $0x1c,%esp
f0103f41:	c3                   	ret    
f0103f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f48:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f4d:	89 e8                	mov    %ebp,%eax
f0103f4f:	bd 20 00 00 00       	mov    $0x20,%ebp
f0103f54:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0103f58:	89 fa                	mov    %edi,%edx
f0103f5a:	d3 e0                	shl    %cl,%eax
f0103f5c:	89 e9                	mov    %ebp,%ecx
f0103f5e:	d3 ea                	shr    %cl,%edx
f0103f60:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f65:	09 c2                	or     %eax,%edx
f0103f67:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103f6b:	89 14 24             	mov    %edx,(%esp)
f0103f6e:	89 f2                	mov    %esi,%edx
f0103f70:	d3 e7                	shl    %cl,%edi
f0103f72:	89 e9                	mov    %ebp,%ecx
f0103f74:	d3 ea                	shr    %cl,%edx
f0103f76:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103f7f:	d3 e6                	shl    %cl,%esi
f0103f81:	89 e9                	mov    %ebp,%ecx
f0103f83:	d3 e8                	shr    %cl,%eax
f0103f85:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103f8a:	09 f0                	or     %esi,%eax
f0103f8c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103f90:	f7 34 24             	divl   (%esp)
f0103f93:	d3 e6                	shl    %cl,%esi
f0103f95:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103f99:	89 d6                	mov    %edx,%esi
f0103f9b:	f7 e7                	mul    %edi
f0103f9d:	39 d6                	cmp    %edx,%esi
f0103f9f:	89 c1                	mov    %eax,%ecx
f0103fa1:	89 d7                	mov    %edx,%edi
f0103fa3:	72 3f                	jb     f0103fe4 <__umoddi3+0x154>
f0103fa5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0103fa9:	72 35                	jb     f0103fe0 <__umoddi3+0x150>
f0103fab:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103faf:	29 c8                	sub    %ecx,%eax
f0103fb1:	19 fe                	sbb    %edi,%esi
f0103fb3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103fb8:	89 f2                	mov    %esi,%edx
f0103fba:	d3 e8                	shr    %cl,%eax
f0103fbc:	89 e9                	mov    %ebp,%ecx
f0103fbe:	d3 e2                	shl    %cl,%edx
f0103fc0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0103fc5:	09 d0                	or     %edx,%eax
f0103fc7:	89 f2                	mov    %esi,%edx
f0103fc9:	d3 ea                	shr    %cl,%edx
f0103fcb:	8b 74 24 10          	mov    0x10(%esp),%esi
f0103fcf:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0103fd3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0103fd7:	83 c4 1c             	add    $0x1c,%esp
f0103fda:	c3                   	ret    
f0103fdb:	90                   	nop
f0103fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103fe0:	39 d6                	cmp    %edx,%esi
f0103fe2:	75 c7                	jne    f0103fab <__umoddi3+0x11b>
f0103fe4:	89 d7                	mov    %edx,%edi
f0103fe6:	89 c1                	mov    %eax,%ecx
f0103fe8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0103fec:	1b 3c 24             	sbb    (%esp),%edi
f0103fef:	eb ba                	jmp    f0103fab <__umoddi3+0x11b>
f0103ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ff8:	39 f5                	cmp    %esi,%ebp
f0103ffa:	0f 82 f1 fe ff ff    	jb     f0103ef1 <__umoddi3+0x61>
f0104000:	e9 f8 fe ff ff       	jmp    f0103efd <__umoddi3+0x6d>
