%ifndef CAT_CCC_ASM
%define CAT_CCC_ASM

; https://en.wikipedia.org/wiki/Function_prologue_and_epilogue

; C Calling Convention begin
%macro ccc_begin 0
  push rbp
  mov rbp, rsp
%endmacro

; C Calling Convention end
%macro ccc_end 0
  mov rsp, rbp
  pop rbp
  ret
%endmacro

%endif ; CAT_CCC_ASM
