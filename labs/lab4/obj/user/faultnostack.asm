
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:      jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 a4 04 80 	movl   $0x8004a4,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 65 03 00 00       	call   8003b3 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  80006e:	e8 09 01 00 00       	call   80017c <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	89 34 24             	mov    %esi,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 61 00 00 00       	call   80011f <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000da:	89 c3                	mov    %eax,%ebx
  8000dc:	89 c7                	mov    %eax,%edi
  8000de:	89 c6                	mov    %eax,%esi
  8000e0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000e5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000e8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800103:	b8 01 00 00 00       	mov    $0x1,%eax
  800108:	89 d1                	mov    %edx,%ecx
  80010a:	89 d3                	mov    %edx,%ebx
  80010c:	89 d7                	mov    %edx,%edi
  80010e:	89 d6                	mov    %edx,%esi
  800110:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800112:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800115:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800118:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80011b:	89 ec                	mov    %ebp,%esp
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	83 ec 38             	sub    $0x38,%esp
  800125:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800128:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80012b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 03 00 00 00       	mov    $0x3,%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	89 cb                	mov    %ecx,%ebx
  80013d:	89 cf                	mov    %ecx,%edi
  80013f:	89 ce                	mov    %ecx,%esi
  800141:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 28                	jle    80016f <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800152:	00 
  800153:	c7 44 24 08 77 12 80 	movl   $0x801277,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  80016a:	e8 41 03 00 00       	call   8004b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800172:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800175:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800178:	89 ec                	mov    %ebp,%esp
  80017a:	5d                   	pop    %ebp
  80017b:	c3                   	ret    

0080017c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800185:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800188:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018b:	ba 00 00 00 00       	mov    $0x0,%edx
  800190:	b8 02 00 00 00       	mov    $0x2,%eax
  800195:	89 d1                	mov    %edx,%ecx
  800197:	89 d3                	mov    %edx,%ebx
  800199:	89 d7                	mov    %edx,%edi
  80019b:	89 d6                	mov    %edx,%esi
  80019d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80019f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a8:	89 ec                	mov    %ebp,%esp
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <sys_yield>:

void
sys_yield(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c5:	89 d1                	mov    %edx,%ecx
  8001c7:	89 d3                	mov    %edx,%ebx
  8001c9:	89 d7                	mov    %edx,%edi
  8001cb:	89 d6                	mov    %edx,%esi
  8001cd:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d8:	89 ec                	mov    %ebp,%esp
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 38             	sub    $0x38,%esp
  8001e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001eb:	be 00 00 00 00       	mov    $0x0,%esi
  8001f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	89 f7                	mov    %esi,%edi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 28                	jle    80022e <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800211:	00 
  800212:	c7 44 24 08 77 12 80 	movl   $0x801277,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  800229:	e8 82 02 00 00       	call   8004b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80022e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800231:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800234:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800237:	89 ec                	mov    %ebp,%esp
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 38             	sub    $0x38,%esp
  800241:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800244:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800247:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024a:	b8 05 00 00 00       	mov    $0x5,%eax
  80024f:	8b 75 18             	mov    0x18(%ebp),%esi
  800252:	8b 7d 14             	mov    0x14(%ebp),%edi
  800255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025b:	8b 55 08             	mov    0x8(%ebp),%edx
  80025e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7e 28                	jle    80028c <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800264:	89 44 24 10          	mov    %eax,0x10(%esp)
  800268:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80026f:	00 
  800270:	c7 44 24 08 77 12 80 	movl   $0x801277,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  800287:	e8 24 02 00 00       	call   8004b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80028c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80028f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800292:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800295:	89 ec                	mov    %ebp,%esp
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 38             	sub    $0x38,%esp
  80029f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7e 28                	jle    8002ea <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 08 77 12 80 	movl   $0x801277,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  8002e5:	e8 c6 01 00 00       	call   8004b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002ea:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ed:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f3:	89 ec                	mov    %ebp,%esp
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	83 ec 38             	sub    $0x38,%esp
  8002fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800300:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800303:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030b:	b8 08 00 00 00       	mov    $0x8,%eax
  800310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	89 df                	mov    %ebx,%edi
  800318:	89 de                	mov    %ebx,%esi
  80031a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80031c:	85 c0                	test   %eax,%eax
  80031e:	7e 28                	jle    800348 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800320:	89 44 24 10          	mov    %eax,0x10(%esp)
  800324:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80032b:	00 
  80032c:	c7 44 24 08 77 12 80 	movl   $0x801277,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  800343:	e8 68 01 00 00       	call   8004b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800348:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80034b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80034e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800351:	89 ec                	mov    %ebp,%esp
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	83 ec 38             	sub    $0x38,%esp
  80035b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80035e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800361:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800364:	bb 00 00 00 00       	mov    $0x0,%ebx
  800369:	b8 09 00 00 00       	mov    $0x9,%eax
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	89 df                	mov    %ebx,%edi
  800376:	89 de                	mov    %ebx,%esi
  800378:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80037a:	85 c0                	test   %eax,%eax
  80037c:	7e 28                	jle    8003a6 <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800382:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800389:	00 
  80038a:	c7 44 24 08 77 12 80 	movl   $0x801277,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  8003a1:	e8 0a 01 00 00       	call   8004b0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8003a6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003a9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003af:	89 ec                	mov    %ebp,%esp
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	83 ec 38             	sub    $0x38,%esp
  8003b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d2:	89 df                	mov    %ebx,%edi
  8003d4:	89 de                	mov    %ebx,%esi
  8003d6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8003d8:	85 c0                	test   %eax,%eax
  8003da:	7e 28                	jle    800404 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003e0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8003e7:	00 
  8003e8:	c7 44 24 08 77 12 80 	movl   $0x801277,0x8(%esp)
  8003ef:	00 
  8003f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f7:	00 
  8003f8:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  8003ff:	e8 ac 00 00 00       	call   8004b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800404:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800407:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80040a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80040d:	89 ec                	mov    %ebp,%esp
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 0c             	sub    $0xc,%esp
  800417:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80041a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80041d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800420:	be 00 00 00 00       	mov    $0x0,%esi
  800425:	b8 0c 00 00 00       	mov    $0xc,%eax
  80042a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80042d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800430:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800433:	8b 55 08             	mov    0x8(%ebp),%edx
  800436:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800438:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80043b:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80043e:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800441:	89 ec                	mov    %ebp,%esp
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	83 ec 38             	sub    $0x38,%esp
  80044b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80044e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800451:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800454:	b9 00 00 00 00       	mov    $0x0,%ecx
  800459:	b8 0d 00 00 00       	mov    $0xd,%eax
  80045e:	8b 55 08             	mov    0x8(%ebp),%edx
  800461:	89 cb                	mov    %ecx,%ebx
  800463:	89 cf                	mov    %ecx,%edi
  800465:	89 ce                	mov    %ecx,%esi
  800467:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800469:	85 c0                	test   %eax,%eax
  80046b:	7e 28                	jle    800495 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80046d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800471:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800478:	00 
  800479:	c7 44 24 08 77 12 80 	movl   $0x801277,0x8(%esp)
  800480:	00 
  800481:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800488:	00 
  800489:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  800490:	e8 1b 00 00 00       	call   8004b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800495:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800498:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80049b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80049e:	89 ec                	mov    %ebp,%esp
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    
	...

008004a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8004a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8004a5:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8004aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8004ac:	83 c4 04             	add    $0x4,%esp
	...

008004b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8004b6:	a1 08 20 80 00       	mov    0x802008,%eax
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	74 10                	je     8004cf <_panic+0x1f>
		cprintf("%s: ", argv0);
  8004bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c3:	c7 04 24 a2 12 80 00 	movl   $0x8012a2,(%esp)
  8004ca:	e8 e8 00 00 00       	call   8005b7 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8004cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004dd:	a1 00 20 80 00       	mov    0x802000,%eax
  8004e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e6:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  8004ed:	e8 c5 00 00 00       	call   8005b7 <cprintf>
	vcprintf(fmt, ap);
  8004f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	e8 52 00 00 00       	call   800556 <vcprintf>
	cprintf("\n");
  800504:	c7 04 24 c3 12 80 00 	movl   $0x8012c3,(%esp)
  80050b:	e8 a7 00 00 00       	call   8005b7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800510:	cc                   	int3   
  800511:	eb fd                	jmp    800510 <_panic+0x60>
	...

00800514 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	53                   	push   %ebx
  800518:	83 ec 14             	sub    $0x14,%esp
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80051e:	8b 03                	mov    (%ebx),%eax
  800520:	8b 55 08             	mov    0x8(%ebp),%edx
  800523:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800527:	83 c0 01             	add    $0x1,%eax
  80052a:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80052c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800531:	75 19                	jne    80054c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800533:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80053a:	00 
  80053b:	8d 43 08             	lea    0x8(%ebx),%eax
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	e8 7a fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  800546:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80054c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800550:	83 c4 14             	add    $0x14,%esp
  800553:	5b                   	pop    %ebx
  800554:	5d                   	pop    %ebp
  800555:	c3                   	ret    

00800556 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80055f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800566:	00 00 00 
	b.cnt = 0;
  800569:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800570:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800573:	8b 45 0c             	mov    0xc(%ebp),%eax
  800576:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057a:	8b 45 08             	mov    0x8(%ebp),%eax
  80057d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800581:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058b:	c7 04 24 14 05 80 00 	movl   $0x800514,(%esp)
  800592:	e8 dd 01 00 00       	call   800774 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800597:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005a7:	89 04 24             	mov    %eax,(%esp)
  8005aa:	e8 11 fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  8005af:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005b5:	c9                   	leave  
  8005b6:	c3                   	ret    

008005b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b7:	55                   	push   %ebp
  8005b8:	89 e5                	mov    %esp,%ebp
  8005ba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8005bd:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	e8 87 ff ff ff       	call   800556 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    
	...

008005e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005e0:	55                   	push   %ebp
  8005e1:	89 e5                	mov    %esp,%ebp
  8005e3:	57                   	push   %edi
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	83 ec 3c             	sub    $0x3c,%esp
  8005e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ec:	89 d7                	mov    %edx,%edi
  8005ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800600:	b8 00 00 00 00       	mov    $0x0,%eax
  800605:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800608:	72 11                	jb     80061b <printnum+0x3b>
  80060a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800610:	76 09                	jbe    80061b <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800612:	83 eb 01             	sub    $0x1,%ebx
  800615:	85 db                	test   %ebx,%ebx
  800617:	7f 51                	jg     80066a <printnum+0x8a>
  800619:	eb 5e                	jmp    800679 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80061b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80061f:	83 eb 01             	sub    $0x1,%ebx
  800622:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800626:	8b 45 10             	mov    0x10(%ebp),%eax
  800629:	89 44 24 08          	mov    %eax,0x8(%esp)
  80062d:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800631:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800635:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80063c:	00 
  80063d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064a:	e8 51 09 00 00       	call   800fa0 <__udivdi3>
  80064f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800653:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800657:	89 04 24             	mov    %eax,(%esp)
  80065a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065e:	89 fa                	mov    %edi,%edx
  800660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800663:	e8 78 ff ff ff       	call   8005e0 <printnum>
  800668:	eb 0f                	jmp    800679 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80066a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066e:	89 34 24             	mov    %esi,(%esp)
  800671:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	75 f1                	jne    80066a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800679:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800681:	8b 45 10             	mov    0x10(%ebp),%eax
  800684:	89 44 24 08          	mov    %eax,0x8(%esp)
  800688:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80068f:	00 
  800690:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	e8 2e 0a 00 00       	call   8010d0 <__umoddi3>
  8006a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a6:	0f be 80 c5 12 80 00 	movsbl 0x8012c5(%eax),%eax
  8006ad:	89 04 24             	mov    %eax,(%esp)
  8006b0:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8006b3:	83 c4 3c             	add    $0x3c,%esp
  8006b6:	5b                   	pop    %ebx
  8006b7:	5e                   	pop    %esi
  8006b8:	5f                   	pop    %edi
  8006b9:	5d                   	pop    %ebp
  8006ba:	c3                   	ret    

008006bb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006be:	83 fa 01             	cmp    $0x1,%edx
  8006c1:	7e 0e                	jle    8006d1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006c3:	8b 10                	mov    (%eax),%edx
  8006c5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006c8:	89 08                	mov    %ecx,(%eax)
  8006ca:	8b 02                	mov    (%edx),%eax
  8006cc:	8b 52 04             	mov    0x4(%edx),%edx
  8006cf:	eb 22                	jmp    8006f3 <getuint+0x38>
	else if (lflag)
  8006d1:	85 d2                	test   %edx,%edx
  8006d3:	74 10                	je     8006e5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006d5:	8b 10                	mov    (%eax),%edx
  8006d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006da:	89 08                	mov    %ecx,(%eax)
  8006dc:	8b 02                	mov    (%edx),%eax
  8006de:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e3:	eb 0e                	jmp    8006f3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006e5:	8b 10                	mov    (%eax),%edx
  8006e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ea:	89 08                	mov    %ecx,(%eax)
  8006ec:	8b 02                	mov    (%edx),%eax
  8006ee:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006f8:	83 fa 01             	cmp    $0x1,%edx
  8006fb:	7e 0e                	jle    80070b <getint+0x16>
		return va_arg(*ap, long long);
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800702:	89 08                	mov    %ecx,(%eax)
  800704:	8b 02                	mov    (%edx),%eax
  800706:	8b 52 04             	mov    0x4(%edx),%edx
  800709:	eb 22                	jmp    80072d <getint+0x38>
	else if (lflag)
  80070b:	85 d2                	test   %edx,%edx
  80070d:	74 10                	je     80071f <getint+0x2a>
		return va_arg(*ap, long);
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	8d 4a 04             	lea    0x4(%edx),%ecx
  800714:	89 08                	mov    %ecx,(%eax)
  800716:	8b 02                	mov    (%edx),%eax
  800718:	89 c2                	mov    %eax,%edx
  80071a:	c1 fa 1f             	sar    $0x1f,%edx
  80071d:	eb 0e                	jmp    80072d <getint+0x38>
	else
		return va_arg(*ap, int);
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	8d 4a 04             	lea    0x4(%edx),%ecx
  800724:	89 08                	mov    %ecx,(%eax)
  800726:	8b 02                	mov    (%edx),%eax
  800728:	89 c2                	mov    %eax,%edx
  80072a:	c1 fa 1f             	sar    $0x1f,%edx
}
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800735:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800739:	8b 10                	mov    (%eax),%edx
  80073b:	3b 50 04             	cmp    0x4(%eax),%edx
  80073e:	73 0a                	jae    80074a <sprintputch+0x1b>
		*b->buf++ = ch;
  800740:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800743:	88 0a                	mov    %cl,(%edx)
  800745:	83 c2 01             	add    $0x1,%edx
  800748:	89 10                	mov    %edx,(%eax)
}
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
  800755:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800759:	8b 45 10             	mov    0x10(%ebp),%eax
  80075c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800760:	8b 45 0c             	mov    0xc(%ebp),%eax
  800763:	89 44 24 04          	mov    %eax,0x4(%esp)
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	89 04 24             	mov    %eax,(%esp)
  80076d:	e8 02 00 00 00       	call   800774 <vprintfmt>
	va_end(ap);
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	57                   	push   %edi
  800778:	56                   	push   %esi
  800779:	53                   	push   %ebx
  80077a:	83 ec 4c             	sub    $0x4c,%esp
  80077d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800780:	8b 75 10             	mov    0x10(%ebp),%esi
  800783:	eb 12                	jmp    800797 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800785:	85 c0                	test   %eax,%eax
  800787:	0f 84 98 03 00 00    	je     800b25 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80078d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800791:	89 04 24             	mov    %eax,(%esp)
  800794:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800797:	0f b6 06             	movzbl (%esi),%eax
  80079a:	83 c6 01             	add    $0x1,%esi
  80079d:	83 f8 25             	cmp    $0x25,%eax
  8007a0:	75 e3                	jne    800785 <vprintfmt+0x11>
  8007a2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8007a6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8007b2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8007b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007be:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007c1:	eb 2b                	jmp    8007ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c3:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007c6:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007ca:	eb 22                	jmp    8007ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007cf:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007d3:	eb 19                	jmp    8007ee <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8007d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8007df:	eb 0d                	jmp    8007ee <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	0f b6 06             	movzbl (%esi),%eax
  8007f1:	0f b6 d0             	movzbl %al,%edx
  8007f4:	8d 7e 01             	lea    0x1(%esi),%edi
  8007f7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8007fa:	83 e8 23             	sub    $0x23,%eax
  8007fd:	3c 55                	cmp    $0x55,%al
  8007ff:	0f 87 fa 02 00 00    	ja     800aff <vprintfmt+0x38b>
  800805:	0f b6 c0             	movzbl %al,%eax
  800808:	ff 24 85 80 13 80 00 	jmp    *0x801380(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80080f:	83 ea 30             	sub    $0x30,%edx
  800812:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  800815:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800819:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  80081f:	83 fa 09             	cmp    $0x9,%edx
  800822:	77 4a                	ja     80086e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800824:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800827:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80082a:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80082d:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800831:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800834:	8d 50 d0             	lea    -0x30(%eax),%edx
  800837:	83 fa 09             	cmp    $0x9,%edx
  80083a:	76 eb                	jbe    800827 <vprintfmt+0xb3>
  80083c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80083f:	eb 2d                	jmp    80086e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8d 50 04             	lea    0x4(%eax),%edx
  800847:	89 55 14             	mov    %edx,0x14(%ebp)
  80084a:	8b 00                	mov    (%eax),%eax
  80084c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800852:	eb 1a                	jmp    80086e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800854:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800857:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80085b:	79 91                	jns    8007ee <vprintfmt+0x7a>
  80085d:	e9 73 ff ff ff       	jmp    8007d5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800862:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800865:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80086c:	eb 80                	jmp    8007ee <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80086e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800872:	0f 89 76 ff ff ff    	jns    8007ee <vprintfmt+0x7a>
  800878:	e9 64 ff ff ff       	jmp    8007e1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80087d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800880:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800883:	e9 66 ff ff ff       	jmp    8007ee <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8d 50 04             	lea    0x4(%eax),%edx
  80088e:	89 55 14             	mov    %edx,0x14(%ebp)
  800891:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800895:	8b 00                	mov    (%eax),%eax
  800897:	89 04 24             	mov    %eax,(%esp)
  80089a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008a0:	e9 f2 fe ff ff       	jmp    800797 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8d 50 04             	lea    0x4(%eax),%edx
  8008ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ae:	8b 00                	mov    (%eax),%eax
  8008b0:	89 c2                	mov    %eax,%edx
  8008b2:	c1 fa 1f             	sar    $0x1f,%edx
  8008b5:	31 d0                	xor    %edx,%eax
  8008b7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8008b9:	83 f8 08             	cmp    $0x8,%eax
  8008bc:	7f 0b                	jg     8008c9 <vprintfmt+0x155>
  8008be:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  8008c5:	85 d2                	test   %edx,%edx
  8008c7:	75 23                	jne    8008ec <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008cd:	c7 44 24 08 dd 12 80 	movl   $0x8012dd,0x8(%esp)
  8008d4:	00 
  8008d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008dc:	89 3c 24             	mov    %edi,(%esp)
  8008df:	e8 68 fe ff ff       	call   80074c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008e7:	e9 ab fe ff ff       	jmp    800797 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008f0:	c7 44 24 08 e6 12 80 	movl   $0x8012e6,0x8(%esp)
  8008f7:	00 
  8008f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ff:	89 3c 24             	mov    %edi,(%esp)
  800902:	e8 45 fe ff ff       	call   80074c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800907:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80090a:	e9 88 fe ff ff       	jmp    800797 <vprintfmt+0x23>
  80090f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800912:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800915:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800918:	8b 45 14             	mov    0x14(%ebp),%eax
  80091b:	8d 50 04             	lea    0x4(%eax),%edx
  80091e:	89 55 14             	mov    %edx,0x14(%ebp)
  800921:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800923:	85 f6                	test   %esi,%esi
  800925:	ba d6 12 80 00       	mov    $0x8012d6,%edx
  80092a:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  80092d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800931:	7e 06                	jle    800939 <vprintfmt+0x1c5>
  800933:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800937:	75 10                	jne    800949 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800939:	0f be 06             	movsbl (%esi),%eax
  80093c:	83 c6 01             	add    $0x1,%esi
  80093f:	85 c0                	test   %eax,%eax
  800941:	0f 85 86 00 00 00    	jne    8009cd <vprintfmt+0x259>
  800947:	eb 76                	jmp    8009bf <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800949:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80094d:	89 34 24             	mov    %esi,(%esp)
  800950:	e8 76 02 00 00       	call   800bcb <strnlen>
  800955:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800958:	29 c2                	sub    %eax,%edx
  80095a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80095d:	85 d2                	test   %edx,%edx
  80095f:	7e d8                	jle    800939 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800961:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800965:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800968:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80096b:	89 d6                	mov    %edx,%esi
  80096d:	89 c7                	mov    %eax,%edi
  80096f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800973:	89 3c 24             	mov    %edi,(%esp)
  800976:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800979:	83 ee 01             	sub    $0x1,%esi
  80097c:	75 f1                	jne    80096f <vprintfmt+0x1fb>
  80097e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800981:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800984:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800987:	eb b0                	jmp    800939 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800989:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80098d:	74 18                	je     8009a7 <vprintfmt+0x233>
  80098f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800992:	83 fa 5e             	cmp    $0x5e,%edx
  800995:	76 10                	jbe    8009a7 <vprintfmt+0x233>
					putch('?', putdat);
  800997:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009a2:	ff 55 08             	call   *0x8(%ebp)
  8009a5:	eb 0a                	jmp    8009b1 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  8009a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ab:	89 04 24             	mov    %eax,(%esp)
  8009ae:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b5:	0f be 06             	movsbl (%esi),%eax
  8009b8:	83 c6 01             	add    $0x1,%esi
  8009bb:	85 c0                	test   %eax,%eax
  8009bd:	75 0e                	jne    8009cd <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009c6:	7f 11                	jg     8009d9 <vprintfmt+0x265>
  8009c8:	e9 ca fd ff ff       	jmp    800797 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009cd:	85 ff                	test   %edi,%edi
  8009cf:	90                   	nop
  8009d0:	78 b7                	js     800989 <vprintfmt+0x215>
  8009d2:	83 ef 01             	sub    $0x1,%edi
  8009d5:	79 b2                	jns    800989 <vprintfmt+0x215>
  8009d7:	eb e6                	jmp    8009bf <vprintfmt+0x24b>
  8009d9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8009dc:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009ea:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ec:	83 ee 01             	sub    $0x1,%esi
  8009ef:	75 ee                	jne    8009df <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009f4:	e9 9e fd ff ff       	jmp    800797 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009f9:	89 ca                	mov    %ecx,%edx
  8009fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fe:	e8 f2 fc ff ff       	call   8006f5 <getint>
  800a03:	89 c6                	mov    %eax,%esi
  800a05:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a07:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a0c:	85 d2                	test   %edx,%edx
  800a0e:	0f 89 ad 00 00 00    	jns    800ac1 <vprintfmt+0x34d>
				putch('-', putdat);
  800a14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a18:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a1f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a22:	f7 de                	neg    %esi
  800a24:	83 d7 00             	adc    $0x0,%edi
  800a27:	f7 df                	neg    %edi
			}
			base = 10;
  800a29:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a2e:	e9 8e 00 00 00       	jmp    800ac1 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a33:	89 ca                	mov    %ecx,%edx
  800a35:	8d 45 14             	lea    0x14(%ebp),%eax
  800a38:	e8 7e fc ff ff       	call   8006bb <getuint>
  800a3d:	89 c6                	mov    %eax,%esi
  800a3f:	89 d7                	mov    %edx,%edi
			base = 10;
  800a41:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a46:	eb 79                	jmp    800ac1 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800a48:	89 ca                	mov    %ecx,%edx
  800a4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4d:	e8 a3 fc ff ff       	call   8006f5 <getint>
  800a52:	89 c6                	mov    %eax,%esi
  800a54:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800a56:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a5b:	85 d2                	test   %edx,%edx
  800a5d:	79 62                	jns    800ac1 <vprintfmt+0x34d>
				putch('-', putdat);
  800a5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a63:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a6a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a6d:	f7 de                	neg    %esi
  800a6f:	83 d7 00             	adc    $0x0,%edi
  800a72:	f7 df                	neg    %edi
			}
			base = 8;
  800a74:	b8 08 00 00 00       	mov    $0x8,%eax
  800a79:	eb 46                	jmp    800ac1 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800a7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a7f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a86:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a8d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a94:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a97:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9a:	8d 50 04             	lea    0x4(%eax),%edx
  800a9d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800aa0:	8b 30                	mov    (%eax),%esi
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800aa7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800aac:	eb 13                	jmp    800ac1 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aae:	89 ca                	mov    %ecx,%edx
  800ab0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab3:	e8 03 fc ff ff       	call   8006bb <getuint>
  800ab8:	89 c6                	mov    %eax,%esi
  800aba:	89 d7                	mov    %edx,%edi
			base = 16;
  800abc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800ac5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ac9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800acc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ad0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad4:	89 34 24             	mov    %esi,(%esp)
  800ad7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800adb:	89 da                	mov    %ebx,%edx
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	e8 fb fa ff ff       	call   8005e0 <printnum>
			break;
  800ae5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ae8:	e9 aa fc ff ff       	jmp    800797 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af1:	89 14 24             	mov    %edx,(%esp)
  800af4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800afa:	e9 98 fc ff ff       	jmp    800797 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b03:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b0a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b0d:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b11:	0f 84 80 fc ff ff    	je     800797 <vprintfmt+0x23>
  800b17:	83 ee 01             	sub    $0x1,%esi
  800b1a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b1e:	75 f7                	jne    800b17 <vprintfmt+0x3a3>
  800b20:	e9 72 fc ff ff       	jmp    800797 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b25:	83 c4 4c             	add    $0x4c,%esp
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	83 ec 28             	sub    $0x28,%esp
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b3c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b40:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	74 30                	je     800b7e <vsnprintf+0x51>
  800b4e:	85 d2                	test   %edx,%edx
  800b50:	7e 2c                	jle    800b7e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b52:	8b 45 14             	mov    0x14(%ebp),%eax
  800b55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b59:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b60:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b67:	c7 04 24 2f 07 80 00 	movl   $0x80072f,(%esp)
  800b6e:	e8 01 fc ff ff       	call   800774 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b73:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b76:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b7c:	eb 05                	jmp    800b83 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b8b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b92:	8b 45 10             	mov    0x10(%ebp),%eax
  800b95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	89 04 24             	mov    %eax,(%esp)
  800ba6:	e8 82 ff ff ff       	call   800b2d <vsnprintf>
	va_end(ap);

	return rc;
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    
  800bad:	00 00                	add    %al,(%eax)
	...

00800bb0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	80 3a 00             	cmpb   $0x0,(%edx)
  800bbe:	74 09                	je     800bc9 <strlen+0x19>
		n++;
  800bc0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc7:	75 f7                	jne    800bc0 <strlen+0x10>
		n++;
	return n;
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bda:	85 c9                	test   %ecx,%ecx
  800bdc:	74 1a                	je     800bf8 <strnlen+0x2d>
  800bde:	80 3b 00             	cmpb   $0x0,(%ebx)
  800be1:	74 15                	je     800bf8 <strnlen+0x2d>
  800be3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800be8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bea:	39 ca                	cmp    %ecx,%edx
  800bec:	74 0a                	je     800bf8 <strnlen+0x2d>
  800bee:	83 c2 01             	add    $0x1,%edx
  800bf1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800bf6:	75 f0                	jne    800be8 <strnlen+0x1d>
		n++;
	return n;
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	53                   	push   %ebx
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c0e:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c11:	83 c2 01             	add    $0x1,%edx
  800c14:	84 c9                	test   %cl,%cl
  800c16:	75 f2                	jne    800c0a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c18:	5b                   	pop    %ebx
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
  800c23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c26:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c29:	85 f6                	test   %esi,%esi
  800c2b:	74 18                	je     800c45 <strncpy+0x2a>
  800c2d:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c32:	0f b6 1a             	movzbl (%edx),%ebx
  800c35:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c38:	80 3a 01             	cmpb   $0x1,(%edx)
  800c3b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c3e:	83 c1 01             	add    $0x1,%ecx
  800c41:	39 f1                	cmp    %esi,%ecx
  800c43:	75 ed                	jne    800c32 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c55:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c58:	89 f8                	mov    %edi,%eax
  800c5a:	85 f6                	test   %esi,%esi
  800c5c:	74 2b                	je     800c89 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800c5e:	83 fe 01             	cmp    $0x1,%esi
  800c61:	74 23                	je     800c86 <strlcpy+0x3d>
  800c63:	0f b6 0b             	movzbl (%ebx),%ecx
  800c66:	84 c9                	test   %cl,%cl
  800c68:	74 1c                	je     800c86 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c6a:	83 ee 02             	sub    $0x2,%esi
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c72:	88 08                	mov    %cl,(%eax)
  800c74:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c77:	39 f2                	cmp    %esi,%edx
  800c79:	74 0b                	je     800c86 <strlcpy+0x3d>
  800c7b:	83 c2 01             	add    $0x1,%edx
  800c7e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c82:	84 c9                	test   %cl,%cl
  800c84:	75 ec                	jne    800c72 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c86:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c89:	29 f8                	sub    %edi,%eax
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c99:	0f b6 01             	movzbl (%ecx),%eax
  800c9c:	84 c0                	test   %al,%al
  800c9e:	74 16                	je     800cb6 <strcmp+0x26>
  800ca0:	3a 02                	cmp    (%edx),%al
  800ca2:	75 12                	jne    800cb6 <strcmp+0x26>
		p++, q++;
  800ca4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ca7:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800cab:	84 c0                	test   %al,%al
  800cad:	74 07                	je     800cb6 <strcmp+0x26>
  800caf:	83 c1 01             	add    $0x1,%ecx
  800cb2:	3a 02                	cmp    (%edx),%al
  800cb4:	74 ee                	je     800ca4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb6:	0f b6 c0             	movzbl %al,%eax
  800cb9:	0f b6 12             	movzbl (%edx),%edx
  800cbc:	29 d0                	sub    %edx,%eax
}
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	53                   	push   %ebx
  800cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cca:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cd2:	85 d2                	test   %edx,%edx
  800cd4:	74 28                	je     800cfe <strncmp+0x3e>
  800cd6:	0f b6 01             	movzbl (%ecx),%eax
  800cd9:	84 c0                	test   %al,%al
  800cdb:	74 24                	je     800d01 <strncmp+0x41>
  800cdd:	3a 03                	cmp    (%ebx),%al
  800cdf:	75 20                	jne    800d01 <strncmp+0x41>
  800ce1:	83 ea 01             	sub    $0x1,%edx
  800ce4:	74 13                	je     800cf9 <strncmp+0x39>
		n--, p++, q++;
  800ce6:	83 c1 01             	add    $0x1,%ecx
  800ce9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cec:	0f b6 01             	movzbl (%ecx),%eax
  800cef:	84 c0                	test   %al,%al
  800cf1:	74 0e                	je     800d01 <strncmp+0x41>
  800cf3:	3a 03                	cmp    (%ebx),%al
  800cf5:	74 ea                	je     800ce1 <strncmp+0x21>
  800cf7:	eb 08                	jmp    800d01 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cf9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cfe:	5b                   	pop    %ebx
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d01:	0f b6 01             	movzbl (%ecx),%eax
  800d04:	0f b6 13             	movzbl (%ebx),%edx
  800d07:	29 d0                	sub    %edx,%eax
  800d09:	eb f3                	jmp    800cfe <strncmp+0x3e>

00800d0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d15:	0f b6 10             	movzbl (%eax),%edx
  800d18:	84 d2                	test   %dl,%dl
  800d1a:	74 1c                	je     800d38 <strchr+0x2d>
		if (*s == c)
  800d1c:	38 ca                	cmp    %cl,%dl
  800d1e:	75 09                	jne    800d29 <strchr+0x1e>
  800d20:	eb 1b                	jmp    800d3d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d22:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800d25:	38 ca                	cmp    %cl,%dl
  800d27:	74 14                	je     800d3d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d29:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800d2d:	84 d2                	test   %dl,%dl
  800d2f:	75 f1                	jne    800d22 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
  800d36:	eb 05                	jmp    800d3d <strchr+0x32>
  800d38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d49:	0f b6 10             	movzbl (%eax),%edx
  800d4c:	84 d2                	test   %dl,%dl
  800d4e:	74 14                	je     800d64 <strfind+0x25>
		if (*s == c)
  800d50:	38 ca                	cmp    %cl,%dl
  800d52:	75 06                	jne    800d5a <strfind+0x1b>
  800d54:	eb 0e                	jmp    800d64 <strfind+0x25>
  800d56:	38 ca                	cmp    %cl,%dl
  800d58:	74 0a                	je     800d64 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d5a:	83 c0 01             	add    $0x1,%eax
  800d5d:	0f b6 10             	movzbl (%eax),%edx
  800d60:	84 d2                	test   %dl,%dl
  800d62:	75 f2                	jne    800d56 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	53                   	push   %ebx
  800d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d73:	89 da                	mov    %ebx,%edx
  800d75:	83 ea 01             	sub    $0x1,%edx
  800d78:	78 0d                	js     800d87 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800d7a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800d7c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800d7e:	88 0a                	mov    %cl,(%edx)
  800d80:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d83:	39 da                	cmp    %ebx,%edx
  800d85:	75 f7                	jne    800d7e <memset+0x18>
		*p++ = c;

	return v;
}
  800d87:	5b                   	pop    %ebx
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d99:	39 c6                	cmp    %eax,%esi
  800d9b:	72 0b                	jb     800da8 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800da2:	85 db                	test   %ebx,%ebx
  800da4:	75 29                	jne    800dcf <memmove+0x45>
  800da6:	eb 35                	jmp    800ddd <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800da8:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800dab:	39 c8                	cmp    %ecx,%eax
  800dad:	73 ee                	jae    800d9d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800daf:	85 db                	test   %ebx,%ebx
  800db1:	74 2a                	je     800ddd <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800db3:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800db6:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800db8:	f7 db                	neg    %ebx
  800dba:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800dbd:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800dbf:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800dc4:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800dc8:	83 ea 01             	sub    $0x1,%edx
  800dcb:	75 f2                	jne    800dbf <memmove+0x35>
  800dcd:	eb 0e                	jmp    800ddd <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800dcf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800dd3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800dd6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800dd9:	39 d3                	cmp    %edx,%ebx
  800ddb:	75 f2                	jne    800dcf <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800de8:	8b 45 10             	mov    0x10(%ebp),%eax
  800deb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800def:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	89 04 24             	mov    %eax,(%esp)
  800dfc:	e8 89 ff ff ff       	call   800d8a <memmove>
}
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e0f:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e12:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e17:	85 ff                	test   %edi,%edi
  800e19:	74 37                	je     800e52 <memcmp+0x4f>
		if (*s1 != *s2)
  800e1b:	0f b6 03             	movzbl (%ebx),%eax
  800e1e:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e21:	83 ef 01             	sub    $0x1,%edi
  800e24:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800e29:	38 c8                	cmp    %cl,%al
  800e2b:	74 1c                	je     800e49 <memcmp+0x46>
  800e2d:	eb 10                	jmp    800e3f <memcmp+0x3c>
  800e2f:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e34:	83 c2 01             	add    $0x1,%edx
  800e37:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e3b:	38 c8                	cmp    %cl,%al
  800e3d:	74 0a                	je     800e49 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e3f:	0f b6 c0             	movzbl %al,%eax
  800e42:	0f b6 c9             	movzbl %cl,%ecx
  800e45:	29 c8                	sub    %ecx,%eax
  800e47:	eb 09                	jmp    800e52 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e49:	39 fa                	cmp    %edi,%edx
  800e4b:	75 e2                	jne    800e2f <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e5d:	89 c2                	mov    %eax,%edx
  800e5f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e62:	39 d0                	cmp    %edx,%eax
  800e64:	73 15                	jae    800e7b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e66:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e6a:	38 08                	cmp    %cl,(%eax)
  800e6c:	75 06                	jne    800e74 <memfind+0x1d>
  800e6e:	eb 0b                	jmp    800e7b <memfind+0x24>
  800e70:	38 08                	cmp    %cl,(%eax)
  800e72:	74 07                	je     800e7b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e74:	83 c0 01             	add    $0x1,%eax
  800e77:	39 d0                	cmp    %edx,%eax
  800e79:	75 f5                	jne    800e70 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	8b 55 08             	mov    0x8(%ebp),%edx
  800e86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e89:	0f b6 02             	movzbl (%edx),%eax
  800e8c:	3c 20                	cmp    $0x20,%al
  800e8e:	74 04                	je     800e94 <strtol+0x17>
  800e90:	3c 09                	cmp    $0x9,%al
  800e92:	75 0e                	jne    800ea2 <strtol+0x25>
		s++;
  800e94:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e97:	0f b6 02             	movzbl (%edx),%eax
  800e9a:	3c 20                	cmp    $0x20,%al
  800e9c:	74 f6                	je     800e94 <strtol+0x17>
  800e9e:	3c 09                	cmp    $0x9,%al
  800ea0:	74 f2                	je     800e94 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ea2:	3c 2b                	cmp    $0x2b,%al
  800ea4:	75 0a                	jne    800eb0 <strtol+0x33>
		s++;
  800ea6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ea9:	bf 00 00 00 00       	mov    $0x0,%edi
  800eae:	eb 10                	jmp    800ec0 <strtol+0x43>
  800eb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800eb5:	3c 2d                	cmp    $0x2d,%al
  800eb7:	75 07                	jne    800ec0 <strtol+0x43>
		s++, neg = 1;
  800eb9:	83 c2 01             	add    $0x1,%edx
  800ebc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ec0:	85 db                	test   %ebx,%ebx
  800ec2:	0f 94 c0             	sete   %al
  800ec5:	74 05                	je     800ecc <strtol+0x4f>
  800ec7:	83 fb 10             	cmp    $0x10,%ebx
  800eca:	75 15                	jne    800ee1 <strtol+0x64>
  800ecc:	80 3a 30             	cmpb   $0x30,(%edx)
  800ecf:	75 10                	jne    800ee1 <strtol+0x64>
  800ed1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ed5:	75 0a                	jne    800ee1 <strtol+0x64>
		s += 2, base = 16;
  800ed7:	83 c2 02             	add    $0x2,%edx
  800eda:	bb 10 00 00 00       	mov    $0x10,%ebx
  800edf:	eb 13                	jmp    800ef4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ee1:	84 c0                	test   %al,%al
  800ee3:	74 0f                	je     800ef4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ee5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eea:	80 3a 30             	cmpb   $0x30,(%edx)
  800eed:	75 05                	jne    800ef4 <strtol+0x77>
		s++, base = 8;
  800eef:	83 c2 01             	add    $0x1,%edx
  800ef2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800efb:	0f b6 0a             	movzbl (%edx),%ecx
  800efe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f01:	80 fb 09             	cmp    $0x9,%bl
  800f04:	77 08                	ja     800f0e <strtol+0x91>
			dig = *s - '0';
  800f06:	0f be c9             	movsbl %cl,%ecx
  800f09:	83 e9 30             	sub    $0x30,%ecx
  800f0c:	eb 1e                	jmp    800f2c <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800f0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f11:	80 fb 19             	cmp    $0x19,%bl
  800f14:	77 08                	ja     800f1e <strtol+0xa1>
			dig = *s - 'a' + 10;
  800f16:	0f be c9             	movsbl %cl,%ecx
  800f19:	83 e9 57             	sub    $0x57,%ecx
  800f1c:	eb 0e                	jmp    800f2c <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800f1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f21:	80 fb 19             	cmp    $0x19,%bl
  800f24:	77 14                	ja     800f3a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f26:	0f be c9             	movsbl %cl,%ecx
  800f29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f2c:	39 f1                	cmp    %esi,%ecx
  800f2e:	7d 0e                	jge    800f3e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f30:	83 c2 01             	add    $0x1,%edx
  800f33:	0f af c6             	imul   %esi,%eax
  800f36:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f38:	eb c1                	jmp    800efb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f3a:	89 c1                	mov    %eax,%ecx
  800f3c:	eb 02                	jmp    800f40 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f3e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f44:	74 05                	je     800f4b <strtol+0xce>
		*endptr = (char *) s;
  800f46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f49:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f4b:	89 ca                	mov    %ecx,%edx
  800f4d:	f7 da                	neg    %edx
  800f4f:	85 ff                	test   %edi,%edi
  800f51:	0f 45 c2             	cmovne %edx,%eax
}
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
  800f59:	00 00                	add    %al,(%eax)
	...

00800f5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f62:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800f69:	75 1c                	jne    800f87 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800f6b:	c7 44 24 08 04 15 80 	movl   $0x801504,0x8(%esp)
  800f72:	00 
  800f73:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f7a:	00 
  800f7b:	c7 04 24 28 15 80 00 	movl   $0x801528,(%esp)
  800f82:	e8 29 f5 ff ff       	call   8004b0 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    
	...

00800fa0 <__udivdi3>:
  800fa0:	83 ec 1c             	sub    $0x1c,%esp
  800fa3:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800fa7:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800fab:	8b 44 24 20          	mov    0x20(%esp),%eax
  800faf:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800fb3:	89 74 24 10          	mov    %esi,0x10(%esp)
  800fb7:	8b 74 24 24          	mov    0x24(%esp),%esi
  800fbb:	85 ff                	test   %edi,%edi
  800fbd:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800fc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc5:	89 cd                	mov    %ecx,%ebp
  800fc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fcb:	75 33                	jne    801000 <__udivdi3+0x60>
  800fcd:	39 f1                	cmp    %esi,%ecx
  800fcf:	77 57                	ja     801028 <__udivdi3+0x88>
  800fd1:	85 c9                	test   %ecx,%ecx
  800fd3:	75 0b                	jne    800fe0 <__udivdi3+0x40>
  800fd5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fda:	31 d2                	xor    %edx,%edx
  800fdc:	f7 f1                	div    %ecx
  800fde:	89 c1                	mov    %eax,%ecx
  800fe0:	89 f0                	mov    %esi,%eax
  800fe2:	31 d2                	xor    %edx,%edx
  800fe4:	f7 f1                	div    %ecx
  800fe6:	89 c6                	mov    %eax,%esi
  800fe8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fec:	f7 f1                	div    %ecx
  800fee:	89 f2                	mov    %esi,%edx
  800ff0:	8b 74 24 10          	mov    0x10(%esp),%esi
  800ff4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800ff8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800ffc:	83 c4 1c             	add    $0x1c,%esp
  800fff:	c3                   	ret    
  801000:	31 d2                	xor    %edx,%edx
  801002:	31 c0                	xor    %eax,%eax
  801004:	39 f7                	cmp    %esi,%edi
  801006:	77 e8                	ja     800ff0 <__udivdi3+0x50>
  801008:	0f bd cf             	bsr    %edi,%ecx
  80100b:	83 f1 1f             	xor    $0x1f,%ecx
  80100e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801012:	75 2c                	jne    801040 <__udivdi3+0xa0>
  801014:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801018:	76 04                	jbe    80101e <__udivdi3+0x7e>
  80101a:	39 f7                	cmp    %esi,%edi
  80101c:	73 d2                	jae    800ff0 <__udivdi3+0x50>
  80101e:	31 d2                	xor    %edx,%edx
  801020:	b8 01 00 00 00       	mov    $0x1,%eax
  801025:	eb c9                	jmp    800ff0 <__udivdi3+0x50>
  801027:	90                   	nop
  801028:	89 f2                	mov    %esi,%edx
  80102a:	f7 f1                	div    %ecx
  80102c:	31 d2                	xor    %edx,%edx
  80102e:	8b 74 24 10          	mov    0x10(%esp),%esi
  801032:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801036:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80103a:	83 c4 1c             	add    $0x1c,%esp
  80103d:	c3                   	ret    
  80103e:	66 90                	xchg   %ax,%ax
  801040:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801045:	b8 20 00 00 00       	mov    $0x20,%eax
  80104a:	89 ea                	mov    %ebp,%edx
  80104c:	2b 44 24 04          	sub    0x4(%esp),%eax
  801050:	d3 e7                	shl    %cl,%edi
  801052:	89 c1                	mov    %eax,%ecx
  801054:	d3 ea                	shr    %cl,%edx
  801056:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80105b:	09 fa                	or     %edi,%edx
  80105d:	89 f7                	mov    %esi,%edi
  80105f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801063:	89 f2                	mov    %esi,%edx
  801065:	8b 74 24 08          	mov    0x8(%esp),%esi
  801069:	d3 e5                	shl    %cl,%ebp
  80106b:	89 c1                	mov    %eax,%ecx
  80106d:	d3 ef                	shr    %cl,%edi
  80106f:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801074:	d3 e2                	shl    %cl,%edx
  801076:	89 c1                	mov    %eax,%ecx
  801078:	d3 ee                	shr    %cl,%esi
  80107a:	09 d6                	or     %edx,%esi
  80107c:	89 fa                	mov    %edi,%edx
  80107e:	89 f0                	mov    %esi,%eax
  801080:	f7 74 24 0c          	divl   0xc(%esp)
  801084:	89 d7                	mov    %edx,%edi
  801086:	89 c6                	mov    %eax,%esi
  801088:	f7 e5                	mul    %ebp
  80108a:	39 d7                	cmp    %edx,%edi
  80108c:	72 22                	jb     8010b0 <__udivdi3+0x110>
  80108e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801092:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801097:	d3 e5                	shl    %cl,%ebp
  801099:	39 c5                	cmp    %eax,%ebp
  80109b:	73 04                	jae    8010a1 <__udivdi3+0x101>
  80109d:	39 d7                	cmp    %edx,%edi
  80109f:	74 0f                	je     8010b0 <__udivdi3+0x110>
  8010a1:	89 f0                	mov    %esi,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	e9 46 ff ff ff       	jmp    800ff0 <__udivdi3+0x50>
  8010aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b0:	8d 46 ff             	lea    -0x1(%esi),%eax
  8010b3:	31 d2                	xor    %edx,%edx
  8010b5:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010b9:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010bd:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010c1:	83 c4 1c             	add    $0x1c,%esp
  8010c4:	c3                   	ret    
	...

008010d0 <__umoddi3>:
  8010d0:	83 ec 1c             	sub    $0x1c,%esp
  8010d3:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  8010d7:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  8010db:	8b 44 24 20          	mov    0x20(%esp),%eax
  8010df:	89 74 24 10          	mov    %esi,0x10(%esp)
  8010e3:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8010e7:	8b 74 24 24          	mov    0x24(%esp),%esi
  8010eb:	85 ed                	test   %ebp,%ebp
  8010ed:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8010f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f5:	89 cf                	mov    %ecx,%edi
  8010f7:	89 04 24             	mov    %eax,(%esp)
  8010fa:	89 f2                	mov    %esi,%edx
  8010fc:	75 1a                	jne    801118 <__umoddi3+0x48>
  8010fe:	39 f1                	cmp    %esi,%ecx
  801100:	76 4e                	jbe    801150 <__umoddi3+0x80>
  801102:	f7 f1                	div    %ecx
  801104:	89 d0                	mov    %edx,%eax
  801106:	31 d2                	xor    %edx,%edx
  801108:	8b 74 24 10          	mov    0x10(%esp),%esi
  80110c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801110:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801114:	83 c4 1c             	add    $0x1c,%esp
  801117:	c3                   	ret    
  801118:	39 f5                	cmp    %esi,%ebp
  80111a:	77 54                	ja     801170 <__umoddi3+0xa0>
  80111c:	0f bd c5             	bsr    %ebp,%eax
  80111f:	83 f0 1f             	xor    $0x1f,%eax
  801122:	89 44 24 04          	mov    %eax,0x4(%esp)
  801126:	75 60                	jne    801188 <__umoddi3+0xb8>
  801128:	3b 0c 24             	cmp    (%esp),%ecx
  80112b:	0f 87 07 01 00 00    	ja     801238 <__umoddi3+0x168>
  801131:	89 f2                	mov    %esi,%edx
  801133:	8b 34 24             	mov    (%esp),%esi
  801136:	29 ce                	sub    %ecx,%esi
  801138:	19 ea                	sbb    %ebp,%edx
  80113a:	89 34 24             	mov    %esi,(%esp)
  80113d:	8b 04 24             	mov    (%esp),%eax
  801140:	8b 74 24 10          	mov    0x10(%esp),%esi
  801144:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801148:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80114c:	83 c4 1c             	add    $0x1c,%esp
  80114f:	c3                   	ret    
  801150:	85 c9                	test   %ecx,%ecx
  801152:	75 0b                	jne    80115f <__umoddi3+0x8f>
  801154:	b8 01 00 00 00       	mov    $0x1,%eax
  801159:	31 d2                	xor    %edx,%edx
  80115b:	f7 f1                	div    %ecx
  80115d:	89 c1                	mov    %eax,%ecx
  80115f:	89 f0                	mov    %esi,%eax
  801161:	31 d2                	xor    %edx,%edx
  801163:	f7 f1                	div    %ecx
  801165:	8b 04 24             	mov    (%esp),%eax
  801168:	f7 f1                	div    %ecx
  80116a:	eb 98                	jmp    801104 <__umoddi3+0x34>
  80116c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801170:	89 f2                	mov    %esi,%edx
  801172:	8b 74 24 10          	mov    0x10(%esp),%esi
  801176:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80117a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80117e:	83 c4 1c             	add    $0x1c,%esp
  801181:	c3                   	ret    
  801182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801188:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80118d:	89 e8                	mov    %ebp,%eax
  80118f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801194:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801198:	89 fa                	mov    %edi,%edx
  80119a:	d3 e0                	shl    %cl,%eax
  80119c:	89 e9                	mov    %ebp,%ecx
  80119e:	d3 ea                	shr    %cl,%edx
  8011a0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011a5:	09 c2                	or     %eax,%edx
  8011a7:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011ab:	89 14 24             	mov    %edx,(%esp)
  8011ae:	89 f2                	mov    %esi,%edx
  8011b0:	d3 e7                	shl    %cl,%edi
  8011b2:	89 e9                	mov    %ebp,%ecx
  8011b4:	d3 ea                	shr    %cl,%edx
  8011b6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011bf:	d3 e6                	shl    %cl,%esi
  8011c1:	89 e9                	mov    %ebp,%ecx
  8011c3:	d3 e8                	shr    %cl,%eax
  8011c5:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011ca:	09 f0                	or     %esi,%eax
  8011cc:	8b 74 24 08          	mov    0x8(%esp),%esi
  8011d0:	f7 34 24             	divl   (%esp)
  8011d3:	d3 e6                	shl    %cl,%esi
  8011d5:	89 74 24 08          	mov    %esi,0x8(%esp)
  8011d9:	89 d6                	mov    %edx,%esi
  8011db:	f7 e7                	mul    %edi
  8011dd:	39 d6                	cmp    %edx,%esi
  8011df:	89 c1                	mov    %eax,%ecx
  8011e1:	89 d7                	mov    %edx,%edi
  8011e3:	72 3f                	jb     801224 <__umoddi3+0x154>
  8011e5:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8011e9:	72 35                	jb     801220 <__umoddi3+0x150>
  8011eb:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011ef:	29 c8                	sub    %ecx,%eax
  8011f1:	19 fe                	sbb    %edi,%esi
  8011f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011f8:	89 f2                	mov    %esi,%edx
  8011fa:	d3 e8                	shr    %cl,%eax
  8011fc:	89 e9                	mov    %ebp,%ecx
  8011fe:	d3 e2                	shl    %cl,%edx
  801200:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801205:	09 d0                	or     %edx,%eax
  801207:	89 f2                	mov    %esi,%edx
  801209:	d3 ea                	shr    %cl,%edx
  80120b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80120f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801213:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801217:	83 c4 1c             	add    $0x1c,%esp
  80121a:	c3                   	ret    
  80121b:	90                   	nop
  80121c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801220:	39 d6                	cmp    %edx,%esi
  801222:	75 c7                	jne    8011eb <__umoddi3+0x11b>
  801224:	89 d7                	mov    %edx,%edi
  801226:	89 c1                	mov    %eax,%ecx
  801228:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80122c:	1b 3c 24             	sbb    (%esp),%edi
  80122f:	eb ba                	jmp    8011eb <__umoddi3+0x11b>
  801231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801238:	39 f5                	cmp    %esi,%ebp
  80123a:	0f 82 f1 fe ff ff    	jb     801131 <__umoddi3+0x61>
  801240:	e9 f8 fe ff ff       	jmp    80113d <__umoddi3+0x6d>
