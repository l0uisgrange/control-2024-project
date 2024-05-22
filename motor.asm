; file	motor.asm   target ATmega128L-4MHz-STK300
; purpose stepper motor control
; module: M1, output port: PORTC
.macro	MOTOR
	ldi	w,@0
	out	PORTC, w			; output motor pin pattern
.endmacro		