; Stdin contains N in decimal notation
; Scan it, save to EAX

%include "stud_io.inc"

global start

section .text
start:
    mov esi, 0        ; ESI for result
    GETCHAR           ; initialize ESI or quit
    cmp eax, -1
    je finish
    sub al, '0'
    mov esi, eax
    mov ebx, 10       ; decimal notation multiplier
scan_next:
    GETCHAR           ; new symbol in AL, or EAX = -1
    cmp eax, -1
    je finish
    xor ecx, ecx
    mov cl, al        ; free AL for multiplication
    mov eax, esi
    mul ebx           ; 10*ESI, result in EDX:EAX, suppose that N < EAX => EDX = 0
    sub cl, '0'       ; convert symbol to digit
    add eax, ecx
    mov esi, eax
    jmp scan_next

finish:
    mov eax, esi
    PUTCHAR 10
    FINISH
