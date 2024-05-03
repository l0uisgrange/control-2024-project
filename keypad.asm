; file  keypad.asm target ATmega128L
; purpose main file

; constants
.equ	KPD_DELAY = 30

int_keypad:
        in      r31, PINA
        reti