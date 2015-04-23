
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
f0100015:	0f 01 15 18 a0 11 00 	lgdtl  0x11a018

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
f0100033:	bc bc 9f 11 f0       	mov    $0xf0119fbc,%esp

	# now to C code
	call	i386_init
f0100038:	e8 03 00 00 00       	call   f0100040 <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <i386_init>:
#include <kern/picirq.h>


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
f0100046:	b8 70 67 1b f0       	mov    $0xf01b6770,%eax
f010004b:	2d 5e 58 1b f0       	sub    $0xf01b585e,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 5e 58 1b f0 	movl   $0xf01b585e,(%esp)
f0100063:	e8 6e 4a 00 00       	call   f0104ad6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 9a 06 00 00       	call   f0100707 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 80 4f 10 f0 	movl   $0xf0104f80,(%esp)
f010007c:	e8 41 31 00 00       	call   f01031c2 <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f0100081:	e8 22 0b 00 00       	call   f0100ba8 <i386_detect_memory>
	i386_vm_init();
f0100086:	e8 d9 10 00 00       	call   f0101164 <i386_vm_init>

	// Lab 3 user environment initialization functions
	env_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 96 29 00 00       	call   f0102a2b <env_init>
	idt_init();
f0100095:	e8 46 31 00 00       	call   f01031e0 <idt_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010009a:	e8 4e 30 00 00       	call   f01030ed <pic_init>
	kclock_init();
f010009f:	90                   	nop
f01000a0:	e8 87 2f 00 00       	call   f010302c <kclock_init>

	// Should always have an idle process as first one.
	ENV_CREATE(user_idle);
f01000a5:	c7 44 24 04 bc 89 00 	movl   $0x89bc,0x4(%esp)
f01000ac:	00 
f01000ad:	c7 04 24 7c a3 11 f0 	movl   $0xf011a37c,(%esp)
f01000b4:	e8 b9 2b 00 00       	call   f0102c72 <env_create>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE2(TEST, TESTSIZE)
#else
	// Touch all you want.
	ENV_CREATE(user_faultallocbad);
f01000b9:	c7 44 24 04 5c 8a 00 	movl   $0x8a5c,0x4(%esp)
f01000c0:	00 
f01000c1:	c7 04 24 2d 69 15 f0 	movl   $0xf015692d,(%esp)
f01000c8:	e8 a5 2b 00 00       	call   f0102c72 <env_create>
	//ENV_CREATE(user_yield);
#endif // TEST*


	// Schedule and run the first user environment!
	sched_yield();
f01000cd:	e8 ae 38 00 00       	call   f0103980 <sched_yield>

f01000d2 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000d2:	55                   	push   %ebp
f01000d3:	89 e5                	mov    %esp,%ebp
f01000d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f01000d8:	83 3d 60 58 1b f0 00 	cmpl   $0x0,0xf01b5860
f01000df:	75 40                	jne    f0100121 <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f01000e1:	8b 45 10             	mov    0x10(%ebp),%eax
f01000e4:	a3 60 58 1b f0       	mov    %eax,0xf01b5860

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01000f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000f7:	c7 04 24 9b 4f 10 f0 	movl   $0xf0104f9b,(%esp)
f01000fe:	e8 bf 30 00 00       	call   f01031c2 <cprintf>
	vcprintf(fmt, ap);
f0100103:	8d 45 14             	lea    0x14(%ebp),%eax
f0100106:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010a:	8b 45 10             	mov    0x10(%ebp),%eax
f010010d:	89 04 24             	mov    %eax,(%esp)
f0100110:	e8 7a 30 00 00       	call   f010318f <vcprintf>
	cprintf("\n");
f0100115:	c7 04 24 cd 5d 10 f0 	movl   $0xf0105dcd,(%esp)
f010011c:	e8 a1 30 00 00       	call   f01031c2 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100121:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100128:	e8 33 07 00 00       	call   f0100860 <monitor>
f010012d:	eb f2                	jmp    f0100121 <_panic+0x4f>

f010012f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010012f:	55                   	push   %ebp
f0100130:	89 e5                	mov    %esp,%ebp
f0100132:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f0100135:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100138:	89 44 24 08          	mov    %eax,0x8(%esp)
f010013c:	8b 45 08             	mov    0x8(%ebp),%eax
f010013f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100143:	c7 04 24 b3 4f 10 f0 	movl   $0xf0104fb3,(%esp)
f010014a:	e8 73 30 00 00       	call   f01031c2 <cprintf>
	vcprintf(fmt, ap);
f010014f:	8d 45 14             	lea    0x14(%ebp),%eax
f0100152:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100156:	8b 45 10             	mov    0x10(%ebp),%eax
f0100159:	89 04 24             	mov    %eax,(%esp)
f010015c:	e8 2e 30 00 00       	call   f010318f <vcprintf>
	cprintf("\n");
f0100161:	c7 04 24 cd 5d 10 f0 	movl   $0xf0105dcd,(%esp)
f0100168:	e8 55 30 00 00       	call   f01031c2 <cprintf>
	va_end(ap);
}
f010016d:	c9                   	leave  
f010016e:	c3                   	ret    
	...

f0100170 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100173:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100178:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100179:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
static bool serial_exists;

int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010017e:	a8 01                	test   $0x1,%al
f0100180:	74 06                	je     f0100188 <serial_proc_data+0x18>
f0100182:	b2 f8                	mov    $0xf8,%dl
f0100184:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100185:	0f b6 c8             	movzbl %al,%ecx
}
f0100188:	89 c8                	mov    %ecx,%eax
f010018a:	5d                   	pop    %ebp
f010018b:	c3                   	ret    

f010018c <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010018c:	55                   	push   %ebp
f010018d:	89 e5                	mov    %esp,%ebp
f010018f:	53                   	push   %ebx
f0100190:	83 ec 14             	sub    $0x14,%esp
f0100193:	ba 64 00 00 00       	mov    $0x64,%edx
f0100198:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100199:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010019e:	a8 01                	test   $0x1,%al
f01001a0:	0f 84 de 00 00 00    	je     f0100284 <kbd_proc_data+0xf8>
f01001a6:	b2 60                	mov    $0x60,%dl
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001ab:	3c e0                	cmp    $0xe0,%al
f01001ad:	75 11                	jne    f01001c0 <kbd_proc_data+0x34>
		// E0 escape character
		shift |= E0ESC;
f01001af:	83 0d 90 58 1b f0 40 	orl    $0x40,0xf01b5890
		return 0;
f01001b6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001bb:	e9 c4 00 00 00       	jmp    f0100284 <kbd_proc_data+0xf8>
	} else if (data & 0x80) {
f01001c0:	84 c0                	test   %al,%al
f01001c2:	79 37                	jns    f01001fb <kbd_proc_data+0x6f>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001c4:	8b 0d 90 58 1b f0    	mov    0xf01b5890,%ecx
f01001ca:	89 cb                	mov    %ecx,%ebx
f01001cc:	83 e3 40             	and    $0x40,%ebx
f01001cf:	83 e0 7f             	and    $0x7f,%eax
f01001d2:	85 db                	test   %ebx,%ebx
f01001d4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001d7:	0f b6 d2             	movzbl %dl,%edx
f01001da:	0f b6 82 e0 51 10 f0 	movzbl -0xfefae20(%edx),%eax
f01001e1:	83 c8 40             	or     $0x40,%eax
f01001e4:	0f b6 c0             	movzbl %al,%eax
f01001e7:	f7 d0                	not    %eax
f01001e9:	21 c1                	and    %eax,%ecx
f01001eb:	89 0d 90 58 1b f0    	mov    %ecx,0xf01b5890
		return 0;
f01001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01001f6:	e9 89 00 00 00       	jmp    f0100284 <kbd_proc_data+0xf8>
	} else if (shift & E0ESC) {
f01001fb:	8b 0d 90 58 1b f0    	mov    0xf01b5890,%ecx
f0100201:	f6 c1 40             	test   $0x40,%cl
f0100204:	74 0e                	je     f0100214 <kbd_proc_data+0x88>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100206:	89 c2                	mov    %eax,%edx
f0100208:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010020b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010020e:	89 0d 90 58 1b f0    	mov    %ecx,0xf01b5890
	}

	shift |= shiftcode[data];
f0100214:	0f b6 d2             	movzbl %dl,%edx
f0100217:	0f b6 82 e0 51 10 f0 	movzbl -0xfefae20(%edx),%eax
f010021e:	0b 05 90 58 1b f0    	or     0xf01b5890,%eax
	shift ^= togglecode[data];
f0100224:	0f b6 8a e0 52 10 f0 	movzbl -0xfefad20(%edx),%ecx
f010022b:	31 c8                	xor    %ecx,%eax
f010022d:	a3 90 58 1b f0       	mov    %eax,0xf01b5890

	c = charcode[shift & (CTL | SHIFT)][data];
f0100232:	89 c1                	mov    %eax,%ecx
f0100234:	83 e1 03             	and    $0x3,%ecx
f0100237:	8b 0c 8d e0 53 10 f0 	mov    -0xfefac20(,%ecx,4),%ecx
f010023e:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100242:	a8 08                	test   $0x8,%al
f0100244:	74 19                	je     f010025f <kbd_proc_data+0xd3>
		if ('a' <= c && c <= 'z')
f0100246:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100249:	83 fa 19             	cmp    $0x19,%edx
f010024c:	77 05                	ja     f0100253 <kbd_proc_data+0xc7>
			c += 'A' - 'a';
f010024e:	83 eb 20             	sub    $0x20,%ebx
f0100251:	eb 0c                	jmp    f010025f <kbd_proc_data+0xd3>
		else if ('A' <= c && c <= 'Z')
f0100253:	8d 4b bf             	lea    -0x41(%ebx),%ecx
			c += 'a' - 'A';
f0100256:	8d 53 20             	lea    0x20(%ebx),%edx
f0100259:	83 f9 19             	cmp    $0x19,%ecx
f010025c:	0f 46 da             	cmovbe %edx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010025f:	f7 d0                	not    %eax
f0100261:	a8 06                	test   $0x6,%al
f0100263:	75 1f                	jne    f0100284 <kbd_proc_data+0xf8>
f0100265:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010026b:	75 17                	jne    f0100284 <kbd_proc_data+0xf8>
		cprintf("Rebooting!\n");
f010026d:	c7 04 24 cd 4f 10 f0 	movl   $0xf0104fcd,(%esp)
f0100274:	e8 49 2f 00 00       	call   f01031c2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100279:	ba 92 00 00 00       	mov    $0x92,%edx
f010027e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100283:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100284:	89 d8                	mov    %ebx,%eax
f0100286:	83 c4 14             	add    $0x14,%esp
f0100289:	5b                   	pop    %ebx
f010028a:	5d                   	pop    %ebp
f010028b:	c3                   	ret    

f010028c <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f010028c:	55                   	push   %ebp
f010028d:	89 e5                	mov    %esp,%ebp
f010028f:	56                   	push   %esi
f0100290:	53                   	push   %ebx
f0100291:	83 ec 10             	sub    $0x10,%esp
f0100294:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100299:	b8 00 00 00 00       	mov    $0x0,%eax
f010029e:	89 da                	mov    %ebx,%edx
f01002a0:	ee                   	out    %al,(%dx)
f01002a1:	b2 fb                	mov    $0xfb,%dl
f01002a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01002a8:	ee                   	out    %al,(%dx)
f01002a9:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01002ae:	b8 0c 00 00 00       	mov    $0xc,%eax
f01002b3:	89 ca                	mov    %ecx,%edx
f01002b5:	ee                   	out    %al,(%dx)
f01002b6:	b2 f9                	mov    $0xf9,%dl
f01002b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01002bd:	ee                   	out    %al,(%dx)
f01002be:	b2 fb                	mov    $0xfb,%dl
f01002c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01002c5:	ee                   	out    %al,(%dx)
f01002c6:	b2 fc                	mov    $0xfc,%dl
f01002c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01002cd:	ee                   	out    %al,(%dx)
f01002ce:	b2 f9                	mov    $0xf9,%dl
f01002d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01002d5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d6:	b2 fd                	mov    $0xfd,%dl
f01002d8:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01002d9:	3c ff                	cmp    $0xff,%al
f01002db:	0f 95 c0             	setne  %al
f01002de:	0f b6 c0             	movzbl %al,%eax
f01002e1:	89 c6                	mov    %eax,%esi
f01002e3:	a3 80 58 1b f0       	mov    %eax,0xf01b5880
f01002e8:	89 da                	mov    %ebx,%edx
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	89 ca                	mov    %ecx,%edx
f01002ed:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f01002ee:	85 f6                	test   %esi,%esi
f01002f0:	74 14                	je     f0100306 <serial_init+0x7a>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f01002f2:	0f b7 05 70 a3 11 f0 	movzwl 0xf011a370,%eax
f01002f9:	25 ef ff 00 00       	and    $0xffef,%eax
f01002fe:	89 04 24             	mov    %eax,(%esp)
f0100301:	e8 76 2d 00 00       	call   f010307c <irq_setmask_8259A>
}
f0100306:	83 c4 10             	add    $0x10,%esp
f0100309:	5b                   	pop    %ebx
f010030a:	5e                   	pop    %esi
f010030b:	5d                   	pop    %ebp
f010030c:	c3                   	ret    

f010030d <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010030d:	55                   	push   %ebp
f010030e:	89 e5                	mov    %esp,%ebp
f0100310:	83 ec 0c             	sub    $0xc,%esp
f0100313:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100316:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100319:	89 7d fc             	mov    %edi,-0x4(%ebp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010031c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100323:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010032a:	5a a5 
	if (*cp != 0xA55A) {
f010032c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100333:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100337:	74 11                	je     f010034a <cga_init+0x3d>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100339:	c7 05 84 58 1b f0 b4 	movl   $0x3b4,0xf01b5884
f0100340:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100343:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100348:	eb 16                	jmp    f0100360 <cga_init+0x53>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010034a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100351:	c7 05 84 58 1b f0 d4 	movl   $0x3d4,0xf01b5884
f0100358:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010035b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100360:	8b 0d 84 58 1b f0    	mov    0xf01b5884,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100366:	b8 0e 00 00 00       	mov    $0xe,%eax
f010036b:	89 ca                	mov    %ecx,%edx
f010036d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010036e:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100371:	89 da                	mov    %ebx,%edx
f0100373:	ec                   	in     (%dx),%al
f0100374:	0f b6 f8             	movzbl %al,%edi
f0100377:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010037f:	89 ca                	mov    %ecx,%edx
f0100381:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100382:	89 da                	mov    %ebx,%edx
f0100384:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100385:	89 35 88 58 1b f0    	mov    %esi,0xf01b5888
	
	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010038b:	0f b6 d8             	movzbl %al,%ebx
f010038e:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100390:	66 89 3d 8c 58 1b f0 	mov    %di,0xf01b588c
}
f0100397:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010039a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010039d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01003a0:	89 ec                	mov    %ebp,%esp
f01003a2:	5d                   	pop    %ebp
f01003a3:	c3                   	ret    

f01003a4 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01003a4:	55                   	push   %ebp
f01003a5:	89 e5                	mov    %esp,%ebp
f01003a7:	53                   	push   %ebx
f01003a8:	83 ec 04             	sub    $0x4,%esp
f01003ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01003ae:	eb 25                	jmp    f01003d5 <cons_intr+0x31>
		if (c == 0)
f01003b0:	85 c0                	test   %eax,%eax
f01003b2:	74 21                	je     f01003d5 <cons_intr+0x31>
			continue;
		cons.buf[cons.wpos++] = c;
f01003b4:	8b 15 a4 5a 1b f0    	mov    0xf01b5aa4,%edx
f01003ba:	88 82 a0 58 1b f0    	mov    %al,-0xfe4a760(%edx)
f01003c0:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01003c3:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01003c8:	ba 00 00 00 00       	mov    $0x0,%edx
f01003cd:	0f 44 c2             	cmove  %edx,%eax
f01003d0:	a3 a4 5a 1b f0       	mov    %eax,0xf01b5aa4
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01003d5:	ff d3                	call   *%ebx
f01003d7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01003da:	75 d4                	jne    f01003b0 <cons_intr+0xc>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01003dc:	83 c4 04             	add    $0x4,%esp
f01003df:	5b                   	pop    %ebx
f01003e0:	5d                   	pop    %ebp
f01003e1:	c3                   	ret    

f01003e2 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01003e2:	55                   	push   %ebp
f01003e3:	89 e5                	mov    %esp,%ebp
f01003e5:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f01003e8:	c7 04 24 8c 01 10 f0 	movl   $0xf010018c,(%esp)
f01003ef:	e8 b0 ff ff ff       	call   f01003a4 <cons_intr>
}
f01003f4:	c9                   	leave  
f01003f5:	c3                   	ret    

f01003f6 <kbd_init>:

void
kbd_init(void)
{
f01003f6:	55                   	push   %ebp
f01003f7:	89 e5                	mov    %esp,%ebp
f01003f9:	83 ec 18             	sub    $0x18,%esp
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01003fc:	e8 e1 ff ff ff       	call   f01003e2 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100401:	0f b7 05 70 a3 11 f0 	movzwl 0xf011a370,%eax
f0100408:	25 fd ff 00 00       	and    $0xfffd,%eax
f010040d:	89 04 24             	mov    %eax,(%esp)
f0100410:	e8 67 2c 00 00       	call   f010307c <irq_setmask_8259A>
}
f0100415:	c9                   	leave  
f0100416:	c3                   	ret    

f0100417 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100417:	55                   	push   %ebp
f0100418:	89 e5                	mov    %esp,%ebp
f010041a:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f010041d:	83 3d 80 58 1b f0 00 	cmpl   $0x0,0xf01b5880
f0100424:	74 0c                	je     f0100432 <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f0100426:	c7 04 24 70 01 10 f0 	movl   $0xf0100170,(%esp)
f010042d:	e8 72 ff ff ff       	call   f01003a4 <cons_intr>
}
f0100432:	c9                   	leave  
f0100433:	c3                   	ret    

f0100434 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100434:	55                   	push   %ebp
f0100435:	89 e5                	mov    %esp,%ebp
f0100437:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010043a:	e8 d8 ff ff ff       	call   f0100417 <serial_intr>
	kbd_intr();
f010043f:	e8 9e ff ff ff       	call   f01003e2 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100444:	8b 15 a0 5a 1b f0    	mov    0xf01b5aa0,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f010044a:	b8 00 00 00 00       	mov    $0x0,%eax
	// (e.g., when called from the kernel monitor).
	serial_intr();
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010044f:	3b 15 a4 5a 1b f0    	cmp    0xf01b5aa4,%edx
f0100455:	74 1e                	je     f0100475 <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f0100457:	0f b6 82 a0 58 1b f0 	movzbl -0xfe4a760(%edx),%eax
f010045e:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100461:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100467:	b9 00 00 00 00       	mov    $0x0,%ecx
f010046c:	0f 44 d1             	cmove  %ecx,%edx
f010046f:	89 15 a0 5a 1b f0    	mov    %edx,0xf01b5aa0
		return c;
	}
	return 0;
}
f0100475:	c9                   	leave  
f0100476:	c3                   	ret    

f0100477 <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f0100477:	55                   	push   %ebp
f0100478:	89 e5                	mov    %esp,%ebp
f010047a:	57                   	push   %edi
f010047b:	56                   	push   %esi
f010047c:	53                   	push   %ebx
f010047d:	83 ec 1c             	sub    $0x1c,%esp
f0100480:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100483:	ba 79 03 00 00       	mov    $0x379,%edx
f0100488:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100489:	84 c0                	test   %al,%al
f010048b:	78 21                	js     f01004ae <cons_putc+0x37>
f010048d:	bb 00 32 00 00       	mov    $0x3200,%ebx
f0100492:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100497:	be 79 03 00 00       	mov    $0x379,%esi
f010049c:	89 ca                	mov    %ecx,%edx
f010049e:	ec                   	in     (%dx),%al
f010049f:	ec                   	in     (%dx),%al
f01004a0:	ec                   	in     (%dx),%al
f01004a1:	ec                   	in     (%dx),%al
f01004a2:	89 f2                	mov    %esi,%edx
f01004a4:	ec                   	in     (%dx),%al
f01004a5:	84 c0                	test   %al,%al
f01004a7:	78 05                	js     f01004ae <cons_putc+0x37>
f01004a9:	83 eb 01             	sub    $0x1,%ebx
f01004ac:	75 ee                	jne    f010049c <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004ae:	ba 78 03 00 00       	mov    $0x378,%edx
f01004b3:	89 f8                	mov    %edi,%eax
f01004b5:	ee                   	out    %al,(%dx)
f01004b6:	b2 7a                	mov    $0x7a,%dl
f01004b8:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004bd:	ee                   	out    %al,(%dx)
f01004be:	b8 08 00 00 00       	mov    $0x8,%eax
f01004c3:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f01004c4:	89 3c 24             	mov    %edi,(%esp)
f01004c7:	e8 08 00 00 00       	call   f01004d4 <cga_putc>
}
f01004cc:	83 c4 1c             	add    $0x1c,%esp
f01004cf:	5b                   	pop    %ebx
f01004d0:	5e                   	pop    %esi
f01004d1:	5f                   	pop    %edi
f01004d2:	5d                   	pop    %ebp
f01004d3:	c3                   	ret    

f01004d4 <cga_putc>:



void
cga_putc(int c)
{
f01004d4:	55                   	push   %ebp
f01004d5:	89 e5                	mov    %esp,%ebp
f01004d7:	56                   	push   %esi
f01004d8:	53                   	push   %ebx
f01004d9:	83 ec 10             	sub    $0x10,%esp
f01004dc:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	// whether are 15-8 bits zero?If they are set 8,9,10 bit 1,If not continue.
	if (!(c & ~0xFF))
f01004df:	89 c1                	mov    %eax,%ecx
f01004e1:	81 e1 00 ff ff ff    	and    $0xffffff00,%ecx
		c |= 0x0a00;
f01004e7:	89 c2                	mov    %eax,%edx
f01004e9:	80 ce 0a             	or     $0xa,%dh
f01004ec:	85 c9                	test   %ecx,%ecx
f01004ee:	0f 44 c2             	cmove  %edx,%eax

	// whether are low 8 bits '\b','\n','\r','\t'?If they are,preform corresponding operation.
	switch (c & 0xff) {
f01004f1:	0f b6 d0             	movzbl %al,%edx
f01004f4:	83 ea 08             	sub    $0x8,%edx
f01004f7:	83 fa 72             	cmp    $0x72,%edx
f01004fa:	0f 87 67 01 00 00    	ja     f0100667 <cga_putc+0x193>
f0100500:	ff 24 95 00 50 10 f0 	jmp    *-0xfefb000(,%edx,4)
	case '\b':
		if (crt_pos > 0) {
f0100507:	0f b7 15 8c 58 1b f0 	movzwl 0xf01b588c,%edx
f010050e:	66 85 d2             	test   %dx,%dx
f0100511:	0f 84 bb 01 00 00    	je     f01006d2 <cga_putc+0x1fe>
			crt_pos--;
f0100517:	83 ea 01             	sub    $0x1,%edx
f010051a:	66 89 15 8c 58 1b f0 	mov    %dx,0xf01b588c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100521:	0f b7 d2             	movzwl %dx,%edx
f0100524:	b0 00                	mov    $0x0,%al
f0100526:	89 c1                	mov    %eax,%ecx
f0100528:	83 c9 20             	or     $0x20,%ecx
f010052b:	a1 88 58 1b f0       	mov    0xf01b5888,%eax
f0100530:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f0100534:	e9 4c 01 00 00       	jmp    f0100685 <cga_putc+0x1b1>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100539:	66 83 05 8c 58 1b f0 	addw   $0x50,0xf01b588c
f0100540:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100541:	0f b7 05 8c 58 1b f0 	movzwl 0xf01b588c,%eax
f0100548:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010054e:	c1 e8 16             	shr    $0x16,%eax
f0100551:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100554:	c1 e0 04             	shl    $0x4,%eax
f0100557:	66 a3 8c 58 1b f0    	mov    %ax,0xf01b588c
		break;
f010055d:	e9 23 01 00 00       	jmp    f0100685 <cga_putc+0x1b1>
	case '\t':
		cons_putc(' ');
f0100562:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100569:	e8 09 ff ff ff       	call   f0100477 <cons_putc>
		cons_putc(' ');
f010056e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100575:	e8 fd fe ff ff       	call   f0100477 <cons_putc>
		cons_putc(' ');
f010057a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100581:	e8 f1 fe ff ff       	call   f0100477 <cons_putc>
		cons_putc(' ');
f0100586:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010058d:	e8 e5 fe ff ff       	call   f0100477 <cons_putc>
		cons_putc(' ');
f0100592:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100599:	e8 d9 fe ff ff       	call   f0100477 <cons_putc>
		break;
f010059e:	e9 e2 00 00 00       	jmp    f0100685 <cga_putc+0x1b1>
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0c00;
f01005a3:	0f b7 15 8c 58 1b f0 	movzwl 0xf01b588c,%edx
f01005aa:	0f b7 da             	movzwl %dx,%ebx
f01005ad:	80 e4 f0             	and    $0xf0,%ah
f01005b0:	80 cc 0c             	or     $0xc,%ah
f01005b3:	8b 0d 88 58 1b f0    	mov    0xf01b5888,%ecx
f01005b9:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005bd:	83 c2 01             	add    $0x1,%edx
f01005c0:	66 89 15 8c 58 1b f0 	mov    %dx,0xf01b588c
		break;
f01005c7:	e9 b9 00 00 00       	jmp    f0100685 <cga_putc+0x1b1>
	case 'v':
	case 'w':
	case 'x':
	case 'y':
	case 'z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0900;
f01005cc:	0f b7 15 8c 58 1b f0 	movzwl 0xf01b588c,%edx
f01005d3:	0f b7 da             	movzwl %dx,%ebx
f01005d6:	80 e4 f0             	and    $0xf0,%ah
f01005d9:	80 cc 09             	or     $0x9,%ah
f01005dc:	8b 0d 88 58 1b f0    	mov    0xf01b5888,%ecx
f01005e2:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005e6:	83 c2 01             	add    $0x1,%edx
f01005e9:	66 89 15 8c 58 1b f0 	mov    %dx,0xf01b588c
		break;
f01005f0:	e9 90 00 00 00       	jmp    f0100685 <cga_putc+0x1b1>
	case 'V':
	case 'W':
	case 'X':
	case 'Y':
	case 'Z':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0100;
f01005f5:	0f b7 15 8c 58 1b f0 	movzwl 0xf01b588c,%edx
f01005fc:	0f b7 da             	movzwl %dx,%ebx
f01005ff:	80 e4 f0             	and    $0xf0,%ah
f0100602:	80 cc 01             	or     $0x1,%ah
f0100605:	8b 0d 88 58 1b f0    	mov    0xf01b5888,%ecx
f010060b:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010060f:	83 c2 01             	add    $0x1,%edx
f0100612:	66 89 15 8c 58 1b f0 	mov    %dx,0xf01b588c
		break;
f0100619:	eb 6a                	jmp    f0100685 <cga_putc+0x1b1>
	case '%':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0e00;
f010061b:	0f b7 15 8c 58 1b f0 	movzwl 0xf01b588c,%edx
f0100622:	0f b7 da             	movzwl %dx,%ebx
f0100625:	80 e4 f0             	and    $0xf0,%ah
f0100628:	80 cc 0e             	or     $0xe,%ah
f010062b:	8b 0d 88 58 1b f0    	mov    0xf01b5888,%ecx
f0100631:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f0100635:	83 c2 01             	add    $0x1,%edx
f0100638:	66 89 15 8c 58 1b f0 	mov    %dx,0xf01b588c
		break;
f010063f:	eb 44                	jmp    f0100685 <cga_putc+0x1b1>
	case '&':
		crt_buf[crt_pos++] = (c&0xf0ff)|0x0d00;
f0100641:	0f b7 15 8c 58 1b f0 	movzwl 0xf01b588c,%edx
f0100648:	0f b7 da             	movzwl %dx,%ebx
f010064b:	80 e4 f0             	and    $0xf0,%ah
f010064e:	80 cc 0d             	or     $0xd,%ah
f0100651:	8b 0d 88 58 1b f0    	mov    0xf01b5888,%ecx
f0100657:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010065b:	83 c2 01             	add    $0x1,%edx
f010065e:	66 89 15 8c 58 1b f0 	mov    %dx,0xf01b588c
		break;
f0100665:	eb 1e                	jmp    f0100685 <cga_putc+0x1b1>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100667:	0f b7 15 8c 58 1b f0 	movzwl 0xf01b588c,%edx
f010066e:	0f b7 da             	movzwl %dx,%ebx
f0100671:	8b 0d 88 58 1b f0    	mov    0xf01b5888,%ecx
f0100677:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010067b:	83 c2 01             	add    $0x1,%edx
f010067e:	66 89 15 8c 58 1b f0 	mov    %dx,0xf01b588c
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100685:	66 81 3d 8c 58 1b f0 	cmpw   $0x7cf,0xf01b588c
f010068c:	cf 07 
f010068e:	76 42                	jbe    f01006d2 <cga_putc+0x1fe>
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100690:	a1 88 58 1b f0       	mov    0xf01b5888,%eax
f0100695:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010069c:	00 
f010069d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01006a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006a7:	89 04 24             	mov    %eax,(%esp)
f01006aa:	e8 4b 44 00 00       	call   f0104afa <memmove>
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0c00 | ' ';
f01006af:	8b 15 88 58 1b f0    	mov    0xf01b5888,%edx
	if (crt_pos >= CRT_SIZE) {
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006b5:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0c00 | ' ';
f01006ba:	66 c7 04 42 20 0c    	movw   $0xc20,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) {
		int i;
		// Move all chars on the screen above a line;(memcpy or memmove: memcpy(dst, src, size))[Comment this line, the screen will never roll for new info]
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// Set the bottom line empty;(0x0700 is for color using)[Comment out this line and the bottom line will be nearly the same as the above line]
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006c0:	83 c0 01             	add    $0x1,%eax
f01006c3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01006c8:	75 f0                	jne    f01006ba <cga_putc+0x1e6>
			crt_buf[i] = 0x0c00 | ' ';
		// Fix the position of screen;[Comment out this line and the screen will turn pure black]
		crt_pos -= CRT_COLS;
f01006ca:	66 83 2d 8c 58 1b f0 	subw   $0x50,0xf01b588c
f01006d1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006d2:	8b 0d 84 58 1b f0    	mov    0xf01b5884,%ecx
f01006d8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006dd:	89 ca                	mov    %ecx,%edx
f01006df:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006e0:	0f b7 35 8c 58 1b f0 	movzwl 0xf01b588c,%esi
f01006e7:	8d 59 01             	lea    0x1(%ecx),%ebx
f01006ea:	89 f0                	mov    %esi,%eax
f01006ec:	66 c1 e8 08          	shr    $0x8,%ax
f01006f0:	89 da                	mov    %ebx,%edx
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006f8:	89 ca                	mov    %ecx,%edx
f01006fa:	ee                   	out    %al,(%dx)
f01006fb:	89 f0                	mov    %esi,%eax
f01006fd:	89 da                	mov    %ebx,%edx
f01006ff:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100700:	83 c4 10             	add    $0x10,%esp
f0100703:	5b                   	pop    %ebx
f0100704:	5e                   	pop    %esi
f0100705:	5d                   	pop    %ebp
f0100706:	c3                   	ret    

f0100707 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100707:	55                   	push   %ebp
f0100708:	89 e5                	mov    %esp,%ebp
f010070a:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f010070d:	e8 fb fb ff ff       	call   f010030d <cga_init>
	kbd_init();
f0100712:	e8 df fc ff ff       	call   f01003f6 <kbd_init>
	serial_init();
f0100717:	e8 70 fb ff ff       	call   f010028c <serial_init>

	if (!serial_exists)
f010071c:	83 3d 80 58 1b f0 00 	cmpl   $0x0,0xf01b5880
f0100723:	75 0c                	jne    f0100731 <cons_init+0x2a>
		cprintf("Serial port does not exist!\n");
f0100725:	c7 04 24 d9 4f 10 f0 	movl   $0xf0104fd9,(%esp)
f010072c:	e8 91 2a 00 00       	call   f01031c2 <cprintf>
}
f0100731:	c9                   	leave  
f0100732:	c3                   	ret    

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	89 04 24             	mov    %eax,(%esp)
f010073f:	e8 33 fd ff ff       	call   f0100477 <cons_putc>
}
f0100744:	c9                   	leave  
f0100745:	c3                   	ret    

f0100746 <getchar>:

int
getchar(void)
{
f0100746:	55                   	push   %ebp
f0100747:	89 e5                	mov    %esp,%ebp
f0100749:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010074c:	e8 e3 fc ff ff       	call   f0100434 <cons_getc>
f0100751:	85 c0                	test   %eax,%eax
f0100753:	74 f7                	je     f010074c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100755:	c9                   	leave  
f0100756:	c3                   	ret    

f0100757 <iscons>:

int
iscons(int fdnum)
{
f0100757:	55                   	push   %ebp
f0100758:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010075a:	b8 01 00 00 00       	mov    $0x1,%eax
f010075f:	5d                   	pop    %ebp
f0100760:	c3                   	ret    
	...

f0100770 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100770:	55                   	push   %ebp
f0100771:	89 e5                	mov    %esp,%ebp
f0100773:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100776:	c7 04 24 f0 53 10 f0 	movl   $0xf01053f0,(%esp)
f010077d:	e8 40 2a 00 00       	call   f01031c2 <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100782:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100789:	00 
f010078a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100791:	f0 
f0100792:	c7 04 24 bc 54 10 f0 	movl   $0xf01054bc,(%esp)
f0100799:	e8 24 2a 00 00       	call   f01031c2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010079e:	c7 44 24 08 75 4f 10 	movl   $0x104f75,0x8(%esp)
f01007a5:	00 
f01007a6:	c7 44 24 04 75 4f 10 	movl   $0xf0104f75,0x4(%esp)
f01007ad:	f0 
f01007ae:	c7 04 24 e0 54 10 f0 	movl   $0xf01054e0,(%esp)
f01007b5:	e8 08 2a 00 00       	call   f01031c2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007ba:	c7 44 24 08 5e 58 1b 	movl   $0x1b585e,0x8(%esp)
f01007c1:	00 
f01007c2:	c7 44 24 04 5e 58 1b 	movl   $0xf01b585e,0x4(%esp)
f01007c9:	f0 
f01007ca:	c7 04 24 04 55 10 f0 	movl   $0xf0105504,(%esp)
f01007d1:	e8 ec 29 00 00       	call   f01031c2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007d6:	c7 44 24 08 70 67 1b 	movl   $0x1b6770,0x8(%esp)
f01007dd:	00 
f01007de:	c7 44 24 04 70 67 1b 	movl   $0xf01b6770,0x4(%esp)
f01007e5:	f0 
f01007e6:	c7 04 24 28 55 10 f0 	movl   $0xf0105528,(%esp)
f01007ed:	e8 d0 29 00 00       	call   f01031c2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-_start+1023)/1024);
f01007f2:	b8 6f 6b 1b f0       	mov    $0xf01b6b6f,%eax
f01007f7:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007fc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100802:	85 c0                	test   %eax,%eax
f0100804:	0f 48 c2             	cmovs  %edx,%eax
f0100807:	c1 f8 0a             	sar    $0xa,%eax
f010080a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080e:	c7 04 24 4c 55 10 f0 	movl   $0xf010554c,(%esp)
f0100815:	e8 a8 29 00 00       	call   f01031c2 <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010081a:	b8 00 00 00 00       	mov    $0x0,%eax
f010081f:	c9                   	leave  
f0100820:	c3                   	ret    

f0100821 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100821:	55                   	push   %ebp
f0100822:	89 e5                	mov    %esp,%ebp
f0100824:	53                   	push   %ebx
f0100825:	83 ec 14             	sub    $0x14,%esp
f0100828:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010082d:	8b 83 44 56 10 f0    	mov    -0xfefa9bc(%ebx),%eax
f0100833:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100837:	8b 83 40 56 10 f0    	mov    -0xfefa9c0(%ebx),%eax
f010083d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100841:	c7 04 24 09 54 10 f0 	movl   $0xf0105409,(%esp)
f0100848:	e8 75 29 00 00       	call   f01031c2 <cprintf>
f010084d:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100850:	83 fb 24             	cmp    $0x24,%ebx
f0100853:	75 d8                	jne    f010082d <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100855:	b8 00 00 00 00       	mov    $0x0,%eax
f010085a:	83 c4 14             	add    $0x14,%esp
f010085d:	5b                   	pop    %ebx
f010085e:	5d                   	pop    %ebp
f010085f:	c3                   	ret    

f0100860 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100860:	55                   	push   %ebp
f0100861:	89 e5                	mov    %esp,%ebp
f0100863:	57                   	push   %edi
f0100864:	56                   	push   %esi
f0100865:	53                   	push   %ebx
f0100866:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100869:	c7 04 24 78 55 10 f0 	movl   $0xf0105578,(%esp)
f0100870:	e8 4d 29 00 00       	call   f01031c2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100875:	c7 04 24 9c 55 10 f0 	movl   $0xf010559c,(%esp)
f010087c:	e8 41 29 00 00       	call   f01031c2 <cprintf>

	// if (tf != NULL)
	// 	print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
f0100881:	c7 04 24 12 54 10 f0 	movl   $0xf0105412,(%esp)
f0100888:	e8 d3 3f 00 00       	call   f0104860 <readline>
f010088d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010088f:	85 c0                	test   %eax,%eax
f0100891:	74 ee                	je     f0100881 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100893:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010089a:	be 00 00 00 00       	mov    $0x0,%esi
f010089f:	eb 06                	jmp    f01008a7 <monitor+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008a1:	c6 03 00             	movb   $0x0,(%ebx)
f01008a4:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008a7:	0f b6 03             	movzbl (%ebx),%eax
f01008aa:	84 c0                	test   %al,%al
f01008ac:	74 6d                	je     f010091b <monitor+0xbb>
f01008ae:	0f be c0             	movsbl %al,%eax
f01008b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b5:	c7 04 24 16 54 10 f0 	movl   $0xf0105416,(%esp)
f01008bc:	e8 ba 41 00 00       	call   f0104a7b <strchr>
f01008c1:	85 c0                	test   %eax,%eax
f01008c3:	75 dc                	jne    f01008a1 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f01008c5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008c8:	74 51                	je     f010091b <monitor+0xbb>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008ca:	83 fe 0f             	cmp    $0xf,%esi
f01008cd:	8d 76 00             	lea    0x0(%esi),%esi
f01008d0:	75 16                	jne    f01008e8 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008d2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008d9:	00 
f01008da:	c7 04 24 1b 54 10 f0 	movl   $0xf010541b,(%esp)
f01008e1:	e8 dc 28 00 00       	call   f01031c2 <cprintf>
f01008e6:	eb 99                	jmp    f0100881 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f01008e8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008ec:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ef:	0f b6 03             	movzbl (%ebx),%eax
f01008f2:	84 c0                	test   %al,%al
f01008f4:	75 0c                	jne    f0100902 <monitor+0xa2>
f01008f6:	eb af                	jmp    f01008a7 <monitor+0x47>
			buf++;
f01008f8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008fb:	0f b6 03             	movzbl (%ebx),%eax
f01008fe:	84 c0                	test   %al,%al
f0100900:	74 a5                	je     f01008a7 <monitor+0x47>
f0100902:	0f be c0             	movsbl %al,%eax
f0100905:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100909:	c7 04 24 16 54 10 f0 	movl   $0xf0105416,(%esp)
f0100910:	e8 66 41 00 00       	call   f0104a7b <strchr>
f0100915:	85 c0                	test   %eax,%eax
f0100917:	74 df                	je     f01008f8 <monitor+0x98>
f0100919:	eb 8c                	jmp    f01008a7 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f010091b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100922:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100923:	85 f6                	test   %esi,%esi
f0100925:	0f 84 56 ff ff ff    	je     f0100881 <monitor+0x21>
f010092b:	bb 40 56 10 f0       	mov    $0xf0105640,%ebx
f0100930:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100935:	8b 03                	mov    (%ebx),%eax
f0100937:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010093e:	89 04 24             	mov    %eax,(%esp)
f0100941:	e8 ba 40 00 00       	call   f0104a00 <strcmp>
f0100946:	85 c0                	test   %eax,%eax
f0100948:	75 24                	jne    f010096e <monitor+0x10e>
			return commands[i].func(argc, argv, tf);
f010094a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010094d:	8b 55 08             	mov    0x8(%ebp),%edx
f0100950:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100954:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100957:	89 54 24 04          	mov    %edx,0x4(%esp)
f010095b:	89 34 24             	mov    %esi,(%esp)
f010095e:	ff 14 85 48 56 10 f0 	call   *-0xfefa9b8(,%eax,4)
	// 	print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100965:	85 c0                	test   %eax,%eax
f0100967:	78 28                	js     f0100991 <monitor+0x131>
f0100969:	e9 13 ff ff ff       	jmp    f0100881 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010096e:	83 c7 01             	add    $0x1,%edi
f0100971:	83 c3 0c             	add    $0xc,%ebx
f0100974:	83 ff 03             	cmp    $0x3,%edi
f0100977:	75 bc                	jne    f0100935 <monitor+0xd5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100979:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010097c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100980:	c7 04 24 38 54 10 f0 	movl   $0xf0105438,(%esp)
f0100987:	e8 36 28 00 00       	call   f01031c2 <cprintf>
f010098c:	e9 f0 fe ff ff       	jmp    f0100881 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100991:	83 c4 5c             	add    $0x5c,%esp
f0100994:	5b                   	pop    %ebx
f0100995:	5e                   	pop    %esi
f0100996:	5f                   	pop    %edi
f0100997:	5d                   	pop    %ebp
f0100998:	c3                   	ret    

f0100999 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100999:	55                   	push   %ebp
f010099a:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010099c:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f010099f:	5d                   	pop    %ebp
f01009a0:	c3                   	ret    

f01009a1 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01009a1:	55                   	push   %ebp
f01009a2:	89 e5                	mov    %esp,%ebp
f01009a4:	57                   	push   %edi
f01009a5:	56                   	push   %esi
f01009a6:	53                   	push   %ebx
f01009a7:	83 ec 4c             	sub    $0x4c,%esp
	unsigned int ebp;
	unsigned int eip;
	struct Eipdebuginfo debug_info;
	int i;	// loop

	cprintf("Stack backtrace:\n");
f01009aa:	c7 04 24 4e 54 10 f0 	movl   $0xf010544e,(%esp)
f01009b1:	e8 0c 28 00 00       	call   f01031c2 <cprintf>
	// current eip and print current function.
	// cprintf is a function so init after it in case.
	eip = read_eip();
f01009b6:	e8 de ff ff ff       	call   f0100999 <read_eip>
f01009bb:	89 c7                	mov    %eax,%edi

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01009bd:	89 ea                	mov    %ebp,%edx
f01009bf:	89 d6                	mov    %edx,%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
f01009c1:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf is a function so init after it in case.
	eip = read_eip();
	ebp = read_ebp();

	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f01009c6:	85 d2                	test   %edx,%edx
f01009c8:	0f 84 cd 00 00 00    	je     f0100a9b <mon_backtrace+0xfa>
	{
		if (debuginfo_eip(eip, &debug_info) >= 0)
f01009ce:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01009d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d5:	89 3c 24             	mov    %edi,(%esp)
f01009d8:	e8 b5 35 00 00       	call   f0103f92 <debuginfo_eip>
f01009dd:	85 c0                	test   %eax,%eax
f01009df:	0f 88 a5 00 00 00    	js     f0100a8a <mon_backtrace+0xe9>
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
f01009e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f3:	c7 04 24 ab 4f 10 f0 	movl   $0xf0104fab,(%esp)
f01009fa:	e8 c3 27 00 00       	call   f01031c2 <cprintf>
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f01009ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100a03:	7e 24                	jle    f0100a29 <mon_backtrace+0x88>
f0100a05:	bb 00 00 00 00       	mov    $0x0,%ebx
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
f0100a0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a0d:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100a11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a15:	c7 04 24 60 54 10 f0 	movl   $0xf0105460,(%esp)
f0100a1c:	e8 a1 27 00 00       	call   f01031c2 <cprintf>
	while (ebp != 0)
	{
		if (debuginfo_eip(eip, &debug_info) >= 0)
		{
			cprintf("%s:%d: ", debug_info.eip_file, debug_info.eip_line);
			for (i = 0; i < debug_info.eip_fn_namelen; ++i)
f0100a21:	83 c3 01             	add    $0x1,%ebx
f0100a24:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100a27:	7f e1                	jg     f0100a0a <mon_backtrace+0x69>
			{
				cprintf("%c", debug_info.eip_fn_name[i]);
			}
			cprintf("+%x -%d\n", eip-debug_info.eip_fn_addr, debug_info.eip_fn_narg);
f0100a29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a2c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a30:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100a33:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100a37:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0100a3e:	e8 7f 27 00 00       	call   f01031c2 <cprintf>
		{
			cprintf("debuginfo_eip() failed\n");
			return -1;
		}

		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
f0100a43:	8b 46 14             	mov    0x14(%esi),%eax
f0100a46:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100a4a:	8b 46 10             	mov    0x10(%esi),%eax
f0100a4d:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100a51:	8b 46 0c             	mov    0xc(%esi),%eax
f0100a54:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100a58:	8b 46 08             	mov    0x8(%esi),%eax
f0100a5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a5f:	8b 46 04             	mov    0x4(%esi),%eax
f0100a62:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a66:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a6a:	c7 04 24 c4 55 10 f0 	movl   $0xf01055c4,(%esp)
f0100a71:	e8 4c 27 00 00       	call   f01031c2 <cprintf>
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
f0100a76:	8b 7e 04             	mov    0x4(%esi),%edi
		ebp = *(unsigned int *)ebp;
f0100a79:	8b 36                	mov    (%esi),%esi
	// cprintf is a function so init after it in case.
	eip = read_eip();
	ebp = read_ebp();

	// in entry.S, ebp is set to be zero before calling i386_init.
	while (ebp != 0)
f0100a7b:	85 f6                	test   %esi,%esi
f0100a7d:	0f 85 4b ff ff ff    	jne    f01009ce <mon_backtrace+0x2d>
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x\n", ebp, *((unsigned int *)ebp+1), *((unsigned int *)ebp+2),
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
f0100a83:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a88:	eb 11                	jmp    f0100a9b <mon_backtrace+0xfa>
			}
			cprintf("+%x -%d\n", eip-debug_info.eip_fn_addr, debug_info.eip_fn_narg);
		}
		else
		{
			cprintf("debuginfo_eip() failed\n");
f0100a8a:	c7 04 24 6c 54 10 f0 	movl   $0xf010546c,(%esp)
f0100a91:	e8 2c 27 00 00       	call   f01031c2 <cprintf>
			return -1;
f0100a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			*((unsigned int *)ebp+3), *((unsigned int *)ebp+4), *((unsigned int *)ebp+5));
		eip = *((unsigned int *)ebp+1);
		ebp = *(unsigned int *)ebp;
	}
	return 0;
}
f0100a9b:	83 c4 4c             	add    $0x4c,%esp
f0100a9e:	5b                   	pop    %ebx
f0100a9f:	5e                   	pop    %esi
f0100aa0:	5f                   	pop    %edi
f0100aa1:	5d                   	pop    %ebp
f0100aa2:	c3                   	ret    
	...

f0100ab0 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list has been set up.
// 
static void*
boot_alloc(uint32_t n, uint32_t align)
{
f0100ab0:	55                   	push   %ebp
f0100ab1:	89 e5                	mov    %esp,%ebp
f0100ab3:	83 ec 08             	sub    $0x8,%esp
f0100ab6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100ab9:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100abc:	89 c6                	mov    %eax,%esi
f0100abe:	89 d1                	mov    %edx,%ecx
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment -
	// i.e., the first virtual address that the linker
	// did _not_ assign to any kernel code or global variables.
	if (boot_freemem == 0)
		boot_freemem = end;
f0100ac0:	83 3d b4 5a 1b f0 00 	cmpl   $0x0,0xf01b5ab4

	// LAB 2: Your code here:
	//	Step 1: round boot_freemem up to be aligned properly
	boot_freemem = ROUNDUP(boot_freemem, align);
f0100ac7:	b8 70 67 1b f0       	mov    $0xf01b6770,%eax
f0100acc:	0f 45 05 b4 5a 1b f0 	cmovne 0xf01b5ab4,%eax
f0100ad3:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
f0100ad7:	89 d8                	mov    %ebx,%eax
f0100ad9:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ade:	f7 f1                	div    %ecx
f0100ae0:	29 d3                	sub    %edx,%ebx
	//	Step 2: save current value of boot_freemem as allocated chunk
	v = boot_freemem;
	//	Step 3: increase boot_freemem to record allocation
	boot_freemem += ROUNDUP(n, align);
f0100ae2:	8d 74 0e ff          	lea    -0x1(%esi,%ecx,1),%esi
f0100ae6:	89 f0                	mov    %esi,%eax
f0100ae8:	ba 00 00 00 00       	mov    $0x0,%edx
f0100aed:	f7 f1                	div    %ecx
f0100aef:	29 d6                	sub    %edx,%esi
f0100af1:	01 de                	add    %ebx,%esi
f0100af3:	89 35 b4 5a 1b f0    	mov    %esi,0xf01b5ab4
	//	Step 4: return allocated chunk
	return v;
}
f0100af9:	89 d8                	mov    %ebx,%eax
f0100afb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100afe:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100b01:	89 ec                	mov    %ebp,%esp
f0100b03:	5d                   	pop    %ebp
f0100b04:	c3                   	ret    

f0100b05 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b05:	55                   	push   %ebp
f0100b06:	89 e5                	mov    %esp,%ebp
f0100b08:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b0b:	89 d1                	mov    %edx,%ecx
f0100b0d:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b10:	8b 0c 88             	mov    (%eax,%ecx,4),%ecx
		return ~0;
f0100b13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b18:	f6 c1 01             	test   $0x1,%cl
f0100b1b:	74 57                	je     f0100b74 <check_va2pa+0x6f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b1d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100b23:	89 c8                	mov    %ecx,%eax
f0100b25:	c1 e8 0c             	shr    $0xc,%eax
f0100b28:	3b 05 60 67 1b f0    	cmp    0xf01b6760,%eax
f0100b2e:	72 20                	jb     f0100b50 <check_va2pa+0x4b>
f0100b30:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100b34:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0100b3b:	f0 
f0100b3c:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0100b43:	00 
f0100b44:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0100b4b:	e8 82 f5 ff ff       	call   f01000d2 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b50:	c1 ea 0c             	shr    $0xc,%edx
f0100b53:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b59:	8b 84 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%eax
f0100b60:	89 c2                	mov    %eax,%edx
f0100b62:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b6a:	85 d2                	test   %edx,%edx
f0100b6c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b71:	0f 44 c2             	cmove  %edx,%eax
}
f0100b74:	c9                   	leave  
f0100b75:	c3                   	ret    

f0100b76 <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0100b76:	55                   	push   %ebp
f0100b77:	89 e5                	mov    %esp,%ebp
f0100b79:	83 ec 18             	sub    $0x18,%esp
f0100b7c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100b7f:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100b82:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b84:	89 04 24             	mov    %eax,(%esp)
f0100b87:	e8 78 24 00 00       	call   f0103004 <mc146818_read>
f0100b8c:	89 c6                	mov    %eax,%esi
f0100b8e:	83 c3 01             	add    $0x1,%ebx
f0100b91:	89 1c 24             	mov    %ebx,(%esp)
f0100b94:	e8 6b 24 00 00       	call   f0103004 <mc146818_read>
f0100b99:	c1 e0 08             	shl    $0x8,%eax
f0100b9c:	09 f0                	or     %esi,%eax
}
f0100b9e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100ba1:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100ba4:	89 ec                	mov    %ebp,%esp
f0100ba6:	5d                   	pop    %ebp
f0100ba7:	c3                   	ret    

f0100ba8 <i386_detect_memory>:

void
i386_detect_memory(void)
{
f0100ba8:	55                   	push   %ebp
f0100ba9:	89 e5                	mov    %esp,%ebp
f0100bab:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0100bae:	b8 15 00 00 00       	mov    $0x15,%eax
f0100bb3:	e8 be ff ff ff       	call   f0100b76 <nvram_read>
f0100bb8:	c1 e0 0a             	shl    $0xa,%eax
f0100bbb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bc0:	a3 a8 5a 1b f0       	mov    %eax,0xf01b5aa8
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0100bc5:	b8 17 00 00 00       	mov    $0x17,%eax
f0100bca:	e8 a7 ff ff ff       	call   f0100b76 <nvram_read>
f0100bcf:	c1 e0 0a             	shl    $0xa,%eax
f0100bd2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bd7:	a3 ac 5a 1b f0       	mov    %eax,0xf01b5aac

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0100bdc:	85 c0                	test   %eax,%eax
f0100bde:	74 0c                	je     f0100bec <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0100be0:	05 00 00 10 00       	add    $0x100000,%eax
f0100be5:	a3 b0 5a 1b f0       	mov    %eax,0xf01b5ab0
f0100bea:	eb 0a                	jmp    f0100bf6 <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0100bec:	a1 a8 5a 1b f0       	mov    0xf01b5aa8,%eax
f0100bf1:	a3 b0 5a 1b f0       	mov    %eax,0xf01b5ab0

	npage = maxpa / PGSIZE;
f0100bf6:	a1 b0 5a 1b f0       	mov    0xf01b5ab0,%eax
f0100bfb:	89 c2                	mov    %eax,%edx
f0100bfd:	c1 ea 0c             	shr    $0xc,%edx
f0100c00:	89 15 60 67 1b f0    	mov    %edx,0xf01b6760

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100c06:	c1 e8 0a             	shr    $0xa,%eax
f0100c09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c0d:	c7 04 24 88 56 10 f0 	movl   $0xf0105688,(%esp)
f0100c14:	e8 a9 25 00 00       	call   f01031c2 <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100c19:	a1 ac 5a 1b f0       	mov    0xf01b5aac,%eax
f0100c1e:	c1 e8 0a             	shr    $0xa,%eax
f0100c21:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c25:	a1 a8 5a 1b f0       	mov    0xf01b5aa8,%eax
f0100c2a:	c1 e8 0a             	shr    $0xa,%eax
f0100c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c31:	c7 04 24 1d 5c 10 f0 	movl   $0xf0105c1d,(%esp)
f0100c38:	e8 85 25 00 00       	call   f01031c2 <cprintf>
}
f0100c3d:	c9                   	leave  
f0100c3e:	c3                   	ret    

f0100c3f <page_init>:
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc()
//
void
page_init(void)
{
f0100c3f:	55                   	push   %ebp
f0100c40:	89 e5                	mov    %esp,%ebp
f0100c42:	56                   	push   %esi
f0100c43:	53                   	push   %ebx
f0100c44:	83 ec 10             	sub    $0x10,%esp
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f0100c47:	c7 05 b8 5a 1b f0 00 	movl   $0x0,0xf01b5ab8
f0100c4e:	00 00 00 
	for (i = 0; i < npage; i++) {
f0100c51:	83 3d 60 67 1b f0 00 	cmpl   $0x0,0xf01b6760
f0100c58:	74 5f                	je     f0100cb9 <page_init+0x7a>
f0100c5a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c5f:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_ref = 0;
f0100c64:	8d 34 52             	lea    (%edx,%edx,2),%esi
f0100c67:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
f0100c6e:	8b 1d 6c 67 1b f0    	mov    0xf01b676c,%ebx
f0100c74:	66 c7 44 13 08 00 00 	movw   $0x0,0x8(%ebx,%edx,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f0100c7b:	8b 0d b8 5a 1b f0    	mov    0xf01b5ab8,%ecx
f0100c81:	89 0c b3             	mov    %ecx,(%ebx,%esi,4)
f0100c84:	85 c9                	test   %ecx,%ecx
f0100c86:	74 11                	je     f0100c99 <page_init+0x5a>
f0100c88:	8b 1d 6c 67 1b f0    	mov    0xf01b676c,%ebx
f0100c8e:	01 d3                	add    %edx,%ebx
f0100c90:	8b 0d b8 5a 1b f0    	mov    0xf01b5ab8,%ecx
f0100c96:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100c99:	03 15 6c 67 1b f0    	add    0xf01b676c,%edx
f0100c9f:	89 15 b8 5a 1b f0    	mov    %edx,0xf01b5ab8
f0100ca5:	c7 42 04 b8 5a 1b f0 	movl   $0xf01b5ab8,0x4(%edx)
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0100cac:	83 c0 01             	add    $0x1,%eax
f0100caf:	89 c2                	mov    %eax,%edx
f0100cb1:	3b 05 60 67 1b f0    	cmp    0xf01b6760,%eax
f0100cb7:	72 ab                	jb     f0100c64 <page_init+0x25>
	// --pgstart;	// protect IOPHYSMEM
	// pgend->pp_link = pgstart;

	// the second method, slow
	// but can edit the .ref to 1
	pages[0].pp_ref = 1;
f0100cb9:	a1 6c 67 1b f0       	mov    0xf01b676c,%eax
f0100cbe:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	// remove the first page, where holds Real Mode IDT
	LIST_REMOVE(&pages[0], pp_link);
f0100cc4:	8b 10                	mov    (%eax),%edx
f0100cc6:	85 d2                	test   %edx,%edx
f0100cc8:	74 06                	je     f0100cd0 <page_init+0x91>
f0100cca:	8b 48 04             	mov    0x4(%eax),%ecx
f0100ccd:	89 4a 04             	mov    %ecx,0x4(%edx)
f0100cd0:	8b 50 04             	mov    0x4(%eax),%edx
f0100cd3:	8b 00                	mov    (%eax),%eax
f0100cd5:	89 02                	mov    %eax,(%edx)
	// remove IO hole and kernel, they are tightly connected
	// notice boot_freemem points to the next byte of free mem, and points to higher mem!
	// so after the last calling "boot_alloc", boot_freemem remains the addr of the end addr of kernel pages plus 1
	for (i = IOPHYSMEM; i < PADDR((unsigned int) boot_freemem); i += PGSIZE)
f0100cd7:	8b 1d b4 5a 1b f0    	mov    0xf01b5ab4,%ebx
f0100cdd:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0100ce3:	76 52                	jbe    f0100d37 <page_init+0xf8>
f0100ce5:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f0100ceb:	81 fb 00 00 0a 00    	cmp    $0xa0000,%ebx
f0100cf1:	76 64                	jbe    f0100d57 <page_init+0x118>
f0100cf3:	ba 00 00 0a 00       	mov    $0xa0000,%edx
	{
		pages[i / PGSIZE].pp_ref = 1;
f0100cf8:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax
f0100cfe:	85 d2                	test   %edx,%edx
f0100d00:	0f 49 c2             	cmovns %edx,%eax
f0100d03:	c1 f8 0c             	sar    $0xc,%eax
f0100d06:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100d09:	c1 e0 02             	shl    $0x2,%eax
f0100d0c:	03 05 6c 67 1b f0    	add    0xf01b676c,%eax
f0100d12:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
		LIST_REMOVE(&pages[i / PGSIZE], pp_link);
f0100d18:	8b 08                	mov    (%eax),%ecx
f0100d1a:	85 c9                	test   %ecx,%ecx
f0100d1c:	74 06                	je     f0100d24 <page_init+0xe5>
f0100d1e:	8b 70 04             	mov    0x4(%eax),%esi
f0100d21:	89 71 04             	mov    %esi,0x4(%ecx)
f0100d24:	8b 48 04             	mov    0x4(%eax),%ecx
f0100d27:	8b 00                	mov    (%eax),%eax
f0100d29:	89 01                	mov    %eax,(%ecx)
	// remove the first page, where holds Real Mode IDT
	LIST_REMOVE(&pages[0], pp_link);
	// remove IO hole and kernel, they are tightly connected
	// notice boot_freemem points to the next byte of free mem, and points to higher mem!
	// so after the last calling "boot_alloc", boot_freemem remains the addr of the end addr of kernel pages plus 1
	for (i = IOPHYSMEM; i < PADDR((unsigned int) boot_freemem); i += PGSIZE)
f0100d2b:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0100d31:	39 da                	cmp    %ebx,%edx
f0100d33:	72 c3                	jb     f0100cf8 <page_init+0xb9>
f0100d35:	eb 20                	jmp    f0100d57 <page_init+0x118>
f0100d37:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100d3b:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f0100d42:	f0 
f0100d43:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
f0100d4a:	00 
f0100d4b:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0100d52:	e8 7b f3 ff ff       	call   f01000d2 <_panic>
	{
		pages[i / PGSIZE].pp_ref = 1;
		LIST_REMOVE(&pages[i / PGSIZE], pp_link);
	}
}
f0100d57:	83 c4 10             	add    $0x10,%esp
f0100d5a:	5b                   	pop    %ebx
f0100d5b:	5e                   	pop    %esi
f0100d5c:	5d                   	pop    %ebp
f0100d5d:	c3                   	ret    

f0100d5e <page_alloc>:
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented 
int
page_alloc(struct Page **pp_store)
{
f0100d5e:	55                   	push   %ebp
f0100d5f:	89 e5                	mov    %esp,%ebp
f0100d61:	83 ec 18             	sub    $0x18,%esp
f0100d64:	8b 55 08             	mov    0x8(%ebp),%edx
	// Fill this function in
	if (LIST_FIRST(&page_free_list) != NULL)
f0100d67:	a1 b8 5a 1b f0       	mov    0xf01b5ab8,%eax
f0100d6c:	85 c0                	test   %eax,%eax
f0100d6e:	74 38                	je     f0100da8 <page_alloc+0x4a>
	{
		// obtain the first page in page_free_list
		*pp_store = LIST_FIRST(&page_free_list);
f0100d70:	89 02                	mov    %eax,(%edx)
		// remove the obtained page in page_free_list
		LIST_REMOVE(*pp_store, pp_link);
f0100d72:	8b 08                	mov    (%eax),%ecx
f0100d74:	85 c9                	test   %ecx,%ecx
f0100d76:	74 06                	je     f0100d7e <page_alloc+0x20>
f0100d78:	8b 40 04             	mov    0x4(%eax),%eax
f0100d7b:	89 41 04             	mov    %eax,0x4(%ecx)
f0100d7e:	8b 02                	mov    (%edx),%eax
f0100d80:	8b 48 04             	mov    0x4(%eax),%ecx
f0100d83:	8b 00                	mov    (%eax),%eax
f0100d85:	89 01                	mov    %eax,(%ecx)
// Note that the corresponding physical page is NOT initialized!
//
static void
page_initpp(struct Page *pp)
{
	memset(pp, 0, sizeof(*pp));
f0100d87:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0100d8e:	00 
f0100d8f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d96:	00 
f0100d97:	8b 02                	mov    (%edx),%eax
f0100d99:	89 04 24             	mov    %eax,(%esp)
f0100d9c:	e8 35 3d 00 00       	call   f0104ad6 <memset>
		*pp_store = LIST_FIRST(&page_free_list);
		// remove the obtained page in page_free_list
		LIST_REMOVE(*pp_store, pp_link);
		// init the page structure
		page_initpp(*pp_store);
		return 0;
f0100da1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100da6:	eb 05                	jmp    f0100dad <page_alloc+0x4f>
	}
	else
	{
		return -E_NO_MEM;
f0100da8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
}
f0100dad:	c9                   	leave  
f0100dae:	c3                   	ret    

f0100daf <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100daf:	55                   	push   %ebp
f0100db0:	89 e5                	mov    %esp,%ebp
f0100db2:	83 ec 18             	sub    $0x18,%esp
f0100db5:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0100db8:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0100dbd:	74 1c                	je     f0100ddb <page_free+0x2c>
	{
		// in case
		panic("pp->pp_ref != 0, but page_free called");
f0100dbf:	c7 44 24 08 d0 56 10 	movl   $0xf01056d0,0x8(%esp)
f0100dc6:	f0 
f0100dc7:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
f0100dce:	00 
f0100dcf:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0100dd6:	e8 f7 f2 ff ff       	call   f01000d2 <_panic>
	}
	else
	{
		LIST_INSERT_HEAD(&page_free_list, pp, pp_link);
f0100ddb:	8b 15 b8 5a 1b f0    	mov    0xf01b5ab8,%edx
f0100de1:	89 10                	mov    %edx,(%eax)
f0100de3:	85 d2                	test   %edx,%edx
f0100de5:	74 09                	je     f0100df0 <page_free+0x41>
f0100de7:	8b 15 b8 5a 1b f0    	mov    0xf01b5ab8,%edx
f0100ded:	89 42 04             	mov    %eax,0x4(%edx)
f0100df0:	a3 b8 5a 1b f0       	mov    %eax,0xf01b5ab8
f0100df5:	c7 40 04 b8 5a 1b f0 	movl   $0xf01b5ab8,0x4(%eax)
	}
}
f0100dfc:	c9                   	leave  
f0100dfd:	c3                   	ret    

f0100dfe <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100dfe:	55                   	push   %ebp
f0100dff:	89 e5                	mov    %esp,%ebp
f0100e01:	83 ec 18             	sub    $0x18,%esp
f0100e04:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100e07:	0f b7 50 08          	movzwl 0x8(%eax),%edx
f0100e0b:	83 ea 01             	sub    $0x1,%edx
f0100e0e:	66 89 50 08          	mov    %dx,0x8(%eax)
f0100e12:	66 85 d2             	test   %dx,%dx
f0100e15:	75 08                	jne    f0100e1f <page_decref+0x21>
		page_free(pp);
f0100e17:	89 04 24             	mov    %eax,(%esp)
f0100e1a:	e8 90 ff ff ff       	call   f0100daf <page_free>
}
f0100e1f:	c9                   	leave  
f0100e20:	c3                   	ret    

f0100e21 <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e21:	55                   	push   %ebp
f0100e22:	89 e5                	mov    %esp,%ebp
f0100e24:	56                   	push   %esi
f0100e25:	53                   	push   %ebx
f0100e26:	83 ec 20             	sub    $0x20,%esp
f0100e29:	8b 75 0c             	mov    0xc(%ebp),%esi
	// new_pg doesn't need an initialization, because
	// it will be casted to the existing space
	struct Page *new_pt;
	// attention to the priority of operations
	// PTE_P means whether it is there in memory
	if ((pgdir[PDX(va)] & PTE_P) != 0)
f0100e2c:	89 f3                	mov    %esi,%ebx
f0100e2e:	c1 eb 16             	shr    $0x16,%ebx
f0100e31:	c1 e3 02             	shl    $0x2,%ebx
f0100e34:	03 5d 08             	add    0x8(%ebp),%ebx
f0100e37:	8b 03                	mov    (%ebx),%eax
f0100e39:	a8 01                	test   $0x1,%al
f0100e3b:	74 47                	je     f0100e84 <pgdir_walk+0x63>
		// and page dir is a page itself, so PTE_ADDR is
		// needed to get the addr of phys page va pointing to.
		// that is the addr of page table
		// remember, pte_addr is a ptr to pte
		// we got ptr to pte through va, and got va through ptr to pte.
		pte_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100e3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e42:	89 c2                	mov    %eax,%edx
f0100e44:	c1 ea 0c             	shr    $0xc,%edx
f0100e47:	3b 15 60 67 1b f0    	cmp    0xf01b6760,%edx
f0100e4d:	72 20                	jb     f0100e6f <pgdir_walk+0x4e>
f0100e4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e53:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0100e5a:	f0 
f0100e5b:	c7 44 24 04 5b 02 00 	movl   $0x25b,0x4(%esp)
f0100e62:	00 
f0100e63:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0100e6a:	e8 63 f2 ff ff       	call   f01000d2 <_panic>
		// now it's time to get final pa through va
		// and remember, pte_addr is an array of pointer to phsy pages
		return &pte_addr[PTX(va)];
f0100e6f:	c1 ee 0a             	shr    $0xa,%esi
f0100e72:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100e78:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100e7f:	e9 ec 00 00 00       	jmp    f0100f70 <pgdir_walk+0x14f>
	}
	else
	{
		if (create == 0)
f0100e84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e88:	0f 84 d6 00 00 00    	je     f0100f64 <pgdir_walk+0x143>
			return NULL;
		}
		else
		{
			// allocate a new page table
			if (page_alloc(&new_pt) == 0)
f0100e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100e91:	89 04 24             	mov    %eax,(%esp)
f0100e94:	e8 c5 fe ff ff       	call   f0100d5e <page_alloc>
f0100e99:	85 c0                	test   %eax,%eax
f0100e9b:	0f 85 ca 00 00 00    	jne    f0100f6b <pgdir_walk+0x14a>
			{
				new_pt->pp_ref = 1;
f0100ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ea4:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100eaa:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f0100eb0:	c1 f8 02             	sar    $0x2,%eax
f0100eb3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100eb9:	c1 e0 0c             	shl    $0xc,%eax
				// new page table need to be cleared or a "pa2page" panic
				// or an assertion failed about "check that new page tables get cleared"
				memset(KADDR(page2pa(new_pt)), 0, PGSIZE);
f0100ebc:	89 c2                	mov    %eax,%edx
f0100ebe:	c1 ea 0c             	shr    $0xc,%edx
f0100ec1:	3b 15 60 67 1b f0    	cmp    0xf01b6760,%edx
f0100ec7:	72 20                	jb     f0100ee9 <pgdir_walk+0xc8>
f0100ec9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ecd:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0100ed4:	f0 
f0100ed5:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0100edc:	00 
f0100edd:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0100ee4:	e8 e9 f1 ff ff       	call   f01000d2 <_panic>
f0100ee9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ef0:	00 
f0100ef1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ef8:	00 
f0100ef9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100efe:	89 04 24             	mov    %eax,(%esp)
f0100f01:	e8 d0 3b 00 00       	call   f0104ad6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0100f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f09:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f0100f0f:	c1 f8 02             	sar    $0x2,%eax
f0100f12:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0100f18:	c1 e0 0c             	shl    $0xc,%eax
				// update the pgdir
				// P, present in the memory
				// W, writable; U, user
				// PTE_U must be here; or GP arises when debuggin user process
				pgdir[PDX(va)] = page2pa(new_pt) | PTE_P | PTE_W | PTE_U;
f0100f1b:	83 c8 07             	or     $0x7,%eax
f0100f1e:	89 03                	mov    %eax,(%ebx)
				// then the same with the condition when page table exists in the dir
				pte_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
f0100f20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f25:	89 c2                	mov    %eax,%edx
f0100f27:	c1 ea 0c             	shr    $0xc,%edx
f0100f2a:	3b 15 60 67 1b f0    	cmp    0xf01b6760,%edx
f0100f30:	72 20                	jb     f0100f52 <pgdir_walk+0x131>
f0100f32:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f36:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0100f3d:	f0 
f0100f3e:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f0100f45:	00 
f0100f46:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0100f4d:	e8 80 f1 ff ff       	call   f01000d2 <_panic>
				return &pte_addr[PTX(va)];
f0100f52:	c1 ee 0a             	shr    $0xa,%esi
f0100f55:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100f5b:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100f62:	eb 0c                	jmp    f0100f70 <pgdir_walk+0x14f>
	}
	else
	{
		if (create == 0)
		{
			return NULL;
f0100f64:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f69:	eb 05                	jmp    f0100f70 <pgdir_walk+0x14f>
				pte_addr = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]));
				return &pte_addr[PTX(va)];
			}
			else
			{
				return NULL;
f0100f6b:	b8 00 00 00 00       	mov    $0x0,%eax
			}
		}
	}
}
f0100f70:	83 c4 20             	add    $0x20,%esp
f0100f73:	5b                   	pop    %ebx
f0100f74:	5e                   	pop    %esi
f0100f75:	5d                   	pop    %ebp
f0100f76:	c3                   	ret    

f0100f77 <boot_map_segment>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
{
f0100f77:	55                   	push   %ebp
f0100f78:	89 e5                	mov    %esp,%ebp
f0100f7a:	57                   	push   %edi
f0100f7b:	56                   	push   %esi
f0100f7c:	53                   	push   %ebx
f0100f7d:	83 ec 2c             	sub    $0x2c,%esp
f0100f80:	89 c7                	mov    %eax,%edi
f0100f82:	89 d6                	mov    %edx,%esi
	// Fill this function in
	// better than int i; no worry about overflow.
	unsigned int i;
	pte_t *pte_addr;
	// size in stack, no worry.
	size = ROUNDUP(size, PGSIZE);
f0100f84:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
	// never be reached. the reason is that it is called by boot,
	// there should not be any protected la allocated, and
	// the os programmer should be very careful so that 
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
f0100f8a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100f90:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f93:	74 5a                	je     f0100fef <boot_map_segment+0x78>
f0100f95:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (pte_addr == NULL)
		{
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pte_addr = (pa+i) | perm | PTE_P;
f0100f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f9d:	83 c8 01             	or     $0x1,%eax
f0100fa0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
	{
		// get the page addr
		pte_addr = pgdir_walk(pgdir, (void *)(la+i), 1);
f0100fa3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100faa:	00 
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
f0100fab:	8d 04 33             	lea    (%ebx,%esi,1),%eax
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
	{
		// get the page addr
		pte_addr = pgdir_walk(pgdir, (void *)(la+i), 1);
f0100fae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fb2:	89 3c 24             	mov    %edi,(%esp)
f0100fb5:	e8 67 fe ff ff       	call   f0100e21 <pgdir_walk>
		if (pte_addr == NULL)
f0100fba:	85 c0                	test   %eax,%eax
f0100fbc:	75 1c                	jne    f0100fda <boot_map_segment+0x63>
		{
			panic("failed to map la to pa in boot_map_segment()");
f0100fbe:	c7 44 24 08 f8 56 10 	movl   $0xf01056f8,0x8(%esp)
f0100fc5:	f0 
f0100fc6:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100fcd:	00 
f0100fce:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0100fd5:	e8 f8 f0 ff ff       	call   f01000d2 <_panic>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, physaddr_t pa, int perm)
f0100fda:	8b 55 08             	mov    0x8(%ebp),%edx
f0100fdd:	01 da                	add    %ebx,%edx
		if (pte_addr == NULL)
		{
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pte_addr = (pa+i) | perm | PTE_P;
f0100fdf:	0b 55 e0             	or     -0x20(%ebp),%edx
f0100fe2:	89 10                	mov    %edx,(%eax)
	// never be reached. the reason is that it is called by boot,
	// there should not be any protected la allocated, and
	// the os programmer should be very careful so that 
	// covering allocating won't happen.
	// And what's more, it seems that pa need to be ROUNDUP?
	for (i = 0; i < size; i += PGSIZE)
f0100fe4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100fea:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0100fed:	77 b4                	ja     f0100fa3 <boot_map_segment+0x2c>
			panic("failed to map la to pa in boot_map_segment()");
		}
		// map the phsy addr
		*pte_addr = (pa+i) | perm | PTE_P;
	}
}
f0100fef:	83 c4 2c             	add    $0x2c,%esp
f0100ff2:	5b                   	pop    %ebx
f0100ff3:	5e                   	pop    %esi
f0100ff4:	5f                   	pop    %edi
f0100ff5:	5d                   	pop    %ebp
f0100ff6:	c3                   	ret    

f0100ff7 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100ff7:	55                   	push   %ebp
f0100ff8:	89 e5                	mov    %esp,%ebp
f0100ffa:	53                   	push   %ebx
f0100ffb:	83 ec 14             	sub    $0x14,%esp
f0100ffe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	// never create a new page table
	pte_t *pte_addr = pgdir_walk(pgdir, va, 0);
f0101001:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101008:	00 
f0101009:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101010:	8b 45 08             	mov    0x8(%ebp),%eax
f0101013:	89 04 24             	mov    %eax,(%esp)
f0101016:	e8 06 fe ff ff       	call   f0100e21 <pgdir_walk>
	if (pte_addr == NULL)
f010101b:	85 c0                	test   %eax,%eax
f010101d:	74 3d                	je     f010105c <page_lookup+0x65>
	{
		return NULL;
	}
	else
	{
		if (pte_store)
f010101f:	85 db                	test   %ebx,%ebx
f0101021:	74 02                	je     f0101025 <page_lookup+0x2e>
		{
			// be careful to read the header comment
			*pte_store = pte_addr;
f0101023:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0101025:	8b 00                	mov    (%eax),%eax
f0101027:	c1 e8 0c             	shr    $0xc,%eax
f010102a:	3b 05 60 67 1b f0    	cmp    0xf01b6760,%eax
f0101030:	72 1c                	jb     f010104e <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0101032:	c7 44 24 08 28 57 10 	movl   $0xf0105728,0x8(%esp)
f0101039:	f0 
f010103a:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0101041:	00 
f0101042:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0101049:	e8 84 f0 ff ff       	call   f01000d2 <_panic>
	return &pages[PPN(pa)];
f010104e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0101051:	c1 e0 02             	shl    $0x2,%eax
f0101054:	03 05 6c 67 1b f0    	add    0xf01b676c,%eax
		}
		// pte_addr is ptr to pte, not phsy page addr
		// we need to get pa through ptr to pte, (* is okay)
		// and then get PPN through pa (1), and get page addr
		// through PPN (2); (1) and (2) are done by "pa2page"
		return pa2page(*pte_addr);
f010105a:	eb 05                	jmp    f0101061 <page_lookup+0x6a>
	// Fill this function in
	// never create a new page table
	pte_t *pte_addr = pgdir_walk(pgdir, va, 0);
	if (pte_addr == NULL)
	{
		return NULL;
f010105c:	b8 00 00 00 00       	mov    $0x0,%eax
		// and then get PPN through pa (1), and get page addr
		// through PPN (2); (1) and (2) are done by "pa2page"
		return pa2page(*pte_addr);
		// "pa2page(phsyaddr_t pa)" returns &pages[PPN(pa)];
	}
}
f0101061:	83 c4 14             	add    $0x14,%esp
f0101064:	5b                   	pop    %ebx
f0101065:	5d                   	pop    %ebp
f0101066:	c3                   	ret    

f0101067 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101067:	55                   	push   %ebp
f0101068:	89 e5                	mov    %esp,%ebp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010106a:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f010106f:	85 c0                	test   %eax,%eax
f0101071:	74 08                	je     f010107b <tlb_invalidate+0x14>
f0101073:	8b 55 08             	mov    0x8(%ebp),%edx
f0101076:	39 50 5c             	cmp    %edx,0x5c(%eax)
f0101079:	75 06                	jne    f0101081 <tlb_invalidate+0x1a>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010107b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010107e:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101081:	5d                   	pop    %ebp
f0101082:	c3                   	ret    

f0101083 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101083:	55                   	push   %ebp
f0101084:	89 e5                	mov    %esp,%ebp
f0101086:	83 ec 28             	sub    $0x28,%esp
f0101089:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010108c:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010108f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101092:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// the corresponding pte to set
	pte_t *pt2set;
	// the page found and to unmap
	// and &pg2um is an addr and never equal to 0
	// or it will crash IDT
	struct Page *pg = page_lookup(pgdir, va, &pt2set);
f0101095:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101098:	89 44 24 08          	mov    %eax,0x8(%esp)
f010109c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010a0:	89 34 24             	mov    %esi,(%esp)
f01010a3:	e8 4f ff ff ff       	call   f0100ff7 <page_lookup>
	if (pg == NULL)
f01010a8:	85 c0                	test   %eax,%eax
f01010aa:	74 1d                	je     f01010c9 <page_remove+0x46>
		return;
	}
	else
	{
		// --ref and if ref == 0 then page_free it
		page_decref(pg);
f01010ac:	89 04 24             	mov    %eax,(%esp)
f01010af:	e8 4a fd ff ff       	call   f0100dfe <page_decref>
		// set the pte to zero as asked
		// if code runs here, pte must exist, as pg exists
		*pt2set = 0;
f01010b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f01010bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010c1:	89 34 24             	mov    %esi,(%esp)
f01010c4:	e8 9e ff ff ff       	call   f0101067 <tlb_invalidate>
	}
}
f01010c9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01010cc:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01010cf:	89 ec                	mov    %ebp,%esp
f01010d1:	5d                   	pop    %ebp
f01010d2:	c3                   	ret    

f01010d3 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f01010d3:	55                   	push   %ebp
f01010d4:	89 e5                	mov    %esp,%ebp
f01010d6:	83 ec 28             	sub    $0x28,%esp
f01010d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01010dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01010df:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01010e2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010e5:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	// always create a new page table if there isn't
	// which is "necessary, on demand" in the comment
	pte_t *pte_addr = pgdir_walk(pgdir, va, 1);
f01010e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010ef:	00 
f01010f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01010f7:	89 04 24             	mov    %eax,(%esp)
f01010fa:	e8 22 fd ff ff       	call   f0100e21 <pgdir_walk>
f01010ff:	89 c3                	mov    %eax,%ebx
	if (pte_addr == NULL)
f0101101:	85 c0                	test   %eax,%eax
f0101103:	74 4d                	je     f0101152 <page_insert+0x7f>
		return -E_NO_MEM;
	}
	else
	{
		// increase pp_ref as insertion succeeds
		++(pp->pp_ref);
f0101105:	66 83 46 08 01       	addw   $0x1,0x8(%esi)
		// REMEMBER, pte_addr is a ptr to pte
		// *pte_addr will get the value addressed at pte_addr
		// already a page mapped at va, remove it
		if ((*pte_addr & PTE_P) != 0)
f010110a:	f6 00 01             	testb  $0x1,(%eax)
f010110d:	74 1e                	je     f010112d <page_insert+0x5a>
		{
			page_remove(pgdir, va);
f010110f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101113:	8b 45 08             	mov    0x8(%ebp),%eax
f0101116:	89 04 24             	mov    %eax,(%esp)
f0101119:	e8 65 ff ff ff       	call   f0101083 <page_remove>
			// The TLB must be invalidated 
			// if a page was formerly present at 'va'.
			tlb_invalidate(pgdir, va);
f010111e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101122:	8b 45 08             	mov    0x8(%ebp),%eax
f0101125:	89 04 24             	mov    %eax,(%esp)
f0101128:	e8 3a ff ff ff       	call   f0101067 <tlb_invalidate>
		}
		// again, through pte_addr we should get pa
		*pte_addr = page2pa(pp) | perm | PTE_P;
f010112d:	8b 55 14             	mov    0x14(%ebp),%edx
f0101130:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101133:	2b 35 6c 67 1b f0    	sub    0xf01b676c,%esi
f0101139:	c1 fe 02             	sar    $0x2,%esi
f010113c:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101142:	c1 e0 0c             	shl    $0xc,%eax
f0101145:	89 d6                	mov    %edx,%esi
f0101147:	09 c6                	or     %eax,%esi
f0101149:	89 33                	mov    %esi,(%ebx)
		return 0;
f010114b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101150:	eb 05                	jmp    f0101157 <page_insert+0x84>
	// always create a new page table if there isn't
	// which is "necessary, on demand" in the comment
	pte_t *pte_addr = pgdir_walk(pgdir, va, 1);
	if (pte_addr == NULL)
	{
		return -E_NO_MEM;
f0101152:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		}
		// again, through pte_addr we should get pa
		*pte_addr = page2pa(pp) | perm | PTE_P;
		return 0;
	}
}
f0101157:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010115a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010115d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101160:	89 ec                	mov    %ebp,%esp
f0101162:	5d                   	pop    %ebp
f0101163:	c3                   	ret    

f0101164 <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f0101164:	55                   	push   %ebp
f0101165:	89 e5                	mov    %esp,%ebp
f0101167:	57                   	push   %edi
f0101168:	56                   	push   %esi
f0101169:	53                   	push   %ebx
f010116a:	83 ec 4c             	sub    $0x4c,%esp
	// Delete this line:
	//panic("i386_vm_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	pgdir = boot_alloc(PGSIZE, PGSIZE);
f010116d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101172:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101177:	e8 34 f9 ff ff       	call   f0100ab0 <boot_alloc>
f010117c:	89 c3                	mov    %eax,%ebx
	memset(pgdir, 0, PGSIZE);
f010117e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101185:	00 
f0101186:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010118d:	00 
f010118e:	89 04 24             	mov    %eax,(%esp)
f0101191:	e8 40 39 00 00       	call   f0104ad6 <memset>
	boot_pgdir = pgdir;
f0101196:	89 1d 68 67 1b f0    	mov    %ebx,0xf01b6768
	boot_cr3 = PADDR(pgdir);
f010119c:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01011a2:	77 20                	ja     f01011c4 <i386_vm_init+0x60>
f01011a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01011a8:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f01011af:	f0 
f01011b0:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
f01011b7:	00 
f01011b8:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01011bf:	e8 0e ef ff ff       	call   f01000d2 <_panic>
f01011c4:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01011ca:	a3 64 67 1b f0       	mov    %eax,0xf01b6764
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel RW, user NONE
	pgdir[PDX(VPT)] = PADDR(pgdir)|PTE_W|PTE_P;
f01011cf:	89 c2                	mov    %eax,%edx
f01011d1:	83 ca 03             	or     $0x3,%edx
f01011d4:	89 93 fc 0e 00 00    	mov    %edx,0xefc(%ebx)

	// same for UVPT
	// Permissions: kernel R, user R 
	pgdir[PDX(UVPT)] = PADDR(pgdir)|PTE_U|PTE_P;
f01011da:	83 c8 05             	or     $0x5,%eax
f01011dd:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// The kernel uses this structure to keep track of physical pages;
	// 'npage' equals the number of physical pages in memory.  User-level
	// programs will get read-only access to the array as well.
	// You must allocate the array yourself.
	// Your code goes here: 
	pages = (struct Page *)boot_alloc(npage*sizeof(struct Page), PGSIZE);
f01011e3:	a1 60 67 1b f0       	mov    0xf01b6760,%eax
f01011e8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01011eb:	c1 e0 02             	shl    $0x2,%eax
f01011ee:	ba 00 10 00 00       	mov    $0x1000,%edx
f01011f3:	e8 b8 f8 ff ff       	call   f0100ab0 <boot_alloc>
f01011f8:	a3 6c 67 1b f0       	mov    %eax,0xf01b676c

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV*sizeof(struct Env), PGSIZE);
f01011fd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101202:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101207:	e8 a4 f8 ff ff       	call   f0100ab0 <boot_alloc>
f010120c:	a3 c4 5a 1b f0       	mov    %eax,0xf01b5ac4
	//////////////////////////////////////////////////////////////////////
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_segment or page_insert
	page_init();
f0101211:	e8 29 fa ff ff       	call   f0100c3f <page_init>
	struct Page_list fl;
	
        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f0101216:	a1 b8 5a 1b f0       	mov    0xf01b5ab8,%eax
f010121b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010121e:	85 c0                	test   %eax,%eax
f0101220:	0f 84 89 00 00 00    	je     f01012af <i386_vm_init+0x14b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101226:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f010122c:	c1 f8 02             	sar    $0x2,%eax
f010122f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101235:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101238:	89 c2                	mov    %eax,%edx
f010123a:	c1 ea 0c             	shr    $0xc,%edx
f010123d:	3b 15 60 67 1b f0    	cmp    0xf01b6760,%edx
f0101243:	72 41                	jb     f0101286 <i386_vm_init+0x122>
f0101245:	eb 1f                	jmp    f0101266 <i386_vm_init+0x102>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101247:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f010124d:	c1 f8 02             	sar    $0x2,%eax
f0101250:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101256:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0101259:	89 c2                	mov    %eax,%edx
f010125b:	c1 ea 0c             	shr    $0xc,%edx
f010125e:	3b 15 60 67 1b f0    	cmp    0xf01b6760,%edx
f0101264:	72 20                	jb     f0101286 <i386_vm_init+0x122>
f0101266:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010126a:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0101271:	f0 
f0101272:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0101279:	00 
f010127a:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0101281:	e8 4c ee ff ff       	call   f01000d2 <_panic>
		memset(page2kva(pp0), 0x97, 128);
f0101286:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010128d:	00 
f010128e:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101295:	00 
f0101296:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010129b:	89 04 24             	mov    %eax,(%esp)
f010129e:	e8 33 38 00 00       	call   f0104ad6 <memset>
	struct Page_list fl;
	
        // if there's a page that shouldn't be on
        // the free list, try to make sure it
        // eventually causes trouble.
	LIST_FOREACH(pp0, &page_free_list, pp_link)
f01012a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01012a6:	8b 00                	mov    (%eax),%eax
f01012a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012ab:	85 c0                	test   %eax,%eax
f01012ad:	75 98                	jne    f0101247 <i386_vm_init+0xe3>
		memset(page2kva(pp0), 0x97, 128);

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f01012af:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01012b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01012bd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	assert(page_alloc(&pp0) == 0);
f01012c4:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01012c7:	89 04 24             	mov    %eax,(%esp)
f01012ca:	e8 8f fa ff ff       	call   f0100d5e <page_alloc>
f01012cf:	85 c0                	test   %eax,%eax
f01012d1:	74 24                	je     f01012f7 <i386_vm_init+0x193>
f01012d3:	c7 44 24 0c 47 5c 10 	movl   $0xf0105c47,0xc(%esp)
f01012da:	f0 
f01012db:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01012e2:	f0 
f01012e3:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f01012ea:	00 
f01012eb:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01012f2:	e8 db ed ff ff       	call   f01000d2 <_panic>
	assert(page_alloc(&pp1) == 0);
f01012f7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01012fa:	89 04 24             	mov    %eax,(%esp)
f01012fd:	e8 5c fa ff ff       	call   f0100d5e <page_alloc>
f0101302:	85 c0                	test   %eax,%eax
f0101304:	74 24                	je     f010132a <i386_vm_init+0x1c6>
f0101306:	c7 44 24 0c 72 5c 10 	movl   $0xf0105c72,0xc(%esp)
f010130d:	f0 
f010130e:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101315:	f0 
f0101316:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f010131d:	00 
f010131e:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101325:	e8 a8 ed ff ff       	call   f01000d2 <_panic>
	assert(page_alloc(&pp2) == 0);
f010132a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010132d:	89 04 24             	mov    %eax,(%esp)
f0101330:	e8 29 fa ff ff       	call   f0100d5e <page_alloc>
f0101335:	85 c0                	test   %eax,%eax
f0101337:	74 24                	je     f010135d <i386_vm_init+0x1f9>
f0101339:	c7 44 24 0c 88 5c 10 	movl   $0xf0105c88,0xc(%esp)
f0101340:	f0 
f0101341:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101348:	f0 
f0101349:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
f0101350:	00 
f0101351:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101358:	e8 75 ed ff ff       	call   f01000d2 <_panic>

	assert(pp0);
f010135d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101360:	85 c9                	test   %ecx,%ecx
f0101362:	75 24                	jne    f0101388 <i386_vm_init+0x224>
f0101364:	c7 44 24 0c ac 5c 10 	movl   $0xf0105cac,0xc(%esp)
f010136b:	f0 
f010136c:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101373:	f0 
f0101374:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
f010137b:	00 
f010137c:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101383:	e8 4a ed ff ff       	call   f01000d2 <_panic>
	assert(pp1 && pp1 != pp0);
f0101388:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010138b:	85 d2                	test   %edx,%edx
f010138d:	74 04                	je     f0101393 <i386_vm_init+0x22f>
f010138f:	39 d1                	cmp    %edx,%ecx
f0101391:	75 24                	jne    f01013b7 <i386_vm_init+0x253>
f0101393:	c7 44 24 0c 9e 5c 10 	movl   $0xf0105c9e,0xc(%esp)
f010139a:	f0 
f010139b:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01013a2:	f0 
f01013a3:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f01013aa:	00 
f01013ab:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01013b2:	e8 1b ed ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013ba:	85 c0                	test   %eax,%eax
f01013bc:	74 08                	je     f01013c6 <i386_vm_init+0x262>
f01013be:	39 c2                	cmp    %eax,%edx
f01013c0:	74 04                	je     f01013c6 <i386_vm_init+0x262>
f01013c2:	39 c1                	cmp    %eax,%ecx
f01013c4:	75 24                	jne    f01013ea <i386_vm_init+0x286>
f01013c6:	c7 44 24 0c 48 57 10 	movl   $0xf0105748,0xc(%esp)
f01013cd:	f0 
f01013ce:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01013d5:	f0 
f01013d6:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f01013dd:	00 
f01013de:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01013e5:	e8 e8 ec ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f01013ea:	8b 3d 6c 67 1b f0    	mov    0xf01b676c,%edi
        assert(page2pa(pp0) < npage*PGSIZE);
f01013f0:	8b 35 60 67 1b f0    	mov    0xf01b6760,%esi
f01013f6:	c1 e6 0c             	shl    $0xc,%esi
f01013f9:	29 f9                	sub    %edi,%ecx
f01013fb:	c1 f9 02             	sar    $0x2,%ecx
f01013fe:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101404:	c1 e1 0c             	shl    $0xc,%ecx
f0101407:	39 f1                	cmp    %esi,%ecx
f0101409:	72 24                	jb     f010142f <i386_vm_init+0x2cb>
f010140b:	c7 44 24 0c b0 5c 10 	movl   $0xf0105cb0,0xc(%esp)
f0101412:	f0 
f0101413:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010141a:	f0 
f010141b:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f0101422:	00 
f0101423:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010142a:	e8 a3 ec ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010142f:	29 fa                	sub    %edi,%edx
f0101431:	c1 fa 02             	sar    $0x2,%edx
f0101434:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010143a:	c1 e2 0c             	shl    $0xc,%edx
        assert(page2pa(pp1) < npage*PGSIZE);
f010143d:	39 d6                	cmp    %edx,%esi
f010143f:	77 24                	ja     f0101465 <i386_vm_init+0x301>
f0101441:	c7 44 24 0c cc 5c 10 	movl   $0xf0105ccc,0xc(%esp)
f0101448:	f0 
f0101449:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101450:	f0 
f0101451:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f0101458:	00 
f0101459:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101460:	e8 6d ec ff ff       	call   f01000d2 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101465:	29 f8                	sub    %edi,%eax
f0101467:	c1 f8 02             	sar    $0x2,%eax
f010146a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101470:	c1 e0 0c             	shl    $0xc,%eax
        assert(page2pa(pp2) < npage*PGSIZE);
f0101473:	39 c6                	cmp    %eax,%esi
f0101475:	77 24                	ja     f010149b <i386_vm_init+0x337>
f0101477:	c7 44 24 0c e8 5c 10 	movl   $0xf0105ce8,0xc(%esp)
f010147e:	f0 
f010147f:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101486:	f0 
f0101487:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
f010148e:	00 
f010148f:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101496:	e8 37 ec ff ff       	call   f01000d2 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010149b:	8b 35 b8 5a 1b f0    	mov    0xf01b5ab8,%esi
	LIST_INIT(&page_free_list);
f01014a1:	c7 05 b8 5a 1b f0 00 	movl   $0x0,0xf01b5ab8
f01014a8:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01014ab:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f01014ae:	89 04 24             	mov    %eax,(%esp)
f01014b1:	e8 a8 f8 ff ff       	call   f0100d5e <page_alloc>
f01014b6:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01014b9:	74 24                	je     f01014df <i386_vm_init+0x37b>
f01014bb:	c7 44 24 0c 04 5d 10 	movl   $0xf0105d04,0xc(%esp)
f01014c2:	f0 
f01014c3:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01014ca:	f0 
f01014cb:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f01014d2:	00 
f01014d3:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01014da:	e8 f3 eb ff ff       	call   f01000d2 <_panic>

        // free and re-allocate?
        page_free(pp0);
f01014df:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01014e2:	89 04 24             	mov    %eax,(%esp)
f01014e5:	e8 c5 f8 ff ff       	call   f0100daf <page_free>
        page_free(pp1);
f01014ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01014ed:	89 04 24             	mov    %eax,(%esp)
f01014f0:	e8 ba f8 ff ff       	call   f0100daf <page_free>
        page_free(pp2);
f01014f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01014f8:	89 04 24             	mov    %eax,(%esp)
f01014fb:	e8 af f8 ff ff       	call   f0100daf <page_free>
	pp0 = pp1 = pp2 = 0;
f0101500:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101507:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010150e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	assert(page_alloc(&pp0) == 0);
f0101515:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101518:	89 04 24             	mov    %eax,(%esp)
f010151b:	e8 3e f8 ff ff       	call   f0100d5e <page_alloc>
f0101520:	85 c0                	test   %eax,%eax
f0101522:	74 24                	je     f0101548 <i386_vm_init+0x3e4>
f0101524:	c7 44 24 0c 47 5c 10 	movl   $0xf0105c47,0xc(%esp)
f010152b:	f0 
f010152c:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101533:	f0 
f0101534:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f010153b:	00 
f010153c:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101543:	e8 8a eb ff ff       	call   f01000d2 <_panic>
	assert(page_alloc(&pp1) == 0);
f0101548:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010154b:	89 04 24             	mov    %eax,(%esp)
f010154e:	e8 0b f8 ff ff       	call   f0100d5e <page_alloc>
f0101553:	85 c0                	test   %eax,%eax
f0101555:	74 24                	je     f010157b <i386_vm_init+0x417>
f0101557:	c7 44 24 0c 72 5c 10 	movl   $0xf0105c72,0xc(%esp)
f010155e:	f0 
f010155f:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101566:	f0 
f0101567:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f010156e:	00 
f010156f:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101576:	e8 57 eb ff ff       	call   f01000d2 <_panic>
	assert(page_alloc(&pp2) == 0);
f010157b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010157e:	89 04 24             	mov    %eax,(%esp)
f0101581:	e8 d8 f7 ff ff       	call   f0100d5e <page_alloc>
f0101586:	85 c0                	test   %eax,%eax
f0101588:	74 24                	je     f01015ae <i386_vm_init+0x44a>
f010158a:	c7 44 24 0c 88 5c 10 	movl   $0xf0105c88,0xc(%esp)
f0101591:	f0 
f0101592:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101599:	f0 
f010159a:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
f01015a1:	00 
f01015a2:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01015a9:	e8 24 eb ff ff       	call   f01000d2 <_panic>
	assert(pp0);
f01015ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01015b1:	85 d2                	test   %edx,%edx
f01015b3:	75 24                	jne    f01015d9 <i386_vm_init+0x475>
f01015b5:	c7 44 24 0c ac 5c 10 	movl   $0xf0105cac,0xc(%esp)
f01015bc:	f0 
f01015bd:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01015c4:	f0 
f01015c5:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
f01015cc:	00 
f01015cd:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01015d4:	e8 f9 ea ff ff       	call   f01000d2 <_panic>
	assert(pp1 && pp1 != pp0);
f01015d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01015dc:	85 c9                	test   %ecx,%ecx
f01015de:	74 04                	je     f01015e4 <i386_vm_init+0x480>
f01015e0:	39 ca                	cmp    %ecx,%edx
f01015e2:	75 24                	jne    f0101608 <i386_vm_init+0x4a4>
f01015e4:	c7 44 24 0c 9e 5c 10 	movl   $0xf0105c9e,0xc(%esp)
f01015eb:	f0 
f01015ec:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01015f3:	f0 
f01015f4:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
f01015fb:	00 
f01015fc:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101603:	e8 ca ea ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101608:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010160b:	85 c0                	test   %eax,%eax
f010160d:	74 08                	je     f0101617 <i386_vm_init+0x4b3>
f010160f:	39 c1                	cmp    %eax,%ecx
f0101611:	74 04                	je     f0101617 <i386_vm_init+0x4b3>
f0101613:	39 c2                	cmp    %eax,%edx
f0101615:	75 24                	jne    f010163b <i386_vm_init+0x4d7>
f0101617:	c7 44 24 0c 48 57 10 	movl   $0xf0105748,0xc(%esp)
f010161e:	f0 
f010161f:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101626:	f0 
f0101627:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f010162e:	00 
f010162f:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101636:	e8 97 ea ff ff       	call   f01000d2 <_panic>
	assert(page_alloc(&pp) == -E_NO_MEM);
f010163b:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f010163e:	89 04 24             	mov    %eax,(%esp)
f0101641:	e8 18 f7 ff ff       	call   f0100d5e <page_alloc>
f0101646:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101649:	74 24                	je     f010166f <i386_vm_init+0x50b>
f010164b:	c7 44 24 0c 04 5d 10 	movl   $0xf0105d04,0xc(%esp)
f0101652:	f0 
f0101653:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010165a:	f0 
f010165b:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0101662:	00 
f0101663:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010166a:	e8 63 ea ff ff       	call   f01000d2 <_panic>

	// give free list back
	page_free_list = fl;
f010166f:	89 35 b8 5a 1b f0    	mov    %esi,0xf01b5ab8

	// free the pages we took
	page_free(pp0);
f0101675:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101678:	89 04 24             	mov    %eax,(%esp)
f010167b:	e8 2f f7 ff ff       	call   f0100daf <page_free>
	page_free(pp1);
f0101680:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101683:	89 04 24             	mov    %eax,(%esp)
f0101686:	e8 24 f7 ff ff       	call   f0100daf <page_free>
	page_free(pp2);
f010168b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010168e:	89 04 24             	mov    %eax,(%esp)
f0101691:	e8 19 f7 ff ff       	call   f0100daf <page_free>

	cprintf("check_page_alloc() succeeded!\n");
f0101696:	c7 04 24 68 57 10 f0 	movl   $0xf0105768,(%esp)
f010169d:	e8 20 1b 00 00       	call   f01031c2 <cprintf>
	pte_t *ptep, *ptep1;
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f01016a2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01016a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01016b0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	assert(page_alloc(&pp0) == 0);
f01016b7:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01016ba:	89 04 24             	mov    %eax,(%esp)
f01016bd:	e8 9c f6 ff ff       	call   f0100d5e <page_alloc>
f01016c2:	85 c0                	test   %eax,%eax
f01016c4:	74 24                	je     f01016ea <i386_vm_init+0x586>
f01016c6:	c7 44 24 0c 47 5c 10 	movl   $0xf0105c47,0xc(%esp)
f01016cd:	f0 
f01016ce:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01016d5:	f0 
f01016d6:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f01016dd:	00 
f01016de:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01016e5:	e8 e8 e9 ff ff       	call   f01000d2 <_panic>
	assert(page_alloc(&pp1) == 0);
f01016ea:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01016ed:	89 04 24             	mov    %eax,(%esp)
f01016f0:	e8 69 f6 ff ff       	call   f0100d5e <page_alloc>
f01016f5:	85 c0                	test   %eax,%eax
f01016f7:	74 24                	je     f010171d <i386_vm_init+0x5b9>
f01016f9:	c7 44 24 0c 72 5c 10 	movl   $0xf0105c72,0xc(%esp)
f0101700:	f0 
f0101701:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101708:	f0 
f0101709:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101710:	00 
f0101711:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101718:	e8 b5 e9 ff ff       	call   f01000d2 <_panic>
	assert(page_alloc(&pp2) == 0);
f010171d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0101720:	89 04 24             	mov    %eax,(%esp)
f0101723:	e8 36 f6 ff ff       	call   f0100d5e <page_alloc>
f0101728:	85 c0                	test   %eax,%eax
f010172a:	74 24                	je     f0101750 <i386_vm_init+0x5ec>
f010172c:	c7 44 24 0c 88 5c 10 	movl   $0xf0105c88,0xc(%esp)
f0101733:	f0 
f0101734:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010173b:	f0 
f010173c:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0101743:	00 
f0101744:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010174b:	e8 82 e9 ff ff       	call   f01000d2 <_panic>

	assert(pp0);
f0101750:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101753:	85 d2                	test   %edx,%edx
f0101755:	75 24                	jne    f010177b <i386_vm_init+0x617>
f0101757:	c7 44 24 0c ac 5c 10 	movl   $0xf0105cac,0xc(%esp)
f010175e:	f0 
f010175f:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101766:	f0 
f0101767:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f010176e:	00 
f010176f:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101776:	e8 57 e9 ff ff       	call   f01000d2 <_panic>
	assert(pp1 && pp1 != pp0);
f010177b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010177e:	85 c9                	test   %ecx,%ecx
f0101780:	74 04                	je     f0101786 <i386_vm_init+0x622>
f0101782:	39 ca                	cmp    %ecx,%edx
f0101784:	75 24                	jne    f01017aa <i386_vm_init+0x646>
f0101786:	c7 44 24 0c 9e 5c 10 	movl   $0xf0105c9e,0xc(%esp)
f010178d:	f0 
f010178e:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101795:	f0 
f0101796:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f010179d:	00 
f010179e:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01017a5:	e8 28 e9 ff ff       	call   f01000d2 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017ad:	85 c0                	test   %eax,%eax
f01017af:	74 08                	je     f01017b9 <i386_vm_init+0x655>
f01017b1:	39 c1                	cmp    %eax,%ecx
f01017b3:	74 04                	je     f01017b9 <i386_vm_init+0x655>
f01017b5:	39 c2                	cmp    %eax,%edx
f01017b7:	75 24                	jne    f01017dd <i386_vm_init+0x679>
f01017b9:	c7 44 24 0c 48 57 10 	movl   $0xf0105748,0xc(%esp)
f01017c0:	f0 
f01017c1:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01017c8:	f0 
f01017c9:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01017d0:	00 
f01017d1:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01017d8:	e8 f5 e8 ff ff       	call   f01000d2 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017dd:	a1 b8 5a 1b f0       	mov    0xf01b5ab8,%eax
f01017e2:	89 45 c0             	mov    %eax,-0x40(%ebp)
	LIST_INIT(&page_free_list);
f01017e5:	c7 05 b8 5a 1b f0 00 	movl   $0x0,0xf01b5ab8
f01017ec:	00 00 00 

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f01017ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01017f2:	89 04 24             	mov    %eax,(%esp)
f01017f5:	e8 64 f5 ff ff       	call   f0100d5e <page_alloc>
f01017fa:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01017fd:	74 24                	je     f0101823 <i386_vm_init+0x6bf>
f01017ff:	c7 44 24 0c 04 5d 10 	movl   $0xf0105d04,0xc(%esp)
f0101806:	f0 
f0101807:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010180e:	f0 
f010180f:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0101816:	00 
f0101817:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010181e:	e8 af e8 ff ff       	call   f01000d2 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(boot_pgdir, (void *) 0x0, &ptep) == NULL);
f0101823:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101826:	89 44 24 08          	mov    %eax,0x8(%esp)
f010182a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101831:	00 
f0101832:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101837:	89 04 24             	mov    %eax,(%esp)
f010183a:	e8 b8 f7 ff ff       	call   f0100ff7 <page_lookup>
f010183f:	85 c0                	test   %eax,%eax
f0101841:	74 24                	je     f0101867 <i386_vm_init+0x703>
f0101843:	c7 44 24 0c 88 57 10 	movl   $0xf0105788,0xc(%esp)
f010184a:	f0 
f010184b:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101852:	f0 
f0101853:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f010185a:	00 
f010185b:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101862:	e8 6b e8 ff ff       	call   f01000d2 <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) < 0);
f0101867:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010186e:	00 
f010186f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101876:	00 
f0101877:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010187a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010187e:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101883:	89 04 24             	mov    %eax,(%esp)
f0101886:	e8 48 f8 ff ff       	call   f01010d3 <page_insert>
f010188b:	85 c0                	test   %eax,%eax
f010188d:	78 24                	js     f01018b3 <i386_vm_init+0x74f>
f010188f:	c7 44 24 0c c0 57 10 	movl   $0xf01057c0,0xc(%esp)
f0101896:	f0 
f0101897:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010189e:	f0 
f010189f:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f01018a6:	00 
f01018a7:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01018ae:	e8 1f e8 ff ff       	call   f01000d2 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01018b6:	89 04 24             	mov    %eax,(%esp)
f01018b9:	e8 f1 f4 ff ff       	call   f0100daf <page_free>
	assert(page_insert(boot_pgdir, pp1, 0x0, 0) == 0);
f01018be:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01018c5:	00 
f01018c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018cd:	00 
f01018ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01018d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018d5:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f01018da:	89 04 24             	mov    %eax,(%esp)
f01018dd:	e8 f1 f7 ff ff       	call   f01010d3 <page_insert>
f01018e2:	85 c0                	test   %eax,%eax
f01018e4:	74 24                	je     f010190a <i386_vm_init+0x7a6>
f01018e6:	c7 44 24 0c ec 57 10 	movl   $0xf01057ec,0xc(%esp)
f01018ed:	f0 
f01018ee:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01018f5:	f0 
f01018f6:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f01018fd:	00 
f01018fe:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101905:	e8 c8 e7 ff ff       	call   f01000d2 <_panic>
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f010190a:	8b 35 68 67 1b f0    	mov    0xf01b6768,%esi
f0101910:	8b 7d dc             	mov    -0x24(%ebp),%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101913:	8b 15 6c 67 1b f0    	mov    0xf01b676c,%edx
f0101919:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010191c:	8b 16                	mov    (%esi),%edx
f010191e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101924:	89 f8                	mov    %edi,%eax
f0101926:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f0101929:	c1 f8 02             	sar    $0x2,%eax
f010192c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101932:	c1 e0 0c             	shl    $0xc,%eax
f0101935:	39 c2                	cmp    %eax,%edx
f0101937:	74 24                	je     f010195d <i386_vm_init+0x7f9>
f0101939:	c7 44 24 0c 18 58 10 	movl   $0xf0105818,0xc(%esp)
f0101940:	f0 
f0101941:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101948:	f0 
f0101949:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0101950:	00 
f0101951:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101958:	e8 75 e7 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(boot_pgdir, 0x0) == page2pa(pp1));
f010195d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101962:	89 f0                	mov    %esi,%eax
f0101964:	e8 9c f1 ff ff       	call   f0100b05 <check_va2pa>
f0101969:	8b 55 d8             	mov    -0x28(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010196c:	89 d1                	mov    %edx,%ecx
f010196e:	2b 4d c4             	sub    -0x3c(%ebp),%ecx
f0101971:	c1 f9 02             	sar    $0x2,%ecx
f0101974:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010197a:	c1 e1 0c             	shl    $0xc,%ecx
f010197d:	39 c8                	cmp    %ecx,%eax
f010197f:	74 24                	je     f01019a5 <i386_vm_init+0x841>
f0101981:	c7 44 24 0c 40 58 10 	movl   $0xf0105840,0xc(%esp)
f0101988:	f0 
f0101989:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101990:	f0 
f0101991:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0101998:	00 
f0101999:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01019a0:	e8 2d e7 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 1);
f01019a5:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f01019aa:	74 24                	je     f01019d0 <i386_vm_init+0x86c>
f01019ac:	c7 44 24 0c 21 5d 10 	movl   $0xf0105d21,0xc(%esp)
f01019b3:	f0 
f01019b4:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01019bb:	f0 
f01019bc:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f01019c3:	00 
f01019c4:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01019cb:	e8 02 e7 ff ff       	call   f01000d2 <_panic>
	assert(pp0->pp_ref == 1);
f01019d0:	66 83 7f 08 01       	cmpw   $0x1,0x8(%edi)
f01019d5:	74 24                	je     f01019fb <i386_vm_init+0x897>
f01019d7:	c7 44 24 0c 32 5d 10 	movl   $0xf0105d32,0xc(%esp)
f01019de:	f0 
f01019df:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01019e6:	f0 
f01019e7:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01019ee:	00 
f01019ef:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01019f6:	e8 d7 e6 ff ff       	call   f01000d2 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f01019fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101a02:	00 
f0101a03:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a0a:	00 
f0101a0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a12:	89 34 24             	mov    %esi,(%esp)
f0101a15:	e8 b9 f6 ff ff       	call   f01010d3 <page_insert>
f0101a1a:	85 c0                	test   %eax,%eax
f0101a1c:	74 24                	je     f0101a42 <i386_vm_init+0x8de>
f0101a1e:	c7 44 24 0c 70 58 10 	movl   $0xf0105870,0xc(%esp)
f0101a25:	f0 
f0101a26:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101a2d:	f0 
f0101a2e:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101a35:	00 
f0101a36:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101a3d:	e8 90 e6 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101a42:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a47:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101a4c:	e8 b4 f0 ff ff       	call   f0100b05 <check_va2pa>
f0101a51:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101a54:	89 d1                	mov    %edx,%ecx
f0101a56:	2b 0d 6c 67 1b f0    	sub    0xf01b676c,%ecx
f0101a5c:	c1 f9 02             	sar    $0x2,%ecx
f0101a5f:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101a65:	c1 e1 0c             	shl    $0xc,%ecx
f0101a68:	39 c8                	cmp    %ecx,%eax
f0101a6a:	74 24                	je     f0101a90 <i386_vm_init+0x92c>
f0101a6c:	c7 44 24 0c a8 58 10 	movl   $0xf01058a8,0xc(%esp)
f0101a73:	f0 
f0101a74:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101a7b:	f0 
f0101a7c:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101a83:	00 
f0101a84:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101a8b:	e8 42 e6 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101a90:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101a95:	74 24                	je     f0101abb <i386_vm_init+0x957>
f0101a97:	c7 44 24 0c 43 5d 10 	movl   $0xf0105d43,0xc(%esp)
f0101a9e:	f0 
f0101a9f:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101aa6:	f0 
f0101aa7:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0101aae:	00 
f0101aaf:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101ab6:	e8 17 e6 ff ff       	call   f01000d2 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101abb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101abe:	89 04 24             	mov    %eax,(%esp)
f0101ac1:	e8 98 f2 ff ff       	call   f0100d5e <page_alloc>
f0101ac6:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101ac9:	74 24                	je     f0101aef <i386_vm_init+0x98b>
f0101acb:	c7 44 24 0c 04 5d 10 	movl   $0xf0105d04,0xc(%esp)
f0101ad2:	f0 
f0101ad3:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101ada:	f0 
f0101adb:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101ae2:	00 
f0101ae3:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101aea:	e8 e3 e5 ff ff       	call   f01000d2 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, 0) == 0);
f0101aef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101af6:	00 
f0101af7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101afe:	00 
f0101aff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b06:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101b0b:	89 04 24             	mov    %eax,(%esp)
f0101b0e:	e8 c0 f5 ff ff       	call   f01010d3 <page_insert>
f0101b13:	85 c0                	test   %eax,%eax
f0101b15:	74 24                	je     f0101b3b <i386_vm_init+0x9d7>
f0101b17:	c7 44 24 0c 70 58 10 	movl   $0xf0105870,0xc(%esp)
f0101b1e:	f0 
f0101b1f:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101b26:	f0 
f0101b27:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0101b2e:	00 
f0101b2f:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101b36:	e8 97 e5 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101b3b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b40:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101b45:	e8 bb ef ff ff       	call   f0100b05 <check_va2pa>
f0101b4a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101b4d:	89 d1                	mov    %edx,%ecx
f0101b4f:	2b 0d 6c 67 1b f0    	sub    0xf01b676c,%ecx
f0101b55:	c1 f9 02             	sar    $0x2,%ecx
f0101b58:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101b5e:	c1 e1 0c             	shl    $0xc,%ecx
f0101b61:	39 c8                	cmp    %ecx,%eax
f0101b63:	74 24                	je     f0101b89 <i386_vm_init+0xa25>
f0101b65:	c7 44 24 0c a8 58 10 	movl   $0xf01058a8,0xc(%esp)
f0101b6c:	f0 
f0101b6d:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101b74:	f0 
f0101b75:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0101b7c:	00 
f0101b7d:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101b84:	e8 49 e5 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101b89:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101b8e:	74 24                	je     f0101bb4 <i386_vm_init+0xa50>
f0101b90:	c7 44 24 0c 43 5d 10 	movl   $0xf0105d43,0xc(%esp)
f0101b97:	f0 
f0101b98:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101b9f:	f0 
f0101ba0:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0101ba7:	00 
f0101ba8:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101baf:	e8 1e e5 ff ff       	call   f01000d2 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(page_alloc(&pp) == -E_NO_MEM);
f0101bb4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101bb7:	89 04 24             	mov    %eax,(%esp)
f0101bba:	e8 9f f1 ff ff       	call   f0100d5e <page_alloc>
f0101bbf:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101bc2:	74 24                	je     f0101be8 <i386_vm_init+0xa84>
f0101bc4:	c7 44 24 0c 04 5d 10 	movl   $0xf0105d04,0xc(%esp)
f0101bcb:	f0 
f0101bcc:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101bd3:	f0 
f0101bd4:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101bdb:	00 
f0101bdc:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101be3:	e8 ea e4 ff ff       	call   f01000d2 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = KADDR(PTE_ADDR(boot_pgdir[PDX(PGSIZE)]));
f0101be8:	8b 15 68 67 1b f0    	mov    0xf01b6768,%edx
f0101bee:	8b 02                	mov    (%edx),%eax
f0101bf0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101bf5:	89 c1                	mov    %eax,%ecx
f0101bf7:	c1 e9 0c             	shr    $0xc,%ecx
f0101bfa:	3b 0d 60 67 1b f0    	cmp    0xf01b6760,%ecx
f0101c00:	72 20                	jb     f0101c22 <i386_vm_init+0xabe>
f0101c02:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c06:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0101c0d:	f0 
f0101c0e:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0101c15:	00 
f0101c16:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101c1d:	e8 b0 e4 ff ff       	call   f01000d2 <_panic>
f0101c22:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(boot_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c31:	00 
f0101c32:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c39:	00 
f0101c3a:	89 14 24             	mov    %edx,(%esp)
f0101c3d:	e8 df f1 ff ff       	call   f0100e21 <pgdir_walk>
f0101c42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101c45:	83 c2 04             	add    $0x4,%edx
f0101c48:	39 d0                	cmp    %edx,%eax
f0101c4a:	74 24                	je     f0101c70 <i386_vm_init+0xb0c>
f0101c4c:	c7 44 24 0c d8 58 10 	movl   $0xf01058d8,0xc(%esp)
f0101c53:	f0 
f0101c54:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101c5b:	f0 
f0101c5c:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101c63:	00 
f0101c64:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101c6b:	e8 62 e4 ff ff       	call   f01000d2 <_panic>

	// should be able to change permissions too.
	assert(page_insert(boot_pgdir, pp2, (void*) PGSIZE, PTE_U) == 0);
f0101c70:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0101c77:	00 
f0101c78:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c7f:	00 
f0101c80:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c87:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101c8c:	89 04 24             	mov    %eax,(%esp)
f0101c8f:	e8 3f f4 ff ff       	call   f01010d3 <page_insert>
f0101c94:	85 c0                	test   %eax,%eax
f0101c96:	74 24                	je     f0101cbc <i386_vm_init+0xb58>
f0101c98:	c7 44 24 0c 18 59 10 	movl   $0xf0105918,0xc(%esp)
f0101c9f:	f0 
f0101ca0:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101ca7:	f0 
f0101ca8:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101caf:	00 
f0101cb0:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101cb7:	e8 16 e4 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp2));
f0101cbc:	8b 35 68 67 1b f0    	mov    0xf01b6768,%esi
f0101cc2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc7:	89 f0                	mov    %esi,%eax
f0101cc9:	e8 37 ee ff ff       	call   f0100b05 <check_va2pa>
f0101cce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101cd1:	89 d1                	mov    %edx,%ecx
f0101cd3:	2b 0d 6c 67 1b f0    	sub    0xf01b676c,%ecx
f0101cd9:	c1 f9 02             	sar    $0x2,%ecx
f0101cdc:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101ce2:	c1 e1 0c             	shl    $0xc,%ecx
f0101ce5:	39 c8                	cmp    %ecx,%eax
f0101ce7:	74 24                	je     f0101d0d <i386_vm_init+0xba9>
f0101ce9:	c7 44 24 0c a8 58 10 	movl   $0xf01058a8,0xc(%esp)
f0101cf0:	f0 
f0101cf1:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101cf8:	f0 
f0101cf9:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101d00:	00 
f0101d01:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101d08:	e8 c5 e3 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 1);
f0101d0d:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101d12:	74 24                	je     f0101d38 <i386_vm_init+0xbd4>
f0101d14:	c7 44 24 0c 43 5d 10 	movl   $0xf0105d43,0xc(%esp)
f0101d1b:	f0 
f0101d1c:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101d23:	f0 
f0101d24:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101d2b:	00 
f0101d2c:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101d33:	e8 9a e3 ff ff       	call   f01000d2 <_panic>
	assert(*pgdir_walk(boot_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d3f:	00 
f0101d40:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d47:	00 
f0101d48:	89 34 24             	mov    %esi,(%esp)
f0101d4b:	e8 d1 f0 ff ff       	call   f0100e21 <pgdir_walk>
f0101d50:	f6 00 04             	testb  $0x4,(%eax)
f0101d53:	75 24                	jne    f0101d79 <i386_vm_init+0xc15>
f0101d55:	c7 44 24 0c 54 59 10 	movl   $0xf0105954,0xc(%esp)
f0101d5c:	f0 
f0101d5d:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101d64:	f0 
f0101d65:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101d6c:	00 
f0101d6d:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101d74:	e8 59 e3 ff ff       	call   f01000d2 <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(boot_pgdir, pp0, (void*) PTSIZE, 0) < 0);
f0101d79:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101d80:	00 
f0101d81:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101d88:	00 
f0101d89:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101d90:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101d95:	89 04 24             	mov    %eax,(%esp)
f0101d98:	e8 36 f3 ff ff       	call   f01010d3 <page_insert>
f0101d9d:	85 c0                	test   %eax,%eax
f0101d9f:	78 24                	js     f0101dc5 <i386_vm_init+0xc61>
f0101da1:	c7 44 24 0c 88 59 10 	movl   $0xf0105988,0xc(%esp)
f0101da8:	f0 
f0101da9:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101db0:	f0 
f0101db1:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0101db8:	00 
f0101db9:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101dc0:	e8 0d e3 ff ff       	call   f01000d2 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(boot_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101dc5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101dcc:	00 
f0101dcd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101dd4:	00 
f0101dd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101dd8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ddc:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101de1:	89 04 24             	mov    %eax,(%esp)
f0101de4:	e8 ea f2 ff ff       	call   f01010d3 <page_insert>
f0101de9:	85 c0                	test   %eax,%eax
f0101deb:	74 24                	je     f0101e11 <i386_vm_init+0xcad>
f0101ded:	c7 44 24 0c bc 59 10 	movl   $0xf01059bc,0xc(%esp)
f0101df4:	f0 
f0101df5:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101dfc:	f0 
f0101dfd:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101e04:	00 
f0101e05:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101e0c:	e8 c1 e2 ff ff       	call   f01000d2 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(boot_pgdir, 0) == page2pa(pp1));
f0101e11:	8b 3d 68 67 1b f0    	mov    0xf01b6768,%edi
f0101e17:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e1c:	89 f8                	mov    %edi,%eax
f0101e1e:	e8 e2 ec ff ff       	call   f0100b05 <check_va2pa>
f0101e23:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101e26:	8b 75 d8             	mov    -0x28(%ebp),%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101e29:	89 f0                	mov    %esi,%eax
f0101e2b:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f0101e31:	c1 f8 02             	sar    $0x2,%eax
f0101e34:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101e3a:	c1 e0 0c             	shl    $0xc,%eax
f0101e3d:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101e40:	74 24                	je     f0101e66 <i386_vm_init+0xd02>
f0101e42:	c7 44 24 0c f4 59 10 	movl   $0xf01059f4,0xc(%esp)
f0101e49:	f0 
f0101e4a:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101e51:	f0 
f0101e52:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101e59:	00 
f0101e5a:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101e61:	e8 6c e2 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101e66:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e6b:	89 f8                	mov    %edi,%eax
f0101e6d:	e8 93 ec ff ff       	call   f0100b05 <check_va2pa>
f0101e72:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101e75:	74 24                	je     f0101e9b <i386_vm_init+0xd37>
f0101e77:	c7 44 24 0c 20 5a 10 	movl   $0xf0105a20,0xc(%esp)
f0101e7e:	f0 
f0101e7f:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101e86:	f0 
f0101e87:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101e8e:	00 
f0101e8f:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101e96:	e8 37 e2 ff ff       	call   f01000d2 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e9b:	66 83 7e 08 02       	cmpw   $0x2,0x8(%esi)
f0101ea0:	74 24                	je     f0101ec6 <i386_vm_init+0xd62>
f0101ea2:	c7 44 24 0c 54 5d 10 	movl   $0xf0105d54,0xc(%esp)
f0101ea9:	f0 
f0101eaa:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101eb1:	f0 
f0101eb2:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0101eb9:	00 
f0101eba:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101ec1:	e8 0c e2 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f0101ec6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ec9:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101ece:	74 24                	je     f0101ef4 <i386_vm_init+0xd90>
f0101ed0:	c7 44 24 0c 65 5d 10 	movl   $0xf0105d65,0xc(%esp)
f0101ed7:	f0 
f0101ed8:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101edf:	f0 
f0101ee0:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101ee7:	00 
f0101ee8:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101eef:	e8 de e1 ff ff       	call   f01000d2 <_panic>

	// pp2 should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp2);
f0101ef4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101ef7:	89 04 24             	mov    %eax,(%esp)
f0101efa:	e8 5f ee ff ff       	call   f0100d5e <page_alloc>
f0101eff:	85 c0                	test   %eax,%eax
f0101f01:	75 08                	jne    f0101f0b <i386_vm_init+0xda7>
f0101f03:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f06:	39 4d e0             	cmp    %ecx,-0x20(%ebp)
f0101f09:	74 24                	je     f0101f2f <i386_vm_init+0xdcb>
f0101f0b:	c7 44 24 0c 50 5a 10 	movl   $0xf0105a50,0xc(%esp)
f0101f12:	f0 
f0101f13:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101f1a:	f0 
f0101f1b:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101f22:	00 
f0101f23:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101f2a:	e8 a3 e1 ff ff       	call   f01000d2 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(boot_pgdir, 0x0);
f0101f2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101f36:	00 
f0101f37:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0101f3c:	89 04 24             	mov    %eax,(%esp)
f0101f3f:	e8 3f f1 ff ff       	call   f0101083 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0101f44:	8b 35 68 67 1b f0    	mov    0xf01b6768,%esi
f0101f4a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f4f:	89 f0                	mov    %esi,%eax
f0101f51:	e8 af eb ff ff       	call   f0100b05 <check_va2pa>
f0101f56:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f59:	74 24                	je     f0101f7f <i386_vm_init+0xe1b>
f0101f5b:	c7 44 24 0c 74 5a 10 	movl   $0xf0105a74,0xc(%esp)
f0101f62:	f0 
f0101f63:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101f6a:	f0 
f0101f6b:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101f72:	00 
f0101f73:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101f7a:	e8 53 e1 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == page2pa(pp1));
f0101f7f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f84:	89 f0                	mov    %esi,%eax
f0101f86:	e8 7a eb ff ff       	call   f0100b05 <check_va2pa>
f0101f8b:	8b 55 d8             	mov    -0x28(%ebp),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0101f8e:	89 d1                	mov    %edx,%ecx
f0101f90:	2b 0d 6c 67 1b f0    	sub    0xf01b676c,%ecx
f0101f96:	c1 f9 02             	sar    $0x2,%ecx
f0101f99:	69 c9 ab aa aa aa    	imul   $0xaaaaaaab,%ecx,%ecx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0101f9f:	c1 e1 0c             	shl    $0xc,%ecx
f0101fa2:	39 c8                	cmp    %ecx,%eax
f0101fa4:	74 24                	je     f0101fca <i386_vm_init+0xe66>
f0101fa6:	c7 44 24 0c 20 5a 10 	movl   $0xf0105a20,0xc(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101fb5:	f0 
f0101fb6:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0101fbd:	00 
f0101fbe:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101fc5:	e8 08 e1 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 1);
f0101fca:	66 83 7a 08 01       	cmpw   $0x1,0x8(%edx)
f0101fcf:	74 24                	je     f0101ff5 <i386_vm_init+0xe91>
f0101fd1:	c7 44 24 0c 21 5d 10 	movl   $0xf0105d21,0xc(%esp)
f0101fd8:	f0 
f0101fd9:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0101fe0:	f0 
f0101fe1:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101fe8:	00 
f0101fe9:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0101ff0:	e8 dd e0 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f0101ff5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff8:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f0101ffd:	74 24                	je     f0102023 <i386_vm_init+0xebf>
f0101fff:	c7 44 24 0c 65 5d 10 	movl   $0xf0105d65,0xc(%esp)
f0102006:	f0 
f0102007:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010200e:	f0 
f010200f:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0102016:	00 
f0102017:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010201e:	e8 af e0 ff ff       	call   f01000d2 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(boot_pgdir, (void*) PGSIZE);
f0102023:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010202a:	00 
f010202b:	89 34 24             	mov    %esi,(%esp)
f010202e:	e8 50 f0 ff ff       	call   f0101083 <page_remove>
	assert(check_va2pa(boot_pgdir, 0x0) == ~0);
f0102033:	8b 35 68 67 1b f0    	mov    0xf01b6768,%esi
f0102039:	ba 00 00 00 00       	mov    $0x0,%edx
f010203e:	89 f0                	mov    %esi,%eax
f0102040:	e8 c0 ea ff ff       	call   f0100b05 <check_va2pa>
f0102045:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102048:	74 24                	je     f010206e <i386_vm_init+0xf0a>
f010204a:	c7 44 24 0c 74 5a 10 	movl   $0xf0105a74,0xc(%esp)
f0102051:	f0 
f0102052:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0102059:	f0 
f010205a:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0102061:	00 
f0102062:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0102069:	e8 64 e0 ff ff       	call   f01000d2 <_panic>
	assert(check_va2pa(boot_pgdir, PGSIZE) == ~0);
f010206e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102073:	89 f0                	mov    %esi,%eax
f0102075:	e8 8b ea ff ff       	call   f0100b05 <check_va2pa>
f010207a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010207d:	74 24                	je     f01020a3 <i386_vm_init+0xf3f>
f010207f:	c7 44 24 0c 98 5a 10 	movl   $0xf0105a98,0xc(%esp)
f0102086:	f0 
f0102087:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010208e:	f0 
f010208f:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102096:	00 
f0102097:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010209e:	e8 2f e0 ff ff       	call   f01000d2 <_panic>
	assert(pp1->pp_ref == 0);
f01020a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01020a6:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01020ab:	74 24                	je     f01020d1 <i386_vm_init+0xf6d>
f01020ad:	c7 44 24 0c 76 5d 10 	movl   $0xf0105d76,0xc(%esp)
f01020b4:	f0 
f01020b5:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01020bc:	f0 
f01020bd:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f01020c4:	00 
f01020c5:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01020cc:	e8 01 e0 ff ff       	call   f01000d2 <_panic>
	assert(pp2->pp_ref == 0);
f01020d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020d4:	66 83 78 08 00       	cmpw   $0x0,0x8(%eax)
f01020d9:	74 24                	je     f01020ff <i386_vm_init+0xf9b>
f01020db:	c7 44 24 0c 65 5d 10 	movl   $0xf0105d65,0xc(%esp)
f01020e2:	f0 
f01020e3:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01020ea:	f0 
f01020eb:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f01020f2:	00 
f01020f3:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01020fa:	e8 d3 df ff ff       	call   f01000d2 <_panic>

	// so it should be returned by page_alloc
	assert(page_alloc(&pp) == 0 && pp == pp1);
f01020ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0102102:	89 04 24             	mov    %eax,(%esp)
f0102105:	e8 54 ec ff ff       	call   f0100d5e <page_alloc>
f010210a:	85 c0                	test   %eax,%eax
f010210c:	75 08                	jne    f0102116 <i386_vm_init+0xfb2>
f010210e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102111:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f0102114:	74 24                	je     f010213a <i386_vm_init+0xfd6>
f0102116:	c7 44 24 0c c0 5a 10 	movl   $0xf0105ac0,0xc(%esp)
f010211d:	f0 
f010211e:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0102125:	f0 
f0102126:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f010212d:	00 
f010212e:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0102135:	e8 98 df ff ff       	call   f01000d2 <_panic>

	// should be no free memory
	assert(page_alloc(&pp) == -E_NO_MEM);
f010213a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010213d:	89 04 24             	mov    %eax,(%esp)
f0102140:	e8 19 ec ff ff       	call   f0100d5e <page_alloc>
f0102145:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102148:	74 24                	je     f010216e <i386_vm_init+0x100a>
f010214a:	c7 44 24 0c 04 5d 10 	movl   $0xf0105d04,0xc(%esp)
f0102151:	f0 
f0102152:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0102159:	f0 
f010215a:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102161:	00 
f0102162:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0102169:	e8 64 df ff ff       	call   f01000d2 <_panic>
	page_remove(boot_pgdir, 0x0);
	assert(pp2->pp_ref == 0);
#endif

	// forcibly take pp0 back
	assert(PTE_ADDR(boot_pgdir[0]) == page2pa(pp0));
f010216e:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f0102173:	8b 08                	mov    (%eax),%ecx
f0102175:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f010217b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010217e:	2b 15 6c 67 1b f0    	sub    0xf01b676c,%edx
f0102184:	c1 fa 02             	sar    $0x2,%edx
f0102187:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f010218d:	c1 e2 0c             	shl    $0xc,%edx
f0102190:	39 d1                	cmp    %edx,%ecx
f0102192:	74 24                	je     f01021b8 <i386_vm_init+0x1054>
f0102194:	c7 44 24 0c 18 58 10 	movl   $0xf0105818,0xc(%esp)
f010219b:	f0 
f010219c:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01021a3:	f0 
f01021a4:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f01021ab:	00 
f01021ac:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01021b3:	e8 1a df ff ff       	call   f01000d2 <_panic>
	boot_pgdir[0] = 0;
f01021b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01021be:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01021c1:	66 83 78 08 01       	cmpw   $0x1,0x8(%eax)
f01021c6:	74 24                	je     f01021ec <i386_vm_init+0x1088>
f01021c8:	c7 44 24 0c 32 5d 10 	movl   $0xf0105d32,0xc(%esp)
f01021cf:	f0 
f01021d0:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01021d7:	f0 
f01021d8:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f01021df:	00 
f01021e0:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01021e7:	e8 e6 de ff ff       	call   f01000d2 <_panic>
	pp0->pp_ref = 0;
f01021ec:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
	
	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021f2:	89 04 24             	mov    %eax,(%esp)
f01021f5:	e8 b5 eb ff ff       	call   f0100daf <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(boot_pgdir, va, 1);
f01021fa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102201:	00 
f0102202:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102209:	00 
f010220a:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f010220f:	89 04 24             	mov    %eax,(%esp)
f0102212:	e8 0a ec ff ff       	call   f0100e21 <pgdir_walk>
f0102217:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = KADDR(PTE_ADDR(boot_pgdir[PDX(va)]));
f010221a:	8b 35 68 67 1b f0    	mov    0xf01b6768,%esi
f0102220:	8b 56 04             	mov    0x4(%esi),%edx
f0102223:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102229:	8b 0d 60 67 1b f0    	mov    0xf01b6760,%ecx
f010222f:	89 d7                	mov    %edx,%edi
f0102231:	c1 ef 0c             	shr    $0xc,%edi
f0102234:	39 cf                	cmp    %ecx,%edi
f0102236:	72 20                	jb     f0102258 <i386_vm_init+0x10f4>
f0102238:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010223c:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0102243:	f0 
f0102244:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f010224b:	00 
f010224c:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0102253:	e8 7a de ff ff       	call   f01000d2 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102258:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010225e:	39 d0                	cmp    %edx,%eax
f0102260:	74 24                	je     f0102286 <i386_vm_init+0x1122>
f0102262:	c7 44 24 0c 87 5d 10 	movl   $0xf0105d87,0xc(%esp)
f0102269:	f0 
f010226a:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0102271:	f0 
f0102272:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102279:	00 
f010227a:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0102281:	e8 4c de ff ff       	call   f01000d2 <_panic>
	boot_pgdir[PDX(va)] = 0;
f0102286:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	pp0->pp_ref = 0;
f010228d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102290:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102296:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f010229c:	c1 f8 02             	sar    $0x2,%eax
f010229f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f01022a5:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f01022a8:	89 c2                	mov    %eax,%edx
f01022aa:	c1 ea 0c             	shr    $0xc,%edx
f01022ad:	39 d1                	cmp    %edx,%ecx
f01022af:	77 20                	ja     f01022d1 <i386_vm_init+0x116d>
f01022b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01022b5:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f01022bc:	f0 
f01022bd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01022c4:	00 
f01022c5:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f01022cc:	e8 01 de ff ff       	call   f01000d2 <_panic>
	
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01022d1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022d8:	00 
f01022d9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01022e0:	00 
f01022e1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01022e6:	89 04 24             	mov    %eax,(%esp)
f01022e9:	e8 e8 27 00 00       	call   f0104ad6 <memset>
	page_free(pp0);
f01022ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01022f1:	89 04 24             	mov    %eax,(%esp)
f01022f4:	e8 b6 ea ff ff       	call   f0100daf <page_free>
	pgdir_walk(boot_pgdir, 0x0, 1);
f01022f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102300:	00 
f0102301:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102308:	00 
f0102309:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f010230e:	89 04 24             	mov    %eax,(%esp)
f0102311:	e8 0b eb ff ff       	call   f0100e21 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102316:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102319:	2b 15 6c 67 1b f0    	sub    0xf01b676c,%edx
f010231f:	c1 fa 02             	sar    $0x2,%edx
f0102322:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102328:	c1 e2 0c             	shl    $0xc,%edx
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f010232b:	89 d0                	mov    %edx,%eax
f010232d:	c1 e8 0c             	shr    $0xc,%eax
f0102330:	3b 05 60 67 1b f0    	cmp    0xf01b6760,%eax
f0102336:	72 20                	jb     f0102358 <i386_vm_init+0x11f4>
f0102338:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010233c:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0102343:	f0 
f0102344:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f010234b:	00 
f010234c:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0102353:	e8 7a dd ff ff       	call   f01000d2 <_panic>
f0102358:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = page2kva(pp0);
f010235e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102361:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f0102368:	75 11                	jne    f010237b <i386_vm_init+0x1217>
f010236a:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f0102370:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102376:	f6 00 01             	testb  $0x1,(%eax)
f0102379:	74 24                	je     f010239f <i386_vm_init+0x123b>
f010237b:	c7 44 24 0c 9f 5d 10 	movl   $0xf0105d9f,0xc(%esp)
f0102382:	f0 
f0102383:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010238a:	f0 
f010238b:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102392:	00 
f0102393:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010239a:	e8 33 dd ff ff       	call   f01000d2 <_panic>
f010239f:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(boot_pgdir, 0x0, 1);
	ptep = page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01023a2:	39 d0                	cmp    %edx,%eax
f01023a4:	75 d0                	jne    f0102376 <i386_vm_init+0x1212>
		assert((ptep[i] & PTE_P) == 0);
	boot_pgdir[0] = 0;
f01023a6:	a1 68 67 1b f0       	mov    0xf01b6768,%eax
f01023ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01023b4:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	page_free_list = fl;
f01023ba:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01023bd:	89 15 b8 5a 1b f0    	mov    %edx,0xf01b5ab8

	// free the pages we took
	page_free(pp0);
f01023c3:	89 04 24             	mov    %eax,(%esp)
f01023c6:	e8 e4 e9 ff ff       	call   f0100daf <page_free>
	page_free(pp1);
f01023cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01023ce:	89 04 24             	mov    %eax,(%esp)
f01023d1:	e8 d9 e9 ff ff       	call   f0100daf <page_free>
	page_free(pp2);
f01023d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023d9:	89 04 24             	mov    %eax,(%esp)
f01023dc:	e8 ce e9 ff ff       	call   f0100daf <page_free>
	
	cprintf("page_check() succeeded!\n");
f01023e1:	c7 04 24 b6 5d 10 f0 	movl   $0xf0105db6,(%esp)
f01023e8:	e8 d5 0d 00 00       	call   f01031c2 <cprintf>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here:
	// [UPAGES, sizeof(PAGES) ] => [pages, sizeof(PAGES)]
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f01023ed:	8b 15 60 67 1b f0    	mov    0xf01b6760,%edx
	boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f01023f3:	a1 6c 67 1b f0       	mov    0xf01b676c,%eax
f01023f8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023fd:	77 20                	ja     f010241f <i386_vm_init+0x12bb>
f01023ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102403:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f010240a:	f0 
f010240b:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f0102412:	00 
f0102413:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010241a:	e8 b3 dc ff ff       	call   f01000d2 <_panic>
	// Permissions:
	//    - pages -- kernel RW, user NONE
	//    - the read-only version mapped at UPAGES -- kernel R, user R
	// Your code goes here:
	// [UPAGES, sizeof(PAGES) ] => [pages, sizeof(PAGES)]
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f010241f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102422:	8d 0c 95 ff 0f 00 00 	lea    0xfff(,%edx,4),%ecx
f0102429:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_segment(pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f010242f:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102436:	00 
f0102437:	05 00 00 00 10       	add    $0x10000000,%eax
f010243c:	89 04 24             	mov    %eax,(%esp)
f010243f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102444:	89 d8                	mov    %ebx,%eax
f0102446:	e8 2c eb ff ff       	call   f0100f77 <boot_map_segment>
	// Permissions:
	//    - envs itself -- kernel RW, user NONE
	//    - the image of envs mapped at UENVS  -- kernel R, user R
	// Lab3: Your code goes here:
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	boot_map_segment(pgdir, UENVS, n, PADDR(envs), PTE_U | PTE_P);
f010244b:	a1 c4 5a 1b f0       	mov    0xf01b5ac4,%eax
f0102450:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102455:	77 20                	ja     f0102477 <i386_vm_init+0x1313>
f0102457:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010245b:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f0102462:	f0 
f0102463:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f010246a:	00 
f010246b:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0102472:	e8 5b dc ff ff       	call   f01000d2 <_panic>
f0102477:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f010247e:	00 
f010247f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102484:	89 04 24             	mov    %eax,(%esp)
f0102487:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010248c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102491:	89 d8                	mov    %ebx,%eax
f0102493:	e8 df ea ff ff       	call   f0100f77 <boot_map_segment>
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed => faults
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// [KSTACKTOP – KSTKSIZE, 8] => [bootstack, 8]
	boot_map_segment(pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0102498:	be 00 20 11 f0       	mov    $0xf0112000,%esi
f010249d:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01024a3:	77 20                	ja     f01024c5 <i386_vm_init+0x1361>
f01024a5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01024a9:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f01024b0:	f0 
f01024b1:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f01024b8:	00 
f01024b9:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01024c0:	e8 0d dc ff ff       	call   f01000d2 <_panic>
f01024c5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01024cc:	00 
f01024cd:	c7 04 24 00 20 11 00 	movl   $0x112000,(%esp)
f01024d4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01024d9:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01024de:	89 d8                	mov    %ebx,%eax
f01024e0:	e8 92 ea ff ff       	call   f0100f77 <boot_map_segment>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the amapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	// [KERNBASE, pages in the memory] => [0, pages in the memory]
	boot_map_segment(pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_W | PTE_P);
f01024e5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01024ec:	00 
f01024ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024f4:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01024f9:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01024fe:	89 d8                	mov    %ebx,%eax
f0102500:	e8 72 ea ff ff       	call   f0100f77 <boot_map_segment>
check_boot_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = boot_pgdir;
f0102505:	8b 3d 68 67 1b f0    	mov    0xf01b6768,%edi

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
f010250b:	8b 0d 60 67 1b f0    	mov    0xf01b6760,%ecx
f0102511:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0102514:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0102517:	8d 04 85 ff 0f 00 00 	lea    0xfff(,%eax,4),%eax
	for (i = 0; i < n; i += PGSIZE)
f010251e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102523:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102526:	0f 84 8f 00 00 00    	je     f01025bb <i386_vm_init+0x1457>
f010252c:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f0102533:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102536:	81 ea 00 00 00 11    	sub    $0x11000000,%edx
	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010253c:	89 f8                	mov    %edi,%eax
f010253e:	e8 c2 e5 ff ff       	call   f0100b05 <check_va2pa>
f0102543:	8b 15 6c 67 1b f0    	mov    0xf01b676c,%edx
f0102549:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010254f:	77 20                	ja     f0102571 <i386_vm_init+0x140d>
f0102551:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102555:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f010255c:	f0 
f010255d:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102564:	00 
f0102565:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010256c:	e8 61 db ff ff       	call   f01000d2 <_panic>
f0102571:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102574:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f010257b:	39 d0                	cmp    %edx,%eax
f010257d:	74 24                	je     f01025a3 <i386_vm_init+0x143f>
f010257f:	c7 44 24 0c e4 5a 10 	movl   $0xf0105ae4,0xc(%esp)
f0102586:	f0 
f0102587:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010258e:	f0 
f010258f:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f0102596:	00 
f0102597:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010259e:	e8 2f db ff ff       	call   f01000d2 <_panic>

	pgdir = boot_pgdir;

	// check pages array
	n = ROUNDUP(npage*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025a3:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f01025aa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01025ad:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f01025b0:	77 81                	ja     f0102533 <i386_vm_init+0x13cf>
f01025b2:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
f01025b9:	eb 07                	jmp    f01025c2 <i386_vm_init+0x145e>
f01025bb:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f01025c2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01025c5:	81 ea 00 00 40 11    	sub    $0x11400000,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01025cb:	89 f8                	mov    %edi,%eax
f01025cd:	e8 33 e5 ff ff       	call   f0100b05 <check_va2pa>
f01025d2:	8b 15 c4 5a 1b f0    	mov    0xf01b5ac4,%edx
f01025d8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01025de:	77 20                	ja     f0102600 <i386_vm_init+0x149c>
f01025e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01025e4:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f01025eb:	f0 
f01025ec:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f01025f3:	00 
f01025f4:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01025fb:	e8 d2 da ff ff       	call   f01000d2 <_panic>
f0102600:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102603:	8d 94 0a 00 00 00 10 	lea    0x10000000(%edx,%ecx,1),%edx
f010260a:	39 d0                	cmp    %edx,%eax
f010260c:	74 24                	je     f0102632 <i386_vm_init+0x14ce>
f010260e:	c7 44 24 0c 18 5b 10 	movl   $0xf0105b18,0xc(%esp)
f0102615:	f0 
f0102616:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010261d:	f0 
f010261e:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0102625:	00 
f0102626:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010262d:	e8 a0 da ff ff       	call   f01000d2 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102632:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f0102639:	81 7d c4 00 f0 01 00 	cmpl   $0x1f000,-0x3c(%ebp)
f0102640:	75 80                	jne    f01025c2 <i386_vm_init+0x145e>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
f0102642:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f0102646:	74 4f                	je     f0102697 <i386_vm_init+0x1533>
f0102648:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f010264f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0102652:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102658:	89 f8                	mov    %edi,%eax
f010265a:	e8 a6 e4 ff ff       	call   f0100b05 <check_va2pa>
f010265f:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0102662:	74 24                	je     f0102688 <i386_vm_init+0x1524>
f0102664:	c7 44 24 0c 4c 5b 10 	movl   $0xf0105b4c,0xc(%esp)
f010266b:	f0 
f010266c:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0102673:	f0 
f0102674:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f010267b:	00 
f010267c:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0102683:	e8 4a da ff ff       	call   f01000d2 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
f0102688:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f010268f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102692:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0102695:	77 b8                	ja     f010264f <i386_vm_init+0x14eb>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102697:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010269c:	89 f8                	mov    %edi,%eax
f010269e:	e8 62 e4 ff ff       	call   f0100b05 <check_va2pa>
f01026a3:	c7 45 c4 00 90 bf ef 	movl   $0xefbf9000,-0x3c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
f01026aa:	81 c6 00 70 40 20    	add    $0x20407000,%esi
f01026b0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01026b3:	01 f2                	add    %esi,%edx
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026b5:	39 d0                	cmp    %edx,%eax
f01026b7:	74 24                	je     f01026dd <i386_vm_init+0x1579>
f01026b9:	c7 44 24 0c 74 5b 10 	movl   $0xf0105b74,0xc(%esp)
f01026c0:	f0 
f01026c1:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f01026c8:	f0 
f01026c9:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f01026d0:	00 
f01026d1:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f01026d8:	e8 f5 d9 ff ff       	call   f01000d2 <_panic>
	// check phys mem
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01026dd:	81 7d c4 00 00 c0 ef 	cmpl   $0xefc00000,-0x3c(%ebp)
f01026e4:	0f 85 07 01 00 00    	jne    f01027f1 <i386_vm_init+0x168d>
f01026ea:	b8 00 00 00 00       	mov    $0x0,%eax
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01026ef:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01026f5:	83 fa 04             	cmp    $0x4,%edx
f01026f8:	77 2a                	ja     f0102724 <i386_vm_init+0x15c0>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i]);
f01026fa:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01026fe:	75 7f                	jne    f010277f <i386_vm_init+0x161b>
f0102700:	c7 44 24 0c cf 5d 10 	movl   $0xf0105dcf,0xc(%esp)
f0102707:	f0 
f0102708:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010270f:	f0 
f0102710:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f0102717:	00 
f0102718:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010271f:	e8 ae d9 ff ff       	call   f01000d2 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE))
f0102724:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102729:	76 2a                	jbe    f0102755 <i386_vm_init+0x15f1>
				assert(pgdir[i]);
f010272b:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010272f:	75 4e                	jne    f010277f <i386_vm_init+0x161b>
f0102731:	c7 44 24 0c cf 5d 10 	movl   $0xf0105dcf,0xc(%esp)
f0102738:	f0 
f0102739:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f0102740:	f0 
f0102741:	c7 44 24 04 95 01 00 	movl   $0x195,0x4(%esp)
f0102748:	00 
f0102749:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f0102750:	e8 7d d9 ff ff       	call   f01000d2 <_panic>
			else
				assert(pgdir[i] == 0);
f0102755:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102759:	74 24                	je     f010277f <i386_vm_init+0x161b>
f010275b:	c7 44 24 0c d8 5d 10 	movl   $0xf0105dd8,0xc(%esp)
f0102762:	f0 
f0102763:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010276a:	f0 
f010276b:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0102772:	00 
f0102773:	c7 04 24 11 5c 10 f0 	movl   $0xf0105c11,(%esp)
f010277a:	e8 53 d9 ff ff       	call   f01000d2 <_panic>
	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f010277f:	83 c0 01             	add    $0x1,%eax
f0102782:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102787:	0f 85 62 ff ff ff    	jne    f01026ef <i386_vm_init+0x158b>
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f010278d:	c7 04 24 bc 5b 10 f0 	movl   $0xf0105bbc,(%esp)
f0102794:	e8 29 0a 00 00       	call   f01031c2 <cprintf>
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA KERNBASE, i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	pgdir[0] = pgdir[PDX(KERNBASE)];
f0102799:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f010279f:	89 03                	mov    %eax,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01027a1:	a1 64 67 1b f0       	mov    0xf01b6764,%eax
f01027a6:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01027a9:	0f 20 c0             	mov    %cr0,%eax
	// Install page table.
	lcr3(boot_cr3);

	// Turn on paging.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f01027ac:	0d 2f 00 05 80       	or     $0x8005002f,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01027b1:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01027b4:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNBASE+x => x => x.
	// (x < 4MB so uses paging pgdir[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f01027b7:	0f 01 15 20 a3 11 f0 	lgdtl  0xf011a320
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01027be:	b8 23 00 00 00       	mov    $0x23,%eax
f01027c3:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01027c5:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01027c7:	b0 10                	mov    $0x10,%al
f01027c9:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01027cb:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01027cd:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f01027cf:	ea d6 27 10 f0 08 00 	ljmp   $0x8,$0xf01027d6
	asm volatile("lldt %%ax" :: "a" (0));
f01027d6:	b0 00                	mov    $0x0,%al
f01027d8:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNBASE+x => KERNBASE+x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	pgdir[0] = 0;
f01027db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01027e1:	a1 64 67 1b f0       	mov    0xf01b6764,%eax
f01027e6:	0f 22 d8             	mov    %eax,%cr3

	// Flush the TLB for good measure, to kill the pgdir[0] mapping.
	lcr3(boot_cr3);
}
f01027e9:	83 c4 4c             	add    $0x4c,%esp
f01027ec:	5b                   	pop    %ebx
f01027ed:	5e                   	pop    %esi
f01027ee:	5f                   	pop    %edi
f01027ef:	5d                   	pop    %ebp
f01027f0:	c3                   	ret    
	for (i = 0; i < npage; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027f1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01027f4:	89 f8                	mov    %edi,%eax
f01027f6:	e8 0a e3 ff ff       	call   f0100b05 <check_va2pa>
f01027fb:	81 45 c4 00 10 00 00 	addl   $0x1000,-0x3c(%ebp)
f0102802:	e9 a9 fe ff ff       	jmp    f01026b0 <i386_vm_init+0x154c>

f0102807 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102807:	55                   	push   %ebp
f0102808:	89 e5                	mov    %esp,%ebp
f010280a:	57                   	push   %edi
f010280b:	56                   	push   %esi
f010280c:	53                   	push   %ebx
f010280d:	83 ec 2c             	sub    $0x2c,%esp
f0102810:	8b 75 08             	mov    0x8(%ebp),%esi
f0102813:	8b 45 0c             	mov    0xc(%ebp),%eax
	// check user privilege and boundary
	// REMEMBER, pte_t mod PGSIZE = 0, and the lower bits
	// describe the privileges of the page
	// check all range
	pte_t *pte_addr;
	uintptr_t lva = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f0102816:	89 c3                	mov    %eax,%ebx
f0102818:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t rva = (uintptr_t)ROUNDUP(va+len, PGSIZE);
f010281e:	03 45 10             	add    0x10(%ebp),%eax
f0102821:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102826:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010282b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			user_mem_check_addr = lva;
			return -E_FAULT;
		}
	}

	return 0;
f010282e:	b8 00 00 00 00       	mov    $0x0,%eax
	// check all range
	pte_t *pte_addr;
	uintptr_t lva = (uintptr_t)ROUNDDOWN(va, PGSIZE);
	uintptr_t rva = (uintptr_t)ROUNDUP(va+len, PGSIZE);
	// rva is not included
	for (; lva < rva; lva += PGSIZE)
f0102833:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102836:	73 66                	jae    f010289e <user_mem_check+0x97>
	{
		// check boundary
		// record the first erroneous virtual address
		// so it cannot be outside the loop
		if (lva >= ULIM)
f0102838:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010283e:	76 17                	jbe    f0102857 <user_mem_check+0x50>
f0102840:	eb 08                	jmp    f010284a <user_mem_check+0x43>
f0102842:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102848:	76 13                	jbe    f010285d <user_mem_check+0x56>
		{
			user_mem_check_addr = lva;
f010284a:	89 1d bc 5a 1b f0    	mov    %ebx,0xf01b5abc
			return -E_FAULT;
f0102850:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102855:	eb 47                	jmp    f010289e <user_mem_check+0x97>
		}
		pte_addr = pgdir_walk(env->env_pgdir, (void *)lva, 0);
		// PTE_U has been added when called in "user_mem_assert()"
		if (pte_addr == NULL || (*pte_addr & (perm | PTE_P)) != perm)
f0102857:	8b 7d 14             	mov    0x14(%ebp),%edi
f010285a:	83 cf 01             	or     $0x1,%edi
		if (lva >= ULIM)
		{
			user_mem_check_addr = lva;
			return -E_FAULT;
		}
		pte_addr = pgdir_walk(env->env_pgdir, (void *)lva, 0);
f010285d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102864:	00 
f0102865:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102869:	8b 46 5c             	mov    0x5c(%esi),%eax
f010286c:	89 04 24             	mov    %eax,(%esp)
f010286f:	e8 ad e5 ff ff       	call   f0100e21 <pgdir_walk>
		// PTE_U has been added when called in "user_mem_assert()"
		if (pte_addr == NULL || (*pte_addr & (perm | PTE_P)) != perm)
f0102874:	85 c0                	test   %eax,%eax
f0102876:	74 09                	je     f0102881 <user_mem_check+0x7a>
f0102878:	8b 00                	mov    (%eax),%eax
f010287a:	21 f8                	and    %edi,%eax
f010287c:	3b 45 14             	cmp    0x14(%ebp),%eax
f010287f:	74 0d                	je     f010288e <user_mem_check+0x87>
		{
			user_mem_check_addr = lva;
f0102881:	89 1d bc 5a 1b f0    	mov    %ebx,0xf01b5abc
			return -E_FAULT;
f0102887:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010288c:	eb 10                	jmp    f010289e <user_mem_check+0x97>
	// check all range
	pte_t *pte_addr;
	uintptr_t lva = (uintptr_t)ROUNDDOWN(va, PGSIZE);
	uintptr_t rva = (uintptr_t)ROUNDUP(va+len, PGSIZE);
	// rva is not included
	for (; lva < rva; lva += PGSIZE)
f010288e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102894:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102897:	77 a9                	ja     f0102842 <user_mem_check+0x3b>
			user_mem_check_addr = lva;
			return -E_FAULT;
		}
	}

	return 0;
f0102899:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010289e:	83 c4 2c             	add    $0x2c,%esp
f01028a1:	5b                   	pop    %ebx
f01028a2:	5e                   	pop    %esi
f01028a3:	5f                   	pop    %edi
f01028a4:	5d                   	pop    %ebp
f01028a5:	c3                   	ret    

f01028a6 <user_mem_assert>:
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01028a6:	55                   	push   %ebp
f01028a7:	89 e5                	mov    %esp,%ebp
f01028a9:	53                   	push   %ebx
f01028aa:	83 ec 14             	sub    $0x14,%esp
f01028ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01028b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01028b3:	83 c8 04             	or     $0x4,%eax
f01028b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01028bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01028c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01028c8:	89 1c 24             	mov    %ebx,(%esp)
f01028cb:	e8 37 ff ff ff       	call   f0102807 <user_mem_check>
f01028d0:	85 c0                	test   %eax,%eax
f01028d2:	79 29                	jns    f01028fd <user_mem_assert+0x57>
		cprintf("[%08x] user_mem_check assertion failure for "
f01028d4:	a1 bc 5a 1b f0       	mov    0xf01b5abc,%eax
f01028d9:	89 44 24 08          	mov    %eax,0x8(%esp)
			"va %08x\n", curenv->env_id, user_mem_check_addr);
f01028dd:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
f01028e2:	8b 40 4c             	mov    0x4c(%eax),%eax
f01028e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01028e9:	c7 04 24 dc 5b 10 f0 	movl   $0xf0105bdc,(%esp)
f01028f0:	e8 cd 08 00 00       	call   f01031c2 <cprintf>
			"va %08x\n", curenv->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01028f5:	89 1c 24             	mov    %ebx,(%esp)
f01028f8:	e8 5b 06 00 00       	call   f0102f58 <env_destroy>
	}
}
f01028fd:	83 c4 14             	add    $0x14,%esp
f0102900:	5b                   	pop    %ebx
f0102901:	5d                   	pop    %ebp
f0102902:	c3                   	ret    
	...

f0102904 <segment_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
segment_alloc(struct Env *e, void *va, size_t len)
{
f0102904:	55                   	push   %ebp
f0102905:	89 e5                	mov    %esp,%ebp
f0102907:	57                   	push   %edi
f0102908:	56                   	push   %esi
f0102909:	53                   	push   %ebx
f010290a:	83 ec 3c             	sub    $0x3c,%esp
f010290d:	89 c6                	mov    %eax,%esi
	//
	// Hint: It is easier to use segment_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round len up.
	// this function will allocates and maps physical memory for an environment.
	va = ROUNDDOWN(va, PGSIZE);
f010290f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102915:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	len = ROUNDUP(len, PGSIZE);
f0102918:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
	struct Page *new_pg;
	int i;
	for (i = 0; i < len; i += PGSIZE)
f010291e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102924:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102927:	0f 84 83 00 00 00    	je     f01029b0 <segment_alloc+0xac>
f010292d:	bf 00 00 00 00       	mov    $0x0,%edi
f0102932:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		// allocate a new page
		if (page_alloc(&new_pg) < 0)
f0102937:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010293a:	89 04 24             	mov    %eax,(%esp)
f010293d:	e8 1c e4 ff ff       	call   f0100d5e <page_alloc>
f0102942:	85 c0                	test   %eax,%eax
f0102944:	79 1c                	jns    f0102962 <segment_alloc+0x5e>
		{
			panic("segment_alloc(): out of memory\n");
f0102946:	c7 44 24 08 e8 5d 10 	movl   $0xf0105de8,0x8(%esp)
f010294d:	f0 
f010294e:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
f0102955:	00 
f0102956:	c7 04 24 5c 5e 10 f0 	movl   $0xf0105e5c,(%esp)
f010295d:	e8 70 d7 ff ff       	call   f01000d2 <_panic>
		}
		// must be e->env_pgdir, not pgdir
		// it is allocated according to env pg dir, as it is allocating pages
		// for user process env
		// User, Writable
		if (page_insert(e->env_pgdir, new_pg, va+i, PTE_U | PTE_W) < 0)
f0102962:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102969:	00 
f010296a:	03 7d d4             	add    -0x2c(%ebp),%edi
f010296d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102978:	8b 46 5c             	mov    0x5c(%esi),%eax
f010297b:	89 04 24             	mov    %eax,(%esp)
f010297e:	e8 50 e7 ff ff       	call   f01010d3 <page_insert>
f0102983:	85 c0                	test   %eax,%eax
f0102985:	79 1c                	jns    f01029a3 <segment_alloc+0x9f>
		{
			panic("segment_alloc(): page table cannot be allocated\n");
f0102987:	c7 44 24 08 08 5e 10 	movl   $0xf0105e08,0x8(%esp)
f010298e:	f0 
f010298f:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
f0102996:	00 
f0102997:	c7 04 24 5c 5e 10 f0 	movl   $0xf0105e5c,(%esp)
f010299e:	e8 2f d7 ff ff       	call   f01000d2 <_panic>
	// this function will allocates and maps physical memory for an environment.
	va = ROUNDDOWN(va, PGSIZE);
	len = ROUNDUP(len, PGSIZE);
	struct Page *new_pg;
	int i;
	for (i = 0; i < len; i += PGSIZE)
f01029a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029a9:	89 df                	mov    %ebx,%edi
f01029ab:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f01029ae:	77 87                	ja     f0102937 <segment_alloc+0x33>
		if (page_insert(e->env_pgdir, new_pg, va+i, PTE_U | PTE_W) < 0)
		{
			panic("segment_alloc(): page table cannot be allocated\n");
		}
	}
}
f01029b0:	83 c4 3c             	add    $0x3c,%esp
f01029b3:	5b                   	pop    %ebx
f01029b4:	5e                   	pop    %esi
f01029b5:	5f                   	pop    %edi
f01029b6:	5d                   	pop    %ebp
f01029b7:	c3                   	ret    

f01029b8 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01029b8:	55                   	push   %ebp
f01029b9:	89 e5                	mov    %esp,%ebp
f01029bb:	53                   	push   %ebx
f01029bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01029bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01029c2:	85 c0                	test   %eax,%eax
f01029c4:	75 0e                	jne    f01029d4 <envid2env+0x1c>
		*env_store = curenv;
f01029c6:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f01029cb:	89 01                	mov    %eax,(%ecx)
		return 0;
f01029cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01029d2:	eb 54                	jmp    f0102a28 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01029d4:	89 c2                	mov    %eax,%edx
f01029d6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01029dc:	6b d2 7c             	imul   $0x7c,%edx,%edx
f01029df:	03 15 c4 5a 1b f0    	add    0xf01b5ac4,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01029e5:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01029e9:	74 05                	je     f01029f0 <envid2env+0x38>
f01029eb:	39 42 4c             	cmp    %eax,0x4c(%edx)
f01029ee:	74 0d                	je     f01029fd <envid2env+0x45>
		*env_store = 0;
f01029f0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f01029f6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01029fb:	eb 2b                	jmp    f0102a28 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01029fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102a01:	74 1e                	je     f0102a21 <envid2env+0x69>
f0102a03:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f0102a08:	39 c2                	cmp    %eax,%edx
f0102a0a:	74 15                	je     f0102a21 <envid2env+0x69>
f0102a0c:	8b 58 4c             	mov    0x4c(%eax),%ebx
f0102a0f:	39 5a 50             	cmp    %ebx,0x50(%edx)
f0102a12:	74 0d                	je     f0102a21 <envid2env+0x69>
		*env_store = 0;
f0102a14:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102a1a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102a1f:	eb 07                	jmp    f0102a28 <envid2env+0x70>
	}

	*env_store = e;
f0102a21:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a28:	5b                   	pop    %ebx
f0102a29:	5d                   	pop    %ebp
f0102a2a:	c3                   	ret    

f0102a2b <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f0102a2b:	55                   	push   %ebp
f0102a2c:	89 e5                	mov    %esp,%ebp
f0102a2e:	57                   	push   %edi
f0102a2f:	56                   	push   %esi
f0102a30:	53                   	push   %ebx
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
f0102a31:	8b 3d c4 5a 1b f0    	mov    0xf01b5ac4,%edi
f0102a37:	8b 15 c8 5a 1b f0    	mov    0xf01b5ac8,%edx
// and insert them into the env_free_list.
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
f0102a3d:	8d 87 84 ef 01 00    	lea    0x1ef84(%edi),%eax
f0102a43:	b9 00 04 00 00       	mov    $0x400,%ecx
f0102a48:	eb 02                	jmp    f0102a4c <env_init+0x21>
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f0102a4a:	89 da                	mov    %ebx,%edx
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
f0102a4c:	89 c3                	mov    %eax,%ebx
f0102a4e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
f0102a55:	89 50 44             	mov    %edx,0x44(%eax)
f0102a58:	85 d2                	test   %edx,%edx
f0102a5a:	74 06                	je     f0102a62 <env_init+0x37>
f0102a5c:	8d 70 44             	lea    0x44(%eax),%esi
f0102a5f:	89 72 48             	mov    %esi,0x48(%edx)
f0102a62:	c7 43 48 c8 5a 1b f0 	movl   $0xf01b5ac8,0x48(%ebx)
f0102a69:	83 e8 7c             	sub    $0x7c,%eax
	// this function will initialize all of the Env structures
	// in the envs array and add them to the env_free_list.
	// just like page_init()
	// REVERSE ORDER!
	int i;
	for (i = NENV-1; i >= 0; --i)
f0102a6c:	83 e9 01             	sub    $0x1,%ecx
f0102a6f:	75 d9                	jne    f0102a4a <env_init+0x1f>
f0102a71:	89 3d c8 5a 1b f0    	mov    %edi,0xf01b5ac8
	{
		// "set  their env_ids to 0"
		envs[i].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[i], env_link);
	}
}
f0102a77:	5b                   	pop    %ebx
f0102a78:	5e                   	pop    %esi
f0102a79:	5f                   	pop    %edi
f0102a7a:	5d                   	pop    %ebp
f0102a7b:	c3                   	ret    

f0102a7c <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102a7c:	55                   	push   %ebp
f0102a7d:	89 e5                	mov    %esp,%ebp
f0102a7f:	53                   	push   %ebx
f0102a80:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f0102a83:	8b 1d c8 5a 1b f0    	mov    0xf01b5ac8,%ebx
f0102a89:	85 db                	test   %ebx,%ebx
f0102a8b:	0f 84 d6 01 00 00    	je     f0102c67 <env_alloc+0x1eb>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0102a91:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f0102a98:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102a9b:	89 04 24             	mov    %eax,(%esp)
f0102a9e:	e8 bb e2 ff ff       	call   f0100d5e <page_alloc>
f0102aa3:	85 c0                	test   %eax,%eax
f0102aa5:	0f 88 c1 01 00 00    	js     f0102c6c <env_alloc+0x1f0>

	// LAB 3: Your code here.
	// this function will allocate a page directory for a new environment
	// and initialize the kernel portion of the new environment's address space.
	// increase pp_ref
	++(p->pp_ref);
f0102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102aae:	66 83 40 08 01       	addw   $0x1,0x8(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102ab3:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f0102ab9:	c1 f8 02             	sar    $0x2,%eax
f0102abc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102ac2:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102ac5:	89 c2                	mov    %eax,%edx
f0102ac7:	c1 ea 0c             	shr    $0xc,%edx
f0102aca:	3b 15 60 67 1b f0    	cmp    0xf01b6760,%edx
f0102ad0:	72 20                	jb     f0102af2 <env_alloc+0x76>
f0102ad2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ad6:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0102add:	f0 
f0102ade:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102ae5:	00 
f0102ae6:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0102aed:	e8 e0 d5 ff ff       	call   f01000d2 <_panic>
	// Attention: need to clear the memory pointed by the page's va,
	// as it holds the process's pg dir.
	// page2kva is the combination of page2pa and KADDR
	// what will happen if "memset" is commented out? have a try.
	memset(page2kva(p), 0, PGSIZE);
f0102af2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102af9:	00 
f0102afa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b01:	00 
f0102b02:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b07:	89 04 24             	mov    %eax,(%esp)
f0102b0a:	e8 c7 1f 00 00       	call   f0104ad6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0102b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b12:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f0102b18:	c1 f8 02             	sar    $0x2,%eax
f0102b1b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0102b21:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0102b24:	89 c2                	mov    %eax,%edx
f0102b26:	c1 ea 0c             	shr    $0xc,%edx
f0102b29:	3b 15 60 67 1b f0    	cmp    0xf01b6760,%edx
f0102b2f:	72 20                	jb     f0102b51 <env_alloc+0xd5>
f0102b31:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b35:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0102b3c:	f0 
f0102b3d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0102b44:	00 
f0102b45:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0102b4c:	e8 81 d5 ff ff       	call   f01000d2 <_panic>
f0102b51:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0102b57:	89 53 5c             	mov    %edx,0x5c(%ebx)
	// set e->env_pgdir to this pg's va
	e->env_pgdir = page2kva(p);
	// set e->env_cr3 to this pg's pa
	e->env_cr3 = page2pa(p);
f0102b5a:	89 43 60             	mov    %eax,0x60(%ebx)
f0102b5d:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	// Page directory and page table constants.
	// NPDENTRIES = 1024	// page directory entries per page directory
	// NPTENTRIES = 1024	// page table entries per page table
	for (i = PDX(UTOP); i < NPDENTRIES; ++i)
	{
		e->env_pgdir[i] = boot_pgdir[i];
f0102b62:	8b 15 68 67 1b f0    	mov    0xf01b6768,%edx
f0102b68:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102b6b:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102b6e:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102b71:	83 c0 04             	add    $0x4,%eax
	// So just copy boot_pgdir to env_pgdir for this part.
	// And UTOP equals UENVS
	// Page directory and page table constants.
	// NPDENTRIES = 1024	// page directory entries per page directory
	// NPTENTRIES = 1024	// page table entries per page table
	for (i = PDX(UTOP); i < NPDENTRIES; ++i)
f0102b74:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102b79:	75 e7                	jne    f0102b62 <env_alloc+0xe6>
		e->env_pgdir[i] = boot_pgdir[i];
	}

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0102b7b:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102b7e:	8b 53 60             	mov    0x60(%ebx),%edx
f0102b81:	83 ca 03             	or     $0x3,%edx
f0102b84:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0102b8a:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102b8d:	8b 53 60             	mov    0x60(%ebx),%edx
f0102b90:	83 ca 05             	or     $0x5,%edx
f0102b93:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102b99:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0102b9c:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ba1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ba6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102bab:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102bae:	89 da                	mov    %ebx,%edx
f0102bb0:	2b 15 c4 5a 1b f0    	sub    0xf01b5ac4,%edx
f0102bb6:	c1 fa 02             	sar    $0x2,%edx
f0102bb9:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0102bbf:	09 d0                	or     %edx,%eax
f0102bc1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bc7:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102bca:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102bd1:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102bd8:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102bdf:	00 
f0102be0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102be7:	00 
f0102be8:	89 1c 24             	mov    %ebx,(%esp)
f0102beb:	e8 e6 1e 00 00       	call   f0104ad6 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0102bf0:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102bf6:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102bfc:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102c02:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102c09:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102c0f:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102c16:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0102c1d:	8b 43 44             	mov    0x44(%ebx),%eax
f0102c20:	85 c0                	test   %eax,%eax
f0102c22:	74 06                	je     f0102c2a <env_alloc+0x1ae>
f0102c24:	8b 53 48             	mov    0x48(%ebx),%edx
f0102c27:	89 50 48             	mov    %edx,0x48(%eax)
f0102c2a:	8b 43 48             	mov    0x48(%ebx),%eax
f0102c2d:	8b 53 44             	mov    0x44(%ebx),%edx
f0102c30:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f0102c32:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c35:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102c37:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0102c3a:	8b 15 c0 5a 1b f0    	mov    0xf01b5ac0,%edx
f0102c40:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c45:	85 d2                	test   %edx,%edx
f0102c47:	74 03                	je     f0102c4c <env_alloc+0x1d0>
f0102c49:	8b 42 4c             	mov    0x4c(%edx),%eax
f0102c4c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102c50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c54:	c7 04 24 67 5e 10 f0 	movl   $0xf0105e67,(%esp)
f0102c5b:	e8 62 05 00 00       	call   f01031c2 <cprintf>
	return 0;
f0102c60:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c65:	eb 05                	jmp    f0102c6c <env_alloc+0x1f0>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
		return -E_NO_FREE_ENV;
f0102c67:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	LIST_REMOVE(e, env_link);
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102c6c:	83 c4 24             	add    $0x24,%esp
f0102c6f:	5b                   	pop    %ebx
f0102c70:	5d                   	pop    %ebp
f0102c71:	c3                   	ret    

f0102c72 <env_create>:
// By convention, envs[0] is the first environment allocated, so
// whoever calls env_create simply looks for the newly created
// environment there. 
void
env_create(uint8_t *binary, size_t size)
{
f0102c72:	55                   	push   %ebp
f0102c73:	89 e5                	mov    %esp,%ebp
f0102c75:	57                   	push   %edi
f0102c76:	56                   	push   %esi
f0102c77:	53                   	push   %ebx
f0102c78:	83 ec 3c             	sub    $0x3c,%esp
f0102c7b:	8b 7d 08             	mov    0x8(%ebp),%edi
	// about env_alloc(struct Env **newenv_store, envid_t parent_id):
	// Allocates and initializes a new environment.
	// On success, the new environment is stored in *newenv_store.
	struct Env *env;
	// The new env's parent ID is set to 0, as the first.
	int env_alloc_info = env_alloc(&env, 0);
f0102c7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c85:	00 
f0102c86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102c89:	89 04 24             	mov    %eax,(%esp)
f0102c8c:	e8 eb fd ff ff       	call   f0102a7c <env_alloc>
	if (env_alloc_info < 0)
f0102c91:	85 c0                	test   %eax,%eax
f0102c93:	79 20                	jns    f0102cb5 <env_create+0x43>
	{
		panic("env_alloc: %e", env_alloc_info);
f0102c95:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c99:	c7 44 24 08 7c 5e 10 	movl   $0xf0105e7c,0x8(%esp)
f0102ca0:	f0 
f0102ca1:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
f0102ca8:	00 
f0102ca9:	c7 04 24 5c 5e 10 f0 	movl   $0xf0105e5c,(%esp)
f0102cb0:	e8 1d d4 ff ff       	call   f01000d2 <_panic>
	}
	load_icode(env, binary, size);
f0102cb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cb8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// only load segments with ph->p_type == ELF_PROG_LOAD.
	struct Elf *env_elf;
	struct Proghdr *ph, *eph;
	env_elf = (struct Elf *)binary;
	// magic number check
	if(env_elf->e_magic != ELF_MAGIC)
f0102cbb:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102cc1:	74 1c                	je     f0102cdf <env_create+0x6d>
	{
		panic("load_icode(): Not a valid ELF!\n");
f0102cc3:	c7 44 24 08 3c 5e 10 	movl   $0xf0105e3c,0x8(%esp)
f0102cca:	f0 
f0102ccb:	c7 44 24 04 49 01 00 	movl   $0x149,0x4(%esp)
f0102cd2:	00 
f0102cd3:	c7 04 24 5c 5e 10 f0 	movl   $0xf0105e5c,(%esp)
f0102cda:	e8 f3 d3 ff ff       	call   f01000d2 <_panic>
	}	
	// load each program segment (ignores ph flags)
	// e_phoff means program header table offset
	// the start position
	ph = (struct Proghdr *)((uint8_t *)(env_elf)+env_elf->e_phoff);
f0102cdf:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	// the end position, e_phnum means the number of program
	// header table entries
	eph = ph+env_elf->e_phnum;
f0102ce2:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0102ce6:	0f 20 da             	mov    %cr3,%edx
f0102ce9:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// save old cr3, cr3 stores the page dir addr(pa)
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
f0102cec:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102cef:	8b 42 5c             	mov    0x5c(%edx),%eax
f0102cf2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cf7:	77 20                	ja     f0102d19 <env_create+0xa7>
f0102cf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cfd:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f0102d04:	f0 
f0102d05:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
f0102d0c:	00 
f0102d0d:	c7 04 24 5c 5e 10 f0 	movl   $0xf0105e5c,(%esp)
f0102d14:	e8 b9 d3 ff ff       	call   f01000d2 <_panic>
		panic("load_icode(): Not a valid ELF!\n");
	}	
	// load each program segment (ignores ph flags)
	// e_phoff means program header table offset
	// the start position
	ph = (struct Proghdr *)((uint8_t *)(env_elf)+env_elf->e_phoff);
f0102d19:	01 fb                	add    %edi,%ebx
	// the end position, e_phnum means the number of program
	// header table entries
	eph = ph+env_elf->e_phnum;
f0102d1b:	0f b7 f6             	movzwl %si,%esi
f0102d1e:	c1 e6 05             	shl    $0x5,%esi
f0102d21:	01 de                	add    %ebx,%esi
	// save old cr3, cr3 stores the page dir addr(pa)
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
f0102d23:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102d28:	0f 22 d8             	mov    %eax,%cr3
	for (; ph < eph; ++ph)
f0102d2b:	39 f3                	cmp    %esi,%ebx
f0102d2d:	73 54                	jae    f0102d83 <env_create+0x111>
	{
		// only load segments with ph->p_type == ELF_PROG_LOAD.
		if (ph->p_type == ELF_PROG_LOAD)
f0102d2f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102d32:	75 48                	jne    f0102d7c <env_create+0x10a>
		{
			// Each segment's virtual address can be found in ph->p_va
			//  and its size in memory can be found in ph->p_memsz.
			segment_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102d34:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102d37:	8b 53 08             	mov    0x8(%ebx),%edx
f0102d3a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d3d:	e8 c2 fb ff ff       	call   f0102904 <segment_alloc>
			//  The ph->p_filesz bytes from the ELF binary, starting at
			//  'binary + ph->p_offset', should be copied to virtual address
			//  ph->p_va.
			memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102d42:	8b 43 10             	mov    0x10(%ebx),%eax
f0102d45:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102d49:	89 f8                	mov    %edi,%eax
f0102d4b:	03 43 04             	add    0x4(%ebx),%eax
f0102d4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d52:	8b 43 08             	mov    0x8(%ebx),%eax
f0102d55:	89 04 24             	mov    %eax,(%esp)
f0102d58:	e8 9d 1d 00 00       	call   f0104afa <memmove>
			//Any remaining memory bytes should be cleared to zero.
			// REMEMBER that ph->p_filesz <= ph->p_memsz.
			memset((void *)(ph->p_va+ph->p_filesz), 0, ph->p_memsz-ph->p_filesz);
f0102d5d:	8b 43 10             	mov    0x10(%ebx),%eax
f0102d60:	8b 53 14             	mov    0x14(%ebx),%edx
f0102d63:	29 c2                	sub    %eax,%edx
f0102d65:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102d69:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102d70:	00 
f0102d71:	03 43 08             	add    0x8(%ebx),%eax
f0102d74:	89 04 24             	mov    %eax,(%esp)
f0102d77:	e8 5a 1d 00 00       	call   f0104ad6 <memset>
	unsigned int old_cr3 = rcr3();
	// load env page dir into cr3
	// if not, addressing will be wrong(Page Fault on memmove and memset),
	// as addressing is tightly related to address. 
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ++ph)
f0102d7c:	83 c3 20             	add    $0x20,%ebx
f0102d7f:	39 de                	cmp    %ebx,%esi
f0102d81:	77 ac                	ja     f0102d2f <env_create+0xbd>
f0102d83:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d86:	0f 22 d8             	mov    %eax,%cr3
		}
	}
	// restore the old cr3
	lcr3(old_cr3);
	// Set the program's entry point.
	e->env_tf.tf_eip = env_elf->e_entry;
f0102d89:	8b 47 18             	mov    0x18(%edi),%eax
f0102d8c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102d8f:	89 42 30             	mov    %eax,0x30(%edx)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	segment_alloc(e, (void *)(USTACKTOP-PGSIZE), PGSIZE);
f0102d92:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102d97:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102d9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d9f:	e8 60 fb ff ff       	call   f0102904 <segment_alloc>
	if (env_alloc_info < 0)
	{
		panic("env_alloc: %e", env_alloc_info);
	}
	load_icode(env, binary, size);
}
f0102da4:	83 c4 3c             	add    $0x3c,%esp
f0102da7:	5b                   	pop    %ebx
f0102da8:	5e                   	pop    %esi
f0102da9:	5f                   	pop    %edi
f0102daa:	5d                   	pop    %ebp
f0102dab:	c3                   	ret    

f0102dac <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0102dac:	55                   	push   %ebp
f0102dad:	89 e5                	mov    %esp,%ebp
f0102daf:	57                   	push   %edi
f0102db0:	56                   	push   %esi
f0102db1:	53                   	push   %ebx
f0102db2:	83 ec 2c             	sub    $0x2c,%esp
f0102db5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;
	
	// If freeing the current environment, switch to boot_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102db8:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f0102dbd:	39 c7                	cmp    %eax,%edi
f0102dbf:	75 09                	jne    f0102dca <env_free+0x1e>
f0102dc1:	8b 15 64 67 1b f0    	mov    0xf01b6764,%edx
f0102dc7:	0f 22 da             	mov    %edx,%cr3
		lcr3(boot_cr3);

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102dca:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0102dcd:	ba 00 00 00 00       	mov    $0x0,%edx
f0102dd2:	85 c0                	test   %eax,%eax
f0102dd4:	74 03                	je     f0102dd9 <env_free+0x2d>
f0102dd6:	8b 50 4c             	mov    0x4c(%eax),%edx
f0102dd9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102ddd:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102de1:	c7 04 24 8a 5e 10 f0 	movl   $0xf0105e8a,(%esp)
f0102de8:	e8 d5 03 00 00       	call   f01031c2 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ded:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102df4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102df7:	c1 e0 02             	shl    $0x2,%eax
f0102dfa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102dfd:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e00:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102e03:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102e06:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102e0c:	0f 84 bb 00 00 00    	je     f0102ecd <env_free+0x121>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102e12:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0102e18:	89 f0                	mov    %esi,%eax
f0102e1a:	c1 e8 0c             	shr    $0xc,%eax
f0102e1d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102e20:	3b 05 60 67 1b f0    	cmp    0xf01b6760,%eax
f0102e26:	72 20                	jb     f0102e48 <env_free+0x9c>
f0102e28:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102e2c:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0102e33:	f0 
f0102e34:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0102e3b:	00 
f0102e3c:	c7 04 24 5c 5e 10 f0 	movl   $0xf0105e5c,(%esp)
f0102e43:	e8 8a d2 ff ff       	call   f01000d2 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102e48:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102e4b:	c1 e2 16             	shl    $0x16,%edx
f0102e4e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e51:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102e56:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102e5d:	01 
f0102e5e:	74 17                	je     f0102e77 <env_free+0xcb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102e60:	89 d8                	mov    %ebx,%eax
f0102e62:	c1 e0 0c             	shl    $0xc,%eax
f0102e65:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102e68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e6c:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e6f:	89 04 24             	mov    %eax,(%esp)
f0102e72:	e8 0c e2 ff ff       	call   f0101083 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e77:	83 c3 01             	add    $0x1,%ebx
f0102e7a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102e80:	75 d4                	jne    f0102e56 <env_free+0xaa>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102e82:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e85:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e88:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102e8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102e92:	3b 05 60 67 1b f0    	cmp    0xf01b6760,%eax
f0102e98:	72 1c                	jb     f0102eb6 <env_free+0x10a>
		panic("pa2page called with invalid pa");
f0102e9a:	c7 44 24 08 28 57 10 	movl   $0xf0105728,0x8(%esp)
f0102ea1:	f0 
f0102ea2:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102ea9:	00 
f0102eaa:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0102eb1:	e8 1c d2 ff ff       	call   f01000d2 <_panic>
	return &pages[PPN(pa)];
f0102eb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102eb9:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102ebc:	c1 e0 02             	shl    $0x2,%eax
f0102ebf:	03 05 6c 67 1b f0    	add    0xf01b676c,%eax
		page_decref(pa2page(pa));
f0102ec5:	89 04 24             	mov    %eax,(%esp)
f0102ec8:	e8 31 df ff ff       	call   f0100dfe <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ecd:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102ed1:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0102ed8:	0f 85 16 ff ff ff    	jne    f0102df4 <env_free+0x48>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0102ede:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0102ee1:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0102ee8:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0102eef:	c1 e8 0c             	shr    $0xc,%eax
f0102ef2:	3b 05 60 67 1b f0    	cmp    0xf01b6760,%eax
f0102ef8:	72 1c                	jb     f0102f16 <env_free+0x16a>
		panic("pa2page called with invalid pa");
f0102efa:	c7 44 24 08 28 57 10 	movl   $0xf0105728,0x8(%esp)
f0102f01:	f0 
f0102f02:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0102f09:	00 
f0102f0a:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0102f11:	e8 bc d1 ff ff       	call   f01000d2 <_panic>
	return &pages[PPN(pa)];
f0102f16:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102f19:	c1 e0 02             	shl    $0x2,%eax
f0102f1c:	03 05 6c 67 1b f0    	add    0xf01b676c,%eax
	page_decref(pa2page(pa));
f0102f22:	89 04 24             	mov    %eax,(%esp)
f0102f25:	e8 d4 de ff ff       	call   f0100dfe <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102f2a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0102f31:	a1 c8 5a 1b f0       	mov    0xf01b5ac8,%eax
f0102f36:	89 47 44             	mov    %eax,0x44(%edi)
f0102f39:	85 c0                	test   %eax,%eax
f0102f3b:	74 06                	je     f0102f43 <env_free+0x197>
f0102f3d:	8d 57 44             	lea    0x44(%edi),%edx
f0102f40:	89 50 48             	mov    %edx,0x48(%eax)
f0102f43:	89 3d c8 5a 1b f0    	mov    %edi,0xf01b5ac8
f0102f49:	c7 47 48 c8 5a 1b f0 	movl   $0xf01b5ac8,0x48(%edi)
}
f0102f50:	83 c4 2c             	add    $0x2c,%esp
f0102f53:	5b                   	pop    %ebx
f0102f54:	5e                   	pop    %esi
f0102f55:	5f                   	pop    %edi
f0102f56:	5d                   	pop    %ebp
f0102f57:	c3                   	ret    

f0102f58 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102f58:	55                   	push   %ebp
f0102f59:	89 e5                	mov    %esp,%ebp
f0102f5b:	53                   	push   %ebx
f0102f5c:	83 ec 14             	sub    $0x14,%esp
f0102f5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	env_free(e);
f0102f62:	89 1c 24             	mov    %ebx,(%esp)
f0102f65:	e8 42 fe ff ff       	call   f0102dac <env_free>

	if (curenv == e) {
f0102f6a:	39 1d c0 5a 1b f0    	cmp    %ebx,0xf01b5ac0
f0102f70:	75 0f                	jne    f0102f81 <env_destroy+0x29>
		curenv = NULL;
f0102f72:	c7 05 c0 5a 1b f0 00 	movl   $0x0,0xf01b5ac0
f0102f79:	00 00 00 
		sched_yield();
f0102f7c:	e8 ff 09 00 00       	call   f0103980 <sched_yield>
	}
}
f0102f81:	83 c4 14             	add    $0x14,%esp
f0102f84:	5b                   	pop    %ebx
f0102f85:	5d                   	pop    %ebp
f0102f86:	c3                   	ret    

f0102f87 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102f87:	55                   	push   %ebp
f0102f88:	89 e5                	mov    %esp,%ebp
f0102f8a:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102f8d:	8b 65 08             	mov    0x8(%ebp),%esp
f0102f90:	61                   	popa   
f0102f91:	07                   	pop    %es
f0102f92:	1f                   	pop    %ds
f0102f93:	83 c4 08             	add    $0x8,%esp
f0102f96:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102f97:	c7 44 24 08 a0 5e 10 	movl   $0xf0105ea0,0x8(%esp)
f0102f9e:	f0 
f0102f9f:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
f0102fa6:	00 
f0102fa7:	c7 04 24 5c 5e 10 f0 	movl   $0xf0105e5c,(%esp)
f0102fae:	e8 1f d1 ff ff       	call   f01000d2 <_panic>

f0102fb3 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0102fb3:	55                   	push   %ebp
f0102fb4:	89 e5                	mov    %esp,%ebp
f0102fb6:	83 ec 18             	sub    $0x18,%esp
f0102fb9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Note: if this is the first call to env_run, curenv is NULL.
	// To start a given environment running in user mode.
	// PART 1
	// switch, and the original status may not be stored as the function 
	// NEVER RETURNS!
	curenv = e;
f0102fbc:	a3 c0 5a 1b f0       	mov    %eax,0xf01b5ac0
	// update its 'env_runs' counter
	++(curenv->env_runs);
f0102fc1:	83 40 58 01          	addl   $0x1,0x58(%eax)
	// switch to its address space
	lcr3(PADDR(curenv->env_pgdir));
f0102fc5:	8b 50 5c             	mov    0x5c(%eax),%edx
f0102fc8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102fce:	77 20                	ja     f0102ff0 <env_run+0x3d>
f0102fd0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102fd4:	c7 44 24 08 ac 56 10 	movl   $0xf01056ac,0x8(%esp)
f0102fdb:	f0 
f0102fdc:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
f0102fe3:	00 
f0102fe4:	c7 04 24 5c 5e 10 f0 	movl   $0xf0105e5c,(%esp)
f0102feb:	e8 e2 d0 ff ff       	call   f01000d2 <_panic>
f0102ff0:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102ff6:	0f 22 da             	mov    %edx,%cr3
	// PART 2
	// restore the environment's registers and
	// drop into user mode in the environment.
	env_pop_tf(&(curenv->env_tf));
f0102ff9:	89 04 24             	mov    %eax,(%esp)
f0102ffc:	e8 86 ff ff ff       	call   f0102f87 <env_pop_tf>
f0103001:	00 00                	add    %al,(%eax)
	...

f0103004 <mc146818_read>:
#include <kern/picirq.h>


unsigned
mc146818_read(unsigned reg)
{
f0103004:	55                   	push   %ebp
f0103005:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103007:	ba 70 00 00 00       	mov    $0x70,%edx
f010300c:	8b 45 08             	mov    0x8(%ebp),%eax
f010300f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103010:	b2 71                	mov    $0x71,%dl
f0103012:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103013:	0f b6 c0             	movzbl %al,%eax
}
f0103016:	5d                   	pop    %ebp
f0103017:	c3                   	ret    

f0103018 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103018:	55                   	push   %ebp
f0103019:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010301b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103020:	8b 45 08             	mov    0x8(%ebp),%eax
f0103023:	ee                   	out    %al,(%dx)
f0103024:	b2 71                	mov    $0x71,%dl
f0103026:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103029:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010302a:	5d                   	pop    %ebp
f010302b:	c3                   	ret    

f010302c <kclock_init>:


void
kclock_init(void)
{
f010302c:	55                   	push   %ebp
f010302d:	89 e5                	mov    %esp,%ebp
f010302f:	83 ec 18             	sub    $0x18,%esp
f0103032:	ba 43 00 00 00       	mov    $0x43,%edx
f0103037:	b8 34 00 00 00       	mov    $0x34,%eax
f010303c:	ee                   	out    %al,(%dx)
f010303d:	b2 40                	mov    $0x40,%dl
f010303f:	b8 9c ff ff ff       	mov    $0xffffff9c,%eax
f0103044:	ee                   	out    %al,(%dx)
f0103045:	b8 2e 00 00 00       	mov    $0x2e,%eax
f010304a:	ee                   	out    %al,(%dx)
	/* initialize 8253 clock to interrupt 100 times/sec */
	outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
	outb(IO_TIMER1, TIMER_DIV(100) % 256);
	outb(IO_TIMER1, TIMER_DIV(100) / 256);
	cprintf("	Setup timer interrupts via 8259A\n");
f010304b:	c7 04 24 ac 5e 10 f0 	movl   $0xf0105eac,(%esp)
f0103052:	e8 6b 01 00 00       	call   f01031c2 <cprintf>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<0));
f0103057:	0f b7 05 70 a3 11 f0 	movzwl 0xf011a370,%eax
f010305e:	25 fe ff 00 00       	and    $0xfffe,%eax
f0103063:	89 04 24             	mov    %eax,(%esp)
f0103066:	e8 11 00 00 00       	call   f010307c <irq_setmask_8259A>
	cprintf("	unmasked timer interrupt\n");
f010306b:	c7 04 24 cf 5e 10 f0 	movl   $0xf0105ecf,(%esp)
f0103072:	e8 4b 01 00 00       	call   f01031c2 <cprintf>
}
f0103077:	c9                   	leave  
f0103078:	c3                   	ret    
f0103079:	00 00                	add    %al,(%eax)
	...

f010307c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010307c:	55                   	push   %ebp
f010307d:	89 e5                	mov    %esp,%ebp
f010307f:	56                   	push   %esi
f0103080:	53                   	push   %ebx
f0103081:	83 ec 10             	sub    $0x10,%esp
f0103084:	8b 45 08             	mov    0x8(%ebp),%eax
f0103087:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103089:	66 a3 70 a3 11 f0    	mov    %ax,0xf011a370
	if (!didinit)
f010308f:	83 3d cc 5a 1b f0 00 	cmpl   $0x0,0xf01b5acc
f0103096:	74 4e                	je     f01030e6 <irq_setmask_8259A+0x6a>
f0103098:	ba 21 00 00 00       	mov    $0x21,%edx
f010309d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f010309e:	89 f0                	mov    %esi,%eax
f01030a0:	66 c1 e8 08          	shr    $0x8,%ax
f01030a4:	b2 a1                	mov    $0xa1,%dl
f01030a6:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01030a7:	c7 04 24 ea 5e 10 f0 	movl   $0xf0105eea,(%esp)
f01030ae:	e8 0f 01 00 00       	call   f01031c2 <cprintf>
	for (i = 0; i < 16; i++)
f01030b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01030b8:	0f b7 f6             	movzwl %si,%esi
f01030bb:	f7 d6                	not    %esi
f01030bd:	0f a3 de             	bt     %ebx,%esi
f01030c0:	73 10                	jae    f01030d2 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f01030c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01030c6:	c7 04 24 13 63 10 f0 	movl   $0xf0106313,(%esp)
f01030cd:	e8 f0 00 00 00       	call   f01031c2 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01030d2:	83 c3 01             	add    $0x1,%ebx
f01030d5:	83 fb 10             	cmp    $0x10,%ebx
f01030d8:	75 e3                	jne    f01030bd <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01030da:	c7 04 24 cd 5d 10 f0 	movl   $0xf0105dcd,(%esp)
f01030e1:	e8 dc 00 00 00       	call   f01031c2 <cprintf>
}
f01030e6:	83 c4 10             	add    $0x10,%esp
f01030e9:	5b                   	pop    %ebx
f01030ea:	5e                   	pop    %esi
f01030eb:	5d                   	pop    %ebp
f01030ec:	c3                   	ret    

f01030ed <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01030ed:	55                   	push   %ebp
f01030ee:	89 e5                	mov    %esp,%ebp
f01030f0:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f01030f3:	c7 05 cc 5a 1b f0 01 	movl   $0x1,0xf01b5acc
f01030fa:	00 00 00 
f01030fd:	ba 21 00 00 00       	mov    $0x21,%edx
f0103102:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103107:	ee                   	out    %al,(%dx)
f0103108:	b2 a1                	mov    $0xa1,%dl
f010310a:	ee                   	out    %al,(%dx)
f010310b:	b2 20                	mov    $0x20,%dl
f010310d:	b8 11 00 00 00       	mov    $0x11,%eax
f0103112:	ee                   	out    %al,(%dx)
f0103113:	b2 21                	mov    $0x21,%dl
f0103115:	b8 20 00 00 00       	mov    $0x20,%eax
f010311a:	ee                   	out    %al,(%dx)
f010311b:	b8 04 00 00 00       	mov    $0x4,%eax
f0103120:	ee                   	out    %al,(%dx)
f0103121:	b8 03 00 00 00       	mov    $0x3,%eax
f0103126:	ee                   	out    %al,(%dx)
f0103127:	b2 a0                	mov    $0xa0,%dl
f0103129:	b8 11 00 00 00       	mov    $0x11,%eax
f010312e:	ee                   	out    %al,(%dx)
f010312f:	b2 a1                	mov    $0xa1,%dl
f0103131:	b8 28 00 00 00       	mov    $0x28,%eax
f0103136:	ee                   	out    %al,(%dx)
f0103137:	b8 02 00 00 00       	mov    $0x2,%eax
f010313c:	ee                   	out    %al,(%dx)
f010313d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103142:	ee                   	out    %al,(%dx)
f0103143:	b2 20                	mov    $0x20,%dl
f0103145:	b8 68 00 00 00       	mov    $0x68,%eax
f010314a:	ee                   	out    %al,(%dx)
f010314b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103150:	ee                   	out    %al,(%dx)
f0103151:	b2 a0                	mov    $0xa0,%dl
f0103153:	b8 68 00 00 00       	mov    $0x68,%eax
f0103158:	ee                   	out    %al,(%dx)
f0103159:	b8 0a 00 00 00       	mov    $0xa,%eax
f010315e:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010315f:	0f b7 05 70 a3 11 f0 	movzwl 0xf011a370,%eax
f0103166:	66 83 f8 ff          	cmp    $0xffff,%ax
f010316a:	74 0b                	je     f0103177 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f010316c:	0f b7 c0             	movzwl %ax,%eax
f010316f:	89 04 24             	mov    %eax,(%esp)
f0103172:	e8 05 ff ff ff       	call   f010307c <irq_setmask_8259A>
}
f0103177:	c9                   	leave  
f0103178:	c3                   	ret    
f0103179:	00 00                	add    %al,(%eax)
	...

f010317c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010317c:	55                   	push   %ebp
f010317d:	89 e5                	mov    %esp,%ebp
f010317f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103182:	8b 45 08             	mov    0x8(%ebp),%eax
f0103185:	89 04 24             	mov    %eax,(%esp)
f0103188:	e8 a6 d5 ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f010318d:	c9                   	leave  
f010318e:	c3                   	ret    

f010318f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010318f:	55                   	push   %ebp
f0103190:	89 e5                	mov    %esp,%ebp
f0103192:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103195:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010319c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010319f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01031ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031b1:	c7 04 24 7c 31 10 f0 	movl   $0xf010317c,(%esp)
f01031b8:	e8 67 12 00 00       	call   f0104424 <vprintfmt>
	return cnt;
}
f01031bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01031c0:	c9                   	leave  
f01031c1:	c3                   	ret    

f01031c2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01031c2:	55                   	push   %ebp
f01031c3:	89 e5                	mov    %esp,%ebp
f01031c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f01031c8:	8d 45 0c             	lea    0xc(%ebp),%eax
f01031cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01031d2:	89 04 24             	mov    %eax,(%esp)
f01031d5:	e8 b5 ff ff ff       	call   f010318f <vcprintf>
	va_end(ap);

	return cnt;
}
f01031da:	c9                   	leave  
f01031db:	c3                   	ret    
f01031dc:	00 00                	add    %al,(%eax)
	...

f01031e0 <idt_init>:
}


void
idt_init(void)
{
f01031e0:	55                   	push   %ebp
f01031e1:	89 e5                	mov    %esp,%ebp
	// istrap: 1 for excp, and 0 for intr.
	// sel: segment selector, should be 0x8 or GD_KT, kernel text.
	// off: offset in code segment for interrupt/trap handler,
	// which should be the handler function entry points.
	// dpl: Descriptor Privilege Level, will be compared with cpl
	SETGATE(idt[T_DIVIDE], 0, GD_KT, idt_divide_error, 0);
f01031e3:	b8 04 39 10 f0       	mov    $0xf0103904,%eax
f01031e8:	66 a3 e0 5a 1b f0    	mov    %ax,0xf01b5ae0
f01031ee:	66 c7 05 e2 5a 1b f0 	movw   $0x8,0xf01b5ae2
f01031f5:	08 00 
f01031f7:	c6 05 e4 5a 1b f0 00 	movb   $0x0,0xf01b5ae4
f01031fe:	c6 05 e5 5a 1b f0 8e 	movb   $0x8e,0xf01b5ae5
f0103205:	c1 e8 10             	shr    $0x10,%eax
f0103208:	66 a3 e6 5a 1b f0    	mov    %ax,0xf01b5ae6
	SETGATE(idt[T_DEBUG], 0, GD_KT, idt_debug_exception, 0);
f010320e:	b8 0a 39 10 f0       	mov    $0xf010390a,%eax
f0103213:	66 a3 e8 5a 1b f0    	mov    %ax,0xf01b5ae8
f0103219:	66 c7 05 ea 5a 1b f0 	movw   $0x8,0xf01b5aea
f0103220:	08 00 
f0103222:	c6 05 ec 5a 1b f0 00 	movb   $0x0,0xf01b5aec
f0103229:	c6 05 ed 5a 1b f0 8e 	movb   $0x8e,0xf01b5aed
f0103230:	c1 e8 10             	shr    $0x10,%eax
f0103233:	66 a3 ee 5a 1b f0    	mov    %ax,0xf01b5aee
	SETGATE(idt[T_NMI], 0, GD_KT, idt_nmi_interrupt, 0);
f0103239:	b8 10 39 10 f0       	mov    $0xf0103910,%eax
f010323e:	66 a3 f0 5a 1b f0    	mov    %ax,0xf01b5af0
f0103244:	66 c7 05 f2 5a 1b f0 	movw   $0x8,0xf01b5af2
f010324b:	08 00 
f010324d:	c6 05 f4 5a 1b f0 00 	movb   $0x0,0xf01b5af4
f0103254:	c6 05 f5 5a 1b f0 8e 	movb   $0x8e,0xf01b5af5
f010325b:	c1 e8 10             	shr    $0x10,%eax
f010325e:	66 a3 f6 5a 1b f0    	mov    %ax,0xf01b5af6
	SETGATE(idt[T_BRKPT], 0, GD_KT, idt_breakpoint, 3);
f0103264:	b8 16 39 10 f0       	mov    $0xf0103916,%eax
f0103269:	66 a3 f8 5a 1b f0    	mov    %ax,0xf01b5af8
f010326f:	66 c7 05 fa 5a 1b f0 	movw   $0x8,0xf01b5afa
f0103276:	08 00 
f0103278:	c6 05 fc 5a 1b f0 00 	movb   $0x0,0xf01b5afc
f010327f:	c6 05 fd 5a 1b f0 ee 	movb   $0xee,0xf01b5afd
f0103286:	c1 e8 10             	shr    $0x10,%eax
f0103289:	66 a3 fe 5a 1b f0    	mov    %ax,0xf01b5afe
	SETGATE(idt[T_OFLOW], 1, GD_KT, idt_overflow, 3);
f010328f:	b8 1c 39 10 f0       	mov    $0xf010391c,%eax
f0103294:	66 a3 00 5b 1b f0    	mov    %ax,0xf01b5b00
f010329a:	66 c7 05 02 5b 1b f0 	movw   $0x8,0xf01b5b02
f01032a1:	08 00 
f01032a3:	c6 05 04 5b 1b f0 00 	movb   $0x0,0xf01b5b04
f01032aa:	c6 05 05 5b 1b f0 ef 	movb   $0xef,0xf01b5b05
f01032b1:	c1 e8 10             	shr    $0x10,%eax
f01032b4:	66 a3 06 5b 1b f0    	mov    %ax,0xf01b5b06
	SETGATE(idt[T_BOUND], 1, GD_KT, idt_bound_check, 3);
f01032ba:	b8 22 39 10 f0       	mov    $0xf0103922,%eax
f01032bf:	66 a3 08 5b 1b f0    	mov    %ax,0xf01b5b08
f01032c5:	66 c7 05 0a 5b 1b f0 	movw   $0x8,0xf01b5b0a
f01032cc:	08 00 
f01032ce:	c6 05 0c 5b 1b f0 00 	movb   $0x0,0xf01b5b0c
f01032d5:	c6 05 0d 5b 1b f0 ef 	movb   $0xef,0xf01b5b0d
f01032dc:	c1 e8 10             	shr    $0x10,%eax
f01032df:	66 a3 0e 5b 1b f0    	mov    %ax,0xf01b5b0e
	// SETGATE(idt[T_OFLOW], 0, GD_KT, idt_overflow, 0);
	// SETGATE(idt[T_BOUND], 0, GD_KT, idt_bound_check, 0);
	SETGATE(idt[T_ILLOP], 0, GD_KT, idt_illegal_opcode, 0);
f01032e5:	b8 28 39 10 f0       	mov    $0xf0103928,%eax
f01032ea:	66 a3 10 5b 1b f0    	mov    %ax,0xf01b5b10
f01032f0:	66 c7 05 12 5b 1b f0 	movw   $0x8,0xf01b5b12
f01032f7:	08 00 
f01032f9:	c6 05 14 5b 1b f0 00 	movb   $0x0,0xf01b5b14
f0103300:	c6 05 15 5b 1b f0 8e 	movb   $0x8e,0xf01b5b15
f0103307:	c1 e8 10             	shr    $0x10,%eax
f010330a:	66 a3 16 5b 1b f0    	mov    %ax,0xf01b5b16
	SETGATE(idt[T_DEVICE], 0, GD_KT, idt_device_not_available, 0);
f0103310:	b8 2e 39 10 f0       	mov    $0xf010392e,%eax
f0103315:	66 a3 18 5b 1b f0    	mov    %ax,0xf01b5b18
f010331b:	66 c7 05 1a 5b 1b f0 	movw   $0x8,0xf01b5b1a
f0103322:	08 00 
f0103324:	c6 05 1c 5b 1b f0 00 	movb   $0x0,0xf01b5b1c
f010332b:	c6 05 1d 5b 1b f0 8e 	movb   $0x8e,0xf01b5b1d
f0103332:	c1 e8 10             	shr    $0x10,%eax
f0103335:	66 a3 1e 5b 1b f0    	mov    %ax,0xf01b5b1e
	// I just cannot set the gate's type to 0101B, which states a task gate
	// Don't know why. May be modified later?
	SETGATE(idt[T_DBLFLT], 0, GD_KT, idt_double_fault, 0);
f010333b:	b8 34 39 10 f0       	mov    $0xf0103934,%eax
f0103340:	66 a3 20 5b 1b f0    	mov    %ax,0xf01b5b20
f0103346:	66 c7 05 22 5b 1b f0 	movw   $0x8,0xf01b5b22
f010334d:	08 00 
f010334f:	c6 05 24 5b 1b f0 00 	movb   $0x0,0xf01b5b24
f0103356:	c6 05 25 5b 1b f0 8e 	movb   $0x8e,0xf01b5b25
f010335d:	c1 e8 10             	shr    $0x10,%eax
f0103360:	66 a3 26 5b 1b f0    	mov    %ax,0xf01b5b26
	SETGATE(idt[T_TSS], 0, GD_KT, idt_invalid_tss, 0);
f0103366:	b8 38 39 10 f0       	mov    $0xf0103938,%eax
f010336b:	66 a3 30 5b 1b f0    	mov    %ax,0xf01b5b30
f0103371:	66 c7 05 32 5b 1b f0 	movw   $0x8,0xf01b5b32
f0103378:	08 00 
f010337a:	c6 05 34 5b 1b f0 00 	movb   $0x0,0xf01b5b34
f0103381:	c6 05 35 5b 1b f0 8e 	movb   $0x8e,0xf01b5b35
f0103388:	c1 e8 10             	shr    $0x10,%eax
f010338b:	66 a3 36 5b 1b f0    	mov    %ax,0xf01b5b36
	SETGATE(idt[T_SEGNP], 0, GD_KT, idt_segment_not_present, 0);
f0103391:	b8 3c 39 10 f0       	mov    $0xf010393c,%eax
f0103396:	66 a3 38 5b 1b f0    	mov    %ax,0xf01b5b38
f010339c:	66 c7 05 3a 5b 1b f0 	movw   $0x8,0xf01b5b3a
f01033a3:	08 00 
f01033a5:	c6 05 3c 5b 1b f0 00 	movb   $0x0,0xf01b5b3c
f01033ac:	c6 05 3d 5b 1b f0 8e 	movb   $0x8e,0xf01b5b3d
f01033b3:	c1 e8 10             	shr    $0x10,%eax
f01033b6:	66 a3 3e 5b 1b f0    	mov    %ax,0xf01b5b3e
	SETGATE(idt[T_STACK], 0, GD_KT, idt_stack_exception, 0);
f01033bc:	b8 40 39 10 f0       	mov    $0xf0103940,%eax
f01033c1:	66 a3 40 5b 1b f0    	mov    %ax,0xf01b5b40
f01033c7:	66 c7 05 42 5b 1b f0 	movw   $0x8,0xf01b5b42
f01033ce:	08 00 
f01033d0:	c6 05 44 5b 1b f0 00 	movb   $0x0,0xf01b5b44
f01033d7:	c6 05 45 5b 1b f0 8e 	movb   $0x8e,0xf01b5b45
f01033de:	c1 e8 10             	shr    $0x10,%eax
f01033e1:	66 a3 46 5b 1b f0    	mov    %ax,0xf01b5b46
	SETGATE(idt[T_GPFLT], 1, GD_KT, idt_general_protection_fault, 0);
f01033e7:	b8 44 39 10 f0       	mov    $0xf0103944,%eax
f01033ec:	66 a3 48 5b 1b f0    	mov    %ax,0xf01b5b48
f01033f2:	66 c7 05 4a 5b 1b f0 	movw   $0x8,0xf01b5b4a
f01033f9:	08 00 
f01033fb:	c6 05 4c 5b 1b f0 00 	movb   $0x0,0xf01b5b4c
f0103402:	c6 05 4d 5b 1b f0 8f 	movb   $0x8f,0xf01b5b4d
f0103409:	c1 e8 10             	shr    $0x10,%eax
f010340c:	66 a3 4e 5b 1b f0    	mov    %ax,0xf01b5b4e
	// SETGATE(idt[T_GPFLT], 0, GD_KT, idt_general_protection_fault, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, idt_page_fault, 0);
f0103412:	b8 48 39 10 f0       	mov    $0xf0103948,%eax
f0103417:	66 a3 50 5b 1b f0    	mov    %ax,0xf01b5b50
f010341d:	66 c7 05 52 5b 1b f0 	movw   $0x8,0xf01b5b52
f0103424:	08 00 
f0103426:	c6 05 54 5b 1b f0 00 	movb   $0x0,0xf01b5b54
f010342d:	c6 05 55 5b 1b f0 8e 	movb   $0x8e,0xf01b5b55
f0103434:	c1 e8 10             	shr    $0x10,%eax
f0103437:	66 a3 56 5b 1b f0    	mov    %ax,0xf01b5b56
	SETGATE(idt[T_FPERR], 0, GD_KT, idt_floating_point_error, 0);
f010343d:	b8 4c 39 10 f0       	mov    $0xf010394c,%eax
f0103442:	66 a3 60 5b 1b f0    	mov    %ax,0xf01b5b60
f0103448:	66 c7 05 62 5b 1b f0 	movw   $0x8,0xf01b5b62
f010344f:	08 00 
f0103451:	c6 05 64 5b 1b f0 00 	movb   $0x0,0xf01b5b64
f0103458:	c6 05 65 5b 1b f0 8e 	movb   $0x8e,0xf01b5b65
f010345f:	c1 e8 10             	shr    $0x10,%eax
f0103462:	66 a3 66 5b 1b f0    	mov    %ax,0xf01b5b66
	SETGATE(idt[T_ALIGN], 0, GD_KT, idt_aligment_check, 0);
f0103468:	b8 52 39 10 f0       	mov    $0xf0103952,%eax
f010346d:	66 a3 68 5b 1b f0    	mov    %ax,0xf01b5b68
f0103473:	66 c7 05 6a 5b 1b f0 	movw   $0x8,0xf01b5b6a
f010347a:	08 00 
f010347c:	c6 05 6c 5b 1b f0 00 	movb   $0x0,0xf01b5b6c
f0103483:	c6 05 6d 5b 1b f0 8e 	movb   $0x8e,0xf01b5b6d
f010348a:	c1 e8 10             	shr    $0x10,%eax
f010348d:	66 a3 6e 5b 1b f0    	mov    %ax,0xf01b5b6e
	SETGATE(idt[T_MCHK], 0, GD_KT, idt_machine_check, 0);
f0103493:	b8 56 39 10 f0       	mov    $0xf0103956,%eax
f0103498:	66 a3 70 5b 1b f0    	mov    %ax,0xf01b5b70
f010349e:	66 c7 05 72 5b 1b f0 	movw   $0x8,0xf01b5b72
f01034a5:	08 00 
f01034a7:	c6 05 74 5b 1b f0 00 	movb   $0x0,0xf01b5b74
f01034ae:	c6 05 75 5b 1b f0 8e 	movb   $0x8e,0xf01b5b75
f01034b5:	c1 e8 10             	shr    $0x10,%eax
f01034b8:	66 a3 76 5b 1b f0    	mov    %ax,0xf01b5b76
	SETGATE(idt[T_SIMDERR], 0, GD_KT, idt_simd_floating_point_error, 0);
f01034be:	b8 5c 39 10 f0       	mov    $0xf010395c,%eax
f01034c3:	66 a3 78 5b 1b f0    	mov    %ax,0xf01b5b78
f01034c9:	66 c7 05 7a 5b 1b f0 	movw   $0x8,0xf01b5b7a
f01034d0:	08 00 
f01034d2:	c6 05 7c 5b 1b f0 00 	movb   $0x0,0xf01b5b7c
f01034d9:	c6 05 7d 5b 1b f0 8e 	movb   $0x8e,0xf01b5b7d
f01034e0:	c1 e8 10             	shr    $0x10,%eax
f01034e3:	66 a3 7e 5b 1b f0    	mov    %ax,0xf01b5b7e
	SETGATE(idt[T_SYSCALL], 1, GD_KT, idt_system_call, 3);
f01034e9:	b8 62 39 10 f0       	mov    $0xf0103962,%eax
f01034ee:	66 a3 60 5c 1b f0    	mov    %ax,0xf01b5c60
f01034f4:	66 c7 05 62 5c 1b f0 	movw   $0x8,0xf01b5c62
f01034fb:	08 00 
f01034fd:	c6 05 64 5c 1b f0 00 	movb   $0x0,0xf01b5c64
f0103504:	c6 05 65 5c 1b f0 ef 	movb   $0xef,0xf01b5c65
f010350b:	c1 e8 10             	shr    $0x10,%eax
f010350e:	66 a3 66 5c 1b f0    	mov    %ax,0xf01b5c66
	// SETGATE(idt[T_SYSCALL], 0, GD_KT, idt_system_call, 3);

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103514:	c7 05 e4 62 1b f0 00 	movl   $0xefc00000,0xf01b62e4
f010351b:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f010351e:	66 c7 05 e8 62 1b f0 	movw   $0x10,0xf01b62e8
f0103525:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103527:	66 c7 05 68 a3 11 f0 	movw   $0x68,0xf011a368
f010352e:	68 00 
f0103530:	b8 e0 62 1b f0       	mov    $0xf01b62e0,%eax
f0103535:	66 a3 6a a3 11 f0    	mov    %ax,0xf011a36a
f010353b:	89 c2                	mov    %eax,%edx
f010353d:	c1 ea 10             	shr    $0x10,%edx
f0103540:	88 15 6c a3 11 f0    	mov    %dl,0xf011a36c
f0103546:	c6 05 6e a3 11 f0 40 	movb   $0x40,0xf011a36e
f010354d:	c1 e8 18             	shr    $0x18,%eax
f0103550:	a2 6f a3 11 f0       	mov    %al,0xf011a36f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0103555:	c6 05 6d a3 11 f0 89 	movb   $0x89,0xf011a36d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010355c:	b8 28 00 00 00       	mov    $0x28,%eax
f0103561:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0103564:	0f 01 1d 74 a3 11 f0 	lidtl  0xf011a374
}
f010356b:	5d                   	pop    %ebp
f010356c:	c3                   	ret    

f010356d <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f010356d:	55                   	push   %ebp
f010356e:	89 e5                	mov    %esp,%ebp
f0103570:	53                   	push   %ebx
f0103571:	83 ec 14             	sub    $0x14,%esp
f0103574:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103577:	8b 03                	mov    (%ebx),%eax
f0103579:	89 44 24 04          	mov    %eax,0x4(%esp)
f010357d:	c7 04 24 fe 5e 10 f0 	movl   $0xf0105efe,(%esp)
f0103584:	e8 39 fc ff ff       	call   f01031c2 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103589:	8b 43 04             	mov    0x4(%ebx),%eax
f010358c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103590:	c7 04 24 0d 5f 10 f0 	movl   $0xf0105f0d,(%esp)
f0103597:	e8 26 fc ff ff       	call   f01031c2 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010359c:	8b 43 08             	mov    0x8(%ebx),%eax
f010359f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035a3:	c7 04 24 1c 5f 10 f0 	movl   $0xf0105f1c,(%esp)
f01035aa:	e8 13 fc ff ff       	call   f01031c2 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01035af:	8b 43 0c             	mov    0xc(%ebx),%eax
f01035b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035b6:	c7 04 24 2b 5f 10 f0 	movl   $0xf0105f2b,(%esp)
f01035bd:	e8 00 fc ff ff       	call   f01031c2 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01035c2:	8b 43 10             	mov    0x10(%ebx),%eax
f01035c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035c9:	c7 04 24 3a 5f 10 f0 	movl   $0xf0105f3a,(%esp)
f01035d0:	e8 ed fb ff ff       	call   f01031c2 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01035d5:	8b 43 14             	mov    0x14(%ebx),%eax
f01035d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035dc:	c7 04 24 49 5f 10 f0 	movl   $0xf0105f49,(%esp)
f01035e3:	e8 da fb ff ff       	call   f01031c2 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01035e8:	8b 43 18             	mov    0x18(%ebx),%eax
f01035eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035ef:	c7 04 24 58 5f 10 f0 	movl   $0xf0105f58,(%esp)
f01035f6:	e8 c7 fb ff ff       	call   f01031c2 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01035fb:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01035fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103602:	c7 04 24 67 5f 10 f0 	movl   $0xf0105f67,(%esp)
f0103609:	e8 b4 fb ff ff       	call   f01031c2 <cprintf>
}
f010360e:	83 c4 14             	add    $0x14,%esp
f0103611:	5b                   	pop    %ebx
f0103612:	5d                   	pop    %ebp
f0103613:	c3                   	ret    

f0103614 <print_trapframe>:
	asm volatile("lidt idt_pd");
}

void
print_trapframe(struct Trapframe *tf)
{
f0103614:	55                   	push   %ebp
f0103615:	89 e5                	mov    %esp,%ebp
f0103617:	53                   	push   %ebx
f0103618:	83 ec 14             	sub    $0x14,%esp
f010361b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010361e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103622:	c7 04 24 a4 5f 10 f0 	movl   $0xf0105fa4,(%esp)
f0103629:	e8 94 fb ff ff       	call   f01031c2 <cprintf>
	print_regs(&tf->tf_regs);
f010362e:	89 1c 24             	mov    %ebx,(%esp)
f0103631:	e8 37 ff ff ff       	call   f010356d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103636:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010363a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010363e:	c7 04 24 b6 5f 10 f0 	movl   $0xf0105fb6,(%esp)
f0103645:	e8 78 fb ff ff       	call   f01031c2 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010364a:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010364e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103652:	c7 04 24 c9 5f 10 f0 	movl   $0xf0105fc9,(%esp)
f0103659:	e8 64 fb ff ff       	call   f01031c2 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010365e:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103661:	83 f8 13             	cmp    $0x13,%eax
f0103664:	77 09                	ja     f010366f <print_trapframe+0x5b>
		return excnames[trapno];
f0103666:	8b 14 85 00 62 10 f0 	mov    -0xfef9e00(,%eax,4),%edx
f010366d:	eb 1d                	jmp    f010368c <print_trapframe+0x78>
	if (trapno == T_SYSCALL)
		return "System call";
f010366f:	ba 76 5f 10 f0       	mov    $0xf0105f76,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0103674:	83 f8 30             	cmp    $0x30,%eax
f0103677:	74 13                	je     f010368c <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103679:	8d 50 e0             	lea    -0x20(%eax),%edx
f010367c:	83 fa 0f             	cmp    $0xf,%edx
		return "Hardware Interrupt";
f010367f:	ba 82 5f 10 f0       	mov    $0xf0105f82,%edx
f0103684:	b9 95 5f 10 f0       	mov    $0xf0105f95,%ecx
f0103689:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010368c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103690:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103694:	c7 04 24 dc 5f 10 f0 	movl   $0xf0105fdc,(%esp)
f010369b:	e8 22 fb ff ff       	call   f01031c2 <cprintf>
	cprintf("  err  0x%08x\n", tf->tf_err);
f01036a0:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01036a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036a7:	c7 04 24 ee 5f 10 f0 	movl   $0xf0105fee,(%esp)
f01036ae:	e8 0f fb ff ff       	call   f01031c2 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01036b3:	8b 43 30             	mov    0x30(%ebx),%eax
f01036b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036ba:	c7 04 24 fd 5f 10 f0 	movl   $0xf0105ffd,(%esp)
f01036c1:	e8 fc fa ff ff       	call   f01031c2 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01036c6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01036ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036ce:	c7 04 24 0c 60 10 f0 	movl   $0xf010600c,(%esp)
f01036d5:	e8 e8 fa ff ff       	call   f01031c2 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01036da:	8b 43 38             	mov    0x38(%ebx),%eax
f01036dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036e1:	c7 04 24 1f 60 10 f0 	movl   $0xf010601f,(%esp)
f01036e8:	e8 d5 fa ff ff       	call   f01031c2 <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f01036ed:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01036f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036f4:	c7 04 24 2e 60 10 f0 	movl   $0xf010602e,(%esp)
f01036fb:	e8 c2 fa ff ff       	call   f01031c2 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103700:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103704:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103708:	c7 04 24 3d 60 10 f0 	movl   $0xf010603d,(%esp)
f010370f:	e8 ae fa ff ff       	call   f01031c2 <cprintf>
}
f0103714:	83 c4 14             	add    $0x14,%esp
f0103717:	5b                   	pop    %ebx
f0103718:	5d                   	pop    %ebp
f0103719:	c3                   	ret    

f010371a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010371a:	55                   	push   %ebp
f010371b:	89 e5                	mov    %esp,%ebp
f010371d:	83 ec 38             	sub    $0x38,%esp
f0103720:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103723:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103726:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103729:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010372c:	0f 20 d2             	mov    %cr2,%edx
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f010372f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103733:	75 1c                	jne    f0103751 <page_fault_handler+0x37>
	{
        		panic("Page fault in kernel");  
f0103735:	c7 44 24 08 50 60 10 	movl   $0xf0106050,0x8(%esp)
f010373c:	f0 
f010373d:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
f0103744:	00 
f0103745:	c7 04 24 65 60 10 f0 	movl   $0xf0106065,(%esp)
f010374c:	e8 81 c9 ff ff       	call   f01000d2 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall != NULL)
f0103751:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f0103756:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010375a:	74 63                	je     f01037bf <page_fault_handler+0xa5>
		// into stack before pushing an UTrapframe.
		// When it is needed to check whether it is nested,
		// just check whether the crrent stack stands between
		// “UXSTACKTOP-PGSIZE” and “UXSTACKTOP-1”.
		// current stack means "esp"
		if ((unsigned int)tf->tf_esp >= UXSTACKTOP-PGSIZE
f010375c:	8b 43 3c             	mov    0x3c(%ebx),%eax
			&& (unsigned int)tf->tf_esp < UXSTACKTOP)
f010375f:	8d 88 00 10 40 11    	lea    0x11401000(%eax),%ecx
		{
			// nested page fault, a blank word needed to save esp to
			// switch recursively later to jump back to user code
			// without visiting kernel after page_fault_handler
			// see _pgfault_upcall
			utf = (struct UTrapframe *)(tf->tf_esp-sizeof(struct UTrapframe)-4);
f0103765:	83 e8 38             	sub    $0x38,%eax
f0103768:	81 f9 ff 0f 00 00    	cmp    $0xfff,%ecx
f010376e:	b9 cc ff bf ee       	mov    $0xeebfffcc,%ecx
f0103773:	0f 46 c8             	cmovbe %eax,%ecx
f0103776:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
			utf = (struct UTrapframe *)(UXSTACKTOP-sizeof(struct UTrapframe));
		}
		// set up page fault stack frame on user excp stack
		// Read processor's CR2 register to find the faulting address
		// fault_va = rcr2();
		utf->utf_fault_va = fault_va;
f0103779:	89 11                	mov    %edx,(%ecx)
		utf->utf_err = tf->tf_err;
f010377b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010377e:	89 41 04             	mov    %eax,0x4(%ecx)
		utf->utf_regs = tf->tf_regs;
f0103781:	89 c8                	mov    %ecx,%eax
f0103783:	83 c0 08             	add    $0x8,%eax
f0103786:	b9 08 00 00 00       	mov    $0x8,%ecx
f010378b:	89 c7                	mov    %eax,%edi
f010378d:	89 de                	mov    %ebx,%esi
f010378f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0103791:	8b 43 30             	mov    0x30(%ebx),%eax
f0103794:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103797:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f010379a:	8b 43 38             	mov    0x38(%ebx),%eax
f010379d:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01037a0:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01037a3:	89 42 30             	mov    %eax,0x30(%edx)
		//  To change what the user environment runs, modify 'curenv->env_tf'
		//  (the 'tf' variable points at 'curenv->env_tf').
		// Well, then why should we set such an argument?
		// eip points to the next ins
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f01037a6:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f01037ab:	8b 50 64             	mov    0x64(%eax),%edx
f01037ae:	89 53 30             	mov    %edx,0x30(%ebx)
		// to start executing on user excp stack
		tf->tf_esp = (uintptr_t)utf;
f01037b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01037b4:	89 53 3c             	mov    %edx,0x3c(%ebx)
		env_run(curenv);
f01037b7:	89 04 24             	mov    %eax,(%esp)
f01037ba:	e8 f4 f7 ff ff       	call   f0102fb3 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01037bf:	8b 4b 30             	mov    0x30(%ebx),%ecx
f01037c2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01037c6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01037ca:	8b 40 4c             	mov    0x4c(%eax),%eax
f01037cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037d1:	c7 04 24 d4 61 10 f0 	movl   $0xf01061d4,(%esp)
f01037d8:	e8 e5 f9 ff ff       	call   f01031c2 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01037dd:	89 1c 24             	mov    %ebx,(%esp)
f01037e0:	e8 2f fe ff ff       	call   f0103614 <print_trapframe>
	env_destroy(curenv);
f01037e5:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f01037ea:	89 04 24             	mov    %eax,(%esp)
f01037ed:	e8 66 f7 ff ff       	call   f0102f58 <env_destroy>
}
f01037f2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01037f5:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01037f8:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01037fb:	89 ec                	mov    %ebp,%esp
f01037fd:	5d                   	pop    %ebp
f01037fe:	c3                   	ret    

f01037ff <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01037ff:	55                   	push   %ebp
f0103800:	89 e5                	mov    %esp,%ebp
f0103802:	57                   	push   %edi
f0103803:	56                   	push   %esi
f0103804:	83 ec 20             	sub    $0x20,%esp
f0103807:	8b 75 08             	mov    0x8(%ebp),%esi
	if ((tf->tf_cs & 3) == 3) {
f010380a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010380e:	83 e0 03             	and    $0x3,%eax
f0103811:	83 f8 03             	cmp    $0x3,%eax
f0103814:	75 3c                	jne    f0103852 <trap+0x53>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103816:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f010381b:	85 c0                	test   %eax,%eax
f010381d:	75 24                	jne    f0103843 <trap+0x44>
f010381f:	c7 44 24 0c 71 60 10 	movl   $0xf0106071,0xc(%esp)
f0103826:	f0 
f0103827:	c7 44 24 08 5d 5c 10 	movl   $0xf0105c5d,0x8(%esp)
f010382e:	f0 
f010382f:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0103836:	00 
f0103837:	c7 04 24 65 60 10 f0 	movl   $0xf0106065,(%esp)
f010383e:	e8 8f c8 ff ff       	call   f01000d2 <_panic>
		curenv->env_tf = *tf;
f0103843:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103848:	89 c7                	mov    %eax,%edi
f010384a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010384c:	8b 35 c0 5a 1b f0    	mov    0xf01b5ac0,%esi
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno)
f0103852:	8b 46 28             	mov    0x28(%esi),%eax
f0103855:	83 f8 0e             	cmp    $0xe,%eax
f0103858:	74 0c                	je     f0103866 <trap+0x67>
f010385a:	83 f8 30             	cmp    $0x30,%eax
f010385d:	74 1d                	je     f010387c <trap+0x7d>
f010385f:	83 f8 03             	cmp    $0x3,%eax
f0103862:	75 4a                	jne    f01038ae <trap+0xaf>
f0103864:	eb 0c                	jmp    f0103872 <trap+0x73>
	{
		case T_PGFLT:
			// dispatch page fault exceptions to page_fault_handler()
			page_fault_handler(tf);
f0103866:	89 34 24             	mov    %esi,(%esp)
f0103869:	e8 ac fe ff ff       	call   f010371a <page_fault_handler>
f010386e:	66 90                	xchg   %ax,%ax
f0103870:	eb 74                	jmp    f01038e6 <trap+0xe7>
			return;
		case T_BRKPT:
			// invoke kernel monitor
			monitor(tf);
f0103872:	89 34 24             	mov    %esi,(%esp)
f0103875:	e8 e6 cf ff ff       	call   f0100860 <monitor>
f010387a:	eb 6a                	jmp    f01038e6 <trap+0xe7>
			// Generic system call: pass system call number in AX,
			// up to five parameters in DX, CX, BX, DI, SI.
			// Interrupt kernel with T_SYSCALL.
			// According to lib/syscall.c
			// Correct order or endless page fault
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f010387c:	8b 46 04             	mov    0x4(%esi),%eax
f010387f:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103883:	8b 06                	mov    (%esi),%eax
f0103885:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103889:	8b 46 10             	mov    0x10(%esi),%eax
f010388c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103890:	8b 46 18             	mov    0x18(%esi),%eax
f0103893:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103897:	8b 46 14             	mov    0x14(%esi),%eax
f010389a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010389e:	8b 46 1c             	mov    0x1c(%esi),%eax
f01038a1:	89 04 24             	mov    %eax,(%esp)
f01038a4:	e8 67 01 00 00       	call   f0103a10 <syscall>
f01038a9:	89 46 1c             	mov    %eax,0x1c(%esi)
f01038ac:	eb 38                	jmp    f01038e6 <trap+0xe7>
	
	// Handle clock and serial interrupts.
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01038ae:	89 34 24             	mov    %esi,(%esp)
f01038b1:	e8 5e fd ff ff       	call   f0103614 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01038b6:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01038bb:	75 1c                	jne    f01038d9 <trap+0xda>
		panic("unhandled trap in kernel");
f01038bd:	c7 44 24 08 78 60 10 	movl   $0xf0106078,0x8(%esp)
f01038c4:	f0 
f01038c5:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f01038cc:	00 
f01038cd:	c7 04 24 65 60 10 f0 	movl   $0xf0106065,(%esp)
f01038d4:	e8 f9 c7 ff ff       	call   f01000d2 <_panic>
	else {
		env_destroy(curenv);
f01038d9:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f01038de:	89 04 24             	mov    %eax,(%esp)
f01038e1:	e8 72 f6 ff ff       	call   f0102f58 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNABLE)
f01038e6:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f01038eb:	85 c0                	test   %eax,%eax
f01038ed:	74 0e                	je     f01038fd <trap+0xfe>
f01038ef:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01038f3:	75 08                	jne    f01038fd <trap+0xfe>
		env_run(curenv);
f01038f5:	89 04 24             	mov    %eax,(%esp)
f01038f8:	e8 b6 f6 ff ff       	call   f0102fb3 <env_run>
	else
		sched_yield();
f01038fd:	e8 7e 00 00 00       	call   f0103980 <sched_yield>
	...

f0103904 <idt_divide_error>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(idt_divide_error, T_DIVIDE)
f0103904:	6a 00                	push   $0x0
f0103906:	6a 00                	push   $0x0
f0103908:	eb 5e                	jmp    f0103968 <_alltraps>

f010390a <idt_debug_exception>:
	TRAPHANDLER_NOEC(idt_debug_exception, T_DEBUG)
f010390a:	6a 00                	push   $0x0
f010390c:	6a 01                	push   $0x1
f010390e:	eb 58                	jmp    f0103968 <_alltraps>

f0103910 <idt_nmi_interrupt>:
	TRAPHANDLER_NOEC(idt_nmi_interrupt, T_NMI)
f0103910:	6a 00                	push   $0x0
f0103912:	6a 02                	push   $0x2
f0103914:	eb 52                	jmp    f0103968 <_alltraps>

f0103916 <idt_breakpoint>:
	TRAPHANDLER_NOEC(idt_breakpoint, T_BRKPT)
f0103916:	6a 00                	push   $0x0
f0103918:	6a 03                	push   $0x3
f010391a:	eb 4c                	jmp    f0103968 <_alltraps>

f010391c <idt_overflow>:
	TRAPHANDLER_NOEC(idt_overflow, T_OFLOW)
f010391c:	6a 00                	push   $0x0
f010391e:	6a 04                	push   $0x4
f0103920:	eb 46                	jmp    f0103968 <_alltraps>

f0103922 <idt_bound_check>:
	TRAPHANDLER_NOEC(idt_bound_check, T_BOUND)
f0103922:	6a 00                	push   $0x0
f0103924:	6a 05                	push   $0x5
f0103926:	eb 40                	jmp    f0103968 <_alltraps>

f0103928 <idt_illegal_opcode>:
	TRAPHANDLER_NOEC(idt_illegal_opcode, T_ILLOP)
f0103928:	6a 00                	push   $0x0
f010392a:	6a 06                	push   $0x6
f010392c:	eb 3a                	jmp    f0103968 <_alltraps>

f010392e <idt_device_not_available>:
	TRAPHANDLER_NOEC(idt_device_not_available, T_DEVICE)
f010392e:	6a 00                	push   $0x0
f0103930:	6a 07                	push   $0x7
f0103932:	eb 34                	jmp    f0103968 <_alltraps>

f0103934 <idt_double_fault>:
	TRAPHANDLER(idt_double_fault, T_DBLFLT)
f0103934:	6a 08                	push   $0x8
f0103936:	eb 30                	jmp    f0103968 <_alltraps>

f0103938 <idt_invalid_tss>:

	TRAPHANDLER(idt_invalid_tss, T_TSS)
f0103938:	6a 0a                	push   $0xa
f010393a:	eb 2c                	jmp    f0103968 <_alltraps>

f010393c <idt_segment_not_present>:
	TRAPHANDLER(idt_segment_not_present, T_SEGNP)
f010393c:	6a 0b                	push   $0xb
f010393e:	eb 28                	jmp    f0103968 <_alltraps>

f0103940 <idt_stack_exception>:
	TRAPHANDLER(idt_stack_exception, T_STACK)
f0103940:	6a 0c                	push   $0xc
f0103942:	eb 24                	jmp    f0103968 <_alltraps>

f0103944 <idt_general_protection_fault>:
	TRAPHANDLER(idt_general_protection_fault, T_GPFLT)
f0103944:	6a 0d                	push   $0xd
f0103946:	eb 20                	jmp    f0103968 <_alltraps>

f0103948 <idt_page_fault>:
	TRAPHANDLER(idt_page_fault, T_PGFLT)
f0103948:	6a 0e                	push   $0xe
f010394a:	eb 1c                	jmp    f0103968 <_alltraps>

f010394c <idt_floating_point_error>:

	TRAPHANDLER_NOEC(idt_floating_point_error, T_FPERR)
f010394c:	6a 00                	push   $0x0
f010394e:	6a 10                	push   $0x10
f0103950:	eb 16                	jmp    f0103968 <_alltraps>

f0103952 <idt_aligment_check>:
	TRAPHANDLER(idt_aligment_check, T_ALIGN)
f0103952:	6a 11                	push   $0x11
f0103954:	eb 12                	jmp    f0103968 <_alltraps>

f0103956 <idt_machine_check>:
	TRAPHANDLER_NOEC(idt_machine_check, T_MCHK)
f0103956:	6a 00                	push   $0x0
f0103958:	6a 12                	push   $0x12
f010395a:	eb 0c                	jmp    f0103968 <_alltraps>

f010395c <idt_simd_floating_point_error>:
	TRAPHANDLER_NOEC(idt_simd_floating_point_error, T_SIMDERR)
f010395c:	6a 00                	push   $0x0
f010395e:	6a 13                	push   $0x13
f0103960:	eb 06                	jmp    f0103968 <_alltraps>

f0103962 <idt_system_call>:
	TRAPHANDLER_NOEC(idt_system_call, T_SYSCALL)
f0103962:	6a 00                	push   $0x0
f0103964:	6a 30                	push   $0x30
f0103966:	eb 00                	jmp    f0103968 <_alltraps>

f0103968 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	/* push values to make the stack look like a struct Trapframe */
	pushl	%ds
f0103968:	1e                   	push   %ds
	pushl	%es
f0103969:	06                   	push   %es
	/* push all regs in */
	pushal
f010396a:	60                   	pusha  

	/* load GD_KD into %ds and %es */
	/* notice that ds and es are 16 bits width */
	movl	$GD_KD,	%eax
f010396b:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,	%ds
f0103970:	8e d8                	mov    %eax,%ds
	movw	%ax,	%es
f0103972:	8e c0                	mov    %eax,%es

	/* pushl %esp to pass a pointer to the Trapframe
	as an argument to trap() and call trap() */
	pushl	%esp
f0103974:	54                   	push   %esp
	call trap
f0103975:	e8 85 fe ff ff       	call   f01037ff <trap>

	/* pop the values pushed in steps 1-3 and iret*/
	popl	%esp
f010397a:	5c                   	pop    %esp
	popal
f010397b:	61                   	popa   
	popl	%es
f010397c:	07                   	pop    %es
	popl	%ds
f010397d:	1f                   	pop    %ds
f010397e:	cf                   	iret   
	...

f0103980 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103980:	55                   	push   %ebp
f0103981:	89 e5                	mov    %esp,%ebp
f0103983:	57                   	push   %edi
f0103984:	56                   	push   %esi
f0103985:	53                   	push   %ebx
f0103986:	83 ec 1c             	sub    $0x1c,%esp
	// unless NOTHING else is runnable.

	// LAB 4: Your code here.
	// after the previously running env
	// curenv may be NULL as curenv may be destroyed by "env_destroy()"
	struct Env *e = (curenv == NULL || curenv >= envs+NENV-1) ? (envs+1) : (curenv+1);
f0103989:	8b 15 c0 5a 1b f0    	mov    0xf01b5ac0,%edx
f010398f:	85 d2                	test   %edx,%edx
f0103991:	74 13                	je     f01039a6 <sched_yield+0x26>
f0103993:	8b 0d c4 5a 1b f0    	mov    0xf01b5ac4,%ecx
f0103999:	81 c1 84 ef 01 00    	add    $0x1ef84,%ecx
f010399f:	8d 42 7c             	lea    0x7c(%edx),%eax
f01039a2:	39 ca                	cmp    %ecx,%edx
f01039a4:	72 08                	jb     f01039ae <sched_yield+0x2e>
f01039a6:	a1 c4 5a 1b f0       	mov    0xf01b5ac4,%eax
f01039ab:	83 c0 7c             	add    $0x7c,%eax
	// skip envs[0]
	int i;	// just a counter
	for (i = 1; i < NENV; ++i)
	{
		if (e->env_status == ENV_RUNNABLE)
f01039ae:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01039b2:	75 10                	jne    f01039c4 <sched_yield+0x44>
f01039b4:	eb 06                	jmp    f01039bc <sched_yield+0x3c>
f01039b6:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01039ba:	75 1c                	jne    f01039d8 <sched_yield+0x58>
		{
			env_run(e);
f01039bc:	89 04 24             	mov    %eax,(%esp)
f01039bf:	e8 ef f5 ff ff       	call   f0102fb3 <env_run>
			// should it return?
			return;
		}
		e = (e >= envs+NENV-1) ? (envs+1) : (e+1);
f01039c4:	8b 3d c4 5a 1b f0    	mov    0xf01b5ac4,%edi
f01039ca:	8d b7 84 ef 01 00    	lea    0x1ef84(%edi),%esi
f01039d0:	8d 5f 7c             	lea    0x7c(%edi),%ebx
f01039d3:	ba ff 03 00 00       	mov    $0x3ff,%edx
f01039d8:	8d 48 7c             	lea    0x7c(%eax),%ecx
f01039db:	39 c6                	cmp    %eax,%esi
f01039dd:	89 c8                	mov    %ecx,%eax
f01039df:	0f 46 c3             	cmovbe %ebx,%eax
	// after the previously running env
	// curenv may be NULL as curenv may be destroyed by "env_destroy()"
	struct Env *e = (curenv == NULL || curenv >= envs+NENV-1) ? (envs+1) : (curenv+1);
	// skip envs[0]
	int i;	// just a counter
	for (i = 1; i < NENV; ++i)
f01039e2:	83 ea 01             	sub    $0x1,%edx
f01039e5:	75 cf                	jne    f01039b6 <sched_yield+0x36>
		}
		e = (e >= envs+NENV-1) ? (envs+1) : (e+1);
	}

	// Run the special idle environment when nothing else is runnable.
	if (envs[0].env_status == ENV_RUNNABLE)
f01039e7:	83 7f 54 01          	cmpl   $0x1,0x54(%edi)
f01039eb:	75 08                	jne    f01039f5 <sched_yield+0x75>
		env_run(&envs[0]);
f01039ed:	89 3c 24             	mov    %edi,(%esp)
f01039f0:	e8 be f5 ff ff       	call   f0102fb3 <env_run>
	else {
		cprintf("Destroyed all environments - nothing more to do!\n");
f01039f5:	c7 04 24 50 62 10 f0 	movl   $0xf0106250,(%esp)
f01039fc:	e8 c1 f7 ff ff       	call   f01031c2 <cprintf>
		while (1)
			monitor(NULL);
f0103a01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103a08:	e8 53 ce ff ff       	call   f0100860 <monitor>
f0103a0d:	eb f2                	jmp    f0103a01 <sched_yield+0x81>
	...

f0103a10 <syscall>:


// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103a10:	55                   	push   %ebp
f0103a11:	89 e5                	mov    %esp,%ebp
f0103a13:	83 ec 38             	sub    $0x38,%esp
f0103a16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103a19:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103a1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103a1f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a22:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103a25:	8b 75 10             	mov    0x10(%ebp),%esi
f0103a28:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno)
f0103a2b:	83 f8 0b             	cmp    $0xb,%eax
f0103a2e:	0f 87 1d 04 00 00    	ja     f0103e51 <syscall+0x441>
f0103a34:	ff 24 85 bc 62 10 f0 	jmp    *-0xfef9d44(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	
	// LAB 3: Your code here.
	user_mem_assert(curenv, (const void *)s, len, PTE_U | PTE_W | PTE_P);
f0103a3b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0103a42:	00 
f0103a43:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103a47:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103a4b:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f0103a50:	89 04 24             	mov    %eax,(%esp)
f0103a53:	e8 4e ee ff ff       	call   f01028a6 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103a58:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103a5c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a60:	c7 04 24 84 62 10 f0 	movl   $0xf0106284,(%esp)
f0103a67:	e8 56 f7 ff ff       	call   f01031c2 <cprintf>
	// LAB 3: Your code here.
	switch (syscallno)
	{
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
f0103a6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a71:	e9 e0 03 00 00       	jmp    f0103e56 <syscall+0x446>
{
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f0103a76:	e8 b9 c9 ff ff       	call   f0100434 <cons_getc>
f0103a7b:	85 c0                	test   %eax,%eax
f0103a7d:	74 f7                	je     f0103a76 <syscall+0x66>
f0103a7f:	90                   	nop
f0103a80:	e9 d1 03 00 00       	jmp    f0103e56 <syscall+0x446>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103a85:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f0103a8a:	8b 40 4c             	mov    0x4c(%eax),%eax
			sys_cputs((const char *)a1, a2);
			return 0;
		case SYS_cgetc:
			return (int32_t)sys_cgetc();
		case SYS_getenvid:
			return (int32_t)sys_getenvid();
f0103a8d:	e9 c4 03 00 00       	jmp    f0103e56 <syscall+0x446>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103a92:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103a99:	00 
f0103a9a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0103a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aa1:	89 3c 24             	mov    %edi,(%esp)
f0103aa4:	e8 0f ef ff ff       	call   f01029b8 <envid2env>
f0103aa9:	85 c0                	test   %eax,%eax
f0103aab:	0f 88 a5 03 00 00    	js     f0103e56 <syscall+0x446>
		return r;
	if (e == curenv)
f0103ab1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103ab4:	8b 15 c0 5a 1b f0    	mov    0xf01b5ac0,%edx
f0103aba:	39 d0                	cmp    %edx,%eax
f0103abc:	75 15                	jne    f0103ad3 <syscall+0xc3>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103abe:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ac5:	c7 04 24 89 62 10 f0 	movl   $0xf0106289,(%esp)
f0103acc:	e8 f1 f6 ff ff       	call   f01031c2 <cprintf>
f0103ad1:	eb 1a                	jmp    f0103aed <syscall+0xdd>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103ad3:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103ad6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ada:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103add:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ae1:	c7 04 24 a4 62 10 f0 	movl   $0xf01062a4,(%esp)
f0103ae8:	e8 d5 f6 ff ff       	call   f01031c2 <cprintf>
	env_destroy(e);
f0103aed:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103af0:	89 04 24             	mov    %eax,(%esp)
f0103af3:	e8 60 f4 ff ff       	call   f0102f58 <env_destroy>
	return 0;
f0103af8:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cgetc:
			return (int32_t)sys_cgetc();
		case SYS_getenvid:
			return (int32_t)sys_getenvid();
		case SYS_env_destroy:
			return (int32_t)sys_env_destroy((envid_t)a1);
f0103afd:	e9 54 03 00 00       	jmp    f0103e56 <syscall+0x446>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0103b02:	e8 79 fe ff ff       	call   f0103980 <sched_yield>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	
	// LAB 4: Your code here.
	struct Env *env;
	if (env_alloc(&env, curenv->env_id) < 0)
f0103b07:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f0103b0c:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b13:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0103b16:	89 04 24             	mov    %eax,(%esp)
f0103b19:	e8 5e ef ff ff       	call   f0102a7c <env_alloc>
f0103b1e:	85 c0                	test   %eax,%eax
f0103b20:	78 2b                	js     f0103b4d <syscall+0x13d>
	{
		return -E_NO_FREE_ENV;
	}
	env->env_status = ENV_NOT_RUNNABLE;
f0103b22:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b25:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	env->env_tf = curenv->env_tf;
f0103b2c:	8b 35 c0 5a 1b f0    	mov    0xf01b5ac0,%esi
f0103b32:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103b37:	89 c7                	mov    %eax,%edi
f0103b39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// amazing, set child's returned value to 0
	env->env_tf.tf_regs.reg_eax = 0;
f0103b3b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b3e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return env->env_id;
f0103b45:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103b48:	e9 09 03 00 00       	jmp    f0103e56 <syscall+0x446>
	
	// LAB 4: Your code here.
	struct Env *env;
	if (env_alloc(&env, curenv->env_id) < 0)
	{
		return -E_NO_FREE_ENV;
f0103b4d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
			return (int32_t)sys_env_destroy((envid_t)a1);
		case SYS_yield:
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
f0103b52:	e9 ff 02 00 00       	jmp    f0103e56 <syscall+0x446>
	
	// LAB 4: Your code here.
	// Set envid's env_status to status, which must be ENV_RUNNABLE
	// or ENV_NOT_RUNNABLE.
	// check status
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0103b57:	8d 56 ff             	lea    -0x1(%esi),%edx
	{
		return -E_INVAL;
f0103b5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	
	// LAB 4: Your code here.
	// Set envid's env_status to status, which must be ENV_RUNNABLE
	// or ENV_NOT_RUNNABLE.
	// check status
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0103b5f:	83 fa 01             	cmp    $0x1,%edx
f0103b62:	0f 87 ee 02 00 00    	ja     f0103e56 <syscall+0x446>
	{
		return -E_INVAL;
	}
	struct Env *env;
	// check envid
	if (envid2env(envid, &env, 1) < 0)
f0103b68:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103b6f:	00 
f0103b70:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0103b73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b77:	89 3c 24             	mov    %edi,(%esp)
f0103b7a:	e8 39 ee ff ff       	call   f01029b8 <envid2env>
f0103b7f:	85 c0                	test   %eax,%eax
f0103b81:	78 10                	js     f0103b93 <syscall+0x183>
	{
		return -E_BAD_ENV;
	}
	env->env_status = status;
f0103b83:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103b86:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0103b89:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b8e:	e9 c3 02 00 00       	jmp    f0103e56 <syscall+0x446>
	}
	struct Env *env;
	// check envid
	if (envid2env(envid, &env, 1) < 0)
	{
		return -E_BAD_ENV;
f0103b93:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
f0103b98:	e9 b9 02 00 00       	jmp    f0103e56 <syscall+0x446>

	// LAB 4: Your code here.
	// Allocate a page of memory and map it at 'va' with permission
	// 'perm' in the address space of 'envid'.
	// PGOFF(va) = va & 0xfff, to check whether va is page-aligned
	if ((unsigned int)va >= UTOP || PGOFF(va) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
f0103b9d:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0103ba3:	0f 87 eb 00 00 00    	ja     f0103c94 <syscall+0x284>
f0103ba9:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0103baf:	0f 85 e9 00 00 00    	jne    f0103c9e <syscall+0x28e>
f0103bb5:	89 d8                	mov    %ebx,%eax
f0103bb7:	83 e0 05             	and    $0x5,%eax
f0103bba:	83 f8 05             	cmp    $0x5,%eax
f0103bbd:	0f 85 e5 00 00 00    	jne    f0103ca8 <syscall+0x298>
	{
		return -E_INVAL;
	}
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
f0103bc3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103bca:	00 
f0103bcb:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0103bce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bd2:	89 3c 24             	mov    %edi,(%esp)
f0103bd5:	e8 de ed ff ff       	call   f01029b8 <envid2env>
f0103bda:	85 c0                	test   %eax,%eax
f0103bdc:	0f 88 d0 00 00 00    	js     f0103cb2 <syscall+0x2a2>
	{
		return -E_BAD_ENV;
	}
	struct Page *pg;
	if (page_alloc(&pg) < 0)
f0103be2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103be5:	89 04 24             	mov    %eax,(%esp)
f0103be8:	e8 71 d1 ff ff       	call   f0100d5e <page_alloc>
f0103bed:	85 c0                	test   %eax,%eax
f0103bef:	0f 88 c7 00 00 00    	js     f0103cbc <syscall+0x2ac>
	{
		return -E_NO_MEM;
	}
	// If page_insert() fails, remember to free the page you allocated!
	if (page_insert(env->env_pgdir, pg, va, perm) < 0)
f0103bf5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103bf9:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103bfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c04:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103c07:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103c0a:	89 04 24             	mov    %eax,(%esp)
f0103c0d:	e8 c1 d4 ff ff       	call   f01010d3 <page_insert>
f0103c12:	85 c0                	test   %eax,%eax
f0103c14:	79 15                	jns    f0103c2b <syscall+0x21b>
	{
		// remember to use "page_decref" rather than
		// "page_free", as page cannot be freed until pg_ref = 0.
		page_decref(pg);
f0103c16:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c19:	89 04 24             	mov    %eax,(%esp)
f0103c1c:	e8 dd d1 ff ff       	call   f0100dfe <page_decref>
		return -E_NO_MEM;
f0103c21:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103c26:	e9 2b 02 00 00       	jmp    f0103e56 <syscall+0x446>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline ppn_t
page2ppn(struct Page *pp)
{
	return pp - pages;
f0103c2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c2e:	2b 05 6c 67 1b f0    	sub    0xf01b676c,%eax
f0103c34:	c1 f8 02             	sar    $0x2,%eax
f0103c37:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
}

static inline physaddr_t
page2pa(struct Page *pp)
{
	return page2ppn(pp) << PGSHIFT;
f0103c3d:	c1 e0 0c             	shl    $0xc,%eax
}

static inline void*
page2kva(struct Page *pp)
{
	return KADDR(page2pa(pp));
f0103c40:	89 c2                	mov    %eax,%edx
f0103c42:	c1 ea 0c             	shr    $0xc,%edx
f0103c45:	3b 15 60 67 1b f0    	cmp    0xf01b6760,%edx
f0103c4b:	72 20                	jb     f0103c6d <syscall+0x25d>
f0103c4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c51:	c7 44 24 08 64 56 10 	movl   $0xf0105664,0x8(%esp)
f0103c58:	f0 
f0103c59:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0103c60:	00 
f0103c61:	c7 04 24 39 5c 10 f0 	movl   $0xf0105c39,(%esp)
f0103c68:	e8 65 c4 ff ff       	call   f01000d2 <_panic>
	}
	// The page's contents are set to 0.
	// Remember "page2kva", ha?
	memset(page2kva(pg), 0, PGSIZE);
f0103c6d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103c74:	00 
f0103c75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c7c:	00 
f0103c7d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103c82:	89 04 24             	mov    %eax,(%esp)
f0103c85:	e8 4c 0e 00 00       	call   f0104ad6 <memset>
	return 0;
f0103c8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c8f:	e9 c2 01 00 00       	jmp    f0103e56 <syscall+0x446>
	// Allocate a page of memory and map it at 'va' with permission
	// 'perm' in the address space of 'envid'.
	// PGOFF(va) = va & 0xfff, to check whether va is page-aligned
	if ((unsigned int)va >= UTOP || PGOFF(va) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P))
	{
		return -E_INVAL;
f0103c94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103c99:	e9 b8 01 00 00       	jmp    f0103e56 <syscall+0x446>
f0103c9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103ca3:	e9 ae 01 00 00       	jmp    f0103e56 <syscall+0x446>
f0103ca8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103cad:	e9 a4 01 00 00       	jmp    f0103e56 <syscall+0x446>
	}
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
	{
		return -E_BAD_ENV;
f0103cb2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103cb7:	e9 9a 01 00 00       	jmp    f0103e56 <syscall+0x446>
	}
	struct Page *pg;
	if (page_alloc(&pg) < 0)
	{
		return -E_NO_MEM;
f0103cbc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0103cc1:	e9 90 01 00 00       	jmp    f0103e56 <syscall+0x446>
	// Map the page of memory at 'srcva' in srcenvid's address space
	// at 'dstva' in dstenvid's address space with permission 'perm'.
	if ((unsigned int)srcva >= UTOP || PGOFF(srcva) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)
		|| (unsigned int)dstva >= UTOP || PGOFF(dstva) )
	{
		return -E_INVAL;
f0103cc6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// Map the page of memory at 'srcva' in srcenvid's address space
	// at 'dstva' in dstenvid's address space with permission 'perm'.
	if ((unsigned int)srcva >= UTOP || PGOFF(srcva) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)
f0103ccb:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0103cd1:	0f 87 7f 01 00 00    	ja     f0103e56 <syscall+0x446>
f0103cd7:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0103cdd:	0f 85 73 01 00 00    	jne    f0103e56 <syscall+0x446>
f0103ce3:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0103ce6:	83 e0 05             	and    $0x5,%eax
		|| (unsigned int)dstva >= UTOP || PGOFF(dstva) )
f0103ce9:	83 f8 05             	cmp    $0x5,%eax
f0103cec:	0f 85 cc 00 00 00    	jne    f0103dbe <syscall+0x3ae>
f0103cf2:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0103cf9:	0f 87 bf 00 00 00    	ja     f0103dbe <syscall+0x3ae>
	{
		return -E_INVAL;
f0103cff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// LAB 4: Your code here.
	// Map the page of memory at 'srcva' in srcenvid's address space
	// at 'dstva' in dstenvid's address space with permission 'perm'.
	if ((unsigned int)srcva >= UTOP || PGOFF(srcva) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)
		|| (unsigned int)dstva >= UTOP || PGOFF(dstva) )
f0103d04:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0103d0b:	0f 85 45 01 00 00    	jne    f0103e56 <syscall+0x446>
	{
		return -E_INVAL;
	}
	struct Env *srcenv, *dstenv;
	if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0)
f0103d11:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103d18:	00 
f0103d19:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0103d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d20:	89 3c 24             	mov    %edi,(%esp)
f0103d23:	e8 90 ec ff ff       	call   f01029b8 <envid2env>
f0103d28:	89 c2                	mov    %eax,%edx
	{
		return -E_BAD_ENV;
f0103d2a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		|| (unsigned int)dstva >= UTOP || PGOFF(dstva) )
	{
		return -E_INVAL;
	}
	struct Env *srcenv, *dstenv;
	if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0)
f0103d2f:	85 d2                	test   %edx,%edx
f0103d31:	0f 88 1f 01 00 00    	js     f0103e56 <syscall+0x446>
f0103d37:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103d3e:	00 
f0103d3f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0103d42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d46:	89 1c 24             	mov    %ebx,(%esp)
f0103d49:	e8 6a ec ff ff       	call   f01029b8 <envid2env>
f0103d4e:	89 c2                	mov    %eax,%edx
	{
		return -E_BAD_ENV;
f0103d50:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		|| (unsigned int)dstva >= UTOP || PGOFF(dstva) )
	{
		return -E_INVAL;
	}
	struct Env *srcenv, *dstenv;
	if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0)
f0103d55:	85 d2                	test   %edx,%edx
f0103d57:	0f 88 f9 00 00 00    	js     f0103e56 <syscall+0x446>
	{
		return -E_BAD_ENV;
	}
	pte_t *pte_addr;
	struct Page *pg = page_lookup(srcenv->env_pgdir, srcva, &pte_addr);
f0103d5d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103d60:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d64:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103d68:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d6b:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103d6e:	89 04 24             	mov    %eax,(%esp)
f0103d71:	e8 81 d2 ff ff       	call   f0100ff7 <page_lookup>
f0103d76:	89 c2                	mov    %eax,%edx
	// find it in src address space
	if (pg == NULL)
f0103d78:	85 c0                	test   %eax,%eax
f0103d7a:	74 4c                	je     f0103dc8 <syscall+0x3b8>
	{
		return -E_INVAL;
	}
	// check extra perm
	if ((perm & PTE_W) && !(*pte_addr & PTE_W))
f0103d7c:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0103d80:	74 11                	je     f0103d93 <syscall+0x383>
	{
		return -E_INVAL;
f0103d82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	if (pg == NULL)
	{
		return -E_INVAL;
	}
	// check extra perm
	if ((perm & PTE_W) && !(*pte_addr & PTE_W))
f0103d87:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103d8a:	f6 01 02             	testb  $0x2,(%ecx)
f0103d8d:	0f 84 c3 00 00 00    	je     f0103e56 <syscall+0x446>
	{
		return -E_INVAL;
	}
	// map to dst address space
	if (page_insert(dstenv->env_pgdir, pg, dstva, perm) < 0)
f0103d93:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0103d96:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d9a:	8b 45 18             	mov    0x18(%ebp),%eax
f0103d9d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103da1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103da5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103da8:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103dab:	89 04 24             	mov    %eax,(%esp)
f0103dae:	e8 20 d3 ff ff       	call   f01010d3 <page_insert>
	{
		return -E_NO_MEM;
f0103db3:	c1 f8 1f             	sar    $0x1f,%eax
f0103db6:	83 e0 fc             	and    $0xfffffffc,%eax
f0103db9:	e9 98 00 00 00       	jmp    f0103e56 <syscall+0x446>
	// Map the page of memory at 'srcva' in srcenvid's address space
	// at 'dstva' in dstenvid's address space with permission 'perm'.
	if ((unsigned int)srcva >= UTOP || PGOFF(srcva) || (perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)
		|| (unsigned int)dstva >= UTOP || PGOFF(dstva) )
	{
		return -E_INVAL;
f0103dbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103dc3:	e9 8e 00 00 00       	jmp    f0103e56 <syscall+0x446>
	pte_t *pte_addr;
	struct Page *pg = page_lookup(srcenv->env_pgdir, srcva, &pte_addr);
	// find it in src address space
	if (pg == NULL)
	{
		return -E_INVAL;
f0103dc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103dcd:	e9 84 00 00 00       	jmp    f0103e56 <syscall+0x446>
	
	// LAB 4: Your code here.
	// Unmap the page of memory at 'va' in the address space of 'envid'.
	if ((unsigned int)va >= UTOP || PGOFF(va))
	{
		return -E_INVAL;
f0103dd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
{
	// Hint: This function is a wrapper around page_remove().
	
	// LAB 4: Your code here.
	// Unmap the page of memory at 'va' in the address space of 'envid'.
	if ((unsigned int)va >= UTOP || PGOFF(va))
f0103dd7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0103ddd:	77 77                	ja     f0103e56 <syscall+0x446>
f0103ddf:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0103de5:	75 6f                	jne    f0103e56 <syscall+0x446>
	{
		return -E_INVAL;
	}
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
f0103de7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103dee:	00 
f0103def:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103df2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103df6:	89 3c 24             	mov    %edi,(%esp)
f0103df9:	e8 ba eb ff ff       	call   f01029b8 <envid2env>
f0103dfe:	89 c2                	mov    %eax,%edx
	{
		return -E_BAD_ENV;
f0103e00:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	if ((unsigned int)va >= UTOP || PGOFF(va))
	{
		return -E_INVAL;
	}
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
f0103e05:	85 d2                	test   %edx,%edx
f0103e07:	78 4d                	js     f0103e56 <syscall+0x446>
	{
		return -E_BAD_ENV;
	}
	page_remove(env->env_pgdir, va);
f0103e09:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e10:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103e13:	89 04 24             	mov    %eax,(%esp)
f0103e16:	e8 68 d2 ff ff       	call   f0101083 <page_remove>
	return 0;
f0103e1b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e20:	eb 34                	jmp    f0103e56 <syscall+0x446>
	// kernel will push a fault record onto the exception stack, then branch to
	// 'func'.
	struct Env *env;
	// set envid2env's third argument to 1, which will check whether
	// the current environment has permission to set envid's status.
	if (envid2env(envid, &env, 1) < 0)
f0103e22:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103e29:	00 
f0103e2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e31:	89 3c 24             	mov    %edi,(%esp)
f0103e34:	e8 7f eb ff ff       	call   f01029b8 <envid2env>
f0103e39:	85 c0                	test   %eax,%eax
f0103e3b:	78 0d                	js     f0103e4a <syscall+0x43a>
	{
		return -E_BAD_ENV;
	}
	env->env_pgfault_upcall = func;
f0103e3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103e40:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0103e43:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e48:	eb 0c                	jmp    f0103e56 <syscall+0x446>
	struct Env *env;
	// set envid2env's third argument to 1, which will check whether
	// the current environment has permission to set envid's status.
	if (envid2env(envid, &env, 1) < 0)
	{
		return -E_BAD_ENV;
f0103e4a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t) a3, (void *)a4, (int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1, (void *)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0103e4f:	eb 05                	jmp    f0103e56 <syscall+0x446>
		default:	//NSYSCALLS means non-syscalls
			return -E_INVAL;
f0103e51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}

	//panic("syscall not implemented");
}
f0103e56:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103e59:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103e5c:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103e5f:	89 ec                	mov    %ebp,%esp
f0103e61:	5d                   	pop    %ebp
f0103e62:	c3                   	ret    
	...

f0103e64 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103e64:	55                   	push   %ebp
f0103e65:	89 e5                	mov    %esp,%ebp
f0103e67:	57                   	push   %edi
f0103e68:	56                   	push   %esi
f0103e69:	53                   	push   %ebx
f0103e6a:	83 ec 14             	sub    $0x14,%esp
f0103e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103e70:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103e73:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103e76:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103e79:	8b 1a                	mov    (%edx),%ebx
f0103e7b:	8b 01                	mov    (%ecx),%eax
f0103e7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0103e80:	39 c3                	cmp    %eax,%ebx
f0103e82:	0f 8f 9c 00 00 00    	jg     f0103f24 <stab_binsearch+0xc0>
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
f0103e88:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103e8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103e92:	01 d8                	add    %ebx,%eax
f0103e94:	89 c7                	mov    %eax,%edi
f0103e96:	c1 ef 1f             	shr    $0x1f,%edi
f0103e99:	01 c7                	add    %eax,%edi
f0103e9b:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103e9d:	39 df                	cmp    %ebx,%edi
f0103e9f:	7c 33                	jl     f0103ed4 <stab_binsearch+0x70>
f0103ea1:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103ea4:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103ea7:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103eac:	39 f0                	cmp    %esi,%eax
f0103eae:	0f 84 bc 00 00 00    	je     f0103f70 <stab_binsearch+0x10c>
f0103eb4:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103eb8:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103ebc:	89 f8                	mov    %edi,%eax
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103ebe:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ec1:	39 d8                	cmp    %ebx,%eax
f0103ec3:	7c 0f                	jl     f0103ed4 <stab_binsearch+0x70>
f0103ec5:	0f b6 0a             	movzbl (%edx),%ecx
f0103ec8:	83 ea 0c             	sub    $0xc,%edx
f0103ecb:	39 f1                	cmp    %esi,%ecx
f0103ecd:	75 ef                	jne    f0103ebe <stab_binsearch+0x5a>
f0103ecf:	e9 9e 00 00 00       	jmp    f0103f72 <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103ed4:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103ed7:	eb 3c                	jmp    f0103f15 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103ed9:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103edc:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0103ede:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103ee1:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103ee8:	eb 2b                	jmp    f0103f15 <stab_binsearch+0xb1>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103eea:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103eed:	76 14                	jbe    f0103f03 <stab_binsearch+0x9f>
			*region_right = m - 1;
f0103eef:	83 e8 01             	sub    $0x1,%eax
f0103ef2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ef5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103ef8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103efa:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103f01:	eb 12                	jmp    f0103f15 <stab_binsearch+0xb1>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103f03:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f06:	89 02                	mov    %eax,(%edx)
			l = m;
			addr++;
f0103f08:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103f0c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103f0e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103f15:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0103f18:	0f 8d 71 ff ff ff    	jge    f0103e8f <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103f1e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f22:	75 0f                	jne    f0103f33 <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0103f24:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f27:	8b 02                	mov    (%edx),%eax
f0103f29:	83 e8 01             	sub    $0x1,%eax
f0103f2c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f2f:	89 01                	mov    %eax,(%ecx)
f0103f31:	eb 57                	jmp    f0103f8a <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f33:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f36:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103f38:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f3b:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f3d:	39 c1                	cmp    %eax,%ecx
f0103f3f:	7d 28                	jge    f0103f69 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103f41:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f44:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0103f47:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0103f4c:	39 f2                	cmp    %esi,%edx
f0103f4e:	74 19                	je     f0103f69 <stab_binsearch+0x105>
f0103f50:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103f54:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103f58:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103f5b:	39 c1                	cmp    %eax,%ecx
f0103f5d:	7d 0a                	jge    f0103f69 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0103f5f:	0f b6 1a             	movzbl (%edx),%ebx
f0103f62:	83 ea 0c             	sub    $0xc,%edx
f0103f65:	39 f3                	cmp    %esi,%ebx
f0103f67:	75 ef                	jne    f0103f58 <stab_binsearch+0xf4>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103f69:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0103f6c:	89 02                	mov    %eax,(%edx)
f0103f6e:	eb 1a                	jmp    f0103f8a <stab_binsearch+0x126>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103f70:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103f72:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103f75:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103f78:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103f7c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103f7f:	0f 82 54 ff ff ff    	jb     f0103ed9 <stab_binsearch+0x75>
f0103f85:	e9 60 ff ff ff       	jmp    f0103eea <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103f8a:	83 c4 14             	add    $0x14,%esp
f0103f8d:	5b                   	pop    %ebx
f0103f8e:	5e                   	pop    %esi
f0103f8f:	5f                   	pop    %edi
f0103f90:	5d                   	pop    %ebp
f0103f91:	c3                   	ret    

f0103f92 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103f92:	55                   	push   %ebp
f0103f93:	89 e5                	mov    %esp,%ebp
f0103f95:	57                   	push   %edi
f0103f96:	56                   	push   %esi
f0103f97:	53                   	push   %ebx
f0103f98:	83 ec 5c             	sub    $0x5c,%esp
f0103f9b:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103fa1:	c7 03 ec 62 10 f0    	movl   $0xf01062ec,(%ebx)
	info->eip_line = 0;
f0103fa7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103fae:	c7 43 08 ec 62 10 f0 	movl   $0xf01062ec,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103fb5:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103fbc:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103fbf:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103fc6:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103fcc:	0f 87 c0 00 00 00    	ja     f0104092 <debuginfo_eip+0x100>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (const void *)usd, sizeof(struct UserStabData), PTE_U | PTE_P) < 0)
f0103fd2:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0103fd9:	00 
f0103fda:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0103fe1:	00 
f0103fe2:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0103fe9:	00 
f0103fea:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f0103fef:	89 04 24             	mov    %eax,(%esp)
f0103ff2:	e8 10 e8 ff ff       	call   f0102807 <user_mem_check>
f0103ff7:	89 c2                	mov    %eax,%edx
		{
			return -1;
f0103ff9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (const void *)usd, sizeof(struct UserStabData), PTE_U | PTE_P) < 0)
f0103ffe:	85 d2                	test   %edx,%edx
f0104000:	0f 88 7c 02 00 00    	js     f0104282 <debuginfo_eip+0x2f0>
		{
			return -1;
		}

		stabs = usd->stabs;
f0104006:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f010400c:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010400f:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0104015:	a1 08 00 20 00       	mov    0x200008,%eax
f010401a:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010401d:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104023:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end-stabs, PTE_U | PTE_P) < 0
f0104026:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f010402d:	00 
f010402e:	89 f8                	mov    %edi,%eax
f0104030:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f0104033:	c1 f8 02             	sar    $0x2,%eax
f0104036:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010403c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104040:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0104043:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104047:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f010404c:	89 04 24             	mov    %eax,(%esp)
f010404f:	e8 b3 e7 ff ff       	call   f0102807 <user_mem_check>
f0104054:	89 c2                	mov    %eax,%edx
		|| user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U | PTE_P) < 0)
		{
			return -1;
f0104056:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end-stabs, PTE_U | PTE_P) < 0
f010405b:	85 d2                	test   %edx,%edx
f010405d:	0f 88 1f 02 00 00    	js     f0104282 <debuginfo_eip+0x2f0>
		|| user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U | PTE_P) < 0)
f0104063:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f010406a:	00 
f010406b:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010406e:	2b 45 bc             	sub    -0x44(%ebp),%eax
f0104071:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104075:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104078:	89 44 24 04          	mov    %eax,0x4(%esp)
f010407c:	a1 c0 5a 1b f0       	mov    0xf01b5ac0,%eax
f0104081:	89 04 24             	mov    %eax,(%esp)
f0104084:	e8 7e e7 ff ff       	call   f0102807 <user_mem_check>
f0104089:	85 c0                	test   %eax,%eax
f010408b:	79 1f                	jns    f01040ac <debuginfo_eip+0x11a>
f010408d:	e9 eb 01 00 00       	jmp    f010427d <debuginfo_eip+0x2eb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104092:	c7 45 c0 14 16 11 f0 	movl   $0xf0111614,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104099:	c7 45 bc 0d e9 10 f0 	movl   $0xf010e90d,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01040a0:	bf 0c e9 10 f0       	mov    $0xf010e90c,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01040a5:	c7 45 c4 54 65 10 f0 	movl   $0xf0106554,-0x3c(%ebp)
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01040ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01040b1:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01040b4:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f01040b7:	0f 83 c5 01 00 00    	jae    f0104282 <debuginfo_eip+0x2f0>
f01040bd:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f01040c1:	0f 85 bb 01 00 00    	jne    f0104282 <debuginfo_eip+0x2f0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01040c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01040ce:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01040d1:	c1 ff 02             	sar    $0x2,%edi
f01040d4:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f01040da:	83 e8 01             	sub    $0x1,%eax
f01040dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01040e0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040e4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01040eb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01040ee:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01040f1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01040f4:	e8 6b fd ff ff       	call   f0103e64 <stab_binsearch>
	if (lfile == 0)
f01040f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f01040fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0104101:	85 d2                	test   %edx,%edx
f0104103:	0f 84 79 01 00 00    	je     f0104282 <debuginfo_eip+0x2f0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104109:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f010410c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010410f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104112:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104116:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010411d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104120:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104123:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104126:	e8 39 fd ff ff       	call   f0103e64 <stab_binsearch>

	if (lfun <= rfun) {
f010412b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010412e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104131:	39 d0                	cmp    %edx,%eax
f0104133:	7f 32                	jg     f0104167 <debuginfo_eip+0x1d5>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104135:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104138:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010413b:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f010413e:	8b 39                	mov    (%ecx),%edi
f0104140:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0104143:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104146:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0104149:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f010414c:	73 09                	jae    f0104157 <debuginfo_eip+0x1c5>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010414e:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104151:	03 7d bc             	add    -0x44(%ebp),%edi
f0104154:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104157:	8b 49 08             	mov    0x8(%ecx),%ecx
f010415a:	89 4b 10             	mov    %ecx,0x10(%ebx)
		// This "n_value" is the function's first addr, but when it comes to SLINE,
		// "n_value" describes the offset, so we need to minus "n_value" fro addr
		// to get the offset of the line.
		addr -= info->eip_fn_addr;
f010415d:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010415f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104162:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104165:	eb 0f                	jmp    f0104176 <debuginfo_eip+0x1e4>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104167:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010416a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010416d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104170:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104173:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104176:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010417d:	00 
f010417e:	8b 43 08             	mov    0x8(%ebx),%eax
f0104181:	89 04 24             	mov    %eax,(%esp)
f0104184:	e8 26 09 00 00       	call   f0104aaf <strfind>
f0104189:	2b 43 08             	sub    0x8(%ebx),%eax
f010418c:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010418f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104193:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010419a:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010419d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01041a0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01041a3:	e8 bc fc ff ff       	call   f0103e64 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f01041a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01041ab:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01041ae:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01041b1:	0f b7 54 96 06       	movzwl 0x6(%esi,%edx,4),%edx
f01041b6:	89 53 04             	mov    %edx,0x4(%ebx)
	if (rline < lline)
f01041b9:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01041bc:	7e 07                	jle    f01041c5 <debuginfo_eip+0x233>
	{
		info->eip_line = -1;
f01041be:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01041c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01041c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01041cb:	89 7d b8             	mov    %edi,-0x48(%ebp)
f01041ce:	39 f8                	cmp    %edi,%eax
f01041d0:	7c 78                	jl     f010424a <debuginfo_eip+0x2b8>
	       && stabs[lline].n_type != N_SOL
f01041d2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01041d5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01041d8:	8d 34 97             	lea    (%edi,%edx,4),%esi
f01041db:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
f01041df:	80 f9 84             	cmp    $0x84,%cl
f01041e2:	74 4e                	je     f0104232 <debuginfo_eip+0x2a0>
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01041e4:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01041e8:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01041eb:	89 c7                	mov    %eax,%edi
f01041ed:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
f01041f0:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01041f3:	eb 27                	jmp    f010421c <debuginfo_eip+0x28a>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01041f5:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01041f8:	39 c3                	cmp    %eax,%ebx
f01041fa:	7e 08                	jle    f0104204 <debuginfo_eip+0x272>
f01041fc:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01041ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104202:	eb 46                	jmp    f010424a <debuginfo_eip+0x2b8>
	       && stabs[lline].n_type != N_SOL
f0104204:	89 d6                	mov    %edx,%esi
f0104206:	83 ea 0c             	sub    $0xc,%edx
f0104209:	0f b6 4a 10          	movzbl 0x10(%edx),%ecx
f010420d:	80 f9 84             	cmp    $0x84,%cl
f0104210:	75 08                	jne    f010421a <debuginfo_eip+0x288>
f0104212:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f0104215:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104218:	eb 18                	jmp    f0104232 <debuginfo_eip+0x2a0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010421a:	89 c7                	mov    %eax,%edi
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010421c:	80 f9 64             	cmp    $0x64,%cl
f010421f:	75 d4                	jne    f01041f5 <debuginfo_eip+0x263>
f0104221:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0104225:	74 ce                	je     f01041f5 <debuginfo_eip+0x263>
f0104227:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f010422a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010422d:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104230:	7f 18                	jg     f010424a <debuginfo_eip+0x2b8>
f0104232:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104235:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104238:	8b 04 86             	mov    (%esi,%eax,4),%eax
f010423b:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010423e:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0104241:	39 d0                	cmp    %edx,%eax
f0104243:	73 05                	jae    f010424a <debuginfo_eip+0x2b8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104245:	03 45 bc             	add    -0x44(%ebp),%eax
f0104248:	89 03                	mov    %eax,(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f010424a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010424d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0104250:	b8 00 00 00 00       	mov    $0x0,%eax

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f0104255:	39 d1                	cmp    %edx,%ecx
f0104257:	7c 29                	jl     f0104282 <debuginfo_eip+0x2f0>
	{
		if (stabs[i].n_type == N_PSYM)
f0104259:	8d 04 52             	lea    (%edx,%edx,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010425c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010425f:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
	{
		if (stabs[i].n_type == N_PSYM)
f0104263:	80 38 a0             	cmpb   $0xa0,(%eax)
f0104266:	75 04                	jne    f010426c <debuginfo_eip+0x2da>
		{
			++(info->eip_fn_narg);
f0104268:	83 43 14 01          	addl   $0x1,0x14(%ebx)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.
	int i;	// loop
	for (i = lfun; i <= rfun; ++i)
f010426c:	83 c2 01             	add    $0x1,%edx
f010426f:	83 c0 0c             	add    $0xc,%eax
f0104272:	39 d1                	cmp    %edx,%ecx
f0104274:	7d ed                	jge    f0104263 <debuginfo_eip+0x2d1>
			++(info->eip_fn_narg);
		}
	}

	
	return 0;
f0104276:	b8 00 00 00 00       	mov    $0x0,%eax
f010427b:	eb 05                	jmp    f0104282 <debuginfo_eip+0x2f0>
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, stab_end-stabs, PTE_U | PTE_P) < 0
		|| user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U | PTE_P) < 0)
		{
			return -1;
f010427d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		}
	}

	
	return 0;
}
f0104282:	83 c4 5c             	add    $0x5c,%esp
f0104285:	5b                   	pop    %ebx
f0104286:	5e                   	pop    %esi
f0104287:	5f                   	pop    %edi
f0104288:	5d                   	pop    %ebp
f0104289:	c3                   	ret    
f010428a:	00 00                	add    %al,(%eax)
f010428c:	00 00                	add    %al,(%eax)
	...

f0104290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104290:	55                   	push   %ebp
f0104291:	89 e5                	mov    %esp,%ebp
f0104293:	57                   	push   %edi
f0104294:	56                   	push   %esi
f0104295:	53                   	push   %ebx
f0104296:	83 ec 3c             	sub    $0x3c,%esp
f0104299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010429c:	89 d7                	mov    %edx,%edi
f010429e:	8b 45 08             	mov    0x8(%ebp),%eax
f01042a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01042a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01042aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01042ad:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01042b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01042b5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01042b8:	72 11                	jb     f01042cb <printnum+0x3b>
f01042ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01042bd:	39 45 10             	cmp    %eax,0x10(%ebp)
f01042c0:	76 09                	jbe    f01042cb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01042c2:	83 eb 01             	sub    $0x1,%ebx
f01042c5:	85 db                	test   %ebx,%ebx
f01042c7:	7f 51                	jg     f010431a <printnum+0x8a>
f01042c9:	eb 5e                	jmp    f0104329 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01042cb:	89 74 24 10          	mov    %esi,0x10(%esp)
f01042cf:	83 eb 01             	sub    $0x1,%ebx
f01042d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01042d6:	8b 45 10             	mov    0x10(%ebp),%eax
f01042d9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01042dd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01042e1:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01042e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01042ec:	00 
f01042ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01042f0:	89 04 24             	mov    %eax,(%esp)
f01042f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042fa:	e8 d1 09 00 00       	call   f0104cd0 <__udivdi3>
f01042ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104303:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104307:	89 04 24             	mov    %eax,(%esp)
f010430a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010430e:	89 fa                	mov    %edi,%edx
f0104310:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104313:	e8 78 ff ff ff       	call   f0104290 <printnum>
f0104318:	eb 0f                	jmp    f0104329 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010431a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010431e:	89 34 24             	mov    %esi,(%esp)
f0104321:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104324:	83 eb 01             	sub    $0x1,%ebx
f0104327:	75 f1                	jne    f010431a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104329:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010432d:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104331:	8b 45 10             	mov    0x10(%ebp),%eax
f0104334:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104338:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010433f:	00 
f0104340:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104343:	89 04 24             	mov    %eax,(%esp)
f0104346:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104349:	89 44 24 04          	mov    %eax,0x4(%esp)
f010434d:	e8 ae 0a 00 00       	call   f0104e00 <__umoddi3>
f0104352:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104356:	0f be 80 f6 62 10 f0 	movsbl -0xfef9d0a(%eax),%eax
f010435d:	89 04 24             	mov    %eax,(%esp)
f0104360:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0104363:	83 c4 3c             	add    $0x3c,%esp
f0104366:	5b                   	pop    %ebx
f0104367:	5e                   	pop    %esi
f0104368:	5f                   	pop    %edi
f0104369:	5d                   	pop    %ebp
f010436a:	c3                   	ret    

f010436b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010436b:	55                   	push   %ebp
f010436c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010436e:	83 fa 01             	cmp    $0x1,%edx
f0104371:	7e 0e                	jle    f0104381 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104373:	8b 10                	mov    (%eax),%edx
f0104375:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104378:	89 08                	mov    %ecx,(%eax)
f010437a:	8b 02                	mov    (%edx),%eax
f010437c:	8b 52 04             	mov    0x4(%edx),%edx
f010437f:	eb 22                	jmp    f01043a3 <getuint+0x38>
	else if (lflag)
f0104381:	85 d2                	test   %edx,%edx
f0104383:	74 10                	je     f0104395 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104385:	8b 10                	mov    (%eax),%edx
f0104387:	8d 4a 04             	lea    0x4(%edx),%ecx
f010438a:	89 08                	mov    %ecx,(%eax)
f010438c:	8b 02                	mov    (%edx),%eax
f010438e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104393:	eb 0e                	jmp    f01043a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104395:	8b 10                	mov    (%eax),%edx
f0104397:	8d 4a 04             	lea    0x4(%edx),%ecx
f010439a:	89 08                	mov    %ecx,(%eax)
f010439c:	8b 02                	mov    (%edx),%eax
f010439e:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01043a3:	5d                   	pop    %ebp
f01043a4:	c3                   	ret    

f01043a5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f01043a5:	55                   	push   %ebp
f01043a6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01043a8:	83 fa 01             	cmp    $0x1,%edx
f01043ab:	7e 0e                	jle    f01043bb <getint+0x16>
		return va_arg(*ap, long long);
f01043ad:	8b 10                	mov    (%eax),%edx
f01043af:	8d 4a 08             	lea    0x8(%edx),%ecx
f01043b2:	89 08                	mov    %ecx,(%eax)
f01043b4:	8b 02                	mov    (%edx),%eax
f01043b6:	8b 52 04             	mov    0x4(%edx),%edx
f01043b9:	eb 22                	jmp    f01043dd <getint+0x38>
	else if (lflag)
f01043bb:	85 d2                	test   %edx,%edx
f01043bd:	74 10                	je     f01043cf <getint+0x2a>
		return va_arg(*ap, long);
f01043bf:	8b 10                	mov    (%eax),%edx
f01043c1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01043c4:	89 08                	mov    %ecx,(%eax)
f01043c6:	8b 02                	mov    (%edx),%eax
f01043c8:	89 c2                	mov    %eax,%edx
f01043ca:	c1 fa 1f             	sar    $0x1f,%edx
f01043cd:	eb 0e                	jmp    f01043dd <getint+0x38>
	else
		return va_arg(*ap, int);
f01043cf:	8b 10                	mov    (%eax),%edx
f01043d1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01043d4:	89 08                	mov    %ecx,(%eax)
f01043d6:	8b 02                	mov    (%edx),%eax
f01043d8:	89 c2                	mov    %eax,%edx
f01043da:	c1 fa 1f             	sar    $0x1f,%edx
}
f01043dd:	5d                   	pop    %ebp
f01043de:	c3                   	ret    

f01043df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01043df:	55                   	push   %ebp
f01043e0:	89 e5                	mov    %esp,%ebp
f01043e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01043e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01043e9:	8b 10                	mov    (%eax),%edx
f01043eb:	3b 50 04             	cmp    0x4(%eax),%edx
f01043ee:	73 0a                	jae    f01043fa <sprintputch+0x1b>
		*b->buf++ = ch;
f01043f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043f3:	88 0a                	mov    %cl,(%edx)
f01043f5:	83 c2 01             	add    $0x1,%edx
f01043f8:	89 10                	mov    %edx,(%eax)
}
f01043fa:	5d                   	pop    %ebp
f01043fb:	c3                   	ret    

f01043fc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01043fc:	55                   	push   %ebp
f01043fd:	89 e5                	mov    %esp,%ebp
f01043ff:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0104402:	8d 45 14             	lea    0x14(%ebp),%eax
f0104405:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104409:	8b 45 10             	mov    0x10(%ebp),%eax
f010440c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104410:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104413:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104417:	8b 45 08             	mov    0x8(%ebp),%eax
f010441a:	89 04 24             	mov    %eax,(%esp)
f010441d:	e8 02 00 00 00       	call   f0104424 <vprintfmt>
	va_end(ap);
}
f0104422:	c9                   	leave  
f0104423:	c3                   	ret    

f0104424 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104424:	55                   	push   %ebp
f0104425:	89 e5                	mov    %esp,%ebp
f0104427:	57                   	push   %edi
f0104428:	56                   	push   %esi
f0104429:	53                   	push   %ebx
f010442a:	83 ec 4c             	sub    $0x4c,%esp
f010442d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104430:	8b 75 10             	mov    0x10(%ebp),%esi
f0104433:	eb 12                	jmp    f0104447 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104435:	85 c0                	test   %eax,%eax
f0104437:	0f 84 98 03 00 00    	je     f01047d5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
f010443d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104441:	89 04 24             	mov    %eax,(%esp)
f0104444:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104447:	0f b6 06             	movzbl (%esi),%eax
f010444a:	83 c6 01             	add    $0x1,%esi
f010444d:	83 f8 25             	cmp    $0x25,%eax
f0104450:	75 e3                	jne    f0104435 <vprintfmt+0x11>
f0104452:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0104456:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f010445d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0104462:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0104469:	b9 00 00 00 00       	mov    $0x0,%ecx
f010446e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104471:	eb 2b                	jmp    f010449e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104473:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104476:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f010447a:	eb 22                	jmp    f010449e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010447c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010447f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0104483:	eb 19                	jmp    f010449e <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104485:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0104488:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010448f:	eb 0d                	jmp    f010449e <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104491:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104497:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010449e:	0f b6 06             	movzbl (%esi),%eax
f01044a1:	0f b6 d0             	movzbl %al,%edx
f01044a4:	8d 7e 01             	lea    0x1(%esi),%edi
f01044a7:	89 7d e0             	mov    %edi,-0x20(%ebp)
f01044aa:	83 e8 23             	sub    $0x23,%eax
f01044ad:	3c 55                	cmp    $0x55,%al
f01044af:	0f 87 fa 02 00 00    	ja     f01047af <vprintfmt+0x38b>
f01044b5:	0f b6 c0             	movzbl %al,%eax
f01044b8:	ff 24 85 c0 63 10 f0 	jmp    *-0xfef9c40(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01044bf:	83 ea 30             	sub    $0x30,%edx
f01044c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f01044c5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f01044c9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f01044cf:	83 fa 09             	cmp    $0x9,%edx
f01044d2:	77 4a                	ja     f010451e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01044d7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f01044da:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f01044dd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f01044e1:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01044e4:	8d 50 d0             	lea    -0x30(%eax),%edx
f01044e7:	83 fa 09             	cmp    $0x9,%edx
f01044ea:	76 eb                	jbe    f01044d7 <vprintfmt+0xb3>
f01044ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01044ef:	eb 2d                	jmp    f010451e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01044f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01044f4:	8d 50 04             	lea    0x4(%eax),%edx
f01044f7:	89 55 14             	mov    %edx,0x14(%ebp)
f01044fa:	8b 00                	mov    (%eax),%eax
f01044fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104502:	eb 1a                	jmp    f010451e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
f0104507:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010450b:	79 91                	jns    f010449e <vprintfmt+0x7a>
f010450d:	e9 73 ff ff ff       	jmp    f0104485 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104512:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104515:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f010451c:	eb 80                	jmp    f010449e <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
f010451e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104522:	0f 89 76 ff ff ff    	jns    f010449e <vprintfmt+0x7a>
f0104528:	e9 64 ff ff ff       	jmp    f0104491 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010452d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104530:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104533:	e9 66 ff ff ff       	jmp    f010449e <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104538:	8b 45 14             	mov    0x14(%ebp),%eax
f010453b:	8d 50 04             	lea    0x4(%eax),%edx
f010453e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104545:	8b 00                	mov    (%eax),%eax
f0104547:	89 04 24             	mov    %eax,(%esp)
f010454a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010454d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104550:	e9 f2 fe ff ff       	jmp    f0104447 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104555:	8b 45 14             	mov    0x14(%ebp),%eax
f0104558:	8d 50 04             	lea    0x4(%eax),%edx
f010455b:	89 55 14             	mov    %edx,0x14(%ebp)
f010455e:	8b 00                	mov    (%eax),%eax
f0104560:	89 c2                	mov    %eax,%edx
f0104562:	c1 fa 1f             	sar    $0x1f,%edx
f0104565:	31 d0                	xor    %edx,%eax
f0104567:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0104569:	83 f8 08             	cmp    $0x8,%eax
f010456c:	7f 0b                	jg     f0104579 <vprintfmt+0x155>
f010456e:	8b 14 85 20 65 10 f0 	mov    -0xfef9ae0(,%eax,4),%edx
f0104575:	85 d2                	test   %edx,%edx
f0104577:	75 23                	jne    f010459c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
f0104579:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010457d:	c7 44 24 08 0e 63 10 	movl   $0xf010630e,0x8(%esp)
f0104584:	f0 
f0104585:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104589:	8b 7d 08             	mov    0x8(%ebp),%edi
f010458c:	89 3c 24             	mov    %edi,(%esp)
f010458f:	e8 68 fe ff ff       	call   f01043fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104594:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104597:	e9 ab fe ff ff       	jmp    f0104447 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f010459c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01045a0:	c7 44 24 08 6f 5c 10 	movl   $0xf0105c6f,0x8(%esp)
f01045a7:	f0 
f01045a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045ac:	8b 7d 08             	mov    0x8(%ebp),%edi
f01045af:	89 3c 24             	mov    %edi,(%esp)
f01045b2:	e8 45 fe ff ff       	call   f01043fc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01045ba:	e9 88 fe ff ff       	jmp    f0104447 <vprintfmt+0x23>
f01045bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01045c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01045c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01045cb:	8d 50 04             	lea    0x4(%eax),%edx
f01045ce:	89 55 14             	mov    %edx,0x14(%ebp)
f01045d1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01045d3:	85 f6                	test   %esi,%esi
f01045d5:	ba 07 63 10 f0       	mov    $0xf0106307,%edx
f01045da:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
f01045dd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01045e1:	7e 06                	jle    f01045e9 <vprintfmt+0x1c5>
f01045e3:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01045e7:	75 10                	jne    f01045f9 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01045e9:	0f be 06             	movsbl (%esi),%eax
f01045ec:	83 c6 01             	add    $0x1,%esi
f01045ef:	85 c0                	test   %eax,%eax
f01045f1:	0f 85 86 00 00 00    	jne    f010467d <vprintfmt+0x259>
f01045f7:	eb 76                	jmp    f010466f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01045f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01045fd:	89 34 24             	mov    %esi,(%esp)
f0104600:	e8 36 03 00 00       	call   f010493b <strnlen>
f0104605:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104608:	29 c2                	sub    %eax,%edx
f010460a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010460d:	85 d2                	test   %edx,%edx
f010460f:	7e d8                	jle    f01045e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0104611:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0104615:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104618:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010461b:	89 d6                	mov    %edx,%esi
f010461d:	89 c7                	mov    %eax,%edi
f010461f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104623:	89 3c 24             	mov    %edi,(%esp)
f0104626:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104629:	83 ee 01             	sub    $0x1,%esi
f010462c:	75 f1                	jne    f010461f <vprintfmt+0x1fb>
f010462e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0104631:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0104634:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104637:	eb b0                	jmp    f01045e9 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104639:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010463d:	74 18                	je     f0104657 <vprintfmt+0x233>
f010463f:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104642:	83 fa 5e             	cmp    $0x5e,%edx
f0104645:	76 10                	jbe    f0104657 <vprintfmt+0x233>
					putch('?', putdat);
f0104647:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010464b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104652:	ff 55 08             	call   *0x8(%ebp)
f0104655:	eb 0a                	jmp    f0104661 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
f0104657:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010465b:	89 04 24             	mov    %eax,(%esp)
f010465e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104661:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0104665:	0f be 06             	movsbl (%esi),%eax
f0104668:	83 c6 01             	add    $0x1,%esi
f010466b:	85 c0                	test   %eax,%eax
f010466d:	75 0e                	jne    f010467d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010466f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104672:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104676:	7f 11                	jg     f0104689 <vprintfmt+0x265>
f0104678:	e9 ca fd ff ff       	jmp    f0104447 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010467d:	85 ff                	test   %edi,%edi
f010467f:	90                   	nop
f0104680:	78 b7                	js     f0104639 <vprintfmt+0x215>
f0104682:	83 ef 01             	sub    $0x1,%edi
f0104685:	79 b2                	jns    f0104639 <vprintfmt+0x215>
f0104687:	eb e6                	jmp    f010466f <vprintfmt+0x24b>
f0104689:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010468c:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010468f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104693:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010469a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010469c:	83 ee 01             	sub    $0x1,%esi
f010469f:	75 ee                	jne    f010468f <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01046a4:	e9 9e fd ff ff       	jmp    f0104447 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01046a9:	89 ca                	mov    %ecx,%edx
f01046ab:	8d 45 14             	lea    0x14(%ebp),%eax
f01046ae:	e8 f2 fc ff ff       	call   f01043a5 <getint>
f01046b3:	89 c6                	mov    %eax,%esi
f01046b5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01046b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01046bc:	85 d2                	test   %edx,%edx
f01046be:	0f 89 ad 00 00 00    	jns    f0104771 <vprintfmt+0x34d>
				putch('-', putdat);
f01046c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01046c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01046cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01046d2:	f7 de                	neg    %esi
f01046d4:	83 d7 00             	adc    $0x0,%edi
f01046d7:	f7 df                	neg    %edi
			}
			base = 10;
f01046d9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01046de:	e9 8e 00 00 00       	jmp    f0104771 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01046e3:	89 ca                	mov    %ecx,%edx
f01046e5:	8d 45 14             	lea    0x14(%ebp),%eax
f01046e8:	e8 7e fc ff ff       	call   f010436b <getuint>
f01046ed:	89 c6                	mov    %eax,%esi
f01046ef:	89 d7                	mov    %edx,%edi
			base = 10;
f01046f1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01046f6:	eb 79                	jmp    f0104771 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
f01046f8:	89 ca                	mov    %ecx,%edx
f01046fa:	8d 45 14             	lea    0x14(%ebp),%eax
f01046fd:	e8 a3 fc ff ff       	call   f01043a5 <getint>
f0104702:	89 c6                	mov    %eax,%esi
f0104704:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
f0104706:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010470b:	85 d2                	test   %edx,%edx
f010470d:	79 62                	jns    f0104771 <vprintfmt+0x34d>
				putch('-', putdat);
f010470f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104713:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010471a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010471d:	f7 de                	neg    %esi
f010471f:	83 d7 00             	adc    $0x0,%edi
f0104722:	f7 df                	neg    %edi
			}
			base = 8;
f0104724:	b8 08 00 00 00       	mov    $0x8,%eax
f0104729:	eb 46                	jmp    f0104771 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
f010472b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010472f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104736:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104739:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010473d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104744:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104747:	8b 45 14             	mov    0x14(%ebp),%eax
f010474a:	8d 50 04             	lea    0x4(%eax),%edx
f010474d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104750:	8b 30                	mov    (%eax),%esi
f0104752:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104757:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010475c:	eb 13                	jmp    f0104771 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010475e:	89 ca                	mov    %ecx,%edx
f0104760:	8d 45 14             	lea    0x14(%ebp),%eax
f0104763:	e8 03 fc ff ff       	call   f010436b <getuint>
f0104768:	89 c6                	mov    %eax,%esi
f010476a:	89 d7                	mov    %edx,%edi
			base = 16;
f010476c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104771:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0104775:	89 54 24 10          	mov    %edx,0x10(%esp)
f0104779:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010477c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104780:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104784:	89 34 24             	mov    %esi,(%esp)
f0104787:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010478b:	89 da                	mov    %ebx,%edx
f010478d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104790:	e8 fb fa ff ff       	call   f0104290 <printnum>
			break;
f0104795:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104798:	e9 aa fc ff ff       	jmp    f0104447 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010479d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047a1:	89 14 24             	mov    %edx,(%esp)
f01047a4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01047aa:	e9 98 fc ff ff       	jmp    f0104447 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01047af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047b3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01047ba:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01047bd:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01047c1:	0f 84 80 fc ff ff    	je     f0104447 <vprintfmt+0x23>
f01047c7:	83 ee 01             	sub    $0x1,%esi
f01047ca:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01047ce:	75 f7                	jne    f01047c7 <vprintfmt+0x3a3>
f01047d0:	e9 72 fc ff ff       	jmp    f0104447 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01047d5:	83 c4 4c             	add    $0x4c,%esp
f01047d8:	5b                   	pop    %ebx
f01047d9:	5e                   	pop    %esi
f01047da:	5f                   	pop    %edi
f01047db:	5d                   	pop    %ebp
f01047dc:	c3                   	ret    

f01047dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01047dd:	55                   	push   %ebp
f01047de:	89 e5                	mov    %esp,%ebp
f01047e0:	83 ec 28             	sub    $0x28,%esp
f01047e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01047e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01047e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01047ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01047f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01047f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01047fa:	85 c0                	test   %eax,%eax
f01047fc:	74 30                	je     f010482e <vsnprintf+0x51>
f01047fe:	85 d2                	test   %edx,%edx
f0104800:	7e 2c                	jle    f010482e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104802:	8b 45 14             	mov    0x14(%ebp),%eax
f0104805:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104809:	8b 45 10             	mov    0x10(%ebp),%eax
f010480c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104810:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104813:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104817:	c7 04 24 df 43 10 f0 	movl   $0xf01043df,(%esp)
f010481e:	e8 01 fc ff ff       	call   f0104424 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104823:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104826:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104829:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010482c:	eb 05                	jmp    f0104833 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010482e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104833:	c9                   	leave  
f0104834:	c3                   	ret    

f0104835 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104835:	55                   	push   %ebp
f0104836:	89 e5                	mov    %esp,%ebp
f0104838:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f010483b:	8d 45 14             	lea    0x14(%ebp),%eax
f010483e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104842:	8b 45 10             	mov    0x10(%ebp),%eax
f0104845:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104849:	8b 45 0c             	mov    0xc(%ebp),%eax
f010484c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104850:	8b 45 08             	mov    0x8(%ebp),%eax
f0104853:	89 04 24             	mov    %eax,(%esp)
f0104856:	e8 82 ff ff ff       	call   f01047dd <vsnprintf>
	va_end(ap);

	return rc;
}
f010485b:	c9                   	leave  
f010485c:	c3                   	ret    
f010485d:	00 00                	add    %al,(%eax)
	...

f0104860 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104860:	55                   	push   %ebp
f0104861:	89 e5                	mov    %esp,%ebp
f0104863:	57                   	push   %edi
f0104864:	56                   	push   %esi
f0104865:	53                   	push   %ebx
f0104866:	83 ec 1c             	sub    $0x1c,%esp
f0104869:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010486c:	85 c0                	test   %eax,%eax
f010486e:	74 10                	je     f0104880 <readline+0x20>
		cprintf("%s", prompt);
f0104870:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104874:	c7 04 24 6f 5c 10 f0 	movl   $0xf0105c6f,(%esp)
f010487b:	e8 42 e9 ff ff       	call   f01031c2 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104880:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104887:	e8 cb be ff ff       	call   f0100757 <iscons>
f010488c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010488e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104893:	e8 ae be ff ff       	call   f0100746 <getchar>
f0104898:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010489a:	85 c0                	test   %eax,%eax
f010489c:	79 17                	jns    f01048b5 <readline+0x55>
			cprintf("read error: %e\n", c);
f010489e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a2:	c7 04 24 44 65 10 f0 	movl   $0xf0106544,(%esp)
f01048a9:	e8 14 e9 ff ff       	call   f01031c2 <cprintf>
			return NULL;
f01048ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01048b3:	eb 61                	jmp    f0104916 <readline+0xb6>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01048b5:	83 f8 1f             	cmp    $0x1f,%eax
f01048b8:	7e 1f                	jle    f01048d9 <readline+0x79>
f01048ba:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01048c0:	7f 17                	jg     f01048d9 <readline+0x79>
			if (echoing)
f01048c2:	85 ff                	test   %edi,%edi
f01048c4:	74 08                	je     f01048ce <readline+0x6e>
				cputchar(c);
f01048c6:	89 04 24             	mov    %eax,(%esp)
f01048c9:	e8 65 be ff ff       	call   f0100733 <cputchar>
			buf[i++] = c;
f01048ce:	88 9e 60 63 1b f0    	mov    %bl,-0xfe49ca0(%esi)
f01048d4:	83 c6 01             	add    $0x1,%esi
f01048d7:	eb ba                	jmp    f0104893 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f01048d9:	83 fb 08             	cmp    $0x8,%ebx
f01048dc:	75 15                	jne    f01048f3 <readline+0x93>
f01048de:	85 f6                	test   %esi,%esi
f01048e0:	7e 11                	jle    f01048f3 <readline+0x93>
			if (echoing)
f01048e2:	85 ff                	test   %edi,%edi
f01048e4:	74 08                	je     f01048ee <readline+0x8e>
				cputchar(c);
f01048e6:	89 1c 24             	mov    %ebx,(%esp)
f01048e9:	e8 45 be ff ff       	call   f0100733 <cputchar>
			i--;
f01048ee:	83 ee 01             	sub    $0x1,%esi
f01048f1:	eb a0                	jmp    f0104893 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01048f3:	83 fb 0a             	cmp    $0xa,%ebx
f01048f6:	74 05                	je     f01048fd <readline+0x9d>
f01048f8:	83 fb 0d             	cmp    $0xd,%ebx
f01048fb:	75 96                	jne    f0104893 <readline+0x33>
			if (echoing)
f01048fd:	85 ff                	test   %edi,%edi
f01048ff:	90                   	nop
f0104900:	74 08                	je     f010490a <readline+0xaa>
				cputchar(c);
f0104902:	89 1c 24             	mov    %ebx,(%esp)
f0104905:	e8 29 be ff ff       	call   f0100733 <cputchar>
			buf[i] = 0;
f010490a:	c6 86 60 63 1b f0 00 	movb   $0x0,-0xfe49ca0(%esi)
			return buf;
f0104911:	b8 60 63 1b f0       	mov    $0xf01b6360,%eax
		}
	}
}
f0104916:	83 c4 1c             	add    $0x1c,%esp
f0104919:	5b                   	pop    %ebx
f010491a:	5e                   	pop    %esi
f010491b:	5f                   	pop    %edi
f010491c:	5d                   	pop    %ebp
f010491d:	c3                   	ret    
	...

f0104920 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0104920:	55                   	push   %ebp
f0104921:	89 e5                	mov    %esp,%ebp
f0104923:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104926:	b8 00 00 00 00       	mov    $0x0,%eax
f010492b:	80 3a 00             	cmpb   $0x0,(%edx)
f010492e:	74 09                	je     f0104939 <strlen+0x19>
		n++;
f0104930:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104933:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104937:	75 f7                	jne    f0104930 <strlen+0x10>
		n++;
	return n;
}
f0104939:	5d                   	pop    %ebp
f010493a:	c3                   	ret    

f010493b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010493b:	55                   	push   %ebp
f010493c:	89 e5                	mov    %esp,%ebp
f010493e:	53                   	push   %ebx
f010493f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104942:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104945:	b8 00 00 00 00       	mov    $0x0,%eax
f010494a:	85 c9                	test   %ecx,%ecx
f010494c:	74 1a                	je     f0104968 <strnlen+0x2d>
f010494e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0104951:	74 15                	je     f0104968 <strnlen+0x2d>
f0104953:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0104958:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010495a:	39 ca                	cmp    %ecx,%edx
f010495c:	74 0a                	je     f0104968 <strnlen+0x2d>
f010495e:	83 c2 01             	add    $0x1,%edx
f0104961:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0104966:	75 f0                	jne    f0104958 <strnlen+0x1d>
		n++;
	return n;
}
f0104968:	5b                   	pop    %ebx
f0104969:	5d                   	pop    %ebp
f010496a:	c3                   	ret    

f010496b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010496b:	55                   	push   %ebp
f010496c:	89 e5                	mov    %esp,%ebp
f010496e:	53                   	push   %ebx
f010496f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104975:	ba 00 00 00 00       	mov    $0x0,%edx
f010497a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010497e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104981:	83 c2 01             	add    $0x1,%edx
f0104984:	84 c9                	test   %cl,%cl
f0104986:	75 f2                	jne    f010497a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104988:	5b                   	pop    %ebx
f0104989:	5d                   	pop    %ebp
f010498a:	c3                   	ret    

f010498b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010498b:	55                   	push   %ebp
f010498c:	89 e5                	mov    %esp,%ebp
f010498e:	56                   	push   %esi
f010498f:	53                   	push   %ebx
f0104990:	8b 45 08             	mov    0x8(%ebp),%eax
f0104993:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104996:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104999:	85 f6                	test   %esi,%esi
f010499b:	74 18                	je     f01049b5 <strncpy+0x2a>
f010499d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01049a2:	0f b6 1a             	movzbl (%edx),%ebx
f01049a5:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01049a8:	80 3a 01             	cmpb   $0x1,(%edx)
f01049ab:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01049ae:	83 c1 01             	add    $0x1,%ecx
f01049b1:	39 f1                	cmp    %esi,%ecx
f01049b3:	75 ed                	jne    f01049a2 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01049b5:	5b                   	pop    %ebx
f01049b6:	5e                   	pop    %esi
f01049b7:	5d                   	pop    %ebp
f01049b8:	c3                   	ret    

f01049b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01049b9:	55                   	push   %ebp
f01049ba:	89 e5                	mov    %esp,%ebp
f01049bc:	57                   	push   %edi
f01049bd:	56                   	push   %esi
f01049be:	53                   	push   %ebx
f01049bf:	8b 7d 08             	mov    0x8(%ebp),%edi
f01049c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01049c5:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01049c8:	89 f8                	mov    %edi,%eax
f01049ca:	85 f6                	test   %esi,%esi
f01049cc:	74 2b                	je     f01049f9 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
f01049ce:	83 fe 01             	cmp    $0x1,%esi
f01049d1:	74 23                	je     f01049f6 <strlcpy+0x3d>
f01049d3:	0f b6 0b             	movzbl (%ebx),%ecx
f01049d6:	84 c9                	test   %cl,%cl
f01049d8:	74 1c                	je     f01049f6 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01049da:	83 ee 02             	sub    $0x2,%esi
f01049dd:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01049e2:	88 08                	mov    %cl,(%eax)
f01049e4:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01049e7:	39 f2                	cmp    %esi,%edx
f01049e9:	74 0b                	je     f01049f6 <strlcpy+0x3d>
f01049eb:	83 c2 01             	add    $0x1,%edx
f01049ee:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01049f2:	84 c9                	test   %cl,%cl
f01049f4:	75 ec                	jne    f01049e2 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01049f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01049f9:	29 f8                	sub    %edi,%eax
}
f01049fb:	5b                   	pop    %ebx
f01049fc:	5e                   	pop    %esi
f01049fd:	5f                   	pop    %edi
f01049fe:	5d                   	pop    %ebp
f01049ff:	c3                   	ret    

f0104a00 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104a00:	55                   	push   %ebp
f0104a01:	89 e5                	mov    %esp,%ebp
f0104a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104a06:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104a09:	0f b6 01             	movzbl (%ecx),%eax
f0104a0c:	84 c0                	test   %al,%al
f0104a0e:	74 16                	je     f0104a26 <strcmp+0x26>
f0104a10:	3a 02                	cmp    (%edx),%al
f0104a12:	75 12                	jne    f0104a26 <strcmp+0x26>
		p++, q++;
f0104a14:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104a17:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0104a1b:	84 c0                	test   %al,%al
f0104a1d:	74 07                	je     f0104a26 <strcmp+0x26>
f0104a1f:	83 c1 01             	add    $0x1,%ecx
f0104a22:	3a 02                	cmp    (%edx),%al
f0104a24:	74 ee                	je     f0104a14 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a26:	0f b6 c0             	movzbl %al,%eax
f0104a29:	0f b6 12             	movzbl (%edx),%edx
f0104a2c:	29 d0                	sub    %edx,%eax
}
f0104a2e:	5d                   	pop    %ebp
f0104a2f:	c3                   	ret    

f0104a30 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104a30:	55                   	push   %ebp
f0104a31:	89 e5                	mov    %esp,%ebp
f0104a33:	53                   	push   %ebx
f0104a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104a37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a3a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104a42:	85 d2                	test   %edx,%edx
f0104a44:	74 28                	je     f0104a6e <strncmp+0x3e>
f0104a46:	0f b6 01             	movzbl (%ecx),%eax
f0104a49:	84 c0                	test   %al,%al
f0104a4b:	74 24                	je     f0104a71 <strncmp+0x41>
f0104a4d:	3a 03                	cmp    (%ebx),%al
f0104a4f:	75 20                	jne    f0104a71 <strncmp+0x41>
f0104a51:	83 ea 01             	sub    $0x1,%edx
f0104a54:	74 13                	je     f0104a69 <strncmp+0x39>
		n--, p++, q++;
f0104a56:	83 c1 01             	add    $0x1,%ecx
f0104a59:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104a5c:	0f b6 01             	movzbl (%ecx),%eax
f0104a5f:	84 c0                	test   %al,%al
f0104a61:	74 0e                	je     f0104a71 <strncmp+0x41>
f0104a63:	3a 03                	cmp    (%ebx),%al
f0104a65:	74 ea                	je     f0104a51 <strncmp+0x21>
f0104a67:	eb 08                	jmp    f0104a71 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104a69:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104a6e:	5b                   	pop    %ebx
f0104a6f:	5d                   	pop    %ebp
f0104a70:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a71:	0f b6 01             	movzbl (%ecx),%eax
f0104a74:	0f b6 13             	movzbl (%ebx),%edx
f0104a77:	29 d0                	sub    %edx,%eax
f0104a79:	eb f3                	jmp    f0104a6e <strncmp+0x3e>

f0104a7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104a7b:	55                   	push   %ebp
f0104a7c:	89 e5                	mov    %esp,%ebp
f0104a7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104a85:	0f b6 10             	movzbl (%eax),%edx
f0104a88:	84 d2                	test   %dl,%dl
f0104a8a:	74 1c                	je     f0104aa8 <strchr+0x2d>
		if (*s == c)
f0104a8c:	38 ca                	cmp    %cl,%dl
f0104a8e:	75 09                	jne    f0104a99 <strchr+0x1e>
f0104a90:	eb 1b                	jmp    f0104aad <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104a92:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
f0104a95:	38 ca                	cmp    %cl,%dl
f0104a97:	74 14                	je     f0104aad <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104a99:	0f b6 50 01          	movzbl 0x1(%eax),%edx
f0104a9d:	84 d2                	test   %dl,%dl
f0104a9f:	75 f1                	jne    f0104a92 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
f0104aa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0104aa6:	eb 05                	jmp    f0104aad <strchr+0x32>
f0104aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104aad:	5d                   	pop    %ebp
f0104aae:	c3                   	ret    

f0104aaf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104aaf:	55                   	push   %ebp
f0104ab0:	89 e5                	mov    %esp,%ebp
f0104ab2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ab5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104ab9:	0f b6 10             	movzbl (%eax),%edx
f0104abc:	84 d2                	test   %dl,%dl
f0104abe:	74 14                	je     f0104ad4 <strfind+0x25>
		if (*s == c)
f0104ac0:	38 ca                	cmp    %cl,%dl
f0104ac2:	75 06                	jne    f0104aca <strfind+0x1b>
f0104ac4:	eb 0e                	jmp    f0104ad4 <strfind+0x25>
f0104ac6:	38 ca                	cmp    %cl,%dl
f0104ac8:	74 0a                	je     f0104ad4 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104aca:	83 c0 01             	add    $0x1,%eax
f0104acd:	0f b6 10             	movzbl (%eax),%edx
f0104ad0:	84 d2                	test   %dl,%dl
f0104ad2:	75 f2                	jne    f0104ac6 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0104ad4:	5d                   	pop    %ebp
f0104ad5:	c3                   	ret    

f0104ad6 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0104ad6:	55                   	push   %ebp
f0104ad7:	89 e5                	mov    %esp,%ebp
f0104ad9:	53                   	push   %ebx
f0104ada:	8b 45 08             	mov    0x8(%ebp),%eax
f0104add:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ae0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0104ae3:	89 da                	mov    %ebx,%edx
f0104ae5:	83 ea 01             	sub    $0x1,%edx
f0104ae8:	78 0d                	js     f0104af7 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f0104aea:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
f0104aec:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
f0104aee:	88 0a                	mov    %cl,(%edx)
f0104af0:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0104af3:	39 da                	cmp    %ebx,%edx
f0104af5:	75 f7                	jne    f0104aee <memset+0x18>
		*p++ = c;

	return v;
}
f0104af7:	5b                   	pop    %ebx
f0104af8:	5d                   	pop    %ebp
f0104af9:	c3                   	ret    

f0104afa <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
f0104afa:	55                   	push   %ebp
f0104afb:	89 e5                	mov    %esp,%ebp
f0104afd:	57                   	push   %edi
f0104afe:	56                   	push   %esi
f0104aff:	53                   	push   %ebx
f0104b00:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b03:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104b09:	39 c6                	cmp    %eax,%esi
f0104b0b:	72 0b                	jb     f0104b18 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0104b0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b12:	85 db                	test   %ebx,%ebx
f0104b14:	75 29                	jne    f0104b3f <memmove+0x45>
f0104b16:	eb 35                	jmp    f0104b4d <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104b18:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
f0104b1b:	39 c8                	cmp    %ecx,%eax
f0104b1d:	73 ee                	jae    f0104b0d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
f0104b1f:	85 db                	test   %ebx,%ebx
f0104b21:	74 2a                	je     f0104b4d <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0104b23:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
f0104b26:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
f0104b28:	f7 db                	neg    %ebx
f0104b2a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
f0104b2d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
f0104b2f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
f0104b34:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0104b38:	83 ea 01             	sub    $0x1,%edx
f0104b3b:	75 f2                	jne    f0104b2f <memmove+0x35>
f0104b3d:	eb 0e                	jmp    f0104b4d <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0104b3f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0104b43:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104b46:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0104b49:	39 d3                	cmp    %edx,%ebx
f0104b4b:	75 f2                	jne    f0104b3f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
f0104b4d:	5b                   	pop    %ebx
f0104b4e:	5e                   	pop    %esi
f0104b4f:	5f                   	pop    %edi
f0104b50:	5d                   	pop    %ebp
f0104b51:	c3                   	ret    

f0104b52 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0104b52:	55                   	push   %ebp
f0104b53:	89 e5                	mov    %esp,%ebp
f0104b55:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104b58:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b5b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b66:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b69:	89 04 24             	mov    %eax,(%esp)
f0104b6c:	e8 89 ff ff ff       	call   f0104afa <memmove>
}
f0104b71:	c9                   	leave  
f0104b72:	c3                   	ret    

f0104b73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104b73:	55                   	push   %ebp
f0104b74:	89 e5                	mov    %esp,%ebp
f0104b76:	57                   	push   %edi
f0104b77:	56                   	push   %esi
f0104b78:	53                   	push   %ebx
f0104b79:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b7f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104b82:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104b87:	85 ff                	test   %edi,%edi
f0104b89:	74 37                	je     f0104bc2 <memcmp+0x4f>
		if (*s1 != *s2)
f0104b8b:	0f b6 03             	movzbl (%ebx),%eax
f0104b8e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104b91:	83 ef 01             	sub    $0x1,%edi
f0104b94:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
f0104b99:	38 c8                	cmp    %cl,%al
f0104b9b:	74 1c                	je     f0104bb9 <memcmp+0x46>
f0104b9d:	eb 10                	jmp    f0104baf <memcmp+0x3c>
f0104b9f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0104ba4:	83 c2 01             	add    $0x1,%edx
f0104ba7:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0104bab:	38 c8                	cmp    %cl,%al
f0104bad:	74 0a                	je     f0104bb9 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
f0104baf:	0f b6 c0             	movzbl %al,%eax
f0104bb2:	0f b6 c9             	movzbl %cl,%ecx
f0104bb5:	29 c8                	sub    %ecx,%eax
f0104bb7:	eb 09                	jmp    f0104bc2 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104bb9:	39 fa                	cmp    %edi,%edx
f0104bbb:	75 e2                	jne    f0104b9f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bc2:	5b                   	pop    %ebx
f0104bc3:	5e                   	pop    %esi
f0104bc4:	5f                   	pop    %edi
f0104bc5:	5d                   	pop    %ebp
f0104bc6:	c3                   	ret    

f0104bc7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104bc7:	55                   	push   %ebp
f0104bc8:	89 e5                	mov    %esp,%ebp
f0104bca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104bcd:	89 c2                	mov    %eax,%edx
f0104bcf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104bd2:	39 d0                	cmp    %edx,%eax
f0104bd4:	73 15                	jae    f0104beb <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104bd6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0104bda:	38 08                	cmp    %cl,(%eax)
f0104bdc:	75 06                	jne    f0104be4 <memfind+0x1d>
f0104bde:	eb 0b                	jmp    f0104beb <memfind+0x24>
f0104be0:	38 08                	cmp    %cl,(%eax)
f0104be2:	74 07                	je     f0104beb <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104be4:	83 c0 01             	add    $0x1,%eax
f0104be7:	39 d0                	cmp    %edx,%eax
f0104be9:	75 f5                	jne    f0104be0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104beb:	5d                   	pop    %ebp
f0104bec:	c3                   	ret    

f0104bed <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104bed:	55                   	push   %ebp
f0104bee:	89 e5                	mov    %esp,%ebp
f0104bf0:	57                   	push   %edi
f0104bf1:	56                   	push   %esi
f0104bf2:	53                   	push   %ebx
f0104bf3:	8b 55 08             	mov    0x8(%ebp),%edx
f0104bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104bf9:	0f b6 02             	movzbl (%edx),%eax
f0104bfc:	3c 20                	cmp    $0x20,%al
f0104bfe:	74 04                	je     f0104c04 <strtol+0x17>
f0104c00:	3c 09                	cmp    $0x9,%al
f0104c02:	75 0e                	jne    f0104c12 <strtol+0x25>
		s++;
f0104c04:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104c07:	0f b6 02             	movzbl (%edx),%eax
f0104c0a:	3c 20                	cmp    $0x20,%al
f0104c0c:	74 f6                	je     f0104c04 <strtol+0x17>
f0104c0e:	3c 09                	cmp    $0x9,%al
f0104c10:	74 f2                	je     f0104c04 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104c12:	3c 2b                	cmp    $0x2b,%al
f0104c14:	75 0a                	jne    f0104c20 <strtol+0x33>
		s++;
f0104c16:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104c19:	bf 00 00 00 00       	mov    $0x0,%edi
f0104c1e:	eb 10                	jmp    f0104c30 <strtol+0x43>
f0104c20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104c25:	3c 2d                	cmp    $0x2d,%al
f0104c27:	75 07                	jne    f0104c30 <strtol+0x43>
		s++, neg = 1;
f0104c29:	83 c2 01             	add    $0x1,%edx
f0104c2c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c30:	85 db                	test   %ebx,%ebx
f0104c32:	0f 94 c0             	sete   %al
f0104c35:	74 05                	je     f0104c3c <strtol+0x4f>
f0104c37:	83 fb 10             	cmp    $0x10,%ebx
f0104c3a:	75 15                	jne    f0104c51 <strtol+0x64>
f0104c3c:	80 3a 30             	cmpb   $0x30,(%edx)
f0104c3f:	75 10                	jne    f0104c51 <strtol+0x64>
f0104c41:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104c45:	75 0a                	jne    f0104c51 <strtol+0x64>
		s += 2, base = 16;
f0104c47:	83 c2 02             	add    $0x2,%edx
f0104c4a:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104c4f:	eb 13                	jmp    f0104c64 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f0104c51:	84 c0                	test   %al,%al
f0104c53:	74 0f                	je     f0104c64 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104c55:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104c5a:	80 3a 30             	cmpb   $0x30,(%edx)
f0104c5d:	75 05                	jne    f0104c64 <strtol+0x77>
		s++, base = 8;
f0104c5f:	83 c2 01             	add    $0x1,%edx
f0104c62:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0104c64:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c69:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104c6b:	0f b6 0a             	movzbl (%edx),%ecx
f0104c6e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104c71:	80 fb 09             	cmp    $0x9,%bl
f0104c74:	77 08                	ja     f0104c7e <strtol+0x91>
			dig = *s - '0';
f0104c76:	0f be c9             	movsbl %cl,%ecx
f0104c79:	83 e9 30             	sub    $0x30,%ecx
f0104c7c:	eb 1e                	jmp    f0104c9c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
f0104c7e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104c81:	80 fb 19             	cmp    $0x19,%bl
f0104c84:	77 08                	ja     f0104c8e <strtol+0xa1>
			dig = *s - 'a' + 10;
f0104c86:	0f be c9             	movsbl %cl,%ecx
f0104c89:	83 e9 57             	sub    $0x57,%ecx
f0104c8c:	eb 0e                	jmp    f0104c9c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
f0104c8e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104c91:	80 fb 19             	cmp    $0x19,%bl
f0104c94:	77 14                	ja     f0104caa <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104c96:	0f be c9             	movsbl %cl,%ecx
f0104c99:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104c9c:	39 f1                	cmp    %esi,%ecx
f0104c9e:	7d 0e                	jge    f0104cae <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0104ca0:	83 c2 01             	add    $0x1,%edx
f0104ca3:	0f af c6             	imul   %esi,%eax
f0104ca6:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104ca8:	eb c1                	jmp    f0104c6b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104caa:	89 c1                	mov    %eax,%ecx
f0104cac:	eb 02                	jmp    f0104cb0 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104cae:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104cb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104cb4:	74 05                	je     f0104cbb <strtol+0xce>
		*endptr = (char *) s;
f0104cb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cb9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104cbb:	89 ca                	mov    %ecx,%edx
f0104cbd:	f7 da                	neg    %edx
f0104cbf:	85 ff                	test   %edi,%edi
f0104cc1:	0f 45 c2             	cmovne %edx,%eax
}
f0104cc4:	5b                   	pop    %ebx
f0104cc5:	5e                   	pop    %esi
f0104cc6:	5f                   	pop    %edi
f0104cc7:	5d                   	pop    %ebp
f0104cc8:	c3                   	ret    
f0104cc9:	00 00                	add    %al,(%eax)
f0104ccb:	00 00                	add    %al,(%eax)
f0104ccd:	00 00                	add    %al,(%eax)
	...

f0104cd0 <__udivdi3>:
f0104cd0:	83 ec 1c             	sub    $0x1c,%esp
f0104cd3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104cd7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
f0104cdb:	8b 44 24 20          	mov    0x20(%esp),%eax
f0104cdf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104ce3:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104ce7:	8b 74 24 24          	mov    0x24(%esp),%esi
f0104ceb:	85 ff                	test   %edi,%edi
f0104ced:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104cf1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104cf5:	89 cd                	mov    %ecx,%ebp
f0104cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cfb:	75 33                	jne    f0104d30 <__udivdi3+0x60>
f0104cfd:	39 f1                	cmp    %esi,%ecx
f0104cff:	77 57                	ja     f0104d58 <__udivdi3+0x88>
f0104d01:	85 c9                	test   %ecx,%ecx
f0104d03:	75 0b                	jne    f0104d10 <__udivdi3+0x40>
f0104d05:	b8 01 00 00 00       	mov    $0x1,%eax
f0104d0a:	31 d2                	xor    %edx,%edx
f0104d0c:	f7 f1                	div    %ecx
f0104d0e:	89 c1                	mov    %eax,%ecx
f0104d10:	89 f0                	mov    %esi,%eax
f0104d12:	31 d2                	xor    %edx,%edx
f0104d14:	f7 f1                	div    %ecx
f0104d16:	89 c6                	mov    %eax,%esi
f0104d18:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104d1c:	f7 f1                	div    %ecx
f0104d1e:	89 f2                	mov    %esi,%edx
f0104d20:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104d24:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104d28:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104d2c:	83 c4 1c             	add    $0x1c,%esp
f0104d2f:	c3                   	ret    
f0104d30:	31 d2                	xor    %edx,%edx
f0104d32:	31 c0                	xor    %eax,%eax
f0104d34:	39 f7                	cmp    %esi,%edi
f0104d36:	77 e8                	ja     f0104d20 <__udivdi3+0x50>
f0104d38:	0f bd cf             	bsr    %edi,%ecx
f0104d3b:	83 f1 1f             	xor    $0x1f,%ecx
f0104d3e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104d42:	75 2c                	jne    f0104d70 <__udivdi3+0xa0>
f0104d44:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
f0104d48:	76 04                	jbe    f0104d4e <__udivdi3+0x7e>
f0104d4a:	39 f7                	cmp    %esi,%edi
f0104d4c:	73 d2                	jae    f0104d20 <__udivdi3+0x50>
f0104d4e:	31 d2                	xor    %edx,%edx
f0104d50:	b8 01 00 00 00       	mov    $0x1,%eax
f0104d55:	eb c9                	jmp    f0104d20 <__udivdi3+0x50>
f0104d57:	90                   	nop
f0104d58:	89 f2                	mov    %esi,%edx
f0104d5a:	f7 f1                	div    %ecx
f0104d5c:	31 d2                	xor    %edx,%edx
f0104d5e:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104d62:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104d66:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104d6a:	83 c4 1c             	add    $0x1c,%esp
f0104d6d:	c3                   	ret    
f0104d6e:	66 90                	xchg   %ax,%ax
f0104d70:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104d75:	b8 20 00 00 00       	mov    $0x20,%eax
f0104d7a:	89 ea                	mov    %ebp,%edx
f0104d7c:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104d80:	d3 e7                	shl    %cl,%edi
f0104d82:	89 c1                	mov    %eax,%ecx
f0104d84:	d3 ea                	shr    %cl,%edx
f0104d86:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104d8b:	09 fa                	or     %edi,%edx
f0104d8d:	89 f7                	mov    %esi,%edi
f0104d8f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104d93:	89 f2                	mov    %esi,%edx
f0104d95:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104d99:	d3 e5                	shl    %cl,%ebp
f0104d9b:	89 c1                	mov    %eax,%ecx
f0104d9d:	d3 ef                	shr    %cl,%edi
f0104d9f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104da4:	d3 e2                	shl    %cl,%edx
f0104da6:	89 c1                	mov    %eax,%ecx
f0104da8:	d3 ee                	shr    %cl,%esi
f0104daa:	09 d6                	or     %edx,%esi
f0104dac:	89 fa                	mov    %edi,%edx
f0104dae:	89 f0                	mov    %esi,%eax
f0104db0:	f7 74 24 0c          	divl   0xc(%esp)
f0104db4:	89 d7                	mov    %edx,%edi
f0104db6:	89 c6                	mov    %eax,%esi
f0104db8:	f7 e5                	mul    %ebp
f0104dba:	39 d7                	cmp    %edx,%edi
f0104dbc:	72 22                	jb     f0104de0 <__udivdi3+0x110>
f0104dbe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
f0104dc2:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104dc7:	d3 e5                	shl    %cl,%ebp
f0104dc9:	39 c5                	cmp    %eax,%ebp
f0104dcb:	73 04                	jae    f0104dd1 <__udivdi3+0x101>
f0104dcd:	39 d7                	cmp    %edx,%edi
f0104dcf:	74 0f                	je     f0104de0 <__udivdi3+0x110>
f0104dd1:	89 f0                	mov    %esi,%eax
f0104dd3:	31 d2                	xor    %edx,%edx
f0104dd5:	e9 46 ff ff ff       	jmp    f0104d20 <__udivdi3+0x50>
f0104dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104de0:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104de3:	31 d2                	xor    %edx,%edx
f0104de5:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104de9:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104ded:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104df1:	83 c4 1c             	add    $0x1c,%esp
f0104df4:	c3                   	ret    
	...

f0104e00 <__umoddi3>:
f0104e00:	83 ec 1c             	sub    $0x1c,%esp
f0104e03:	89 6c 24 18          	mov    %ebp,0x18(%esp)
f0104e07:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0104e0b:	8b 44 24 20          	mov    0x20(%esp),%eax
f0104e0f:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104e13:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104e17:	8b 74 24 24          	mov    0x24(%esp),%esi
f0104e1b:	85 ed                	test   %ebp,%ebp
f0104e1d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104e21:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e25:	89 cf                	mov    %ecx,%edi
f0104e27:	89 04 24             	mov    %eax,(%esp)
f0104e2a:	89 f2                	mov    %esi,%edx
f0104e2c:	75 1a                	jne    f0104e48 <__umoddi3+0x48>
f0104e2e:	39 f1                	cmp    %esi,%ecx
f0104e30:	76 4e                	jbe    f0104e80 <__umoddi3+0x80>
f0104e32:	f7 f1                	div    %ecx
f0104e34:	89 d0                	mov    %edx,%eax
f0104e36:	31 d2                	xor    %edx,%edx
f0104e38:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104e3c:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104e40:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104e44:	83 c4 1c             	add    $0x1c,%esp
f0104e47:	c3                   	ret    
f0104e48:	39 f5                	cmp    %esi,%ebp
f0104e4a:	77 54                	ja     f0104ea0 <__umoddi3+0xa0>
f0104e4c:	0f bd c5             	bsr    %ebp,%eax
f0104e4f:	83 f0 1f             	xor    $0x1f,%eax
f0104e52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e56:	75 60                	jne    f0104eb8 <__umoddi3+0xb8>
f0104e58:	3b 0c 24             	cmp    (%esp),%ecx
f0104e5b:	0f 87 07 01 00 00    	ja     f0104f68 <__umoddi3+0x168>
f0104e61:	89 f2                	mov    %esi,%edx
f0104e63:	8b 34 24             	mov    (%esp),%esi
f0104e66:	29 ce                	sub    %ecx,%esi
f0104e68:	19 ea                	sbb    %ebp,%edx
f0104e6a:	89 34 24             	mov    %esi,(%esp)
f0104e6d:	8b 04 24             	mov    (%esp),%eax
f0104e70:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104e74:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104e78:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104e7c:	83 c4 1c             	add    $0x1c,%esp
f0104e7f:	c3                   	ret    
f0104e80:	85 c9                	test   %ecx,%ecx
f0104e82:	75 0b                	jne    f0104e8f <__umoddi3+0x8f>
f0104e84:	b8 01 00 00 00       	mov    $0x1,%eax
f0104e89:	31 d2                	xor    %edx,%edx
f0104e8b:	f7 f1                	div    %ecx
f0104e8d:	89 c1                	mov    %eax,%ecx
f0104e8f:	89 f0                	mov    %esi,%eax
f0104e91:	31 d2                	xor    %edx,%edx
f0104e93:	f7 f1                	div    %ecx
f0104e95:	8b 04 24             	mov    (%esp),%eax
f0104e98:	f7 f1                	div    %ecx
f0104e9a:	eb 98                	jmp    f0104e34 <__umoddi3+0x34>
f0104e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104ea0:	89 f2                	mov    %esi,%edx
f0104ea2:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104ea6:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104eaa:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104eae:	83 c4 1c             	add    $0x1c,%esp
f0104eb1:	c3                   	ret    
f0104eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104eb8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104ebd:	89 e8                	mov    %ebp,%eax
f0104ebf:	bd 20 00 00 00       	mov    $0x20,%ebp
f0104ec4:	2b 6c 24 04          	sub    0x4(%esp),%ebp
f0104ec8:	89 fa                	mov    %edi,%edx
f0104eca:	d3 e0                	shl    %cl,%eax
f0104ecc:	89 e9                	mov    %ebp,%ecx
f0104ece:	d3 ea                	shr    %cl,%edx
f0104ed0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104ed5:	09 c2                	or     %eax,%edx
f0104ed7:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104edb:	89 14 24             	mov    %edx,(%esp)
f0104ede:	89 f2                	mov    %esi,%edx
f0104ee0:	d3 e7                	shl    %cl,%edi
f0104ee2:	89 e9                	mov    %ebp,%ecx
f0104ee4:	d3 ea                	shr    %cl,%edx
f0104ee6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104eeb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104eef:	d3 e6                	shl    %cl,%esi
f0104ef1:	89 e9                	mov    %ebp,%ecx
f0104ef3:	d3 e8                	shr    %cl,%eax
f0104ef5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104efa:	09 f0                	or     %esi,%eax
f0104efc:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104f00:	f7 34 24             	divl   (%esp)
f0104f03:	d3 e6                	shl    %cl,%esi
f0104f05:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104f09:	89 d6                	mov    %edx,%esi
f0104f0b:	f7 e7                	mul    %edi
f0104f0d:	39 d6                	cmp    %edx,%esi
f0104f0f:	89 c1                	mov    %eax,%ecx
f0104f11:	89 d7                	mov    %edx,%edi
f0104f13:	72 3f                	jb     f0104f54 <__umoddi3+0x154>
f0104f15:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0104f19:	72 35                	jb     f0104f50 <__umoddi3+0x150>
f0104f1b:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104f1f:	29 c8                	sub    %ecx,%eax
f0104f21:	19 fe                	sbb    %edi,%esi
f0104f23:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104f28:	89 f2                	mov    %esi,%edx
f0104f2a:	d3 e8                	shr    %cl,%eax
f0104f2c:	89 e9                	mov    %ebp,%ecx
f0104f2e:	d3 e2                	shl    %cl,%edx
f0104f30:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104f35:	09 d0                	or     %edx,%eax
f0104f37:	89 f2                	mov    %esi,%edx
f0104f39:	d3 ea                	shr    %cl,%edx
f0104f3b:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104f3f:	8b 7c 24 14          	mov    0x14(%esp),%edi
f0104f43:	8b 6c 24 18          	mov    0x18(%esp),%ebp
f0104f47:	83 c4 1c             	add    $0x1c,%esp
f0104f4a:	c3                   	ret    
f0104f4b:	90                   	nop
f0104f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104f50:	39 d6                	cmp    %edx,%esi
f0104f52:	75 c7                	jne    f0104f1b <__umoddi3+0x11b>
f0104f54:	89 d7                	mov    %edx,%edi
f0104f56:	89 c1                	mov    %eax,%ecx
f0104f58:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
f0104f5c:	1b 3c 24             	sbb    (%esp),%edi
f0104f5f:	eb ba                	jmp    f0104f1b <__umoddi3+0x11b>
f0104f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104f68:	39 f5                	cmp    %esi,%ebp
f0104f6a:	0f 82 f1 fe ff ff    	jb     f0104e61 <__umoddi3+0x61>
f0104f70:	e9 f8 fe ff ff       	jmp    f0104e6d <__umoddi3+0x6d>
