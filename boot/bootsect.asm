[org 0x7c00]                    ; Global memory offset. Bootloader is placed here
KERNEL_OFFSET equ 0x1000

  mov [BOOT_DRIVE], dl          ; BIOS sets the boot drive

  mov bp, 0x9000                ; Set the stack location
  mov sp, bp

  mov bx, MSG_REAL_MODE
  call print
  call print_nl

  call load_kernel              ; Read kernel from disk
  call switch_to_pm             ; disable interrupts, load GDT, finally jumps to BEGIN_PM
  jmp $                         ; Never executed

%include "boot/print.asm"
%include "boot/32bitgdt.asm"
%include "boot/32bitprint.asm"
%include "boot/32bitswitch.asm"
%include "boot/disk.asm"
%include "boot/printhex.asm"

[bits 16]
load_kernel:
  mov bx, MSG_LOAD_KERNEL
  call print
  call print_nl

  mov bx, KERNEL_OFFSET
  mov dh, 16                        ; Accounts for larger kernel
  mov dl, [BOOT_DRIVE]
  call disk_load
  ret

[bits 32]
BEGIN_PM:                           ; This runs after switch
  mov ebx, MSG_PROT_MODE
  call print_string_pm
  call KERNEL_OFFSET                ; Hand over control to the kernel
  jmp $                             ; Stay here if the kernel hands back control

BOOT_DRIVE db 0                                           ; in case dl gets overwritten
MSG_REAL_MODE db 'Started in 16-bit real mode', 0
MSG_PROT_MODE db 'Loaded 32-bit protected mode', 0
MSG_LOAD_KERNEL db "Loading kernel into memory", 0

; Bootsector
times 510 - ($ - $$) db 0
dw 0xaa55