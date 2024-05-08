; file keypad.asm

.include "macros.asm"
.include "definitions.asm"

; ——————————————— definitions ————————————————
.equ	KPD_DELAY = 30          ; keypad bouncing delay
.def	wr0 = r2	        ; detected row in hex
.def	wr1 = r1		; detected column in hex
.def	mask = r14		; row mask indicating which row has been detected in bin
.def	wr2 = r15	        ; semaphore: must enter LCD display routine, unary: 0 or other

; —————————— interrupt vector table ——————————
.org 0
	jmp     reset
	jmp	ext_int0        ; external interrupt INT0
	jmp	ext_int1        ; external interrupt INT1

; ————————— interrupt service routines ————————
ext_int0:
	_LDI	wr1, 0x00
	_LDI	mask, 0b10000000
	rjmp	column_detect

ext_int1:
	reti

column_detect:
	OUTI	PORTD, 0xff     ; bit4-7 driven high

col7:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b01111111     ; check column 7
	WAIT_MS	KPD_DELAY
	in	w, PIND
	and	w, mask
	tst	w
	breq	col6
	_LDI	wr1, w
	rjmp	row_detect

col6:
	_LDI	mask, 0b01000000
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0xbf     ; check column 7
	WAIT_MS	KPD_DELAY
	in	w, PIND
	and	w, mask
	tst	w
	breq	col5
	_LDI	wr1, w
	rjmp	row_detect

col5:
	_LDI	mask, 0b00100000
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0xdf     ; check column 7
	WAIT_MS	KPD_DELAY
	in	w, PIND
	and	w, mask
	tst	w
	breq	col4
	_LDI	wr1, 0x02
	rjmp	row_detect

col4:
	_LDI	mask, 0b00010000
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0xef     ; check column 7
	WAIT_MS	KPD_DELAY
	in	w, PIND
	and	w, mask
	tst	w
	breq	err_row0
	_LDI	wr1, 0x03
	rjmp	row_detect

; TODO TO BE COMPLETED AT THIS LOCATION

err_row0:
	rjmp	int_return

row_detect:
        OUTI    PORTD, 0x00

row7:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0xf7     ; check column 7
	WAIT_MS	KPD_DELAY
	in	w, PIND
	and	w, mask
	tst	w
	breq	row6
	_LDI	wr0, 0x00
	rjmp	int_return

row6:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0xfb     ; check column 7
	WAIT_MS	KPD_DELAY
	in	w, PIND
	and	w, mask
	tst	w
	breq	row5
	_LDI	wr0, 0x01
	rjmp	int_return

row5:

int_return:
	rcall   LCD_blink_off
        INVP	PORTB, 0         ; visual feedback of key pressed acknowledge
	ldi     _w, 10           ; sound feedback of key pressed acknowledge
	_LDI	wr2, 0xff
	reti
	
.include "lcd.asm"			; include UART routines
.include "printf.asm"		; include formatted printing routines

; —————— initialization and configuration ——————

.org 0x400

reset:	LDSP	RAMEND                  ; Load Stack Pointer (SP)
	rcall	LCD_init		; initialize UART
	OUTI	DDRD, 0xf0		; bit0-3 pull-up and bits4-7 driven low
	OUTI	PORTD, 0x0f		; output
	OUTI	DDRB, 0xff		; turn on LEDs
	OUTI	EIMSK, 0x0f		; enable INT0-INT3
	OUTI	EICRB, 0b0		;>at low level
	sbi	DDRE, SPEAKER           ; enable sound
	PRINTF  LCD
	.db	CR, "Welcome to", CR, LF, "Mastermind"
	.db     0
	; WAIT_MS 3000
	rcall   LCD_clear
	rcall   LCD_home
	PRINTF  LCD
	.db	CR, "Number to guess:", LF
	.db     0
	rcall   LCD_blink_on
	clr	wr0
	clr	wr1
	clr	wr2
	clr	a1
	clr	a2
	clr	a3
	clr	b1
	clr	b2
	clr	b3
	sei

; —————————————— main program ——————————————
main:
	tst     wr2				; check flag/semaphore
	breq    main
	clr	wr2
	clr	a0
	clr     a1
	clr     a2
	clr     a3
	add     a0, wr0
	clr     b0
	clr     b1
	clr     b2
	clr     b3
	add     b0, wr1

	PRINTF  LCD
	.db CR,LF,"->", FBIN, b
	.db 0
	rjmp	main
	
; code conversion table, character set #1 key to ASCII	
KPDConvTable:
.db '1', '2', '3', 'A'
.db '4', '5', '6', 'B'
.db '7', '8', '9', 'C'
.db '*', '0', '#', 'D'