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
%macro toRad 1
;result is in floatrad
finit
fldpi
fld dword[%1]
fmulp
fstp dword[floatnum]
fld dword[floatnum]
mov dword[topRange],180
fild dword[topRange]
fdivp
fstp dword[floatRad]
ffree
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
%macro testPrint 1
    mov eax, [%1]
    mov [floatnum],eax
    myPrintFloat floatnum  
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
%macro calcWithRand 2
    pushad
;;PARAM : var where to store the coordinate
    RandomGenerator         ;seed <- new random num
;; we need to compute x = floating point (seed/MAXINT)*100
    finit       ; initialize the x87 subsystem
    fld dword[seed]         ;st0= seed
    fld dword[MAXINT]      ;st1= MaxInt
    fdivp                   ;seed / MAXINT ;st0 = st1 / st0
    fild %2  ;st1= 100
    fmulp                   ; 100*(seed / MAXINT)
    fstp %1
    ffree
    popad
%endmacro

%macro checkRangeZero  3
;1=num to check  2=toprange  3=bottom range
;checke above range
finit 
mov dword[floatnum],%2
fild dword[floatnum]
fld dword[%1]
fcomip
jbe %%belowCheck
;above range

fld dword[%1]
fild dword[floatnum]
fsubp
fstp dword[%1]
ffree

;check below range
%%belowCheck:finit
mov dword[floatnum],%3
fild dword[floatnum]
fld dword[%1]
fcomip
jae %%inrange
mov dword[floatnum],%2
fld dword[%1]
fild dword[floatnum]
faddp
fstp dword[%1]
%%inrange:; in range no need to fix
ffree
%endmacro

%macro checkZero 0
    cmp cx, 0 
    je %%endcheck
    mov cx, 1
    %%endcheck:
%endmacro
%macro checkRange  3
;1=num to check  2=toprange  3=bottom range
;checke above range
finit 
mov dword[floatnum],%2
fild dword[floatnum]
fld dword[%1]
fcomip
jbe %%belowCheck
;above range

fld dword[%1]
fild dword[floatnum]
fsubp
fstp dword[%1]
ffree

;check below range
%%belowCheck:finit
mov dword[floatnum],%3
fild dword[floatnum]
fld dword[%1]
fcomip
jae %%inrange
fild dword[floatnum]
fld dword[%1]
faddp
fstp dword[%1]
%%inrange:; in range no need to fix
ffree
%endmacro
%macro caclNewCordX 3
    ;1= cord=x OR y ,2= angle, 3=speed
    toRad %2 ;floatrad=toRad(angle)
    finit 
    fld dword[floatRad]; enter angle in rad
    fcos
    fld dword[%3]; enter speed
    fmulp
    fld dword[%1] ;enter cord
    faddp
    fstp dword[%1]
    ffree
    ;now check range
    checkRangeZero %1,100,0
%endmacro
%macro caclNewCordY 3
    ;1= cord=x OR y ,2= angle, 3=speed
    toRad %2 ;floatrad=toRad(angle)
    finit 
    fld dword[floatRad]; enter angle in rad
    fsin
    fld dword[%3]; enter speed
    fmulp
    fld dword[%1] ;enter cord
    faddp
    fstp dword[%1]
    ffree
    ;now check range
    checkRangeZero %1,100,0
%endmacro
%macro print_new_line 0
     pushad
     push newline			; call printf with 1 arg
     call printf
     add esp,4
     popad
%endmacro
%macro distance 4
;1=xdrone 2=ydrone 3=xtarget 4=ytarget
finit
fld dword[%1]
fld dword[%3]
fsubp ;xdrone-xtarget
fstp dword[floatnum]
fld dword[floatnum]
fld dword[floatnum]
fmulp ;(xdrone-xtarget)^2
fstp dword[floatnum]
fld dword[%2]
fld dword[%4]
fsubp;ydrone-ytarget
fstp dword[floatnum2]
fld dword[floatnum2]
fld dword[floatnum2]
fmulp; ;(ydrone-ytarget)^2
fstp dword[floatnum2]
fld dword[floatnum]
fld dword[floatnum2]
faddp;(xdrone-xtarget)^2+(ydrone-ytarget)^2
fsqrt
fstp dword[floatdistance]
ffree
%endmacro
%macro myPrint 2
    push %1				; call printf with 2 arguments -  
    push %2	            ; pointer to str and pointer to format 
    call printf
    add esp,8
%endmacro
%macro divI 1
    pushad
    mov edx,0
    mov eax, dword[i]
    mov ecx, %1
    div ecx
    mov dword[reminder],edx
    mov dword[quotient],eax
    popad
%endmacro
%macro print_debug 1
     pushad
     push %1			; call printf with 1 arg
     call printf
     add esp,4
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
topRange: resd 1
floatHeading: resd 1
floatSpeed: resd 1
floatRad: resd 1
tempx: resd 1
tempy: resd 1
tempSpeed:resd 1
tempAngle:resd 1
floatnum2: resd 1
floatdistance: resd 1
reminder: resd 1
quotient: resd 1
randomAngle: resd 1
randomSpeed: resd 1

section .data
MAXINT: dd 65535
destroyBool: dd 0; t=1 f=0 if the drone can destroy the target

section .rodata
format_string: db "%s", 0	; format string
format_int: db "%d", 0	; format int
format_float: db "%f", 0	; format float
newline: db 10,0	; format newline
format_string_newline: db "%s", 10, 0	; format string
format_int_newline: db "%d", 10, 0	; format int
format_float_newline: db "%.2f", 10, 0	; format float
debug1: db "drone func, id: ",0	; format comma
debug2: db "drone removed taget, targets killed: ",0	; format comma
CODEP equ 0      ;offset of pointer to co-routine function in co-routine struct 
SPP equ 4          ; offset of pointer to co-routine stack in co-routine struct 
ID equ 8
X equ 12
Y equ 16
ANGLE equ 20
SPEED equ 24
N_TARGETS equ 28
STACK_MALLOC equ 32
STKSZ	equ	16*1024	     ; co-routine stack size
pi: dt    3.141592653589793238462 ; pi


section .text
global drone_function
extern printf 
extern seed
extern ONEHUNDRED
extern drone_array
extern activeDroneID
extern CORS
extern x_target
extern y_target
extern d
extern resume

drone_function:

;======================================================LIOR=======================================
generateNewAngle:
mov dword[topRange],120
calcWithRand dword[floatHeading], dword[topRange];new angle in float heading 
mov edx,0
mov dword[topRange],60      ;sub 60 from cacl withRAnd result
fld dword[floatHeading]
fild dword[topRange]
fsubp
fstp dword[floatHeading]
ffree
mov ebx,dword[drone_array]
mov ecx,dword[activeDroneID]
dec ecx
mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
mov edx,dword[ebx+ANGLE]; edx=cor[i].angle
mov dword[floatnum],edx
finit ;calc delta angle
fld dword[floatnum]
fld dword[floatHeading]
faddp
fstp dword[randomAngle]
ffree

checkRangeZero randomAngle,360,0
;now new dalta angle is in randomAngle


fenerateNewSpeed:
mov edx, 0
mov dword[topRange],20
calcWithRand dword[floatSpeed], dword[topRange]; new speed in floatspped
mov dword[topRange],10      ;sub 10 from caclwithRAnd result
fild dword[topRange]
fld dword[floatSpeed]
fsubp
fstp dword[floatSpeed]
ffree

mov ebx,dword[drone_array]
mov ecx,dword[activeDroneID]
dec ecx
mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
mov edx,dword[ebx+SPEED]; edx=cor[i].angle

finit ; calc delta speed
fld dword[ebx+SPEED]
fld dword[floatSpeed]
faddp
fstp dword[randomSpeed]
ffree
checkRangeZero randomSpeed,100,0
;now new delta speed is in randomSpeed

moveDrone:
mov ebx,dword[drone_array]
mov ecx,dword[activeDroneID]
dec ecx
mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
mov edx,[ebx+X]; edx=cors[i].x
mov dword[tempx],edx
mov edx,[ebx+Y]; edx=cors[i].y
mov dword[tempy],edx
mov edx,[ebx+ANGLE];edx=cors[i].angle
mov dword[tempAngle],edx
mov edx,[ebx+SPEED];edx=cors[i].speed
mov dword[tempSpeed],edx

caclNewCordX tempx,tempAngle,tempSpeed ;change x
caclNewCordY tempy,tempAngle,tempSpeed ;change y

mov edx,dword[tempx]
mov[ebx+X],edx;save new x
mov edx,dword[tempy]
mov[ebx+Y],edx;save new y

;now need to update the sppen and angle
mov ebx,dword[drone_array]
mov ecx,dword[activeDroneID]
dec ecx
mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
mov edx,dword[randomAngle]
mov [ebx+ANGLE],edx;update angle
mov edx,dword[randomSpeed]
mov [ebx+SPEED],edx; update speed


;=================================DASHA=====================================================================

while_MayDestroy:
    call mayDestroy
    mov eax, dword[destroyBool]
    cmp eax,0
    je change_location

    ;destroy the target
    mov ebx,dword[drone_array]
    mov ecx,dword[activeDroneID]
    dec ecx
    mov ebx,[ebx+4*ecx]     ;get to active droneID now eax points to the cors[i]
    mov edx,[ebx+N_TARGETS]
    inc edx; targets++
    mov[ebx+N_TARGETS],edx  ;update targets

    ;resume target co-routine
    mov ebx, [CORS+4]         ;get target corutine
    call resume

;=============================LIOR =====================================
change_location:

newAngle:
mov dword[topRange],120
calcWithRand dword[floatHeading], dword[topRange];new angle in float heading 
mov edx,0
mov dword[topRange],60      ;sub 60 from cacl withRAnd result
fld dword[floatHeading]
fild dword[topRange]
fsubp
fstp dword[floatHeading]
ffree
mov ebx,dword[drone_array]
mov ecx,dword[activeDroneID]
dec ecx
mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
mov edx,dword[ebx+ANGLE]; edx=cor[i].angle
mov dword[floatnum],edx
finit ;calc delta angle
fld dword[floatnum]
fld dword[floatHeading]
faddp
fstp dword[randomAngle]
ffree

checkRangeZero randomAngle,360,0
;now new dalta angle is in randomAngle

newSpeed:
mov edx, 0
mov dword[topRange],20
calcWithRand dword[floatSpeed], dword[topRange]; new speed in floatspped
mov dword[topRange],10      ;sub 10 from caclwithRAnd result
fild dword[topRange]
fld dword[floatSpeed]
fsubp
fstp dword[floatSpeed]
ffree

mov ebx,dword[drone_array]
mov ecx,dword[activeDroneID]
dec ecx
mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
mov edx,dword[ebx+SPEED]; edx=cor[i].angle

finit ; calc delta speed
fld dword[ebx+SPEED]
fld dword[floatSpeed]
faddp
fstp dword[randomSpeed]
ffree
checkRangeZero randomSpeed,100,0
;now new delta speed is in randomSpeed

moveDroneInLoop:
mov ebx,dword[drone_array]
mov ecx,dword[activeDroneID]
dec ecx
mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
mov edx,[ebx+X]; edx=cors[i].x
mov dword[tempx],edx
mov edx,[ebx+Y]; edx=cors[i].y
mov dword[tempy],edx
mov edx,[ebx+ANGLE];edx=cors[i].angle
mov dword[tempAngle],edx
mov edx,[ebx+SPEED];edx=cors[i].speed
mov dword[tempSpeed],edx


caclNewCordX tempx,tempAngle,tempSpeed ;change x
caclNewCordY tempy,tempAngle,tempSpeed ;change y

mov edx,dword[tempx]
mov[ebx+X],edx;save new x
mov edx,dword[tempy]
mov[ebx+Y],edx;save new y

;now need to update the sppen and angle
mov ebx,dword[drone_array]
mov ecx,dword[activeDroneID]
dec ecx
mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
mov edx,dword[randomAngle]
mov [ebx+ANGLE],edx;update angle
mov edx,dword[randomSpeed]
mov [ebx+SPEED],edx; update speed

;===========================DASHA=============================================
;resume scheduler co-routine by calling resume(scheduler)
    mov ebx, dword[CORS+8] 
    call resume
    jmp while_MayDestroy

    
;====================================================May Destroy=============================================
mayDestroy:
    StartFunc
    mov ebx,0
    mov dword[destroyBool],ebx        ; set bool false
    mov ebx,dword[drone_array]
    mov ecx,dword[activeDroneID]
    dec ecx
    mov ebx,[ebx+4*ecx]; get to active droneID now eax points to the cors[i]
    mov edx,[ebx+X]; edx=cors[i].x
    mov dword[tempx],edx
    mov edx,[ebx+Y]; edx=cors[i].y
    mov dword[tempy],edx
    distance tempx,tempy,x_target,y_target ;result in floatdistance 

    ; check if floatdistance <=d
    finit
    fld dword[d];load d ;st1
    fld dword[floatdistance];load distance ;st0
    fcomip;check floatdistance <=d
    ja failure; not  ;jump if st(0)>st(1)
    ;yes
    mov dword[destroyBool],1; set bool true

    failure:
    ffree
    endFunc