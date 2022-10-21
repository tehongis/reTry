

    org $0801
basic
    db $0b,$08,$e6,$07,$9e,$32,$30,$36,$34,$00,$00

    org $0810
main

reverse_chars
    ldx #$00
.lower2upper

    lda $0400,x
    eor #$80
    sta $0400,x
.noupper4
    lda $0500,x
    eor #$80
    sta $0500,x
.noupper5

    lda $0600,x
    eor #$80
    sta $0600,x
.noupper6

    lda $0700,x
    eor #$80
    sta $0700,x
.noupper7
    inx
    bne .lower2upper

    lda #$06
    ldx #$00
.coliniloop
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    bne .coliniloop

set_colors    
    lda #$0e
    sta $d020
    lda #$0e
    sta $d021

music_init
    lda #$01
    sta music


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
    cli

.mainidleloop
    jmp .mainidleloop

irq
    inc $d020
    jsr music+3
    dec $d020

    jsr copycolors

    asl $d019
    rti

copycolors
    ldx #$00
.copyloop    
    lda colorfont+8*0,x
    sta $d800+$28*0,x
    lda colorfont+8*1,x
    sta $d800+$28*1,x
    lda colorfont+8*2,x
    sta $d800+$28*2,x
    lda colorfont+8*3,x
    sta $d800+$28*3,x
    lda colorfont+8*4,x
    sta $d800+$28*4,x
    lda colorfont+8*5,x
    sta $d800+$28*5,x
    lda colorfont+8*6,x
    sta $d800+$28*6,x
    lda colorfont+8*7,x
    sta $d800+$28*7,x
    inx
    cpx #$08
    bne .copyloop
    rts

    org $1000
music
    incbin Avenge.dat,2

colorfont
    db  $00,$00,$00,$00,$00,$00,$00,$00
    db  $00,$00,$01,$0f,$0c,$0b,$00,$00
    db  $00,$01,$0f,$00,$00,$0c,$0b,$00
    db  $00,$01,$0f,$00,$00,$0c,$0b,$00
    db  $00,$01,$0f,$0f,$0c,$0c,$0b,$00
    db  $00,$01,$0f,$00,$00,$0c,$0b,$00
    db  $00,$01,$0f,$00,$00,$0c,$0b,$00
    db  $00,$00,$00,$00,$00,$00,$00,$00
