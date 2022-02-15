

	org $0801
basic
	db $0c,$08,$e6,$07,$9e,$20,$32,$30,$36,$34,$00,$00

	org $0810
main
	lda #$00
	sta $d020
	lda #$00
	sta $d021

	lda #$00
	jsr music

	sei

	lda #$35
	sta $01

	lda #<irq
	sta $fffe
	lda #>irq
	sta $ffff

	lda #$7f
	sta $dc0d

	lda #$01
	sta $d01a

	lda #$00
	sta $d012 
	lda #$1b
	sta $d011
	
	cli

.mainloop
	jmp .mainloop

irq
	pha
	txa
	pha
	tya
	pha

	lda #$01
	sta $d019


	lda #$60
.waitloop
	cmp $d012
	bne .waitloop

	ldx #$00
.colorloop
	lda colors,x
	sta $d020
	sta $d021
	nop
	nop
	nop
	nop
	nop
	nop
	inx 
	cpx #$40
	bne .colorloop

	lda #$fc
.waitloop2
	cmp $d012
	bne .waitloop2

	dec $d020
	jsr music+3
	inc $d020

	pla
	tay
	pla
	tax
	pla

	rti

	org $0f00
colors
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00
	db $01,$00,$01,$00,$01,$00,$01,$00


	org $1000
music
	incbin "Pulse.dat",2
