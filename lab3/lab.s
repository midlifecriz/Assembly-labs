bits 64
; Change register in every string
section .data
size	equ	10 ; размер буфера
varname:
	db	"FILENAME", 0
err2:
	db	"No such file or directory", 10
err3:
	db	"Not found", 10

err3len	equ	$-err3

err13:
	db	"Permisssion denied", 10
err17:
	db	"File exists", 10
err21:
	db	"Is a directory", 10
err36:
	db	"File name too long", 10
err150:
	db	"Program does not require parameters", 10
err151:
	db	"Error reading filename", 10
err255:
	db	"Unknown error", 10
errlist:
	times	2	dd	err255
	dd	err2
	dd	err3
	times	9	dd	err255
	dd	err13
	times	3	dd	err255
	dd	err17
	times	3	dd	err255
	dd	err21
	times	14	dd	err255
	dd	err36
	times	113	dd	err255
	dd	err150
	dd	err151
	times	154	dd	err255
fdr:
	dd	-1	;дескриптор файла для чтения
	
; для записи - 1 (стандартный вывод)

section .text
global _start
_start:
	mov rax, [rsp]
	cmp rax, 1 ;сравниваем количество параметров
	je .m0

	mov ebx, 150
	jmp .m11 ; ошибка

;ПОИСК ПЕРЕМЕННОЙ ОКРУЖЕНИЯ
.m0:
	mov rdi, varname
	mov ebx, 2

.m1:
	; считываем переменные окружения
	inc ebx
	mov rsi, [rsp+rbx*8]
	or rsi, rsi
	je .m6 ; null
	xor ecx, ecx

.m2:
	; ищем нужную переменную
	mov al, [rdi+rcx]
	cmp al, [rsi+rcx]
	jne .m4 ;не совпали => следующая
	inc ecx
	jmp .m2

.m4:
	or al, al
	jne .m1
	cmp byte[rsi+rcx], '='
	jne .m1
	; совпало 
	lea rax, [rsi+rcx+1] ; это значение переменной (+1 потому что =)
	jmp .m7

.m6:
	; не нашли и выводим сообщение об ошибке
	mov eax, 1
	mov edi, 2 ; stderr
	mov esi, err3
	mov edx, err3len
	syscall
	mov ebx, 3 ; код ошибки
	jmp .m13

;OPEN FILE
.m7:
	; открываем файл на чтение
	mov rdi, rax
	xor esi, esi
	mov eax, 2
	syscall

	or eax, eax  ; если успешно открылся, eax >= 0, там файловый дескриптор
	jge .m8
	mov ebx, eax
	neg ebx ; делаем код ошибки положительным
	jmp .m10 ; обработчик ошибок

.m8:
	mov [fdr], eax ; сохранили дескриптор

.m9:
	mov edi, [fdr]
	mov esi, 1 ; 1 - вывод на экран
	call work  ; процедура обработки
	mov ebx, eax
	neg ebx

.m10:
	or ebx, ebx
	je .m12
	mov eax, 1
	mov edi, 1
	mov esi, [errlist+rbx*4]
	mov edx, 1

.m11:	;error != 0
	inc edx
	cmp byte [rsi+rdx-1], 10
	jne .m11
	syscall

.m12:	;error == 0
	cmp dword [fdr], -1
	je .m13 ;если файл не был открыт вообще
	; иначе если на чтение
	mov eax, 3
	mov edi, [fdr]
	syscall

.m13:
	; файл вообще не открывали
	mov edi, ebx
	mov eax, 60
	syscall

;кадр стека
bufin	equ	size 	; куда считываем файл
bufout	equ	size+bufin ; куда кладем обработанные строки
fr	equ	bufout+4
fw	equ	fr+4	; это 1
l	equ	fw+4	; счетчик букв
n	equ	l+4	; счетчик слов, нужен чтобы не вставить перед первым словом пробел

; обработчик
work:
	; подготовили регистры
	push rbp ;потому что портим
	mov rbp, rsp
	sub rsp, n
	push rbx
	mov [rbp-fr], edi
	mov [rbp-fw], esi ; это 1
	mov dword [rbp-l], 0
	mov dword [rbp-n], 0

.m0:
	;чтение из файла
	mov eax, 0
	mov edi, [rbp-fr]
	lea rsi, [rbp-bufin] ;указываем именно кадр стека, а не число
	mov edx, size
	syscall
	or eax, eax ; если успешно, то eax>=0
	jle .m8 ; ошибка
	; восстанавливаем регистры
	mov ebx, [rbp-l]
	mov edx, [rbp-n]
	lea rsi, [rbp-bufin]
	lea rdi, [rbp-bufout]
	mov ecx, eax ; заносим количество считанных байт

.m1:
	; начинаем считывать
	mov al, [rsi] ; считали символ, rsi++
	inc rsi

	; разделитель?
	cmp al, 10 ; если \n
	je .m4
	cmp al, 32 ; пробел
	je .m4
	cmp al, 9 ;tab
	je .m4 

	; если не разделитель
	or ebx, ebx
	jne .m2 
	; вставляем пробел, если не первое слово в строке
	or edx, edx
	je .m2
	mov byte [rdi], ' '
	inc rdi
	
.m2:	
	; проверка - меняем регистр или нет
	mov r8b, al
	or r8b, 0x20 ; разница между нижним и верхним регистром
	sub r8b, 'a'
	cmp r8b, 'z'-'a'
	ja .no_toggle ; ниче не надо 
	xor al, 0x20 ; меняем регистр

.no_toggle:
	; вставка буквы
	mov [rdi], al
	inc rdi

.m3:
	; инкремент счетчика
	inc ebx
	jmp .m6

.m4:
	; если разделитель, то мы здесь
	or ebx, ebx ; обработали это слово
	je .m5
	; не обработали
	xor ebx, ebx
	inc edx

.m5:
	; проверяем на конец строки, если он - обнуляем счетчик слов
	cmp al, 10
	jne .m6
	xor edx, edx
	mov byte [rdi], 10
	inc rdi

.m6:
	loop .m1 ; обработка следующего символа
	; цикл по всему считанному буферу
	mov [rbp-l], ebx
	mov [rbp-n], edx
	lea rsi, [rbp-bufout]
	mov rdx, rdi
	sub rdx, rsi
	mov ebx, edx

.m7:
	; пишем в файл
	mov eax, 1
	mov edi, [rbp-fw]
	syscall
	or eax, eax ; успешна ли запись
	jl .m8
	sub ebx, eax ; проверяем, все ли записали
	je .m0
	lea rsi, [rbp+rax-bufout]
	mov edx, ebx
	jmp .m7

.m8:
	; ошибку обработает основная программа
	pop rbx
	leave
	ret

