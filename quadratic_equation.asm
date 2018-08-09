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
    PUTCHAR 10
    PRINT 'Enter a, b, c: '

    call read_number        ; read a
    cmp eax, 0
    jz not_quadratic_equation
    push eax

    call read_number        ; read b
    push eax

    call read_number        ; read c
    push eax

    finit                   ; coprocessor in initial state

    call discriminant       ; result in ST0

    PUTCHAR 10              ; print discriminant
    PRINT 'Discriminant: '

    sub esp, 4
    frndint
    fist dword [esp]
    call print_number
    add esp, 4

    ftst                    ; compare ST0 with 0
    fstsw ax                ; copy SR to AX
    sahf                    ; load FLAGS from ah
    jb no_roots             ; no roots if D < 0

    call find_roots         ; result in ST0 and ST1

    PUTCHAR 10
    PUTCHAR 10
    PRINT 'Roots: '

    sub esp, 4              ; print first root
    frndint
    fistp dword [esp]
    call print_number

    PUTCHAR ' '

    fistp dword [esp]       ; print second root
    frndint
    call print_number

    PUTCHAR 10

    add esp, 4
finish:
    add esp, 12
    SUCCESS_FINISH

no_roots:
    PUTCHAR 10
    PUTCHAR 10
    PRINT 'Equation has no real roots'
    jmp finish
not_quadratic_equation:
    PUTCHAR 10
    PUTCHAR 10
    PRINT "'a' should not be equal 0"
    jmp finish

discriminant:               ; suppose a,b,c unsigned
    push ebp                ; organize stack frame
    mov ebp, esp
    pushf                   ; store flags [ebp-4]
    push dword 4            ; constant 4  [ebp-8]

    fild dword [ebp+12]     ; ST0 = b
    fild dword [ebp+12]     ; ST0 = b, ST1 = b
    fmulp                   ; ST0 = b*b
    fild dword [ebp-8]      ; ST0 = 4.0, ST1 = b*b
    fild dword [ebp+16]     ; ST0 = a, ST1 = 4, ST2 = b*b
    fmulp                   ; ST0 = 4*a, ST1 = b*b
    fild dword [ebp+8]      ; ST0 = c, ST1 = 4*a, ST2 = b*b
    fmulp                   ; ST0 = 4*a*c, ST1 = b*b
    fsubp                   ; ST0 = b*b-4*a*c

    add esp, 4              ; cleanup
    popf                    
    mov esp, ebp
    pop ebp
    ret

find_roots:
    push ebp                ; organize stack frame
    mov ebp, esp
    pushf                   ; store flags [ebp-4]
    push dword 2            ; constant 2  [ebp-8]

    ftst                    ; compare ST0 with 0
    fstsw ax                ; copy SR to AX
    sahf                    ; load FLAGS from ah
    jz .multiplicity_root

    fsqrt                   ; ST0 = sqrt(Discriminant) = D'

    fild dword [ebp+12]     ; ST0 = b, ST1 = D'
    fchs                    ; ST0 = -b, ST1 = D'
    fsub st1                ; ST0 = -b - D', ST1 = D' => need for second root

    fild dword [ebp-8]      ; ST0 = 2, ST1 = -b - D', ST2 = D'
    fdivp                   ; ST0 = (-b-D')/2, ST1 = D'
    fild dword [ebp+16]     ; ST0 = a, ST1 = (-b-D')/2, ST2 = D'
    fdivp                   ; ST0 = (-b-D')/(2*a) = x1, ST1 = D'
    fxch                    ; ST0 = D', ST1 = x1

    fild dword [ebp+12]     ; ST0 = b, ST1 = D', ST2 = x1
    fchs                    ; ST0 = -b, ST1 = D', ST2 = x1
    faddp st1               ; ST0 = -b + D', ST1 = x1
    fild dword [ebp-8]      ; ST0 = 2, ST1 = -b + D', ST2 = x1
    fdivp                   ; ST0 = (-b+D')/2, ST1 = x1
    fild dword [ebp+16]     ; ST0 = a, ST1 = (-b+D')/2, ST2 = x1
    fdivp                   ; ST0 = (-b+D')/(2*a) = x2, ST1 = x1
    jmp .quit
.multiplicity_root:
    fstp st0                ; erase zero discriminant value
    fild dword [ebp+12]     ; ST0 = b
    fchs                    ; ST0 = -b
    fild dword [ebp-8]      ; ST0 = 2.0, ST1 = -b
    fdivp                   ; ST0 = -b/2
    fild dword [ebp+16]     ; ST0 = a, ST1 = -b/2
    fdivp                   ; ST0 = -b/(2*a) = x1
    fld st0                 ; ST0 = ST1 = x1
.quit:
    add esp, 4              ; cleanup
    popf                    
    mov esp, ebp
    pop ebp
    ret