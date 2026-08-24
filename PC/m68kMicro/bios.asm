* =============================================================================
* Rocket68 Kernel & OS Monitor (Modular Architecture V2.5) - OSA 1/4
* =============================================================================

* --- LAITTEISTON VAKIOMÄÄRITTELYT ---
VBLANK      EQU     $001FFFFB           ; VBLANK rekisteri (1 = uusi ruutu)
BEEP_REG    EQU     $001FFFFC           ; Aanilaite (Word: Hz taajuus)
KEYBOARD    EQU     $001FFFFF           ; Nappaimisto (Byte: b7=Make/Break)
FB_START    EQU     $00200000           ; Framebufferin alku (320x256, 8-bit)
PALETTE     EQU     $00214000           ; Palettimuistin alku (256 * RGBQUAD)
FONT_ROM    EQU     $00220000           ; Toshiba FONT.ROM sijainti RAMissa

            org     $00000000

* --- M68k Vektoritaulukko ---
            dc.l    $00080000           ; Initial Stack Pointer (SSP)
            dc.l    KERNEL_START        ; Initial Program Counter (PC)

* --- M68k Autovektorikeskeytykset (Kernel-ohjatut) ---
            org     $00000064
            dc.l    INT_VBLANK          ; Level 1: VBLANK
            dc.l    INT_KEYBOARD        ; Level 2: Keyboard

            org     $00001000

* =============================================================================
* KERNEL: ALUSTUS JA KESKEYTYKSET
* =============================================================================
KERNEL_START:
            ; Nollataan kernelin ja monitorin muuttujat
            clr.b   (CURSOR_X)
            clr.b   (CURSOR_Y)
            clr.b   (BLINK_CTR)
            clr.b   (BLINK_STATE)
            clr.b   (KBD_NEW)
            clr.b   (KBD_CHAR)
            clr.b   (BUF_LEN)

            ; Alustetaan väripaletti
            movea.l #PALETTE,a0
            clr.l   (a0)+               ; Väri 0 = Musta (Tausta)
            move.l  #$00FFFFFF,(a0)+    ; Väri 1 = Valkoinen (Teksti)

            bsr     CLEAR_SCREEN
            
            lea     SYS_MSG,a4
            bsr     PRINT_STRING

            move.w  #$2000,sr           ; Enabloidaan keskeytykset, siirrytään Monitoriin
            bra     MONITOR_MAIN

* --- KERNEL KESKEYTYKSET ---

INT_VBLANK:
            move.b  (VBLANK),d0         ; Kuitataan keskeytys laitteelta
            addq.b  #1,(BLINK_CTR)      ; Kasvatetaan laskuria monitoria varten
            rte

INT_KEYBOARD:
            movem.l d0/a0,-(sp)
            move.b  (KEYBOARD),d0
            beq     .kbd_exit
            
            btst    #7,d0               ; Testataan bitti 7 (0=Make, 1=Break)
            bne     .key_rel
            
            andi.b  #$7F,d0             ; Puhdistetaan bitti 7
            
            ; Muunnetaan Scancode ASCIIksi (LUT Monitoria varten)
            lea     SCANCODE_LUT,a0
            move.b  (a0,d0.w),d0
            beq     .kbd_exit           ; Jos 0, merkkiä ei tueta
            
            move.b  d0,(KBD_CHAR)       ; Tallennetaan merkki puskuriin
            move.b  #1,(KBD_NEW)        ; Asetetaan "uusi näppäin" -lippu
            bra     .kbd_exit
.key_rel:
            clr.b   (KEYBOARD)          ; Kuitataan vapautus
.kbd_exit:
            movem.l (sp)+,d0/a0
            rte
* =============================================================================
* MONITOR: KÄYTTÄJÄKERROS - OSA 2/4
* =============================================================================
MONITOR_MAIN:
            move.b  #62,d0              ; '>' Prompt
            bsr     PRINT_CHAR
            move.b  #32,d0              ; Välilyönti
            bsr     PRINT_CHAR

.monitor_loop:
            ; --- Kursorin vilkutuslogiikka (Monitoriohjattu) ---
            cmp.b   #30,(BLINK_CTR)
            blt     .check_keyboard
            clr.b   (BLINK_CTR)
            eori.b  #1,(BLINK_STATE)
            bsr     RENDER_CURSOR_BLOCK

.check_keyboard:
            tst.b   (KBD_NEW)           ; Onko uutta näppäintä tullut?
            beq     .monitor_loop       ; Jos ei, jatketaan silmukkaa
            
            bsr     ERASE_CURSOR        ; Pyyhitään kursori ennen tulostusta
            clr.b   (KBD_NEW)           ; Kuitataan merkki luetuksi
            move.b  (KBD_CHAR),d0       ; d0 = Painettu ASCII-merkki

            ; Tarkistetaan ENTER ($0D)
            cmp.b   #$0D,d0
            beq     .handle_enter

            ; Tarkistetaan BACKSPACE ($08)
            cmp.b   #$08,d0
            beq     .handle_backspace

            ; Lisätään merkki komentopuskuriin, jos mahtuu (max 32 merkkiä)
            move.b  (BUF_LEN),d1
            cmp.b   #32,d1
            bge     .monitor_loop       
            
            lea     CMD_BUFFER,a0
            ext.w   d1
            move.b  d0,(a0,d1.w)        ; Tallennetaan merkki
            addq.b  #1,(BUF_LEN)        ; Kasvatetaan puskurin kokoa
            
            bsr     PRINT_CHAR          ; Kaiutetaan merkki ruudulle
            bra     .monitor_loop

.handle_backspace:
            tst.b   (BUF_LEN)
            beq     .monitor_loop       ; Puskuri tyhjä, skipataan
            subq.b  #1,(BUF_LEN)
            subq.b  #1,(CURSOR_X)       ; Siirretään kursoritilaa taaksepäin
            move.b  #32,d0              ; Tulostetaan tyhjä merkki päälle
            bsr     PRINT_CHAR
            subq.b  #1,(CURSOR_X)       ; Korjataan kursorin X takaisin
            bra     .monitor_loop

.handle_enter:
            move.b  #$0D,d0             ; Rivinvaihto ruudulle
            bsr     PRINT_CHAR
            
            bsr     PARSE_AND_EXECUTE   ; Suoritetaan komento!
            
            clr.b   (BUF_LEN)           ; Tyhjennetään komentopuskuri
            
            move.b  #62,d0              ; '>'
            bsr     PRINT_CHAR
            move.b  #32,d0              ; ' '
            bsr     PRINT_CHAR
            bra     .monitor_loop

* --- KOMENTOTULKKI (Parsinta ja suoritus) ---
PARSE_AND_EXECUTE:
            tst.b   (BUF_LEN)
            beq     .parse_done         ; Tyhjä rivi
            
            lea     CMD_BUFFER,a0
            move.b  (a0),d0             ; Otetaan ensimmäinen merkki
            
            ; Muutetaan pieni kirjain suureksi (esim m -> M)
            cmp.b   #$61,d0
            blt     .check_uppercase
            cmp.b   #$7A,d0
            bgt     .check_uppercase
            sub.b   #$20,d0             
            
.check_uppercase:
            cmp.b   #$4D,d0             ; Komento 'M' (Memory Dump)
            beq     .exec_m
            cmp.b   #$47,d0             ; Komento 'G' (Go / Jump)
            beq     .exec_g
            cmp.b   #$52,d0             ; Komento 'R' (Register Dump)
            beq     .exec_r
            
            ; Tuntematon komento
            lea     ERR_MSG,a4
            bsr     PRINT_STRING
            rts

.exec_m:
            lea     2(a0),a1
            bsr     HEX_TO_LONG         ; Alkuosoite puskurista d0:aan
            move.l  d0,d2               ; d2 = Alkuosoite
            
            lea     11(a0),a1
            bsr     HEX_TO_LONG         ; Loppuosoite puskurista d0:aan
            move.l  d0,d3               ; d3 = Loppuosoite
            
            bsr     DO_HEX_DUMP
            rts

.exec_g:
            lea     2(a0),a1
            bsr     HEX_TO_LONG         ; Kohdeosoite d0:aan
            movea.l d0,a0
            
            move.w  #220,(BEEP_REG)     ; Ääniindikaattori ennen hyppyä
            jmp     (a0)                ; Hypätään koodiin!

.exec_r:
            bsr     DO_REG_DUMP
.parse_done:
            rts
* =============================================================================
* MONITORI-KOMENNOT JA DATAMUUNNOKSET - OSA 3/4
* =============================================================================

* --- CPU REKISTERIEN TULOSTUS (R-KOMENTO) ---
DO_REG_DUMP:
            movem.l d0-d7/a0-a7,(REG_SAVE) ; Tallennetaan nykyiset tilat varjoon
            move.w  sr,(SR_SAVE)
            
            movem.l d0-d2/a0-a4,-(sp)   
            
            ; 1. Tulostetaan datarekisterit (D0-D7)
            lea     DREG_TXT,a4
            bsr     PRINT_STRING
            
            lea     REG_SAVE,a0         
            moveq   #7,d1               
            moveq   #0,d2               
.d_loop:
            move.b  #'D',d0
            bsr     PRINT_CHAR
            move.b  d2,d0
            add.b   #$30,d0             
            bsr     PRINT_CHAR
            move.b  #'=',d0
            bsr     PRINT_CHAR
            
            move.l  (a0)+,d0            
            bsr     PRINT_HEX_LONG
            
            move.b  #$20,d0             
            bsr     PRINT_CHAR
            addq.b  #1,d2
            cmp.b   #4,d2
            bne     .no_d_nl
            move.b  #$0D,d0             
            bsr     PRINT_CHAR
.no_d_nl:
            dbra    d1,.d_loop
            move.b  #$0D,d0
            bsr     PRINT_CHAR

            ; 2. Tulostetaan osoiterekisterit (A0-A7)
            lea     AREG_TXT,a4
            bsr     PRINT_STRING
            
            lea     REG_SAVE+32,a0      
            moveq   #7,d1
            moveq   #0,d2
.a_loop:
            move.b  #'A',d0
            bsr     PRINT_CHAR
            move.b  d2,d0
            add.b   #$30,d0
            bsr     PRINT_CHAR
            move.b  #'=',d0
            bsr     PRINT_CHAR
            
            move.l  (a0)+,d0
            bsr     PRINT_HEX_LONG
            
            move.b  #$20,d0
            bsr     PRINT_CHAR
            addq.b  #1,d2
            cmp.b   #4,d2
            bne     .no_a_nl
            move.b  #$0D,d0
            bsr     PRINT_CHAR
.no_a_nl:
            dbra    d1,.a_loop
            move.b  #$0D,d0
            bsr     PRINT_CHAR

            ; 3. Tulostetaan statusrekisteri (SR)
            lea     SR_TXT,a4
            bsr     PRINT_STRING
            moveq   #0,d0
            move.w  (SR_SAVE),d0
            bsr     PRINT_HEX_BYTE      
            move.b  #$0D,d0
            bsr     PRINT_CHAR

            movem.l (sp)+,d0-d2/a0-a4
            rts

* --- HEX DUMP TOTEUTUS (M-KOMENTO) ---
DO_HEX_DUMP:
            movem.l d0-d4/a0,-(sp)
.dump_line:
            cmp.l   d3,d2
            bhi     .dump_exit          ; Jos alku > loppu, poistutaanko
            
            move.l  d2,d0
            bsr     PRINT_HEX_LONG
            move.b  #$3A,d0             ; ':'
            bsr     PRINT_CHAR
            move.b  #$32,d0             ; ' '
            bsr     PRINT_CHAR
            
            movea.l d2,a0
            moveq   #7,d4
.hex_loop:
            move.b  (a0)+,d0
            bsr     PRINT_HEX_BYTE
            move.b  #$32,d0             ; Välilyönti
            bsr     PRINT_CHAR
            dbra    d4,.hex_loop
            
            move.b  #$0D,d0             ; Rivinvaihto
            bsr     PRINT_CHAR
            
            addq.l  #8,d2               ; Seuraavat 8 tavua
            bra     .dump_line
.dump_exit:
            movem.l (sp)+,d0-d4/a0
            rts

* --- APURUTIINIT: MUUNNOKSET ---

HEX_TO_LONG:
            movem.l d1-d3/a1,-(sp)
            moveq   #0,d0
            moveq   #7,d2               
.loop:
            moveq   #0,d1
            move.b  (a1)+,d1
            beq     .done               
            cmp.b   #$39,d1
            bhi     .letter
            sub.b   #$30,d1             
            bra     .shift
.letter:
            andi.b  #$DF,d1             ; Pakotetaan suuraakkoseksi
            sub.b   #$37,d1             
.shift:
            lsl.l   #4,d0
            or.b    d1,d0
            dbra    d2,.loop
.done:
            movem.l (sp)+,d1-d3/a1
            rts

PRINT_HEX_LONG:
            movem.l d0-d2,-(sp)
            move.l  d0,d2
            moveq   #7,d1               
.l_loop:
            rol.l   #4,d2               
            move.b  d2,d0
            andi.b  #$0F,d0
            bsr     PRINT_NIBBLE
            dbra    d1,.l_loop
            movem.l (sp)+,d0-d2
            rts

PRINT_HEX_BYTE:
            movem.l d0-d1,-(sp)
            move.b  d0,d1
            lsr.b   #4,d0               
            bsr     PRINT_NIBBLE
            move.b  d1,d0               
            andi.b  #$0F,d0
            bsr     PRINT_NIBBLE
            movem.l (sp)+,d0-d1
            rts

PRINT_NIBBLE:
            cmp.b   #9,d0
            bhi     .char_a_f
            add.b   #$30,d0             
            bra     .out
.char_a_f:
            add.b   #$37,d0             
.out:
            bsr     PRINT_CHAR
            rts
* =============================================================================
* BIOS MATALAN TASON GRAFIIKKARUTIINIT JA DATA - OSA 4/4
* =============================================================================

PRINT_STRING:
            move.l  d0,-(sp)
.str_loop:
            move.b  (a4)+,d0
            beq     .str_exit
            bsr     PRINT_CHAR
            bra     .str_loop
.str_exit:
            move.l  (sp)+,d0
            rts

CLEAR_SCREEN:
            movea.l #FB_START,a0
            move.w  #20479,d0           
.clear_loop:
            clr.l   (a0)+
            dbra    d0,.clear_loop
            clr.b   (CURSOR_X)
            clr.b   (CURSOR_Y)
            rts

SCROLL_UP:
            movea.l #FB_START,a0       
            lea     2560(a0),a1         
            move.w  #19839,d0          
.scroll_loop:
            move.l  (a1)+,(a0)+
            dbra    d0,.scroll_loop

            move.w  #639,d0             
.fill_blank:
            clr.l   (a0)+
            dbra    d0,.fill_blank

            subq.b  #1,(CURSOR_Y)      
            rts

SCROLL_DOWN:
            movem.l d0-d2/a0-a1,-(sp)

            ; --- 1. KOPIOINTI ALHAALTA YLÖSPÄIN ---
            ; Kokonaiskoko = 320 * 256 = 81600 tavua.
            ; Siirrettävä määrä (31 riviä) = 320 * 8 * 31 = 79040 tavua.
            ; Yhden merkkirivin siirtymä = 320 * 8 = 2560 tavua.
            
            movea.l #FB_START+81600,a0   ; Lähde-osoitin: Ruudun aivan loppu
            movea.l #FB_START+81600,a1   ; Kohde-osoitin: Ruudun aivan loppu + siirtymä
            
            ; Peruutetaan osoittimia siirrettävän datan verran taaksepäin
            ; Koska kopioidaan takaperin, a0 (lähde) alkaa kohdasta (End - 2560)
            lea     -2560(a0),a0         
            
            ; Lasketaan kuinka monta pitkäsanaa (LONG = 4 tavua) siirretään
            ; 79040 tavua / 4 = 19760 pitkäsanaa.
            ; dbra-silmukka ajaa N+1 kertaa, joten laskuri = 19759
            move.l  #19759,d0            

.copy_loop:
            move.l  -(a0),-(a1)          ; Kopioidaan 4 tavua kerrallaan takaperin
            dbra    d0,.copy_loop

            ; --- 2. YLIMMÄN RIVIN TYHJENNYS ---
            ; Ensimmäiset 2560 tavua täytetään nollalla (musta väri)
            movea.l #FB_START,a0
            move.w  #639,d0              ; 2560 tavua / 4 (LONG) = 640. dbra-laskuri = 639
            moveq   #0,d1                ; Tyhjennysväri = 0 (musta)

.clear_loop:
            move.l  d1,(a0)+             ; Kirjoitetaan mustaa nollaa eteenpäin
            dbra    d0,.clear_loop

            movem.l (sp)+,d0-d2/a0-a1
            rts


;=============================================================================
; PRINT_CHAR - Piirtää 8x8 merkin annettuihin koordinaatteihin
; Sisääntulot:
;   d0.b = ASCII-merkki
;   d1.b = X-koordinaatti (sarake, 0-39)
;   d2.b = Y-koordinaatti (rivi, 0-31)
;=============================================================================
PRINT_CHAR:
            movem.l d1-d6/a0-a1,-(sp)   

            andi.l  #$000000FF,d0        ; Puhdistetaan d0 sisältämään vain ASCII-tavu
            
            ; --- FONTIN OSOITTEEN LASKENTA ---
            lsl.l   #3,d0               ; d0 = merkki * 8 (tavua per merkki)
            movea.l #FONT_ROM,a0        ; Osoitetaan fontin alkuun
            adda.l  d0,a0               ; a0 = tämän merkin bittikartan alkuosoite

            ; --- RUUTUOSOITTEEN LASKENTA (VRAM / FB) ---
            ; Lasketaan pystysuuntainen offset (Y * 8 pikseliriviä * 320 pikseliä leveys)
            andi.l  #$000000FF,d2        ; Varmistetaan puhdas Y-arvo
            lsl.l   #3,d2               ; Y-pikseli = Y * 8
            mulu.w  #320,d2             ; d2 = Y-pikselirivin aloituskohta näytöllä
            
            ; Lasketaan vaakasuuntainen offset (X * 8 pikseliä leveyttä)
            andi.l  #$000000FF,d1        ; Varmistetaan puhdas X-arvo
            lsl.l   #3,d1               ; X-pikseli = X * 8
            
            movea.l #FB_START,a1        ; Framebufferin alkuosoite
            adda.l  d2,a1
            adda.l  d1,a1               ; a1 osoittaa nyt ruudulla merkin vasempaan ylänurkkaan

            ; --- MERKIN PIIRTÄMINEN (8 RIVIÄ) ---
            moveq   #7,d4               ; Silmukka 8 riville (7..0)
.draw_row:
            move.b  (a0)+,d5            ; Luetaan fontin rivitavu
            moveq   #7,d6               ; Silmukka 8 sarakkeelle/bitille (7..0)
.draw_col:
            btst    d6,d5               ; Testataan bittiä vasemmalta oikealle (MSB -> LSB)
            beq     .bg_pixel
            move.b  #1,(a1)+            ; Piirretään tekstiväri (1 = keltainen)
            bra     .next_pixel
.bg_pixel:
            move.b  #0,(a1)+            ; Piirretään taustaväri (0 = musta)
.next_pixel:
            dbra    d6,.draw_col
            lea     312(a1),a1          ; Siirrytään näytöllä seuraavan rivin alkuun (320 - 8 pikseliä)
            dbra    d4,.draw_row

            movem.l (sp)+,d1-d6/a0-a1
            rts

* =============================================================================
* DATALOHKOT JA MUUTTUJAT (Sijoitettu loppuun)
* =============================================================================
            EVEN
SYS_MSG:    dc.b    "ROCKET68 KERNEL V2.5 BOOTED",$0D,0
ERR_MSG:    dc.b    "SYNTAX ERROR",$0D,0
DREG_TXT:   dc.b    "DATA REGISTERS:",$0D,0
AREG_TXT:   dc.b    "ADDRESS REGISTERS:",$0D,0
SR_TXT:     dc.b    "STATUS REGISTER (SR): $",0

SCANCODE_LUT:
            dc.b    0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 8, 9
            dc.b    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', $0D, 0, 'A', 'S'
            dc.b    'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', $27, '`', 0, $5C, 'Z', 'X', 'C', 'V'
            dc.b    'B', 'N', 'M', ',', '.', '/', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0

* Järjestelmän RAM-muuttujat (Sijoitus turvallisesti osoitteeseen $4000)
            org     $00004000
            EVEN
CURSOR_X:   ds.b    1
CURSOR_Y:   ds.b    1
BLINK_CTR:  ds.b    1
BLINK_STATE:ds.b    1

KBD_NEW:    ds.b    1                   
KBD_CHAR:   ds.b    1                   
BUF_LEN:    ds.b    1                   
CMD_BUFFER: ds.b    32                  

REG_SAVE:   ds.l    16                  ; Varjoalue 16 CPU-rekisterille (D0-D7, A0-A7)
SR_SAVE:    ds.w    1                   ; Varjoalue Status Registerille (SR)

            end     KERNEL_START
