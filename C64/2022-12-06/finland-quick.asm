

spriteheight equ 31

    org $0801
basic:
    db  $0c,$08,$e6,$07,$9e,$20,$32,$30,$36,$34,$00,$00

    org $0810
main:   
    lda #$04
    sta $d020
    lda #$06
    sta $d021

    ldx #$00
    lda #$00
.colorloop
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    bne .colorloop

    ldx #$00
    lda #$20
.charloop
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne .charloop



    lda #$60
    sta $d000
    sta $d002
    sta $d004
    sta $d006
    sta $d008
    sta $d00a
    sta $d00c
    sta $d00e

    clc
    lda #$00
    sta $d001
    adc #spriteheight
    sta $d003
    adc #spriteheight
    sta $d005
    adc #spriteheight
    sta $d007
    adc #spriteheight
    sta $d009
    adc #spriteheight
    sta $d00b
    adc #spriteheight
    sta $d00d
    adc #spriteheight
    sta $d00f

    lda #$ff 
    sta $d015
    sta $d017
    sta $d01d

    lda #$06
    sta $d027
    sta $d028
    sta $d029
    sta $d02a
    sta $d02b
    sta $d02c
    sta $d02d
    sta $d02e

    lda #$3f
    sta $07f8
    sta $07f9
    sta $07fa
    sta $07fb
    sta $07fc
    sta $07fd
    sta $07fe
    sta $07ff



    lda #$01
    jsr music

    sei
    lda #$35
    sta $01
    lda #$7f
    sta $dc0d
    lda #$01
    sta $d01a
    lda #<irq
    sta $fffe
    lda #>irq
    sta $ffff
    lda #$70
    sta $d012
    lda #$1b
    sta $d011
    cli
.loop
    jmp .loop

irq

    ldx #$09
.lineend
    dex
    bne .lineend

    lda #$06
    sta $d020
    sta $d021


    lda #$a0
.wait
    cmp $d012
    bne .wait

    ldx #$09
.lineend2
    dex
    bne .lineend2
    nop

    lda #$01
    sta $d020
    sta $d021

    lda #$fa
.wait2
    cmp $d012
    bne .wait2
    lda #$13
    sta $d011

    jsr music+3
    lda #$1b
    sta $d011

    lsr $d019
    rti

    text    "code by Tero Hongisto/reTry. Music by Mikko Paronen(coax)"

    org $0fc0
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff



    org $1000
music
    incbin "Finlandia.dat",2
    