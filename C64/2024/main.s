

; https://sta.c64.org/cbm64mem.html


    org $0800
basic:
    db  $00,$0c,$08,$e8,$07,$9e,$20,$32,$30,$36,$34,$00,$00

    org $0810
init:

	jsr copyrom

	jsr initsound

	jsr	sprrandompositions

	sei
	lda #$35
	sta $01

	lda #<irq
	sta $fffe
	lda #>irq
	sta $ffff

	lda #$7f
	sta $dc0d
	sta $dd0d

	lda #$01
	sta $d01a

	lda #$20
	sta $d012
	lda #$1b
	sta $d011

	lda $dc0d
	lda $dd0d
	asl $d019
	cli


	lda #$1f
	sta $d018
    lda #$0e
    sta $d020
    lda #$06
    sta $d021

	lda #$ff
	sta $d015	;sprites on

	lda #$ff
	sta	$d01b	;sprite priority

	ldx #$00
	lda #$01
.sprcolorloop
	sta $d027,x
	inx
	cpx #$08
	bne .sprcolorloop


.loop 
    jmp .loop

copyrom:
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

sprrandompositions
	ldx #$00
	ldy #$ff
	lda #$fe
.spriteloop
	sbc #$23
	eor #$4f
	and #$f8
	sta spritelocs,x
	tay
	lda #$ff
	sta spritelocs+1,x
	tya
	inx
	inx
	cpx #$10
	bne .spriteloop
	rts


initsound

	lda #$00
	sta $d415	;filter freq
	lda #$00
	sta $d416	;filter freq
	lda #$00
	sta $d417	;filter ctrl
	lda #$0f
	sta $d418	;volume & filtermode


voice1:

	lda #$0f
	sta $d405	;AD
	lda #$ff
	sta $d406	;SR

	lda #$00
	sta $d400	;freq lo
	lda #$02
	sta $d401	;freq hi

	lda #$00
	sta $d402	;pulse lo
	lda #$01
	sta $d403	;pulse hi

	lda #$41
	sta $d404

voice2:
	lda #$0f
	sta $d40c	;AD
	lda #$ff
	sta $d40d	;SR

	lda #$01
	sta $d407	;freq lo
	lda #$02
	sta $d408	;freq hi

	lda #$00
	sta $d409	;pulse lo
	lda #$02
	sta $d40a	;pulse hi

	lda #$41
	sta $d40b


	nop
	nop

	lda #$40
	sta $d404
	sta $d40b

	rts



irq:
	inc $d020
	asl $d019

	jsr	sprsetform

	jsr	sprsetpositions

	jsr	sprmovepositions

	dec $d020
    rti

sprsetform
	lda $ff
	and #$03
	ora #$fc
	sta $07f8
	sta $07f9
	sta $07fa
	sta $07fb
	sta $07fc
	sta $07fd
	sta $07fe
	sta $07ff

	inc $ff

	rts

sprsetpositions
	
	ldx #$00
.spriteloop
	lda spritelocs,x
	sta $d000,x
	inx 
	cpx #$11
	bne .spriteloop

	rts

sprmovepositions
	ldx #$00
.spriteloop2
	sec
	lda spritelocs+1,x
	sbc #$01
	cmp #$00
	bne .continue

	lda $fe
	sta spritelocs,x
	lda #$ff

.continue
	sta spritelocs+1,x
	inx 
	inx 
	cpx #$10
	bne .spriteloop2

	lda $fe
	adc $ff
	eor #$1f
	sta $fe

	dec $fe

	rts

spritelocs:
	db $00,$00, $00,$00, $00,$00, $00,$00
	db $00,$00, $00,$00, $00,$00, $00,$00
	db $00

	org $3f00

	db	$28,$00,$00,$14,$00,$00,$28,$00
	db	$00,$54,$00,$00,$2a,$00,$00,$54
	db	$00,$00,$aa,$00,$00,$55,$00,$00
	db	$aa,$00,$00,$5d,$00,$00,$f7,$00
	db	$00,$be,$00,$00,$fb,$00,$00,$ff
	db	$00,$00,$ff,$00,$00,$ff,$00,$00
	db	$ff,$00,$00,$ff,$00,$00,$ff,$00
	db	$00,$ff,$00,$00,$ff,$00,$00,$03

	db	$08,$00,$00,$14,$00,$00,$28,$00
	db	$00,$14,$00,$00,$2a,$00,$00,$54
	db	$00,$00,$2a,$00,$00,$55,$00,$00
	db	$aa,$00,$00,$55,$00,$00,$ba,$00
	db	$00,$ef,$00,$00,$7d,$00,$00,$df
	db	$00,$00,$ff,$00,$00,$ff,$00,$00
	db	$ff,$00,$00,$ff,$00,$00,$ff,$00
	db	$00,$ff,$00,$00,$ff,$00,$00,$03

	db	$14,$00,$00,$28,$00,$00,$14,$00
	db	$00,$2a,$00,$00,$54,$00,$00,$2a
	db	$00,$00,$55,$00,$00,$aa,$00,$00
	db	$55,$00,$00,$ba,$00,$00,$ef,$00
	db	$00,$7d,$00,$00,$df,$00,$00,$ff
	db	$00,$00,$ff,$00,$00,$ff,$00,$00
	db	$ff,$00,$00,$ff,$00,$00,$ff,$00
	db	$00,$ff,$00,$00,$ff,$00,$00,$03

	db	$10,$00,$00,$28,$00,$00,$14,$00
	db	$00,$28,$00,$00,$54,$00,$00,$2a
	db	$00,$00,$54,$00,$00,$aa,$00,$00
	db	$55,$00,$00,$aa,$00,$00,$5d,$00
	db	$00,$f7,$00,$00,$be,$00,$00,$fb
	db	$00,$00,$ff,$00,$00,$ff,$00,$00
	db	$ff,$00,$00,$ff,$00,$00,$ff,$00
	db	$00,$ff,$00,$00,$ff,$00,$00,$03