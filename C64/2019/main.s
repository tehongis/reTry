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
	lda #$32
	sta $d012
	lda #$01
	sta $d01a
	cli

	jsr resettext

	lda #$00
	sta $fe

	lda #$00
	sta $ff

	lda #$00
	jsr	song

	jsr gfxinit

.loop
	jmp .loop

;---------------- GFX init

gfxinit
	lda #$00
	sta $d020
	lda #$01
	sta $d021
	lda #$0e
	sta $d022
	lda #$01
	sta $d023

	lda #$c8
	sta $d016	;multicolor off

	lda #$15
	sta $d018	; font location

	ldx	#$00
	lda	#$00
.colorloop
	sta	$d800,x
	sta	$d900,x
	sta	$da00,x
	sta	$db00,x
	inx
	bne	.colorloop

	ldx	#$00
	lda	#$00
.charloop
	lda screen,x
	sta	$0400,x
	lda screen+$100,x
	sta	$0500,x
	lda screen+$200,x
	sta	$0600,x
	lda screen+$300,x
	sta	$0700,x
	inx
	bne	.charloop

	rts

;----------------- IRQ

mainirq
	pha
	txa
	pha
	tya
	pha

	lda #$c8
	sta $d016	;multicolor off

	jsr	rasters

	lda	$fe
	and #$07
	ora	#$C0
	sta	$d016

	jsr rastermove

	ldx	#$00
.charcolloop
	lda	colors,x
	sta $d990,x
	sta $d9b8,x
	inx
	cpx	#$28
	bne .charcolloop

	ldx	#$3b
.delayloop
	cmp	$ea
	dex
	bne	.delayloop

	lda	$fe
	and #$07
	cmp #$00
	bne	.nolinescroll
	jsr scrolline
.nolinescroll
	dec $fe

	lda	#$00
	sta	$d021


	dec $d020
	jsr song+3
	inc $d020

	lda $d019
	sta $d019

	pla
	tay
	pla
	tax
	pla

	rti

; ---- Rasters
rasters
	lda	#$00
	sta	$d021
	sta	$d021
	nop
	nop
	nop

	ldx	#$00
.rastloop
	lda	colors,x
	sta	$d021
	sta	$d021
	txa
	and #$07
	beq	.skip
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9
	cmp #$c9

.skip
	inx
	cpx #$48
	bne .rastloop
	nop

	lda	#$00
	sta	$d020
	sta	$d021

	rts

rastermove
	ldx	#$46
.rollloop
	lda	colors,x
	sta colors+1,x
	dex
	bne	.rollloop

	ldx	$ff
	lda	rastercolors,x
	sta	colors+2
	inc $ff

	rts

scrolline
	ldx #$00
.lineloop
	lda $0591,x
	sta $0590,x
	lda $05b9,x
	sta $05b8,x

	inx
	cpx	#$28
	bne	.lineloop


	ldy #$00
	lda ($fc),y
	beq	.end
	sta $05b7
	clc
	ora #$80
	sta $05df
	jmp .advance
.end
	jsr resettext
	lda #$20
	sta $0607

.advance
	clc
	lda	$fc
	adc #$01
	sta $fc
	lda $fd
	adc #$00
	sta $fd
	rts

resettext
	lda #<scrolltext
	sta $fc
	lda #>scrolltext
	sta $fd
	rts

	org $0e00
scrolltext
	db "toimiiko nyt vai onko kaikki EDELLEENKIN PASKAA... "

colors
	blk	$100,$00

	org $1000
song
	incbin	"Data\song.dat"

	org	$3000
rastercolors
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00

	db	$00,$00,$06,$06,$00,$00,$00,$00
	db	$00,$06,$0e,$0e,$06,$00,$00,$00

	db	$06,$0e,$03,$03,$0e,$06,$00,$00

	db	$06,$00,$06,$06,$0e,$06,$0e,$0e
	db	$06,$0e,$06,$06,$00,$06,$00,$00

	db	$06,$00,$06,$06,$0e,$06,$0e,$0e
	db	$03,$0e,$03,$03,$0e,$03,$0e,$0e
	db	$06,$0e,$06,$06,$00,$06,$00,$00

	db	$06,$00,$06,$06,$0e,$06,$0e,$0e
	db	$03,$0e,$03,$03,$01,$03,$01,$01
	db	$03,$01,$03,$03,$0e,$03,$0e,$0e
	db	$06,$0e,$06,$06,$00,$06,$00,$00

	db	$06,$00,$06,$06,$0e,$06,$0e,$0e
	db	$03,$0e,$03,$03,$0e,$03,$0e,$0e
	db	$06,$0e,$06,$06,$00,$06,$00,$00

	db	$06,$00,$06,$06,$0e,$06,$0e,$0e
	db	$06,$0e,$06,$06,$00,$06,$00,$00

	db	$06,$0e,$03,$03,$0e,$06,$00,$00

	db	$00,$06,$0e,$0e,$06,$00,$00,$00
	db	$00,$00,$06,$06,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00

	org $3800
screen
	;reTry
	incbin	"reTry.scr"
