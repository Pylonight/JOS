
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 a2 01 00 00       	call   8001f8 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 65 03 00 00       	call   8003cf <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  80008a:	e8 09 01 00 00       	call   800198 <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 61 00 00 00       	call   80013b <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 c3                	mov    %eax,%ebx
  8000f8:	89 c7                	mov    %eax,%edi
  8000fa:	89 c6                	mov    %eax,%esi
  8000fc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000fe:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800101:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800104:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800107:	89 ec                	mov    %ebp,%esp
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_cgetc>:

int
sys_cgetc(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800114:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800117:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 01 00 00 00       	mov    $0x1,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80012e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800131:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800134:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800137:	89 ec                	mov    %ebp,%esp
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 38             	sub    $0x38,%esp
  800141:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800144:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800147:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014f:	b8 03 00 00 00       	mov    $0x3,%eax
  800154:	8b 55 08             	mov    0x8(%ebp),%edx
  800157:	89 cb                	mov    %ecx,%ebx
  800159:	89 cf                	mov    %ecx,%edi
  80015b:	89 ce                	mov    %ecx,%esi
  80015d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80015f:	85 c0                	test   %eax,%eax
  800161:	7e 28                	jle    80018b <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800163:	89 44 24 10          	mov    %eax,0x10(%esp)
  800167:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80016e:	00 
  80016f:	c7 44 24 08 37 12 80 	movl   $0x801237,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80017e:	00 
  80017f:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  800186:	e8 35 03 00 00       	call   8004c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80018b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80018e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800191:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800194:	89 ec                	mov    %ebp,%esp
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001a1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b1:	89 d1                	mov    %edx,%ecx
  8001b3:	89 d3                	mov    %edx,%ebx
  8001b5:	89 d7                	mov    %edx,%edi
  8001b7:	89 d6                	mov    %edx,%esi
  8001b9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001be:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c4:	89 ec                	mov    %ebp,%esp
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    

008001c8 <sys_yield>:

void
sys_yield(void)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001d1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001dc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001e1:	89 d1                	mov    %edx,%ecx
  8001e3:	89 d3                	mov    %edx,%ebx
  8001e5:	89 d7                	mov    %edx,%edi
  8001e7:	89 d6                	mov    %edx,%esi
  8001e9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001eb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001f4:	89 ec                	mov    %ebp,%esp
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 38             	sub    $0x38,%esp
  8001fe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800201:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800204:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	be 00 00 00 00       	mov    $0x0,%esi
  80020c:	b8 04 00 00 00       	mov    $0x4,%eax
  800211:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800217:	8b 55 08             	mov    0x8(%ebp),%edx
  80021a:	89 f7                	mov    %esi,%edi
  80021c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80021e:	85 c0                	test   %eax,%eax
  800220:	7e 28                	jle    80024a <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800222:	89 44 24 10          	mov    %eax,0x10(%esp)
  800226:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80022d:	00 
  80022e:	c7 44 24 08 37 12 80 	movl   $0x801237,0x8(%esp)
  800235:	00 
  800236:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023d:	00 
  80023e:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  800245:	e8 76 02 00 00       	call   8004c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80024a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80024d:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800250:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800253:	89 ec                	mov    %ebp,%esp
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 38             	sub    $0x38,%esp
  80025d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800260:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800263:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800266:	b8 05 00 00 00       	mov    $0x5,%eax
  80026b:	8b 75 18             	mov    0x18(%ebp),%esi
  80026e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800271:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
  80027a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7e 28                	jle    8002a8 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800280:	89 44 24 10          	mov    %eax,0x10(%esp)
  800284:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80028b:	00 
  80028c:	c7 44 24 08 37 12 80 	movl   $0x801237,0x8(%esp)
  800293:	00 
  800294:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029b:	00 
  80029c:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  8002a3:	e8 18 02 00 00       	call   8004c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002b1:	89 ec                	mov    %ebp,%esp
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 38             	sub    $0x38,%esp
  8002bb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002be:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002c1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 28                	jle    800306 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002e9:	00 
  8002ea:	c7 44 24 08 37 12 80 	movl   $0x801237,0x8(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f9:	00 
  8002fa:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  800301:	e8 ba 01 00 00       	call   8004c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800306:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800309:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80030c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80030f:	89 ec                	mov    %ebp,%esp
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 38             	sub    $0x38,%esp
  800319:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80031c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80031f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	bb 00 00 00 00       	mov    $0x0,%ebx
  800327:	b8 08 00 00 00       	mov    $0x8,%eax
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 df                	mov    %ebx,%edi
  800334:	89 de                	mov    %ebx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 28                	jle    800364 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800340:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800347:	00 
  800348:	c7 44 24 08 37 12 80 	movl   $0x801237,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  80035f:	e8 5c 01 00 00       	call   8004c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800364:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800367:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80036a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80036d:	89 ec                	mov    %ebp,%esp
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 38             	sub    $0x38,%esp
  800377:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80037a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80037d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800380:	bb 00 00 00 00       	mov    $0x0,%ebx
  800385:	b8 09 00 00 00       	mov    $0x9,%eax
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	89 df                	mov    %ebx,%edi
  800392:	89 de                	mov    %ebx,%esi
  800394:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800396:	85 c0                	test   %eax,%eax
  800398:	7e 28                	jle    8003c2 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8003a5:	00 
  8003a6:	c7 44 24 08 37 12 80 	movl   $0x801237,0x8(%esp)
  8003ad:	00 
  8003ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b5:	00 
  8003b6:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  8003bd:	e8 fe 00 00 00       	call   8004c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003c2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003c5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003c8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003cb:	89 ec                	mov    %ebp,%esp
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	83 ec 38             	sub    $0x38,%esp
  8003d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003d8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003db:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ee:	89 df                	mov    %ebx,%edi
  8003f0:	89 de                	mov    %ebx,%esi
  8003f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	7e 28                	jle    800420 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003fc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800403:	00 
  800404:	c7 44 24 08 37 12 80 	movl   $0x801237,0x8(%esp)
  80040b:	00 
  80040c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800413:	00 
  800414:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  80041b:	e8 a0 00 00 00       	call   8004c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800420:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800423:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800426:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800429:	89 ec                	mov    %ebp,%esp
  80042b:	5d                   	pop    %ebp
  80042c:	c3                   	ret    

0080042d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	83 ec 0c             	sub    $0xc,%esp
  800433:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800436:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800439:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043c:	be 00 00 00 00       	mov    $0x0,%esi
  800441:	b8 0c 00 00 00       	mov    $0xc,%eax
  800446:	8b 7d 14             	mov    0x14(%ebp),%edi
  800449:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80044c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044f:	8b 55 08             	mov    0x8(%ebp),%edx
  800452:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800454:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800457:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80045a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80045d:	89 ec                	mov    %ebp,%esp
  80045f:	5d                   	pop    %ebp
  800460:	c3                   	ret    

00800461 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	83 ec 38             	sub    $0x38,%esp
  800467:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80046a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80046d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800470:	b9 00 00 00 00       	mov    $0x0,%ecx
  800475:	b8 0d 00 00 00       	mov    $0xd,%eax
  80047a:	8b 55 08             	mov    0x8(%ebp),%edx
  80047d:	89 cb                	mov    %ecx,%ebx
  80047f:	89 cf                	mov    %ecx,%edi
  800481:	89 ce                	mov    %ecx,%esi
  800483:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800485:	85 c0                	test   %eax,%eax
  800487:	7e 28                	jle    8004b1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800489:	89 44 24 10          	mov    %eax,0x10(%esp)
  80048d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800494:	00 
  800495:	c7 44 24 08 37 12 80 	movl   $0x801237,0x8(%esp)
  80049c:	00 
  80049d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8004a4:	00 
  8004a5:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  8004ac:	e8 0f 00 00 00       	call   8004c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8004b1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8004b4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8004b7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8004ba:	89 ec                	mov    %ebp,%esp
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    
	...

008004c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8004c6:	a1 08 20 80 00       	mov    0x802008,%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	74 10                	je     8004df <_panic+0x1f>
		cprintf("%s: ", argv0);
  8004cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d3:	c7 04 24 62 12 80 00 	movl   $0x801262,(%esp)
  8004da:	e8 e8 00 00 00       	call   8005c7 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8004df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ed:	a1 00 20 80 00       	mov    0x802000,%eax
  8004f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f6:	c7 04 24 67 12 80 00 	movl   $0x801267,(%esp)
  8004fd:	e8 c5 00 00 00       	call   8005c7 <cprintf>
	vcprintf(fmt, ap);
  800502:	8d 45 14             	lea    0x14(%ebp),%eax
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	8b 45 10             	mov    0x10(%ebp),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	e8 52 00 00 00       	call   800566 <vcprintf>
	cprintf("\n");
  800514:	c7 04 24 83 12 80 00 	movl   $0x801283,(%esp)
  80051b:	e8 a7 00 00 00       	call   8005c7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800520:	cc                   	int3   
  800521:	eb fd                	jmp    800520 <_panic+0x60>
	...

00800524 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	53                   	push   %ebx
  800528:	83 ec 14             	sub    $0x14,%esp
  80052b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80052e:	8b 03                	mov    (%ebx),%eax
  800530:	8b 55 08             	mov    0x8(%ebp),%edx
  800533:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800537:	83 c0 01             	add    $0x1,%eax
  80053a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80053c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800541:	75 19                	jne    80055c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800543:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80054a:	00 
  80054b:	8d 43 08             	lea    0x8(%ebx),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	e8 86 fb ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  800556:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80055c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800560:	83 c4 14             	add    $0x14,%esp
  800563:	5b                   	pop    %ebx
  800564:	5d                   	pop    %ebp
  800565:	c3                   	ret    

00800566 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80056f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800576:	00 00 00 
	b.cnt = 0;
  800579:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800580:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800583:	8b 45 0c             	mov    0xc(%ebp),%eax
  800586:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058a:	8b 45 08             	mov    0x8(%ebp),%eax
  80058d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800591:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059b:	c7 04 24 24 05 80 00 	movl   $0x800524,(%esp)
  8005a2:	e8 dd 01 00 00       	call   800784 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	e8 1d fb ff ff       	call   8000dc <sys_cputs>

	return b.cnt;
}
  8005bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005c5:	c9                   	leave  
  8005c6:	c3                   	ret    

008005c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8005cd:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d7:	89 04 24             	mov    %eax,(%esp)
  8005da:	e8 87 ff ff ff       	call   800566 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005df:	c9                   	leave  
  8005e0:	c3                   	ret    
	...

008005f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005f0:	55                   	push   %ebp
  8005f1:	89 e5                	mov    %esp,%ebp
  8005f3:	57                   	push   %edi
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
  8005f6:	83 ec 3c             	sub    $0x3c,%esp
  8005f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005fc:	89 d7                	mov    %edx,%edi
  8005fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800601:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800604:	8b 45 0c             	mov    0xc(%ebp),%eax
  800607:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80060d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800610:	b8 00 00 00 00       	mov    $0x0,%eax
  800615:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800618:	72 11                	jb     80062b <printnum+0x3b>
  80061a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800620:	76 09                	jbe    80062b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800622:	83 eb 01             	sub    $0x1,%ebx
  800625:	85 db                	test   %ebx,%ebx
  800627:	7f 51                	jg     80067a <printnum+0x8a>
  800629:	eb 5e                	jmp    800689 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80062b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80062f:	83 eb 01             	sub    $0x1,%ebx
  800632:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800636:	8b 45 10             	mov    0x10(%ebp),%eax
  800639:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800641:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800645:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80064c:	00 
  80064d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800650:	89 04 24             	mov    %eax,(%esp)
  800653:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065a:	e8 11 09 00 00       	call   800f70 <__udivdi3>
  80065f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800663:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066e:	89 fa                	mov    %edi,%edx
  800670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800673:	e8 78 ff ff ff       	call   8005f0 <printnum>
  800678:	eb 0f                	jmp    800689 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80067a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067e:	89 34 24             	mov    %esi,(%esp)
  800681:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800684:	83 eb 01             	sub    $0x1,%ebx
  800687:	75 f1                	jne    80067a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800689:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800691:	8b 45 10             	mov    0x10(%ebp),%eax
  800694:	89 44 24 08          	mov    %eax,0x8(%esp)
  800698:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80069f:	00 
  8006a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006a3:	89 04 24             	mov    %eax,(%esp)
  8006a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ad:	e8 ee 09 00 00       	call   8010a0 <__umoddi3>
  8006b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b6:	0f be 80 85 12 80 00 	movsbl 0x801285(%eax),%eax
  8006bd:	89 04 24             	mov    %eax,(%esp)
  8006c0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8006c3:	83 c4 3c             	add    $0x3c,%esp
  8006c6:	5b                   	pop    %ebx
  8006c7:	5e                   	pop    %esi
  8006c8:	5f                   	pop    %edi
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006ce:	83 fa 01             	cmp    $0x1,%edx
  8006d1:	7e 0e                	jle    8006e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006d8:	89 08                	mov    %ecx,(%eax)
  8006da:	8b 02                	mov    (%edx),%eax
  8006dc:	8b 52 04             	mov    0x4(%edx),%edx
  8006df:	eb 22                	jmp    800703 <getuint+0x38>
	else if (lflag)
  8006e1:	85 d2                	test   %edx,%edx
  8006e3:	74 10                	je     8006f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006e5:	8b 10                	mov    (%eax),%edx
  8006e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ea:	89 08                	mov    %ecx,(%eax)
  8006ec:	8b 02                	mov    (%edx),%eax
  8006ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f3:	eb 0e                	jmp    800703 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006f5:	8b 10                	mov    (%eax),%edx
  8006f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006fa:	89 08                	mov    %ecx,(%eax)
  8006fc:	8b 02                	mov    (%edx),%eax
  8006fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800708:	83 fa 01             	cmp    $0x1,%edx
  80070b:	7e 0e                	jle    80071b <getint+0x16>
		return va_arg(*ap, long long);
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800712:	89 08                	mov    %ecx,(%eax)
  800714:	8b 02                	mov    (%edx),%eax
  800716:	8b 52 04             	mov    0x4(%edx),%edx
  800719:	eb 22                	jmp    80073d <getint+0x38>
	else if (lflag)
  80071b:	85 d2                	test   %edx,%edx
  80071d:	74 10                	je     80072f <getint+0x2a>
		return va_arg(*ap, long);
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	8d 4a 04             	lea    0x4(%edx),%ecx
  800724:	89 08                	mov    %ecx,(%eax)
  800726:	8b 02                	mov    (%edx),%eax
  800728:	89 c2                	mov    %eax,%edx
  80072a:	c1 fa 1f             	sar    $0x1f,%edx
  80072d:	eb 0e                	jmp    80073d <getint+0x38>
	else
		return va_arg(*ap, int);
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	8d 4a 04             	lea    0x4(%edx),%ecx
  800734:	89 08                	mov    %ecx,(%eax)
  800736:	8b 02                	mov    (%edx),%eax
  800738:	89 c2                	mov    %eax,%edx
  80073a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800745:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800749:	8b 10                	mov    (%eax),%edx
  80074b:	3b 50 04             	cmp    0x4(%eax),%edx
  80074e:	73 0a                	jae    80075a <sprintputch+0x1b>
		*b->buf++ = ch;
  800750:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800753:	88 0a                	mov    %cl,(%edx)
  800755:	83 c2 01             	add    $0x1,%edx
  800758:	89 10                	mov    %edx,(%eax)
}
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800769:	8b 45 10             	mov    0x10(%ebp),%eax
  80076c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800770:	8b 45 0c             	mov    0xc(%ebp),%eax
  800773:	89 44 24 04          	mov    %eax,0x4(%esp)
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	e8 02 00 00 00       	call   800784 <vprintfmt>
	va_end(ap);
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	57                   	push   %edi
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
  80078a:	83 ec 4c             	sub    $0x4c,%esp
  80078d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800790:	8b 75 10             	mov    0x10(%ebp),%esi
  800793:	eb 12                	jmp    8007a7 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800795:	85 c0                	test   %eax,%eax
  800797:	0f 84 98 03 00 00    	je     800b35 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80079d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a1:	89 04 24             	mov    %eax,(%esp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a7:	0f b6 06             	movzbl (%esi),%eax
  8007aa:	83 c6 01             	add    $0x1,%esi
  8007ad:	83 f8 25             	cmp    $0x25,%eax
  8007b0:	75 e3                	jne    800795 <vprintfmt+0x11>
  8007b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8007b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8007c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8007c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007d1:	eb 2b                	jmp    8007fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007d6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007da:	eb 22                	jmp    8007fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007df:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007e3:	eb 19                	jmp    8007fe <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8007e8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8007ef:	eb 0d                	jmp    8007fe <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fe:	0f b6 06             	movzbl (%esi),%eax
  800801:	0f b6 d0             	movzbl %al,%edx
  800804:	8d 7e 01             	lea    0x1(%esi),%edi
  800807:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80080a:	83 e8 23             	sub    $0x23,%eax
  80080d:	3c 55                	cmp    $0x55,%al
  80080f:	0f 87 fa 02 00 00    	ja     800b0f <vprintfmt+0x38b>
  800815:	0f b6 c0             	movzbl %al,%eax
  800818:	ff 24 85 40 13 80 00 	jmp    *0x801340(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80081f:	83 ea 30             	sub    $0x30,%edx
  800822:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800825:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800829:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80082c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80082f:	83 fa 09             	cmp    $0x9,%edx
  800832:	77 4a                	ja     80087e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800834:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800837:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80083a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80083d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800841:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800844:	8d 50 d0             	lea    -0x30(%eax),%edx
  800847:	83 fa 09             	cmp    $0x9,%edx
  80084a:	76 eb                	jbe    800837 <vprintfmt+0xb3>
  80084c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80084f:	eb 2d                	jmp    80087e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 50 04             	lea    0x4(%eax),%edx
  800857:	89 55 14             	mov    %edx,0x14(%ebp)
  80085a:	8b 00                	mov    (%eax),%eax
  80085c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800862:	eb 1a                	jmp    80087e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800864:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800867:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80086b:	79 91                	jns    8007fe <vprintfmt+0x7a>
  80086d:	e9 73 ff ff ff       	jmp    8007e5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800872:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800875:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80087c:	eb 80                	jmp    8007fe <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80087e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800882:	0f 89 76 ff ff ff    	jns    8007fe <vprintfmt+0x7a>
  800888:	e9 64 ff ff ff       	jmp    8007f1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80088d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800890:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800893:	e9 66 ff ff ff       	jmp    8007fe <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 04             	lea    0x4(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a5:	8b 00                	mov    (%eax),%eax
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008b0:	e9 f2 fe ff ff       	jmp    8007a7 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	8d 50 04             	lea    0x4(%eax),%edx
  8008bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008be:	8b 00                	mov    (%eax),%eax
  8008c0:	89 c2                	mov    %eax,%edx
  8008c2:	c1 fa 1f             	sar    $0x1f,%edx
  8008c5:	31 d0                	xor    %edx,%eax
  8008c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8008c9:	83 f8 08             	cmp    $0x8,%eax
  8008cc:	7f 0b                	jg     8008d9 <vprintfmt+0x155>
  8008ce:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	75 23                	jne    8008fc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008dd:	c7 44 24 08 9d 12 80 	movl   $0x80129d,0x8(%esp)
  8008e4:	00 
  8008e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ec:	89 3c 24             	mov    %edi,(%esp)
  8008ef:	e8 68 fe ff ff       	call   80075c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008f7:	e9 ab fe ff ff       	jmp    8007a7 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800900:	c7 44 24 08 a6 12 80 	movl   $0x8012a6,0x8(%esp)
  800907:	00 
  800908:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090f:	89 3c 24             	mov    %edi,(%esp)
  800912:	e8 45 fe ff ff       	call   80075c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800917:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80091a:	e9 88 fe ff ff       	jmp    8007a7 <vprintfmt+0x23>
  80091f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800922:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800925:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8d 50 04             	lea    0x4(%eax),%edx
  80092e:	89 55 14             	mov    %edx,0x14(%ebp)
  800931:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800933:	85 f6                	test   %esi,%esi
  800935:	ba 96 12 80 00       	mov    $0x801296,%edx
  80093a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80093d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800941:	7e 06                	jle    800949 <vprintfmt+0x1c5>
  800943:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800947:	75 10                	jne    800959 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800949:	0f be 06             	movsbl (%esi),%eax
  80094c:	83 c6 01             	add    $0x1,%esi
  80094f:	85 c0                	test   %eax,%eax
  800951:	0f 85 86 00 00 00    	jne    8009dd <vprintfmt+0x259>
  800957:	eb 76                	jmp    8009cf <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800959:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095d:	89 34 24             	mov    %esi,(%esp)
  800960:	e8 76 02 00 00       	call   800bdb <strnlen>
  800965:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800968:	29 c2                	sub    %eax,%edx
  80096a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80096d:	85 d2                	test   %edx,%edx
  80096f:	7e d8                	jle    800949 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800971:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800975:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800978:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80097b:	89 d6                	mov    %edx,%esi
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800983:	89 3c 24             	mov    %edi,(%esp)
  800986:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800989:	83 ee 01             	sub    $0x1,%esi
  80098c:	75 f1                	jne    80097f <vprintfmt+0x1fb>
  80098e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800991:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800994:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800997:	eb b0                	jmp    800949 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800999:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80099d:	74 18                	je     8009b7 <vprintfmt+0x233>
  80099f:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009a2:	83 fa 5e             	cmp    $0x5e,%edx
  8009a5:	76 10                	jbe    8009b7 <vprintfmt+0x233>
					putch('?', putdat);
  8009a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ab:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009b2:	ff 55 08             	call   *0x8(%ebp)
  8009b5:	eb 0a                	jmp    8009c1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8009b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009bb:	89 04 24             	mov    %eax,(%esp)
  8009be:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009c5:	0f be 06             	movsbl (%esi),%eax
  8009c8:	83 c6 01             	add    $0x1,%esi
  8009cb:	85 c0                	test   %eax,%eax
  8009cd:	75 0e                	jne    8009dd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009d6:	7f 11                	jg     8009e9 <vprintfmt+0x265>
  8009d8:	e9 ca fd ff ff       	jmp    8007a7 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009dd:	85 ff                	test   %edi,%edi
  8009df:	90                   	nop
  8009e0:	78 b7                	js     800999 <vprintfmt+0x215>
  8009e2:	83 ef 01             	sub    $0x1,%edi
  8009e5:	79 b2                	jns    800999 <vprintfmt+0x215>
  8009e7:	eb e6                	jmp    8009cf <vprintfmt+0x24b>
  8009e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8009ec:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009fa:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009fc:	83 ee 01             	sub    $0x1,%esi
  8009ff:	75 ee                	jne    8009ef <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a01:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a04:	e9 9e fd ff ff       	jmp    8007a7 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a09:	89 ca                	mov    %ecx,%edx
  800a0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0e:	e8 f2 fc ff ff       	call   800705 <getint>
  800a13:	89 c6                	mov    %eax,%esi
  800a15:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a17:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a1c:	85 d2                	test   %edx,%edx
  800a1e:	0f 89 ad 00 00 00    	jns    800ad1 <vprintfmt+0x34d>
				putch('-', putdat);
  800a24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a28:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a2f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a32:	f7 de                	neg    %esi
  800a34:	83 d7 00             	adc    $0x0,%edi
  800a37:	f7 df                	neg    %edi
			}
			base = 10;
  800a39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a3e:	e9 8e 00 00 00       	jmp    800ad1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a43:	89 ca                	mov    %ecx,%edx
  800a45:	8d 45 14             	lea    0x14(%ebp),%eax
  800a48:	e8 7e fc ff ff       	call   8006cb <getuint>
  800a4d:	89 c6                	mov    %eax,%esi
  800a4f:	89 d7                	mov    %edx,%edi
			base = 10;
  800a51:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a56:	eb 79                	jmp    800ad1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800a58:	89 ca                	mov    %ecx,%edx
  800a5a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5d:	e8 a3 fc ff ff       	call   800705 <getint>
  800a62:	89 c6                	mov    %eax,%esi
  800a64:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800a66:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a6b:	85 d2                	test   %edx,%edx
  800a6d:	79 62                	jns    800ad1 <vprintfmt+0x34d>
				putch('-', putdat);
  800a6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a73:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a7a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a7d:	f7 de                	neg    %esi
  800a7f:	83 d7 00             	adc    $0x0,%edi
  800a82:	f7 df                	neg    %edi
			}
			base = 8;
  800a84:	b8 08 00 00 00       	mov    $0x8,%eax
  800a89:	eb 46                	jmp    800ad1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800a8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a8f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a96:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a99:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a9d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800aa4:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800aa7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaa:	8d 50 04             	lea    0x4(%eax),%edx
  800aad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ab0:	8b 30                	mov    (%eax),%esi
  800ab2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ab7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800abc:	eb 13                	jmp    800ad1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800abe:	89 ca                	mov    %ecx,%edx
  800ac0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ac3:	e8 03 fc ff ff       	call   8006cb <getuint>
  800ac8:	89 c6                	mov    %eax,%esi
  800aca:	89 d7                	mov    %edx,%edi
			base = 16;
  800acc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ad1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800ad5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ad9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800adc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ae0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae4:	89 34 24             	mov    %esi,(%esp)
  800ae7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aeb:	89 da                	mov    %ebx,%edx
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	e8 fb fa ff ff       	call   8005f0 <printnum>
			break;
  800af5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800af8:	e9 aa fc ff ff       	jmp    8007a7 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800afd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b01:	89 14 24             	mov    %edx,(%esp)
  800b04:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b07:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b0a:	e9 98 fc ff ff       	jmp    8007a7 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b13:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b1a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b1d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b21:	0f 84 80 fc ff ff    	je     8007a7 <vprintfmt+0x23>
  800b27:	83 ee 01             	sub    $0x1,%esi
  800b2a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b2e:	75 f7                	jne    800b27 <vprintfmt+0x3a3>
  800b30:	e9 72 fc ff ff       	jmp    8007a7 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b35:	83 c4 4c             	add    $0x4c,%esp
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	83 ec 28             	sub    $0x28,%esp
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b4c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b50:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b53:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	74 30                	je     800b8e <vsnprintf+0x51>
  800b5e:	85 d2                	test   %edx,%edx
  800b60:	7e 2c                	jle    800b8e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b62:	8b 45 14             	mov    0x14(%ebp),%eax
  800b65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b69:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b70:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b77:	c7 04 24 3f 07 80 00 	movl   $0x80073f,(%esp)
  800b7e:	e8 01 fc ff ff       	call   800784 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b83:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b86:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b8c:	eb 05                	jmp    800b93 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b93:	c9                   	leave  
  800b94:	c3                   	ret    

00800b95 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b9b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	89 04 24             	mov    %eax,(%esp)
  800bb6:	e8 82 ff ff ff       	call   800b3d <vsnprintf>
	va_end(ap);

	return rc;
}
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    
  800bbd:	00 00                	add    %al,(%eax)
	...

00800bc0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	80 3a 00             	cmpb   $0x0,(%edx)
  800bce:	74 09                	je     800bd9 <strlen+0x19>
		n++;
  800bd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bd7:	75 f7                	jne    800bd0 <strlen+0x10>
		n++;
	return n;
}
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	53                   	push   %ebx
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bea:	85 c9                	test   %ecx,%ecx
  800bec:	74 1a                	je     800c08 <strnlen+0x2d>
  800bee:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bf1:	74 15                	je     800c08 <strnlen+0x2d>
  800bf3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800bf8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bfa:	39 ca                	cmp    %ecx,%edx
  800bfc:	74 0a                	je     800c08 <strnlen+0x2d>
  800bfe:	83 c2 01             	add    $0x1,%edx
  800c01:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800c06:	75 f0                	jne    800bf8 <strnlen+0x1d>
		n++;
	return n;
}
  800c08:	5b                   	pop    %ebx
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	53                   	push   %ebx
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c1e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c21:	83 c2 01             	add    $0x1,%edx
  800c24:	84 c9                	test   %cl,%cl
  800c26:	75 f2                	jne    800c1a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c28:	5b                   	pop    %ebx
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	8b 45 08             	mov    0x8(%ebp),%eax
  800c33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c36:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c39:	85 f6                	test   %esi,%esi
  800c3b:	74 18                	je     800c55 <strncpy+0x2a>
  800c3d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c42:	0f b6 1a             	movzbl (%edx),%ebx
  800c45:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c48:	80 3a 01             	cmpb   $0x1,(%edx)
  800c4b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c4e:	83 c1 01             	add    $0x1,%ecx
  800c51:	39 f1                	cmp    %esi,%ecx
  800c53:	75 ed                	jne    800c42 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c65:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c68:	89 f8                	mov    %edi,%eax
  800c6a:	85 f6                	test   %esi,%esi
  800c6c:	74 2b                	je     800c99 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800c6e:	83 fe 01             	cmp    $0x1,%esi
  800c71:	74 23                	je     800c96 <strlcpy+0x3d>
  800c73:	0f b6 0b             	movzbl (%ebx),%ecx
  800c76:	84 c9                	test   %cl,%cl
  800c78:	74 1c                	je     800c96 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c7a:	83 ee 02             	sub    $0x2,%esi
  800c7d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c82:	88 08                	mov    %cl,(%eax)
  800c84:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c87:	39 f2                	cmp    %esi,%edx
  800c89:	74 0b                	je     800c96 <strlcpy+0x3d>
  800c8b:	83 c2 01             	add    $0x1,%edx
  800c8e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c92:	84 c9                	test   %cl,%cl
  800c94:	75 ec                	jne    800c82 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c96:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c99:	29 f8                	sub    %edi,%eax
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ca9:	0f b6 01             	movzbl (%ecx),%eax
  800cac:	84 c0                	test   %al,%al
  800cae:	74 16                	je     800cc6 <strcmp+0x26>
  800cb0:	3a 02                	cmp    (%edx),%al
  800cb2:	75 12                	jne    800cc6 <strcmp+0x26>
		p++, q++;
  800cb4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cb7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800cbb:	84 c0                	test   %al,%al
  800cbd:	74 07                	je     800cc6 <strcmp+0x26>
  800cbf:	83 c1 01             	add    $0x1,%ecx
  800cc2:	3a 02                	cmp    (%edx),%al
  800cc4:	74 ee                	je     800cb4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cc6:	0f b6 c0             	movzbl %al,%eax
  800cc9:	0f b6 12             	movzbl (%edx),%edx
  800ccc:	29 d0                	sub    %edx,%eax
}
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	53                   	push   %ebx
  800cd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cda:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ce2:	85 d2                	test   %edx,%edx
  800ce4:	74 28                	je     800d0e <strncmp+0x3e>
  800ce6:	0f b6 01             	movzbl (%ecx),%eax
  800ce9:	84 c0                	test   %al,%al
  800ceb:	74 24                	je     800d11 <strncmp+0x41>
  800ced:	3a 03                	cmp    (%ebx),%al
  800cef:	75 20                	jne    800d11 <strncmp+0x41>
  800cf1:	83 ea 01             	sub    $0x1,%edx
  800cf4:	74 13                	je     800d09 <strncmp+0x39>
		n--, p++, q++;
  800cf6:	83 c1 01             	add    $0x1,%ecx
  800cf9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cfc:	0f b6 01             	movzbl (%ecx),%eax
  800cff:	84 c0                	test   %al,%al
  800d01:	74 0e                	je     800d11 <strncmp+0x41>
  800d03:	3a 03                	cmp    (%ebx),%al
  800d05:	74 ea                	je     800cf1 <strncmp+0x21>
  800d07:	eb 08                	jmp    800d11 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d11:	0f b6 01             	movzbl (%ecx),%eax
  800d14:	0f b6 13             	movzbl (%ebx),%edx
  800d17:	29 d0                	sub    %edx,%eax
  800d19:	eb f3                	jmp    800d0e <strncmp+0x3e>

00800d1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d25:	0f b6 10             	movzbl (%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	74 1c                	je     800d48 <strchr+0x2d>
		if (*s == c)
  800d2c:	38 ca                	cmp    %cl,%dl
  800d2e:	75 09                	jne    800d39 <strchr+0x1e>
  800d30:	eb 1b                	jmp    800d4d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d32:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800d35:	38 ca                	cmp    %cl,%dl
  800d37:	74 14                	je     800d4d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d39:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800d3d:	84 d2                	test   %dl,%dl
  800d3f:	75 f1                	jne    800d32 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
  800d46:	eb 05                	jmp    800d4d <strchr+0x32>
  800d48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d59:	0f b6 10             	movzbl (%eax),%edx
  800d5c:	84 d2                	test   %dl,%dl
  800d5e:	74 14                	je     800d74 <strfind+0x25>
		if (*s == c)
  800d60:	38 ca                	cmp    %cl,%dl
  800d62:	75 06                	jne    800d6a <strfind+0x1b>
  800d64:	eb 0e                	jmp    800d74 <strfind+0x25>
  800d66:	38 ca                	cmp    %cl,%dl
  800d68:	74 0a                	je     800d74 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d6a:	83 c0 01             	add    $0x1,%eax
  800d6d:	0f b6 10             	movzbl (%eax),%edx
  800d70:	84 d2                	test   %dl,%dl
  800d72:	75 f2                	jne    800d66 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	53                   	push   %ebx
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d83:	89 da                	mov    %ebx,%edx
  800d85:	83 ea 01             	sub    $0x1,%edx
  800d88:	78 0d                	js     800d97 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800d8a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800d8c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800d8e:	88 0a                	mov    %cl,(%edx)
  800d90:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d93:	39 da                	cmp    %ebx,%edx
  800d95:	75 f7                	jne    800d8e <memset+0x18>
		*p++ = c;

	return v;
}
  800d97:	5b                   	pop    %ebx
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800da9:	39 c6                	cmp    %eax,%esi
  800dab:	72 0b                	jb     800db8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800dad:	ba 00 00 00 00       	mov    $0x0,%edx
  800db2:	85 db                	test   %ebx,%ebx
  800db4:	75 29                	jne    800ddf <memmove+0x45>
  800db6:	eb 35                	jmp    800ded <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800db8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800dbb:	39 c8                	cmp    %ecx,%eax
  800dbd:	73 ee                	jae    800dad <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800dbf:	85 db                	test   %ebx,%ebx
  800dc1:	74 2a                	je     800ded <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800dc3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800dc6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800dc8:	f7 db                	neg    %ebx
  800dca:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800dcd:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800dcf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800dd4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800dd8:	83 ea 01             	sub    $0x1,%edx
  800ddb:	75 f2                	jne    800dcf <memmove+0x35>
  800ddd:	eb 0e                	jmp    800ded <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800ddf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800de3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800de6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800de9:	39 d3                	cmp    %edx,%ebx
  800deb:	75 f2                	jne    800ddf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800df8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	89 04 24             	mov    %eax,(%esp)
  800e0c:	e8 89 ff ff ff       	call   800d9a <memmove>
}
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e1f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e22:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e27:	85 ff                	test   %edi,%edi
  800e29:	74 37                	je     800e62 <memcmp+0x4f>
		if (*s1 != *s2)
  800e2b:	0f b6 03             	movzbl (%ebx),%eax
  800e2e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e31:	83 ef 01             	sub    $0x1,%edi
  800e34:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e39:	38 c8                	cmp    %cl,%al
  800e3b:	74 1c                	je     800e59 <memcmp+0x46>
  800e3d:	eb 10                	jmp    800e4f <memcmp+0x3c>
  800e3f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e44:	83 c2 01             	add    $0x1,%edx
  800e47:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e4b:	38 c8                	cmp    %cl,%al
  800e4d:	74 0a                	je     800e59 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e4f:	0f b6 c0             	movzbl %al,%eax
  800e52:	0f b6 c9             	movzbl %cl,%ecx
  800e55:	29 c8                	sub    %ecx,%eax
  800e57:	eb 09                	jmp    800e62 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e59:	39 fa                	cmp    %edi,%edx
  800e5b:	75 e2                	jne    800e3f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e72:	39 d0                	cmp    %edx,%eax
  800e74:	73 15                	jae    800e8b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e76:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e7a:	38 08                	cmp    %cl,(%eax)
  800e7c:	75 06                	jne    800e84 <memfind+0x1d>
  800e7e:	eb 0b                	jmp    800e8b <memfind+0x24>
  800e80:	38 08                	cmp    %cl,(%eax)
  800e82:	74 07                	je     800e8b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e84:	83 c0 01             	add    $0x1,%eax
  800e87:	39 d0                	cmp    %edx,%eax
  800e89:	75 f5                	jne    800e80 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
  800e96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e99:	0f b6 02             	movzbl (%edx),%eax
  800e9c:	3c 20                	cmp    $0x20,%al
  800e9e:	74 04                	je     800ea4 <strtol+0x17>
  800ea0:	3c 09                	cmp    $0x9,%al
  800ea2:	75 0e                	jne    800eb2 <strtol+0x25>
		s++;
  800ea4:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ea7:	0f b6 02             	movzbl (%edx),%eax
  800eaa:	3c 20                	cmp    $0x20,%al
  800eac:	74 f6                	je     800ea4 <strtol+0x17>
  800eae:	3c 09                	cmp    $0x9,%al
  800eb0:	74 f2                	je     800ea4 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eb2:	3c 2b                	cmp    $0x2b,%al
  800eb4:	75 0a                	jne    800ec0 <strtol+0x33>
		s++;
  800eb6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eb9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ebe:	eb 10                	jmp    800ed0 <strtol+0x43>
  800ec0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ec5:	3c 2d                	cmp    $0x2d,%al
  800ec7:	75 07                	jne    800ed0 <strtol+0x43>
		s++, neg = 1;
  800ec9:	83 c2 01             	add    $0x1,%edx
  800ecc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ed0:	85 db                	test   %ebx,%ebx
  800ed2:	0f 94 c0             	sete   %al
  800ed5:	74 05                	je     800edc <strtol+0x4f>
  800ed7:	83 fb 10             	cmp    $0x10,%ebx
  800eda:	75 15                	jne    800ef1 <strtol+0x64>
  800edc:	80 3a 30             	cmpb   $0x30,(%edx)
  800edf:	75 10                	jne    800ef1 <strtol+0x64>
  800ee1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ee5:	75 0a                	jne    800ef1 <strtol+0x64>
		s += 2, base = 16;
  800ee7:	83 c2 02             	add    $0x2,%edx
  800eea:	bb 10 00 00 00       	mov    $0x10,%ebx
  800eef:	eb 13                	jmp    800f04 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ef1:	84 c0                	test   %al,%al
  800ef3:	74 0f                	je     800f04 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ef5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800efa:	80 3a 30             	cmpb   $0x30,(%edx)
  800efd:	75 05                	jne    800f04 <strtol+0x77>
		s++, base = 8;
  800eff:	83 c2 01             	add    $0x1,%edx
  800f02:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
  800f09:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f0b:	0f b6 0a             	movzbl (%edx),%ecx
  800f0e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f11:	80 fb 09             	cmp    $0x9,%bl
  800f14:	77 08                	ja     800f1e <strtol+0x91>
			dig = *s - '0';
  800f16:	0f be c9             	movsbl %cl,%ecx
  800f19:	83 e9 30             	sub    $0x30,%ecx
  800f1c:	eb 1e                	jmp    800f3c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f1e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f21:	80 fb 19             	cmp    $0x19,%bl
  800f24:	77 08                	ja     800f2e <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f26:	0f be c9             	movsbl %cl,%ecx
  800f29:	83 e9 57             	sub    $0x57,%ecx
  800f2c:	eb 0e                	jmp    800f3c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f2e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f31:	80 fb 19             	cmp    $0x19,%bl
  800f34:	77 14                	ja     800f4a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f36:	0f be c9             	movsbl %cl,%ecx
  800f39:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f3c:	39 f1                	cmp    %esi,%ecx
  800f3e:	7d 0e                	jge    800f4e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f40:	83 c2 01             	add    $0x1,%edx
  800f43:	0f af c6             	imul   %esi,%eax
  800f46:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f48:	eb c1                	jmp    800f0b <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f4a:	89 c1                	mov    %eax,%ecx
  800f4c:	eb 02                	jmp    800f50 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f4e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f54:	74 05                	je     800f5b <strtol+0xce>
		*endptr = (char *) s;
  800f56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f59:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f5b:	89 ca                	mov    %ecx,%edx
  800f5d:	f7 da                	neg    %edx
  800f5f:	85 ff                	test   %edi,%edi
  800f61:	0f 45 c2             	cmovne %edx,%eax
}
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	00 00                	add    %al,(%eax)
  800f6b:	00 00                	add    %al,(%eax)
  800f6d:	00 00                	add    %al,(%eax)
	...

00800f70 <__udivdi3>:
  800f70:	83 ec 1c             	sub    $0x1c,%esp
  800f73:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f77:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f7b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f7f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f83:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f87:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f8b:	85 ff                	test   %edi,%edi
  800f8d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f95:	89 cd                	mov    %ecx,%ebp
  800f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9b:	75 33                	jne    800fd0 <__udivdi3+0x60>
  800f9d:	39 f1                	cmp    %esi,%ecx
  800f9f:	77 57                	ja     800ff8 <__udivdi3+0x88>
  800fa1:	85 c9                	test   %ecx,%ecx
  800fa3:	75 0b                	jne    800fb0 <__udivdi3+0x40>
  800fa5:	b8 01 00 00 00       	mov    $0x1,%eax
  800faa:	31 d2                	xor    %edx,%edx
  800fac:	f7 f1                	div    %ecx
  800fae:	89 c1                	mov    %eax,%ecx
  800fb0:	89 f0                	mov    %esi,%eax
  800fb2:	31 d2                	xor    %edx,%edx
  800fb4:	f7 f1                	div    %ecx
  800fb6:	89 c6                	mov    %eax,%esi
  800fb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fbc:	f7 f1                	div    %ecx
  800fbe:	89 f2                	mov    %esi,%edx
  800fc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fc4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fc8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fcc:	83 c4 1c             	add    $0x1c,%esp
  800fcf:	c3                   	ret    
  800fd0:	31 d2                	xor    %edx,%edx
  800fd2:	31 c0                	xor    %eax,%eax
  800fd4:	39 f7                	cmp    %esi,%edi
  800fd6:	77 e8                	ja     800fc0 <__udivdi3+0x50>
  800fd8:	0f bd cf             	bsr    %edi,%ecx
  800fdb:	83 f1 1f             	xor    $0x1f,%ecx
  800fde:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fe2:	75 2c                	jne    801010 <__udivdi3+0xa0>
  800fe4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fe8:	76 04                	jbe    800fee <__udivdi3+0x7e>
  800fea:	39 f7                	cmp    %esi,%edi
  800fec:	73 d2                	jae    800fc0 <__udivdi3+0x50>
  800fee:	31 d2                	xor    %edx,%edx
  800ff0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff5:	eb c9                	jmp    800fc0 <__udivdi3+0x50>
  800ff7:	90                   	nop
  800ff8:	89 f2                	mov    %esi,%edx
  800ffa:	f7 f1                	div    %ecx
  800ffc:	31 d2                	xor    %edx,%edx
  800ffe:	8b 74 24 10          	mov    0x10(%esp),%esi
  801002:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801006:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80100a:	83 c4 1c             	add    $0x1c,%esp
  80100d:	c3                   	ret    
  80100e:	66 90                	xchg   %ax,%ax
  801010:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801015:	b8 20 00 00 00       	mov    $0x20,%eax
  80101a:	89 ea                	mov    %ebp,%edx
  80101c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801020:	d3 e7                	shl    %cl,%edi
  801022:	89 c1                	mov    %eax,%ecx
  801024:	d3 ea                	shr    %cl,%edx
  801026:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80102b:	09 fa                	or     %edi,%edx
  80102d:	89 f7                	mov    %esi,%edi
  80102f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801033:	89 f2                	mov    %esi,%edx
  801035:	8b 74 24 08          	mov    0x8(%esp),%esi
  801039:	d3 e5                	shl    %cl,%ebp
  80103b:	89 c1                	mov    %eax,%ecx
  80103d:	d3 ef                	shr    %cl,%edi
  80103f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801044:	d3 e2                	shl    %cl,%edx
  801046:	89 c1                	mov    %eax,%ecx
  801048:	d3 ee                	shr    %cl,%esi
  80104a:	09 d6                	or     %edx,%esi
  80104c:	89 fa                	mov    %edi,%edx
  80104e:	89 f0                	mov    %esi,%eax
  801050:	f7 74 24 0c          	divl   0xc(%esp)
  801054:	89 d7                	mov    %edx,%edi
  801056:	89 c6                	mov    %eax,%esi
  801058:	f7 e5                	mul    %ebp
  80105a:	39 d7                	cmp    %edx,%edi
  80105c:	72 22                	jb     801080 <__udivdi3+0x110>
  80105e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801062:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801067:	d3 e5                	shl    %cl,%ebp
  801069:	39 c5                	cmp    %eax,%ebp
  80106b:	73 04                	jae    801071 <__udivdi3+0x101>
  80106d:	39 d7                	cmp    %edx,%edi
  80106f:	74 0f                	je     801080 <__udivdi3+0x110>
  801071:	89 f0                	mov    %esi,%eax
  801073:	31 d2                	xor    %edx,%edx
  801075:	e9 46 ff ff ff       	jmp    800fc0 <__udivdi3+0x50>
  80107a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801080:	8d 46 ff             	lea    -0x1(%esi),%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	8b 74 24 10          	mov    0x10(%esp),%esi
  801089:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80108d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801091:	83 c4 1c             	add    $0x1c,%esp
  801094:	c3                   	ret    
	...

008010a0 <__umoddi3>:
  8010a0:	83 ec 1c             	sub    $0x1c,%esp
  8010a3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010a7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8010ab:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010af:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010b3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010b7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010bb:	85 ed                	test   %ebp,%ebp
  8010bd:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c5:	89 cf                	mov    %ecx,%edi
  8010c7:	89 04 24             	mov    %eax,(%esp)
  8010ca:	89 f2                	mov    %esi,%edx
  8010cc:	75 1a                	jne    8010e8 <__umoddi3+0x48>
  8010ce:	39 f1                	cmp    %esi,%ecx
  8010d0:	76 4e                	jbe    801120 <__umoddi3+0x80>
  8010d2:	f7 f1                	div    %ecx
  8010d4:	89 d0                	mov    %edx,%eax
  8010d6:	31 d2                	xor    %edx,%edx
  8010d8:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010dc:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010e0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010e4:	83 c4 1c             	add    $0x1c,%esp
  8010e7:	c3                   	ret    
  8010e8:	39 f5                	cmp    %esi,%ebp
  8010ea:	77 54                	ja     801140 <__umoddi3+0xa0>
  8010ec:	0f bd c5             	bsr    %ebp,%eax
  8010ef:	83 f0 1f             	xor    $0x1f,%eax
  8010f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f6:	75 60                	jne    801158 <__umoddi3+0xb8>
  8010f8:	3b 0c 24             	cmp    (%esp),%ecx
  8010fb:	0f 87 07 01 00 00    	ja     801208 <__umoddi3+0x168>
  801101:	89 f2                	mov    %esi,%edx
  801103:	8b 34 24             	mov    (%esp),%esi
  801106:	29 ce                	sub    %ecx,%esi
  801108:	19 ea                	sbb    %ebp,%edx
  80110a:	89 34 24             	mov    %esi,(%esp)
  80110d:	8b 04 24             	mov    (%esp),%eax
  801110:	8b 74 24 10          	mov    0x10(%esp),%esi
  801114:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801118:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80111c:	83 c4 1c             	add    $0x1c,%esp
  80111f:	c3                   	ret    
  801120:	85 c9                	test   %ecx,%ecx
  801122:	75 0b                	jne    80112f <__umoddi3+0x8f>
  801124:	b8 01 00 00 00       	mov    $0x1,%eax
  801129:	31 d2                	xor    %edx,%edx
  80112b:	f7 f1                	div    %ecx
  80112d:	89 c1                	mov    %eax,%ecx
  80112f:	89 f0                	mov    %esi,%eax
  801131:	31 d2                	xor    %edx,%edx
  801133:	f7 f1                	div    %ecx
  801135:	8b 04 24             	mov    (%esp),%eax
  801138:	f7 f1                	div    %ecx
  80113a:	eb 98                	jmp    8010d4 <__umoddi3+0x34>
  80113c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801140:	89 f2                	mov    %esi,%edx
  801142:	8b 74 24 10          	mov    0x10(%esp),%esi
  801146:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80114a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80114e:	83 c4 1c             	add    $0x1c,%esp
  801151:	c3                   	ret    
  801152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801158:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115d:	89 e8                	mov    %ebp,%eax
  80115f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801164:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801168:	89 fa                	mov    %edi,%edx
  80116a:	d3 e0                	shl    %cl,%eax
  80116c:	89 e9                	mov    %ebp,%ecx
  80116e:	d3 ea                	shr    %cl,%edx
  801170:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801175:	09 c2                	or     %eax,%edx
  801177:	8b 44 24 08          	mov    0x8(%esp),%eax
  80117b:	89 14 24             	mov    %edx,(%esp)
  80117e:	89 f2                	mov    %esi,%edx
  801180:	d3 e7                	shl    %cl,%edi
  801182:	89 e9                	mov    %ebp,%ecx
  801184:	d3 ea                	shr    %cl,%edx
  801186:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80118b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80118f:	d3 e6                	shl    %cl,%esi
  801191:	89 e9                	mov    %ebp,%ecx
  801193:	d3 e8                	shr    %cl,%eax
  801195:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80119a:	09 f0                	or     %esi,%eax
  80119c:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011a0:	f7 34 24             	divl   (%esp)
  8011a3:	d3 e6                	shl    %cl,%esi
  8011a5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011a9:	89 d6                	mov    %edx,%esi
  8011ab:	f7 e7                	mul    %edi
  8011ad:	39 d6                	cmp    %edx,%esi
  8011af:	89 c1                	mov    %eax,%ecx
  8011b1:	89 d7                	mov    %edx,%edi
  8011b3:	72 3f                	jb     8011f4 <__umoddi3+0x154>
  8011b5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8011b9:	72 35                	jb     8011f0 <__umoddi3+0x150>
  8011bb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011bf:	29 c8                	sub    %ecx,%eax
  8011c1:	19 fe                	sbb    %edi,%esi
  8011c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011c8:	89 f2                	mov    %esi,%edx
  8011ca:	d3 e8                	shr    %cl,%eax
  8011cc:	89 e9                	mov    %ebp,%ecx
  8011ce:	d3 e2                	shl    %cl,%edx
  8011d0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011d5:	09 d0                	or     %edx,%eax
  8011d7:	89 f2                	mov    %esi,%edx
  8011d9:	d3 ea                	shr    %cl,%edx
  8011db:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011df:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011e3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011e7:	83 c4 1c             	add    $0x1c,%esp
  8011ea:	c3                   	ret    
  8011eb:	90                   	nop
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	39 d6                	cmp    %edx,%esi
  8011f2:	75 c7                	jne    8011bb <__umoddi3+0x11b>
  8011f4:	89 d7                	mov    %edx,%edi
  8011f6:	89 c1                	mov    %eax,%ecx
  8011f8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011fc:	1b 3c 24             	sbb    (%esp),%edi
  8011ff:	eb ba                	jmp    8011bb <__umoddi3+0x11b>
  801201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801208:	39 f5                	cmp    %esi,%ebp
  80120a:	0f 82 f1 fe ff ff    	jb     801101 <__umoddi3+0x61>
  801210:	e9 f8 fe ff ff       	jmp    80110d <__umoddi3+0x6d>
