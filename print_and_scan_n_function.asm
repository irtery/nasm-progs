; Stdin contains N in decimal notation
; Scan it, save to EAX

%include "stud_io.inc"

global start

section .text
start:
    call scan
    push eax
    call print            ; check
    jmp finish
scan:
    push ebp              ; organize stack frame
    mov ebp, esp
    push ebx              ; according CDECL convention EBX should be stored
    push esi              ; according CDECL convention ESI should be stored
    xor esi, esi          ; ESI for result
    mov ebx, 10           ; decimal notation multiplier
.scan_next_digit:
    GETCHAR               ; new symbol in AL
    cmp eax, -1
    je .quit
    cmp eax, 48
    jnge .quit            ; symbol not greater or equal '0' symbol => not digit symbol
    cmp eax, 57
    jnle .quit            ; symbol not less or equal '9' symbol => not digit symbol
    xor ecx, ecx
    mov cl, al            ; free AL for multiplication
    mov eax, esi
    mul ebx               ; 10*ESI, result in EDX:EAX, suppose that N < EAX => EDX = 0
    sub cl, '0'           ; convert symbol to digit
    add eax, ecx
    mov esi, eax
    jmp .scan_next_digit
.quit:
    mov eax, esi          ; result in EAX
    pop esi               ; clean stack frame
    pop ebx
    mov esp, ebp
    pop ebp
    ret
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
    PUTCHAR 10
.print_next_digit:
    pop edx
    PUTCHAR dl
    loop .print_next_digit
.quit:
    pop ebx               ; restore EBX
    mov esp, ebp          ; clean stack frame
    pop ebp               
    ret
finish:
    PUTCHAR 10
    FINISH
