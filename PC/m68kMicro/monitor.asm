* =============================================================================
* Rocket68 Operating System Monitor (monitor.asm) - WORD MMIO WINDOW VERSION
* =============================================================================
* Loader lataa tämän ja hyppää osoitteeseen $00006000.

* --- LIITOKSET BIOS-HYPPYKIRJASTOON ($0F00 ALUE) ---
B_PRINT_CHAR    EQU     $00000F00
B_CLEAR_SCREEN  EQU     $00000F06
B_HDD_READ      EQU     $00000F18           ; KORJAUS: Päivitetty osoite $0818 -> $0F18
B_PRINT_STR     EQU     $00000F24
B_GLOBAL_HALT   EQU     $00000F30
HDD_WINDOW      EQU     $001F0000           ; Maagisen muisti-ikkunan aloitusosoite

            org     $00006000

MONITOR_START:
            ; 1. Tulostetaan Monitorin tervetuliaislogo
            lea     MSG_MON_WELCOME(pc),a4
            jsr     (B_PRINT_STR)

MONITOR_LOOP:
            ; 2. Tulostetaan komentorivikehote (Prompt) "> "
            lea     MSG_PROMPT(pc),a4
            jsr     (B_PRINT_STR)

            ; 3. Odotetaan näppäinsyötettä (Toteutetaan tässä yksinkertainen polling-haku)
            ; Koska emulaattori paukuttaa Keyboard-tilaa, luetaan merkki livenä.
            ; Jos näppäimistöä ei ole vielä kytketty keskeytyksiin, monitori voi odottaa tässä.
            ; Tehdään toistaiseksi simuloitu "odota D-näppäintä" tai suora suoritus testausta varten,
            ; mutta ajetaan DIR suoraan käynnistyksessä, jotta nähdään sen toimivuus heti livenä!

            jmp     *   ;B_GLOBAL_HALT

            bra.s   CMD_DIRECTORY       ; TESTI: Ajetaan DIR automaattisesti käynnistyksessä!

* =============================================================================
* D: DIRECTORY LISTING (Aito muisti-ikkunapohjainen DIR)
* =============================================================================
CMD_DIRECTORY:
            movem.l d0-d2/a0-a2,-(sp)   ; Suojataan rekisterit pinoon

            ; 1. Pyydetään BIOSia lataamaan tiedostotaulukko (LBA 1) muisti-ikkunaan
            move.l  #1,d0               ; Sektori LBA = 1 (Hakemisto)
            suba.l  a0,a0               ; a0 = 0 (Kertoo BIOSille, ettei kopioida muualle RAMiin)
            jsr     (B_HDD_READ)        ; Kutsutaan BIOS-lukua ($00000F18)
            
            tst.b   d0                  ; Palauttiko BIOS 0 (OK)?
            bne.s   .dir_hw_error       ; Jos tuli virhe, poistutaan

            ; 2. Luetaan tiedostorivi suoraan maagisesta ikkunasta ($001F0000)
            lea     (HDD_WINDOW),a0     ; a0 osoittaa ensimmäiseen 32-tavuiseen alkioon
            moveq   #15,d7              ; Tarkistetaan max 16 tiedostoalkiota (15 -> 0)

.loop_entries:
            tst.b   (a0)                ; Onko nimen ensimmäinen merkki \0 (tyhjä alkio)?
            beq.s   .skip_entry         ; Jos tyhjä, siirrytään seuraavaan

            ; 3. Kopioidaan 12-tavuinen tiedostonimi väliaikaiseen puskuriin tulostusta varten
            lea     TMP_NAME_BUF,a1
            moveq   #11,d1              ; 12 merkkiä (0-11)
.copy_name:
            move.b  (a0,d1.w),(a1,d1.w)
            dbra    d1,.copy_name
            clr.b   12(a1)              ; Pakotetaan nollapääte \0 string-tulostusta varten

            ; 4. Tulostetaan tiedoston nimi ruudulle BIOS-rutiinilla
            movea.l #TMP_NAME_BUF,a4
            jsr     (B_PRINT_STR)

            ; Tulostetaan rivinvaihto \n seuraavaa tiedostoa varten
            lea     MSG_DIR_NL,a4
            jsr     (B_PRINT_STR)

.skip_entry:
            adda.l  #32,a0              ; Siirrytään seuraavaan 32-tavuiseen alkioon (tiedostoriviin)
            dbra    d7,.loop_entries

            movem.l (sp)+,d0-d2/a0-a2   ; Palautetaan rekisterit pinosta
            jmp     MONITOR_LOOP        ; Palataan komentorivisilmukkaan!

.dir_hw_error:
            lea     MSG_HW_ERROR,a4
            jsr     (B_PRINT_STR)
            movem.l (sp)+,d0-d2/a0-a2
            jmp     MONITOR_LOOP

* =============================================================================
* DATA JA TEKSTIVAKIOT
* =============================================================================
            EVEN
MSG_MON_WELCOME: dc.b 10,"--- Rocket68 Command Monitor v1.0 ---",10,0
MSG_PROMPT:      dc.b "> ",0
MSG_DIR_NL:      dc.b 10,0
MSG_HW_ERROR:    dc.b "[ERROR] Hakemiston luku levylta epäonnistui!",10,0

* =============================================================================
* MONITORIN GLOBAALIT RAM-PUSKURIT
* =============================================================================
            org     $00007500           ; Sijoitetaan puskurit turvallisen kauas koodista
TMP_NAME_BUF:  ds.b    13               ; Tilaa 12 merkille + \0
