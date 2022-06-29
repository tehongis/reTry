
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

    ldx #$00
.chrinitloop
    lda screen,x
    sta $0400,x
    lda screen+256,x
    sta $0500,x
    lda screen+256*2,x
    sta $0600,x
    lda screen+256*3,x
    sta $0700,x
    inx
    bne .chrinitloop

    lda #$00
    jsr music

    sei

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

    lda #$0fb
    sta $d012
    lda #$1b
    sta $d011

    lda $dc0d

    cli

.initloop
    jmp .initloop

copycharrom
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

    rts

irq
    pha
    txa
    pha
    tya
    pha

    lda $d019
    sta $d019


    dec $d020
    jsr scrollfont
    inc $d020

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


;-----

scrollfont
    ldx #$00

.fontloop
    lda $3808,x
    tay
    sta $3800,x

    lda $3810,x
    sta $3808,x

    lda $3818,x
    sta $3810,x

    lda $3820,x
    sta $3818,x

    lda $3828,x
    sta $3820,x

    lda $3830,x
    sta $3828,x

    lda $3838,x
    sta $3830,x

    lda $3840,x
    sta $3838,x

    lda $3848,x
    sta $3840,x

    lda $3850,x
    sta $3848,x

    lda $3858,x
    sta $3850,x

    lda $3860,x
    sta $3858,x

    lda $3868,x
    sta $3860,x

    lda $3870,x
    sta $3868,x

    lda $3878,x
    sta $3870,x

    lda $3880,x
    sta $3878,x

    lda $3888,x
    sta $3880,x

    lda $3890,x
    sta $3888,x

    lda $3898,x
    sta $3890,x

    lda $38a0,x
    sta $3898,x

    lda $38a8,x
    sta $38a0,x

    lda $38b0,x
    sta $38a8,x

    lda $38b8,x
    sta $38b0,x

    lda $38c0,x
    sta $38b8,x

    lda $38c8,x
    sta $38c0,x

    lda $38d0,x
    sta $38c8,x

    lda $38d8,x
    sta $38d0,x

    lda $38e0,x
    sta $38d8,x

    lda $38e8,x
    sta $38e0,x

    lda $38f0,x
    sta $38e8,x

    lda $38f8,x
    sta $38f0,x

    lda $3900,x
    sta $38f8,x

    lda $3908,x
    sta $3900,x

    lda $3910,x
    sta $3908,x

    lda $3918,x
    sta $3910,x

    lda $3920,x
    sta $3918,x

    lda $3928,x
    sta $3920,x

    lda $3930,x
    sta $3928,x

    lda $3938,x
    sta $3930,x

    lda $3940,x
    sta $3938,x

    lda $3948,x
    sta $3940,x

    lda $3950,x
    sta $3948,x

    lda $3958,x
    sta $3950,x

    lda $3960,x
    sta $3958,x

    lda $3968,x
    sta $3960,x

    lda $3970,x
    sta $3968,x

    lda $3978,x
    sta $3970,x

    lda $3980,x
    sta $3978,x

    lda $3988,x
    sta $3980,x

    lda $3990,x
    sta $3988,x

    lda $3998,x
    sta $3990,x

    lda $39a0,x
    sta $3998,x

    lda $39a8,x
    sta $39a0,x

    lda $39b0,x
    sta $39a8,x

    lda $39b8,x
    sta $39b0,x

    lda $39c0,x
    sta $39b8,x

    lda $39c8,x
    sta $39c0,x

    lda $39d0,x
    sta $39c8,x

    lda $39d8,x
    sta $39d0,x

    lda $39e0,x
    sta $39c8,x

    lda $39e8,x
    sta $39e0,x

    lda $39f0,x
    sta $39e8,x

    lda $39f8,x
    sta $39f0,x

    lda $3a00,x
    sta $39f8,x

    tya
    sta $3a00,x

    inx
    cpx #$07
    beq .endloop
    jmp .fontloop

.endloop
    rts


;-----

colorroll

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

    rts

;-----

color2scr

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

    rts

;-----

scrollu
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
    rts

;-----


scrolld
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

    rts

    org $0c00

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

    org $3000
screen    
    incbin "screen",2

    org $3800
font
    db $00,$00,$00,$01,$80,$00,$00,$00
    db $00,$00,$00,$03,$c0,$00,$00,$00
    db $00,$00,$00,$07,$e0,$00,$00,$00
    db $00,$00,$00,$0f,$f0,$00,$00,$00
    db $00,$00,$00,$1f,$f8,$00,$00,$00
    db $00,$00,$00,$3f,$fc,$00,$00,$00
    db $00,$00,$00,$7f,$fe,$00,$00,$00
    db $00,$00,$00,$ff,$ff,$00,$00,$00

    db $00,$00,$01,$ff,$ff,$80,$00,$00
    db $00,$00,$03,$ff,$ff,$c0,$00,$00
    db $00,$00,$07,$ff,$ff,$e0,$00,$00
    db $00,$00,$0f,$ff,$ff,$f0,$00,$00
    db $00,$00,$1f,$ff,$ff,$f8,$00,$00
    db $00,$00,$3f,$ff,$ff,$fc,$00,$00
    db $00,$00,$7f,$ff,$ff,$fe,$00,$00
    db $00,$00,$ff,$ff,$ff,$ff,$00,$00

    db $00,$01,$ff,$ff,$ff,$ff,$80,$00
    db $00,$03,$ff,$ff,$ff,$ff,$c0,$00
    db $00,$07,$ff,$ff,$ff,$ff,$e0,$00
    db $00,$0f,$ff,$ff,$ff,$ff,$f0,$00
    db $00,$1f,$ff,$ff,$ff,$ff,$f8,$00
    db $00,$3f,$ff,$ff,$ff,$ff,$fc,$00
    db $00,$7f,$ff,$ff,$ff,$ff,$fe,$00
    db $00,$ff,$ff,$ff,$ff,$ff,$ff,$00

    db $00,$ff,$ff,$ff,$ff,$ff,$ff,$00
    db $00,$7f,$ff,$ff,$ff,$ff,$fe,$00
    db $00,$3f,$ff,$ff,$ff,$ff,$fc,$00
    db $00,$1f,$ff,$ff,$ff,$ff,$f8,$00
    db $00,$0f,$ff,$ff,$ff,$ff,$f0,$00
    db $00,$07,$ff,$ff,$ff,$ff,$e0,$00
    db $00,$03,$ff,$ff,$ff,$ff,$c0,$00
    db $00,$01,$ff,$ff,$ff,$ff,$80,$00

    db $00,$00,$ff,$ff,$ff,$ff,$00,$00
    db $00,$00,$7f,$ff,$ff,$fe,$00,$00
    db $00,$00,$3f,$ff,$ff,$fc,$00,$00
    db $00,$00,$1f,$ff,$ff,$f8,$00,$00
    db $00,$00,$0f,$ff,$ff,$f0,$00,$00
    db $00,$00,$07,$ff,$ff,$e0,$00,$00
    db $00,$00,$03,$ff,$ff,$c0,$00,$00
    db $00,$00,$01,$ff,$ff,$80,$00,$00

    db $00,$00,$00,$ff,$ff,$00,$00,$00
    db $00,$00,$00,$7f,$fe,$00,$00,$00
    db $00,$00,$00,$3f,$fc,$00,$00,$00
    db $00,$00,$00,$1f,$f8,$00,$00,$00
    db $00,$00,$00,$0f,$f0,$00,$00,$00
    db $00,$00,$00,$07,$e0,$00,$00,$00
    db $00,$00,$00,$03,$c0,$00,$00,$00
    db $00,$00,$00,$01,$80,$00,$00,$00

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
