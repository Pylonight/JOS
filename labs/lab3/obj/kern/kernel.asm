
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
f0100063:	e8 4e 3e 00 00       	call   f0103eb6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 44 06 00 00       	call   f01006b1 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 60 43 10 f0 	movl   $0xf0104360,(%esp)
f010007c:	e8 0d 2f 00 00       	call   f0102f8e <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100081:	e8 d2 0a 00 00       	call   f0100b58 <i386_detect_memory>
	i386_vm_init();
f0100086:	e8 78 10 00 00       	call   f0101103 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 91 28 00 00       	call   f0102926 <env_init>
	idt_init();
f0100095:	e8 0e 2f 00 00       	call   f0102fa8 <idt_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE);
#else
	// Touch all you want.
	ENV_CREATE(user_hello);
f010009a:	c7 44 24 04 96 78 00 	movl   $0x7896,0x4(%esp)
f01000a1:	00 
f01000a2:	c7 04 24 78 83 11 f0 	movl   $0xf0118378,(%esp)
f01000a9:	e8 b0 2a 00 00       	call   f0102b5e <env_create>
#endif // TEST*


	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000ae:	a1 60 2d 17 f0       	mov    0xf0172d60,%eax
f01000b3:	89 04 24             	mov    %eax,(%esp)
f01000b6:	e8 14 2e 00 00       	call   f0102ecf <env_run>

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
f01000e0:	c7 04 24 7b 43 10 f0 	movl   $0xf010437b,(%esp)
f01000e7:	e8 a2 2e 00 00       	call   f0102f8e <cprintf>
	vcprintf(fmt, ap);
f01000ec:	8d 45 14             	lea    0x14(%ebp),%eax
f01000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000f3:	8b 45 10             	mov    0x10(%ebp),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 5d 2e 00 00       	call   f0102f5b <vcprintf>
	cprintf("\n");
f01000fe:	c7 04 24 80 52 10 f0 	movl   $0xf0105280,(%esp)
f0100105:	e8 84 2e 00 00       	call   f0102f8e <cprintf>
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
f010012c:	c7 04 24 93 43 10 f0 	movl   $0xf0104393,(%esp)
f0100133:	e8 56 2e 00 00       	call   f0102f8e <cprintf>
	vcprintf(fmt, ap);
f0100138:	8d 45 14             	lea    0x14(%ebp),%eax
f010013b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010013f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100142:	89 04 24             	mov    %eax,(%esp)
f0100145:	e8 11 2e 00 00       	call   f0102f5b <vcprintf>
	cprintf("\n");
f010014a:	c7 04 24 80 52 10 f0 	movl   $0xf0105280,(%esp)
f0100151:	e8 38 2e 00 00       	call   f0102f8e <cprintf>
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
f01001c2:	0f b6 82 c0 45 10 f0 	movzbl -0xfefba40(%edx),%eax
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
f01001ff:	0f b6 82 c0 45 10 f0 	movzbl -0xfefba40(%edx),%eax
f0100206:	0b 05 30 2b 17 f0    	or     0xf0172b30,%eax
	shift ^= togglecode[data];
f010020c:	0f b6 8a c0 46 10 f0 	movzbl -0xfefb940(%edx),%ecx
f0100213:	31 c8                	xor    %ecx,%eax
f0100215:	a3 30 2b 17 f0       	mov    %eax,0xf0172b30

	c = charcode[shift & (CTL | SHIFT)][data];
f010021a:	89 c1                	mov    %eax,%ecx
f010021c:	83 e1 03             	and    $0x3,%ecx
f010021f:	8b 0c 8d c0 47 10 f0 	mov    -0xfefb840(,%ecx,4),%ecx
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
f0100255:	c7 04 24 ad 43 10 f0 	movl   $0xf01043ad,(%esp)
f010025c:	e8 2d 2d 00 00       	call   f0102f8e <cprintf>
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
f01004aa:	ff 24 95 e0 43 10 f0 	jmp    *-0xfefbc20(,%edx,4)
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
f0100654:	e8 81 38 00 00       	call   f0103eda <memmove>
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
f01006ca:	c7 04 24 b9 43 10 f0 	movl   $0xf01043b9,(%esp)
f01006d1:	e8 b8 28 00 00       	call   f0102f8e <cprintf>
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
f0100716:	c7 04 24 d0 47 10 f0 	movl   $0xf01047d0,(%esp)
f010071d:	e8 6c 28 00 00       	call   f0102f8e <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100722:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100729:	00 
f010072a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100731:	f0 
f0100732:	c7 04 24 9c 48 10 f0 	movl   $0xf010489c,(%esp)
f0100739:	e8 50 28 00 00       	call   f0102f8e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010073e:	c7 44 24 08 55 43 10 	movl   $0x104355,0x8(%esp)
f0100745:	00 
f0100746:	c7 44 24 04 55 43 10 	movl   $0xf0104355,0x4(%esp)
f010074d:	f0 
f010074e:	c7 04 24 c0 48 10 f0 	movl   $0xf01048c0,(%esp)
f0100755:	e8 34 28 00 00       	call   f0102f8e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010075a:	c7 44 24 08 e5 2a 17 	movl   $0x172ae5,0x8(%esp)
f0100761:	00 
f0100762:	c7 44 24 04 e5 2a 17 	movl   $0xf0172ae5,0x4(%esp)
f0100769:	f0 
f010076a:	c7 04 24 e4 48 10 f0 	movl   $0xf01048e4,(%esp)
f0100771:	e8 18 28 00 00       	call   f0102f8e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100776:	c7 44 24 08 10 3a 17 	movl   $0x173a10,0x8(%esp)
f010077d:	00 
f010077e:	c7 44 24 04 10 3a 17 	movl   $0xf0173a10,0x4(%esp)
f0100785:	f0 
f0100786:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f010078d:	e8 fc 27 00 00       	call   f0102f8e <cprintf>
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
f01007ae:	c7 04 24 2c 49 10 f0 	movl   $0xf010492c,(%esp)
f01007b5:	e8 d4 27 00 00       	call   f0102f8e <cprintf>
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
f01007cd:	8b 83 24 4a 10 f0    	mov    -0xfefb5dc(%ebx),%eax
f01007d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d7:	8b 83 20 4a 10 f0    	mov    -0xfefb5e0(%ebx),%eax
f01007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007e1:	c7 04 24 e9 47 10 f0 	movl   $0xf01047e9,(%esp)
f01007e8:	e8 a1 27 00 00       	call   f0102f8e <cprintf>
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
f0100809:	c7 04 24 58 49 10 f0 	movl   $0xf0104958,(%esp)
f0100810:	e8 79 27 00 00       	call   f0102f8e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100815:	c7 04 24 7c 49 10 f0 	movl   $0xf010497c,(%esp)
f010081c:	e8 6d 27 00 00       	call   f0102f8e <cprintf>

	if (tf != NULL)
f0100821:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100825:	74 0b                	je     f0100832 <monitor+0x32>
		print_trapframe(tf);
f0100827:	8b 45 08             	mov    0x8(%ebp),%eax
f010082a:	89 04 24             	mov    %eax,(%esp)
f010082d:	e8 79 28 00 00       	call   f01030ab <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100832:	c7 04 24 f2 47 10 f0 	movl   $0xf01047f2,(%esp)
f0100839:	e8 02 34 00 00       	call   f0103c40 <readline>
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
f0100866:	c7 04 24 f6 47 10 f0 	movl   $0xf01047f6,(%esp)
f010086d:	e8 e9 35 00 00       	call   f0103e5b <strchr>
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
f010088a:	c7 04 24 fb 47 10 f0 	movl   $0xf01047fb,(%esp)
f0100891:	e8 f8 26 00 00       	call   f0102f8e <cprintf>
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
f01008b9:	c7 04 24 f6 47 10 f0 	movl   $0xf01047f6,(%esp)
f01008c0:	e8 96 35 00 00       	call   f0103e5b <strchr>
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
f01008db:	bb 20 4a 10 f0       	mov    $0xf0104a20,%ebx
f01008e0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e5:	8b 03                	mov    (%ebx),%eax
f01008e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008eb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ee:	89 04 24             	mov    %eax,(%esp)
f01008f1:	e8 ea 34 00 00       	call   f0103de0 <strcmp>
f01008f6:	85 c0                	test   %eax,%eax
f01008f8:	75 24                	jne    f010091e <monitor+0x11e>
			return commands[i].func(argc, argv, tf);
f01008fa:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008fd:	8b 55 08             	mov    0x8(%ebp),%edx
f0100900:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100904:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100907:	89 54 24 04          	mov    %edx,0x4(%esp)
f010090b:	89 34 24             	mov    %esi,(%esp)
f010090e:	ff 14 85 28 4a 10 f0 	call   *-0xfefb5d8(,%eax,4)
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
f0100930:	c7 04 24 18 48 10 f0 	movl   $0xf0104818,(%esp)
f0100937:	e8 52 26 00 00       	call   f0102f8e <cprintf>
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
f010095a:	c7 04 24 2e 48 10 f0 	movl   $0xf010482e,(%esp)
f0100961:	e8 28 26 00 00       	call   f0102f8e <cprintf>
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
f0100988:	e8 8d 2a 00 00       	call   f010341a <debuginfo_eip>
f010098d:	85 c0                	test   %eax,%eax
f010098f:	0f 88 a5 00 00 00    	js     f0100a3a <mon_backtrace+0xe9>
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
f0100995:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100998:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010099f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a3:	c7 04 24 8b 43 10 f0 	movl   $0xf010438b,(%esp)
f01009aa:	e8 df 25 00 00       	call   f0102f8e <cprintf>
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f01009af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01009b3:	7e 24                	jle    f01009d9 <mon_backtrace+0x88>
f01009b5:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
f01009ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009bd:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f01009c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009c5:	c7 04 24 40 48 10 f0 	movl   $0xf0104840,(%esp)
f01009cc:	e8 bd 25 00 00       	call   f0102f8e <cprintf>
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
f01009e7:	c7 04 24 43 48 10 f0 	movl   $0xf0104843,(%esp)
f01009ee:	e8 9b 25 00 00       	call   f0102f8e <cprintf>
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
f0100a1a:	c7 04 24 a4 49 10 f0 	movl   $0xf01049a4,(%esp)
f0100a21:	e8 68 25 00 00       	call   f0102f8e <cprintf>
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
f0100a3a:	c7 04 24 4c 48 10 f0 	movl   $0xf010484c,(%esp)
f0100a41:	e8 48 25 00 00       	call   f0102f8e <cprintf>
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
f0100ae4:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f0100aeb:	f0 
f0100aec:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0100af3:	00 
f0100af4:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0100b37:	e8 e4 23 00 00       	call   f0102f20 <mc146818_read>
f0100b3c:	89 c6                	mov    %eax,%esi
f0100b3e:	83 c3 01             	add    $0x1,%ebx
f0100b41:	89 1c 24             	mov    %ebx,(%esp)
f0100b44:	e8 d7 23 00 00       	call   f0102f20 <mc146818_read>
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
f0100bbd:	c7 04 24 68 4a 10 f0 	movl   $0xf0104a68,(%esp)
f0100bc4:	e8 c5 23 00 00       	call   f0102f8e <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100bc9:	a1 4c 2d 17 f0       	mov    0xf0172d4c,%eax
f0100bce:	c1 e8 0a             	shr    $0xa,%eax
f0100bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bd5:	a1 48 2d 17 f0       	mov    0xf0172d48,%eax
f0100bda:	c1 e8 0a             	shr    $0xa,%eax
f0100bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100be1:	c7 04 24 fd 4f 10 f0 	movl   $0xf0104ffd,(%esp)
f0100be8:	e8 a1 23 00 00       	call   f0102f8e <cprintf>
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
f0100ceb:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f0100cf2:	f0 
f0100cf3:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
f0100cfa:	00 
f0100cfb:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0100d4c:	e8 65 31 00 00       	call   f0103eb6 <memset>
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
f0100d6f:	c7 44 24 08 b0 4a 10 	movl   $0xf0104ab0,0x8(%esp)
f0100d76:	f0 
f0100d77:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
f0100d7e:	00 
f0100d7f:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0100e03:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f0100e0a:	f0 
f0100e0b:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
f0100e12:	00 
f0100e13:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0100e7d:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0100e8c:	00 
f0100e8d:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0100e94:	e8 22 f2 ff ff       	call   f01000bb <_panic>
f0100e99:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ea0:	00 
f0100ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ea8:	00 
f0100ea9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100eae:	89 04 24             	mov    %eax,(%esp)
f0100eb1:	e8 00 30 00 00       	call   f0103eb6 <memset>
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
f0100ee6:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f0100eed:	f0 
f0100eee:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100ef5:	00 
f0100ef6:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0100f6e:	c7 44 24 08 d8 4a 10 	movl   $0xf0104ad8,0x8(%esp)
f0100f75:	f0 
f0100f76:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100f7d:	00 
f0100f7e:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0100fe2:	c7 44 24 08 08 4b 10 	movl   $0xf0104b08,0x8(%esp)
f0100fe9:	f0 
f0100fea:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0100ff1:	00 
f0100ff2:	c7 04 24 19 50 10 f0 	movl   $0xf0105019,(%esp)
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
f0101130:	e8 81 2d 00 00       	call   f0103eb6 <memset>
	boot_pgdir = pgdir;
f0101135:	89 1d 08 3a 17 f0    	mov    %ebx,0xf0173a08
	boot_cr3 = PADDR(pgdir);
f010113b:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101141:	77 20                	ja     f0101163 <i386_vm_init+0x60>
f0101143:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101147:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f010114e:	f0 
f010114f:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
f0101156:	00 
f0101157:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101209:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f0101210:	f0 
f0101211:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101218:	00 
f0101219:	c7 04 24 19 50 10 f0 	movl   $0xf0105019,(%esp)
f0101220:	e8 96 ee ff ff       	call   f01000bb <_panic>
		memset(page2kva(pp0), 0x97, 128);
f0101225:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010122c:	00 
f010122d:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101234:	00 
f0101235:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010123a:	89 04 24             	mov    %eax,(%esp)
f010123d:	e8 74 2c 00 00       	call   f0103eb6 <memset>
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
f0101272:	c7 44 24 0c 27 50 10 	movl   $0xf0105027,0xc(%esp)
f0101279:	f0 
f010127a:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101281:	f0 
f0101282:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f0101289:	00 
f010128a:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101291:	e8 25 ee ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f0101296:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101299:	89 04 24             	mov    %eax,(%esp)
f010129c:	e8 6d fa ff ff       	call   f0100d0e <page_alloc>
f01012a1:	85 c0                	test   %eax,%eax
f01012a3:	74 24                	je     f01012c9 <i386_vm_init+0x1c6>
f01012a5:	c7 44 24 0c 52 50 10 	movl   $0xf0105052,0xc(%esp)
f01012ac:	f0 
f01012ad:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01012b4:	f0 
f01012b5:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f01012bc:	00 
f01012bd:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01012c4:	e8 f2 ed ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f01012c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01012cc:	89 04 24             	mov    %eax,(%esp)
f01012cf:	e8 3a fa ff ff       	call   f0100d0e <page_alloc>
f01012d4:	85 c0                	test   %eax,%eax
f01012d6:	74 24                	je     f01012fc <i386_vm_init+0x1f9>
f01012d8:	c7 44 24 0c 68 50 10 	movl   $0xf0105068,0xc(%esp)
f01012df:	f0 
f01012e0:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01012e7:	f0 
f01012e8:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f01012ef:	00 
f01012f0:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01012f7:	e8 bf ed ff ff       	call   f01000bb <_panic>

	assert(pp0);
f01012fc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012ff:	85 c9                	test   %ecx,%ecx
f0101301:	75 24                	jne    f0101327 <i386_vm_init+0x224>
f0101303:	c7 44 24 0c 8c 50 10 	movl   $0xf010508c,0xc(%esp)
f010130a:	f0 
f010130b:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101312:	f0 
f0101313:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f010131a:	00 
f010131b:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101322:	e8 94 ed ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f0101327:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010132a:	85 d2                	test   %edx,%edx
f010132c:	74 04                	je     f0101332 <i386_vm_init+0x22f>
f010132e:	39 d1                	cmp    %edx,%ecx
f0101330:	75 24                	jne    f0101356 <i386_vm_init+0x253>
f0101332:	c7 44 24 0c 7e 50 10 	movl   $0xf010507e,0xc(%esp)
f0101339:	f0 
f010133a:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101341:	f0 
f0101342:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0101349:	00 
f010134a:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101351:	e8 65 ed ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101356:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101359:	85 c0                	test   %eax,%eax
f010135b:	74 08                	je     f0101365 <i386_vm_init+0x262>
f010135d:	39 c2                	cmp    %eax,%edx
f010135f:	74 04                	je     f0101365 <i386_vm_init+0x262>
f0101361:	39 c1                	cmp    %eax,%ecx
f0101363:	75 24                	jne    f0101389 <i386_vm_init+0x286>
f0101365:	c7 44 24 0c 28 4b 10 	movl   $0xf0104b28,0xc(%esp)
f010136c:	f0 
f010136d:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101374:	f0 
f0101375:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f010137c:	00 
f010137d:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01013aa:	c7 44 24 0c 90 50 10 	movl   $0xf0105090,0xc(%esp)
f01013b1:	f0 
f01013b2:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01013b9:	f0 
f01013ba:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f01013c1:	00 
f01013c2:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01013e0:	c7 44 24 0c ac 50 10 	movl   $0xf01050ac,0xc(%esp)
f01013e7:	f0 
f01013e8:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01013ef:	f0 
f01013f0:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f01013f7:	00 
f01013f8:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101416:	c7 44 24 0c c8 50 10 	movl   $0xf01050c8,0xc(%esp)
f010141d:	f0 
f010141e:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101425:	f0 
f0101426:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f010142d:	00 
f010142e:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f010145a:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f0101461:	f0 
f0101462:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101469:	f0 
f010146a:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0101471:	00 
f0101472:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01014c3:	c7 44 24 0c 27 50 10 	movl   $0xf0105027,0xc(%esp)
f01014ca:	f0 
f01014cb:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01014d2:	f0 
f01014d3:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f01014da:	00 
f01014db:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01014e2:	e8 d4 eb ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f01014e7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01014ea:	89 04 24             	mov    %eax,(%esp)
f01014ed:	e8 1c f8 ff ff       	call   f0100d0e <page_alloc>
f01014f2:	85 c0                	test   %eax,%eax
f01014f4:	74 24                	je     f010151a <i386_vm_init+0x417>
f01014f6:	c7 44 24 0c 52 50 10 	movl   $0xf0105052,0xc(%esp)
f01014fd:	f0 
f01014fe:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101505:	f0 
f0101506:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f010150d:	00 
f010150e:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101515:	e8 a1 eb ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f010151a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010151d:	89 04 24             	mov    %eax,(%esp)
f0101520:	e8 e9 f7 ff ff       	call   f0100d0e <page_alloc>
f0101525:	85 c0                	test   %eax,%eax
f0101527:	74 24                	je     f010154d <i386_vm_init+0x44a>
f0101529:	c7 44 24 0c 68 50 10 	movl   $0xf0105068,0xc(%esp)
f0101530:	f0 
f0101531:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101538:	f0 
f0101539:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f0101540:	00 
f0101541:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101548:	e8 6e eb ff ff       	call   f01000bb <_panic>
	assert(pp0);
f010154d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101550:	85 d2                	test   %edx,%edx
f0101552:	75 24                	jne    f0101578 <i386_vm_init+0x475>
f0101554:	c7 44 24 0c 8c 50 10 	movl   $0xf010508c,0xc(%esp)
f010155b:	f0 
f010155c:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101563:	f0 
f0101564:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
f010156b:	00 
f010156c:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101573:	e8 43 eb ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f0101578:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010157b:	85 c9                	test   %ecx,%ecx
f010157d:	74 04                	je     f0101583 <i386_vm_init+0x480>
f010157f:	39 ca                	cmp    %ecx,%edx
f0101581:	75 24                	jne    f01015a7 <i386_vm_init+0x4a4>
f0101583:	c7 44 24 0c 7e 50 10 	movl   $0xf010507e,0xc(%esp)
f010158a:	f0 
f010158b:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101592:	f0 
f0101593:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
f010159a:	00 
f010159b:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01015a2:	e8 14 eb ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	74 08                	je     f01015b6 <i386_vm_init+0x4b3>
f01015ae:	39 c1                	cmp    %eax,%ecx
f01015b0:	74 04                	je     f01015b6 <i386_vm_init+0x4b3>
f01015b2:	39 c2                	cmp    %eax,%edx
f01015b4:	75 24                	jne    f01015da <i386_vm_init+0x4d7>
f01015b6:	c7 44 24 0c 28 4b 10 	movl   $0xf0104b28,0xc(%esp)
f01015bd:	f0 
f01015be:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01015c5:	f0 
f01015c6:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f01015cd:	00 
f01015ce:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01015d5:	e8 e1 ea ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f01015da:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01015dd:	89 04 24             	mov    %eax,(%esp)
f01015e0:	e8 29 f7 ff ff       	call   f0100d0e <page_alloc>
f01015e5:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01015e8:	74 24                	je     f010160e <i386_vm_init+0x50b>
f01015ea:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f01015f1:	f0 
f01015f2:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01015f9:	f0 
f01015fa:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0101601:	00 
f0101602:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101635:	c7 04 24 48 4b 10 f0 	movl   $0xf0104b48,(%esp)
f010163c:	e8 4d 19 00 00       	call   f0102f8e <cprintf>
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
f0101665:	c7 44 24 0c 27 50 10 	movl   $0xf0105027,0xc(%esp)
f010166c:	f0 
f010166d:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101674:	f0 
f0101675:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010167c:	00 
f010167d:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101684:	e8 32 ea ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f0101689:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010168c:	89 04 24             	mov    %eax,(%esp)
f010168f:	e8 7a f6 ff ff       	call   f0100d0e <page_alloc>
f0101694:	85 c0                	test   %eax,%eax
f0101696:	74 24                	je     f01016bc <i386_vm_init+0x5b9>
f0101698:	c7 44 24 0c 52 50 10 	movl   $0xf0105052,0xc(%esp)
f010169f:	f0 
f01016a0:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01016a7:	f0 
f01016a8:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f01016af:	00 
f01016b0:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01016b7:	e8 ff e9 ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f01016bc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01016bf:	89 04 24             	mov    %eax,(%esp)
f01016c2:	e8 47 f6 ff ff       	call   f0100d0e <page_alloc>
f01016c7:	85 c0                	test   %eax,%eax
f01016c9:	74 24                	je     f01016ef <i386_vm_init+0x5ec>
f01016cb:	c7 44 24 0c 68 50 10 	movl   $0xf0105068,0xc(%esp)
f01016d2:	f0 
f01016d3:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01016da:	f0 
f01016db:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f01016e2:	00 
f01016e3:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01016ea:	e8 cc e9 ff ff       	call   f01000bb <_panic>

	assert(pp0);
f01016ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01016f2:	85 d2                	test   %edx,%edx
f01016f4:	75 24                	jne    f010171a <i386_vm_init+0x617>
f01016f6:	c7 44 24 0c 8c 50 10 	movl   $0xf010508c,0xc(%esp)
f01016fd:	f0 
f01016fe:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101705:	f0 
f0101706:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f010170d:	00 
f010170e:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101715:	e8 a1 e9 ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f010171a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010171d:	85 c9                	test   %ecx,%ecx
f010171f:	74 04                	je     f0101725 <i386_vm_init+0x622>
f0101721:	39 ca                	cmp    %ecx,%edx
f0101723:	75 24                	jne    f0101749 <i386_vm_init+0x646>
f0101725:	c7 44 24 0c 7e 50 10 	movl   $0xf010507e,0xc(%esp)
f010172c:	f0 
f010172d:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101734:	f0 
f0101735:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f010173c:	00 
f010173d:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101744:	e8 72 e9 ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101749:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010174c:	85 c0                	test   %eax,%eax
f010174e:	74 08                	je     f0101758 <i386_vm_init+0x655>
f0101750:	39 c1                	cmp    %eax,%ecx
f0101752:	74 04                	je     f0101758 <i386_vm_init+0x655>
f0101754:	39 c2                	cmp    %eax,%edx
f0101756:	75 24                	jne    f010177c <i386_vm_init+0x679>
f0101758:	c7 44 24 0c 28 4b 10 	movl   $0xf0104b28,0xc(%esp)
f010175f:	f0 
f0101760:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101767:	f0 
f0101768:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f010176f:	00 
f0101770:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f010179e:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f01017a5:	f0 
f01017a6:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01017ad:	f0 
f01017ae:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f01017b5:	00 
f01017b6:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01017e2:	c7 44 24 0c 68 4b 10 	movl   $0xf0104b68,0xc(%esp)
f01017e9:	f0 
f01017ea:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01017f1:	f0 
f01017f2:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f01017f9:	00 
f01017fa:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f010182e:	c7 44 24 0c a0 4b 10 	movl   $0xf0104ba0,0xc(%esp)
f0101835:	f0 
f0101836:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f010183d:	f0 
f010183e:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101845:	00 
f0101846:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101885:	c7 44 24 0c cc 4b 10 	movl   $0xf0104bcc,0xc(%esp)
f010188c:	f0 
f010188d:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101894:	f0 
f0101895:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f010189c:	00 
f010189d:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01018d8:	c7 44 24 0c f8 4b 10 	movl   $0xf0104bf8,0xc(%esp)
f01018df:	f0 
f01018e0:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01018e7:	f0 
f01018e8:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f01018ef:	00 
f01018f0:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101920:	c7 44 24 0c 20 4c 10 	movl   $0xf0104c20,0xc(%esp)
f0101927:	f0 
f0101928:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f010192f:	f0 
f0101930:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101937:	00 
f0101938:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f010193f:	e8 77 e7 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 1);
f0101944:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101949:	74 24                	je     f010196f <i386_vm_init+0x86c>
f010194b:	c7 44 24 0c 01 51 10 	movl   $0xf0105101,0xc(%esp)
f0101952:	f0 
f0101953:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f010195a:	f0 
f010195b:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101962:	00 
f0101963:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f010196a:	e8 4c e7 ff ff       	call   f01000bb <_panic>
	assert(pp0->pp_ref == 1);
f010196f:	66 83 7f 08 01       	cmpw   $0x1,0x8(%edi)
f0101974:	74 24                	je     f010199a <i386_vm_init+0x897>
f0101976:	c7 44 24 0c 12 51 10 	movl   $0xf0105112,0xc(%esp)
f010197d:	f0 
f010197e:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101985:	f0 
f0101986:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f010198d:	00 
f010198e:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01019bd:	c7 44 24 0c 50 4c 10 	movl   $0xf0104c50,0xc(%esp)
f01019c4:	f0 
f01019c5:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01019cc:	f0 
f01019cd:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f01019d4:	00 
f01019d5:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101a0b:	c7 44 24 0c 88 4c 10 	movl   $0xf0104c88,0xc(%esp)
f0101a12:	f0 
f0101a13:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101a1a:	f0 
f0101a1b:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101a22:	00 
f0101a23:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101a2a:	e8 8c e6 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101a2f:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101a34:	74 24                	je     f0101a5a <i386_vm_init+0x957>
f0101a36:	c7 44 24 0c 23 51 10 	movl   $0xf0105123,0xc(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101a4d:	00 
f0101a4e:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101a55:	e8 61 e6 ff ff       	call   f01000bb <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101a5a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101a5d:	89 04 24             	mov    %eax,(%esp)
f0101a60:	e8 a9 f2 ff ff       	call   f0100d0e <page_alloc>
f0101a65:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101a68:	74 24                	je     f0101a8e <i386_vm_init+0x98b>
f0101a6a:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101a79:	f0 
f0101a7a:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101a81:	00 
f0101a82:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101ab6:	c7 44 24 0c 50 4c 10 	movl   $0xf0104c50,0xc(%esp)
f0101abd:	f0 
f0101abe:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101ac5:	f0 
f0101ac6:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0101acd:	00 
f0101ace:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101b04:	c7 44 24 0c 88 4c 10 	movl   $0xf0104c88,0xc(%esp)
f0101b0b:	f0 
f0101b0c:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101b13:	f0 
f0101b14:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0101b1b:	00 
f0101b1c:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101b23:	e8 93 e5 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101b28:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101b2d:	74 24                	je     f0101b53 <i386_vm_init+0xa50>
f0101b2f:	c7 44 24 0c 23 51 10 	movl   $0xf0105123,0xc(%esp)
f0101b36:	f0 
f0101b37:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101b3e:	f0 
f0101b3f:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101b46:	00 
f0101b47:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101b4e:	e8 68 e5 ff ff       	call   f01000bb <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101b53:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101b56:	89 04 24             	mov    %eax,(%esp)
f0101b59:	e8 b0 f1 ff ff       	call   f0100d0e <page_alloc>
f0101b5e:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101b61:	74 24                	je     f0101b87 <i386_vm_init+0xa84>
f0101b63:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f0101b6a:	f0 
f0101b6b:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101b72:	f0 
f0101b73:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0101b7a:	00 
f0101b7b:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101ba5:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f0101bac:	f0 
f0101bad:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0101bb4:	00 
f0101bb5:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101beb:	c7 44 24 0c b8 4c 10 	movl   $0xf0104cb8,0xc(%esp)
f0101bf2:	f0 
f0101bf3:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101bfa:	f0 
f0101bfb:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101c02:	00 
f0101c03:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101c37:	c7 44 24 0c f8 4c 10 	movl   $0xf0104cf8,0xc(%esp)
f0101c3e:	f0 
f0101c3f:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101c46:	f0 
f0101c47:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0101c4e:	00 
f0101c4f:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101c88:	c7 44 24 0c 88 4c 10 	movl   $0xf0104c88,0xc(%esp)
f0101c8f:	f0 
f0101c90:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101c97:	f0 
f0101c98:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0101c9f:	00 
f0101ca0:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101ca7:	e8 0f e4 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101cac:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101cb1:	74 24                	je     f0101cd7 <i386_vm_init+0xbd4>
f0101cb3:	c7 44 24 0c 23 51 10 	movl   $0xf0105123,0xc(%esp)
f0101cba:	f0 
f0101cbb:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101cc2:	f0 
f0101cc3:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0101cca:	00 
f0101ccb:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101cf4:	c7 44 24 0c 34 4d 10 	movl   $0xf0104d34,0xc(%esp)
f0101cfb:	f0 
f0101cfc:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101d03:	f0 
f0101d04:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0101d0b:	00 
f0101d0c:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101d40:	c7 44 24 0c 68 4d 10 	movl   $0xf0104d68,0xc(%esp)
f0101d47:	f0 
f0101d48:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101d4f:	f0 
f0101d50:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101d57:	00 
f0101d58:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101d8c:	c7 44 24 0c 9c 4d 10 	movl   $0xf0104d9c,0xc(%esp)
f0101d93:	f0 
f0101d94:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101d9b:	f0 
f0101d9c:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101da3:	00 
f0101da4:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101de1:	c7 44 24 0c d4 4d 10 	movl   $0xf0104dd4,0xc(%esp)
f0101de8:	f0 
f0101de9:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101df0:	f0 
f0101df1:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0101df8:	00 
f0101df9:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101e00:	e8 b6 e2 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101e05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e0a:	89 f8                	mov    %edi,%eax
f0101e0c:	e8 a4 ec ff ff       	call   f0100ab5 <check_va2pa>
f0101e11:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101e14:	74 24                	je     f0101e3a <i386_vm_init+0xd37>
f0101e16:	c7 44 24 0c 00 4e 10 	movl   $0xf0104e00,0xc(%esp)
f0101e1d:	f0 
f0101e1e:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101e25:	f0 
f0101e26:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101e2d:	00 
f0101e2e:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101e35:	e8 81 e2 ff ff       	call   f01000bb <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e3a:	66 83 7e 08 02       	cmpw   $0x2,0x8(%esi)
f0101e3f:	74 24                	je     f0101e65 <i386_vm_init+0xd62>
f0101e41:	c7 44 24 0c 34 51 10 	movl   $0xf0105134,0xc(%esp)
f0101e48:	f0 
f0101e49:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101e50:	f0 
f0101e51:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101e58:	00 
f0101e59:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101e60:	e8 56 e2 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0101e65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e68:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101e6d:	74 24                	je     f0101e93 <i386_vm_init+0xd90>
f0101e6f:	c7 44 24 0c 45 51 10 	movl   $0xf0105145,0xc(%esp)
f0101e76:	f0 
f0101e77:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101e7e:	f0 
f0101e7f:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0101e86:	00 
f0101e87:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101eaa:	c7 44 24 0c 30 4e 10 	movl   $0xf0104e30,0xc(%esp)
f0101eb1:	f0 
f0101eb2:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101eb9:	f0 
f0101eba:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101ec1:	00 
f0101ec2:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101efa:	c7 44 24 0c 54 4e 10 	movl   $0xf0104e54,0xc(%esp)
f0101f01:	f0 
f0101f02:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101f11:	00 
f0101f12:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101f45:	c7 44 24 0c 00 4e 10 	movl   $0xf0104e00,0xc(%esp)
f0101f4c:	f0 
f0101f4d:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101f54:	f0 
f0101f55:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101f5c:	00 
f0101f5d:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101f64:	e8 52 e1 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 1);
f0101f69:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101f6e:	74 24                	je     f0101f94 <i386_vm_init+0xe91>
f0101f70:	c7 44 24 0c 01 51 10 	movl   $0xf0105101,0xc(%esp)
f0101f77:	f0 
f0101f78:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101f7f:	f0 
f0101f80:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101f87:	00 
f0101f88:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0101f8f:	e8 27 e1 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0101f94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f97:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101f9c:	74 24                	je     f0101fc2 <i386_vm_init+0xebf>
f0101f9e:	c7 44 24 0c 45 51 10 	movl   $0xf0105145,0xc(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101fb5:	00 
f0101fb6:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0101fe9:	c7 44 24 0c 54 4e 10 	movl   $0xf0104e54,0xc(%esp)
f0101ff0:	f0 
f0101ff1:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0101ff8:	f0 
f0101ff9:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0102000:	00 
f0102001:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0102008:	e8 ae e0 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f010200d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102012:	89 f0                	mov    %esi,%eax
f0102014:	e8 9c ea ff ff       	call   f0100ab5 <check_va2pa>
f0102019:	83 f8 ff             	cmp    $0xffffffff,%eax
f010201c:	74 24                	je     f0102042 <i386_vm_init+0xf3f>
f010201e:	c7 44 24 0c 78 4e 10 	movl   $0xf0104e78,0xc(%esp)
f0102025:	f0 
f0102026:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f010202d:	f0 
f010202e:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102035:	00 
f0102036:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f010203d:	e8 79 e0 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 0);
f0102042:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102045:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010204a:	74 24                	je     f0102070 <i386_vm_init+0xf6d>
f010204c:	c7 44 24 0c 56 51 10 	movl   $0xf0105156,0xc(%esp)
f0102053:	f0 
f0102054:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f010205b:	f0 
f010205c:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102063:	00 
f0102064:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f010206b:	e8 4b e0 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0102070:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102073:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102078:	74 24                	je     f010209e <i386_vm_init+0xf9b>
f010207a:	c7 44 24 0c 45 51 10 	movl   $0xf0105145,0xc(%esp)
f0102081:	f0 
f0102082:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0102089:	f0 
f010208a:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102091:	00 
f0102092:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01020b5:	c7 44 24 0c a0 4e 10 	movl   $0xf0104ea0,0xc(%esp)
f01020bc:	f0 
f01020bd:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01020c4:	f0 
f01020c5:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01020cc:	00 
f01020cd:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01020d4:	e8 e2 df ff ff       	call   f01000bb <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01020d9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01020dc:	89 04 24             	mov    %eax,(%esp)
f01020df:	e8 2a ec ff ff       	call   f0100d0e <page_alloc>
f01020e4:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01020e7:	74 24                	je     f010210d <i386_vm_init+0x100a>
f01020e9:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f01020f0:	f0 
f01020f1:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01020f8:	f0 
f01020f9:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102100:	00 
f0102101:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0102133:	c7 44 24 0c f8 4b 10 	movl   $0xf0104bf8,0xc(%esp)
f010213a:	f0 
f010213b:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0102142:	f0 
f0102143:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f010214a:	00 
f010214b:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f0102152:	e8 64 df ff ff       	call   f01000bb <_panic>
	boot_pgdir[0] = 0;
f0102157:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010215d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102160:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102165:	74 24                	je     f010218b <i386_vm_init+0x1088>
f0102167:	c7 44 24 0c 12 51 10 	movl   $0xf0105112,0xc(%esp)
f010216e:	f0 
f010216f:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0102176:	f0 
f0102177:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f010217e:	00 
f010217f:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01021db:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01021f2:	e8 c4 de ff ff       	call   f01000bb <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021f7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01021fd:	39 d0                	cmp    %edx,%eax
f01021ff:	74 24                	je     f0102225 <i386_vm_init+0x1122>
f0102201:	c7 44 24 0c 67 51 10 	movl   $0xf0105167,0xc(%esp)
f0102208:	f0 
f0102209:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0102210:	f0 
f0102211:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102218:	00 
f0102219:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0102254:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f010225b:	f0 
f010225c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102263:	00 
f0102264:	c7 04 24 19 50 10 f0 	movl   $0xf0105019,(%esp)
f010226b:	e8 4b de ff ff       	call   f01000bb <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102270:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102277:	00 
f0102278:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010227f:	00 
f0102280:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102285:	89 04 24             	mov    %eax,(%esp)
f0102288:	e8 29 1c 00 00       	call   f0103eb6 <memset>
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
f01022db:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f01022e2:	f0 
f01022e3:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01022ea:	00 
f01022eb:	c7 04 24 19 50 10 f0 	movl   $0xf0105019,(%esp)
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
f010231a:	c7 44 24 0c 7f 51 10 	movl   $0xf010517f,0xc(%esp)
f0102321:	f0 
f0102322:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0102329:	f0 
f010232a:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102331:	00 
f0102332:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0102380:	c7 04 24 96 51 10 f0 	movl   $0xf0105196,(%esp)
f0102387:	e8 02 0c 00 00       	call   f0102f8e <cprintf>
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
f01023a2:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01023fa:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f0102401:	f0 
f0102402:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102409:	00 
f010240a:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0102448:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f010244f:	f0 
f0102450:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f0102457:	00 
f0102458:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f01024f4:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f01024fb:	f0 
f01024fc:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102503:	00 
f0102504:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f010250b:	e8 ab db ff ff       	call   f01000bb <_panic>
f0102510:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102513:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f010251a:	39 d0                	cmp    %edx,%eax
f010251c:	74 24                	je     f0102542 <i386_vm_init+0x143f>
f010251e:	c7 44 24 0c c4 4e 10 	movl   $0xf0104ec4,0xc(%esp)
f0102525:	f0 
f0102526:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f010252d:	f0 
f010252e:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102535:	00 
f0102536:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0102583:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f010258a:	f0 
f010258b:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0102592:	00 
f0102593:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f010259a:	e8 1c db ff ff       	call   f01000bb <_panic>
f010259f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01025a2:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f01025a9:	39 d0                	cmp    %edx,%eax
f01025ab:	74 24                	je     f01025d1 <i386_vm_init+0x14ce>
f01025ad:	c7 44 24 0c f8 4e 10 	movl   $0xf0104ef8,0xc(%esp)
f01025b4:	f0 
f01025b5:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f01025c4:	00 
f01025c5:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0102603:	c7 44 24 0c 2c 4f 10 	movl   $0xf0104f2c,0xc(%esp)
f010260a:	f0 
f010260b:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0102612:	f0 
f0102613:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f010261a:	00 
f010261b:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f0102658:	c7 44 24 0c 54 4f 10 	movl   $0xf0104f54,0xc(%esp)
f010265f:	f0 
f0102660:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0102667:	f0 
f0102668:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f010266f:	00 
f0102670:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f010269f:	c7 44 24 0c af 51 10 	movl   $0xf01051af,0xc(%esp)
f01026a6:	f0 
f01026a7:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01026ae:	f0 
f01026af:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f01026b6:	00 
f01026b7:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01026be:	e8 f8 d9 ff ff       	call   f01000bb <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f01026c3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01026c8:	76 2a                	jbe    f01026f4 <i386_vm_init+0x15f1>
				assert(pgdir[i]);
f01026ca:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026ce:	75 4e                	jne    f010271e <i386_vm_init+0x161b>
f01026d0:	c7 44 24 0c af 51 10 	movl   $0xf01051af,0xc(%esp)
f01026d7:	f0 
f01026d8:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
f01026e7:	00 
f01026e8:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
f01026ef:	e8 c7 d9 ff ff       	call   f01000bb <_panic>
			else
				assert(pgdir[i] == 0);
f01026f4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026f8:	74 24                	je     f010271e <i386_vm_init+0x161b>
f01026fa:	c7 44 24 0c b8 51 10 	movl   $0xf01051b8,0xc(%esp)
f0102701:	f0 
f0102702:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f0102709:	f0 
f010270a:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0102711:	00 
f0102712:	c7 04 24 f1 4f 10 f0 	movl   $0xf0104ff1,(%esp)
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
f010272c:	c7 04 24 9c 4f 10 f0 	movl   $0xf0104f9c,(%esp)
f0102733:	e8 56 08 00 00       	call   f0102f8e <cprintf>
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
f01027f2:	c7 04 24 bc 4f 10 f0 	movl   $0xf0104fbc,(%esp)
f01027f9:	e8 90 07 00 00       	call   f0102f8e <cprintf>
			"va %08x\n", curenv->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01027fe:	89 1c 24             	mov    %ebx,(%esp)
f0102801:	e8 72 06 00 00       	call   f0102e78 <env_destroy>
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
	// (But only if you need it for load_icode.)
	//
	// Hint: It is easier to use segment_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round len up.
	va = ROUNDDOWN(va, PGSIZE);
f0102817:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010281d:	89 d3                	mov    %edx,%ebx
	void * va_end = va + ROUNDUP(len, PGSIZE);
f010281f:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0102825:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010282a:	01 d0                	add    %edx,%eax
f010282c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Page *pg;
	for(; va < va_end; va += PGSIZE)
f010282f:	39 c2                	cmp    %eax,%edx
f0102831:	73 78                	jae    f01028ab <segment_alloc+0x9f>
	{
		if(page_alloc(&pg)!=0)
f0102833:	8d 7d e4             	lea    -0x1c(%ebp),%edi
f0102836:	89 3c 24             	mov    %edi,(%esp)
f0102839:	e8 d0 e4 ff ff       	call   f0100d0e <page_alloc>
f010283e:	85 c0                	test   %eax,%eax
f0102840:	74 1c                	je     f010285e <segment_alloc+0x52>
			panic("segment_alloc:page_alloc() out of memory!\n");
f0102842:	c7 44 24 08 c8 51 10 	movl   $0xf01051c8,0x8(%esp)
f0102849:	f0 
f010284a:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
f0102851:	00 
f0102852:	c7 04 24 4e 52 10 f0 	movl   $0xf010524e,(%esp)
f0102859:	e8 5d d8 ff ff       	call   f01000bb <_panic>
		int i = page_insert(e->env_pgdir, pg, va, PTE_U|PTE_W);
f010285e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102865:	00 
f0102866:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010286a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010286d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102871:	8b 46 5c             	mov    0x5c(%esi),%eax
f0102874:	89 04 24             	mov    %eax,(%esp)
f0102877:	e8 f6 e7 ff ff       	call   f0101072 <page_insert>
		if(i < 0)
f010287c:	85 c0                	test   %eax,%eax
f010287e:	79 20                	jns    f01028a0 <segment_alloc+0x94>
			panic("segment_alloc: page_insert()  %e",i);
f0102880:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102884:	c7 44 24 08 f4 51 10 	movl   $0xf01051f4,0x8(%esp)
f010288b:	f0 
f010288c:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f0102893:	00 
f0102894:	c7 04 24 4e 52 10 f0 	movl   $0xf010524e,(%esp)
f010289b:	e8 1b d8 ff ff       	call   f01000bb <_panic>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round len up.
	va = ROUNDDOWN(va, PGSIZE);
	void * va_end = va + ROUNDUP(len, PGSIZE);
	struct Page *pg;
	for(; va < va_end; va += PGSIZE)
f01028a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028a6:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01028a9:	77 8b                	ja     f0102836 <segment_alloc+0x2a>
			panic("segment_alloc:page_alloc() out of memory!\n");
		int i = page_insert(e->env_pgdir, pg, va, PTE_U|PTE_W);
		if(i < 0)
			panic("segment_alloc: page_insert()  %e",i);
	}
}
f01028ab:	83 c4 3c             	add    $0x3c,%esp
f01028ae:	5b                   	pop    %ebx
f01028af:	5e                   	pop    %esi
f01028b0:	5f                   	pop    %edi
f01028b1:	5d                   	pop    %ebp
f01028b2:	c3                   	ret    

f01028b3 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01028b3:	55                   	push   %ebp
f01028b4:	89 e5                	mov    %esp,%ebp
f01028b6:	53                   	push   %ebx
f01028b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01028ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01028bd:	85 c0                	test   %eax,%eax
f01028bf:	75 0e                	jne    f01028cf <envid2env+0x1c>
		*env_store = curenv;
f01028c1:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f01028c6:	89 01                	mov    %eax,(%ecx)
		return 0;
f01028c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01028cd:	eb 54                	jmp    f0102923 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01028cf:	89 c2                	mov    %eax,%edx
f01028d1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01028d7:	6b d2 64             	imul   $0x64,%edx,%edx
f01028da:	03 15 60 2d 17 f0    	add    0xf0172d60,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01028e0:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01028e4:	74 05                	je     f01028eb <envid2env+0x38>
f01028e6:	39 42 4c             	cmp    %eax,0x4c(%edx)
f01028e9:	74 0d                	je     f01028f8 <envid2env+0x45>
		*env_store = 0;
f01028eb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01028f1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01028f6:	eb 2b                	jmp    f0102923 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01028f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01028fc:	74 1e                	je     f010291c <envid2env+0x69>
f01028fe:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f0102903:	39 c2                	cmp    %eax,%edx
f0102905:	74 15                	je     f010291c <envid2env+0x69>
f0102907:	8b 58 4c             	mov    0x4c(%eax),%ebx
f010290a:	39 5a 50             	cmp    %ebx,0x50(%edx)
f010290d:	74 0d                	je     f010291c <envid2env+0x69>
		*env_store = 0;
f010290f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102915:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010291a:	eb 07                	jmp    f0102923 <envid2env+0x70>
	}

	*env_store = e;
f010291c:	89 11                	mov    %edx,(%ecx)
	return 0;
f010291e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102923:	5b                   	pop    %ebx
f0102924:	5d                   	pop    %ebp
f0102925:	c3                   	ret    

f0102926 <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f0102926:	55                   	push   %ebp
f0102927:	89 e5                	mov    %esp,%ebp
f0102929:	57                   	push   %edi
f010292a:	56                   	push   %esi
f010292b:	53                   	push   %ebx
	// LAB 3: Your code here.
	struct Env *env;
	int i;
	for(i = NENV - 1; i >= 0; i--)
	{
		envs[i].env_id = i;
f010292c:	8b 3d 60 2d 17 f0    	mov    0xf0172d60,%edi
f0102932:	8b 0d 64 2d 17 f0    	mov    0xf0172d64,%ecx
// and insert them into the env_free_list.
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
f0102938:	8d 87 9c 8f 01 00    	lea    0x18f9c(%edi),%eax
{
	// LAB 3: Your code here.
	struct Env *env;
	int i;
	for(i = NENV - 1; i >= 0; i--)
f010293e:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0102943:	eb 02                	jmp    f0102947 <env_init+0x21>
	{
		envs[i].env_id = i;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f0102945:	89 d9                	mov    %ebx,%ecx
	// LAB 3: Your code here.
	struct Env *env;
	int i;
	for(i = NENV - 1; i >= 0; i--)
	{
		envs[i].env_id = i;
f0102947:	89 c3                	mov    %eax,%ebx
f0102949:	89 50 4c             	mov    %edx,0x4c(%eax)
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f010294c:	89 48 44             	mov    %ecx,0x44(%eax)
f010294f:	85 c9                	test   %ecx,%ecx
f0102951:	74 06                	je     f0102959 <env_init+0x33>
f0102953:	8d 70 44             	lea    0x44(%eax),%esi
f0102956:	89 71 48             	mov    %esi,0x48(%ecx)
f0102959:	c7 43 48 64 2d 17 f0 	movl   $0xf0172d64,0x48(%ebx)
env_init(void)
{
	// LAB 3: Your code here.
	struct Env *env;
	int i;
	for(i = NENV - 1; i >= 0; i--)
f0102960:	83 ea 01             	sub    $0x1,%edx
f0102963:	83 e8 64             	sub    $0x64,%eax
f0102966:	83 fa ff             	cmp    $0xffffffff,%edx
f0102969:	75 da                	jne    f0102945 <env_init+0x1f>
f010296b:	89 3d 64 2d 17 f0    	mov    %edi,0xf0172d64
	{
		envs[i].env_id = i;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
	}
}
f0102971:	5b                   	pop    %ebx
f0102972:	5e                   	pop    %esi
f0102973:	5f                   	pop    %edi
f0102974:	5d                   	pop    %ebp
f0102975:	c3                   	ret    

f0102976 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102976:	55                   	push   %ebp
f0102977:	89 e5                	mov    %esp,%ebp
f0102979:	53                   	push   %ebx
f010297a:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f010297d:	8b 1d 64 2d 17 f0    	mov    0xf0172d64,%ebx
f0102983:	85 db                	test   %ebx,%ebx
f0102985:	0f 84 c8 01 00 00    	je     f0102b53 <env_alloc+0x1dd>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f010298b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f0102992:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102995:	89 04 24             	mov    %eax,(%esp)
f0102998:	e8 71 e3 ff ff       	call   f0100d0e <page_alloc>
f010299d:	85 c0                	test   %eax,%eax
f010299f:	0f 88 b3 01 00 00    	js     f0102b58 <env_alloc+0x1e2>
	//    - Note: pp_ref is not maintained for most physical pages
	//	mapped above UTOP -- but you do need to increment
	//	env_pgdir's pp_ref!

	// LAB 3: Your code here.
	p -> pp_ref++;
f01029a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01029a8:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01029ad:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f01029b3:	c1 f8 02             	sar    $0x2,%eax
f01029b6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01029bc:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01029bf:	89 c2                	mov    %eax,%edx
f01029c1:	c1 ea 0c             	shr    $0xc,%edx
f01029c4:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f01029ca:	72 20                	jb     f01029ec <env_alloc+0x76>
f01029cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029d0:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f01029d7:	f0 
f01029d8:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01029df:	00 
f01029e0:	c7 04 24 19 50 10 f0 	movl   $0xf0105019,(%esp)
f01029e7:	e8 cf d6 ff ff       	call   f01000bb <_panic>
	memset(page2kva(p), 0, PGSIZE);
f01029ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01029f3:	00 
f01029f4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01029fb:	00 
f01029fc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a01:	89 04 24             	mov    %eax,(%esp)
f0102a04:	e8 ad 14 00 00       	call   f0103eb6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a0c:	2b 05 0c 3a 17 f0    	sub    0xf0173a0c,%eax
f0102a12:	c1 f8 02             	sar    $0x2,%eax
f0102a15:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102a1b:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102a1e:	89 c2                	mov    %eax,%edx
f0102a20:	c1 ea 0c             	shr    $0xc,%edx
f0102a23:	3b 15 00 3a 17 f0    	cmp    0xf0173a00,%edx
f0102a29:	72 20                	jb     f0102a4b <env_alloc+0xd5>
f0102a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a2f:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f0102a36:	f0 
f0102a37:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102a3e:	00 
f0102a3f:	c7 04 24 19 50 10 f0 	movl   $0xf0105019,(%esp)
f0102a46:	e8 70 d6 ff ff       	call   f01000bb <_panic>
f0102a4b:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0102a51:	89 53 5c             	mov    %edx,0x5c(%ebx)
	e -> env_pgdir = page2kva(p);
	e -> env_cr3 = page2pa(p);
f0102a54:	89 43 60             	mov    %eax,0x60(%ebx)
f0102a57:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	for(i = PDX(UTOP); i < NPDENTRIES; i++)
	{
		e -> env_pgdir[i] = boot_pgdir[i];
f0102a5c:	8b 15 08 3a 17 f0    	mov    0xf0173a08,%edx
f0102a62:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102a65:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102a68:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102a6b:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	p -> pp_ref++;
	memset(page2kva(p), 0, PGSIZE);
	e -> env_pgdir = page2kva(p);
	e -> env_cr3 = page2pa(p);
	for(i = PDX(UTOP); i < NPDENTRIES; i++)
f0102a6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a73:	75 e7                	jne    f0102a5c <env_alloc+0xe6>
		e -> env_pgdir[i] = boot_pgdir[i];
	}

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0102a75:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102a78:	8b 53 60             	mov    0x60(%ebx),%edx
f0102a7b:	83 ca 03             	or     $0x3,%edx
f0102a7e:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0102a84:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102a87:	8b 53 60             	mov    0x60(%ebx),%edx
f0102a8a:	83 ca 05             	or     $0x5,%edx
f0102a8d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102a93:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0102a96:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102a9b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102aa0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102aa5:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102aa8:	89 da                	mov    %ebx,%edx
f0102aaa:	2b 15 60 2d 17 f0    	sub    0xf0172d60,%edx
f0102ab0:	c1 fa 02             	sar    $0x2,%edx
f0102ab3:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0102ab9:	09 d0                	or     %edx,%eax
f0102abb:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102abe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ac1:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102ac4:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102acb:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102ad2:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102ad9:	00 
f0102ada:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102ae1:	00 
f0102ae2:	89 1c 24             	mov    %ebx,(%esp)
f0102ae5:	e8 cc 13 00 00       	call   f0103eb6 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0102aea:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102af0:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102af6:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102afc:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102b03:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0102b09:	8b 43 44             	mov    0x44(%ebx),%eax
f0102b0c:	85 c0                	test   %eax,%eax
f0102b0e:	74 06                	je     f0102b16 <env_alloc+0x1a0>
f0102b10:	8b 53 48             	mov    0x48(%ebx),%edx
f0102b13:	89 50 48             	mov    %edx,0x48(%eax)
f0102b16:	8b 43 48             	mov    0x48(%ebx),%eax
f0102b19:	8b 53 44             	mov    0x44(%ebx),%edx
f0102b1c:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f0102b1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b21:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102b23:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0102b26:	8b 15 5c 2d 17 f0    	mov    0xf0172d5c,%edx
f0102b2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b31:	85 d2                	test   %edx,%edx
f0102b33:	74 03                	je     f0102b38 <env_alloc+0x1c2>
f0102b35:	8b 42 4c             	mov    0x4c(%edx),%eax
f0102b38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b40:	c7 04 24 59 52 10 f0 	movl   $0xf0105259,(%esp)
f0102b47:	e8 42 04 00 00       	call   f0102f8e <cprintf>
	return 0;
f0102b4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b51:	eb 05                	jmp    f0102b58 <env_alloc+0x1e2>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
f0102b53:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102b58:	83 c4 24             	add    $0x24,%esp
f0102b5b:	5b                   	pop    %ebx
f0102b5c:	5d                   	pop    %ebp
f0102b5d:	c3                   	ret    

f0102b5e <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f0102b5e:	55                   	push   %ebp
f0102b5f:	89 e5                	mov    %esp,%ebp
f0102b61:	57                   	push   %edi
f0102b62:	56                   	push   %esi
f0102b63:	53                   	push   %ebx
f0102b64:	83 ec 3c             	sub    $0x3c,%esp
f0102b67:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *env;
	int i;
	cprintf("env_create start! \n");
f0102b6a:	c7 04 24 6e 52 10 f0 	movl   $0xf010526e,(%esp)
f0102b71:	e8 18 04 00 00       	call   f0102f8e <cprintf>
	i = env_alloc(&env, 0);
f0102b76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b7d:	00 
f0102b7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102b81:	89 04 24             	mov    %eax,(%esp)
f0102b84:	e8 ed fd ff ff       	call   f0102976 <env_alloc>
	if( i < 0)
f0102b89:	85 c0                	test   %eax,%eax
f0102b8b:	79 20                	jns    f0102bad <env_create+0x4f>
	{
		panic("env_create: %e", i);
f0102b8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b91:	c7 44 24 08 82 52 10 	movl   $0xf0105282,0x8(%esp)
f0102b98:	f0 
f0102b99:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
f0102ba0:	00 
f0102ba1:	c7 04 24 4e 52 10 f0 	movl   $0xf010524e,(%esp)
f0102ba8:	e8 0e d5 ff ff       	call   f01000bb <_panic>
	}
	cprintf("env_alloc success!!\n");
f0102bad:	c7 04 24 91 52 10 f0 	movl   $0xf0105291,(%esp)
f0102bb4:	e8 d5 03 00 00       	call   f0102f8e <cprintf>
	load_icode(env, binary, size);
f0102bb9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bbc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0102bbf:	0f 20 da             	mov    %cr3,%edx
f0102bc2:	89 55 d0             	mov    %edx,-0x30(%ebp)
	struct Page *pg;
	int i;
	unsigned int old_cr3;
	env_elf = (struct Elf*)binary;
	old_cr3 = rcr3();
	lcr3(PADDR(e->env_pgdir));
f0102bc5:	8b 40 5c             	mov    0x5c(%eax),%eax
f0102bc8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bcd:	77 20                	ja     f0102bef <env_create+0x91>
f0102bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bd3:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f0102bda:	f0 
f0102bdb:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f0102be2:	00 
f0102be3:	c7 04 24 4e 52 10 f0 	movl   $0xf010524e,(%esp)
f0102bea:	e8 cc d4 ff ff       	call   f01000bb <_panic>
f0102bef:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102bf4:	0f 22 d8             	mov    %eax,%cr3
	if(env_elf->e_magic != ELF_MAGIC)
f0102bf7:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102bfd:	74 1c                	je     f0102c1b <env_create+0xbd>
		panic("load_icode: Not a valid ELF!\n");
f0102bff:	c7 44 24 08 a6 52 10 	movl   $0xf01052a6,0x8(%esp)
f0102c06:	f0 
f0102c07:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
f0102c0e:	00 
f0102c0f:	c7 04 24 4e 52 10 f0 	movl   $0xf010524e,(%esp)
f0102c16:	e8 a0 d4 ff ff       	call   f01000bb <_panic>
	ph = (struct Proghdr *)((unsigned int)env_elf + env_elf->e_phoff);
f0102c1b:	89 fb                	mov    %edi,%ebx
f0102c1d:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + env_elf->e_phnum;
f0102c20:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102c24:	c1 e6 05             	shl    $0x5,%esi
f0102c27:	01 de                	add    %ebx,%esi
	for(; ph < eph; ph++)
f0102c29:	39 f3                	cmp    %esi,%ebx
f0102c2b:	73 6a                	jae    f0102c97 <env_create+0x139>
	{
		if(ph->p_type == ELF_PROG_LOAD)
f0102c2d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102c30:	75 5e                	jne    f0102c90 <env_create+0x132>
		{
			segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102c32:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102c35:	8b 53 08             	mov    0x8(%ebx),%edx
f0102c38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c3b:	e8 cc fb ff ff       	call   f010280c <segment_alloc>
			memset((void *)ROUNDDOWN((uintptr_t)ph->p_va,PGSIZE), 0, ROUNDUP(ph->p_memsz, PGSIZE));
f0102c40:	8b 43 14             	mov    0x14(%ebx),%eax
f0102c43:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102c48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102c4d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102c51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c58:	00 
f0102c59:	8b 43 08             	mov    0x8(%ebx),%eax
f0102c5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102c61:	89 04 24             	mov    %eax,(%esp)
f0102c64:	e8 4d 12 00 00       	call   f0103eb6 <memset>
			cprintf("segment_alloc success !!!\n");
f0102c69:	c7 04 24 c4 52 10 f0 	movl   $0xf01052c4,(%esp)
f0102c70:	e8 19 03 00 00       	call   f0102f8e <cprintf>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102c75:	8b 43 10             	mov    0x10(%ebx),%eax
f0102c78:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102c7c:	89 f8                	mov    %edi,%eax
f0102c7e:	03 43 04             	add    0x4(%ebx),%eax
f0102c81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c85:	8b 43 08             	mov    0x8(%ebx),%eax
f0102c88:	89 04 24             	mov    %eax,(%esp)
f0102c8b:	e8 4a 12 00 00       	call   f0103eda <memmove>
	lcr3(PADDR(e->env_pgdir));
	if(env_elf->e_magic != ELF_MAGIC)
		panic("load_icode: Not a valid ELF!\n");
	ph = (struct Proghdr *)((unsigned int)env_elf + env_elf->e_phoff);
	eph = ph + env_elf->e_phnum;
	for(; ph < eph; ph++)
f0102c90:	83 c3 20             	add    $0x20,%ebx
f0102c93:	39 de                	cmp    %ebx,%esi
f0102c95:	77 96                	ja     f0102c2d <env_create+0xcf>
			memset((void *)ROUNDDOWN((uintptr_t)ph->p_va,PGSIZE), 0, ROUNDUP(ph->p_memsz, PGSIZE));
			cprintf("segment_alloc success !!!\n");
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
		}
	}
	e->env_tf.tf_eip = env_elf->e_entry;
f0102c97:	8b 47 18             	mov    0x18(%edi),%eax
f0102c9a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c9d:	89 42 30             	mov    %eax,0x30(%edx)
	
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	segment_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0102ca0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102ca5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102caa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cad:	e8 5a fb ff ff       	call   f010280c <segment_alloc>
f0102cb2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102cb5:	0f 22 d8             	mov    %eax,%cr3
	{
		panic("env_create: %e", i);
	}
	cprintf("env_alloc success!!\n");
	load_icode(env, binary, size);
	cprintf("env_create end!\n");
f0102cb8:	c7 04 24 df 52 10 f0 	movl   $0xf01052df,(%esp)
f0102cbf:	e8 ca 02 00 00       	call   f0102f8e <cprintf>
	return;
}
f0102cc4:	83 c4 3c             	add    $0x3c,%esp
f0102cc7:	5b                   	pop    %ebx
f0102cc8:	5e                   	pop    %esi
f0102cc9:	5f                   	pop    %edi
f0102cca:	5d                   	pop    %ebp
f0102ccb:	c3                   	ret    

f0102ccc <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0102ccc:	55                   	push   %ebp
f0102ccd:	89 e5                	mov    %esp,%ebp
f0102ccf:	57                   	push   %edi
f0102cd0:	56                   	push   %esi
f0102cd1:	53                   	push   %ebx
f0102cd2:	83 ec 2c             	sub    $0x2c,%esp
f0102cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102cd8:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f0102cdd:	39 c7                	cmp    %eax,%edi
f0102cdf:	75 09                	jne    f0102cea <env_free+0x1e>
f0102ce1:	8b 15 04 3a 17 f0    	mov    0xf0173a04,%edx
f0102ce7:	0f 22 da             	mov    %edx,%cr3
		lcr3(boot_cr3);

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102cea:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0102ced:	ba 00 00 00 00       	mov    $0x0,%edx
f0102cf2:	85 c0                	test   %eax,%eax
f0102cf4:	74 03                	je     f0102cf9 <env_free+0x2d>
f0102cf6:	8b 50 4c             	mov    0x4c(%eax),%edx
f0102cf9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102cfd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102d01:	c7 04 24 f0 52 10 f0 	movl   $0xf01052f0,(%esp)
f0102d08:	e8 81 02 00 00       	call   f0102f8e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d0d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102d14:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d17:	c1 e0 02             	shl    $0x2,%eax
f0102d1a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d1d:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d20:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d23:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102d26:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102d2c:	0f 84 bb 00 00 00    	je     f0102ded <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102d32:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0102d38:	89 f0                	mov    %esi,%eax
f0102d3a:	c1 e8 0c             	shr    $0xc,%eax
f0102d3d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102d40:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0102d46:	72 20                	jb     f0102d68 <env_free+0x9c>
f0102d48:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102d4c:	c7 44 24 08 44 4a 10 	movl   $0xf0104a44,0x8(%esp)
f0102d53:	f0 
f0102d54:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0102d5b:	00 
f0102d5c:	c7 04 24 4e 52 10 f0 	movl   $0xf010524e,(%esp)
f0102d63:	e8 53 d3 ff ff       	call   f01000bb <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d68:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d6b:	c1 e2 16             	shl    $0x16,%edx
f0102d6e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d71:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102d76:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102d7d:	01 
f0102d7e:	74 17                	je     f0102d97 <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102d80:	89 d8                	mov    %ebx,%eax
f0102d82:	c1 e0 0c             	shl    $0xc,%eax
f0102d85:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102d88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d8c:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d8f:	89 04 24             	mov    %eax,(%esp)
f0102d92:	e8 8b e2 ff ff       	call   f0101022 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d97:	83 c3 01             	add    $0x1,%ebx
f0102d9a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102da0:	75 d4                	jne    f0102d76 <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102da2:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102da5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102da8:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102daf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102db2:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0102db8:	72 1c                	jb     f0102dd6 <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0102dba:	c7 44 24 08 08 4b 10 	movl   $0xf0104b08,0x8(%esp)
f0102dc1:	f0 
f0102dc2:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102dc9:	00 
f0102dca:	c7 04 24 19 50 10 f0 	movl   $0xf0105019,(%esp)
f0102dd1:	e8 e5 d2 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0102dd6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102dd9:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102ddc:	c1 e0 02             	shl    $0x2,%eax
f0102ddf:	03 05 0c 3a 17 f0    	add    0xf0173a0c,%eax
		page_decref(pa2page(pa));
f0102de5:	89 04 24             	mov    %eax,(%esp)
f0102de8:	e8 c1 df ff ff       	call   f0100dae <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ded:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102df1:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102df8:	0f 85 16 ff ff ff    	jne    f0102d14 <env_free+0x48>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0102dfe:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0102e01:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0102e08:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102e0f:	c1 e8 0c             	shr    $0xc,%eax
f0102e12:	3b 05 00 3a 17 f0    	cmp    0xf0173a00,%eax
f0102e18:	72 1c                	jb     f0102e36 <env_free+0x16a>
		panic("pa2page called with invalid pa");
f0102e1a:	c7 44 24 08 08 4b 10 	movl   $0xf0104b08,0x8(%esp)
f0102e21:	f0 
f0102e22:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102e29:	00 
f0102e2a:	c7 04 24 19 50 10 f0 	movl   $0xf0105019,(%esp)
f0102e31:	e8 85 d2 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0102e36:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102e39:	c1 e0 02             	shl    $0x2,%eax
f0102e3c:	03 05 0c 3a 17 f0    	add    0xf0173a0c,%eax
	page_decref(pa2page(pa));
f0102e42:	89 04 24             	mov    %eax,(%esp)
f0102e45:	e8 64 df ff ff       	call   f0100dae <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102e4a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0102e51:	a1 64 2d 17 f0       	mov    0xf0172d64,%eax
f0102e56:	89 47 44             	mov    %eax,0x44(%edi)
f0102e59:	85 c0                	test   %eax,%eax
f0102e5b:	74 06                	je     f0102e63 <env_free+0x197>
f0102e5d:	8d 57 44             	lea    0x44(%edi),%edx
f0102e60:	89 50 48             	mov    %edx,0x48(%eax)
f0102e63:	89 3d 64 2d 17 f0    	mov    %edi,0xf0172d64
f0102e69:	c7 47 48 64 2d 17 f0 	movl   $0xf0172d64,0x48(%edi)
}
f0102e70:	83 c4 2c             	add    $0x2c,%esp
f0102e73:	5b                   	pop    %ebx
f0102e74:	5e                   	pop    %esi
f0102e75:	5f                   	pop    %edi
f0102e76:	5d                   	pop    %ebp
f0102e77:	c3                   	ret    

f0102e78 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102e78:	55                   	push   %ebp
f0102e79:	89 e5                	mov    %esp,%ebp
f0102e7b:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0102e7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e81:	89 04 24             	mov    %eax,(%esp)
f0102e84:	e8 43 fe ff ff       	call   f0102ccc <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102e89:	c7 04 24 18 52 10 f0 	movl   $0xf0105218,(%esp)
f0102e90:	e8 f9 00 00 00       	call   f0102f8e <cprintf>
	while (1)
		monitor(NULL);
f0102e95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e9c:	e8 5f d9 ff ff       	call   f0100800 <monitor>
f0102ea1:	eb f2                	jmp    f0102e95 <env_destroy+0x1d>

f0102ea3 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102ea3:	55                   	push   %ebp
f0102ea4:	89 e5                	mov    %esp,%ebp
f0102ea6:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102ea9:	8b 65 08             	mov    0x8(%ebp),%esp
f0102eac:	61                   	popa   
f0102ead:	07                   	pop    %es
f0102eae:	1f                   	pop    %ds
f0102eaf:	83 c4 08             	add    $0x8,%esp
f0102eb2:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102eb3:	c7 44 24 08 06 53 10 	movl   $0xf0105306,0x8(%esp)
f0102eba:	f0 
f0102ebb:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
f0102ec2:	00 
f0102ec3:	c7 04 24 4e 52 10 f0 	movl   $0xf010524e,(%esp)
f0102eca:	e8 ec d1 ff ff       	call   f01000bb <_panic>

f0102ecf <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0102ecf:	55                   	push   %ebp
f0102ed0:	89 e5                	mov    %esp,%ebp
f0102ed2:	83 ec 18             	sub    $0x18,%esp
f0102ed5:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.
	
	curenv = e;
f0102ed8:	a3 5c 2d 17 f0       	mov    %eax,0xf0172d5c
	curenv -> env_runs ++;
f0102edd:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0102ee1:	8b 50 5c             	mov    0x5c(%eax),%edx
f0102ee4:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102eea:	77 20                	ja     f0102f0c <env_run+0x3d>
f0102eec:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102ef0:	c7 44 24 08 8c 4a 10 	movl   $0xf0104a8c,0x8(%esp)
f0102ef7:	f0 
f0102ef8:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
f0102eff:	00 
f0102f00:	c7 04 24 4e 52 10 f0 	movl   $0xf010524e,(%esp)
f0102f07:	e8 af d1 ff ff       	call   f01000bb <_panic>
f0102f0c:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102f12:	0f 22 da             	mov    %edx,%cr3
	
	env_pop_tf(&(curenv -> env_tf));
f0102f15:	89 04 24             	mov    %eax,(%esp)
f0102f18:	e8 86 ff ff ff       	call   f0102ea3 <env_pop_tf>
f0102f1d:	00 00                	add    %al,(%eax)
	...

f0102f20 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102f20:	55                   	push   %ebp
f0102f21:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f23:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f28:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f2b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f2c:	b2 71                	mov    $0x71,%dl
f0102f2e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f2f:	0f b6 c0             	movzbl %al,%eax
}
f0102f32:	5d                   	pop    %ebp
f0102f33:	c3                   	ret    

f0102f34 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f34:	55                   	push   %ebp
f0102f35:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f37:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f3f:	ee                   	out    %al,(%dx)
f0102f40:	b2 71                	mov    $0x71,%dl
f0102f42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f45:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f46:	5d                   	pop    %ebp
f0102f47:	c3                   	ret    

f0102f48 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f48:	55                   	push   %ebp
f0102f49:	89 e5                	mov    %esp,%ebp
f0102f4b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102f4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f51:	89 04 24             	mov    %eax,(%esp)
f0102f54:	e8 7f d7 ff ff       	call   f01006d8 <cputchar>
	*cnt++;
}
f0102f59:	c9                   	leave  
f0102f5a:	c3                   	ret    

f0102f5b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f5b:	55                   	push   %ebp
f0102f5c:	89 e5                	mov    %esp,%ebp
f0102f5e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102f61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f68:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f72:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f7d:	c7 04 24 48 2f 10 f0 	movl   $0xf0102f48,(%esp)
f0102f84:	e8 7b 08 00 00       	call   f0103804 <vprintfmt>
	return cnt;
}
f0102f89:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f8c:	c9                   	leave  
f0102f8d:	c3                   	ret    

f0102f8e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f8e:	55                   	push   %ebp
f0102f8f:	89 e5                	mov    %esp,%ebp
f0102f91:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0102f94:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102f97:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f9e:	89 04 24             	mov    %eax,(%esp)
f0102fa1:	e8 b5 ff ff ff       	call   f0102f5b <vcprintf>
	va_end(ap);

	return cnt;
}
f0102fa6:	c9                   	leave  
f0102fa7:	c3                   	ret    

f0102fa8 <idt_init>:
}


void
idt_init(void)
{
f0102fa8:	55                   	push   %ebp
f0102fa9:	89 e5                	mov    %esp,%ebp
	
	// LAB 3: Your code here.

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102fab:	c7 05 84 35 17 f0 00 	movl   $0xefc00000,0xf0173584
f0102fb2:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0102fb5:	66 c7 05 88 35 17 f0 	movw   $0x10,0xf0173588
f0102fbc:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102fbe:	66 c7 05 68 83 11 f0 	movw   $0x68,0xf0118368
f0102fc5:	68 00 
f0102fc7:	b8 80 35 17 f0       	mov    $0xf0173580,%eax
f0102fcc:	66 a3 6a 83 11 f0    	mov    %ax,0xf011836a
f0102fd2:	89 c2                	mov    %eax,%edx
f0102fd4:	c1 ea 10             	shr    $0x10,%edx
f0102fd7:	88 15 6c 83 11 f0    	mov    %dl,0xf011836c
f0102fdd:	c6 05 6e 83 11 f0 40 	movb   $0x40,0xf011836e
f0102fe4:	c1 e8 18             	shr    $0x18,%eax
f0102fe7:	a2 6f 83 11 f0       	mov    %al,0xf011836f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0102fec:	c6 05 6d 83 11 f0 89 	movb   $0x89,0xf011836d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0102ff3:	b8 28 00 00 00       	mov    $0x28,%eax
f0102ff8:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0102ffb:	0f 01 1d 70 83 11 f0 	lidtl  0xf0118370
}
f0103002:	5d                   	pop    %ebp
f0103003:	c3                   	ret    

f0103004 <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0103004:	55                   	push   %ebp
f0103005:	89 e5                	mov    %esp,%ebp
f0103007:	53                   	push   %ebx
f0103008:	83 ec 14             	sub    $0x14,%esp
f010300b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010300e:	8b 03                	mov    (%ebx),%eax
f0103010:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103014:	c7 04 24 12 53 10 f0 	movl   $0xf0105312,(%esp)
f010301b:	e8 6e ff ff ff       	call   f0102f8e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103020:	8b 43 04             	mov    0x4(%ebx),%eax
f0103023:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103027:	c7 04 24 21 53 10 f0 	movl   $0xf0105321,(%esp)
f010302e:	e8 5b ff ff ff       	call   f0102f8e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103033:	8b 43 08             	mov    0x8(%ebx),%eax
f0103036:	89 44 24 04          	mov    %eax,0x4(%esp)
f010303a:	c7 04 24 30 53 10 f0 	movl   $0xf0105330,(%esp)
f0103041:	e8 48 ff ff ff       	call   f0102f8e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103046:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103049:	89 44 24 04          	mov    %eax,0x4(%esp)
f010304d:	c7 04 24 3f 53 10 f0 	movl   $0xf010533f,(%esp)
f0103054:	e8 35 ff ff ff       	call   f0102f8e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103059:	8b 43 10             	mov    0x10(%ebx),%eax
f010305c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103060:	c7 04 24 4e 53 10 f0 	movl   $0xf010534e,(%esp)
f0103067:	e8 22 ff ff ff       	call   f0102f8e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010306c:	8b 43 14             	mov    0x14(%ebx),%eax
f010306f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103073:	c7 04 24 5d 53 10 f0 	movl   $0xf010535d,(%esp)
f010307a:	e8 0f ff ff ff       	call   f0102f8e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010307f:	8b 43 18             	mov    0x18(%ebx),%eax
f0103082:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103086:	c7 04 24 6c 53 10 f0 	movl   $0xf010536c,(%esp)
f010308d:	e8 fc fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103092:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103095:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103099:	c7 04 24 7b 53 10 f0 	movl   $0xf010537b,(%esp)
f01030a0:	e8 e9 fe ff ff       	call   f0102f8e <cprintf>
}
f01030a5:	83 c4 14             	add    $0x14,%esp
f01030a8:	5b                   	pop    %ebx
f01030a9:	5d                   	pop    %ebp
f01030aa:	c3                   	ret    

f01030ab <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f01030ab:	55                   	push   %ebp
f01030ac:	89 e5                	mov    %esp,%ebp
f01030ae:	53                   	push   %ebx
f01030af:	83 ec 14             	sub    $0x14,%esp
f01030b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f01030b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01030b9:	c7 04 24 48 54 10 f0 	movl   $0xf0105448,(%esp)
f01030c0:	e8 c9 fe ff ff       	call   f0102f8e <cprintf>
	print_regs(&tf->tf_regs);
f01030c5:	89 1c 24             	mov    %ebx,(%esp)
f01030c8:	e8 37 ff ff ff       	call   f0103004 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01030cd:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01030d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030d5:	c7 04 24 a5 53 10 f0 	movl   $0xf01053a5,(%esp)
f01030dc:	e8 ad fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01030e1:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01030e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030e9:	c7 04 24 b8 53 10 f0 	movl   $0xf01053b8,(%esp)
f01030f0:	e8 99 fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01030f5:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01030f8:	83 f8 13             	cmp    $0x13,%eax
f01030fb:	77 09                	ja     f0103106 <print_trapframe+0x5b>
		return excnames[trapno];
f01030fd:	8b 14 85 20 56 10 f0 	mov    -0xfefa9e0(,%eax,4),%edx
f0103104:	eb 10                	jmp    f0103116 <print_trapframe+0x6b>
	if (trapno == T_SYSCALL)
f0103106:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
f0103109:	ba 8a 53 10 f0       	mov    $0xf010538a,%edx
f010310e:	b9 96 53 10 f0       	mov    $0xf0105396,%ecx
f0103113:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103116:	89 54 24 08          	mov    %edx,0x8(%esp)
f010311a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010311e:	c7 04 24 cb 53 10 f0 	movl   $0xf01053cb,(%esp)
f0103125:	e8 64 fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f010312a:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010312d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103131:	c7 04 24 dd 53 10 f0 	movl   $0xf01053dd,(%esp)
f0103138:	e8 51 fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010313d:	8b 43 30             	mov    0x30(%ebx),%eax
f0103140:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103144:	c7 04 24 ec 53 10 f0 	movl   $0xf01053ec,(%esp)
f010314b:	e8 3e fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103150:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103154:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103158:	c7 04 24 fb 53 10 f0 	movl   $0xf01053fb,(%esp)
f010315f:	e8 2a fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103164:	8b 43 38             	mov    0x38(%ebx),%eax
f0103167:	89 44 24 04          	mov    %eax,0x4(%esp)
f010316b:	c7 04 24 0e 54 10 f0 	movl   $0xf010540e,(%esp)
f0103172:	e8 17 fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103177:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010317a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010317e:	c7 04 24 1d 54 10 f0 	movl   $0xf010541d,(%esp)
f0103185:	e8 04 fe ff ff       	call   f0102f8e <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010318a:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010318e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103192:	c7 04 24 2c 54 10 f0 	movl   $0xf010542c,(%esp)
f0103199:	e8 f0 fd ff ff       	call   f0102f8e <cprintf>
}
f010319e:	83 c4 14             	add    $0x14,%esp
f01031a1:	5b                   	pop    %ebx
f01031a2:	5d                   	pop    %ebp
f01031a3:	c3                   	ret    

f01031a4 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01031a4:	55                   	push   %ebp
f01031a5:	89 e5                	mov    %esp,%ebp
f01031a7:	57                   	push   %edi
f01031a8:	56                   	push   %esi
f01031a9:	83 ec 10             	sub    $0x10,%esp
f01031ac:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("Incoming TRAP frame at %p\n", tf);
f01031af:	89 74 24 04          	mov    %esi,0x4(%esp)
f01031b3:	c7 04 24 3f 54 10 f0 	movl   $0xf010543f,(%esp)
f01031ba:	e8 cf fd ff ff       	call   f0102f8e <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01031bf:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01031c3:	83 e0 03             	and    $0x3,%eax
f01031c6:	83 f8 03             	cmp    $0x3,%eax
f01031c9:	75 3c                	jne    f0103207 <trap+0x63>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f01031cb:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f01031d0:	85 c0                	test   %eax,%eax
f01031d2:	75 24                	jne    f01031f8 <trap+0x54>
f01031d4:	c7 44 24 0c 5a 54 10 	movl   $0xf010545a,0xc(%esp)
f01031db:	f0 
f01031dc:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f01031e3:	f0 
f01031e4:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
f01031eb:	00 
f01031ec:	c7 04 24 61 54 10 f0 	movl   $0xf0105461,(%esp)
f01031f3:	e8 c3 ce ff ff       	call   f01000bb <_panic>
		curenv->env_tf = *tf;
f01031f8:	b9 11 00 00 00       	mov    $0x11,%ecx
f01031fd:	89 c7                	mov    %eax,%edi
f01031ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103201:	8b 35 5c 2d 17 f0    	mov    0xf0172d5c,%esi
	// Handle processor exceptions.
	// LAB 3: Your code here.
	

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103207:	89 34 24             	mov    %esi,(%esp)
f010320a:	e8 9c fe ff ff       	call   f01030ab <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010320f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103214:	75 1c                	jne    f0103232 <trap+0x8e>
		panic("unhandled trap in kernel");
f0103216:	c7 44 24 08 6d 54 10 	movl   $0xf010546d,0x8(%esp)
f010321d:	f0 
f010321e:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
f0103225:	00 
f0103226:	c7 04 24 61 54 10 f0 	movl   $0xf0105461,(%esp)
f010322d:	e8 89 ce ff ff       	call   f01000bb <_panic>
	else {
		env_destroy(curenv);
f0103232:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f0103237:	89 04 24             	mov    %eax,(%esp)
f010323a:	e8 39 fc ff ff       	call   f0102e78 <env_destroy>
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f010323f:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f0103244:	85 c0                	test   %eax,%eax
f0103246:	74 06                	je     f010324e <trap+0xaa>
f0103248:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010324c:	74 24                	je     f0103272 <trap+0xce>
f010324e:	c7 44 24 0c c8 55 10 	movl   $0xf01055c8,0xc(%esp)
f0103255:	f0 
f0103256:	c7 44 24 08 3d 50 10 	movl   $0xf010503d,0x8(%esp)
f010325d:	f0 
f010325e:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
f0103265:	00 
f0103266:	c7 04 24 61 54 10 f0 	movl   $0xf0105461,(%esp)
f010326d:	e8 49 ce ff ff       	call   f01000bb <_panic>
        env_run(curenv);
f0103272:	89 04 24             	mov    %eax,(%esp)
f0103275:	e8 55 fc ff ff       	call   f0102ecf <env_run>

f010327a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010327a:	55                   	push   %ebp
f010327b:	89 e5                	mov    %esp,%ebp
f010327d:	53                   	push   %ebx
f010327e:	83 ec 14             	sub    $0x14,%esp
f0103281:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103284:	0f 20 d0             	mov    %cr2,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103287:	8b 53 30             	mov    0x30(%ebx),%edx
f010328a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010328e:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0103292:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103297:	8b 40 4c             	mov    0x4c(%eax),%eax
f010329a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010329e:	c7 04 24 f8 55 10 f0 	movl   $0xf01055f8,(%esp)
f01032a5:	e8 e4 fc ff ff       	call   f0102f8e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01032aa:	89 1c 24             	mov    %ebx,(%esp)
f01032ad:	e8 f9 fd ff ff       	call   f01030ab <print_trapframe>
	env_destroy(curenv);
f01032b2:	a1 5c 2d 17 f0       	mov    0xf0172d5c,%eax
f01032b7:	89 04 24             	mov    %eax,(%esp)
f01032ba:	e8 b9 fb ff ff       	call   f0102e78 <env_destroy>
}
f01032bf:	83 c4 14             	add    $0x14,%esp
f01032c2:	5b                   	pop    %ebx
f01032c3:	5d                   	pop    %ebp
f01032c4:	c3                   	ret    
f01032c5:	00 00                	add    %al,(%eax)
	...

f01032c8 <syscall>:
f01032c8:	55                   	push   %ebp
f01032c9:	89 e5                	mov    %esp,%ebp
f01032cb:	83 ec 18             	sub    $0x18,%esp
f01032ce:	c7 44 24 08 70 56 10 	movl   $0xf0105670,0x8(%esp)
f01032d5:	f0 
f01032d6:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01032dd:	00 
f01032de:	c7 04 24 88 56 10 f0 	movl   $0xf0105688,(%esp)
f01032e5:	e8 d1 cd ff ff       	call   f01000bb <_panic>
	...

f01032ec <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01032ec:	55                   	push   %ebp
f01032ed:	89 e5                	mov    %esp,%ebp
f01032ef:	57                   	push   %edi
f01032f0:	56                   	push   %esi
f01032f1:	53                   	push   %ebx
f01032f2:	83 ec 14             	sub    $0x14,%esp
f01032f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01032f8:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01032fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01032fe:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103301:	8b 1a                	mov    (%edx),%ebx
f0103303:	8b 01                	mov    (%ecx),%eax
f0103305:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0103308:	39 c3                	cmp    %eax,%ebx
f010330a:	0f 8f 9c 00 00 00    	jg     f01033ac <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103310:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103317:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010331a:	01 d8                	add    %ebx,%eax
f010331c:	89 c7                	mov    %eax,%edi
f010331e:	c1 ef 1f             	shr    $0x1f,%edi
f0103321:	01 c7                	add    %eax,%edi
f0103323:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103325:	39 df                	cmp    %ebx,%edi
f0103327:	7c 33                	jl     f010335c <stab_binsearch+0x70>
f0103329:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010332c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010332f:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103334:	39 f0                	cmp    %esi,%eax
f0103336:	0f 84 bc 00 00 00    	je     f01033f8 <stab_binsearch+0x10c>
f010333c:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103340:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103344:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103346:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103349:	39 d8                	cmp    %ebx,%eax
f010334b:	7c 0f                	jl     f010335c <stab_binsearch+0x70>
f010334d:	0f b6 0a             	movzbl (%edx),%ecx
f0103350:	83 ea 0c             	sub    $0xc,%edx
f0103353:	39 f1                	cmp    %esi,%ecx
f0103355:	75 ef                	jne    f0103346 <stab_binsearch+0x5a>
f0103357:	e9 9e 00 00 00       	jmp    f01033fa <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010335c:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010335f:	eb 3c                	jmp    f010339d <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103361:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103364:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0103366:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103369:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103370:	eb 2b                	jmp    f010339d <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103372:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103375:	76 14                	jbe    f010338b <stab_binsearch+0x9f>
			*region_right = m - 1;
f0103377:	83 e8 01             	sub    $0x1,%eax
f010337a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010337d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103380:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103382:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103389:	eb 12                	jmp    f010339d <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010338b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010338e:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0103390:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103394:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103396:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f010339d:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01033a0:	0f 8d 71 ff ff ff    	jge    f0103317 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01033a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01033aa:	75 0f                	jne    f01033bb <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01033ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01033af:	8b 02                	mov    (%edx),%eax
f01033b1:	83 e8 01             	sub    $0x1,%eax
f01033b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01033b7:	89 01                	mov    %eax,(%ecx)
f01033b9:	eb 57                	jmp    f0103412 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01033be:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01033c0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01033c3:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033c5:	39 c1                	cmp    %eax,%ecx
f01033c7:	7d 28                	jge    f01033f1 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01033c9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01033cc:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01033cf:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01033d4:	39 f2                	cmp    %esi,%edx
f01033d6:	74 19                	je     f01033f1 <stab_binsearch+0x105>
f01033d8:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01033dc:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01033e0:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033e3:	39 c1                	cmp    %eax,%ecx
f01033e5:	7d 0a                	jge    f01033f1 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01033e7:	0f b6 1a             	movzbl (%edx),%ebx
f01033ea:	83 ea 0c             	sub    $0xc,%edx
f01033ed:	39 f3                	cmp    %esi,%ebx
f01033ef:	75 ef                	jne    f01033e0 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f01033f1:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01033f4:	89 02                	mov    %eax,(%edx)
f01033f6:	eb 1a                	jmp    f0103412 <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01033f8:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01033fa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01033fd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103400:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103404:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103407:	0f 82 54 ff ff ff    	jb     f0103361 <stab_binsearch+0x75>
f010340d:	e9 60 ff ff ff       	jmp    f0103372 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103412:	83 c4 14             	add    $0x14,%esp
f0103415:	5b                   	pop    %ebx
f0103416:	5e                   	pop    %esi
f0103417:	5f                   	pop    %edi
f0103418:	5d                   	pop    %ebp
f0103419:	c3                   	ret    

f010341a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010341a:	55                   	push   %ebp
f010341b:	89 e5                	mov    %esp,%ebp
f010341d:	57                   	push   %edi
f010341e:	56                   	push   %esi
f010341f:	53                   	push   %ebx
f0103420:	83 ec 5c             	sub    $0x5c,%esp
f0103423:	8b 75 08             	mov    0x8(%ebp),%esi
f0103426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103429:	c7 03 97 56 10 f0    	movl   $0xf0105697,(%ebx)
	info->eip_line = 0;
f010342f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103436:	c7 43 08 97 56 10 f0 	movl   $0xf0105697,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010343d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103444:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103447:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010344e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103454:	77 23                	ja     f0103479 <debuginfo_eip+0x5f>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f0103456:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f010345c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010345f:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0103465:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010346b:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f010346e:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103474:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0103477:	eb 1a                	jmp    f0103493 <debuginfo_eip+0x79>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103479:	c7 45 c0 9b f5 10 f0 	movl   $0xf010f59b,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103480:	c7 45 b8 25 cc 10 f0 	movl   $0xf010cc25,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103487:	ba 24 cc 10 f0       	mov    $0xf010cc24,%edx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010348c:	c7 45 c4 b0 58 10 f0 	movl   $0xf01058b0,-0x3c(%ebp)
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103493:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103498:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010349b:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f010349e:	0f 83 be 01 00 00    	jae    f0103662 <debuginfo_eip+0x248>
f01034a4:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01034a8:	0f 85 b4 01 00 00    	jne    f0103662 <debuginfo_eip+0x248>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01034ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01034b5:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f01034b8:	c1 fa 02             	sar    $0x2,%edx
f01034bb:	69 c2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%eax
f01034c1:	83 e8 01             	sub    $0x1,%eax
f01034c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01034c7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01034cb:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01034d2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01034d5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01034d8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01034db:	e8 0c fe ff ff       	call   f01032ec <stab_binsearch>
	if (lfile == 0)
f01034e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01034e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f01034e8:	85 d2                	test   %edx,%edx
f01034ea:	0f 84 72 01 00 00    	je     f0103662 <debuginfo_eip+0x248>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01034f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f01034f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01034f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01034fd:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103504:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103507:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010350a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010350d:	e8 da fd ff ff       	call   f01032ec <stab_binsearch>

	if (lfun <= rfun) {
f0103512:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103515:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103518:	39 d0                	cmp    %edx,%eax
f010351a:	7f 32                	jg     f010354e <debuginfo_eip+0x134>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010351c:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010351f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103522:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0103525:	8b 39                	mov    (%ecx),%edi
f0103527:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f010352a:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010352d:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0103530:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0103533:	73 09                	jae    f010353e <debuginfo_eip+0x124>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103535:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0103538:	03 7d b8             	add    -0x48(%ebp),%edi
f010353b:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010353e:	8b 49 08             	mov    0x8(%ecx),%ecx
f0103541:	89 4b 10             	mov    %ecx,0x10(%ebx)
		// This "n_value" is the function's first addr, but when it comes to SLINE,
		// "n_value" describes the offset, so we need to minus "n_value" fro addr
		// to get the offset of the line.
		addr -= info->eip_fn_addr;
f0103544:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103546:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103549:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010354c:	eb 0f                	jmp    f010355d <debuginfo_eip+0x143>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010354e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103551:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103554:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103557:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010355a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010355d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103564:	00 
f0103565:	8b 43 08             	mov    0x8(%ebx),%eax
f0103568:	89 04 24             	mov    %eax,(%esp)
f010356b:	e8 1f 09 00 00       	call   f0103e8f <strfind>
f0103570:	2b 43 08             	sub    0x8(%ebx),%eax
f0103573:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103576:	89 74 24 04          	mov    %esi,0x4(%esp)
f010357a:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103581:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103584:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103587:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010358a:	e8 5d fd ff ff       	call   f01032ec <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f010358f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103592:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103595:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103598:	0f b7 54 96 06       	movzwl 0x6(%esi,%edx,4),%edx
f010359d:	89 53 04             	mov    %edx,0x4(%ebx)
	if (rline < lline)
f01035a0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01035a3:	7e 07                	jle    f01035ac <debuginfo_eip+0x192>
	{
		info->eip_line = -1;
f01035a5:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01035ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01035af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01035b2:	89 7d bc             	mov    %edi,-0x44(%ebp)
f01035b5:	39 f8                	cmp    %edi,%eax
f01035b7:	7c 78                	jl     f0103631 <debuginfo_eip+0x217>
	       && stabs[lline].n_type != N_SOL
f01035b9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01035bc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01035bf:	8d 34 97             	lea    (%edi,%edx,4),%esi
f01035c2:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f01035c6:	80 f9 84             	cmp    $0x84,%cl
f01035c9:	74 4e                	je     f0103619 <debuginfo_eip+0x1ff>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01035cb:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01035cf:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01035d2:	89 c7                	mov    %eax,%edi
f01035d4:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f01035d7:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f01035da:	eb 27                	jmp    f0103603 <debuginfo_eip+0x1e9>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01035dc:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01035df:	39 c3                	cmp    %eax,%ebx
f01035e1:	7e 08                	jle    f01035eb <debuginfo_eip+0x1d1>
f01035e3:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01035e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01035e9:	eb 46                	jmp    f0103631 <debuginfo_eip+0x217>
	       && stabs[lline].n_type != N_SOL
f01035eb:	89 d6                	mov    %edx,%esi
f01035ed:	83 ea 0c             	sub    $0xc,%edx
f01035f0:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f01035f4:	80 f9 84             	cmp    $0x84,%cl
f01035f7:	75 08                	jne    f0103601 <debuginfo_eip+0x1e7>
f01035f9:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01035fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01035ff:	eb 18                	jmp    f0103619 <debuginfo_eip+0x1ff>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103601:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103603:	80 f9 64             	cmp    $0x64,%cl
f0103606:	75 d4                	jne    f01035dc <debuginfo_eip+0x1c2>
f0103608:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f010360c:	74 ce                	je     f01035dc <debuginfo_eip+0x1c2>
f010360e:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0103611:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103614:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0103617:	7f 18                	jg     f0103631 <debuginfo_eip+0x217>
f0103619:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010361c:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010361f:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0103622:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103625:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0103628:	39 d0                	cmp    %edx,%eax
f010362a:	73 05                	jae    f0103631 <debuginfo_eip+0x217>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010362c:	03 45 b8             	add    -0x48(%ebp),%eax
f010362f:	89 03                	mov    %eax,(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0103631:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103634:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0103637:	b8 00 00 00 00       	mov    $0x0,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f010363c:	39 d1                	cmp    %edx,%ecx
f010363e:	7c 22                	jl     f0103662 <debuginfo_eip+0x248>
	{
		if (stabs[i].n_type == N_PSYM)
f0103640:	8d 04 52             	lea    (%edx,%edx,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103643:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103646:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
	{
		if (stabs[i].n_type == N_PSYM)
f010364a:	80 38 a0             	cmpb   $0xa0,(%eax)
f010364d:	75 04                	jne    f0103653 <debuginfo_eip+0x239>
		{
			++(info->eip_fn_narg);
f010364f:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0103653:	83 c2 01             	add    $0x1,%edx
f0103656:	83 c0 0c             	add    $0xc,%eax
f0103659:	39 d1                	cmp    %edx,%ecx
f010365b:	7d ed                	jge    f010364a <debuginfo_eip+0x230>
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f010365d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103662:	83 c4 5c             	add    $0x5c,%esp
f0103665:	5b                   	pop    %ebx
f0103666:	5e                   	pop    %esi
f0103667:	5f                   	pop    %edi
f0103668:	5d                   	pop    %ebp
f0103669:	c3                   	ret    
f010366a:	00 00                	add    %al,(%eax)
f010366c:	00 00                	add    %al,(%eax)
	...

f0103670 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103670:	55                   	push   %ebp
f0103671:	89 e5                	mov    %esp,%ebp
f0103673:	57                   	push   %edi
f0103674:	56                   	push   %esi
f0103675:	53                   	push   %ebx
f0103676:	83 ec 3c             	sub    $0x3c,%esp
f0103679:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010367c:	89 d7                	mov    %edx,%edi
f010367e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103681:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103684:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103687:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010368a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010368d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103690:	b8 00 00 00 00       	mov    $0x0,%eax
f0103695:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0103698:	72 11                	jb     f01036ab <printnum+0x3b>
f010369a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010369d:	39 45 10             	cmp    %eax,0x10(%ebp)
f01036a0:	76 09                	jbe    f01036ab <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01036a2:	83 eb 01             	sub    $0x1,%ebx
f01036a5:	85 db                	test   %ebx,%ebx
f01036a7:	7f 51                	jg     f01036fa <printnum+0x8a>
f01036a9:	eb 5e                	jmp    f0103709 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01036ab:	89 74 24 10          	mov    %esi,0x10(%esp)
f01036af:	83 eb 01             	sub    $0x1,%ebx
f01036b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01036b6:	8b 45 10             	mov    0x10(%ebp),%eax
f01036b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036bd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01036c1:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01036c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01036cc:	00 
f01036cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036d0:	89 04 24             	mov    %eax,(%esp)
f01036d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036da:	e8 d1 09 00 00       	call   f01040b0 <__udivdi3>
f01036df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01036e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01036e7:	89 04 24             	mov    %eax,(%esp)
f01036ea:	89 54 24 04          	mov    %edx,0x4(%esp)
f01036ee:	89 fa                	mov    %edi,%edx
f01036f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01036f3:	e8 78 ff ff ff       	call   f0103670 <printnum>
f01036f8:	eb 0f                	jmp    f0103709 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01036fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01036fe:	89 34 24             	mov    %esi,(%esp)
f0103701:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103704:	83 eb 01             	sub    $0x1,%ebx
f0103707:	75 f1                	jne    f01036fa <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103709:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010370d:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103711:	8b 45 10             	mov    0x10(%ebp),%eax
f0103714:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103718:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010371f:	00 
f0103720:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103723:	89 04 24             	mov    %eax,(%esp)
f0103726:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103729:	89 44 24 04          	mov    %eax,0x4(%esp)
f010372d:	e8 ae 0a 00 00       	call   f01041e0 <__umoddi3>
f0103732:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103736:	0f be 80 a1 56 10 f0 	movsbl -0xfefa95f(%eax),%eax
f010373d:	89 04 24             	mov    %eax,(%esp)
f0103740:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0103743:	83 c4 3c             	add    $0x3c,%esp
f0103746:	5b                   	pop    %ebx
f0103747:	5e                   	pop    %esi
f0103748:	5f                   	pop    %edi
f0103749:	5d                   	pop    %ebp
f010374a:	c3                   	ret    

f010374b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010374b:	55                   	push   %ebp
f010374c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010374e:	83 fa 01             	cmp    $0x1,%edx
f0103751:	7e 0e                	jle    f0103761 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103753:	8b 10                	mov    (%eax),%edx
f0103755:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103758:	89 08                	mov    %ecx,(%eax)
f010375a:	8b 02                	mov    (%edx),%eax
f010375c:	8b 52 04             	mov    0x4(%edx),%edx
f010375f:	eb 22                	jmp    f0103783 <getuint+0x38>
	else if (lflag)
f0103761:	85 d2                	test   %edx,%edx
f0103763:	74 10                	je     f0103775 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103765:	8b 10                	mov    (%eax),%edx
f0103767:	8d 4a 04             	lea    0x4(%edx),%ecx
f010376a:	89 08                	mov    %ecx,(%eax)
f010376c:	8b 02                	mov    (%edx),%eax
f010376e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103773:	eb 0e                	jmp    f0103783 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103775:	8b 10                	mov    (%eax),%edx
f0103777:	8d 4a 04             	lea    0x4(%edx),%ecx
f010377a:	89 08                	mov    %ecx,(%eax)
f010377c:	8b 02                	mov    (%edx),%eax
f010377e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103783:	5d                   	pop    %ebp
f0103784:	c3                   	ret    

f0103785 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103785:	55                   	push   %ebp
f0103786:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103788:	83 fa 01             	cmp    $0x1,%edx
f010378b:	7e 0e                	jle    f010379b <getint+0x16>
		return va_arg(*ap, long long);
f010378d:	8b 10                	mov    (%eax),%edx
f010378f:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103792:	89 08                	mov    %ecx,(%eax)
f0103794:	8b 02                	mov    (%edx),%eax
f0103796:	8b 52 04             	mov    0x4(%edx),%edx
f0103799:	eb 22                	jmp    f01037bd <getint+0x38>
	else if (lflag)
f010379b:	85 d2                	test   %edx,%edx
f010379d:	74 10                	je     f01037af <getint+0x2a>
		return va_arg(*ap, long);
f010379f:	8b 10                	mov    (%eax),%edx
f01037a1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01037a4:	89 08                	mov    %ecx,(%eax)
f01037a6:	8b 02                	mov    (%edx),%eax
f01037a8:	89 c2                	mov    %eax,%edx
f01037aa:	c1 fa 1f             	sar    $0x1f,%edx
f01037ad:	eb 0e                	jmp    f01037bd <getint+0x38>
	else
		return va_arg(*ap, int);
f01037af:	8b 10                	mov    (%eax),%edx
f01037b1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01037b4:	89 08                	mov    %ecx,(%eax)
f01037b6:	8b 02                	mov    (%edx),%eax
f01037b8:	89 c2                	mov    %eax,%edx
f01037ba:	c1 fa 1f             	sar    $0x1f,%edx
}
f01037bd:	5d                   	pop    %ebp
f01037be:	c3                   	ret    

f01037bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01037bf:	55                   	push   %ebp
f01037c0:	89 e5                	mov    %esp,%ebp
f01037c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01037c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01037c9:	8b 10                	mov    (%eax),%edx
f01037cb:	3b 50 04             	cmp    0x4(%eax),%edx
f01037ce:	73 0a                	jae    f01037da <sprintputch+0x1b>
		*b->buf++ = ch;
f01037d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01037d3:	88 0a                	mov    %cl,(%edx)
f01037d5:	83 c2 01             	add    $0x1,%edx
f01037d8:	89 10                	mov    %edx,(%eax)
}
f01037da:	5d                   	pop    %ebp
f01037db:	c3                   	ret    

f01037dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01037dc:	55                   	push   %ebp
f01037dd:	89 e5                	mov    %esp,%ebp
f01037df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01037e2:	8d 45 14             	lea    0x14(%ebp),%eax
f01037e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037e9:	8b 45 10             	mov    0x10(%ebp),%eax
f01037ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01037f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01037fa:	89 04 24             	mov    %eax,(%esp)
f01037fd:	e8 02 00 00 00       	call   f0103804 <vprintfmt>
	va_end(ap);
}
f0103802:	c9                   	leave  
f0103803:	c3                   	ret    

f0103804 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103804:	55                   	push   %ebp
f0103805:	89 e5                	mov    %esp,%ebp
f0103807:	57                   	push   %edi
f0103808:	56                   	push   %esi
f0103809:	53                   	push   %ebx
f010380a:	83 ec 4c             	sub    $0x4c,%esp
f010380d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103810:	8b 75 10             	mov    0x10(%ebp),%esi
f0103813:	eb 12                	jmp    f0103827 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103815:	85 c0                	test   %eax,%eax
f0103817:	0f 84 98 03 00 00    	je     f0103bb5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f010381d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103821:	89 04 24             	mov    %eax,(%esp)
f0103824:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103827:	0f b6 06             	movzbl (%esi),%eax
f010382a:	83 c6 01             	add    $0x1,%esi
f010382d:	83 f8 25             	cmp    $0x25,%eax
f0103830:	75 e3                	jne    f0103815 <vprintfmt+0x11>
f0103832:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0103836:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010383d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0103842:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103849:	b9 00 00 00 00       	mov    $0x0,%ecx
f010384e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103851:	eb 2b                	jmp    f010387e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103853:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103856:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f010385a:	eb 22                	jmp    f010387e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010385c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010385f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0103863:	eb 19                	jmp    f010387e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103865:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103868:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010386f:	eb 0d                	jmp    f010387e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103871:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103874:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103877:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010387e:	0f b6 06             	movzbl (%esi),%eax
f0103881:	0f b6 d0             	movzbl %al,%edx
f0103884:	8d 7e 01             	lea    0x1(%esi),%edi
f0103887:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010388a:	83 e8 23             	sub    $0x23,%eax
f010388d:	3c 55                	cmp    $0x55,%al
f010388f:	0f 87 fa 02 00 00    	ja     f0103b8f <vprintfmt+0x38b>
f0103895:	0f b6 c0             	movzbl %al,%eax
f0103898:	ff 24 85 2c 57 10 f0 	jmp    *-0xfefa8d4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010389f:	83 ea 30             	sub    $0x30,%edx
f01038a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f01038a5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f01038a9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f01038af:	83 fa 09             	cmp    $0x9,%edx
f01038b2:	77 4a                	ja     f01038fe <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01038b7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f01038ba:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f01038bd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f01038c1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01038c4:	8d 50 d0             	lea    -0x30(%eax),%edx
f01038c7:	83 fa 09             	cmp    $0x9,%edx
f01038ca:	76 eb                	jbe    f01038b7 <vprintfmt+0xb3>
f01038cc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01038cf:	eb 2d                	jmp    f01038fe <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01038d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01038d4:	8d 50 04             	lea    0x4(%eax),%edx
f01038d7:	89 55 14             	mov    %edx,0x14(%ebp)
f01038da:	8b 00                	mov    (%eax),%eax
f01038dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01038e2:	eb 1a                	jmp    f01038fe <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f01038e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01038eb:	79 91                	jns    f010387e <vprintfmt+0x7a>
f01038ed:	e9 73 ff ff ff       	jmp    f0103865 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01038f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01038f5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01038fc:	eb 80                	jmp    f010387e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f01038fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103902:	0f 89 76 ff ff ff    	jns    f010387e <vprintfmt+0x7a>
f0103908:	e9 64 ff ff ff       	jmp    f0103871 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010390d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103910:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103913:	e9 66 ff ff ff       	jmp    f010387e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103918:	8b 45 14             	mov    0x14(%ebp),%eax
f010391b:	8d 50 04             	lea    0x4(%eax),%edx
f010391e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103921:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103925:	8b 00                	mov    (%eax),%eax
f0103927:	89 04 24             	mov    %eax,(%esp)
f010392a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010392d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103930:	e9 f2 fe ff ff       	jmp    f0103827 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103935:	8b 45 14             	mov    0x14(%ebp),%eax
f0103938:	8d 50 04             	lea    0x4(%eax),%edx
f010393b:	89 55 14             	mov    %edx,0x14(%ebp)
f010393e:	8b 00                	mov    (%eax),%eax
f0103940:	89 c2                	mov    %eax,%edx
f0103942:	c1 fa 1f             	sar    $0x1f,%edx
f0103945:	31 d0                	xor    %edx,%eax
f0103947:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0103949:	83 f8 06             	cmp    $0x6,%eax
f010394c:	7f 0b                	jg     f0103959 <vprintfmt+0x155>
f010394e:	8b 14 85 84 58 10 f0 	mov    -0xfefa77c(,%eax,4),%edx
f0103955:	85 d2                	test   %edx,%edx
f0103957:	75 23                	jne    f010397c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0103959:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010395d:	c7 44 24 08 b9 56 10 	movl   $0xf01056b9,0x8(%esp)
f0103964:	f0 
f0103965:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103969:	8b 7d 08             	mov    0x8(%ebp),%edi
f010396c:	89 3c 24             	mov    %edi,(%esp)
f010396f:	e8 68 fe ff ff       	call   f01037dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103974:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103977:	e9 ab fe ff ff       	jmp    f0103827 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f010397c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103980:	c7 44 24 08 4f 50 10 	movl   $0xf010504f,0x8(%esp)
f0103987:	f0 
f0103988:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010398c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010398f:	89 3c 24             	mov    %edi,(%esp)
f0103992:	e8 45 fe ff ff       	call   f01037dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103997:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010399a:	e9 88 fe ff ff       	jmp    f0103827 <vprintfmt+0x23>
f010399f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01039a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01039a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01039ab:	8d 50 04             	lea    0x4(%eax),%edx
f01039ae:	89 55 14             	mov    %edx,0x14(%ebp)
f01039b1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01039b3:	85 f6                	test   %esi,%esi
f01039b5:	ba b2 56 10 f0       	mov    $0xf01056b2,%edx
f01039ba:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f01039bd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01039c1:	7e 06                	jle    f01039c9 <vprintfmt+0x1c5>
f01039c3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01039c7:	75 10                	jne    f01039d9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01039c9:	0f be 06             	movsbl (%esi),%eax
f01039cc:	83 c6 01             	add    $0x1,%esi
f01039cf:	85 c0                	test   %eax,%eax
f01039d1:	0f 85 86 00 00 00    	jne    f0103a5d <vprintfmt+0x259>
f01039d7:	eb 76                	jmp    f0103a4f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01039d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01039dd:	89 34 24             	mov    %esi,(%esp)
f01039e0:	e8 36 03 00 00       	call   f0103d1b <strnlen>
f01039e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039e8:	29 c2                	sub    %eax,%edx
f01039ea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01039ed:	85 d2                	test   %edx,%edx
f01039ef:	7e d8                	jle    f01039c9 <vprintfmt+0x1c5>
					putch(padc, putdat);
f01039f1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01039f5:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01039f8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01039fb:	89 d6                	mov    %edx,%esi
f01039fd:	89 c7                	mov    %eax,%edi
f01039ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103a03:	89 3c 24             	mov    %edi,(%esp)
f0103a06:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103a09:	83 ee 01             	sub    $0x1,%esi
f0103a0c:	75 f1                	jne    f01039ff <vprintfmt+0x1fb>
f0103a0e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103a11:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0103a14:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103a17:	eb b0                	jmp    f01039c9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103a19:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103a1d:	74 18                	je     f0103a37 <vprintfmt+0x233>
f0103a1f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103a22:	83 fa 5e             	cmp    $0x5e,%edx
f0103a25:	76 10                	jbe    f0103a37 <vprintfmt+0x233>
					putch('?', putdat);
f0103a27:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103a2b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103a32:	ff 55 08             	call   *0x8(%ebp)
f0103a35:	eb 0a                	jmp    f0103a41 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f0103a37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103a3b:	89 04 24             	mov    %eax,(%esp)
f0103a3e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103a41:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0103a45:	0f be 06             	movsbl (%esi),%eax
f0103a48:	83 c6 01             	add    $0x1,%esi
f0103a4b:	85 c0                	test   %eax,%eax
f0103a4d:	75 0e                	jne    f0103a5d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a4f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103a52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a56:	7f 11                	jg     f0103a69 <vprintfmt+0x265>
f0103a58:	e9 ca fd ff ff       	jmp    f0103827 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103a5d:	85 ff                	test   %edi,%edi
f0103a5f:	90                   	nop
f0103a60:	78 b7                	js     f0103a19 <vprintfmt+0x215>
f0103a62:	83 ef 01             	sub    $0x1,%edi
f0103a65:	79 b2                	jns    f0103a19 <vprintfmt+0x215>
f0103a67:	eb e6                	jmp    f0103a4f <vprintfmt+0x24b>
f0103a69:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103a6c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103a6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103a73:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103a7a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103a7c:	83 ee 01             	sub    $0x1,%esi
f0103a7f:	75 ee                	jne    f0103a6f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a81:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103a84:	e9 9e fd ff ff       	jmp    f0103827 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103a89:	89 ca                	mov    %ecx,%edx
f0103a8b:	8d 45 14             	lea    0x14(%ebp),%eax
f0103a8e:	e8 f2 fc ff ff       	call   f0103785 <getint>
f0103a93:	89 c6                	mov    %eax,%esi
f0103a95:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103a97:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103a9c:	85 d2                	test   %edx,%edx
f0103a9e:	0f 89 ad 00 00 00    	jns    f0103b51 <vprintfmt+0x34d>
				putch('-', putdat);
f0103aa4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103aa8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103aaf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103ab2:	f7 de                	neg    %esi
f0103ab4:	83 d7 00             	adc    $0x0,%edi
f0103ab7:	f7 df                	neg    %edi
			}
			base = 10;
f0103ab9:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103abe:	e9 8e 00 00 00       	jmp    f0103b51 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103ac3:	89 ca                	mov    %ecx,%edx
f0103ac5:	8d 45 14             	lea    0x14(%ebp),%eax
f0103ac8:	e8 7e fc ff ff       	call   f010374b <getuint>
f0103acd:	89 c6                	mov    %eax,%esi
f0103acf:	89 d7                	mov    %edx,%edi
			base = 10;
f0103ad1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103ad6:	eb 79                	jmp    f0103b51 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f0103ad8:	89 ca                	mov    %ecx,%edx
f0103ada:	8d 45 14             	lea    0x14(%ebp),%eax
f0103add:	e8 a3 fc ff ff       	call   f0103785 <getint>
f0103ae2:	89 c6                	mov    %eax,%esi
f0103ae4:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f0103ae6:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103aeb:	85 d2                	test   %edx,%edx
f0103aed:	79 62                	jns    f0103b51 <vprintfmt+0x34d>
				putch('-', putdat);
f0103aef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103af3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103afa:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103afd:	f7 de                	neg    %esi
f0103aff:	83 d7 00             	adc    $0x0,%edi
f0103b02:	f7 df                	neg    %edi
			}
			base = 8;
f0103b04:	b8 08 00 00 00       	mov    $0x8,%eax
f0103b09:	eb 46                	jmp    f0103b51 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f0103b0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b0f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103b16:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103b19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b1d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103b24:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103b27:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b2a:	8d 50 04             	lea    0x4(%eax),%edx
f0103b2d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103b30:	8b 30                	mov    (%eax),%esi
f0103b32:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103b37:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103b3c:	eb 13                	jmp    f0103b51 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103b3e:	89 ca                	mov    %ecx,%edx
f0103b40:	8d 45 14             	lea    0x14(%ebp),%eax
f0103b43:	e8 03 fc ff ff       	call   f010374b <getuint>
f0103b48:	89 c6                	mov    %eax,%esi
f0103b4a:	89 d7                	mov    %edx,%edi
			base = 16;
f0103b4c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103b51:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0103b55:	89 54 24 10          	mov    %edx,0x10(%esp)
f0103b59:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103b5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103b60:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b64:	89 34 24             	mov    %esi,(%esp)
f0103b67:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103b6b:	89 da                	mov    %ebx,%edx
f0103b6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b70:	e8 fb fa ff ff       	call   f0103670 <printnum>
			break;
f0103b75:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103b78:	e9 aa fc ff ff       	jmp    f0103827 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103b7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b81:	89 14 24             	mov    %edx,(%esp)
f0103b84:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b87:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103b8a:	e9 98 fc ff ff       	jmp    f0103827 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103b8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b93:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103b9a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103b9d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103ba1:	0f 84 80 fc ff ff    	je     f0103827 <vprintfmt+0x23>
f0103ba7:	83 ee 01             	sub    $0x1,%esi
f0103baa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103bae:	75 f7                	jne    f0103ba7 <vprintfmt+0x3a3>
f0103bb0:	e9 72 fc ff ff       	jmp    f0103827 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0103bb5:	83 c4 4c             	add    $0x4c,%esp
f0103bb8:	5b                   	pop    %ebx
f0103bb9:	5e                   	pop    %esi
f0103bba:	5f                   	pop    %edi
f0103bbb:	5d                   	pop    %ebp
f0103bbc:	c3                   	ret    

f0103bbd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103bbd:	55                   	push   %ebp
f0103bbe:	89 e5                	mov    %esp,%ebp
f0103bc0:	83 ec 28             	sub    $0x28,%esp
f0103bc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bc6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103bc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103bcc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103bd0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103bd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103bda:	85 c0                	test   %eax,%eax
f0103bdc:	74 30                	je     f0103c0e <vsnprintf+0x51>
f0103bde:	85 d2                	test   %edx,%edx
f0103be0:	7e 2c                	jle    f0103c0e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103be2:	8b 45 14             	mov    0x14(%ebp),%eax
f0103be5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103be9:	8b 45 10             	mov    0x10(%ebp),%eax
f0103bec:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103bf0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bf7:	c7 04 24 bf 37 10 f0 	movl   $0xf01037bf,(%esp)
f0103bfe:	e8 01 fc ff ff       	call   f0103804 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103c03:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103c06:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c0c:	eb 05                	jmp    f0103c13 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103c0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103c13:	c9                   	leave  
f0103c14:	c3                   	ret    

f0103c15 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103c15:	55                   	push   %ebp
f0103c16:	89 e5                	mov    %esp,%ebp
f0103c18:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0103c1b:	8d 45 14             	lea    0x14(%ebp),%eax
f0103c1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c22:	8b 45 10             	mov    0x10(%ebp),%eax
f0103c25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c30:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c33:	89 04 24             	mov    %eax,(%esp)
f0103c36:	e8 82 ff ff ff       	call   f0103bbd <vsnprintf>
	va_end(ap);

	return rc;
}
f0103c3b:	c9                   	leave  
f0103c3c:	c3                   	ret    
f0103c3d:	00 00                	add    %al,(%eax)
	...

f0103c40 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103c40:	55                   	push   %ebp
f0103c41:	89 e5                	mov    %esp,%ebp
f0103c43:	57                   	push   %edi
f0103c44:	56                   	push   %esi
f0103c45:	53                   	push   %ebx
f0103c46:	83 ec 1c             	sub    $0x1c,%esp
f0103c49:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103c4c:	85 c0                	test   %eax,%eax
f0103c4e:	74 10                	je     f0103c60 <readline+0x20>
		cprintf("%s", prompt);
f0103c50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c54:	c7 04 24 4f 50 10 f0 	movl   $0xf010504f,(%esp)
f0103c5b:	e8 2e f3 ff ff       	call   f0102f8e <cprintf>

	i = 0;
	echoing = iscons(0);
f0103c60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103c67:	e8 90 ca ff ff       	call   f01006fc <iscons>
f0103c6c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103c6e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103c73:	e8 73 ca ff ff       	call   f01006eb <getchar>
f0103c78:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103c7a:	85 c0                	test   %eax,%eax
f0103c7c:	79 17                	jns    f0103c95 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c82:	c7 04 24 a0 58 10 f0 	movl   $0xf01058a0,(%esp)
f0103c89:	e8 00 f3 ff ff       	call   f0102f8e <cprintf>
			return NULL;
f0103c8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c93:	eb 61                	jmp    f0103cf6 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103c95:	83 f8 1f             	cmp    $0x1f,%eax
f0103c98:	7e 1f                	jle    f0103cb9 <readline+0x79>
f0103c9a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103ca0:	7f 17                	jg     f0103cb9 <readline+0x79>
			if (echoing)
f0103ca2:	85 ff                	test   %edi,%edi
f0103ca4:	74 08                	je     f0103cae <readline+0x6e>
				cputchar(c);
f0103ca6:	89 04 24             	mov    %eax,(%esp)
f0103ca9:	e8 2a ca ff ff       	call   f01006d8 <cputchar>
			buf[i++] = c;
f0103cae:	88 9e 00 36 17 f0    	mov    %bl,-0xfe8ca00(%esi)
f0103cb4:	83 c6 01             	add    $0x1,%esi
f0103cb7:	eb ba                	jmp    f0103c73 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0103cb9:	83 fb 08             	cmp    $0x8,%ebx
f0103cbc:	75 15                	jne    f0103cd3 <readline+0x93>
f0103cbe:	85 f6                	test   %esi,%esi
f0103cc0:	7e 11                	jle    f0103cd3 <readline+0x93>
			if (echoing)
f0103cc2:	85 ff                	test   %edi,%edi
f0103cc4:	74 08                	je     f0103cce <readline+0x8e>
				cputchar(c);
f0103cc6:	89 1c 24             	mov    %ebx,(%esp)
f0103cc9:	e8 0a ca ff ff       	call   f01006d8 <cputchar>
			i--;
f0103cce:	83 ee 01             	sub    $0x1,%esi
f0103cd1:	eb a0                	jmp    f0103c73 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103cd3:	83 fb 0a             	cmp    $0xa,%ebx
f0103cd6:	74 05                	je     f0103cdd <readline+0x9d>
f0103cd8:	83 fb 0d             	cmp    $0xd,%ebx
f0103cdb:	75 96                	jne    f0103c73 <readline+0x33>
			if (echoing)
f0103cdd:	85 ff                	test   %edi,%edi
f0103cdf:	90                   	nop
f0103ce0:	74 08                	je     f0103cea <readline+0xaa>
				cputchar(c);
f0103ce2:	89 1c 24             	mov    %ebx,(%esp)
f0103ce5:	e8 ee c9 ff ff       	call   f01006d8 <cputchar>
			buf[i] = 0;
f0103cea:	c6 86 00 36 17 f0 00 	movb   $0x0,-0xfe8ca00(%esi)
			return buf;
f0103cf1:	b8 00 36 17 f0       	mov    $0xf0173600,%eax
		}
	}
}
f0103cf6:	83 c4 1c             	add    $0x1c,%esp
f0103cf9:	5b                   	pop    %ebx
f0103cfa:	5e                   	pop    %esi
f0103cfb:	5f                   	pop    %edi
f0103cfc:	5d                   	pop    %ebp
f0103cfd:	c3                   	ret    
	...

f0103d00 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0103d00:	55                   	push   %ebp
f0103d01:	89 e5                	mov    %esp,%ebp
f0103d03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103d06:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d0b:	80 3a 00             	cmpb   $0x0,(%edx)
f0103d0e:	74 09                	je     f0103d19 <strlen+0x19>
		n++;
f0103d10:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103d13:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103d17:	75 f7                	jne    f0103d10 <strlen+0x10>
		n++;
	return n;
}
f0103d19:	5d                   	pop    %ebp
f0103d1a:	c3                   	ret    

f0103d1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103d1b:	55                   	push   %ebp
f0103d1c:	89 e5                	mov    %esp,%ebp
f0103d1e:	53                   	push   %ebx
f0103d1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103d25:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d2a:	85 c9                	test   %ecx,%ecx
f0103d2c:	74 1a                	je     f0103d48 <strnlen+0x2d>
f0103d2e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0103d31:	74 15                	je     f0103d48 <strnlen+0x2d>
f0103d33:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0103d38:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103d3a:	39 ca                	cmp    %ecx,%edx
f0103d3c:	74 0a                	je     f0103d48 <strnlen+0x2d>
f0103d3e:	83 c2 01             	add    $0x1,%edx
f0103d41:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0103d46:	75 f0                	jne    f0103d38 <strnlen+0x1d>
		n++;
	return n;
}
f0103d48:	5b                   	pop    %ebx
f0103d49:	5d                   	pop    %ebp
f0103d4a:	c3                   	ret    

f0103d4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103d4b:	55                   	push   %ebp
f0103d4c:	89 e5                	mov    %esp,%ebp
f0103d4e:	53                   	push   %ebx
f0103d4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103d55:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d5a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103d5e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103d61:	83 c2 01             	add    $0x1,%edx
f0103d64:	84 c9                	test   %cl,%cl
f0103d66:	75 f2                	jne    f0103d5a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103d68:	5b                   	pop    %ebx
f0103d69:	5d                   	pop    %ebp
f0103d6a:	c3                   	ret    

f0103d6b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103d6b:	55                   	push   %ebp
f0103d6c:	89 e5                	mov    %esp,%ebp
f0103d6e:	56                   	push   %esi
f0103d6f:	53                   	push   %ebx
f0103d70:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d73:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d76:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103d79:	85 f6                	test   %esi,%esi
f0103d7b:	74 18                	je     f0103d95 <strncpy+0x2a>
f0103d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103d82:	0f b6 1a             	movzbl (%edx),%ebx
f0103d85:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103d88:	80 3a 01             	cmpb   $0x1,(%edx)
f0103d8b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103d8e:	83 c1 01             	add    $0x1,%ecx
f0103d91:	39 f1                	cmp    %esi,%ecx
f0103d93:	75 ed                	jne    f0103d82 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103d95:	5b                   	pop    %ebx
f0103d96:	5e                   	pop    %esi
f0103d97:	5d                   	pop    %ebp
f0103d98:	c3                   	ret    

f0103d99 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103d99:	55                   	push   %ebp
f0103d9a:	89 e5                	mov    %esp,%ebp
f0103d9c:	57                   	push   %edi
f0103d9d:	56                   	push   %esi
f0103d9e:	53                   	push   %ebx
f0103d9f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103da2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103da5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103da8:	89 f8                	mov    %edi,%eax
f0103daa:	85 f6                	test   %esi,%esi
f0103dac:	74 2b                	je     f0103dd9 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f0103dae:	83 fe 01             	cmp    $0x1,%esi
f0103db1:	74 23                	je     f0103dd6 <strlcpy+0x3d>
f0103db3:	0f b6 0b             	movzbl (%ebx),%ecx
f0103db6:	84 c9                	test   %cl,%cl
f0103db8:	74 1c                	je     f0103dd6 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0103dba:	83 ee 02             	sub    $0x2,%esi
f0103dbd:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103dc2:	88 08                	mov    %cl,(%eax)
f0103dc4:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103dc7:	39 f2                	cmp    %esi,%edx
f0103dc9:	74 0b                	je     f0103dd6 <strlcpy+0x3d>
f0103dcb:	83 c2 01             	add    $0x1,%edx
f0103dce:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103dd2:	84 c9                	test   %cl,%cl
f0103dd4:	75 ec                	jne    f0103dc2 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0103dd6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103dd9:	29 f8                	sub    %edi,%eax
}
f0103ddb:	5b                   	pop    %ebx
f0103ddc:	5e                   	pop    %esi
f0103ddd:	5f                   	pop    %edi
f0103dde:	5d                   	pop    %ebp
f0103ddf:	c3                   	ret    

f0103de0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103de0:	55                   	push   %ebp
f0103de1:	89 e5                	mov    %esp,%ebp
f0103de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103de6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103de9:	0f b6 01             	movzbl (%ecx),%eax
f0103dec:	84 c0                	test   %al,%al
f0103dee:	74 16                	je     f0103e06 <strcmp+0x26>
f0103df0:	3a 02                	cmp    (%edx),%al
f0103df2:	75 12                	jne    f0103e06 <strcmp+0x26>
		p++, q++;
f0103df4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103df7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0103dfb:	84 c0                	test   %al,%al
f0103dfd:	74 07                	je     f0103e06 <strcmp+0x26>
f0103dff:	83 c1 01             	add    $0x1,%ecx
f0103e02:	3a 02                	cmp    (%edx),%al
f0103e04:	74 ee                	je     f0103df4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103e06:	0f b6 c0             	movzbl %al,%eax
f0103e09:	0f b6 12             	movzbl (%edx),%edx
f0103e0c:	29 d0                	sub    %edx,%eax
}
f0103e0e:	5d                   	pop    %ebp
f0103e0f:	c3                   	ret    

f0103e10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103e10:	55                   	push   %ebp
f0103e11:	89 e5                	mov    %esp,%ebp
f0103e13:	53                   	push   %ebx
f0103e14:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e1a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103e22:	85 d2                	test   %edx,%edx
f0103e24:	74 28                	je     f0103e4e <strncmp+0x3e>
f0103e26:	0f b6 01             	movzbl (%ecx),%eax
f0103e29:	84 c0                	test   %al,%al
f0103e2b:	74 24                	je     f0103e51 <strncmp+0x41>
f0103e2d:	3a 03                	cmp    (%ebx),%al
f0103e2f:	75 20                	jne    f0103e51 <strncmp+0x41>
f0103e31:	83 ea 01             	sub    $0x1,%edx
f0103e34:	74 13                	je     f0103e49 <strncmp+0x39>
		n--, p++, q++;
f0103e36:	83 c1 01             	add    $0x1,%ecx
f0103e39:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103e3c:	0f b6 01             	movzbl (%ecx),%eax
f0103e3f:	84 c0                	test   %al,%al
f0103e41:	74 0e                	je     f0103e51 <strncmp+0x41>
f0103e43:	3a 03                	cmp    (%ebx),%al
f0103e45:	74 ea                	je     f0103e31 <strncmp+0x21>
f0103e47:	eb 08                	jmp    f0103e51 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103e49:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103e4e:	5b                   	pop    %ebx
f0103e4f:	5d                   	pop    %ebp
f0103e50:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103e51:	0f b6 01             	movzbl (%ecx),%eax
f0103e54:	0f b6 13             	movzbl (%ebx),%edx
f0103e57:	29 d0                	sub    %edx,%eax
f0103e59:	eb f3                	jmp    f0103e4e <strncmp+0x3e>

f0103e5b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103e5b:	55                   	push   %ebp
f0103e5c:	89 e5                	mov    %esp,%ebp
f0103e5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103e65:	0f b6 10             	movzbl (%eax),%edx
f0103e68:	84 d2                	test   %dl,%dl
f0103e6a:	74 1c                	je     f0103e88 <strchr+0x2d>
		if (*s == c)
f0103e6c:	38 ca                	cmp    %cl,%dl
f0103e6e:	75 09                	jne    f0103e79 <strchr+0x1e>
f0103e70:	eb 1b                	jmp    f0103e8d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103e72:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0103e75:	38 ca                	cmp    %cl,%dl
f0103e77:	74 14                	je     f0103e8d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103e79:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0103e7d:	84 d2                	test   %dl,%dl
f0103e7f:	75 f1                	jne    f0103e72 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0103e81:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e86:	eb 05                	jmp    f0103e8d <strchr+0x32>
f0103e88:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103e8d:	5d                   	pop    %ebp
f0103e8e:	c3                   	ret    

f0103e8f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103e8f:	55                   	push   %ebp
f0103e90:	89 e5                	mov    %esp,%ebp
f0103e92:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e95:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103e99:	0f b6 10             	movzbl (%eax),%edx
f0103e9c:	84 d2                	test   %dl,%dl
f0103e9e:	74 14                	je     f0103eb4 <strfind+0x25>
		if (*s == c)
f0103ea0:	38 ca                	cmp    %cl,%dl
f0103ea2:	75 06                	jne    f0103eaa <strfind+0x1b>
f0103ea4:	eb 0e                	jmp    f0103eb4 <strfind+0x25>
f0103ea6:	38 ca                	cmp    %cl,%dl
f0103ea8:	74 0a                	je     f0103eb4 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103eaa:	83 c0 01             	add    $0x1,%eax
f0103ead:	0f b6 10             	movzbl (%eax),%edx
f0103eb0:	84 d2                	test   %dl,%dl
f0103eb2:	75 f2                	jne    f0103ea6 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0103eb4:	5d                   	pop    %ebp
f0103eb5:	c3                   	ret    

f0103eb6 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0103eb6:	55                   	push   %ebp
f0103eb7:	89 e5                	mov    %esp,%ebp
f0103eb9:	53                   	push   %ebx
f0103eba:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ebd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0103ec3:	89 da                	mov    %ebx,%edx
f0103ec5:	83 ea 01             	sub    $0x1,%edx
f0103ec8:	78 0d                	js     f0103ed7 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f0103eca:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f0103ecc:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f0103ece:	88 0a                	mov    %cl,(%edx)
f0103ed0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0103ed3:	39 da                	cmp    %ebx,%edx
f0103ed5:	75 f7                	jne    f0103ece <memset+0x18>
		*p++ = c;

	return v;
}
f0103ed7:	5b                   	pop    %ebx
f0103ed8:	5d                   	pop    %ebp
f0103ed9:	c3                   	ret    

f0103eda <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f0103eda:	55                   	push   %ebp
f0103edb:	89 e5                	mov    %esp,%ebp
f0103edd:	57                   	push   %edi
f0103ede:	56                   	push   %esi
f0103edf:	53                   	push   %ebx
f0103ee0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ee3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103ee9:	39 c6                	cmp    %eax,%esi
f0103eeb:	72 0b                	jb     f0103ef8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0103eed:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ef2:	85 db                	test   %ebx,%ebx
f0103ef4:	75 29                	jne    f0103f1f <memmove+0x45>
f0103ef6:	eb 35                	jmp    f0103f2d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103ef8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f0103efb:	39 c8                	cmp    %ecx,%eax
f0103efd:	73 ee                	jae    f0103eed <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f0103eff:	85 db                	test   %ebx,%ebx
f0103f01:	74 2a                	je     f0103f2d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0103f03:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f0103f06:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f0103f08:	f7 db                	neg    %ebx
f0103f0a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f0103f0d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f0103f0f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0103f14:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0103f18:	83 ea 01             	sub    $0x1,%edx
f0103f1b:	75 f2                	jne    f0103f0f <memmove+0x35>
f0103f1d:	eb 0e                	jmp    f0103f2d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0103f1f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0103f23:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103f26:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0103f29:	39 d3                	cmp    %edx,%ebx
f0103f2b:	75 f2                	jne    f0103f1f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f0103f2d:	5b                   	pop    %ebx
f0103f2e:	5e                   	pop    %esi
f0103f2f:	5f                   	pop    %edi
f0103f30:	5d                   	pop    %ebp
f0103f31:	c3                   	ret    

f0103f32 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0103f32:	55                   	push   %ebp
f0103f33:	89 e5                	mov    %esp,%ebp
f0103f35:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103f38:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f3b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f46:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f49:	89 04 24             	mov    %eax,(%esp)
f0103f4c:	e8 89 ff ff ff       	call   f0103eda <memmove>
}
f0103f51:	c9                   	leave  
f0103f52:	c3                   	ret    

f0103f53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103f53:	55                   	push   %ebp
f0103f54:	89 e5                	mov    %esp,%ebp
f0103f56:	57                   	push   %edi
f0103f57:	56                   	push   %esi
f0103f58:	53                   	push   %ebx
f0103f59:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f5c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103f5f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103f62:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103f67:	85 ff                	test   %edi,%edi
f0103f69:	74 37                	je     f0103fa2 <memcmp+0x4f>
		if (*s1 != *s2)
f0103f6b:	0f b6 03             	movzbl (%ebx),%eax
f0103f6e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103f71:	83 ef 01             	sub    $0x1,%edi
f0103f74:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0103f79:	38 c8                	cmp    %cl,%al
f0103f7b:	74 1c                	je     f0103f99 <memcmp+0x46>
f0103f7d:	eb 10                	jmp    f0103f8f <memcmp+0x3c>
f0103f7f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0103f84:	83 c2 01             	add    $0x1,%edx
f0103f87:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0103f8b:	38 c8                	cmp    %cl,%al
f0103f8d:	74 0a                	je     f0103f99 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0103f8f:	0f b6 c0             	movzbl %al,%eax
f0103f92:	0f b6 c9             	movzbl %cl,%ecx
f0103f95:	29 c8                	sub    %ecx,%eax
f0103f97:	eb 09                	jmp    f0103fa2 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103f99:	39 fa                	cmp    %edi,%edx
f0103f9b:	75 e2                	jne    f0103f7f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103f9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103fa2:	5b                   	pop    %ebx
f0103fa3:	5e                   	pop    %esi
f0103fa4:	5f                   	pop    %edi
f0103fa5:	5d                   	pop    %ebp
f0103fa6:	c3                   	ret    

f0103fa7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103fa7:	55                   	push   %ebp
f0103fa8:	89 e5                	mov    %esp,%ebp
f0103faa:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103fad:	89 c2                	mov    %eax,%edx
f0103faf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103fb2:	39 d0                	cmp    %edx,%eax
f0103fb4:	73 15                	jae    f0103fcb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103fb6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0103fba:	38 08                	cmp    %cl,(%eax)
f0103fbc:	75 06                	jne    f0103fc4 <memfind+0x1d>
f0103fbe:	eb 0b                	jmp    f0103fcb <memfind+0x24>
f0103fc0:	38 08                	cmp    %cl,(%eax)
f0103fc2:	74 07                	je     f0103fcb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103fc4:	83 c0 01             	add    $0x1,%eax
f0103fc7:	39 d0                	cmp    %edx,%eax
f0103fc9:	75 f5                	jne    f0103fc0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103fcb:	5d                   	pop    %ebp
f0103fcc:	c3                   	ret    

f0103fcd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103fcd:	55                   	push   %ebp
f0103fce:	89 e5                	mov    %esp,%ebp
f0103fd0:	57                   	push   %edi
f0103fd1:	56                   	push   %esi
f0103fd2:	53                   	push   %ebx
f0103fd3:	8b 55 08             	mov    0x8(%ebp),%edx
f0103fd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103fd9:	0f b6 02             	movzbl (%edx),%eax
f0103fdc:	3c 20                	cmp    $0x20,%al
f0103fde:	74 04                	je     f0103fe4 <strtol+0x17>
f0103fe0:	3c 09                	cmp    $0x9,%al
f0103fe2:	75 0e                	jne    f0103ff2 <strtol+0x25>
		s++;
f0103fe4:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103fe7:	0f b6 02             	movzbl (%edx),%eax
f0103fea:	3c 20                	cmp    $0x20,%al
f0103fec:	74 f6                	je     f0103fe4 <strtol+0x17>
f0103fee:	3c 09                	cmp    $0x9,%al
f0103ff0:	74 f2                	je     f0103fe4 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103ff2:	3c 2b                	cmp    $0x2b,%al
f0103ff4:	75 0a                	jne    f0104000 <strtol+0x33>
		s++;
f0103ff6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103ff9:	bf 00 00 00 00       	mov    $0x0,%edi
f0103ffe:	eb 10                	jmp    f0104010 <strtol+0x43>
f0104000:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104005:	3c 2d                	cmp    $0x2d,%al
f0104007:	75 07                	jne    f0104010 <strtol+0x43>
		s++, neg = 1;
f0104009:	83 c2 01             	add    $0x1,%edx
f010400c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104010:	85 db                	test   %ebx,%ebx
f0104012:	0f 94 c0             	sete   %al
f0104015:	74 05                	je     f010401c <strtol+0x4f>
f0104017:	83 fb 10             	cmp    $0x10,%ebx
f010401a:	75 15                	jne    f0104031 <strtol+0x64>
f010401c:	80 3a 30             	cmpb   $0x30,(%edx)
f010401f:	75 10                	jne    f0104031 <strtol+0x64>
f0104021:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104025:	75 0a                	jne    f0104031 <strtol+0x64>
		s += 2, base = 16;
f0104027:	83 c2 02             	add    $0x2,%edx
f010402a:	bb 10 00 00 00       	mov    $0x10,%ebx
f010402f:	eb 13                	jmp    f0104044 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0104031:	84 c0                	test   %al,%al
f0104033:	74 0f                	je     f0104044 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104035:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010403a:	80 3a 30             	cmpb   $0x30,(%edx)
f010403d:	75 05                	jne    f0104044 <strtol+0x77>
		s++, base = 8;
f010403f:	83 c2 01             	add    $0x1,%edx
f0104042:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0104044:	b8 00 00 00 00       	mov    $0x0,%eax
f0104049:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010404b:	0f b6 0a             	movzbl (%edx),%ecx
f010404e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104051:	80 fb 09             	cmp    $0x9,%bl
f0104054:	77 08                	ja     f010405e <strtol+0x91>
			dig = *s - '0';
f0104056:	0f be c9             	movsbl %cl,%ecx
f0104059:	83 e9 30             	sub    $0x30,%ecx
f010405c:	eb 1e                	jmp    f010407c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f010405e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104061:	80 fb 19             	cmp    $0x19,%bl
f0104064:	77 08                	ja     f010406e <strtol+0xa1>
			dig = *s - 'a' + 10;
f0104066:	0f be c9             	movsbl %cl,%ecx
f0104069:	83 e9 57             	sub    $0x57,%ecx
f010406c:	eb 0e                	jmp    f010407c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f010406e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104071:	80 fb 19             	cmp    $0x19,%bl
f0104074:	77 14                	ja     f010408a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104076:	0f be c9             	movsbl %cl,%ecx
f0104079:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010407c:	39 f1                	cmp    %esi,%ecx
f010407e:	7d 0e                	jge    f010408e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104080:	83 c2 01             	add    $0x1,%edx
f0104083:	0f af c6             	imul   %esi,%eax
f0104086:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104088:	eb c1                	jmp    f010404b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010408a:	89 c1                	mov    %eax,%ecx
f010408c:	eb 02                	jmp    f0104090 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010408e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104090:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104094:	74 05                	je     f010409b <strtol+0xce>
		*endptr = (char *) s;
f0104096:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104099:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010409b:	89 ca                	mov    %ecx,%edx
f010409d:	f7 da                	neg    %edx
f010409f:	85 ff                	test   %edi,%edi
f01040a1:	0f 45 c2             	cmovne %edx,%eax
}
f01040a4:	5b                   	pop    %ebx
f01040a5:	5e                   	pop    %esi
f01040a6:	5f                   	pop    %edi
f01040a7:	5d                   	pop    %ebp
f01040a8:	c3                   	ret    
f01040a9:	00 00                	add    %al,(%eax)
f01040ab:	00 00                	add    %al,(%eax)
f01040ad:	00 00                	add    %al,(%eax)
	...

f01040b0 <__udivdi3>:
f01040b0:	83 ec 1c             	sub    $0x1c,%esp
f01040b3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01040b7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f01040bb:	8b 44 24 20          	mov    0x20(%esp),%eax
f01040bf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01040c3:	89 74 24 10          	mov    %esi,0x10(%esp)
f01040c7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01040cb:	85 ff                	test   %edi,%edi
f01040cd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01040d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01040d5:	89 cd                	mov    %ecx,%ebp
f01040d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040db:	75 33                	jne    f0104110 <__udivdi3+0x60>
f01040dd:	39 f1                	cmp    %esi,%ecx
f01040df:	77 57                	ja     f0104138 <__udivdi3+0x88>
f01040e1:	85 c9                	test   %ecx,%ecx
f01040e3:	75 0b                	jne    f01040f0 <__udivdi3+0x40>
f01040e5:	b8 01 00 00 00       	mov    $0x1,%eax
f01040ea:	31 d2                	xor    %edx,%edx
f01040ec:	f7 f1                	div    %ecx
f01040ee:	89 c1                	mov    %eax,%ecx
f01040f0:	89 f0                	mov    %esi,%eax
f01040f2:	31 d2                	xor    %edx,%edx
f01040f4:	f7 f1                	div    %ecx
f01040f6:	89 c6                	mov    %eax,%esi
f01040f8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01040fc:	f7 f1                	div    %ecx
f01040fe:	89 f2                	mov    %esi,%edx
f0104100:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104104:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104108:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010410c:	83 c4 1c             	add    $0x1c,%esp
f010410f:	c3                   	ret    
f0104110:	31 d2                	xor    %edx,%edx
f0104112:	31 c0                	xor    %eax,%eax
f0104114:	39 f7                	cmp    %esi,%edi
f0104116:	77 e8                	ja     f0104100 <__udivdi3+0x50>
f0104118:	0f bd cf             	bsr    %edi,%ecx
f010411b:	83 f1 1f             	xor    $0x1f,%ecx
f010411e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104122:	75 2c                	jne    f0104150 <__udivdi3+0xa0>
f0104124:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0104128:	76 04                	jbe    f010412e <__udivdi3+0x7e>
f010412a:	39 f7                	cmp    %esi,%edi
f010412c:	73 d2                	jae    f0104100 <__udivdi3+0x50>
f010412e:	31 d2                	xor    %edx,%edx
f0104130:	b8 01 00 00 00       	mov    $0x1,%eax
f0104135:	eb c9                	jmp    f0104100 <__udivdi3+0x50>
f0104137:	90                   	nop
f0104138:	89 f2                	mov    %esi,%edx
f010413a:	f7 f1                	div    %ecx
f010413c:	31 d2                	xor    %edx,%edx
f010413e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104142:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104146:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010414a:	83 c4 1c             	add    $0x1c,%esp
f010414d:	c3                   	ret    
f010414e:	66 90                	xchg   %ax,%ax
f0104150:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104155:	b8 20 00 00 00       	mov    $0x20,%eax
f010415a:	89 ea                	mov    %ebp,%edx
f010415c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104160:	d3 e7                	shl    %cl,%edi
f0104162:	89 c1                	mov    %eax,%ecx
f0104164:	d3 ea                	shr    %cl,%edx
f0104166:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010416b:	09 fa                	or     %edi,%edx
f010416d:	89 f7                	mov    %esi,%edi
f010416f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104173:	89 f2                	mov    %esi,%edx
f0104175:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104179:	d3 e5                	shl    %cl,%ebp
f010417b:	89 c1                	mov    %eax,%ecx
f010417d:	d3 ef                	shr    %cl,%edi
f010417f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104184:	d3 e2                	shl    %cl,%edx
f0104186:	89 c1                	mov    %eax,%ecx
f0104188:	d3 ee                	shr    %cl,%esi
f010418a:	09 d6                	or     %edx,%esi
f010418c:	89 fa                	mov    %edi,%edx
f010418e:	89 f0                	mov    %esi,%eax
f0104190:	f7 74 24 0c          	divl   0xc(%esp)
f0104194:	89 d7                	mov    %edx,%edi
f0104196:	89 c6                	mov    %eax,%esi
f0104198:	f7 e5                	mul    %ebp
f010419a:	39 d7                	cmp    %edx,%edi
f010419c:	72 22                	jb     f01041c0 <__udivdi3+0x110>
f010419e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f01041a2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01041a7:	d3 e5                	shl    %cl,%ebp
f01041a9:	39 c5                	cmp    %eax,%ebp
f01041ab:	73 04                	jae    f01041b1 <__udivdi3+0x101>
f01041ad:	39 d7                	cmp    %edx,%edi
f01041af:	74 0f                	je     f01041c0 <__udivdi3+0x110>
f01041b1:	89 f0                	mov    %esi,%eax
f01041b3:	31 d2                	xor    %edx,%edx
f01041b5:	e9 46 ff ff ff       	jmp    f0104100 <__udivdi3+0x50>
f01041ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01041c0:	8d 46 ff             	lea    -0x1(%esi),%eax
f01041c3:	31 d2                	xor    %edx,%edx
f01041c5:	8b 74 24 10          	mov    0x10(%esp),%esi
f01041c9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01041cd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01041d1:	83 c4 1c             	add    $0x1c,%esp
f01041d4:	c3                   	ret    
	...

f01041e0 <__umoddi3>:
f01041e0:	83 ec 1c             	sub    $0x1c,%esp
f01041e3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01041e7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f01041eb:	8b 44 24 20          	mov    0x20(%esp),%eax
f01041ef:	89 74 24 10          	mov    %esi,0x10(%esp)
f01041f3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01041f7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01041fb:	85 ed                	test   %ebp,%ebp
f01041fd:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104201:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104205:	89 cf                	mov    %ecx,%edi
f0104207:	89 04 24             	mov    %eax,(%esp)
f010420a:	89 f2                	mov    %esi,%edx
f010420c:	75 1a                	jne    f0104228 <__umoddi3+0x48>
f010420e:	39 f1                	cmp    %esi,%ecx
f0104210:	76 4e                	jbe    f0104260 <__umoddi3+0x80>
f0104212:	f7 f1                	div    %ecx
f0104214:	89 d0                	mov    %edx,%eax
f0104216:	31 d2                	xor    %edx,%edx
f0104218:	8b 74 24 10          	mov    0x10(%esp),%esi
f010421c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104220:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104224:	83 c4 1c             	add    $0x1c,%esp
f0104227:	c3                   	ret    
f0104228:	39 f5                	cmp    %esi,%ebp
f010422a:	77 54                	ja     f0104280 <__umoddi3+0xa0>
f010422c:	0f bd c5             	bsr    %ebp,%eax
f010422f:	83 f0 1f             	xor    $0x1f,%eax
f0104232:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104236:	75 60                	jne    f0104298 <__umoddi3+0xb8>
f0104238:	3b 0c 24             	cmp    (%esp),%ecx
f010423b:	0f 87 07 01 00 00    	ja     f0104348 <__umoddi3+0x168>
f0104241:	89 f2                	mov    %esi,%edx
f0104243:	8b 34 24             	mov    (%esp),%esi
f0104246:	29 ce                	sub    %ecx,%esi
f0104248:	19 ea                	sbb    %ebp,%edx
f010424a:	89 34 24             	mov    %esi,(%esp)
f010424d:	8b 04 24             	mov    (%esp),%eax
f0104250:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104254:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104258:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010425c:	83 c4 1c             	add    $0x1c,%esp
f010425f:	c3                   	ret    
f0104260:	85 c9                	test   %ecx,%ecx
f0104262:	75 0b                	jne    f010426f <__umoddi3+0x8f>
f0104264:	b8 01 00 00 00       	mov    $0x1,%eax
f0104269:	31 d2                	xor    %edx,%edx
f010426b:	f7 f1                	div    %ecx
f010426d:	89 c1                	mov    %eax,%ecx
f010426f:	89 f0                	mov    %esi,%eax
f0104271:	31 d2                	xor    %edx,%edx
f0104273:	f7 f1                	div    %ecx
f0104275:	8b 04 24             	mov    (%esp),%eax
f0104278:	f7 f1                	div    %ecx
f010427a:	eb 98                	jmp    f0104214 <__umoddi3+0x34>
f010427c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104280:	89 f2                	mov    %esi,%edx
f0104282:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104286:	8b 7c 24 14          	mov    0x14(%esp),%edi
f010428a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010428e:	83 c4 1c             	add    $0x1c,%esp
f0104291:	c3                   	ret    
f0104292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104298:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010429d:	89 e8                	mov    %ebp,%eax
f010429f:	bd 20 00 00 00       	mov    $0x20,%ebp
f01042a4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01042a8:	89 fa                	mov    %edi,%edx
f01042aa:	d3 e0                	shl    %cl,%eax
f01042ac:	89 e9                	mov    %ebp,%ecx
f01042ae:	d3 ea                	shr    %cl,%edx
f01042b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01042b5:	09 c2                	or     %eax,%edx
f01042b7:	8b 44 24 08          	mov    0x8(%esp),%eax
f01042bb:	89 14 24             	mov    %edx,(%esp)
f01042be:	89 f2                	mov    %esi,%edx
f01042c0:	d3 e7                	shl    %cl,%edi
f01042c2:	89 e9                	mov    %ebp,%ecx
f01042c4:	d3 ea                	shr    %cl,%edx
f01042c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01042cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01042cf:	d3 e6                	shl    %cl,%esi
f01042d1:	89 e9                	mov    %ebp,%ecx
f01042d3:	d3 e8                	shr    %cl,%eax
f01042d5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01042da:	09 f0                	or     %esi,%eax
f01042dc:	8b 74 24 08          	mov    0x8(%esp),%esi
f01042e0:	f7 34 24             	divl   (%esp)
f01042e3:	d3 e6                	shl    %cl,%esi
f01042e5:	89 74 24 08          	mov    %esi,0x8(%esp)
f01042e9:	89 d6                	mov    %edx,%esi
f01042eb:	f7 e7                	mul    %edi
f01042ed:	39 d6                	cmp    %edx,%esi
f01042ef:	89 c1                	mov    %eax,%ecx
f01042f1:	89 d7                	mov    %edx,%edi
f01042f3:	72 3f                	jb     f0104334 <__umoddi3+0x154>
f01042f5:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01042f9:	72 35                	jb     f0104330 <__umoddi3+0x150>
f01042fb:	8b 44 24 08          	mov    0x8(%esp),%eax
f01042ff:	29 c8                	sub    %ecx,%eax
f0104301:	19 fe                	sbb    %edi,%esi
f0104303:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104308:	89 f2                	mov    %esi,%edx
f010430a:	d3 e8                	shr    %cl,%eax
f010430c:	89 e9                	mov    %ebp,%ecx
f010430e:	d3 e2                	shl    %cl,%edx
f0104310:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104315:	09 d0                	or     %edx,%eax
f0104317:	89 f2                	mov    %esi,%edx
f0104319:	d3 ea                	shr    %cl,%edx
f010431b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010431f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104323:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104327:	83 c4 1c             	add    $0x1c,%esp
f010432a:	c3                   	ret    
f010432b:	90                   	nop
f010432c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104330:	39 d6                	cmp    %edx,%esi
f0104332:	75 c7                	jne    f01042fb <__umoddi3+0x11b>
f0104334:	89 d7                	mov    %edx,%edi
f0104336:	89 c1                	mov    %eax,%ecx
f0104338:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010433c:	1b 3c 24             	sbb    (%esp),%edi
f010433f:	eb ba                	jmp    f01042fb <__umoddi3+0x11b>
f0104341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104348:	39 f5                	cmp    %esi,%ebp
f010434a:	0f 82 f1 fe ff ff    	jb     f0104241 <__umoddi3+0x61>
f0104350:	e9 f8 fe ff ff       	jmp    f010424d <__umoddi3+0x6d>
