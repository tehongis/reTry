


    org $0801
bajsic
    db  $0c,$08,$e4,$07,$9e,$20,$32,$30,$36,$34,$00,$00
    org $0810
main
    lda #$00
    sta $d020
    sta $d021

    sei

    lda #$7f
    sta $dc0d

    lda #$01
    sta $d01a

    lda #$35
    sta $01

    lda #<irq_a
    sta $fffe
    lda #>irq_a
    sta $ffff

    lda #$5b
    sta $d011
    lda #$44
    sta $d012

    cli
    lda #$00
    jsr music

.loop
    jmp .loop
 
    org $0900   

irq_a
    sta $fa
    stx $fb
    sty $fc

    lda $d019
    sta $d019

    lda #<irq_b
    sta $fffe
    lda #>irq_b
    sta $ffff

    lda #$5b
    sta $d011
    lda #$a2
    sta $d012


    inc $d020
    jsr music+3
    dec $d020

    ldy $fc
    ldx $fb
    lda $fa
    
    rti

irq_b
    sta $fa
    stx $fb
    sty $fc

    lda $d019
    sta $d019

    lda #<irq_a
    sta $fffe
    lda #>irq_a
    sta $ffff

    lda #$5b
    sta $d011
    lda #$44
    sta $d012

    dec $d020
    ldx #$90
.bloop
    nop
    nop
    nop    
    dex 
    bne .bloop
    inc $d020

    ldy $fc
    ldx $fb
    lda $fa
    
    rti


    org $1000
music
    incbin  "avenge.dat",2

;Name:            Avenge
;Author:          Thomas Mogensen (DRAX)
;Released:        1992 Vibrants
;Load range:      $1000-$1ED9
;Init address:    $1000
;Play address:    $1003

