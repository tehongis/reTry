

	
sprdist = 26

	org $0801
basic	
 	db  $0d,$08,$e5,$07,$9e,$28,$32,$30,$36,$34,$29,$00,$00
	org $0810
main	
	lda	#$00
	sta $d020
	sta $d021

	ldx #$00
.charloop
	lda logo,x
	sta $0400,x
	lda logo+$100,x
	sta $0500,x
	lda #$20
	sta $0600,x
	sta $0700,x
	inx
	bne .charloop

	ldx #$00
	lda #$00
.colorloop
	sta $d800,x
	sta $d900,x
	sta $da00,x
	sta $db00,x
	inx
	bne .colorloop


	lda #$ff
	sta $3ff8
	sta $3ff9
	sta $3ffa
	sta $3ffb
	sta $3ffc
	sta $3ffd
	sta $3ffe
	sta $3fff


	lda #$01
	jsr	$1000

	sei
	lda #$35
	sta $01

	lda #<myirq
	sta $fffe
	lda #>myirq
	sta $ffff

	lda #$7f
	sta $dc0d
	sta $dd0d

	lda #$1f
	sta $d018

	lda #$01
	sta $d01a

	lda #$00
	sta $d012
	lda #$1b
	sta $d011

	lda $dc0d
	lda $dd0d
	asl $d019
	cli

	lda #$c0
	sta $07f8
	lda #$c1
	sta $07f9
	lda #$c2
	sta $07fa
	lda #$c3
	sta $07fb
	lda #$c4
	sta $07fc
	lda #$c5
	sta $07fd
	lda #$c6
	sta $07fe
	lda #$c7
	sta $07ff

	lda #$20
	clc
	sta $d000
	adc #sprdist
	sta $d002
	adc #sprdist
	sta $d004
	adc #sprdist
	sta $d006
	adc #sprdist
	sta $d008
	adc #sprdist
	sta $d00a
	adc #sprdist
	sta $d00c
	adc #sprdist
	sta $d00e

	lda #$e0
	clc
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f

	lda #$06
	sta $d027
	sta $d028
	sta $d029
	sta $d02a
	sta $d02b
	sta $d02c
	sta $d02d
	sta $d02e

	lda #%01111111
	sta $d015
	sta $d01c

	lda #$00
	sta $fe
	lda #$40
	sta $ff

.initloop
	nop
	jmp .initloop

;*************************************
;* IRQ Starts here
;*************************************

myirq:
	asl $d019

	inc $fe
	inc $ff

	ldx $fe
	lda color,x
	sta $d025
	ldx $ff
	lda color,x
	sta $d026

	lda #$33
.raswait
	cmp $d012
	bne .raswait

	nop
	nop
	nop
	nop
	
	ldy #$00
.coloop
	lda color,y
	sta $d020
	sta $d021
	ldx delay,y
.deloop
	dex
	bne	.deloop
	iny
	cpy #$40
	bne	.coloop

	lda #$00
	sta $d020
	lda #$00
	sta $d021

	lda #$f8
.raswait2
	cmp $d012
	bne .raswait2

	lda	#$09
	sta $d020
	jsr $1003
	lda	#$05
	sta $d020


	lda $fc
	and #$1f
	tax
	lda fontanim+0,x
	sta font+0+(8*0)
	sta font+1+(8*0)
	sta font+2+(8*0)
	sta font+3+(8*0)
	sta font+4+(8*0)
	sta font+5+(8*0)
	sta font+6+(8*0)
	sta font+7+(8*0)

	lda fontanim+1,x
	sta font+0+(8*1)
	sta font+1+(8*1)
	sta font+2+(8*1)
	sta font+3+(8*1)
	sta font+4+(8*1)
	sta font+5+(8*1)
	sta font+6+(8*1)
	sta font+7+(8*1)

	lda fontanim+2,x
	sta font+0+(8*2)
	sta font+1+(8*2)
	sta font+2+(8*2)
	sta font+3+(8*2)
	sta font+4+(8*2)
	sta font+5+(8*2)
	sta font+6+(8*2)
	sta font+7+(8*2)

	lda fontanim+3,x
	sta font+0+(8*3)
	sta font+1+(8*3)
	sta font+2+(8*3)
	sta font+3+(8*3)
	sta font+4+(8*3)
	sta font+5+(8*3)
	sta font+6+(8*3)
	sta font+7+(8*3)

	lda fontanim+4,x
	sta font+0+(8*4)
	sta font+1+(8*4)
	sta font+2+(8*4)
	sta font+3+(8*4)
	sta font+4+(8*4)
	sta font+5+(8*4)
	sta font+6+(8*4)
	sta font+7+(8*4)

	lda fontanim+5,x
	sta font+0+(8*5)
	sta font+1+(8*5)
	sta font+2+(8*5)
	sta font+3+(8*5)
	sta font+4+(8*5)
	sta font+5+(8*5)
	sta font+6+(8*5)
	sta font+7+(8*5)

	lda fontanim+6,x
	sta font+0+(8*6)
	sta font+1+(8*6)
	sta font+2+(8*6)
	sta font+3+(8*6)
	sta font+4+(8*6)
	sta font+5+(8*6)
	sta font+6+(8*6)
	sta font+7+(8*6)

	lda fontanim+7,x
	sta font+0+(8*7)
	sta font+1+(8*7)
	sta font+2+(8*7)
	sta font+3+(8*7)
	sta font+4+(8*7)
	sta font+5+(8*7)
	sta font+6+(8*7)
	sta font+7+(8*7)

	lda fontanim+8,x
	sta font+0+(8*8)
	sta font+1+(8*8)
	sta font+2+(8*8)
	sta font+3+(8*8)
	sta font+4+(8*8)
	sta font+5+(8*8)
	sta font+6+(8*8)
	sta font+7+(8*8)

	lda fontanim+9,x
	sta font+0+(8*9)
	sta font+1+(8*9)
	sta font+2+(8*9)
	sta font+3+(8*9)
	sta font+4+(8*9)
	sta font+5+(8*9)
	sta font+6+(8*9)
	sta font+7+(8*9)

	lda fontanim+10,x
	sta font+0+(8*10)
	sta font+1+(8*10)
	sta font+2+(8*10)
	sta font+3+(8*10)
	sta font+4+(8*10)
	sta font+5+(8*10)
	sta font+6+(8*10)
	sta font+7+(8*10)

	lda fontanim+11,x
	sta font+0+(8*11)
	sta font+1+(8*11)
	sta font+2+(8*11)
	sta font+3+(8*11)
	sta font+4+(8*11)
	sta font+5+(8*11)
	sta font+6+(8*11)
	sta font+7+(8*11)

	lda fontanim+12,x
	sta font+0+(8*12)
	sta font+1+(8*12)
	sta font+2+(8*12)
	sta font+3+(8*12)
	sta font+4+(8*12)
	sta font+5+(8*12)
	sta font+6+(8*12)
	sta font+7+(8*12)

	lda fontanim+13,x
	sta font+0+(8*13)
	sta font+1+(8*13)
	sta font+2+(8*13)
	sta font+3+(8*13)
	sta font+4+(8*13)
	sta font+5+(8*13)
	sta font+6+(8*13)
	sta font+7+(8*13)

	lda fontanim+14,x
	sta font+0+(8*14)
	sta font+1+(8*14)
	sta font+2+(8*14)
	sta font+3+(8*14)
	sta font+4+(8*14)
	sta font+5+(8*14)
	sta font+6+(8*14)
	sta font+7+(8*14)

	lda fontanim+15,x
	sta font+0+(8*15)
	sta font+1+(8*15)
	sta font+2+(8*15)
	sta font+3+(8*15)
	sta font+4+(8*15)
	sta font+5+(8*15)
	sta font+6+(8*15)
	sta font+7+(8*15)


	inc $fc

	lda	#$00
	sta $d020

	rti

;*************************************
;* Data Starts here
;*************************************

	org $0e00
delay:
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01
	db $08,$08,$08,$08,$08,$08,$08,$01

	org $0f00
color:
	db 	$0b,$00,$0b,$0b,$05,$0b,$05,$05
	db 	$0d,$05,$0d,$0d,$01,$0d,$01,$01
	db 	$01,$01,$01,$01,$01,$01,$01,$01
	db 	$01,$01,$01,$01,$01,$01,$01,$01

	db 	$01,$01,$01,$01,$01,$01,$01,$01
	db 	$01,$01,$01,$01,$01,$01,$01,$01
	db 	$03,$01,$03,$03,$0e,$03,$0e,$0e
	db 	$06,$0e,$06,$06,$00,$06,$00,$00
	
	db 	$0b,$00,$0b,$0b,$0c,$0b,$0c,$0c
	db 	$0f,$0c,$0f,$0f,$01,$0f,$01,$01
	db 	$0f,$01,$0f,$0f,$0c,$0f,$0c,$0c
	db 	$0b,$0c,$0b,$0b,$0b,$00,$0b,$00
	
	db 	$06,$00,$06,$06,$0e,$06,$0e,$0e
	db 	$03,$0e,$03,$03,$01,$03,$01,$01
	db 	$03,$01,$03,$03,$0e,$03,$0e,$0e
	db 	$06,$0e,$06,$06,$00,$06,$00,$00

;*************************************
;* Music Starts here
;*************************************

	org $1000
music:
	incbin "Snickers.dat",2	; offset set to 2 to skip loadaddress bytes.

	org $2e00
logo:
	;  r                                e                                t                                r                                y
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff 
	db $00,$01,$02,$03,$04,$05,$ff,$ff, $ff,$02,$03,$04,$05,$06,$ff,$ff, $ff,$03,$04,$ff,$ff,$ff,$ff,$ff, $03,$04,$05,$06,$07,$08,$ff,$ff, $04,$05,$ff,$ff,$ff,$09,$0a,$ff
	db $00,$01,$ff,$ff,$ff,$05,$06,$ff, $01,$02,$ff,$ff,$ff,$06,$07,$ff, $02,$03,$04,$05,$06,$07,$08,$ff, $03,$04,$ff,$ff,$ff,$08,$09,$ff, $04,$05,$ff,$ff,$ff,$09,$0a,$ff
	db $00,$01,$ff,$ff,$ff,$ff,$ff,$ff, $01,$02,$ff,$ff,$ff,$06,$07,$ff, $ff,$03,$04,$ff,$ff,$ff,$ff,$ff, $03,$04,$ff,$ff,$ff,$ff,$ff,$ff, $04,$05,$ff,$ff,$ff,$09,$0a,$ff
	db $00,$01,$ff,$ff,$ff,$ff,$ff,$ff, $01,$02,$03,$04,$05,$06,$ff,$ff, $ff,$03,$04,$ff,$ff,$ff,$ff,$ff, $03,$04,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$05,$06,$07,$08,$09,$0a,$ff
	db $00,$01,$ff,$ff,$ff,$ff,$ff,$ff, $01,$02,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$03,$04,$ff,$ff,$ff,$ff,$ff, $03,$04,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$09,$0a,$ff
	db $00,$01,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$02,$03,$04,$05,$06,$ff,$ff, $ff,$ff,$04,$05,$06,$07,$ff,$ff, $03,$04,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$06,$07,$08,$09,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff, $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

;*************************************
;* Spritedata Starts here
;*************************************

	org $3000
sprdata:
	db $2a,$aa,$a8,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$2a,$aa,$a8,$81

	db $2a,$aa,$a8,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$2a,$aa,$a8,$81

	db $2a,$aa,$a8,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$2a,$aa,$a8,$81

	db $2a,$aa,$a8,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$2a,$aa,$a8,$81

	db $2a,$aa,$a8,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$2a,$aa,$a8,$81

	db $2a,$aa,$a8,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$2a,$aa,$a8,$81

	db $2a,$aa,$a8,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$b7,$77,$76,$9d
	db $dd,$de,$b7,$77,$76,$9d,$dd,$de
	db $b7,$77,$76,$9d,$dd,$de,$b7,$77
	db $76,$9d,$dd,$de,$2a,$aa,$a8,$81

	org $3700
fontanim
	db $80,$c0,$e0,$f0,$f8,$fc,$fe,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $7f,$3f,$1f,$0f,$07,$03,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $80,$c0,$e0,$f0,$f8,$fc,$fe,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $7f,$3f,$1f,$0f,$07,$03,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00

	org $3800
font:
	blk $800,0
