; program accepts as command line args some integers
; print sum of them into stdout

%include "my_io.inc"

global start
extern print_number

section .text
start:
    mov ebx, [esp]              ; quantity of command line elements, argc
    xor esi, esi                ; ESI for sum   
.process_next:
    push dword [esp+4*ebx]      ; address of argument's begining
    call convert_to_digit       ; result in EAX
    add esp, 4

    add esi, eax                ; accumulate sum
    dec ebx
    cmp ebx, 1                  ; [esp+4] contains './sum'
    jg .process_next

    push esi
    PRINT "Sum: "
    call print_number
    PUTCHAR 10
    add esp, 4

    SUCCESS_FINISH

convert_to_digit:
    push ebp
    mov ebp, esp
    pushf
    push esi                   ; according CDECL
    push edi                   ; according CDECL
    push ebx                   ; according CDECL
    push dword 10              ; local: decimal notation multiplier
    sub esp, 4                 ; local: to store new digit

    mov esi, [ebp+8]           ; address of string's begining
    mov edi, '+'
    xor ebx, ebx               ; for result number
    xor ecx, ecx               ; for address of current symbol
    xor eax, eax               ; for current symbol

    mov al, byte [esi]         ; first symbol
    cmp al, '-'                ; first symbol is sign symbol?
    jne .not_sign_symbol
    inc ecx
    mov edi, '-'

.next_digit:
    xor eax, eax
    mov al, byte [esi+ecx]     ; new symbol in AL
.not_sign_symbol:
    cmp al, 0                  ; restrictive 0
    je .quit
    cmp al, '0'
    jb .quit                   ; not digit symbol
    cmp al, '9'
    ja .quit                   ; not digit symbol
    sub al, '0'                ; convert symbol to digit

    mov [esp], eax             ; free AL for multiplication
    mov eax, ebx
    mul dword [esp+4]          ; 10*EBX, result in EDX:EAX, suppose that N < EAX => EDX = 0              
    add eax, [esp]             ; 10*EBX + new digit

    mov ebx, eax
    inc ecx
    jmp .next_digit
.quit:
    mov eax, ebx               ; result in EAX
    cmp edi, '+'
    je .finish
    not eax                    ; negative number
    add eax, 1
    
.finish:
    add esp, 8                 ; local variables
    pop ebx
    pop edi
    pop esi
    popf                    
    mov esp, ebp
    pop ebp
    ret

