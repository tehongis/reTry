; reTry demo 2025 - SineSprite
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

	org $0801
basic
	db 	$0d, $08, $e0, $07, $9e, $28, $32, $30, $36, $34, $29, $00 ;2016 SYS (2064)

	org $0810
init

	;sprites on
	lda #$ff
	sta $d015

	; x and y expansion
	lda #$00
	sta $d017
	lda #$00
	sta $d01d

	;sprite priority
	lda #$00
	sta $d01b

	;sprite multicolor
	lda #$ff
	sta $d01c

	lda #$01 ; sprite multicolor 1
	sta $d025
	lda #$00 ; sprite multicolor 2
	sta $d026


	; sprite colors
	lda #$05
	sta $d027
	sta $d028
	sta $d029
	sta $d02a
	sta $d02b
	sta $d02c
	sta $d02d
	sta $d02e

	; pointer setup
	clc
	ldx #$00
	lda #$00
.pointerloop1
	sta pointers,x
	adc #$0b
	inx 
	inx 
	cpx #$10
	bne .pointerloop1

	clc
	ldx #$00
	lda #$80
.pointerloop2
	sta pointers+1,x
	adc #$f9
	inx 
	inx 
	cpx #$10
	bne .pointerloop2

	; irq setup
	sei 

    lda #$35
    sta $01

    lda #$7f
    sta $dc0d

    lda $dc0d
    lda $dd0d

    lda #$1b
    sta $d011
    lda #$fc
    sta $d012

    lda #<irq
    sta $fffe
    lda #>irq
    sta $ffff

    lda #$01
    sta $d01a

	jsr sinehalf

    cli

.iniloop
	jmp .iniloop

irq


	inc $d020
	jsr spriteregs

	inc $d020
	jsr animatesprites

	inc $d020
	jsr recalcpritelocs

	inc $d020
	jsr pointerupdate

	lda #$0e
	sta $d020
	lda #$06
	sta $d021

	asl $d019
	rti

sinehalf
	ldx #$00
.halfloop
	lda sine,x
	lsr
	sta sine+$0100,x
	inx 
	bne .halfloop
	rts

spriteregs
	ldx #$00
.regloop
	clc
	lda sprlocation,x
	adc #$30
	sta $d000,x
	ror $d010
	inx
	clc
	lda sprlocation,x
	adc #$40
	sta $d000,x
	inx
	cpx #$10
	bne .regloop

	rts

recalcpritelocs

	ldy #$00	
.locloop
	ldx pointers,y
	lda sine,x
	sta sprlocation,y
	iny 
	ldx pointers,y
	lda sine+$0100,x
	sta sprlocation,y
	iny 
	cpy #$10
	bne .locloop

	rts

animatesprites
	ldx #$00
.pointerloop
	lda sprpointers,x
	sta $07f8,x
	inx
	cpx #$8
	bne .pointerloop

	rts

pointerupdate
	ldx #$00
	clc
.pointerloop
	inc pointers,x
	inx 
	cpx #$10
	bne .pointerloop
	rts 

pointers
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00

sprlocation
	db $00, $01, $02, $03, $04, $05, $06, $07
	db $08, $09, $0a, $0b, $0c, $0d, $0e, $0f

sprpointers
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

	org $3c00

sine
 	db $80,$83,$86,$89,$8c,$8f,$92,$95,$98,$9b,$9e,$a2,$a5,$a7,$aa,$ad,$b0,$b3,$b6,$b9,$bc,$be,$c1,$c4,$c6,$c9,$cb,$ce,$d0,$d3,$d5,$d7,$da,$dc,$de,$e0,$e2,$e4,$e6,$e8,$ea,$eb,$ed,$ee,$f0,$f1,$f3,$f4,$f5,$f6,$f8,$f9,$fa,$fa,$fb,$fc,$fd,$fd,$fe,$fe,$fe,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$fe,$fe,$fe,$fd,$fd,$fc,$fb,$fa,$fa,$f9,$f8,$f6,$f5,$f4,$f3,$f1,$f0,$ee,$ed,$eb,$ea,$e8,$e6,$e4,$e2,$e0,$de,$dc,$da,$d7,$d5,$d3,$d0,$ce,$cb,$c9,$c6,$c4,$c1,$be,$bc,$b9,$b6,$b3,$b0,$ad,$aa,$a7,$a5,$a2,$9e,$9b,$98,$95,$92,$8f,$8c,$89,$86,$83,$80,$7c,$79,$76,$73,$70,$6d,$6a,$67,$64,$61,$5d,$5a,$58,$55,$52,$4f,$4c,$49,$46,$43,$41,$3e,$3b,$39,$36,$34,$31,$2f,$2c,$2a,$28,$25,$23,$21,$1f,$1d,$1b,$19,$17,$15,$14,$12,$11,$f,$e,$c,$b,$a,$9,$7,$6,$5,$5,$4,$3,$2,$2,$1,$1,$1,$0,$0,$0,$0,$0,$0,$0,$1,$1,$1,$2,$2,$3,$4,$5,$5,$6,$7,$9,$a,$b,$c,$e,$f,$11,$12,$14,$15,$17,$19,$1b,$1d,$1f,$21,$23,$25,$28,$2a,$2c,$2f,$31,$34,$36,$39,$3b,$3e,$41,$43,$46,$49,$4c,$4f,$52,$55,$58,$5a,$5d,$61,$64,$67,$6a,$6d,$70,$73,$76,$79,$7c

	org $3fc0
spritegraphics
	db $00,$3c,$00,$03,$db,$c0,$0d,$aa
	db $b0,$0e,$aa,$b0,$39,$aa,$ac,$35
	db $6a,$ac,$35,$6a,$ac,$e5,$6a,$bb
	db $d9,$aa,$af,$ea,$aa,$bb,$ea,$aa
	db $af,$ea,$aa,$bb,$ea,$aa,$ef,$ea
	db $aa,$bf,$3a,$aa,$ec,$3e,$ae,$bc
	db $3a,$eb,$fc,$0f,$bb,$f0,$0e,$ef
	db $f0,$03,$ff,$c0,$00,$3c,$00,$86