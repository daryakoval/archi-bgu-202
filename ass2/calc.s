
%macro StartFunc 0
    push ebp 			; Save caller state
    mov ebp, esp
    pushad 				; Save some more caller state
%endmacro

%macro myPrintString 1
    push %1				; call printf with 2 arguments -  
    push format_string	; pointer to str and pointer to format string
    call printf
    add esp,8
%endmacro

%macro myNewline 0
    push newline			; call printf with 1 arg
    call printf
    add esp,4
%endmacro

%macro myGetString 1
    push %1
    call gets
    add esp,4
%endmacro

%macro myMalloc 1
    saveMyRegisters
    push %1
    call malloc
    add esp,4
%endmacro

%macro saveMyRegisters 0
    mov [saveEax],eax
    mov [saveEbx],ebx
    mov [saveEcx],ecx
    mov [saveEdx],edx
%endmacro

%macro incNumOfOperations 0
    mov eax, dword[numOfOperations]
    inc eax
    mov dword[numOfOperations],eax
%endmacro

%macro freeLinkAtAdress 1
    mov eax, %1         ;lets put current link adress at eax 
    %%freeLinkLoop:
    cmp eax, 0             ;check if current != null
    je %%endFreeMacro
    mov ebx, dword[eax+1]        ;ebx <- next link address
    mov dword[saveEbx],ebx      ;backup next link address
    push eax
    call free                   ; call to free link
    add esp,4
    mov ebx, dword[saveEbx]         
    mov eax, ebx                ;eax<-next link
    jmp %%freeLinkLoop
    %%endFreeMacro:
%endmacro

%macro printOperationsNum 0
    push eax			; call printf with 2 arguments -  
    push format_Hexa_exit	; pointer to INT and pointer to format INT
    call printf
    add esp,8
%endmacro

%macro NewLinkAppend 0
    ;;PRE: before sending first link please set "first" to 1
    ;;PRE: please put new link's data at : [newLinkData]
    ;;PRE : edi holds first link adress
    cmp byte[first],1       ;is it first link at this linked list ?
    je %%newFirstLink         
    myMalloc 5                  ;else it is not first link, so we need to malloc it 
    mov ecx, 0
    mov cl,[newLinkData]
    mov byte[eax+0],cl             ;eax <- new link, data : number
    mov dword[eax+1],0               ;next = null         
    mov ebx,edi             ; get prev link 
    inc ebx  
    mov dword[ebx],eax      ; set that prev link now has next -> eax
    mov edi,eax          ;now prev link is current
    jmp %%endNewLink

    %%newFirstLink:
    mov ebx,edi              ;ebx holds first link adress
    mov ecx, 0
    mov cl,[newLinkData]       ;ecx holds data
    mov byte[ebx+0],cl             ;ebx first parameter is data
    mov dword[ebx+1],0          ;and next is null ptr
    mov byte[first],0          ;already not first link

    %%endNewLink:
%endmacro

%macro isDebug 1
    saveMyRegisters
    mov ebx, dword[debugMode] 
    cmp ebx, 0
    je %%endDebugmacro
    DebugPrint %1

    %%endDebugmacro:
%endmacro

%macro DebugPrint 1
    push %1
    push format_string_newline
    push dword[stderr]
    call fprintf
    add esp,12
%endmacro

%macro numOrLetter 1
    cmp %1, '9'				; check if @param is 10-15
	ja %%letter			; if yes jmp to change		
	sub %1, 48	
    jmp %%endLetterMacro

    %%letter:
	sub %1, 55				;change to char A-F

    %%endLetterMacro:
%endmacro

%macro helperLetOrNum 0
    ;PRE : bl contains the num we trying to convert
    cmp bl, 9				; check if bl is 10-15
	ja %%hex			        ; if yes jmp to change		
	add bl, 48
    jmp %%endhelper
    %%hex:
    add bl, 55				;change to char A-F

    %%endhelper:
%endmacro

%macro printLink 0
    ;;PRE: put first cell adress at edx!!!
    mov ebx,0
    mov bl, byte[edx]      ;; go to first link [edx] 1 byte is number ebx <- link.data
    push ebx
    push format_hexa
    call printf
    add esp,8
    ;;finished to take care of current link
%endmacro

%macro printMSBLink 0
    ;;PRE: put first cell adress at edx!!!
    mov ebx,0
    mov bl, byte[edx]      ;; go to first link [edx] 1 byte is number ebx <- link.data
    push ebx
    push format_hexa_msb
    call printf
    add esp,8
    ;;finished to take care of current link
%endmacro

%macro isDebugResult 0 
    ;;PRE : result already pushed to the stack - at last cell
    ;;if debug mode on -  every result pushed onto the operand stack
    mov ebx, dword[debugMode] 
    cmp ebx, 0
    je %%endDebugresult
    printResult
    DebugResult
    %%endDebugresult:
%endmacro

%macro printResult 0
    push format_result
    push format_string
    push dword[stderr]
    call fprintf
    add esp,12
%endmacro

%macro DebugResult 0
    mov eax, [stackSize]            ;go to last element on stack
    mov edx, [Stack]
    dec eax
    mov edx,dword[edx+4*eax]           ;lets get first cell adress we need = the link adress
    push dword[stderr]
    push edx
    call PrintListFunc
    add esp,8
    myNewline ;print \n at the end of printing
%endmacro

%macro MSBLinkMacro 0
    ;PRE: eax holds last link at linked list
    ;PRE: edx holds num of digits
    cmp byte[eax], 15   ;check if it is one diget or two
    ja %%add2
    add edx, 1
    jmp %%endMSBmacro
    %%add2:
    add edx, 2
    %%endMSBmacro:
%endmacro

%macro Duptail 0
    %%DupTailLoop:
    mov ecx, 0
    mov cl, byte [eax]      ; go to first link [eax] 1 byte is number cl <- link.data
    mov byte[newLinkData], cl
    NewLinkAppend   ;new link data at [newLinkData], first link adress at edi
    mov eax, [saveEax]  ;restore : eax holds adress of upper list (first link)
    inc eax         ;inc eax (after reading num[byte]) ang get next adress
    cmp dword[eax], 0        ;;if next (address + 1 ) == NULL we finished,
    je %%endDuptail
    mov eax, dword[eax] ;lets get the value inside the adress {sypposed to be next link adress}
    jmp %%DupTailLoop
    %%endDuptail:
%endmacro

%macro DeleteLeadingZeroes 0
;delete zeros
    mov dword[temp],1; set temp to 1
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    mov ebx, dword[ebx+4*edx] ;ebx holds the address of top stack linkedlist
    ;find the end of the list-we need to save the address of the last link
    
    mov dword[saveStart],ebx ;save the first link
    mov dword[saveCurr],ebx ;save current link
    mov dword[saveEnd],ebx  ;save temporry the first link to be last
    mov dword[savePrev],ebx ;save temporry the pret to be start

    %%findlastLoop:
    mov ebx,dword[saveCurr]; take the current link
    inc ebx ;next address
    mov ebx,[ebx]
    mov dword[saveCurr],ebx
    cmp ebx,0 ;if end
    je %%endfound
    mov dword[saveEnd],ebx; update end link
    mov eax,dword[temp]
    cmp eax,1
    je %%skippreset
    
    mov eax,dword[savePrev]; eax=prev
    inc eax
    mov eax, [eax] ; prev=prev->next
    mov dword[savePrev],eax
    %%skippreset:
    mov dword[temp],0 ;chang temp to 0
    jmp %%findlastLoop

    %%endfound:
    mov edx,0
    mov ebx,dword[saveStart]; ebx=first address
    mov ecx,dword[saveEnd]; ecx=last address
    cmp ebx,ecx ;last=first
    je %%noNeedDel;finished
    mov dl, byte[ecx];edx=value of last link
    cmp dl,0
    jne %%noNeedDel; last link isnt 0 we finished
    ;case 2- last is 0 we need to delete
    freeLinkAtAdress ecx ;we fre last link and need to find the last again
    mov edx,dword[savePrev]; edx=prev
    inc edx
    mov dword[edx],0; set prev->next to null
    mov dword[temp],1 ;reset temp
    mov eax,dword[saveStart]
    mov dword[saveCurr],eax ;reset current
    mov dword[saveEnd], eax ;reset end
    mov dword[savePrev],eax ;reset prev
    jmp %%findlastLoop

    %%noNeedDel:
%endmacro

section .bss
    input: resb 82
    buff: resb 80
    output: resb 3
    operationsNumString: resb 12
    currentStackPointer: resd 1  
    Stack: resd 1
    saveEax: resd 1
    saveEbx: resd 1
    saveEax2: resd 1
    saveEbx2: resd 1
    saveEcx: resd 1
    saveEdx: resd 1
    saveN: resd 1
    first: resb 1            ;boolean to check if it is first link in linked list
    opNum: resb 12          ;to print num of operations at the end
    newLinkA: resd 1
    saveNewLinkedist: resd 1        ;newAND
    saveNum1: resd 1                ;newAND
    saveNum2: resd 1                ;newAND
    saveStart: resd 1               ;newAND
    saveEnd: resd 1                 ;newAND
    saveCurr: resd 1                ;newAND
    savePrev:    resd 1           ;newAND
    temp: resd 1                     ;newAND
    car: resb 1                   ;newPLUS 
    toDel1: resd 1                ;newAND
    toDel2: resd 1                 ;newAND
    toDelete1: resd 1
    toDelete2: resd 1

section .data       ; we define (global) initialized variables in .data section
    sixteen: dd 0x10
	num: dd 0
	acc: dd 0
    stackGivenSize: dd 5       ;wasnt initialized yet - by deafult the stack size is 5
    debugMode: dd 0             ;0 = debug mode turned off, 1 = debug mode turned on;
    calc: db "calc: ",0
    errorOverFlow: db "Error: Operand Stack Overflow",10, 0
    errorArguments: db "Error: Insufficient Number of Arguments on Stack",10,0
    argc: dd 0
    argv: dd 0
    numOfOperations: dd 0       ;we will need to return it ant the end of function
    stackSize: dd 0             ;first we have an empty stack
    numberLen: dd 0             
    newLinkData: db 0           ;we will use it to save data for next link
    ;first: db 0             ;boolean to check if it is first link in linked list
    handleQuitDebug: db 10,"User entered quit command. Exiting...",10,0
    handlePlusDebug: db 10,"User entered PLUS command.",10,0
    handlePNPDebug: db 10,"User entered Pop And Print command.",10,0
    handleDupDebug: db 10,"User entered Duplicate command.",10,0
    handleANDDebug: db 10,"User entered AND command.",10,0
    handleORDebug: db 10,"User entered OR command.",10,0
    handleNDebug: db 10,"User entered Number Of Hexa Digits command.",10,0

section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 0	; format string
    newline: db 10,0	; format newline
    format_string_newline: db "%s", 10, 0	; format string
	format_hexa: db "%02X", 0	; format hexanum
    format_hexa_msb: db "%X", 0	; format hexanum
	format_int: db "%d", 10, 0	; format int
    format_Hexa_exit: db "%X", 10, 0	; format hexa
    format_result: db "New RESULT pushed to the stack: " ,0

section .text
  align 16
  global main
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern getchar 
  extern fgets 
  extern gets
  extern stderr
  extern stdin

;================================================= Main ========================================================
main:
    StartFunc
    mov eax, [ebp+8]	; Copy function args to registers: leftmost... ecx = argc
    mov ebx, [ebp+12] 	; Next argument... ebx = argv[]
    mov [argc],eax
    mov dword[argv],ebx
    call myCalc
    MainEnd:
    printOperationsNum
    popad			
	mov esp, ebp	
	pop ebp
	ret			

;;============================================== myCalc ===============================================
myCalc:
    push ebp              		; save Base Pointer (bp) original value
    mov ebp, esp         		; use Base Pointer to access stack contents 
    pushad                   	; push all signficant registers onto stack (backup registers values)
    mov eax, dword[argc]
    mov ebx, dword[argv]
    jmp checkArguments      ; start : get all arguments, check if debug mode, check the size of stack
    backToMain:
    CalcLoop:                   ; print calc and wait for user to enter number 
    myPrintString calc
    push buff
    call gets              ;recive users string   ;al <-- char from the user
    add esp,4
    mov eax,buff
    jmp compareOperators           ;compare recived string to one of operators, else it is number :(
    end:
        popad                    	; restore all previously used registers
        mov eax,dword[numOfOperations]         		;(returned values are in eax)
        mov esp, ebp			        ; free function activation frame
        pop ebp				        ; restore Base Pointer previous value (to returnt to the activation frame of main(...))
        ret				            

;;============================================== checkArguments ===============================================
; start : get all arguments, check if debug mode, check the size of stack 
checkArguments:
    cmp eax,1           ;check the number of arguments
    je createStack       ;no args so back to main

    checkIfFirstD:               
    mov ecx,[ebx+4]             ;ecx = argv[1]
    cmp byte [ecx],'-'          ;check if argv[1] is "-d"
    jnz checkIfSecondD               ;first arg is not -d, so it number
    inc ecx
	cmp byte[ecx], 'd'
    jne checkIfSecondD          ;yes it is "-d", lets change it, if it not, jmp to check second arg
    mov edx, 1
    mov [debugMode], edx        ;turn on debug mode
    jmp secondIsNum

    FirstIsNum:                     ;if we got here so argv[1] != "-d", and we dont have argv[2],or argv[2]!="-d" so it should be hexaloop
    mov ecx,[ebx+4]                 ;ecx = argv[1]
    jmp hexaLoop                 ;now we will have at acc the num of stack size

    checkIfSecondD:
    cmp eax, 3              
    jne FirstIsNum           ;no second
    mov ecx,[ebx+8]         ;ecx = argv[2]
    cmp byte [ecx],'-'      ;check if argv[2] is "-d"
    jne FirstIsNum
    inc ecx
	cmp byte[ecx], 'd'
    jne FirstIsNum          ;yes it is "-d", lets change debugMode
    mov edx, 1
    mov [debugMode], edx
    jmp FirstIsNum  

    secondIsNum:      ;got here because : argv[1] ="-d"
    cmp eax, 3              ;
    jne createStack           ;no argv[2] ;else second is number 
    mov ecx,[ebx+8]                 ;ecx = argv[2]
    jmp hexaLoop            ;now we will have at acc the num of stack size

    createStack:
    push 20                ; malloc size of defualt stack = 5 *4 bytes
    call malloc
    add esp,4
    mov [Stack],eax
    jmp backToMain

hexaLoop:			;convert string to num
    movzx ebx, byte[ecx]	;convert char to int : ebx<-ecx
    numOrLetter ebx
    mov [num],ebx			;save the ebx into num
    mov eax, [acc] 			;move acc(prev num) into eax
    mov ebx ,[sixteen]		;mutiply 16
    mul ebx					;multiply	eax=eax*16
    add eax,[num]			;add num(from given string) to eax value: eax=eax+num
    mov [acc],eax			; now we have new value at acc <- eax
    inc ecx      	    	; increment ecx value; now ecx points to the next character of the string
    cmp byte [ecx], 0   	; check if the next character (character = byte) is zero (i.e.)
    jnz hexaLoop      	    ; if not, keep looping until meet null termination character
    mov edx, [acc]
    mov [stackGivenSize], edx
    shl edx,2               ;muliply the size by 4
    push edx                ; malloc size of given stack
    call malloc
    add esp,4
    mov [Stack],eax
    jmp backToMain               ;back to main

;;============================================== checkUserInput ===============================================

compareOperators:
    cmp byte[eax], 'q'
    je handleQuit
    cmp byte[eax], '+'
    je handlePlus
    cmp byte[eax], 'p'
    je handlePopAndPrint
    cmp byte[eax], 'd'
    je handleDuplicate
    cmp byte[eax], '&'
    je handleAND
    cmp byte[eax], '|'
    je handleOR
    cmp byte[eax], 'n'
    je handleNumberOfN

 createNumber:
    isDebug eax           ;if debug mode is on : print out every number read from the user
    mov eax, [saveEax]
    mov ecx, [stackSize]            ;first check if there no overflow
    cmp dword[stackGivenSize],ecx
    je handleStackOwerflow
    mov edx, 0                      ;edx will be counter for how many numbers we put to buff
    
    loopingStringByChar:
    cmp byte[eax],0                ; string ended ;
    je FINISH_NUMBER
    inc edx
    inc eax
    jmp loopingStringByChar
    
    FINISH_NUMBER:
    mov [numberLen],edx             ;save recived string length
    myMalloc 5                      ;malloc for first link, eax has the link
    mov edi,eax   ;save first link pointer, we will add it to the stack
    mov byte[first],1                   ;save that this link is first
    mov ebx,[stackSize]             ;
    mov ecx,[Stack]
    mov dword[ecx+4*ebx],eax           ;lets put the new link to the top of stack
    inc ebx
    mov [stackSize],ebx             ;now size of stack was increased
    jmp addNumToLink

;;================================================Stack Managment Functions ==========================================
freeMemory:
    freeNextLink:
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    cmp edx, 0
    je freeStack
    dec edx
    mov dword[stackSize],edx
    mov eax, dword[ebx+4*edx]  ;mov eax <- [stack+4*stacksize] , now eax holds upper link adress
    freeLinkAtAdress eax
    jmp freeNextLink
    freeStack:
    mov ebx, dword[Stack]
    push ebx
    call free
    add esp,4
    jmp end

addNumToLink:
    mov edx,[numberLen]        
    cmp edx, 0        ;if len 0 we finished to read this num and creating linked list
    je BeforeCalcLoop
    cmp edx, 1        ;if len 1, this string has odd num of characters
    je oddNum                
    sub edx,2
    mov [numberLen],edx
    jmp hexaTwice             ;if len 2 and more, contuniue to create links

BeforeCalcLoop:
    DeleteLeadingZeroes
    jmp CalcLoop

;===============================================Hexa Help Transport Numbers ============================================
hexaTwice:			;convert string to num
    mov ecx, buff
    add ecx, edx      ;get first of two numbers to change
    movzx ebx, byte[ecx]	;convert char to int : ebx<-ecx
    numOrLetter ebx
    mov eax, ebx   	    	;move first num into eax
    mov ebx ,dword[sixteen]		;mutiply 16
    mul ebx					;multiply	eax=eax*16
    inc ecx      ;get second of two numbers to change
    movzx ebx, byte[ecx]	;convert char to int : ebx<-ecx
    numOrLetter ebx
    add eax,ebx			    ;add num(from given string) to eax value: eax=eax*16+ebx
    mov [newLinkData], eax
    NewLinkAppend
    jmp addNumToLink


oddNum:
    sub edx,1               ;reduce num of len, now len is 0,
    mov [numberLen],edx
    mov ecx, buff           ;we want to create link with only one num - the first
    movzx ebx, byte[ecx]	;convert char to int : ebx<-ecx
    numOrLetter ebx
    mov [newLinkData], ebx
    NewLinkAppend 
    jmp addNumToLink      

PrintListFunc:
    push ebp              		; save Base Pointer (bp) original value
    mov ebp, esp         		; use Base Pointer to access stack contents (do_Str(...) activation frame)
    pushad                   	; push all signficant registers onto stack (backup registers values)
    mov edx, dword [ebp+8]	    ; get first argument : edx <- link adress 
    mov eax, dword [ebp+12]	    ; get second argument : eax <- stdin/stderr 
    inc edx                     ;get link.next
    cmp dword[edx], 0              ;;if next (address + 1 ) == NULL we finished,
    jne nextLink
    dec edx     ;get back edx = link address
    printMSBLink
    jmp endPrint
    nextLink:
    mov ecx, dword[edx]       ;lets get the value inside the adress {sypposed to be next link adress}
    push eax
    push ecx
    call PrintListFunc ;first print next link
    add esp,8
    dec edx
    printLink
    endPrint:
    popad           ; restore all previously used registers
    mov esp, ebp	; free function activation frame
    pop ebp			; restore Base Pointer previous value (to returnt to the activation frame of main(...))
    ret				; returns from do_Str(...) function

;;===============================================HandleOperators and Errors===================================================
handleQuit:
    isDebug handleQuitDebug
    jmp freeMemory

handlePlus:
    isDebug handlePlusDebug
    incNumOfOperations
    mov eax, [stackSize]            ;first check if there no underflow
    cmp eax,2
    jb handleNoNumbersOnStack

    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    mov ebx, dword[ebx+4*edx]       ;mov to ebx <- [stack+(4*stacksize)] , ebx holds adress of upper list (first link)
    mov dword[saveNum1],ebx         ;save first address of num1
    mov dword[toDel1],ebx           ;save address to delete
    mov ebx, dword[Stack]
    dec edx
    mov ecx, dword[ebx+4*edx]        ;mov to ecx <- [stack+(4*stacksize)] , ecx holds adress of seccond upper list (first link)
    mov dword[saveNum2],ecx         ;save first address of num2
    mov dword[toDel2] ,ecx          ;save addres to del         
    ;update stack szie
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx

    mov dword[stackSize],edx; stacksize reduce by 1 and the 2 numbers removed from stack

    mov byte[first], 1    ;set that we will create first link
    myMalloc 5              ; allocate memory for first link
    mov edi,eax         ;edi holds first link adress

    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    mov dword[ebx+4*edx],eax           ;lets put the new link to the top of stack
    inc edx
    mov dword[stackSize],edx             ; now size of stack was increased-> stcksize is correnct anf new list add to thr top of the stack
    ;NEED to eval newlink data
    clc ; set carry flag to 0
    mov byte[car],0 ;save cf=0

    plusLoop:
    mov ecx,0
    mov eax,0
    mov ebx,dword[saveNum1]; take link from num1
    mov cl,byte[ebx]; take val of num1 link
    inc ebx; next link
    mov ebx,[ebx]
    mov dword[saveNum1],ebx;save num1 next link
    mov ebx, dword[saveNum2];take link from n2
    mov al,byte[ebx];take val of num2 link
    inc ebx;next link
    mov ebx,[ebx]
    mov dword[saveNum2],ebx;save num 2 next link
    doplus:cmp byte[car],0
    jne cfsetone
    clc;set cf to 0
    jmp skip2
    cfsetone:
    stc; set cf to 1
    ;cl+al+cf
    skip2:adc cl,al ;add with carry
    jc saveCF1
    mov byte[car],0 ;save cf=0
    jmp skip
    saveCF1:
    mov byte[car],1 ;save cf=1
    skip:mov byte[newLinkData],cl ;newData=cl

    NewLinkAppend
    ;now i need to check when the num is finished
    mov ebx,dword[saveNum1]; take next link of num1
    cmp ebx,0;check if num1 finished
    je case1
    jmp case3

    case1:;num1 done num2 done
    mov ebx,dword[saveNum2] ;take next link pf num2
    cmp ebx,0;check if num2 finished
    je endplus
    jmp case2

    case2:;num1 done num2 not
    mov ecx,0
    mov eax,0
    mov cl,0 ;cl is now 0
    mov ebx, dword[saveNum2];take link from n2
    mov al,byte[ebx];take val of num2 link
    inc ebx;next link
    mov ebx,[ebx]
    mov dword[saveNum2],ebx;save num 2 next link
    jmp doplus
    
    case3:;num1 not num2 done
    mov ebx,dword[saveNum2]; take next link of num2
    cmp ebx,0;check if num2 finished
    jne case4
    mov ecx,0
    mov eax,0
    mov ebx,dword[saveNum1]; take link from num1
    mov cl,byte[ebx]; take val of num1 link
    inc ebx; next link
    mov ebx,[ebx]
    mov dword[saveNum1],ebx;save num1 next link
    mov al,0 ;now al is 0
    jmp doplus

    case4:;num1 not num2 not
    jmp plusLoop

    endplus:
    mov bl,byte[car]
    cmp bl,0
    je noNeedtoAdd
    mov byte[newLinkData],bl
    NewLinkAppend

    noNeedtoAdd:
    mov eax, dword[toDel1]
    freeLinkAtAdress eax
    mov eax,dword[toDel2]
    freeLinkAtAdress eax

    isDebugResult
    jmp CalcLoop
handlePopAndPrint:
    isDebug handlePNPDebug
    incNumOfOperations
    mov eax, [stackSize]            ;first check if there no underflow
    cmp eax,0
    je handleNoNumbersOnStack
    mov eax, [stackSize]            ;go to last element on stack
    mov edx, [Stack]
    dec eax
    mov [stackSize],eax             ;we will have now less elements on stack
    mov edx,dword[edx+4*eax]           ;lets get first cell adress we need = the link adress
    push dword[stdin]
    push edx
    call PrintListFunc
    add esp,8
    myNewline ;print \n at the end of printing
    ;; free memory at stackSize+1
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    mov eax, dword[ebx+4*edx]               ;mov to eax <- [stack+(4*stacksize)]
    freeLinkAtAdress eax
    jmp CalcLoop


handleDuplicate:
    isDebug handleDupDebug
    incNumOfOperations
    mov eax, [stackSize]            ;first check if there no underflow
    cmp eax,0
    je handleNoNumbersOnStack
    mov eax, [stackSize]            ;first check if there no owerflow
    cmp dword[stackGivenSize],eax
    je handleStackOwerflow

    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    mov ebx, dword[ebx+4*edx]       ;mov to ebx <- [stack+(4*stacksize)] , ebx holds adress of upper list (first link)
    mov byte[first], 1    ;set that we will create first link
    myMalloc 5              ; allocate memory for first link
    mov edi,eax         ;edi holds first link adress
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    mov dword[ebx+4*edx],eax           ;lets put the new link to the top of stack
    inc edx
    mov dword[stackSize],edx             ; now size of stack was increased
    mov ebx, [saveEbx]  ;restore : ebx holds adress of upper list (first link)
    
    DupLoop:
    mov ecx, 0
    mov cl, byte [ebx]      ; go to first link [ebx] 1 byte is number cl <- link.data
    mov byte[newLinkData], cl
    NewLinkAppend   ;new link data at [newLinkData], first link adress at edi
    mov ebx, [saveEbx]  ;restore : ebx holds adress of upper list (first link)
    inc ebx         ;inc ebx (after reading num[byte]) ang get next adress
    cmp dword[ebx], 0        ;;if next (address + 1 ) == NULL we finished,
    je DupEND
    mov ebx, dword[ebx] ;lets get the value inside the adress {sypposed to be next link adress}
    jmp DupLoop
    
    DupEND:
    isDebugResult
    jmp CalcLoop

handleAND:
    isDebug handleANDDebug
    incNumOfOperations
    mov eax, [stackSize]            ;first check if there no underflow
    cmp eax,2
    jb handleNoNumbersOnStack

    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    mov ebx, dword[ebx+4*edx]       ;mov to ebx <- [stack+(4*stacksize)] , ebx holds adress of upper list (first link)
    mov dword[saveNum1],ebx         ;save first address of num1
    mov dword[toDel1],ebx
    mov ebx, dword[Stack]
    dec edx
    mov ecx, dword[ebx+4*edx]        ;mov to ecx <- [stack+(4*stacksize)] , ecx holds adress of seccond upper list (first link)
    mov dword[saveNum2],ecx         ;save first address of num2
    mov dword[toDel2],ecx
    ;update stack szie
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    
    mov dword[stackSize],edx; stacksize reduce by 1 and the 2 numbers removed from stack

    mov byte[first], 1    ;set that we will create first link
    myMalloc 5              ; allocate memory for first link
    mov edi,eax         ;edi holds first link adress
    
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    mov dword[ebx+4*edx],eax           ;lets put the new link to the top of stack
    inc edx
    mov dword[stackSize],edx             ; now size of stack was increased-> stcksize is correnct anf new list add to thr top of the stack

    ANDloop:
    mov ecx,0
    mov eax,0
    mov ebx,dword[saveNum1]; take link from num1
    mov cl,byte[ebx]; take val of num1 link
    inc ebx; next link
    mov ebx,[ebx]
    mov dword[saveNum1],ebx;save num1 next link
    mov ebx, dword[saveNum2];take link from n2
    mov al,byte[ebx];take val of num2 link
    inc ebx;next link
    mov ebx,[ebx]
    mov dword[saveNum2],ebx;save num 2 next link
    and cl,al;make and 
    mov byte[newLinkData],cl;save  new data
    NewLinkAppend; add new link to ANDnum
    mov ebx,dword[saveNum1]; take next link of num1
    cmp ebx,0;check if num1 finished
    je endAND
    mov ebx,dword[saveNum2];take next link of num2
    cmp ebx,0; check if num2 finished
    je endAND
    jmp ANDloop 

    endAND:; free 2 numbers
    
    mov eax,dword[toDel1]
    freeLinkAtAdress eax
    mov eax, dword[toDel2]
    freeLinkAtAdress eax
    
    DeleteLeadingZeroes
    isDebugResult
    jmp CalcLoop

handleOR:
    isDebug handleORDebug
    incNumOfOperations
    mov eax, [stackSize]            ;first check if there no underflow
    cmp eax,2
    jb handleNoNumbersOnStack
    mov ebx, dword[Stack]                   ; I want to access last linked list
    mov edx, dword[stackSize]
    dec edx
    mov eax, dword[ebx+4*edx]               ;mov to eax <- [stack+(4*stacksize-1)]
    mov dword[toDelete1], eax
    dec edx
    mov eax, dword[ebx+4*edx]               ;mov to eax <- [stack+(4*stacksize-2)]
    mov dword[toDelete2],eax
    ;now I have two adresses for 2 linked list that I need to handle or 
    mov byte[first], 1    ;set that we will create first link
    myMalloc 5              ; allocate memory for first link
    mov dword[newLinkA],eax         ;newLinkA holds first link adress
    mov edi,eax
    mov eax,dword[toDelete1]
    mov ebx,dword[toDelete2]

    OrLoop: 
    mov ecx, 0
    mov cl, byte [eax]      ; go to first link [eax] 1 byte is number cl <- link.data
    mov dl, byte [ebx] 
    or cl, dl
    mov byte[newLinkData], cl
    mov dword[saveEax],eax
    mov dword[saveEbx],ebx
    NewLinkAppend   ;new link data at [newLinkData], first link adress at edi
    mov eax,dword[saveEax]
    mov ebx,dword[saveEbx]
    inc eax
    inc ebx         ;inc ebx (after reading num[byte]) ang get next adress
    cmp dword[eax], 0        ;;if next (address + 1 ) == NULL we finished first link
    je duptail1
    cmp dword[ebx],0        ;if next (address + 1 ) == NULL we finished second link
    je duptail2
    mov eax, dword[eax] ;lets get the value inside the adress {sypposed to be next link adress}
    mov ebx, dword[ebx] ;lets get the value inside the adress {sypposed to be next link adress}
    jmp OrLoop

    duptail1: ;;got here if first link finished
    cmp dword[ebx],0        ;if next (address + 1 ) == NULL we finished second link too
    je endOR
    mov eax, dword[ebx] ;lets get the value inside the adress {sypposed to be next link adress}
    Duptail
    jmp endOR

    duptail2: ;;got here if second link finished but first not
    mov eax, dword[eax] ;lets get the value inside the adress {sypposed to be next link adress}
    Duptail

    endOR:
    mov eax, dword[toDelete1]
    freeLinkAtAdress eax
    mov eax, dword[toDelete2]
    freeLinkAtAdress eax
    mov ebx, dword[Stack]              
    mov edx, dword[stackSize]
    dec edx
    mov dword[stackSize], edx
    dec edx
    mov eax, dword[newLinkA]
    mov dword[ebx+4*edx], eax              ;mov to [stack+(4*stacksize-1)] <- new link
    isDebugResult
    jmp CalcLoop

handleNumberOfN:
    isDebug handleNDebug
    incNumOfOperations
    mov eax, dword[stackSize]            ;first check if there no underflow
    cmp eax,0
    je handleNoNumbersOnStack
    mov ebx, dword[Stack]                   ; I want to access last linked list
    mov edx, dword[stackSize]
    dec edx
    mov eax, dword[ebx+4*edx]               ;mov to eax <- [stack+(4*stacksize-1)]
    mov edx, 0 ;edx is new counter

    ;eax holds first link adress
    countNloop:
    cmp dword[eax+1], 0   ;if next null
    je MSBLink      ;msb may have less than 2 digits
    add edx, 2      ;else it is not msb, and have 2 digits
    mov eax, dword[eax+1]  ;put next link in eax
    jmp countNloop

    MSBLink:
    MSBLinkMacro
    mov dword[saveN],edx  ;save N numbers
    mov byte[first], 1    ;set that we will create first link
    myMalloc 5              ; allocate memory for first link
    mov dword[newLinkA],eax         ;newLinkA holds first link adress
    mov edi,eax 
    mov edx, dword[saveN]  ; restore N numbers 

    NLoop:
    and edx, 0xff
    mov byte[newLinkData], dl
    NewLinkAppend   ;new link data at [newLinkData], first link adress at edi
    mov edx, dword[saveN]
    shr edx, 8
    mov dword[saveN],edx  ;save new N numbers after divide
    cmp edx, 0
    jne NLoop
    
    ;;at the end
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    mov eax, dword[ebx+4*edx]               ;mov to eax <- [stack+(4*stacksize-1)]
    freeLinkAtAdress eax                    ;free prev link
    mov ebx, dword[Stack]
    mov edx, dword[stackSize]
    dec edx
    mov eax, dword[newLinkA]                ;push new link
    mov dword[ebx+4*edx] ,eax              ;mov to eax -> [stack+(4*stacksize-1)]
    isDebugResult
    jmp CalcLoop

handleStackOwerflow:
    myPrintString errorOverFlow
    jmp CalcLoop
handleNoNumbersOnStack:
    myPrintString errorArguments
    jmp CalcLoop
