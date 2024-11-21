

    org $8000
    dw coldstart            ; coldstart vector
    dw warmstart            ; warmstart vector
    db $C3,$C2,$CD,$38,$30  ; "CBM8O". Autostart string

coldstart
warmstart
    sei
.loop
    inc $d020
    dec $d021
    jmp .loop

