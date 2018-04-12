print_hex:
  pusha

  xor cx, cx        ; Index variable

  hex_loop:
    cmp cx, 4       ; Loop 4 times
    je end

    mov ax, dx      ; Use ax as the working register
    and ax, 0x000f  ; Mask the first three digits
    add al, 0x30    ; Convert to ascii
    cmp al, 0x39    ; If > 9, add extra 8 to represent A to F
    jle step2
    add al, 7       ; 'A' is ASCII 65 instead of 58 so 65-58 = 7

  step2:
    mov bx, HEX_OUT + 5     ; base + length
    sub bx, cx              ; index variable
    mov [bx], al            ; Copy the ASCII char on al to the position pointed to by bx
    ror dx, 4               

    inc cx
    jmp hex_loop

  end:
    mov bx, HEX_OUT
    call print

    popa
    ret

  HEX_OUT:
    db '0x0000', 0        ; Reserve memory for new string