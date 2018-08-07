; Stdin contains N in decimal notation
; Read it, save to EAX

%include "my_io.inc"

global read_number

section .text
read_number:
    push ebp              ; organize stack frame
    mov ebp, esp
    pushf                 ; store flags
    push ebx              ; according CDECL convention EBX should be stored
    push esi              ; according CDECL convention ESI should be stored
    xor esi, esi          ; ESI for result
    mov ebx, 10           ; decimal notation multiplier
.read_digit:
    GETCHAR               ; new symbol in AL
    cmp eax, -1
    je .quit
    cmp eax, '0'
    jnge .quit            ; not digit symbol
    cmp eax, '9'
    jnle .quit            ; not digit symbol
    xor ecx, ecx
    mov cl, al            ; free AL for multiplication
    mov eax, esi
    mul ebx               ; 10*ESI, result in EDX:EAX, suppose that N < EAX => EDX = 0
    sub cl, '0'           ; convert symbol to digit
    add eax, ecx
    mov esi, eax
    jmp .read_digit
.quit:
    mov eax, esi          ; result in EAX
    pop esi               ; clean stack frame
    pop ebx
    popf
    mov esp, ebp
    pop ebp
    ret