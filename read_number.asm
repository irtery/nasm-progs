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
    push edi              ; according CDECL convention ESI should be stored
    mov edi, '+'          ; EDI for number sign, will store as unsigned
    xor esi, esi          ; ESI for result
    mov ebx, 10           ; decimal notation multiplier

    GETCHAR               ; new symbol in AL
    cmp eax, -1
    je .quit
    cmp al, '-'          ; first symbol is sign symbol?
    jne .not_sign_symbol
    mov edi, '-'

.read_digit:
    GETCHAR               ; new symbol in AL
    cmp eax, -1
    je .quit
.not_sign_symbol:
    cmp al, '0'
    jnae .quit            ; not digit symbol
    cmp al, '9'
    jnbe .quit            ; not digit symbol
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
    cmp edi, '+'
    je .simple_quit
    not eax
    add eax, 1
.simple_quit:
    pop edi               ; cleanup
    pop esi
    pop ebx
    popf
    mov esp, ebp
    pop ebp
    ret