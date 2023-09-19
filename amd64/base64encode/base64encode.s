/*
** Base 64 Encode
**
** Encode in base64 content read on STDIN and print it to STDOUT
**
*/
.text
.global _start
_start:
    pushq   %rbp
    mov     %rsp,       %rbp

    /*
    ** Allocating space on stack
    **
    **         8 bytes to store message length -8(%rbp)
    **         8 bytes to store override length -16(%rbp)
    **         8 bytes to store current position in message -24(%rbp)
    **         8 bytes to store result length -32(%rbp)
    **        64 bytes to store the dictionnary -96(%rbp) : 
    **            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    **      1024 bytes to read from stdin  -1096(%rbp) or 1364(%rsp)
    **      1364 bytes to write base64 message -2460(%rbp) or (%rsp)
    */
    subq    $32,                %rsp
    
    movabs  $0x2f2b393837363534,%rax
    push    %rax
    movabs  $0x333231307a797877,%rax
    push    %rax
    movabs  $0x767574737271706f,%rax
    push    %rax
    movabs  $0x6e6d6c6b6a696867,%rax
    push    %rax
    movabs  $0x6665646362615a59,%rax
    push    %rax
    movabs  $0x5857565554535251,%rax
    push    %rax
    movabs  $0x504f4e4d4c4b4a49,%rax
    push    %rax
    movabs  $0x4847464544434241,%rax
    push    %rax

    subq    $2388,          %rsp        
    /*
    ** Read input on STDIN
    */
read_input:
    mov     $0,                 %rax        /* Read syscall */
    mov     $0,                 %rdi        /* Set fd to STDIN */
    leaq    1364(%rsp),         %rsi        /* Write result on stack */
    mov     $1024,              %rdx        /* Read length */
    syscall
    
    mov     %rax,               -8(%rbp)    /* Copy read length to message size */

    /*
    ** Convert in b64 
    */            
    movl    %eax,               %ebx        /* Set dividend */
    movl    $3,                 %ecx        /* Set divisor */
    cdq
    div     %ecx                            /* Divide message length by 3 */
    xor     %rdi,               %rdi        /* Reset rdi to 0 */
    mov     %rdx,               %rdi        /* Saving remainder */
    /* Compute result length */
    mov     %rax,               -32(%rbp)
    mov     $4,                 %rcx
    mul     %rcx
    mov     %rax,               -32(%rbp)
    
    cmp     $0,                 %rdi
    je      encode                          /* if length % 3 = 0 no need to 
                                                pad with = at end of encode message */
    addq    $4,                 -32(%rbp)
    movq    $3,                 -16(%rbp)   /* Compute required padding */
    subq    %rdi,               -16(%rbp)
    movq    -16(%rbp),          %rcx

    /* 
    ** Remmember to fill padding with 0 
    */
encode:                                     /* Initialize loop */        
    movq    $0,                 -24(%rbp)
    mov     $0,                 %rdx        /* Output position */

encoding_loop:
    xor     %rax,               %rax        /* Set rax to 0 */
    xor     %rdi,               %rdi
    movq    -24(%rbp),          %rdi        /* Get read position */
    mov     $3,                 %rcx
big_endian:
    movb    1364(%rsp, %rdi),   %al        /* Get next 3 bytes big endian */
    shl     $8,                 %rax
    inc     %rdi
    loop    big_endian
    shr     $8,                 %rax

    mov     $4,                 %rcx        /* Set loop countdown to 4 */
get_c:
    movl    %eax,               %esi
    shr     $18,                %esi
    and     $0x3F,              %esi
    movb    -96(%rbp,%rsi),     %sil
    movb    %sil,               (%rsp,%rdx)
    shl     $6,                 %eax
    inc     %rdx
    loop    get_c

    /* loop condition */
    addq    $3,                 -24(%rbp)   /* increment position by 3 */   
    movq    -8(%rbp),           %rax        
    cmpq    %rax,               -24(%rbp)   /* Compare position to message length */
    jl      encoding_loop
    
    /*
    ** Padding with = if required
    */
    movq    -16(%rbp),          %rcx
    cmp     $0,                 %rcx
    je      end_encode
    movq    -32(%rbp),          %rax
    subq    %rcx,               %rax
padding:
    movb    $0x3d,              (%rsp,%rax)
    inc     %rax
    loop    padding

end_encode:

    /* Write on STDOUT */
    mov     $1,                 %rax
    mov     $1,                 %rdi
    leaq    (%rsp),             %rsi        /* Move down the stack with buf_len!! */
    mov     -32(%rbp),          %rdx
    syscall
    

exit_0:
    /* Exit 0 */
    xor     %rdi,               %rdi
    mov     $60,                %rax
    syscall
