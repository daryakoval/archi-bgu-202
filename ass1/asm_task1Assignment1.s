section	.rodata			; we define (global) read-only variables in .rodata section
format_int: db "%d", 10, 0	; format int

section .data                    	; we define (global) initialized variables in .data section

section .text
	global assFunc
	extern c_checkValidity
	extern printf

assFunc:
	push ebp
	mov ebp, esp		
	mov ebx, dword [ebp+8]	; get first argument : x
	mov ecx, dword [ebp+12]	; get second argument : y
	push ecx				; push y
	push ebx				; push x
	call c_checkValidity    ; call c function
	cmp eax, '0'			; compare c ; if 0 +
	je sum					; if 0 do +
	sub ebx, ecx			; else do sub
	jmp print
	sum:
		add ebx, ecx		; calculate x+y
	print:	
		push ebx	
		push format_int
		call printf			;print

	mov esp, ebp	
	pop ebp
	ret
