

; https://sta.c64.org/cbm64mem.html

; 3e00-4000 spriteforms

    org $0800
basic:
    db  $00,$0c,$08,$e8,$07,$9e,$20,$32,$30,$36,$34,$00,$00

    org $0810
init:

	jsr copyrom
	jsr setupscreen
	jsr setupcharmap

	jsr initsprformdata
	jsr	sprsetform	
	jsr setupsprites

	jsr initIRQ

	lda #$00
	jsr music


.loop 
    jmp .loop

initIRQ		;-------------------------------

	sei
	lda #$35
	sta $01

	lda #<MyIRQ
	sta $fffe
	lda #>MyIRQ
	sta $ffff

	lda #$7f
	sta $dc0d
	sta $dd0d

	lda #$01
	sta $d01a

	lda #$fc
	sta $d012
	lda #$1b
	sta $d011

	lda $dc0d
	lda $dd0d
	asl $d019
	cli

	rts

setupscreen		;-------------------------------

	lda #$1f
	sta $d018
    lda #$0e
    sta $d020
    lda #$06
    sta $d021

	rts

setupcharmap		;-------------------------------

	ldx #$00
.charmaploop
	lda #$00
	sta $0400,x
	sta $0400+(4*40*1),x
	sta $0400+(4*40*2),x
	sta $0400+(4*40*3),x
	sta $0400+(4*40*4),x
	sta $0400+(4*40*5),x
	sta $0400+(4*40*6),x
	lda #$04
	sta $0401,x
	sta $0401+(4*40*1),x
	sta $0401+(4*40*2),x
	sta $0401+(4*40*3),x
	sta $0401+(4*40*4),x
	sta $0401+(4*40*5),x
	sta $0401+(4*40*6),x
	lda #$08
	sta $0402,x
	sta $0402+(4*40*1),x
	sta $0402+(4*40*2),x
	sta $0402+(4*40*3),x
	sta $0402+(4*40*4),x
	sta $0402+(4*40*5),x
	sta $0402+(4*40*6),x
	lda #$0c
	sta $0403,x
	sta $0403+(4*40*1),x
	sta $0403+(4*40*2),x
	sta $0403+(4*40*3),x
	sta $0403+(4*40*4),x
	sta $0403+(4*40*5),x
	sta $0403+(4*40*6),x
	inx
	inx
	inx
	inx
	cpx #$28
	bne .charmaploop

	ldx #$00
	clc
.mapcopyloop
	lda $0400,x
	adc #$01
	sta $0400+(40*1),x
	sta $0400+(40*1)+(4*40*1),x
	sta $0400+(40*1)+(4*40*2),x
	sta $0400+(40*1)+(4*40*3),x
	sta $0400+(40*1)+(4*40*4),x
	sta $0400+(40*1)+(4*40*5),x
	adc #$01
	sta $0400+(40*2),x
	sta $0400+(40*2)+(4*40*1),x
	sta $0400+(40*2)+(4*40*2),x
	sta $0400+(40*2)+(4*40*3),x
	sta $0400+(40*2)+(4*40*4),x
	sta $0400+(40*2)+(4*40*5),x
	adc #$01
	sta $0400+(40*3),x
	sta $0400+(40*3)+(4*40*1),x
	sta $0400+(40*3)+(4*40*2),x
	sta $0400+(40*3)+(4*40*3),x
	sta $0400+(40*3)+(4*40*4),x
	sta $0400+(40*3)+(4*40*5),x
	inx
	cpx #$28
	bne .mapcopyloop

	rts

setupsprites		;-------------------------------

	lda #$ff
	sta $d015	;sprites on

	lda #$00
	sta	$d01b	;sprite priority

	ldx #$00
	lda #$00
.sprcolorloop
	sta $d027,x
	inx
	cpx #$08
	bne .sprcolorloop
	rts

sprsetform		;-------------------------------

	ldx #$f8
	stx $07f8
	inx
	stx $07f9
	inx
	stx $07fa
	inx
	stx $07fb
	inx
	stx $07fc
	inx
	stx $07fd
	inx
	stx $07fe
	inx
	stx $07ff

	rts

initsprformdata		;-------------------------------

	lda #$ff
	ldx #$00
.sprformloop
	sta $3e00,x
	sta $3e40,x
	sta $3e80,x
	sta $3ec0,x
	sta $3f00,x
	sta $3f40,x
	sta $3f80,x
	sta $3fc0,x
	inx
	cpx #$40
	bne .sprformloop

	rts


copyrom		;-------------------------------
	sei
	lda #%00110011 ; %0xx: Character ROM visible at $D000-$DFFF. (Except for the value %000, see above.)
	sta $01

	ldx #$00
.loop
	lda $d000,x
	sta $3800,x
	lda $d100,x
	sta $3900,x
	lda $d200,x
	sta $3a00,x
	lda $d300,x
	sta $3b00,x

	inx
	bne .loop

	lda #$37
	sta $01
	cli

	rts

MyIRQ		;-------------------------------:
	inc $d020
	asl $d019


	jsr	spriteUpdate
	jsr	animateChars
;	jsr music + 3

	dec $d020
    rti

animateChars

	ldy $3800	;backup bottom
	ldx #$00
.animloop
	lda $3801,x
	sta $3800,x
	inx
	cpx #$7f
	bne .animloop
	sty $387f

	rts

spriteUpdate
	ldx #$00
.spriteloop
	lda spritelocs,x
	sta $d000,x
	inx 
	cpx #$11
	bne .spriteloop
	rts

spritelocs:
	db $38,$38
	db $38,$50
	db $38,$68
	db $38,$80
	db $38,$98
	db $38,$b0
	db $38,$c8
	db $38,$e0
	db $ff

	org $1000
music
	incbin "music.dat"
