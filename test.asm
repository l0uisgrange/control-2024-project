; file test.asm
; purpose test LCD on ATmega128

.include "macros.asm"
.include "definitions.asm"

reset :
        LDSP    RAMEND
        OUTI    DDRB, 0xff
        rcall   LCD_init
        rcall   LCD_blink_on
        jmp     intro

; === include ===
.include "lcd.asm"

intro :
        ldi     a0, 'A'
        rcall   lcd_putc
        ldi     a0, 'V'
        rcall   lcd_putc
        ldi     a0, 'R'
        rcall   lcd_putc
        