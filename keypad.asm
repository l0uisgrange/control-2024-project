; file keypad.asm

.include "macros.asm"
.include "definitions.asm"

; ——————————————— definitions ————————————————
.equ	KPD_DELAY = 30      ; keypad bouncing delay
.def	wr0 = r2		    ; detected row in hex
.def	wr1 = r1		    ; detected column in hex
.def	mask = r14		    ; row mask indicating which row has been detected in bin
.def	wr2 = r15		    ; semaphore: must enter LCD display routine, unary: 0 or other

; —————————— interrupt vector table ——————————
.org 0
	jmp reset
	jmp	int0	            ; external interrupt INT0
	jmp	int1	            ; external interrupt INT1

; TODO TO BE COMPLETED AT THIS LOCATION

; ————————— interrupt service routines ————————
int0:
	_LDI	wr1, 0x00		; detect row 1
	_LDI	mask, 0b00000001
	rjmp	column_detect
	; no reti (grouped in isr_return)

int1:
    _LDI    wr0, 0x00
    _LDI    mask, 0b00000001
    rjmp    row_detect
    ; no reti (grouped in isr_return)
    
; TODO TO BE COMPLETED AT THIS LOCATION

column_detect:
	OUTI	PORTD, 0xff	    ; bit4-7 driven high

row_detect:
    OUTI    PORTD, 0x00      ; bit4-7 driven low

col7:
	WAIT_MS	KPD_DELAY
	OUTI	PORTD, 0x7f	    ; check column 7
	WAIT_MS	KPD_DELAY
	in		w, PIND
	and		w, mask
	tst		w
	brne	col6
	_LDI	wr0, 0x00
	rjmp	int_return

col6:
; TODO TO BE COMPLETED AT THIS LOCATION
	
err_row0:			        ; debug purpose and filter residual glitches
	rjmp	int_return
	; no reti (grouped in isr_return)

int_return:
	INVP	PORTB,0		    ; visual feedback of key pressed acknowledge
	ldi		_w,10		    ; sound feedback of key pressed acknowledge

beep01:
	; TODO TO BE COMPLETED AT THIS LOCATION
	_LDI	wr2,0xff
	reti
	
.include "lcd.asm"			; include UART routines
.include "printf.asm"		; include formatted printing routines

; —————— initialization and configuration ——————

.org 0x400

reset:	LDSP	RAMEND		; Load Stack Pointer (SP)
	rcall	LCD_init		; initialize UART
	OUTI	DDRD, 0xf0		; bit0-3 pull-up and bits4-7 driven low
	OUTI	PORTD, 0x0f		; output
	OUTI	DDRB, 0xff		; turn on LEDs
	OUTI	EIMSK, 0x0f		; enable INT0-INT3
	OUTI	EICRB, 0b0		;>at low level
	sbi		DDRE, SPEAKER	; enable sound
    PRINTF  LCD .db	CR,CR,"Welcome to Mastermind"
    WAIT_MS 3000
    PRINTF  LCD .db	CR,CR,"Number to guess:"
	clr		wr0
	clr		wr1
	clr		wr2
	clr		a1				
	clr		a2
	clr		a3
	clr		b1
	clr		b2
	clr		b3
	sei
    ;jmp	main			; not useful in this case, kept for modularity

; —————————————— main program ——————————————
main:
	tst		wr2				; check flag/semaphore
	breq	main
	clr		wr2
	clr		a0
	add		a0, wr1
	add		a0, wr0

	; TODO COMPLETE HERE

    PRINTF  LCD .db CR,LF,"KPD=",FHEX,a," ascii=",FHEX,b .db 0
	rjmp	main
	
; code conversion table, character set #1 key to ASCII	
KPDConvTable:
.db '1', '2', '3', 'A'
.db '4', '5', '6', 'B'
.db '7', '8', '9', 'C'
.db '*', '0', '#', 'D'