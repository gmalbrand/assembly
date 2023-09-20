.text
.global _start
_start:
    
    /* 
    ** 8 bits division
    ** Args:
    ** - %al = dividend
    ** - %dil = divisor
    ** Result:
    ** - %al = quotient
    ** - %ah = remainded
    */
    movb    $9,         %al
    movb    $2,         %dil
    div     %dil
    /* Reset registers */
    xor     %rax,       %rax
    xor     %rdi,       %rdi
    /* 
    ** 16 bits division 
    ** Args:
    ** - %ax = dividend
    ** - %di = divisor
    ** Result:
    ** - %ax = quotient
    ** - %dx = remainded
    */
    movw    $1024,      %ax
    movw    $3,         %di
    div     %di
    /* Reset registers */
    xor     %rax,       %rax
    xor     %rdx,       %rdx
    xor     %rdi,       %rdi
    /* 32 bits division
    ** Args:
    ** - %edx:%eax = dividend
    ** - %edi = divisor
    ** Result:
    ** - %eax = quotient
    ** - %edx = remainded
    */
    movl    $8096,      %eax
    movl    $0,         %edx
    movl    $3,         %edi
    div     %edi
    /* Reset registers */
    xor     %rax,       %rax
    xor     %rdx,       %rdx
    xor     %rdi,       %rdi
    /* 
    ** 64 bits division 
    ** Args:
    ** - %rdx:%rax = dividend
    ** - %rdi = divisor
    */
    mov     $0,         %rdx
    mov     $0xFFFFFFFF,%rax
    mov     $3,         %rdi
    div     %rdi
    nop
