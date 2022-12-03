

CHROUT  equ $FFD2

    org $0801
basic
    db  $0c,$08,$e6,$07,$9e,$20,$32,$30,$36,$34,$00,$00 

    org $0810
main



    sei 
    lda #<nmi
    sta $0318
    lda #>nmi
    sta $0319

    lda #$00
    sta $dd0e

    lda #$00
    sta $dd04
    lda #$27
    sta $dd05

    lda #$81
    sta $dd0d
    lda #$01
    sta $dd0e
    cli

    lda #$01
    jsr $0FF6   ;init music


    ldy #$00
    lda #<input
    sta $fe
    lda #>input
    sta $ff

.readloop    
    jsr getinput
    cmp #$00
    beq .endofinput
    cmp #$20
    beq .skip
    cmp #$0a
    bne .notenter
    lda #$0d
.notenter        
    jsr CHROUT
.skip
    jsr nextchar
    jmp .readloop

.endofinput
    rts

getinput
    ldy #$00
    lda ($fe),y
    rts

nextchar
    clc
    lda $fe
    adc #$01
    sta $fe

    lda $ff
    adc #$00
    sta $ff
    rts

nmi
    pha
    txa
    pha
    tya
    pha

    inc $d020
    jsr $1003
    dec $d020

    lda $dd0d

    pla
    tay
    pla
    tax
    pla 

    rti


    org $0FF6
music   ; By Antti Hannula
    incbin "Days_of_Creation.dat",2

    align 8
input
    incbin "2022-day02-input.txt"
    db  $00
