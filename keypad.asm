; file  keypad.asm target ATmega128L
; purpose main file

keypad:
        in      r31, PINF

        ret