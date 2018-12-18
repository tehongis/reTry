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
	sta	$dc0d
	lda #$35
	sta $01
	lda #<mainirq
	sta $fffe
	lda #>mainirq
	sta $ffff
	lda #$03
	sta $dd00
	lda #$1b
	sta $d011
	lda #$00
	sta $d012
	lda #$01
	sta $d01a
	cli
	
	lda #$00
	jsr	song
	
	jsr gfxinit

	lda #$00
	sta $ff
.loop
	jmp .loop

mainirq
	pha
	txa
	pha
	tya
	pha
	
	inc $d020
	
	jsr song+3
	
	ldx	#$00
.loop
	lda	fontdata+$28*0,x
	sta	$0400+$28*0,x
	lda	fontdata+$28*1,x
	sta	$0400+$28*1,x
	lda	fontdata+$28*2,x
	sta	$0400+$28*2,x
	lda	fontdata+$28*3,x
	sta	$0400+$28*3,x
	inx
	cpx	#$28
	bne	.loop
	
	dec $d020
	
	lda $d019
	sta $d019

	pla
	tay
	pla
	tax
	pla

	rti

gfxinit
	lda #$00
	sta $d020
	lda #$00
	sta $d021
	lda #$0e
	sta $d022
	lda #$01
	sta $d023

	lda #$d8
	sta $d016	;multicolor on

	lda #$1c
	sta $d018	; font location

	ldx	#$00
	lda	#$0e
.colorloop
	sta	$d800,x
	sta	$d900,x
	sta	$da00,x
	sta	$db00,x
	inx
	bne	.colorloop	
	
	rts

	org $1000
song
	incbin	"Data\song.dat"

	org $3000
font
	incbin	"Data\font_gfx2.dat"

	org $4000
fontdata
	incbin	"Data\font_data.dat"
	
	
	
