; file sound.asm target ATmega128L-4MHz-STK300
; purpose library, sound generation

; ——— play sound ———
sound:
	; in	a0	period of oscillation (in 10us)
	; 	b0	duration of sound (in 2.5ms)
	mov	d1,d0		; duration high byte = b
	clr	d0		; duration  low byte = 0
	clr	c1		; period high byte = a
	tst	c0
	breq	sound_off	; if a0=0 then no sound	
sound1:
	mov	w,c0		
	rcall	wait9us		; 9us
	nop			; 0.25us
	dec	w		; 0.25us
	brne	PC-3		; 0.50us	total = 10us
	INVP	PORTE,SPEAKER	; invert piezo output
	sub	d0,c0		; decrement duration low  byte
	sbc	d1,c1		; decrement duration high byte
	brcc	sound1		; continue if duration>0
	ret

; ——— stop sound ———
sound_off:
	_LDI	c0,1
	rcall	wait9us
	sub	d0,c0		; decrement duration low  byte
	sbc	d1,c1		; decrement duration high byte
	brcc	PC-3		; continue if duration>0
	ret

; ——— wait routines ———
wait9us:rjmp	PC+1		; waiting 2 cycles
	rjmp	PC+1		; waiting 2 cylces
wait8us:rcall	wait4us		; recursive call with "falling through"
wait4us:rcall	wait2us	
wait2us:nop
	ret			; rcall(4), nop(1), ret(3) = 8cycl. (=2us)

; ——— calculation of the musical scale ———
; period (10us)	= 100'000/freq(Hz)
.equ	do	= 100000/517	; (517 Hz)
.equ	dom	= do*944/1000	; do major
.equ	re	= do*891/1000
.equ	rem	= do*841/1000	; re major
.equ	mi	= do*794/1000
.equ	fa	= do*749/1000
.equ	fam	= do*707/1000	; fa major
.equ	so	= do*667/1000
.equ	som	= do*630/1000	; so major
.equ	la	= do*595/1000
.equ	lam	= do*561/1000	; la major
.equ	si	= do*530/1000

.equ	do2	= do/2
.equ	dom2	= dom/2
.equ	re2	= re/2
.equ	rem2	= rem/2
.equ	mi2	= mi/2
.equ	fa2	= fa/2
.equ	fam2	= fam/2
.equ	so2	= so/2
.equ	som2	= som/2
.equ	la2	= la/2
.equ	lam2	= lam/2
.equ	si2	= si/2

.equ	do3	= do/4
.equ	dom3	= dom/4
.equ	re3	= re/4
.equ	rem3	= rem/4
.equ	mi3	= mi/4
.equ	fa3	= fa/4
.equ	fam3	= fam/4
.equ	so3	= so/4
.equ	som3	= som/4
.equ	la3	= la/4
.equ	lam3	= lam/4
.equ	si3	= si/4	

.equ	do4 	= do/8
