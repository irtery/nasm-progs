; EAX contains some number N
; Print N to stdout in decimal notation

%include "stud_io.inc"

global start

section .text
start:
    push dword 123456
    call print
    jmp finish
print:
    push ebp              ; organize stack frame
    mov ebp, esp
    push ebx              ; according CDECL convention EBX should be stored
    mov eax, [ebp+8]      ; store number to print
    mov ebx, 10           ; decimal notation
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
.print_digits:
    pop edx
    PUTCHAR dl
    loop .print_digits
.quit:
    pop ebx               ; restore EBX
    mov esp, ebp          
    pop ebp               ; clear stack frame
    ret
finish:
    PUTCHAR 10
    FINISH
