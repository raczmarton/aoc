section .rodata
input:
  incbin "input"
eof:

section .data
done: TIMES 1000000 db 0 ; No more segfault porfavor

section .text
global _start
_start:

    mov rsi, input
    mov rbp, rsp
    xor rcx, rcx

readbytes:
  
  .number:
    cmp rsi, eof
    jae resolve

    movzx rax, byte [rsi]
    inc rsi
    sub rax, 48

    cmp rax, 0
    jle .empty

  .addnumber:
    push rcx
    dec rax
    jnz .addnumber

    inc rcx

  .empty:
    cmp rsi, eof
    jae resolve

    movzx rax, byte [rsi]
    inc rsi
    sub rax, 48

    cmp rax, 0
    jle readbytes

  .puthole:
    push -1
    dec rax
    jnz .puthole

    jmp readbytes

resolve:
    xor rax, rax
    mov r8, rbp
    mov r9, rsp

  .loop:
    mov r11, 0

  .size:
    inc r11
    mov r10, [r9+8*r11]
    cmp r10, [r9]
    je .size

    mov r10, [r9]
    cmp byte [done+r10], 1
    je .nextchunk

    mov byte [done+r10], 1

    call findemptywithsize
    cmp rax, 1
    je .nextchunk

  .move:
    mov r10, [r9]
    mov [r8], r10
    mov qword [r9], -1
    add r9, 8
    sub r8, 8
    dec r11
    jnz .move
    sub r9, 8
    jmp .skipempty

  .nextchunk:
    mov rax, 8
    mul r11
    add r9, rax 

  .skipempty:
    cmp r9, rbp
    jae accumulate
    cmp qword [r9], -1
    jne .loop
    add r9, 8
    jmp .skipempty

findempty:
    sub r8, 8
    cmp r8, r9
    jle .none
    cmp qword [r8], -1
    jne findempty
    ret

  .none:
    mov rax, 1
    ret

findemptywithsize:
    mov r8, rbp

  .loopback:
    call findempty
    cmp rax, 1
    je .none
    xor rax, rax
    xor rcx, rcx
    
  .findnext:
    dec rcx
    cmp qword [r8+8*rcx], -1
    je .findnext
   
    neg rcx
    cmp rcx, r11
    jl .loopback
    jmp .end

  .none:
    mov rax, 1
  .end:
    ret

accumulate:
    mov rcx, -1
    xor rax, rax
    mov r8, rbp
    xor r15, r15

  .loop:
    inc rcx
    sub r8, 8
    cmp r8, rsp
    je print
    cmp qword [r8], -1
    je .loop
    mov rax, rcx
    mul qword [r8]
    add r15, rax
    jmp .loop

print:
    mov rbp, rsp
    mov r10, 10
    sub rsp, 22
                       
    mov byte [rbp-1], 10  
    lea r12, [rbp-2]
    mov rax, r15

 .loop:
    xor edx, edx
    div r10
    add rdx, 48
    mov [r12], dl
    dec r12
    cmp r12, rsp
    jne .loop

    mov r9, rsp
    mov r11, 22
 .trim:
    inc r9
    dec r11
    cmp byte [r9], 48
    je .trim

    mov rax, 1
    mov rdi, 1
    mov rsi, r9
    mov rdx, r11
    syscall

    mov rax, 60
    mov rdi, 0
    syscall