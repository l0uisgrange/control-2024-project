; file lcd.asm
; purpose LCD HD44780U initialization

.equ    LCD_IR = 0x8000         ; address LCD instruction reg
.equ    LCD_DR = 0xc000         ; address LCD data register

.macro  LD_IR
a:      lds     r16, LCD_IR     ; read the SRAM (LCD IR) into r16
        sbrc    r16, 7          ; check the busy flag (bit7)
        rjmp    a               ; jump back if busy flag set
        ldi     r16, @0         ; load value into r16
        sts     LCD_IR, r16     ; store value to SRAM (LCD IR)
        .endmacro


main:
        LD_IR    0b00000001      ; clear display
        LD_IR    0b00000010      ; return home
        LD_IR    0b00000110      ; entry mode set
        LD_IR    0b00001111      ; display on/off control


loop:
        rjmp loop