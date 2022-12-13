
irq_a_pos   = $32
irq_b_pos   = $92
irq_c_pos   = $ea
irq_d_pos   = $ff


    org $0801
bajsic
    db  $0c,$08,$e4,$07,$9e,$20,$32,$30,$36,$34,$00,$00
    org $0810
main
    lda #$06
    sta $d020
    lda #$00
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
    lda #irq_a_pos
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
    lda #irq_b_pos
    sta $d012

    lda #$06
    sta $d020
    lda #$00
    sta $d021

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

    lda #<irq_c
    sta $fffe
    lda #>irq_c
    sta $ffff

    lda #$5b
    sta $d011
    lda #irq_c_pos
    sta $d012

    lda #$0e
    sta $d020
    lda #$0a
    sta $d021

    ldy $fc
    ldx $fb
    lda $fa
    
    rti

irq_c
    sta $fa
    stx $fb
    sty $fc

    lda $d019
    sta $d019

    lda #<irq_d
    sta $fffe
    lda #>irq_d
    sta $ffff

    lda #$5b
    sta $d011
    lda #irq_d_pos
    sta $d012

    lda #$06
    sta $d020
    lda #$0C
    sta $d021

    ldy $fc
    ldx $fb
    lda $fa

    rti

irq_d
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
    lda #irq_a_pos
    sta $d012

    lda #$08
    sta $d020
    lda #$0b
    sta $d021
    jsr music+3
    lda #$05
    sta $d020
    lda #$05
    sta $d021


    ldy $fc
    ldx $fb
    lda $fa

    rti


    org $1000
music
    incbin  "Avenge.dat",2

;Name:            Avenge
;Author:          Thomas Mogensen (DRAX)
;Released:        1992 Vibrants
;Load range:      $1000-$1ED9
;Init address:    $1000
;Play address:    $1003

