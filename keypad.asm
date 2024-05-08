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
	_LDI	mask, 0b10111111
	rjmp	row_detect

ext_int1:
	_LDI	wr1, 0x00
	_LDI	mask, 0b10111111
	rjmp	row_detect

row_detect:

row1:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b00001111
	WAIT_MS	KPD_DELAY
	in		w, PIND
	add		wr1, w
	; insert here
	rjmp	int_return

row2:
	and		w, mask
	tst		w
	breq	row2
	add		wr1, w
	

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
	.db CR,LF,">", FBIN, b
	.db 0
	rjmp	main
	
; code conversion table, character set #1 key to ASCII	
KPDConvTable:
.db '1', '2', '3', 'A'
.db '4', '5', '6', 'B'
.db '7', '8', '9', 'C'
.db '*', '0', '#', 'D'