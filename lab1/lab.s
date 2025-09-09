bits 64
;	result = a*c/b + d*b/e - c^2/(a*d)
section .data
result:
	dq	0
a:
	dd	25
b:	
	dw	70
c:
	dd	64
d:
	dw	10
e:
	dd	15

section .text
global _start
_start:
	; a*с/b  64 bit
	xor rax, rax ; обнулили
	mov eax, dword[a]
	xor rcx, rcx ;!
	mov ecx, dword[c]
	mul rcx ; результат в паре rdx:rax
	movzx rbx, word[b]
	test rbx, rbx
	jz err
	div rbx ; rdx:rax/rbx, result in rax
	mov rbx, rax ; res in rbx

	; d*b/e  32 bit
	movzx eax, word[d]
	movzx ecx, word[b]
	mul ecx ;результат в edx:eax
	mov ecx, dword[e]
	test ecx, ecx
	jz err
	div ecx ;edx:eax/ecx, результат в eax
	xor rsi, rsi
	mov esi, eax

	; c^2/(a*d)  64 bit
	xor rax, rax
	mov eax, dword[a]
	movzx rcx, word[d] 
	mul rcx ; результат в rdx:rax
	test rax, rax
	jz err
	mov rcx, rax;  
	xor rax, rax
	mov eax, dword[c]
	mul rax
	div rcx
	mov rdi, rax;

	; a*c/b + d*b/e
	add rbx, rsi
	jc err

	; a*c/b + d*b/e - c^2/(a*d) 
	sub rbx, rdi

	; result
	mov [result], rbx

	mov eax, 60
	mov edi, 0
	syscall

err:
	mov eax, 60
	mov edi, 1
	syscall
	
