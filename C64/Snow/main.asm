
mode        equ $f8
ptrlo       equ $fa
ptrhi       equ $fb
counter     equ $fd

    org $0801
bajsic
    db  $0c,$08,$e4,$07,$9e,$20,$32,$30,$36,$34,$00,$00

    org $0810
main
    lda #$01
    jsr music

    jsr clearfont
    jsr clearscreen

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


clearfont
    ldx #$00
    txa
.fontloop
    sta $3800,x
    sta $3a00,x
    sta $3c00,x
    sta $3e00,x
    inx
    bne .fontloop
    rts

clearscreen
    ldx #$00
    txa
.scrloop
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne .scrloop
    rts


; ----------- Copyfont
;copyfont
;    sei
;    lda #$33
;    sta $01
;    ldx #$00
;.fontloop    
;    lda $d000,x
;    sta $3800,x
;    lda $d100,x
;    sta $3900,x
;    lda $d200,x
;    sta $3a00,x
;    lda $d300,x
;    sta $3b00,x
;    lda #$ff
;    sta $3c00,x
;    sta $3d00,x
;    sta $3e00,x
;    sta $3f00,x
;    inx
;    bne .fontloop
;    lda #$37
;    sta $01
;    cli
;    rts

; ----------- Irq
irq

    jsr music+3

    lda mode
    cmp #$00
    bne .step1
    pha
    lda #$00
    sta $d020
    lda #$00
    sta $d021

    jsr scrollup
    pla
.step1

    cmp #$01
    bne .step5
    pha
    lda #$00
    sta $d020
    lda #$00
    sta $d021
    jsr drop
    jsr draw
    pla
.step5


    lda $d019
    sta $d019
    rti

;-------------- end of IRQ

scrollup
    ldx counter
    
.scrolloop
    lda screenhi,x
    sta ptrhi
    lda screenlo,x
    sta ptrlo

    clc
    lda counter
    ldy #$00
.loop
    sta (ptrlo),y
    clc
    adc #$40
    iny
    sta (ptrlo),y
    clc
    adc #$40
    iny
    sta (ptrlo),y
    clc
    adc #$40
    iny
    sta (ptrlo),y
    clc
    adc #$40
    iny
    cpy #$28
    bne .loop

    clc
    lda ptrhi
    adc #$d4
    sta ptrhi

    lda #$01
    ldy #$00
.loop2
    sta (ptrlo),y
    iny
    cpy #$28
    bne .loop2


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

drop
    ldx #$00
    clc
.loop  
    lda $3801,x
    sta $3800,x
    lda $3a01,x
    sta $3a00,x
    lda $3c01,x
    sta $3c00,x
    lda $3e01,x
    sta $3e00,x
    inx
    cpx #$c8
    bne .loop
    inc counter
    rts

draw
    ldx counter
    lda sine,x
    tay
    and #$07
    tax
    tya

    lsr
    lsr
    lsr
    and #$03

    cmp #$00
    bne .pass1
    lda bits,x
    sta $38c8
    lda #$00
    sta $3ac8
    sta $3cc8
    sta $3ec8

.pass1    

    cmp #$01
    bne .pass2
    lda bits,x
    sta $3ac8
    lda #$00
    sta $38c8
    sta $3cc8
    sta $3ec8
.pass2    

    cmp #$02
    bne .pass3
    lda bits,x
    sta $3cc8
    lda #$00
    sta $38c8
    sta $3ac8
    sta $3ec8
.pass3    

    cmp #$03
    bne .pass4
    lda bits,x
    sta $3ec8
    lda #$00
    sta $38c8
    sta $3ac8
    sta $3cc8
.pass4    

    rts


bits
    db $80,$40,$20,$10,$08,$04,$02,$01

    org $0d00
sine
        db      $40, $3e, $3c, $3b, $39, $38, $36, $35
        db      $33, $31, $30, $2e, $2d, $2b, $2a, $28
        db      $27, $25, $24, $23, $21, $20, $1e, $1d
        db      $1c, $1b, $19, $18, $17, $16, $14, $13
        db      $12, $11, $10, $0f, $0e, $0d, $0c, $0b
        db      $0a, $09, $08, $08, $07, $06, $06, $05
        db      $04, $04, $03, $03, $02, $02, $01, $01
        db      $01, $00, $00, $00, $00, $00, $00, $00
        db      $00, $00, $00, $00, $00, $00, $00, $01
        db      $01, $01, $02, $02, $02, $03, $03, $04
        db      $05, $05, $06, $07, $07, $08, $09, $0a
        db      $0b, $0b, $0c, $0d, $0e, $0f, $10, $12
        db      $13, $14, $15, $16, $17, $19, $1a, $1b
        db      $1c, $1e, $1f, $21, $22, $23, $25, $26
        db      $28, $29, $2b, $2c, $2e, $2f, $31, $32
        db      $34, $35, $37, $38, $3a, $3c, $3d, $3f
        db      $40, $42, $43, $45, $47, $48, $4a, $4b
        db      $4d, $4e, $50, $51, $53, $54, $56, $57
        db      $59, $5a, $5c, $5d, $5e, $60, $61, $63
        db      $64, $65, $66, $68, $69, $6a, $6b, $6c
        db      $6d, $6f, $70, $71, $72, $73, $74, $74
        db      $75, $76, $77, $78, $78, $79, $7a, $7a
        db      $7b, $7c, $7c, $7d, $7d, $7d, $7e, $7e
        db      $7e, $7f, $7f, $7f, $7f, $7f, $7f, $7f
        db      $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7e
        db      $7e, $7e, $7d, $7d, $7c, $7c, $7b, $7b
        db      $7a, $79, $79, $78, $77, $77, $76, $75
        db      $74, $73, $72, $71, $70, $6f, $6e, $6d
        db      $6c, $6b, $69, $68, $67, $66, $64, $63
        db      $62, $61, $5f, $5e, $5c, $5b, $5a, $58
        db      $57, $55, $54, $52, $51, $4f, $4e, $4c
        db      $4a, $49, $47, $46, $44, $43, $41, $40

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
