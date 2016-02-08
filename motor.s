.include "m8def.inc"
.cseg
.org 0
rjmp setup

; Looping Louie Motor Controller Firmware
; Random & fixed speed control
; 
; Motor speed control via PC(0123) 
; Random speed on/off PC5
; Start trigger on PB0
; Motor PWM on PB1

setup:
	; Set up stack pointer
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	; Read seed from EEPROM
	ldi r16, 0
	out EEARL, r16
	out EEARH, r16
	sbi EECR, EERE
	in r1, EEDR
	inc r1
eepwr:	sbic EECR, 1
	rjmp eepwr
	out EEDR, r1
	in r16, SREG
	cli
	sbi EECR, EEMWE
	sbi EECR, EEWE
	out SREG, r16

	; PORTD is (currently) a debug output
	ldi r16, 0xFF
	out DDRD, r16
	out PORTD, r1
	
	;PWM Port
	ldi r16, 0b00000010
	out DDRB, r16 

	ldi r16, 0b00000001
	out PORTB, r16

	; DIP Port
	ldi r16, 0
	out DDRC, r16
	ldi r16, 0b00111111
	out PORTC, r16

	; Timer2 (Randomness / LEDs)
	ldi r16, 1<<CS22 | 1<<CS21 | 1<<CS20
	out TCCR2, r16

	; PWM Timer
	ldi r16, 1<<COM1A1 | 1<<WGM11
	out TCCR1A, r16
	ldi r16, 1<<WGM12 | 1<<WGM13 | 1<<CS11 | 1<<CS10
	out TCCR1B, r16

	; Set TOP
	ldi r16, 0
	out ICR1H, r16
	ldi r16, 0xFF
	out ICR1L, r16

	; Set Compare
	ldi r16, 0
	out OCR1AH, r16
	ldi r16, 0x10
	out OCR1AL, r16

startwait:
	; Stop motor PWM output
	ldi r16, 1<<WGM11
	out TCCR1A, r16

	; Set up registers
	ldi r16, 0
	mov r2, r16

	; Wait for start button
	sbic PINB, 0
	rjmp startwait
	rcall delay
release:sbis PINB, 0
	rjmp release
	rcall delay

	; Start PWM output
	ldi r16, 1<<COM1A1 | 1<<WGM11
	out TCCR1A, r16

main:
	; Core pin read loop
	sbic PINC, 5
	rcall readspeed
	sbis PINC, 4
	rcall ledspeed
	sbis PINC, 5
	rcall speedrand
	sbis PINC, 4
	rcall ledrand
	sbis PINB, 0
	rjmp debounce_stop
	rjmp main

debounce_stop:
	rcall delay
	sbic PINB, 0
	rjmp main
rel:	sbis PINB, 0
	rjmp rel
	rcall delay
	rjmp startwait

ledspeed:
	; TODO Implement fixed LED speed
	ret

speedrand:
	; Decrement random speed timeout
	in r16, PINC
	andi r16, 0x0F
	tst r2
	; If timeout elapsed, generate new random speed
	breq newspd
	dec r2
	; Push the current timeout to debug
	out PORTD, r2
	rcall delay
	ret
newspd:
	; Generate random new speed and timeout
	; r17 - Time
	; r16 - Speed
	rcall genrnd
	mov r17, r16
	andi r17, 0X0F
	ori r17, 0x10
	ori r16, 0x1F
	out OCR1AL, r16
	mov r2, r17
	rcall delay
	ret

ledrand:
	; TODO Implement random LED speed
	ret

genrnd:
	; Return a random number in r16
	in r16, TCNT2
	eor r16, r1
	ret

readspeed:
	ldi r16, 0
	in r17, PINC
	andi r17, 0x0F
	lsl r17
	lsl r17
	lsl r17
	lsl r17
	ori r17, 0x0F
	out OCR1AH, r16
	out OCR1AL, r17
	rcall genrnd
	out PORTD, r16
	ret

delay:
	ldi r16, 0xFF
delay_outer:
	ldi r17, 0xFF
delay_inner:
	dec r17
	brne delay_inner
	dec r16
	brne delay_outer
	ret


.db "Hardware: Indidev; Code: cbdev; 2015-12-05"
