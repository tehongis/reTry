;=============================================================================
; MONITOR.ASM - Käyttöjärjestelmän monitori, kursorihallinta ja komentorivi
;=============================================================================

; --- GLOBAALIT REKISTERI- JA MUUTTUJAMÄÄRITTELYT ---
; (Määrittele nämä tarvittaessa projektisi yhteisessä equ-tiedostossa)
CURSOR_X    equ     $0000A000           ; Kursorin X-koordinaatti RAM-muistissa
CURSOR_Y    equ     $0000A001           ; Kursorin Y-koordinaatti RAM-muistissa

;=============================================================================
; MONITOR_START - Monitorin pääasiallinen käynnistyspiste
;=============================================================================
MONITOR_START:
            ; Nollataan kursorin sijainti vasempaan ylänurkkaan
            clr.b   (CURSOR_X)
            clr.b   (CURSOR_Y)

            ; Tulostetaan käyttöjärjestelmän tervetuliaisviesti
            lea     WELCOME_MSG,a0
            bsr     MONITOR_PRINT_STRING

            ; Tähän väliin tulee myöhemmin komentorivin pääsilmukka (Shell prompt)
.main_loop:
            ; Odotetaan näppäinpainallusta, käsitellään komennot jne.
            bra     .main_loop

;=============================================================================
; MONITOR_PRINT_STRING - Tulostaa nollatavun (\0) päättyvän merkkijonon
; Sisääntulo:
;   a0 = Osoitin tulostettavan merkkijonon alkuun
;=============================================================================
MONITOR_PRINT_STRING:
            movem.l d0/a0,-(sp)
.string_loop:
            move.b  (a0)+,d0            ; Luetaan seuraava merkki
            beq     .string_done        ; Jos merkki on nolla (\0), lopetetaan
            bsr     MONITOR_PUTCHAR     ; Tulostetaan merkki monitorin kautta
            bra     .string_loop
.string_done:
            movem.l (sp)+,d0/a0
            rts

;=============================================================================
; MONITOR_PUTCHAR - Monitorin tulostuslogiikka ohjausmerkeillä
; Sisääntulo:
;   d0.b = Tulostettava ASCII-merkki (tai ohjauskoodi)
;=============================================================================
MONITOR_PUTCHAR:
            movem.l d1-d2,-(sp)

            ; --- OHJAUSMERKKIEN KÄSITTELY ---
            cmp.b   #$0D,d0              ; Carriage Return (\r)
            beq     .handle_newline
            cmp.b   #$0A,d0              ; Line Feed (\n)
            beq     .handle_newline

            ; --- NORMAALIN MERKIN TULOSTUS ---
            moveq   #0,d1
            move.b  (CURSOR_X),d1        ; d1 = Nykyinen X-koordinaatti
            
            moveq   #0,d2
            move.b  (CURSOR_Y),d2        ; d2 = Nykyinen Y-koordinaatti

            ; Kutsutaan kernelin tyhmää piirtäjää (d0=merkki, d1=X, d2=Y)
            bsr     PRINT_CHAR          

            ; Siirretään kursoria yksi merkki oikealle
            addq.b  #1,(CURSOR_X)
            cmp.b   #40,(CURSOR_X)      ; Saavutettiinko rivin oikea reuna (40 merkkiä)?
            blt     .putchar_done       ; Jos ei, homma valmis

            ; --- RIVINVAIHTO JA VIERITYS ---
.handle_newline:
            clr.b   (CURSOR_X)          ; Palautetaan kursori vasempaan reunaan
            addq.b  #1,(CURSOR_Y)       ; Siirrytään seuraavalle riville
            cmp.b   #32,(CURSOR_Y)      ; Menikö ruudun alareunan yli (32 riviä)?
            blt     .putchar_done       ; Jos ei, homma valmis

            ; Jos ollaan alareunassa, vieritetään ruutua ylöspäin
            bsr     SCROLL_UP           ; Kutsutaan kernelin vieritysrutiinia
            move.b  #31,(CURSOR_Y)      ; Lukitaan kursori alimmalle riville

.putchar_done:
            movem.l (sp)+,d1-d2
            rts

;=============================================================================
; DATA-SEKTIO
;=============================================================================
WELCOME_MSG:
            dc.b    "Rocket68 Interrupt-Driven OS", $0D, $0A
            dc.b    "System ready.", $0D, $0A, 0
