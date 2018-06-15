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
	
	lda	#$01
	sta	$d020

	lda $d019
	sta $d019

	ldx	sinepos
	lda	sine,x
	sta	rowposy

	sta	row1_pointers+$01
	sta	row1_pointers+$03
	sta	row1_pointers+$05
	sta	row1_pointers+$07
	sta	row1_pointers+$09
	sta	row1_pointers+$0b
	sta	row1_pointers+$0d
	sta	row1_pointers+$0f

	clc
	adc #22

	sta	row2_pointers+$01
	sta	row2_pointers+$03
	sta	row2_pointers+$05
	sta	row2_pointers+$07
	sta	row2_pointers+$09
	sta	row2_pointers+$0b
	sta	row2_pointers+$0d
	sta	row2_pointers+$0f

	inc	sinepos
	
	lda #<row1irq
	sta $fffe
	lda #>row1irq
	sta $ffff	
	lda rowposy
	clc
	sbc	#$04
	sta $d012

	lda	#$07
	sta	$d020
	
	pla
	tay
	pla
	tax
	pla

	rti	
	
row1irq

	pha
	txa
	pha
	tya
	pha

	lda $d019
	sta $d019

posrow1
	ldx	#$00
.sprloop
	lda	row1_pointers,x
	sta	$d000,x
	inx
	cpx	#$10
	bne	.sprloop

	lda #<row2irq
	sta $fffe
	lda #>row2irq
	sta $ffff	
	lda rowposy
	clc
	adc	#$0e
	sta $d012

	lda	#$0c
	sta	$d020
	
	pla
	tay
	pla
	tax
	pla

	rti

row2irq
	pha
	txa
	pha
	tya
	pha

	lda $d019
	sta $d019

posrow2
	ldx	#$00
.sprloop
	lda	row2_pointers,x
	sta	$d000,x
	inx
	cpx	#$10
	bne	.sprloop

	lda #<mainirq
	sta $fffe
	lda #>mainirq
	sta $ffff
	lda #$00
	sta $d012
	
	lda	#$00
	sta	$d020

	jsr	song+3

	lda	#$0e
	sta	$d020
	

	pla
	tay
	pla
	tax
	pla

	rti
		
gfxinit
	lda #$0e
	sta $d020
	lda #$06
	sta $d021

	lda	#$04
	sta	$d025	;Sprite extra color #1
	lda	#$03
	sta	$d026	;Sprite extra color #2
	lda	#$01
	sta	$d027	;Sprite color #1
	sta	$d028	;Sprite color #2
	sta	$d029	;Sprite color #3
	sta	$d02a	;Sprite color #4
	sta	$d02b	;Sprite color #5
	sta	$d02c	;Sprite color #6
	sta	$d02d	;Sprite color #7
	sta	$d02e	;Sprite color #8
	
	lda	#$c0
	sta	$07f8
	lda	#$c1
	sta	$07f9
	lda	#$c2
	sta	$07fa
	lda	#$c3
	sta	$07fb
	lda	#$c4
	sta	$07fc
	lda	#$c5
	sta	$07fd
	lda	#$c6
	sta	$07fe
	lda	#$c7
	sta	$07ff

	lda #$c8
	sta $d016
	lda #$14
	sta $d018

	lda #$ff
	sta	$d015	;Sprites on
	lda #$ff
	sta	$d01c	;Spr Multicolor on
	lda	#$ff
	sta	$d01b	;Sprite priority

	ldx	#$00
	lda	rowposx
	clc
.loop
	sta	row1_pointers,x
	sta	row2_pointers,x
	adc	#24
	inx
	inx
	cpx	#$10
	bne	.loop

	rts

sinepos
	db	0
rowposx
	db	63+24
rowposy
	db	$0
row1_pointers
	db	$0,0,$0,0,$0,0,$0,0,$0,0,$0,0,$0,0,$0,0,%00000000
row2_pointers
	db	$0,0,$0,0,$0,0,$0,0,$0,0,$0,0,$0,0,$0,0,%00000000

	org $0e00
sine
	db	$10,$11,$12,$13,$14,$15,$16,$17
	db	$18,$19,$1a,$1b,$1c,$1d,$1e,$1f
	db	$20,$21,$22,$23,$24,$25,$26,$27
	db	$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
	db	$30,$31,$32,$33,$34,$35,$36,$37
	db	$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
	db	$40,$41,$42,$43,$44,$45,$46,$47
	db	$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$50,$50,$50,$50,$50,$50,$50,$50	
	db	$4e,$4c,$4a,$48,$46,$44,$42,$40		
	db	$3e,$3c,$3a,$38,$36,$34,$32,$30		
	db	$2e,$2c,$2a,$28,$26,$24,$22,$20
	db	$1e,$1c,$1a,$18,$16,$14,$12,$10

	org $1000
song
	incbin	"song.dat"

	org $3000
	
sprite
	db	255, 255, 255, 128, 0, 0, 187, 32, 0 
	db	160, 0, 0, 160, 0, 0, 128, 0, 0 
	db	160, 0, 0, 160, 0, 0, 128, 52, 0 
	db	128, 62, 0, 160, 54, 0, 128, 48, 0 
	db	128, 48, 0, 128, 48, 0, 128, 0, 0 
	db	128, 0, 0, 128, 0, 0, 128, 0, 0 
	db	128, 0, 0, 128, 0, 0, 128, 0, 0 
	
sprite2
	db	255, 255, 255, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 112, 0 
	db	0, 216, 0, 0, 248, 0, 0, 192, 0 
	db	0, 216, 0, 0, 112, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 

sprite3
	db	255, 255, 255, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 252, 0, 0, 48, 0, 0, 48, 0 
	db	0, 48, 0, 0, 48, 0, 0, 48, 0 
	db	0, 48, 0, 0, 48, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 

sprite4
	db	255, 255, 255, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 104, 0, 0, 124, 0 
	db	0, 108, 0, 0, 96, 0, 0, 96, 0 
	db	0, 96, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 

sprite5
	db	255, 255, 255, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 108, 0, 0, 108, 0 
	db	0, 108, 0, 0, 60, 0, 0, 24, 0 
	db	0, 48, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 

sprite6
	db	255, 255, 255, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 

sprite7
	db	255, 255, 255, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 
	db	0, 0, 0, 0, 0, 0, 0, 0, 0 

sprite8
	db	255, 255, 255, 0, 0, 1, 0, 0, 1 
	db	0, 0, 1, 0, 0, 1, 0, 0, 1 
	db	0, 0, 1, 0, 0, 1, 0, 0, 1 
	db	0, 0, 1, 0, 0, 1, 0, 0, 1 
	db	0, 0, 1, 0, 0, 1, 0, 0, 1 
	db	0, 0, 1, 0, 0, 1, 0, 0, 1 
	db	0, 0, 1, 0, 0, 1, 0, 0, 1 
