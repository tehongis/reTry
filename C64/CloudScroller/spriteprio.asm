


    org $0801
basic
    byte $0c,$08,$e4,$07,$9e,$20,$32,$30,$36,$34,$00,$00 ;2020 SYS2064

    org $0810
init

    jsr screeninit

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

screeninit
    lda #$0b
    sta $d020

    lda #$0c
    sta $d021

    lda #$20
    ldx #$00
.charinit 
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne .charinit

    lda #$00
    ldx #$00
.colorinit 
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    bne .colorinit

    lda #$a0
    ldx #$00
.blockcharinit 
    sta $0544,x
    sta $0544+$29,x
    inx
    cpx #$20
    bne .blockcharinit

    lda #$01
    ldx #$00
.blockcolorinit 
    sta $d944,x
    inx
    cpx #$20
    bne .blockcolorinit

sprites

    lda #%00000011
    sta $d015

    lda #$a0
    sta $d000
    lda #$6c
    sta $d001
    lda #$b0
    sta $d002
    lda #$6c
    sta $d003
    lda #$00
    sta $d010

    lda #$06
    sta $d027       ;sprite 0 color 
    lda #$07
    sta $d028       ;sprite 1 color

    lda #$ff
    sta $07f8
    sta $07f9

    lda #%00000001      ;priority trick
    sta $d01b

    lda #$00
    sta $d01c       ;multicolor

    lda #$00
    sta $d01d       ;x expand
    lda #$00
    sta $d017       ;y expand

    rts

musicirq 
    sta $fa
    stx $fb
    sty $fc

    jsr music+3

    lda #$01
    sta $d019

    ldy $fc
    ldx $fb
    lda $fa
    rti

retrylogochars
    byte $06,$0e,$03,$01,$03,$0e,$06,$00
retrylogocolors
    byte $06,$0e,$03,$01,$03,$0e,$06,$00

    org $1000
music
    incbin "Crackwhore.dat",2

    org  $3fc0
sprite
    byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff