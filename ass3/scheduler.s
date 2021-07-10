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
%macro divide 2
    pushad
    mov edx,0
    mov eax, %1
    mov ecx, %2
    div ecx
    mov dword[reminder],edx
    popad
%endmacro
%macro Find_M 0
    pushad
    mov ecx,0
    mov dword[numOfActiveDrones],ecx
    Find_First_active      ;find first active
    chande_M_to_first_active

    %%find_m_loop:
    mov edx, dword[drone_array] 
    mov edx, dword[edx+4*ecx]     ; ebx = drones[ecx]
    cmp edx, 0              ;if drone (i%N)+1 is active
    je %%next_drone
    increment_active_drones_num
    mov eax, dword[edx+N_TARGETS]     ;check its score
    cmp dword[M],eax
    ja %%change_m
    %%next_drone:
    inc ecx
    cmp ecx, dword[N]
    jne %%find_m_loop
    jmp %%end_find_m

    %%change_m:
    mov dword[M],eax
    mov dword[looser_drone_index], ecx
    jmp %%next_drone

    %%end_find_m:
    popad
%endmacro
%macro chande_M_to_first_active 0
pushad
    mov ebx, dword[winner_id]
    dec ebx
    mov dword[looser_drone_index], ebx
    mov edx, dword[drone_array]
    mov ebx, dword[edx+4*ebx]
    mov ebx, dword[ebx+N_TARGETS]
    mov dword[M],ebx
    popad
%endmacro
%macro increment_active_drones_num 0
    mov ebx, dword[numOfActiveDrones]
    inc ebx
    mov dword[numOfActiveDrones],ebx
%endmacro
%macro decrement_active_drones_num 0
pushad
    mov ebx, dword[numOfActiveDrones]
    dec ebx
    mov dword[numOfActiveDrones],ebx
    popad
%endmacro
%macro Find_First_active 0
    pushad
    mov ecx,0

    %%find_id_loop:
    mov edx, dword[drone_array] 
    mov edx, dword[edx+4*ecx]     ; ebx = drones[ecx]
    cmp edx, 0              ;if drone (i%N)+1 is active
    je %%next_id
    mov eax, dword[edx+ID]     ;check its score
    mov dword[winner_id], eax
    jmp %%winner_found
    %%next_id:
    inc ecx
    cmp ecx, dword[N]
    jne %%find_id_loop

    %%winner_found:
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
%macro myPrint 2
     pushad
    push dword[%1]				; call printf with 2 arguments -  
    push %2	            ; pointer to str and pointer to format 
    call printf
    add esp,8
    popad
%endmacro
;======================================= TESTS ===============================

%macro print_comma 1
     pushad
     push %1			; call printf with 1 arg
     call printf
     add esp,4
     popad
%endmacro

;=============================================================================

section .bss 
    reminder: resd 1
    quotient: resd 1
    numOfActiveDrones: resd 1
    looser_drone_index: resd 1
    winner_id: resd 1
    to_delete: resd 1
section .data
    i: dd 0
    M: dd 0
section .rodata
format_winner_newline: db "The Winner is drone: %d", 10, 0	; format string
format_int_newline: db "%d", 10, 0	; format int
comma: db "i: " ,0	; format comma
debug1: db "delete drone at index: %d",0 
    CODEP equ 0      ;offset of pointer to co-routine function in co-routine struct 
    SPP equ 4          ; offset of pointer to co-routine stack in co-routine struct 
    ID equ 8
    N_TARGETS equ 28
    STACK_MALLOC equ 32

section .text
    global scheduler_function
    extern printer_func
    extern resume
    extern do_resume
    extern drone_array
    extern CORS
    extern N
    extern K
    extern R
    extern SPMAIN
    extern CURR
    extern exit
    extern printf
    extern activeDroneID
    extern free
    extern CORS

scheduler_function:

    divI dword[N]
    mov edx, dword[drone_array]             ; edx = drone array
    mov ecx, dword[reminder]        ;get (i%N)
    mov edx, [edx+4*ecx]     ; ebx = drones[ecx]
    cmp edx, 0              ;if drone (i%N)+1 is active
    je print_board
    inc ecx
    mov dword[activeDroneID], ecx
    mov ebx, edx         ;(*)check==== switch to the i’th drone co-routine
    call resume

    print_board:
    divI dword[K]
    mov ecx, dword[reminder]        ;get (i%K)
    cmp ecx, 0          ;if i%K == 0 //time to print the game board
    jne strangeAritmetic
    mov ebx, [CORS]         ;get printer corutine
    call resume

    strangeAritmetic:           ;if (i/N)%R == 0 && i%N ==0 //R rounds have passed
    mov ecx, dword[i]
    cmp ecx, 0 
    je check_winner
    divI dword[N]               ;get (i/N)
    mov ecx, dword[quotient]       ;ecx <- (i/N) 
    divide dword[quotient],dword[R]   ; if = (i/N)%R == 0
    mov edx, dword[reminder]
    cmp edx,0
    jne check_winner
    
    divI dword[N]               ;if i%N ==0 //R rounds have passed
    mov ecx, dword[reminder]        ;get (i%N)
    cmp ecx,0
    jne check_winner

    Find_M                        ;find M - the lowest number of targets destroyed, between all of the active drone

    mov ebx, dword[numOfActiveDrones]           ;TODO: check if this is neseserry
    cmp ebx,1
    je check_winner

    mov edx, dword[drone_array]                        ;"turn off" one of the drones that destroyed only M targets.
    mov ecx, dword[looser_drone_index]
    mov ebx, [edx+4*ecx]     ; ebx  = drones[ecx]
    mov dword[to_delete],ebx
    mov dword[edx+4*ecx],0
    free_drone dword[to_delete]
    decrement_active_drones_num


    check_winner:
    mov eax,dword[numOfActiveDrones]                    ;if only one active drone is left
    cmp eax, 1
    jne finish_this_iteration

    Find_First_active

    myPrint winner_id,format_winner_newline                    ;print The Winner is drone: <id of the drone>
    jmp end_co          ;stop the game (return to main() function or exit)

    finish_this_iteration:              ;i++
    incrementI:
    mov ecx, dword[i]
    inc ecx
    mov dword[i], ecx
    jmp scheduler_function

end_co:
    mov esp,[SPMAIN]
    popad
    jmp exit

