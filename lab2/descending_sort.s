bits 64
; Sorting columns of matrix using Shell sort (descending sort)
section .data
rows:
	db	4              
columns:
	db	4           
matrix:                        
	dw 4, 5, 6, 7
	dw 1, -2, 4, 8
    	dw 10, 12, -1, 0
	dw 5, 6, 1, 4

section .text
global _start
_start:
	; rows > 1 ?
	movzx r8d, byte [rows]
	cmp   r8d, 1
	jle   end_of_program

	mov   rbx, matrix
	; columns < 1?
	movzx edx, byte [columns]
	cmp   edx, 1
	jl   end_of_program

	xor   r9d, r9d ; номер текущего столбца              

; внешний цикл по столбцам
column_loop:
	cmp   r9d, edx ; индекс текущего столбца < их всего?
	jge   end_of_program	; все столбцы обработаны

	mov   esi, r8d	; esi = rows
	shr   esi, 1	; step = rows/2

; проверка шага
shell_step_loop:
	test  esi, esi
	jz    next_column ; step==0
	mov   ecx, esi	; i = step
	
; цикл по одному столбцу (идем по строкам)
row_i_loop:
	cmp   ecx, r8d
	jge   step_done	; i >= rows => для этого шага все прошли

	; читаем элемент матрицы
	mov   r15d, ecx
	imul  r15d, edx               
	add   r15d, r9d
	shl   r15d, 1                
	movzx r13d, word[rbx + r15]

	mov   eax, ecx ; index = i для вставки

; вставка с шагом
insert_loop:
	cmp   eax, esi
	jb    place_element ; index<step => мы нашли место

	; читаем предыдущий элемент на расстоянии step
	mov   r15d, eax
	sub   r15d, esi
	imul  r15d, edx              
	add   r15d, r9d              
	shl   r15d, 1
	movzx r10d, word [rbx + r15]

	; если prev > текущего элемента
	cmp   r10w, r13w
	jge   place_element

shift_prev:
	mov   r15d, eax
	imul  r15d, edx
	add   r15d, r9d
	shl   r15d, 1
	mov   [rbx + r15], r10w

	sub   eax, esi
	jmp   insert_loop

place_element:
	mov   r15d, eax
	imul  r15d, edx
	add   r15d, r9d
	shl   r15d, 1
	mov   [rbx + r15], r13w

	inc   ecx
	jmp   row_i_loop ; к следующей строке

; уменьшаем шаг
step_done:
	shr   esi, 1
	jmp   shell_step_loop

; к следующему столбцу
next_column:
	inc   r9d
	jmp   column_loop

end_of_program:
	xor   edi, edi
	mov   eax, 60
	syscall

