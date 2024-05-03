; file  app.asm target ATmega128L
; purpose main file

reset:
        ldi     r31, 0x00   ; configure portF as output
        out     DDRF, r31