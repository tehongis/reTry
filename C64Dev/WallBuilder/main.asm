; reTry demo 2017
;
; MIT License
;
; Copyright (c) 2017 Tero Hongisto
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.


screen1 = $4000

	org $0801
basic
	db 	$0d, $08, $e0, $07, $9e, $28, $32, $30, $36, $34, $29, $00 ;2016 SYS (2064)

	org $0810
init
	sei
	lda #$7f
	sta $dc0d
	lda #$35
	sta $01
	lda #<mainirq
	sta $fffe
	lda #>mainirq
	sta $ffff
	lda #$1b
	sta $d011
	lda #$00
	sta $d012
	lda #$01
	sta $d01a
	cli

	lda #$00
	jsr song

	jsr gfxinit

.loop
	jmp .loop

gfxinit
		lda #$00
		sta $d020
		lda #$0b
		sta $d021
		lda #$0c
		sta $d022
		lda #$09
		sta $d023
		lda #$07
		sta $d024

		lda #$02
		sta $dd00	;Bank change

		lda #$de	; font at BankBase + $3800, screen at $3400-$37ff
		sta $d018

		lda #$d8
		sta $d016	;Char multicolor on

		ldx	#$00
.maploop
		lda	mapchars,x
		sta	$7400,x
		lda	mapchars+$100,x
		sta	$7500,x
		lda	mapchars+$200,x
		sta	$7600,x
		lda	mapchars+$300,x
		sta	$7700,x
		inx
		bne	.maploop

		ldx	#$00
.colorloop
		lda	mapcolors,x
		sta	$d800,x
		lda	mapcolors+$100,x
		sta	$d900,x
		lda	mapcolors+$200,x
		sta	$da00,x
		lda	mapcolors+$300,x
		sta	$db00,x
		inx
		bne	.colorloop

		lda #$ff
		sta $d015	;sprites enabled

		lda #$00
		sta	$d01b		;Sprite priority
		lda #$ff		;all sprites multicolor
		sta $d01c

		lda #$08
		sta	$D025		;Spr multicolor 1
		lda #$00
		sta	$D026		;Spr multicolor 2
		lda #$07
		sta	$D027		;Spr color 1
		lda #$0a
		sta	$D028		;Spr color 1

		lda #$00
		sta $d017		;sprites x double
		lda #$00
		sta $d01d		;sprites y double

		rts

mainirq
	pha
	txa
	pha
	tya
	pha

	dec $d020

	jsr song+3

	inc $d020


	lda	charx
	sta	$d000
	sta $d002

	lda	chary
	sta	$d001
	clc
	adc #21
	sta $d003

	lda	animbase
	clc
	adc	animcount
	sta	$77f8	;spr0ptr
	clc
	adc	#$08
	sta	$77f9	;spr1ptr



	lda $dc00
	sta joystick

	jsr checkmoves


	inc $7700

	lda $d019
	sta $d019

	pla
	tay
	pla
	tax
	pla

	rti

checkmoves

		lda	joystick
		and #$01
		bne .notup
		jsr	joyup
.notup

		lda	joystick
		and #$02
		bne .notdown
		jsr joydown
.notdown

		lda	joystick
		and #$04
		bne .notleft
		jsr joyleft
.notleft

		lda	joystick
		and #$08
		bne .notright
		jsr joyright
.notright

		lda	joystick
		and #$10
		bne .nobutton
		jsr joybutton
.nobutton
	  rts

joyup
		dec	chary
		rts

joydown
		inc	chary
   	rts

joyleft
	lda	animdelay
	clc
	adc #$01
	and	#$01
	sta	animdelay
	cmp	#$00
	bne	.ohi


		lda	#$00
		sta	animbase
		lda	animcount
		clc
		adc #$01
		and #$03
		sta	animcount

		dec	charx
		dec	charx

.ohi
		rts

joyright

		lda	animdelay
		clc
		adc #$01
		and	#$01
		sta	animdelay
		cmp	#$00
		bne	.ohi

		lda	#$04
		sta	animbase
		lda	animcount
		clc
		adc #$01
		and #$03
		sta	animcount

		inc	charx
		inc	charx
.ohi
   	rts

joybutton
		inc	 $d021
		rts


charx
		byte	$80
chary
		byte	$80
joystick
		byte	$00

lastdirection
		byte	$00
animdelay
		byte	$00
animbase
		byte  $00
animcount
		byte	$00
button
		byte	$00

	org $1000
song
	incbin	"song.dat"

	org $4000
sprites
	incbin "sprites.dat"

	org $7800
font
	incbin "font.dat"

	org $8000
mapchars
	incbin "mapchars.dat"
mapcolors
	incbin "mapcolors.dat"
