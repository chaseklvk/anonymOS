print:
  pusha               ; Push registers to stack

  start:
    mov al, [bx]        ; Base address for string
    cmp al, 0
    je done

    ; Print w/ help from BIOS
    mov ah, 0x0e        
    int 0x10

    ; Increment the pointer
    add bx, 1 
    jmp start
  done:
    popa
    ret

print_nl:
  pusha

  mov ah, 0x0e
  mov al, 0x0a        ; Newline character
  int 0x10 
  mov al, 0x0d        ; Carriage return
  int 0x10

  popa
  ret