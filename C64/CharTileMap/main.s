

    org $0801
basic:
    db  $0c,$08,$e6,$07,$9e,$20,$32,$30,$36,$34,$00,$00

    org $0810
main:
    ldx #$00
    lda #$00
    clc
.screenloop
    txa
    and #$03
    tay
    lda model,y
    sta $0400+0*$28,x
    sta $0400+4*$28,x
    sta $0400+8*$28,x
    sta $0400+12*$28,x
    sta $0400+16*$28,x
    sta $0400+20*$28,x
    adc #$01
    sta $0400+1*$28,x
    sta $0400+5*$28,x
    sta $0400+9*$28,x
    sta $0400+13*$28,x
    sta $0400+17*$28,x
    sta $0400+21*$28,x
    adc #$01
    sta $0400+2*$28,x
    sta $0400+6*$28,x
    sta $0400+10*$28,x
    sta $0400+14*$28,x
    sta $0400+18*$28,x
    sta $0400+22*$28,x
    adc #$01
    sta $0400+3*$28,x
    sta $0400+7*$28,x
    sta $0400+11*$28,x
    sta $0400+15*$28,x
    sta $0400+19*$28,x
    sta $0400+23*$28,x
    inx
    cpx #$28
    bne .screenloop

    ldx #$00
    lda #$00
.colorloop
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    bne .colorloop

    ; clean charmap
    ldx #$00
.fontloop
    lda #$00
    sta $3800,x
    sta $3900,x
    inx
    bne .fontloop


    sei
    lda #$35
    sta $01
    lda #<irq
    sta $fffe
    lda #>irq
    sta $ffff
    cli

    lda #$7f
    sta $dc0d
    lda #$01
    sta $d01a

    lda #$30
    sta $d012
    lda #$1b
    sta $d011

    lda #$0c
    sta $d020
    lda #$0b
    sta $d021

    lda #$1f
    sta $d018

noexitloop
    jmp noexitloop

plot
    ; y working
    ; x needs more logic.
    and #$1f
    tay
    lda $3800,y
    eor #$ff
    sta $3800,y
    rts

irq

    dec $d020

    lda $ff
    jsr plot
    inc $ff

    inc $d020

    rol $d019
    rti

model
    db $00,$04,$08,$0c