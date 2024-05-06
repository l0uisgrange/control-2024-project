; file  keypad.asm target ATmega128L
; purpose main file

	; === definitions ===
.equ	KPDD = DDRD
.equ	KPDO = PORTD
.equ	KPDI = PIND

.equ	KPD_DELAY = 30	; msec, debouncing keys of keypad

.def	wr0 = r2		; detected row in hex
.def	wr1 = r1		; detected column in hex
.def	mask = r14		; row mask indicating which row has been detected in bin
.def	wr2 = r15		; semaphore: must enter LCD display routine, unary: 0 or other


	; === interrupt service routines ===
isr_ext_int0:
	INVP	PORTB,0			;;debug
	_LDI	wr1, 0x00		; detect row 1
	_LDI	mask, 0b00000001
	reti
	; no reti (grouped in isr_return)
