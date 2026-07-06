


SID_BASE = $d400

CH1 = $00
CH2 = $07
CH3 = $0e

; ----- BASIC AUTORUN

    org $0801 ; Standard SYS 2061 BASIC start
BASIC
    db $0c,$08,$ea,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00

; ----- IRQ SETUP

SETUP
    sei

    lda #$7f
    sta $dc0d   ;CIA_ICR

    lda #$1b
    sta $d011

    lda #$10
    sta $d012

    lda #<IRQ
    sta $0314
    lda #>IRQ
    sta $0315

    lda #$01
    sta $d01a

    cli

    jsr PLAYER_INIT

    rts

; ----- IRQ
IRQ pha
    tax
    pha
    tay
    pha 

    asl $d019

    inc $d020
    jsr PLAYER_PLAY
    dec $d020

    pla
    tay
    pla
    tax
    pla

    jmp $ea31

; ----- PLAYER INIT
PLAYER_INIT:

    jsr INIT_SID
    jsr SET_PATCH
    jsr INIT_TRACK

    rts

; ----- SID INIT

INIT_SID:
    lda #$00            ; Load 0 into Accumulator to clear registers
    ldx #$18            ; Loop counter to cover 25 SID registers ($00 to $18)

.CLEAR_LOOP:
    sta SID_BASE,x      ; Write 00 to SID register ($D400 + X)
    dex                 ; Decrement index pointer
    bpl .CLEAR_LOOP      ; Repeat until X becomes negative (covers all registers)

    lda #$0F            ; $0F sets master volume to MAX, selects no filter
    sta SID_BASE + $18  ; Write to SID volume register ($D418)

    rts                 ; Return from Subroutine

PLAYER_PLAY

    lda TRACK1_DELAY
    beq .NEWNOTE
    jsr PLAY_ARP_FRAME
    dec TRACK1_DELAY
    rts

.NEWNOTE
    lda #$0c
    sta TRACK1_DELAY

    lda #$41
    sta SID_BASE+$04

    lda #$18
    sta SID_BASE+$02
    lda #$45
    sta SID_BASE+$03

    lda #$18
    sta SID_BASE+$05
    lda #$45
    sta SID_BASE+$06

    ldy #$00        
    lda #$30
    jsr NOTE2FREQ

    rts

; ----- NOTE TO FREQ LOOKUP
; (set x for note ; y = $00,$07,$0e CHANNEL)    
NOTE2FREQ
    lda FREQ_LO,X  ; Load the low byte ($F1 for PAL)
    sta $d400,y    ; Write to Voice 1 Frequency Low
    lda FREQ_HI,X  ; Load the high byte ($08 for PAL)
    sta $d401,y    ; Write to Voice 1 Frequency High
    rts

PLAY_ARP_FRAME

    ldx ARP_ROTATION
    lda ARP_01,x
    cmp #$ff
    bne .cont
    ldy #$00
    sty ARP_ROTATION
.cont
    clc
    adc #$30
    jsr NOTE2FREQ
    inc ARP_ROTATION

    rts

; ----- PLAYER VARIABLES

ARP_DELAY
    db  0

ARP_ROTATION
    db  0
TRACK1_DELAY
    db  0

; ----- SONG DATA

SONG_DATA
;   $FF: End of track loop. When the driver hits this byte, it resets the track pointer back to the beginning.
;   $FE: Single play. Tells the driver to stop playing when the song finishes.

; ----- ARPEGGIO LOOKUP
ARP_LOOKUP_HI
    db <ARP_00
    db <ARP_01
    db <ARP_02
    db <ARP_03
    db <ARP_04

ARP_LOOKUP_LO
    db >ARP_00
    db >ARP_01
    db >ARP_02
    db >ARP_03
    db >ARP_04

; ----- ARPEGGIO DATA
ARP_00:
    db $00, $ff  ; PerussÃ¤vel, Suuri terssi (+4), Kvintti (+7), Oktaavi (+12)
ARP_01
    db $00, $04, $07, $0C , $ff  ; major triad
ARP_02
    db $00, $03, $07, $0C  ; minor triad
ARP_03
    db $00, $05, $07, $0b, $0c, $ff  ; Major 7th Sus4 
ARP_04
    db $00, $0c, $18, $0c, $ff  ; Octave Jump 

; ----- NOTE FREQ TABLES
FREQ_LO:
    db $16, $27, $39, $4B, $5F, $74, $8A, $A1, $BA, $D4, $F0, $0E, $2D, $4E, $71, $96
    db $BE, $E7, $14, $42, $74, $A9, $E0, $1B, $5A, $9C, $E2, $2D, $7B, $CF, $27, $85
    db $E8, $51, $C1, $37, $B4, $38, $C4, $59, $F7, $9D, $4E, $0A, $D0, $A2, $81, $6D
    db $67, $70, $89, $B2, $ED, $3B, $9C, $13, $A0, $45, $02, $DA, $CE, $E0, $11, $64
    db $DA, $76, $39, $46, $40, $89, $04, $B4, $9C, $C0, $23, $C8, $B4, $EB, $72, $4C
    db $80, $12, $08, $68, $39, $90, $45, $90, $68, $D6, $E3, $99, $00, $24, $10, $D0
    db $71, $00, $8A, $20, $D1, $AD, $C7, $13, $00, $48, $21, $A1, $E2, $FF, $15, $40
    db $A1, $5A, $8D, $62, $FF, $90, $41, $42, $C4, $FF, $29, $80, $42, $B4, $1B, $C4
    db $FF, $20, $82, $83, $89, $FE, $53, $00, $85, $67, $36, $88, $FE, $41, $04, $07
    db $12, $FB, $A6, $00, $09, $CE, $6C, $10, $FC, $81, $08, $0D, $24, $F7, $4B, $00
    db $13, $9C, $D7, $20, $F7, $02, $10, $1B, $47, $EE, $96, $01, $25, $38, $AE, $40
    db $EE, $05, $21, $35, $8F, $DB, $2D, $01, $4A, $70, $5C, $80, $DC, $09, $41, $6A
    db $1E, $B6, $59, $03, $94, $E0, $B9, $01, $B8, $12, $83, $D5, $3C, $6D, $14, $06
    db $29, $C0, $72, $01, $71, $25, $06, $A9, $78, $DA, $65, $0C, $52, $81, $E4, $02
    db $E1, $49, $0C, $52, $F0, $B4, $CA, $17, $A3, $02, $C7, $04, $C3, $92, $17, $A5
    db $DF, $67, $94, $2F, $47, $03, $8F, $08, $85, $25, $2F, $4A, $BE, $CF, $27, $5E

FREQ_HI:
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02
    db $02, $02, $03, $03, $03, $03, $03, $04, $04, $04, $04, $05, $05, $05, $06, $06
    db $06, $07, $07, $08, $08, $09, $09, $0A, $0A, $0B, $0C, $0D, $0D, $0E, $0F, $10
    db $11, $12, $13, $14, $15, $17, $18, $1A, $1B, $1D, $1F, $20, $22, $24, $27, $29
    db $2B, $2E, $31, $34, $37, $3A, $3E, $41, $45, $49, $4E, $52, $57, $5C, $62, $68
    db $6E, $75, $7C, $83, $8B, $93, $9C, $A5, $AF, $B9, $C4, $D0, $DD, $EA, $F8, $06
    db $16, $27, $38, $4B, $5E, $73, $89, $A1, $BA, $D4, $F0, $0D, $2C, $4D, $71, $96
    db $BD, $E7, $13, $42, $73, $A8, $E0, $1B, $59, $9B, $E2, $2C, $7B, $CE, $27, $84
    db $E7, $51, $C0, $36, $B3, $37, $C4, $59, $F6, $9D, $4E, $09, $CF, $A2, $81, $6D
    db $67, $6F, $88, $B2, $ED, $3A, $9C, $13, $9F, $44, $02, $DA, $CE, $DF, $11, $64
    db $DA, $75, $38, $26, $3F, $89, $04, $B4, $9C, $BF, $22, $C8, $B4, $EB, $71, $4C
    db $7F, $12, $08, $68, $38, $7F, $45, $90, $68, $D6, $E3, $98, $FF, $24, $10, $D0
    db $71, $FF, $8A, $20, $D0, $AC, $C6, $31, $FF, $48, $20, $A0, $E2, $FF, $14, $40
    db $A1, $59, $8D, $62, $FF, $90, $41, $41, $84, $67, $35, $88, $FD, $40, $04, $06
    db $11, $FB, $A5, $00, $09, $CE, $6B, $10, $FB, $81, $08, $0D, $23, $F6, $4B, $00








