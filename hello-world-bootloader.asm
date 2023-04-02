BITS 16
CPU X64
ORG 0x7c00

start:
    ;; SI is 16-bit source ptr for string ops; See 3.4 of intel manual.
    mov si,data
    ;; Video service interrupt
    ;; http://www.ctyme.com/intr/rb-0210.htm
    CALL printstr
    ;; Halt execution once done.
    hlt

printstr:
printnext:
    ;; print each char, use null delimiter
    mov AL, [SI]
    INC SI
    ;; set ZF flag to 0 if zero
    ;; && exit if zero
    OR AL,AL
    JZ finish
    ;; print char
    CALL printchar
    JMP printnext

printchar:
    ;; BIOS interrupt to print char at AL.
    ;; How interrupt works: Move arguments into AH reg.
    mov AH,0x0E
    ;; Then call the interrupt code.
    int 0x10
    ret

finish:
    ret

data:
    ;; data via pseudo instructions: https://www.nasm.us/doc/nasmdoc3.html#section-3.2
    ;; we use `db` to declare sequence of bytes
    db 'hello world'
    ;; See: https://www.nasm.us/doc/nasmdoc3.html#section-3.5
    ;; We use 510 because we skip the last two bytes for boot signature.
    ;; This pads our program until it is 512 bytes.
    ;; This is because it is the size of the physical boot sector,
    ;; it MUST be 512 bytes exactly.
    ;; (Recall we are actually emulating a physical boot sector, via qemu.)
    ;; Otherwise qemu doesn't know what to do with missing bytes.
    TIMES 510 - ($ - $$) db 0
    ;; Indicate we are bootable.
    DW 0xAA55
