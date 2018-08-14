; Copy contents from one file to another
; ./catn source_file_name destination_file_name (-n)
; -n -- optional parameter, last argument
; if -n occurred, print also line nembers into destination file

%include "my_io.inc"

global start

extern print_number

%define arg(n) ebp+(4*n)+4
%define local(n) ebp-(4*n)

section .bss
    buffer resb 4096                     ; will read in 4096 byte chunks
    bufzise equ $-buffer
    fdsrc  resd 1                        ; source file descriptor
    fddest resd 1                        ; destination file descriptor
    flag   resb 1                        ; copy with line numbers (=1) or not (=0)

section .text
start:
    call check_arguments                 ; result in EAX, EAX = -1 if error or EAX = [flag] value
    cmp eax, -1
    je print_help_msg
    mov [flag], eax                      ; save flag for main cycle

    pop ecx                              ; don't need quantity of command line elements
    mov edi, [esp]                       ; EDI = address of args beginning

    OPEN_FILE_FOR_READ dword [edi+4]     ; 2nd arg = source file name, EAX = file descriptor or -1 if error
    cmp eax, -1
    je source_file_error
    mov [fdsrc], eax

    OPEN_FILE_FOR_WRITE dword [edi+8]    ; 3nd arg = dest file name, EAX = file descriptor or -1 if error
    cmp eax, -1
    je destination_file_error
    mov [fddest], eax

.main_cycle:
    READ_FROM_FILE buffer, bufzise      ; EAX contains num of read bytes
    cmp eax, 0
    jle .close_files

    push dword [fdsrc]
    call print_number
    add esp, 4

    ; WRITE_TO_FILE buffer, eax
    ; jmp .main_cycle

.close_files:
    CLOSE_FILE dword [fdsrc]
    CLOSE_FILE dword [fddest]
finish:
    SUCCESS_FINISH

print_help_msg:
    PRINT "Usage: ./asm <src> <dst> <-n>"
    jmp finish
source_file_error:
    PRINT "Couldn't open source file for reading"
    jmp finish
destination_file_error:
    CLOSE_FILE dword [fdsrc]
    PRINT "Couldn't open destination file for writing"
    jmp finish

check_arguments:
    push ebp
    mov ebp, esp
    pushf

    cmp dword [arg(1)], 3
    jl .error                       ; cannot be less than 3 argument line params
    mov eax, 0                      ; define flag
    cmp dword [arg(1)], 4
    jl .finish                      ; suppose simple copying (=3 args)            
                                    ; if more than 4 arguments passed, 4th can be '-n' flag
    mov ebx, dword [arg(5)]         ; as arg(1) = quantity, arg(2) = 1st param, etc
    cmp byte [ebx], '-'
    jne .finish                     ; suppose simple copying
    cmp byte [ebx+1], 'n'
    jne .finish                     ; suppose simple copying
    cmp byte [ebx+2], 0
    jne .finish                     ; suppose simple copying
    mov eax, 1                      ; suppose copying with line numbers
    jmp .finish
.error:
    mov eax, -1
.finish:
    popf                    
    mov esp, ebp
    pop ebp
    ret

