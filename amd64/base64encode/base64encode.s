/*
** Base 64 Encode
**
** Encode in base64 content read on STDIN and print it to STDOUT
**
*/
.section .rodata
b64chars:
    .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"    
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
    **      1024 bytes to read from stdin 1364(%rsp)
    **      1364 bytes to write base64 message (%rsp)
    */
    subq    $2420,              %rsp        
    /*
    ** Read input on STDIN
    */
read_input:
    mov     $0,                 %rax        /* Read syscall */
    mov     $0,                 %rdi        /* Set fd to STDIN */
    leaq    1364(%rsp),         %rsi        /* Write result on stack */
    mov     $1023,              %rdx        /* Read length */
    syscall
    
    mov     %rax,               -8(%rbp)    /* Copy read length to message size */

    cmp     $0,                 %rax         /* If  nothing on stdin jump to end */
    je      exit_0

    xor     %rdx,               %rdx        /* Compute result length and overrid */
    mov     $3,                 %rbx        /* Set divisor, dividend is already in rax */
    div     %rbx                            /* Divide message length by 3 */
    mov     %rdx,               %rdi        /* Save remainded  */
    mov     $4,                 %rbx        /* Multiply quotient by 4 to get result size */
    mul     %rbx
    mov     %rax,               -32(%rbp)   /* Save result length */
    cmp     $0,                 %rdi        /* If padding required */
    je      encode                         
    addq    $4,                 -32(%rbp)   /* Add 4 to message length */
    movq    $3,                 -16(%rbp)   /* Compute override */
    subq    %rdi,               -16(%rbp)   

encode:                                     /* Initialize loop */        
    movq    $0,                 -24(%rbp)   /* Current message position */
    mov     $0,                 %rdx        /* Current Output position */
    leaq    b64chars,           %rbx        /* Address of b64chars */
encoding_loop:
    xor     %rax,               %rax        /* Set rax to 0 */
    xor     %rdi,               %rdi        /* Set rdi to 0 */
    movq    -24(%rbp),          %rdi        /* Get read position */
    mov     $3,                 %rcx        /* Move bytes to big endian */
big_endian:
    movb    1364(%rsp, %rdi),   %al
    shl     $8,                 %rax
    inc     %rdi
    loop    big_endian
    shr     $8,                 %rax
            
    mov     $4,                 %rcx        /* Encode next 3 bytes */
get_c:
    movl    %eax,               %esi        /* Copy bytes */
    shr     $18,                %esi        /* Keep only 6 higher bits */
    and     $0x3F,              %esi        /* Only keep 6 bits */
    movb    (%rbx,%rsi),        %sil        /* Get corresponding char */
    movb    %sil,               (%rsp,%rdx) /* Mov to char to result */
    shl     $6,                 %eax        /* Move to next 6 bits */
    inc     %rdx                            /* Increment result position */
    loop    get_c

    addq    $3,                 -24(%rbp)   /* Increment message position by 3 */   
    movq    -8(%rbp),           %rax        
    cmpq    %rax,               -24(%rbp)   /* Compare position to message length */
    jl      encoding_loop                   /* Jump if there are bytes left */
    
    movq    -16(%rbp),          %rcx        /* Check if padding is required */
    cmp     $0,                 %rcx        
    je      end_encode
    movq    -32(%rbp),          %rax        /* Add = * override at end of result */
    subq    %rcx,               %rax
padding:
    movb    $0x3d,              (%rsp,%rax)
    inc     %rax
    loop    padding

end_encode:
    mov     $1,                 %rax        /* Write result on stdout */
    mov     $1,                 %rdi
    leaq    (%rsp),             %rsi        /* Move down the stack with buf_len!! */
    mov     -32(%rbp),          %rdx
    syscall
    
    cmpq    $1023,              -8(%rbp)    /* Check if there is still data on stdin */ 
    je      read_input

exit_0:
    /* Exit 0 */
    xor     %rdi,               %rdi
    mov     $60,                %rax
    syscall
