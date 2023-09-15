/*
** Base 64 Encode
**
** Encode in base64 content read on STDIN and print it to STDOUT
**
*/
/* Syscall references */
.set    sys_read,   0
.set    sys_write,  1
.set    sys_exit,   60

/* Some values */
.set    std_in,     0
.set    std_out,    1
.set    buf_len,    1024

.text
.global _start
_start:
    pushq   %rbp
    mov     %rsp,       %rbp
    /*
    ** Read input on STDIN
    */
    pushq   $0                          /* Push message size on stack */
read_input:
    subq    $buf_len,       %rsp        /* Allocate memory on the stack */

    mov     $sys_read,      %rax        /* Read STDIN */
    mov     $std_in,        %rdi
    leaq    (%rsp),         %rsi
    mov     $buf_len,       %rdx
    syscall
    
    add     %rax,           -8(%rbp)    /* Add read length to message size */
    cmp     $buf_len,       %rax        /* Check if it read everything */
    je      read_input                  /* Continue reading if required */

    /*
    ** Convert in b64 
    */
    nop
    /*
    **  Writing down the stack on STDOUT
    */
    leaq    -8(%rbp),       %rsi        /* Start reading message from top of the stack */
    pushq   -8(%rbp)                    /* Push message size on stack */
write_loop:
    /* Write on STDOUT */
    mov     $sys_write,     %rax
    mov     $std_out,       %rdi
    leaq    -1024(%rsi),    %rsi        /* Move down the stack with buf_len!! */
    mov     $buf_len,       %rdx
    syscall
    
    subq    $buf_len,       (%rsp)      /* Decrease message size */
    jns     write_loop

    /* Exit 0 */
    xor     %rdi,           %rdi
    mov     $sys_exit,      %rax
    syscall
