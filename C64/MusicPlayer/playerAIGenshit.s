


SID_BASE = $d400

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


; ----- PATCH INIT
; A = patch number, X = voice offset ($00, $07, $0e)
INIT_PATCH:
        pha
        txa
        pha
        tya
        pha

        sta $fd
        stx $fe

        ldx $fd
        lda PATCH_LOOKUP_LO,x
        sta $fb
        lda PATCH_LOOKUP_HI,x
        sta $fc

        ldy #$00
        lda ($fb),y
        ldx $fe
        ora #$01
        sta SID_BASE + $04,x

        iny
        lda ($fb),y
        ldx $fe
        sta SID_BASE + $05,x

        iny
        lda ($fb),y
        ldx $fe
        sta SID_BASE + $06,x

        ldy #$04
        lda ($fb),y
        ldx $fe
        cpx #$00
        bne .VOICE2
        cmp #$01
        bne .CHECK_EFFECT1
        sta VOICE1_ARP_ACTIVE
        ldy #$05
        lda ($fb),y
        bne .HAS_SPEED1
        lda #$01
.HAS_SPEED1
        sta VOICE1_ARP_SPEED
        ldy #$06
        lda ($fb),y
        bne .HAS_TABLE1
        lda #$00
.HAS_TABLE1
        sta VOICE1_ARP_TABLE
        lda #$00
        sta VOICE1_ARP_INDEX
        sta VOICE1_ARP_COUNTER
        sta VOICE1_BASENOTE
        jmp .DONE
.CHECK_EFFECT1
        cmp #$02
        bcc .NO_EFFECT1
        cmp #$05
        bcs .NO_EFFECT1
        sta VOICE1_EFFECT_TYPE
        ldy #$05
        lda ($fb),y
        sta VOICE1_EFFECT_SPEED
        ldy #$06
        lda ($fb),y
        sta VOICE1_EFFECT_PARAM
        lda #$00
        sta VOICE1_ARP_ACTIVE
        sta VOICE1_ARP_SPEED
        sta VOICE1_ARP_TABLE
        sta VOICE1_ARP_INDEX
        sta VOICE1_ARP_COUNTER
        sta VOICE1_BASENOTE
        jmp .DONE
.NO_EFFECT1
        lda #$00
        sta VOICE1_EFFECT_TYPE
        sta VOICE1_EFFECT_SPEED
        sta VOICE1_EFFECT_PARAM
        sta VOICE1_ARP_ACTIVE
        sta VOICE1_ARP_SPEED
        sta VOICE1_ARP_TABLE
        sta VOICE1_ARP_INDEX
        sta VOICE1_ARP_COUNTER
        sta VOICE1_BASENOTE
        jmp .DONE
.VOICE2
        cpx #$07
        bne .VOICE3
        cmp #$01
        bne .CHECK_EFFECT2
        sta VOICE2_ARP_ACTIVE
        ldy #$05
        lda ($fb),y
        bne .HAS_SPEED2
        lda #$01
.HAS_SPEED2
        sta VOICE2_ARP_SPEED
        ldy #$06
        lda ($fb),y
        bne .HAS_TABLE2
        lda #$00
.HAS_TABLE2
        sta VOICE2_ARP_TABLE
        lda #$00
        sta VOICE2_ARP_INDEX
        sta VOICE2_ARP_COUNTER
        sta VOICE2_BASENOTE
        jmp .DONE
.CHECK_EFFECT2
        cmp #$02
        bcc .NO_EFFECT2
        cmp #$05
        bcs .NO_EFFECT2
        sta VOICE2_EFFECT_TYPE
        ldy #$05
        lda ($fb),y
        sta VOICE2_EFFECT_SPEED
        ldy #$06
        lda ($fb),y
        sta VOICE2_EFFECT_PARAM
        lda #$00
        sta VOICE2_ARP_ACTIVE
        sta VOICE2_ARP_SPEED
        sta VOICE2_ARP_TABLE
        sta VOICE2_ARP_INDEX
        sta VOICE2_ARP_COUNTER
        sta VOICE2_BASENOTE
        jmp .DONE
.NO_EFFECT2
        lda #$00
        sta VOICE2_EFFECT_TYPE
        sta VOICE2_EFFECT_SPEED
        sta VOICE2_EFFECT_PARAM
        sta VOICE2_ARP_ACTIVE
        sta VOICE2_ARP_SPEED
        sta VOICE2_ARP_TABLE
        sta VOICE2_ARP_INDEX
        sta VOICE2_ARP_COUNTER
        sta VOICE2_BASENOTE
        jmp .DONE
.VOICE3
        cmp #$01
        bne .CHECK_EFFECT3
        sta VOICE3_ARP_ACTIVE
        ldy #$05
        lda ($fb),y
        bne .HAS_SPEED3
        lda #$01
.HAS_SPEED3
        sta VOICE3_ARP_SPEED
        ldy #$06
        lda ($fb),y
        bne .HAS_TABLE3
        lda #$00
.HAS_TABLE3
        sta VOICE3_ARP_TABLE
        lda #$00
        sta VOICE3_ARP_INDEX
        sta VOICE3_ARP_COUNTER
        sta VOICE3_BASENOTE
        jmp .DONE
.CHECK_EFFECT3
        cmp #$02
        bcc .NO_EFFECT3
        cmp #$05
        bcs .NO_EFFECT3
        sta VOICE3_EFFECT_TYPE
        ldy #$05
        lda ($fb),y
        sta VOICE3_EFFECT_SPEED
        ldy #$06
        lda ($fb),y
        sta VOICE3_EFFECT_PARAM
        lda #$00
        sta VOICE3_ARP_ACTIVE
        sta VOICE3_ARP_SPEED
        sta VOICE3_ARP_TABLE
        sta VOICE3_ARP_INDEX
        sta VOICE3_ARP_COUNTER
        sta VOICE3_BASENOTE
        jmp .DONE
.NO_EFFECT3
        lda #$00
        sta VOICE3_EFFECT_TYPE
        sta VOICE3_EFFECT_SPEED
        sta VOICE3_EFFECT_PARAM
        sta VOICE3_ARP_ACTIVE
        sta VOICE3_ARP_SPEED
        sta VOICE3_ARP_TABLE
        sta VOICE3_ARP_INDEX
        sta VOICE3_ARP_COUNTER
        sta VOICE3_BASENOTE
.DONE
        pla
        tay
        pla
        tax
        pla
        rts

; ----- TRACK INIT
INIT_TRACK:
        lda #$00
        sta TRACK1_INDEX
        sta TRACK2_INDEX
        sta TRACK3_INDEX

        sta TRACK1_DELAY
        sta TRACK2_DELAY
        sta TRACK3_DELAY

        sta PATTERN1_POS
        sta PATTERN2_POS
        sta PATTERN3_POS

        ldy #$00
        lda VOICE1_TRACKS,y
        tay
        lda PATTERNLOOKUP_LO,y
        sta PATTERN1_PTR_LO
        lda PATTERNLOOKUP_HI,y
        sta PATTERN1_PTR_HI

        lda VOICE2_TRACKS,y
        tay
        lda PATTERNLOOKUP_LO,y
        sta PATTERN2_PTR_LO
        lda PATTERNLOOKUP_HI,y
        sta PATTERN2_PTR_HI

        lda VOICE3_TRACKS,y
        tay
        lda PATTERNLOOKUP_LO,y
        sta PATTERN3_PTR_LO
        lda PATTERNLOOKUP_HI,y
        sta PATTERN3_PTR_HI

        rts

; ----- PLAYER
PLAYER_PLAY:
    jsr PLAY_VOICE_1
    jsr PLAY_VOICE_2
    jsr PLAY_VOICE_3
    rts

PLAY_VOICE_1:
    lda TRACK1_DELAY
    beq .FETCH
    ldx #$00
    jsr PLAY_ARP_FRAME
    dec TRACK1_DELAY
    rts

.FETCH:
    ldy PATTERN1_POS
    lda PATTERN1_PTR_LO
    sta $f9
    lda PATTERN1_PTR_HI
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .HAVE_CMD

    lda #$00
    sta PATTERN1_POS
    inc TRACK1_INDEX
    ldy TRACK1_INDEX
    lda VOICE1_TRACKS,y
    cmp #$ff
    bne .LOAD_PATTERN
    ldy #$00
    sty TRACK1_INDEX
    lda VOICE1_TRACKS,y
.LOAD_PATTERN:
    tay
    lda PATTERNLOOKUP_LO,y
    sta PATTERN1_PTR_LO
    lda PATTERNLOOKUP_HI,y
    sta PATTERN1_PTR_HI
    lda #$00
    sta PATTERN1_POS
    ldy PATTERN1_POS
    lda PATTERN1_PTR_LO
    sta $f9
    lda PATTERN1_PTR_HI
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .HAVE_CMD
    rts

.HAVE_CMD:
    sta $fd
    and #$1f
    bne .DELAY_OK
    lda #$01
.DELAY_OK:
    sta TRACK1_DELAY

    lda $fd
    bmi .HAS_PREFIX

    iny
    lda ($f9),y
    sta VOICE1_BASENOTE
    ldx #$00
    jsr PLAY_NOTE
    lda PATTERN1_POS
    clc
    adc #$02
    sta PATTERN1_POS
    rts

.HAS_PREFIX:
    iny
    lda ($f9),y
    cmp #$80
    bcs .SKIP_PATCH
    ldx #$00
    jsr INIT_PATCH
.SKIP_PATCH:
    iny
    lda ($f9),y
    sta VOICE1_BASENOTE
    ldx #$00
    jsr PLAY_NOTE
    lda PATTERN1_POS
    clc
    adc #$03
    sta PATTERN1_POS
    rts

PLAY_VOICE_2:
    lda TRACK2_DELAY
    beq .FETCH
    ldx #$07
    jsr PLAY_ARP_FRAME
    dec TRACK2_DELAY
    rts

.FETCH:
    ldy PATTERN2_POS
    lda PATTERN2_PTR_LO
    sta $f9
    lda PATTERN2_PTR_HI
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .HAVE_CMD

    lda #$00
    sta PATTERN2_POS
    inc TRACK2_INDEX
    ldy TRACK2_INDEX
    lda VOICE2_TRACKS,y
    cmp #$ff
    bne .LOAD_PATTERN
    ldy #$00
    sty TRACK2_INDEX
    lda VOICE2_TRACKS,y
.LOAD_PATTERN:
    tay
    lda PATTERNLOOKUP_LO,y
    sta PATTERN2_PTR_LO
    lda PATTERNLOOKUP_HI,y
    sta PATTERN2_PTR_HI
    lda #$00
    sta PATTERN2_POS
    ldy PATTERN2_POS
    lda PATTERN2_PTR_LO
    sta $f9
    lda PATTERN2_PTR_HI
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .HAVE_CMD
    rts

.HAVE_CMD:
    sta $fd
    and #$1f
    bne .DELAY_OK
    lda #$01
.DELAY_OK:
    sta TRACK2_DELAY

    lda $fd
    bmi .HAS_PREFIX

    iny
    lda ($f9),y
    sta VOICE2_BASENOTE
    ldx #$07
    jsr PLAY_NOTE
    lda PATTERN2_POS
    clc
    adc #$02
    sta PATTERN2_POS
    rts

.HAS_PREFIX:
    iny
    lda ($f9),y
    cmp #$80
    bcs .SKIP_PATCH
    ldx #$07
    jsr INIT_PATCH
.SKIP_PATCH:
    iny
    lda ($f9),y
    sta VOICE2_BASENOTE
    ldx #$07
    jsr PLAY_NOTE
    lda PATTERN2_POS
    clc
    adc #$03
    sta PATTERN2_POS
    rts

PLAY_VOICE_3:
    lda TRACK3_DELAY
    beq .FETCH
    ldx #$0e
    jsr PLAY_ARP_FRAME
    dec TRACK3_DELAY
    rts

.FETCH:
    ldy PATTERN3_POS
    lda PATTERN3_PTR_LO
    sta $f9
    lda PATTERN3_PTR_HI
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .HAVE_CMD

    lda #$00
    sta PATTERN3_POS
    inc TRACK3_INDEX
    ldy TRACK3_INDEX
    lda VOICE3_TRACKS,y
    cmp #$ff
    bne .LOAD_PATTERN
    ldy #$00
    sty TRACK3_INDEX
    lda VOICE3_TRACKS,y
.LOAD_PATTERN:
    tay
    lda PATTERNLOOKUP_LO,y
    sta PATTERN3_PTR_LO
    lda PATTERNLOOKUP_HI,y
    sta PATTERN3_PTR_HI
    lda #$00
    sta PATTERN3_POS
    ldy PATTERN3_POS
    lda PATTERN3_PTR_LO
    sta $f9
    lda PATTERN3_PTR_HI
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .HAVE_CMD
    rts

.HAVE_CMD:
    sta $fd
    and #$1f
    bne .DELAY_OK
    lda #$01
.DELAY_OK:
    sta TRACK3_DELAY

    lda $fd
    bmi .HAS_PREFIX

    iny
    lda ($f9),y
    sta VOICE3_BASENOTE
    ldx #$0e
    jsr PLAY_NOTE
    lda PATTERN3_POS
    clc
    adc #$02
    sta PATTERN3_POS
    rts

.HAS_PREFIX:
    iny
    lda ($f9),y
    cmp #$80
    bcs .SKIP_PATCH
    ldx #$0e
    jsr INIT_PATCH
.SKIP_PATCH:
    iny
    lda ($f9),y
    sta VOICE3_BASENOTE
    ldx #$0e
    jsr PLAY_NOTE
    lda PATTERN3_POS
    clc
    adc #$03
    sta PATTERN3_POS
    rts

; ----- NOTE PLAYER
PLAY_NOTE:
    sta $fd
    stx $fe

    ldx $fd
    lda FREQ_LO,x
    ldx $fe
    sta SID_BASE,x

    ldx $fd
    lda FREQ_HI,x
    ldx $fe
    sta SID_BASE + $01,x

    rts

PLAY_ARP_FRAME:
    cpx #$00
    bne .CHECK_VOICE2
    lda VOICE1_ARP_ACTIVE
    beq .ARP_DONE1
    dec VOICE1_ARP_COUNTER
    bmi .ADVANCE1
    rts
.ADVANCE1
    lda VOICE1_ARP_SPEED
    sta VOICE1_ARP_COUNTER
    ldy VOICE1_ARP_INDEX
    lda VOICE1_ARP_TABLE
    tax
    lda ARP_LOOKUP_LO,x
    sta $f9
    lda ARP_LOOKUP_HI,x
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .OK1
    ldy #$00
    sty VOICE1_ARP_INDEX
    lda ($f9),y
.OK1
    clc
    adc VOICE1_BASENOTE
    ldx #$00
    jsr PLAY_NOTE
    inc VOICE1_ARP_INDEX
    rts
.ARP_DONE1
    rts
.CHECK_VOICE2
    cpx #$07
    bne .VOICE3
    lda VOICE2_ARP_ACTIVE
    beq .ARP_DONE2
    dec VOICE2_ARP_COUNTER
    bmi .ADVANCE2
    rts
.ADVANCE2
    lda VOICE2_ARP_SPEED
    sta VOICE2_ARP_COUNTER
    ldy VOICE2_ARP_INDEX
    lda VOICE2_ARP_TABLE
    tax
    lda ARP_LOOKUP_LO,x
    sta $f9
    lda ARP_LOOKUP_HI,x
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .OK2
    ldy #$00
    sty VOICE2_ARP_INDEX
    lda ($f9),y
.OK2
    clc
    adc VOICE2_BASENOTE
    ldx #$07
    jsr PLAY_NOTE
    inc VOICE2_ARP_INDEX
    rts
.ARP_DONE2
    rts
.VOICE3
    lda VOICE3_ARP_ACTIVE
    beq .ARP_DONE3
    dec VOICE3_ARP_COUNTER
    bmi .ADVANCE3
    rts
.ADVANCE3
    lda VOICE3_ARP_SPEED
    sta VOICE3_ARP_COUNTER
    ldy VOICE3_ARP_INDEX
    lda VOICE3_ARP_TABLE
    tax
    lda ARP_LOOKUP_LO,x
    sta $f9
    lda ARP_LOOKUP_HI,x
    sta $fa
    lda ($f9),y
    cmp #$ff
    bne .OK3
    ldy #$00
    sty VOICE3_ARP_INDEX
    lda ($f9),y
.OK3
    clc
    adc VOICE3_BASENOTE
    ldx #$0e
    jsr PLAY_NOTE
    inc VOICE3_ARP_INDEX
    rts
.ARP_DONE3
    rts


; ----- NOTE TO FREQ LOOKUP
NOTE2FREQ       ; (set x for note)
    LDA FREQ_LO,X  ; Load the low byte ($F1 for PAL)
    STA $D400      ; Write to Voice 1 Frequency Low
    LDA FREQ_HI,X  ; Load the high byte ($08 for PAL)
    STA $D401      ; Write to Voice 1 Frequency High
    RTS


; ----- PLAYER VARIABLES
TRACK1_INDEX
    db 0
TRACK2_INDEX
    db 0
TRACK3_INDEX
    db 0

PATTERN1_POS
    db 0
PATTERN2_POS
    db 0
PATTERN3_POS
    db 0

PATTERN1_PTR_LO
    db 0
PATTERN1_PTR_HI
    db 0
PATTERN2_PTR_LO
    db 0
PATTERN2_PTR_HI
    db 0
PATTERN3_PTR_LO
    db 0
PATTERN3_PTR_HI
    db 0

TRACK1_DELAY
    db 0
TRACK2_DELAY
    db 0
TRACK3_DELAY
    db 0

VOICE1_WAVEFORM
    db 0
VOICE2_WAVEFORM
    db 0
VOICE3_WAVEFORM
    db 0

VOICE1_BASENOTE
    db 0
VOICE2_BASENOTE
    db 0
VOICE3_BASENOTE
    db 0

VOICE1_ARP_ACTIVE
    db 0
VOICE2_ARP_ACTIVE
    db 0
VOICE3_ARP_ACTIVE
    db 0

VOICE1_ARP_TABLE
    db 0
VOICE2_ARP_TABLE
    db 0
VOICE3_ARP_TABLE
    db 0

VOICE1_ARP_INDEX
    db 0
VOICE2_ARP_INDEX
    db 0
VOICE3_ARP_INDEX
    db 0

VOICE1_ARP_COUNTER
    db 0
VOICE2_ARP_COUNTER
    db 0
VOICE3_ARP_COUNTER
    db 0

VOICE1_ARP_SPEED
    db 0
VOICE2_ARP_SPEED
    db 0
VOICE3_ARP_SPEED
    db 0

VOICE1_EFFECT_TYPE
    db 0
VOICE2_EFFECT_TYPE
    db 0
VOICE3_EFFECT_TYPE
    db 0

VOICE1_EFFECT_SPEED
    db 0
VOICE2_EFFECT_SPEED
    db 0
VOICE3_EFFECT_SPEED
    db 0

VOICE1_EFFECT_PARAM
    db 0
VOICE2_EFFECT_PARAM
    db 0
VOICE3_EFFECT_PARAM
    db 0

; ----- SONG DATA

SONG_DATA
VOICE1_TRACKS
    db $01, $01, $01, $02, $FF
VOICE2_TRACKS
    db $FF
VOICE3_TRACKS
    db $03,$FF

;   $FF: End of track loop. When the driver hits this byte, it resets the track pointer back to the beginning.
;   $FE: Single play. Tells the driver to stop playing when the song finishes.


; ----- PATTERN LOOKUP TABLE
PATTERNLOOKUP_LO
    db <PATTERN_00
    db <PATTERN_01
    db <PATTERN_02
    db <PATTERN_03

PATTERNLOOKUP_HI
    db >PATTERN_00
    db >PATTERN_01
    db >PATTERN_02
    db >PATTERN_03

; ----- PATTERN DATA
PATTERNS:
;   Byte 1: Note Duration & Status Flag Bits (Mandatory)
;   The first byte designated how many system frames (ticks) the note held. 
;   The lower 5 bits set the length ($00 to $1F), while the upper 3 bits acted as conditional hardware flags
;   Bit 5 ($20): Cut release. Disables standard voice decay.
;   Bit 6 ($40): Tie note. Appends this pitch to the previous note without triggering a fresh ADSR volume envelope (used for legato).
;   Bit 7 ($80): Prefix Flag. If this bit is active, it alerts the driver that optiona l parameter bytes are immediately following it in the memory stream.
;   Byte 2: Instrument Patch or Pitch Glides (Optional)This byte was read only if Bit 7 of Byte 1 was enabled. The driver evaluated whether this byte was positive or negative to choose an execution route:Positive Value ($00â€“$7F): Sets a new patch instrument number (loads fresh ADSR, pulse width, and waveform data into the SID).Negative Value ($80â€“$FE): Triggers an automated pitch slide (portamento). The number defined the speed of the sweep.Byte 3: Pitch Value (Conditional)The actual hex index value for the note (like $24 for middle C). If the pattern data instructed a pause instead of a frequency pitch, it utilized a rest flag:
;   $FF: Signaled the absolute end of the pattern data block. 
;   The driver would exit and hop to the next pattern ID in the Track Playlist.

PATTERN_00:
    db  $ff

PATTERN_01:
    db $8C, $01, $2B ; 3-Byte Packet: Bit 7 set ($8C). 
                      ; Next byte ($02) loads Instrument #1. 
                      ; Third byte ($2B) plays note G-3 for 12 ticks.
    db $0C, $24      ; 1-Byte Config: Play note $24 (C-3) for 12 ticks
    db $0C, $26      ; 1-Byte Config: Play note $26 (D-3) for 6 ticks   
    db $0C, $2D      ; 1-Byte Config: Bit 6 set ($4C). Tie/slur into 
                      ; note $2D (A-3) without re-firing the volume envelope.                      
    db $FF           ; End of Pattern marker. Fetch next Track ID.

PATTERN_02:
    db $8C, $02, $2B ; 3-Byte Packet: Bit 7 set ($8C). 
                      ; Next byte ($02) loads Instrument #2. 
                      ; Third byte ($2B) plays note G-3 for 12 ticks.
    db $0C, $28      ; 1-Byte Config: Play note $24 (C-3) for 12 ticks
    db $4C, $26      ; 1-Byte Config: Play note $26 (D-3) for 6 ticks                      
    db $0C, $2D      ; 1-Byte Config: Bit 6 set ($4C). Tie/slur into 
                      ; note $2D (A-3) without re-firing the volume envelope.                  
    db $FF           ; End of Pattern marker. Fetch next Track ID.

PATTERN_03:
    db $b0, $02, $4B ; 3-Byte Packet: Bit 7 set ($8C). 
    db $FF           ; End of Pattern marker. Fetch next Track ID.



; ----- PATCH LOOKUP TABLE

PATCHES:
PATCH_LOOKUP_LO
    db <PATCH_00
    db <PATCH_01
    db <PATCH_02

PATCH_LOOKUP_HI
    db >PATCH_00
    db >PATCH_01
    db >PATCH_02

; ----- PATCH DATA
PATCH_00:
    db $00       ; Tavu 1: Aaltomuoto (Waveform) -> Kolmio/Saha/Kohina ($11 = Saha + Gate)
    db $00, $00  ; Tavu 2-3: Attack/Decay ($01) ja Sustain/Release ($A8) -> ADSR-verhokÃ¤yrÃ¤
    db $00       ; Tavu 4: Pulssileveyden ylÃ¤tavu (Pulse Width High Byte, esim. kanttiaallolle)
    db $00       ; Tavu 5: Efektilippu (FX Flag) -> $00 = ei efekti, $01 = arpeggio, $02 = vibrato, $03 = slide up, $04 = slide down
    db $00       ; Tavu 6: Efektin nopeus / parametrin arvo
    db $00       ; Tavu 7: Efektin lisÃ¤parametri

; Esimerkki Rob Hubbardin basso-soittimesta assembly-muodossa
PATCH_01:
    db $21       ; Tavu 1: Aaltomuoto (Waveform) -> Kolmio/Saha/Kohina ($11 = Saha + Gate)
    db $01, $A8  ; Tavu 2-3: Attack/Decay ($01) ja Sustain/Release ($A8) -> ADSR-verhokÃ¤yrÃ¤
    db $10       ; Tavu 4: Pulssileveyden ylÃ¤tavu (Pulse Width High Byte, esim. kanttiaallolle)
    db $00       ; Tavu 5: Efektilippu (FX Flag) -> $00 = ei efekti, $01 = arpeggio, $02 = vibrato, $03 = slide up, $04 = slide down
    db $00       ; Tavu 6: Efektin nopeus / parametrin arvo
    db $00       ; Tavu 7: Efektin lisÃ¤parametri

; =============================================================================
; ROB HUBBARD STYLE INSTRUMENT EXAMPLE 2: "SPACE ARPEGGIO LEAD"
; Optimized for lead melodies and fast cascading electronic chords.
; =============================================================================
PATCH_02:
    db $11       ; Tavu 1: Aaltomuoto -> Kanttiaalto + Gate pÃ¤Ã¤llÃ¤ ($40 + $01)
    db $02, $A9  ; Tavu 2-3: Attack/Decay ($02 = erittÃ¤in terÃ¤vÃ¤ isku) 
                  ;           Sustain/Release ($A9 = keskivoimakas pito, pitkÃ¤ loppukaiku)
    db $08       ; Tavu 4: Pulssileveyden aloitusarvo
    db $01       ; Tavu 5: Efektilippu ($01 = arpeggio)
    db $03       ; Tavu 6: Efektin nopeus / parametrin arvo
    db $04       ; Tavu 7: Efektin lisÃ¤parametri

; ----- ARPEGGIO LOOKUP TABLE

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








