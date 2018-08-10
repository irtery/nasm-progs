; Stack contains some number N
; Print N to stdout in decimal notation

%include "my_io.inc"

global print_number

section .text
print_number:
    push ebp              ; organize stack frame
    mov ebp, esp
    pushf                 ; store flags
    push ebx              ; according CDECL convention EBX should be stored
    mov eax, [ebp+8]      ; store number to print
    push edi              ; for sign symbol
    mov edi, '+'
    mov ebx, 10           ; decimal notation
    xor ecx, ecx          ; digits count
    cmp eax, 0
    jg .save_digits      ; is positive?
    mov edi, '-'
    mov ecx, edi
    not eax
    add eax, 1

    xor ecx, ecx          ; digits count
.save_digits:
    xor edx, edx
    div ebx               ; divide EDX:EAX by 10
                          ; EAX contains quotient, EDX -- reminder
    add edx, '0'          ; get decimal symbol
    push edx              ; push digit to stack
    inc ecx
    test eax, eax         ; EAX = 0 ?
    jne .save_digits

    cmp edi, '-'         ; negative?
    jne .print_digit
    cmp [esp], dword '0'
    je .print_digit
    PUTCHAR '-'

.print_digit:
    pop edx
    PUTCHAR dl
    loop .print_digit
.quit:
    pop edi               ; restore EDI
    pop ebx               ; restore EBX
    popf
    mov esp, ebp          ; clean stack frame
    pop ebp               
    ret
