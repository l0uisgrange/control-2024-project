; file  keypad.asm target ATmega128L
; purpose main file


; constants
.equ	KPD_DELAY = 30
.equ    KPD_COL = 0b00001111
.equ    KPD_ROW = 0b11110000


int_kpd:
        in      b0, PIND
        OUTI    DDRD, KPD_ROW
        OUTI    PORTD, KPD_ROW
        in      b1, PIND
        rcall   LCD_clear
        ldi     a0, 'I'
        rcall   lcd_putc
        ldi     a0, 'N'
        rcall   lcd_putc
        ldi     a0, 'T'
        rcall   lcd_putc
        reti