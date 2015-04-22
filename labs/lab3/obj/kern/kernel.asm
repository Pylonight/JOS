
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
f0100015:	0f 01 15 18 90 11 00 	lgdtl  0x119018

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
f0100033:	bc bc 8f 11 f0       	mov    $0xf0118fbc,%esp

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
f0100046:	b8 10 4a 17 f0       	mov    $0xf0174a10,%eax
f010004b:	2d e5 3a 17 f0       	sub    $0xf0173ae5,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 e5 3a 17 f0 	movl   $0xf0173ae5,(%esp)
f0100063:	e8 6e 44 00 00       	call   f01044d6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 44 06 00 00       	call   f01006b1 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 80 49 10 f0 	movl   $0xf0104980,(%esp)
f010007c:	e8 7d 2f 00 00       	call   f0102ffe <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100081:	e8 d2 0a 00 00       	call   f0100b58 <i386_detect_memory>
	i386_vm_init();
f0100086:	e8 78 10 00 00       	call   f0101103 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 36 29 00 00       	call   f01029cb <env_init>
	idt_init();
f0100095:	e8 86 2f 00 00       	call   f0103020 <idt_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE);
#else
	// Touch all you want.
	ENV_CREATE(user_hello);
f010009a:	c7 44 24 04 96 78 00 	movl   $0x7896,0x4(%esp)
f01000a1:	00 
f01000a2:	c7 04 24 78 93 11 f0 	movl   $0xf0119378,(%esp)
f01000a9:	e8 56 2b 00 00       	call   f0102c04 <env_create>
#endif // TEST*


	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000ae:	a1 64 3d 17 f0       	mov    0xf0173d64,%eax
f01000b3:	89 04 24             	mov    %eax,(%esp)
f01000b6:	e8 86 2e 00 00       	call   f0102f41 <env_run>

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
f01000c1:	83 3d 00 3b 17 f0 00 	cmpl   $0x0,0xf0173b00
f01000c8:	75 40                	jne    f010010a <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f01000ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01000cd:	a3 00 3b 17 f0       	mov    %eax,0xf0173b00

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000e0:	c7 04 24 9b 49 10 f0 	movl   $0xf010499b,(%esp)
f01000e7:	e8 12 2f 00 00       	call   f0102ffe <cprintf>
	vcprintf(fmt, ap);
f01000ec:	8d 45 14             	lea    0x14(%ebp),%eax
f01000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000f3:	8b 45 10             	mov    0x10(%ebp),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 cd 2e 00 00       	call   f0102fcb <vcprintf>
	cprintf("\n");
f01000fe:	c7 04 24 cd 57 10 f0 	movl   $0xf01057cd,(%esp)
f0100105:	e8 f4 2e 00 00       	call   f0102ffe <cprintf>
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
f010012c:	c7 04 24 b3 49 10 f0 	movl   $0xf01049b3,(%esp)
f0100133:	e8 c6 2e 00 00       	call   f0102ffe <cprintf>
	vcprintf(fmt, ap);
f0100138:	8d 45 14             	lea    0x14(%ebp),%eax
f010013b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010013f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100142:	89 04 24             	mov    %eax,(%esp)
f0100145:	e8 81 2e 00 00       	call   f0102fcb <vcprintf>
	cprintf("\n");
f010014a:	c7 04 24 cd 57 10 f0 	movl   $0xf01057cd,(%esp)
f0100151:	e8 a8 2e 00 00       	call   f0102ffe <cprintf>
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
f0100197:	83 0d 30 3b 17 f0 40 	orl    $0x40,0xf0173b30
		return 0;
f010019e:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001a3:	e9 c4 00 00 00       	jmp    f010026c <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01001a8:	84 c0                	test   %al,%al
f01001aa:	79 37                	jns    f01001e3 <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ac:	8b 0d 30 3b 17 f0    	mov    0xf0173b30,%ecx
f01001b2:	89 cb                	mov    %ecx,%ebx
f01001b4:	83 e3 40             	and    $0x40,%ebx
f01001b7:	83 e0 7f             	and    $0x7f,%eax
f01001ba:	85 db                	test   %ebx,%ebx
f01001bc:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001bf:	0f b6 d2             	movzbl %dl,%edx
f01001c2:	0f b6 82 e0 4b 10 f0 	movzbl -0xfefb420(%edx),%eax
f01001c9:	83 c8 40             	or     $0x40,%eax
f01001cc:	0f b6 c0             	movzbl %al,%eax
f01001cf:	f7 d0                	not    %eax
f01001d1:	21 c1                	and    %eax,%ecx
f01001d3:	89 0d 30 3b 17 f0    	mov    %ecx,0xf0173b30
		return 0;
f01001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001de:	e9 89 00 00 00       	jmp    f010026c <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01001e3:	8b 0d 30 3b 17 f0    	mov    0xf0173b30,%ecx
f01001e9:	f6 c1 40             	test   $0x40,%cl
f01001ec:	74 0e                	je     f01001fc <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ee:	89 c2                	mov    %eax,%edx
f01001f0:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01001f3:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f6:	89 0d 30 3b 17 f0    	mov    %ecx,0xf0173b30
	}

	shift |= shiftcode[data];
f01001fc:	0f b6 d2             	movzbl %dl,%edx
f01001ff:	0f b6 82 e0 4b 10 f0 	movzbl -0xfefb420(%edx),%eax
f0100206:	0b 05 30 3b 17 f0    	or     0xf0173b30,%eax
	shift ^= togglecode[data];
f010020c:	0f b6 8a e0 4c 10 f0 	movzbl -0xfefb320(%edx),%ecx
f0100213:	31 c8                	xor    %ecx,%eax
f0100215:	a3 30 3b 17 f0       	mov    %eax,0xf0173b30

	c = charcode[shift & (CTL | SHIFT)][data];
f010021a:	89 c1                	mov    %eax,%ecx
f010021c:	83 e1 03             	and    $0x3,%ecx
f010021f:	8b 0c 8d e0 4d 10 f0 	mov    -0xfefb220(,%ecx,4),%ecx
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
f0100255:	c7 04 24 cd 49 10 f0 	movl   $0xf01049cd,(%esp)
f010025c:	e8 9d 2d 00 00       	call   f0102ffe <cprintf>
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
f01002c5:	a3 20 3b 17 f0       	mov    %eax,0xf0173b20
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
f01002ff:	c7 05 24 3b 17 f0 b4 	movl   $0x3b4,0xf0173b24
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
f0100317:	c7 05 24 3b 17 f0 d4 	movl   $0x3d4,0xf0173b24
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
f0100326:	8b 0d 24 3b 17 f0    	mov    0xf0173b24,%ecx
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
f010034b:	89 35 28 3b 17 f0    	mov    %esi,0xf0173b28
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100351:	0f b6 d8             	movzbl %al,%ebx
f0100354:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100356:	66 89 3d 2c 3b 17 f0 	mov    %di,0xf0173b2c
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
f010037f:	8b 15 44 3d 17 f0    	mov    0xf0173d44,%edx
f0100385:	88 82 40 3b 17 f0    	mov    %al,-0xfe8c4c0(%edx)
f010038b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010038e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100393:	ba 00 00 00 00       	mov    $0x0,%edx
f0100398:	0f 44 c2             	cmove  %edx,%eax
f010039b:	a3 44 3d 17 f0       	mov    %eax,0xf0173d44
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
f01003c7:	83 3d 20 3b 17 f0 00 	cmpl   $0x0,0xf0173b20
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
f01003ee:	8b 15 40 3d 17 f0    	mov    0xf0173d40,%edx
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
f01003f9:	3b 15 44 3d 17 f0    	cmp    0xf0173d44,%edx
f01003ff:	74 1e                	je     f010041f <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100401:	0f b6 82 40 3b 17 f0 	movzbl -0xfe8c4c0(%edx),%eax
f0100408:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f010040b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100411:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100416:	0f 44 d1             	cmove  %ecx,%edx
f0100419:	89 15 40 3d 17 f0    	mov    %edx,0xf0173d40
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
f01004aa:	ff 24 95 00 4a 10 f0 	jmp    *-0xfefb600(,%edx,4)
	case '\b':
		if (crt_pos > 0) {
f01004b1:	0f b7 15 2c 3b 17 f0 	movzwl 0xf0173b2c,%edx
f01004b8:	66 85 d2             	test   %dx,%dx
f01004bb:	0f 84 bb 01 00 00    	je     f010067c <cga_putc+0x1fe>
			crt_pos--;
f01004c1:	83 ea 01             	sub    $0x1,%edx
f01004c4:	66 89 15 2c 3b 17 f0 	mov    %dx,0xf0173b2c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004cb:	0f b7 d2             	movzwl %dx,%edx
f01004ce:	b0 00                	mov    $0x0,%al
f01004d0:	89 c1                	mov    %eax,%ecx
f01004d2:	83 c9 20             	or     $0x20,%ecx
f01004d5:	a1 28 3b 17 f0       	mov    0xf0173b28,%eax
f01004da:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f01004de:	e9 4c 01 00 00       	jmp    f010062f <cga_putc+0x1b1>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e3:	66 83 05 2c 3b 17 f0 	addw   $0x50,0xf0173b2c
f01004ea:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004eb:	0f b7 05 2c 3b 17 f0 	movzwl 0xf0173b2c,%eax
f01004f2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f8:	c1 e8 16             	shr    $0x16,%eax
f01004fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fe:	c1 e0 04             	shl    $0x4,%eax
f0100501:	66 a3 2c 3b 17 f0    	mov    %ax,0xf0173b2c
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
f010054d:	0f b7 15 2c 3b 17 f0 	movzwl 0xf0173b2c,%edx
f0100554:	0f b7 da             	movzwl %dx,%ebx
f0100557:	80 e4 f0             	and    $0xf0,%ah
f010055a:	80 cc 0c             	or     $0xc,%ah
f010055d:	8b 0d 28 3b 17 f0    	mov    0xf0173b28,%ecx
f0100563:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100567:	83 c2 01             	add    $0x1,%edx
f010056a:	66 89 15 2c 3b 17 f0 	mov    %dx,0xf0173b2c
		break;
f0100571:	e9 b9 00 00 00       	jmp    f010062f <cga_putc+0x1b1>
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0900;
f0100576:	0f b7 15 2c 3b 17 f0 	movzwl 0xf0173b2c,%edx
f010057d:	0f b7 da             	movzwl %dx,%ebx
f0100580:	80 e4 f0             	and    $0xf0,%ah
f0100583:	80 cc 09             	or     $0x9,%ah
f0100586:	8b 0d 28 3b 17 f0    	mov    0xf0173b28,%ecx
f010058c:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100590:	83 c2 01             	add    $0x1,%edx
f0100593:	66 89 15 2c 3b 17 f0 	mov    %dx,0xf0173b2c
		break;
f010059a:	e9 90 00 00 00       	jmp    f010062f <cga_putc+0x1b1>
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0100;
f010059f:	0f b7 15 2c 3b 17 f0 	movzwl 0xf0173b2c,%edx
f01005a6:	0f b7 da             	movzwl %dx,%ebx
f01005a9:	80 e4 f0             	and    $0xf0,%ah
f01005ac:	80 cc 01             	or     $0x1,%ah
f01005af:	8b 0d 28 3b 17 f0    	mov    0xf0173b28,%ecx
f01005b5:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005b9:	83 c2 01             	add    $0x1,%edx
f01005bc:	66 89 15 2c 3b 17 f0 	mov    %dx,0xf0173b2c
		break;
f01005c3:	eb 6a                	jmp    f010062f <cga_putc+0x1b1>
	case '%':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0e00;
f01005c5:	0f b7 15 2c 3b 17 f0 	movzwl 0xf0173b2c,%edx
f01005cc:	0f b7 da             	movzwl %dx,%ebx
f01005cf:	80 e4 f0             	and    $0xf0,%ah
f01005d2:	80 cc 0e             	or     $0xe,%ah
f01005d5:	8b 0d 28 3b 17 f0    	mov    0xf0173b28,%ecx
f01005db:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005df:	83 c2 01             	add    $0x1,%edx
f01005e2:	66 89 15 2c 3b 17 f0 	mov    %dx,0xf0173b2c
		break;
f01005e9:	eb 44                	jmp    f010062f <cga_putc+0x1b1>
	case '&':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0d00;
f01005eb:	0f b7 15 2c 3b 17 f0 	movzwl 0xf0173b2c,%edx
f01005f2:	0f b7 da             	movzwl %dx,%ebx
f01005f5:	80 e4 f0             	and    $0xf0,%ah
f01005f8:	80 cc 0d             	or     $0xd,%ah
f01005fb:	8b 0d 28 3b 17 f0    	mov    0xf0173b28,%ecx
f0100601:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100605:	83 c2 01             	add    $0x1,%edx
f0100608:	66 89 15 2c 3b 17 f0 	mov    %dx,0xf0173b2c
		break;
f010060f:	eb 1e                	jmp    f010062f <cga_putc+0x1b1>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100611:	0f b7 15 2c 3b 17 f0 	movzwl 0xf0173b2c,%edx
f0100618:	0f b7 da             	movzwl %dx,%ebx
f010061b:	8b 0d 28 3b 17 f0    	mov    0xf0173b28,%ecx
f0100621:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100625:	83 c2 01             	add    $0x1,%edx
f0100628:	66 89 15 2c 3b 17 f0 	mov    %dx,0xf0173b2c
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010062f:	66 81 3d 2c 3b 17 f0 	cmpw   $0x7cf,0xf0173b2c
f0100636:	cf 07 
f0100638:	76 42                	jbe    f010067c <cga_putc+0x1fe>
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010063a:	a1 28 3b 17 f0       	mov    0xf0173b28,%eax
f010063f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100646:	00 
f0100647:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010064d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100651:	89 04 24             	mov    %eax,(%esp)
f0100654:	e8 a1 3e 00 00       	call   f01044fa <memmove>
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0c00 | ' ';
f0100659:	8b 15 28 3b 17 f0    	mov    0xf0173b28,%edx
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
f0100674:	66 83 2d 2c 3b 17 f0 	subw   $0x50,0xf0173b2c
f010067b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010067c:	8b 0d 24 3b 17 f0    	mov    0xf0173b24,%ecx
f0100682:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100687:	89 ca                	mov    %ecx,%edx
f0100689:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010068a:	0f b7 35 2c 3b 17 f0 	movzwl 0xf0173b2c,%esi
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
f01006c1:	83 3d 20 3b 17 f0 00 	cmpl   $0x0,0xf0173b20
f01006c8:	75 0c                	jne    f01006d6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01006ca:	c7 04 24 d9 49 10 f0 	movl   $0xf01049d9,(%esp)
f01006d1:	e8 28 29 00 00       	call   f0102ffe <cprintf>
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
f0100716:	c7 04 24 f0 4d 10 f0 	movl   $0xf0104df0,(%esp)
f010071d:	e8 dc 28 00 00       	call   f0102ffe <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100722:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100729:	00 
f010072a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100731:	f0 
f0100732:	c7 04 24 bc 4e 10 f0 	movl   $0xf0104ebc,(%esp)
f0100739:	e8 c0 28 00 00       	call   f0102ffe <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010073e:	c7 44 24 08 75 49 10 	movl   $0x104975,0x8(%esp)
f0100745:	00 
f0100746:	c7 44 24 04 75 49 10 	movl   $0xf0104975,0x4(%esp)
f010074d:	f0 
f010074e:	c7 04 24 e0 4e 10 f0 	movl   $0xf0104ee0,(%esp)
f0100755:	e8 a4 28 00 00       	call   f0102ffe <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010075a:	c7 44 24 08 e5 3a 17 	movl   $0x173ae5,0x8(%esp)
f0100761:	00 
f0100762:	c7 44 24 04 e5 3a 17 	movl   $0xf0173ae5,0x4(%esp)
f0100769:	f0 
f010076a:	c7 04 24 04 4f 10 f0 	movl   $0xf0104f04,(%esp)
f0100771:	e8 88 28 00 00       	call   f0102ffe <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100776:	c7 44 24 08 10 4a 17 	movl   $0x174a10,0x8(%esp)
f010077d:	00 
f010077e:	c7 44 24 04 10 4a 17 	movl   $0xf0174a10,0x4(%esp)
f0100785:	f0 
f0100786:	c7 04 24 28 4f 10 f0 	movl   $0xf0104f28,(%esp)
f010078d:	e8 6c 28 00 00       	call   f0102ffe <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f0100792:	b8 0f 4e 17 f0       	mov    $0xf0174e0f,%eax
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
f01007ae:	c7 04 24 4c 4f 10 f0 	movl   $0xf0104f4c,(%esp)
f01007b5:	e8 44 28 00 00       	call   f0102ffe <cprintf>
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
f01007cd:	8b 83 44 50 10 f0    	mov    -0xfefafbc(%ebx),%eax
f01007d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d7:	8b 83 40 50 10 f0    	mov    -0xfefafc0(%ebx),%eax
f01007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007e1:	c7 04 24 09 4e 10 f0 	movl   $0xf0104e09,(%esp)
f01007e8:	e8 11 28 00 00       	call   f0102ffe <cprintf>
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
f0100809:	c7 04 24 78 4f 10 f0 	movl   $0xf0104f78,(%esp)
f0100810:	e8 e9 27 00 00       	call   f0102ffe <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100815:	c7 04 24 9c 4f 10 f0 	movl   $0xf0104f9c,(%esp)
f010081c:	e8 dd 27 00 00       	call   f0102ffe <cprintf>

	if (tf != NULL)
f0100821:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100825:	74 0b                	je     f0100832 <monitor+0x32>
		print_trapframe(tf);
f0100827:	8b 45 08             	mov    0x8(%ebp),%eax
f010082a:	89 04 24             	mov    %eax,(%esp)
f010082d:	e8 22 2c 00 00       	call   f0103454 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100832:	c7 04 24 12 4e 10 f0 	movl   $0xf0104e12,(%esp)
f0100839:	e8 22 3a 00 00       	call   f0104260 <readline>
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
f0100866:	c7 04 24 16 4e 10 f0 	movl   $0xf0104e16,(%esp)
f010086d:	e8 09 3c 00 00       	call   f010447b <strchr>
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
f010088a:	c7 04 24 1b 4e 10 f0 	movl   $0xf0104e1b,(%esp)
f0100891:	e8 68 27 00 00       	call   f0102ffe <cprintf>
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
f01008b9:	c7 04 24 16 4e 10 f0 	movl   $0xf0104e16,(%esp)
f01008c0:	e8 b6 3b 00 00       	call   f010447b <strchr>
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
f01008db:	bb 40 50 10 f0       	mov    $0xf0105040,%ebx
f01008e0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e5:	8b 03                	mov    (%ebx),%eax
f01008e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008eb:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ee:	89 04 24             	mov    %eax,(%esp)
f01008f1:	e8 0a 3b 00 00       	call   f0104400 <strcmp>
f01008f6:	85 c0                	test   %eax,%eax
f01008f8:	75 24                	jne    f010091e <monitor+0x11e>
			return commands[i].func(argc, argv, tf);
f01008fa:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008fd:	8b 55 08             	mov    0x8(%ebp),%edx
f0100900:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100904:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100907:	89 54 24 04          	mov    %edx,0x4(%esp)
f010090b:	89 34 24             	mov    %esi,(%esp)
f010090e:	ff 14 85 48 50 10 f0 	call   *-0xfefafb8(,%eax,4)
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
f0100930:	c7 04 24 38 4e 10 f0 	movl   $0xf0104e38,(%esp)
f0100937:	e8 c2 26 00 00       	call   f0102ffe <cprintf>
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
f010095a:	c7 04 24 4e 4e 10 f0 	movl   $0xf0104e4e,(%esp)
f0100961:	e8 98 26 00 00       	call   f0102ffe <cprintf>
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
f0100988:	e8 05 30 00 00       	call   f0103992 <debuginfo_eip>
f010098d:	85 c0                	test   %eax,%eax
f010098f:	0f 88 a5 00 00 00    	js     f0100a3a <mon_backtrace+0xe9>
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
f0100995:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100998:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010099f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a3:	c7 04 24 ab 49 10 f0 	movl   $0xf01049ab,(%esp)
f01009aa:	e8 4f 26 00 00       	call   f0102ffe <cprintf>
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f01009af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01009b3:	7e 24                	jle    f01009d9 <mon_backtrace+0x88>
f01009b5:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
f01009ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009bd:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f01009c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009c5:	c7 04 24 60 4e 10 f0 	movl   $0xf0104e60,(%esp)
f01009cc:	e8 2d 26 00 00       	call   f0102ffe <cprintf>
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
f01009e7:	c7 04 24 63 4e 10 f0 	movl   $0xf0104e63,(%esp)
f01009ee:	e8 0b 26 00 00       	call   f0102ffe <cprintf>
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
f0100a1a:	c7 04 24 c4 4f 10 f0 	movl   $0xf0104fc4,(%esp)
f0100a21:	e8 d8 25 00 00       	call   f0102ffe <cprintf>
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
f0100a3a:	c7 04 24 6c 4e 10 f0 	movl   $0xf0104e6c,(%esp)
f0100a41:	e8 b8 25 00 00       	call   f0102ffe <cprintf>
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
f0100a70:	83 3d 54 3d 17 f0 00 	cmpl   $0x0,0xf0173d54

	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	boot_freemem = ROUNDUP(boot_freemem, align);
f0100a77:	b8 10 4a 17 f0       	mov    $0xf0174a10,%eax
f0100a7c:	0f 45 05 54 3d 17 f0 	cmovne 0xf0173d54,%eax
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
f0100aa3:	89 35 54 3d 17 f0    	mov    %esi,0xf0173d54
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
f0100ad8:	3b 05 00 4a 17 f0    	cmp    0xf0174a00,%eax
f0100ade:	72 20                	jb     f0100b00 <check_va2pa+0x4b>
f0100ae0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100ae4:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0100aeb:	f0 
f0100aec:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0100af3:	00 
f0100af4:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0100b37:	e8 54 24 00 00       	call   f0102f90 <mc146818_read>
f0100b3c:	89 c6                	mov    %eax,%esi
f0100b3e:	83 c3 01             	add    $0x1,%ebx
f0100b41:	89 1c 24             	mov    %ebx,(%esp)
f0100b44:	e8 47 24 00 00       	call   f0102f90 <mc146818_read>
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
f0100b70:	a3 48 3d 17 f0       	mov    %eax,0xf0173d48
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0100b75:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b7a:	e8 a7 ff ff ff       	call   f0100b26 <nvram_read>
f0100b7f:	c1 e0 0a             	shl    $0xa,%eax
f0100b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b87:	a3 4c 3d 17 f0       	mov    %eax,0xf0173d4c

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0100b8c:	85 c0                	test   %eax,%eax
f0100b8e:	74 0c                	je     f0100b9c <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0100b90:	05 00 00 10 00       	add    $0x100000,%eax
f0100b95:	a3 50 3d 17 f0       	mov    %eax,0xf0173d50
f0100b9a:	eb 0a                	jmp    f0100ba6 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0100b9c:	a1 48 3d 17 f0       	mov    0xf0173d48,%eax
f0100ba1:	a3 50 3d 17 f0       	mov    %eax,0xf0173d50

	npage = maxpa / PGSIZE;
f0100ba6:	a1 50 3d 17 f0       	mov    0xf0173d50,%eax
f0100bab:	89 c2                	mov    %eax,%edx
f0100bad:	c1 ea 0c             	shr    $0xc,%edx
f0100bb0:	89 15 00 4a 17 f0    	mov    %edx,0xf0174a00

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100bb6:	c1 e8 0a             	shr    $0xa,%eax
f0100bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bbd:	c7 04 24 88 50 10 f0 	movl   $0xf0105088,(%esp)
f0100bc4:	e8 35 24 00 00       	call   f0102ffe <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100bc9:	a1 4c 3d 17 f0       	mov    0xf0173d4c,%eax
f0100bce:	c1 e8 0a             	shr    $0xa,%eax
f0100bd1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100bd5:	a1 48 3d 17 f0       	mov    0xf0173d48,%eax
f0100bda:	c1 e8 0a             	shr    $0xa,%eax
f0100bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100be1:	c7 04 24 1d 56 10 f0 	movl   $0xf010561d,(%esp)
f0100be8:	e8 11 24 00 00       	call   f0102ffe <cprintf>
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
f0100bf7:	c7 05 58 3d 17 f0 00 	movl   $0x0,0xf0173d58
f0100bfe:	00 00 00 
	for (i = 0; i < npage; i++) {
f0100c01:	83 3d 00 4a 17 f0 00 	cmpl   $0x0,0xf0174a00
f0100c08:	74 5f                	je     f0100c69 <page_init+0x7a>
f0100c0a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c0f:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f0100c14:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0100c17:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
f0100c1e:	8b 1d 0c 4a 17 f0    	mov    0xf0174a0c,%ebx
f0100c24:	66 c7 44 13 08 00 00 	movw   $0x0,0x8(%ebx,%edx,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100c2b:	8b 0d 58 3d 17 f0    	mov    0xf0173d58,%ecx
f0100c31:	89 0c b3             	mov    %ecx,(%ebx,%esi,4)
f0100c34:	85 c9                	test   %ecx,%ecx
f0100c36:	74 11                	je     f0100c49 <page_init+0x5a>
f0100c38:	8b 1d 0c 4a 17 f0    	mov    0xf0174a0c,%ebx
f0100c3e:	01 d3                	add    %edx,%ebx
f0100c40:	8b 0d 58 3d 17 f0    	mov    0xf0173d58,%ecx
f0100c46:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100c49:	03 15 0c 4a 17 f0    	add    0xf0174a0c,%edx
f0100c4f:	89 15 58 3d 17 f0    	mov    %edx,0xf0173d58
f0100c55:	c7 42 04 58 3d 17 f0 	movl   $0xf0173d58,0x4(%edx)
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0100c5c:	83 c0 01             	add    $0x1,%eax
f0100c5f:	89 c2                	mov    %eax,%edx
f0100c61:	3b 05 00 4a 17 f0    	cmp    0xf0174a00,%eax
f0100c67:	72 ab                	jb     f0100c14 <page_init+0x25>
	// --pgstart;	// protect IOPHYSMEM
	// pgend->pp_link = pgstart;

	// the second method, slow
	// but can edit the .ref to 1
	pages[0].pp_ref = 1;
f0100c69:	a1 0c 4a 17 f0       	mov    0xf0174a0c,%eax
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
f0100c87:	8b 1d 54 3d 17 f0    	mov    0xf0173d54,%ebx
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
f0100cbc:	03 05 0c 4a 17 f0    	add    0xf0174a0c,%eax
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
f0100ceb:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f0100cf2:	f0 
f0100cf3:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
f0100cfa:	00 
f0100cfb:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0100d17:	a1 58 3d 17 f0       	mov    0xf0173d58,%eax
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
f0100d4c:	e8 85 37 00 00       	call   f01044d6 <memset>
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
f0100d6f:	c7 44 24 08 d0 50 10 	movl   $0xf01050d0,0x8(%esp)
f0100d76:	f0 
f0100d77:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
f0100d7e:	00 
f0100d7f:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0100d86:	e8 30 f3 ff ff       	call   f01000bb <_panic>
	}
	else
	{
		LIST_INSERT_HEAD(&page_free_list, pp, pp_link);
f0100d8b:	8b 15 58 3d 17 f0    	mov    0xf0173d58,%edx
f0100d91:	89 10                	mov    %edx,(%eax)
f0100d93:	85 d2                	test   %edx,%edx
f0100d95:	74 09                	je     f0100da0 <page_free+0x41>
f0100d97:	8b 15 58 3d 17 f0    	mov    0xf0173d58,%edx
f0100d9d:	89 42 04             	mov    %eax,0x4(%edx)
f0100da0:	a3 58 3d 17 f0       	mov    %eax,0xf0173d58
f0100da5:	c7 40 04 58 3d 17 f0 	movl   $0xf0173d58,0x4(%eax)
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
		// remember, pte_addr is a ptr to pte
		// we got ptr to pte through va, and got va through ptr to pte.
		pte_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100ded:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100df2:	89 c2                	mov    %eax,%edx
f0100df4:	c1 ea 0c             	shr    $0xc,%edx
f0100df7:	3b 15 00 4a 17 f0    	cmp    0xf0174a00,%edx
f0100dfd:	72 20                	jb     f0100e1f <pgdir_walk+0x4e>
f0100dff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e03:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0100e0a:	f0 
f0100e0b:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
f0100e12:	00 
f0100e13:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0100e1a:	e8 9c f2 ff ff       	call   f01000bb <_panic>
		// now it's time to get final pa through va
		// and remember, pte_addr is an array of pointer to phsy pages
		return &pte_addr[PTX(va)];
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
f0100e5a:	2b 05 0c 4a 17 f0    	sub    0xf0174a0c,%eax
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
f0100e71:	3b 15 00 4a 17 f0    	cmp    0xf0174a00,%edx
f0100e77:	72 20                	jb     f0100e99 <pgdir_walk+0xc8>
f0100e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e7d:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0100e8c:	00 
f0100e8d:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0100e94:	e8 22 f2 ff ff       	call   f01000bb <_panic>
f0100e99:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ea0:	00 
f0100ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ea8:	00 
f0100ea9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100eae:	89 04 24             	mov    %eax,(%esp)
f0100eb1:	e8 20 36 00 00       	call   f01044d6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100eb9:	2b 05 0c 4a 17 f0    	sub    0xf0174a0c,%eax
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
				pte_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100ed0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ed5:	89 c2                	mov    %eax,%edx
f0100ed7:	c1 ea 0c             	shr    $0xc,%edx
f0100eda:	3b 15 00 4a 17 f0    	cmp    0xf0174a00,%edx
f0100ee0:	72 20                	jb     f0100f02 <pgdir_walk+0x131>
f0100ee2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee6:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0100eed:	f0 
f0100eee:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100ef5:	00 
f0100ef6:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0100efd:	e8 b9 f1 ff ff       	call   f01000bb <_panic>
				return &pte_addr[PTX(va)];
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
				pte_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
				return &pte_addr[PTX(va)];
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
	pte_t *pte_addr;
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
		if (pte_addr == NULL)
		{
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pte_addr = (pa+i) | perm | PTE_P;
f0100f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f4d:	83 c8 01             	or     $0x1,%eax
f0100f50:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
	{
		// get the page addr
		pte_addr = pgdir_walk(pgdir, (void *)(la+i), 1);
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
		pte_addr = pgdir_walk(pgdir, (void *)(la+i), 1);
f0100f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f62:	89 3c 24             	mov    %edi,(%esp)
f0100f65:	e8 67 fe ff ff       	call   f0100dd1 <pgdir_walk>
		if (pte_addr == NULL)
f0100f6a:	85 c0                	test   %eax,%eax
f0100f6c:	75 1c                	jne    f0100f8a <boot_map_segment+0x63>
		{
			panic("failed to map la to pa in boot_map_segment()");
f0100f6e:	c7 44 24 08 f8 50 10 	movl   $0xf01050f8,0x8(%esp)
f0100f75:	f0 
f0100f76:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100f7d:	00 
f0100f7e:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0100f85:	e8 31 f1 ff ff       	call   f01000bb <_panic>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
f0100f8a:	8b 55 08             	mov    0x8(%ebp),%edx
f0100f8d:	01 da                	add    %ebx,%edx
		if (pte_addr == NULL)
		{
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pte_addr = (pa+i) | perm | PTE_P;
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
		*pte_addr = (pa+i) | perm | PTE_P;
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
	pte_t *pte_addr = pgdir_walk(pgdir, va, 0);
f0100fb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100fb8:	00 
f0100fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fc3:	89 04 24             	mov    %eax,(%esp)
f0100fc6:	e8 06 fe ff ff       	call   f0100dd1 <pgdir_walk>
	if (pte_addr == NULL)
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
			*pte_store = pte_addr;
f0100fd3:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100fd5:	8b 00                	mov    (%eax),%eax
f0100fd7:	c1 e8 0c             	shr    $0xc,%eax
f0100fda:	3b 05 00 4a 17 f0    	cmp    0xf0174a00,%eax
f0100fe0:	72 1c                	jb     f0100ffe <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0100fe2:	c7 44 24 08 28 51 10 	movl   $0xf0105128,0x8(%esp)
f0100fe9:	f0 
f0100fea:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0100ff1:	00 
f0100ff2:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
f0100ff9:	e8 bd f0 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0100ffe:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101001:	c1 e0 02             	shl    $0x2,%eax
f0101004:	03 05 0c 4a 17 f0    	add    0xf0174a0c,%eax
		}
		// pte_addr is ptr to pte, not phsy page addr
		// we need to get pa through ptr to pte, (* is okay)
		// and then get PPN through pa (1), and get page addr
		// through PPN (2); (1) and (2) are done by "pa2page"
		return pa2page(*pte_addr);
f010100a:	eb 05                	jmp    f0101011 <page_lookup+0x6a>
	// Fill this function in
	// never create a new page table
	pte_t *pte_addr = pgdir_walk(pgdir, va, 0);
	if (pte_addr == NULL)
	{
		return NULL;
f010100c:	b8 00 00 00 00       	mov    $0x0,%eax
		// and then get PPN through pa (1), and get page addr
		// through PPN (2); (1) and (2) are done by "pa2page"
		return pa2page(*pte_addr);
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
	pte_t *pte_addr = pgdir_walk(pgdir, va, 1);
f0101087:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010108e:	00 
f010108f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101093:	8b 45 08             	mov    0x8(%ebp),%eax
f0101096:	89 04 24             	mov    %eax,(%esp)
f0101099:	e8 33 fd ff ff       	call   f0100dd1 <pgdir_walk>
f010109e:	89 c3                	mov    %eax,%ebx
	if (pte_addr == NULL)
f01010a0:	85 c0                	test   %eax,%eax
f01010a2:	74 4d                	je     f01010f1 <page_insert+0x7f>
		return -E_NO_MEM;
	}
	else
	{
		// increase pp_ref as insertion succeeds
		++(pp->pp_ref);
f01010a4:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
		// REMEMBER, pte_addr is a ptr to pte
		// *pte_addr will get the value addressed at pte_addr
		// already a page mapped at va, remove it
		if ((*pte_addr & PTE_P) != 0)
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
		// again, through pte_addr we should get pa
		*pte_addr = page2pa(pp) | perm | PTE_P;
f01010cc:	8b 55 14             	mov    0x14(%ebp),%edx
f01010cf:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01010d2:	2b 35 0c 4a 17 f0    	sub    0xf0174a0c,%esi
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
	pte_t *pte_addr = pgdir_walk(pgdir, va, 1);
	if (pte_addr == NULL)
	{
		return -E_NO_MEM;
f01010f1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		}
		// again, through pte_addr we should get pa
		*pte_addr = page2pa(pp) | perm | PTE_P;
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
f0101130:	e8 a1 33 00 00       	call   f01044d6 <memset>
	boot_pgdir = pgdir;
f0101135:	89 1d 08 4a 17 f0    	mov    %ebx,0xf0174a08
	boot_cr3 = PADDR(pgdir);
f010113b:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0101141:	77 20                	ja     f0101163 <i386_vm_init+0x60>
f0101143:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101147:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f010114e:	f0 
f010114f:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
f0101156:	00 
f0101157:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f010115e:	e8 58 ef ff ff       	call   f01000bb <_panic>
f0101163:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0101169:	a3 04 4a 17 f0       	mov    %eax,0xf0174a04
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
f0101182:	a1 00 4a 17 f0       	mov    0xf0174a00,%eax
f0101187:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010118a:	c1 e0 02             	shl    $0x2,%eax
f010118d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101192:	e8 c9 f8 ff ff       	call   f0100a60 <boot_alloc>
f0101197:	a3 0c 4a 17 f0       	mov    %eax,0xf0174a0c

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV*sizeof(struct Env), PGSIZE);
f010119c:	ba 00 10 00 00       	mov    $0x1000,%edx
f01011a1:	b8 00 90 01 00       	mov    $0x19000,%eax
f01011a6:	e8 b5 f8 ff ff       	call   f0100a60 <boot_alloc>
f01011ab:	a3 64 3d 17 f0       	mov    %eax,0xf0173d64
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
f01011b5:	a1 58 3d 17 f0       	mov    0xf0173d58,%eax
f01011ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011bd:	85 c0                	test   %eax,%eax
f01011bf:	0f 84 89 00 00 00    	je     f010124e <i386_vm_init+0x14b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01011c5:	2b 05 0c 4a 17 f0    	sub    0xf0174a0c,%eax
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
f01011dc:	3b 15 00 4a 17 f0    	cmp    0xf0174a00,%edx
f01011e2:	72 41                	jb     f0101225 <i386_vm_init+0x122>
f01011e4:	eb 1f                	jmp    f0101205 <i386_vm_init+0x102>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01011e6:	2b 05 0c 4a 17 f0    	sub    0xf0174a0c,%eax
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
f01011fd:	3b 15 00 4a 17 f0    	cmp    0xf0174a00,%edx
f0101203:	72 20                	jb     f0101225 <i386_vm_init+0x122>
f0101205:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101209:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0101210:	f0 
f0101211:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101218:	00 
f0101219:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
f0101220:	e8 96 ee ff ff       	call   f01000bb <_panic>
		memset(page2kva(pp0), 0x97, 128);
f0101225:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010122c:	00 
f010122d:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101234:	00 
f0101235:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010123a:	89 04 24             	mov    %eax,(%esp)
f010123d:	e8 94 32 00 00       	call   f01044d6 <memset>
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
f0101272:	c7 44 24 0c 47 56 10 	movl   $0xf0105647,0xc(%esp)
f0101279:	f0 
f010127a:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101281:	f0 
f0101282:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f0101289:	00 
f010128a:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101291:	e8 25 ee ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f0101296:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101299:	89 04 24             	mov    %eax,(%esp)
f010129c:	e8 6d fa ff ff       	call   f0100d0e <page_alloc>
f01012a1:	85 c0                	test   %eax,%eax
f01012a3:	74 24                	je     f01012c9 <i386_vm_init+0x1c6>
f01012a5:	c7 44 24 0c 72 56 10 	movl   $0xf0105672,0xc(%esp)
f01012ac:	f0 
f01012ad:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01012b4:	f0 
f01012b5:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f01012bc:	00 
f01012bd:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01012c4:	e8 f2 ed ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f01012c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01012cc:	89 04 24             	mov    %eax,(%esp)
f01012cf:	e8 3a fa ff ff       	call   f0100d0e <page_alloc>
f01012d4:	85 c0                	test   %eax,%eax
f01012d6:	74 24                	je     f01012fc <i386_vm_init+0x1f9>
f01012d8:	c7 44 24 0c 88 56 10 	movl   $0xf0105688,0xc(%esp)
f01012df:	f0 
f01012e0:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01012e7:	f0 
f01012e8:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f01012ef:	00 
f01012f0:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01012f7:	e8 bf ed ff ff       	call   f01000bb <_panic>

	assert(pp0);
f01012fc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012ff:	85 c9                	test   %ecx,%ecx
f0101301:	75 24                	jne    f0101327 <i386_vm_init+0x224>
f0101303:	c7 44 24 0c ac 56 10 	movl   $0xf01056ac,0xc(%esp)
f010130a:	f0 
f010130b:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101312:	f0 
f0101313:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f010131a:	00 
f010131b:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101322:	e8 94 ed ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f0101327:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010132a:	85 d2                	test   %edx,%edx
f010132c:	74 04                	je     f0101332 <i386_vm_init+0x22f>
f010132e:	39 d1                	cmp    %edx,%ecx
f0101330:	75 24                	jne    f0101356 <i386_vm_init+0x253>
f0101332:	c7 44 24 0c 9e 56 10 	movl   $0xf010569e,0xc(%esp)
f0101339:	f0 
f010133a:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101341:	f0 
f0101342:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0101349:	00 
f010134a:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101351:	e8 65 ed ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101356:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101359:	85 c0                	test   %eax,%eax
f010135b:	74 08                	je     f0101365 <i386_vm_init+0x262>
f010135d:	39 c2                	cmp    %eax,%edx
f010135f:	74 04                	je     f0101365 <i386_vm_init+0x262>
f0101361:	39 c1                	cmp    %eax,%ecx
f0101363:	75 24                	jne    f0101389 <i386_vm_init+0x286>
f0101365:	c7 44 24 0c 48 51 10 	movl   $0xf0105148,0xc(%esp)
f010136c:	f0 
f010136d:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101374:	f0 
f0101375:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f010137c:	00 
f010137d:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101384:	e8 32 ed ff ff       	call   f01000bb <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101389:	8b 3d 0c 4a 17 f0    	mov    0xf0174a0c,%edi
        assert(page2pa(pp0) < npage*PGSIZE);
f010138f:	8b 35 00 4a 17 f0    	mov    0xf0174a00,%esi
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
f01013aa:	c7 44 24 0c b0 56 10 	movl   $0xf01056b0,0xc(%esp)
f01013b1:	f0 
f01013b2:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01013b9:	f0 
f01013ba:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f01013c1:	00 
f01013c2:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f01013e0:	c7 44 24 0c cc 56 10 	movl   $0xf01056cc,0xc(%esp)
f01013e7:	f0 
f01013e8:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01013ef:	f0 
f01013f0:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f01013f7:	00 
f01013f8:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0101416:	c7 44 24 0c e8 56 10 	movl   $0xf01056e8,0xc(%esp)
f010141d:	f0 
f010141e:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101425:	f0 
f0101426:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f010142d:	00 
f010142e:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101435:	e8 81 ec ff ff       	call   f01000bb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010143a:	8b 35 58 3d 17 f0    	mov    0xf0173d58,%esi
	LIST_INIT(&page_free_list);
f0101440:	c7 05 58 3d 17 f0 00 	movl   $0x0,0xf0173d58
f0101447:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010144a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f010144d:	89 04 24             	mov    %eax,(%esp)
f0101450:	e8 b9 f8 ff ff       	call   f0100d0e <page_alloc>
f0101455:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101458:	74 24                	je     f010147e <i386_vm_init+0x37b>
f010145a:	c7 44 24 0c 04 57 10 	movl   $0xf0105704,0xc(%esp)
f0101461:	f0 
f0101462:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101469:	f0 
f010146a:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0101471:	00 
f0101472:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f01014c3:	c7 44 24 0c 47 56 10 	movl   $0xf0105647,0xc(%esp)
f01014ca:	f0 
f01014cb:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01014d2:	f0 
f01014d3:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f01014da:	00 
f01014db:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01014e2:	e8 d4 eb ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f01014e7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01014ea:	89 04 24             	mov    %eax,(%esp)
f01014ed:	e8 1c f8 ff ff       	call   f0100d0e <page_alloc>
f01014f2:	85 c0                	test   %eax,%eax
f01014f4:	74 24                	je     f010151a <i386_vm_init+0x417>
f01014f6:	c7 44 24 0c 72 56 10 	movl   $0xf0105672,0xc(%esp)
f01014fd:	f0 
f01014fe:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101505:	f0 
f0101506:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f010150d:	00 
f010150e:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101515:	e8 a1 eb ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f010151a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010151d:	89 04 24             	mov    %eax,(%esp)
f0101520:	e8 e9 f7 ff ff       	call   f0100d0e <page_alloc>
f0101525:	85 c0                	test   %eax,%eax
f0101527:	74 24                	je     f010154d <i386_vm_init+0x44a>
f0101529:	c7 44 24 0c 88 56 10 	movl   $0xf0105688,0xc(%esp)
f0101530:	f0 
f0101531:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101538:	f0 
f0101539:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f0101540:	00 
f0101541:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101548:	e8 6e eb ff ff       	call   f01000bb <_panic>
	assert(pp0);
f010154d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101550:	85 d2                	test   %edx,%edx
f0101552:	75 24                	jne    f0101578 <i386_vm_init+0x475>
f0101554:	c7 44 24 0c ac 56 10 	movl   $0xf01056ac,0xc(%esp)
f010155b:	f0 
f010155c:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101563:	f0 
f0101564:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
f010156b:	00 
f010156c:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101573:	e8 43 eb ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f0101578:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010157b:	85 c9                	test   %ecx,%ecx
f010157d:	74 04                	je     f0101583 <i386_vm_init+0x480>
f010157f:	39 ca                	cmp    %ecx,%edx
f0101581:	75 24                	jne    f01015a7 <i386_vm_init+0x4a4>
f0101583:	c7 44 24 0c 9e 56 10 	movl   $0xf010569e,0xc(%esp)
f010158a:	f0 
f010158b:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101592:	f0 
f0101593:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
f010159a:	00 
f010159b:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01015a2:	e8 14 eb ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	74 08                	je     f01015b6 <i386_vm_init+0x4b3>
f01015ae:	39 c1                	cmp    %eax,%ecx
f01015b0:	74 04                	je     f01015b6 <i386_vm_init+0x4b3>
f01015b2:	39 c2                	cmp    %eax,%edx
f01015b4:	75 24                	jne    f01015da <i386_vm_init+0x4d7>
f01015b6:	c7 44 24 0c 48 51 10 	movl   $0xf0105148,0xc(%esp)
f01015bd:	f0 
f01015be:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01015c5:	f0 
f01015c6:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f01015cd:	00 
f01015ce:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01015d5:	e8 e1 ea ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f01015da:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01015dd:	89 04 24             	mov    %eax,(%esp)
f01015e0:	e8 29 f7 ff ff       	call   f0100d0e <page_alloc>
f01015e5:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01015e8:	74 24                	je     f010160e <i386_vm_init+0x50b>
f01015ea:	c7 44 24 0c 04 57 10 	movl   $0xf0105704,0xc(%esp)
f01015f1:	f0 
f01015f2:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01015f9:	f0 
f01015fa:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0101601:	00 
f0101602:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101609:	e8 ad ea ff ff       	call   f01000bb <_panic>

	// give free list back
	page_free_list = fl;
f010160e:	89 35 58 3d 17 f0    	mov    %esi,0xf0173d58

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
f0101635:	c7 04 24 68 51 10 f0 	movl   $0xf0105168,(%esp)
f010163c:	e8 bd 19 00 00       	call   f0102ffe <cprintf>
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
f0101665:	c7 44 24 0c 47 56 10 	movl   $0xf0105647,0xc(%esp)
f010166c:	f0 
f010166d:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101674:	f0 
f0101675:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f010167c:	00 
f010167d:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101684:	e8 32 ea ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp1) == 0);
f0101689:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010168c:	89 04 24             	mov    %eax,(%esp)
f010168f:	e8 7a f6 ff ff       	call   f0100d0e <page_alloc>
f0101694:	85 c0                	test   %eax,%eax
f0101696:	74 24                	je     f01016bc <i386_vm_init+0x5b9>
f0101698:	c7 44 24 0c 72 56 10 	movl   $0xf0105672,0xc(%esp)
f010169f:	f0 
f01016a0:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01016a7:	f0 
f01016a8:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f01016af:	00 
f01016b0:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01016b7:	e8 ff e9 ff ff       	call   f01000bb <_panic>
	assert(page_alloc(&pp2) == 0);
f01016bc:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01016bf:	89 04 24             	mov    %eax,(%esp)
f01016c2:	e8 47 f6 ff ff       	call   f0100d0e <page_alloc>
f01016c7:	85 c0                	test   %eax,%eax
f01016c9:	74 24                	je     f01016ef <i386_vm_init+0x5ec>
f01016cb:	c7 44 24 0c 88 56 10 	movl   $0xf0105688,0xc(%esp)
f01016d2:	f0 
f01016d3:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01016da:	f0 
f01016db:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f01016e2:	00 
f01016e3:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01016ea:	e8 cc e9 ff ff       	call   f01000bb <_panic>

	assert(pp0);
f01016ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01016f2:	85 d2                	test   %edx,%edx
f01016f4:	75 24                	jne    f010171a <i386_vm_init+0x617>
f01016f6:	c7 44 24 0c ac 56 10 	movl   $0xf01056ac,0xc(%esp)
f01016fd:	f0 
f01016fe:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101705:	f0 
f0101706:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f010170d:	00 
f010170e:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101715:	e8 a1 e9 ff ff       	call   f01000bb <_panic>
	assert(pp1 && pp1 != pp0);
f010171a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010171d:	85 c9                	test   %ecx,%ecx
f010171f:	74 04                	je     f0101725 <i386_vm_init+0x622>
f0101721:	39 ca                	cmp    %ecx,%edx
f0101723:	75 24                	jne    f0101749 <i386_vm_init+0x646>
f0101725:	c7 44 24 0c 9e 56 10 	movl   $0xf010569e,0xc(%esp)
f010172c:	f0 
f010172d:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101734:	f0 
f0101735:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f010173c:	00 
f010173d:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101744:	e8 72 e9 ff ff       	call   f01000bb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101749:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010174c:	85 c0                	test   %eax,%eax
f010174e:	74 08                	je     f0101758 <i386_vm_init+0x655>
f0101750:	39 c1                	cmp    %eax,%ecx
f0101752:	74 04                	je     f0101758 <i386_vm_init+0x655>
f0101754:	39 c2                	cmp    %eax,%edx
f0101756:	75 24                	jne    f010177c <i386_vm_init+0x679>
f0101758:	c7 44 24 0c 48 51 10 	movl   $0xf0105148,0xc(%esp)
f010175f:	f0 
f0101760:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101767:	f0 
f0101768:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f010176f:	00 
f0101770:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101777:	e8 3f e9 ff ff       	call   f01000bb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010177c:	a1 58 3d 17 f0       	mov    0xf0173d58,%eax
f0101781:	89 45 c0             	mov    %eax,-0x40(%ebp)
	LIST_INIT(&page_free_list);
f0101784:	c7 05 58 3d 17 f0 00 	movl   $0x0,0xf0173d58
f010178b:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010178e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101791:	89 04 24             	mov    %eax,(%esp)
f0101794:	e8 75 f5 ff ff       	call   f0100d0e <page_alloc>
f0101799:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010179c:	74 24                	je     f01017c2 <i386_vm_init+0x6bf>
f010179e:	c7 44 24 0c 04 57 10 	movl   $0xf0105704,0xc(%esp)
f01017a5:	f0 
f01017a6:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01017ad:	f0 
f01017ae:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f01017b5:	00 
f01017b6:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01017bd:	e8 f9 e8 ff ff       	call   f01000bb <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f01017c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01017c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01017d0:	00 
f01017d1:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f01017d6:	89 04 24             	mov    %eax,(%esp)
f01017d9:	e8 c9 f7 ff ff       	call   f0100fa7 <page_lookup>
f01017de:	85 c0                	test   %eax,%eax
f01017e0:	74 24                	je     f0101806 <i386_vm_init+0x703>
f01017e2:	c7 44 24 0c 88 51 10 	movl   $0xf0105188,0xc(%esp)
f01017e9:	f0 
f01017ea:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01017f1:	f0 
f01017f2:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f01017f9:	00 
f01017fa:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101801:	e8 b5 e8 ff ff       	call   f01000bb <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0101806:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010180d:	00 
f010180e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101815:	00 
f0101816:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101819:	89 44 24 04          	mov    %eax,0x4(%esp)
f010181d:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0101822:	89 04 24             	mov    %eax,(%esp)
f0101825:	e8 48 f8 ff ff       	call   f0101072 <page_insert>
f010182a:	85 c0                	test   %eax,%eax
f010182c:	78 24                	js     f0101852 <i386_vm_init+0x74f>
f010182e:	c7 44 24 0c c0 51 10 	movl   $0xf01051c0,0xc(%esp)
f0101835:	f0 
f0101836:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f010183d:	f0 
f010183e:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0101845:	00 
f0101846:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0101874:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0101879:	89 04 24             	mov    %eax,(%esp)
f010187c:	e8 f1 f7 ff ff       	call   f0101072 <page_insert>
f0101881:	85 c0                	test   %eax,%eax
f0101883:	74 24                	je     f01018a9 <i386_vm_init+0x7a6>
f0101885:	c7 44 24 0c ec 51 10 	movl   $0xf01051ec,0xc(%esp)
f010188c:	f0 
f010188d:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101894:	f0 
f0101895:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f010189c:	00 
f010189d:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01018a4:	e8 12 e8 ff ff       	call   f01000bb <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f01018a9:	8b 35 08 4a 17 f0    	mov    0xf0174a08,%esi
f01018af:	8b 7d dc             	mov    -0x24(%ebp),%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01018b2:	8b 15 0c 4a 17 f0    	mov    0xf0174a0c,%edx
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
f01018d8:	c7 44 24 0c 18 52 10 	movl   $0xf0105218,0xc(%esp)
f01018df:	f0 
f01018e0:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01018e7:	f0 
f01018e8:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01018ef:	00 
f01018f0:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0101920:	c7 44 24 0c 40 52 10 	movl   $0xf0105240,0xc(%esp)
f0101927:	f0 
f0101928:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f010192f:	f0 
f0101930:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0101937:	00 
f0101938:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f010193f:	e8 77 e7 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 1);
f0101944:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101949:	74 24                	je     f010196f <i386_vm_init+0x86c>
f010194b:	c7 44 24 0c 21 57 10 	movl   $0xf0105721,0xc(%esp)
f0101952:	f0 
f0101953:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f010195a:	f0 
f010195b:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0101962:	00 
f0101963:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f010196a:	e8 4c e7 ff ff       	call   f01000bb <_panic>
	assert(pp0->pp_ref == 1);
f010196f:	66 83 7f 08 01       	cmpw   $0x1,0x8(%edi)
f0101974:	74 24                	je     f010199a <i386_vm_init+0x897>
f0101976:	c7 44 24 0c 32 57 10 	movl   $0xf0105732,0xc(%esp)
f010197d:	f0 
f010197e:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101985:	f0 
f0101986:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f010198d:	00 
f010198e:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f01019bd:	c7 44 24 0c 70 52 10 	movl   $0xf0105270,0xc(%esp)
f01019c4:	f0 
f01019c5:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01019cc:	f0 
f01019cd:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f01019d4:	00 
f01019d5:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01019dc:	e8 da e6 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f01019e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019e6:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f01019eb:	e8 c5 f0 ff ff       	call   f0100ab5 <check_va2pa>
f01019f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01019f3:	89 d1                	mov    %edx,%ecx
f01019f5:	2b 0d 0c 4a 17 f0    	sub    0xf0174a0c,%ecx
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
f0101a0b:	c7 44 24 0c a8 52 10 	movl   $0xf01052a8,0xc(%esp)
f0101a12:	f0 
f0101a13:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101a1a:	f0 
f0101a1b:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101a22:	00 
f0101a23:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101a2a:	e8 8c e6 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101a2f:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101a34:	74 24                	je     f0101a5a <i386_vm_init+0x957>
f0101a36:	c7 44 24 0c 43 57 10 	movl   $0xf0105743,0xc(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0101a4d:	00 
f0101a4e:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101a55:	e8 61 e6 ff ff       	call   f01000bb <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101a5a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101a5d:	89 04 24             	mov    %eax,(%esp)
f0101a60:	e8 a9 f2 ff ff       	call   f0100d0e <page_alloc>
f0101a65:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101a68:	74 24                	je     f0101a8e <i386_vm_init+0x98b>
f0101a6a:	c7 44 24 0c 04 57 10 	movl   $0xf0105704,0xc(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101a79:	f0 
f0101a7a:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101a81:	00 
f0101a82:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101a89:	e8 2d e6 ff ff       	call   f01000bb <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101a8e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101a95:	00 
f0101a96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a9d:	00 
f0101a9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101aa5:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0101aaa:	89 04 24             	mov    %eax,(%esp)
f0101aad:	e8 c0 f5 ff ff       	call   f0101072 <page_insert>
f0101ab2:	85 c0                	test   %eax,%eax
f0101ab4:	74 24                	je     f0101ada <i386_vm_init+0x9d7>
f0101ab6:	c7 44 24 0c 70 52 10 	movl   $0xf0105270,0xc(%esp)
f0101abd:	f0 
f0101abe:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101ac5:	f0 
f0101ac6:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101acd:	00 
f0101ace:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101ad5:	e8 e1 e5 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101ada:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101adf:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0101ae4:	e8 cc ef ff ff       	call   f0100ab5 <check_va2pa>
f0101ae9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101aec:	89 d1                	mov    %edx,%ecx
f0101aee:	2b 0d 0c 4a 17 f0    	sub    0xf0174a0c,%ecx
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
f0101b04:	c7 44 24 0c a8 52 10 	movl   $0xf01052a8,0xc(%esp)
f0101b0b:	f0 
f0101b0c:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101b13:	f0 
f0101b14:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0101b1b:	00 
f0101b1c:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101b23:	e8 93 e5 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101b28:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101b2d:	74 24                	je     f0101b53 <i386_vm_init+0xa50>
f0101b2f:	c7 44 24 0c 43 57 10 	movl   $0xf0105743,0xc(%esp)
f0101b36:	f0 
f0101b37:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101b3e:	f0 
f0101b3f:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101b46:	00 
f0101b47:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101b4e:	e8 68 e5 ff ff       	call   f01000bb <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101b53:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101b56:	89 04 24             	mov    %eax,(%esp)
f0101b59:	e8 b0 f1 ff ff       	call   f0100d0e <page_alloc>
f0101b5e:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101b61:	74 24                	je     f0101b87 <i386_vm_init+0xa84>
f0101b63:	c7 44 24 0c 04 57 10 	movl   $0xf0105704,0xc(%esp)
f0101b6a:	f0 
f0101b6b:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101b72:	f0 
f0101b73:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101b7a:	00 
f0101b7b:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101b82:	e8 34 e5 ff ff       	call   f01000bb <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0101b87:	8b 15 08 4a 17 f0    	mov    0xf0174a08,%edx
f0101b8d:	8b 02                	mov    (%edx),%eax
f0101b8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101b94:	89 c1                	mov    %eax,%ecx
f0101b96:	c1 e9 0c             	shr    $0xc,%ecx
f0101b99:	3b 0d 00 4a 17 f0    	cmp    0xf0174a00,%ecx
f0101b9f:	72 20                	jb     f0101bc1 <i386_vm_init+0xabe>
f0101ba1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ba5:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0101bac:	f0 
f0101bad:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0101bb4:	00 
f0101bb5:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0101beb:	c7 44 24 0c d8 52 10 	movl   $0xf01052d8,0xc(%esp)
f0101bf2:	f0 
f0101bf3:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101bfa:	f0 
f0101bfb:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101c02:	00 
f0101c03:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101c0a:	e8 ac e4 ff ff       	call   f01000bb <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0101c0f:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0101c16:	00 
f0101c17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c1e:	00 
f0101c1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c22:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c26:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0101c2b:	89 04 24             	mov    %eax,(%esp)
f0101c2e:	e8 3f f4 ff ff       	call   f0101072 <page_insert>
f0101c33:	85 c0                	test   %eax,%eax
f0101c35:	74 24                	je     f0101c5b <i386_vm_init+0xb58>
f0101c37:	c7 44 24 0c 18 53 10 	movl   $0xf0105318,0xc(%esp)
f0101c3e:	f0 
f0101c3f:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101c46:	f0 
f0101c47:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101c4e:	00 
f0101c4f:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101c56:	e8 60 e4 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101c5b:	8b 35 08 4a 17 f0    	mov    0xf0174a08,%esi
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
f0101c72:	2b 0d 0c 4a 17 f0    	sub    0xf0174a0c,%ecx
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
f0101c88:	c7 44 24 0c a8 52 10 	movl   $0xf01052a8,0xc(%esp)
f0101c8f:	f0 
f0101c90:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101c97:	f0 
f0101c98:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101c9f:	00 
f0101ca0:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101ca7:	e8 0f e4 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 1);
f0101cac:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101cb1:	74 24                	je     f0101cd7 <i386_vm_init+0xbd4>
f0101cb3:	c7 44 24 0c 43 57 10 	movl   $0xf0105743,0xc(%esp)
f0101cba:	f0 
f0101cbb:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101cc2:	f0 
f0101cc3:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101cca:	00 
f0101ccb:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0101cf4:	c7 44 24 0c 54 53 10 	movl   $0xf0105354,0xc(%esp)
f0101cfb:	f0 
f0101cfc:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101d03:	f0 
f0101d04:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101d0b:	00 
f0101d0c:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101d13:	e8 a3 e3 ff ff       	call   f01000bb <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101d18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101d1f:	00 
f0101d20:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101d27:	00 
f0101d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101d2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d2f:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0101d34:	89 04 24             	mov    %eax,(%esp)
f0101d37:	e8 36 f3 ff ff       	call   f0101072 <page_insert>
f0101d3c:	85 c0                	test   %eax,%eax
f0101d3e:	78 24                	js     f0101d64 <i386_vm_init+0xc61>
f0101d40:	c7 44 24 0c 88 53 10 	movl   $0xf0105388,0xc(%esp)
f0101d47:	f0 
f0101d48:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101d4f:	f0 
f0101d50:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0101d57:	00 
f0101d58:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101d5f:	e8 57 e3 ff ff       	call   f01000bb <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d64:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101d6b:	00 
f0101d6c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d73:	00 
f0101d74:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d7b:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0101d80:	89 04 24             	mov    %eax,(%esp)
f0101d83:	e8 ea f2 ff ff       	call   f0101072 <page_insert>
f0101d88:	85 c0                	test   %eax,%eax
f0101d8a:	74 24                	je     f0101db0 <i386_vm_init+0xcad>
f0101d8c:	c7 44 24 0c bc 53 10 	movl   $0xf01053bc,0xc(%esp)
f0101d93:	f0 
f0101d94:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101d9b:	f0 
f0101d9c:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101da3:	00 
f0101da4:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101dab:	e8 0b e3 ff ff       	call   f01000bb <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0101db0:	8b 3d 08 4a 17 f0    	mov    0xf0174a08,%edi
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
f0101dca:	2b 05 0c 4a 17 f0    	sub    0xf0174a0c,%eax
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
f0101de1:	c7 44 24 0c f4 53 10 	movl   $0xf01053f4,0xc(%esp)
f0101de8:	f0 
f0101de9:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101df0:	f0 
f0101df1:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101df8:	00 
f0101df9:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101e00:	e8 b6 e2 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101e05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e0a:	89 f8                	mov    %edi,%eax
f0101e0c:	e8 a4 ec ff ff       	call   f0100ab5 <check_va2pa>
f0101e11:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101e14:	74 24                	je     f0101e3a <i386_vm_init+0xd37>
f0101e16:	c7 44 24 0c 20 54 10 	movl   $0xf0105420,0xc(%esp)
f0101e1d:	f0 
f0101e1e:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101e25:	f0 
f0101e26:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101e2d:	00 
f0101e2e:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101e35:	e8 81 e2 ff ff       	call   f01000bb <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e3a:	66 83 7e 08 02       	cmpw   $0x2,0x8(%esi)
f0101e3f:	74 24                	je     f0101e65 <i386_vm_init+0xd62>
f0101e41:	c7 44 24 0c 54 57 10 	movl   $0xf0105754,0xc(%esp)
f0101e48:	f0 
f0101e49:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101e50:	f0 
f0101e51:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0101e58:	00 
f0101e59:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101e60:	e8 56 e2 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0101e65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e68:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101e6d:	74 24                	je     f0101e93 <i386_vm_init+0xd90>
f0101e6f:	c7 44 24 0c 65 57 10 	movl   $0xf0105765,0xc(%esp)
f0101e76:	f0 
f0101e77:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101e7e:	f0 
f0101e7f:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101e86:	00 
f0101e87:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0101eaa:	c7 44 24 0c 50 54 10 	movl   $0xf0105450,0xc(%esp)
f0101eb1:	f0 
f0101eb2:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101eb9:	f0 
f0101eba:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101ec1:	00 
f0101ec2:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101ec9:	e8 ed e1 ff ff       	call   f01000bb <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0101ece:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ed5:	00 
f0101ed6:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0101edb:	89 04 24             	mov    %eax,(%esp)
f0101ede:	e8 3f f1 ff ff       	call   f0101022 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101ee3:	8b 35 08 4a 17 f0    	mov    0xf0174a08,%esi
f0101ee9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eee:	89 f0                	mov    %esi,%eax
f0101ef0:	e8 c0 eb ff ff       	call   f0100ab5 <check_va2pa>
f0101ef5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ef8:	74 24                	je     f0101f1e <i386_vm_init+0xe1b>
f0101efa:	c7 44 24 0c 74 54 10 	movl   $0xf0105474,0xc(%esp)
f0101f01:	f0 
f0101f02:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101f11:	00 
f0101f12:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0101f2f:	2b 0d 0c 4a 17 f0    	sub    0xf0174a0c,%ecx
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
f0101f45:	c7 44 24 0c 20 54 10 	movl   $0xf0105420,0xc(%esp)
f0101f4c:	f0 
f0101f4d:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101f54:	f0 
f0101f55:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0101f5c:	00 
f0101f5d:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101f64:	e8 52 e1 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 1);
f0101f69:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101f6e:	74 24                	je     f0101f94 <i386_vm_init+0xe91>
f0101f70:	c7 44 24 0c 21 57 10 	movl   $0xf0105721,0xc(%esp)
f0101f77:	f0 
f0101f78:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101f7f:	f0 
f0101f80:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101f87:	00 
f0101f88:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101f8f:	e8 27 e1 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0101f94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f97:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101f9c:	74 24                	je     f0101fc2 <i386_vm_init+0xebf>
f0101f9e:	c7 44 24 0c 65 57 10 	movl   $0xf0105765,0xc(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101fb5:	00 
f0101fb6:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0101fbd:	e8 f9 e0 ff ff       	call   f01000bb <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0101fc2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fc9:	00 
f0101fca:	89 34 24             	mov    %esi,(%esp)
f0101fcd:	e8 50 f0 ff ff       	call   f0101022 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101fd2:	8b 35 08 4a 17 f0    	mov    0xf0174a08,%esi
f0101fd8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fdd:	89 f0                	mov    %esi,%eax
f0101fdf:	e8 d1 ea ff ff       	call   f0100ab5 <check_va2pa>
f0101fe4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fe7:	74 24                	je     f010200d <i386_vm_init+0xf0a>
f0101fe9:	c7 44 24 0c 74 54 10 	movl   $0xf0105474,0xc(%esp)
f0101ff0:	f0 
f0101ff1:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0101ff8:	f0 
f0101ff9:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0102000:	00 
f0102001:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0102008:	e8 ae e0 ff ff       	call   f01000bb <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f010200d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102012:	89 f0                	mov    %esi,%eax
f0102014:	e8 9c ea ff ff       	call   f0100ab5 <check_va2pa>
f0102019:	83 f8 ff             	cmp    $0xffffffff,%eax
f010201c:	74 24                	je     f0102042 <i386_vm_init+0xf3f>
f010201e:	c7 44 24 0c 98 54 10 	movl   $0xf0105498,0xc(%esp)
f0102025:	f0 
f0102026:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f010202d:	f0 
f010202e:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102035:	00 
f0102036:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f010203d:	e8 79 e0 ff ff       	call   f01000bb <_panic>
	assert(pp1->pp_ref == 0);
f0102042:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102045:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f010204a:	74 24                	je     f0102070 <i386_vm_init+0xf6d>
f010204c:	c7 44 24 0c 76 57 10 	movl   $0xf0105776,0xc(%esp)
f0102053:	f0 
f0102054:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f010205b:	f0 
f010205c:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0102063:	00 
f0102064:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f010206b:	e8 4b e0 ff ff       	call   f01000bb <_panic>
	assert(pp2->pp_ref == 0);
f0102070:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102073:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0102078:	74 24                	je     f010209e <i386_vm_init+0xf9b>
f010207a:	c7 44 24 0c 65 57 10 	movl   $0xf0105765,0xc(%esp)
f0102081:	f0 
f0102082:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0102089:	f0 
f010208a:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102091:	00 
f0102092:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f01020b5:	c7 44 24 0c c0 54 10 	movl   $0xf01054c0,0xc(%esp)
f01020bc:	f0 
f01020bd:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01020c4:	f0 
f01020c5:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01020cc:	00 
f01020cd:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01020d4:	e8 e2 df ff ff       	call   f01000bb <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01020d9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01020dc:	89 04 24             	mov    %eax,(%esp)
f01020df:	e8 2a ec ff ff       	call   f0100d0e <page_alloc>
f01020e4:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01020e7:	74 24                	je     f010210d <i386_vm_init+0x100a>
f01020e9:	c7 44 24 0c 04 57 10 	movl   $0xf0105704,0xc(%esp)
f01020f0:	f0 
f01020f1:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01020f8:	f0 
f01020f9:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102100:	00 
f0102101:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0102108:	e8 ae df ff ff       	call   f01000bb <_panic>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f010210d:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f0102112:	8b 08                	mov    (%eax),%ecx
f0102114:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010211a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010211d:	2b 15 0c 4a 17 f0    	sub    0xf0174a0c,%edx
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
f0102133:	c7 44 24 0c 18 52 10 	movl   $0xf0105218,0xc(%esp)
f010213a:	f0 
f010213b:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0102142:	f0 
f0102143:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010214a:	00 
f010214b:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f0102152:	e8 64 df ff ff       	call   f01000bb <_panic>
	boot_pgdir[0] = 0;
f0102157:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010215d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102160:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f0102165:	74 24                	je     f010218b <i386_vm_init+0x1088>
f0102167:	c7 44 24 0c 32 57 10 	movl   $0xf0105732,0xc(%esp)
f010216e:	f0 
f010216f:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0102176:	f0 
f0102177:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010217e:	00 
f010217f:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f01021a9:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f01021ae:	89 04 24             	mov    %eax,(%esp)
f01021b1:	e8 1b ec ff ff       	call   f0100dd1 <pgdir_walk>
f01021b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f01021b9:	8b 35 08 4a 17 f0    	mov    0xf0174a08,%esi
f01021bf:	8b 56 04             	mov    0x4(%esi),%edx
f01021c2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021c8:	8b 0d 00 4a 17 f0    	mov    0xf0174a00,%ecx
f01021ce:	89 d7                	mov    %edx,%edi
f01021d0:	c1 ef 0c             	shr    $0xc,%edi
f01021d3:	39 cf                	cmp    %ecx,%edi
f01021d5:	72 20                	jb     f01021f7 <i386_vm_init+0x10f4>
f01021d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01021db:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f01021e2:	f0 
f01021e3:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f01021ea:	00 
f01021eb:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01021f2:	e8 c4 de ff ff       	call   f01000bb <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021f7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01021fd:	39 d0                	cmp    %edx,%eax
f01021ff:	74 24                	je     f0102225 <i386_vm_init+0x1122>
f0102201:	c7 44 24 0c 87 57 10 	movl   $0xf0105787,0xc(%esp)
f0102208:	f0 
f0102209:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0102210:	f0 
f0102211:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102218:	00 
f0102219:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0102235:	2b 05 0c 4a 17 f0    	sub    0xf0174a0c,%eax
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
f0102254:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f010225b:	f0 
f010225c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102263:	00 
f0102264:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
f010226b:	e8 4b de ff ff       	call   f01000bb <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102270:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102277:	00 
f0102278:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010227f:	00 
f0102280:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102285:	89 04 24             	mov    %eax,(%esp)
f0102288:	e8 49 22 00 00       	call   f01044d6 <memset>
	page_free(pp0);
f010228d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102290:	89 04 24             	mov    %eax,(%esp)
f0102293:	e8 c7 ea ff ff       	call   f0100d5f <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f0102298:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010229f:	00 
f01022a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022a7:	00 
f01022a8:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f01022ad:	89 04 24             	mov    %eax,(%esp)
f01022b0:	e8 1c eb ff ff       	call   f0100dd1 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01022b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01022b8:	2b 15 0c 4a 17 f0    	sub    0xf0174a0c,%edx
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
f01022cf:	3b 05 00 4a 17 f0    	cmp    0xf0174a00,%eax
f01022d5:	72 20                	jb     f01022f7 <i386_vm_init+0x11f4>
f01022d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01022db:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f01022e2:	f0 
f01022e3:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01022ea:	00 
f01022eb:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
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
f010231a:	c7 44 24 0c 9f 57 10 	movl   $0xf010579f,0xc(%esp)
f0102321:	f0 
f0102322:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0102329:	f0 
f010232a:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102331:	00 
f0102332:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0102345:	a1 08 4a 17 f0       	mov    0xf0174a08,%eax
f010234a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102350:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102353:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f0102359:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010235c:	89 15 58 3d 17 f0    	mov    %edx,0xf0173d58

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
f0102380:	c7 04 24 b6 57 10 f0 	movl   $0xf01057b6,(%esp)
f0102387:	e8 72 0c 00 00       	call   f0102ffe <cprintf>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here:
	// [UPAGES, sizeof(PAGES) ] => [pages, sizeof(PAGES)]
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f010238c:	8b 15 00 4a 17 f0    	mov    0xf0174a00,%edx
	boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f0102392:	a1 0c 4a 17 f0       	mov    0xf0174a0c,%eax
f0102397:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010239c:	77 20                	ja     f01023be <i386_vm_init+0x12bb>
f010239e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023a2:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f01023ea:	a1 64 3d 17 f0       	mov    0xf0173d64,%eax
f01023ef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023f4:	77 20                	ja     f0102416 <i386_vm_init+0x1313>
f01023f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023fa:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f0102401:	f0 
f0102402:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102409:	00 
f010240a:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0102437:	be 00 10 11 f0       	mov    $0xf0111000,%esi
f010243c:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102442:	77 20                	ja     f0102464 <i386_vm_init+0x1361>
f0102444:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102448:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f010244f:	f0 
f0102450:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f0102457:	00 
f0102458:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f010245f:	e8 57 dc ff ff       	call   f01000bb <_panic>
f0102464:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010246b:	00 
f010246c:	c7 04 24 00 10 11 00 	movl   $0x111000,(%esp)
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
f01024a4:	8b 3d 08 4a 17 f0    	mov    0xf0174a08,%edi

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f01024aa:	8b 0d 00 4a 17 f0    	mov    0xf0174a00,%ecx
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
f01024e2:	8b 15 0c 4a 17 f0    	mov    0xf0174a0c,%edx
f01024e8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01024ee:	77 20                	ja     f0102510 <i386_vm_init+0x140d>
f01024f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024f4:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f01024fb:	f0 
f01024fc:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102503:	00 
f0102504:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f010250b:	e8 ab db ff ff       	call   f01000bb <_panic>
f0102510:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102513:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f010251a:	39 d0                	cmp    %edx,%eax
f010251c:	74 24                	je     f0102542 <i386_vm_init+0x143f>
f010251e:	c7 44 24 0c e4 54 10 	movl   $0xf01054e4,0xc(%esp)
f0102525:	f0 
f0102526:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f010252d:	f0 
f010252e:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102535:	00 
f0102536:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0102571:	8b 15 64 3d 17 f0    	mov    0xf0173d64,%edx
f0102577:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010257d:	77 20                	ja     f010259f <i386_vm_init+0x149c>
f010257f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102583:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f010258a:	f0 
f010258b:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0102592:	00 
f0102593:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f010259a:	e8 1c db ff ff       	call   f01000bb <_panic>
f010259f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01025a2:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f01025a9:	39 d0                	cmp    %edx,%eax
f01025ab:	74 24                	je     f01025d1 <i386_vm_init+0x14ce>
f01025ad:	c7 44 24 0c 18 55 10 	movl   $0xf0105518,0xc(%esp)
f01025b4:	f0 
f01025b5:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f01025c4:	00 
f01025c5:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0102603:	c7 44 24 0c 4c 55 10 	movl   $0xf010554c,0xc(%esp)
f010260a:	f0 
f010260b:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0102612:	f0 
f0102613:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f010261a:	00 
f010261b:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f0102658:	c7 44 24 0c 74 55 10 	movl   $0xf0105574,0xc(%esp)
f010265f:	f0 
f0102660:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0102667:	f0 
f0102668:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f010266f:	00 
f0102670:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f010269f:	c7 44 24 0c cf 57 10 	movl   $0xf01057cf,0xc(%esp)
f01026a6:	f0 
f01026a7:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01026ae:	f0 
f01026af:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f01026b6:	00 
f01026b7:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01026be:	e8 f8 d9 ff ff       	call   f01000bb <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f01026c3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01026c8:	76 2a                	jbe    f01026f4 <i386_vm_init+0x15f1>
				assert(pgdir[i]);
f01026ca:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026ce:	75 4e                	jne    f010271e <i386_vm_init+0x161b>
f01026d0:	c7 44 24 0c cf 57 10 	movl   $0xf01057cf,0xc(%esp)
f01026d7:	f0 
f01026d8:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01026df:	f0 
f01026e0:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
f01026e7:	00 
f01026e8:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
f01026ef:	e8 c7 d9 ff ff       	call   f01000bb <_panic>
			else
				assert(pgdir[i] == 0);
f01026f4:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026f8:	74 24                	je     f010271e <i386_vm_init+0x161b>
f01026fa:	c7 44 24 0c d8 57 10 	movl   $0xf01057d8,0xc(%esp)
f0102701:	f0 
f0102702:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f0102709:	f0 
f010270a:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0102711:	00 
f0102712:	c7 04 24 11 56 10 f0 	movl   $0xf0105611,(%esp)
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
f010272c:	c7 04 24 bc 55 10 f0 	movl   $0xf01055bc,(%esp)
f0102733:	e8 c6 08 00 00       	call   f0102ffe <cprintf>
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
f0102740:	a1 04 4a 17 f0       	mov    0xf0174a04,%eax
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
f0102756:	0f 01 15 20 93 11 f0 	lgdtl  0xf0119320
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
f0102780:	a1 04 4a 17 f0       	mov    0xf0174a04,%eax
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
f01027a9:	57                   	push   %edi
f01027aa:	56                   	push   %esi
f01027ab:	53                   	push   %ebx
f01027ac:	83 ec 2c             	sub    $0x2c,%esp
f01027af:	8b 75 08             	mov    0x8(%ebp),%esi
f01027b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	// check user privilege and boundary
	// REMEMBER, pte_t mod PGSIZE = 0, and the lower bits
	// describe the privileges of the page
	// check all range
	pte_t *pte_addr;
	uintptr_t lva = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f01027b5:	89 c3                	mov    %eax,%ebx
f01027b7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t rva = (uintptr_t)ROUNDUP(va+len, PGSIZE);
f01027bd:	03 45 10             	add    0x10(%ebp),%eax
f01027c0:	05 ff 0f 00 00       	add    $0xfff,%eax
f01027c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01027ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			user_mem_check_addr = lva;
			return -E_FAULT;
		}
	}

	return 0;
f01027cd:	b8 00 00 00 00       	mov    $0x0,%eax
	// check all range
	pte_t *pte_addr;
	uintptr_t lva = (uintptr_t)ROUNDDOWN(va, PGSIZE);
	uintptr_t rva = (uintptr_t)ROUNDUP(va+len, PGSIZE);
	// rva is not included
	for (; lva < rva; lva += PGSIZE)
f01027d2:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01027d5:	73 66                	jae    f010283d <user_mem_check+0x97>
	{
		// check boundary
		// record the first erroneous virtual address
		// so it cannot be outside the loop
		if (lva >= ULIM)
f01027d7:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01027dd:	76 17                	jbe    f01027f6 <user_mem_check+0x50>
f01027df:	eb 08                	jmp    f01027e9 <user_mem_check+0x43>
f01027e1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01027e7:	76 13                	jbe    f01027fc <user_mem_check+0x56>
		{
			user_mem_check_addr = lva;
f01027e9:	89 1d 5c 3d 17 f0    	mov    %ebx,0xf0173d5c
			return -E_FAULT;
f01027ef:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01027f4:	eb 47                	jmp    f010283d <user_mem_check+0x97>
		}
		pte_addr = pgdir_walk(env->env_pgdir, (void *)lva, 0);
		// PTE_U has been added when called in "user_mem_assert()"
		if (pte_addr == NULL || (*pte_addr & (perm | PTE_P)) != perm)
f01027f6:	8b 7d 14             	mov    0x14(%ebp),%edi
f01027f9:	83 cf 01             	or     $0x1,%edi
		if (lva >= ULIM)
		{
			user_mem_check_addr = lva;
			return -E_FAULT;
		}
		pte_addr = pgdir_walk(env->env_pgdir, (void *)lva, 0);
f01027fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102803:	00 
f0102804:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102808:	8b 46 5c             	mov    0x5c(%esi),%eax
f010280b:	89 04 24             	mov    %eax,(%esp)
f010280e:	e8 be e5 ff ff       	call   f0100dd1 <pgdir_walk>
		// PTE_U has been added when called in "user_mem_assert()"
		if (pte_addr == NULL || (*pte_addr & (perm | PTE_P)) != perm)
f0102813:	85 c0                	test   %eax,%eax
f0102815:	74 09                	je     f0102820 <user_mem_check+0x7a>
f0102817:	8b 00                	mov    (%eax),%eax
f0102819:	21 f8                	and    %edi,%eax
f010281b:	3b 45 14             	cmp    0x14(%ebp),%eax
f010281e:	74 0d                	je     f010282d <user_mem_check+0x87>
		{
			user_mem_check_addr = lva;
f0102820:	89 1d 5c 3d 17 f0    	mov    %ebx,0xf0173d5c
			return -E_FAULT;
f0102826:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010282b:	eb 10                	jmp    f010283d <user_mem_check+0x97>
	// check all range
	pte_t *pte_addr;
	uintptr_t lva = (uintptr_t)ROUNDDOWN(va, PGSIZE);
	uintptr_t rva = (uintptr_t)ROUNDUP(va+len, PGSIZE);
	// rva is not included
	for (; lva < rva; lva += PGSIZE)
f010282d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102833:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102836:	77 a9                	ja     f01027e1 <user_mem_check+0x3b>
			user_mem_check_addr = lva;
			return -E_FAULT;
		}
	}

	return 0;
f0102838:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010283d:	83 c4 2c             	add    $0x2c,%esp
f0102840:	5b                   	pop    %ebx
f0102841:	5e                   	pop    %esi
f0102842:	5f                   	pop    %edi
f0102843:	5d                   	pop    %ebp
f0102844:	c3                   	ret    

f0102845 <user_mem_assert>:
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102845:	55                   	push   %ebp
f0102846:	89 e5                	mov    %esp,%ebp
f0102848:	53                   	push   %ebx
f0102849:	83 ec 14             	sub    $0x14,%esp
f010284c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010284f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102852:	83 c8 04             	or     $0x4,%eax
f0102855:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102859:	8b 45 10             	mov    0x10(%ebp),%eax
f010285c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102860:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102863:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102867:	89 1c 24             	mov    %ebx,(%esp)
f010286a:	e8 37 ff ff ff       	call   f01027a6 <user_mem_check>
f010286f:	85 c0                	test   %eax,%eax
f0102871:	79 29                	jns    f010289c <user_mem_assert+0x57>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102873:	a1 5c 3d 17 f0       	mov    0xf0173d5c,%eax
f0102878:	89 44 24 08          	mov    %eax,0x8(%esp)
			"va %08x\n", curenv->env_id, user_mem_check_addr);
f010287c:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
f0102881:	8b 40 4c             	mov    0x4c(%eax),%eax
f0102884:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102888:	c7 04 24 dc 55 10 f0 	movl   $0xf01055dc,(%esp)
f010288f:	e8 6a 07 00 00       	call   f0102ffe <cprintf>
			"va %08x\n", curenv->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102894:	89 1c 24             	mov    %ebx,(%esp)
f0102897:	e8 4e 06 00 00       	call   f0102eea <env_destroy>
	}
}
f010289c:	83 c4 14             	add    $0x14,%esp
f010289f:	5b                   	pop    %ebx
f01028a0:	5d                   	pop    %ebp
f01028a1:	c3                   	ret    
	...

f01028a4 <segment_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
segment_alloc(struct Env *e, void *va, size_t len)
{
f01028a4:	55                   	push   %ebp
f01028a5:	89 e5                	mov    %esp,%ebp
f01028a7:	57                   	push   %edi
f01028a8:	56                   	push   %esi
f01028a9:	53                   	push   %ebx
f01028aa:	83 ec 3c             	sub    $0x3c,%esp
f01028ad:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use segment_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round len up.
	// this function will allocates and maps physical memory for an environment.
	va = ROUNDDOWN(va, PGSIZE);
f01028af:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01028b5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	len = ROUNDUP(len, PGSIZE);
f01028b8:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
	struct Page *new_pg;
	int i;
	for (i = 0; i < len; i += PGSIZE)
f01028be:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01028c4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01028c7:	0f 84 83 00 00 00    	je     f0102950 <segment_alloc+0xac>
f01028cd:	bf 00 00 00 00       	mov    $0x0,%edi
f01028d2:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		// allocate a new page
		if (page_alloc(&new_pg) < 0)
f01028d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01028da:	89 04 24             	mov    %eax,(%esp)
f01028dd:	e8 2c e4 ff ff       	call   f0100d0e <page_alloc>
f01028e2:	85 c0                	test   %eax,%eax
f01028e4:	79 1c                	jns    f0102902 <segment_alloc+0x5e>
		{
			panic("segment_alloc(): out of memory\n");
f01028e6:	c7 44 24 08 e8 57 10 	movl   $0xf01057e8,0x8(%esp)
f01028ed:	f0 
f01028ee:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
f01028f5:	00 
f01028f6:	c7 04 24 92 58 10 f0 	movl   $0xf0105892,(%esp)
f01028fd:	e8 b9 d7 ff ff       	call   f01000bb <_panic>
		}
		// must be e->env_pgdir, not pgdir
		// it is allocated according to env pg dir, as it is allocating pages
		// for user process env
		// User, Writable
		if (page_insert(e->env_pgdir, new_pg, va+i, PTE_U | PTE_W) < 0)
f0102902:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102909:	00 
f010290a:	03 7d d4             	add    -0x2c(%ebp),%edi
f010290d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102911:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102914:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102918:	8b 46 5c             	mov    0x5c(%esi),%eax
f010291b:	89 04 24             	mov    %eax,(%esp)
f010291e:	e8 4f e7 ff ff       	call   f0101072 <page_insert>
f0102923:	85 c0                	test   %eax,%eax
f0102925:	79 1c                	jns    f0102943 <segment_alloc+0x9f>
		{
			panic("segment_alloc(): page table cannot be allocated\n");
f0102927:	c7 44 24 08 08 58 10 	movl   $0xf0105808,0x8(%esp)
f010292e:	f0 
f010292f:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
f0102936:	00 
f0102937:	c7 04 24 92 58 10 f0 	movl   $0xf0105892,(%esp)
f010293e:	e8 78 d7 ff ff       	call   f01000bb <_panic>
	// this function will allocates and maps physical memory for an environment.
	va = ROUNDDOWN(va, PGSIZE);
	len = ROUNDUP(len, PGSIZE);
	struct Page *new_pg;
	int i;
	for (i = 0; i < len; i += PGSIZE)
f0102943:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102949:	89 df                	mov    %ebx,%edi
f010294b:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f010294e:	77 87                	ja     f01028d7 <segment_alloc+0x33>
		if (page_insert(e->env_pgdir, new_pg, va+i, PTE_U | PTE_W) < 0)
		{
			panic("segment_alloc(): page table cannot be allocated\n");
		}
	}
}
f0102950:	83 c4 3c             	add    $0x3c,%esp
f0102953:	5b                   	pop    %ebx
f0102954:	5e                   	pop    %esi
f0102955:	5f                   	pop    %edi
f0102956:	5d                   	pop    %ebp
f0102957:	c3                   	ret    

f0102958 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102958:	55                   	push   %ebp
f0102959:	89 e5                	mov    %esp,%ebp
f010295b:	53                   	push   %ebx
f010295c:	8b 45 08             	mov    0x8(%ebp),%eax
f010295f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102962:	85 c0                	test   %eax,%eax
f0102964:	75 0e                	jne    f0102974 <envid2env+0x1c>
		*env_store = curenv;
f0102966:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f010296b:	89 01                	mov    %eax,(%ecx)
		return 0;
f010296d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102972:	eb 54                	jmp    f01029c8 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102974:	89 c2                	mov    %eax,%edx
f0102976:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010297c:	6b d2 64             	imul   $0x64,%edx,%edx
f010297f:	03 15 64 3d 17 f0    	add    0xf0173d64,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102985:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102989:	74 05                	je     f0102990 <envid2env+0x38>
f010298b:	39 42 4c             	cmp    %eax,0x4c(%edx)
f010298e:	74 0d                	je     f010299d <envid2env+0x45>
		*env_store = 0;
f0102990:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102996:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010299b:	eb 2b                	jmp    f01029c8 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010299d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01029a1:	74 1e                	je     f01029c1 <envid2env+0x69>
f01029a3:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f01029a8:	39 c2                	cmp    %eax,%edx
f01029aa:	74 15                	je     f01029c1 <envid2env+0x69>
f01029ac:	8b 58 4c             	mov    0x4c(%eax),%ebx
f01029af:	39 5a 50             	cmp    %ebx,0x50(%edx)
f01029b2:	74 0d                	je     f01029c1 <envid2env+0x69>
		*env_store = 0;
f01029b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01029ba:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01029bf:	eb 07                	jmp    f01029c8 <envid2env+0x70>
	}

	*env_store = e;
f01029c1:	89 11                	mov    %edx,(%ecx)
	return 0;
f01029c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029c8:	5b                   	pop    %ebx
f01029c9:	5d                   	pop    %ebp
f01029ca:	c3                   	ret    

f01029cb <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f01029cb:	55                   	push   %ebp
f01029cc:	89 e5                	mov    %esp,%ebp
f01029ce:	57                   	push   %edi
f01029cf:	56                   	push   %esi
f01029d0:	53                   	push   %ebx
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
f01029d1:	8b 3d 64 3d 17 f0    	mov    0xf0173d64,%edi
f01029d7:	8b 15 68 3d 17 f0    	mov    0xf0173d68,%edx
// and insert them into the env_free_list.
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
f01029dd:	8d 87 9c 8f 01 00    	lea    0x18f9c(%edi),%eax
f01029e3:	b9 00 04 00 00       	mov    $0x400,%ecx
f01029e8:	eb 02                	jmp    f01029ec <env_init+0x21>
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f01029ea:	89 da                	mov    %ebx,%edx
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
f01029ec:	89 c3                	mov    %eax,%ebx
f01029ee:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f01029f5:	89 50 44             	mov    %edx,0x44(%eax)
f01029f8:	85 d2                	test   %edx,%edx
f01029fa:	74 06                	je     f0102a02 <env_init+0x37>
f01029fc:	8d 70 44             	lea    0x44(%eax),%esi
f01029ff:	89 72 48             	mov    %esi,0x48(%edx)
f0102a02:	c7 43 48 68 3d 17 f0 	movl   $0xf0173d68,0x48(%ebx)
f0102a09:	83 e8 64             	sub    $0x64,%eax
	// this function will initialize all of the Env structures
	// in the envs array and add them to the env_free_list.
	// just like page_init()
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
f0102a0c:	83 e9 01             	sub    $0x1,%ecx
f0102a0f:	75 d9                	jne    f01029ea <env_init+0x1f>
f0102a11:	89 3d 68 3d 17 f0    	mov    %edi,0xf0173d68
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
	}
}
f0102a17:	5b                   	pop    %ebx
f0102a18:	5e                   	pop    %esi
f0102a19:	5f                   	pop    %edi
f0102a1a:	5d                   	pop    %ebp
f0102a1b:	c3                   	ret    

f0102a1c <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102a1c:	55                   	push   %ebp
f0102a1d:	89 e5                	mov    %esp,%ebp
f0102a1f:	53                   	push   %ebx
f0102a20:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f0102a23:	8b 1d 68 3d 17 f0    	mov    0xf0173d68,%ebx
f0102a29:	85 db                	test   %ebx,%ebx
f0102a2b:	0f 84 c8 01 00 00    	je     f0102bf9 <env_alloc+0x1dd>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0102a31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f0102a38:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102a3b:	89 04 24             	mov    %eax,(%esp)
f0102a3e:	e8 cb e2 ff ff       	call   f0100d0e <page_alloc>
f0102a43:	85 c0                	test   %eax,%eax
f0102a45:	0f 88 b3 01 00 00    	js     f0102bfe <env_alloc+0x1e2>

	// LAB 3: Your code here.
	// this function will allocate a page directory for a new environment
	// and initialize the kernel portion of the new environment's address space.
	// increase pp_ref
	++(p->pp_ref);
f0102a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a4e:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102a53:	2b 05 0c 4a 17 f0    	sub    0xf0174a0c,%eax
f0102a59:	c1 f8 02             	sar    $0x2,%eax
f0102a5c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102a62:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102a65:	89 c2                	mov    %eax,%edx
f0102a67:	c1 ea 0c             	shr    $0xc,%edx
f0102a6a:	3b 15 00 4a 17 f0    	cmp    0xf0174a00,%edx
f0102a70:	72 20                	jb     f0102a92 <env_alloc+0x76>
f0102a72:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a76:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0102a7d:	f0 
f0102a7e:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102a85:	00 
f0102a86:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
f0102a8d:	e8 29 d6 ff ff       	call   f01000bb <_panic>
	// Attention: need to clear the memory pointed by the page's va,
	// as it holds the process's pg dir.
	// page2kva is the combination of page2pa and KADDR
	// what will happen if "memset" is commented out? have a try.
	memset(page2kva(p), 0, PGSIZE);
f0102a92:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a99:	00 
f0102a9a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102aa1:	00 
f0102aa2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aa7:	89 04 24             	mov    %eax,(%esp)
f0102aaa:	e8 27 1a 00 00       	call   f01044d6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ab2:	2b 05 0c 4a 17 f0    	sub    0xf0174a0c,%eax
f0102ab8:	c1 f8 02             	sar    $0x2,%eax
f0102abb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102ac1:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102ac4:	89 c2                	mov    %eax,%edx
f0102ac6:	c1 ea 0c             	shr    $0xc,%edx
f0102ac9:	3b 15 00 4a 17 f0    	cmp    0xf0174a00,%edx
f0102acf:	72 20                	jb     f0102af1 <env_alloc+0xd5>
f0102ad1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ad5:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0102adc:	f0 
f0102add:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102ae4:	00 
f0102ae5:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
f0102aec:	e8 ca d5 ff ff       	call   f01000bb <_panic>
f0102af1:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0102af7:	89 53 5c             	mov    %edx,0x5c(%ebx)
	// set e->env_pgdir to this pg's va
	e->env_pgdir = page2kva(p);
	// set e->env_cr3 to this pg's pa
	e->env_cr3 = page2pa(p);
f0102afa:	89 43 60             	mov    %eax,0x60(%ebx)
f0102afd:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	// Page directory and page table constants.
	// NPDENTRIES = 1024	// page directory entries per page directory
	// NPTENTRIES = 1024	// page table entries per page table
	for (i = PDX(UTOP); i < NPDENTRIES; ++i)
	{
		e->env_pgdir[i] = boot_pgdir[i];
f0102b02:	8b 15 08 4a 17 f0    	mov    0xf0174a08,%edx
f0102b08:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102b0b:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102b0e:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102b11:	83 c0 04             	add    $0x4,%eax
	// So just copy boot_pgdir to env_pgdir for this part.
	// And UTOP equals UENVS
	// Page directory and page table constants.
	// NPDENTRIES = 1024	// page directory entries per page directory
	// NPTENTRIES = 1024	// page table entries per page table
	for (i = PDX(UTOP); i < NPDENTRIES; ++i)
f0102b14:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102b19:	75 e7                	jne    f0102b02 <env_alloc+0xe6>
		e->env_pgdir[i] = boot_pgdir[i];
	}

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0102b1b:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102b1e:	8b 53 60             	mov    0x60(%ebx),%edx
f0102b21:	83 ca 03             	or     $0x3,%edx
f0102b24:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0102b2a:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102b2d:	8b 53 60             	mov    0x60(%ebx),%edx
f0102b30:	83 ca 05             	or     $0x5,%edx
f0102b33:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102b39:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0102b3c:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102b41:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102b46:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b4b:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102b4e:	89 da                	mov    %ebx,%edx
f0102b50:	2b 15 64 3d 17 f0    	sub    0xf0173d64,%edx
f0102b56:	c1 fa 02             	sar    $0x2,%edx
f0102b59:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0102b5f:	09 d0                	or     %edx,%eax
f0102b61:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102b64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b67:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102b6a:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102b71:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102b78:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102b7f:	00 
f0102b80:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b87:	00 
f0102b88:	89 1c 24             	mov    %ebx,(%esp)
f0102b8b:	e8 46 19 00 00       	call   f01044d6 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0102b90:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102b96:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102b9c:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102ba2:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102ba9:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0102baf:	8b 43 44             	mov    0x44(%ebx),%eax
f0102bb2:	85 c0                	test   %eax,%eax
f0102bb4:	74 06                	je     f0102bbc <env_alloc+0x1a0>
f0102bb6:	8b 53 48             	mov    0x48(%ebx),%edx
f0102bb9:	89 50 48             	mov    %edx,0x48(%eax)
f0102bbc:	8b 43 48             	mov    0x48(%ebx),%eax
f0102bbf:	8b 53 44             	mov    0x44(%ebx),%edx
f0102bc2:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f0102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bc7:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102bc9:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0102bcc:	8b 15 60 3d 17 f0    	mov    0xf0173d60,%edx
f0102bd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bd7:	85 d2                	test   %edx,%edx
f0102bd9:	74 03                	je     f0102bde <env_alloc+0x1c2>
f0102bdb:	8b 42 4c             	mov    0x4c(%edx),%eax
f0102bde:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102be2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102be6:	c7 04 24 9d 58 10 f0 	movl   $0xf010589d,(%esp)
f0102bed:	e8 0c 04 00 00       	call   f0102ffe <cprintf>
	return 0;
f0102bf2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bf7:	eb 05                	jmp    f0102bfe <env_alloc+0x1e2>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
f0102bf9:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102bfe:	83 c4 24             	add    $0x24,%esp
f0102c01:	5b                   	pop    %ebx
f0102c02:	5d                   	pop    %ebp
f0102c03:	c3                   	ret    

f0102c04 <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f0102c04:	55                   	push   %ebp
f0102c05:	89 e5                	mov    %esp,%ebp
f0102c07:	57                   	push   %edi
f0102c08:	56                   	push   %esi
f0102c09:	53                   	push   %ebx
f0102c0a:	83 ec 3c             	sub    $0x3c,%esp
f0102c0d:	8b 7d 08             	mov    0x8(%ebp),%edi
	// about env_alloc(struct Env **newenv_store, envid_t parent_id):
	// Allocates and initializes a new environment.
	// On success, the new environment is stored in *newenv_store.
	struct Env *env;
	// The new env's parent ID is set to 0, as the first.
	int env_alloc_info = env_alloc(&env, 0);
f0102c10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c17:	00 
f0102c18:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102c1b:	89 04 24             	mov    %eax,(%esp)
f0102c1e:	e8 f9 fd ff ff       	call   f0102a1c <env_alloc>
	if (env_alloc_info < 0)
f0102c23:	85 c0                	test   %eax,%eax
f0102c25:	79 20                	jns    f0102c47 <env_create+0x43>
	{
		panic("env_alloc: %e", env_alloc_info);
f0102c27:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c2b:	c7 44 24 08 b2 58 10 	movl   $0xf01058b2,0x8(%esp)
f0102c32:	f0 
f0102c33:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
f0102c3a:	00 
f0102c3b:	c7 04 24 92 58 10 f0 	movl   $0xf0105892,(%esp)
f0102c42:	e8 74 d4 ff ff       	call   f01000bb <_panic>
	}
	load_icode(env, binary, size);
f0102c47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// only load segments with ph->p_type == ELF_PROG_LOAD.
	struct Elf *env_elf;
	struct Proghdr *ph, *eph;
	env_elf = (struct Elf *)binary;
	// magic number check
	if(env_elf->e_magic != ELF_MAGIC)
f0102c4d:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102c53:	74 1c                	je     f0102c71 <env_create+0x6d>
	{
		panic("load_icode(): Not a valid ELF!\n");
f0102c55:	c7 44 24 08 3c 58 10 	movl   $0xf010583c,0x8(%esp)
f0102c5c:	f0 
f0102c5d:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f0102c64:	00 
f0102c65:	c7 04 24 92 58 10 f0 	movl   $0xf0105892,(%esp)
f0102c6c:	e8 4a d4 ff ff       	call   f01000bb <_panic>
	}	
	// load each program segment (ignores ph flags)
	// e_phoff means program header table offset
	// the start position
	ph = (struct Proghdr *)((uint8_t *)(env_elf)+env_elf->e_phoff);
f0102c71:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	// the end position, e_phnum means the number of program
	// header table entries
	eph = ph+env_elf->e_phnum;
f0102c74:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0102c78:	0f 20 da             	mov    %cr3,%edx
f0102c7b:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// save old cr3, cr3 stores the page dir addr(pa)
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
f0102c7e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c81:	8b 42 5c             	mov    0x5c(%edx),%eax
f0102c84:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c89:	77 20                	ja     f0102cab <env_create+0xa7>
f0102c8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c8f:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f0102c96:	f0 
f0102c97:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
f0102c9e:	00 
f0102c9f:	c7 04 24 92 58 10 f0 	movl   $0xf0105892,(%esp)
f0102ca6:	e8 10 d4 ff ff       	call   f01000bb <_panic>
		panic("load_icode(): Not a valid ELF!\n");
	}	
	// load each program segment (ignores ph flags)
	// e_phoff means program header table offset
	// the start position
	ph = (struct Proghdr *)((uint8_t *)(env_elf)+env_elf->e_phoff);
f0102cab:	01 fb                	add    %edi,%ebx
	// the end position, e_phnum means the number of program
	// header table entries
	eph = ph+env_elf->e_phnum;
f0102cad:	0f b7 f6             	movzwl %si,%esi
f0102cb0:	c1 e6 05             	shl    $0x5,%esi
f0102cb3:	01 de                	add    %ebx,%esi
	// save old cr3, cr3 stores the page dir addr(pa)
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
f0102cb5:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102cba:	0f 22 d8             	mov    %eax,%cr3
	for (; ph < eph; ++ph)
f0102cbd:	39 f3                	cmp    %esi,%ebx
f0102cbf:	73 54                	jae    f0102d15 <env_create+0x111>
	{
		// only load segments with ph->p_type == ELF_PROG_LOAD.
		if (ph->p_type == ELF_PROG_LOAD)
f0102cc1:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102cc4:	75 48                	jne    f0102d0e <env_create+0x10a>
		{
			// Each segment's virtual address can be found in ph->p_va
			//  and its size in memory can be found in ph->p_memsz.
			segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102cc6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102cc9:	8b 53 08             	mov    0x8(%ebx),%edx
f0102ccc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ccf:	e8 d0 fb ff ff       	call   f01028a4 <segment_alloc>
			//  The ph->p_filesz bytes from the ELF binary, starting at
			//  'binary + ph->p_offset', should be copied to virtual address
			//  ph->p_va.
			memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102cd4:	8b 43 10             	mov    0x10(%ebx),%eax
f0102cd7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102cdb:	89 f8                	mov    %edi,%eax
f0102cdd:	03 43 04             	add    0x4(%ebx),%eax
f0102ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ce4:	8b 43 08             	mov    0x8(%ebx),%eax
f0102ce7:	89 04 24             	mov    %eax,(%esp)
f0102cea:	e8 0b 18 00 00       	call   f01044fa <memmove>
			//Any remaining memory bytes should be cleared to zero.
			// REMEMBER that ph->p_filesz <= ph->p_memsz.
			memset((void *)(ph->p_va+ph->p_filesz), 0, ph->p_memsz-ph->p_filesz);
f0102cef:	8b 43 10             	mov    0x10(%ebx),%eax
f0102cf2:	8b 53 14             	mov    0x14(%ebx),%edx
f0102cf5:	29 c2                	sub    %eax,%edx
f0102cf7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102cfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102d02:	00 
f0102d03:	03 43 08             	add    0x8(%ebx),%eax
f0102d06:	89 04 24             	mov    %eax,(%esp)
f0102d09:	e8 c8 17 00 00       	call   f01044d6 <memset>
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ++ph)
f0102d0e:	83 c3 20             	add    $0x20,%ebx
f0102d11:	39 de                	cmp    %ebx,%esi
f0102d13:	77 ac                	ja     f0102cc1 <env_create+0xbd>
f0102d15:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d18:	0f 22 d8             	mov    %eax,%cr3
		}
	}
	// restore the old cr3
	lcr3(old_cr3);
	// Set the program's entry point.
	e->env_tf.tf_eip = env_elf->e_entry;
f0102d1b:	8b 47 18             	mov    0x18(%edi),%eax
f0102d1e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102d21:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	segment_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f0102d24:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102d29:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102d2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d31:	e8 6e fb ff ff       	call   f01028a4 <segment_alloc>
	if (env_alloc_info < 0)
	{
		panic("env_alloc: %e", env_alloc_info);
	}
	load_icode(env, binary, size);
}
f0102d36:	83 c4 3c             	add    $0x3c,%esp
f0102d39:	5b                   	pop    %ebx
f0102d3a:	5e                   	pop    %esi
f0102d3b:	5f                   	pop    %edi
f0102d3c:	5d                   	pop    %ebp
f0102d3d:	c3                   	ret    

f0102d3e <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0102d3e:	55                   	push   %ebp
f0102d3f:	89 e5                	mov    %esp,%ebp
f0102d41:	57                   	push   %edi
f0102d42:	56                   	push   %esi
f0102d43:	53                   	push   %ebx
f0102d44:	83 ec 2c             	sub    $0x2c,%esp
f0102d47:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102d4a:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f0102d4f:	39 c7                	cmp    %eax,%edi
f0102d51:	75 09                	jne    f0102d5c <env_free+0x1e>
f0102d53:	8b 15 04 4a 17 f0    	mov    0xf0174a04,%edx
f0102d59:	0f 22 da             	mov    %edx,%cr3
		lcr3(boot_cr3);

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d5c:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0102d5f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102d64:	85 c0                	test   %eax,%eax
f0102d66:	74 03                	je     f0102d6b <env_free+0x2d>
f0102d68:	8b 50 4c             	mov    0x4c(%eax),%edx
f0102d6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102d6f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102d73:	c7 04 24 c0 58 10 f0 	movl   $0xf01058c0,(%esp)
f0102d7a:	e8 7f 02 00 00       	call   f0102ffe <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d7f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102d86:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d89:	c1 e0 02             	shl    $0x2,%eax
f0102d8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d8f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d92:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d95:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102d98:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102d9e:	0f 84 bb 00 00 00    	je     f0102e5f <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102da4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0102daa:	89 f0                	mov    %esi,%eax
f0102dac:	c1 e8 0c             	shr    $0xc,%eax
f0102daf:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102db2:	3b 05 00 4a 17 f0    	cmp    0xf0174a00,%eax
f0102db8:	72 20                	jb     f0102dda <env_free+0x9c>
f0102dba:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102dbe:	c7 44 24 08 64 50 10 	movl   $0xf0105064,0x8(%esp)
f0102dc5:	f0 
f0102dc6:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
f0102dcd:	00 
f0102dce:	c7 04 24 92 58 10 f0 	movl   $0xf0105892,(%esp)
f0102dd5:	e8 e1 d2 ff ff       	call   f01000bb <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102dda:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102ddd:	c1 e2 16             	shl    $0x16,%edx
f0102de0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102de3:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102de8:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102def:	01 
f0102df0:	74 17                	je     f0102e09 <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102df2:	89 d8                	mov    %ebx,%eax
f0102df4:	c1 e0 0c             	shl    $0xc,%eax
f0102df7:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102dfa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dfe:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e01:	89 04 24             	mov    %eax,(%esp)
f0102e04:	e8 19 e2 ff ff       	call   f0101022 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e09:	83 c3 01             	add    $0x1,%ebx
f0102e0c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102e12:	75 d4                	jne    f0102de8 <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102e14:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e17:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e1a:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102e21:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102e24:	3b 05 00 4a 17 f0    	cmp    0xf0174a00,%eax
f0102e2a:	72 1c                	jb     f0102e48 <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0102e2c:	c7 44 24 08 28 51 10 	movl   $0xf0105128,0x8(%esp)
f0102e33:	f0 
f0102e34:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102e3b:	00 
f0102e3c:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
f0102e43:	e8 73 d2 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0102e48:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e4b:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102e4e:	c1 e0 02             	shl    $0x2,%eax
f0102e51:	03 05 0c 4a 17 f0    	add    0xf0174a0c,%eax
		page_decref(pa2page(pa));
f0102e57:	89 04 24             	mov    %eax,(%esp)
f0102e5a:	e8 4f df ff ff       	call   f0100dae <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102e5f:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102e63:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102e6a:	0f 85 16 ff ff ff    	jne    f0102d86 <env_free+0x48>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0102e70:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0102e73:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0102e7a:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102e81:	c1 e8 0c             	shr    $0xc,%eax
f0102e84:	3b 05 00 4a 17 f0    	cmp    0xf0174a00,%eax
f0102e8a:	72 1c                	jb     f0102ea8 <env_free+0x16a>
		panic("pa2page called with invalid pa");
f0102e8c:	c7 44 24 08 28 51 10 	movl   $0xf0105128,0x8(%esp)
f0102e93:	f0 
f0102e94:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102e9b:	00 
f0102e9c:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
f0102ea3:	e8 13 d2 ff ff       	call   f01000bb <_panic>
	return &pages[PPN(pa)];
f0102ea8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102eab:	c1 e0 02             	shl    $0x2,%eax
f0102eae:	03 05 0c 4a 17 f0    	add    0xf0174a0c,%eax
	page_decref(pa2page(pa));
f0102eb4:	89 04 24             	mov    %eax,(%esp)
f0102eb7:	e8 f2 de ff ff       	call   f0100dae <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102ebc:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0102ec3:	a1 68 3d 17 f0       	mov    0xf0173d68,%eax
f0102ec8:	89 47 44             	mov    %eax,0x44(%edi)
f0102ecb:	85 c0                	test   %eax,%eax
f0102ecd:	74 06                	je     f0102ed5 <env_free+0x197>
f0102ecf:	8d 57 44             	lea    0x44(%edi),%edx
f0102ed2:	89 50 48             	mov    %edx,0x48(%eax)
f0102ed5:	89 3d 68 3d 17 f0    	mov    %edi,0xf0173d68
f0102edb:	c7 47 48 68 3d 17 f0 	movl   $0xf0173d68,0x48(%edi)
}
f0102ee2:	83 c4 2c             	add    $0x2c,%esp
f0102ee5:	5b                   	pop    %ebx
f0102ee6:	5e                   	pop    %esi
f0102ee7:	5f                   	pop    %edi
f0102ee8:	5d                   	pop    %ebp
f0102ee9:	c3                   	ret    

f0102eea <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102eea:	55                   	push   %ebp
f0102eeb:	89 e5                	mov    %esp,%ebp
f0102eed:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0102ef0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ef3:	89 04 24             	mov    %eax,(%esp)
f0102ef6:	e8 43 fe ff ff       	call   f0102d3e <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102efb:	c7 04 24 5c 58 10 f0 	movl   $0xf010585c,(%esp)
f0102f02:	e8 f7 00 00 00       	call   f0102ffe <cprintf>
	while (1)
		monitor(NULL);
f0102f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f0e:	e8 ed d8 ff ff       	call   f0100800 <monitor>
f0102f13:	eb f2                	jmp    f0102f07 <env_destroy+0x1d>

f0102f15 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102f15:	55                   	push   %ebp
f0102f16:	89 e5                	mov    %esp,%ebp
f0102f18:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102f1b:	8b 65 08             	mov    0x8(%ebp),%esp
f0102f1e:	61                   	popa   
f0102f1f:	07                   	pop    %es
f0102f20:	1f                   	pop    %ds
f0102f21:	83 c4 08             	add    $0x8,%esp
f0102f24:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102f25:	c7 44 24 08 d6 58 10 	movl   $0xf01058d6,0x8(%esp)
f0102f2c:	f0 
f0102f2d:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
f0102f34:	00 
f0102f35:	c7 04 24 92 58 10 f0 	movl   $0xf0105892,(%esp)
f0102f3c:	e8 7a d1 ff ff       	call   f01000bb <_panic>

f0102f41 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0102f41:	55                   	push   %ebp
f0102f42:	89 e5                	mov    %esp,%ebp
f0102f44:	83 ec 18             	sub    $0x18,%esp
f0102f47:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.
	// To start a given environment running in user mode.
	// PART 1
	// switch, and the original status may not be stored as the function 
	// NEVER RETURNS!
	curenv = e;
f0102f4a:	a3 60 3d 17 f0       	mov    %eax,0xf0173d60
	// update its 'env_runs' counter
	++(curenv->env_runs);
f0102f4f:	83 40 58 01          	addl   $0x1,0x58(%eax)
	// switch to its address space
	lcr3(PADDR(curenv->env_pgdir));
f0102f53:	8b 50 5c             	mov    0x5c(%eax),%edx
f0102f56:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102f5c:	77 20                	ja     f0102f7e <env_run+0x3d>
f0102f5e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f62:	c7 44 24 08 ac 50 10 	movl   $0xf01050ac,0x8(%esp)
f0102f69:	f0 
f0102f6a:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
f0102f71:	00 
f0102f72:	c7 04 24 92 58 10 f0 	movl   $0xf0105892,(%esp)
f0102f79:	e8 3d d1 ff ff       	call   f01000bb <_panic>
f0102f7e:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102f84:	0f 22 da             	mov    %edx,%cr3
	// PART 2
	// restore the environment's registers and
	// drop into user mode in the environment.
	env_pop_tf(&(curenv->env_tf));
f0102f87:	89 04 24             	mov    %eax,(%esp)
f0102f8a:	e8 86 ff ff ff       	call   f0102f15 <env_pop_tf>
	...

f0102f90 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102f90:	55                   	push   %ebp
f0102f91:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f93:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f98:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f9b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f9c:	b2 71                	mov    $0x71,%dl
f0102f9e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f9f:	0f b6 c0             	movzbl %al,%eax
}
f0102fa2:	5d                   	pop    %ebp
f0102fa3:	c3                   	ret    

f0102fa4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102fa4:	55                   	push   %ebp
f0102fa5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fa7:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fac:	8b 45 08             	mov    0x8(%ebp),%eax
f0102faf:	ee                   	out    %al,(%dx)
f0102fb0:	b2 71                	mov    $0x71,%dl
f0102fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fb5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102fb6:	5d                   	pop    %ebp
f0102fb7:	c3                   	ret    

f0102fb8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102fb8:	55                   	push   %ebp
f0102fb9:	89 e5                	mov    %esp,%ebp
f0102fbb:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102fbe:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fc1:	89 04 24             	mov    %eax,(%esp)
f0102fc4:	e8 0f d7 ff ff       	call   f01006d8 <cputchar>
	*cnt++;
}
f0102fc9:	c9                   	leave  
f0102fca:	c3                   	ret    

f0102fcb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102fcb:	55                   	push   %ebp
f0102fcc:	89 e5                	mov    %esp,%ebp
f0102fce:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102fd1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102fdf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fe2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102fe6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fed:	c7 04 24 b8 2f 10 f0 	movl   $0xf0102fb8,(%esp)
f0102ff4:	e8 2b 0e 00 00       	call   f0103e24 <vprintfmt>
	return cnt;
}
f0102ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ffc:	c9                   	leave  
f0102ffd:	c3                   	ret    

f0102ffe <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102ffe:	55                   	push   %ebp
f0102fff:	89 e5                	mov    %esp,%ebp
f0103001:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0103004:	8d 45 0c             	lea    0xc(%ebp),%eax
f0103007:	89 44 24 04          	mov    %eax,0x4(%esp)
f010300b:	8b 45 08             	mov    0x8(%ebp),%eax
f010300e:	89 04 24             	mov    %eax,(%esp)
f0103011:	e8 b5 ff ff ff       	call   f0102fcb <vcprintf>
	va_end(ap);

	return cnt;
}
f0103016:	c9                   	leave  
f0103017:	c3                   	ret    
	...

f0103020 <idt_init>:
}


void
idt_init(void)
{
f0103020:	55                   	push   %ebp
f0103021:	89 e5                	mov    %esp,%ebp
	// istrap: 1 for excp, and 0 for intr.
	// sel: segment selector, should be 0x8 or GD_KT, kernel text.
	// off: offset in code segment for interrupt/trap handler,
	// which should be the handler function entry points.
	// dpl: Descriptor Privilege Level, will be compared with cpl
	SETGATE(idt[T_DIVIDE], 0, GD_KT, idt_divide_error, 0);
f0103023:	b8 ec 36 10 f0       	mov    $0xf01036ec,%eax
f0103028:	66 a3 80 3d 17 f0    	mov    %ax,0xf0173d80
f010302e:	66 c7 05 82 3d 17 f0 	movw   $0x8,0xf0173d82
f0103035:	08 00 
f0103037:	c6 05 84 3d 17 f0 00 	movb   $0x0,0xf0173d84
f010303e:	c6 05 85 3d 17 f0 8e 	movb   $0x8e,0xf0173d85
f0103045:	c1 e8 10             	shr    $0x10,%eax
f0103048:	66 a3 86 3d 17 f0    	mov    %ax,0xf0173d86
	SETGATE(idt[T_DEBUG], 0, GD_KT, idt_debug_exception, 0);
f010304e:	b8 f2 36 10 f0       	mov    $0xf01036f2,%eax
f0103053:	66 a3 88 3d 17 f0    	mov    %ax,0xf0173d88
f0103059:	66 c7 05 8a 3d 17 f0 	movw   $0x8,0xf0173d8a
f0103060:	08 00 
f0103062:	c6 05 8c 3d 17 f0 00 	movb   $0x0,0xf0173d8c
f0103069:	c6 05 8d 3d 17 f0 8e 	movb   $0x8e,0xf0173d8d
f0103070:	c1 e8 10             	shr    $0x10,%eax
f0103073:	66 a3 8e 3d 17 f0    	mov    %ax,0xf0173d8e
	SETGATE(idt[T_NMI], 0, GD_KT, idt_nmi_interrupt, 0);
f0103079:	b8 f8 36 10 f0       	mov    $0xf01036f8,%eax
f010307e:	66 a3 90 3d 17 f0    	mov    %ax,0xf0173d90
f0103084:	66 c7 05 92 3d 17 f0 	movw   $0x8,0xf0173d92
f010308b:	08 00 
f010308d:	c6 05 94 3d 17 f0 00 	movb   $0x0,0xf0173d94
f0103094:	c6 05 95 3d 17 f0 8e 	movb   $0x8e,0xf0173d95
f010309b:	c1 e8 10             	shr    $0x10,%eax
f010309e:	66 a3 96 3d 17 f0    	mov    %ax,0xf0173d96
	SETGATE(idt[T_BRKPT], 0, GD_KT, idt_breakpoint, 3);
f01030a4:	b8 fe 36 10 f0       	mov    $0xf01036fe,%eax
f01030a9:	66 a3 98 3d 17 f0    	mov    %ax,0xf0173d98
f01030af:	66 c7 05 9a 3d 17 f0 	movw   $0x8,0xf0173d9a
f01030b6:	08 00 
f01030b8:	c6 05 9c 3d 17 f0 00 	movb   $0x0,0xf0173d9c
f01030bf:	c6 05 9d 3d 17 f0 ee 	movb   $0xee,0xf0173d9d
f01030c6:	c1 e8 10             	shr    $0x10,%eax
f01030c9:	66 a3 9e 3d 17 f0    	mov    %ax,0xf0173d9e
	SETGATE(idt[T_OFLOW], 1, GD_KT, idt_overflow, 3);
f01030cf:	b8 04 37 10 f0       	mov    $0xf0103704,%eax
f01030d4:	66 a3 a0 3d 17 f0    	mov    %ax,0xf0173da0
f01030da:	66 c7 05 a2 3d 17 f0 	movw   $0x8,0xf0173da2
f01030e1:	08 00 
f01030e3:	c6 05 a4 3d 17 f0 00 	movb   $0x0,0xf0173da4
f01030ea:	c6 05 a5 3d 17 f0 ef 	movb   $0xef,0xf0173da5
f01030f1:	c1 e8 10             	shr    $0x10,%eax
f01030f4:	66 a3 a6 3d 17 f0    	mov    %ax,0xf0173da6
	SETGATE(idt[T_BOUND], 1, GD_KT, idt_bound_check, 3);
f01030fa:	b8 0a 37 10 f0       	mov    $0xf010370a,%eax
f01030ff:	66 a3 a8 3d 17 f0    	mov    %ax,0xf0173da8
f0103105:	66 c7 05 aa 3d 17 f0 	movw   $0x8,0xf0173daa
f010310c:	08 00 
f010310e:	c6 05 ac 3d 17 f0 00 	movb   $0x0,0xf0173dac
f0103115:	c6 05 ad 3d 17 f0 ef 	movb   $0xef,0xf0173dad
f010311c:	c1 e8 10             	shr    $0x10,%eax
f010311f:	66 a3 ae 3d 17 f0    	mov    %ax,0xf0173dae
	// SETGATE(idt[T_OFLOW], 0, GD_KT, idt_overflow, 0);
	// SETGATE(idt[T_BOUND], 0, GD_KT, idt_bound_check, 0);
	SETGATE(idt[T_ILLOP], 0, GD_KT, idt_illegal_opcode, 0);
f0103125:	b8 10 37 10 f0       	mov    $0xf0103710,%eax
f010312a:	66 a3 b0 3d 17 f0    	mov    %ax,0xf0173db0
f0103130:	66 c7 05 b2 3d 17 f0 	movw   $0x8,0xf0173db2
f0103137:	08 00 
f0103139:	c6 05 b4 3d 17 f0 00 	movb   $0x0,0xf0173db4
f0103140:	c6 05 b5 3d 17 f0 8e 	movb   $0x8e,0xf0173db5
f0103147:	c1 e8 10             	shr    $0x10,%eax
f010314a:	66 a3 b6 3d 17 f0    	mov    %ax,0xf0173db6
	SETGATE(idt[T_DEVICE], 0, GD_KT, idt_device_not_available, 0);
f0103150:	b8 16 37 10 f0       	mov    $0xf0103716,%eax
f0103155:	66 a3 b8 3d 17 f0    	mov    %ax,0xf0173db8
f010315b:	66 c7 05 ba 3d 17 f0 	movw   $0x8,0xf0173dba
f0103162:	08 00 
f0103164:	c6 05 bc 3d 17 f0 00 	movb   $0x0,0xf0173dbc
f010316b:	c6 05 bd 3d 17 f0 8e 	movb   $0x8e,0xf0173dbd
f0103172:	c1 e8 10             	shr    $0x10,%eax
f0103175:	66 a3 be 3d 17 f0    	mov    %ax,0xf0173dbe
	// I just cannot set the gate's type to 0101B, which states a task gate
	// Don't know why. May be modified later?
	SETGATE(idt[T_DBLFLT], 0, GD_KT, idt_double_fault, 0);
f010317b:	b8 1c 37 10 f0       	mov    $0xf010371c,%eax
f0103180:	66 a3 c0 3d 17 f0    	mov    %ax,0xf0173dc0
f0103186:	66 c7 05 c2 3d 17 f0 	movw   $0x8,0xf0173dc2
f010318d:	08 00 
f010318f:	c6 05 c4 3d 17 f0 00 	movb   $0x0,0xf0173dc4
f0103196:	c6 05 c5 3d 17 f0 8e 	movb   $0x8e,0xf0173dc5
f010319d:	c1 e8 10             	shr    $0x10,%eax
f01031a0:	66 a3 c6 3d 17 f0    	mov    %ax,0xf0173dc6
	SETGATE(idt[T_TSS], 0, GD_KT, idt_invalid_tss, 0);
f01031a6:	b8 20 37 10 f0       	mov    $0xf0103720,%eax
f01031ab:	66 a3 d0 3d 17 f0    	mov    %ax,0xf0173dd0
f01031b1:	66 c7 05 d2 3d 17 f0 	movw   $0x8,0xf0173dd2
f01031b8:	08 00 
f01031ba:	c6 05 d4 3d 17 f0 00 	movb   $0x0,0xf0173dd4
f01031c1:	c6 05 d5 3d 17 f0 8e 	movb   $0x8e,0xf0173dd5
f01031c8:	c1 e8 10             	shr    $0x10,%eax
f01031cb:	66 a3 d6 3d 17 f0    	mov    %ax,0xf0173dd6
	SETGATE(idt[T_SEGNP], 0, GD_KT, idt_segment_not_present, 0);
f01031d1:	b8 24 37 10 f0       	mov    $0xf0103724,%eax
f01031d6:	66 a3 d8 3d 17 f0    	mov    %ax,0xf0173dd8
f01031dc:	66 c7 05 da 3d 17 f0 	movw   $0x8,0xf0173dda
f01031e3:	08 00 
f01031e5:	c6 05 dc 3d 17 f0 00 	movb   $0x0,0xf0173ddc
f01031ec:	c6 05 dd 3d 17 f0 8e 	movb   $0x8e,0xf0173ddd
f01031f3:	c1 e8 10             	shr    $0x10,%eax
f01031f6:	66 a3 de 3d 17 f0    	mov    %ax,0xf0173dde
	SETGATE(idt[T_STACK], 0, GD_KT, idt_stack_exception, 0);
f01031fc:	b8 28 37 10 f0       	mov    $0xf0103728,%eax
f0103201:	66 a3 e0 3d 17 f0    	mov    %ax,0xf0173de0
f0103207:	66 c7 05 e2 3d 17 f0 	movw   $0x8,0xf0173de2
f010320e:	08 00 
f0103210:	c6 05 e4 3d 17 f0 00 	movb   $0x0,0xf0173de4
f0103217:	c6 05 e5 3d 17 f0 8e 	movb   $0x8e,0xf0173de5
f010321e:	c1 e8 10             	shr    $0x10,%eax
f0103221:	66 a3 e6 3d 17 f0    	mov    %ax,0xf0173de6
	SETGATE(idt[T_GPFLT], 1, GD_KT, idt_general_protection_fault, 0);
f0103227:	b8 2c 37 10 f0       	mov    $0xf010372c,%eax
f010322c:	66 a3 e8 3d 17 f0    	mov    %ax,0xf0173de8
f0103232:	66 c7 05 ea 3d 17 f0 	movw   $0x8,0xf0173dea
f0103239:	08 00 
f010323b:	c6 05 ec 3d 17 f0 00 	movb   $0x0,0xf0173dec
f0103242:	c6 05 ed 3d 17 f0 8f 	movb   $0x8f,0xf0173ded
f0103249:	c1 e8 10             	shr    $0x10,%eax
f010324c:	66 a3 ee 3d 17 f0    	mov    %ax,0xf0173dee
	// SETGATE(idt[T_GPFLT], 0, GD_KT, idt_general_protection_fault, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, idt_page_fault, 0);
f0103252:	b8 30 37 10 f0       	mov    $0xf0103730,%eax
f0103257:	66 a3 f0 3d 17 f0    	mov    %ax,0xf0173df0
f010325d:	66 c7 05 f2 3d 17 f0 	movw   $0x8,0xf0173df2
f0103264:	08 00 
f0103266:	c6 05 f4 3d 17 f0 00 	movb   $0x0,0xf0173df4
f010326d:	c6 05 f5 3d 17 f0 8e 	movb   $0x8e,0xf0173df5
f0103274:	c1 e8 10             	shr    $0x10,%eax
f0103277:	66 a3 f6 3d 17 f0    	mov    %ax,0xf0173df6
	SETGATE(idt[T_FPERR], 0, GD_KT, idt_floating_point_error, 0);
f010327d:	b8 34 37 10 f0       	mov    $0xf0103734,%eax
f0103282:	66 a3 00 3e 17 f0    	mov    %ax,0xf0173e00
f0103288:	66 c7 05 02 3e 17 f0 	movw   $0x8,0xf0173e02
f010328f:	08 00 
f0103291:	c6 05 04 3e 17 f0 00 	movb   $0x0,0xf0173e04
f0103298:	c6 05 05 3e 17 f0 8e 	movb   $0x8e,0xf0173e05
f010329f:	c1 e8 10             	shr    $0x10,%eax
f01032a2:	66 a3 06 3e 17 f0    	mov    %ax,0xf0173e06
	SETGATE(idt[T_ALIGN], 0, GD_KT, idt_aligment_check, 0);
f01032a8:	b8 3a 37 10 f0       	mov    $0xf010373a,%eax
f01032ad:	66 a3 08 3e 17 f0    	mov    %ax,0xf0173e08
f01032b3:	66 c7 05 0a 3e 17 f0 	movw   $0x8,0xf0173e0a
f01032ba:	08 00 
f01032bc:	c6 05 0c 3e 17 f0 00 	movb   $0x0,0xf0173e0c
f01032c3:	c6 05 0d 3e 17 f0 8e 	movb   $0x8e,0xf0173e0d
f01032ca:	c1 e8 10             	shr    $0x10,%eax
f01032cd:	66 a3 0e 3e 17 f0    	mov    %ax,0xf0173e0e
	SETGATE(idt[T_MCHK], 0, GD_KT, idt_machine_check, 0);
f01032d3:	b8 3e 37 10 f0       	mov    $0xf010373e,%eax
f01032d8:	66 a3 10 3e 17 f0    	mov    %ax,0xf0173e10
f01032de:	66 c7 05 12 3e 17 f0 	movw   $0x8,0xf0173e12
f01032e5:	08 00 
f01032e7:	c6 05 14 3e 17 f0 00 	movb   $0x0,0xf0173e14
f01032ee:	c6 05 15 3e 17 f0 8e 	movb   $0x8e,0xf0173e15
f01032f5:	c1 e8 10             	shr    $0x10,%eax
f01032f8:	66 a3 16 3e 17 f0    	mov    %ax,0xf0173e16
	SETGATE(idt[T_SIMDERR], 0, GD_KT, idt_simd_floating_point_error, 0);
f01032fe:	b8 44 37 10 f0       	mov    $0xf0103744,%eax
f0103303:	66 a3 18 3e 17 f0    	mov    %ax,0xf0173e18
f0103309:	66 c7 05 1a 3e 17 f0 	movw   $0x8,0xf0173e1a
f0103310:	08 00 
f0103312:	c6 05 1c 3e 17 f0 00 	movb   $0x0,0xf0173e1c
f0103319:	c6 05 1d 3e 17 f0 8e 	movb   $0x8e,0xf0173e1d
f0103320:	c1 e8 10             	shr    $0x10,%eax
f0103323:	66 a3 1e 3e 17 f0    	mov    %ax,0xf0173e1e
	SETGATE(idt[T_SYSCALL], 1, GD_KT, idt_system_call, 3);
f0103329:	b8 4a 37 10 f0       	mov    $0xf010374a,%eax
f010332e:	66 a3 00 3f 17 f0    	mov    %ax,0xf0173f00
f0103334:	66 c7 05 02 3f 17 f0 	movw   $0x8,0xf0173f02
f010333b:	08 00 
f010333d:	c6 05 04 3f 17 f0 00 	movb   $0x0,0xf0173f04
f0103344:	c6 05 05 3f 17 f0 ef 	movb   $0xef,0xf0173f05
f010334b:	c1 e8 10             	shr    $0x10,%eax
f010334e:	66 a3 06 3f 17 f0    	mov    %ax,0xf0173f06
	// SETGATE(idt[T_SYSCALL], 0, GD_KT, idt_system_call, 3);

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103354:	c7 05 84 45 17 f0 00 	movl   $0xefc00000,0xf0174584
f010335b:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f010335e:	66 c7 05 88 45 17 f0 	movw   $0x10,0xf0174588
f0103365:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103367:	66 c7 05 68 93 11 f0 	movw   $0x68,0xf0119368
f010336e:	68 00 
f0103370:	b8 80 45 17 f0       	mov    $0xf0174580,%eax
f0103375:	66 a3 6a 93 11 f0    	mov    %ax,0xf011936a
f010337b:	89 c2                	mov    %eax,%edx
f010337d:	c1 ea 10             	shr    $0x10,%edx
f0103380:	88 15 6c 93 11 f0    	mov    %dl,0xf011936c
f0103386:	c6 05 6e 93 11 f0 40 	movb   $0x40,0xf011936e
f010338d:	c1 e8 18             	shr    $0x18,%eax
f0103390:	a2 6f 93 11 f0       	mov    %al,0xf011936f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0103395:	c6 05 6d 93 11 f0 89 	movb   $0x89,0xf011936d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010339c:	b8 28 00 00 00       	mov    $0x28,%eax
f01033a1:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f01033a4:	0f 01 1d 70 93 11 f0 	lidtl  0xf0119370
}
f01033ab:	5d                   	pop    %ebp
f01033ac:	c3                   	ret    

f01033ad <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f01033ad:	55                   	push   %ebp
f01033ae:	89 e5                	mov    %esp,%ebp
f01033b0:	53                   	push   %ebx
f01033b1:	83 ec 14             	sub    $0x14,%esp
f01033b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01033b7:	8b 03                	mov    (%ebx),%eax
f01033b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033bd:	c7 04 24 e2 58 10 f0 	movl   $0xf01058e2,(%esp)
f01033c4:	e8 35 fc ff ff       	call   f0102ffe <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01033c9:	8b 43 04             	mov    0x4(%ebx),%eax
f01033cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033d0:	c7 04 24 f1 58 10 f0 	movl   $0xf01058f1,(%esp)
f01033d7:	e8 22 fc ff ff       	call   f0102ffe <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01033dc:	8b 43 08             	mov    0x8(%ebx),%eax
f01033df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033e3:	c7 04 24 00 59 10 f0 	movl   $0xf0105900,(%esp)
f01033ea:	e8 0f fc ff ff       	call   f0102ffe <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01033ef:	8b 43 0c             	mov    0xc(%ebx),%eax
f01033f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033f6:	c7 04 24 0f 59 10 f0 	movl   $0xf010590f,(%esp)
f01033fd:	e8 fc fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103402:	8b 43 10             	mov    0x10(%ebx),%eax
f0103405:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103409:	c7 04 24 1e 59 10 f0 	movl   $0xf010591e,(%esp)
f0103410:	e8 e9 fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103415:	8b 43 14             	mov    0x14(%ebx),%eax
f0103418:	89 44 24 04          	mov    %eax,0x4(%esp)
f010341c:	c7 04 24 2d 59 10 f0 	movl   $0xf010592d,(%esp)
f0103423:	e8 d6 fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103428:	8b 43 18             	mov    0x18(%ebx),%eax
f010342b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010342f:	c7 04 24 3c 59 10 f0 	movl   $0xf010593c,(%esp)
f0103436:	e8 c3 fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010343b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010343e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103442:	c7 04 24 4b 59 10 f0 	movl   $0xf010594b,(%esp)
f0103449:	e8 b0 fb ff ff       	call   f0102ffe <cprintf>
}
f010344e:	83 c4 14             	add    $0x14,%esp
f0103451:	5b                   	pop    %ebx
f0103452:	5d                   	pop    %ebp
f0103453:	c3                   	ret    

f0103454 <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f0103454:	55                   	push   %ebp
f0103455:	89 e5                	mov    %esp,%ebp
f0103457:	53                   	push   %ebx
f0103458:	83 ec 14             	sub    $0x14,%esp
f010345b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010345e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103462:	c7 04 24 39 5a 10 f0 	movl   $0xf0105a39,(%esp)
f0103469:	e8 90 fb ff ff       	call   f0102ffe <cprintf>
	print_regs(&tf->tf_regs);
f010346e:	89 1c 24             	mov    %ebx,(%esp)
f0103471:	e8 37 ff ff ff       	call   f01033ad <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103476:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010347a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010347e:	c7 04 24 75 59 10 f0 	movl   $0xf0105975,(%esp)
f0103485:	e8 74 fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010348a:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010348e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103492:	c7 04 24 88 59 10 f0 	movl   $0xf0105988,(%esp)
f0103499:	e8 60 fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010349e:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01034a1:	83 f8 13             	cmp    $0x13,%eax
f01034a4:	77 09                	ja     f01034af <print_trapframe+0x5b>
		return excnames[trapno];
f01034a6:	8b 14 85 20 5c 10 f0 	mov    -0xfefa3e0(,%eax,4),%edx
f01034ad:	eb 10                	jmp    f01034bf <print_trapframe+0x6b>
	if (trapno == T_SYSCALL)
f01034af:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
f01034b2:	ba 5a 59 10 f0       	mov    $0xf010595a,%edx
f01034b7:	b9 66 59 10 f0       	mov    $0xf0105966,%ecx
f01034bc:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01034bf:	89 54 24 08          	mov    %edx,0x8(%esp)
f01034c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034c7:	c7 04 24 9b 59 10 f0 	movl   $0xf010599b,(%esp)
f01034ce:	e8 2b fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f01034d3:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01034d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034da:	c7 04 24 ad 59 10 f0 	movl   $0xf01059ad,(%esp)
f01034e1:	e8 18 fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01034e6:	8b 43 30             	mov    0x30(%ebx),%eax
f01034e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034ed:	c7 04 24 bc 59 10 f0 	movl   $0xf01059bc,(%esp)
f01034f4:	e8 05 fb ff ff       	call   f0102ffe <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01034f9:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01034fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103501:	c7 04 24 cb 59 10 f0 	movl   $0xf01059cb,(%esp)
f0103508:	e8 f1 fa ff ff       	call   f0102ffe <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010350d:	8b 43 38             	mov    0x38(%ebx),%eax
f0103510:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103514:	c7 04 24 de 59 10 f0 	movl   $0xf01059de,(%esp)
f010351b:	e8 de fa ff ff       	call   f0102ffe <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103520:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103523:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103527:	c7 04 24 ed 59 10 f0 	movl   $0xf01059ed,(%esp)
f010352e:	e8 cb fa ff ff       	call   f0102ffe <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103533:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103537:	89 44 24 04          	mov    %eax,0x4(%esp)
f010353b:	c7 04 24 fc 59 10 f0 	movl   $0xf01059fc,(%esp)
f0103542:	e8 b7 fa ff ff       	call   f0102ffe <cprintf>
}
f0103547:	83 c4 14             	add    $0x14,%esp
f010354a:	5b                   	pop    %ebx
f010354b:	5d                   	pop    %ebp
f010354c:	c3                   	ret    

f010354d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010354d:	55                   	push   %ebp
f010354e:	89 e5                	mov    %esp,%ebp
f0103550:	53                   	push   %ebx
f0103551:	83 ec 14             	sub    $0x14,%esp
f0103554:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103557:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f010355a:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010355e:	75 1c                	jne    f010357c <page_fault_handler+0x2f>
	{
        		panic("Page fault in kernel");  
f0103560:	c7 44 24 08 0f 5a 10 	movl   $0xf0105a0f,0x8(%esp)
f0103567:	f0 
f0103568:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f010356f:	00 
f0103570:	c7 04 24 24 5a 10 f0 	movl   $0xf0105a24,(%esp)
f0103577:	e8 3f cb ff ff       	call   f01000bb <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010357c:	8b 53 30             	mov    0x30(%ebx),%edx
f010357f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103583:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0103587:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010358c:	8b 40 4c             	mov    0x4c(%eax),%eax
f010358f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103593:	c7 04 24 b0 5b 10 f0 	movl   $0xf0105bb0,(%esp)
f010359a:	e8 5f fa ff ff       	call   f0102ffe <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010359f:	89 1c 24             	mov    %ebx,(%esp)
f01035a2:	e8 ad fe ff ff       	call   f0103454 <print_trapframe>
	env_destroy(curenv);
f01035a7:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f01035ac:	89 04 24             	mov    %eax,(%esp)
f01035af:	e8 36 f9 ff ff       	call   f0102eea <env_destroy>
}
f01035b4:	83 c4 14             	add    $0x14,%esp
f01035b7:	5b                   	pop    %ebx
f01035b8:	5d                   	pop    %ebp
f01035b9:	c3                   	ret    

f01035ba <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01035ba:	55                   	push   %ebp
f01035bb:	89 e5                	mov    %esp,%ebp
f01035bd:	57                   	push   %edi
f01035be:	56                   	push   %esi
f01035bf:	83 ec 20             	sub    $0x20,%esp
f01035c2:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("Incoming TRAP frame at %p\n", tf);
f01035c5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035c9:	c7 04 24 30 5a 10 f0 	movl   $0xf0105a30,(%esp)
f01035d0:	e8 29 fa ff ff       	call   f0102ffe <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01035d5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01035d9:	83 e0 03             	and    $0x3,%eax
f01035dc:	83 f8 03             	cmp    $0x3,%eax
f01035df:	75 3c                	jne    f010361d <trap+0x63>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f01035e1:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f01035e6:	85 c0                	test   %eax,%eax
f01035e8:	75 24                	jne    f010360e <trap+0x54>
f01035ea:	c7 44 24 0c 4b 5a 10 	movl   $0xf0105a4b,0xc(%esp)
f01035f1:	f0 
f01035f2:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01035f9:	f0 
f01035fa:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f0103601:	00 
f0103602:	c7 04 24 24 5a 10 f0 	movl   $0xf0105a24,(%esp)
f0103609:	e8 ad ca ff ff       	call   f01000bb <_panic>
		curenv->env_tf = *tf;
f010360e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103613:	89 c7                	mov    %eax,%edi
f0103615:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103617:	8b 35 60 3d 17 f0    	mov    0xf0173d60,%esi
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno)
f010361d:	8b 46 28             	mov    0x28(%esi),%eax
f0103620:	83 f8 0e             	cmp    $0xe,%eax
f0103623:	74 0d                	je     f0103632 <trap+0x78>
f0103625:	83 f8 30             	cmp    $0x30,%eax
f0103628:	74 1c                	je     f0103646 <trap+0x8c>
f010362a:	83 f8 03             	cmp    $0x3,%eax
f010362d:	75 49                	jne    f0103678 <trap+0xbe>
f010362f:	90                   	nop
f0103630:	eb 0a                	jmp    f010363c <trap+0x82>
	{
		case T_PGFLT:
			// dispatch page fault exceptions to page_fault_handler()
			page_fault_handler(tf);
f0103632:	89 34 24             	mov    %esi,(%esp)
f0103635:	e8 13 ff ff ff       	call   f010354d <page_fault_handler>
f010363a:	eb 74                	jmp    f01036b0 <trap+0xf6>
			return;
		case T_BRKPT:
			// invoke kernel monitor
			monitor(tf);
f010363c:	89 34 24             	mov    %esi,(%esp)
f010363f:	e8 bc d1 ff ff       	call   f0100800 <monitor>
f0103644:	eb 6a                	jmp    f01036b0 <trap+0xf6>
			// Generic system call: pass system call number in AX,
			// up to five parameters in DX, CX, BX, DI, SI.
			// Interrupt kernel with T_SYSCALL.
			// According to lib/syscall.c
			// Correct order or endless page fault
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f0103646:	8b 46 04             	mov    0x4(%esi),%eax
f0103649:	89 44 24 14          	mov    %eax,0x14(%esp)
f010364d:	8b 06                	mov    (%esi),%eax
f010364f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103653:	8b 46 10             	mov    0x10(%esi),%eax
f0103656:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010365a:	8b 46 18             	mov    0x18(%esi),%eax
f010365d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103661:	8b 46 14             	mov    0x14(%esi),%eax
f0103664:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103668:	8b 46 1c             	mov    0x1c(%esi),%eax
f010366b:	89 04 24             	mov    %eax,(%esp)
f010366e:	e8 fd 00 00 00       	call   f0103770 <syscall>
f0103673:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103676:	eb 38                	jmp    f01036b0 <trap+0xf6>
				tf->tf_regs.reg_esi);
			return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103678:	89 34 24             	mov    %esi,(%esp)
f010367b:	e8 d4 fd ff ff       	call   f0103454 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103680:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103685:	75 1c                	jne    f01036a3 <trap+0xe9>
		panic("unhandled trap in kernel");
f0103687:	c7 44 24 08 52 5a 10 	movl   $0xf0105a52,0x8(%esp)
f010368e:	f0 
f010368f:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0103696:	00 
f0103697:	c7 04 24 24 5a 10 f0 	movl   $0xf0105a24,(%esp)
f010369e:	e8 18 ca ff ff       	call   f01000bb <_panic>
	else {
		env_destroy(curenv);
f01036a3:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f01036a8:	89 04 24             	mov    %eax,(%esp)
f01036ab:	e8 3a f8 ff ff       	call   f0102eea <env_destroy>
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f01036b0:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f01036b5:	85 c0                	test   %eax,%eax
f01036b7:	74 06                	je     f01036bf <trap+0x105>
f01036b9:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01036bd:	74 24                	je     f01036e3 <trap+0x129>
f01036bf:	c7 44 24 0c d4 5b 10 	movl   $0xf0105bd4,0xc(%esp)
f01036c6:	f0 
f01036c7:	c7 44 24 08 5d 56 10 	movl   $0xf010565d,0x8(%esp)
f01036ce:	f0 
f01036cf:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
f01036d6:	00 
f01036d7:	c7 04 24 24 5a 10 f0 	movl   $0xf0105a24,(%esp)
f01036de:	e8 d8 c9 ff ff       	call   f01000bb <_panic>
        env_run(curenv);
f01036e3:	89 04 24             	mov    %eax,(%esp)
f01036e6:	e8 56 f8 ff ff       	call   f0102f41 <env_run>
	...

f01036ec <idt_divide_error>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(idt_divide_error, T_DIVIDE)
f01036ec:	6a 00                	push   $0x0
f01036ee:	6a 00                	push   $0x0
f01036f0:	eb 5e                	jmp    f0103750 <_alltraps>

f01036f2 <idt_debug_exception>:
	TRAPHANDLER_NOEC(idt_debug_exception, T_DEBUG)
f01036f2:	6a 00                	push   $0x0
f01036f4:	6a 01                	push   $0x1
f01036f6:	eb 58                	jmp    f0103750 <_alltraps>

f01036f8 <idt_nmi_interrupt>:
	TRAPHANDLER_NOEC(idt_nmi_interrupt, T_NMI)
f01036f8:	6a 00                	push   $0x0
f01036fa:	6a 02                	push   $0x2
f01036fc:	eb 52                	jmp    f0103750 <_alltraps>

f01036fe <idt_breakpoint>:
	TRAPHANDLER_NOEC(idt_breakpoint, T_BRKPT)
f01036fe:	6a 00                	push   $0x0
f0103700:	6a 03                	push   $0x3
f0103702:	eb 4c                	jmp    f0103750 <_alltraps>

f0103704 <idt_overflow>:
	TRAPHANDLER_NOEC(idt_overflow, T_OFLOW)
f0103704:	6a 00                	push   $0x0
f0103706:	6a 04                	push   $0x4
f0103708:	eb 46                	jmp    f0103750 <_alltraps>

f010370a <idt_bound_check>:
	TRAPHANDLER_NOEC(idt_bound_check, T_BOUND)
f010370a:	6a 00                	push   $0x0
f010370c:	6a 05                	push   $0x5
f010370e:	eb 40                	jmp    f0103750 <_alltraps>

f0103710 <idt_illegal_opcode>:
	TRAPHANDLER_NOEC(idt_illegal_opcode, T_ILLOP)
f0103710:	6a 00                	push   $0x0
f0103712:	6a 06                	push   $0x6
f0103714:	eb 3a                	jmp    f0103750 <_alltraps>

f0103716 <idt_device_not_available>:
	TRAPHANDLER_NOEC(idt_device_not_available, T_DEVICE)
f0103716:	6a 00                	push   $0x0
f0103718:	6a 07                	push   $0x7
f010371a:	eb 34                	jmp    f0103750 <_alltraps>

f010371c <idt_double_fault>:
	TRAPHANDLER(idt_double_fault, T_DBLFLT)
f010371c:	6a 08                	push   $0x8
f010371e:	eb 30                	jmp    f0103750 <_alltraps>

f0103720 <idt_invalid_tss>:

	TRAPHANDLER(idt_invalid_tss, T_TSS)
f0103720:	6a 0a                	push   $0xa
f0103722:	eb 2c                	jmp    f0103750 <_alltraps>

f0103724 <idt_segment_not_present>:
	TRAPHANDLER(idt_segment_not_present, T_SEGNP)
f0103724:	6a 0b                	push   $0xb
f0103726:	eb 28                	jmp    f0103750 <_alltraps>

f0103728 <idt_stack_exception>:
	TRAPHANDLER(idt_stack_exception, T_STACK)
f0103728:	6a 0c                	push   $0xc
f010372a:	eb 24                	jmp    f0103750 <_alltraps>

f010372c <idt_general_protection_fault>:
	TRAPHANDLER(idt_general_protection_fault, T_GPFLT)
f010372c:	6a 0d                	push   $0xd
f010372e:	eb 20                	jmp    f0103750 <_alltraps>

f0103730 <idt_page_fault>:
	TRAPHANDLER(idt_page_fault, T_PGFLT)
f0103730:	6a 0e                	push   $0xe
f0103732:	eb 1c                	jmp    f0103750 <_alltraps>

f0103734 <idt_floating_point_error>:

	TRAPHANDLER_NOEC(idt_floating_point_error, T_FPERR)
f0103734:	6a 00                	push   $0x0
f0103736:	6a 10                	push   $0x10
f0103738:	eb 16                	jmp    f0103750 <_alltraps>

f010373a <idt_aligment_check>:
	TRAPHANDLER(idt_aligment_check, T_ALIGN)
f010373a:	6a 11                	push   $0x11
f010373c:	eb 12                	jmp    f0103750 <_alltraps>

f010373e <idt_machine_check>:
	TRAPHANDLER_NOEC(idt_machine_check, T_MCHK)
f010373e:	6a 00                	push   $0x0
f0103740:	6a 12                	push   $0x12
f0103742:	eb 0c                	jmp    f0103750 <_alltraps>

f0103744 <idt_simd_floating_point_error>:
	TRAPHANDLER_NOEC(idt_simd_floating_point_error, T_SIMDERR)
f0103744:	6a 00                	push   $0x0
f0103746:	6a 13                	push   $0x13
f0103748:	eb 06                	jmp    f0103750 <_alltraps>

f010374a <idt_system_call>:
	TRAPHANDLER_NOEC(idt_system_call, T_SYSCALL)
f010374a:	6a 00                	push   $0x0
f010374c:	6a 30                	push   $0x30
f010374e:	eb 00                	jmp    f0103750 <_alltraps>

f0103750 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	/* push values to make the stack look like a struct Trapframe */
	pushl	%ds
f0103750:	1e                   	push   %ds
	pushl	%es
f0103751:	06                   	push   %es
	/* push all regs in */
	pushal
f0103752:	60                   	pusha  

	/* load GD_KD into %ds and %es */
	/* notice that ds and es are 16 bits width */
	movl	$GD_KD,	%eax
f0103753:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,	%ds
f0103758:	8e d8                	mov    %eax,%ds
	movw	%ax,	%es
f010375a:	8e c0                	mov    %eax,%es

	/* pushl %esp to pass a pointer to the Trapframe
	as an argument to trap() and call trap() */
	pushl	%esp
f010375c:	54                   	push   %esp
	call trap
f010375d:	e8 58 fe ff ff       	call   f01035ba <trap>

	/* pop the values pushed in steps 1-3 and iret*/
	popl	%esp
f0103762:	5c                   	pop    %esp
	popal
f0103763:	61                   	popa   
	popl	%es
f0103764:	07                   	pop    %es
	popl	%ds
f0103765:	1f                   	pop    %ds
f0103766:	cf                   	iret   
	...

f0103770 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103770:	55                   	push   %ebp
f0103771:	89 e5                	mov    %esp,%ebp
f0103773:	56                   	push   %esi
f0103774:	53                   	push   %ebx
f0103775:	83 ec 20             	sub    $0x20,%esp
f0103778:	8b 45 08             	mov    0x8(%ebp),%eax
f010377b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010377e:	8b 75 10             	mov    0x10(%ebp),%esi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno)
f0103781:	83 f8 01             	cmp    $0x1,%eax
f0103784:	74 50                	je     f01037d6 <syscall+0x66>
f0103786:	83 f8 01             	cmp    $0x1,%eax
f0103789:	72 10                	jb     f010379b <syscall+0x2b>
f010378b:	83 f8 02             	cmp    $0x2,%eax
f010378e:	74 52                	je     f01037e2 <syscall+0x72>
f0103790:	83 f8 03             	cmp    $0x3,%eax
f0103793:	0f 85 bc 00 00 00    	jne    f0103855 <syscall+0xe5>
f0103799:	eb 51                	jmp    f01037ec <syscall+0x7c>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv, (const void *)s, len, PTE_U | PTE_W | PTE_P);
f010379b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01037a2:	00 
f01037a3:	89 74 24 08          	mov    %esi,0x8(%esp)
f01037a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01037ab:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f01037b0:	89 04 24             	mov    %eax,(%esp)
f01037b3:	e8 8d f0 ff ff       	call   f0102845 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01037b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01037bc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037c0:	c7 04 24 70 5c 10 f0 	movl   $0xf0105c70,(%esp)
f01037c7:	e8 32 f8 ff ff       	call   f0102ffe <cprintf>
	// LAB 3: Your code here.
	switch (syscallno)
	{
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
f01037cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01037d1:	e9 84 00 00 00       	jmp    f010385a <syscall+0xea>
{
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f01037d6:	e8 03 cc ff ff       	call   f01003de <cons_getc>
f01037db:	85 c0                	test   %eax,%eax
f01037dd:	74 f7                	je     f01037d6 <syscall+0x66>
f01037df:	90                   	nop
f01037e0:	eb 78                	jmp    f010385a <syscall+0xea>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01037e2:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f01037e7:	8b 40 4c             	mov    0x4c(%eax),%eax
			sys_cputs((const char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return (int32_t)sys_cgetc();
		case SYS_getenvid:
			return (int32_t)sys_getenvid();
f01037ea:	eb 6e                	jmp    f010385a <syscall+0xea>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01037ec:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01037f3:	00 
f01037f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037fb:	89 1c 24             	mov    %ebx,(%esp)
f01037fe:	e8 55 f1 ff ff       	call   f0102958 <envid2env>
f0103803:	85 c0                	test   %eax,%eax
f0103805:	78 53                	js     f010385a <syscall+0xea>
		return r;
	if (e == curenv)
f0103807:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010380a:	8b 15 60 3d 17 f0    	mov    0xf0173d60,%edx
f0103810:	39 d0                	cmp    %edx,%eax
f0103812:	75 15                	jne    f0103829 <syscall+0xb9>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103814:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103817:	89 44 24 04          	mov    %eax,0x4(%esp)
f010381b:	c7 04 24 75 5c 10 f0 	movl   $0xf0105c75,(%esp)
f0103822:	e8 d7 f7 ff ff       	call   f0102ffe <cprintf>
f0103827:	eb 1a                	jmp    f0103843 <syscall+0xd3>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103829:	8b 40 4c             	mov    0x4c(%eax),%eax
f010382c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103830:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103833:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103837:	c7 04 24 90 5c 10 f0 	movl   $0xf0105c90,(%esp)
f010383e:	e8 bb f7 ff ff       	call   f0102ffe <cprintf>
	env_destroy(e);
f0103843:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103846:	89 04 24             	mov    %eax,(%esp)
f0103849:	e8 9c f6 ff ff       	call   f0102eea <env_destroy>
	return 0;
f010384e:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cgetc:
			return (int32_t)sys_cgetc();
		case SYS_getenvid:
			return (int32_t)sys_getenvid();
		case SYS_env_destroy:
			return (int32_t)sys_env_destroy((envid_t)a1);
f0103853:	eb 05                	jmp    f010385a <syscall+0xea>
		default:	//NSYSCALLS means non-syscalls
			return -E_INVAL;
f0103855:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	//panic("syscall not implemented");
}
f010385a:	83 c4 20             	add    $0x20,%esp
f010385d:	5b                   	pop    %ebx
f010385e:	5e                   	pop    %esi
f010385f:	5d                   	pop    %ebp
f0103860:	c3                   	ret    
f0103861:	00 00                	add    %al,(%eax)
	...

f0103864 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103864:	55                   	push   %ebp
f0103865:	89 e5                	mov    %esp,%ebp
f0103867:	57                   	push   %edi
f0103868:	56                   	push   %esi
f0103869:	53                   	push   %ebx
f010386a:	83 ec 14             	sub    $0x14,%esp
f010386d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103870:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103873:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103876:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103879:	8b 1a                	mov    (%edx),%ebx
f010387b:	8b 01                	mov    (%ecx),%eax
f010387d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0103880:	39 c3                	cmp    %eax,%ebx
f0103882:	0f 8f 9c 00 00 00    	jg     f0103924 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103888:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010388f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103892:	01 d8                	add    %ebx,%eax
f0103894:	89 c7                	mov    %eax,%edi
f0103896:	c1 ef 1f             	shr    $0x1f,%edi
f0103899:	01 c7                	add    %eax,%edi
f010389b:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010389d:	39 df                	cmp    %ebx,%edi
f010389f:	7c 33                	jl     f01038d4 <stab_binsearch+0x70>
f01038a1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01038a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01038a7:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f01038ac:	39 f0                	cmp    %esi,%eax
f01038ae:	0f 84 bc 00 00 00    	je     f0103970 <stab_binsearch+0x10c>
f01038b4:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01038b8:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01038bc:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01038be:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01038c1:	39 d8                	cmp    %ebx,%eax
f01038c3:	7c 0f                	jl     f01038d4 <stab_binsearch+0x70>
f01038c5:	0f b6 0a             	movzbl (%edx),%ecx
f01038c8:	83 ea 0c             	sub    $0xc,%edx
f01038cb:	39 f1                	cmp    %esi,%ecx
f01038cd:	75 ef                	jne    f01038be <stab_binsearch+0x5a>
f01038cf:	e9 9e 00 00 00       	jmp    f0103972 <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01038d4:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01038d7:	eb 3c                	jmp    f0103915 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01038d9:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01038dc:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01038de:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01038e1:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01038e8:	eb 2b                	jmp    f0103915 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01038ea:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01038ed:	76 14                	jbe    f0103903 <stab_binsearch+0x9f>
			*region_right = m - 1;
f01038ef:	83 e8 01             	sub    $0x1,%eax
f01038f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01038f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01038f8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01038fa:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103901:	eb 12                	jmp    f0103915 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103903:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103906:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0103908:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010390c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010390e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103915:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103918:	0f 8d 71 ff ff ff    	jge    f010388f <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010391e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103922:	75 0f                	jne    f0103933 <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103924:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103927:	8b 02                	mov    (%edx),%eax
f0103929:	83 e8 01             	sub    $0x1,%eax
f010392c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010392f:	89 01                	mov    %eax,(%ecx)
f0103931:	eb 57                	jmp    f010398a <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103933:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103936:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103938:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010393b:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010393d:	39 c1                	cmp    %eax,%ecx
f010393f:	7d 28                	jge    f0103969 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103941:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103944:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103947:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f010394c:	39 f2                	cmp    %esi,%edx
f010394e:	74 19                	je     f0103969 <stab_binsearch+0x105>
f0103950:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103954:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103958:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010395b:	39 c1                	cmp    %eax,%ecx
f010395d:	7d 0a                	jge    f0103969 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f010395f:	0f b6 1a             	movzbl (%edx),%ebx
f0103962:	83 ea 0c             	sub    $0xc,%edx
f0103965:	39 f3                	cmp    %esi,%ebx
f0103967:	75 ef                	jne    f0103958 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103969:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010396c:	89 02                	mov    %eax,(%edx)
f010396e:	eb 1a                	jmp    f010398a <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103970:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103972:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103975:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103978:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010397c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010397f:	0f 82 54 ff ff ff    	jb     f01038d9 <stab_binsearch+0x75>
f0103985:	e9 60 ff ff ff       	jmp    f01038ea <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010398a:	83 c4 14             	add    $0x14,%esp
f010398d:	5b                   	pop    %ebx
f010398e:	5e                   	pop    %esi
f010398f:	5f                   	pop    %edi
f0103990:	5d                   	pop    %ebp
f0103991:	c3                   	ret    

f0103992 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103992:	55                   	push   %ebp
f0103993:	89 e5                	mov    %esp,%ebp
f0103995:	57                   	push   %edi
f0103996:	56                   	push   %esi
f0103997:	53                   	push   %ebx
f0103998:	83 ec 5c             	sub    $0x5c,%esp
f010399b:	8b 75 08             	mov    0x8(%ebp),%esi
f010399e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01039a1:	c7 03 a8 5c 10 f0    	movl   $0xf0105ca8,(%ebx)
	info->eip_line = 0;
f01039a7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01039ae:	c7 43 08 a8 5c 10 f0 	movl   $0xf0105ca8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01039b5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01039bc:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01039bf:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01039c6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01039cc:	0f 87 c0 00 00 00    	ja     f0103a92 <debuginfo_eip+0x100>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (const void *)usd, sizeof(struct UserStabData), PTE_U | PTE_P) < 0)
f01039d2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01039d9:	00 
f01039da:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01039e1:	00 
f01039e2:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01039e9:	00 
f01039ea:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f01039ef:	89 04 24             	mov    %eax,(%esp)
f01039f2:	e8 af ed ff ff       	call   f01027a6 <user_mem_check>
f01039f7:	89 c2                	mov    %eax,%edx
		{
			return -1;
f01039f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (const void *)usd, sizeof(struct UserStabData), PTE_U | PTE_P) < 0)
f01039fe:	85 d2                	test   %edx,%edx
f0103a00:	0f 88 7c 02 00 00    	js     f0103c82 <debuginfo_eip+0x2f0>
		{
			return -1;
		}

		stabs = usd->stabs;
f0103a06:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0103a0c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0103a0f:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0103a15:	a1 08 00 20 00       	mov    0x200008,%eax
f0103a1a:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0103a1d:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103a23:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end-stabs, PTE_U | PTE_P) < 0
f0103a26:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0103a2d:	00 
f0103a2e:	89 f8                	mov    %edi,%eax
f0103a30:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f0103a33:	c1 f8 02             	sar    $0x2,%eax
f0103a36:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103a3c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a40:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103a43:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103a47:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f0103a4c:	89 04 24             	mov    %eax,(%esp)
f0103a4f:	e8 52 ed ff ff       	call   f01027a6 <user_mem_check>
f0103a54:	89 c2                	mov    %eax,%edx
		|| user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U | PTE_P) < 0)
		{
			return -1;
f0103a56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end-stabs, PTE_U | PTE_P) < 0
f0103a5b:	85 d2                	test   %edx,%edx
f0103a5d:	0f 88 1f 02 00 00    	js     f0103c82 <debuginfo_eip+0x2f0>
		|| user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U | PTE_P) < 0)
f0103a63:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0103a6a:	00 
f0103a6b:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0103a6e:	2b 45 bc             	sub    -0x44(%ebp),%eax
f0103a71:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a75:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103a78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a7c:	a1 60 3d 17 f0       	mov    0xf0173d60,%eax
f0103a81:	89 04 24             	mov    %eax,(%esp)
f0103a84:	e8 1d ed ff ff       	call   f01027a6 <user_mem_check>
f0103a89:	85 c0                	test   %eax,%eax
f0103a8b:	79 1f                	jns    f0103aac <debuginfo_eip+0x11a>
f0103a8d:	e9 eb 01 00 00       	jmp    f0103c7d <debuginfo_eip+0x2eb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103a92:	c7 45 c0 16 01 11 f0 	movl   $0xf0110116,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103a99:	c7 45 bc 2d d7 10 f0 	movl   $0xf010d72d,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103aa0:	bf 2c d7 10 f0       	mov    $0xf010d72c,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103aa5:	c7 45 c4 c0 5e 10 f0 	movl   $0xf0105ec0,-0x3c(%ebp)
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103aac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103ab1:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103ab4:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f0103ab7:	0f 83 c5 01 00 00    	jae    f0103c82 <debuginfo_eip+0x2f0>
f0103abd:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f0103ac1:	0f 85 bb 01 00 00    	jne    f0103c82 <debuginfo_eip+0x2f0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103ac7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103ace:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0103ad1:	c1 ff 02             	sar    $0x2,%edi
f0103ad4:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0103ada:	83 e8 01             	sub    $0x1,%eax
f0103add:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103ae0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103ae4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103aeb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103aee:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103af1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103af4:	e8 6b fd ff ff       	call   f0103864 <stab_binsearch>
	if (lfile == 0)
f0103af9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0103afc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0103b01:	85 d2                	test   %edx,%edx
f0103b03:	0f 84 79 01 00 00    	je     f0103c82 <debuginfo_eip+0x2f0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103b09:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0103b0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103b12:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b16:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103b1d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103b20:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103b23:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103b26:	e8 39 fd ff ff       	call   f0103864 <stab_binsearch>

	if (lfun <= rfun) {
f0103b2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b2e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b31:	39 d0                	cmp    %edx,%eax
f0103b33:	7f 32                	jg     f0103b67 <debuginfo_eip+0x1d5>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103b35:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103b38:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103b3b:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0103b3e:	8b 39                	mov    (%ecx),%edi
f0103b40:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0103b43:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103b46:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0103b49:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0103b4c:	73 09                	jae    f0103b57 <debuginfo_eip+0x1c5>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103b4e:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0103b51:	03 7d bc             	add    -0x44(%ebp),%edi
f0103b54:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103b57:	8b 49 08             	mov    0x8(%ecx),%ecx
f0103b5a:	89 4b 10             	mov    %ecx,0x10(%ebx)
		// This "n_value" is the function's first addr, but when it comes to SLINE,
		// "n_value" describes the offset, so we need to minus "n_value" fro addr
		// to get the offset of the line.
		addr -= info->eip_fn_addr;
f0103b5d:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103b5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103b62:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103b65:	eb 0f                	jmp    f0103b76 <debuginfo_eip+0x1e4>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103b67:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103b6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b6d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103b70:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b73:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103b76:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103b7d:	00 
f0103b7e:	8b 43 08             	mov    0x8(%ebx),%eax
f0103b81:	89 04 24             	mov    %eax,(%esp)
f0103b84:	e8 26 09 00 00       	call   f01044af <strfind>
f0103b89:	2b 43 08             	sub    0x8(%ebx),%eax
f0103b8c:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103b8f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b93:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103b9a:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103b9d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103ba0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103ba3:	e8 bc fc ff ff       	call   f0103864 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0103ba8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bab:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103bae:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103bb1:	0f b7 54 96 06       	movzwl 0x6(%esi,%edx,4),%edx
f0103bb6:	89 53 04             	mov    %edx,0x4(%ebx)
	if (rline < lline)
f0103bb9:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103bbc:	7e 07                	jle    f0103bc5 <debuginfo_eip+0x233>
	{
		info->eip_line = -1;
f0103bbe:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103bc5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103bc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103bcb:	89 7d b8             	mov    %edi,-0x48(%ebp)
f0103bce:	39 f8                	cmp    %edi,%eax
f0103bd0:	7c 78                	jl     f0103c4a <debuginfo_eip+0x2b8>
	       && stabs[lline].n_type != N_SOL
f0103bd2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103bd5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103bd8:	8d 34 97             	lea    (%edi,%edx,4),%esi
f0103bdb:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f0103bdf:	80 f9 84             	cmp    $0x84,%cl
f0103be2:	74 4e                	je     f0103c32 <debuginfo_eip+0x2a0>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103be4:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0103be8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103beb:	89 c7                	mov    %eax,%edi
f0103bed:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f0103bf0:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0103bf3:	eb 27                	jmp    f0103c1c <debuginfo_eip+0x28a>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103bf5:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103bf8:	39 c3                	cmp    %eax,%ebx
f0103bfa:	7e 08                	jle    f0103c04 <debuginfo_eip+0x272>
f0103bfc:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0103bff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103c02:	eb 46                	jmp    f0103c4a <debuginfo_eip+0x2b8>
	       && stabs[lline].n_type != N_SOL
f0103c04:	89 d6                	mov    %edx,%esi
f0103c06:	83 ea 0c             	sub    $0xc,%edx
f0103c09:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f0103c0d:	80 f9 84             	cmp    $0x84,%cl
f0103c10:	75 08                	jne    f0103c1a <debuginfo_eip+0x288>
f0103c12:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0103c15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103c18:	eb 18                	jmp    f0103c32 <debuginfo_eip+0x2a0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103c1a:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103c1c:	80 f9 64             	cmp    $0x64,%cl
f0103c1f:	75 d4                	jne    f0103bf5 <debuginfo_eip+0x263>
f0103c21:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0103c25:	74 ce                	je     f0103bf5 <debuginfo_eip+0x263>
f0103c27:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0103c2a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103c2d:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0103c30:	7f 18                	jg     f0103c4a <debuginfo_eip+0x2b8>
f0103c32:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103c35:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0103c38:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0103c3b:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103c3e:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0103c41:	39 d0                	cmp    %edx,%eax
f0103c43:	73 05                	jae    f0103c4a <debuginfo_eip+0x2b8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103c45:	03 45 bc             	add    -0x44(%ebp),%eax
f0103c48:	89 03                	mov    %eax,(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0103c4a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103c4d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0103c50:	b8 00 00 00 00       	mov    $0x0,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0103c55:	39 d1                	cmp    %edx,%ecx
f0103c57:	7c 29                	jl     f0103c82 <debuginfo_eip+0x2f0>
	{
		if (stabs[i].n_type == N_PSYM)
f0103c59:	8d 04 52             	lea    (%edx,%edx,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103c5c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103c5f:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
	{
		if (stabs[i].n_type == N_PSYM)
f0103c63:	80 38 a0             	cmpb   $0xa0,(%eax)
f0103c66:	75 04                	jne    f0103c6c <debuginfo_eip+0x2da>
		{
			++(info->eip_fn_narg);
f0103c68:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0103c6c:	83 c2 01             	add    $0x1,%edx
f0103c6f:	83 c0 0c             	add    $0xc,%eax
f0103c72:	39 d1                	cmp    %edx,%ecx
f0103c74:	7d ed                	jge    f0103c63 <debuginfo_eip+0x2d1>
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0103c76:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c7b:	eb 05                	jmp    f0103c82 <debuginfo_eip+0x2f0>
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end-stabs, PTE_U | PTE_P) < 0
		|| user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U | PTE_P) < 0)
		{
			return -1;
f0103c7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		}
	}

	
	return 0;
}
f0103c82:	83 c4 5c             	add    $0x5c,%esp
f0103c85:	5b                   	pop    %ebx
f0103c86:	5e                   	pop    %esi
f0103c87:	5f                   	pop    %edi
f0103c88:	5d                   	pop    %ebp
f0103c89:	c3                   	ret    
f0103c8a:	00 00                	add    %al,(%eax)
f0103c8c:	00 00                	add    %al,(%eax)
	...

f0103c90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103c90:	55                   	push   %ebp
f0103c91:	89 e5                	mov    %esp,%ebp
f0103c93:	57                   	push   %edi
f0103c94:	56                   	push   %esi
f0103c95:	53                   	push   %ebx
f0103c96:	83 ec 3c             	sub    $0x3c,%esp
f0103c99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103c9c:	89 d7                	mov    %edx,%edi
f0103c9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ca1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ca7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103caa:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103cad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103cb0:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cb5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0103cb8:	72 11                	jb     f0103ccb <printnum+0x3b>
f0103cba:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103cbd:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103cc0:	76 09                	jbe    f0103ccb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103cc2:	83 eb 01             	sub    $0x1,%ebx
f0103cc5:	85 db                	test   %ebx,%ebx
f0103cc7:	7f 51                	jg     f0103d1a <printnum+0x8a>
f0103cc9:	eb 5e                	jmp    f0103d29 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103ccb:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103ccf:	83 eb 01             	sub    $0x1,%ebx
f0103cd2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103cd6:	8b 45 10             	mov    0x10(%ebp),%eax
f0103cd9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103cdd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0103ce1:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0103ce5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103cec:	00 
f0103ced:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103cf0:	89 04 24             	mov    %eax,(%esp)
f0103cf3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cfa:	e8 d1 09 00 00       	call   f01046d0 <__udivdi3>
f0103cff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103d03:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103d07:	89 04 24             	mov    %eax,(%esp)
f0103d0a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103d0e:	89 fa                	mov    %edi,%edx
f0103d10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d13:	e8 78 ff ff ff       	call   f0103c90 <printnum>
f0103d18:	eb 0f                	jmp    f0103d29 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d1a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d1e:	89 34 24             	mov    %esi,(%esp)
f0103d21:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103d24:	83 eb 01             	sub    $0x1,%ebx
f0103d27:	75 f1                	jne    f0103d1a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d29:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d2d:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103d31:	8b 45 10             	mov    0x10(%ebp),%eax
f0103d34:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d38:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103d3f:	00 
f0103d40:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103d43:	89 04 24             	mov    %eax,(%esp)
f0103d46:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d4d:	e8 ae 0a 00 00       	call   f0104800 <__umoddi3>
f0103d52:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103d56:	0f be 80 b2 5c 10 f0 	movsbl -0xfefa34e(%eax),%eax
f0103d5d:	89 04 24             	mov    %eax,(%esp)
f0103d60:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0103d63:	83 c4 3c             	add    $0x3c,%esp
f0103d66:	5b                   	pop    %ebx
f0103d67:	5e                   	pop    %esi
f0103d68:	5f                   	pop    %edi
f0103d69:	5d                   	pop    %ebp
f0103d6a:	c3                   	ret    

f0103d6b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103d6b:	55                   	push   %ebp
f0103d6c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103d6e:	83 fa 01             	cmp    $0x1,%edx
f0103d71:	7e 0e                	jle    f0103d81 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103d73:	8b 10                	mov    (%eax),%edx
f0103d75:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103d78:	89 08                	mov    %ecx,(%eax)
f0103d7a:	8b 02                	mov    (%edx),%eax
f0103d7c:	8b 52 04             	mov    0x4(%edx),%edx
f0103d7f:	eb 22                	jmp    f0103da3 <getuint+0x38>
	else if (lflag)
f0103d81:	85 d2                	test   %edx,%edx
f0103d83:	74 10                	je     f0103d95 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103d85:	8b 10                	mov    (%eax),%edx
f0103d87:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103d8a:	89 08                	mov    %ecx,(%eax)
f0103d8c:	8b 02                	mov    (%edx),%eax
f0103d8e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d93:	eb 0e                	jmp    f0103da3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103d95:	8b 10                	mov    (%eax),%edx
f0103d97:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103d9a:	89 08                	mov    %ecx,(%eax)
f0103d9c:	8b 02                	mov    (%edx),%eax
f0103d9e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103da3:	5d                   	pop    %ebp
f0103da4:	c3                   	ret    

f0103da5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103da5:	55                   	push   %ebp
f0103da6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103da8:	83 fa 01             	cmp    $0x1,%edx
f0103dab:	7e 0e                	jle    f0103dbb <getint+0x16>
		return va_arg(*ap, long long);
f0103dad:	8b 10                	mov    (%eax),%edx
f0103daf:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103db2:	89 08                	mov    %ecx,(%eax)
f0103db4:	8b 02                	mov    (%edx),%eax
f0103db6:	8b 52 04             	mov    0x4(%edx),%edx
f0103db9:	eb 22                	jmp    f0103ddd <getint+0x38>
	else if (lflag)
f0103dbb:	85 d2                	test   %edx,%edx
f0103dbd:	74 10                	je     f0103dcf <getint+0x2a>
		return va_arg(*ap, long);
f0103dbf:	8b 10                	mov    (%eax),%edx
f0103dc1:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103dc4:	89 08                	mov    %ecx,(%eax)
f0103dc6:	8b 02                	mov    (%edx),%eax
f0103dc8:	89 c2                	mov    %eax,%edx
f0103dca:	c1 fa 1f             	sar    $0x1f,%edx
f0103dcd:	eb 0e                	jmp    f0103ddd <getint+0x38>
	else
		return va_arg(*ap, int);
f0103dcf:	8b 10                	mov    (%eax),%edx
f0103dd1:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103dd4:	89 08                	mov    %ecx,(%eax)
f0103dd6:	8b 02                	mov    (%edx),%eax
f0103dd8:	89 c2                	mov    %eax,%edx
f0103dda:	c1 fa 1f             	sar    $0x1f,%edx
}
f0103ddd:	5d                   	pop    %ebp
f0103dde:	c3                   	ret    

f0103ddf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103ddf:	55                   	push   %ebp
f0103de0:	89 e5                	mov    %esp,%ebp
f0103de2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103de5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103de9:	8b 10                	mov    (%eax),%edx
f0103deb:	3b 50 04             	cmp    0x4(%eax),%edx
f0103dee:	73 0a                	jae    f0103dfa <sprintputch+0x1b>
		*b->buf++ = ch;
f0103df0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103df3:	88 0a                	mov    %cl,(%edx)
f0103df5:	83 c2 01             	add    $0x1,%edx
f0103df8:	89 10                	mov    %edx,(%eax)
}
f0103dfa:	5d                   	pop    %ebp
f0103dfb:	c3                   	ret    

f0103dfc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103dfc:	55                   	push   %ebp
f0103dfd:	89 e5                	mov    %esp,%ebp
f0103dff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0103e02:	8d 45 14             	lea    0x14(%ebp),%eax
f0103e05:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e09:	8b 45 10             	mov    0x10(%ebp),%eax
f0103e0c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e13:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e17:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e1a:	89 04 24             	mov    %eax,(%esp)
f0103e1d:	e8 02 00 00 00       	call   f0103e24 <vprintfmt>
	va_end(ap);
}
f0103e22:	c9                   	leave  
f0103e23:	c3                   	ret    

f0103e24 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103e24:	55                   	push   %ebp
f0103e25:	89 e5                	mov    %esp,%ebp
f0103e27:	57                   	push   %edi
f0103e28:	56                   	push   %esi
f0103e29:	53                   	push   %ebx
f0103e2a:	83 ec 4c             	sub    $0x4c,%esp
f0103e2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e30:	8b 75 10             	mov    0x10(%ebp),%esi
f0103e33:	eb 12                	jmp    f0103e47 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103e35:	85 c0                	test   %eax,%eax
f0103e37:	0f 84 98 03 00 00    	je     f01041d5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f0103e3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e41:	89 04 24             	mov    %eax,(%esp)
f0103e44:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103e47:	0f b6 06             	movzbl (%esi),%eax
f0103e4a:	83 c6 01             	add    $0x1,%esi
f0103e4d:	83 f8 25             	cmp    $0x25,%eax
f0103e50:	75 e3                	jne    f0103e35 <vprintfmt+0x11>
f0103e52:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0103e56:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103e5d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0103e62:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103e69:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e6e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103e71:	eb 2b                	jmp    f0103e9e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e73:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103e76:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0103e7a:	eb 22                	jmp    f0103e9e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e7c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103e7f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0103e83:	eb 19                	jmp    f0103e9e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e85:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103e88:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103e8f:	eb 0d                	jmp    f0103e9e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103e91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103e94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e97:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e9e:	0f b6 06             	movzbl (%esi),%eax
f0103ea1:	0f b6 d0             	movzbl %al,%edx
f0103ea4:	8d 7e 01             	lea    0x1(%esi),%edi
f0103ea7:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0103eaa:	83 e8 23             	sub    $0x23,%eax
f0103ead:	3c 55                	cmp    $0x55,%al
f0103eaf:	0f 87 fa 02 00 00    	ja     f01041af <vprintfmt+0x38b>
f0103eb5:	0f b6 c0             	movzbl %al,%eax
f0103eb8:	ff 24 85 3c 5d 10 f0 	jmp    *-0xfefa2c4(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103ebf:	83 ea 30             	sub    $0x30,%edx
f0103ec2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0103ec5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0103ec9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ecc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0103ecf:	83 fa 09             	cmp    $0x9,%edx
f0103ed2:	77 4a                	ja     f0103f1e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ed4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103ed7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0103eda:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0103edd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0103ee1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103ee4:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103ee7:	83 fa 09             	cmp    $0x9,%edx
f0103eea:	76 eb                	jbe    f0103ed7 <vprintfmt+0xb3>
f0103eec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103eef:	eb 2d                	jmp    f0103f1e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103ef1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ef4:	8d 50 04             	lea    0x4(%eax),%edx
f0103ef7:	89 55 14             	mov    %edx,0x14(%ebp)
f0103efa:	8b 00                	mov    (%eax),%eax
f0103efc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103f02:	eb 1a                	jmp    f0103f1e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f04:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0103f07:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f0b:	79 91                	jns    f0103e9e <vprintfmt+0x7a>
f0103f0d:	e9 73 ff ff ff       	jmp    f0103e85 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f12:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103f15:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103f1c:	eb 80                	jmp    f0103e9e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f0103f1e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f22:	0f 89 76 ff ff ff    	jns    f0103e9e <vprintfmt+0x7a>
f0103f28:	e9 64 ff ff ff       	jmp    f0103e91 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103f2d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f30:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103f33:	e9 66 ff ff ff       	jmp    f0103e9e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103f38:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f3b:	8d 50 04             	lea    0x4(%eax),%edx
f0103f3e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f41:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f45:	8b 00                	mov    (%eax),%eax
f0103f47:	89 04 24             	mov    %eax,(%esp)
f0103f4a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f4d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103f50:	e9 f2 fe ff ff       	jmp    f0103e47 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103f55:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f58:	8d 50 04             	lea    0x4(%eax),%edx
f0103f5b:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f5e:	8b 00                	mov    (%eax),%eax
f0103f60:	89 c2                	mov    %eax,%edx
f0103f62:	c1 fa 1f             	sar    $0x1f,%edx
f0103f65:	31 d0                	xor    %edx,%eax
f0103f67:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0103f69:	83 f8 06             	cmp    $0x6,%eax
f0103f6c:	7f 0b                	jg     f0103f79 <vprintfmt+0x155>
f0103f6e:	8b 14 85 94 5e 10 f0 	mov    -0xfefa16c(,%eax,4),%edx
f0103f75:	85 d2                	test   %edx,%edx
f0103f77:	75 23                	jne    f0103f9c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0103f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f7d:	c7 44 24 08 ca 5c 10 	movl   $0xf0105cca,0x8(%esp)
f0103f84:	f0 
f0103f85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f89:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103f8c:	89 3c 24             	mov    %edi,(%esp)
f0103f8f:	e8 68 fe ff ff       	call   f0103dfc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f94:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103f97:	e9 ab fe ff ff       	jmp    f0103e47 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0103f9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103fa0:	c7 44 24 08 6f 56 10 	movl   $0xf010566f,0x8(%esp)
f0103fa7:	f0 
f0103fa8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103fac:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103faf:	89 3c 24             	mov    %edi,(%esp)
f0103fb2:	e8 45 fe ff ff       	call   f0103dfc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103fb7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103fba:	e9 88 fe ff ff       	jmp    f0103e47 <vprintfmt+0x23>
f0103fbf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103fc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103fc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103fc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fcb:	8d 50 04             	lea    0x4(%eax),%edx
f0103fce:	89 55 14             	mov    %edx,0x14(%ebp)
f0103fd1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103fd3:	85 f6                	test   %esi,%esi
f0103fd5:	ba c3 5c 10 f0       	mov    $0xf0105cc3,%edx
f0103fda:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0103fdd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103fe1:	7e 06                	jle    f0103fe9 <vprintfmt+0x1c5>
f0103fe3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0103fe7:	75 10                	jne    f0103ff9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103fe9:	0f be 06             	movsbl (%esi),%eax
f0103fec:	83 c6 01             	add    $0x1,%esi
f0103fef:	85 c0                	test   %eax,%eax
f0103ff1:	0f 85 86 00 00 00    	jne    f010407d <vprintfmt+0x259>
f0103ff7:	eb 76                	jmp    f010406f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103ff9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103ffd:	89 34 24             	mov    %esi,(%esp)
f0104000:	e8 36 03 00 00       	call   f010433b <strnlen>
f0104005:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104008:	29 c2                	sub    %eax,%edx
f010400a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010400d:	85 d2                	test   %edx,%edx
f010400f:	7e d8                	jle    f0103fe9 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0104011:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0104015:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104018:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010401b:	89 d6                	mov    %edx,%esi
f010401d:	89 c7                	mov    %eax,%edi
f010401f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104023:	89 3c 24             	mov    %edi,(%esp)
f0104026:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104029:	83 ee 01             	sub    $0x1,%esi
f010402c:	75 f1                	jne    f010401f <vprintfmt+0x1fb>
f010402e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0104031:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0104034:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104037:	eb b0                	jmp    f0103fe9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104039:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010403d:	74 18                	je     f0104057 <vprintfmt+0x233>
f010403f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104042:	83 fa 5e             	cmp    $0x5e,%edx
f0104045:	76 10                	jbe    f0104057 <vprintfmt+0x233>
					putch('?', putdat);
f0104047:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010404b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104052:	ff 55 08             	call   *0x8(%ebp)
f0104055:	eb 0a                	jmp    f0104061 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f0104057:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010405b:	89 04 24             	mov    %eax,(%esp)
f010405e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104061:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0104065:	0f be 06             	movsbl (%esi),%eax
f0104068:	83 c6 01             	add    $0x1,%esi
f010406b:	85 c0                	test   %eax,%eax
f010406d:	75 0e                	jne    f010407d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010406f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104072:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104076:	7f 11                	jg     f0104089 <vprintfmt+0x265>
f0104078:	e9 ca fd ff ff       	jmp    f0103e47 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010407d:	85 ff                	test   %edi,%edi
f010407f:	90                   	nop
f0104080:	78 b7                	js     f0104039 <vprintfmt+0x215>
f0104082:	83 ef 01             	sub    $0x1,%edi
f0104085:	79 b2                	jns    f0104039 <vprintfmt+0x215>
f0104087:	eb e6                	jmp    f010406f <vprintfmt+0x24b>
f0104089:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010408c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010408f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104093:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010409a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010409c:	83 ee 01             	sub    $0x1,%esi
f010409f:	75 ee                	jne    f010408f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01040a4:	e9 9e fd ff ff       	jmp    f0103e47 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01040a9:	89 ca                	mov    %ecx,%edx
f01040ab:	8d 45 14             	lea    0x14(%ebp),%eax
f01040ae:	e8 f2 fc ff ff       	call   f0103da5 <getint>
f01040b3:	89 c6                	mov    %eax,%esi
f01040b5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01040b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01040bc:	85 d2                	test   %edx,%edx
f01040be:	0f 89 ad 00 00 00    	jns    f0104171 <vprintfmt+0x34d>
				putch('-', putdat);
f01040c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01040c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01040cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01040d2:	f7 de                	neg    %esi
f01040d4:	83 d7 00             	adc    $0x0,%edi
f01040d7:	f7 df                	neg    %edi
			}
			base = 10;
f01040d9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01040de:	e9 8e 00 00 00       	jmp    f0104171 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01040e3:	89 ca                	mov    %ecx,%edx
f01040e5:	8d 45 14             	lea    0x14(%ebp),%eax
f01040e8:	e8 7e fc ff ff       	call   f0103d6b <getuint>
f01040ed:	89 c6                	mov    %eax,%esi
f01040ef:	89 d7                	mov    %edx,%edi
			base = 10;
f01040f1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01040f6:	eb 79                	jmp    f0104171 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f01040f8:	89 ca                	mov    %ecx,%edx
f01040fa:	8d 45 14             	lea    0x14(%ebp),%eax
f01040fd:	e8 a3 fc ff ff       	call   f0103da5 <getint>
f0104102:	89 c6                	mov    %eax,%esi
f0104104:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f0104106:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010410b:	85 d2                	test   %edx,%edx
f010410d:	79 62                	jns    f0104171 <vprintfmt+0x34d>
				putch('-', putdat);
f010410f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104113:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010411a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010411d:	f7 de                	neg    %esi
f010411f:	83 d7 00             	adc    $0x0,%edi
f0104122:	f7 df                	neg    %edi
			}
			base = 8;
f0104124:	b8 08 00 00 00       	mov    $0x8,%eax
f0104129:	eb 46                	jmp    f0104171 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f010412b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010412f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104136:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104139:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010413d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104144:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104147:	8b 45 14             	mov    0x14(%ebp),%eax
f010414a:	8d 50 04             	lea    0x4(%eax),%edx
f010414d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104150:	8b 30                	mov    (%eax),%esi
f0104152:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104157:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010415c:	eb 13                	jmp    f0104171 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010415e:	89 ca                	mov    %ecx,%edx
f0104160:	8d 45 14             	lea    0x14(%ebp),%eax
f0104163:	e8 03 fc ff ff       	call   f0103d6b <getuint>
f0104168:	89 c6                	mov    %eax,%esi
f010416a:	89 d7                	mov    %edx,%edi
			base = 16;
f010416c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104171:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0104175:	89 54 24 10          	mov    %edx,0x10(%esp)
f0104179:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010417c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104180:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104184:	89 34 24             	mov    %esi,(%esp)
f0104187:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010418b:	89 da                	mov    %ebx,%edx
f010418d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104190:	e8 fb fa ff ff       	call   f0103c90 <printnum>
			break;
f0104195:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104198:	e9 aa fc ff ff       	jmp    f0103e47 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010419d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041a1:	89 14 24             	mov    %edx,(%esp)
f01041a4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01041a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01041aa:	e9 98 fc ff ff       	jmp    f0103e47 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01041af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01041b3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01041ba:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01041bd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01041c1:	0f 84 80 fc ff ff    	je     f0103e47 <vprintfmt+0x23>
f01041c7:	83 ee 01             	sub    $0x1,%esi
f01041ca:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01041ce:	75 f7                	jne    f01041c7 <vprintfmt+0x3a3>
f01041d0:	e9 72 fc ff ff       	jmp    f0103e47 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01041d5:	83 c4 4c             	add    $0x4c,%esp
f01041d8:	5b                   	pop    %ebx
f01041d9:	5e                   	pop    %esi
f01041da:	5f                   	pop    %edi
f01041db:	5d                   	pop    %ebp
f01041dc:	c3                   	ret    

f01041dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01041dd:	55                   	push   %ebp
f01041de:	89 e5                	mov    %esp,%ebp
f01041e0:	83 ec 28             	sub    $0x28,%esp
f01041e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01041e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01041e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01041ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01041f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01041f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01041fa:	85 c0                	test   %eax,%eax
f01041fc:	74 30                	je     f010422e <vsnprintf+0x51>
f01041fe:	85 d2                	test   %edx,%edx
f0104200:	7e 2c                	jle    f010422e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104202:	8b 45 14             	mov    0x14(%ebp),%eax
f0104205:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104209:	8b 45 10             	mov    0x10(%ebp),%eax
f010420c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104210:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104213:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104217:	c7 04 24 df 3d 10 f0 	movl   $0xf0103ddf,(%esp)
f010421e:	e8 01 fc ff ff       	call   f0103e24 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104223:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104226:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104229:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010422c:	eb 05                	jmp    f0104233 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010422e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104233:	c9                   	leave  
f0104234:	c3                   	ret    

f0104235 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104235:	55                   	push   %ebp
f0104236:	89 e5                	mov    %esp,%ebp
f0104238:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f010423b:	8d 45 14             	lea    0x14(%ebp),%eax
f010423e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104242:	8b 45 10             	mov    0x10(%ebp),%eax
f0104245:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104249:	8b 45 0c             	mov    0xc(%ebp),%eax
f010424c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104250:	8b 45 08             	mov    0x8(%ebp),%eax
f0104253:	89 04 24             	mov    %eax,(%esp)
f0104256:	e8 82 ff ff ff       	call   f01041dd <vsnprintf>
	va_end(ap);

	return rc;
}
f010425b:	c9                   	leave  
f010425c:	c3                   	ret    
f010425d:	00 00                	add    %al,(%eax)
	...

f0104260 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104260:	55                   	push   %ebp
f0104261:	89 e5                	mov    %esp,%ebp
f0104263:	57                   	push   %edi
f0104264:	56                   	push   %esi
f0104265:	53                   	push   %ebx
f0104266:	83 ec 1c             	sub    $0x1c,%esp
f0104269:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010426c:	85 c0                	test   %eax,%eax
f010426e:	74 10                	je     f0104280 <readline+0x20>
		cprintf("%s", prompt);
f0104270:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104274:	c7 04 24 6f 56 10 f0 	movl   $0xf010566f,(%esp)
f010427b:	e8 7e ed ff ff       	call   f0102ffe <cprintf>

	i = 0;
	echoing = iscons(0);
f0104280:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104287:	e8 70 c4 ff ff       	call   f01006fc <iscons>
f010428c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010428e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104293:	e8 53 c4 ff ff       	call   f01006eb <getchar>
f0104298:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010429a:	85 c0                	test   %eax,%eax
f010429c:	79 17                	jns    f01042b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010429e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042a2:	c7 04 24 b0 5e 10 f0 	movl   $0xf0105eb0,(%esp)
f01042a9:	e8 50 ed ff ff       	call   f0102ffe <cprintf>
			return NULL;
f01042ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01042b3:	eb 61                	jmp    f0104316 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01042b5:	83 f8 1f             	cmp    $0x1f,%eax
f01042b8:	7e 1f                	jle    f01042d9 <readline+0x79>
f01042ba:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01042c0:	7f 17                	jg     f01042d9 <readline+0x79>
			if (echoing)
f01042c2:	85 ff                	test   %edi,%edi
f01042c4:	74 08                	je     f01042ce <readline+0x6e>
				cputchar(c);
f01042c6:	89 04 24             	mov    %eax,(%esp)
f01042c9:	e8 0a c4 ff ff       	call   f01006d8 <cputchar>
			buf[i++] = c;
f01042ce:	88 9e 00 46 17 f0    	mov    %bl,-0xfe8ba00(%esi)
f01042d4:	83 c6 01             	add    $0x1,%esi
f01042d7:	eb ba                	jmp    f0104293 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f01042d9:	83 fb 08             	cmp    $0x8,%ebx
f01042dc:	75 15                	jne    f01042f3 <readline+0x93>
f01042de:	85 f6                	test   %esi,%esi
f01042e0:	7e 11                	jle    f01042f3 <readline+0x93>
			if (echoing)
f01042e2:	85 ff                	test   %edi,%edi
f01042e4:	74 08                	je     f01042ee <readline+0x8e>
				cputchar(c);
f01042e6:	89 1c 24             	mov    %ebx,(%esp)
f01042e9:	e8 ea c3 ff ff       	call   f01006d8 <cputchar>
			i--;
f01042ee:	83 ee 01             	sub    $0x1,%esi
f01042f1:	eb a0                	jmp    f0104293 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01042f3:	83 fb 0a             	cmp    $0xa,%ebx
f01042f6:	74 05                	je     f01042fd <readline+0x9d>
f01042f8:	83 fb 0d             	cmp    $0xd,%ebx
f01042fb:	75 96                	jne    f0104293 <readline+0x33>
			if (echoing)
f01042fd:	85 ff                	test   %edi,%edi
f01042ff:	90                   	nop
f0104300:	74 08                	je     f010430a <readline+0xaa>
				cputchar(c);
f0104302:	89 1c 24             	mov    %ebx,(%esp)
f0104305:	e8 ce c3 ff ff       	call   f01006d8 <cputchar>
			buf[i] = 0;
f010430a:	c6 86 00 46 17 f0 00 	movb   $0x0,-0xfe8ba00(%esi)
			return buf;
f0104311:	b8 00 46 17 f0       	mov    $0xf0174600,%eax
		}
	}
}
f0104316:	83 c4 1c             	add    $0x1c,%esp
f0104319:	5b                   	pop    %ebx
f010431a:	5e                   	pop    %esi
f010431b:	5f                   	pop    %edi
f010431c:	5d                   	pop    %ebp
f010431d:	c3                   	ret    
	...

f0104320 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0104320:	55                   	push   %ebp
f0104321:	89 e5                	mov    %esp,%ebp
f0104323:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104326:	b8 00 00 00 00       	mov    $0x0,%eax
f010432b:	80 3a 00             	cmpb   $0x0,(%edx)
f010432e:	74 09                	je     f0104339 <strlen+0x19>
		n++;
f0104330:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104333:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104337:	75 f7                	jne    f0104330 <strlen+0x10>
		n++;
	return n;
}
f0104339:	5d                   	pop    %ebp
f010433a:	c3                   	ret    

f010433b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010433b:	55                   	push   %ebp
f010433c:	89 e5                	mov    %esp,%ebp
f010433e:	53                   	push   %ebx
f010433f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104342:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104345:	b8 00 00 00 00       	mov    $0x0,%eax
f010434a:	85 c9                	test   %ecx,%ecx
f010434c:	74 1a                	je     f0104368 <strnlen+0x2d>
f010434e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104351:	74 15                	je     f0104368 <strnlen+0x2d>
f0104353:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0104358:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010435a:	39 ca                	cmp    %ecx,%edx
f010435c:	74 0a                	je     f0104368 <strnlen+0x2d>
f010435e:	83 c2 01             	add    $0x1,%edx
f0104361:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104366:	75 f0                	jne    f0104358 <strnlen+0x1d>
		n++;
	return n;
}
f0104368:	5b                   	pop    %ebx
f0104369:	5d                   	pop    %ebp
f010436a:	c3                   	ret    

f010436b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010436b:	55                   	push   %ebp
f010436c:	89 e5                	mov    %esp,%ebp
f010436e:	53                   	push   %ebx
f010436f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104372:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104375:	ba 00 00 00 00       	mov    $0x0,%edx
f010437a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010437e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104381:	83 c2 01             	add    $0x1,%edx
f0104384:	84 c9                	test   %cl,%cl
f0104386:	75 f2                	jne    f010437a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104388:	5b                   	pop    %ebx
f0104389:	5d                   	pop    %ebp
f010438a:	c3                   	ret    

f010438b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010438b:	55                   	push   %ebp
f010438c:	89 e5                	mov    %esp,%ebp
f010438e:	56                   	push   %esi
f010438f:	53                   	push   %ebx
f0104390:	8b 45 08             	mov    0x8(%ebp),%eax
f0104393:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104396:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104399:	85 f6                	test   %esi,%esi
f010439b:	74 18                	je     f01043b5 <strncpy+0x2a>
f010439d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01043a2:	0f b6 1a             	movzbl (%edx),%ebx
f01043a5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01043a8:	80 3a 01             	cmpb   $0x1,(%edx)
f01043ab:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01043ae:	83 c1 01             	add    $0x1,%ecx
f01043b1:	39 f1                	cmp    %esi,%ecx
f01043b3:	75 ed                	jne    f01043a2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01043b5:	5b                   	pop    %ebx
f01043b6:	5e                   	pop    %esi
f01043b7:	5d                   	pop    %ebp
f01043b8:	c3                   	ret    

f01043b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01043b9:	55                   	push   %ebp
f01043ba:	89 e5                	mov    %esp,%ebp
f01043bc:	57                   	push   %edi
f01043bd:	56                   	push   %esi
f01043be:	53                   	push   %ebx
f01043bf:	8b 7d 08             	mov    0x8(%ebp),%edi
f01043c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043c5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01043c8:	89 f8                	mov    %edi,%eax
f01043ca:	85 f6                	test   %esi,%esi
f01043cc:	74 2b                	je     f01043f9 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01043ce:	83 fe 01             	cmp    $0x1,%esi
f01043d1:	74 23                	je     f01043f6 <strlcpy+0x3d>
f01043d3:	0f b6 0b             	movzbl (%ebx),%ecx
f01043d6:	84 c9                	test   %cl,%cl
f01043d8:	74 1c                	je     f01043f6 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01043da:	83 ee 02             	sub    $0x2,%esi
f01043dd:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01043e2:	88 08                	mov    %cl,(%eax)
f01043e4:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01043e7:	39 f2                	cmp    %esi,%edx
f01043e9:	74 0b                	je     f01043f6 <strlcpy+0x3d>
f01043eb:	83 c2 01             	add    $0x1,%edx
f01043ee:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01043f2:	84 c9                	test   %cl,%cl
f01043f4:	75 ec                	jne    f01043e2 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01043f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01043f9:	29 f8                	sub    %edi,%eax
}
f01043fb:	5b                   	pop    %ebx
f01043fc:	5e                   	pop    %esi
f01043fd:	5f                   	pop    %edi
f01043fe:	5d                   	pop    %ebp
f01043ff:	c3                   	ret    

f0104400 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104400:	55                   	push   %ebp
f0104401:	89 e5                	mov    %esp,%ebp
f0104403:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104406:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104409:	0f b6 01             	movzbl (%ecx),%eax
f010440c:	84 c0                	test   %al,%al
f010440e:	74 16                	je     f0104426 <strcmp+0x26>
f0104410:	3a 02                	cmp    (%edx),%al
f0104412:	75 12                	jne    f0104426 <strcmp+0x26>
		p++, q++;
f0104414:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104417:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f010441b:	84 c0                	test   %al,%al
f010441d:	74 07                	je     f0104426 <strcmp+0x26>
f010441f:	83 c1 01             	add    $0x1,%ecx
f0104422:	3a 02                	cmp    (%edx),%al
f0104424:	74 ee                	je     f0104414 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104426:	0f b6 c0             	movzbl %al,%eax
f0104429:	0f b6 12             	movzbl (%edx),%edx
f010442c:	29 d0                	sub    %edx,%eax
}
f010442e:	5d                   	pop    %ebp
f010442f:	c3                   	ret    

f0104430 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104430:	55                   	push   %ebp
f0104431:	89 e5                	mov    %esp,%ebp
f0104433:	53                   	push   %ebx
f0104434:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010443a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010443d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104442:	85 d2                	test   %edx,%edx
f0104444:	74 28                	je     f010446e <strncmp+0x3e>
f0104446:	0f b6 01             	movzbl (%ecx),%eax
f0104449:	84 c0                	test   %al,%al
f010444b:	74 24                	je     f0104471 <strncmp+0x41>
f010444d:	3a 03                	cmp    (%ebx),%al
f010444f:	75 20                	jne    f0104471 <strncmp+0x41>
f0104451:	83 ea 01             	sub    $0x1,%edx
f0104454:	74 13                	je     f0104469 <strncmp+0x39>
		n--, p++, q++;
f0104456:	83 c1 01             	add    $0x1,%ecx
f0104459:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010445c:	0f b6 01             	movzbl (%ecx),%eax
f010445f:	84 c0                	test   %al,%al
f0104461:	74 0e                	je     f0104471 <strncmp+0x41>
f0104463:	3a 03                	cmp    (%ebx),%al
f0104465:	74 ea                	je     f0104451 <strncmp+0x21>
f0104467:	eb 08                	jmp    f0104471 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104469:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010446e:	5b                   	pop    %ebx
f010446f:	5d                   	pop    %ebp
f0104470:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104471:	0f b6 01             	movzbl (%ecx),%eax
f0104474:	0f b6 13             	movzbl (%ebx),%edx
f0104477:	29 d0                	sub    %edx,%eax
f0104479:	eb f3                	jmp    f010446e <strncmp+0x3e>

f010447b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010447b:	55                   	push   %ebp
f010447c:	89 e5                	mov    %esp,%ebp
f010447e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104481:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104485:	0f b6 10             	movzbl (%eax),%edx
f0104488:	84 d2                	test   %dl,%dl
f010448a:	74 1c                	je     f01044a8 <strchr+0x2d>
		if (*s == c)
f010448c:	38 ca                	cmp    %cl,%dl
f010448e:	75 09                	jne    f0104499 <strchr+0x1e>
f0104490:	eb 1b                	jmp    f01044ad <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104492:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0104495:	38 ca                	cmp    %cl,%dl
f0104497:	74 14                	je     f01044ad <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104499:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f010449d:	84 d2                	test   %dl,%dl
f010449f:	75 f1                	jne    f0104492 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f01044a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01044a6:	eb 05                	jmp    f01044ad <strchr+0x32>
f01044a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01044ad:	5d                   	pop    %ebp
f01044ae:	c3                   	ret    

f01044af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01044af:	55                   	push   %ebp
f01044b0:	89 e5                	mov    %esp,%ebp
f01044b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01044b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01044b9:	0f b6 10             	movzbl (%eax),%edx
f01044bc:	84 d2                	test   %dl,%dl
f01044be:	74 14                	je     f01044d4 <strfind+0x25>
		if (*s == c)
f01044c0:	38 ca                	cmp    %cl,%dl
f01044c2:	75 06                	jne    f01044ca <strfind+0x1b>
f01044c4:	eb 0e                	jmp    f01044d4 <strfind+0x25>
f01044c6:	38 ca                	cmp    %cl,%dl
f01044c8:	74 0a                	je     f01044d4 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01044ca:	83 c0 01             	add    $0x1,%eax
f01044cd:	0f b6 10             	movzbl (%eax),%edx
f01044d0:	84 d2                	test   %dl,%dl
f01044d2:	75 f2                	jne    f01044c6 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01044d4:	5d                   	pop    %ebp
f01044d5:	c3                   	ret    

f01044d6 <memset>:


void *
memset(void *v, int c, size_t n)
{
f01044d6:	55                   	push   %ebp
f01044d7:	89 e5                	mov    %esp,%ebp
f01044d9:	53                   	push   %ebx
f01044da:	8b 45 08             	mov    0x8(%ebp),%eax
f01044dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01044e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01044e3:	89 da                	mov    %ebx,%edx
f01044e5:	83 ea 01             	sub    $0x1,%edx
f01044e8:	78 0d                	js     f01044f7 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f01044ea:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f01044ec:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f01044ee:	88 0a                	mov    %cl,(%edx)
f01044f0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01044f3:	39 da                	cmp    %ebx,%edx
f01044f5:	75 f7                	jne    f01044ee <memset+0x18>
		*p++ = c;

	return v;
}
f01044f7:	5b                   	pop    %ebx
f01044f8:	5d                   	pop    %ebp
f01044f9:	c3                   	ret    

f01044fa <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f01044fa:	55                   	push   %ebp
f01044fb:	89 e5                	mov    %esp,%ebp
f01044fd:	57                   	push   %edi
f01044fe:	56                   	push   %esi
f01044ff:	53                   	push   %ebx
f0104500:	8b 45 08             	mov    0x8(%ebp),%eax
f0104503:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104506:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104509:	39 c6                	cmp    %eax,%esi
f010450b:	72 0b                	jb     f0104518 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f010450d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104512:	85 db                	test   %ebx,%ebx
f0104514:	75 29                	jne    f010453f <memmove+0x45>
f0104516:	eb 35                	jmp    f010454d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104518:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f010451b:	39 c8                	cmp    %ecx,%eax
f010451d:	73 ee                	jae    f010450d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f010451f:	85 db                	test   %ebx,%ebx
f0104521:	74 2a                	je     f010454d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0104523:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f0104526:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f0104528:	f7 db                	neg    %ebx
f010452a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f010452d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f010452f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0104534:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0104538:	83 ea 01             	sub    $0x1,%edx
f010453b:	75 f2                	jne    f010452f <memmove+0x35>
f010453d:	eb 0e                	jmp    f010454d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f010453f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0104543:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104546:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0104549:	39 d3                	cmp    %edx,%ebx
f010454b:	75 f2                	jne    f010453f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f010454d:	5b                   	pop    %ebx
f010454e:	5e                   	pop    %esi
f010454f:	5f                   	pop    %edi
f0104550:	5d                   	pop    %ebp
f0104551:	c3                   	ret    

f0104552 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0104552:	55                   	push   %ebp
f0104553:	89 e5                	mov    %esp,%ebp
f0104555:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104558:	8b 45 10             	mov    0x10(%ebp),%eax
f010455b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010455f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104562:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104566:	8b 45 08             	mov    0x8(%ebp),%eax
f0104569:	89 04 24             	mov    %eax,(%esp)
f010456c:	e8 89 ff ff ff       	call   f01044fa <memmove>
}
f0104571:	c9                   	leave  
f0104572:	c3                   	ret    

f0104573 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104573:	55                   	push   %ebp
f0104574:	89 e5                	mov    %esp,%ebp
f0104576:	57                   	push   %edi
f0104577:	56                   	push   %esi
f0104578:	53                   	push   %ebx
f0104579:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010457c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010457f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104582:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104587:	85 ff                	test   %edi,%edi
f0104589:	74 37                	je     f01045c2 <memcmp+0x4f>
		if (*s1 != *s2)
f010458b:	0f b6 03             	movzbl (%ebx),%eax
f010458e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104591:	83 ef 01             	sub    $0x1,%edi
f0104594:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0104599:	38 c8                	cmp    %cl,%al
f010459b:	74 1c                	je     f01045b9 <memcmp+0x46>
f010459d:	eb 10                	jmp    f01045af <memcmp+0x3c>
f010459f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f01045a4:	83 c2 01             	add    $0x1,%edx
f01045a7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01045ab:	38 c8                	cmp    %cl,%al
f01045ad:	74 0a                	je     f01045b9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f01045af:	0f b6 c0             	movzbl %al,%eax
f01045b2:	0f b6 c9             	movzbl %cl,%ecx
f01045b5:	29 c8                	sub    %ecx,%eax
f01045b7:	eb 09                	jmp    f01045c2 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01045b9:	39 fa                	cmp    %edi,%edx
f01045bb:	75 e2                	jne    f010459f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01045bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01045c2:	5b                   	pop    %ebx
f01045c3:	5e                   	pop    %esi
f01045c4:	5f                   	pop    %edi
f01045c5:	5d                   	pop    %ebp
f01045c6:	c3                   	ret    

f01045c7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01045c7:	55                   	push   %ebp
f01045c8:	89 e5                	mov    %esp,%ebp
f01045ca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01045cd:	89 c2                	mov    %eax,%edx
f01045cf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01045d2:	39 d0                	cmp    %edx,%eax
f01045d4:	73 15                	jae    f01045eb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01045d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01045da:	38 08                	cmp    %cl,(%eax)
f01045dc:	75 06                	jne    f01045e4 <memfind+0x1d>
f01045de:	eb 0b                	jmp    f01045eb <memfind+0x24>
f01045e0:	38 08                	cmp    %cl,(%eax)
f01045e2:	74 07                	je     f01045eb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01045e4:	83 c0 01             	add    $0x1,%eax
f01045e7:	39 d0                	cmp    %edx,%eax
f01045e9:	75 f5                	jne    f01045e0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01045eb:	5d                   	pop    %ebp
f01045ec:	c3                   	ret    

f01045ed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01045ed:	55                   	push   %ebp
f01045ee:	89 e5                	mov    %esp,%ebp
f01045f0:	57                   	push   %edi
f01045f1:	56                   	push   %esi
f01045f2:	53                   	push   %ebx
f01045f3:	8b 55 08             	mov    0x8(%ebp),%edx
f01045f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01045f9:	0f b6 02             	movzbl (%edx),%eax
f01045fc:	3c 20                	cmp    $0x20,%al
f01045fe:	74 04                	je     f0104604 <strtol+0x17>
f0104600:	3c 09                	cmp    $0x9,%al
f0104602:	75 0e                	jne    f0104612 <strtol+0x25>
		s++;
f0104604:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104607:	0f b6 02             	movzbl (%edx),%eax
f010460a:	3c 20                	cmp    $0x20,%al
f010460c:	74 f6                	je     f0104604 <strtol+0x17>
f010460e:	3c 09                	cmp    $0x9,%al
f0104610:	74 f2                	je     f0104604 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104612:	3c 2b                	cmp    $0x2b,%al
f0104614:	75 0a                	jne    f0104620 <strtol+0x33>
		s++;
f0104616:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104619:	bf 00 00 00 00       	mov    $0x0,%edi
f010461e:	eb 10                	jmp    f0104630 <strtol+0x43>
f0104620:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104625:	3c 2d                	cmp    $0x2d,%al
f0104627:	75 07                	jne    f0104630 <strtol+0x43>
		s++, neg = 1;
f0104629:	83 c2 01             	add    $0x1,%edx
f010462c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104630:	85 db                	test   %ebx,%ebx
f0104632:	0f 94 c0             	sete   %al
f0104635:	74 05                	je     f010463c <strtol+0x4f>
f0104637:	83 fb 10             	cmp    $0x10,%ebx
f010463a:	75 15                	jne    f0104651 <strtol+0x64>
f010463c:	80 3a 30             	cmpb   $0x30,(%edx)
f010463f:	75 10                	jne    f0104651 <strtol+0x64>
f0104641:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104645:	75 0a                	jne    f0104651 <strtol+0x64>
		s += 2, base = 16;
f0104647:	83 c2 02             	add    $0x2,%edx
f010464a:	bb 10 00 00 00       	mov    $0x10,%ebx
f010464f:	eb 13                	jmp    f0104664 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0104651:	84 c0                	test   %al,%al
f0104653:	74 0f                	je     f0104664 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104655:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010465a:	80 3a 30             	cmpb   $0x30,(%edx)
f010465d:	75 05                	jne    f0104664 <strtol+0x77>
		s++, base = 8;
f010465f:	83 c2 01             	add    $0x1,%edx
f0104662:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0104664:	b8 00 00 00 00       	mov    $0x0,%eax
f0104669:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010466b:	0f b6 0a             	movzbl (%edx),%ecx
f010466e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104671:	80 fb 09             	cmp    $0x9,%bl
f0104674:	77 08                	ja     f010467e <strtol+0x91>
			dig = *s - '0';
f0104676:	0f be c9             	movsbl %cl,%ecx
f0104679:	83 e9 30             	sub    $0x30,%ecx
f010467c:	eb 1e                	jmp    f010469c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f010467e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104681:	80 fb 19             	cmp    $0x19,%bl
f0104684:	77 08                	ja     f010468e <strtol+0xa1>
			dig = *s - 'a' + 10;
f0104686:	0f be c9             	movsbl %cl,%ecx
f0104689:	83 e9 57             	sub    $0x57,%ecx
f010468c:	eb 0e                	jmp    f010469c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f010468e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104691:	80 fb 19             	cmp    $0x19,%bl
f0104694:	77 14                	ja     f01046aa <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104696:	0f be c9             	movsbl %cl,%ecx
f0104699:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010469c:	39 f1                	cmp    %esi,%ecx
f010469e:	7d 0e                	jge    f01046ae <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01046a0:	83 c2 01             	add    $0x1,%edx
f01046a3:	0f af c6             	imul   %esi,%eax
f01046a6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01046a8:	eb c1                	jmp    f010466b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01046aa:	89 c1                	mov    %eax,%ecx
f01046ac:	eb 02                	jmp    f01046b0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01046ae:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01046b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01046b4:	74 05                	je     f01046bb <strtol+0xce>
		*endptr = (char *) s;
f01046b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01046b9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01046bb:	89 ca                	mov    %ecx,%edx
f01046bd:	f7 da                	neg    %edx
f01046bf:	85 ff                	test   %edi,%edi
f01046c1:	0f 45 c2             	cmovne %edx,%eax
}
f01046c4:	5b                   	pop    %ebx
f01046c5:	5e                   	pop    %esi
f01046c6:	5f                   	pop    %edi
f01046c7:	5d                   	pop    %ebp
f01046c8:	c3                   	ret    
f01046c9:	00 00                	add    %al,(%eax)
f01046cb:	00 00                	add    %al,(%eax)
f01046cd:	00 00                	add    %al,(%eax)
	...

f01046d0 <__udivdi3>:
f01046d0:	83 ec 1c             	sub    $0x1c,%esp
f01046d3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01046d7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f01046db:	8b 44 24 20          	mov    0x20(%esp),%eax
f01046df:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01046e3:	89 74 24 10          	mov    %esi,0x10(%esp)
f01046e7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01046eb:	85 ff                	test   %edi,%edi
f01046ed:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f01046f1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046f5:	89 cd                	mov    %ecx,%ebp
f01046f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046fb:	75 33                	jne    f0104730 <__udivdi3+0x60>
f01046fd:	39 f1                	cmp    %esi,%ecx
f01046ff:	77 57                	ja     f0104758 <__udivdi3+0x88>
f0104701:	85 c9                	test   %ecx,%ecx
f0104703:	75 0b                	jne    f0104710 <__udivdi3+0x40>
f0104705:	b8 01 00 00 00       	mov    $0x1,%eax
f010470a:	31 d2                	xor    %edx,%edx
f010470c:	f7 f1                	div    %ecx
f010470e:	89 c1                	mov    %eax,%ecx
f0104710:	89 f0                	mov    %esi,%eax
f0104712:	31 d2                	xor    %edx,%edx
f0104714:	f7 f1                	div    %ecx
f0104716:	89 c6                	mov    %eax,%esi
f0104718:	8b 44 24 04          	mov    0x4(%esp),%eax
f010471c:	f7 f1                	div    %ecx
f010471e:	89 f2                	mov    %esi,%edx
f0104720:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104724:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104728:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010472c:	83 c4 1c             	add    $0x1c,%esp
f010472f:	c3                   	ret    
f0104730:	31 d2                	xor    %edx,%edx
f0104732:	31 c0                	xor    %eax,%eax
f0104734:	39 f7                	cmp    %esi,%edi
f0104736:	77 e8                	ja     f0104720 <__udivdi3+0x50>
f0104738:	0f bd cf             	bsr    %edi,%ecx
f010473b:	83 f1 1f             	xor    $0x1f,%ecx
f010473e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104742:	75 2c                	jne    f0104770 <__udivdi3+0xa0>
f0104744:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0104748:	76 04                	jbe    f010474e <__udivdi3+0x7e>
f010474a:	39 f7                	cmp    %esi,%edi
f010474c:	73 d2                	jae    f0104720 <__udivdi3+0x50>
f010474e:	31 d2                	xor    %edx,%edx
f0104750:	b8 01 00 00 00       	mov    $0x1,%eax
f0104755:	eb c9                	jmp    f0104720 <__udivdi3+0x50>
f0104757:	90                   	nop
f0104758:	89 f2                	mov    %esi,%edx
f010475a:	f7 f1                	div    %ecx
f010475c:	31 d2                	xor    %edx,%edx
f010475e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104762:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104766:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010476a:	83 c4 1c             	add    $0x1c,%esp
f010476d:	c3                   	ret    
f010476e:	66 90                	xchg   %ax,%ax
f0104770:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104775:	b8 20 00 00 00       	mov    $0x20,%eax
f010477a:	89 ea                	mov    %ebp,%edx
f010477c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104780:	d3 e7                	shl    %cl,%edi
f0104782:	89 c1                	mov    %eax,%ecx
f0104784:	d3 ea                	shr    %cl,%edx
f0104786:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010478b:	09 fa                	or     %edi,%edx
f010478d:	89 f7                	mov    %esi,%edi
f010478f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104793:	89 f2                	mov    %esi,%edx
f0104795:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104799:	d3 e5                	shl    %cl,%ebp
f010479b:	89 c1                	mov    %eax,%ecx
f010479d:	d3 ef                	shr    %cl,%edi
f010479f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01047a4:	d3 e2                	shl    %cl,%edx
f01047a6:	89 c1                	mov    %eax,%ecx
f01047a8:	d3 ee                	shr    %cl,%esi
f01047aa:	09 d6                	or     %edx,%esi
f01047ac:	89 fa                	mov    %edi,%edx
f01047ae:	89 f0                	mov    %esi,%eax
f01047b0:	f7 74 24 0c          	divl   0xc(%esp)
f01047b4:	89 d7                	mov    %edx,%edi
f01047b6:	89 c6                	mov    %eax,%esi
f01047b8:	f7 e5                	mul    %ebp
f01047ba:	39 d7                	cmp    %edx,%edi
f01047bc:	72 22                	jb     f01047e0 <__udivdi3+0x110>
f01047be:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f01047c2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01047c7:	d3 e5                	shl    %cl,%ebp
f01047c9:	39 c5                	cmp    %eax,%ebp
f01047cb:	73 04                	jae    f01047d1 <__udivdi3+0x101>
f01047cd:	39 d7                	cmp    %edx,%edi
f01047cf:	74 0f                	je     f01047e0 <__udivdi3+0x110>
f01047d1:	89 f0                	mov    %esi,%eax
f01047d3:	31 d2                	xor    %edx,%edx
f01047d5:	e9 46 ff ff ff       	jmp    f0104720 <__udivdi3+0x50>
f01047da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01047e0:	8d 46 ff             	lea    -0x1(%esi),%eax
f01047e3:	31 d2                	xor    %edx,%edx
f01047e5:	8b 74 24 10          	mov    0x10(%esp),%esi
f01047e9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01047ed:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01047f1:	83 c4 1c             	add    $0x1c,%esp
f01047f4:	c3                   	ret    
	...

f0104800 <__umoddi3>:
f0104800:	83 ec 1c             	sub    $0x1c,%esp
f0104803:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104807:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010480b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010480f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104813:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104817:	8b 74 24 24          	mov    0x24(%esp),%esi
f010481b:	85 ed                	test   %ebp,%ebp
f010481d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104821:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104825:	89 cf                	mov    %ecx,%edi
f0104827:	89 04 24             	mov    %eax,(%esp)
f010482a:	89 f2                	mov    %esi,%edx
f010482c:	75 1a                	jne    f0104848 <__umoddi3+0x48>
f010482e:	39 f1                	cmp    %esi,%ecx
f0104830:	76 4e                	jbe    f0104880 <__umoddi3+0x80>
f0104832:	f7 f1                	div    %ecx
f0104834:	89 d0                	mov    %edx,%eax
f0104836:	31 d2                	xor    %edx,%edx
f0104838:	8b 74 24 10          	mov    0x10(%esp),%esi
f010483c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104840:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104844:	83 c4 1c             	add    $0x1c,%esp
f0104847:	c3                   	ret    
f0104848:	39 f5                	cmp    %esi,%ebp
f010484a:	77 54                	ja     f01048a0 <__umoddi3+0xa0>
f010484c:	0f bd c5             	bsr    %ebp,%eax
f010484f:	83 f0 1f             	xor    $0x1f,%eax
f0104852:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104856:	75 60                	jne    f01048b8 <__umoddi3+0xb8>
f0104858:	3b 0c 24             	cmp    (%esp),%ecx
f010485b:	0f 87 07 01 00 00    	ja     f0104968 <__umoddi3+0x168>
f0104861:	89 f2                	mov    %esi,%edx
f0104863:	8b 34 24             	mov    (%esp),%esi
f0104866:	29 ce                	sub    %ecx,%esi
f0104868:	19 ea                	sbb    %ebp,%edx
f010486a:	89 34 24             	mov    %esi,(%esp)
f010486d:	8b 04 24             	mov    (%esp),%eax
f0104870:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104874:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104878:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010487c:	83 c4 1c             	add    $0x1c,%esp
f010487f:	c3                   	ret    
f0104880:	85 c9                	test   %ecx,%ecx
f0104882:	75 0b                	jne    f010488f <__umoddi3+0x8f>
f0104884:	b8 01 00 00 00       	mov    $0x1,%eax
f0104889:	31 d2                	xor    %edx,%edx
f010488b:	f7 f1                	div    %ecx
f010488d:	89 c1                	mov    %eax,%ecx
f010488f:	89 f0                	mov    %esi,%eax
f0104891:	31 d2                	xor    %edx,%edx
f0104893:	f7 f1                	div    %ecx
f0104895:	8b 04 24             	mov    (%esp),%eax
f0104898:	f7 f1                	div    %ecx
f010489a:	eb 98                	jmp    f0104834 <__umoddi3+0x34>
f010489c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01048a0:	89 f2                	mov    %esi,%edx
f01048a2:	8b 74 24 10          	mov    0x10(%esp),%esi
f01048a6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01048aa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01048ae:	83 c4 1c             	add    $0x1c,%esp
f01048b1:	c3                   	ret    
f01048b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01048b8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01048bd:	89 e8                	mov    %ebp,%eax
f01048bf:	bd 20 00 00 00       	mov    $0x20,%ebp
f01048c4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01048c8:	89 fa                	mov    %edi,%edx
f01048ca:	d3 e0                	shl    %cl,%eax
f01048cc:	89 e9                	mov    %ebp,%ecx
f01048ce:	d3 ea                	shr    %cl,%edx
f01048d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01048d5:	09 c2                	or     %eax,%edx
f01048d7:	8b 44 24 08          	mov    0x8(%esp),%eax
f01048db:	89 14 24             	mov    %edx,(%esp)
f01048de:	89 f2                	mov    %esi,%edx
f01048e0:	d3 e7                	shl    %cl,%edi
f01048e2:	89 e9                	mov    %ebp,%ecx
f01048e4:	d3 ea                	shr    %cl,%edx
f01048e6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01048eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01048ef:	d3 e6                	shl    %cl,%esi
f01048f1:	89 e9                	mov    %ebp,%ecx
f01048f3:	d3 e8                	shr    %cl,%eax
f01048f5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01048fa:	09 f0                	or     %esi,%eax
f01048fc:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104900:	f7 34 24             	divl   (%esp)
f0104903:	d3 e6                	shl    %cl,%esi
f0104905:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104909:	89 d6                	mov    %edx,%esi
f010490b:	f7 e7                	mul    %edi
f010490d:	39 d6                	cmp    %edx,%esi
f010490f:	89 c1                	mov    %eax,%ecx
f0104911:	89 d7                	mov    %edx,%edi
f0104913:	72 3f                	jb     f0104954 <__umoddi3+0x154>
f0104915:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0104919:	72 35                	jb     f0104950 <__umoddi3+0x150>
f010491b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010491f:	29 c8                	sub    %ecx,%eax
f0104921:	19 fe                	sbb    %edi,%esi
f0104923:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104928:	89 f2                	mov    %esi,%edx
f010492a:	d3 e8                	shr    %cl,%eax
f010492c:	89 e9                	mov    %ebp,%ecx
f010492e:	d3 e2                	shl    %cl,%edx
f0104930:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104935:	09 d0                	or     %edx,%eax
f0104937:	89 f2                	mov    %esi,%edx
f0104939:	d3 ea                	shr    %cl,%edx
f010493b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010493f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104943:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104947:	83 c4 1c             	add    $0x1c,%esp
f010494a:	c3                   	ret    
f010494b:	90                   	nop
f010494c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104950:	39 d6                	cmp    %edx,%esi
f0104952:	75 c7                	jne    f010491b <__umoddi3+0x11b>
f0104954:	89 d7                	mov    %edx,%edi
f0104956:	89 c1                	mov    %eax,%ecx
f0104958:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010495c:	1b 3c 24             	sbb    (%esp),%edi
f010495f:	eb ba                	jmp    f010491b <__umoddi3+0x11b>
f0104961:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104968:	39 f5                	cmp    %esi,%ebp
f010496a:	0f 82 f1 fe ff ff    	jb     f0104861 <__umoddi3+0x61>
f0104970:	e9 f8 fe ff ff       	jmp    f010486d <__umoddi3+0x6d>
