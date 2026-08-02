.intel_syntax noprefix

.include "constants.inc"

.global _start

.macro macro_input buffer, len
	mov rcx, [rip + hConIn]
	lea rdx, [rip + \buffer]
	mov r8, \len
	lea r9, [rsp+40]
	mov qword ptr [rsp+32], 0
	call ReadConsoleA
.endm

.macro macro_output buffer, len
	mov rcx, [rip + hConOut]
	lea rdx, [rip + \buffer]
	mov r8, \len
	lea r9, [rsp+40]
	mov qword ptr [rsp+32], 0
	call WriteConsoleA
.endm

.section .rodata, "rd"
	msg_number1: .ascii "Input number 1: "
	msg_number2: .ascii "Input number 2: "
	.equ msg_number_len, . - msg_number2

	msg_math: .ascii "Mathematical operation: "
	.equ msg_math_len, . - msg_math 

	msg_input: .string "%11d"
	msg_result: .string "Result %d\n"

	msg_zero: .ascii "Math Error\n"
	.equ msg_zero_len, . - msg_zero 

.bss
	.lcomm hConOut, 8
	.lcomm hConIn, 8

	.lcomm buffer, 16
	.equ buffer_size, 16

	.lcomm number1, 4
	.lcomm number2, 4

	.lcomm math, 1

.text
.p2align 4,,15
clearConsole:
	sub rsp, 56

	.Lclear:
		mov rcx, [rip + hConIn]
		lea rdx, [rsp+48]
		mov r8, 1
		lea r9, [rsp+40]
		mov qword ptr [rsp+32], 0
		call ReadConsoleA

		mov cl, [rsp+48]
		cmp cl, '\n'
		jne .Lclear

	add rsp, 56
	ret 

_start:
	push rdi
	sub rsp, 48

	mov rcx, STD_INPUT_HANDLE
	call GetStdHandle
	mov [rip + hConIn], rax

	mov rcx, STD_OUTPUT_HANDLE
	call GetStdHandle
	mov [rip + hConOut], rax

	.p2align 4,,7
	.Lloop:
		macro_output msg_number1, msg_number_len
		macro_input buffer, buffer_size

		lea rcx, [rip + buffer]
		lea rdx, [rip + msg_input]
		lea r8, [rip + number1]
		call sscanf
		cmp rax, 1
		jne .Lloop

		lea rdi, [rip + buffer]
		mov rcx, buffer_size
		mov al, '\n'
		cld
		repne scasb 
		test rcx, rcx
		jnz 1f
		call clearConsole

		1:
		macro_output msg_math, msg_math_len
		macro_input buffer, 1

		call clearConsole

		mov cl, [rip + buffer]

		cmp cl, '+'
		je 1f
		cmp cl, '-'
		je 1f
		cmp cl, '*'
		je 1f
		cmp cl, '/'
		jne .Lloop

		1:
		mov [rip + math], cl 

		macro_output msg_number2, msg_number_len
		macro_input buffer, buffer_size

		lea rcx, [rip + buffer]
		lea rdx, [rip + msg_input]
		lea r8, [rip + number2]
		call sscanf
		cmp rax, 1
		jne .Lloop

		lea rdi, [rip + buffer]
		mov rcx, buffer_size
		mov al, '\n'
		repne scasb
		test rcx, rcx
		jnz 1f
		call clearConsole

		1:
		mov cl, [rip + math]
		cmp cl, '+'
		je .Lplus
		cmp cl, '-'
		je .Lminus
		cmp cl, '*'
		je .Ltimes

		mov ecx, [rip + number2]
		test ecx, ecx
		jz .Lzero
		mov eax, [rip + number1]

		cdq
		idiv ecx

		lea rcx, [rip + msg_result]
		movsxd rdx, eax
		call printf
		jmp .Lexit

		.Lzero:
			macro_output msg_zero, msg_zero_len
			jmp .Lloop

		.Lplus:
			mov eax, [rip + number1]
			add eax, [rip + number2]

			lea rcx, [rip + msg_result]
			movsxd rdx, eax
			call printf
			jmp .Lexit

		.Lminus:
			mov eax, [rip + number1]
			sub eax, [rip + number2]

			lea rcx, [rip + msg_result]
			movsxd rdx, eax
			call printf
			jmp .Lexit

		.Ltimes:
			mov eax, [rip + number1]
			imul eax, [rip + number2]

			lea rcx, [rip + msg_result]
			movsxd rdx, eax
			call printf

		.Lexit:
			macro_input buffer, 1

			add rsp, 48
			pop rdi
			xor ecx, ecx
			call ExitProcess
			
