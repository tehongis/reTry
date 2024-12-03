

; https://sta.c64.org/cbm64mem.html


    org $0800
basic:
    db  $00,$0c,$08,$e8,$07,$9e,$20,$32,$30,$36,$34,$00,$00

    org $0810
init:
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

	lda #$f6
	sta $d012
	lda #$1b
	sta $d011

	lda $dc0d
	lda $dd0d
	asl $d019
	cli


	lda #$14
	sta $d018
    lda #$0e
    sta $d020
    lda #$06
    sta $d021

.loop 
    jmp .loop


irq:
	inc $d020
	asl $d019

	lda #%00011000
	sta $d011

	ldx #$0c
	lda #$06
.colorloop	
	sta $d020
	dex
	bne	.colorloop

	lda #%00010000
	sta $d011

	jsr colorgen

	dec $d020

	inc $3fff
    rti


colorgen
	ldx #$00
.colorloop
	lda colors,x
	sta $3fff

	eor #$00
	eor #$00
	eor #$00
	eor #$00
	eor #$00
	eor #$00
	eor #$00
	eor #$00
	eor #$00
	eor #$00

	inx
	cpx #$80
	bne .colorloop

	rts


colors
	db	$01,$03,$07,$0f,$1f,$3f,$7f,$ff
	db	$fe,$fc,$f8,$f0,$e0,$c0,$80,$00
	db	$01,$03,$07,$0f,$1f,$3f,$7f,$ff
	db	$fe,$fc,$f8,$f0,$e0,$c0,$80,$00

	db	$01,$03,$07,$0f,$1f,$3f,$7f,$ff
	db	$fe,$fc,$f8,$f0,$e0,$c0,$80,$00
	db	$01,$03,$07,$0f,$1f,$3f,$7f,$ff
	db	$fe,$fc,$f8,$f0,$e0,$c0,$80,$00


	db	$01,$03,$07,$0f,$1f,$3f,$7f,$ff
	db	$fe,$fc,$f8,$f0,$e0,$c0,$80,$00
	db	$01,$03,$07,$0f,$1f,$3f,$7f,$ff
	db	$fe,$fc,$f8,$f0,$e0,$c0,$80,$00
