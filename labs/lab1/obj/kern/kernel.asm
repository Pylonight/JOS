
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
f0100038:	e8 5d 00 00 00       	call   f010009a <i386_init>

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
f0100040:	53                   	push   %ebx
f0100041:	83 ec 18             	sub    $0x18,%esp
f0100044:	8b 5c 24 20          	mov    0x20(%esp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f0100048:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004c:	c7 04 24 a0 16 10 f0 	movl   $0xf01016a0,(%esp)
f0100053:	e8 ba 08 00 00       	call   f0100912 <cprintf>
	if (x > 0)
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 0d                	jle    f0100069 <test_backtrace+0x29>
		test_backtrace(x-1);
f010005c:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010005f:	89 04 24             	mov    %eax,(%esp)
f0100062:	e8 d9 ff ff ff       	call   f0100040 <test_backtrace>
f0100067:	eb 1c                	jmp    f0100085 <test_backtrace+0x45>
	else
		mon_backtrace(0, 0, 0);
f0100069:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100070:	00 
f0100071:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100078:	00 
f0100079:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100080:	e8 ef 06 00 00       	call   f0100774 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100085:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100089:	c7 04 24 bc 16 10 f0 	movl   $0xf01016bc,(%esp)
f0100090:	e8 7d 08 00 00       	call   f0100912 <cprintf>
}
f0100095:	83 c4 18             	add    $0x18,%esp
f0100098:	5b                   	pop    %ebx
f0100099:	c3                   	ret    

f010009a <i386_init>:

void
i386_init(void)
{
f010009a:	83 ec 1c             	sub    $0x1c,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009d:	b8 80 f9 10 f0       	mov    $0xf010f980,%eax
f01000a2:	2d 20 f3 10 f0       	sub    $0xf010f320,%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b2:	00 
f01000b3:	c7 04 24 20 f3 10 f0 	movl   $0xf010f320,(%esp)
f01000ba:	e8 0f 11 00 00       	call   f01011ce <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000bf:	e8 62 05 00 00       	call   f0100626 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000c4:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000cb:	00 
f01000cc:	c7 04 24 d7 16 10 f0 	movl   $0xf01016d7,(%esp)
f01000d3:	e8 3a 08 00 00       	call   f0100912 <cprintf>




	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000d8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000df:	e8 5c ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000eb:	e8 8a 06 00 00       	call   f010077a <monitor>
f01000f0:	eb f2                	jmp    f01000e4 <i386_init+0x4a>

f01000f2 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f2:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	if (panicstr)
f01000f5:	83 3d 20 f3 10 f0 00 	cmpl   $0x0,0xf010f320
f01000fc:	75 45                	jne    f0100143 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000fe:	8b 44 24 28          	mov    0x28(%esp),%eax
f0100102:	a3 20 f3 10 f0       	mov    %eax,0xf010f320

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100107:	8b 44 24 24          	mov    0x24(%esp),%eax
f010010b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010010f:	8b 44 24 20          	mov    0x20(%esp),%eax
f0100113:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100117:	c7 04 24 f2 16 10 f0 	movl   $0xf01016f2,(%esp)
f010011e:	e8 ef 07 00 00       	call   f0100912 <cprintf>
	vcprintf(fmt, ap);
f0100123:	8d 44 24 2c          	lea    0x2c(%esp),%eax
f0100127:	89 44 24 04          	mov    %eax,0x4(%esp)
f010012b:	8b 44 24 28          	mov    0x28(%esp),%eax
f010012f:	89 04 24             	mov    %eax,(%esp)
f0100132:	e8 a4 07 00 00       	call   f01008db <vcprintf>
	cprintf("\n");
f0100137:	c7 04 24 2e 17 10 f0 	movl   $0xf010172e,(%esp)
f010013e:	e8 cf 07 00 00       	call   f0100912 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100143:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010014a:	e8 2b 06 00 00       	call   f010077a <monitor>
f010014f:	eb f2                	jmp    f0100143 <_panic+0x51>

f0100151 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100151:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f0100154:	8b 44 24 24          	mov    0x24(%esp),%eax
f0100158:	89 44 24 08          	mov    %eax,0x8(%esp)
f010015c:	8b 44 24 20          	mov    0x20(%esp),%eax
f0100160:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100164:	c7 04 24 0a 17 10 f0 	movl   $0xf010170a,(%esp)
f010016b:	e8 a2 07 00 00       	call   f0100912 <cprintf>
	vcprintf(fmt, ap);
f0100170:	8d 44 24 2c          	lea    0x2c(%esp),%eax
f0100174:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100178:	8b 44 24 28          	mov    0x28(%esp),%eax
f010017c:	89 04 24             	mov    %eax,(%esp)
f010017f:	e8 57 07 00 00       	call   f01008db <vcprintf>
	cprintf("\n");
f0100184:	c7 04 24 2e 17 10 f0 	movl   $0xf010172e,(%esp)
f010018b:	e8 82 07 00 00       	call   f0100912 <cprintf>
	va_end(ap);
}
f0100190:	83 c4 1c             	add    $0x1c,%esp
f0100193:	c3                   	ret    
	...

f01001a0 <serial_proc_data>:

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a5:	ec                   	in     (%dx),%al

int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001a6:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001ab:	a8 01                	test   $0x1,%al
f01001ad:	74 06                	je     f01001b5 <serial_proc_data+0x15>
f01001af:	b2 f8                	mov    $0xf8,%dl
f01001b1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001b2:	0f b6 c8             	movzbl %al,%ecx
}
f01001b5:	89 c8                	mov    %ecx,%eax
f01001b7:	c3                   	ret    

f01001b8 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001b8:	53                   	push   %ebx
f01001b9:	83 ec 18             	sub    $0x18,%esp
f01001bc:	ba 64 00 00 00       	mov    $0x64,%edx
f01001c1:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01001c2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001c7:	a8 01                	test   $0x1,%al
f01001c9:	0f 84 de 00 00 00    	je     f01002ad <kbd_proc_data+0xf5>
f01001cf:	b2 60                	mov    $0x60,%dl
f01001d1:	ec                   	in     (%dx),%al
f01001d2:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001d4:	3c e0                	cmp    $0xe0,%al
f01001d6:	75 11                	jne    f01001e9 <kbd_proc_data+0x31>
		// E0 escape character
		shift |= E0ESC;
f01001d8:	83 0d 50 f3 10 f0 40 	orl    $0x40,0xf010f350
		return 0;
f01001df:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001e4:	e9 c4 00 00 00       	jmp    f01002ad <kbd_proc_data+0xf5>
	} else if (data & 0x80) {
f01001e9:	84 c0                	test   %al,%al
f01001eb:	79 37                	jns    f0100224 <kbd_proc_data+0x6c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ed:	8b 0d 50 f3 10 f0    	mov    0xf010f350,%ecx
f01001f3:	89 cb                	mov    %ecx,%ebx
f01001f5:	83 e3 40             	and    $0x40,%ebx
f01001f8:	83 e0 7f             	and    $0x7f,%eax
f01001fb:	85 db                	test   %ebx,%ebx
f01001fd:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100200:	0f b6 d2             	movzbl %dl,%edx
f0100203:	0f b6 82 60 17 10 f0 	movzbl -0xfefe8a0(%edx),%eax
f010020a:	83 c8 40             	or     $0x40,%eax
f010020d:	0f b6 c0             	movzbl %al,%eax
f0100210:	f7 d0                	not    %eax
f0100212:	21 c1                	and    %eax,%ecx
f0100214:	89 0d 50 f3 10 f0    	mov    %ecx,0xf010f350
		return 0;
f010021a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010021f:	e9 89 00 00 00       	jmp    f01002ad <kbd_proc_data+0xf5>
	} else if (shift & E0ESC) {
f0100224:	8b 0d 50 f3 10 f0    	mov    0xf010f350,%ecx
f010022a:	f6 c1 40             	test   $0x40,%cl
f010022d:	74 0e                	je     f010023d <kbd_proc_data+0x85>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010022f:	89 c2                	mov    %eax,%edx
f0100231:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100234:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100237:	89 0d 50 f3 10 f0    	mov    %ecx,0xf010f350
	}

	shift |= shiftcode[data];
f010023d:	0f b6 d2             	movzbl %dl,%edx
f0100240:	0f b6 82 60 17 10 f0 	movzbl -0xfefe8a0(%edx),%eax
f0100247:	0b 05 50 f3 10 f0    	or     0xf010f350,%eax
	shift ^= togglecode[data];
f010024d:	0f b6 8a 60 18 10 f0 	movzbl -0xfefe7a0(%edx),%ecx
f0100254:	31 c8                	xor    %ecx,%eax
f0100256:	a3 50 f3 10 f0       	mov    %eax,0xf010f350

	c = charcode[shift & (CTL | SHIFT)][data];
f010025b:	89 c1                	mov    %eax,%ecx
f010025d:	83 e1 03             	and    $0x3,%ecx
f0100260:	8b 0c 8d 60 19 10 f0 	mov    -0xfefe6a0(,%ecx,4),%ecx
f0100267:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010026b:	a8 08                	test   $0x8,%al
f010026d:	74 19                	je     f0100288 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f010026f:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100272:	83 fa 19             	cmp    $0x19,%edx
f0100275:	77 05                	ja     f010027c <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f0100277:	83 eb 20             	sub    $0x20,%ebx
f010027a:	eb 0c                	jmp    f0100288 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f010027c:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f010027f:	8d 53 20             	lea    0x20(%ebx),%edx
f0100282:	83 f9 19             	cmp    $0x19,%ecx
f0100285:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100288:	f7 d0                	not    %eax
f010028a:	a8 06                	test   $0x6,%al
f010028c:	75 1f                	jne    f01002ad <kbd_proc_data+0xf5>
f010028e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100294:	75 17                	jne    f01002ad <kbd_proc_data+0xf5>
		cprintf("Rebooting!\n");
f0100296:	c7 04 24 24 17 10 f0 	movl   $0xf0101724,(%esp)
f010029d:	e8 70 06 00 00       	call   f0100912 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002a2:	ba 92 00 00 00       	mov    $0x92,%edx
f01002a7:	b8 03 00 00 00       	mov    $0x3,%eax
f01002ac:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002ad:	89 d8                	mov    %ebx,%eax
f01002af:	83 c4 18             	add    $0x18,%esp
f01002b2:	5b                   	pop    %ebx
f01002b3:	c3                   	ret    

f01002b4 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f01002b4:	53                   	push   %ebx
f01002b5:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01002ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01002bf:	89 da                	mov    %ebx,%edx
f01002c1:	ee                   	out    %al,(%dx)
f01002c2:	b2 fb                	mov    $0xfb,%dl
f01002c4:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01002c9:	ee                   	out    %al,(%dx)
f01002ca:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01002cf:	b8 0c 00 00 00       	mov    $0xc,%eax
f01002d4:	89 ca                	mov    %ecx,%edx
f01002d6:	ee                   	out    %al,(%dx)
f01002d7:	b2 f9                	mov    $0xf9,%dl
f01002d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01002de:	ee                   	out    %al,(%dx)
f01002df:	b2 fb                	mov    $0xfb,%dl
f01002e1:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e6:	ee                   	out    %al,(%dx)
f01002e7:	b2 fc                	mov    $0xfc,%dl
f01002e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01002ee:	ee                   	out    %al,(%dx)
f01002ef:	b2 f9                	mov    $0xf9,%dl
f01002f1:	b8 01 00 00 00       	mov    $0x1,%eax
f01002f6:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f7:	b2 fd                	mov    $0xfd,%dl
f01002f9:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01002fa:	3c ff                	cmp    $0xff,%al
f01002fc:	0f 95 c0             	setne  %al
f01002ff:	0f b6 c0             	movzbl %al,%eax
f0100302:	a3 40 f3 10 f0       	mov    %eax,0xf010f340
f0100307:	89 da                	mov    %ebx,%edx
f0100309:	ec                   	in     (%dx),%al
f010030a:	89 ca                	mov    %ecx,%edx
f010030c:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010030d:	5b                   	pop    %ebx
f010030e:	c3                   	ret    

f010030f <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010030f:	83 ec 0c             	sub    $0xc,%esp
f0100312:	89 1c 24             	mov    %ebx,(%esp)
f0100315:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100319:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010031d:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100324:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010032b:	5a a5 
	if (*cp != 0xA55A) {
f010032d:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100334:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100338:	74 11                	je     f010034b <cga_init+0x3c>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010033a:	c7 05 44 f3 10 f0 b4 	movl   $0x3b4,0xf010f344
f0100341:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100344:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100349:	eb 16                	jmp    f0100361 <cga_init+0x52>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010034b:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100352:	c7 05 44 f3 10 f0 d4 	movl   $0x3d4,0xf010f344
f0100359:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010035c:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100361:	8b 0d 44 f3 10 f0    	mov    0xf010f344,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100367:	b8 0e 00 00 00       	mov    $0xe,%eax
f010036c:	89 ca                	mov    %ecx,%edx
f010036e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010036f:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100372:	89 da                	mov    %ebx,%edx
f0100374:	ec                   	in     (%dx),%al
f0100375:	0f b6 f8             	movzbl %al,%edi
f0100378:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100380:	89 ca                	mov    %ecx,%edx
f0100382:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100383:	89 da                	mov    %ebx,%edx
f0100385:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100386:	89 35 48 f3 10 f0    	mov    %esi,0xf010f348
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010038c:	0f b6 d8             	movzbl %al,%ebx
f010038f:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100391:	66 89 3d 4c f3 10 f0 	mov    %di,0xf010f34c
}
f0100398:	8b 1c 24             	mov    (%esp),%ebx
f010039b:	8b 74 24 04          	mov    0x4(%esp),%esi
f010039f:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01003a3:	83 c4 0c             	add    $0xc,%esp
f01003a6:	c3                   	ret    

f01003a7 <kbd_init>:
}

void
kbd_init(void)
{
}
f01003a7:	f3 c3                	repz ret 

f01003a9 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01003a9:	53                   	push   %ebx
f01003aa:	83 ec 08             	sub    $0x8,%esp
f01003ad:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01003b1:	eb 25                	jmp    f01003d8 <cons_intr+0x2f>
		if (c == 0)
f01003b3:	85 c0                	test   %eax,%eax
f01003b5:	74 21                	je     f01003d8 <cons_intr+0x2f>
			continue;
		cons.buf[cons.wpos++] = c;
f01003b7:	8b 15 64 f5 10 f0    	mov    0xf010f564,%edx
f01003bd:	88 82 60 f3 10 f0    	mov    %al,-0xfef0ca0(%edx)
f01003c3:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01003c6:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01003cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01003d0:	0f 44 c2             	cmove  %edx,%eax
f01003d3:	a3 64 f5 10 f0       	mov    %eax,0xf010f564
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01003d8:	ff d3                	call   *%ebx
f01003da:	83 f8 ff             	cmp    $0xffffffff,%eax
f01003dd:	75 d4                	jne    f01003b3 <cons_intr+0xa>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01003df:	83 c4 08             	add    $0x8,%esp
f01003e2:	5b                   	pop    %ebx
f01003e3:	c3                   	ret    

f01003e4 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01003e4:	83 ec 1c             	sub    $0x1c,%esp
	cons_intr(kbd_proc_data);
f01003e7:	c7 04 24 b8 01 10 f0 	movl   $0xf01001b8,(%esp)
f01003ee:	e8 b6 ff ff ff       	call   f01003a9 <cons_intr>
}
f01003f3:	83 c4 1c             	add    $0x1c,%esp
f01003f6:	c3                   	ret    

f01003f7 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01003f7:	83 ec 1c             	sub    $0x1c,%esp
	if (serial_exists)
f01003fa:	83 3d 40 f3 10 f0 00 	cmpl   $0x0,0xf010f340
f0100401:	74 0c                	je     f010040f <serial_intr+0x18>
		cons_intr(serial_proc_data);
f0100403:	c7 04 24 a0 01 10 f0 	movl   $0xf01001a0,(%esp)
f010040a:	e8 9a ff ff ff       	call   f01003a9 <cons_intr>
}
f010040f:	83 c4 1c             	add    $0x1c,%esp
f0100412:	c3                   	ret    

f0100413 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100413:	83 ec 0c             	sub    $0xc,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100416:	e8 dc ff ff ff       	call   f01003f7 <serial_intr>
	kbd_intr();
f010041b:	e8 c4 ff ff ff       	call   f01003e4 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100420:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100426:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010042b:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f0100431:	74 1e                	je     f0100451 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f0100433:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f010043a:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f010043d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100443:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100448:	0f 44 d1             	cmove  %ecx,%edx
f010044b:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f0100451:	83 c4 0c             	add    $0xc,%esp
f0100454:	c3                   	ret    

f0100455 <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f0100455:	57                   	push   %edi
f0100456:	56                   	push   %esi
f0100457:	53                   	push   %ebx
f0100458:	83 ec 10             	sub    $0x10,%esp
f010045b:	8b 7c 24 20          	mov    0x20(%esp),%edi
f010045f:	ba 79 03 00 00       	mov    $0x379,%edx
f0100464:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100465:	84 c0                	test   %al,%al
f0100467:	78 21                	js     f010048a <cons_putc+0x35>
f0100469:	bb 00 32 00 00       	mov    $0x3200,%ebx
f010046e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100473:	be 79 03 00 00       	mov    $0x379,%esi
f0100478:	89 ca                	mov    %ecx,%edx
f010047a:	ec                   	in     (%dx),%al
f010047b:	ec                   	in     (%dx),%al
f010047c:	ec                   	in     (%dx),%al
f010047d:	ec                   	in     (%dx),%al
f010047e:	89 f2                	mov    %esi,%edx
f0100480:	ec                   	in     (%dx),%al
f0100481:	84 c0                	test   %al,%al
f0100483:	78 05                	js     f010048a <cons_putc+0x35>
f0100485:	83 eb 01             	sub    $0x1,%ebx
f0100488:	75 ee                	jne    f0100478 <cons_putc+0x23>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010048a:	ba 78 03 00 00       	mov    $0x378,%edx
f010048f:	89 f8                	mov    %edi,%eax
f0100491:	ee                   	out    %al,(%dx)
f0100492:	b2 7a                	mov    $0x7a,%dl
f0100494:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100499:	ee                   	out    %al,(%dx)
f010049a:	b8 08 00 00 00       	mov    $0x8,%eax
f010049f:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f01004a0:	89 3c 24             	mov    %edi,(%esp)
f01004a3:	e8 07 00 00 00       	call   f01004af <cga_putc>
}
f01004a8:	83 c4 10             	add    $0x10,%esp
f01004ab:	5b                   	pop    %ebx
f01004ac:	5e                   	pop    %esi
f01004ad:	5f                   	pop    %edi
f01004ae:	c3                   	ret    

f01004af <cga_putc>:



void
cga_putc(int c)
{
f01004af:	56                   	push   %esi
f01004b0:	53                   	push   %ebx
f01004b1:	83 ec 14             	sub    $0x14,%esp
f01004b4:	8b 44 24 20          	mov    0x20(%esp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004b8:	89 c1                	mov    %eax,%ecx
f01004ba:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0700;
f01004c0:	89 c2                	mov    %eax,%edx
f01004c2:	80 ce 07             	or     $0x7,%dh
f01004c5:	85 c9                	test   %ecx,%ecx
f01004c7:	0f 44 c2             	cmove  %edx,%eax

	switch (c & 0xff) {
f01004ca:	0f b6 d0             	movzbl %al,%edx
f01004cd:	83 fa 09             	cmp    $0x9,%edx
f01004d0:	74 77                	je     f0100549 <cga_putc+0x9a>
f01004d2:	83 fa 09             	cmp    $0x9,%edx
f01004d5:	7f 0b                	jg     f01004e2 <cga_putc+0x33>
f01004d7:	83 fa 08             	cmp    $0x8,%edx
f01004da:	0f 85 a7 00 00 00    	jne    f0100587 <cga_putc+0xd8>
f01004e0:	eb 10                	jmp    f01004f2 <cga_putc+0x43>
f01004e2:	83 fa 0a             	cmp    $0xa,%edx
f01004e5:	74 3c                	je     f0100523 <cga_putc+0x74>
f01004e7:	83 fa 0d             	cmp    $0xd,%edx
f01004ea:	0f 85 97 00 00 00    	jne    f0100587 <cga_putc+0xd8>
f01004f0:	eb 39                	jmp    f010052b <cga_putc+0x7c>
	case '\b':
		if (crt_pos > 0) {
f01004f2:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f01004f9:	66 85 d2             	test   %dx,%dx
f01004fc:	0f 84 f0 00 00 00    	je     f01005f2 <cga_putc+0x143>
			crt_pos--;
f0100502:	83 ea 01             	sub    $0x1,%edx
f0100505:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010050c:	0f b7 d2             	movzwl %dx,%edx
f010050f:	b0 00                	mov    $0x0,%al
f0100511:	83 c8 20             	or     $0x20,%eax
f0100514:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010051a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010051e:	e9 82 00 00 00       	jmp    f01005a5 <cga_putc+0xf6>
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
f0100547:	eb 5c                	jmp    f01005a5 <cga_putc+0xf6>
	case '\t':
		cons_putc(' ');
f0100549:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100550:	e8 00 ff ff ff       	call   f0100455 <cons_putc>
		cons_putc(' ');
f0100555:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010055c:	e8 f4 fe ff ff       	call   f0100455 <cons_putc>
		cons_putc(' ');
f0100561:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100568:	e8 e8 fe ff ff       	call   f0100455 <cons_putc>
		cons_putc(' ');
f010056d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100574:	e8 dc fe ff ff       	call   f0100455 <cons_putc>
		cons_putc(' ');
f0100579:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100580:	e8 d0 fe ff ff       	call   f0100455 <cons_putc>
		break;
f0100585:	eb 1e                	jmp    f01005a5 <cga_putc+0xf6>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100587:	0f b7 15 4c f3 10 f0 	movzwl 0xf010f34c,%edx
f010058e:	0f b7 da             	movzwl %dx,%ebx
f0100591:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f0100597:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010059b:	83 c2 01             	add    $0x1,%edx
f010059e:	66 89 15 4c f3 10 f0 	mov    %dx,0xf010f34c
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005a5:	66 81 3d 4c f3 10 f0 	cmpw   $0x7cf,0xf010f34c
f01005ac:	cf 07 
f01005ae:	76 42                	jbe    f01005f2 <cga_putc+0x143>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005b0:	a1 48 f3 10 f0       	mov    0xf010f348,%eax
f01005b5:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005bc:	00 
f01005bd:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005c3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005c7:	89 04 24             	mov    %eax,(%esp)
f01005ca:	e8 22 0c 00 00       	call   f01011f1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005cf:	8b 15 48 f3 10 f0    	mov    0xf010f348,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d5:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005da:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005e0:	83 c0 01             	add    $0x1,%eax
f01005e3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005e8:	75 f0                	jne    f01005da <cga_putc+0x12b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005ea:	66 83 2d 4c f3 10 f0 	subw   $0x50,0xf010f34c
f01005f1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005f2:	8b 0d 44 f3 10 f0    	mov    0xf010f344,%ecx
f01005f8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005fd:	89 ca                	mov    %ecx,%edx
f01005ff:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100600:	0f b7 1d 4c f3 10 f0 	movzwl 0xf010f34c,%ebx
f0100607:	8d 71 01             	lea    0x1(%ecx),%esi
f010060a:	89 d8                	mov    %ebx,%eax
f010060c:	66 c1 e8 08          	shr    $0x8,%ax
f0100610:	89 f2                	mov    %esi,%edx
f0100612:	ee                   	out    %al,(%dx)
f0100613:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100618:	89 ca                	mov    %ecx,%edx
f010061a:	ee                   	out    %al,(%dx)
f010061b:	89 d8                	mov    %ebx,%eax
f010061d:	89 f2                	mov    %esi,%edx
f010061f:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100620:	83 c4 14             	add    $0x14,%esp
f0100623:	5b                   	pop    %ebx
f0100624:	5e                   	pop    %esi
f0100625:	c3                   	ret    

f0100626 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100626:	83 ec 1c             	sub    $0x1c,%esp
	cga_init();
f0100629:	e8 e1 fc ff ff       	call   f010030f <cga_init>
	kbd_init();
	serial_init();
f010062e:	e8 81 fc ff ff       	call   f01002b4 <serial_init>

	if (!serial_exists)
f0100633:	83 3d 40 f3 10 f0 00 	cmpl   $0x0,0xf010f340
f010063a:	75 0c                	jne    f0100648 <cons_init+0x22>
		cprintf("Serial port does not exist!\n");
f010063c:	c7 04 24 30 17 10 f0 	movl   $0xf0101730,(%esp)
f0100643:	e8 ca 02 00 00       	call   f0100912 <cprintf>
}
f0100648:	83 c4 1c             	add    $0x1c,%esp
f010064b:	c3                   	ret    

f010064c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010064c:	83 ec 1c             	sub    $0x1c,%esp
	cons_putc(c);
f010064f:	8b 44 24 20          	mov    0x20(%esp),%eax
f0100653:	89 04 24             	mov    %eax,(%esp)
f0100656:	e8 fa fd ff ff       	call   f0100455 <cons_putc>
}
f010065b:	83 c4 1c             	add    $0x1c,%esp
f010065e:	c3                   	ret    

f010065f <getchar>:

int
getchar(void)
{
f010065f:	83 ec 0c             	sub    $0xc,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100662:	e8 ac fd ff ff       	call   f0100413 <cons_getc>
f0100667:	85 c0                	test   %eax,%eax
f0100669:	74 f7                	je     f0100662 <getchar+0x3>
		/* do nothing */;
	return c;
}
f010066b:	83 c4 0c             	add    $0xc,%esp
f010066e:	c3                   	ret    

f010066f <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010066f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100674:	c3                   	ret    
	...

f0100680 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100680:	83 ec 1c             	sub    $0x1c,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100683:	c7 04 24 70 19 10 f0 	movl   $0xf0101970,(%esp)
f010068a:	e8 83 02 00 00       	call   f0100912 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f010068f:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100696:	00 
f0100697:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069e:	f0 
f010069f:	c7 04 24 fc 19 10 f0 	movl   $0xf01019fc,(%esp)
f01006a6:	e8 67 02 00 00       	call   f0100912 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ab:	c7 44 24 08 85 16 10 	movl   $0x101685,0x8(%esp)
f01006b2:	00 
f01006b3:	c7 44 24 04 85 16 10 	movl   $0xf0101685,0x4(%esp)
f01006ba:	f0 
f01006bb:	c7 04 24 20 1a 10 f0 	movl   $0xf0101a20,(%esp)
f01006c2:	e8 4b 02 00 00       	call   f0100912 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c7:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f01006ce:	00 
f01006cf:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f01006d6:	f0 
f01006d7:	c7 04 24 44 1a 10 f0 	movl   $0xf0101a44,(%esp)
f01006de:	e8 2f 02 00 00       	call   f0100912 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e3:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f01006ea:	00 
f01006eb:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f01006f2:	f0 
f01006f3:	c7 04 24 68 1a 10 f0 	movl   $0xf0101a68,(%esp)
f01006fa:	e8 13 02 00 00       	call   f0100912 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f01006ff:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f0100704:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100709:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010070f:	85 c0                	test   %eax,%eax
f0100711:	0f 48 c2             	cmovs  %edx,%eax
f0100714:	c1 f8 0a             	sar    $0xa,%eax
f0100717:	89 44 24 04          	mov    %eax,0x4(%esp)
f010071b:	c7 04 24 8c 1a 10 f0 	movl   $0xf0101a8c,(%esp)
f0100722:	e8 eb 01 00 00       	call   f0100912 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f0100727:	b8 00 00 00 00       	mov    $0x0,%eax
f010072c:	83 c4 1c             	add    $0x1c,%esp
f010072f:	c3                   	ret    

f0100730 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100730:	83 ec 1c             	sub    $0x1c,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100733:	c7 44 24 08 89 19 10 	movl   $0xf0101989,0x8(%esp)
f010073a:	f0 
f010073b:	c7 44 24 04 a7 19 10 	movl   $0xf01019a7,0x4(%esp)
f0100742:	f0 
f0100743:	c7 04 24 ac 19 10 f0 	movl   $0xf01019ac,(%esp)
f010074a:	e8 c3 01 00 00       	call   f0100912 <cprintf>
f010074f:	c7 44 24 08 b8 1a 10 	movl   $0xf0101ab8,0x8(%esp)
f0100756:	f0 
f0100757:	c7 44 24 04 b5 19 10 	movl   $0xf01019b5,0x4(%esp)
f010075e:	f0 
f010075f:	c7 04 24 ac 19 10 f0 	movl   $0xf01019ac,(%esp)
f0100766:	e8 a7 01 00 00       	call   f0100912 <cprintf>
	return 0;
}
f010076b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100770:	83 c4 1c             	add    $0x1c,%esp
f0100773:	c3                   	ret    

f0100774 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
f0100774:	b8 00 00 00 00       	mov    $0x0,%eax
f0100779:	c3                   	ret    

f010077a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010077a:	57                   	push   %edi
f010077b:	56                   	push   %esi
f010077c:	53                   	push   %ebx
f010077d:	83 ec 50             	sub    $0x50,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100780:	c7 04 24 e0 1a 10 f0 	movl   $0xf0101ae0,(%esp)
f0100787:	e8 86 01 00 00       	call   f0100912 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010078c:	c7 04 24 04 1b 10 f0 	movl   $0xf0101b04,(%esp)
f0100793:	e8 7a 01 00 00       	call   f0100912 <cprintf>
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f0100798:	8d 7c 24 10          	lea    0x10(%esp),%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f010079c:	c7 04 24 be 19 10 f0 	movl   $0xf01019be,(%esp)
f01007a3:	e8 b8 07 00 00       	call   f0100f60 <readline>
f01007a8:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007aa:	85 c0                	test   %eax,%eax
f01007ac:	74 ee                	je     f010079c <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007ae:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
f01007b5:	00 
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007b6:	be 00 00 00 00       	mov    $0x0,%esi
f01007bb:	eb 06                	jmp    f01007c3 <monitor+0x49>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007bd:	c6 03 00             	movb   $0x0,(%ebx)
f01007c0:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007c3:	0f b6 03             	movzbl (%ebx),%eax
f01007c6:	84 c0                	test   %al,%al
f01007c8:	74 6a                	je     f0100834 <monitor+0xba>
f01007ca:	0f be c0             	movsbl %al,%eax
f01007cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007d1:	c7 04 24 c2 19 10 f0 	movl   $0xf01019c2,(%esp)
f01007d8:	e8 93 09 00 00       	call   f0101170 <strchr>
f01007dd:	85 c0                	test   %eax,%eax
f01007df:	75 dc                	jne    f01007bd <monitor+0x43>
			*buf++ = 0;
		if (*buf == 0)
f01007e1:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007e4:	74 4e                	je     f0100834 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007e6:	83 fe 0f             	cmp    $0xf,%esi
f01007e9:	75 16                	jne    f0100801 <monitor+0x87>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007eb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007f2:	00 
f01007f3:	c7 04 24 c7 19 10 f0 	movl   $0xf01019c7,(%esp)
f01007fa:	e8 13 01 00 00       	call   f0100912 <cprintf>
f01007ff:	eb 9b                	jmp    f010079c <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100801:	89 5c b4 10          	mov    %ebx,0x10(%esp,%esi,4)
f0100805:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100808:	0f b6 03             	movzbl (%ebx),%eax
f010080b:	84 c0                	test   %al,%al
f010080d:	75 0c                	jne    f010081b <monitor+0xa1>
f010080f:	eb b2                	jmp    f01007c3 <monitor+0x49>
			buf++;
f0100811:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100814:	0f b6 03             	movzbl (%ebx),%eax
f0100817:	84 c0                	test   %al,%al
f0100819:	74 a8                	je     f01007c3 <monitor+0x49>
f010081b:	0f be c0             	movsbl %al,%eax
f010081e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100822:	c7 04 24 c2 19 10 f0 	movl   $0xf01019c2,(%esp)
f0100829:	e8 42 09 00 00       	call   f0101170 <strchr>
f010082e:	85 c0                	test   %eax,%eax
f0100830:	74 df                	je     f0100811 <monitor+0x97>
f0100832:	eb 8f                	jmp    f01007c3 <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f0100834:	c7 44 b4 10 00 00 00 	movl   $0x0,0x10(%esp,%esi,4)
f010083b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010083c:	85 f6                	test   %esi,%esi
f010083e:	0f 84 58 ff ff ff    	je     f010079c <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100844:	c7 44 24 04 a7 19 10 	movl   $0xf01019a7,0x4(%esp)
f010084b:	f0 
f010084c:	8b 44 24 10          	mov    0x10(%esp),%eax
f0100850:	89 04 24             	mov    %eax,(%esp)
f0100853:	e8 a0 08 00 00       	call   f01010f8 <strcmp>
f0100858:	ba 00 00 00 00       	mov    $0x0,%edx
f010085d:	85 c0                	test   %eax,%eax
f010085f:	74 1d                	je     f010087e <monitor+0x104>
f0100861:	c7 44 24 04 b5 19 10 	movl   $0xf01019b5,0x4(%esp)
f0100868:	f0 
f0100869:	8b 44 24 10          	mov    0x10(%esp),%eax
f010086d:	89 04 24             	mov    %eax,(%esp)
f0100870:	e8 83 08 00 00       	call   f01010f8 <strcmp>
f0100875:	85 c0                	test   %eax,%eax
f0100877:	75 29                	jne    f01008a2 <monitor+0x128>
f0100879:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f010087e:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0100881:	01 c2                	add    %eax,%edx
f0100883:	8b 44 24 60          	mov    0x60(%esp),%eax
f0100887:	89 44 24 08          	mov    %eax,0x8(%esp)
f010088b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010088f:	89 34 24             	mov    %esi,(%esp)
f0100892:	ff 14 95 34 1b 10 f0 	call   *-0xfefe4cc(,%edx,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100899:	85 c0                	test   %eax,%eax
f010089b:	78 1e                	js     f01008bb <monitor+0x141>
f010089d:	e9 fa fe ff ff       	jmp    f010079c <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008a2:	8b 44 24 10          	mov    0x10(%esp),%eax
f01008a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008aa:	c7 04 24 e4 19 10 f0 	movl   $0xf01019e4,(%esp)
f01008b1:	e8 5c 00 00 00       	call   f0100912 <cprintf>
f01008b6:	e9 e1 fe ff ff       	jmp    f010079c <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008bb:	83 c4 50             	add    $0x50,%esp
f01008be:	5b                   	pop    %ebx
f01008bf:	5e                   	pop    %esi
f01008c0:	5f                   	pop    %edi
f01008c1:	c3                   	ret    

f01008c2 <read_eip>:
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01008c2:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01008c5:	c3                   	ret    
	...

f01008c8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008c8:	83 ec 1c             	sub    $0x1c,%esp
	cputchar(ch);
f01008cb:	8b 44 24 20          	mov    0x20(%esp),%eax
f01008cf:	89 04 24             	mov    %eax,(%esp)
f01008d2:	e8 75 fd ff ff       	call   f010064c <cputchar>
	*cnt++;
}
f01008d7:	83 c4 1c             	add    $0x1c,%esp
f01008da:	c3                   	ret    

f01008db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008db:	83 ec 2c             	sub    $0x2c,%esp
	int cnt = 0;
f01008de:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f01008e5:	00 

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008e6:	8b 44 24 34          	mov    0x34(%esp),%eax
f01008ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008ee:	8b 44 24 30          	mov    0x30(%esp),%eax
f01008f2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008f6:	8d 44 24 1c          	lea    0x1c(%esp),%eax
f01008fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008fe:	c7 04 24 c8 08 10 f0 	movl   $0xf01008c8,(%esp)
f0100905:	e8 85 01 00 00       	call   f0100a8f <vprintfmt>
	return cnt;
}
f010090a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010090e:	83 c4 2c             	add    $0x2c,%esp
f0100911:	c3                   	ret    

f0100912 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100912:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100915:	8d 44 24 24          	lea    0x24(%esp),%eax
f0100919:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091d:	8b 44 24 20          	mov    0x20(%esp),%eax
f0100921:	89 04 24             	mov    %eax,(%esp)
f0100924:	e8 b2 ff ff ff       	call   f01008db <vcprintf>
	va_end(ap);

	return cnt;
}
f0100929:	83 c4 1c             	add    $0x1c,%esp
f010092c:	c3                   	ret    
f010092d:	00 00                	add    %al,(%eax)
	...

f0100930 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100930:	55                   	push   %ebp
f0100931:	57                   	push   %edi
f0100932:	56                   	push   %esi
f0100933:	53                   	push   %ebx
f0100934:	83 ec 3c             	sub    $0x3c,%esp
f0100937:	89 c5                	mov    %eax,%ebp
f0100939:	89 d7                	mov    %edx,%edi
f010093b:	8b 44 24 50          	mov    0x50(%esp),%eax
f010093f:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100943:	8b 44 24 54          	mov    0x54(%esp),%eax
f0100947:	89 44 24 28          	mov    %eax,0x28(%esp)
f010094b:	8b 5c 24 5c          	mov    0x5c(%esp),%ebx
f010094f:	8b 74 24 60          	mov    0x60(%esp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100953:	b8 00 00 00 00       	mov    $0x0,%eax
f0100958:	3b 44 24 28          	cmp    0x28(%esp),%eax
f010095c:	72 13                	jb     f0100971 <printnum+0x41>
f010095e:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0100962:	39 44 24 58          	cmp    %eax,0x58(%esp)
f0100966:	76 09                	jbe    f0100971 <printnum+0x41>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100968:	83 eb 01             	sub    $0x1,%ebx
f010096b:	85 db                	test   %ebx,%ebx
f010096d:	7f 53                	jg     f01009c2 <printnum+0x92>
f010096f:	eb 5f                	jmp    f01009d0 <printnum+0xa0>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100971:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100975:	83 eb 01             	sub    $0x1,%ebx
f0100978:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010097c:	8b 44 24 58          	mov    0x58(%esp),%eax
f0100980:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100984:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100988:	8b 74 24 0c          	mov    0xc(%esp),%esi
f010098c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100993:	00 
f0100994:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0100998:	89 04 24             	mov    %eax,(%esp)
f010099b:	8b 44 24 28          	mov    0x28(%esp),%eax
f010099f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a3:	e8 38 0a 00 00       	call   f01013e0 <__udivdi3>
f01009a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01009ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01009b0:	89 04 24             	mov    %eax,(%esp)
f01009b3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009b7:	89 fa                	mov    %edi,%edx
f01009b9:	89 e8                	mov    %ebp,%eax
f01009bb:	e8 70 ff ff ff       	call   f0100930 <printnum>
f01009c0:	eb 0e                	jmp    f01009d0 <printnum+0xa0>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01009c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01009c6:	89 34 24             	mov    %esi,(%esp)
f01009c9:	ff d5                	call   *%ebp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01009cb:	83 eb 01             	sub    $0x1,%ebx
f01009ce:	75 f2                	jne    f01009c2 <printnum+0x92>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01009d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01009d4:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01009d8:	8b 44 24 58          	mov    0x58(%esp),%eax
f01009dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01009e7:	00 
f01009e8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f01009ec:	89 04 24             	mov    %eax,(%esp)
f01009ef:	8b 44 24 28          	mov    0x28(%esp),%eax
f01009f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f7:	e8 14 0b 00 00       	call   f0101510 <__umoddi3>
f01009fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100a00:	0f be 80 44 1b 10 f0 	movsbl -0xfefe4bc(%eax),%eax
f0100a07:	89 04 24             	mov    %eax,(%esp)
f0100a0a:	ff d5                	call   *%ebp
}
f0100a0c:	83 c4 3c             	add    $0x3c,%esp
f0100a0f:	5b                   	pop    %ebx
f0100a10:	5e                   	pop    %esi
f0100a11:	5f                   	pop    %edi
f0100a12:	5d                   	pop    %ebp
f0100a13:	c3                   	ret    

f0100a14 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100a14:	83 fa 01             	cmp    $0x1,%edx
f0100a17:	7e 0d                	jle    f0100a26 <getuint+0x12>
		return va_arg(*ap, unsigned long long);
f0100a19:	8b 10                	mov    (%eax),%edx
f0100a1b:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100a1e:	89 08                	mov    %ecx,(%eax)
f0100a20:	8b 02                	mov    (%edx),%eax
f0100a22:	8b 52 04             	mov    0x4(%edx),%edx
f0100a25:	c3                   	ret    
	else if (lflag)
f0100a26:	85 d2                	test   %edx,%edx
f0100a28:	74 0f                	je     f0100a39 <getuint+0x25>
		return va_arg(*ap, unsigned long);
f0100a2a:	8b 10                	mov    (%eax),%edx
f0100a2c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100a2f:	89 08                	mov    %ecx,(%eax)
f0100a31:	8b 02                	mov    (%edx),%eax
f0100a33:	ba 00 00 00 00       	mov    $0x0,%edx
f0100a38:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
f0100a39:	8b 10                	mov    (%eax),%edx
f0100a3b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100a3e:	89 08                	mov    %ecx,(%eax)
f0100a40:	8b 02                	mov    (%edx),%eax
f0100a42:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100a47:	c3                   	ret    

f0100a48 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100a48:	8b 44 24 08          	mov    0x8(%esp),%eax
	b->cnt++;
f0100a4c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100a50:	8b 10                	mov    (%eax),%edx
f0100a52:	3b 50 04             	cmp    0x4(%eax),%edx
f0100a55:	73 0b                	jae    f0100a62 <sprintputch+0x1a>
		*b->buf++ = ch;
f0100a57:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f0100a5b:	88 0a                	mov    %cl,(%edx)
f0100a5d:	83 c2 01             	add    $0x1,%edx
f0100a60:	89 10                	mov    %edx,(%eax)
f0100a62:	f3 c3                	repz ret 

f0100a64 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100a64:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100a67:	8d 44 24 2c          	lea    0x2c(%esp),%eax
f0100a6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a6f:	8b 44 24 28          	mov    0x28(%esp),%eax
f0100a73:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a77:	8b 44 24 24          	mov    0x24(%esp),%eax
f0100a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a7f:	8b 44 24 20          	mov    0x20(%esp),%eax
f0100a83:	89 04 24             	mov    %eax,(%esp)
f0100a86:	e8 04 00 00 00       	call   f0100a8f <vprintfmt>
	va_end(ap);
}
f0100a8b:	83 c4 1c             	add    $0x1c,%esp
f0100a8e:	c3                   	ret    

f0100a8f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100a8f:	55                   	push   %ebp
f0100a90:	57                   	push   %edi
f0100a91:	56                   	push   %esi
f0100a92:	53                   	push   %ebx
f0100a93:	83 ec 4c             	sub    $0x4c,%esp
f0100a96:	8b 6c 24 60          	mov    0x60(%esp),%ebp
f0100a9a:	8b 5c 24 64          	mov    0x64(%esp),%ebx
f0100a9e:	8b 74 24 68          	mov    0x68(%esp),%esi
f0100aa2:	eb 11                	jmp    f0100ab5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100aa4:	85 c0                	test   %eax,%eax
f0100aa6:	0f 84 14 04 00 00    	je     f0100ec0 <vprintfmt+0x431>
				return;
			putch(ch, putdat);
f0100aac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ab0:	89 04 24             	mov    %eax,(%esp)
f0100ab3:	ff d5                	call   *%ebp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100ab5:	0f b6 06             	movzbl (%esi),%eax
f0100ab8:	83 c6 01             	add    $0x1,%esi
f0100abb:	83 f8 25             	cmp    $0x25,%eax
f0100abe:	75 e4                	jne    f0100aa4 <vprintfmt+0x15>
f0100ac0:	c6 44 24 2c 20       	movb   $0x20,0x2c(%esp)
f0100ac5:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
f0100acc:	00 
f0100acd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100ad2:	c7 44 24 34 ff ff ff 	movl   $0xffffffff,0x34(%esp)
f0100ad9:	ff 
f0100ada:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100adf:	89 7c 24 38          	mov    %edi,0x38(%esp)
f0100ae3:	eb 34                	jmp    f0100b19 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ae5:	8b 74 24 28          	mov    0x28(%esp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100ae9:	c6 44 24 2c 2d       	movb   $0x2d,0x2c(%esp)
f0100aee:	eb 29                	jmp    f0100b19 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100af0:	8b 74 24 28          	mov    0x28(%esp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100af4:	c6 44 24 2c 30       	movb   $0x30,0x2c(%esp)
f0100af9:	eb 1e                	jmp    f0100b19 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100afb:	8b 74 24 28          	mov    0x28(%esp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100aff:	c7 44 24 34 00 00 00 	movl   $0x0,0x34(%esp)
f0100b06:	00 
f0100b07:	eb 10                	jmp    f0100b19 <vprintfmt+0x8a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100b09:	8b 44 24 38          	mov    0x38(%esp),%eax
f0100b0d:	89 44 24 34          	mov    %eax,0x34(%esp)
f0100b11:	c7 44 24 38 ff ff ff 	movl   $0xffffffff,0x38(%esp)
f0100b18:	ff 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b19:	0f b6 06             	movzbl (%esi),%eax
f0100b1c:	0f b6 d0             	movzbl %al,%edx
f0100b1f:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b22:	89 7c 24 28          	mov    %edi,0x28(%esp)
f0100b26:	83 e8 23             	sub    $0x23,%eax
f0100b29:	3c 55                	cmp    $0x55,%al
f0100b2b:	0f 87 6a 03 00 00    	ja     f0100e9b <vprintfmt+0x40c>
f0100b31:	0f b6 c0             	movzbl %al,%eax
f0100b34:	ff 24 85 d4 1b 10 f0 	jmp    *-0xfefe42c(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100b3b:	83 ea 30             	sub    $0x30,%edx
f0100b3e:	89 54 24 38          	mov    %edx,0x38(%esp)
				ch = *fmt;
f0100b42:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0100b46:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b49:	8b 74 24 28          	mov    0x28(%esp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0100b4d:	83 fa 09             	cmp    $0x9,%edx
f0100b50:	77 57                	ja     f0100ba9 <vprintfmt+0x11a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b52:	8b 7c 24 38          	mov    0x38(%esp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100b56:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0100b59:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0100b5c:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0100b60:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100b63:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100b66:	83 fa 09             	cmp    $0x9,%edx
f0100b69:	76 eb                	jbe    f0100b56 <vprintfmt+0xc7>
f0100b6b:	89 7c 24 38          	mov    %edi,0x38(%esp)
f0100b6f:	eb 38                	jmp    f0100ba9 <vprintfmt+0x11a>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100b71:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0100b75:	8d 50 04             	lea    0x4(%eax),%edx
f0100b78:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0100b7c:	8b 00                	mov    (%eax),%eax
f0100b7e:	89 44 24 38          	mov    %eax,0x38(%esp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b82:	8b 74 24 28          	mov    0x28(%esp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100b86:	eb 21                	jmp    f0100ba9 <vprintfmt+0x11a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b88:	8b 74 24 28          	mov    0x28(%esp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0100b8c:	83 7c 24 34 00       	cmpl   $0x0,0x34(%esp)
f0100b91:	79 86                	jns    f0100b19 <vprintfmt+0x8a>
f0100b93:	e9 63 ff ff ff       	jmp    f0100afb <vprintfmt+0x6c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b98:	8b 74 24 28          	mov    0x28(%esp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100b9c:	c7 44 24 30 01 00 00 	movl   $0x1,0x30(%esp)
f0100ba3:	00 
			goto reswitch;
f0100ba4:	e9 70 ff ff ff       	jmp    f0100b19 <vprintfmt+0x8a>

		process_precision:
			if (width < 0)
f0100ba9:	83 7c 24 34 00       	cmpl   $0x0,0x34(%esp)
f0100bae:	0f 89 65 ff ff ff    	jns    f0100b19 <vprintfmt+0x8a>
f0100bb4:	e9 50 ff ff ff       	jmp    f0100b09 <vprintfmt+0x7a>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100bb9:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100bbc:	8b 74 24 28          	mov    0x28(%esp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100bc0:	e9 54 ff ff ff       	jmp    f0100b19 <vprintfmt+0x8a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100bc5:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0100bc9:	8d 50 04             	lea    0x4(%eax),%edx
f0100bcc:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0100bd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100bd4:	8b 00                	mov    (%eax),%eax
f0100bd6:	89 04 24             	mov    %eax,(%esp)
f0100bd9:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100bdb:	8b 74 24 28          	mov    0x28(%esp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100bdf:	e9 d1 fe ff ff       	jmp    f0100ab5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100be4:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0100be8:	8d 50 04             	lea    0x4(%eax),%edx
f0100beb:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0100bef:	8b 00                	mov    (%eax),%eax
f0100bf1:	89 c2                	mov    %eax,%edx
f0100bf3:	c1 fa 1f             	sar    $0x1f,%edx
f0100bf6:	31 d0                	xor    %edx,%eax
f0100bf8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100bfa:	83 f8 06             	cmp    $0x6,%eax
f0100bfd:	7f 0b                	jg     f0100c0a <vprintfmt+0x17b>
f0100bff:	8b 14 85 2c 1d 10 f0 	mov    -0xfefe2d4(,%eax,4),%edx
f0100c06:	85 d2                	test   %edx,%edx
f0100c08:	75 21                	jne    f0100c2b <vprintfmt+0x19c>
				printfmt(putch, putdat, "error %d", err);
f0100c0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c0e:	c7 44 24 08 5c 1b 10 	movl   $0xf0101b5c,0x8(%esp)
f0100c15:	f0 
f0100c16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c1a:	89 2c 24             	mov    %ebp,(%esp)
f0100c1d:	e8 42 fe ff ff       	call   f0100a64 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100c22:	8b 74 24 28          	mov    0x28(%esp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100c26:	e9 8a fe ff ff       	jmp    f0100ab5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100c2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c2f:	c7 44 24 08 65 1b 10 	movl   $0xf0101b65,0x8(%esp)
f0100c36:	f0 
f0100c37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c3b:	89 2c 24             	mov    %ebp,(%esp)
f0100c3e:	e8 21 fe ff ff       	call   f0100a64 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100c43:	8b 74 24 28          	mov    0x28(%esp),%esi
f0100c47:	e9 69 fe ff ff       	jmp    f0100ab5 <vprintfmt+0x26>
f0100c4c:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0100c50:	8b 44 24 34          	mov    0x34(%esp),%eax
f0100c54:	89 44 24 38          	mov    %eax,0x38(%esp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100c58:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0100c5c:	8d 50 04             	lea    0x4(%eax),%edx
f0100c5f:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0100c63:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0100c65:	85 f6                	test   %esi,%esi
f0100c67:	ba 55 1b 10 f0       	mov    $0xf0101b55,%edx
f0100c6c:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f0100c6f:	83 7c 24 38 00       	cmpl   $0x0,0x38(%esp)
f0100c74:	7e 07                	jle    f0100c7d <vprintfmt+0x1ee>
f0100c76:	80 7c 24 2c 2d       	cmpb   $0x2d,0x2c(%esp)
f0100c7b:	75 13                	jne    f0100c90 <vprintfmt+0x201>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100c7d:	0f be 06             	movsbl (%esi),%eax
f0100c80:	83 c6 01             	add    $0x1,%esi
f0100c83:	85 c0                	test   %eax,%eax
f0100c85:	0f 85 9c 00 00 00    	jne    f0100d27 <vprintfmt+0x298>
f0100c8b:	e9 87 00 00 00       	jmp    f0100d17 <vprintfmt+0x288>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100c90:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c94:	89 34 24             	mov    %esi,(%esp)
f0100c97:	e8 9d 03 00 00       	call   f0101039 <strnlen>
f0100c9c:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0100ca0:	29 c1                	sub    %eax,%ecx
f0100ca2:	89 4c 24 34          	mov    %ecx,0x34(%esp)
f0100ca6:	85 c9                	test   %ecx,%ecx
f0100ca8:	7e d3                	jle    f0100c7d <vprintfmt+0x1ee>
					putch(padc, putdat);
f0100caa:	0f be 44 24 2c       	movsbl 0x2c(%esp),%eax
f0100caf:	89 74 24 38          	mov    %esi,0x38(%esp)
f0100cb3:	89 7c 24 3c          	mov    %edi,0x3c(%esp)
f0100cb7:	89 ce                	mov    %ecx,%esi
f0100cb9:	89 c7                	mov    %eax,%edi
f0100cbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cbf:	89 3c 24             	mov    %edi,(%esp)
f0100cc2:	ff d5                	call   *%ebp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100cc4:	83 ee 01             	sub    $0x1,%esi
f0100cc7:	75 f2                	jne    f0100cbb <vprintfmt+0x22c>
f0100cc9:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0100ccd:	89 74 24 34          	mov    %esi,0x34(%esp)
f0100cd1:	8b 74 24 38          	mov    0x38(%esp),%esi
f0100cd5:	eb a6                	jmp    f0100c7d <vprintfmt+0x1ee>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100cd7:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f0100cdc:	74 19                	je     f0100cf7 <vprintfmt+0x268>
f0100cde:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100ce1:	83 fa 5e             	cmp    $0x5e,%edx
f0100ce4:	76 11                	jbe    f0100cf7 <vprintfmt+0x268>
					putch('?', putdat);
f0100ce6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cea:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100cf1:	ff 54 24 2c          	call   *0x2c(%esp)
f0100cf5:	eb 0b                	jmp    f0100d02 <vprintfmt+0x273>
				else
					putch(ch, putdat);
f0100cf7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cfb:	89 04 24             	mov    %eax,(%esp)
f0100cfe:	ff 54 24 2c          	call   *0x2c(%esp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d02:	83 ed 01             	sub    $0x1,%ebp
f0100d05:	0f be 06             	movsbl (%esi),%eax
f0100d08:	83 c6 01             	add    $0x1,%esi
f0100d0b:	85 c0                	test   %eax,%eax
f0100d0d:	75 20                	jne    f0100d2f <vprintfmt+0x2a0>
f0100d0f:	89 6c 24 34          	mov    %ebp,0x34(%esp)
f0100d13:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d17:	8b 74 24 28          	mov    0x28(%esp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d1b:	83 7c 24 34 00       	cmpl   $0x0,0x34(%esp)
f0100d20:	7f 20                	jg     f0100d42 <vprintfmt+0x2b3>
f0100d22:	e9 8e fd ff ff       	jmp    f0100ab5 <vprintfmt+0x26>
f0100d27:	89 6c 24 2c          	mov    %ebp,0x2c(%esp)
f0100d2b:	8b 6c 24 34          	mov    0x34(%esp),%ebp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d2f:	85 ff                	test   %edi,%edi
f0100d31:	78 a4                	js     f0100cd7 <vprintfmt+0x248>
f0100d33:	83 ef 01             	sub    $0x1,%edi
f0100d36:	79 9f                	jns    f0100cd7 <vprintfmt+0x248>
f0100d38:	89 6c 24 34          	mov    %ebp,0x34(%esp)
f0100d3c:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0100d40:	eb d5                	jmp    f0100d17 <vprintfmt+0x288>
f0100d42:	8b 74 24 34          	mov    0x34(%esp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100d46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d4a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100d51:	ff d5                	call   *%ebp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d53:	83 ee 01             	sub    $0x1,%esi
f0100d56:	75 ee                	jne    f0100d46 <vprintfmt+0x2b7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d58:	8b 74 24 28          	mov    0x28(%esp),%esi
f0100d5c:	e9 54 fd ff ff       	jmp    f0100ab5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100d61:	83 f9 01             	cmp    $0x1,%ecx
f0100d64:	7e 12                	jle    f0100d78 <vprintfmt+0x2e9>
		return va_arg(*ap, long long);
f0100d66:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0100d6a:	8d 50 08             	lea    0x8(%eax),%edx
f0100d6d:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0100d71:	8b 30                	mov    (%eax),%esi
f0100d73:	8b 78 04             	mov    0x4(%eax),%edi
f0100d76:	eb 2a                	jmp    f0100da2 <vprintfmt+0x313>
	else if (lflag)
f0100d78:	85 c9                	test   %ecx,%ecx
f0100d7a:	74 14                	je     f0100d90 <vprintfmt+0x301>
		return va_arg(*ap, long);
f0100d7c:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0100d80:	8d 50 04             	lea    0x4(%eax),%edx
f0100d83:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0100d87:	8b 30                	mov    (%eax),%esi
f0100d89:	89 f7                	mov    %esi,%edi
f0100d8b:	c1 ff 1f             	sar    $0x1f,%edi
f0100d8e:	eb 12                	jmp    f0100da2 <vprintfmt+0x313>
	else
		return va_arg(*ap, int);
f0100d90:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0100d94:	8d 50 04             	lea    0x4(%eax),%edx
f0100d97:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0100d9b:	8b 30                	mov    (%eax),%esi
f0100d9d:	89 f7                	mov    %esi,%edi
f0100d9f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0100da2:	85 ff                	test   %edi,%edi
f0100da4:	78 0e                	js     f0100db4 <vprintfmt+0x325>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100da6:	89 f0                	mov    %esi,%eax
f0100da8:	89 fa                	mov    %edi,%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0100daa:	be 0a 00 00 00       	mov    $0xa,%esi
f0100daf:	e9 a7 00 00 00       	jmp    f0100e5b <vprintfmt+0x3cc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0100db4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100db8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100dbf:	ff d5                	call   *%ebp
				num = -(long long) num;
f0100dc1:	89 f0                	mov    %esi,%eax
f0100dc3:	89 fa                	mov    %edi,%edx
f0100dc5:	f7 d8                	neg    %eax
f0100dc7:	83 d2 00             	adc    $0x0,%edx
f0100dca:	f7 da                	neg    %edx
			}
			base = 10;
f0100dcc:	be 0a 00 00 00       	mov    $0xa,%esi
f0100dd1:	e9 85 00 00 00       	jmp    f0100e5b <vprintfmt+0x3cc>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100dd6:	89 ca                	mov    %ecx,%edx
f0100dd8:	8d 44 24 6c          	lea    0x6c(%esp),%eax
f0100ddc:	e8 33 fc ff ff       	call   f0100a14 <getuint>
			base = 10;
f0100de1:	be 0a 00 00 00       	mov    $0xa,%esi
			goto number;
f0100de6:	eb 73                	jmp    f0100e5b <vprintfmt+0x3cc>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0100de8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100dec:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100df3:	ff d5                	call   *%ebp
			putch('X', putdat);
f0100df5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100df9:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100e00:	ff d5                	call   *%ebp
			putch('X', putdat);
f0100e02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e06:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0100e0d:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e0f:	8b 74 24 28          	mov    0x28(%esp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0100e13:	e9 9d fc ff ff       	jmp    f0100ab5 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0100e18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e1c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100e23:	ff d5                	call   *%ebp
			putch('x', putdat);
f0100e25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e29:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100e30:	ff d5                	call   *%ebp
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100e32:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0100e36:	8d 50 04             	lea    0x4(%eax),%edx
f0100e39:	89 54 24 6c          	mov    %edx,0x6c(%esp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100e3d:	8b 00                	mov    (%eax),%eax
f0100e3f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0100e44:	be 10 00 00 00       	mov    $0x10,%esi
			goto number;
f0100e49:	eb 10                	jmp    f0100e5b <vprintfmt+0x3cc>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100e4b:	89 ca                	mov    %ecx,%edx
f0100e4d:	8d 44 24 6c          	lea    0x6c(%esp),%eax
f0100e51:	e8 be fb ff ff       	call   f0100a14 <getuint>
			base = 16;
f0100e56:	be 10 00 00 00       	mov    $0x10,%esi
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100e5b:	0f be 4c 24 2c       	movsbl 0x2c(%esp),%ecx
f0100e60:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100e64:	8b 7c 24 34          	mov    0x34(%esp),%edi
f0100e68:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0100e6c:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100e70:	89 04 24             	mov    %eax,(%esp)
f0100e73:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100e77:	89 da                	mov    %ebx,%edx
f0100e79:	89 e8                	mov    %ebp,%eax
f0100e7b:	e8 b0 fa ff ff       	call   f0100930 <printnum>
			break;
f0100e80:	8b 74 24 28          	mov    0x28(%esp),%esi
f0100e84:	e9 2c fc ff ff       	jmp    f0100ab5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100e89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e8d:	89 14 24             	mov    %edx,(%esp)
f0100e90:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e92:	8b 74 24 28          	mov    0x28(%esp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0100e96:	e9 1a fc ff ff       	jmp    f0100ab5 <vprintfmt+0x26>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100e9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e9f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100ea6:	ff d5                	call   *%ebp
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100ea8:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0100eac:	0f 84 03 fc ff ff    	je     f0100ab5 <vprintfmt+0x26>
f0100eb2:	83 ee 01             	sub    $0x1,%esi
f0100eb5:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0100eb9:	75 f7                	jne    f0100eb2 <vprintfmt+0x423>
f0100ebb:	e9 f5 fb ff ff       	jmp    f0100ab5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0100ec0:	83 c4 4c             	add    $0x4c,%esp
f0100ec3:	5b                   	pop    %ebx
f0100ec4:	5e                   	pop    %esi
f0100ec5:	5f                   	pop    %edi
f0100ec6:	5d                   	pop    %ebp
f0100ec7:	c3                   	ret    

f0100ec8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100ec8:	83 ec 2c             	sub    $0x2c,%esp
f0100ecb:	8b 44 24 30          	mov    0x30(%esp),%eax
f0100ecf:	8b 54 24 34          	mov    0x34(%esp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100ed3:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100ed7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0100edb:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f0100edf:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f0100ee6:	00 

	if (buf == NULL || n < 1)
f0100ee7:	85 c0                	test   %eax,%eax
f0100ee9:	74 35                	je     f0100f20 <vsnprintf+0x58>
f0100eeb:	85 d2                	test   %edx,%edx
f0100eed:	7e 31                	jle    f0100f20 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100eef:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0100ef3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ef7:	8b 44 24 38          	mov    0x38(%esp),%eax
f0100efb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100eff:	8d 44 24 14          	lea    0x14(%esp),%eax
f0100f03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f07:	c7 04 24 48 0a 10 f0 	movl   $0xf0100a48,(%esp)
f0100f0e:	e8 7c fb ff ff       	call   f0100a8f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100f13:	8b 44 24 14          	mov    0x14(%esp),%eax
f0100f17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100f1a:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0100f1e:	eb 05                	jmp    f0100f25 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0100f20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0100f25:	83 c4 2c             	add    $0x2c,%esp
f0100f28:	c3                   	ret    

f0100f29 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100f29:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100f2c:	8d 44 24 2c          	lea    0x2c(%esp),%eax
f0100f30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f34:	8b 44 24 28          	mov    0x28(%esp),%eax
f0100f38:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f3c:	8b 44 24 24          	mov    0x24(%esp),%eax
f0100f40:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f44:	8b 44 24 20          	mov    0x20(%esp),%eax
f0100f48:	89 04 24             	mov    %eax,(%esp)
f0100f4b:	e8 78 ff ff ff       	call   f0100ec8 <vsnprintf>
	va_end(ap);

	return rc;
}
f0100f50:	83 c4 1c             	add    $0x1c,%esp
f0100f53:	c3                   	ret    
	...

f0100f60 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0100f60:	57                   	push   %edi
f0100f61:	56                   	push   %esi
f0100f62:	53                   	push   %ebx
f0100f63:	83 ec 10             	sub    $0x10,%esp
f0100f66:	8b 44 24 20          	mov    0x20(%esp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0100f6a:	85 c0                	test   %eax,%eax
f0100f6c:	74 10                	je     f0100f7e <readline+0x1e>
		cprintf("%s", prompt);
f0100f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f72:	c7 04 24 65 1b 10 f0 	movl   $0xf0101b65,(%esp)
f0100f79:	e8 94 f9 ff ff       	call   f0100912 <cprintf>

	i = 0;
	echoing = iscons(0);
f0100f7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100f85:	e8 e5 f6 ff ff       	call   f010066f <iscons>
f0100f8a:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0100f8c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0100f91:	e8 c9 f6 ff ff       	call   f010065f <getchar>
f0100f96:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0100f98:	85 c0                	test   %eax,%eax
f0100f9a:	79 17                	jns    f0100fb3 <readline+0x53>
			cprintf("read error: %e\n", c);
f0100f9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa0:	c7 04 24 48 1d 10 f0 	movl   $0xf0101d48,(%esp)
f0100fa7:	e8 66 f9 ff ff       	call   f0100912 <cprintf>
			return NULL;
f0100fac:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fb1:	eb 63                	jmp    f0101016 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0100fb3:	83 f8 1f             	cmp    $0x1f,%eax
f0100fb6:	7e 1f                	jle    f0100fd7 <readline+0x77>
f0100fb8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0100fbe:	7f 17                	jg     f0100fd7 <readline+0x77>
			if (echoing)
f0100fc0:	85 ff                	test   %edi,%edi
f0100fc2:	74 08                	je     f0100fcc <readline+0x6c>
				cputchar(c);
f0100fc4:	89 04 24             	mov    %eax,(%esp)
f0100fc7:	e8 80 f6 ff ff       	call   f010064c <cputchar>
			buf[i++] = c;
f0100fcc:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0100fd2:	83 c6 01             	add    $0x1,%esi
f0100fd5:	eb ba                	jmp    f0100f91 <readline+0x31>
		} else if (c == '\b' && i > 0) {
f0100fd7:	83 fb 08             	cmp    $0x8,%ebx
f0100fda:	75 15                	jne    f0100ff1 <readline+0x91>
f0100fdc:	85 f6                	test   %esi,%esi
f0100fde:	7e 11                	jle    f0100ff1 <readline+0x91>
			if (echoing)
f0100fe0:	85 ff                	test   %edi,%edi
f0100fe2:	74 08                	je     f0100fec <readline+0x8c>
				cputchar(c);
f0100fe4:	89 1c 24             	mov    %ebx,(%esp)
f0100fe7:	e8 60 f6 ff ff       	call   f010064c <cputchar>
			i--;
f0100fec:	83 ee 01             	sub    $0x1,%esi
f0100fef:	eb a0                	jmp    f0100f91 <readline+0x31>
		} else if (c == '\n' || c == '\r') {
f0100ff1:	83 fb 0a             	cmp    $0xa,%ebx
f0100ff4:	74 05                	je     f0100ffb <readline+0x9b>
f0100ff6:	83 fb 0d             	cmp    $0xd,%ebx
f0100ff9:	75 96                	jne    f0100f91 <readline+0x31>
			if (echoing)
f0100ffb:	85 ff                	test   %edi,%edi
f0100ffd:	8d 76 00             	lea    0x0(%esi),%esi
f0101000:	74 08                	je     f010100a <readline+0xaa>
				cputchar(c);
f0101002:	89 1c 24             	mov    %ebx,(%esp)
f0101005:	e8 42 f6 ff ff       	call   f010064c <cputchar>
			buf[i] = 0;
f010100a:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
			return buf;
f0101011:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
		}
	}
}
f0101016:	83 c4 10             	add    $0x10,%esp
f0101019:	5b                   	pop    %ebx
f010101a:	5e                   	pop    %esi
f010101b:	5f                   	pop    %edi
f010101c:	c3                   	ret    
f010101d:	00 00                	add    %al,(%eax)
	...

f0101020 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0101020:	8b 54 24 04          	mov    0x4(%esp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101024:	b8 00 00 00 00       	mov    $0x0,%eax
f0101029:	80 3a 00             	cmpb   $0x0,(%edx)
f010102c:	74 09                	je     f0101037 <strlen+0x17>
		n++;
f010102e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101031:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101035:	75 f7                	jne    f010102e <strlen+0xe>
		n++;
	return n;
}
f0101037:	f3 c3                	repz ret 

f0101039 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101039:	53                   	push   %ebx
f010103a:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f010103e:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101042:	b8 00 00 00 00       	mov    $0x0,%eax
f0101047:	85 c9                	test   %ecx,%ecx
f0101049:	74 1a                	je     f0101065 <strnlen+0x2c>
f010104b:	80 3b 00             	cmpb   $0x0,(%ebx)
f010104e:	74 15                	je     f0101065 <strnlen+0x2c>
f0101050:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0101055:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101057:	39 ca                	cmp    %ecx,%edx
f0101059:	74 0a                	je     f0101065 <strnlen+0x2c>
f010105b:	83 c2 01             	add    $0x1,%edx
f010105e:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0101063:	75 f0                	jne    f0101055 <strnlen+0x1c>
		n++;
	return n;
}
f0101065:	5b                   	pop    %ebx
f0101066:	c3                   	ret    

f0101067 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101067:	53                   	push   %ebx
f0101068:	8b 44 24 08          	mov    0x8(%esp),%eax
f010106c:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101070:	ba 00 00 00 00       	mov    $0x0,%edx
f0101075:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0101079:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010107c:	83 c2 01             	add    $0x1,%edx
f010107f:	84 c9                	test   %cl,%cl
f0101081:	75 f2                	jne    f0101075 <strcpy+0xe>
		/* do nothing */;
	return ret;
}
f0101083:	5b                   	pop    %ebx
f0101084:	c3                   	ret    

f0101085 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101085:	56                   	push   %esi
f0101086:	53                   	push   %ebx
f0101087:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010108b:	8b 54 24 10          	mov    0x10(%esp),%edx
f010108f:	8b 74 24 14          	mov    0x14(%esp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101093:	85 f6                	test   %esi,%esi
f0101095:	74 18                	je     f01010af <strncpy+0x2a>
f0101097:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010109c:	0f b6 1a             	movzbl (%edx),%ebx
f010109f:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01010a2:	80 3a 01             	cmpb   $0x1,(%edx)
f01010a5:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01010a8:	83 c1 01             	add    $0x1,%ecx
f01010ab:	39 f1                	cmp    %esi,%ecx
f01010ad:	75 ed                	jne    f010109c <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01010af:	5b                   	pop    %ebx
f01010b0:	5e                   	pop    %esi
f01010b1:	c3                   	ret    

f01010b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01010b2:	57                   	push   %edi
f01010b3:	56                   	push   %esi
f01010b4:	53                   	push   %ebx
f01010b5:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01010b9:	8b 5c 24 14          	mov    0x14(%esp),%ebx
f01010bd:	8b 74 24 18          	mov    0x18(%esp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01010c1:	89 f8                	mov    %edi,%eax
f01010c3:	85 f6                	test   %esi,%esi
f01010c5:	74 2b                	je     f01010f2 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01010c7:	83 fe 01             	cmp    $0x1,%esi
f01010ca:	74 23                	je     f01010ef <strlcpy+0x3d>
f01010cc:	0f b6 0b             	movzbl (%ebx),%ecx
f01010cf:	84 c9                	test   %cl,%cl
f01010d1:	74 1c                	je     f01010ef <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01010d3:	83 ee 02             	sub    $0x2,%esi
f01010d6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01010db:	88 08                	mov    %cl,(%eax)
f01010dd:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01010e0:	39 f2                	cmp    %esi,%edx
f01010e2:	74 0b                	je     f01010ef <strlcpy+0x3d>
f01010e4:	83 c2 01             	add    $0x1,%edx
f01010e7:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01010eb:	84 c9                	test   %cl,%cl
f01010ed:	75 ec                	jne    f01010db <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01010ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01010f2:	29 f8                	sub    %edi,%eax
}
f01010f4:	5b                   	pop    %ebx
f01010f5:	5e                   	pop    %esi
f01010f6:	5f                   	pop    %edi
f01010f7:	c3                   	ret    

f01010f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01010f8:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f01010fc:	8b 54 24 08          	mov    0x8(%esp),%edx
	while (*p && *p == *q)
f0101100:	0f b6 01             	movzbl (%ecx),%eax
f0101103:	84 c0                	test   %al,%al
f0101105:	74 16                	je     f010111d <strcmp+0x25>
f0101107:	3a 02                	cmp    (%edx),%al
f0101109:	75 12                	jne    f010111d <strcmp+0x25>
		p++, q++;
f010110b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010110e:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0101112:	84 c0                	test   %al,%al
f0101114:	74 07                	je     f010111d <strcmp+0x25>
f0101116:	83 c1 01             	add    $0x1,%ecx
f0101119:	3a 02                	cmp    (%edx),%al
f010111b:	74 ee                	je     f010110b <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010111d:	0f b6 c0             	movzbl %al,%eax
f0101120:	0f b6 12             	movzbl (%edx),%edx
f0101123:	29 d0                	sub    %edx,%eax
}
f0101125:	c3                   	ret    

f0101126 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101126:	53                   	push   %ebx
f0101127:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f010112b:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010112f:	8b 54 24 10          	mov    0x10(%esp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101133:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101138:	85 d2                	test   %edx,%edx
f010113a:	74 28                	je     f0101164 <strncmp+0x3e>
f010113c:	0f b6 01             	movzbl (%ecx),%eax
f010113f:	84 c0                	test   %al,%al
f0101141:	74 23                	je     f0101166 <strncmp+0x40>
f0101143:	3a 03                	cmp    (%ebx),%al
f0101145:	75 1f                	jne    f0101166 <strncmp+0x40>
f0101147:	83 ea 01             	sub    $0x1,%edx
f010114a:	74 13                	je     f010115f <strncmp+0x39>
		n--, p++, q++;
f010114c:	83 c1 01             	add    $0x1,%ecx
f010114f:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101152:	0f b6 01             	movzbl (%ecx),%eax
f0101155:	84 c0                	test   %al,%al
f0101157:	74 0d                	je     f0101166 <strncmp+0x40>
f0101159:	3a 03                	cmp    (%ebx),%al
f010115b:	74 ea                	je     f0101147 <strncmp+0x21>
f010115d:	eb 07                	jmp    f0101166 <strncmp+0x40>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010115f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101164:	5b                   	pop    %ebx
f0101165:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101166:	0f b6 01             	movzbl (%ecx),%eax
f0101169:	0f b6 13             	movzbl (%ebx),%edx
f010116c:	29 d0                	sub    %edx,%eax
f010116e:	eb f4                	jmp    f0101164 <strncmp+0x3e>

f0101170 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101170:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101174:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
f0101179:	0f b6 10             	movzbl (%eax),%edx
f010117c:	84 d2                	test   %dl,%dl
f010117e:	74 1b                	je     f010119b <strchr+0x2b>
		if (*s == c)
f0101180:	38 ca                	cmp    %cl,%dl
f0101182:	75 09                	jne    f010118d <strchr+0x1d>
f0101184:	f3 c3                	repz ret 
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101186:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0101189:	38 ca                	cmp    %cl,%dl
f010118b:	74 13                	je     f01011a0 <strchr+0x30>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010118d:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0101191:	84 d2                	test   %dl,%dl
f0101193:	75 f1                	jne    f0101186 <strchr+0x16>
		if (*s == c)
			return (char *) s;
	return 0;
f0101195:	b8 00 00 00 00       	mov    $0x0,%eax
f010119a:	c3                   	ret    
f010119b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011a0:	f3 c3                	repz ret 

f01011a2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01011a2:	8b 44 24 04          	mov    0x4(%esp),%eax
f01011a6:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
f01011ab:	0f b6 10             	movzbl (%eax),%edx
f01011ae:	84 d2                	test   %dl,%dl
f01011b0:	74 1a                	je     f01011cc <strfind+0x2a>
		if (*s == c)
f01011b2:	38 ca                	cmp    %cl,%dl
f01011b4:	75 0c                	jne    f01011c2 <strfind+0x20>
f01011b6:	f3 c3                	repz ret 
f01011b8:	38 ca                	cmp    %cl,%dl
f01011ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01011c0:	74 0a                	je     f01011cc <strfind+0x2a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01011c2:	83 c0 01             	add    $0x1,%eax
f01011c5:	0f b6 10             	movzbl (%eax),%edx
f01011c8:	84 d2                	test   %dl,%dl
f01011ca:	75 ec                	jne    f01011b8 <strfind+0x16>
		if (*s == c)
			break;
	return (char *) s;
}
f01011cc:	f3 c3                	repz ret 

f01011ce <memset>:


void *
memset(void *v, int c, size_t n)
{
f01011ce:	53                   	push   %ebx
f01011cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01011d3:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f01011d7:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01011db:	89 da                	mov    %ebx,%edx
f01011dd:	83 ea 01             	sub    $0x1,%edx
f01011e0:	78 0d                	js     f01011ef <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f01011e2:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f01011e4:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f01011e6:	88 0a                	mov    %cl,(%edx)
f01011e8:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01011eb:	39 da                	cmp    %ebx,%edx
f01011ed:	75 f7                	jne    f01011e6 <memset+0x18>
		*p++ = c;

	return v;
}
f01011ef:	5b                   	pop    %ebx
f01011f0:	c3                   	ret    

f01011f1 <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f01011f1:	57                   	push   %edi
f01011f2:	56                   	push   %esi
f01011f3:	53                   	push   %ebx
f01011f4:	8b 44 24 10          	mov    0x10(%esp),%eax
f01011f8:	8b 74 24 14          	mov    0x14(%esp),%esi
f01011fc:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101200:	39 c6                	cmp    %eax,%esi
f0101202:	72 0b                	jb     f010120f <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101204:	ba 00 00 00 00       	mov    $0x0,%edx
f0101209:	85 db                	test   %ebx,%ebx
f010120b:	75 29                	jne    f0101236 <memmove+0x45>
f010120d:	eb 35                	jmp    f0101244 <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010120f:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f0101212:	39 c8                	cmp    %ecx,%eax
f0101214:	73 ee                	jae    f0101204 <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f0101216:	85 db                	test   %ebx,%ebx
f0101218:	74 2a                	je     f0101244 <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f010121a:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f010121d:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f010121f:	f7 db                	neg    %ebx
f0101221:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f0101224:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f0101226:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f010122b:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f010122f:	83 ea 01             	sub    $0x1,%edx
f0101232:	75 f2                	jne    f0101226 <memmove+0x35>
f0101234:	eb 0e                	jmp    f0101244 <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0101236:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f010123a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010123d:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101240:	39 d3                	cmp    %edx,%ebx
f0101242:	75 f2                	jne    f0101236 <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f0101244:	5b                   	pop    %ebx
f0101245:	5e                   	pop    %esi
f0101246:	5f                   	pop    %edi
f0101247:	c3                   	ret    

f0101248 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0101248:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010124b:	8b 44 24 18          	mov    0x18(%esp),%eax
f010124f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101253:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101257:	89 44 24 04          	mov    %eax,0x4(%esp)
f010125b:	8b 44 24 10          	mov    0x10(%esp),%eax
f010125f:	89 04 24             	mov    %eax,(%esp)
f0101262:	e8 8a ff ff ff       	call   f01011f1 <memmove>
}
f0101267:	83 c4 0c             	add    $0xc,%esp
f010126a:	c3                   	ret    

f010126b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010126b:	57                   	push   %edi
f010126c:	56                   	push   %esi
f010126d:	53                   	push   %ebx
f010126e:	8b 5c 24 10          	mov    0x10(%esp),%ebx
f0101272:	8b 74 24 14          	mov    0x14(%esp),%esi
f0101276:	8b 7c 24 18          	mov    0x18(%esp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010127a:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010127f:	85 ff                	test   %edi,%edi
f0101281:	74 37                	je     f01012ba <memcmp+0x4f>
		if (*s1 != *s2)
f0101283:	0f b6 03             	movzbl (%ebx),%eax
f0101286:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101289:	83 ef 01             	sub    $0x1,%edi
f010128c:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0101291:	38 c8                	cmp    %cl,%al
f0101293:	74 1c                	je     f01012b1 <memcmp+0x46>
f0101295:	eb 10                	jmp    f01012a7 <memcmp+0x3c>
f0101297:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f010129c:	83 c2 01             	add    $0x1,%edx
f010129f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01012a3:	38 c8                	cmp    %cl,%al
f01012a5:	74 0a                	je     f01012b1 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f01012a7:	0f b6 c0             	movzbl %al,%eax
f01012aa:	0f b6 c9             	movzbl %cl,%ecx
f01012ad:	29 c8                	sub    %ecx,%eax
f01012af:	eb 09                	jmp    f01012ba <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01012b1:	39 fa                	cmp    %edi,%edx
f01012b3:	75 e2                	jne    f0101297 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01012b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012ba:	5b                   	pop    %ebx
f01012bb:	5e                   	pop    %esi
f01012bc:	5f                   	pop    %edi
f01012bd:	c3                   	ret    

f01012be <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01012be:	8b 44 24 04          	mov    0x4(%esp),%eax
	const void *ends = (const char *) s + n;
f01012c2:	89 c2                	mov    %eax,%edx
f01012c4:	03 54 24 0c          	add    0xc(%esp),%edx
	for (; s < ends; s++)
f01012c8:	39 d0                	cmp    %edx,%eax
f01012ca:	73 16                	jae    f01012e2 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01012cc:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
f01012d1:	38 08                	cmp    %cl,(%eax)
f01012d3:	75 06                	jne    f01012db <memfind+0x1d>
f01012d5:	f3 c3                	repz ret 
f01012d7:	38 08                	cmp    %cl,(%eax)
f01012d9:	74 07                	je     f01012e2 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01012db:	83 c0 01             	add    $0x1,%eax
f01012de:	39 d0                	cmp    %edx,%eax
f01012e0:	75 f5                	jne    f01012d7 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01012e2:	f3 c3                	repz ret 

f01012e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01012e4:	55                   	push   %ebp
f01012e5:	57                   	push   %edi
f01012e6:	56                   	push   %esi
f01012e7:	53                   	push   %ebx
f01012e8:	8b 54 24 14          	mov    0x14(%esp),%edx
f01012ec:	8b 74 24 18          	mov    0x18(%esp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01012f0:	0f b6 02             	movzbl (%edx),%eax
f01012f3:	3c 20                	cmp    $0x20,%al
f01012f5:	74 04                	je     f01012fb <strtol+0x17>
f01012f7:	3c 09                	cmp    $0x9,%al
f01012f9:	75 0e                	jne    f0101309 <strtol+0x25>
		s++;
f01012fb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01012fe:	0f b6 02             	movzbl (%edx),%eax
f0101301:	3c 20                	cmp    $0x20,%al
f0101303:	74 f6                	je     f01012fb <strtol+0x17>
f0101305:	3c 09                	cmp    $0x9,%al
f0101307:	74 f2                	je     f01012fb <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101309:	3c 2b                	cmp    $0x2b,%al
f010130b:	75 0a                	jne    f0101317 <strtol+0x33>
		s++;
f010130d:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101310:	bf 00 00 00 00       	mov    $0x0,%edi
f0101315:	eb 10                	jmp    f0101327 <strtol+0x43>
f0101317:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010131c:	3c 2d                	cmp    $0x2d,%al
f010131e:	75 07                	jne    f0101327 <strtol+0x43>
		s++, neg = 1;
f0101320:	83 c2 01             	add    $0x1,%edx
f0101323:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101327:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
f010132c:	0f 94 c0             	sete   %al
f010132f:	74 07                	je     f0101338 <strtol+0x54>
f0101331:	83 7c 24 1c 10       	cmpl   $0x10,0x1c(%esp)
f0101336:	75 18                	jne    f0101350 <strtol+0x6c>
f0101338:	80 3a 30             	cmpb   $0x30,(%edx)
f010133b:	75 13                	jne    f0101350 <strtol+0x6c>
f010133d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101341:	75 0d                	jne    f0101350 <strtol+0x6c>
		s += 2, base = 16;
f0101343:	83 c2 02             	add    $0x2,%edx
f0101346:	c7 44 24 1c 10 00 00 	movl   $0x10,0x1c(%esp)
f010134d:	00 
f010134e:	eb 1c                	jmp    f010136c <strtol+0x88>
	else if (base == 0 && s[0] == '0')
f0101350:	84 c0                	test   %al,%al
f0101352:	74 18                	je     f010136c <strtol+0x88>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101354:	c7 44 24 1c 0a 00 00 	movl   $0xa,0x1c(%esp)
f010135b:	00 
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010135c:	80 3a 30             	cmpb   $0x30,(%edx)
f010135f:	75 0b                	jne    f010136c <strtol+0x88>
		s++, base = 8;
f0101361:	83 c2 01             	add    $0x1,%edx
f0101364:	c7 44 24 1c 08 00 00 	movl   $0x8,0x1c(%esp)
f010136b:	00 
	else if (base == 0)
		base = 10;
f010136c:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101371:	0f b6 0a             	movzbl (%edx),%ecx
f0101374:	8d 69 d0             	lea    -0x30(%ecx),%ebp
f0101377:	89 eb                	mov    %ebp,%ebx
f0101379:	80 fb 09             	cmp    $0x9,%bl
f010137c:	77 08                	ja     f0101386 <strtol+0xa2>
			dig = *s - '0';
f010137e:	0f be c9             	movsbl %cl,%ecx
f0101381:	83 e9 30             	sub    $0x30,%ecx
f0101384:	eb 22                	jmp    f01013a8 <strtol+0xc4>
		else if (*s >= 'a' && *s <= 'z')
f0101386:	8d 69 9f             	lea    -0x61(%ecx),%ebp
f0101389:	89 eb                	mov    %ebp,%ebx
f010138b:	80 fb 19             	cmp    $0x19,%bl
f010138e:	77 08                	ja     f0101398 <strtol+0xb4>
			dig = *s - 'a' + 10;
f0101390:	0f be c9             	movsbl %cl,%ecx
f0101393:	83 e9 57             	sub    $0x57,%ecx
f0101396:	eb 10                	jmp    f01013a8 <strtol+0xc4>
		else if (*s >= 'A' && *s <= 'Z')
f0101398:	8d 69 bf             	lea    -0x41(%ecx),%ebp
f010139b:	89 eb                	mov    %ebp,%ebx
f010139d:	80 fb 19             	cmp    $0x19,%bl
f01013a0:	77 18                	ja     f01013ba <strtol+0xd6>
			dig = *s - 'A' + 10;
f01013a2:	0f be c9             	movsbl %cl,%ecx
f01013a5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01013a8:	3b 4c 24 1c          	cmp    0x1c(%esp),%ecx
f01013ac:	7d 10                	jge    f01013be <strtol+0xda>
			break;
		s++, val = (val * base) + dig;
f01013ae:	83 c2 01             	add    $0x1,%edx
f01013b1:	0f af 44 24 1c       	imul   0x1c(%esp),%eax
f01013b6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01013b8:	eb b7                	jmp    f0101371 <strtol+0x8d>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01013ba:	89 c1                	mov    %eax,%ecx
f01013bc:	eb 02                	jmp    f01013c0 <strtol+0xdc>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01013be:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01013c0:	85 f6                	test   %esi,%esi
f01013c2:	74 02                	je     f01013c6 <strtol+0xe2>
		*endptr = (char *) s;
f01013c4:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01013c6:	89 ca                	mov    %ecx,%edx
f01013c8:	f7 da                	neg    %edx
f01013ca:	85 ff                	test   %edi,%edi
f01013cc:	0f 45 c2             	cmovne %edx,%eax
}
f01013cf:	5b                   	pop    %ebx
f01013d0:	5e                   	pop    %esi
f01013d1:	5f                   	pop    %edi
f01013d2:	5d                   	pop    %ebp
f01013d3:	c3                   	ret    
	...

f01013e0 <__udivdi3>:
f01013e0:	83 ec 1c             	sub    $0x1c,%esp
f01013e3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01013e7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f01013eb:	8b 44 24 20          	mov    0x20(%esp),%eax
f01013ef:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01013f3:	89 74 24 10          	mov    %esi,0x10(%esp)
f01013f7:	8b 74 24 24          	mov    0x24(%esp),%esi
f01013fb:	85 ff                	test   %edi,%edi
f01013fd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101401:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101405:	89 cd                	mov    %ecx,%ebp
f0101407:	89 44 24 04          	mov    %eax,0x4(%esp)
f010140b:	75 33                	jne    f0101440 <__udivdi3+0x60>
f010140d:	39 f1                	cmp    %esi,%ecx
f010140f:	77 57                	ja     f0101468 <__udivdi3+0x88>
f0101411:	85 c9                	test   %ecx,%ecx
f0101413:	75 0b                	jne    f0101420 <__udivdi3+0x40>
f0101415:	b8 01 00 00 00       	mov    $0x1,%eax
f010141a:	31 d2                	xor    %edx,%edx
f010141c:	f7 f1                	div    %ecx
f010141e:	89 c1                	mov    %eax,%ecx
f0101420:	89 f0                	mov    %esi,%eax
f0101422:	31 d2                	xor    %edx,%edx
f0101424:	f7 f1                	div    %ecx
f0101426:	89 c6                	mov    %eax,%esi
f0101428:	8b 44 24 04          	mov    0x4(%esp),%eax
f010142c:	f7 f1                	div    %ecx
f010142e:	89 f2                	mov    %esi,%edx
f0101430:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101434:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101438:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010143c:	83 c4 1c             	add    $0x1c,%esp
f010143f:	c3                   	ret    
f0101440:	31 d2                	xor    %edx,%edx
f0101442:	31 c0                	xor    %eax,%eax
f0101444:	39 f7                	cmp    %esi,%edi
f0101446:	77 e8                	ja     f0101430 <__udivdi3+0x50>
f0101448:	0f bd cf             	bsr    %edi,%ecx
f010144b:	83 f1 1f             	xor    $0x1f,%ecx
f010144e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101452:	75 2c                	jne    f0101480 <__udivdi3+0xa0>
f0101454:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0101458:	76 04                	jbe    f010145e <__udivdi3+0x7e>
f010145a:	39 f7                	cmp    %esi,%edi
f010145c:	73 d2                	jae    f0101430 <__udivdi3+0x50>
f010145e:	31 d2                	xor    %edx,%edx
f0101460:	b8 01 00 00 00       	mov    $0x1,%eax
f0101465:	eb c9                	jmp    f0101430 <__udivdi3+0x50>
f0101467:	90                   	nop
f0101468:	89 f2                	mov    %esi,%edx
f010146a:	f7 f1                	div    %ecx
f010146c:	31 d2                	xor    %edx,%edx
f010146e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101472:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101476:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010147a:	83 c4 1c             	add    $0x1c,%esp
f010147d:	c3                   	ret    
f010147e:	66 90                	xchg   %ax,%ax
f0101480:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101485:	b8 20 00 00 00       	mov    $0x20,%eax
f010148a:	89 ea                	mov    %ebp,%edx
f010148c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101490:	d3 e7                	shl    %cl,%edi
f0101492:	89 c1                	mov    %eax,%ecx
f0101494:	d3 ea                	shr    %cl,%edx
f0101496:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010149b:	09 fa                	or     %edi,%edx
f010149d:	89 f7                	mov    %esi,%edi
f010149f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01014a3:	89 f2                	mov    %esi,%edx
f01014a5:	8b 74 24 08          	mov    0x8(%esp),%esi
f01014a9:	d3 e5                	shl    %cl,%ebp
f01014ab:	89 c1                	mov    %eax,%ecx
f01014ad:	d3 ef                	shr    %cl,%edi
f01014af:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01014b4:	d3 e2                	shl    %cl,%edx
f01014b6:	89 c1                	mov    %eax,%ecx
f01014b8:	d3 ee                	shr    %cl,%esi
f01014ba:	09 d6                	or     %edx,%esi
f01014bc:	89 fa                	mov    %edi,%edx
f01014be:	89 f0                	mov    %esi,%eax
f01014c0:	f7 74 24 0c          	divl   0xc(%esp)
f01014c4:	89 d7                	mov    %edx,%edi
f01014c6:	89 c6                	mov    %eax,%esi
f01014c8:	f7 e5                	mul    %ebp
f01014ca:	39 d7                	cmp    %edx,%edi
f01014cc:	72 22                	jb     f01014f0 <__udivdi3+0x110>
f01014ce:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f01014d2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01014d7:	d3 e5                	shl    %cl,%ebp
f01014d9:	39 c5                	cmp    %eax,%ebp
f01014db:	73 04                	jae    f01014e1 <__udivdi3+0x101>
f01014dd:	39 d7                	cmp    %edx,%edi
f01014df:	74 0f                	je     f01014f0 <__udivdi3+0x110>
f01014e1:	89 f0                	mov    %esi,%eax
f01014e3:	31 d2                	xor    %edx,%edx
f01014e5:	e9 46 ff ff ff       	jmp    f0101430 <__udivdi3+0x50>
f01014ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01014f0:	8d 46 ff             	lea    -0x1(%esi),%eax
f01014f3:	31 d2                	xor    %edx,%edx
f01014f5:	8b 74 24 10          	mov    0x10(%esp),%esi
f01014f9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01014fd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101501:	83 c4 1c             	add    $0x1c,%esp
f0101504:	c3                   	ret    
	...

f0101510 <__umoddi3>:
f0101510:	83 ec 1c             	sub    $0x1c,%esp
f0101513:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0101517:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f010151b:	8b 44 24 20          	mov    0x20(%esp),%eax
f010151f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101523:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101527:	8b 74 24 24          	mov    0x24(%esp),%esi
f010152b:	85 ed                	test   %ebp,%ebp
f010152d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0101531:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101535:	89 cf                	mov    %ecx,%edi
f0101537:	89 04 24             	mov    %eax,(%esp)
f010153a:	89 f2                	mov    %esi,%edx
f010153c:	75 1a                	jne    f0101558 <__umoddi3+0x48>
f010153e:	39 f1                	cmp    %esi,%ecx
f0101540:	76 4e                	jbe    f0101590 <__umoddi3+0x80>
f0101542:	f7 f1                	div    %ecx
f0101544:	89 d0                	mov    %edx,%eax
f0101546:	31 d2                	xor    %edx,%edx
f0101548:	8b 74 24 10          	mov    0x10(%esp),%esi
f010154c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101550:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101554:	83 c4 1c             	add    $0x1c,%esp
f0101557:	c3                   	ret    
f0101558:	39 f5                	cmp    %esi,%ebp
f010155a:	77 54                	ja     f01015b0 <__umoddi3+0xa0>
f010155c:	0f bd c5             	bsr    %ebp,%eax
f010155f:	83 f0 1f             	xor    $0x1f,%eax
f0101562:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101566:	75 60                	jne    f01015c8 <__umoddi3+0xb8>
f0101568:	3b 0c 24             	cmp    (%esp),%ecx
f010156b:	0f 87 07 01 00 00    	ja     f0101678 <__umoddi3+0x168>
f0101571:	89 f2                	mov    %esi,%edx
f0101573:	8b 34 24             	mov    (%esp),%esi
f0101576:	29 ce                	sub    %ecx,%esi
f0101578:	19 ea                	sbb    %ebp,%edx
f010157a:	89 34 24             	mov    %esi,(%esp)
f010157d:	8b 04 24             	mov    (%esp),%eax
f0101580:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101584:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101588:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f010158c:	83 c4 1c             	add    $0x1c,%esp
f010158f:	c3                   	ret    
f0101590:	85 c9                	test   %ecx,%ecx
f0101592:	75 0b                	jne    f010159f <__umoddi3+0x8f>
f0101594:	b8 01 00 00 00       	mov    $0x1,%eax
f0101599:	31 d2                	xor    %edx,%edx
f010159b:	f7 f1                	div    %ecx
f010159d:	89 c1                	mov    %eax,%ecx
f010159f:	89 f0                	mov    %esi,%eax
f01015a1:	31 d2                	xor    %edx,%edx
f01015a3:	f7 f1                	div    %ecx
f01015a5:	8b 04 24             	mov    (%esp),%eax
f01015a8:	f7 f1                	div    %ecx
f01015aa:	eb 98                	jmp    f0101544 <__umoddi3+0x34>
f01015ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01015b0:	89 f2                	mov    %esi,%edx
f01015b2:	8b 74 24 10          	mov    0x10(%esp),%esi
f01015b6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f01015ba:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f01015be:	83 c4 1c             	add    $0x1c,%esp
f01015c1:	c3                   	ret    
f01015c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01015c8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01015cd:	89 e8                	mov    %ebp,%eax
f01015cf:	bd 20 00 00 00       	mov    $0x20,%ebp
f01015d4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f01015d8:	89 fa                	mov    %edi,%edx
f01015da:	d3 e0                	shl    %cl,%eax
f01015dc:	89 e9                	mov    %ebp,%ecx
f01015de:	d3 ea                	shr    %cl,%edx
f01015e0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01015e5:	09 c2                	or     %eax,%edx
f01015e7:	8b 44 24 08          	mov    0x8(%esp),%eax
f01015eb:	89 14 24             	mov    %edx,(%esp)
f01015ee:	89 f2                	mov    %esi,%edx
f01015f0:	d3 e7                	shl    %cl,%edi
f01015f2:	89 e9                	mov    %ebp,%ecx
f01015f4:	d3 ea                	shr    %cl,%edx
f01015f6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01015fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01015ff:	d3 e6                	shl    %cl,%esi
f0101601:	89 e9                	mov    %ebp,%ecx
f0101603:	d3 e8                	shr    %cl,%eax
f0101605:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010160a:	09 f0                	or     %esi,%eax
f010160c:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101610:	f7 34 24             	divl   (%esp)
f0101613:	d3 e6                	shl    %cl,%esi
f0101615:	89 74 24 08          	mov    %esi,0x8(%esp)
f0101619:	89 d6                	mov    %edx,%esi
f010161b:	f7 e7                	mul    %edi
f010161d:	39 d6                	cmp    %edx,%esi
f010161f:	89 c1                	mov    %eax,%ecx
f0101621:	89 d7                	mov    %edx,%edi
f0101623:	72 3f                	jb     f0101664 <__umoddi3+0x154>
f0101625:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0101629:	72 35                	jb     f0101660 <__umoddi3+0x150>
f010162b:	8b 44 24 08          	mov    0x8(%esp),%eax
f010162f:	29 c8                	sub    %ecx,%eax
f0101631:	19 fe                	sbb    %edi,%esi
f0101633:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101638:	89 f2                	mov    %esi,%edx
f010163a:	d3 e8                	shr    %cl,%eax
f010163c:	89 e9                	mov    %ebp,%ecx
f010163e:	d3 e2                	shl    %cl,%edx
f0101640:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101645:	09 d0                	or     %edx,%eax
f0101647:	89 f2                	mov    %esi,%edx
f0101649:	d3 ea                	shr    %cl,%edx
f010164b:	8b 74 24 10          	mov    0x10(%esp),%esi
f010164f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0101653:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0101657:	83 c4 1c             	add    $0x1c,%esp
f010165a:	c3                   	ret    
f010165b:	90                   	nop
f010165c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101660:	39 d6                	cmp    %edx,%esi
f0101662:	75 c7                	jne    f010162b <__umoddi3+0x11b>
f0101664:	89 d7                	mov    %edx,%edi
f0101666:	89 c1                	mov    %eax,%ecx
f0101668:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f010166c:	1b 3c 24             	sbb    (%esp),%edi
f010166f:	eb ba                	jmp    f010162b <__umoddi3+0x11b>
f0101671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101678:	39 f5                	cmp    %esi,%ebp
f010167a:	0f 82 f1 fe ff ff    	jb     f0101571 <__umoddi3+0x61>
f0101680:	e9 f8 fe ff ff       	jmp    f010157d <__umoddi3+0x6d>
