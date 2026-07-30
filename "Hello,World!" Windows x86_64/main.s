.intel_syntax noprefix

.include "constants.inc"

.global _start

.section .rodata, "rd"
	msg: .ascii "Hello, World!\n"
	.equ msg_len, . - msg 

.text
_start:
	sub rsp, 56

	mov rcx, STD_OUTPUT_HANDLE
	call GetStdHandle

	mov rcx, rax
	lea rdx, [rip + msg]
	mov r8, msg_len
	lea r9, [rsp+40]
	mov qword ptr [rsp+32], 0
	call WriteConsoleA

	mov rcx, STD_INPUT_HANDLE
	call GetStdHandle

	mov rcx, rax
	lea rdx, [rsp+48]
	mov r8, 1
	lea r9, [rsp+40]
	mov qword ptr [rsp+32], 0
	call ReadConsoleA

	add rsp, 56
	xor ecx, ecx
	call ExitProcess
	
