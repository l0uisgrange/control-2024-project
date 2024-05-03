keypad:
    ldi     r16, 0x0f
    out     DDRD, r16
    ldi     r20, 0b11101111
    out     PORTD, r20
    nop
    in      r16, PIND
    andi    r16, 0b11110000
    ret