
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80004d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800050:	8b 75 08             	mov    0x8(%ebp),%esi
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	// initialize the global pointer env to point at this 
	// environment's struct Env in the envs[] array.
	env = envs+ENVX(sys_getenvid());
  800056:	e8 09 01 00 00       	call   800164 <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x34>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007c:	89 34 24             	mov    %esi,(%esp)
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
}
  800089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80008c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008f:	89 ec                	mov    %ebp,%esp
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 61 00 00 00       	call   800107 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	89 c3                	mov    %eax,%ebx
  8000c4:	89 c7                	mov    %eax,%edi
  8000c6:	89 c6                	mov    %eax,%esi
  8000c8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ca:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000cd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8000d0:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8000d3:	89 ec                	mov    %ebp,%esp
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000e3:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f0:	89 d1                	mov    %edx,%ecx
  8000f2:	89 d3                	mov    %edx,%ebx
  8000f4:	89 d7                	mov    %edx,%edi
  8000f6:	89 d6                	mov    %edx,%esi
  8000f8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800100:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800103:	89 ec                	mov    %ebp,%esp
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 38             	sub    $0x38,%esp
  80010d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800110:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800113:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011b:	b8 03 00 00 00       	mov    $0x3,%eax
  800120:	8b 55 08             	mov    0x8(%ebp),%edx
  800123:	89 cb                	mov    %ecx,%ebx
  800125:	89 cf                	mov    %ecx,%edi
  800127:	89 ce                	mov    %ecx,%esi
  800129:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	7e 28                	jle    800157 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800133:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80013a:	00 
  80013b:	c7 44 24 08 f7 11 80 	movl   $0x8011f7,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  800152:	e8 35 03 00 00       	call   80048c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800157:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80015a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80015d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800160:	89 ec                	mov    %ebp,%esp
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80016d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800170:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	ba 00 00 00 00       	mov    $0x0,%edx
  800178:	b8 02 00 00 00       	mov    $0x2,%eax
  80017d:	89 d1                	mov    %edx,%ecx
  80017f:	89 d3                	mov    %edx,%ebx
  800181:	89 d7                	mov    %edx,%edi
  800183:	89 d6                	mov    %edx,%esi
  800185:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800187:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80018a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80018d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800190:	89 ec                	mov    %ebp,%esp
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    

00800194 <sys_yield>:

void
sys_yield(void)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80019d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001a0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ad:	89 d1                	mov    %edx,%ecx
  8001af:	89 d3                	mov    %edx,%ebx
  8001b1:	89 d7                	mov    %edx,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001b7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001bd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001c0:	89 ec                	mov    %ebp,%esp
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	83 ec 38             	sub    $0x38,%esp
  8001ca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001cd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001d0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d3:	be 00 00 00 00       	mov    $0x0,%esi
  8001d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	89 f7                	mov    %esi,%edi
  8001e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8001ea:	85 c0                	test   %eax,%eax
  8001ec:	7e 28                	jle    800216 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 08 f7 11 80 	movl   $0x8011f7,0x8(%esp)
  800201:	00 
  800202:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800209:	00 
  80020a:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  800211:	e8 76 02 00 00       	call   80048c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800216:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800219:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80021c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80021f:	89 ec                	mov    %ebp,%esp
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 38             	sub    $0x38,%esp
  800229:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80022c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80022f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	b8 05 00 00 00       	mov    $0x5,%eax
  800237:	8b 75 18             	mov    0x18(%ebp),%esi
  80023a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80023d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 28                	jle    800274 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800250:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800257:	00 
  800258:	c7 44 24 08 f7 11 80 	movl   $0x8011f7,0x8(%esp)
  80025f:	00 
  800260:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800267:	00 
  800268:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  80026f:	e8 18 02 00 00       	call   80048c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800274:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800277:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80027a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80027d:	89 ec                	mov    %ebp,%esp
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 38             	sub    $0x38,%esp
  800287:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80028a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80028d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	b8 06 00 00 00       	mov    $0x6,%eax
  80029a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029d:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7e 28                	jle    8002d2 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ae:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 08 f7 11 80 	movl   $0x8011f7,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  8002cd:	e8 ba 01 00 00       	call   80048c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002db:	89 ec                	mov    %ebp,%esp
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 38             	sub    $0x38,%esp
  8002e5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002eb:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8002f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fe:	89 df                	mov    %ebx,%edi
  800300:	89 de                	mov    %ebx,%esi
  800302:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800304:	85 c0                	test   %eax,%eax
  800306:	7e 28                	jle    800330 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800308:	89 44 24 10          	mov    %eax,0x10(%esp)
  80030c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800313:	00 
  800314:	c7 44 24 08 f7 11 80 	movl   $0x8011f7,0x8(%esp)
  80031b:	00 
  80031c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800323:	00 
  800324:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  80032b:	e8 5c 01 00 00       	call   80048c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800330:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800333:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800336:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800339:	89 ec                	mov    %ebp,%esp
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	83 ec 38             	sub    $0x38,%esp
  800343:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800346:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800349:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800351:	b8 09 00 00 00       	mov    $0x9,%eax
  800356:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 df                	mov    %ebx,%edi
  80035e:	89 de                	mov    %ebx,%esi
  800360:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7e 28                	jle    80038e <sys_env_set_trapframe+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800371:	00 
  800372:	c7 44 24 08 f7 11 80 	movl   $0x8011f7,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  800389:	e8 fe 00 00 00       	call   80048c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80038e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800391:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800394:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800397:	89 ec                	mov    %ebp,%esp
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	83 ec 38             	sub    $0x38,%esp
  8003a1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003a4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003a7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ba:	89 df                	mov    %ebx,%edi
  8003bc:	89 de                	mov    %ebx,%esi
  8003be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	7e 28                	jle    8003ec <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8003cf:	00 
  8003d0:	c7 44 24 08 f7 11 80 	movl   $0x8011f7,0x8(%esp)
  8003d7:	00 
  8003d8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003df:	00 
  8003e0:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  8003e7:	e8 a0 00 00 00       	call   80048c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003ec:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003ef:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003f2:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003f5:	89 ec                	mov    %ebp,%esp
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    

008003f9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
  8003fc:	83 ec 0c             	sub    $0xc,%esp
  8003ff:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800402:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800405:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800408:	be 00 00 00 00       	mov    $0x0,%esi
  80040d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800412:	8b 7d 14             	mov    0x14(%ebp),%edi
  800415:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800418:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041b:	8b 55 08             	mov    0x8(%ebp),%edx
  80041e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800420:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800423:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800426:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800429:	89 ec                	mov    %ebp,%esp
  80042b:	5d                   	pop    %ebp
  80042c:	c3                   	ret    

0080042d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	83 ec 38             	sub    $0x38,%esp
  800433:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800436:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800439:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800441:	b8 0d 00 00 00       	mov    $0xd,%eax
  800446:	8b 55 08             	mov    0x8(%ebp),%edx
  800449:	89 cb                	mov    %ecx,%ebx
  80044b:	89 cf                	mov    %ecx,%edi
  80044d:	89 ce                	mov    %ecx,%esi
  80044f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	if(check && ret > 0)
  800451:	85 c0                	test   %eax,%eax
  800453:	7e 28                	jle    80047d <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800455:	89 44 24 10          	mov    %eax,0x10(%esp)
  800459:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800460:	00 
  800461:	c7 44 24 08 f7 11 80 	movl   $0x8011f7,0x8(%esp)
  800468:	00 
  800469:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800470:	00 
  800471:	c7 04 24 14 12 80 00 	movl   $0x801214,(%esp)
  800478:	e8 0f 00 00 00       	call   80048c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80047d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800480:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800483:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800486:	89 ec                	mov    %ebp,%esp
  800488:	5d                   	pop    %ebp
  800489:	c3                   	ret    
	...

0080048c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
  80048f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	if (argv0)
  800492:	a1 08 20 80 00       	mov    0x802008,%eax
  800497:	85 c0                	test   %eax,%eax
  800499:	74 10                	je     8004ab <_panic+0x1f>
		cprintf("%s: ", argv0);
  80049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049f:	c7 04 24 22 12 80 00 	movl   $0x801222,(%esp)
  8004a6:	e8 e8 00 00 00       	call   800593 <cprintf>
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8004ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004b9:	a1 00 20 80 00       	mov    0x802000,%eax
  8004be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c2:	c7 04 24 27 12 80 00 	movl   $0x801227,(%esp)
  8004c9:	e8 c5 00 00 00       	call   800593 <cprintf>
	vcprintf(fmt, ap);
  8004ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8004d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	e8 52 00 00 00       	call   800532 <vcprintf>
	cprintf("\n");
  8004e0:	c7 04 24 43 12 80 00 	movl   $0x801243,(%esp)
  8004e7:	e8 a7 00 00 00       	call   800593 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ec:	cc                   	int3   
  8004ed:	eb fd                	jmp    8004ec <_panic+0x60>
	...

008004f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	53                   	push   %ebx
  8004f4:	83 ec 14             	sub    $0x14,%esp
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8004fa:	8b 03                	mov    (%ebx),%eax
  8004fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800503:	83 c0 01             	add    $0x1,%eax
  800506:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800508:	3d ff 00 00 00       	cmp    $0xff,%eax
  80050d:	75 19                	jne    800528 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80050f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800516:	00 
  800517:	8d 43 08             	lea    0x8(%ebx),%eax
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	e8 86 fb ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800522:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800528:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80052c:	83 c4 14             	add    $0x14,%esp
  80052f:	5b                   	pop    %ebx
  800530:	5d                   	pop    %ebp
  800531:	c3                   	ret    

00800532 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80053b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800542:	00 00 00 
	b.cnt = 0;
  800545:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80054c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80054f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800552:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800556:	8b 45 08             	mov    0x8(%ebp),%eax
  800559:	89 44 24 08          	mov    %eax,0x8(%esp)
  80055d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800563:	89 44 24 04          	mov    %eax,0x4(%esp)
  800567:	c7 04 24 f0 04 80 00 	movl   $0x8004f0,(%esp)
  80056e:	e8 d1 01 00 00       	call   800744 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800573:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800583:	89 04 24             	mov    %eax,(%esp)
  800586:	e8 1d fb ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  80058b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800591:	c9                   	leave  
  800592:	c3                   	ret    

00800593 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800593:	55                   	push   %ebp
  800594:	89 e5                	mov    %esp,%ebp
  800596:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800599:	8d 45 0c             	lea    0xc(%ebp),%eax
  80059c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	e8 87 ff ff ff       	call   800532 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005ab:	c9                   	leave  
  8005ac:	c3                   	ret    
  8005ad:	00 00                	add    %al,(%eax)
	...

008005b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	57                   	push   %edi
  8005b4:	56                   	push   %esi
  8005b5:	53                   	push   %ebx
  8005b6:	83 ec 3c             	sub    $0x3c,%esp
  8005b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005bc:	89 d7                	mov    %edx,%edi
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8005d8:	72 11                	jb     8005eb <printnum+0x3b>
  8005da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005e0:	76 09                	jbe    8005eb <printnum+0x3b>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005e2:	83 eb 01             	sub    $0x1,%ebx
  8005e5:	85 db                	test   %ebx,%ebx
  8005e7:	7f 51                	jg     80063a <printnum+0x8a>
  8005e9:	eb 5e                	jmp    800649 <printnum+0x99>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005eb:	89 74 24 10          	mov    %esi,0x10(%esp)
  8005ef:	83 eb 01             	sub    $0x1,%ebx
  8005f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005fd:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800601:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800605:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80060c:	00 
  80060d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061a:	e8 11 09 00 00       	call   800f30 <__udivdi3>
  80061f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800623:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062e:	89 fa                	mov    %edi,%edx
  800630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800633:	e8 78 ff ff ff       	call   8005b0 <printnum>
  800638:	eb 0f                	jmp    800649 <printnum+0x99>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063e:	89 34 24             	mov    %esi,(%esp)
  800641:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800644:	83 eb 01             	sub    $0x1,%ebx
  800647:	75 f1                	jne    80063a <printnum+0x8a>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800649:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064d:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800651:	8b 45 10             	mov    0x10(%ebp),%eax
  800654:	89 44 24 08          	mov    %eax,0x8(%esp)
  800658:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80065f:	00 
  800660:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800663:	89 04 24             	mov    %eax,(%esp)
  800666:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	e8 ee 09 00 00       	call   801060 <__umoddi3>
  800672:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800676:	0f be 80 45 12 80 00 	movsbl 0x801245(%eax),%eax
  80067d:	89 04 24             	mov    %eax,(%esp)
  800680:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800683:	83 c4 3c             	add    $0x3c,%esp
  800686:	5b                   	pop    %ebx
  800687:	5e                   	pop    %esi
  800688:	5f                   	pop    %edi
  800689:	5d                   	pop    %ebp
  80068a:	c3                   	ret    

0080068b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80068e:	83 fa 01             	cmp    $0x1,%edx
  800691:	7e 0e                	jle    8006a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800693:	8b 10                	mov    (%eax),%edx
  800695:	8d 4a 08             	lea    0x8(%edx),%ecx
  800698:	89 08                	mov    %ecx,(%eax)
  80069a:	8b 02                	mov    (%edx),%eax
  80069c:	8b 52 04             	mov    0x4(%edx),%edx
  80069f:	eb 22                	jmp    8006c3 <getuint+0x38>
	else if (lflag)
  8006a1:	85 d2                	test   %edx,%edx
  8006a3:	74 10                	je     8006b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006aa:	89 08                	mov    %ecx,(%eax)
  8006ac:	8b 02                	mov    (%edx),%eax
  8006ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b3:	eb 0e                	jmp    8006c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006b5:	8b 10                	mov    (%eax),%edx
  8006b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006ba:	89 08                	mov    %ecx,(%eax)
  8006bc:	8b 02                	mov    (%edx),%eax
  8006be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006c8:	83 fa 01             	cmp    $0x1,%edx
  8006cb:	7e 0e                	jle    8006db <getint+0x16>
		return va_arg(*ap, long long);
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006d2:	89 08                	mov    %ecx,(%eax)
  8006d4:	8b 02                	mov    (%edx),%eax
  8006d6:	8b 52 04             	mov    0x4(%edx),%edx
  8006d9:	eb 22                	jmp    8006fd <getint+0x38>
	else if (lflag)
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 10                	je     8006ef <getint+0x2a>
		return va_arg(*ap, long);
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006e4:	89 08                	mov    %ecx,(%eax)
  8006e6:	8b 02                	mov    (%edx),%eax
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	c1 fa 1f             	sar    $0x1f,%edx
  8006ed:	eb 0e                	jmp    8006fd <getint+0x38>
	else
		return va_arg(*ap, int);
  8006ef:	8b 10                	mov    (%eax),%edx
  8006f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f4:	89 08                	mov    %ecx,(%eax)
  8006f6:	8b 02                	mov    (%edx),%eax
  8006f8:	89 c2                	mov    %eax,%edx
  8006fa:	c1 fa 1f             	sar    $0x1f,%edx
}
  8006fd:	5d                   	pop    %ebp
  8006fe:	c3                   	ret    

008006ff <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800705:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	3b 50 04             	cmp    0x4(%eax),%edx
  80070e:	73 0a                	jae    80071a <sprintputch+0x1b>
		*b->buf++ = ch;
  800710:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800713:	88 0a                	mov    %cl,(%edx)
  800715:	83 c2 01             	add    $0x1,%edx
  800718:	89 10                	mov    %edx,(%eax)
}
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
  800725:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800729:	8b 45 10             	mov    0x10(%ebp),%eax
  80072c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800730:	8b 45 0c             	mov    0xc(%ebp),%eax
  800733:	89 44 24 04          	mov    %eax,0x4(%esp)
  800737:	8b 45 08             	mov    0x8(%ebp),%eax
  80073a:	89 04 24             	mov    %eax,(%esp)
  80073d:	e8 02 00 00 00       	call   800744 <vprintfmt>
	va_end(ap);
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	57                   	push   %edi
  800748:	56                   	push   %esi
  800749:	53                   	push   %ebx
  80074a:	83 ec 4c             	sub    $0x4c,%esp
  80074d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800750:	8b 75 10             	mov    0x10(%ebp),%esi
  800753:	eb 12                	jmp    800767 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800755:	85 c0                	test   %eax,%eax
  800757:	0f 84 98 03 00 00    	je     800af5 <vprintfmt+0x3b1>
				return;
			putch(ch, putdat);
  80075d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800761:	89 04 24             	mov    %eax,(%esp)
  800764:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800767:	0f b6 06             	movzbl (%esi),%eax
  80076a:	83 c6 01             	add    $0x1,%esi
  80076d:	83 f8 25             	cmp    $0x25,%eax
  800770:	75 e3                	jne    800755 <vprintfmt+0x11>
  800772:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800776:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80077d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800782:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800789:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800791:	eb 2b                	jmp    8007be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800793:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800796:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80079a:	eb 22                	jmp    8007be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80079f:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007a3:	eb 19                	jmp    8007be <vprintfmt+0x7a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8007a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8007af:	eb 0d                	jmp    8007be <vprintfmt+0x7a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007b7:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	0f b6 06             	movzbl (%esi),%eax
  8007c1:	0f b6 d0             	movzbl %al,%edx
  8007c4:	8d 7e 01             	lea    0x1(%esi),%edi
  8007c7:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8007ca:	83 e8 23             	sub    $0x23,%eax
  8007cd:	3c 55                	cmp    $0x55,%al
  8007cf:	0f 87 fa 02 00 00    	ja     800acf <vprintfmt+0x38b>
  8007d5:	0f b6 c0             	movzbl %al,%eax
  8007d8:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8007df:	83 ea 30             	sub    $0x30,%edx
  8007e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
  8007e5:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8007e9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  8007ef:	83 fa 09             	cmp    $0x9,%edx
  8007f2:	77 4a                	ja     80083e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007f7:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8007fa:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8007fd:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800801:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800804:	8d 50 d0             	lea    -0x30(%eax),%edx
  800807:	83 fa 09             	cmp    $0x9,%edx
  80080a:	76 eb                	jbe    8007f7 <vprintfmt+0xb3>
  80080c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80080f:	eb 2d                	jmp    80083e <vprintfmt+0xfa>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 50 04             	lea    0x4(%eax),%edx
  800817:	89 55 14             	mov    %edx,0x14(%ebp)
  80081a:	8b 00                	mov    (%eax),%eax
  80081c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800822:	eb 1a                	jmp    80083e <vprintfmt+0xfa>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800824:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case '*':
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
  800827:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80082b:	79 91                	jns    8007be <vprintfmt+0x7a>
  80082d:	e9 73 ff ff ff       	jmp    8007a5 <vprintfmt+0x61>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800832:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800835:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80083c:	eb 80                	jmp    8007be <vprintfmt+0x7a>

		process_precision:
			if (width < 0)
  80083e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800842:	0f 89 76 ff ff ff    	jns    8007be <vprintfmt+0x7a>
  800848:	e9 64 ff ff ff       	jmp    8007b1 <vprintfmt+0x6d>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80084d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800850:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800853:	e9 66 ff ff ff       	jmp    8007be <vprintfmt+0x7a>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8d 50 04             	lea    0x4(%eax),%edx
  80085e:	89 55 14             	mov    %edx,0x14(%ebp)
  800861:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800865:	8b 00                	mov    (%eax),%eax
  800867:	89 04 24             	mov    %eax,(%esp)
  80086a:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80086d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800870:	e9 f2 fe ff ff       	jmp    800767 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800875:	8b 45 14             	mov    0x14(%ebp),%eax
  800878:	8d 50 04             	lea    0x4(%eax),%edx
  80087b:	89 55 14             	mov    %edx,0x14(%ebp)
  80087e:	8b 00                	mov    (%eax),%eax
  800880:	89 c2                	mov    %eax,%edx
  800882:	c1 fa 1f             	sar    $0x1f,%edx
  800885:	31 d0                	xor    %edx,%eax
  800887:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800889:	83 f8 08             	cmp    $0x8,%eax
  80088c:	7f 0b                	jg     800899 <vprintfmt+0x155>
  80088e:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800895:	85 d2                	test   %edx,%edx
  800897:	75 23                	jne    8008bc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800899:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089d:	c7 44 24 08 5d 12 80 	movl   $0x80125d,0x8(%esp)
  8008a4:	00 
  8008a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ac:	89 3c 24             	mov    %edi,(%esp)
  8008af:	e8 68 fe ff ff       	call   80071c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008b7:	e9 ab fe ff ff       	jmp    800767 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008c0:	c7 44 24 08 66 12 80 	movl   $0x801266,0x8(%esp)
  8008c7:	00 
  8008c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cf:	89 3c 24             	mov    %edi,(%esp)
  8008d2:	e8 45 fe ff ff       	call   80071c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008da:	e9 88 fe ff ff       	jmp    800767 <vprintfmt+0x23>
  8008df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8008f3:	85 f6                	test   %esi,%esi
  8008f5:	ba 56 12 80 00       	mov    $0x801256,%edx
  8008fa:	0f 44 f2             	cmove  %edx,%esi
			if (width > 0 && padc != '-')
  8008fd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800901:	7e 06                	jle    800909 <vprintfmt+0x1c5>
  800903:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800907:	75 10                	jne    800919 <vprintfmt+0x1d5>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800909:	0f be 06             	movsbl (%esi),%eax
  80090c:	83 c6 01             	add    $0x1,%esi
  80090f:	85 c0                	test   %eax,%eax
  800911:	0f 85 86 00 00 00    	jne    80099d <vprintfmt+0x259>
  800917:	eb 76                	jmp    80098f <vprintfmt+0x24b>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800919:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091d:	89 34 24             	mov    %esi,(%esp)
  800920:	e8 76 02 00 00       	call   800b9b <strnlen>
  800925:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800928:	29 c2                	sub    %eax,%edx
  80092a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80092d:	85 d2                	test   %edx,%edx
  80092f:	7e d8                	jle    800909 <vprintfmt+0x1c5>
					putch(padc, putdat);
  800931:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800935:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800938:	89 7d d0             	mov    %edi,-0x30(%ebp)
  80093b:	89 d6                	mov    %edx,%esi
  80093d:	89 c7                	mov    %eax,%edi
  80093f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800943:	89 3c 24             	mov    %edi,(%esp)
  800946:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800949:	83 ee 01             	sub    $0x1,%esi
  80094c:	75 f1                	jne    80093f <vprintfmt+0x1fb>
  80094e:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800951:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800954:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800957:	eb b0                	jmp    800909 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800959:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80095d:	74 18                	je     800977 <vprintfmt+0x233>
  80095f:	8d 50 e0             	lea    -0x20(%eax),%edx
  800962:	83 fa 5e             	cmp    $0x5e,%edx
  800965:	76 10                	jbe    800977 <vprintfmt+0x233>
					putch('?', putdat);
  800967:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800972:	ff 55 08             	call   *0x8(%ebp)
  800975:	eb 0a                	jmp    800981 <vprintfmt+0x23d>
				else
					putch(ch, putdat);
  800977:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097b:	89 04 24             	mov    %eax,(%esp)
  80097e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800981:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800985:	0f be 06             	movsbl (%esi),%eax
  800988:	83 c6 01             	add    $0x1,%esi
  80098b:	85 c0                	test   %eax,%eax
  80098d:	75 0e                	jne    80099d <vprintfmt+0x259>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800992:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800996:	7f 11                	jg     8009a9 <vprintfmt+0x265>
  800998:	e9 ca fd ff ff       	jmp    800767 <vprintfmt+0x23>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80099d:	85 ff                	test   %edi,%edi
  80099f:	90                   	nop
  8009a0:	78 b7                	js     800959 <vprintfmt+0x215>
  8009a2:	83 ef 01             	sub    $0x1,%edi
  8009a5:	79 b2                	jns    800959 <vprintfmt+0x215>
  8009a7:	eb e6                	jmp    80098f <vprintfmt+0x24b>
  8009a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8009ac:	8b 7d 08             	mov    0x8(%ebp),%edi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009ba:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009bc:	83 ee 01             	sub    $0x1,%esi
  8009bf:	75 ee                	jne    8009af <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009c1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009c4:	e9 9e fd ff ff       	jmp    800767 <vprintfmt+0x23>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009c9:	89 ca                	mov    %ecx,%edx
  8009cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ce:	e8 f2 fc ff ff       	call   8006c5 <getint>
  8009d3:	89 c6                	mov    %eax,%esi
  8009d5:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009dc:	85 d2                	test   %edx,%edx
  8009de:	0f 89 ad 00 00 00    	jns    800a91 <vprintfmt+0x34d>
				putch('-', putdat);
  8009e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ef:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8009f2:	f7 de                	neg    %esi
  8009f4:	83 d7 00             	adc    $0x0,%edi
  8009f7:	f7 df                	neg    %edi
			}
			base = 10;
  8009f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009fe:	e9 8e 00 00 00       	jmp    800a91 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a03:	89 ca                	mov    %ecx,%edx
  800a05:	8d 45 14             	lea    0x14(%ebp),%eax
  800a08:	e8 7e fc ff ff       	call   80068b <getuint>
  800a0d:	89 c6                	mov    %eax,%esi
  800a0f:	89 d7                	mov    %edx,%edi
			base = 10;
  800a11:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a16:	eb 79                	jmp    800a91 <vprintfmt+0x34d>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
  800a18:	89 ca                	mov    %ecx,%edx
  800a1a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1d:	e8 a3 fc ff ff       	call   8006c5 <getint>
  800a22:	89 c6                	mov    %eax,%esi
  800a24:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  800a26:	b8 08 00 00 00       	mov    $0x8,%eax
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a2b:	85 d2                	test   %edx,%edx
  800a2d:	79 62                	jns    800a91 <vprintfmt+0x34d>
				putch('-', putdat);
  800a2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a33:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a3a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a3d:	f7 de                	neg    %esi
  800a3f:	83 d7 00             	adc    $0x0,%edi
  800a42:	f7 df                	neg    %edi
			}
			base = 8;
  800a44:	b8 08 00 00 00       	mov    $0x8,%eax
  800a49:	eb 46                	jmp    800a91 <vprintfmt+0x34d>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800a4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a4f:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a56:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a59:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a5d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a64:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a67:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6a:	8d 50 04             	lea    0x4(%eax),%edx
  800a6d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a70:	8b 30                	mov    (%eax),%esi
  800a72:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a77:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a7c:	eb 13                	jmp    800a91 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a7e:	89 ca                	mov    %ecx,%edx
  800a80:	8d 45 14             	lea    0x14(%ebp),%eax
  800a83:	e8 03 fc ff ff       	call   80068b <getuint>
  800a88:	89 c6                	mov    %eax,%esi
  800a8a:	89 d7                	mov    %edx,%edi
			base = 16;
  800a8c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a91:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800a95:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a99:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a9c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa4:	89 34 24             	mov    %esi,(%esp)
  800aa7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aab:	89 da                	mov    %ebx,%edx
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	e8 fb fa ff ff       	call   8005b0 <printnum>
			break;
  800ab5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ab8:	e9 aa fc ff ff       	jmp    800767 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800abd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ac1:	89 14 24             	mov    %edx,(%esp)
  800ac4:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ac7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800aca:	e9 98 fc ff ff       	jmp    800767 <vprintfmt+0x23>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800acf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ada:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800add:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ae1:	0f 84 80 fc ff ff    	je     800767 <vprintfmt+0x23>
  800ae7:	83 ee 01             	sub    $0x1,%esi
  800aea:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800aee:	75 f7                	jne    800ae7 <vprintfmt+0x3a3>
  800af0:	e9 72 fc ff ff       	jmp    800767 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800af5:	83 c4 4c             	add    $0x4c,%esp
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	83 ec 28             	sub    $0x28,%esp
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b0c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b10:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	74 30                	je     800b4e <vsnprintf+0x51>
  800b1e:	85 d2                	test   %edx,%edx
  800b20:	7e 2c                	jle    800b4e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b22:	8b 45 14             	mov    0x14(%ebp),%eax
  800b25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b29:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b30:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b37:	c7 04 24 ff 06 80 00 	movl   $0x8006ff,(%esp)
  800b3e:	e8 01 fc ff ff       	call   800744 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b46:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b4c:	eb 05                	jmp    800b53 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b62:	8b 45 10             	mov    0x10(%ebp),%eax
  800b65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	89 04 24             	mov    %eax,(%esp)
  800b76:	e8 82 ff ff ff       	call   800afd <vsnprintf>
	va_end(ap);

	return rc;
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    
  800b7d:	00 00                	add    %al,(%eax)
	...

00800b80 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b8e:	74 09                	je     800b99 <strlen+0x19>
		n++;
  800b90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b97:	75 f7                	jne    800b90 <strlen+0x10>
		n++;
	return n;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  800baa:	85 c9                	test   %ecx,%ecx
  800bac:	74 1a                	je     800bc8 <strnlen+0x2d>
  800bae:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bb1:	74 15                	je     800bc8 <strnlen+0x2d>
  800bb3:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800bb8:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bba:	39 ca                	cmp    %ecx,%edx
  800bbc:	74 0a                	je     800bc8 <strnlen+0x2d>
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800bc6:	75 f0                	jne    800bb8 <strnlen+0x1d>
		n++;
	return n;
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bde:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800be1:	83 c2 01             	add    $0x1,%edx
  800be4:	84 c9                	test   %cl,%cl
  800be6:	75 f2                	jne    800bda <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800be8:	5b                   	pop    %ebx
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf9:	85 f6                	test   %esi,%esi
  800bfb:	74 18                	je     800c15 <strncpy+0x2a>
  800bfd:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c02:	0f b6 1a             	movzbl (%edx),%ebx
  800c05:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c08:	80 3a 01             	cmpb   $0x1,(%edx)
  800c0b:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c0e:	83 c1 01             	add    $0x1,%ecx
  800c11:	39 f1                	cmp    %esi,%ecx
  800c13:	75 ed                	jne    800c02 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c25:	8b 75 10             	mov    0x10(%ebp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c28:	89 f8                	mov    %edi,%eax
  800c2a:	85 f6                	test   %esi,%esi
  800c2c:	74 2b                	je     800c59 <strlcpy+0x40>
		while (--size > 0 && *src != '\0')
  800c2e:	83 fe 01             	cmp    $0x1,%esi
  800c31:	74 23                	je     800c56 <strlcpy+0x3d>
  800c33:	0f b6 0b             	movzbl (%ebx),%ecx
  800c36:	84 c9                	test   %cl,%cl
  800c38:	74 1c                	je     800c56 <strlcpy+0x3d>
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  800c3a:	83 ee 02             	sub    $0x2,%esi
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c42:	88 08                	mov    %cl,(%eax)
  800c44:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c47:	39 f2                	cmp    %esi,%edx
  800c49:	74 0b                	je     800c56 <strlcpy+0x3d>
  800c4b:	83 c2 01             	add    $0x1,%edx
  800c4e:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c52:	84 c9                	test   %cl,%cl
  800c54:	75 ec                	jne    800c42 <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  800c56:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c59:	29 f8                	sub    %edi,%eax
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c66:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c69:	0f b6 01             	movzbl (%ecx),%eax
  800c6c:	84 c0                	test   %al,%al
  800c6e:	74 16                	je     800c86 <strcmp+0x26>
  800c70:	3a 02                	cmp    (%edx),%al
  800c72:	75 12                	jne    800c86 <strcmp+0x26>
		p++, q++;
  800c74:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c77:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
  800c7b:	84 c0                	test   %al,%al
  800c7d:	74 07                	je     800c86 <strcmp+0x26>
  800c7f:	83 c1 01             	add    $0x1,%ecx
  800c82:	3a 02                	cmp    (%edx),%al
  800c84:	74 ee                	je     800c74 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c86:	0f b6 c0             	movzbl %al,%eax
  800c89:	0f b6 12             	movzbl (%edx),%edx
  800c8c:	29 d0                	sub    %edx,%eax
}
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	53                   	push   %ebx
  800c94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c9a:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ca2:	85 d2                	test   %edx,%edx
  800ca4:	74 28                	je     800cce <strncmp+0x3e>
  800ca6:	0f b6 01             	movzbl (%ecx),%eax
  800ca9:	84 c0                	test   %al,%al
  800cab:	74 24                	je     800cd1 <strncmp+0x41>
  800cad:	3a 03                	cmp    (%ebx),%al
  800caf:	75 20                	jne    800cd1 <strncmp+0x41>
  800cb1:	83 ea 01             	sub    $0x1,%edx
  800cb4:	74 13                	je     800cc9 <strncmp+0x39>
		n--, p++, q++;
  800cb6:	83 c1 01             	add    $0x1,%ecx
  800cb9:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cbc:	0f b6 01             	movzbl (%ecx),%eax
  800cbf:	84 c0                	test   %al,%al
  800cc1:	74 0e                	je     800cd1 <strncmp+0x41>
  800cc3:	3a 03                	cmp    (%ebx),%al
  800cc5:	74 ea                	je     800cb1 <strncmp+0x21>
  800cc7:	eb 08                	jmp    800cd1 <strncmp+0x41>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cc9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd1:	0f b6 01             	movzbl (%ecx),%eax
  800cd4:	0f b6 13             	movzbl (%ebx),%edx
  800cd7:	29 d0                	sub    %edx,%eax
  800cd9:	eb f3                	jmp    800cce <strncmp+0x3e>

00800cdb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce5:	0f b6 10             	movzbl (%eax),%edx
  800ce8:	84 d2                	test   %dl,%dl
  800cea:	74 1c                	je     800d08 <strchr+0x2d>
		if (*s == c)
  800cec:	38 ca                	cmp    %cl,%dl
  800cee:	75 09                	jne    800cf9 <strchr+0x1e>
  800cf0:	eb 1b                	jmp    800d0d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cf2:	83 c0 01             	add    $0x1,%eax
		if (*s == c)
  800cf5:	38 ca                	cmp    %cl,%dl
  800cf7:	74 14                	je     800d0d <strchr+0x32>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cf9:	0f b6 50 01          	movzbl 0x1(%eax),%edx
  800cfd:	84 d2                	test   %dl,%dl
  800cff:	75 f1                	jne    800cf2 <strchr+0x17>
		if (*s == c)
			return (char *) s;
	return 0;
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	eb 05                	jmp    800d0d <strchr+0x32>
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d19:	0f b6 10             	movzbl (%eax),%edx
  800d1c:	84 d2                	test   %dl,%dl
  800d1e:	74 14                	je     800d34 <strfind+0x25>
		if (*s == c)
  800d20:	38 ca                	cmp    %cl,%dl
  800d22:	75 06                	jne    800d2a <strfind+0x1b>
  800d24:	eb 0e                	jmp    800d34 <strfind+0x25>
  800d26:	38 ca                	cmp    %cl,%dl
  800d28:	74 0a                	je     800d34 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d2a:	83 c0 01             	add    $0x1,%eax
  800d2d:	0f b6 10             	movzbl (%eax),%edx
  800d30:	84 d2                	test   %dl,%dl
  800d32:	75 f2                	jne    800d26 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <memset>:


void *
memset(void *v, int c, size_t n)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	53                   	push   %ebx
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d43:	89 da                	mov    %ebx,%edx
  800d45:	83 ea 01             	sub    $0x1,%edx
  800d48:	78 0d                	js     800d57 <memset+0x21>
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
  800d4a:	01 c3                	add    %eax,%ebx
{
	char *p;
	int m;

	p = v;
  800d4c:	89 c2                	mov    %eax,%edx
	m = n;
	while (--m >= 0)
		*p++ = c;
  800d4e:	88 0a                	mov    %cl,(%edx)
  800d50:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800d53:	39 da                	cmp    %ebx,%edx
  800d55:	75 f7                	jne    800d4e <memset+0x18>
		*p++ = c;

	return v;
}
  800d57:	5b                   	pop    %ebx
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <memmove>:

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d69:	39 c6                	cmp    %eax,%esi
  800d6b:	72 0b                	jb     800d78 <memmove+0x1e>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800d6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d72:	85 db                	test   %ebx,%ebx
  800d74:	75 29                	jne    800d9f <memmove+0x45>
  800d76:	eb 35                	jmp    800dad <memmove+0x53>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d78:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  800d7b:	39 c8                	cmp    %ecx,%eax
  800d7d:	73 ee                	jae    800d6d <memmove+0x13>
		s += n;
		d += n;
		while (n-- > 0)
  800d7f:	85 db                	test   %ebx,%ebx
  800d81:	74 2a                	je     800dad <memmove+0x53>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
  800d83:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
  800d86:	89 da                	mov    %ebx,%edx
}

/* no memcpy - use memmove instead */

void *
memmove(void *dst, const void *src, size_t n)
  800d88:	f7 db                	neg    %ebx
  800d8a:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
  800d8d:	01 fb                	add    %edi,%ebx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
  800d8f:	0f b6 4c 16 ff       	movzbl -0x1(%esi,%edx,1),%ecx
  800d94:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800d98:	83 ea 01             	sub    $0x1,%edx
  800d9b:	75 f2                	jne    800d8f <memmove+0x35>
  800d9d:	eb 0e                	jmp    800dad <memmove+0x53>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800d9f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800da3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800da6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800da9:	39 d3                	cmp    %edx,%ebx
  800dab:	75 f2                	jne    800d9f <memmove+0x45>
			*d++ = *s++;

	return dst;
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800db8:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	89 04 24             	mov    %eax,(%esp)
  800dcc:	e8 89 ff ff ff       	call   800d5a <memmove>
}
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    

00800dd3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ddc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ddf:	8b 7d 10             	mov    0x10(%ebp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800de2:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800de7:	85 ff                	test   %edi,%edi
  800de9:	74 37                	je     800e22 <memcmp+0x4f>
		if (*s1 != *s2)
  800deb:	0f b6 03             	movzbl (%ebx),%eax
  800dee:	0f b6 0e             	movzbl (%esi),%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df1:	83 ef 01             	sub    $0x1,%edi
  800df4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (*s1 != *s2)
  800df9:	38 c8                	cmp    %cl,%al
  800dfb:	74 1c                	je     800e19 <memcmp+0x46>
  800dfd:	eb 10                	jmp    800e0f <memcmp+0x3c>
  800dff:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  800e04:	83 c2 01             	add    $0x1,%edx
  800e07:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
  800e0b:	38 c8                	cmp    %cl,%al
  800e0d:	74 0a                	je     800e19 <memcmp+0x46>
			return (int) *s1 - (int) *s2;
  800e0f:	0f b6 c0             	movzbl %al,%eax
  800e12:	0f b6 c9             	movzbl %cl,%ecx
  800e15:	29 c8                	sub    %ecx,%eax
  800e17:	eb 09                	jmp    800e22 <memcmp+0x4f>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e19:	39 fa                	cmp    %edi,%edx
  800e1b:	75 e2                	jne    800dff <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e2d:	89 c2                	mov    %eax,%edx
  800e2f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e32:	39 d0                	cmp    %edx,%eax
  800e34:	73 15                	jae    800e4b <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800e3a:	38 08                	cmp    %cl,(%eax)
  800e3c:	75 06                	jne    800e44 <memfind+0x1d>
  800e3e:	eb 0b                	jmp    800e4b <memfind+0x24>
  800e40:	38 08                	cmp    %cl,(%eax)
  800e42:	74 07                	je     800e4b <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e44:	83 c0 01             	add    $0x1,%eax
  800e47:	39 d0                	cmp    %edx,%eax
  800e49:	75 f5                	jne    800e40 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e59:	0f b6 02             	movzbl (%edx),%eax
  800e5c:	3c 20                	cmp    $0x20,%al
  800e5e:	74 04                	je     800e64 <strtol+0x17>
  800e60:	3c 09                	cmp    $0x9,%al
  800e62:	75 0e                	jne    800e72 <strtol+0x25>
		s++;
  800e64:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e67:	0f b6 02             	movzbl (%edx),%eax
  800e6a:	3c 20                	cmp    $0x20,%al
  800e6c:	74 f6                	je     800e64 <strtol+0x17>
  800e6e:	3c 09                	cmp    $0x9,%al
  800e70:	74 f2                	je     800e64 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e72:	3c 2b                	cmp    $0x2b,%al
  800e74:	75 0a                	jne    800e80 <strtol+0x33>
		s++;
  800e76:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e79:	bf 00 00 00 00       	mov    $0x0,%edi
  800e7e:	eb 10                	jmp    800e90 <strtol+0x43>
  800e80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e85:	3c 2d                	cmp    $0x2d,%al
  800e87:	75 07                	jne    800e90 <strtol+0x43>
		s++, neg = 1;
  800e89:	83 c2 01             	add    $0x1,%edx
  800e8c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e90:	85 db                	test   %ebx,%ebx
  800e92:	0f 94 c0             	sete   %al
  800e95:	74 05                	je     800e9c <strtol+0x4f>
  800e97:	83 fb 10             	cmp    $0x10,%ebx
  800e9a:	75 15                	jne    800eb1 <strtol+0x64>
  800e9c:	80 3a 30             	cmpb   $0x30,(%edx)
  800e9f:	75 10                	jne    800eb1 <strtol+0x64>
  800ea1:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ea5:	75 0a                	jne    800eb1 <strtol+0x64>
		s += 2, base = 16;
  800ea7:	83 c2 02             	add    $0x2,%edx
  800eaa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800eaf:	eb 13                	jmp    800ec4 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800eb1:	84 c0                	test   %al,%al
  800eb3:	74 0f                	je     800ec4 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800eb5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eba:	80 3a 30             	cmpb   $0x30,(%edx)
  800ebd:	75 05                	jne    800ec4 <strtol+0x77>
		s++, base = 8;
  800ebf:	83 c2 01             	add    $0x1,%edx
  800ec2:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ec4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec9:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ecb:	0f b6 0a             	movzbl (%edx),%ecx
  800ece:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ed1:	80 fb 09             	cmp    $0x9,%bl
  800ed4:	77 08                	ja     800ede <strtol+0x91>
			dig = *s - '0';
  800ed6:	0f be c9             	movsbl %cl,%ecx
  800ed9:	83 e9 30             	sub    $0x30,%ecx
  800edc:	eb 1e                	jmp    800efc <strtol+0xaf>
		else if (*s >= 'a' && *s <= 'z')
  800ede:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ee1:	80 fb 19             	cmp    $0x19,%bl
  800ee4:	77 08                	ja     800eee <strtol+0xa1>
			dig = *s - 'a' + 10;
  800ee6:	0f be c9             	movsbl %cl,%ecx
  800ee9:	83 e9 57             	sub    $0x57,%ecx
  800eec:	eb 0e                	jmp    800efc <strtol+0xaf>
		else if (*s >= 'A' && *s <= 'Z')
  800eee:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ef1:	80 fb 19             	cmp    $0x19,%bl
  800ef4:	77 14                	ja     800f0a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ef6:	0f be c9             	movsbl %cl,%ecx
  800ef9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800efc:	39 f1                	cmp    %esi,%ecx
  800efe:	7d 0e                	jge    800f0e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800f00:	83 c2 01             	add    $0x1,%edx
  800f03:	0f af c6             	imul   %esi,%eax
  800f06:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f08:	eb c1                	jmp    800ecb <strtol+0x7e>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f0a:	89 c1                	mov    %eax,%ecx
  800f0c:	eb 02                	jmp    800f10 <strtol+0xc3>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f0e:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f14:	74 05                	je     800f1b <strtol+0xce>
		*endptr = (char *) s;
  800f16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f19:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f1b:	89 ca                	mov    %ecx,%edx
  800f1d:	f7 da                	neg    %edx
  800f1f:	85 ff                	test   %edi,%edi
  800f21:	0f 45 c2             	cmovne %edx,%eax
}
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	00 00                	add    %al,(%eax)
  800f2b:	00 00                	add    %al,(%eax)
  800f2d:	00 00                	add    %al,(%eax)
	...

00800f30 <__udivdi3>:
  800f30:	83 ec 1c             	sub    $0x1c,%esp
  800f33:	89 7c 24 14          	mov    %edi,0x14(%esp)
  800f37:	8b 7c 24 2c          	mov    0x2c(%esp),%edi
  800f3b:	8b 44 24 20          	mov    0x20(%esp),%eax
  800f3f:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f43:	89 74 24 10          	mov    %esi,0x10(%esp)
  800f47:	8b 74 24 24          	mov    0x24(%esp),%esi
  800f4b:	85 ff                	test   %edi,%edi
  800f4d:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  800f51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f55:	89 cd                	mov    %ecx,%ebp
  800f57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5b:	75 33                	jne    800f90 <__udivdi3+0x60>
  800f5d:	39 f1                	cmp    %esi,%ecx
  800f5f:	77 57                	ja     800fb8 <__udivdi3+0x88>
  800f61:	85 c9                	test   %ecx,%ecx
  800f63:	75 0b                	jne    800f70 <__udivdi3+0x40>
  800f65:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6a:	31 d2                	xor    %edx,%edx
  800f6c:	f7 f1                	div    %ecx
  800f6e:	89 c1                	mov    %eax,%ecx
  800f70:	89 f0                	mov    %esi,%eax
  800f72:	31 d2                	xor    %edx,%edx
  800f74:	f7 f1                	div    %ecx
  800f76:	89 c6                	mov    %eax,%esi
  800f78:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f7c:	f7 f1                	div    %ecx
  800f7e:	89 f2                	mov    %esi,%edx
  800f80:	8b 74 24 10          	mov    0x10(%esp),%esi
  800f84:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800f88:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800f8c:	83 c4 1c             	add    $0x1c,%esp
  800f8f:	c3                   	ret    
  800f90:	31 d2                	xor    %edx,%edx
  800f92:	31 c0                	xor    %eax,%eax
  800f94:	39 f7                	cmp    %esi,%edi
  800f96:	77 e8                	ja     800f80 <__udivdi3+0x50>
  800f98:	0f bd cf             	bsr    %edi,%ecx
  800f9b:	83 f1 1f             	xor    $0x1f,%ecx
  800f9e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fa2:	75 2c                	jne    800fd0 <__udivdi3+0xa0>
  800fa4:	3b 6c 24 08          	cmp    0x8(%esp),%ebp
  800fa8:	76 04                	jbe    800fae <__udivdi3+0x7e>
  800faa:	39 f7                	cmp    %esi,%edi
  800fac:	73 d2                	jae    800f80 <__udivdi3+0x50>
  800fae:	31 d2                	xor    %edx,%edx
  800fb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb5:	eb c9                	jmp    800f80 <__udivdi3+0x50>
  800fb7:	90                   	nop
  800fb8:	89 f2                	mov    %esi,%edx
  800fba:	f7 f1                	div    %ecx
  800fbc:	31 d2                	xor    %edx,%edx
  800fbe:	8b 74 24 10          	mov    0x10(%esp),%esi
  800fc2:	8b 7c 24 14          	mov    0x14(%esp),%edi
  800fc6:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  800fca:	83 c4 1c             	add    $0x1c,%esp
  800fcd:	c3                   	ret    
  800fce:	66 90                	xchg   %ax,%ax
  800fd0:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fd5:	b8 20 00 00 00       	mov    $0x20,%eax
  800fda:	89 ea                	mov    %ebp,%edx
  800fdc:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fe0:	d3 e7                	shl    %cl,%edi
  800fe2:	89 c1                	mov    %eax,%ecx
  800fe4:	d3 ea                	shr    %cl,%edx
  800fe6:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800feb:	09 fa                	or     %edi,%edx
  800fed:	89 f7                	mov    %esi,%edi
  800fef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ff9:	d3 e5                	shl    %cl,%ebp
  800ffb:	89 c1                	mov    %eax,%ecx
  800ffd:	d3 ef                	shr    %cl,%edi
  800fff:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801004:	d3 e2                	shl    %cl,%edx
  801006:	89 c1                	mov    %eax,%ecx
  801008:	d3 ee                	shr    %cl,%esi
  80100a:	09 d6                	or     %edx,%esi
  80100c:	89 fa                	mov    %edi,%edx
  80100e:	89 f0                	mov    %esi,%eax
  801010:	f7 74 24 0c          	divl   0xc(%esp)
  801014:	89 d7                	mov    %edx,%edi
  801016:	89 c6                	mov    %eax,%esi
  801018:	f7 e5                	mul    %ebp
  80101a:	39 d7                	cmp    %edx,%edi
  80101c:	72 22                	jb     801040 <__udivdi3+0x110>
  80101e:	8b 6c 24 08          	mov    0x8(%esp),%ebp
  801022:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801027:	d3 e5                	shl    %cl,%ebp
  801029:	39 c5                	cmp    %eax,%ebp
  80102b:	73 04                	jae    801031 <__udivdi3+0x101>
  80102d:	39 d7                	cmp    %edx,%edi
  80102f:	74 0f                	je     801040 <__udivdi3+0x110>
  801031:	89 f0                	mov    %esi,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	e9 46 ff ff ff       	jmp    800f80 <__udivdi3+0x50>
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	8d 46 ff             	lea    -0x1(%esi),%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	8b 74 24 10          	mov    0x10(%esp),%esi
  801049:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80104d:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  801051:	83 c4 1c             	add    $0x1c,%esp
  801054:	c3                   	ret    
	...

00801060 <__umoddi3>:
  801060:	83 ec 1c             	sub    $0x1c,%esp
  801063:	89 6c 24 18          	mov    %ebp,0x18(%esp)
  801067:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
  80106b:	8b 44 24 20          	mov    0x20(%esp),%eax
  80106f:	89 74 24 10          	mov    %esi,0x10(%esp)
  801073:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801077:	8b 74 24 24          	mov    0x24(%esp),%esi
  80107b:	85 ed                	test   %ebp,%ebp
  80107d:	89 7c 24 14          	mov    %edi,0x14(%esp)
  801081:	89 44 24 08          	mov    %eax,0x8(%esp)
  801085:	89 cf                	mov    %ecx,%edi
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	89 f2                	mov    %esi,%edx
  80108c:	75 1a                	jne    8010a8 <__umoddi3+0x48>
  80108e:	39 f1                	cmp    %esi,%ecx
  801090:	76 4e                	jbe    8010e0 <__umoddi3+0x80>
  801092:	f7 f1                	div    %ecx
  801094:	89 d0                	mov    %edx,%eax
  801096:	31 d2                	xor    %edx,%edx
  801098:	8b 74 24 10          	mov    0x10(%esp),%esi
  80109c:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010a0:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010a4:	83 c4 1c             	add    $0x1c,%esp
  8010a7:	c3                   	ret    
  8010a8:	39 f5                	cmp    %esi,%ebp
  8010aa:	77 54                	ja     801100 <__umoddi3+0xa0>
  8010ac:	0f bd c5             	bsr    %ebp,%eax
  8010af:	83 f0 1f             	xor    $0x1f,%eax
  8010b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b6:	75 60                	jne    801118 <__umoddi3+0xb8>
  8010b8:	3b 0c 24             	cmp    (%esp),%ecx
  8010bb:	0f 87 07 01 00 00    	ja     8011c8 <__umoddi3+0x168>
  8010c1:	89 f2                	mov    %esi,%edx
  8010c3:	8b 34 24             	mov    (%esp),%esi
  8010c6:	29 ce                	sub    %ecx,%esi
  8010c8:	19 ea                	sbb    %ebp,%edx
  8010ca:	89 34 24             	mov    %esi,(%esp)
  8010cd:	8b 04 24             	mov    (%esp),%eax
  8010d0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8010d4:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8010d8:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8010dc:	83 c4 1c             	add    $0x1c,%esp
  8010df:	c3                   	ret    
  8010e0:	85 c9                	test   %ecx,%ecx
  8010e2:	75 0b                	jne    8010ef <__umoddi3+0x8f>
  8010e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e9:	31 d2                	xor    %edx,%edx
  8010eb:	f7 f1                	div    %ecx
  8010ed:	89 c1                	mov    %eax,%ecx
  8010ef:	89 f0                	mov    %esi,%eax
  8010f1:	31 d2                	xor    %edx,%edx
  8010f3:	f7 f1                	div    %ecx
  8010f5:	8b 04 24             	mov    (%esp),%eax
  8010f8:	f7 f1                	div    %ecx
  8010fa:	eb 98                	jmp    801094 <__umoddi3+0x34>
  8010fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801100:	89 f2                	mov    %esi,%edx
  801102:	8b 74 24 10          	mov    0x10(%esp),%esi
  801106:	8b 7c 24 14          	mov    0x14(%esp),%edi
  80110a:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  80110e:	83 c4 1c             	add    $0x1c,%esp
  801111:	c3                   	ret    
  801112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801118:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80111d:	89 e8                	mov    %ebp,%eax
  80111f:	bd 20 00 00 00       	mov    $0x20,%ebp
  801124:	2b 6c 24 04          	sub    0x4(%esp),%ebp
  801128:	89 fa                	mov    %edi,%edx
  80112a:	d3 e0                	shl    %cl,%eax
  80112c:	89 e9                	mov    %ebp,%ecx
  80112e:	d3 ea                	shr    %cl,%edx
  801130:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801135:	09 c2                	or     %eax,%edx
  801137:	8b 44 24 08          	mov    0x8(%esp),%eax
  80113b:	89 14 24             	mov    %edx,(%esp)
  80113e:	89 f2                	mov    %esi,%edx
  801140:	d3 e7                	shl    %cl,%edi
  801142:	89 e9                	mov    %ebp,%ecx
  801144:	d3 ea                	shr    %cl,%edx
  801146:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80114b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80114f:	d3 e6                	shl    %cl,%esi
  801151:	89 e9                	mov    %ebp,%ecx
  801153:	d3 e8                	shr    %cl,%eax
  801155:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80115a:	09 f0                	or     %esi,%eax
  80115c:	8b 74 24 08          	mov    0x8(%esp),%esi
  801160:	f7 34 24             	divl   (%esp)
  801163:	d3 e6                	shl    %cl,%esi
  801165:	89 74 24 08          	mov    %esi,0x8(%esp)
  801169:	89 d6                	mov    %edx,%esi
  80116b:	f7 e7                	mul    %edi
  80116d:	39 d6                	cmp    %edx,%esi
  80116f:	89 c1                	mov    %eax,%ecx
  801171:	89 d7                	mov    %edx,%edi
  801173:	72 3f                	jb     8011b4 <__umoddi3+0x154>
  801175:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801179:	72 35                	jb     8011b0 <__umoddi3+0x150>
  80117b:	8b 44 24 08          	mov    0x8(%esp),%eax
  80117f:	29 c8                	sub    %ecx,%eax
  801181:	19 fe                	sbb    %edi,%esi
  801183:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801188:	89 f2                	mov    %esi,%edx
  80118a:	d3 e8                	shr    %cl,%eax
  80118c:	89 e9                	mov    %ebp,%ecx
  80118e:	d3 e2                	shl    %cl,%edx
  801190:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801195:	09 d0                	or     %edx,%eax
  801197:	89 f2                	mov    %esi,%edx
  801199:	d3 ea                	shr    %cl,%edx
  80119b:	8b 74 24 10          	mov    0x10(%esp),%esi
  80119f:	8b 7c 24 14          	mov    0x14(%esp),%edi
  8011a3:	8b 6c 24 18          	mov    0x18(%esp),%ebp
  8011a7:	83 c4 1c             	add    $0x1c,%esp
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	39 d6                	cmp    %edx,%esi
  8011b2:	75 c7                	jne    80117b <__umoddi3+0x11b>
  8011b4:	89 d7                	mov    %edx,%edi
  8011b6:	89 c1                	mov    %eax,%ecx
  8011b8:	2b 4c 24 0c          	sub    0xc(%esp),%ecx
  8011bc:	1b 3c 24             	sbb    (%esp),%edi
  8011bf:	eb ba                	jmp    80117b <__umoddi3+0x11b>
  8011c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	39 f5                	cmp    %esi,%ebp
  8011ca:	0f 82 f1 fe ff ff    	jb     8010c1 <__umoddi3+0x61>
  8011d0:	e9 f8 fe ff ff       	jmp    8010cd <__umoddi3+0x6d>
