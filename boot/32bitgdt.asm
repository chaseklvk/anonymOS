gdt_start:
  dd 0x0            ; 4 Byte
  dd 0x0            ; 4 Byte

gdt_code:
  dw 0xffff         ; Segment length, bits 0-15
  dw 0x0            ; Segment base, bits 0-15
  db 0x0            ; Segment base, bits 16-23
  db 10011010b      ; flags (8bits)
  db 11001111b      ; flags (4bits) + segment length, bits 16-19
  db 0x0            ; Segment base, bits 24-31

gdt_data:
  dw 0xffff
  dw 0x0
  db 0x0
  db 10010010b
  db 11001111b
  db 0x0

gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1        ; size (16 bit), always one less of its true size
  dd gdt_start                      ; address (32 bit)

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start