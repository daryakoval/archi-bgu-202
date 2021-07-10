%macro RandomGenerator 0
    mov edx,0
    %%random_loop:
    mov ax, word[seed]
    mov bx, 1           ;mask for 16's bit
    and bx, ax          ;get 16's bit bx <- 16
    mov cx, 4           ; mask for 14 bit
    and cx, ax          ;get 14's bit 
    checkZero 
    xor bx, cx          ;first xor : bx holds first xor result
    mov cx, 8           ; mask for 13 bit
    and cx, ax          ;get 13's bit 
    checkZero 
    xor bx,cx           ;second xor : bx holds second xor result
    mov cx, 32          ; mask for 11 bit
    and cx, ax          ;get 11's bit 
    checkZero 
    xor bx,cx           ;third xor : bx holds thirs xor result
    shl bx,15           ;mov bx value to the begining
    shr ax,1            ;shift seed value right
    or ax, bx
    mov word[seed],ax
    inc edx
    cmp edx,16
    jne %%random_loop
%endmacro

%macro checkZero 0
    cmp cx, 0 
    je %%endcheck
    mov cx, 1
    %%endcheck:
%endmacro

%macro coordinate_creator 1
    pushad
;;PARAM : var where to store the coordinate
    RandomGenerator         ;seed <- new random num
;; we need to compute x = floating point (seed/MAXINT)*100
    finit       ; initialize the x87 subsystem
    fld dword[seed]         ;st0= seed
    fld dword[MAXINT]       ;st1= MaxInt
    fdivp                   ;seed / MAXINT ;st0 = st1 / st0
    fild dword[ONEHUNDRED]  ;st1= 100
    fmulp                   ; 100*(seed / MAXINT)
    fstp %1
    ffree
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
%macro print_debug 0
     pushad
     push debug			; call printf with 1 arg
     call printf
     add esp,4
     popad
%endmacro

section .rodata
    debug: db "target func ",10,0	; format comma
section .data  
    MAXINT: dd 65535
    ONEHUNDRED: dd 100

section .text
    extern resume
    extern x_target
    extern y_target
    extern seed
    global target_function
    global createTarget
    extern destroybool
    extern drone_array
    extern activeDroneID
    extern printf
target_function:
    call createTarget; create new target
    mov edx, dword[drone_array]             ; edx = drone array
    mov ecx, dword[activeDroneID]        ;get (i%N)
    dec ecx
    mov ebx, [edx+4*ecx]     ; ebx = drones[ecx]
    call resume
    jmp target_function

createTarget:
    StartFunc
    coordinate_creator dword[x_target]
    coordinate_creator dword[y_target]
    endFunc


