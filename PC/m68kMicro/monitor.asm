* =============================================================================
* Rocket68 System Monitor (monitor.asm) - OSA 1/2 (Korjattu virhehypyt & DIR)
* =============================================================================
* Tämä ohjelma ladataan muistiin osoitteeseen $00006000.

* --- BIOS API JUMP LIBRARYN OSOITTEET ---
B_PRINT_CHAR    EQU     $00000800
B_CLEAR_SCREEN  EQU     $00000806
B_SCROLL_UP     EQU     $0000080C
B_SCROLL_DOWN   EQU     $00000812
B_HDD_READ      EQU     $00000818
B_HDD_WRITE     EQU     $0000081E
B_PRINT_STR     EQU     $00000824

* --- BIOS GLOBAALIT MUUTTUJAT RAMISSA ---
SYS_TICKS       EQU     $00004010
BIOS_KBD_NEW    EQU     $00004014
BIOS_KBD_CHAR   EQU     $00004015

            org     $00006000

MONITOR_START:
            clr.b   (MON_CUR_X)
            clr.b   (MON_CUR_Y)
            clr.b   (BUF_LEN)
            clr.b   (LAST_TICK)
            clr.b   (CUR_STATE)

            jsr     (B_CLEAR_SCREEN)
            lea     MSG_WELCOME,a4
            jsr     (B_PRINT_STR)

MONITOR_PROMPT:
            move.b  #'>',d0
            move.b  (MON_CUR_X),d1
            move.b  (MON_CUR_Y),d2
            jsr     (B_PRINT_CHAR)
            addq.b  #1,(MON_CUR_X)

            move.b  #' ',d0
            move.b  (MON_CUR_X),d1
            move.b  (MON_CUR_Y),d2
            jsr     (B_PRINT_CHAR)
            addq.b  #1,(MON_CUR_X)

MONITOR_LOOP:
            move.l  (SYS_TICKS),d0
            andi.l  #$0000001F,d0       
            beq     .toggle_cursor      
            clr.b   (LAST_TICK)
            bra     .check_keyboard

.toggle_cursor:
            tst.b   (LAST_TICK)         
            bne     .check_keyboard
            move.b  #1,(LAST_TICK)
            eori.b  #1,(CUR_STATE)      
            bsr     DRAW_MON_CURSOR

.check_keyboard:
            tst.b   (BIOS_KBD_NEW)
            beq     MONITOR_LOOP        

            bsr     ERASE_MON_CURSOR    
            clr.b   (BIOS_KBD_NEW)      
            move.b  (BIOS_KBD_CHAR),d0  

            cmp.b   #$0D,d0             ; ENTER?
            beq     .handle_enter
            cmp.b   #$08,d0             ; BACKSPACE?
            beq     .handle_backspace

            move.b  (BUF_LEN),d1
            cmp.b   #32,d1
            bge     MONITOR_LOOP        
            
            lea     CMD_BUFFER,a0
            ext.w   d1
            move.b  d0,(a0,d1.w)        
            addq.b  #1,(BUF_LEN)        

            move.b  (MON_CUR_X),d1
            move.b  (MON_CUR_Y),d2
            jsr     (B_PRINT_CHAR)
            
            addq.b  #1,(MON_CUR_X)
            cmp.b   #40,(MON_CUR_X)
            bcs     MONITOR_LOOP
            clr.b   (MON_CUR_X)
            addq.b  #1,(MON_CUR_Y)      
            bra     MONITOR_LOOP

.handle_backspace:
            tst.b   (BUF_LEN)
            beq     MONITOR_LOOP        
            subq.b  #1,(BUF_LEN)
            subq.b  #1,(MON_CUR_X)      
            
            move.b  #' ',d0             
            move.b  (MON_CUR_X),d1
            move.b  (MON_CUR_Y),d2
            jsr     (B_PRINT_CHAR)
            bra     MONITOR_LOOP

.handle_enter:
            clr.b   (MON_CUR_X)
            addq.b  #1,(MON_CUR_Y)
            cmp.b   #32,(MON_CUR_Y)
            bcs     .no_scroll
            jsr     (B_SCROLL_UP)
            move.b  #31,(MON_CUR_Y)
.no_scroll:
            bsr     PARSE_COMMAND
            clr.b   (BUF_LEN)           
            bra     MONITOR_PROMPT

* =============================================================================
* KOMENTOTULKKI (Parser & Execution)
* =============================================================================
PARSE_COMMAND:
            tst.b   (BUF_LEN)
            beq     .exit_parse         
            
            lea     CMD_BUFFER,a0
            move.b  (a0),d0             

            ; Muutetaan pienet kirjaimet isoiksi (Upcase)
            cmp.b   #$61,d0
            bcs     .check_cmd
            cmp.b   #$7A,d0
            bhi     .check_cmd
            sub.b   #$20,d0

.check_cmd:
            cmp.b   #'M',d0             ; M = Memory Dump
            beq     CMD_MEMORY_DUMP
            cmp.b   #'R',d0             ; R = Register Dump
            beq     CMD_REG_DUMP
            cmp.b   #'G',d0             ; G = Go
            beq     CMD_GO
            cmp.b   #'L',d0             ; L = Load Sector from HDD
            beq     CMD_LOAD_SECTOR
            cmp.b   #'S',d0             ; S = Save Sector to HDD
            beq     CMD_SAVE_SECTOR
            cmp.b   #'D',d0             ; D = Directory lista komento
            beq     CMD_DIRECTORY

            ; Tuntematon komento
            lea     MSG_ERROR,a4
            jsr     (B_PRINT_STR)
.exit_parse:
            rts
* =============================================================================
* KOMENTOFUNKTIOT JA APURUTIINIT - OSA 2/2
* =============================================================================

* --- L: LOAD SECTOR FROM HDD ---
CMD_LOAD_SECTOR:
            bsr     PARSE_HEX_ARGS      ; d2 = LBA, d3 = RAM osoite
            tst.b   d0                  ; 0 = OK, 1 = Virhe
            bne     MON_SYNTAX_ERR      ; KORJATTU: Globaali hyppy

            move.l  d2,d0               ; LBA lohko BIOSille
            movea.l d3,a0               ; Kohde RAM-osoite BIOSille
            jsr     (B_HDD_READ)        ; Kutsutaan BIOS-DMA lukua
            tst.b   d0                  ; 0 = OK
            bne     MON_HW_ERR          ; KORJATTU: Globaali hyppy

            lea     MSG_L_OK,a4
            jsr     (B_PRINT_STR)
            rts

* --- S: SAVE SECTOR TO HDD ---
CMD_SAVE_SECTOR:
            bsr     PARSE_HEX_ARGS      ; d2 = LBA, d3 = RAM osoite
            tst.b   d0
            bne     MON_SYNTAX_ERR      ; KORJATTU: Globaali hyppy

            move.l  d2,d0               ; LBA lohko BIOSille
            movea.l d3,a0               ; Lähde RAM-osoite BIOSille
            jsr     (B_HDD_WRITE)       ; Kutsutaan BIOS-DMA kirjoitusta
            tst.b   d0
            bne     MON_HW_ERR          ; KORJATTU: Globaali hyppy

            lea     MSG_S_OK,a4
            jsr     (B_PRINT_STR)
            rts


CMD_DIRECTORY:
            movem.l d0-d7/a0-a2,-(sp)   ; Suojataan kaikki rekisterit pinoon

            ; 1. Ladataan kiintolevyn hakemistolohko (LBA 1) väliaikaiseen RAM-puskuriin
            move.l  #1,d0               ; Sektori LBA = 1
            movea.l #DIR_LIST_BUF,a0    ; Kohdeosoite RAM-muistissa
            jsr     (B_HDD_READ)        ; Kutsutaan BIOSin DMA-lukua hyppytaulukosta
            
            tst.b   d0                  ; Tarkistetaan palautuskoodi (0 = OK)
            bne     .dir_hw_error       ; Jos hdd petti, hypätään virheeseen

            ; 2. Käydään läpi hakemiston 16 tiedostoalkiota (32 tavua per alkio)
            movea.l #DIR_LIST_BUF,a0    ; a0 osoittaa ensimmäiseen alkioon
            moveq   #15,d7              ; d7 = Silmukan laskuri (16 alkiota, 15->0)

.loop_entries:
            ; Tarkistetaan onko alkio tyhjä (jos nimen ensimmäinen tavu on $00)
            tst.b   (a0)
            beq     .skip_entry         ; Jos tyhjä, hypätään tämän yli

            ; Tulostetaan tiedoston nimi (Tavut 0-11)
            ; B_PRINT_STR odottaa, että merkkijono päättyy nollaan (\0).
            ; Koska nimi on kiinteä 12 tavua ilman nollaa, käytetään a0-osoitetta suoraan,
            ; mutta varmistetaan tulostus tulostamalla merkki kerrallaan tai pakottamalla loppuun \0.
            ; helpompi tapa: kopioidaan nimi hetkeksi puskuriin ja laitetaan perään \0.
            lea     TMP_NAME_BUF,a1
            moveq   #11,d1              ; 12 merkkiä
.copy_name:
            move.b  (a0,d1.w),(a1,d1.w)
            dbra    d1,.copy_name
            clr.b   12(a1)              ; Pakotetaan nollapääte \0 osoitteeseen +12
            
            movea.l #TMP_NAME_BUF,a4    ; a4 = Merkkijono BIOSille
            jsr     (B_PRINT_STR)       ; Tulostetaan tiedoston nimi ruudulle!

            ; Tulostetaan väli ja ilmoitus koosta
            lea     MSG_DIR_LINE_END,a4
            jsr     (B_PRINT_STR)       ; Tulostetaan rivinvaihto \n seuraavaa varten

.skip_entry:
            adda.l  #32,a0              ; Siirrytään seuraavaan 32-tavuiseen alkioon
            dbra    d7,.loop_entries

            movem.l (sp)+,d0-d7/a0-a2   ; Palautetaan rekisterit
            rts

.dir_hw_error:
            lea     MSG_HW_ERROR,a4
            jsr     (B_PRINT_STR)
            movem.l (sp)+,d0-d7/a0-a2
            rts




* --- YHTEISET GLOBAALIT VIRHEPAIKAT ---
MON_SYNTAX_ERR:
            lea     MSG_ERROR,a4
            jsr     (B_PRINT_STR)
            rts

MON_HW_ERR:
            lea     MSG_HW_ERROR,a4
            jsr     (B_PRINT_STR)
            rts

* --- DUMMY RUNKOKOMENNOT ---
CMD_MEMORY_DUMP:
            lea     MSG_M_DUMMY,a4
            jsr     (B_PRINT_STR)
            rts

CMD_REG_DUMP:
            lea     MSG_R_DUMMY,a4
            jsr     (B_PRINT_STR)
            rts

CMD_GO:
            lea     MSG_G_DUMMY,a4
            jsr     (B_PRINT_STR)
            rts

* =============================================================================
* APURUTIINIT: HEX-PARAMETRIEN PARSINTA
* =============================================================================
PARSE_HEX_ARGS:
            movem.l d1/d4/a0,-(sp)
            lea     CMD_BUFFER,a0
            
            move.b  (BUF_LEN),d0
            cmp.b   #19,d0
            blt     .parse_err

            ; 1. ARGUMENTTI (LBA) osoitteesta a0+2
            lea     2(a0),a1
            moveq   #7,d4               
            moveq   #0,d2
.lba_loop:
            move.b  (a1)+,d1
            bsr     HEX_CHAR_TO_VAL
            cmpi.b  #$FF,d0
            beq     .parse_err          
            lsl.l   #4,d2
            or.b    d0,d2
            dbra    d4,.lba_loop

            ; 2. ARGUMENTTI (RAM) osoitteesta a0+11
            lea     11(a0),a1
            moveq   #7,d4               
            moveq   #0,d3
.ram_loop:
            move.b  (a1)+,d1
            bsr     HEX_CHAR_TO_VAL
            cmpi.b  #$FF,d0
            beq     .parse_err
            lsl.l   #4,d3
            or.b    d0,d3
            dbra    d4,.ram_loop

            moveq   #0,d0               ; d0 = 0 (OK)
            movem.l (sp)+,d1/d4/a0
            rts
.parse_err:
            moveq   #1,d0               ; d0 = 1 (Virhe)
            movem.l (sp)+,d1/d4/a0
            rts

HEX_CHAR_TO_VAL:
            cmp.b   #$30,d1
            bcs     .not_hex
            cmp.b   #$39,d1
            bhi     .check_alpha
            sub.b   #$30,d1             
            move.b  d1,d0
            rts
.check_alpha:
            cmp.b   #$61,d1
            bcs     .is_upper
            sub.b   #$20,d1
.is_upper:
            cmp.b   #$41,d1
            bcs     .not_hex
            cmp.b   #$46,d1
            bhi     .not_hex
            sub.b   #$37,d1             
            move.b  d1,d0
            rts
.not_hex:
            move.b  #$FF,d0
            rts

* --- NÄYTTÖGRAFIIKAN APURUTIINIT ---
DRAW_MON_CURSOR:
            tst.b   (CUR_STATE)
            beq     .clear_c
            move.b  #$5F,d0             
            bra     .draw
.clear_c:
            move.b  #' ',d0             
.draw:
            move.b  (MON_CUR_X),d1
            move.b  (MON_CUR_Y),d2
            jsr     (B_PRINT_CHAR)
            rts

ERASE_MON_CURSOR:
            move.b  #' ',d0
            move.b  (MON_CUR_X),d1
            move.b  (MON_CUR_Y),d2
            jsr     (B_PRINT_CHAR)
            rts

* =============================================================================
* DATALOHKOT JA REKISTERIVARAUKSET
* =============================================================================
            EVEN
MSG_WELCOME:  dc.b  "Rocket68 Command Monitor v1.1 Ready.",10,0
MSG_ERROR:    dc.b  "Syntax error! Use: L/S [LBA_HEX] [RAM_HEX]",10,0
MSG_HW_ERROR: dc.b  "Hardware I/O error from virtual HDD!",10,0
MSG_L_OK:     dc.b  "Sector loaded successfully via DMA.",10,0
MSG_S_OK:     dc.b  "Sector saved successfully via DMA.",10,0
MSG_DIR_DUMMY:dc.b  "DIR-Command: Volume indexing listing here.",10,0
MSG_M_DUMMY:  dc.b  "M-Command: Hex dump routine here.",10,0
MSG_R_DUMMY:  dc.b  "R-Command: CPU Register matrix here.",10,0
MSG_G_DUMMY:  dc.b  "G-Command: Jump to address routine here.",10,0

            EVEN
MON_CUR_X:    ds.b    1                   
MON_CUR_Y:    ds.b    1                   
BUF_LEN:      ds.b    1                   
LAST_TICK:    ds.b    1                   
CUR_STATE:    ds.b    1                   
CMD_BUFFER:   ds.b    32                  

            EVEN
MSG_DIR_LINE_END: dc.b  10,0            ; Rivinvaihto tiedostojen väliin

            org     $00007500           ; Varataan puskurit turvalliseen paikkaan kaukana koodista
TMP_NAME_BUF:  ds.b    13               ; Tilaa nimelle + \0
DIR_LIST_BUF:  ds.b    512              ; 512 tavun väliaikaispuskuri LBA 1:lle
            end     MONITOR_START
