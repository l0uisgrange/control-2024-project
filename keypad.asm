.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; ——— definitions ———
.equ	KPD_DELAY = 30	; msec, debouncing keys of keypad
.def	col = r2		; detected column in hex
.def	row = r1		; detected row in hex
.def	mask = r14		; row mask indicating which row has been detected in bin
.def	sem = r15		; semaphore: must enter LCD display routine, unary: 0 or other

.org 0
	jmp 	reset
	jmp 	isr_ext_int0		; external interrupt INT0
	jmp 	isr_ext_int1		; external interrupt INT1
	jmp 	isr_ext_int2		; external interrupt INT2
	jmp 	isr_ext_int3		; external interrupt INT3

isr_ext_int0:
	INVP 	PORTB, 0		;debug
	_LDI	row, 0x00		;detect row 0
	_LDI	mask, 0b00000001
	out 	SREG, _sreg		;restauration du contexte
	rjmp	column_detect

isr_ext_int1:
	INVP	PORTB, 1		;debug
	_LDI	row, 0x01		;detect row 1
	_LDI	mask, 0b00000010
	rjmp	column_detect

isr_ext_int2:
	INVP	PORTB, 2		;debug
	_LDI	row, 0x02		;detect row 2
	_LDI	mask, 0b00000100
	rjmp	column_detect

isr_ext_int3:
	INVP	PORTB, 3		;debug
	_LDI	row, 0x03		;detect row 1
	_LDI	mask, 0b00001000
	rjmp	column_detect

column_detect:
	OUTI	PORTD, 0xff		;bit4-7 driven high (lines)

col3:					
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b01111111	; check column 3
	WAIT_MS	KPD_DELAY
	in	w, PIND		; in PIND
	and	w, mask		; we are masking the selected row
	tst	w			; testing if column is pressed (test for 0 or minus)
	brne	col2
	_LDI	col, 0x03
	INVP	PORTB, 7		; LED inverts if key pressed!
	rjmp	isr_return

col2:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b10111111	; check column 2
	WAIT_MS	KPD_DELAY
	in	w, PIND		; in PIND
	and	w, mask		
	tst	w			; testing if column is pressed (test for 0 or minus)
	brne	col1
	_LDI	col, 0x02
	INVP	PORTB, 6		; LED inverts if key pressed!
	rjmp	isr_return

col1:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b11011111	; check column 1
	WAIT_MS	KPD_DELAY
	in	w, PIND		; in PIND
	and	w, mask		
	tst	w			; testing if column is pressed (test for 0 or minus)
	brne	col0
	_LDI	col, 0x01
	INVP	PORTB, 5		; LED inverts if key pressed!
	rjmp	isr_return

col0:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b11101111	; check column 0
	WAIT_MS	KPD_DELAY
	in	w, PIND		; in PIND
	and	w, mask		
	tst	w			; testing if column is pressed (test for 0 or minus)
	brne	isr_return
	_LDI	col, 0x00
	INVP	PORTB, 4		; LED inverts if key pressed!
	rjmp	isr_return

isr_return:
	OUTI PORTD, 0x0f
	reti

.include "lcd.asm"			; include UART routines
.include "printf.asm"

.org 0x400

reset:	
	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	LCD_init		; initialize UART
	OUTI	DDRD, 0xf0		; bit0-3 pull-up and bits4-7 driven low
	OUTI	PORTD, 0x0f		;>(needs the two lines)
	OUTI	DDRB, 0xff		; turn on LEDs
	OUTI	EIMSK, 0x0f		; enable INT0-INT3
	OUTI	EICRB, 0b0		;>at low level
	clr	col
	clr	row
	clr	sem
	clr	a1				
	clr	a2
	clr	a3
	clr	b1
	clr	b2
	clr	b3
	PRINTF  LCD
	.db	CR, "Welcome to", CR, LF, "Mastermind"
	.db     0
	WAIT_MS 3000
	rcall   LCD_clear
	rcall	LCD_home
	sei
	jmp main

main:
	rcall	decode

	PRINTF	LCD
	.db CR, "number to guess: ", FCHAR, b
	.db 0

	rjmp	main

decode:
	ldi	zl, low(2*lookup0)	; load table of row 0
	ldi	zh, high(2*lookup0)
	add	zl, col
	mov	w, row
	MUL4	w
	add	zl, w
	lpm
	clr	b0
	mov	b0, r0
	ret


; ——— lookup table ———
lookup0:
.db " 123A456B789C*0#D"
