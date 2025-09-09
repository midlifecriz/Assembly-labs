bits 64
;	Sorting the columns of matrix using shell sort
section .data
rows:
	db	4 ;строки
columns:
	db	4 ;столбцы
matrix:
	dw	4, 5, 6, 7
	dw	1, -2, 4, 8
	dw	10, 12, -1, 0
	dw	5, 6, 1, 4
order:
	db 	1 ; 1 - возрастание, 0 - убывание

section .text
global _start
_start:
	; проверили что строк > 1
	mov ecx, [rows]
	cmp ecx, 1
	jle end ; rows<=1
	mov ebx, matrix

m1:
	; проверка количества столбцов + начало 
	xor edi, edi
	mov eax, [rbx] ;???
	mov ecx, [columns] 
	
	cmp ecx, 1
	jl end; columns<=0

	jmp while_start

shift_column:
	add ebx, 4 ;сдвиг на следующий столбец
	mov esi, [rows]
	shr esi, 1 ; step = size/2
	jmp while_step_is_not_zero

while_step_is_not_zero:
	cmp esi, 0
	jz shift_column ; step = 0
	
	mov r8, ecx ; save ecx
	mov ecx, [rows]
	jmp for_i_to_size
	;
	shr esi, 1 ; step/2
	jmp while_step_is_not_zero

for_i_to_size:
	mov eax, [ebx+ecx*4] ; element = data[i]
	mov edi, ecx ; index = i
	jmp while_find

while_find:
	cmp edi, esi ; index >= step?
	jge ;
	jmp 

insert:
	
end_of_program:
	xor edi, edi
	mov eax, 60
	syscall

