



    org $0801
basic:
    ; 2022 SYS2064
    db  $0b, $08, $e6, $07, $9e, $32, $30, $36, $34, $00, $00
     
    org $0810
init:
    ldx #$00
.charloop
    lda #$01
    sta $0400,x
    sta $0480,x
    sta $0500,x
    sta $0580,x
    sta $0600,x
    sta $0680,x
    sta $0700,x
    sta $0780,x
    inx
    cpx #$80
    bne .charloop

    ldx #$00
    lda #$00
.colorloop
    sta $d800,x
    sta $d840,x
    sta $d880,x
    sta $d8c0,x
    sta $d900,x
    sta $d940,x
    sta $d980,x
    sta $d9c0,x
    sta $da00,x
    sta $da40,x
    sta $da80,x
    sta $dac0,x
    sta $db00,x
    sta $db40,x
    sta $db80,x
    sta $dbc0,x
    inx
    cpx #$40
    bne .colorloop

; sprites

    lda #$ff
    sta $d015

    lda #$01
    ldx #$00
.spritecolloop    
    sta $d027,x
    inx
    cpx #$08
    bne .spritecolloop

; music

    lda #$00
    jsr music

; irq setup

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

    lda #$cf
    sta $d012
    lda #$1b
    sta $d011
    cli

    lda #$10
    sta $fd
    lda #$20
    sta $fe
    lda #$30
    sta $ff

.idleloop
    jmp .idleloop


irq:
    lda #$d8
    sta $d016
    lda #$18
    sta $d011

    inc $d020

    ldx #$00
.moveleft
    lda $0401+$28*0,x
    sta $0400+$28*0,x
    lda $0401+$28*1,x
    sta $0400+$28*1,x
    lda $0401+$28*2,x
    sta $0400+$28*2,x
    lda $0401+$28*3,x
    sta $0400+$28*3,x
    lda $0401+$28*4,x
    sta $0400+$28*4,x
    lda $0401+$28*5,x
    sta $0400+$28*5,x
    lda $0401+$28*6,x
    sta $0400+$28*6,x
    lda $0401+$28*7,x
    sta $0400+$28*7,x
    lda $0401+$28*8,x
    sta $0400+$28*8,x
    lda $0401+$28*9,x
    sta $0400+$28*9,x
    lda $0401+$28*10,x
    sta $0400+$28*10,x
    lda $0401+$28*11,x
    sta $0400+$28*11,x
    lda $0401+$28*12,x
    sta $0400+$28*12,x
    lda $0401+$28*13,x
    sta $0400+$28*13,x
    lda $0401+$28*14,x
    sta $0400+$28*14,x
    lda $0401+$28*15,x
    sta $0400+$28*15,x
    lda $0401+$28*16,x
    sta $0400+$28*16,x
    lda $0401+$28*17,x
    sta $0400+$28*17,x
    lda $0401+$28*18,x
    sta $0400+$28*18,x
    lda $0401+$28*19,x
    sta $0400+$28*19,x
    inx
    cpx #$27
    bne .moveleft

    lda $ff
    sta $0427+$28*0
    sta $0427+$28*1
    sta $0427+$28*2
    sta $0427+$28*3
    sta $0427+$28*4
    sta $0427+$28*5
    sta $0427+$28*6
    sta $0427+$28*7
    sta $0427+$28*8
    sta $0427+$28*9
    sta $0427+$28*10
    sta $0427+$28*11
    sta $0427+$28*12
    sta $0427+$28*13
    sta $0427+$28*14
    sta $0427+$28*15
    sta $0427+$28*16
    sta $0427+$28*17
    sta $0427+$28*18
    sta $0427+$28*19

    inc $ff

    inc $d020

    jsr spriteupdate


    lda #$18
    sta $d011

    lda $ff
    and #$07
    ora #$d0
    sta $d016

    inc $d020
    jsr music+3
    inc $d020

    lda #$0b
    sta $d020
    lda #$0c
    sta $d021

    lda #$01
    sta $d019
    rti

spriteupdate
    lda $ff
    ldx #$00
.spriteaniloop    
    adc #$01
    and #$07
    ora #$e0
    sta $07f8,x
    inx 
    cpx #$08
    bne .spriteaniloop

    ldx #$00
.spritelocloop
    lda spritelocations,x
    sta $d000,x
    inx
    cpx #$11
    bne .spritelocloop

    ldx #$00
    ldy $fe
.sinelocXs 
    lda sinewave,y
    adc #$2c
    ror $d010
    sta spritelocations,x
    pha
    tya
    adc #$08
    tay
    pla
    inx
    inx
    cpx #$10
    bne .sinelocXs

    ldx #$00
    ldy $fd
.sinelocYs 
    lda sinewave,y
    lsr
    adc #$38
    sta spritelocations+1,x
    pha
    tya
    adc #$8
    tay
    pla
    inx
    inx
    cpx #$10
    bne .sinelocYs

    inc $fe
    inc $fd
    inc $fd

    rts


spritelocations
    db  $00,$00,$00,$00,$00,$00,$00,$00
    db  $00,$00,$00,$00,$00,$00,$00,$00
    db  $00


linelocations
    db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
    db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f

linecolors
    db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
    db $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f

sinewave
    db  $80,$83,$86,$89,$8c,$8f,$92,$95,$99,$9c,$9f,$a2,$a5,$a8,$ab,$ae
    db  $b1,$b4,$b6,$b9,$bc,$bf,$c2,$c4,$c7,$c9,$cc,$cf,$d1,$d3,$d6,$d8
    db  $da,$dc,$df,$e1,$e3,$e5,$e7,$e8,$ea,$ec,$ee,$ef,$f1,$f2,$f3,$f5
    db  $f6,$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fd,$fe,$fe,$ff,$ff,$ff,$ff,$ff
    db  $ff,$ff,$ff,$ff,$ff,$fe,$fe,$fd,$fd,$fc,$fb,$fb,$fa,$f9,$f8,$f7
    db  $f5,$f4,$f3,$f1,$f0,$ee,$ed,$eb,$e9,$e8,$e6,$e4,$e2,$e0,$de,$db
    db  $d9,$d7,$d5,$d2,$d0,$cd,$cb,$c8,$c6,$c3,$c0,$bd,$bb,$b8,$b5,$b2
    db  $af,$ac,$a9,$a6,$a3,$a0,$9d,$9a,$97,$94,$91,$8e,$8b,$87,$84,$81
    db  $7e,$7b,$78,$74,$71,$6e,$6b,$68,$65,$62,$5f,$5c,$59,$56,$53,$50
    db  $4d,$4a,$47,$44,$42,$3f,$3c,$39,$37,$34,$32,$2f,$2d,$2a,$28,$26
    db  $24,$21,$1f,$1d,$1b,$19,$17,$16,$14,$12,$11,$0f,$0e,$0c,$0b,$0a
    db  $08,$07,$06,$05,$04,$04,$03,$02,$02,$01,$01,$00,$00,$00,$00,$00
    db  $00,$00,$00,$00,$00,$01,$01,$02,$02,$03,$04,$05,$06,$07,$08,$09
    db  $0a,$0c,$0d,$0e,$10,$11,$13,$15,$17,$18,$1a,$1c,$1e,$20,$23,$25
    db  $27,$29,$2c,$2e,$30,$33,$36,$38,$3b,$3d,$40,$43,$46,$49,$4b,$4e
    db  $51,$54,$57,$5a,$5d,$60,$63,$66,$6a,$6d,$70,$73,$76,$79,$7c,$7f

colorwave
    db $00,$0b,$00,$0b,$0b,$0c,$0b,$0c,$0c,$0f,$0c,$0f,$0f,$01,$0f,$01
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

    db $01,$0f,$01,$0f,$0f,$0c,$0f,$0c,$0c,$0b,$0c,$0b,$0b,$00,$0b,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

    db $00,$0b,$00,$0b,$0b,$0c,$0b,$0c,$0c,$0f,$0c,$0f,$0f,$01,$0f,$01
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

    db $01,$0f,$01,$0f,$0f,$0c,$0f,$0c,$0c,$0b,$0c,$0b,$0b,$00,$0b,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00



logo
    text "ramalamadingdong 2022"



	org $1000
music
	incbin "Fungus.dat",2


    org $3800

sprite_0:
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$0e
	db	$00,$00,$0f,$80,$00,$1f,$e0,$00
	db	$1f,$f8,$00,$0f,$fe,$00,$03,$ff
	db	$80,$00,$ff,$e0,$00,$3f,$f8,$00
	db	$0f,$fc,$00,$03,$fc,$00,$00,$f8
	db	$00,$00,$38,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00

sprite_1:
	db	$00,$00,$00,$00,$00,$00,$03,$00
	db	$00,$07,$80,$00,$0f,$c0,$00,$0f
	db	$e0,$00,$07,$f0,$00,$03,$f8,$00
	db	$01,$fc,$00,$00,$fe,$00,$00,$7f
	db	$00,$00,$3f,$80,$00,$1f,$c0,$00
	db	$0f,$e0,$00,$07,$f0,$00,$03,$f8
	db	$00,$01,$f8,$00,$00,$f0,$00,$00
	db	$60,$00,$00,$00,$00,$00,$00,$00

sprite_2:
	db	$00,$00,$00,$00,$00,$00,$00,$e0
	db	$00,$03,$e0,$00,$01,$f0,$00,$01
	db	$f0,$00,$00,$f8,$00,$00,$f8,$00
	db	$00,$7c,$00,$00,$7c,$00,$00,$3e
	db	$00,$00,$3e,$00,$00,$1f,$00,$00
	db	$1f,$00,$00,$0f,$80,$00,$0f,$80
	db	$00,$07,$c0,$00,$07,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00

sprite_3:
	db	$00,$00,$00,$00,$00,$00,$00,$3c
	db	$00,$00,$3c,$00,$00,$3c,$00,$00
	db	$3c,$00,$00,$3c,$00,$00,$3c,$00
	db	$00,$3c,$00,$00,$3c,$00,$00,$3c
	db	$00,$00,$3c,$00,$00,$3c,$00,$00
	db	$3c,$00,$00,$3c,$00,$00,$3c,$00
	db	$00,$3c,$00,$00,$3c,$00,$00,$3c
	db	$00,$00,$00,$00,$00,$00,$00,$00

sprite_4:
	db	$00,$00,$00,$00,$00,$00,$00,$07
	db	$00,$00,$07,$c0,$00,$0f,$80,$00
	db	$0f,$80,$00,$1f,$00,$00,$1f,$00
	db	$00,$3e,$00,$00,$3e,$00,$00,$7c
	db	$00,$00,$7c,$00,$00,$f8,$00,$00
	db	$f8,$00,$01,$f0,$00,$01,$f0,$00
	db	$03,$e0,$00,$00,$e0,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00

sprite_5:
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$c0,$00,$01,$e0,$00,$03,$f0,$00
	db	$07,$f0,$00,$0f,$e0,$00,$1f,$c0
	db	$00,$3f,$80,$00,$7f,$00,$00,$fe
	db	$00,$01,$fc,$00,$03,$f8,$00,$07
	db	$f0,$00,$0f,$e0,$00,$1f,$c0,$00
	db	$1f,$80,$00,$0f,$00,$00,$06,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00

sprite_6:
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$70,$00,$01,$f0,$00,$07,$f8
	db	$00,$1f,$f8,$00,$7f,$f0,$01,$ff
	db	$c0,$07,$ff,$00,$1f,$fc,$00,$3f
	db	$f0,$00,$3f,$c0,$00,$1f,$00,$00
	db	$1c,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00

sprite_7
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$1f,$ff,$f8,$1f,$ff,$f8,$1f,$ff
	db	$f8,$1f,$ff,$f8,$1f,$ff,$f8,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00
	db	$00,$00,$00,$00,$00,$00,$00,$00

