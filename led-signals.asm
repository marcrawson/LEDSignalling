; a2-signalling.asm

.include "m2560def.inc"
.cseg
.org 0

; ---------------------------------------------------
; ---- TESTING SECTIONN OF THE CODE -----------------
;----------------------------------------------------

;rjmp test_part_a
; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end

; ---------------------------------------------------
; -------- CODE SECTION BEGINS HERE -----------------
;----------------------------------------------------

set_leds:

	clr r18 ; bit set tracker

	;LED01 (left)
	ldi r17, 0b00000010 ; load corresponding value to register
	sbrc r16, 5 ; check if 5th bit value equals 1
		add r18, r17 ; add corresponding value to portB output

	;LED02
	ldi r17, 0b00001000 ; load corresponding value to register
	sbrc r16, 4 ; check if 4th bit value equals 1
		add r18, r17 ; add corresponding value to portB output

	out portB, r18 ; pipe final value to portB
	clr r18 ; clear register

	;LED03
	ldi r17, 0b00000010 ; load corresponding value to register
	sbrc r16, 3 ; check if 3rd bit value equals 1
		add r18, r17 ; add corresponding value to portL output

	;LED04
	ldi r17, 0b00001000 ; load corresponding value to register
	sbrc r16, 2 ; check if 2nd bit value equals 1
		add r18, r17 ; add corresponding value to portL output

	;LED05
	ldi r17, 0b00100000 ; load corresponding value to register
	sbrc r16, 1 ; check if 1st bit value equals 1
		add r18, r17 ; add corresponding value to portL output

	;LED06 (right)
	ldi r17, 0b10000000 ; load corresponding value to register
	sbrc r16, 0 ; check if 0th bit value equals 1
		add r18, r17 ; add corresponding value to portL output

	sts portL, r18 ; pipe final value to portL
	clr r18 ; clear register

	ret


slow_leds:
	clr r16 ; clear register
	mov r16, r17 ; move r17 to r16
	rcall set_leds ; call set_leds
	rcall delay_long ; ~1 sec delay

	clr r16 ; clear register
	rcall set_leds ; call set_leds
	ret


fast_leds:
	clr r16 ; clear register
	mov r16, r17 ; move r17 to r16
	rcall set_leds ; call set_leds
	rcall delay_short ; ~0.25 sec delay

	clr r16 ; clear register
	rcall set_leds ; call set_leds
	ret


leds_with_speed:
	clr r17 ; clear register
	pop r22 ; get input byte pushed onto stack
	pop r21
	pop r20
	pop r17

	push r17 ; rebuild stack
	push r20
	push r21
	push r22 

	sbrc r17, 7 ; test if 7th digit is 1
		rcall slow_leds ; if yes, then call slow_leds
	sbrs r17, 7 ; test if 7th digit is not 1
		rcall fast_leds ; if yes, then call fast_leds
	clr r17 ; clear register

	ret


encode_letter:
	pop r3 ; get input value pushed to stack
	pop r4
	pop r5
	pop r18

	push r18 ; rebuild stack
	push r5
	push r4
	push r3

	ldi r17, 0b11000000 ; long_duration constant
	ldi r26, 0b00000000 ; count variable

	ldi ZH, high(PATTERNS << 1) ; point to patterns table
	ldi ZL, low(PATTERNS << 1)
	clr r25 ; clear register

	lpm r16, Z ; let r16 to point to Z

	find_letter:
		cp r18, r16 ; check if equal
			breq loop ; if equal, then move to looping light/duration pattern
		adiw Z, 8 ; Z points to 8 bits down
		lpm r16, Z ; let r16 to point to Z
		rjmp find_letter ; re-loop
		
	loop:
		inc r26 ; register ++
		adiw Z, 1 ; Z points to 1 bit down
		lpm r16, Z ; let r16 to point to Z
		lsl r25 ; shift all values of bits left
		sbrc r16, 0 ; find led pattern
			inc r25
		cpi r26, 6 ; loop 6 times (for each led light)
			brne loop

	get_duration:
		adiw Z, 1 ; Z points to 1 bit down
		lpm r16, Z ; let r16 to point to Z
		cpi r16, 0b00000001 ; find if duration is needed
			breq add_duration ; call add_duration
		rjmp done

	add_duration:
		add r25, r17 ; add duration encoding

	done: 
		ret


display_message:
	push ZH ; push pointers to stack
	push ZL

	mov ZH, r25 ; let r25 equal ZH
	mov ZL, r24 ; let r24 equal ZL

	clr r18 ; clear register

	traverse_word:
		lpm r18, Z+ ; let r18 point to 1 bit ahead of Z
		cpi r18, 0 ; if r18 equals 0 then:
			breq done_traverse ; end traversal

		push r18
		rcall encode_letter ; call encode_letter
		pop r18

		push r25
		rcall leds_with_speed ; call leds_with_speed
		rcall delay_short ; delay to meet video
		rcall delay_short
		pop r25

		rjmp traverse_word

	done_traverse:
		pop ZL ; rebuild stack
		pop ZH

		ret


; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret

delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
.cseg

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "W", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0
