bits 64
; a^x = sum[(x*ln(a))^n]/n!
section .data
msg1:
	db	"Input a", 10, 0
msg2:
	db	"Input x", 10, 0
msg3:
	db	"Input eps", 10, 0
msg4:
	db	"%lf", 0
msg5:
	db	"pow(%.10g, %.10g)=%.10g", 10, 0
msg6:
	db	"mypow(%.10g, %.10g)=%.10g", 10, 0
msg7:
	db	"term[%d]=%.10g", 10, 0
mode:
	db	"w", 0
error_fopen:
	db	"Cannot open file", 10, 0
error_a:
	db	"a must be greater than 0", 10, 0
one:
	dq	1.0
zero:
	dq	0.0
abs_mask:
	dq 0x7FFFFFFFFFFFFFFF

section .text

a	equ	8
x	equ	a+8
eps	equ	x+8
res	equ	eps+8

my_pow:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 56 ; на стеке под локальные переменные
	push	rbx
	mov	rbx, rdi ; в rdi был дескриптор

	; проверка a>0
	movsd	[rbp-8], xmm0 ; a
	movsd	[rbp-16], xmm1 ; x
	movsd	[rbp-24], xmm2 ; eps
	comisd	xmm0, qword [zero]
	jbe	.error_a

	; считаем log(a)
	movsd	xmm0, [rbp-8]
	call	log
	movsd	[rbp-32], xmm0
	movsd	xmm0, [rbp-16]
	; x*log(a)
	mulsd	xmm0, [rbp-32]
	movsd	[rbp-32], xmm0

	movsd	xmm0, [one]
	movsd	xmm1, xmm0 ; в xmm1 накапливаем сумму ряда
	movsd	xmm2, xmm0 ; в xmm2 текущий член ряда (term)
	mov	ecx, 1

.loop:
	movsd	xmm0, xmm2
	mulsd	xmm0, [rbp-32] ; term*xlog(a)
	cvtsi2sd xmm3, ecx
	divsd	xmm0, xmm3 ; делим на n
	movsd	xmm2, xmm0

	addsd	xmm1, xmm2 ; обновили сумму

	; сохраняем, чтобы ничего не слетело
	movsd	[rbp-40], xmm1 ;sum
	movsd	[rbp-48], xmm2 ;term

	; печать в файл
	mov	dword[rbp-52], ecx ; чтобы тоже не слетел
	mov	rdi, rbx
	mov	rsi, msg7
	mov	edx, ecx
	movsd	xmm0, [rbp-48]
	mov	eax, 1
	call	fprintf

	; восстанавливаем значения регистров
	mov	ecx, dword[rbp-52]
	movsd	xmm1, [rbp-40]
	movsd	xmm2, [rbp-48]

	; берем модуль и сравниваем с eps
        movsd  xmm0, xmm2
	call	fabs
        comisd  xmm0, [rbp-24]
        ja      .continue 
        jmp     .done

.continue:
	; |term|>eps
	inc	ecx
	jmp	.loop

.done:
	; |term|<eps
	movapd	xmm0, xmm1
	pop	rbx
	leave
	ret

.error_a:
	mov	rdi, error_a
	xor	eax, eax
	call	printf
	mov	eax, 1
	pop	rbx
	leave
	ret


extern	printf
extern	scanf
extern	pow
extern	log
extern 	fabs
extern	fopen
extern	fprintf
extern	fclose

global	main

main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, res

	cmp	rdi, 2
	jne	.error_fopen

	mov	rdi, [rsi+8]
	mov	rsi, mode
	call	fopen
	test	rax, rax 
	jz	.error_fopen
	mov	rbx, rax

	; input a
	mov	rdi, msg1
	xor	eax, eax
	call	printf

	mov	rdi, msg4
	lea	rsi, [rbp-a]
	xor	eax, eax
	call	scanf

	; a>0?
	movsd 	xmm0, [rbp-a]
	comisd	xmm0, qword[zero]
	jbe	.error_a

	; input x
	mov	rdi, msg2
	xor	eax, eax
	call	printf

	mov	rdi, msg4
	lea	rsi, [rbp-x]
	xor	eax, eax
	call	scanf

	; input eps
	mov	rdi, msg3
	xor	eax, eax
	call	printf

	mov	rdi, msg4
	lea	rsi, [rbp-eps]
	xor	eax, eax
	call	scanf
	
	; call pow
	movsd	xmm0, [rbp-a]
	movsd	xmm1, [rbp-x]
	call	pow
	movsd	[rbp-res], xmm0
	
	;print pow result
	mov	edi, msg5
	movsd	xmm0, [rbp-a]
	movsd	xmm1, [rbp-x]
	movsd	xmm2, [rbp-res]
	mov	eax, 3
	call	printf

	; call my_pow
	movsd	xmm0, [rbp-a]
	movsd	xmm1, [rbp-x]
	movsd	xmm2, [rbp-eps]
	mov	rdi, rbx
	call	my_pow
	movsd	[rbp-res], xmm0

	; print my_pow result
	mov	edi, msg6
	movsd	xmm0, [rbp-a]
	movsd	xmm1, [rbp-x]
	movsd	xmm2, [rbp-res]
	mov	eax, 3
	call	printf

	; close file
	mov	rdi, rbx
	call	fclose

	; end of program
	leave
	xor	eax, eax
	ret

.error_fopen:
	mov	rdi, error_fopen
	xor	eax, eax
	call	printf
	mov	eax, 1
	leave
	ret

.error_a:
        mov     rdi, error_a
        xor     eax, eax
        call    printf
        mov     eax, 1
        pop     rbx
        leave
        ret

