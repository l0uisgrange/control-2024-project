; file  app.asm target ATmega128L
; purpose main file

.include "lcd.asm"


reset:
        ldi     r31, 0x00       ; configure portF as input
        out     DDRF, r31
        ;       ---------       ; LCD reset
        in      r16, MCUCR      ; enable ext. SRAM access
        sbr     sbr, (1<<SRE)+(1<<SRW10)


