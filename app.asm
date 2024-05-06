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
        OUTI	KPDD,0xf0		; bit0-3 pull-up and bits4-7 driven low
	OUTI	KPDO,0x0f		;>(needs the two lines)
	OUTI	DDRB,0xff		; turn on LEDs
	OUTI	EIMSK,0x0f		; enable INT0-INT3
	OUTI	EICRB,0b0		;>at low level
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
        
