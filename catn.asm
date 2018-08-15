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
    buffer       resb 4096                ; will read in 4096 byte chunks
    bufzise equ $-buffer
    fdsrc        resd 1                   ; source file descriptor
    fddest       resd 1                   ; destination file descriptor
    argvp        resd 1                   ; address of begining command line args
    flag         resb 1                   ; copy with line numbers (=1) or not (=0)
    line_num     resd 1                   ; current line number                        if flag = 1
    line_beg     resd 1                   ; address of first symbol in current line    if flag = 1
    line_num_buf resb 10                  ; buffer for current line number symbols     if flag = 1

section .text
start:
    call check_arguments                 ; result in EAX, EAX = -1 if error or EAX = [flag] value
    cmp eax, -1
    je print_help_msg
    mov [flag], al                       ; save flag for main cycle

    pop ecx                              ; don't need quantity of command line elements
    mov [argvp], esp                     
    mov esi, [argvp]                     ; ESI = address of first argument

    OPEN_FILE_FOR_READ dword [esi+4]     ; 2nd arg = source file name, EAX = file descriptor or -1 if error
    cmp eax, -1
    je source_file_error
    mov [fdsrc], eax

    OPEN_FILE_FOR_WRITE dword [esi+8]     ; 3nd arg = dest file name, EAX = file descriptor or -1 if error
    cmp eax, -1
    je destination_file_error
    mov [fddest], eax

    cmp byte [flag], 1
    jne main_cycle
    mov dword [line_num], 1
    call write_line_number
 
main_cycle:
    READ_FROM_FILE buffer, bufzise         ; EAX contains num of read bytes
    cmp eax, 0
    jle .close_files

    mov ebx, eax                           ; EAX will be spoiled

    cmp byte [flag], 0
    je .simple_write
    jmp .write_with_numbers

.simple_write:
    WRITE_TO_FILE buffer, ebx
    jmp .loop

.write_with_numbers:
    xor ecx, ecx                            ; ECX = current offset
    xor esi, esi                            ; offset of first symbol of current line
    mov edi, buffer
    mov dword [line_beg], edi               ; address of first symbol of current line
.process_next_symbol:
    cmp ebx, ecx                            ; current offset = number of read bytes
    je .exit_loop_in_loop                                ; next chunk
    cmp byte [buffer+ecx], 10               ; if not new line
    jne .next_symbol
    inc ecx                                 ; print 10 symbol too
    mov edi, ecx                   
    sub edi, esi                            ; EDI quantity of symbols in current line
    WRITE_TO_FILE dword [line_beg], edi

    inc dword [line_num]                    ; begin new line
    call write_line_number

    mov edi, buffer
    add edi, ecx
    mov dword [line_beg], edi              ; change offset of first symbol in line
    mov esi, ecx
    jmp .loop_in_loop
.next_symbol:
    inc ecx
.loop_in_loop:
    jmp .process_next_symbol
.exit_loop_in_loop:                         ; print left symbols in buffer
    mov edi, ecx                   
    sub edi, esi                            ; quantity of left symbols
    WRITE_TO_FILE dword [line_beg], edi

.loop:
    jmp main_cycle

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

write_line_number:
    push ebp
    mov ebp, esp
    pushf
    push ebx                        ; according CDECL convention EBX should be stored
    push ecx                        ; ECX need in main cycle, will store digits count
    push dword 10                   ; for devide local(4)

    xor ecx, ecx
    mov eax, [line_num]

.save_in_stack:                     ; will save digits' symbols in inverse order
    inc ecx
    xor edx, edx
    div dword [local(4)]            ; divide EDX:EAX by 10
                                    ; EAX contains quotient, EDX -- reminder

    add edx, '0'                    ; get decimal symbol
    push edx                        ; push digit to stack

    cmp eax, 0                      ; EAX = 0 ?
    jne .save_in_stack

    xor ebx, ebx                    ; current digit number
.save_in_buf:
    pop edx
    mov [line_num_buf+ebx], dl
    inc ebx
    cmp ebx, ecx
    jne .save_in_buf

    mov byte [line_num_buf+ebx], ' '    ; print space after number
    inc ecx

    WRITE_TO_FILE line_num_buf, ecx
.finish:
    add esp, 4
    pop ecx
    pop ebx
    popf                    
    mov esp, ebp
    pop ebp
    ret

