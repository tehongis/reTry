
mode        equ $f8
counter     equ $ff

    org $0801
bajsic
    db  $0c,$08,$e4,$07,$9e,$20,$32,$30,$36,$34,$00,$00

    org $0810
main
    lda #$01
    jsr music

    jsr copyfont

    lda #$00
    sta mode
    lda #$00
    sta counter

    sei
    lda #$35
    sta $01

    lda #$7f
    sta $dc0d

    lda #$01
    sta $d01a

    lda #<irq
    sta $fffe
    lda #>irq
    sta $ffff

    lda #$1f
    sta $d018
    lda #$1b
    sta $d011
    lda #00
    sta $d012

    lda $dc0d
    lda $dd0d

    lda #$0e
    sta $d020
    lda #$06
    sta $d021

    cli

.loop
    jmp .loop

; ----------- Copyfont
copyfont
    sei
    lda #$33
    sta $01
    ldx #$00
.fontloop    
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
    bne .fontloop
    lda #$37
    sta $01
    cli
    rts

; ----------- Irq
irq

    jsr music+3

    lda mode
;    sta $d020   ; For debug only ..remove later
    cmp #$00
    bne .step1
    pha
    jsr scrollup
    pla
.step1

    lda mode
;    sta $d020   ; For debug only ..remove later
    cmp #$01
    bne .step2
    pha
    jsr fontclearer
    pla
.step2

    cmp #$02
    bne .step3
    pha
    lda #$0e
    sta $d020
    lda #$0e
    sta $d021
    jsr screenfiller
    pla
.step3

    cmp #$03
    bne .step4
    pha
    lda #$0e
    sta $d020
    lda #$0e
    sta $d021
    jsr colorset
    pla
.step4

    cmp #$04
    bne .step5
    pha
    lda #$0e
    sta $d020
    lda #$0e
    sta $d021
    jsr drop
    pla
.step5

    lda $d019
    sta $d019
    rti

;-------------- end of IRQ

scrollup
    ldy counter
    lda screenhi,y
    sta $fb
    lda screenlo,y
    sta $fa

    ldy #0
.lineloop
    lda #$a0
    sta ($fa),y
    iny
    cpy #$28
    bne .lineloop

    lda counter
    cmp #24
    bcc .notdone
    lda #$00
    sta counter
    lda #$01
    sta mode
    rts
.notdone
    inc counter
    rts

fontclearer
    ldx counter
    lda #$ff
    sta $3800,x
    sta $3900,x
    sta $3a00,x
    sta $3b00,x
    sta $3c00,x
    sta $3d00,x
    sta $3e00,x
    sta $3f00,x

    txa
    cmp #counter
    bcc .notdone
    lda #$00
    sta counter
    lda #$02
    sta mode
    rts

.notdone
    inc counter

    rts

screenfiller
    ldy counter
    lda screenhi,y
    sta $fb
    lda screenlo,y
    sta $fa
    tya
    ldy #$00
.lineloop
    sta ($fa),y
    iny
    cpy #$28
    bne .lineloop

    lda counter
    cmp #24
    bcc .notdone
    lda #$00
    sta counter
    lda #$03
    sta mode
    rts

.notdone
    inc counter

    rts

colorset
    lda #$d8
    sta $fb
    lda #$00
    sta $fa

    ldy counter

    ldx #$00
.loop
    lda #$01
    sta ($fa),y
    clc
    lda $fa
    adc #$28
    sta $fa
    lda $fb
    adc #$00
    sta $fb
    inx
    cpx #24
    bne .loop
  
    lda counter
    cmp #$27
    bcc .notdone
    lda #$00
    sta counter
    lda #$04
    sta mode
    rts
.notdone
    inc counter

    rts

drop
    ldx counter
    stx $38c8
    ldx #$00
    clc
.loop  
    lda $3801,x
    sta $3800,x
    inx
    cpx #$c8
    bne .loop
    inc counter

    rts

    org $0e00
screenhi
	db	$04, $04, $04, $04, $04, $04, $04, $05
    db  $05, $05, $05, $05, $05, $06, $06, $06
    db  $06, $06, $06, $06, $07, $07, $07, $07
    db  $07

screenlo
	db	$00, $28, $50, $78, $a0, $c8, $f0, $18
    db  $40, $68, $90, $b8, $e0, $08, $30, $58
    db  $80, $a8, $d0, $f8, $20, $48, $70, $98
    db  $c0

    org $1000
music
    incbin  "Oldskoolcrayfish.dat",2
;Song by Agemixer
