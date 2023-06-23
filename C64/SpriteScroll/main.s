
    org $0800
basic:
    db $00,$0b,$08,$e7,$07,$9e,$32,$30,$36,$34,$00,$00

    org $0810
main:
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
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

sprcolors
    db $01,$01,$01,$01,$01,$01,$01,$01

sprlocations
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00


    org $0f00
sine
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70
    db $80,$50,$80,$60,$70,$40,$90,$80
    db $80,$50,$80,$60,$70,$40,$90,$70

    org $1000
music:
    incbin "Snickers.dat",2

    org $3fc0
sprite:
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    db $ff,$ff,$ff,$ff,$ff,$ff,$ff

    org $4000
end
