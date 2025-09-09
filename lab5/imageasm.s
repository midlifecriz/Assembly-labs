bits 64
global work_image_asm

section .text
work_image_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi ; входное изображение
    mov r13, rsi ; выходное изображение
    movsxd r14, edx ; ширина входного изображения
    movsxd r15, ecx ; высота входного изображения

    movsxd r8, r8d          ; x0
    movsxd r9, r9d          ; y0

    mov eax, dword [rbp+16] ; x1
    movsxd r10, eax
    mov eax, dword [rbp+24] ; y1
    movsxd r11, eax

    mov rbx, r10
    sub rbx, r8
    inc rbx ; ширина обрабатываемого региона

    mov rax, r11
    sub rax, r9
    inc rax ; высота обрабатываемого региона
    mov rdi, rax

    xor rcx, rcx
.y_loop:
    cmp rcx, rdi
    jge .end_y_loop

    xor rdx, rdx
.x_loop:
    cmp rdx, rbx
    jge .end_x_loop

    ; вычисляем смещение входного пикселя
    mov rax, r9
    add rax, rcx
    imul rax, r14
    mov rsi, r8
    add rsi, rdx
    add rax, rsi
    shl rax, 2          
    mov rsi, rax            ; смещение в байтах

    ; вычисляем смещение выходного пикселя
    mov rax, rcx
    imul rax, rbx
    add rax, rdx
    shl rax, 2

    ; top-left
    mov rax, rsi
    sub rax, r14
    shl rax, 2
    add rax, r12
    sub rax, 4
    mov r8d, dword [rax]

    ; top
    mov rax, rsi
    sub rax, r14
    shl rax, 2
    add rax, r12
    mov r9d, dword [rax]

    ; top-right
    mov rax, rsi
    sub rax, r14
    shl rax, 2
    add rax, r12
    add rax, 4
    mov r10d, dword [rax]

    ; left
    mov rax, rsi
    add rax, r12
    sub rax, 4
    mov r11d, dword [rax]

    ; center
    mov rax, rsi
    add rax, r12
    mov eax, dword [rax]

    ; right
    mov rbx, rsi
    add rbx, r12
    add rbx, 4
    mov ebx, dword [rbx]

    ; bottom-left
    mov rax, rsi
    add rax, r14
    shl rax, 2
    add rax, r12
    sub rax, 4
    mov ecx, dword [rax]

    ; bottom
    mov rax, rsi
    add rax, r14
    shl rax, 2
    add rax, r12
    mov edx, dword [rax]

    ; bottom-right
    mov rax, rsi
    add rax, r14
    shl rax, 2
    add rax, r12
    add rax, 4
    mov esi, dword [rax]

    ; свёртка 8*center - сумма остальных
    mov edi, eax
    shl edi, 3
    sub edi, r8d
    sub edi, r9d
    sub edi, r10d
    sub edi, r11d
    sub edi, ebx
    sub edi, ecx
    sub edi, edx
    sub edi, esi

    mov dword [r13 + rax], edi

    inc rdx
    jmp .x_loop

.end_x_loop:
    inc rcx
    jmp .y_loop

.end_y_loop:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

