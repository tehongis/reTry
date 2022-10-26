


    org $0801
basic
    byte $0c,$08,$e4,$07,$9e,$20,$32,$30,$36,$34,$00,$00 ;2020 SYS2064

    org $0810
init

    lda #$00
    sta $d020
    sta $d021

    lda #$00
    jsr music

    sei
    lda #$35
    sta $01
    lda #<musicirq
    sta $fffe
    lda #>musicirq
    sta $ffff
    lda #$7f
    sta $dc0d
    lda #$01
    sta $d01a
    lda #$18
    sta $d011
    lda #$00
    sta $d012
    cli
.loop
    jmp .loop

musicirq 
    sta $fa
    stx $fb
    sty $fc

    jsr music+3

    lda colors
    sta $d021

    lda #$01
    sta $d019

    lda #<fxirq01
    sta $fffe
    lda #>fxirq01
    sta $ffff
    lda $ff
    and #$07
    ora #$18
    sta $d011
    clc
    lda $ff
    adc #$20
    sta $d012

    lda waves
    sta $d016

    lda $ff
    and #$07
    cmp #$07
    bne .noscroll2
    ldx #$00
.chaloop2
    lda $0428+$28*4,x
    sta $0400+$28*4,x
    lda $0428+$28*4+$14,x
    sta $0400+$28*4+$14,x
    lda $0428+$28*5,x
    sta $0400+$28*5,x
    lda $0428+$28*5+$14,x
    sta $0400+$28*5+$14,x
    lda $0428+$28*6,x
    sta $0400+$28*6,x
    lda $0428+$28*6+$14,x
    sta $0400+$28*6+$14,x
    lda $0428+$28*7,x
    sta $0400+$28*7,x
    lda $0428+$28*7+$14,x
    sta $0400+$28*7+$14,x
    inx
    cpx #$14
    bne .chaloop2
.noscroll2


    ldy $fc
    ldx $fb
    lda $fa
    rti

fxirq01
    sta $fa
    stx $fb
    sty $fc

    lda colors+1
    sta $d021

    lda #$01
    sta $d019

    lda #<fxirq02
    sta $fffe
    lda #>fxirq02
    sta $ffff
    lda $ff
    and #$07
    ora #$18
    sta $d011
    clc
    lda $ff
    adc #$40
    sta $d012

    lda waves+1
    sta $d016

    lda $ff
    and #$07
    cmp #$07
    bne .noscroll
    ldx #$00
.chaloop
    lda $0428+$28*8,x
    sta $0400+$28*8,x
    lda $0428+$28*8+$14,x
    sta $0400+$28*8+$14,x
    lda $0428+$28*9,x
    sta $0400+$28*9,x
    lda $0428+$28*9+$14,x
    sta $0400+$28*9+$14,x
    lda $0428+$28*10,x
    sta $0400+$28*10,x
    lda $0428+$28*10+$14,x
    sta $0400+$28*10+$14,x
    lda $0428+$28*11,x
    sta $0400+$28*11,x
    lda $0428+$28*11+$14,x
    sta $0400+$28*11+$14,x
    inx
    cpx #$14
    bne .chaloop
.noscroll


    ldy $fc
    ldx $fb
    lda $fa
    rti

fxirq02
    sta $fa
    stx $fb
    sty $fc

    lda colors+2
    sta $d021

    lda #$01
    sta $d019

    lda #<fxirq03
    sta $fffe
    lda #>fxirq03
    sta $ffff
    lda $ff
    and #$07
    ora #$18
    sta $d011
    clc
    lda $ff
    adc #$60
    sta $d012

    lda waves+2
    sta $d016

    lda $ff
    and #$07
    cmp #$07
    bne .noscroll
    ldx #$00
.chaloop
    lda $0428+$28*12,x
    sta $0400+$28*12,x
    lda $0428+$28*12+$14,x
    sta $0400+$28*12+$14,x
    lda $0428+$28*13,x
    sta $0400+$28*13,x
    lda $0428+$28*13+$14,x
    sta $0400+$28*13+$14,x
    lda $0428+$28*14,x
    sta $0400+$28*14,x
    lda $0428+$28*14+$14,x
    sta $0400+$28*14+$14,x
    lda $0428+$28*15,x
    sta $0400+$28*15,x
    lda $0428+$28*15+$14,x
    sta $0400+$28*15+$14,x
    inx
    cpx #$14
    bne .chaloop
.noscroll

    ldy $fc
    ldx $fb
    lda $fa
    rti

fxirq03
    sta $fa
    stx $fb
    sty $fc

    lda colors+3
    sta $d021

    lda #$01
    sta $d019

    lda #<fxirq04
    sta $fffe
    lda #>fxirq04
    sta $ffff
    lda $ff
    and #$07
    ora #$18
    sta $d011
    clc
    lda $ff
    adc #$80
    sta $d012

    lda waves+3
    sta $d016

    lda $ff
    and #$07
    cmp #$07
    bne .noscroll
    ldx #$00
.chaloop
    lda $0428+$28*15,x
    sta $0400+$28*15,x
    lda $0428+$28*15+$14,x
    sta $0400+$28*15+$14,x
    lda $0428+$28*16,x
    sta $0400+$28*16,x
    lda $0428+$28*16+$14,x
    sta $0400+$28*16+$14,x
    lda $0428+$28*17,x
    sta $0400+$28*17,x
    lda $0428+$28*17+$14,x
    sta $0400+$28*17+$14,x
    lda $0428+$28*18,x
    sta $0400+$28*18,x
    lda $0428+$28*18+$14,x
    sta $0400+$28*18+$14,x
    inx
    cpx #$14
    bne .chaloop
.noscroll

    ldy $fc
    ldx $fb
    lda $fa
    rti

fxirq04
    sta $fa
    stx $fb
    sty $fc

    lda colors+4
    sta $d021

    lda #$01
    sta $d019

    lda #<fxirq05
    sta $fffe
    lda #>fxirq05
    sta $ffff
    lda $ff
    and #$07
    ora #$18
    sta $d011
    clc
    lda $ff
    adc #$a0
    sta $d012

    lda waves+4
    sta $d016

    lda $ff
    and #$07
    cmp #$07
    bne .noscroll
    ldx #$00
.chaloop
    lda $0428+$28*18,x
    sta $0400+$28*18,x
    lda $0428+$28*18+$14,x
    sta $0400+$28*18+$14,x
    lda $0428+$28*19,x
    sta $0400+$28*19,x
    lda $0428+$28*19+$14,x
    sta $0400+$28*19+$14,x
    lda $0428+$28*20,x
    sta $0400+$28*20,x
    lda $0428+$28*20+$14,x
    sta $0400+$28*20+$14,x
    lda $0428+$28*21,x
    sta $0400+$28*21,x
    lda $0428+$28*21+$14,x
    sta $0400+$28*21+$14,x
    inx
    cpx #$14
    bne .chaloop
.noscroll

    ldy $fc
    ldx $fb
    lda $fa
    rti

fxirq05
    sta $fa
    stx $fb
    sty $fc

    lda colors+5
    sta $d021

    lda #$01
    sta $d019

    lda #<fxirq06
    sta $fffe
    lda #>fxirq06
    sta $ffff
    lda $ff
    and #$07
    ora #$18
    sta $d011
    clc
    lda $ff
    adc #$c0
    sta $d012

    lda waves+5
    sta $d016

    lda $ff
    and #$07
    cmp #$07
    bne .noscroll
    ldx #$00
.chaloop
    lda $0428+$28*22,x
    sta $0400+$28*22,x
    lda $0428+$28*22+$14,x
    sta $0400+$28*22+$14,x
    lda $0428+$28*23,x
    sta $0400+$28*23,x
    lda $0428+$28*23+$14,x
    sta $0400+$28*23+$14,x
    lda $0428+$28*24,x
    sta $0400+$28*24,x
    lda $0428+$28*24+$14,x
    sta $0400+$28*24+$14,x
    inx
    cpx #$14
    bne .chaloop
.noscroll

    ldy $fc
    ldx $fb
    lda $fa
    rti

fxirq06
    sta $fa
    stx $fb
    sty $fc

    lda colors+6
    sta $d021

    lda #$01
    sta $d019

    lda #<fxirq07
    sta $fffe
    lda #>fxirq07
    sta $ffff
    lda $ff
    and #$07
    ora #$18
    sta $d011
    clc
    lda $ff
    adc #$e0
    sta $d012

    lda waves+6
    sta $d016

    lda $ff
    and #$07
    cmp #$00
    bne .noscroll
    ldx #$00
.chaloop
    lda $0428+$28*0,x
    sta $0400+$28*0,x
    lda $0428+$28*0+$14,x
    sta $0400+$28*0+$14,x
    lda $0428+$28*1,x
    sta $0400+$28*1,x
    lda $0428+$28*1+$14,x
    sta $0400+$28*1+$14,x
    lda $0428+$28*2,x
    sta $0400+$28*2,x
    lda $0428+$28*2+$14,x
    sta $0400+$28*2+$14,x
    lda $0428+$28*3,x
    sta $0400+$28*3,x
    lda $0428+$28*3+$14,x
    sta $0400+$28*3+$14,x
    inx
    cpx #$14
    bne .chaloop
.noscroll

    ldy $fc
    ldx $fb
    lda $fa
    rti

fxirq07
    sta $fa
    stx $fb
    sty $fc

    lda colors+7
    sta $d021

    lda #$01
    sta $d019

    lda #<musicirq
    sta $fffe
    lda #>musicirq
    sta $ffff
    lda $ff
    and #$07
    ora #$18
    sta $d011
    lda #$00
    sta $d012

    lda waves+7
    sta $d016

    dec $ff
    lda $ff
    and #$1f
    sta $ff
    cmp #$1f
    bne .notmax

    ldx #$00
.cololoop
    lda colors+1,x
    sta colors,x
    inx
    cpx #$07
    bne .cololoop


    lda $fe
    and #$1f
    tax
    lda colorarray,x
    sta colors+7
    inc $fe



.notmax

    lda waves+7
    sta waves+8
    lda waves+6
    sta waves+7
    lda waves+5
    sta waves+6
    lda waves+4
    sta waves+5
    lda waves+3
    sta waves+4
    lda waves+2
    sta waves+3
    lda waves+1
    sta waves+2
    lda waves+0
    sta waves+1

    lda $ff
    and #$1f
    tax
    lda wavearray,x
    sta waves


    lda $ff
    and #$07
    cmp #$07
    bne .nochars

    lda $ff
    ldx #$00
.lineloop    
    sta $0400+$28*25,x
    inx
    cpx #$28
    bne .lineloop

.nochars

    ldy $fc
    ldx $fb
    lda $fa
    rti

colors
    byte $00,$00,$00,$00,$00,$00,$00,$00
waves
    byte $c8,$c8,$c8,$c8,$c8,$c8,$c8,$c8

wavearray
    byte $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7
    byte $c7,$c6,$c5,$c4,$c3,$c2,$c1,$c0
    byte $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7
    byte $c7,$c6,$c5,$c4,$c3,$c2,$c1,$c0

colorarray
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
    byte $06,$0e,$03,$01,$03,$0e,$06,$00

    org $1000
music
    incbin "Crackwhore.dat",2
