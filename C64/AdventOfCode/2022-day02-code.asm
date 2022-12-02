

CHROUT  equ $FFD2

    org $0801
basic:
    db  $0c,$08,$e6,$07,$9e,$20,$32,$30,$36,$34,$00,$00 

    org $0810

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

    align 8
input
    incbin "2022-day02-input.txt"
    db  $00
