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

        ; параметры из C:
        ; rdi: imgfrom
        ; rsi: imgto
        ; edx: src_width
        ; ecx: src_height
        ; r8d: x1
        ; r9d: y1
        ; [rbp+16]: x2
        ; [rbp+24]: y2

        mov r12, rdi            ; r12 = imgfrom
        mov r13, rsi            ; r13 = imgto
        movsxd r14, edx         ; r14 = src_width (64-bit)
        movsxd r15, ecx         ; r15 = src_height (64-bit)

        movsxd r8, r8d          ; r8 = x1
        movsxd r9, r9d          ; r9 = y1

        ; загружаем x2 и у2 из стека (int, 4 байта)
        mov eax, dword [rbp+16]
        movsxd r10, eax         ; r10 = x2
        mov eax, dword [rbp+24]
        movsxd r11, eax         ; r11 = y2 (64-bit)

        ; dst_width = x2 - x1 + 1
        mov rbx, r10            ; rbx = x2
        sub rbx, r8             ; rbx = x2 - x1
        inc rbx                 ; rbx = dst_width

        ; dst_height = y2 - y1 + 1
        mov rax, r11            ; rax = y2
        sub rax, r9             ; rax = y2 - y1
        inc rax                 ; rax = dst_height
        mov rdi, rax            ; rdi = dst_height (граница цикла y_dst)

        ; внешний цикл для y_dst
        ; rcx будет счётчиком для y_dst (0 -> dst_height-1)
        xor rcx, rcx            ; rcx = y_dst = 0
.y_loop:
        cmp rcx, rdi            ; cmp y_dst, dst_height (rdi)
        jge .end_y_loop         ; if y_dst >= dst_height, выход из y_loop

        ; внутренний цикл для x_dst
        ; rdx будет счётчиком для x_dst (0 -> dst_width-1)
        xor rdx, rdx            ; rdx = x_dst = 0
.x_loop:
        cmp rdx, rbx            ; cmp x_dst, dst_width (rbx)
        jge .end_x_loop         ; if x_dst >= dst_width, выход из x_loop

        ; x_src = x1 + x_dst
        mov rax, r8             ; rax = x1 (r8)
        add rax, rdx            ; rax = x1 + x_dst (rdx)
        mov rsi, rax

        ; y_src = y1 + y_dst
        mov rax, r9             ; rax = y1 (r9)
        add rax, rcx            ; rax = y1 + y_dst (rcx)

        ; адрес нужного пикселя в изначальной картинке: (y_src * src_width + x_src) * 4
        imul rax, r14           ; rax = y_src * src_width (r14)
        add rax, rsi            ; rax = (y_src * src_width) + x_src (rsi)
        shl rax, 2              ; rax = (y_src * src_width + x_src) * 4 (смещение)
        mov rsi, rax

        ; адрес пикселя, куда писать: (y_dst * dst_width + x_dst) * 4
        mov rax, rcx            ; rax = y_dst (rcx)
        imul rax, rbx           ; rax = y_dst * dst_width (rbx)
        add rax, rdx            ; rax = (y_dst * dst_width) + x_dst (rdx)
        shl rax, 2              ; rax = (y_dst * dst_width + x_dst) * 4 (смещение)

        ; r12 = src_base_ptr, r13 = dst_base_ptr
        mov r10d, dword [r12 + rsi]   ; считать 4 байта из src_base_ptr[src_byte_offset]
        mov dword [r13 + rax], r10d   ; записать 4 байта в dst_base_ptr[dst_byte_offset]

        inc rdx                 ; x_dst++
        jmp .x_loop
.end_x_loop:
        inc rcx                 ; y_dst++
        jmp .y_loop

.end_y_loop:
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        pop rbp
        ret

