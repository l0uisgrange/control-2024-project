; file          app.asm target ATmega128L
; purpose       main file

.include "macros.asm"
.include "definitions.asm"

; interrupt vector table
.org    0
        jmp     reset
        jmp	isr_ext_int0	; external interrupt INT0


; reset before start
reset:
        ;       --------------          ; Activate interruptions
        LDSP    RAMEND                  ; load SP
        OUTI    EIMSK, 0b00000001       ; enable int0 (int_kpd)
        STSI    EICRA, (1<<ISC01 | 1<<ISC00)
        sei                             ; set global interrupt
        ;       --------------          ; configure PORTA as I/O
        OUTI    DDRD, KPD_COL
        OUTI    PORTD, KPD_COL          ; set bits 0-3 to 
        ;       --------------          ; START LCD reset
        rcall   LCD_init                ; initialize LCD
        rcall   LCD_blink_on            ; turn blinking on
        ;       --------------          ; start process
        jmp     intro

.include "lcd.asm"
.include "keypad.asm"

intro:
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

; main process
main:
        WAIT_MS 100
        rjmp    main
        
