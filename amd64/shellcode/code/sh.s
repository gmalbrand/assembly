.text
.global _start
_start:
    nop
    xor     %rax,       %rax
    xor     %rsi,       %rsi
    movabs  $0x68732f6e69622f2f, %rdi
    shr     $8,         %rdi
    push    %rdi
    mov     %rsp,       %rdi
    movb    $59,        %al
    mov     %rsp,       %rdi
    syscall
