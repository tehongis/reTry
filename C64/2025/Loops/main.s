

; https://sta.c64.org/cbm64mem.html

; 1000-1c00 music
; 3e00-4000 spriteforms

SPRADDX = 22
SPRADDY = 54

    org $0800
basic:
    db  $00,$0c,$08,$e8,$07,$9e,$20,$32,$30,$36,$34,$00,$00

    org $0810
init:

;	jsr copyrom
	jsr setupscreen
;	jsr setupcharmap

	jsr calcsinesplit

	jsr initsprformdata
	jsr	sprsetform	
	jsr setupsprites

	jsr initIRQ

	lda #$01
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

	lda #$15
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

setupsprites		;-------------------------------

	lda #$ff
	sta $d015	;sprites on

	lda #$00
	sta	$d01b	;sprite priority

	ldx #$00
	lda #$01
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

calcsinesplit:
	ldx #$00
.splitloop
 	lda sine,x
	lsr 
	sta sinesplit,x
	inx
	bne .splitloop
	rts

MyIRQ		;-------------------------------:
	inc $d020
	asl $d019

	jsr	spriteCalc
	jsr	spriteUpdate
	jsr	animateChars

	inc $d020
	jsr music + 3
	dec $d020

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


spriteCalc

	clc
	ldx #$00
.spriteloopx
	lda spritex
	adc spriteform,x
	sta spritelocs,x
	ror spritelocs+$10
	inx
	inx
	cpx #$10
	bne .spriteloopx

	clc
	ldx #$00
.spriteloopy
	lda spritey
	adc spriteform+1,x
	sta spritelocs+1,x
	inx
	inx
	cpx #$10
	bne .spriteloopy

	clc
	ldx spritecounters
	lda sine,x
	sta spritex

	clc
	ldx spritecounters+1
	lda sine,x
	lsr
	sta spritey

	inc spritecounters
	inc spritecounters+1

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

spritex:
	db 0

spritey:
	db 0

spritecounters:
	db 0,50,210,150

spriteform:
	db SPRADDX+(24*0),SPRADDY+(21*0)
	db SPRADDX+(24*0),SPRADDY+(21*1)
	db SPRADDX+(24*0),SPRADDY+(21*2)
	db SPRADDX+(24*1),SPRADDY+(21*0)
	db SPRADDX+(24*1),SPRADDY+(21*2)
	db SPRADDX+(24*2),SPRADDY+(21*0)
	db SPRADDX+(24*2),SPRADDY+(21*1)
	db SPRADDX+(24*2),SPRADDY+(21*2)

spritelocs:
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0

	org $0e00
sine:
	db	$7f,$82,$85,$88,$8b,$8e,$91,$94,$97,$9a,$9d,$a1,$a4,$a6,$a9,$ac
	db	$af,$b2,$b5,$b8,$bb,$bd,$c0,$c3,$c5,$c8,$ca,$cd,$cf,$d2,$d4,$d6
	db	$d9,$db,$dd,$df,$e1,$e3,$e5,$e7,$e8,$ea,$ec,$ed,$ef,$f0,$f2,$f3
	db	$f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fb,$fc,$fc,$fd,$fd,$fd,$fd,$fd
	db	$fd,$fd,$fd,$fd,$fd,$fc,$fc,$fb,$fb,$fa,$f9,$f9,$f8,$f7,$f6,$f5
	db	$f3,$f2,$f1,$ef,$ee,$ec,$eb,$e9,$e7,$e6,$e4,$e2,$e0,$de,$dc,$da
	db	$d7,$d5,$d3,$d1,$ce,$cc,$c9,$c7,$c4,$c1,$bf,$bc,$b9,$b6,$b4,$b1
	db	$ae,$ab,$a8,$a5,$a2,$9f,$9c,$99,$96,$93,$90,$8d,$89,$86,$83,$80
	db	$7d,$7a,$77,$74,$70,$6d,$6a,$67,$64,$61,$5e,$5b,$58,$55,$52,$4f
	db	$4c,$49,$47,$44,$41,$3e,$3c,$39,$36,$34,$31,$2f,$2c,$2a,$28,$26
	db	$23,$21,$1f,$1d,$1b,$19,$17,$16,$14,$12,$11,$0f,$0e,$0c,$0b,$0a
	db	$08,$07,$06,$05,$04,$04,$03,$02,$02,$01,$01,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$01,$01,$02,$02,$03,$04,$05,$06,$07,$08,$09
	db	$0a,$0b,$0d,$0e,$10,$11,$13,$15,$16,$18,$1a,$1c,$1e,$20,$22,$24
	db	$27,$29,$2b,$2e,$30,$33,$35,$38,$3a,$3d,$40,$42,$45,$48,$4b,$4e
	db	$51,$54,$57,$59,$5c,$60,$63,$66,$69,$6c,$6f,$72,$75,$78,$7b,$7e

	org $0f00
sinesplit:
	db	$7f,$82,$85,$88,$8b,$8e,$91,$94,$97,$9a,$9d,$a1,$a4,$a6,$a9,$ac
	db	$af,$b2,$b5,$b8,$bb,$bd,$c0,$c3,$c5,$c8,$ca,$cd,$cf,$d2,$d4,$d6
	db	$d9,$db,$dd,$df,$e1,$e3,$e5,$e7,$e8,$ea,$ec,$ed,$ef,$f0,$f2,$f3
	db	$f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$fb,$fc,$fc,$fd,$fd,$fd,$fd,$fd
	db	$fd,$fd,$fd,$fd,$fd,$fc,$fc,$fb,$fb,$fa,$f9,$f9,$f8,$f7,$f6,$f5
	db	$f3,$f2,$f1,$ef,$ee,$ec,$eb,$e9,$e7,$e6,$e4,$e2,$e0,$de,$dc,$da
	db	$d7,$d5,$d3,$d1,$ce,$cc,$c9,$c7,$c4,$c1,$bf,$bc,$b9,$b6,$b4,$b1
	db	$ae,$ab,$a8,$a5,$a2,$9f,$9c,$99,$96,$93,$90,$8d,$89,$86,$83,$80
	db	$7d,$7a,$77,$74,$70,$6d,$6a,$67,$64,$61,$5e,$5b,$58,$55,$52,$4f
	db	$4c,$49,$47,$44,$41,$3e,$3c,$39,$36,$34,$31,$2f,$2c,$2a,$28,$26
	db	$23,$21,$1f,$1d,$1b,$19,$17,$16,$14,$12,$11,$0f,$0e,$0c,$0b,$0a
	db	$08,$07,$06,$05,$04,$04,$03,$02,$02,$01,$01,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$01,$01,$02,$02,$03,$04,$05,$06,$07,$08,$09
	db	$0a,$0b,$0d,$0e,$10,$11,$13,$15,$16,$18,$1a,$1c,$1e,$20,$22,$24
	db	$27,$29,$2b,$2e,$30,$33,$35,$38,$3a,$3d,$40,$42,$45,$48,$4b,$4e
	db	$51,$54,$57,$59,$5c,$60,$63,$66,$69,$6c,$6f,$72,$75,$78,$7b,$7e


	org $1000
music
	incbin "Music.dat",2 
