.section .text
.globl _start

_start:
    jmp escape_sheep
    nop
    nop
    nop
    nop
    nop
    nop
    nop
escape_sheep:
    xor     %rax, %rax
    movb    $0x2, %dil
    movb    $0x3c, %al
    syscall
