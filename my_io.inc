%macro _syscall_read 3
  _syscall_3 3, %1, %2, %3
%endmacro

%macro _syscall_write 3
  _syscall_3 4, %1, %2, %3
%endmacro

%macro _syscall_open_file_for_read 2
  _syscall_2 5, %1, %2
%endmacro

%macro _syscall_open_file_for_write 3
  _syscall_3 5, %1, %2, %3
%endmacro

%macro _syscall_3 4
  push  %4
  push  %3
  push  %2
  mov eax, %1
  sub esp, 4
  int 0x80
  add esp, 16
%endmacro

%macro _syscall_2 3
  push  %3
  push  %2
  mov eax, %1
  sub esp, 4
  int 0x80
  add esp, 12
%endmacro

%macro OPEN_FILE_FOR_READ 1
  _syscall_open_file_for_read %1, 0             ; READ_ONLY
%endmacro

%macro READ_FROM_FILE 2
  _syscall_read dword [fdsrc], %1, %2
%endmacro

%macro WRITE_TO_FILE 2
  _syscall_write dword [fddest], %1, %2
%endmacro

%macro OPEN_FILE_FOR_WRITE 1
  _syscall_open_file_for_write %1, 601h, 0666o  ; WRITE with default rights
%endmacro

%macro CLOSE_FILE 1
  pusha
  pushf
  push  %1
  mov eax, 6
  sub esp, 4
  int 0x80
  add esp, 8
  popf
  popa
%endmacro

%macro GETCHAR 0
  pusha
  pushf
  push  edi
  sub esp, 2
  mov edi, esp
  _syscall_read 0, edi, 1
  cmp eax, 1
  jne %%eof_reached
  xor eax,eax
  mov al, [edi]
  jmp %%quit
%%eof_reached:
  xor eax, eax
  not eax               ; eax := -1
%%quit:
  add esp, 2
  pop edi
  popf
  popa
%endmacro

%macro  PUTCHAR 1
  pusha
  pushf
  mov al, %1
  sub esp, 2              ; reserve memory for buffer
  mov edi, esp
  mov [edi], al
  _syscall_write 1, edi, 1
  add esp, 2
  popf
  popa
%endmacro

; print string into standard output
%macro PRINT 1
  pusha
  pushf
  jmp  %%print_str
%%str db %1, 10, 0
%%strln equ $-%%str
%%print_str:
  _syscall_write 1, %%str, %%strln
  popf
  popa
%endmacro

%macro SUCCESS_FINISH 0
  push dword 0          ; "success"
  mov  eax, 1           ; _exit syscall
  push eax              ; push anything
  int  0x80
%endmacro
