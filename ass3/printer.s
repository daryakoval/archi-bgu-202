%macro testPrint 1
     pushad
    mov eax, [%1]
    mov [floatnum],eax
    myPrintFloat d  
    popad
%endmacro
%macro myPrintFloat 1
     pushad
    ffree
    fld dword[floatnum]
    fstp qword[floatnumQ]
    push dword[floatnumQ+4];
    push dword[floatnumQ]
    push format_float
    call printf
    add esp, 12
    popad
%endmacro
%macro print_new_line 0
     pushad
     push newline			; call printf with 1 arg
     call printf
     add esp,4
     popad
%endmacro
%macro print_comma 0
     pushad
     push comma			; call printf with 1 arg
     call printf
     add esp,4
     popad
%endmacro
%macro myPrint 2
     pushad
    push dword[%1]				; call printf with 2 arguments -  
    push %2	            ; pointer to str and pointer to format 
    call printf
    add esp,8
    popad
%endmacro
%macro endFunc 0
    popad			
	mov esp, ebp	
	pop ebp
	ret	
%endmacro
%macro StartFunc 0
    push ebp 			; Save caller state
    mov ebp, esp
    pushad 				; Save some more caller state
%endmacro

section .bss
     floatnum: resd 1
     floatnumQ: resq 1
     tempID: resd 1
     tempX: resd 1
     tempY: resd 1
     tempAlpha: resd 1
     tempSpeed: resd 1
     tempNumOfDestroyed: resd 1

section .rodata
format_string_newline: db "%s", 10, 0	; format string
format_int_newline: db "%d", 10, 0	; format int
format_float_newline: db "%.2f", 10, 0	; format float
format_int: db "%d", 0	; format int
format_float: db "%.2f",  0	; format float
newline: db 10,0	; format newline
comma: db "," ,0	; format comma

ID equ 8
X equ 12
Y equ 16
ANGLE equ 20
SPEED equ 24
N_TARGETS equ 28

section .text
     extern printf
     extern resume
     extern do_resume
     global printer_function
     extern N
     extern x_target
     extern y_target
     extern drone_array
     extern CORS

printer_function:
     ;print : this is the current target coordinates

     testPrint x_target
     print_comma
     testPrint y_target
     print_new_line

     mov ecx, 0          ; counter for drone array
     mov edx, dword[drone_array]             ; edx = drone array
     
     ;print :print all drones in loop
     print_loop:
     cmp ecx, dword[N]
     je finish
     mov ebx, dword[edx+4*ecx]     ; ebx = drones[ecx]
     cmp ebx,0
     je end_of_iteration

     mov eax,dword[ebx+ID]
     mov dword[tempID],eax
     myPrint tempID, format_int
     print_comma

     mov eax,[ebx+X]
     mov dword[tempX],eax
     testPrint tempX
     print_comma

     mov eax,[ebx+Y]
     mov dword[tempY],eax
     testPrint tempY
     print_comma

     mov eax,[ebx+ANGLE]
     mov dword[tempAlpha],eax
     testPrint tempAlpha
     print_comma

     mov eax,[ebx+SPEED]
     mov dword[tempSpeed],eax
     testPrint tempSpeed
     print_comma

     mov eax,dword[ebx+N_TARGETS]
     mov dword[tempNumOfDestroyed],eax
     myPrint tempNumOfDestroyed, format_int_newline

     end_of_iteration:
     inc ecx
     jmp print_loop
     finish:

     mov ebx, dword[CORS+8] 
    call resume
    jmp printer_function