

    ;org  $0801
    ;db  $0c,$08,$e8,$07,$9e,$36,$34,$37,$33,$38,$00,$00 ; SYS 64738


    org $8000
    dw coldstart            ; coldstart vector
    dw warmstart            ; warmstart vector
    db $C3,$C2,$CD,$38,$30  ; "CBM8O". Autostart string

coldstart
warmstart
    sei
    lda #$00
    sta $dd00
.loop
    inc $d020
    jmp .loop

