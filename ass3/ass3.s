%macro StartFunc 0
    push ebp 			; Save caller state
    mov ebp, esp
    pushad 				; Save some more caller state
%endmacro
%macro endFunc 0
    popad			
	mov esp, ebp	
	pop ebp
	ret	
%endmacro
%macro myMalloc 1
    push %1
    call malloc
    add esp,4
%endmacro
%macro myPrintFloat 1
    ffree
    fld dword[floatnum]
    fstp qword[floatnumQ]
    push dword[floatnumQ+4];
    push dword[floatnumQ]
    push format_float_newline
    call printf
    add esp, 12
%endmacro
%macro sscanfFromArgs 3
    push %1  ;address to save N
    push %2     ;format
    push %3; N value 
    call sscanf
    add esp, 12
%endmacro
%macro myPrint 2
    push %1				; call printf with 2 arguments -  
    push %2	            ; pointer to str and pointer to format 
    call printf
    add esp,8
%endmacro
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

%macro calcWithRand 2
    pushad
;;PARAM : var where to store the coordinate
    RandomGenerator         ;seed <- new random num
;; we need to compute x = floating point (seed/MAXINT)*100
    finit       ; initialize the x87 subsystem
    fld dword[seed]         ;st0= seed
    fld dword[MAXINT]      ;st1= MaxInt
    fdivp                   ;seed / MAXINT ;st0 = st1 / st0
    fild %2  ;st1= 100 or 120
    fmulp                   ; 100*(seed / MAXINT)
    fstp %1
    ffree
    popad
%endmacro

%macro free_drone 1
    pushad
    ;PARAM : drone address
    mov eax, %1
    mov eax, dword[eax+STACK_MALLOC]
    push eax
    call free
    add esp, 4
    mov eax, %1
    push eax
    call free
    add esp, 4
    popad
%endmacro

%macro testPrint 1
    pushad
    mov eax, [%1]
    mov [floatnum],eax
    myPrintFloat d  
    popad
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

section .bss
    global N
    N: resd 1   ;number of drones
    global R
    R: resd 1   ;number of full scheduler cycles between each elimination
    global K
    K: resd 1   ;how many drone steps between game board printings
    global b
    b: resd 1   ; angle of drone field-of-view 
    global d
    d: resd 1   ;maximum distance that allows to destroy a target
    global seed
    seed: resd 1;seed for initialization of LFSR shift register
    global drone_array
    drone_array: resd 1
    global x_target
    x_target: resd 1
    global y_target
    y_target: resd 1
    global destroybool
    destroybool: resd 1

    tempnum: resd 1

    floatnum: resd 1
    floatnumQ: resq 1
    saveEax: resd 1
    saveEbx: resd 1
    saveEcx: resd 1
    area: resd 1
    tempX: resd 1
    tempY: resd 1
    to_delete: resd 1

    global CURR
    CURR:	resd	1
    SPT:	resd	1   ; temporary stack pointer
    global SPMAIN
    SPMAIN:	resd	1   ; stack pointer of main
    STKSZ	equ	16*1024	     ; co-routine stack size
    STK1:	resb	STKSZ
    STK2:	resb	STKSZ
    STK3:	resb	STKSZ

    initSpeed: resd 1
    initAngle: resd 1

    global activeDroneID
    activeDroneID: resd 1

section .data  
    MAXINT: dd 65535
    ONEHUNDRED: dd 100
global	numco
    numco:	dd	3
    CO1:	dd	printer_function	      ; struct of first co-routine
        dd	STK1+STKSZ		
    CO2:	dd	target_function 	      ; struct of second co-routine
        dd	STK2+STKSZ	
    CO3:	dd	scheduler_function	      ; struct of scheduler
        dd	STK3+STKSZ
    global CORS
    CORS:	dd	CO1
        dd	CO2
        dd	CO3

section	.rodata	
format_string: db "%s", 0	; format string
format_int: db "%d", 0	; format int
format_float: db "%f", 0	; format float
newline: db 10,0	; format newline
format_string_newline: db "%s", 10, 0	; format string
format_int_newline: db "%d", 10, 0	; format int
format_float_newline: db "%.2f", 10, 0	; format float

CODEP equ 0      ;offset of pointer to co-routine function in co-routine struct 
SPP equ 4          ; offset of pointer to co-routine stack in co-routine struct 
ID equ 8
X equ 12
Y equ 16
ANGLE equ 20
SPEED equ 24
N_TARGETS equ 28
STACK_MALLOC equ 32

section .text
  align 16
  global main
  global resume
  global do_resume
  global exit
  extern printf
  extern fprintf 
  extern malloc 
  extern calloc 
  extern free 
  extern sscanf
  extern scheduler_function
  extern printer_function
  extern target_function
  extern drone_function


;================================================= Main ========================================================
main:
loadArgs:
    StartFunc
    mov esi, [ebp+12]; **argv
    mov ebx,1; argv index set to 1
    mov eax,[esi+ebx*4] ;put in eax argv[1]=N
    sscanfFromArgs N, format_int, eax
    inc ebx ;index++
    mov eax,[esi+ebx*4]; put in eax  argv[2]=R
    sscanfFromArgs R, format_int, eax
    inc ebx ;index++
    mov eax,[esi+ebx*4]; put in eax  argv[3]=K
    sscanfFromArgs K, format_int, eax
    inc ebx ;index++
    mov eax,[esi+ebx*4]; put in eax  argv[4]=d
    sscanfFromArgs d, format_float, eax
    inc ebx ;index++
    mov eax,[esi+ebx*4]; put in eax  argv[5]=seed
    sscanfFromArgs seed, format_int, eax

;==================================== initialize the target ==========================================================

;; Create Random Target
    coordinate_creator dword[x_target]
    coordinate_creator dword[y_target]

initCo2:    ;target func
	mov ebx, 1		; get co-routine ID number
	mov ebx, [4*ebx + CORS]	; get pointer to COi struct
	mov eax, [ebx]            ; get initial EIP value – pointer to COi function
	mov [SPT], esp	               ; save esp value
	mov esp, [ebx+SPP]                  ; get initial esp value – pointer to COi stack
	push eax 	                                         ; push initial “return” address
	pushfd		                  ; push flags
	pushad		               ; push all other registers
	mov [ebx+SPP], esp              ; save new SPi value (after all the pushes)
	mov esp, [SPT]

;==================================== initialize the drones =================================================================
    mov eax, dword[N]
    shl eax, 2
    myMalloc eax                 ;malloc for N*4 
    mov dword[drone_array],eax
    mov ecx, 0                   ;counter for num of drones initialized

initLoop:
    cmp ecx, dword[N]
    je finish_init_drones
    mov dword[saveEcx],ecx
    myMalloc 36
    mov ecx, dword[saveEcx]
    mov edx, dword[drone_array]
    mov dword[edx+ecx*4], eax              ;put new drone at drone_array[ecx] <- mallocated eax
    mov ebx, eax
    mov dword[ebx+CODEP], drone_function   ;offset of pointer to co-routine function in co-routine struct 
    mov dword[saveEbx],ebx
    myMalloc STKSZ
    mov ebx, dword[saveEbx]

    mov dword[ebx+STACK_MALLOC], eax
    add eax, STKSZ
    mov dword[ebx+SPP], eax ;put stack adrees - > point to the end of stack
    mov ecx, dword[saveEcx]
    inc ecx
    mov dword[ebx+ID], ecx
    mov eax,dword[ebx+ID]

    coordinate_creator dword[tempX] ;macro that generates x value and puts it in edx
    mov edx, dword[tempX]
    mov [ebx+X], edx

    coordinate_creator dword[tempY]; macro that generates y value and puts it in edx
    mov edx, dword[tempY]
    mov dword[ebx+Y], edx
    
    ;todo macro that generates speed value and puts it in edx
    mov dword[tempnum], 100
    calcWithRand dword[initSpeed],dword[tempnum]
    mov edx,dword[initSpeed]
    mov dword[ebx+SPEED], edx
    ;todo macro that generates angle value and puts it in edx

    mov dword[tempnum],360
    calcWithRand dword[initAngle],dword[tempnum]
    mov edx,dword[initAngle]
    mov dword[ebx+ANGLE], edx

    mov eax, 0
    mov dword[ebx+N_TARGETS], eax ;at the begining no targets was destroyed

    initDroneCo:  ;drone func
    mov ecx, dword[saveEcx]
	mov ebx, ecx	; get co-routine ID number
    mov edx, dword[drone_array]
	mov ebx, dword[4*ecx + edx]	; get pointer to COi struct;
	mov eax, [ebx]            ; get initial EIP value – pointer to COi function
	mov [SPT], esp	               ; save esp value
	mov esp, [ebx+SPP]                  ; get initial esp value – pointer to COi stack
	push eax 	                  ; push initial “return” address
	pushfd		                  ; push flags
	pushad		               ; push all other registers
	mov [ebx+SPP], esp              ; save new SPi value (after all the pushes)
	mov esp, [SPT]                  ;restore esp

    inc ecx
    jmp initLoop

finish_init_drones:
;==================================== Init 3 Co - Printer, Target, Scheduler ===============================================================
initCo1:  ;printer func
	mov ebx, 0		; get co-routine ID number
	mov ebx, [4*ebx + CORS]	; get pointer to COi struct
	mov eax, [ebx]            ; get initial EIP value – pointer to COi function
	mov [SPT], esp	               ; save esp value
	mov esp, [ebx+SPP]                  ; get initial esp value – pointer to COi stack
	push eax 	                                         ; push initial “return” address
	pushfd		                  ; push flags
	pushad		               ; push all other registers
	mov [ebx+SPP], esp              ; save new SPi value (after all the pushes)
	mov esp, [SPT]	

initCo3:    ;scheduler func
	mov ebx, 2		; get co-routine ID number
	mov ebx, [4*ebx + CORS]	; get pointer to COi struct
	mov eax, [ebx]            ; get initial EIP value – pointer to COi function
	mov [SPT], esp	               ; save esp value
	mov esp, [ebx+SPP]                  ; get initial esp value – pointer to COi stack
	push eax 	                                         ; push initial “return” address
	pushfd		                  ; push flags
	pushad		               ; push all other registers
	mov [ebx+SPP], esp              ; save new SPi value (after all the pushes)
	mov esp, [SPT]

;=================================================== Resume and Do Resume ===============================================
startCo:
	pushad			; save registers of main ()
	mov [SPMAIN], esp		; save ESP of main ()
	mov ebx, 2		; gets ID of a scheduler co-routine
	mov ebx, [ebx*4 + CORS]	; gets a pointer to a scheduler struct
	jmp do_resume

resume:	; save state of current co-routine
	pushfd
	pushad
	mov edx, [CURR]
	mov [edx+SPP], esp   ; save current ESP
do_resume:  ; load ESP for resumed co-routine
	mov esp, [ebx+SPP]
	mov [CURR], ebx
	popad  ; restore resumed co-routine state
	popfd
	ret        ; "return" to resumed co-routine


exit:
    mov ecx, -1          ; counter for drone array
    mov edx, dword[drone_array]             ; edx = drone array

    free_loop:
    inc ecx
    cmp ecx, dword[N]
    je end
    mov ebx, dword[edx+4*ecx]     ; ebx = drones[ecx]
    cmp ebx,0
    je free_loop
    mov dword[to_delete], ebx
    free_drone dword[to_delete]
    jmp free_loop
    end:

    push dword[drone_array]
    call free
    add esp,4

finalfinal:
    endFunc

