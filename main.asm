; file main.asm	target ATmega128L-4MHz-STK300
; purpose main file - run mastermind game

.include "macros.asm"			; include macro definitions
.include "definitions.asm"		; include register/constant definitions

; ——— definitions ———
.equ	KPD_DELAY = 30			; msec, debouncing keys of keypad
.def	col = r2			; detected column in hex
.def	row = r1			; detected row in hex
.def	mask = r14			; row mask indicating which row has been detected in bin

; ––– interrupt vectors table –––
.org 0
	jmp 	reset
	jmp 	keypad_int0		; external interrupt INT0
	jmp 	keypad_int1		; external interrupt INT1
	jmp 	keypad_int2		; external interrupt INT2
	jmp 	keypad_int3		; external interrupt INT3

keypad_int0:
	_LDI	row, 0x00		; detect row 0
	_LDI	mask, 0b00000001
	out 	SREG, _sreg		; context restore
	rjmp	column_detect

keypad_int1:
	_LDI	row, 0x01		;detect row 1
	_LDI	mask, 0b00000010
	rjmp	column_detect

keypad_int2:
	_LDI	row, 0x02		;detect row 2
	_LDI	mask, 0b00000100
	rjmp	column_detect

keypad_int3:
	_LDI	row, 0x03		;detect row 1
	_LDI	mask, 0b00001000
	rjmp	column_detect

column_detect:
	OUTI	PORTD, 0xff		; bit4-7 driven high (lines)

col3:					
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b01111111	; check column 3
	WAIT_MS	KPD_DELAY
	in	w, PIND			; in PIND
	and	w, mask			; we are masking the selected row
	tst	w			; testing if column is pressed (test for 0 or minus)
	brne	col2
	_LDI	col, 0x04		; added 1 for ops with lookup table
	rjmp	isr_return

col2:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b10111111	; check column 2
	WAIT_MS	KPD_DELAY
	in	w, PIND			; in PIND
	and	w, mask		
	tst	w			; testing if column is pressed (test for 0 or minus)
	brne	col1
	_LDI	col, 0x03		; added 1 for ops with lookup table
	rjmp	isr_return

col1:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b11011111	; check column 1
	WAIT_MS	KPD_DELAY
	in	w, PIND			; in PIND
	and	w, mask		
	tst	w			; testing if column is pressed (test for 0 or minus)
	brne	col0
	_LDI	col, 0x02		; added 1 for ops with lookup table
	rjmp	isr_return

col0:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0b11101111	; check column 0
	WAIT_MS	KPD_DELAY
	in	w, PIND			; in PIND
	and	w, mask		
	tst	w			; testing if column is pressed (test for 0 or minus)
	brne	isr_return
	_LDI	col, 0x01		; added 1 for ops with lookup table
	rjmp	isr_return

isr_return:
	OUTI PORTD, 0x0f
	reti

.include "lcd.asm"
.include "printf.asm"
.include "sound.asm"
.include "eeprom.asm"

.org 0x400

reset:	
	LDSP	RAMEND			; load Stack Pointer (SP)
	rcall	LCD_init		; initialize UART
	OUTI	DDRD, 0xf0		; bit0-3 pull-up and bits4-7 driven low
	OUTI	PORTD, 0x0f		; >(needs the two lines)
	OUTI	DDRB, 0xff		; turn on LEDs
	OUTI	EIMSK, 0x0f		; enable INT0-INT3
	OUTI	EICRB, 0b0		; >at low level
	OUTI	DDRE, 0xff		; set buzzer pull-up
	CLR2	col, row
	CLR4	a0, a1, a2, a3
	CLR4	b0, b1, b2, b3
	CLR4	c0, c1, c2, c3
	CLR4	d0, d1, d2, d3
	PRINTF  LCD
	.db	CR, "Welcome to", CR, LF, "Mastermind"
	.db     0
	WAIT_MS 3000
	DISPLAY_RESET
	sei

; ––– game configuration –––
main:
	PRINTF	LCD
	.db CR, "Char to guess"
	.db 0
	DECODE	b0
	cpi	b0, 0x20		; compare b0 to space char
	breq	main
	DISPLAY_RESET
	PRINTF	LCD
	.db CR, "Char to guess", LF, FCHAR, b
	.db 0
	WAIT_MS	2000
	DISPLAY_RESET
	CLR2	row, col

; ––– make a guess –––
guess:
	PRINTF	LCD
	.db CR, "Guess the char"
	.db 0
	DECODE	a0
	cpi	a0, 0x20		; compare a0 to space char
	breq	guess
	DISPLAY_RESET
	PRINTF	LCD
	.db CR, "Guess the char", LF, FCHAR, a
	.db 0
	WAIT_MS	1000

; –– check if guess correct ––
check:
	DISPLAY_RESET
	cp	a0, b0
	breq	success

; –– wrong guess ––
fail:
	inc	c3
	_CPI	c3, 0x04
	breq	checkm8
	DISPLAY_RESULT "Wrong!"
	WAIT_MS	1000
	DISPLAY_RESET
	CLR3	a0, row, col
	rjmp	guess

; –– correct guess ––
success:
	CLR4	d0, d1, d2, d3
	rcall	eeprom_load
	inc	d0
	rcall	eeprom_store
	DISPLAY_RESULT "Correct!"
	rcall	victory
	WAIT_MS	1000
done:
	CLR4	a0, b0, row, col
	DISPLAY_RESET
	rjmp	main
checkm8:
	CLR5	d0, d1, d2, d3, c3
	rcall	eeprom_load
	dec	d0
	sbrs	d0, 7
	rcall	eeprom_store
	rcall	eeprom_load
	DISPLAY_RESULT "You lost!"
	rcall	loss
	WAIT_MS	1000
	rjmp	main
victory:
	ldi	zl, low(2*win)
	ldi	zh, high(2*win)
	rjmp 	play
loss:
	ldi	zl, low(2*death)
	ldi	zh, high(2*death)
play:
	lpm
	adiw	zl, 1
	_CPI	r0, 0xff
	breq	end
	mov	c0, r0
	_LDI	d0, 45
	rcall	sound
	rjmp	play
end:
	rcall	sound_off
	ret	

; ——— keypad lookup table ———
lookup0:
.db " 123A456B789C*0#D"

; ––– mario winner sound table –––
win:
.db	so, do2, mi2, so2, do3, mi3, so3, so3, so3, mi3, mi3, 0
.db	som, do2, rem2, som2, do3, fam3, som3, som3, som3, rem2, rem2, 0
.db	lam, re2, fa2, lam2, re3, fa3, lam3, lam3, lam3, lam3, 0, lam3, 0, lam3, do4, do4, do4, do4, do4, do4, do4, do4, 0xff

; ––– mario loser sound table –––
death:
.db	so2, re3, 0, 0, re3, 0, re3, 0, do3, 0, si2, 0, so2, so2, 0, 0, mi2, do2, do2, 0xff 
