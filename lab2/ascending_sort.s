bits 64
; Sorting columns of matrix using Shell sort (ascending sort)
; Задаем step, все элементы на расстоянии step сортируем вставками, step делим на 2 и т.д.
section .data
rows:
	db	2              
columns:
	db	2           
matrix:                        
	dw 4, 5
	dw 1, -2

section .text
global _start
_start:
    ; rows > 1 ?
	movzx r8d, byte [rows]
	cmp   r8d, 1
	jle   end_of_program

	mov   rbx, matrix
	; columns < 1 ? 
	movzx edx, byte [columns]
	cmp   edx, 1
	jl   end_of_program

	xor   r9d, r9d	; номер текущего столбца           

; внешний цикл по столбцам
column_loop:
	cmp   r9d, edx	;индекс текущего столбца < всего столбцов?
	jge   end_of_program ; все столбцы обработаны

	mov   esi, r8d	; esi = rows
	shr   esi, 1 ; step = rows/2

; проверка шага 
shell_step_loop:
	test  esi, esi
	jz    next_column  ; если step==0, то отсортировали
	mov   ecx, esi	; i = step

; цикл по одному столбцу (идем по строкам)
row_i_loop:
	cmp   ecx, r8d
	jge   step_done ; i >= rows => для этого step все прошли

	; читаем элемент матрицы
	mov   r15d, ecx
	imul  r15d, edx               
	add   r15d, r9d
	shl   r15d, 1                
	movzx r13d, word[rbx + r15]

	mov   eax, ecx ; index = i - сюда вставляем

; вставка с шагом
insert_loop:
	cmp   eax, esi
	jl    place_element ; index<step => мы нашли место

	; читаем предыдущий элемент (на расстоянии step)
	mov   r15d, eax
	sub   r15d, esi
	imul  r15d, edx              
	add   r15d, r9d              
	shl   r15d, 1
	movzx r10d, word[rbx + r15]  ; matrix[index-step][column]

	cmp   r10w, r13w ; prev <= текущего элемента?
	jle   place_element 
	jmp   shift_prev

; сдвигаем предыдущий элемент вниз
shift_prev:
	mov   r15d, eax
	imul  r15d, edx
	add   r15d, r9d
	shl   r15d, 1
	mov   [rbx + r15], r10w

	sub   eax, esi	; index -=step
	jmp   insert_loop ; продолжаем искать место

place_element:
	mov   r15d, eax
	imul  r15d, edx
	add   r15d, r9d
	shl   r15d, 1
	mov   [rbx + r15], r13w

	inc   ecx ; следующая строка
	jmp   row_i_loop

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

