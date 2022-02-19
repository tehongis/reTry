

    org $0801
basic
    db $0c,$08,$e6,$07,$9e,$20,$32,$30,$36,$34,$00,$00 

init
    org $0810

    lda #$0c
    sta $d020
    lda #$0b
    sta $d021

    lda #$1e
    sta $d018

    lda #$00
    ldx #$00
.colinitloop
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    bne .colinitloop

    lda #$20
    ldx #$00
.chrinitloop
    txa
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne .chrinitloop

    lda #$00
    jsr music

    sei

    lda #$33    ;Charrom visible
    sta $01
    ldx #$00
.romcopyloop    
    lda $d000,x
    sta $3800,x
    lda $d100,x
    sta $3900,x
    lda $d200,x
    sta $3a00,x
    lda $d300,x
    sta $3b00,x
    lda $d400,x
    sta $3c00,x
    lda $d500,x
    sta $3d00,x
    lda $d600,x
    sta $3e00,x
    lda $d700,x
    sta $3f00,x
    inx
    bne .romcopyloop

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

    lda #$30
    sta $d012
    lda #$1b
    sta $d011

    lda $dc0d

    cli

.initloop
    jmp .initloop

irq
    pha
    txa
    pha
    tya
    pha

    lda $d019
    sta $d019

    inc $d020
    jsr music+3
    dec $d020


    lda $3800
    tay
    ldx #$00
.chrscrollu    
    lda $3801,x
    sta $3800,x
    inx 
    cpx #$07
    bne .chrscrollu
    tya
    sta $3807

    pla
    tay
    pla
    tax
    pla

    rti

    org $1000
music

    incbin "Pulse.dat",2
