section .rodata
input:
  incbin "input"
eof:

section .text
  global _start
_start:

    mov rsi, input
    mov rbp, rsp
    xor rcx, rcx

readbytes:
  
  .number:
    cmp rsi, eof
    jae initpointers

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
    jae initpointers

    movzx rax, byte [rsi]
    inc rsi
    sub rax, 48

    cmp rax, 0
    jle readbytes

  .addempty:
    push -1
    dec rax
    jnz .addempty

    jmp readbytes

initpointers:
    xor rax, rax
    mov r8, rbp
    mov r9, rsp

  .loop:
    call findempty
    cmp rax, 1
    je accumulate
    mov r10, [r9]
    mov [r8], r10
    mov qword [r9], -1 

  .skipempty:
    add r9, 8
    cmp qword [r9], -1
    je .skipempty
    jmp .loop


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

accumulate:
    xor rcx, rcx
    xor rax, rax
    mov r8, rbp
    xor r15, r15

  .loop:
    sub r8, 8
    cmp qword [r8], -1
    je print
    mov rax, rcx
    mul qword [r8]
    add r15, rax
    inc rcx
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