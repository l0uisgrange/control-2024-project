; file  keypad.asm target ATmega128L
; purpose main file

; constants
.equ	KPD_DELAY = 30
.equ    KPD_COL = 0b00001111
.equ    KPD_ROW = 0b11110000


int_keypad:
        in      r31, PINA
        reti