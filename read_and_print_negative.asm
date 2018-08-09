; Read number from stdin, print it to stdout
; Number may containt sign symbol

%include "my_io.inc"

global start
extern read_number
extern print_number

section .text
start:
    call read_number
    push eax

    call print_number
    add esp, 4
    
    SUCCESS_FINISH