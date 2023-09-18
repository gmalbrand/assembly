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
    mov     %rcx,               %rdi        /* Saving remainder */
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
encoding_loop:
    xor     %rdx,               %rdx        /* Set rdx to 0 */
    movb    -24(%rbp),          %dl         /* Get first character position */
    movb    1364(%rsp, %rdx),   %al         /* Get first character */
    shr     $2,                 %al         /* Shift 2 bits right */
    movb    -96(%rbp,%rax),     %al
    movb    %al,                (%rsp,%rdx) /* Move result in response */

    movb    1364(%rsp, %rdx),   %al         /* Get first character */
    inc     %rdx                            /* Increment character position */
    movb    1364(%rsp, %rdx),   %cl         /* Get second character */
    andb    $0x3,               %al         /* Only keep last 2 bis */
    shl     $4,                 %al         /* Shift 4 bits left of first character */
    shr     $4,                 %cl         /* Shift 4 bits right of second character */
    orb     %al,                %cl         /* Get new value */
    movb    -96(%rbp, %rcx),    %al         /* Get corresponding character */
    movb    %al,                (%rsp,%rdx) /* Move result in response */

    movb    1364(%rbp, %rdx),   %al         /* Get second character */
    inc     %rdx                            /* Increment character position */
    movb    1364(%rbp, %rdx),   %cl         /* Get Third character */
    andb    $0xF,               %al         /* Only keep first 4 bits */
    shl     $2,                 %al         /* Shift 2 bits left */
    shr     $6,                 %cl         /* Shift 6 bits right */
    orb     %al,                %cl         /* Get new value */
    movb    -96(%rbp, %rcx),    %al         /* Get corresponding character */
    movb    %al,                (%rsp,%rdx) /* Move result in response */

    movb    1364(%rbp, %rdx),   %al         /* Get third character */
    inc     %rdx                            /* Increment character position */
    and     $0x3F,              %al         /* Only keep the first 6 bits */
    movb    -96(%rbp, %rax),    %al         /* Get corresponding character */
    movb    %al,                (%rsp,%rdx) /* Move result in response */
    
    /* loop condition */
    addq    $3,                 -24(%rbp)   /* increment position by 3 */   
    movq    -8(%rbp),           %rax        
    cmpq    %rax,               -24(%rbp)   /* Compare position to message length */
    jl      encoding_loop
    
    /*
    ** Padding with = if required
    */

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
