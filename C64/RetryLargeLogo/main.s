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

SINECOUNTL = $f8
SINECOUNTH = $f9


	org $0801
basic
	db 	$0d, $08, $e0, $07, $9e, $28, $32, $30, $36, $34, $29, $00 ;2016 SYS (2064)

	org $0810

	jsr screeninit
	jsr spriteinit
	jsr	precalc

	sei
	lda #$7f
	sta	$dc0d
	lda #$35
	sta $01
	lda #<mainirq
	sta $fffe
	lda #>mainirq
	sta $ffff
;	lda #$03
;	sta $dd00		;Move display to $4000
	lda #$10
	sta $d011
	lda #$f7
	sta $d012
	lda #$01
	sta $d01a
	cli

	lda #$35
	sta SINECOUNTH
	lda #$ef
	sta SINECOUNTL	
	lda #$00
	jsr	song
	
.loop
	jmp .loop
	
;------ Main IRQ	

mainirq
	pha
	txa
	pha
	tya
	pha

	lda $d019
	sta $d019
	
	jsr	getsinel
	and #$07
	eor #$07
	ora #$10
	sta $d011

	jsr	sineinc
	

	jsr	getsineh
	sta	HARD
	
	jsr logo2screen
	
	jsr	line2code

	jsr	song+3
		
	pla
	tay
	pla
	tax
	pla

	rti	
	
screeninit
	lda	#$00
	sta	$d020
	lda	#$00
	sta	$d021
	lda #$c8
	;lda #$d8		;Multicolor
	sta $d016
		
	ldx	#$00
	lda	#$01
.cololoop
	sta	$d800,x
	sta	$d900,x
	sta	$da00,x
	sta	$db00,x
	inx
	bne	.cololoop

	rts
	
spriteinit
	
	lda	#$ff
	sta $d015	;sprite 0 on

	lda #$0f	;priority
	sta $d01b
	
	ldx	#$00
.locloop	
	lda	spriteloc,x
	sta	$d000,x
	inx
	cpx #$11
	bne	.locloop

	ldx	#$00
.modloop	
	lda	spritemodel,x
	sta $07f8,x
	lda	spritecol,x
	sta $d027,x
	inx
	cpx #$08
	bne	.modloop

	rts

sineinc
	clc
	lda SINECOUNTL
	adc #$02
	sta SINECOUNTL
	
	lda SINECOUNTH
	adc	#$00
	cmp	#$38
	beq sinereset
	sta SINECOUNTH
	rts
	
sinereset
	lda #>sinedata
	sta SINECOUNTH
	lda #<sinedata
	sta SINECOUNTL
	rts

getsineh
	ldy	#$00
	lda	(SINECOUNTL),y
	rts

getsinel
	lda SINECOUNTH
	eor	#$08
	sta SINECOUNTH

	ldy	#$00
	lda	(SINECOUNTL),y
	tay

	lda SINECOUNTH
	eor	#$08
	sta SINECOUNTH
	
	tya
	rts
	

precalc
	
	lda	#<logodata
	sta	$fb
	lda #>logodata
	sta	$fc

	ldx	#$00
.precaloop
	lda	$fb
	clc
	adc	#$28
	sta $fb
	sta	logolocl,x
	
	lda	$fc
	adc	#$00
	sta $fc
	sta	logoloch,x

	inx
	bne	.precaloop
	rts

line2code
	ldx	HARD
	lda logolocl,x
	sta logo2screen+(6*0)+3
	lda logoloch,x
	sta logo2screen+(6*0)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*1)+3
	lda logoloch,x
	sta logo2screen+(6*1)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*2)+3
	lda logoloch,x
	sta logo2screen+(6*2)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*3)+3
	lda logoloch,x
	sta logo2screen+(6*3)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*4)+3
	lda logoloch,x
	sta logo2screen+(6*4)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*5)+3
	lda logoloch,x
	sta logo2screen+(6*5)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*6)+3
	lda logoloch,x
	sta logo2screen+(6*6)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*7)+3
	lda logoloch,x
	sta logo2screen+(6*7)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*8)+3
	lda logoloch,x
	sta logo2screen+(6*8)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*9)+3
	lda logoloch,x
	sta logo2screen+(6*9)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*10)+3
	lda logoloch,x
	sta logo2screen+(6*10)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*11)+3
	lda logoloch,x
	sta logo2screen+(6*11)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*12)+3
	lda logoloch,x
	sta logo2screen+(6*12)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*13)+3
	lda logoloch,x
	sta logo2screen+(6*13)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*14)+3
	lda logoloch,x
	sta logo2screen+(6*14)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*15)+3
	lda logoloch,x
	sta logo2screen+(6*15)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*16)+3
	lda logoloch,x
	sta logo2screen+(6*16)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*17)+3
	lda logoloch,x
	sta logo2screen+(6*17)+4
	inx
	lda logolocl,x
	sta logo2screen+(6*18)+3
	lda logoloch,x
	sta logo2screen+(6*18)+4
	
;-------- block for last 8 lines
	inx
	lda logolocl,x
	sta logo2screen+(6*19)+10
	lda logoloch,x
	sta logo2screen+(6*19)+11
	inx
	lda logolocl,x
	sta logo2screen+(6*20)+10
	lda logoloch,x
	sta logo2screen+(6*20)+11
	inx
	lda logolocl,x
	sta logo2screen+(6*21)+10
	lda logoloch,x
	sta logo2screen+(6*21)+11
	inx
	lda logolocl,x
	sta logo2screen+(6*22)+10
	lda logoloch,x
	sta logo2screen+(6*22)+11
	inx
	lda logolocl,x
	sta logo2screen+(6*23)+10
	lda logoloch,x
	sta logo2screen+(6*23)+11
	inx
	lda logolocl,x
	sta logo2screen+(6*24)+10
	lda logoloch,x
	sta logo2screen+(6*24)+11
	
	rts
	
logo2screen
	ldx	#$00
.lineloop1
	lda	logodata+($28*0),x
	sta	$0400+($28*0),x
	lda	logodata+($28*1),x
	sta	$0400+($28*1),x
	lda	logodata+($28*2),x
	sta	$0400+($28*2),x
	lda	logodata+($28*3),x
	sta	$0400+($28*3),x
	lda	logodata+($28*4),x
	sta	$0400+($28*4),x
	lda	logodata+($28*5),x
	sta	$0400+($28*5),x
	lda	logodata+($28*6),x
	sta	$0400+($28*6),x
	lda	logodata+($28*7),x
	sta	$0400+($28*7),x
	lda	logodata+($28*8),x
	sta	$0400+($28*8),x
	lda	logodata+($28*9),x
	sta	$0400+($28*9),x
	lda	logodata+($28*10),x
	sta	$0400+($28*10),x
	lda	logodata+($28*11),x
	sta	$0400+($28*11),x
	lda	logodata+($28*12),x
	sta	$0400+($28*12),x
	lda	logodata+($28*13),x
	sta	$0400+($28*13),x
	lda	logodata+($28*14),x
	sta	$0400+($28*14),x
	lda	logodata+($28*15),x
	sta	$0400+($28*15),x
	lda	logodata+($28*16),x
	sta	$0400+($28*16),x
	lda	logodata+($28*17),x
	sta	$0400+($28*17),x
	lda	logodata+($28*18),x
	sta	$0400+($28*18),x
	inx
	cpx #$28
	bne	.lineloop1
	
	ldx	#$00
.lineloop2	
	lda	logodata+($28*19),x
	sta	$0400+($28*19),x
	lda	logodata+($28*20),x
	sta	$0400+($28*20),x
	lda	logodata+($28*21),x
	sta	$0400+($28*21),x
	lda	logodata+($28*22),x
	sta	$0400+($28*22),x
	lda	logodata+($28*23),x
	sta	$0400+($28*23),x
	lda	logodata+($28*24),x
	sta	$0400+($28*24),x
	inx
	cpx #$28
	bne	.lineloop2
	rts

	
;------- DATA BE BELOW HERE	
hexlist
	db "0123456789abcdef"
	
DIRECTION
	db	$00
SOFT
	db	$00
HARD
	db 	$00
	
spriteloc
	db	$00,$de
	db	$19,$de
	db	$2d,$de
	db	$3f,$de
	db	$01,$df
	db	$1a,$df
	db	$2e,$df
	db	$40,$df
	db	$ff
spritemodel
	db	$bb,$bc,$bd,$be,$bb,$bc,$bd,$be
spritecol
	db	$0e,$0e,$0e,$0e,$06,$06,$06,$06
	
	org $0e00
logolocl
	org $0f00
logoloch

	org $1000
song
	incbin	"song.dat"

	org $2ec0
spritedata

;number_2:
	db	$7f,$ff,$fe,$ff,$00,$ff,$ff,$00
	db	$ff,$ff,$00,$ff,$ff,$00,$ff,$ff
	db	$00,$ff,$ff,$00,$ff,$00,$00,$ff
	db	$00,$01,$ff,$00,$03,$fe,$3f,$ff
	db	$fc,$7f,$c0,$00,$ff,$80,$00,$ff
	db	$00,$00,$ff,$00,$ff,$ff,$00,$ff
	db	$ff,$00,$ff,$ff,$00,$ff,$ff,$00
	db	$ff,$ff,$00,$ff,$ff,$ff,$ff,$01

; number_0
	db	$7f,$ff,$fe,$ff,$00,$ff,$ff,$00
	db	$ff,$ff,$00,$ff,$ff,$00,$ff,$ff
	db	$00,$ff,$ff,$00,$ff,$ff,$00,$ff
	db	$ff,$00,$ff,$ff,$00,$ff,$ff,$00
	db	$ff,$ff,$00,$ff,$ff,$00,$ff,$ff
	db	$00,$ff,$ff,$00,$ff,$ff,$00,$ff
	db	$ff,$00,$ff,$ff,$00,$ff,$ff,$00
	db	$ff,$ff,$00,$ff,$7f,$ff,$fe,$01

;number_1
	db	$00,$ff,$00,$01,$ff,$00,$03,$ff
	db	$00,$07,$ff,$00,$00,$ff,$00,$00
	db	$ff,$00,$00,$ff,$00,$00,$ff,$00
	db	$00,$ff,$00,$00,$ff,$00,$00,$ff
	db	$00,$00,$ff,$00,$00,$ff,$00,$00
	db	$ff,$00,$00,$ff,$00,$00,$ff,$00
	db	$00,$ff,$00,$00,$ff,$00,$00,$ff
	db	$00,$00,$ff,$00,$00,$ff,$00,$01

;number_9:
	db	$7f,$ff,$fe,$ff,$00,$ff,$ff,$00
	db	$ff,$ff,$00,$ff,$ff,$00,$ff,$ff
	db	$00,$ff,$ff,$00,$ff,$ff,$00,$ff
	db	$ff,$00,$ff,$ff,$00,$ff,$7f,$ff
	db	$ff,$00,$00,$ff,$00,$00,$ff,$00
	db	$00,$ff,$ff,$00,$ff,$ff,$00,$ff
	db	$ff,$00,$ff,$ff,$00,$ff,$ff,$00
	db	$ff,$ff,$00,$ff,$7f,$ff,$fe,$01

	org $3000
sinedata
	incbin	"sinedata.dat"	; 2048 Hi bytes and 2048 lo bytes

	org $4000
logodata
	incbin	"logo.dat"
