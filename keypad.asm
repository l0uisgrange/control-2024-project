.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

	; === definitions ===
.equ	KPDD = DDRD
.equ	KPDO = PORTD
.equ	KPDI = PIND

.equ	KPD_DELAY = 30	; msec, debouncing keys of keypad

.def	col = r2		; detected column in hex
.def	row = r1		; detected row in hex
.def	mask = r14		; row mask indicating which row has been detected in bin
.def	sem = r15		; semaphore: must enter LCD display routine, unary: 0 or other

.org 0
	jmp reset
	jmp	isr_ext_int0	; external interrupt INT0
	jmp	isr_ext_int1	; external interrupt INT1
	jmp isr_ext_int2	; external interrupt INT2
	jmp isr_ext_int3	; external interrupt INT3

isr_ext_int0:
	;in _sreg, SREG			;sauvegarde du contexte

	INVP PORTB,0			;debug
	_LDI	row, 0x00		; detect row 0
	_LDI	mask, 0b00000001

	out SREG, _sreg			;restauration du contexte

	rjmp	column_detect

isr_ext_int1:
	INVP PORTB,1			;debug
	_LDI	row, 0x01		; detect row 1
	_LDI	mask, 0b00000010

	rjmp	column_detect

isr_ext_int2:
	INVP PORTB,2			;debug
	_LDI	row, 0x02		; detect row 2
	_LDI	mask, 0b00000100

	rjmp	column_detect

isr_ext_int3:
	INVP PORTB,3			;debug
	_LDI	row, 0x03		; detect row 1
	_LDI	mask, 0b00001000

	rjmp	column_detect

column_detect:
	OUTI	PORTD,0xff	; bit4-7 driven high (lines)

col3:					
	WAIT_MS	KPD_DELAY
	OUTI	PORTD,0b01111111	; check column 3
	WAIT_MS	KPD_DELAY
	in		w,PIND		; in PIND
	and		w,mask		; we are masking the selected row
	tst		w			; testing if column is pressed (test for 0 or minus)
	brne	col2
	_LDI	col,0x03
	INVP	PORTB,7		; LED inverts if key pressed!
	rjmp	isr_return

col2:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD,0b10111111	; check column 2
	WAIT_MS	KPD_DELAY
	in		w,PIND		; in PIND
	and		w,mask		
	tst		w			; testing if column is pressed (test for 0 or minus)
	brne	col1
	_LDI	col,0x02
	INVP	PORTB,6		; LED inverts if key pressed!
	rjmp	isr_return

col1:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD,0b11011111	; check column 1
	WAIT_MS	KPD_DELAY
	in		w,PIND		; in PIND
	and		w,mask		
	tst		w			; testing if column is pressed (test for 0 or minus)
	brne	col0
	_LDI	col,0x01
	INVP	PORTB,5		; LED inverts if key pressed!
	rjmp	isr_return

col0:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD,0b11101111	; check column 0
	WAIT_MS	KPD_DELAY
	in		w,PIND		; in PIND
	and		w,mask		
	tst		w			; testing if column is pressed (test for 0 or minus)
	brne	isr_return
	_LDI	col,0x00
	INVP	PORTB,4		; LED inverts if key pressed!
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

	OUTI	DDRD,0xf0		; bit0-3 pull-up and bits4-7 driven low
	OUTI	PORTD,0x0f		;>(needs the two lines)
	OUTI	DDRB,0xff		; turn on LEDs
	OUTI	EIMSK,0x0f		; enable INT0-INT3
	OUTI	EICRB,0b0		;>at low level
	sbi		DDRE,SPEAKER	; enable sound

	clr		col
	clr		row
	clr		sem

	clr		a1				
	clr		a2
	clr		a3
	clr		b1
	clr		b2
	clr		b3

	sei

	jmp main

main:
	clr a0
	add a0, row
	;add a0, col
	clr b0
	add b0, col

	ldi zl, low(2*krow0)	; load table of row 0
	ldi zh, low(2*krow0) 
	add zl, a0
	adc zh, a1
	lpm
	;mov b0, r0
	

PRINTF LCD
.db CR,LF, "KPD=", FHEX, a, " ascii=", FHEX, b
.db 0
	rjmp main


; code conversion table, character set #1 key to ASCII	
krow0:
.db 0x41,0x42,0x43,0x44		;col 0: A,B,C,D
.db 0x33,0x36,0x39,0x23		;col 1: 3,6,9,#
.db 0x32,0x35,0x38,0x30		;col 2: 2,5,8,0
.db 0x31,0x34,0x37,0x2a		;col 3: 1,4,7,*