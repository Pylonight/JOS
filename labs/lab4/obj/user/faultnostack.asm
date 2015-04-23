
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
  800153:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  80016a:	e8 59 03 00 00       	call   8004c8 <_panic>

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
  800212:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  800219:	00 
  80021a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800221:	00 
  800222:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  800229:	e8 9a 02 00 00       	call   8004c8 <_panic>

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
  800270:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  800277:	00 
  800278:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  800287:	e8 3c 02 00 00       	call   8004c8 <_panic>

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
  8002ce:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002dd:	00 
  8002de:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  8002e5:	e8 de 01 00 00       	call   8004c8 <_panic>

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
  80032c:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  800333:	00 
  800334:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  800343:	e8 80 01 00 00       	call   8004c8 <_panic>

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
  80038a:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  800391:	00 
  800392:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800399:	00 
  80039a:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  8003a1:	e8 22 01 00 00       	call   8004c8 <_panic>

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
  8003e8:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  8003ef:	00 
  8003f0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003f7:	00 
  8003f8:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  8003ff:	e8 c4 00 00 00       	call   8004c8 <_panic>

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
  800479:	c7 44 24 08 d7 12 80 	movl   $0x8012d7,0x8(%esp)
  800480:	00 
  800481:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800488:	00 
  800489:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  800490:	e8 33 00 00 00       	call   8004c8 <_panic>

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
	// it means that esp points to fault_va now, esp -> fault_va
	// eax, ecx, edx are saved-by-caller regs, use as wish
	// while edx, esi, edi are saved-by-called regs, save before using
	// and restore before leaving
	// our eip
	movl	40(%esp),	%eax
  8004af:	8b 44 24 28          	mov    0x28(%esp),%eax
	// esp, the trap-time stack to return to
	movl	48(%esp),	%ecx
  8004b3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
	// set rip to be out eip
	// there is only one op-num can be memory-accessing
	movl	%eax,	-4(%ecx)
  8004b7:	89 41 fc             	mov    %eax,-0x4(%ecx)

	// Restore the trap-time registers.
	// LAB 4: Your code here.
	// esp -> fault_va
	// skip fault_va and tf_err
	addl	$8,	%esp
  8004ba:	83 c4 08             	add    $0x8,%esp
	// esp -> trap-time edi
	popal
  8004bd:	61                   	popa   

	// Restore eflags from the stack.
	// LAB 4: Your code here.
	// esp -> trap-time eip
	addl	$4,	%esp
  8004be:	83 c4 04             	add    $0x4,%esp
	// esp -> trap-time eflags
	// popfl defined in "inc/x86.h"
	popfl
  8004c1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// esp -> trap-time esp
	// as requested
	popl	%esp
  8004c2:	5c                   	pop    %esp
	// esp -> the first argument
	subl	$4,	%esp
  8004c3:	83 ec 04             	sub    $0x4,%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// esp -> rip
	// ret will jump to rip, but esp must point to rip
  8004c6:	c3                   	ret    
	...

008004c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  8004ce:	a1 08 20 80 00       	mov    0x802008,%eax
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	74 10                	je     8004e7 <_panic+0x1f>
		cprintf("%s: ", argv0);
  8004d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004db:	c7 04 24 02 13 80 00 	movl   $0x801302,(%esp)
  8004e2:	e8 e8 00 00 00       	call   8005cf <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8004e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f5:	a1 00 20 80 00       	mov    0x802000,%eax
  8004fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fe:	c7 04 24 07 13 80 00 	movl   $0x801307,(%esp)
  800505:	e8 c5 00 00 00       	call   8005cf <cprintf>
	vcprintf(fmt, ap);
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	8b 45 10             	mov    0x10(%ebp),%eax
  800514:	89 04 24             	mov    %eax,(%esp)
  800517:	e8 52 00 00 00       	call   80056e <vcprintf>
	cprintf("\n");
  80051c:	c7 04 24 23 13 80 00 	movl   $0x801323,(%esp)
  800523:	e8 a7 00 00 00       	call   8005cf <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800528:	cc                   	int3   
  800529:	eb fd                	jmp    800528 <_panic+0x60>
	...

0080052c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	53                   	push   %ebx
  800530:	83 ec 14             	sub    $0x14,%esp
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800536:	8b 03                	mov    (%ebx),%eax
  800538:	8b 55 08             	mov    0x8(%ebp),%edx
  80053b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80053f:	83 c0 01             	add    $0x1,%eax
  800542:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800544:	3d ff 00 00 00       	cmp    $0xff,%eax
  800549:	75 19                	jne    800564 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80054b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800552:	00 
  800553:	8d 43 08             	lea    0x8(%ebx),%eax
  800556:	89 04 24             	mov    %eax,(%esp)
  800559:	e8 62 fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  80055e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800564:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800568:	83 c4 14             	add    $0x14,%esp
  80056b:	5b                   	pop    %ebx
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800577:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80057e:	00 00 00 
	b.cnt = 0;
  800581:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800588:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80058b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800592:	8b 45 08             	mov    0x8(%ebp),%eax
  800595:	89 44 24 08          	mov    %eax,0x8(%esp)
  800599:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a3:	c7 04 24 2c 05 80 00 	movl   $0x80052c,(%esp)
  8005aa:	e8 d5 01 00 00       	call   800784 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005af:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	e8 f9 fa ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  8005c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005cd:	c9                   	leave  
  8005ce:	c3                   	ret    

008005cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8005d5:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	e8 87 ff ff ff       	call   80056e <vcprintf>
	va_end(ap);

	return cnt;
}
  8005e7:	c9                   	leave  
  8005e8:	c3                   	ret    
  8005e9:	00 00                	add    %al,(%eax)
  8005eb:	00 00                	add    %al,(%eax)
  8005ed:	00 00                	add    %al,(%eax)
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
  80065a:	e8 b1 09 00 00       	call   801010 <__udivdi3>
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
  8006ad:	e8 8e 0a 00 00       	call   801140 <__umoddi3>
  8006b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b6:	0f be 80 25 13 80 00 	movsbl 0x801325(%eax),%eax
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
  800818:	ff 24 85 e0 13 80 00 	jmp    *0x8013e0(,%eax,4)
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
  8008ce:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	75 23                	jne    8008fc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008dd:	c7 44 24 08 3d 13 80 	movl   $0x80133d,0x8(%esp)
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
  800900:	c7 44 24 08 46 13 80 	movl   $0x801346,0x8(%esp)
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
  800935:	ba 36 13 80 00       	mov    $0x801336,%edx
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
	...

00800f6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 14             	sub    $0x14,%esp
	int r;

	// Set the page fault handler function.
	// If there isn't one yet, _pgfault_handler will be 0.
	if (_pgfault_handler == 0) {
  800f73:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800f7a:	75 77                	jne    800ff3 <set_pgfault_handler+0x87>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  800f7c:	e8 fb f1 ff ff       	call   80017c <sys_getenvid>
  800f81:	89 c3                	mov    %eax,%ebx
		// The first time we register a handler, we need to 
		// allocate an exception stack (one page of memory with its top
		// at UXSTACKTOP). [UXSTACKTOP-PGSIZE, UXSTACKTOP-1]
		// user can read, write
		if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE),
  800f83:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f92:	ee 
  800f93:	89 04 24             	mov    %eax,(%esp)
  800f96:	e8 41 f2 ff ff       	call   8001dc <sys_page_alloc>
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	79 20                	jns    800fbf <set_pgfault_handler+0x53>
			PTE_W | PTE_U | PTE_P)) < 0)
		{
			panic("set_pgfault_handler: %e", r);
  800f9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fa3:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800faa:	00 
  800fab:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fb2:	00 
  800fb3:	c7 04 24 7c 15 80 00 	movl   $0x80157c,(%esp)
  800fba:	e8 09 f5 ff ff       	call   8004c8 <_panic>
			return;
		}
		// tell the kernel to call the assembly-language
		// _pgfault_upcall routine when a page fault occurs.
		if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  800fbf:	c7 44 24 04 a4 04 80 	movl   $0x8004a4,0x4(%esp)
  800fc6:	00 
  800fc7:	89 1c 24             	mov    %ebx,(%esp)
  800fca:	e8 e4 f3 ff ff       	call   8003b3 <sys_env_set_pgfault_upcall>
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	79 20                	jns    800ff3 <set_pgfault_handler+0x87>
		{
			panic("set_pgfault_handler: %e", r);
  800fd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fd7:	c7 44 24 08 64 15 80 	movl   $0x801564,0x8(%esp)
  800fde:	00 
  800fdf:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800fe6:	00 
  800fe7:	c7 04 24 7c 15 80 00 	movl   $0x80157c,(%esp)
  800fee:	e8 d5 f4 ff ff       	call   8004c8 <_panic>

		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  800ffb:	83 c4 14             	add    $0x14,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    
	...

00801010 <__udivdi3>:
  801010:	83 ec 1c             	sub    $0x1c,%esp
  801013:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801017:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  80101b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80101f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801023:	89 74 24 10          	mov    %esi,0x10(%esp)
  801027:	8b 74 24 24          	mov    0x24(%esp),%esi
  80102b:	85 ff                	test   %edi,%edi
  80102d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801031:	89 44 24 08          	mov    %eax,0x8(%esp)
  801035:	89 cd                	mov    %ecx,%ebp
  801037:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103b:	75 33                	jne    801070 <__udivdi3+0x60>
  80103d:	39 f1                	cmp    %esi,%ecx
  80103f:	77 57                	ja     801098 <__udivdi3+0x88>
  801041:	85 c9                	test   %ecx,%ecx
  801043:	75 0b                	jne    801050 <__udivdi3+0x40>
  801045:	b8 01 00 00 00       	mov    $0x1,%eax
  80104a:	31 d2                	xor    %edx,%edx
  80104c:	f7 f1                	div    %ecx
  80104e:	89 c1                	mov    %eax,%ecx
  801050:	89 f0                	mov    %esi,%eax
  801052:	31 d2                	xor    %edx,%edx
  801054:	f7 f1                	div    %ecx
  801056:	89 c6                	mov    %eax,%esi
  801058:	8b 44 24 04          	mov    0x4(%esp),%eax
  80105c:	f7 f1                	div    %ecx
  80105e:	89 f2                	mov    %esi,%edx
  801060:	8b 74 24 10          	mov    0x10(%esp),%esi
  801064:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801068:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80106c:	83 c4 1c             	add    $0x1c,%esp
  80106f:	c3                   	ret    
  801070:	31 d2                	xor    %edx,%edx
  801072:	31 c0                	xor    %eax,%eax
  801074:	39 f7                	cmp    %esi,%edi
  801076:	77 e8                	ja     801060 <__udivdi3+0x50>
  801078:	0f bd cf             	bsr    %edi,%ecx
  80107b:	83 f1 1f             	xor    $0x1f,%ecx
  80107e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801082:	75 2c                	jne    8010b0 <__udivdi3+0xa0>
  801084:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  801088:	76 04                	jbe    80108e <__udivdi3+0x7e>
  80108a:	39 f7                	cmp    %esi,%edi
  80108c:	73 d2                	jae    801060 <__udivdi3+0x50>
  80108e:	31 d2                	xor    %edx,%edx
  801090:	b8 01 00 00 00       	mov    $0x1,%eax
  801095:	eb c9                	jmp    801060 <__udivdi3+0x50>
  801097:	90                   	nop
  801098:	89 f2                	mov    %esi,%edx
  80109a:	f7 f1                	div    %ecx
  80109c:	31 d2                	xor    %edx,%edx
  80109e:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010a2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010a6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010aa:	83 c4 1c             	add    $0x1c,%esp
  8010ad:	c3                   	ret    
  8010ae:	66 90                	xchg   %ax,%ax
  8010b0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010b5:	b8 20 00 00 00       	mov    $0x20,%eax
  8010ba:	89 ea                	mov    %ebp,%edx
  8010bc:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010c0:	d3 e7                	shl    %cl,%edi
  8010c2:	89 c1                	mov    %eax,%ecx
  8010c4:	d3 ea                	shr    %cl,%edx
  8010c6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010cb:	09 fa                	or     %edi,%edx
  8010cd:	89 f7                	mov    %esi,%edi
  8010cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010d3:	89 f2                	mov    %esi,%edx
  8010d5:	8b 74 24 08          	mov    0x8(%esp),%esi
  8010d9:	d3 e5                	shl    %cl,%ebp
  8010db:	89 c1                	mov    %eax,%ecx
  8010dd:	d3 ef                	shr    %cl,%edi
  8010df:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010e4:	d3 e2                	shl    %cl,%edx
  8010e6:	89 c1                	mov    %eax,%ecx
  8010e8:	d3 ee                	shr    %cl,%esi
  8010ea:	09 d6                	or     %edx,%esi
  8010ec:	89 fa                	mov    %edi,%edx
  8010ee:	89 f0                	mov    %esi,%eax
  8010f0:	f7 74 24 0c          	divl   0xc(%esp)
  8010f4:	89 d7                	mov    %edx,%edi
  8010f6:	89 c6                	mov    %eax,%esi
  8010f8:	f7 e5                	mul    %ebp
  8010fa:	39 d7                	cmp    %edx,%edi
  8010fc:	72 22                	jb     801120 <__udivdi3+0x110>
  8010fe:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801102:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801107:	d3 e5                	shl    %cl,%ebp
  801109:	39 c5                	cmp    %eax,%ebp
  80110b:	73 04                	jae    801111 <__udivdi3+0x101>
  80110d:	39 d7                	cmp    %edx,%edi
  80110f:	74 0f                	je     801120 <__udivdi3+0x110>
  801111:	89 f0                	mov    %esi,%eax
  801113:	31 d2                	xor    %edx,%edx
  801115:	e9 46 ff ff ff       	jmp    801060 <__udivdi3+0x50>
  80111a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801120:	8d 46 ff             	lea    -0x1(%esi),%eax
  801123:	31 d2                	xor    %edx,%edx
  801125:	8b 74 24 10          	mov    0x10(%esp),%esi
  801129:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80112d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801131:	83 c4 1c             	add    $0x1c,%esp
  801134:	c3                   	ret    
	...

00801140 <__umoddi3>:
  801140:	83 ec 1c             	sub    $0x1c,%esp
  801143:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801147:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80114b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80114f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801153:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801157:	8b 74 24 24          	mov    0x24(%esp),%esi
  80115b:	85 ed                	test   %ebp,%ebp
  80115d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801161:	89 44 24 08          	mov    %eax,0x8(%esp)
  801165:	89 cf                	mov    %ecx,%edi
  801167:	89 04 24             	mov    %eax,(%esp)
  80116a:	89 f2                	mov    %esi,%edx
  80116c:	75 1a                	jne    801188 <__umoddi3+0x48>
  80116e:	39 f1                	cmp    %esi,%ecx
  801170:	76 4e                	jbe    8011c0 <__umoddi3+0x80>
  801172:	f7 f1                	div    %ecx
  801174:	89 d0                	mov    %edx,%eax
  801176:	31 d2                	xor    %edx,%edx
  801178:	8b 74 24 10          	mov    0x10(%esp),%esi
  80117c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801180:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801184:	83 c4 1c             	add    $0x1c,%esp
  801187:	c3                   	ret    
  801188:	39 f5                	cmp    %esi,%ebp
  80118a:	77 54                	ja     8011e0 <__umoddi3+0xa0>
  80118c:	0f bd c5             	bsr    %ebp,%eax
  80118f:	83 f0 1f             	xor    $0x1f,%eax
  801192:	89 44 24 04          	mov    %eax,0x4(%esp)
  801196:	75 60                	jne    8011f8 <__umoddi3+0xb8>
  801198:	3b 0c 24             	cmp    (%esp),%ecx
  80119b:	0f 87 07 01 00 00    	ja     8012a8 <__umoddi3+0x168>
  8011a1:	89 f2                	mov    %esi,%edx
  8011a3:	8b 34 24             	mov    (%esp),%esi
  8011a6:	29 ce                	sub    %ecx,%esi
  8011a8:	19 ea                	sbb    %ebp,%edx
  8011aa:	89 34 24             	mov    %esi,(%esp)
  8011ad:	8b 04 24             	mov    (%esp),%eax
  8011b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011b4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011b8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011bc:	83 c4 1c             	add    $0x1c,%esp
  8011bf:	c3                   	ret    
  8011c0:	85 c9                	test   %ecx,%ecx
  8011c2:	75 0b                	jne    8011cf <__umoddi3+0x8f>
  8011c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c9:	31 d2                	xor    %edx,%edx
  8011cb:	f7 f1                	div    %ecx
  8011cd:	89 c1                	mov    %eax,%ecx
  8011cf:	89 f0                	mov    %esi,%eax
  8011d1:	31 d2                	xor    %edx,%edx
  8011d3:	f7 f1                	div    %ecx
  8011d5:	8b 04 24             	mov    (%esp),%eax
  8011d8:	f7 f1                	div    %ecx
  8011da:	eb 98                	jmp    801174 <__umoddi3+0x34>
  8011dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	89 f2                	mov    %esi,%edx
  8011e2:	8b 74 24 10          	mov    0x10(%esp),%esi
  8011e6:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011ea:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011ee:	83 c4 1c             	add    $0x1c,%esp
  8011f1:	c3                   	ret    
  8011f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011f8:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011fd:	89 e8                	mov    %ebp,%eax
  8011ff:	bd 20 00 00 00       	mov    $0x20,%ebp
  801204:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801208:	89 fa                	mov    %edi,%edx
  80120a:	d3 e0                	shl    %cl,%eax
  80120c:	89 e9                	mov    %ebp,%ecx
  80120e:	d3 ea                	shr    %cl,%edx
  801210:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801215:	09 c2                	or     %eax,%edx
  801217:	8b 44 24 08          	mov    0x8(%esp),%eax
  80121b:	89 14 24             	mov    %edx,(%esp)
  80121e:	89 f2                	mov    %esi,%edx
  801220:	d3 e7                	shl    %cl,%edi
  801222:	89 e9                	mov    %ebp,%ecx
  801224:	d3 ea                	shr    %cl,%edx
  801226:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80122b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122f:	d3 e6                	shl    %cl,%esi
  801231:	89 e9                	mov    %ebp,%ecx
  801233:	d3 e8                	shr    %cl,%eax
  801235:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80123a:	09 f0                	or     %esi,%eax
  80123c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801240:	f7 34 24             	divl   (%esp)
  801243:	d3 e6                	shl    %cl,%esi
  801245:	89 74 24 08          	mov    %esi,0x8(%esp)
  801249:	89 d6                	mov    %edx,%esi
  80124b:	f7 e7                	mul    %edi
  80124d:	39 d6                	cmp    %edx,%esi
  80124f:	89 c1                	mov    %eax,%ecx
  801251:	89 d7                	mov    %edx,%edi
  801253:	72 3f                	jb     801294 <__umoddi3+0x154>
  801255:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801259:	72 35                	jb     801290 <__umoddi3+0x150>
  80125b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80125f:	29 c8                	sub    %ecx,%eax
  801261:	19 fe                	sbb    %edi,%esi
  801263:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801268:	89 f2                	mov    %esi,%edx
  80126a:	d3 e8                	shr    %cl,%eax
  80126c:	89 e9                	mov    %ebp,%ecx
  80126e:	d3 e2                	shl    %cl,%edx
  801270:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801275:	09 d0                	or     %edx,%eax
  801277:	89 f2                	mov    %esi,%edx
  801279:	d3 ea                	shr    %cl,%edx
  80127b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80127f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  801283:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801287:	83 c4 1c             	add    $0x1c,%esp
  80128a:	c3                   	ret    
  80128b:	90                   	nop
  80128c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801290:	39 d6                	cmp    %edx,%esi
  801292:	75 c7                	jne    80125b <__umoddi3+0x11b>
  801294:	89 d7                	mov    %edx,%edi
  801296:	89 c1                	mov    %eax,%ecx
  801298:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  80129c:	1b 3c 24             	sbb    (%esp),%edi
  80129f:	eb ba                	jmp    80125b <__umoddi3+0x11b>
  8012a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	39 f5                	cmp    %esi,%ebp
  8012aa:	0f 82 f1 fe ff ff    	jb     8011a1 <__umoddi3+0x61>
  8012b0:	e9 f8 fe ff ff       	jmp    8011ad <__umoddi3+0x6d>
