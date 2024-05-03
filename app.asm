; file  app.asm target ATmega128L
; purpose main file

.include "lcd.asm"

; interrupt vector table
.org 0
        jmp     reset
        jmp     int_keypad

; reset before start
reset:
        ldi     r31, 0x00       ; configure portF as input
        out     DDRF, r31
        ;       ---------       ; LCD reset
        in      r16, MCUCR      ; enable ext. SRAM access
        sbr     sbr, (1<<SRE)+(1<<SRW10)
        rjmp main

main:
        ; code


