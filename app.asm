; file  app.asm target ATmega128L
; purpose main file

; === include ===
.include "lcd.asm"

; interrupt vector table
.org 0
        jmp     reset
        jmp     int_keypad

; reset before start
reset:
        ldi     r31, 0x00           ; configure portF as input
        out     DDRF, r31
        ;       --------------      ; START LCD resest
        LDSP    RAMEND              ; set up stack pointer
        OUTI    DDRB, 0xff          ; configure portB to output
        rcall   LCD_init            ; initialize LCD
        rcall   LCD_blink_on        ; turn blinking on
        jmp     intro
        ;       --------------      ; END LCD reset
        rjmp main


intro:
        ldi     a0, 'A'             ; write character 'A'
        rcall   lcd_putc
        ldi     a0, 'V'             ; write character 'V'
        rcall   lcd_putc
        ldi     a0, 'R'             ; write character 'R'
        rcall   lcd_putc


main:
        WAIT_MS 100
        CP0     PIND, 0, LCD_home
        CP0     PIND, 1, LCD_clear
        CP0     PIND, 2, LCD_display_right
        CP0     PIND, 3, LCD_display_left
        CP0     PIND, 4, LCD_cursor_right
        CP0     PIND, 5, LCD_cursor_left
        JP0     PIND, 6, intro
        rjmp    main