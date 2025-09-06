%include "ccc.asm"

section .data

; https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md

SYS_READ: equ 0
SYS_WRITE: equ 1
SYS_EXIT: equ 60

EXIT_OK: equ 0
EXIT_ERR: equ 1

STDIN: equ 0
STDOUT: equ 1
STDERR: equ 2

; Default buffer size from stdio.h
BUFSIZ: equ 8192

HELP: db "The help!!", 10, 0
HELP_LEN: equ $-HELP

VERSION: db "Version!!", 10, 0
VERSION_LEN: equ $-VERSION

INVALID_OPTION: db "cat: invalid option '%'", 10, "Try cat --help for more information", 10, 0

HELP_OPTION: db "--help", 0
VERSION_OPTION: db "--version", 0

SHOW_ALL_OPTION: db "-A", 0
NUMBER_NON_BLANK_OPTION: db "-b", 0
SHOW_ENDS_OPTION: db "-e", 0
NUMBER_OPTION: db "-n", 0
SQUEEZE_BLANK_OPTION: db "-s", 0
SHOW_TABS_OPTION: db "-T", 0
SHOW_NON_PRINTING_OPTION: db "-v", 0

BYTE_SIZE: equ 1
WORD_SIZE: equ 2
DWORD_SIZE: equ 4
QWORD_SIZE: equ 8

section .bss



section .text

global _start

; exit(DWORD %0) void
; %0: status
exit:
  ccc_begin
  mov rax, SYS_EXIT
  syscall
  ccc_end

%macro write 1
  ccc_begin
  ; BYTE *%0: -8
  ; QWORD %1: -16
  sub rsp, 16
  mov [rbp - 16], rdi
  mov [rbp - 8], rsi
  mov rax, SYS_WRITE
  mov rdi, %1
  mov rsi, [rbp - 16]
  mov rdx, [rbp - 8]
  syscall
  ccc_end
%endmacro

; writeout(BYTE *%0, QWORD %1) void
; %0: buffer
; %1: length of the buffer
writeout:
  write STDOUT

; writeerr(BYTE *%0, QWORD %1) void
; %0: buffer
; %1: length of the buffer
writeerr:
  write STDERR

%macro writeb 1
  ccc_begin
  ; BYTE %0: -1
  sub rsp, 1
  mov [rbp - 1], sil
  lea rdi, [rbp - 1]
  mov rsi, 1
  call %1
  ccc_end
%endmacro

; writeoutb(BYTE %0) void
writeoutb:
  writeb writeout

; writeerrb(BYTE %0) void
writeerrb:
  writeb writeerr

; memcmp(BYTE *%0, BYTE *%1) BYTE
memcmp:
  ccc_begin
  ; BYTE *%0 (s1): -16
  ; BYTE *%1 (s2): -8
  sub rsp, 16
  mov [rbp - 16], rdi ; store %0
  mov [rbp - 8], rsi ; store %1

.loop:
  nop

.eq:
  mov rdi, [rbp - 16]
  mov rsi, [rbp - 8]
  mov al, [rdi]
  mov bl, [rsi]
  cmp al, bl
  jne .false

.continue:
  test al, al
  je .true
  inc QWORD [rbp - 16]
  inc QWORD [rbp - 8]
  jmp .loop

.false:
  mov al, 0
  jmp .exit

.true:
  mov al, 1

.exit:
  ccc_end

; memlen(BYTE *%0) QWORD
memlen:
  ccc_begin
  ; BYTE *%0 (s): -8
  ; QWORD counter: -16
  sub rsp, 16
  mov [rbp - 8], rdi ; store %0
  mov QWORD [rbp - 16], 0 ; store counter

.loop:
  nop

.cond:
  mov rdi, [rbp - 8]
  mov al, [rdi]
  test al, al
  jz .exit
  inc QWORD [rbp - 8]
  inc QWORD [rbp - 16]
  jmp .loop

.exit:
  mov rax, [rbp - 16]
  ccc_end

%macro writefmt 2
  ccc_begin
  ; BYTE *%0 (s): -16
  ; DWORD %1: -8 - count of args
  ; QWORD args_counter: -24
  ; BYTE *%1 (current_arg): -32
  sub rsp, 32
  mov [rbp - 16], rdi
  mov [rbp - 8], rsi
  mov QWORD [rbp - 24], 0 ; store args_counter
  mov QWORD [rbp - 32], 0 ; store current_arg

.loop:
  nop

.next_char:
  mov rdi, [rbp - 16]
  mov al, [rdi]
  test al, al
  jz .exit
  cmp al, '%'
  je .handle_format
  mov sil, al
  call %1
  jmp .continue_loop

.handle_format:
  mov rax, [rbp - 24]
  imul rax, QWORD_SIZE
  mov rax, [rbp + 16 + rax]
  mov [rbp - 32], rax
  mov rdi, [rbp - 32]
  call memlen
  mov rdi, [rbp - 32]
  mov rsi, rax
  call %2
  inc QWORD [rbp - 24]

.continue_loop:
  inc QWORD [rbp - 16]
  jmp .loop

.exit:
  ccc_end
%endmacro

; writeoutfmt(BYTE *%0, DWORD %1, ...) void
;                                 ^^^ push that onto the stack
;
; e.g.
;
; rdi: "This option is invalid: %"
; rsi: 1
; stack:
;   - "-f"
writeoutfmt:
  writefmt writeoutb, writeout

; writeerrfmt(BYTE *%0, DWORD %1, ...) void
;                                 ^^^ push that onto the stack
writeerrfmt:
  writefmt writeerrb, writeerr

; handle_arg(BYTE* %0) void
handle_arg:
  ccc_begin
  ; BYTE *%0: -8
  sub rsp, 8
  mov [rbp - 8], rdi ; store %0
  mov rdi, [rbp - 8]
  mov rsi, HELP_OPTION
  call memcmp
  cmp al, 1
  je .help
  mov rdi, [rbp - 8]
  mov rsi, VERSION_OPTION
  call memcmp
  cmp al, 1
  je .version
  jmp .invalid

.help:
  mov rdi, HELP
  mov rsi, HELP_LEN
  call writeout
  mov edi, EXIT_OK
  call exit

.version:
  mov rdi, VERSION
  mov rsi, VERSION_LEN
  call writeout
  mov rdi, EXIT_OK
  call exit

.invalid:
  mov rdi, INVALID_OPTION
  mov rsi, 1
  push QWORD [rbp - 8]
  call writeerrfmt
  add rsp, 8
  mov rdi, EXIT_ERR
  call exit

.exit:
  ccc_end

; handle_args(DWORD %0, BYTE **%1) void
handle_args:
  ccc_begin
  ; DWORD %0 (argc): 16
  ; BYTE **%1 (argv): 8
  sub rsp, 16
  mov edx, edi
  mov eax, QWORD_SIZE
  imul edx
  mov [rbp - 16], eax ; store %0 * QWORD_SIZE
  mov [rbp - 8], rsi ; store %1
 
.loop:
  cmp DWORD [rbp - 16], 0
  jg .body
  jmp .exit

.body:
  sub DWORD [rbp - 16], QWORD_SIZE
  mov rdi, [rbp - 8]
  mov eax, [rbp - 16]
  add rdi, rax
  mov rdi, [rdi]
  call handle_arg
  jmp .loop
  
.exit:
  ccc_end

; handle_input() void
handle_input:
  ccc_begin
  ; BYTE buffer[BUFSIZ]: BUFSIZ (8192)
  sub rsp, BUFSIZ

.loop: 
  mov rax, SYS_READ
  mov rdi, STDIN
  lea rsi, [rbp - BUFSIZ]
  mov rdx, BUFSIZ
  syscall
  cmp rax, 0
  jg .write_buffer
  jmp .exit

.write_buffer:
  lea rdi, [rbp - BUFSIZ]
  mov rsi, rax
  call writeout
  jmp .loop

.exit:
  ccc_end

; main(DWORD %0, BYTE **%1) DWORD
main:
  ccc_begin
  ; DWORD %0 (argc): -8
  ; BYTE **%1 (argv): -16
  sub rsp, 16
  mov [rbp - 16], edi ; store %0
  mov [rbp - 8], rsi ; store %1
  cmp DWORD [rbp - 16], 1
  jle .handle_input

.handle_args:
  mov edi, [rbp - 16]
  mov rsi, [rbp - 8]
  call handle_args
  jmp .exit

.handle_input:
  call handle_input

.exit:
  mov eax, EXIT_OK
  ccc_end

_start:
  mov edi, [rsp] ; rdi = argc
  lea rsi, [rsp + 8] ; rsi = &argv[0]
  call main
  mov edi, eax
  call exit
