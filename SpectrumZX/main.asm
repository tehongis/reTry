
SCR equ $4000          ; Sets a constant

    org $8000          ; Where our program will being in the computer's memory

MAIN
    ld bc,STRING
    ld de,SCR

LOOP          ; Marker
    ld a,(bc)
    cp 0          ; zero not 'o'
    jr z,EXIT
    rst $10
    inc bc
    inc de
    jr LOOP

EXIT
    ret

STRING
    defb "Demo 2019!"
    defb 13,0 ; zero not 'o'

    end
