
; The tunnel effect is accomplished by using 3 arrays, each the size of the screen.
; The first array contains the distance from that pixel to the center of the screen, 
; scaled and modulated by the height of the texture. 
; The second array contains the angle from that pixel to the center of the screen. 
; The third array contains a clamped distance from the center of the screen.
; These arrays are calculated only once.
; Then they are used to calculate the coordinates of the texture. 
; The first array determines the x coordinate of the texture. 
; The second array determines the y coordinate. 
; The third array determines how to darken the texture so that the center of the tunnel is blackened.
; Finally, to pan the center of the tunnel around, 
; we actually make the arrays twice the screen size and simply pan around the arrays.

colorptr equ $fa

    org $0801
basic
    db $0c,$08,$e6,$07,$9e,$20,$32,$30,$36,$34,$00,$00 

    org $0810
init

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

    lda #$a0
    ldx #$00
.chrinitloop
    ;txa
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

    lda #$0fc
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


    ldx #$00
.colarrloop
    lda colorarray,x
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    cpx #40*4
    bne .colarrloop

    inc $d020

    ldx #$00
.colrollloop
    lda colorarray+1,x
    sta colorarray,x
    inx
    cpx #40*4
    bne .colrollloop

    lda colorptr
    clc
    adc #$01
    and #$7f
    sta colorptr
    tax
    lda colormap,x
    sta colorarray+((40*4) -1)

    inc $d020
    
.scrollu
    ldy $3800
    lda $3801
    sta $3800
    lda $3802
    sta $3801
    lda $3803
    sta $3802
    lda $3804
    sta $3803
    lda $3805
    sta $3804
    lda $3806
    sta $3805
    lda $3807
    sta $3806
    sty $3807

.scrolld
    ldy $3817
    lda $3816
    sta $3817
    lda $3815
    sta $3816
    lda $3814
    sta $3815
    lda $3813
    sta $3814
    lda $3812
    sta $3813
    lda $3811
    sta $3812
    lda $3810
    sta $3811
    sty $3810

    inc $d020
    jsr music+3
    lda #$0c
    sta $d020

    pla
    tay
    pla
    tax
    pla

    rti

colormap
    db $00,$06,$00,$06,$06,$0e,$06,$0e
    db $0e,$03,$0e,$03,$03,$01,$03,$01
    db $01,$03,$01,$03,$03,$0e,$03,$0e
    db $0e,$06,$0e,$06,$06,$00,$06,$00

    db $00,$0b,$00,$0b,$0b,$05,$0b,$05
    db $05,$0d,$05,$0d,$0d,$01,$0d,$01
    db $01,$0d,$01,$0d,$0d,$05,$0d,$05
    db $05,$0b,$05,$0b,$0b,$00,$0b,$00

    db $00,$02,$00,$02,$02,$0a,$02,$0a
    db $0a,$07,$0a,$07,$07,$01,$07,$01
    db $01,$07,$01,$07,$07,$0a,$07,$0a
    db $0a,$02,$0a,$02,$02,$00,$02,$00

    db $00,$0b,$00,$0b,$0b,$0c,$0b,$0c
    db $0c,$0f,$0c,$0f,$0f,$01,$0f,$01
    db $01,$0f,$01,$0f,$0f,$0c,$0f,$0c
    db $0c,$0b,$0c,$0b,$0b,$00,$0b,$00

    org $0f00
colorarray
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00

    org $1000
music
    incbin "Pulse.dat",2
