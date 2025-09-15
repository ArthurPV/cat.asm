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
  .20: db "or available locally via: info '(coreutils) cat invocation'", 10
HELP_LEN: equ $-HELP

VERSION: db "cat (Linux x86_64 ASM clone) 0.0", 10
VERSION_LEN: equ $-VERSION

INVALID_OPTION: db "cat: invalid option -- '%'", 10, "Try cat --help for more information", 10, 0

UNRECOGNIZED_OPTION: db "cat: unrecognized option '%'", 10, "Try 'cat --help' for more information.", 10, 0

FAILED_TO_OPEN_FILE: db "cat: %: Failed to open file", 10, 0
FAILED_TO_READ_FILE: db "cat: %: Failed to read file", 10, 0

DASH: db '-', 0

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

TAB_SUBSTITUTION: db "^I"
TAB_SUBSTITUTION_LEN: equ $-TAB_SUBSTITUTION

LINE_NUMBER_SPACES_5: db "     " ; left_spaces: ln < 10
LINE_NUMBER_SPACES_LEN_5: equ $-LINE_NUMBER_SPACES_5

LINE_NUMBER_SPACES_4: db "    " ; left_spaces: ln < 100
LINE_NUMBER_SPACES_LEN_4: equ $-LINE_NUMBER_SPACES_4

LINE_NUMBER_SPACES_3: db "   " ; left_spaces: ln < 1000
LINE_NUMBER_SPACES_LEN_3: equ $-LINE_NUMBER_SPACES_3

LINE_NUMBER_SPACES_2: db "  " ; left_spaces: ln < 10000
LINE_NUMBER_SPACES_LEN_2: equ $-LINE_NUMBER_SPACES_2

LINE_NUMBER_SPACES_1: db " " ; left_spaces: ln < 1000000
LINE_NUMBER_SPACES_LEN_1: equ $-LINE_NUMBER_SPACES_1

BYTE_SIZE: equ 1
WORD_SIZE: equ 2
DWORD_SIZE: equ 4
QWORD_SIZE: equ 8

BREAK_BY_EOF: equ 1
BREAK_BY_LF: equ 2
BREAK_BY_HT: equ 3
BREAK_BY_NON_PRINTING: equ 4

CH_0: db "^@", 0
CH_1: db "^A", 0
CH_2: db "^B", 0
CH_3: db "^C", 0
CH_4: db "^D", 0
CH_5: db "^E", 0
CH_6: db "^F", 0
CH_7: db "^G", 0
CH_8: db "^H", 0
; NOTE: 0x09 and 0x0A are considered as printing characters
CH_11: db "^K", 0
CH_12: db "^L", 0
CH_13: db "^M", 0
CH_14: db "^N", 0
CH_15: db "^O", 0
CH_16: db "^P", 0
CH_17: db "^Q", 0
CH_18: db "^R", 0
CH_19: db "^S", 0
CH_20: db "^T", 0
CH_21: db "^U", 0
CH_22: db "^V", 0
CH_23: db "^W", 0
CH_24: db "^X", 0
CH_25: db "^Y", 0
CH_26: db "^Z", 0
CH_27: db "^[", 0
CH_28: db "^\", 0
CH_29: db "^]", 0
CH_30: db "^^", 0
CH_31: db "^_", 0
CH_127: db "^?", 0
CH_128: db "M-^@", 0
CH_129: db "M-^A", 0
CH_130: db "M-^B", 0
CH_131: db "M-^C", 0
CH_132: db "M-^D", 0
CH_133: db "M-^E", 0
CH_134: db "M-^F", 0
CH_135: db "M-^G", 0
CH_136: db "M-^H", 0
CH_137: db "M-^I", 0
CH_138: db "M-^J", 0
CH_139: db "M-^K", 0
CH_140: db "M-^L", 0
CH_141: db "M-^M", 0
CH_142: db "M-^N", 0
CH_143: db "M-^O", 0
CH_144: db "M-^P", 0
CH_145: db "M-^Q", 0
CH_146: db "M-^R", 0
CH_147: db "M-^S", 0
CH_148: db "M-^T", 0
CH_149: db "M-^U", 0
CH_150: db "M-^V", 0
CH_151: db "M-^W", 0
CH_152: db "M-^X", 0
CH_153: db "M-^Y", 0
CH_154: db "M-^Z", 0
CH_155: db "M-^[", 0
CH_156: db "M-^\",0
CH_157: db "M-^]", 0
CH_158: db "M-^^", 0
CH_159: db "M-^_", 0
CH_160: db "M- ", 0
CH_161: db "M-!", 0
CH_162: db 'M-"', 0
CH_163: db "M-#", 0
CH_164: db "M-$", 0
CH_165: db "M-%", 0
CH_166: db "M-&", 0
CH_167: db "M-'", 0
CH_168: db "M-(", 0
CH_169: db "M-)", 0
CH_170: db "M-*", 0
CH_171: db "M-+", 0
CH_172: db "M-,", 0
CH_173: db "M--", 0
CH_174: db "M-.", 0
CH_175: db "M-/", 0
CH_176: db "M-0", 0
CH_177: db "M-1", 0
CH_178: db "M-2", 0
CH_179: db "M-3", 0
CH_180: db "M-4", 0
CH_181: db "M-5", 0
CH_182: db "M-6", 0
CH_183: db "M-7", 0
CH_184: db "M-8", 0
CH_185: db "M-9", 0
CH_186: db "M-:", 0
CH_187: db "M-;", 0
CH_188: db "M-<", 0
CH_189: db "M-=", 0
CH_190: db "M->", 0
CH_191: db "M-?", 0
CH_192: db "M-@", 0
CH_193: db "M-A", 0
CH_194: db "M-B", 0
CH_195: db "M-C", 0
CH_196: db "M-D", 0
CH_197: db "M-E", 0
CH_198: db "M-F", 0
CH_199: db "M-G", 0
CH_200: db "M-H", 0
CH_201: db "M-I", 0
CH_202: db "M-J", 0
CH_203: db "M-K", 0
CH_204: db "M-L", 0
CH_205: db "M-M", 0
CH_206: db "M-N", 0
CH_207: db "M-O", 0
CH_208: db "M-P", 0
CH_209: db "M-Q", 0
CH_210: db "M-R", 0
CH_211: db "M-S", 0
CH_212: db "M-T", 0
CH_213: db "M-U", 0
CH_214: db "M-V", 0
CH_215: db "M-W", 0
CH_216: db "M-X", 0
CH_217: db "M-Y", 0
CH_218: db "M-Z", 0
CH_219: db "M-[", 0
CH_220: db "M-\", 0
CH_221: db "M-]", 0
CH_222: db "M-^", 0
CH_223: db "M-_", 0
CH_224: db "M-`", 0
CH_225: db "M-a", 0
CH_226: db "M-b", 0
CH_227: db "M-c", 0
CH_228: db "M-d", 0
CH_229: db "M-e", 0
CH_230: db "M-f", 0
CH_231: db "M-g", 0
CH_232: db "M-h", 0
CH_233: db "M-i", 0
CH_234: db "M-j", 0
CH_235: db "M-k", 0
CH_236: db "M-l", 0
CH_237: db "M-m", 0
CH_238: db "M-n", 0
CH_239: db "M-o", 0
CH_240: db "M-p", 0
CH_241: db "M-q", 0
CH_242: db "M-r", 0
CH_243: db "M-s", 0
CH_244: db "M-t", 0
CH_245: db "M-u", 0
CH_246: db "M-v", 0
CH_247: db "M-w", 0
CH_248: db "M-x", 0
CH_249: db "M-y", 0
CH_250: db "M-z", 0
CH_251: db "M-{", 0
CH_252: db "M-|", 0
CH_253: db "M-}", 0
CH_254: db "M-~", 0
CH_255: db "M-^?", 0

; null (0) = printing
; non-null = non-printing
non_printing_characters_table:
  dq CH_0, CH_1, CH_2, CH_3
  dq CH_4, CH_5, CH_6, CH_7
  dq CH_8, 0, 0, CH_11
  dq CH_12, CH_13, CH_14, CH_15
  dq CH_16, CH_17, CH_18, CH_19
  dq CH_20, CH_21, CH_22, CH_23
  dq CH_24, CH_25, CH_26, CH_27
  dq CH_28, CH_29, CH_30, CH_31
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 32–39
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 40–47
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 48–55
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 56–63
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 64–71
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 72–79
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 80–87
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 88–95
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 96–103
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 104–111
  dq 0, 0, 0, 0, 0, 0, 0, 0 ; 112–119
  dq 0, 0, 0, 0, 0, 0, 0 ; 120–126
  dq CH_127 ; <DEL>
  dq CH_128, CH_129, CH_130, CH_131
  dq CH_132, CH_133, CH_134, CH_135
  dq CH_136, CH_137, CH_138, CH_139
  dq CH_140, CH_141, CH_142, CH_143
  dq CH_144, CH_145, CH_146, CH_147
  dq CH_148, CH_149, CH_150, CH_151
  dq CH_152, CH_153, CH_154, CH_155
  dq CH_156, CH_157, CH_158, CH_159
  dq CH_160, CH_161, CH_162, CH_163
  dq CH_164, CH_165, CH_166, CH_167
  dq CH_168, CH_169, CH_170, CH_171
  dq CH_172, CH_173, CH_174, CH_175
  dq CH_176, CH_177, CH_178, CH_179
  dq CH_180, CH_181, CH_182, CH_183
  dq CH_184, CH_185, CH_186, CH_187
  dq CH_188, CH_189, CH_190, CH_191
  dq CH_192, CH_193, CH_194, CH_195
  dq CH_196, CH_197, CH_198, CH_199
  dq CH_200, CH_201, CH_202, CH_203
  dq CH_204, CH_205, CH_206, CH_207
  dq CH_208, CH_209, CH_210, CH_211
  dq CH_212, CH_213, CH_214, CH_215
  dq CH_216, CH_217, CH_218, CH_219
  dq CH_220, CH_221, CH_222, CH_223
  dq CH_224, CH_225, CH_226, CH_227
  dq CH_228, CH_229, CH_230, CH_231
  dq CH_232, CH_233, CH_234, CH_235
  dq CH_236, CH_237, CH_238, CH_239
  dq CH_240, CH_241, CH_242, CH_243
  dq CH_244, CH_245, CH_246, CH_247
  dq CH_248, CH_249, CH_250, CH_251
  dq CH_252, CH_253, CH_254, CH_255

section .bss

option:
  .b: resb 1
  .E: resb 1
  .n: resb 1
  .s: resb 1
  .T: resb 1
  .u: resb 1
  .v: resb 1

; Check if the handle_input function can be called.
; This prevents the user from using the dash option multiple times
; and entering input loops multiple times on the same file being read.
can_handle_input: resb 1
can_write_line_count: resb 1
has_handled_files: resb 1

line_count: resq 1
empty_line_count: resq 1

break_by: resb 1

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

; set_b_option() void
set_b_option:
  ccc_begin
  mov BYTE [option.b], 1
  mov BYTE [option.n], 0
  ccc_end

; set_n_option() void
set_n_option:
  ccc_begin
  test BYTE [option.b], 1
  jz .set
  jmp .exit

.set:
  mov BYTE [option.n], 1

.exit:
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
  call set_b_option
  jmp .exit

.E:
  mov BYTE [option.E], 1
  jmp .exit

.n:
  call set_n_option
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
  call set_b_option
  jmp .loop

.e:
  call set_e_option
  jmp .loop

.E:
  mov BYTE [option.E], 1
  jmp .loop

.n:
  call set_n_option
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

; write_line_number(QWORD %0) void
write_line_number:
  ccc_begin
  ; QWORD %0: -80
  ; QWORD digits_count: -72
  ; BYTE digits[64]: -64
  sub rsp, 80
  mov [rbp - 80], rdi ; store %0
  mov QWORD [rbp - 72], 0 ; store digits_count = 0

_handle_negative:
  cmp QWORD [rbp - 80], 0
  jl .body
  jmp _convert_int_to_string

.body:
  mov sil, '-'
  call writeoutb
  neg QWORD [rbp - 80] ; store %0 = -%0

_convert_int_to_string:
  ; NOTE: We need to jump on body, in case of %0 is equal to 0
  jmp .body

.loop:
  cmp QWORD [rbp - 80], 0
  jg .body
  jmp .exit

.body:
  mov rax, [rbp - 80]
  cqo
  mov rbx, 10
  idiv rbx
  mov [rbp - 80], rax ; %0 = quotient
  add rdx, '0' ; reminder += '0'
  lea rcx, [rbp - 64]
  add rcx, [rbp - 72]
  mov [rcx], rdx
  inc QWORD [rbp - 72]
  jmp .loop

.exit:
  nop

_write_left_spaces:
  cmp QWORD [rbp - 72], 1
  je .write_5
  cmp QWORD [rbp - 72], 2
  je .write_4
  cmp QWORD [rbp - 72], 3
  je .write_3
  cmp QWORD [rbp - 72], 4
  je .write_2
  cmp QWORD [rbp - 72], 5
  je .write_1
  jmp _write_int

.write_5:
  mov rdi, LINE_NUMBER_SPACES_5
  mov rsi, LINE_NUMBER_SPACES_LEN_5
  call writeout
  jmp _write_int

.write_4:
  mov rdi, LINE_NUMBER_SPACES_4
  mov rsi, LINE_NUMBER_SPACES_LEN_4
  call writeout
  jmp _write_int

.write_3:
  mov rdi, LINE_NUMBER_SPACES_3
  mov rsi, LINE_NUMBER_SPACES_LEN_3
  call writeout
  jmp _write_int

.write_2:
  mov rdi, LINE_NUMBER_SPACES_2
  mov rsi, LINE_NUMBER_SPACES_LEN_2
  call writeout
  jmp _write_int

.write_1:
  mov rdi, LINE_NUMBER_SPACES_1
  mov rsi, LINE_NUMBER_SPACES_LEN_1
  call writeout

_write_int:
  nop

.loop:
  cmp QWORD [rbp - 72], 0
  jg .body
  jmp _write_right_spaces

.body:
  mov rdx, [rbp - 72]
  dec rdx
  lea rdi, [rbp - 64]
  add rdi, rdx
  mov rsi, 1
  call writeout
  dec QWORD [rbp - 72]
  jmp .loop

_write_right_spaces:
  cmp QWORD [rbp - 80], 1000000
  jl .write_two_spaces
  mov rdi, LINE_NUMBER_SPACES_1
  mov rsi, LINE_NUMBER_SPACES_LEN_1
  call writeout
  jmp .exit

.write_two_spaces:
  mov rdi, LINE_NUMBER_SPACES_2
  mov rsi, LINE_NUMBER_SPACES_LEN_2
  call writeout

.exit:
  ccc_end

; is_non_printing_character(BYTE %0)
is_non_printing_character:
  ccc_begin
  ; BYTE %0: -1
  sub rsp, 1
  mov [rbp - 1], sil
  mov al, [rbp - 1]
  movzx rsi, al
  mov rbx, non_printing_characters_table
  mov rdi, [rbx + rsi * 8]
  test rdi, rdi
  jz .zero
  jmp .one

.zero:
  mov al, 0
  jmp .exit

.one:
  mov al, 1

.exit:
  ccc_end

; file_content_iter(BYTE *%0, QWORD %1) BYTE*
file_content_iter:
  ccc_begin
  ; BYTE *%0: -16
  ; QWORD %1: -8
  ; QWORD count: -24
  sub rsp, 24
  mov [rbp - 16], rdi
  mov [rbp - 8], rsi
  mov QWORD [rbp - 24], 0
  mov BYTE [break_by], 0

.loop:
  mov rdi, [rbp - 8]
  cmp [rbp - 24], rdi
  jge .eof
  mov rdi, [rbp - 16]
  add rdi, [rbp - 24]
  mov al, [rdi]
  cmp al, 10
  je .lf
  cmp al, 9
  je .ht
  mov sil, al
  call is_non_printing_character
  test al, al
  jz .continue
  jmp .non_printing

.continue:
  inc QWORD [rbp - 24]
  jmp .loop

.eof:
  mov BYTE [break_by], BREAK_BY_EOF
  dec QWORD [rbp - 24]
  jmp .exit

.lf:
  mov BYTE [break_by], BREAK_BY_LF
  inc QWORD [rbp - 24]
  jmp .exit

.ht:
  test BYTE [option.T], 1
  jz .continue
  mov BYTE [break_by], BREAK_BY_HT
  inc QWORD [rbp - 24]
  jmp .exit

.non_printing:
  test BYTE [option.v], 1
  jz .continue
  mov BYTE [break_by], BREAK_BY_NON_PRINTING
  inc QWORD [rbp - 24]
  jmp .exit

.exit:
  mov rax, [rbp - 16]
  add rax, [rbp - 24]
  ccc_end

; write_line_count(QWORD %0) void
; %0: buffer_length
; %1: current_buffer_length
write_line_count:
  ccc_begin
  sub rsp, 16
  ; QWORD %0 (buffer_length): -8
  ; QWORD %1 (current_buffer_length): -16
  mov [rbp - 8], rdi
  mov [rbp - 16], rsi
  ; cmp QWORD [rbp - 8], 0
  ; je .exit
  test BYTE [can_write_line_count], 1
  jz .exit
  test BYTE [option.n], 1
  jz .b
  jmp .s

.b:
  test BYTE [option.b], 1
  jz .exit
  cmp QWORD [rbp - 16], 0
  jle .exit

.s:
  test BYTE [option.s], 1
  jz .write
  cmp QWORD [empty_line_count], 1
  jl .write
  cmp QWORD [rbp - 16], 0
  jg .write
  jmp .exit

.write:
  inc QWORD [line_count]
  mov rdi, [line_count]
  call write_line_number

.exit:
  mov BYTE [can_write_line_count], 0
  ccc_end

; write_show_ends() void
write_show_ends:
  ccc_begin
  test BYTE [option.E], 1
  jz .exit
  mov sil, '$'
  call writeoutb

.exit:
  ccc_end

; write_show_tabs() void
write_show_tabs:
  ccc_begin
  test BYTE [option.T], 1
  jz .write_tab
  mov rdi, TAB_SUBSTITUTION
  mov rsi, TAB_SUBSTITUTION_LEN
  call writeout
  jmp .exit

.write_tab:
  mov sil, 9
  call writeoutb

.exit:
  ccc_end

; write_lf(QWORD %0) void
write_lf:
  ccc_begin
  ; QWORD %0 (current_buffer_len): -8
  sub rsp, 8
  mov [rbp - 8], rdi ; store %0
  cmp QWORD [rbp - 8], 0
  je .empty_line
  jmp .non_empty_line

.empty_line:
  inc QWORD [empty_line_count]
  jmp .continue

.non_empty_line:
  mov QWORD [empty_line_count], 0

.continue:
  test BYTE [option.s], 1
  jz .write
  cmp QWORD [empty_line_count], 1
  jle .write
  jmp .exit

.write:
  call write_show_ends
  mov sil, 10
  call writeoutb

.exit:
  mov BYTE [can_write_line_count], 1
  ccc_end

; writeout_file_content(BYTE *%0, QWORD %1) void
writeout_file_content:
  ccc_begin
  ; BYTE *%0: -16
  ; QWORD %1: -8
  ; BYTE *current_buffer: -24
  ; QWORD current_buffer_len: -32
  sub rsp, 32
  mov [rbp - 16], rdi ; store %0
  mov [rbp - 8], rsi ; store %1
  mov QWORD [rbp - 24], 0 ; store current_buffer
  mov QWORD [rbp - 32], 0 ; store current_buffer_len

.loop:
  mov rdi, [rbp - 16]
  mov rsi, [rbp - 8]
  call file_content_iter
  mov rcx, rax
  sub rcx, [rbp - 16]
  cmp rcx, 0
  ; je .exit
  jle .exit
  mov rdx, [rbp - 16]
  mov [rbp - 24], rdx
  mov [rbp - 16], rax
  sub [rbp - 8], rcx
  mov [rbp - 32], rcx
  cmp BYTE [break_by], BREAK_BY_LF
  je .lf
  cmp BYTE [break_by], BREAK_BY_HT
  je .ht
  cmp BYTE [break_by], BREAK_BY_NON_PRINTING
  je .non_printing
  mov rdi, [rbp - 8]
  mov rsi, [rbp - 32]
  call write_line_count
  jmp .write_line

.lf:
  dec QWORD [rbp - 32] ; avoid to write new line
  mov rdi, [rbp - 8]
  mov rsi, [rbp - 32]
  call write_line_count
  jmp .write_line

.ht:
  mov rdi, [rbp - 8]
  mov rsi, [rbp - 32]
  call write_line_count
  dec QWORD [rbp - 32] ; avoid to write tab
  jmp .write_line

.non_printing:
  mov rdi, [rbp - 8]
  mov rsi, [rbp - 32]
  call write_line_count
  dec QWORD [rbp - 32] ; avoid to write non printing character
  jmp .write_line

.write_line:
  cmp QWORD [rbp - 32], 0
  jle .continue
  mov rdi, [rbp - 24]
  mov rsi, [rbp - 32]
  call writeout
  jmp .continue

.continue:
  cmp BYTE [break_by], BREAK_BY_EOF
  je .eof
  cmp BYTE [break_by], BREAK_BY_LF
  je .write_lf 
  cmp BYTE [break_by], BREAK_BY_HT
  je .write_ht
  cmp BYTE [break_by], BREAK_BY_NON_PRINTING
  je .write_non_printing
  jmp .loop

.eof:
  jmp .exit

.write_lf:
  mov rdi, [rbp - 32]
  call write_lf
  jmp .loop

.write_ht:
  call write_show_tabs
  jmp .loop

.write_non_printing:
  mov rsi, [rbp - 16]
  dec rsi
  mov al, [rsi]
  movzx rsi, al
  mov rbx, non_printing_characters_table
  mov rdi, [rbx + rsi * 8]
  push rdi
  call memlen
  pop rdi
  mov rsi, rax
  call writeout
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
  jne .handle_input
  mov BYTE [has_handled_files], 1
  mov rax, SYS_OPEN
  mov rdi, [rbp - 8]
  mov esi, O_RDONLY
  mov edx, S_IRWXU
  syscall
  cmp rax, 0 ; check for error
  jl .open_error
  mov DWORD [rbp - 16], eax
  mov BYTE [can_handle_input], 1
  mov BYTE [can_write_line_count], 1
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
  jmp .exit

.handle_input:
  test BYTE [can_handle_input], 1
  jz .exit
  mov rdi, [rbp - 8]
  mov rsi, DASH
  call memcmp
  test al, 1
  jz .exit
  mov BYTE [can_handle_input], 0
  call handle_input

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
  mov BYTE [can_write_line_count], 1

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
  call writeout_file_content
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

.handle_args:
  mov edi, [rbp - 16]
  mov rsi, [rbp - 8]
  call handle_options
  mov edi, [rbp - 16]
  mov rsi, [rbp - 8]
  call handle_files
  test BYTE [has_handled_files], 1
  jz .handle_input
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
