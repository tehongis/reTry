

    org $0400
basic
    db  $00,$0c,$04,$e4,$07,$9e,$20,$31,$30,$34,$30,$00,$00,$00


    org $0410
main
    ldx #$00
    lda #$20
.loop
    sta $8000,x
    sta $8100,x 
    sta $8200,x
    sta $8300,x 
    sta $8400,x
    sta $8500,x 
    sta $8600,x
    sta $8700,x
    inx
    bne .loop

.loop2
    ldx #$00
.kbdloop
    stx $e810
    lda $e812
    sta $8000,x
    inx
    cpx #$10
    bne .kbdloop
    
     lda $e813
    sta $8700,y
    iny

    jmp .loop2

    rts
