section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string
	format_hexa: db "%X", 10, 0	; format string
	format_int: db "%d", 10, 0	; format int

section .bss			; we define (global) uninitialized variables in .bss section
	an: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
	ar: resb 12

section .data       ; we define (global) initialized variables in .data section
	ten: dd 10
	num: dd 0
	acc: dd 0

section .text
	global convertor
	extern printf

convertor:
	push ebp
	mov ebp, esp	
	pushad			
	mov ecx, dword [ebp+8]	; get function argument (pointer to string)

	decimalLoop:			;convert string to num

		movzx ebx, byte[ecx]	;convert char to int : ebx<-ecx
		sub ebx,'0'				;convert char to int : ebx = ebx-'0'
		mov [num],ebx			;save the ebx into num

		mov eax, [acc] 			;move acc(prev num) into eax
		mov ebx ,[ten]			;mutiply 10
		mul ebx					;multiply	eax=eax*10
		add eax,[num]			;add num(from given string) to eax value: eax=eax+num
	
		mov [acc],eax			; now we have new value at acc <- eax
		inc ecx      	    	; increment ecx value; now ecx points to the next character of the string
		cmp byte [ecx], 10   	; check if the next character (character = byte) is zero (i.e. new line)
		jnz decimalLoop      	; if not, keep looping until meet null termination character
		mov edx, 0

	hexaLoop:			;convert acc to hexa
		mov ebx, [acc]
		and ebx, 15				;and acc with 1111 (mod16)
		cmp ebx, 9				; check if ebx is 10-15
		ja hexaChange			; if yes jmp to change		
		add ebx, 48	
	continiueLoop:
		mov [ar+edx], ebx			;save mod value
		inc edx
		mov eax, [acc]
		shr	eax, 4				;divide acc by 16, using shift 4
		mov [acc], eax						
		cmp eax, 0				;check if it the end and jmp to loop
		jnz hexaLoop
		mov ebx, 0
		dec edx
		jmp anLoop

	hexaChange:
		add ebx, 55				;change to char A-F
		jmp continiueLoop;

	anLoop: ;The Last mission - create full string!!
		mov eax, [ar+edx]
		mov [an+ebx], eax
		inc ebx
		dec edx
		cmp edx, -1	   			; check if the next character (character = byte) is zero (i.e. null terminator)
		jnz anLoop      			; if not, keep looping until meet null termination character
		mov edx,0
		mov [an+ebx],edx

	print:
		;mov [an], ecx
		push an				; call printf with 2 arguments -  
		push format_string	; pointer to str and pointer to format string
		call printf

	mov eax,0
	mov [acc],eax

	add esp, 8		; clean up stack after call

	popad			
	mov esp, ebp	
	pop ebp
	ret


