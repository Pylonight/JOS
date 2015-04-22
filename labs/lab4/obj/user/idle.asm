
obj/user/idle:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 20 80 00 00 	movl   $0x801200,0x802000
  800041:	12 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 53 01 00 00       	call   80019c <sys_yield>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800049:	cc                   	int3   
  80004a:	eb f8                	jmp    800044 <umain+0x10>

0080004c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800055:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  80005e:	e8 09 01 00 00       	call   80016c <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 f6                	test   %esi,%esi
  800077:	7e 07                	jle    800080 <libmain+0x34>
		binaryname = argv[0];
  800079:	8b 03                	mov    (%ebx),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800084:	89 34 24             	mov    %esi,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
}
  800091:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800094:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800097:	89 ec                	mov    %ebp,%esp
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a9:	e8 61 00 00 00       	call   80010f <sys_env_destroy>
}
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000bc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	89 c3                	mov    %eax,%ebx
  8000cc:	89 c7                	mov    %eax,%edi
  8000ce:	89 c6                	mov    %eax,%esi
  8000d0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000db:	89 ec                	mov    %ebp,%esp
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	83 ec 0c             	sub    $0xc,%esp
  8000e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	89 d1                	mov    %edx,%ecx
  8000fa:	89 d3                	mov    %edx,%ebx
  8000fc:	89 d7                	mov    %edx,%edi
  8000fe:	89 d6                	mov    %edx,%esi
  800100:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800102:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800105:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800108:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 38             	sub    $0x38,%esp
  800115:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800118:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800123:	b8 03 00 00 00       	mov    $0x3,%eax
  800128:	8b 55 08             	mov    0x8(%ebp),%edx
  80012b:	89 cb                	mov    %ecx,%ebx
  80012d:	89 cf                	mov    %ecx,%edi
  80012f:	89 ce                	mov    %ecx,%esi
  800131:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800133:	85 c0                	test   %eax,%eax
  800135:	7e 28                	jle    80015f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800142:	00 
  800143:	c7 44 24 08 1c 12 80 	movl   $0x80121c,0x8(%esp)
  80014a:	00 
  80014b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800152:	00 
  800153:	c7 04 24 39 12 80 00 	movl   $0x801239,(%esp)
  80015a:	e8 35 03 00 00       	call   800494 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800162:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800165:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800168:	89 ec                	mov    %ebp,%esp
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 0c             	sub    $0xc,%esp
  800172:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800175:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800178:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017b:	ba 00 00 00 00       	mov    $0x0,%edx
  800180:	b8 02 00 00 00       	mov    $0x2,%eax
  800185:	89 d1                	mov    %edx,%ecx
  800187:	89 d3                	mov    %edx,%ebx
  800189:	89 d7                	mov    %edx,%edi
  80018b:	89 d6                	mov    %edx,%esi
  80018d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800192:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800195:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800198:	89 ec                	mov    %ebp,%esp
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <sys_yield>:

void
sys_yield(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b5:	89 d1                	mov    %edx,%ecx
  8001b7:	89 d3                	mov    %edx,%ebx
  8001b9:	89 d7                	mov    %edx,%edi
  8001bb:	89 d6                	mov    %edx,%esi
  8001bd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001bf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001c2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c8:	89 ec                	mov    %ebp,%esp
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 38             	sub    $0x38,%esp
  8001d2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	be 00 00 00 00       	mov    $0x0,%esi
  8001e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	89 f7                	mov    %esi,%edi
  8001f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 28                	jle    80021e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fa:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800201:	00 
  800202:	c7 44 24 08 1c 12 80 	movl   $0x80121c,0x8(%esp)
  800209:	00 
  80020a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800211:	00 
  800212:	c7 04 24 39 12 80 00 	movl   $0x801239,(%esp)
  800219:	e8 76 02 00 00       	call   800494 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80021e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800221:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800224:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800227:	89 ec                	mov    %ebp,%esp
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 38             	sub    $0x38,%esp
  800231:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800234:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800237:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	b8 05 00 00 00       	mov    $0x5,%eax
  80023f:	8b 75 18             	mov    0x18(%ebp),%esi
  800242:	8b 7d 14             	mov    0x14(%ebp),%edi
  800245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	8b 55 08             	mov    0x8(%ebp),%edx
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 28                	jle    80027c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	89 44 24 10          	mov    %eax,0x10(%esp)
  800258:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80025f:	00 
  800260:	c7 44 24 08 1c 12 80 	movl   $0x80121c,0x8(%esp)
  800267:	00 
  800268:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026f:	00 
  800270:	c7 04 24 39 12 80 00 	movl   $0x801239,(%esp)
  800277:	e8 18 02 00 00       	call   800494 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80027c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80027f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800282:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800285:	89 ec                	mov    %ebp,%esp
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 38             	sub    $0x38,%esp
  80028f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800292:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800295:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 28                	jle    8002da <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002bd:	00 
  8002be:	c7 44 24 08 1c 12 80 	movl   $0x80121c,0x8(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002cd:	00 
  8002ce:	c7 04 24 39 12 80 00 	movl   $0x801239,(%esp)
  8002d5:	e8 ba 01 00 00       	call   800494 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002da:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002dd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002e0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002e3:	89 ec                	mov    %ebp,%esp
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 38             	sub    $0x38,%esp
  8002ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fb:	b8 08 00 00 00       	mov    $0x8,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	89 df                	mov    %ebx,%edi
  800308:	89 de                	mov    %ebx,%esi
  80030a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80030c:	85 c0                	test   %eax,%eax
  80030e:	7e 28                	jle    800338 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800310:	89 44 24 10          	mov    %eax,0x10(%esp)
  800314:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80031b:	00 
  80031c:	c7 44 24 08 1c 12 80 	movl   $0x80121c,0x8(%esp)
  800323:	00 
  800324:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80032b:	00 
  80032c:	c7 04 24 39 12 80 00 	movl   $0x801239,(%esp)
  800333:	e8 5c 01 00 00       	call   800494 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800338:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80033b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80033e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800341:	89 ec                	mov    %ebp,%esp
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	83 ec 38             	sub    $0x38,%esp
  80034b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80034e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800351:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800354:	bb 00 00 00 00       	mov    $0x0,%ebx
  800359:	b8 09 00 00 00       	mov    $0x9,%eax
  80035e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800361:	8b 55 08             	mov    0x8(%ebp),%edx
  800364:	89 df                	mov    %ebx,%edi
  800366:	89 de                	mov    %ebx,%esi
  800368:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80036a:	85 c0                	test   %eax,%eax
  80036c:	7e 28                	jle    800396 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800372:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800379:	00 
  80037a:	c7 44 24 08 1c 12 80 	movl   $0x80121c,0x8(%esp)
  800381:	00 
  800382:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800389:	00 
  80038a:	c7 04 24 39 12 80 00 	movl   $0x801239,(%esp)
  800391:	e8 fe 00 00 00       	call   800494 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800396:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800399:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80039c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80039f:	89 ec                	mov    %ebp,%esp
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 38             	sub    $0x38,%esp
  8003a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c2:	89 df                	mov    %ebx,%edi
  8003c4:	89 de                	mov    %ebx,%esi
  8003c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	7e 28                	jle    8003f4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003d0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8003d7:	00 
  8003d8:	c7 44 24 08 1c 12 80 	movl   $0x80121c,0x8(%esp)
  8003df:	00 
  8003e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e7:	00 
  8003e8:	c7 04 24 39 12 80 00 	movl   $0x801239,(%esp)
  8003ef:	e8 a0 00 00 00       	call   800494 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003fd:	89 ec                	mov    %ebp,%esp
  8003ff:	5d                   	pop    %ebp
  800400:	c3                   	ret    

00800401 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 0c             	sub    $0xc,%esp
  800407:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80040a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80040d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800410:	be 00 00 00 00       	mov    $0x0,%esi
  800415:	b8 0c 00 00 00       	mov    $0xc,%eax
  80041a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80041d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800420:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800423:	8b 55 08             	mov    0x8(%ebp),%edx
  800426:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800428:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800431:	89 ec                	mov    %ebp,%esp
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    

00800435 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	83 ec 38             	sub    $0x38,%esp
  80043b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80043e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800441:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800444:	b9 00 00 00 00       	mov    $0x0,%ecx
  800449:	b8 0d 00 00 00       	mov    $0xd,%eax
  80044e:	8b 55 08             	mov    0x8(%ebp),%edx
  800451:	89 cb                	mov    %ecx,%ebx
  800453:	89 cf                	mov    %ecx,%edi
  800455:	89 ce                	mov    %ecx,%esi
  800457:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800459:	85 c0                	test   %eax,%eax
  80045b:	7e 28                	jle    800485 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80045d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800461:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800468:	00 
  800469:	c7 44 24 08 1c 12 80 	movl   $0x80121c,0x8(%esp)
  800470:	00 
  800471:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800478:	00 
  800479:	c7 04 24 39 12 80 00 	movl   $0x801239,(%esp)
  800480:	e8 0f 00 00 00       	call   800494 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800485:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800488:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80048b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80048e:	89 ec                	mov    %ebp,%esp
  800490:	5d                   	pop    %ebp
  800491:	c3                   	ret    
	...

00800494 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  80049a:	a1 08 20 80 00       	mov    0x802008,%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	74 10                	je     8004b3 <_panic+0x1f>
		cprintf("%s: ", argv0);
  8004a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a7:	c7 04 24 47 12 80 00 	movl   $0x801247,(%esp)
  8004ae:	e8 e8 00 00 00       	call   80059b <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004c1:	a1 00 20 80 00       	mov    0x802000,%eax
  8004c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ca:	c7 04 24 4c 12 80 00 	movl   $0x80124c,(%esp)
  8004d1:	e8 c5 00 00 00       	call   80059b <cprintf>
	vcprintf(fmt, ap);
  8004d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8004d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	e8 52 00 00 00       	call   80053a <vcprintf>
	cprintf("\n");
  8004e8:	c7 04 24 68 12 80 00 	movl   $0x801268,(%esp)
  8004ef:	e8 a7 00 00 00       	call   80059b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004f4:	cc                   	int3   
  8004f5:	eb fd                	jmp    8004f4 <_panic+0x60>
	...

008004f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	53                   	push   %ebx
  8004fc:	83 ec 14             	sub    $0x14,%esp
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800502:	8b 03                	mov    (%ebx),%eax
  800504:	8b 55 08             	mov    0x8(%ebp),%edx
  800507:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80050b:	83 c0 01             	add    $0x1,%eax
  80050e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800510:	3d ff 00 00 00       	cmp    $0xff,%eax
  800515:	75 19                	jne    800530 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800517:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80051e:	00 
  80051f:	8d 43 08             	lea    0x8(%ebx),%eax
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	e8 86 fb ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  80052a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800530:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800534:	83 c4 14             	add    $0x14,%esp
  800537:	5b                   	pop    %ebx
  800538:	5d                   	pop    %ebp
  800539:	c3                   	ret    

0080053a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800543:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80054a:	00 00 00 
	b.cnt = 0;
  80054d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800554:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800557:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055e:	8b 45 08             	mov    0x8(%ebp),%eax
  800561:	89 44 24 08          	mov    %eax,0x8(%esp)
  800565:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	c7 04 24 f8 04 80 00 	movl   $0x8004f8,(%esp)
  800576:	e8 d9 01 00 00       	call   800754 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80057b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80058b:	89 04 24             	mov    %eax,(%esp)
  80058e:	e8 1d fb ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  800593:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800599:	c9                   	leave  
  80059a:	c3                   	ret    

0080059b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80059b:	55                   	push   %ebp
  80059c:	89 e5                	mov    %esp,%ebp
  80059e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8005a1:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ab:	89 04 24             	mov    %eax,(%esp)
  8005ae:	e8 87 ff ff ff       	call   80053a <vcprintf>
	va_end(ap);

	return cnt;
}
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    
	...

008005c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	57                   	push   %edi
  8005c4:	56                   	push   %esi
  8005c5:	53                   	push   %ebx
  8005c6:	83 ec 3c             	sub    $0x3c,%esp
  8005c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005cc:	89 d7                	mov    %edx,%edi
  8005ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005da:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005dd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005e8:	72 11                	jb     8005fb <printnum+0x3b>
  8005ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ed:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005f0:	76 09                	jbe    8005fb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f2:	83 eb 01             	sub    $0x1,%ebx
  8005f5:	85 db                	test   %ebx,%ebx
  8005f7:	7f 51                	jg     80064a <printnum+0x8a>
  8005f9:	eb 5e                	jmp    800659 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005fb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005ff:	83 eb 01             	sub    $0x1,%ebx
  800602:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800606:	8b 45 10             	mov    0x10(%ebp),%eax
  800609:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800611:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800615:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80061c:	00 
  80061d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062a:	e8 11 09 00 00       	call   800f40 <__udivdi3>
  80062f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800633:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063e:	89 fa                	mov    %edi,%edx
  800640:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800643:	e8 78 ff ff ff       	call   8005c0 <printnum>
  800648:	eb 0f                	jmp    800659 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80064a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064e:	89 34 24             	mov    %esi,(%esp)
  800651:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800654:	83 eb 01             	sub    $0x1,%ebx
  800657:	75 f1                	jne    80064a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800659:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800661:	8b 45 10             	mov    0x10(%ebp),%eax
  800664:	89 44 24 08          	mov    %eax,0x8(%esp)
  800668:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80066f:	00 
  800670:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800673:	89 04 24             	mov    %eax,(%esp)
  800676:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80067d:	e8 ee 09 00 00       	call   801070 <__umoddi3>
  800682:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800686:	0f be 80 6a 12 80 00 	movsbl 0x80126a(%eax),%eax
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800693:	83 c4 3c             	add    $0x3c,%esp
  800696:	5b                   	pop    %ebx
  800697:	5e                   	pop    %esi
  800698:	5f                   	pop    %edi
  800699:	5d                   	pop    %ebp
  80069a:	c3                   	ret    

0080069b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80069e:	83 fa 01             	cmp    $0x1,%edx
  8006a1:	7e 0e                	jle    8006b1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006a8:	89 08                	mov    %ecx,(%eax)
  8006aa:	8b 02                	mov    (%edx),%eax
  8006ac:	8b 52 04             	mov    0x4(%edx),%edx
  8006af:	eb 22                	jmp    8006d3 <getuint+0x38>
	else if (lflag)
  8006b1:	85 d2                	test   %edx,%edx
  8006b3:	74 10                	je     8006c5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006b5:	8b 10                	mov    (%eax),%edx
  8006b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ba:	89 08                	mov    %ecx,(%eax)
  8006bc:	8b 02                	mov    (%edx),%eax
  8006be:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c3:	eb 0e                	jmp    8006d3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006c5:	8b 10                	mov    (%eax),%edx
  8006c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ca:	89 08                	mov    %ecx,(%eax)
  8006cc:	8b 02                	mov    (%edx),%eax
  8006ce:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 0e                	jle    8006eb <getint+0x16>
		return va_arg(*ap, long long);
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006e2:	89 08                	mov    %ecx,(%eax)
  8006e4:	8b 02                	mov    (%edx),%eax
  8006e6:	8b 52 04             	mov    0x4(%edx),%edx
  8006e9:	eb 22                	jmp    80070d <getint+0x38>
	else if (lflag)
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	74 10                	je     8006ff <getint+0x2a>
		return va_arg(*ap, long);
  8006ef:	8b 10                	mov    (%eax),%edx
  8006f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f4:	89 08                	mov    %ecx,(%eax)
  8006f6:	8b 02                	mov    (%edx),%eax
  8006f8:	89 c2                	mov    %eax,%edx
  8006fa:	c1 fa 1f             	sar    $0x1f,%edx
  8006fd:	eb 0e                	jmp    80070d <getint+0x38>
	else
		return va_arg(*ap, int);
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	8d 4a 04             	lea    0x4(%edx),%ecx
  800704:	89 08                	mov    %ecx,(%eax)
  800706:	8b 02                	mov    (%edx),%eax
  800708:	89 c2                	mov    %eax,%edx
  80070a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800715:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800719:	8b 10                	mov    (%eax),%edx
  80071b:	3b 50 04             	cmp    0x4(%eax),%edx
  80071e:	73 0a                	jae    80072a <sprintputch+0x1b>
		*b->buf++ = ch;
  800720:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800723:	88 0a                	mov    %cl,(%edx)
  800725:	83 c2 01             	add    $0x1,%edx
  800728:	89 10                	mov    %edx,(%eax)
}
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800732:	8d 45 14             	lea    0x14(%ebp),%eax
  800735:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800739:	8b 45 10             	mov    0x10(%ebp),%eax
  80073c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800740:	8b 45 0c             	mov    0xc(%ebp),%eax
  800743:	89 44 24 04          	mov    %eax,0x4(%esp)
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	89 04 24             	mov    %eax,(%esp)
  80074d:	e8 02 00 00 00       	call   800754 <vprintfmt>
	va_end(ap);
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	57                   	push   %edi
  800758:	56                   	push   %esi
  800759:	53                   	push   %ebx
  80075a:	83 ec 4c             	sub    $0x4c,%esp
  80075d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800760:	8b 75 10             	mov    0x10(%ebp),%esi
  800763:	eb 12                	jmp    800777 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800765:	85 c0                	test   %eax,%eax
  800767:	0f 84 98 03 00 00    	je     800b05 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80076d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800771:	89 04 24             	mov    %eax,(%esp)
  800774:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800777:	0f b6 06             	movzbl (%esi),%eax
  80077a:	83 c6 01             	add    $0x1,%esi
  80077d:	83 f8 25             	cmp    $0x25,%eax
  800780:	75 e3                	jne    800765 <vprintfmt+0x11>
  800782:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800786:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80078d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800792:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800799:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007a1:	eb 2b                	jmp    8007ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007a6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007aa:	eb 22                	jmp    8007ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007af:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007b3:	eb 19                	jmp    8007ce <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8007b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8007bf:	eb 0d                	jmp    8007ce <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007c7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ce:	0f b6 06             	movzbl (%esi),%eax
  8007d1:	0f b6 d0             	movzbl %al,%edx
  8007d4:	8d 7e 01             	lea    0x1(%esi),%edi
  8007d7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8007da:	83 e8 23             	sub    $0x23,%eax
  8007dd:	3c 55                	cmp    $0x55,%al
  8007df:	0f 87 fa 02 00 00    	ja     800adf <vprintfmt+0x38b>
  8007e5:	0f b6 c0             	movzbl %al,%eax
  8007e8:	ff 24 85 40 13 80 00 	jmp    *0x801340(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007ef:	83 ea 30             	sub    $0x30,%edx
  8007f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8007f5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8007f9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8007ff:	83 fa 09             	cmp    $0x9,%edx
  800802:	77 4a                	ja     80084e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800804:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800807:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80080a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80080d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800811:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800814:	8d 50 d0             	lea    -0x30(%eax),%edx
  800817:	83 fa 09             	cmp    $0x9,%edx
  80081a:	76 eb                	jbe    800807 <vprintfmt+0xb3>
  80081c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80081f:	eb 2d                	jmp    80084e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8d 50 04             	lea    0x4(%eax),%edx
  800827:	89 55 14             	mov    %edx,0x14(%ebp)
  80082a:	8b 00                	mov    (%eax),%eax
  80082c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800832:	eb 1a                	jmp    80084e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800834:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800837:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80083b:	79 91                	jns    8007ce <vprintfmt+0x7a>
  80083d:	e9 73 ff ff ff       	jmp    8007b5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800842:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800845:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80084c:	eb 80                	jmp    8007ce <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80084e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800852:	0f 89 76 ff ff ff    	jns    8007ce <vprintfmt+0x7a>
  800858:	e9 64 ff ff ff       	jmp    8007c1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80085d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800860:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800863:	e9 66 ff ff ff       	jmp    8007ce <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800875:	8b 00                	mov    (%eax),%eax
  800877:	89 04 24             	mov    %eax,(%esp)
  80087a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800880:	e9 f2 fe ff ff       	jmp    800777 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8d 50 04             	lea    0x4(%eax),%edx
  80088b:	89 55 14             	mov    %edx,0x14(%ebp)
  80088e:	8b 00                	mov    (%eax),%eax
  800890:	89 c2                	mov    %eax,%edx
  800892:	c1 fa 1f             	sar    $0x1f,%edx
  800895:	31 d0                	xor    %edx,%eax
  800897:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800899:	83 f8 08             	cmp    $0x8,%eax
  80089c:	7f 0b                	jg     8008a9 <vprintfmt+0x155>
  80089e:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  8008a5:	85 d2                	test   %edx,%edx
  8008a7:	75 23                	jne    8008cc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ad:	c7 44 24 08 82 12 80 	movl   $0x801282,0x8(%esp)
  8008b4:	00 
  8008b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bc:	89 3c 24             	mov    %edi,(%esp)
  8008bf:	e8 68 fe ff ff       	call   80072c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008c7:	e9 ab fe ff ff       	jmp    800777 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008d0:	c7 44 24 08 8b 12 80 	movl   $0x80128b,0x8(%esp)
  8008d7:	00 
  8008d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008df:	89 3c 24             	mov    %edi,(%esp)
  8008e2:	e8 45 fe ff ff       	call   80072c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008ea:	e9 88 fe ff ff       	jmp    800777 <vprintfmt+0x23>
  8008ef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8d 50 04             	lea    0x4(%eax),%edx
  8008fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800901:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800903:	85 f6                	test   %esi,%esi
  800905:	ba 7b 12 80 00       	mov    $0x80127b,%edx
  80090a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80090d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800911:	7e 06                	jle    800919 <vprintfmt+0x1c5>
  800913:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800917:	75 10                	jne    800929 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800919:	0f be 06             	movsbl (%esi),%eax
  80091c:	83 c6 01             	add    $0x1,%esi
  80091f:	85 c0                	test   %eax,%eax
  800921:	0f 85 86 00 00 00    	jne    8009ad <vprintfmt+0x259>
  800927:	eb 76                	jmp    80099f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800929:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80092d:	89 34 24             	mov    %esi,(%esp)
  800930:	e8 76 02 00 00       	call   800bab <strnlen>
  800935:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800938:	29 c2                	sub    %eax,%edx
  80093a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80093d:	85 d2                	test   %edx,%edx
  80093f:	7e d8                	jle    800919 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800941:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800945:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800948:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80094b:	89 d6                	mov    %edx,%esi
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800953:	89 3c 24             	mov    %edi,(%esp)
  800956:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800959:	83 ee 01             	sub    $0x1,%esi
  80095c:	75 f1                	jne    80094f <vprintfmt+0x1fb>
  80095e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800961:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800964:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800967:	eb b0                	jmp    800919 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800969:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80096d:	74 18                	je     800987 <vprintfmt+0x233>
  80096f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800972:	83 fa 5e             	cmp    $0x5e,%edx
  800975:	76 10                	jbe    800987 <vprintfmt+0x233>
					putch('?', putdat);
  800977:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800982:	ff 55 08             	call   *0x8(%ebp)
  800985:	eb 0a                	jmp    800991 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800987:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80098b:	89 04 24             	mov    %eax,(%esp)
  80098e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800991:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800995:	0f be 06             	movsbl (%esi),%eax
  800998:	83 c6 01             	add    $0x1,%esi
  80099b:	85 c0                	test   %eax,%eax
  80099d:	75 0e                	jne    8009ad <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80099f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009a6:	7f 11                	jg     8009b9 <vprintfmt+0x265>
  8009a8:	e9 ca fd ff ff       	jmp    800777 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ad:	85 ff                	test   %edi,%edi
  8009af:	90                   	nop
  8009b0:	78 b7                	js     800969 <vprintfmt+0x215>
  8009b2:	83 ef 01             	sub    $0x1,%edi
  8009b5:	79 b2                	jns    800969 <vprintfmt+0x215>
  8009b7:	eb e6                	jmp    80099f <vprintfmt+0x24b>
  8009b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8009bc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009c3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009ca:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009cc:	83 ee 01             	sub    $0x1,%esi
  8009cf:	75 ee                	jne    8009bf <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009d4:	e9 9e fd ff ff       	jmp    800777 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009d9:	89 ca                	mov    %ecx,%edx
  8009db:	8d 45 14             	lea    0x14(%ebp),%eax
  8009de:	e8 f2 fc ff ff       	call   8006d5 <getint>
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009ec:	85 d2                	test   %edx,%edx
  8009ee:	0f 89 ad 00 00 00    	jns    800aa1 <vprintfmt+0x34d>
				putch('-', putdat);
  8009f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a02:	f7 de                	neg    %esi
  800a04:	83 d7 00             	adc    $0x0,%edi
  800a07:	f7 df                	neg    %edi
			}
			base = 10;
  800a09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0e:	e9 8e 00 00 00       	jmp    800aa1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a13:	89 ca                	mov    %ecx,%edx
  800a15:	8d 45 14             	lea    0x14(%ebp),%eax
  800a18:	e8 7e fc ff ff       	call   80069b <getuint>
  800a1d:	89 c6                	mov    %eax,%esi
  800a1f:	89 d7                	mov    %edx,%edi
			base = 10;
  800a21:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a26:	eb 79                	jmp    800aa1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800a28:	89 ca                	mov    %ecx,%edx
  800a2a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a2d:	e8 a3 fc ff ff       	call   8006d5 <getint>
  800a32:	89 c6                	mov    %eax,%esi
  800a34:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800a36:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a3b:	85 d2                	test   %edx,%edx
  800a3d:	79 62                	jns    800aa1 <vprintfmt+0x34d>
				putch('-', putdat);
  800a3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a43:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a4a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a4d:	f7 de                	neg    %esi
  800a4f:	83 d7 00             	adc    $0x0,%edi
  800a52:	f7 df                	neg    %edi
			}
			base = 8;
  800a54:	b8 08 00 00 00       	mov    $0x8,%eax
  800a59:	eb 46                	jmp    800aa1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800a5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a66:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a74:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a77:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7a:	8d 50 04             	lea    0x4(%eax),%edx
  800a7d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a80:	8b 30                	mov    (%eax),%esi
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a87:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a8c:	eb 13                	jmp    800aa1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a8e:	89 ca                	mov    %ecx,%edx
  800a90:	8d 45 14             	lea    0x14(%ebp),%eax
  800a93:	e8 03 fc ff ff       	call   80069b <getuint>
  800a98:	89 c6                	mov    %eax,%esi
  800a9a:	89 d7                	mov    %edx,%edi
			base = 16;
  800a9c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aa1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800aa5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800aa9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ab0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab4:	89 34 24             	mov    %esi,(%esp)
  800ab7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800abb:	89 da                	mov    %ebx,%edx
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	e8 fb fa ff ff       	call   8005c0 <printnum>
			break;
  800ac5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ac8:	e9 aa fc ff ff       	jmp    800777 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800acd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad1:	89 14 24             	mov    %edx,(%esp)
  800ad4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ad7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ada:	e9 98 fc ff ff       	jmp    800777 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800adf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aea:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aed:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800af1:	0f 84 80 fc ff ff    	je     800777 <vprintfmt+0x23>
  800af7:	83 ee 01             	sub    $0x1,%esi
  800afa:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800afe:	75 f7                	jne    800af7 <vprintfmt+0x3a3>
  800b00:	e9 72 fc ff ff       	jmp    800777 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b05:	83 c4 4c             	add    $0x4c,%esp
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	83 ec 28             	sub    $0x28,%esp
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b1c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b20:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	74 30                	je     800b5e <vsnprintf+0x51>
  800b2e:	85 d2                	test   %edx,%edx
  800b30:	7e 2c                	jle    800b5e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b32:	8b 45 14             	mov    0x14(%ebp),%eax
  800b35:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b39:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b40:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b47:	c7 04 24 0f 07 80 00 	movl   $0x80070f,(%esp)
  800b4e:	e8 01 fc ff ff       	call   800754 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b56:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b5c:	eb 05                	jmp    800b63 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b5e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b72:	8b 45 10             	mov    0x10(%ebp),%eax
  800b75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	89 04 24             	mov    %eax,(%esp)
  800b86:	e8 82 ff ff ff       	call   800b0d <vsnprintf>
	va_end(ap);

	return rc;
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    
  800b8d:	00 00                	add    %al,(%eax)
	...

00800b90 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b9e:	74 09                	je     800ba9 <strlen+0x19>
		n++;
  800ba0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ba3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ba7:	75 f7                	jne    800ba0 <strlen+0x10>
		n++;
	return n;
}
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bba:	85 c9                	test   %ecx,%ecx
  800bbc:	74 1a                	je     800bd8 <strnlen+0x2d>
  800bbe:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bc1:	74 15                	je     800bd8 <strnlen+0x2d>
  800bc3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800bc8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bca:	39 ca                	cmp    %ecx,%edx
  800bcc:	74 0a                	je     800bd8 <strnlen+0x2d>
  800bce:	83 c2 01             	add    $0x1,%edx
  800bd1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800bd6:	75 f0                	jne    800bc8 <strnlen+0x1d>
		n++;
	return n;
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	53                   	push   %ebx
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bee:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bf1:	83 c2 01             	add    $0x1,%edx
  800bf4:	84 c9                	test   %cl,%cl
  800bf6:	75 f2                	jne    800bea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c06:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c09:	85 f6                	test   %esi,%esi
  800c0b:	74 18                	je     800c25 <strncpy+0x2a>
  800c0d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c12:	0f b6 1a             	movzbl (%edx),%ebx
  800c15:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c18:	80 3a 01             	cmpb   $0x1,(%edx)
  800c1b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	39 f1                	cmp    %esi,%ecx
  800c23:	75 ed                	jne    800c12 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c35:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c38:	89 f8                	mov    %edi,%eax
  800c3a:	85 f6                	test   %esi,%esi
  800c3c:	74 2b                	je     800c69 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800c3e:	83 fe 01             	cmp    $0x1,%esi
  800c41:	74 23                	je     800c66 <strlcpy+0x3d>
  800c43:	0f b6 0b             	movzbl (%ebx),%ecx
  800c46:	84 c9                	test   %cl,%cl
  800c48:	74 1c                	je     800c66 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c4a:	83 ee 02             	sub    $0x2,%esi
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c52:	88 08                	mov    %cl,(%eax)
  800c54:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c57:	39 f2                	cmp    %esi,%edx
  800c59:	74 0b                	je     800c66 <strlcpy+0x3d>
  800c5b:	83 c2 01             	add    $0x1,%edx
  800c5e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c62:	84 c9                	test   %cl,%cl
  800c64:	75 ec                	jne    800c52 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c66:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c69:	29 f8                	sub    %edi,%eax
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c76:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c79:	0f b6 01             	movzbl (%ecx),%eax
  800c7c:	84 c0                	test   %al,%al
  800c7e:	74 16                	je     800c96 <strcmp+0x26>
  800c80:	3a 02                	cmp    (%edx),%al
  800c82:	75 12                	jne    800c96 <strcmp+0x26>
		p++, q++;
  800c84:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c87:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800c8b:	84 c0                	test   %al,%al
  800c8d:	74 07                	je     800c96 <strcmp+0x26>
  800c8f:	83 c1 01             	add    $0x1,%ecx
  800c92:	3a 02                	cmp    (%edx),%al
  800c94:	74 ee                	je     800c84 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c96:	0f b6 c0             	movzbl %al,%eax
  800c99:	0f b6 12             	movzbl (%edx),%edx
  800c9c:	29 d0                	sub    %edx,%eax
}
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	53                   	push   %ebx
  800ca4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800caa:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cad:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cb2:	85 d2                	test   %edx,%edx
  800cb4:	74 28                	je     800cde <strncmp+0x3e>
  800cb6:	0f b6 01             	movzbl (%ecx),%eax
  800cb9:	84 c0                	test   %al,%al
  800cbb:	74 24                	je     800ce1 <strncmp+0x41>
  800cbd:	3a 03                	cmp    (%ebx),%al
  800cbf:	75 20                	jne    800ce1 <strncmp+0x41>
  800cc1:	83 ea 01             	sub    $0x1,%edx
  800cc4:	74 13                	je     800cd9 <strncmp+0x39>
		n--, p++, q++;
  800cc6:	83 c1 01             	add    $0x1,%ecx
  800cc9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ccc:	0f b6 01             	movzbl (%ecx),%eax
  800ccf:	84 c0                	test   %al,%al
  800cd1:	74 0e                	je     800ce1 <strncmp+0x41>
  800cd3:	3a 03                	cmp    (%ebx),%al
  800cd5:	74 ea                	je     800cc1 <strncmp+0x21>
  800cd7:	eb 08                	jmp    800ce1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce1:	0f b6 01             	movzbl (%ecx),%eax
  800ce4:	0f b6 13             	movzbl (%ebx),%edx
  800ce7:	29 d0                	sub    %edx,%eax
  800ce9:	eb f3                	jmp    800cde <strncmp+0x3e>

00800ceb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf5:	0f b6 10             	movzbl (%eax),%edx
  800cf8:	84 d2                	test   %dl,%dl
  800cfa:	74 1c                	je     800d18 <strchr+0x2d>
		if (*s == c)
  800cfc:	38 ca                	cmp    %cl,%dl
  800cfe:	75 09                	jne    800d09 <strchr+0x1e>
  800d00:	eb 1b                	jmp    800d1d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d02:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800d05:	38 ca                	cmp    %cl,%dl
  800d07:	74 14                	je     800d1d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d09:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800d0d:	84 d2                	test   %dl,%dl
  800d0f:	75 f1                	jne    800d02 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800d11:	b8 00 00 00 00       	mov    $0x0,%eax
  800d16:	eb 05                	jmp    800d1d <strchr+0x32>
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	8b 45 08             	mov    0x8(%ebp),%eax
  800d25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d29:	0f b6 10             	movzbl (%eax),%edx
  800d2c:	84 d2                	test   %dl,%dl
  800d2e:	74 14                	je     800d44 <strfind+0x25>
		if (*s == c)
  800d30:	38 ca                	cmp    %cl,%dl
  800d32:	75 06                	jne    800d3a <strfind+0x1b>
  800d34:	eb 0e                	jmp    800d44 <strfind+0x25>
  800d36:	38 ca                	cmp    %cl,%dl
  800d38:	74 0a                	je     800d44 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d3a:	83 c0 01             	add    $0x1,%eax
  800d3d:	0f b6 10             	movzbl (%eax),%edx
  800d40:	84 d2                	test   %dl,%dl
  800d42:	75 f2                	jne    800d36 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	53                   	push   %ebx
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d53:	89 da                	mov    %ebx,%edx
  800d55:	83 ea 01             	sub    $0x1,%edx
  800d58:	78 0d                	js     800d67 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800d5a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800d5c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800d5e:	88 0a                	mov    %cl,(%edx)
  800d60:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d63:	39 da                	cmp    %ebx,%edx
  800d65:	75 f7                	jne    800d5e <memset+0x18>
		*p++ = c;

	return v;
}
  800d67:	5b                   	pop    %ebx
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d79:	39 c6                	cmp    %eax,%esi
  800d7b:	72 0b                	jb     800d88 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800d7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d82:	85 db                	test   %ebx,%ebx
  800d84:	75 29                	jne    800daf <memmove+0x45>
  800d86:	eb 35                	jmp    800dbd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d88:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800d8b:	39 c8                	cmp    %ecx,%eax
  800d8d:	73 ee                	jae    800d7d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800d8f:	85 db                	test   %ebx,%ebx
  800d91:	74 2a                	je     800dbd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800d93:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800d96:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800d98:	f7 db                	neg    %ebx
  800d9a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800d9d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800d9f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800da4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800da8:	83 ea 01             	sub    $0x1,%edx
  800dab:	75 f2                	jne    800d9f <memmove+0x35>
  800dad:	eb 0e                	jmp    800dbd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800daf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800db3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800db6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800db9:	39 d3                	cmp    %edx,%ebx
  800dbb:	75 f2                	jne    800daf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	89 04 24             	mov    %eax,(%esp)
  800ddc:	e8 89 ff ff ff       	call   800d6a <memmove>
}
  800de1:	c9                   	leave  
  800de2:	c3                   	ret    

00800de3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800def:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df7:	85 ff                	test   %edi,%edi
  800df9:	74 37                	je     800e32 <memcmp+0x4f>
		if (*s1 != *s2)
  800dfb:	0f b6 03             	movzbl (%ebx),%eax
  800dfe:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e01:	83 ef 01             	sub    $0x1,%edi
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e09:	38 c8                	cmp    %cl,%al
  800e0b:	74 1c                	je     800e29 <memcmp+0x46>
  800e0d:	eb 10                	jmp    800e1f <memcmp+0x3c>
  800e0f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e14:	83 c2 01             	add    $0x1,%edx
  800e17:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e1b:	38 c8                	cmp    %cl,%al
  800e1d:	74 0a                	je     800e29 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e1f:	0f b6 c0             	movzbl %al,%eax
  800e22:	0f b6 c9             	movzbl %cl,%ecx
  800e25:	29 c8                	sub    %ecx,%eax
  800e27:	eb 09                	jmp    800e32 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e29:	39 fa                	cmp    %edi,%edx
  800e2b:	75 e2                	jne    800e0f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e42:	39 d0                	cmp    %edx,%eax
  800e44:	73 15                	jae    800e5b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e4a:	38 08                	cmp    %cl,(%eax)
  800e4c:	75 06                	jne    800e54 <memfind+0x1d>
  800e4e:	eb 0b                	jmp    800e5b <memfind+0x24>
  800e50:	38 08                	cmp    %cl,(%eax)
  800e52:	74 07                	je     800e5b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e54:	83 c0 01             	add    $0x1,%eax
  800e57:	39 d0                	cmp    %edx,%eax
  800e59:	75 f5                	jne    800e50 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e69:	0f b6 02             	movzbl (%edx),%eax
  800e6c:	3c 20                	cmp    $0x20,%al
  800e6e:	74 04                	je     800e74 <strtol+0x17>
  800e70:	3c 09                	cmp    $0x9,%al
  800e72:	75 0e                	jne    800e82 <strtol+0x25>
		s++;
  800e74:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e77:	0f b6 02             	movzbl (%edx),%eax
  800e7a:	3c 20                	cmp    $0x20,%al
  800e7c:	74 f6                	je     800e74 <strtol+0x17>
  800e7e:	3c 09                	cmp    $0x9,%al
  800e80:	74 f2                	je     800e74 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e82:	3c 2b                	cmp    $0x2b,%al
  800e84:	75 0a                	jne    800e90 <strtol+0x33>
		s++;
  800e86:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e89:	bf 00 00 00 00       	mov    $0x0,%edi
  800e8e:	eb 10                	jmp    800ea0 <strtol+0x43>
  800e90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e95:	3c 2d                	cmp    $0x2d,%al
  800e97:	75 07                	jne    800ea0 <strtol+0x43>
		s++, neg = 1;
  800e99:	83 c2 01             	add    $0x1,%edx
  800e9c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ea0:	85 db                	test   %ebx,%ebx
  800ea2:	0f 94 c0             	sete   %al
  800ea5:	74 05                	je     800eac <strtol+0x4f>
  800ea7:	83 fb 10             	cmp    $0x10,%ebx
  800eaa:	75 15                	jne    800ec1 <strtol+0x64>
  800eac:	80 3a 30             	cmpb   $0x30,(%edx)
  800eaf:	75 10                	jne    800ec1 <strtol+0x64>
  800eb1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eb5:	75 0a                	jne    800ec1 <strtol+0x64>
		s += 2, base = 16;
  800eb7:	83 c2 02             	add    $0x2,%edx
  800eba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ebf:	eb 13                	jmp    800ed4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ec1:	84 c0                	test   %al,%al
  800ec3:	74 0f                	je     800ed4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ec5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eca:	80 3a 30             	cmpb   $0x30,(%edx)
  800ecd:	75 05                	jne    800ed4 <strtol+0x77>
		s++, base = 8;
  800ecf:	83 c2 01             	add    $0x1,%edx
  800ed2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800edb:	0f b6 0a             	movzbl (%edx),%ecx
  800ede:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ee1:	80 fb 09             	cmp    $0x9,%bl
  800ee4:	77 08                	ja     800eee <strtol+0x91>
			dig = *s - '0';
  800ee6:	0f be c9             	movsbl %cl,%ecx
  800ee9:	83 e9 30             	sub    $0x30,%ecx
  800eec:	eb 1e                	jmp    800f0c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800eee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ef1:	80 fb 19             	cmp    $0x19,%bl
  800ef4:	77 08                	ja     800efe <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ef6:	0f be c9             	movsbl %cl,%ecx
  800ef9:	83 e9 57             	sub    $0x57,%ecx
  800efc:	eb 0e                	jmp    800f0c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800efe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f01:	80 fb 19             	cmp    $0x19,%bl
  800f04:	77 14                	ja     800f1a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f06:	0f be c9             	movsbl %cl,%ecx
  800f09:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f0c:	39 f1                	cmp    %esi,%ecx
  800f0e:	7d 0e                	jge    800f1e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f10:	83 c2 01             	add    $0x1,%edx
  800f13:	0f af c6             	imul   %esi,%eax
  800f16:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f18:	eb c1                	jmp    800edb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f1a:	89 c1                	mov    %eax,%ecx
  800f1c:	eb 02                	jmp    800f20 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f1e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f24:	74 05                	je     800f2b <strtol+0xce>
		*endptr = (char *) s;
  800f26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f29:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f2b:	89 ca                	mov    %ecx,%edx
  800f2d:	f7 da                	neg    %edx
  800f2f:	85 ff                	test   %edi,%edi
  800f31:	0f 45 c2             	cmovne %edx,%eax
}
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    
  800f39:	00 00                	add    %al,(%eax)
  800f3b:	00 00                	add    %al,(%eax)
  800f3d:	00 00                	add    %al,(%eax)
	...

00800f40 <__udivdi3>:
  800f40:	83 ec 1c             	sub    $0x1c,%esp
  800f43:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f47:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f4b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f4f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f53:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f57:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f5b:	85 ff                	test   %edi,%edi
  800f5d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f65:	89 cd                	mov    %ecx,%ebp
  800f67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6b:	75 33                	jne    800fa0 <__udivdi3+0x60>
  800f6d:	39 f1                	cmp    %esi,%ecx
  800f6f:	77 57                	ja     800fc8 <__udivdi3+0x88>
  800f71:	85 c9                	test   %ecx,%ecx
  800f73:	75 0b                	jne    800f80 <__udivdi3+0x40>
  800f75:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7a:	31 d2                	xor    %edx,%edx
  800f7c:	f7 f1                	div    %ecx
  800f7e:	89 c1                	mov    %eax,%ecx
  800f80:	89 f0                	mov    %esi,%eax
  800f82:	31 d2                	xor    %edx,%edx
  800f84:	f7 f1                	div    %ecx
  800f86:	89 c6                	mov    %eax,%esi
  800f88:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f8c:	f7 f1                	div    %ecx
  800f8e:	89 f2                	mov    %esi,%edx
  800f90:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f94:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f98:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f9c:	83 c4 1c             	add    $0x1c,%esp
  800f9f:	c3                   	ret    
  800fa0:	31 d2                	xor    %edx,%edx
  800fa2:	31 c0                	xor    %eax,%eax
  800fa4:	39 f7                	cmp    %esi,%edi
  800fa6:	77 e8                	ja     800f90 <__udivdi3+0x50>
  800fa8:	0f bd cf             	bsr    %edi,%ecx
  800fab:	83 f1 1f             	xor    $0x1f,%ecx
  800fae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fb2:	75 2c                	jne    800fe0 <__udivdi3+0xa0>
  800fb4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fb8:	76 04                	jbe    800fbe <__udivdi3+0x7e>
  800fba:	39 f7                	cmp    %esi,%edi
  800fbc:	73 d2                	jae    800f90 <__udivdi3+0x50>
  800fbe:	31 d2                	xor    %edx,%edx
  800fc0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc5:	eb c9                	jmp    800f90 <__udivdi3+0x50>
  800fc7:	90                   	nop
  800fc8:	89 f2                	mov    %esi,%edx
  800fca:	f7 f1                	div    %ecx
  800fcc:	31 d2                	xor    %edx,%edx
  800fce:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fd2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fd6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fda:	83 c4 1c             	add    $0x1c,%esp
  800fdd:	c3                   	ret    
  800fde:	66 90                	xchg   %ax,%ax
  800fe0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fe5:	b8 20 00 00 00       	mov    $0x20,%eax
  800fea:	89 ea                	mov    %ebp,%edx
  800fec:	2b 44 24 04          	sub    0x4(%esp),%eax
  800ff0:	d3 e7                	shl    %cl,%edi
  800ff2:	89 c1                	mov    %eax,%ecx
  800ff4:	d3 ea                	shr    %cl,%edx
  800ff6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffb:	09 fa                	or     %edi,%edx
  800ffd:	89 f7                	mov    %esi,%edi
  800fff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801003:	89 f2                	mov    %esi,%edx
  801005:	8b 74 24 08          	mov    0x8(%esp),%esi
  801009:	d3 e5                	shl    %cl,%ebp
  80100b:	89 c1                	mov    %eax,%ecx
  80100d:	d3 ef                	shr    %cl,%edi
  80100f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801014:	d3 e2                	shl    %cl,%edx
  801016:	89 c1                	mov    %eax,%ecx
  801018:	d3 ee                	shr    %cl,%esi
  80101a:	09 d6                	or     %edx,%esi
  80101c:	89 fa                	mov    %edi,%edx
  80101e:	89 f0                	mov    %esi,%eax
  801020:	f7 74 24 0c          	divl   0xc(%esp)
  801024:	89 d7                	mov    %edx,%edi
  801026:	89 c6                	mov    %eax,%esi
  801028:	f7 e5                	mul    %ebp
  80102a:	39 d7                	cmp    %edx,%edi
  80102c:	72 22                	jb     801050 <__udivdi3+0x110>
  80102e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801032:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801037:	d3 e5                	shl    %cl,%ebp
  801039:	39 c5                	cmp    %eax,%ebp
  80103b:	73 04                	jae    801041 <__udivdi3+0x101>
  80103d:	39 d7                	cmp    %edx,%edi
  80103f:	74 0f                	je     801050 <__udivdi3+0x110>
  801041:	89 f0                	mov    %esi,%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	e9 46 ff ff ff       	jmp    800f90 <__udivdi3+0x50>
  80104a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801050:	8d 46 ff             	lea    -0x1(%esi),%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	8b 74 24 10          	mov    0x10(%esp),%esi
  801059:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80105d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801061:	83 c4 1c             	add    $0x1c,%esp
  801064:	c3                   	ret    
	...

00801070 <__umoddi3>:
  801070:	83 ec 1c             	sub    $0x1c,%esp
  801073:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801077:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80107b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80107f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801083:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801087:	8b 74 24 24          	mov    0x24(%esp),%esi
  80108b:	85 ed                	test   %ebp,%ebp
  80108d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801091:	89 44 24 08          	mov    %eax,0x8(%esp)
  801095:	89 cf                	mov    %ecx,%edi
  801097:	89 04 24             	mov    %eax,(%esp)
  80109a:	89 f2                	mov    %esi,%edx
  80109c:	75 1a                	jne    8010b8 <__umoddi3+0x48>
  80109e:	39 f1                	cmp    %esi,%ecx
  8010a0:	76 4e                	jbe    8010f0 <__umoddi3+0x80>
  8010a2:	f7 f1                	div    %ecx
  8010a4:	89 d0                	mov    %edx,%eax
  8010a6:	31 d2                	xor    %edx,%edx
  8010a8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010ac:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010b0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010b4:	83 c4 1c             	add    $0x1c,%esp
  8010b7:	c3                   	ret    
  8010b8:	39 f5                	cmp    %esi,%ebp
  8010ba:	77 54                	ja     801110 <__umoddi3+0xa0>
  8010bc:	0f bd c5             	bsr    %ebp,%eax
  8010bf:	83 f0 1f             	xor    $0x1f,%eax
  8010c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c6:	75 60                	jne    801128 <__umoddi3+0xb8>
  8010c8:	3b 0c 24             	cmp    (%esp),%ecx
  8010cb:	0f 87 07 01 00 00    	ja     8011d8 <__umoddi3+0x168>
  8010d1:	89 f2                	mov    %esi,%edx
  8010d3:	8b 34 24             	mov    (%esp),%esi
  8010d6:	29 ce                	sub    %ecx,%esi
  8010d8:	19 ea                	sbb    %ebp,%edx
  8010da:	89 34 24             	mov    %esi,(%esp)
  8010dd:	8b 04 24             	mov    (%esp),%eax
  8010e0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010e4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010ec:	83 c4 1c             	add    $0x1c,%esp
  8010ef:	c3                   	ret    
  8010f0:	85 c9                	test   %ecx,%ecx
  8010f2:	75 0b                	jne    8010ff <__umoddi3+0x8f>
  8010f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f9:	31 d2                	xor    %edx,%edx
  8010fb:	f7 f1                	div    %ecx
  8010fd:	89 c1                	mov    %eax,%ecx
  8010ff:	89 f0                	mov    %esi,%eax
  801101:	31 d2                	xor    %edx,%edx
  801103:	f7 f1                	div    %ecx
  801105:	8b 04 24             	mov    (%esp),%eax
  801108:	f7 f1                	div    %ecx
  80110a:	eb 98                	jmp    8010a4 <__umoddi3+0x34>
  80110c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801110:	89 f2                	mov    %esi,%edx
  801112:	8b 74 24 10          	mov    0x10(%esp),%esi
  801116:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80111a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111e:	83 c4 1c             	add    $0x1c,%esp
  801121:	c3                   	ret    
  801122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801128:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112d:	89 e8                	mov    %ebp,%eax
  80112f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801134:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801138:	89 fa                	mov    %edi,%edx
  80113a:	d3 e0                	shl    %cl,%eax
  80113c:	89 e9                	mov    %ebp,%ecx
  80113e:	d3 ea                	shr    %cl,%edx
  801140:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801145:	09 c2                	or     %eax,%edx
  801147:	8b 44 24 08          	mov    0x8(%esp),%eax
  80114b:	89 14 24             	mov    %edx,(%esp)
  80114e:	89 f2                	mov    %esi,%edx
  801150:	d3 e7                	shl    %cl,%edi
  801152:	89 e9                	mov    %ebp,%ecx
  801154:	d3 ea                	shr    %cl,%edx
  801156:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80115f:	d3 e6                	shl    %cl,%esi
  801161:	89 e9                	mov    %ebp,%ecx
  801163:	d3 e8                	shr    %cl,%eax
  801165:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116a:	09 f0                	or     %esi,%eax
  80116c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801170:	f7 34 24             	divl   (%esp)
  801173:	d3 e6                	shl    %cl,%esi
  801175:	89 74 24 08          	mov    %esi,0x8(%esp)
  801179:	89 d6                	mov    %edx,%esi
  80117b:	f7 e7                	mul    %edi
  80117d:	39 d6                	cmp    %edx,%esi
  80117f:	89 c1                	mov    %eax,%ecx
  801181:	89 d7                	mov    %edx,%edi
  801183:	72 3f                	jb     8011c4 <__umoddi3+0x154>
  801185:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801189:	72 35                	jb     8011c0 <__umoddi3+0x150>
  80118b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80118f:	29 c8                	sub    %ecx,%eax
  801191:	19 fe                	sbb    %edi,%esi
  801193:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801198:	89 f2                	mov    %esi,%edx
  80119a:	d3 e8                	shr    %cl,%eax
  80119c:	89 e9                	mov    %ebp,%ecx
  80119e:	d3 e2                	shl    %cl,%edx
  8011a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a5:	09 d0                	or     %edx,%eax
  8011a7:	89 f2                	mov    %esi,%edx
  8011a9:	d3 ea                	shr    %cl,%edx
  8011ab:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011af:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011b3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011b7:	83 c4 1c             	add    $0x1c,%esp
  8011ba:	c3                   	ret    
  8011bb:	90                   	nop
  8011bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	39 d6                	cmp    %edx,%esi
  8011c2:	75 c7                	jne    80118b <__umoddi3+0x11b>
  8011c4:	89 d7                	mov    %edx,%edi
  8011c6:	89 c1                	mov    %eax,%ecx
  8011c8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011cc:	1b 3c 24             	sbb    (%esp),%edi
  8011cf:	eb ba                	jmp    80118b <__umoddi3+0x11b>
  8011d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	39 f5                	cmp    %esi,%ebp
  8011da:	0f 82 f1 fe ff ff    	jb     8010d1 <__umoddi3+0x61>
  8011e0:	e9 f8 fe ff ff       	jmp    8010dd <__umoddi3+0x6d>
