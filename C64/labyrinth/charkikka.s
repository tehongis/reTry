

    org $0801
basic:
    db $0b,$08,$e6,$07,$9e,$32,$30,$36,$34,$00,$00


    org $0810
init
    lda #$0e
    sta $d020
    lda #$06
    sta $d021

    lda #$00
    jsr music

    sei

    lda #$35
    sta $01

    lda #$7f
    sta $dc0d


    lda $dc0d
    lda $dd0d

    lda #$f8
    sta $d012
    lda #$10
    sta $d011

    lda #<irq
    sta $fffe
    lda #>irq
    sta $ffff

    lda #$01
    sta $d01a

    cli


  
.loop  
    jmp .loop


irq 

    lda $ff
    and #$07
    ora #$10
    sta $d011
    dec $ff
    and #$07
    cmp #$07
    bne .noscreenup
    jsr screenup
    jsr newcharline

.noscreenup
    jsr music+3

    asl $d019  
    rti

screenup
    ldx #$00
.toploop
    lda $0428+($28*0),x
    sta $0400+($28*0),x
    lda $0428+($28*1),x
    sta $0400+($28*1),x
    lda $0428+($28*2),x
    sta $0400+($28*2),x
    lda $0428+($28*3),x
    sta $0400+($28*3),x
    lda $0428+($28*4),x
    sta $0400+($28*4),x
    lda $0428+($28*5),x
    sta $0400+($28*5),x
    lda $0428+($28*6),x
    sta $0400+($28*6),x
    lda $0428+($28*7),x
    sta $0400+($28*7),x
    lda $0428+($28*8),x
    sta $0400+($28*8),x
    lda $0428+($28*9),x
    sta $0400+($28*9),x
    inx 
    cpx #$28
    bne .toploop

    ldx #$00
.bottomloop
    lda $0428+($28*10),x
    sta $0400+($28*10),x
    lda $0428+($28*11),x
    sta $0400+($28*11),x
    lda $0428+($28*12),x
    sta $0400+($28*12),x
    lda $0428+($28*13),x
    sta $0400+($28*13),x
    lda $0428+($28*14),x
    sta $0400+($28*14),x
    lda $0428+($28*15),x
    sta $0400+($28*15),x
    lda $0428+($28*16),x
    sta $0400+($28*16),x
    lda $0428+($28*17),x
    sta $0400+($28*17),x
    lda $0428+($28*18),x
    sta $0400+($28*18),x
    lda $0428+($28*19),x
    sta $0400+($28*19),x
    lda $0428+($28*20),x
    sta $0400+($28*20),x
    lda $0428+($28*21),x
    sta $0400+($28*21),x
    lda $0428+($28*22),x
    sta $0400+($28*22),x
    lda $0428+($28*23),x
    sta $0400+($28*23),x
    inx 
    cpx #$28
    bne .bottomloop

    rts

newcharline
    ldx #$00
.lineloop
    lda $d41b
    ror
    ror
    adc $fe
    rol
    adc $d41c
    rol
    rol
    and #1
    tay
    lda charmap,y
    sta $0400+($28*24),x
    inc $fe
    inx 
    cpx #$28
    bne .lineloop
    rts


charmap
    db $4d,$4e,$40,$42
    db $4c,$4f,$50,$7a

    org $1000
music
    incbin "Raccoon.dat",2