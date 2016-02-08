.include "tn25def.inc"
.cseg
.org 0
rjmp setup

; Looping Louie Strike Counter Firmware
; Count down remaining lives
;
; LEDs on PB(1234)
; Hall switch and reset trigger on PB0
; Long press to reset

.equ LIVES = 4

setup:
	; Set up the stack pointer
	ldi r16, low(RAMEND)
	; Set up I/O
	out SPL, r16
	ldi r16, 0b00111110
	out DDRB, r16
	; Output initial LED status
	ldi r16, LIVES
	rcall ledout

main:
	; Core loop
	sbis PINB, 0
	rcall debounce
	rjmp main

debounce:
	ldi r18, 0x08
	rcall pwait
	sbis PINB, 0
	rcall count
	ldi r20, 0
	ldi r21, 0
wrelse:	inc r20
	brvs inc16b
	rjmp chkrel
inc16b: inc r21
	brvs rstcnt
	rjmp chkrel	
rstcnt:	ldi r16, LIVES
	rcall ledout
chkrel:	sbis PINB, 0
	rjmp wrelse
	ldi r18, 0xFF
	rcall pwait
	ldi r18, 0xFF
	rcall pwait
	ret
	
ledout:
	; Output strikes left as LED indicator
	mov r17, r16
	ldi r18, 0
lloop:	cpi r17, 0
	breq lend
	ori r18, 1
	rol r18
	dec r17
	rjmp lloop
lend:	ori r18, 1
	out PORTB, r18
	ret

count:
	; Decrement strike counter
	cpi r16, 0
	breq cont
	dec r16
	rjmp cont
cont:	rcall ledout
	ret

pwait:	ldi r19, 0xFF
pw_ilo:	dec r19
        brne pw_ilo
        dec r18
        brne pwait
        ret

.db "Hardware: Indidev; Code: cbdev; 2015-12-05"
