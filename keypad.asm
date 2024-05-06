; file  keypad.asm target ATmega128L
; purpose main file

	; === definitions ===
.equ	KPD_COL = 0b00001111
.equ	KPD_ROW = 0b11110000

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
        WAIT_MS 2000
        ldi     a0, 'E'                 ; write character 'A'
        rcall   lcd_putc
        ldi     a0, 'n'                 ; write character 'V'
        rcall   lcd_putc
        ldi     a0, 't'                 ; write character 'R'
        rcall   lcd_putc
        ldi     a0, 'e'                 ; write character 'A'
        rcall   lcd_putc
        ldi     a0, 'r'                 ; write character 'V'
        rcall   lcd_putc
        ldi     a0, ':'                 ; write character 'R'
        rcall   lcd_putc
        reti