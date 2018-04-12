disk_load:
  pusha
  push dx             ; Save on stack for later user

  mov ah, 0x02        ; We want to read from disk 0x02 = 'read'
  mov al, dh          ; al = number of sectors to read
  mov cl, 0x02        ; Sector to start (sector 1 is boot sector)
  mov ch, 0x00        ; Cylinder
  mov dh, 0x00        ; Head number

  int 0x13
  jc disk_error

  pop dx
  cmp al, dh
  jne sectors_error
  popa
  ret

  disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh, ah                ; ah = error code, dl = disk drive that dropped the error
    call print_hex
    jmp disk_loop
  
  sectors_error:
    mov bx, SECTORS_ERROR
    call print
  
  disk_loop:
    jmp $

  DISK_ERROR: db 'Disk read error', 0
  SECTORS_ERROR: db 'Incorrect number of sectors read', 0
