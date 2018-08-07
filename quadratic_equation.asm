; Read 3 numbers from stdin: a, b, c
; Let a,b,c be coefficients of quadratic equation
; Solve equation or report that equation has no roots
; Print the whole part of the roots

%include "my_io.inc"

global start
extern read_number
extern print_number

section .text
start:
    call read_number        ; a
    push eax

    call read_number        ; b
    push eax

    call read_number        ; c
    push eax

    finit                   ; coprocessor in initial state

    call discriminant       ; result in ST0
    add esp, 12
  
    sub esp, 4              ; should print discriminant
    fistp dword [esp]
    call print_number
    add esp, 4
.finish:
    SUCCESS_FINISH


discriminant:               ; suppose a,b,c unsigned
    push ebp                ; organize stack frame
    mov ebp, esp
    pushf                   ; store flags
    fld dword[ebp+12]       ; ST0 = b

    sub esp, 4              ; should print b
    fist dword [esp]
    call print_number
    add esp, 4

    fld st0                 ; ST0 = b, ST1 = b
    fmulp                   ; ST0 = b*b

    push dword 4
    fild dword [esp]        ; ST0 = 4.0, ST1 = b*b
    add esp, 4

    fmul dword[ebp+8]       ; ST0 = 4*a, ST1= b*b
    fmul dword[ebp+16]      ; ST0 = 4*a*c, ST1 = b*b
    fsubp st1, st0          ; ST0 = b*b-4*a*c
.quit:
    popf                    ; cleanup
    mov esp, ebp
    pop ebp
    ret