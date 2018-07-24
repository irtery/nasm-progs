; EAX contains some number N
; Print N to stdout in decimal notation

%include "stud_io.inc"

global start

section .bss
  digits resb 20

section .text
start:
    mov eax, 213621893    ; move number to eax
    mov ecx, 0            ; digits count
    mov ebx, 10           ; decimal notation
repeat:
    xor edx, edx
    div ebx               ; divide EDX:EAX by 10
                          ; EAX contains quotient, EDX -- reminder
    add dl, '0'           ; get decimal symbol
    mov [digits+ecx], dl  ; save to digits array
    inc ecx
    test eax, eax         ; EAX = 0 ?
    jne repeat

    dec ecx
print_digits:
    PUTCHAR byte [digits+ecx]
    loop print_digits

    PUTCHAR [digits]

    PUTCHAR 10
    FINISH