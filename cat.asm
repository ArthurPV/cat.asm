%include "ccc.asm"

section .data

; https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md

SYS_READ: equ 0
SYS_WRITE: equ 1
SYS_OPEN: equ 2
SYS_CLOSE: equ 3
SYS_EXIT: equ 60

O_RDONLY: equ 0x0000000

S_IRUSR: equ 1 << 8 ; R for owner
S_IWUSR: equ 1 << 7 ; W for owner
S_IXUSR: equ 1 << 6 ; X for owner
S_IRWXU: equ S_IRUSR | S_IWUSR | S_IXUSR ; RWX mask for owner

EXIT_OK: equ 0
EXIT_ERR: equ 1

STDIN: equ 0
STDOUT: equ 1
STDERR: equ 2

; Default buffer size from stdio.h
BUFSIZ: equ 8192

; The help comes from the GNU cat command:
HELP : db "Usage: cat [OPTION]... [FILE]...", 10
  .1 : db "Concatenate FILE(s) to standard output.", 10, 10
  .2 : db "With no FILE, or when FILE is -, read standard input.", 10, 10
  .3 : db "  -A, --show-all           equivalent to -vET", 10
  .4 : db "  -b, --number-nonblank    number nonempty output lines, overrides -n", 10
  .5 : db "  -e                       equivalent to -vE", 10
  .6 : db "  -E, --show-ends          display $ at end of each line", 10
  .7 : db "  -n, --number             number all output lines", 10
  .8 : db "  -s, --squeeze-blank      suppress repeated empty output lines", 10
  .9 : db "  -t                       equivalent to -vT", 10
  .10: db "  -T, --show-tabs          display TAB characters as ^I", 10
  .11: db "  -u                       (ignored)", 10
  .12: db "  -v, --show-nonprinting   use ^ and M- notation, except for LFD and TAB", 10
  .13: db "      --help        display this help and exit", 10
  .14: db "      --version     output version information and exit", 10, 10
  .15: db "Examples:", 10
  .16: db "  cat f - g  Output f's contents, then standard input, then g's contents.", 10
  .17: db "  cat        Copy standard input to standard output.", 10, 10
  .18: db "GNU coreutils online help: <https://www.gnu.org/software/coreutils/>", 10
  .19: db "Full documentation <https://www.gnu.org/software/coreutils/cat>", 10
  .20: db "or available locally via: info '(coreutils) cat invocation'", 10, 0
HELP_LEN: equ $-HELP

VERSION: db "cat (Linux x86_64 ASM clone) 0.0", 10, 0
VERSION_LEN: equ $-VERSION

INVALID_OPTION: db "cat: invalid option -- '%'", 10, "Try cat --help for more information", 10, 0

UNRECOGNIZED_OPTION: db "cat: unrecognized option '%'", 10, "Try 'cat --help' for more information.", 10, 0

FAILED_TO_OPEN_FILE: db "cat: %: Failed to open file", 10, 0
FAILED_TO_READ_FILE: db "cat: %: Failed to read file", 10, 0

OPTION_LONG:
  .SHOW_ALL: db "--show-all", 0
  .NUMBER_NON_BLANK: db "--number-nonblank", 0
  .SHOW_ENDS: db "--show-ends", 0
  .NUMBER: db "--number", 0
  .SQUEEZE_BLANK: db "--squeeze-blank", 0
  .SHOW_TABS: db "--show-tabs", 0
  .SHOW_NONPRINTING: db "--show-nonprinting", 0
  .HELP: db "--help", 0
  .VERSION: db "--version", 0

OPTION_SHORT:
  .A: equ 'A'
  .b: equ 'b'
  .e: equ 'e'
  .E: equ 'E'
  .n: equ 'n'
  .s: equ 's'
  .t: equ 't'
  .T: equ 'T'
  .u: equ 'u'
  .v: equ 'v'

BYTE_SIZE: equ 1
WORD_SIZE: equ 2
DWORD_SIZE: equ 4
QWORD_SIZE: equ 8

section .bss

option:
  .b: resb 1
  .E: resb 1
  .n: resb 1
  .s: resb 1
  .T: resb 1
  .u: resb 1
  .v: resb 1

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

; option_n(BYTE* %0) DWORD
option_n:
  ccc_begin
  mov eax, 0
  mov dh, [rdi]
  cmp dh, '-'
  jne .exit
  inc rdi
  mov dh, [rdi]
  cmp dh, '-'
  je .two
  mov eax, 1
  jmp .exit

.two:
  mov eax, 2

.exit:
  ccc_end

; set_A_option() void
set_A_option:
  ccc_begin
  mov BYTE [option.v], 1
  mov BYTE [option.E], 1
  mov BYTE [option.T], 1
  ccc_end

; set_e_option() void
set_e_option:
  ccc_begin
  mov BYTE [option.v], 1
  mov BYTE [option.E], 1
  ccc_end

; set_t_option() void
set_t_option:
  ccc_begin
  mov BYTE [option.v], 1
  mov BYTE [option.T], 1
  ccc_end

; handle_long_option(BYTE *%0) void
handle_long_option:
  ccc_begin
  ; BYTE *%0: -8
  sub rsp, 8
  mov [rbp - 8], rdi ; store %0
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.SHOW_ALL
  call memcmp
  cmp al, 1
  je .A
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.NUMBER_NON_BLANK
  call memcmp
  cmp al, 1
  je .b
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.SHOW_ENDS
  call memcmp
  cmp al, 1
  je .E
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.NUMBER
  call memcmp
  cmp al, 1
  je .n
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.SQUEEZE_BLANK
  call memcmp
  cmp al, 1
  je .s
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.SHOW_TABS
  call memcmp
  cmp al, 1
  je .T
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.SHOW_NONPRINTING
  call memcmp
  cmp al, 1
  je .v
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.HELP
  call memcmp
  cmp al, 1
  je .help
  mov rdi, [rbp - 8]
  mov rsi, OPTION_LONG.VERSION
  call memcmp
  cmp al, 1
  je .version
  jmp .unrecognized_option

.A:
  call set_A_option
  jmp .exit

.b:
  mov BYTE [option.b], 1
  jmp .exit

.E:
  mov BYTE [option.E], 1
  jmp .exit

.n:
  mov BYTE [option.n], 1
  jmp .exit

.s:
  mov BYTE [option.s], 1
  jmp .exit

.T:
  mov BYTE [option.T], 1
  jmp .exit

.v:
  mov BYTE [option.v], 1
  jmp .exit

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

.unrecognized_option:
  mov rdi, UNRECOGNIZED_OPTION
  mov rsi, 1
  push QWORD [rbp - 8]
  call writeerrfmt
  add rsp, QWORD_SIZE * 1
  mov rdi, EXIT_ERR
  call exit

.exit:
  ccc_end

; handle_short_option(BYTE *%0) void
handle_short_option:
  ccc_begin
  ; BYTE *%0: -8
  ; BYTE current: -16
  sub rsp, 16
  mov [rbp - 8], rdi ; store %0

.loop:
  inc QWORD [rbp - 8]
  mov rdi, [rbp - 8]
  mov al, [rdi]
  mov BYTE [rbp - 16], al
  cmp al, 0
  je .exit
  cmp al, OPTION_SHORT.A
  je .A
  cmp al, OPTION_SHORT.b
  je .b
  cmp al, OPTION_SHORT.e
  je .e
  cmp al, OPTION_SHORT.E
  je .E
  cmp al, OPTION_SHORT.n
  je .n
  cmp al, OPTION_SHORT.s
  je .s
  cmp al, OPTION_SHORT.t
  je .t
  cmp al, OPTION_SHORT.T
  je .T
  cmp al, OPTION_SHORT.u
  je .u
  cmp al, OPTION_SHORT.v
  je .v
  jmp .invalid

.A:
  call set_A_option
  jmp .loop

.b:
  mov BYTE [option.b], 1
  jmp .loop

.e:
  call set_e_option
  jmp .loop

.E:
  mov BYTE [option.E], 1
  jmp .loop

.n:
  mov BYTE [option.n], 1
  jmp .loop

.s:
  mov BYTE [option.s], 1
  jmp .loop

.t:
  call set_t_option
  jmp .loop

.T:
  mov BYTE [option.T], 1
  jmp .loop

.u:
  mov BYTE [option.u], 1
  jmp .loop

.v:
  mov BYTE [option.v], 1
  jmp .loop

.invalid:
  mov rdi, INVALID_OPTION
  mov rsi, 1
  lea rdx, [rbp - 16]
  push QWORD rdx
  call writeerrfmt
  add rsp, QWORD_SIZE * 1
  mov rdi, EXIT_ERR
  call exit

.exit:
  ccc_end

; handle_option(BYTE *%0) void
handle_option:
  ccc_begin
  ; BYTE *%0: -8
  sub rsp, 8
  mov [rbp - 8], rdi ; store %0
  mov rdi, [rbp - 8]
  call option_n
  cmp eax, 1
  je .handle_short_option
  cmp eax, 2
  je .handle_long_option
  jmp .exit

.handle_long_option:
  mov rdi, [rbp - 8]
  call handle_long_option
  jmp .exit

.handle_short_option:
  mov rdi, [rbp - 8]
  call handle_short_option
  jmp .exit

.exit:
  ccc_end

; handle_options(DWORD %0, BYTE **%1) void
handle_options:
  ccc_begin
  ; DWORD %0 (argc): -16
  ; BYTE **%1 (argv): -8
  sub rsp, 16
  mov edx, edi
  mov eax, QWORD_SIZE
  imul edx
  mov [rbp - 16], eax ; store %0 * QWORD_SIZE
  mov [rbp - 8], rsi ; store %1
 
.loop:
  cmp DWORD [rbp - 16], 8 ; we skip the first arg
  jg .body
  jmp .exit

.body:
  sub DWORD [rbp - 16], QWORD_SIZE
  mov rdi, [rbp - 8]
  mov eax, [rbp - 16]
  add rdi, rax
  mov rdi, [rdi]
  call handle_option
  jmp .loop
  
.exit:
  ccc_end

; writeout_file_content(BYTE *%0, QWORD %1) void
writeout_file_content:
  ccc_begin
  ; BYTE *%0: -8
  ; QWORD %1: -16
  ; QWORD counter: -24
  sub rsp, 24
  mov [rbp - 8], rdi ; store %0
  mov [rbp - 16], rsi ; store %1
  mov QWORD [rbp - 24], 0 ; store counter

.loop:
  mov rcx, [rbp - 16]
  mov rdx, [rbp - 24]
  cmp rdx, rcx
  jge .exit
  mov rdx, [rbp - 8]
  add rdx, [rbp - 24]
  mov sil, [rdx]
  call writeoutb
  inc QWORD [rbp - 24]
  jmp .loop

.exit:
  ccc_end

; handle_file(BYTE *%0) void
handle_file:
  ccc_begin
  ; BYTE *%0: -8
  ; DWORD fd: -16
  ; BYTE *buffer: -BUFSIZ - 16
  sub rsp, 16 + BUFSIZ
  mov [rbp - 8], rdi ; store %0
  mov rdi, [rbp - 8]
  call option_n
  cmp eax, 0
  jne .exit
  mov rax, SYS_OPEN
  mov rdi, [rbp - 8]
  mov esi, O_RDONLY
  mov edx, S_IRWXU
  syscall
  cmp rax, 0 ; check for error
  jl .open_error
  mov DWORD [rbp - 16], eax
  jmp .read

.open_error:
  mov rdi, FAILED_TO_OPEN_FILE
  mov rsi, 1
  push QWORD [rbp - 8]
  call writeerrfmt
  add rsp, QWORD_SIZE * 1
  jmp .exit

.read:
  mov rdi, [rbp - 16]
  mov rax, SYS_READ
  lea rsi, [rbp - BUFSIZ - 16]
  mov rdx, BUFSIZ
  syscall
  cmp rax, 0
  jl .read_error
  je .close
  lea rdi, [rbp - BUFSIZ - 16]
  mov rsi, rax
  call writeout_file_content
  jmp .read

.read_error:
  mov rdi, FAILED_TO_READ_FILE
  mov rsi, 1
  push QWORD [rbp - 8]
  call writeerrfmt
  add rsp, QWORD_SIZE * 1

.close:
  mov rax, SYS_CLOSE
  mov rdi, [rbp - 16]
  syscall

.exit:
  ccc_end

; handle_files(DWORD %0, BYTE **%1) void
handle_files:
  ccc_begin
  ; DWORD %0 (argc): -16
  ; BYTE **%1 (argv): -8
  ; DWORD counter: -24
  sub rsp, 24
  mov edx, edi
  mov eax, QWORD_SIZE
  imul edx
  mov [rbp - 16], eax ; store %0 * QWORD_SIZE
  mov [rbp - 8], rsi ; store %1
  mov DWORD [rbp - 24], QWORD_SIZE ; store counter

.loop:
  mov edi, [rbp - 16]
  mov esi, [rbp - 24]
  cmp esi, edi
  jl .body
  jmp .exit

.body:
  mov rdi, [rbp - 8]
  mov eax, [rbp - 24]
  add rdi, rax
  mov rdi, [rdi]
  call handle_file
  add DWORD [rbp - 24], QWORD_SIZE
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
  call handle_options
  mov edi, [rbp - 16]
  mov rsi, [rbp - 8]
  call handle_files
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
