;;; https://www.nasm.us/doc/nasmdoc7.html
;;; These are just assembler directives, they don't occupy space in the actual program.
BITS 16                         ; We just use 16 bit execution mode,
                                ; hence this is needed for assembler to correctly encode
                                ; our instructions.
CPU X64                         ; Specify the CPU Arch.
ORG 0x7c00                      ; Short for Origin. This is an offset added to all internal address references.
                                ; See: https://www.nasm.us/doc/nasmdoc8.html#section-8.1.1

;;; This runs the hello world program then halts.
start:
    ;; SI is 16-bit source ptr for string ops; See 3.4 of intel manual.
    mov si,data
    CALL printstr
    ;; Halt execution once done.
    hlt

;;; Print string function, we will call this to print hello world.
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

;;; Print char function, we will print characters of "hello world" with this.
;;; Relies on VIDEO WRITE STRING Interrupt: http://www.ctyme.com/intr/rb-0210.htm
printchar:
    ;; BIOS interrupt to print char at AL.
    ;; How interrupt works: Move arguments into AH reg.
    mov AH,0x0E
    ;; Video service interrupt
    int 0x10
    ret

finish:
    ret

data:
    ;; data via pseudo instructions: https://www.nasm.us/doc/nasmdoc3.html#section-3.2
    ;; we use `db` to declare sequence of bytes
    db 'hello world'
    ;; What does ($-$$) mean?
    ;; $ refers to current pos, at the beginning of line containing the $ expr.
    ;; For instance, if you did `JMP $`,
    ;; The `$` refers its own address. Therefore it will rerun itself (`JMP $`), in an infinite loop.
    ;; `$$` refers to beginning of the current section.
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
