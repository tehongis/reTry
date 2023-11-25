
    org $0800
basic:
    db $00,$0b,$08,$e7,$07,$9e,$32,$30,$36,$34,$00,$00

    org $0810
main:

    ; copy char rom to $3000-$3fff
    sei
    lda #$31
    sta $01

    ldx #$00
.charcopyloop
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
    bne .charcopyloop

    lda #$37
    sta $01

    cli

    ; %0xx: Character ROM visible at $D000-$DFFF. (Except for the value %000, see above.)

    lda #$00
    sta $d020
    sta $d021

    lda #$00
    jsr music

    sei

    lda #$7f
    sta $dc0d

    lda #$01
    sta $d01a

    lda #$35
    sta $01

    lda #<irq
    sta $fffe
    lda #>irq
    sta $ffff

    lda #$5b
    sta $d011
    lda #$31
    sta $d012

    lda #$ff
    sta $d015   ;spr on

    lda #$00
    sta $d017   ;spr double height
    sta $d01d   ;spr double width
    sta $d01b   ;spr priority
    sta $d01c   ;spr multicolor

    cli

.dummyloop
    jmp .dummyloop


irq
    sta $fa
    stx $fb
    sty $fc

    lda $d019
    sta $d019

    ldx #$00
.formloop
    lda sprforms,x
    sta $07f8,x
    inx 
    cpx #$08
    bne .formloop

    ldx #$00
.colorloop
    lda sprcolors,x
    sta $d027,x
    inx 
    cpx #$08
    bne .colorloop

    ldx #$00
.posloop
    lda sprlocations,x
    sta $d000,x
    inx 
    cpx #$11
    bne .posloop

    inc $d020
    jsr music+3
    dec $d020


    ldx $fe
    lda sine,x
    sta sprlocations

    ldx $ff
    lda sine,x
    sta sprlocations+1

    inc $fe
    dec $ff

    ldy $fc
    ldx $fb
    lda $fa
    
    rti

sprforms
    db $f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff

sprcolors
    db $01,$01,$01,$01,$01,$01,$01,$01

sprlocations
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00


    org $0f00
sine
    db 0, 25, 50, 74, 98, 120, 141, 161, 180, 197, 212, 225, 236, 244, 250, 253
    db 255, 253, 250, 244, 236, 225, 212, 197, 180, 161, 141, 120, 98, 74, 50, 25
    db 0, 25, 50, 74, 98, 120, 141, 161, 180, 197, 212, 225, 236, 244, 250, 253
    db 255, 253, 250, 244, 236, 225, 212, 197, 180, 161, 141, 120, 98, 74, 50, 25

    org $1000
music:
    incbin "Snickers.dat",2

    end
