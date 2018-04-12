[bits 32]

; Call main from kernel.c
[extern main]
call main

; Hang the program
jmp $