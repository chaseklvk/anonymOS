[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f           ; the color byte for each character

print_string_pm:
  pusha
  mov edx, VIDEO_MEMORY

print_string_pm_loop:
  mov al, [ebx]                    ; Address of our character
  mov ah, WHITE_ON_BLACK 
  cmp al, 0                        ; Check if end of string
  je print_string_pm_done

  mov [edx], ax                     ; store character + attribute in video memory
  add ebx, 1                        ; next char
  add edx, 2                        ; next video memory position

  jmp print_string_pm_loop

print_string_pm_done:
  popa
  ret