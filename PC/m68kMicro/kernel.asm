;=============================================================================
; KERNEL.ASM - Laitteistoalustus, Keskeytysvektorit ja VRAM-grafiikka
;=============================================================================

; --- LAITTEISTOKONSTANTIT (VRAM JA EMULAATTORI) ---
FB_START    equ     $00010000           ; Framebufferin / VRAM:in alkuosoite RAM-muistissa
FONT_ROM    equ     $000F0000           ; FONT.ROM binäärin latausosoite muistissa

;=============================================================================
; M68000 KESKEYTYSVEKTORITAULUKKO (Sijaitsee osoitteesta $00000000 alkaen)
;=============================================================================
            org     $00000000
            
            ; --- JÄRJESTELMÄN KÄYNNISTYS (RESET) ---
            dc.l    $00008000           ; Vektori 0: Alkuperäinen pinon osoite (Stack Pointer)
            dc.l    START               ; Vektori 1: Käynnistysosoite (Reset Vector)

            ; --- JÄRJESTELMÄVIRHEVEKTORIT ---
            dc.l    DEFAULT_HANDLER     ; Vektori 2: Bus Error
            dc.l    DEFAULT_HANDLER     ; Vektori 3: Address Error
            dc.l    DEFAULT_HANDLER     ; Vektori 4: Illegal Instruction
            dc.l    DEFAULT_HANDLER     ; Vektori 5: Zero Divide (Nollalla jako)
            dc.l    DEFAULT_HANDLER     ; Vektori 6: CHK Instruction
            dc.l    DEFAULT_HANDLER     ; Vektori 7: TRAPV Instruction
            dc.l    DEFAULT_HANDLER     ; Vektori 8: Privilege Violation
            dc.l    DEFAULT_HANDLER     ; Vektori 9: Trace Interrupt
            dc.l    DEFAULT_HANDLER     ; Vektori 10: Line 1010 Emulator
            dc.l    DEFAULT_HANDLER     ; Vektori 11: Line 1111 Emulator
            ; Vektorit 12-23 Varattu prosessorille
            dcb.l   12,DEFAULT_HANDLER

            ; --- JÄRJESTELMÄN PERUSKESKEYTYKSET ---
            dc.l    DEFAULT_HANDLER     ; Vektori 24: Spurious Interrupt
            
            ; --- AUTOTEVETORIKESKEYTYKSET (LEVEL 1-7) ---
            dc.l    DEFAULT_HANDLER     ; Level 1: Esim. Toissijaiset laitteet
            dc.l    KEYBOARD_ISR        ; Level 2: NÄPPÄIMISTÖN KESKEYTYS (Esimerkki)
            dc.l    DEFAULT_HANDLER     ; Level 3: Esim. Verkkokortti / Sarjaportti
            dc.l    DEFAULT_HANDLER     ; Level 4: Esim. Ajastin (Timer)
            dc.l    DEFAULT_HANDLER     ; Level 5: Varattu
            dc.l    DEFAULT_HANDLER     ; Level 6: Varattu
            dc.l    DEFAULT_HANDLER     ; Level 7: NMI (Non-Maskable Interrupt)

            ; --- TRAP-KESKEYTYKSET (0-15) ---
            ; Voidaan käyttää myöhemmin järjestelmäkutsuina (System Calls)
            dcb.l   16,DEFAULT_HANDLER

            ; --- LOPUT KESKEYTYSVEKTORIT (Käyttäjän määritettävissä 64-255) ---
            dcb.l   192,DEFAULT_HANDLER

;=============================================================================
; START - Järjestelmän fyysinen käynnistyspiste
;=============================================================================
START:
            ; Säädetään M68k tilarekisteri (Status Register)
            ; Sallitaan kaikki keskeytystasot (SR = $2000 kytkee Supervisor moden päälle)
            move.w  #$2000,sr           

            ; Kun matalan tason alustus on valmis, siirretään kontrolli monitorille
            bra     MONITOR_START

;=============================================================================
; KESKEYTYKSEN KÄSITTELIJÄT (ISR - Interrupt Service Routines)
;=============================================================================

; --- NÄPPÄIMISTÖN KESKEYTYSRUTIINI ---
KEYBOARD_ISR:
            movem.l d0-d7/a0-a6,-(sp)    ; Otetaan kaikki rekisterit talteen

            ; 1. Tähän tulee myöhemmin emulaattorisi näppäimistöportin luku
            ; Esim: move.b (KEYBOARD_DATA_REG), d0
            
            ; 2. Kutsutaan monitorin puolella olevaa näppäimistökäsittelijää
            ; jsr    MONITOR_HANDLE_KEY

            movem.l (sp)+,d0-d7/a0-a6    ; Palautetaan rekisterit
            rte                         ; Return from Exception (Pakollinen M68k keskeytyksille!)

; --- GENEERINEN TURVAKÄSITTELIJÄ VIRHEILLE ---
DEFAULT_HANDLER:
            ; Jos emulaattorissa tapahtuu virhe (kuten nollalla jako), 
            ; lukitaan prosessori tähän silmukkaan, jotta se ei ala suorittaa roskaa.
            nop
            bra     DEFAULT_HANDLER


;=============================================================================
; RAUTARAJAPINTA (VRAM RUTIINIT) --- Tästä eteenpäin koodi pysyy samana...
;=============================================================================
PRINT_CHAR:
            movem.l d1-d6/a0-a1,-(sp)

            andi.l  #$000000FF,d0        ; Puhdistetaan d0 sisältämään vain ASCII-tavu
            
            ; --- FONTIN OSOITTEEN LASKENTA ---
            lsl.l   #3,d0               ; d0 = merkki * 8 (tavua per merkki uusi font.asm)
            movea.l #FONT_ROM,a0        ; Osoitetaan puhtaan fontin alkuun
            adda.l  d0,a0               ; a0 = tämän merkin bittikartan ensimmäinen rivi

            ; --- RUUTUOSOITTEEN LASKENTA (VRAM) ---
            andi.l  #$000000FF,d2        ; Puhdistetaan Y-arvo varmuuden vuoksi
            lsl.l   #3,d2               ; Y-pikselirivi = Y * 8
            mulu.w  #320,d2             ; d2 = Y-akselin muistioffset (leveys 320 px)
            
            andi.l  #$000000FF,d1        ; Puhdistetaan X-arvo varmuuden vuoksi
            lsl.l   #3,d1               ; X-pikselisarake = X * 8
            
            movea.l #FB_START,a1        ; Framebufferin alkuosoite
            adda.l  d2,a1
            adda.l  d1,a1               ; a1 osoittaa nyt ruudulla merkin vasempaan ylänurkkaan

            ; --- MERKIN PIIRTÄMINEN RUUDULLE (8 RIVIÄ) ---
            moveq   #7,d4               ; Silmukka 8 pystyriville (7..0)
.draw_row:
            move.b  (a0)+,d5            ; Luetaan fontin rivitavu ja kasvatetaan a0
            moveq   #7,d6               ; Silmukka 8 vaakapikselille (7..0)
.draw_col:
            btst    d6,d5               ; Testataan bittiä vasemmalta oikealle (MSB -> LSB)
            beq     .bg_pixel
            move.b  #1,(a1)+            ; Pikseli päällä: Tekstiväri (1 = keltainen)
            bra     .next_pixel
.bg_pixel:
            move.b  #0,(a1)+            ; Pikseli pois: Taustaväri (0 = musta)
.next_pixel:
            dbra    d6,.draw_col
            lea     312(a1),a1          ; Siirrytään VRAM:issa seuraavalle riville (320 - 8 pikseliä)
            dbra    d4,.draw_row

            movem.l (sp)+,d1-d6/a0-a1
            rts

;=============================================================================
; SCROLL_UP - Vierittää ruutua yhden merkkirivin (8 px) YLÖSPÄIN
; Tyhjentää alimman rivin mustaksi.
;=============================================================================
SCROLL_UP:
            movem.l d0-d2/a0-a1,-(sp)

            ; Kopioidaan rivejä 1-31 ylöspäin rivin 0 päälle
            ; Siirrettävä määrä = 320 * 8 * 31 = 79040 tavua
            movea.l #FB_START+2560,a0    ; Lähde: toisen merkkirivin alku (320 * 8 = 2560)
            movea.l #FB_START,a1         ; Kohde: ruudun alku
            
            move.l  #19759,d0            ; 79040 tavua / 4 (LONG) = 19760 lohkoa. dbra-laskuri = 19759
.copy_up_loop:
            move.l  (a0)+,(a1)+          ; Kopioidaan 4 tavua kerrallaan eteenpäin
            dbra    d0,.copy_up_loop

            ; Tyhjennetään alin jätetty merkkirivi mustaksi (2560 tavua)
            move.w  #639,d0              ; 2560 tavua / 4 (LONG) = 640 lohkoa. dbra-laskuri = 639
            moveq   #0,d1                ; Tyhjennysväri = 0 (musta)
.clear_up_loop:
            move.l  d1,(a1)+             ; Kirjoitetaan nollaa a1 osoittamaan loppupäähän
            dbra    d0,.clear_up_loop

            movem.l (sp)+,d0-d2/a0-a1
            rts

;=============================================================================
; SCROLL_DOWN - Vierittää ruutua yhden merkkirivin (8 px) ALASPÄIN
; Tyhjentää ylimmän rivin mustaksi (hyödyllinen ruutueditoreille).
;=============================================================================
SCROLL_DOWN:
            movem.l d0-d2/a0-a1,-(sp)

            ; Kopioidaan ruudun sisältöä alaspäin takaperin aloittaen muistin lopusta
            movea.l #FB_START+81600,a0   ; Lähde-osoitin: Ruudun fyysinen loppu (320 * 256 = 81600)
            movea.l #FB_START+81600,a1   ; Kohde-osoitin: Ruudun fyysinen loppu
            lea     -2560(a0),a0         ; Siirretään lähde osoittamaan yhtä merkkiriviä ylemmäs
            
            move.l  #19759,d0            ; 79040 siirrettävää tavua / 4 = 19760 pitkäsanaa. Laskuri = 19759
.copy_down_loop:
            move.l  -(a0),-(a1)          ; Kopioidaan LONG kerrallaan takaperin
            dbra    d0,.copy_down_loop

            ; Tyhjennetään ylin merkkirivi mustaksi (ensimmäiset 2560 tavua)
            movea.l #FB_START,a0
            move.w  #639,d0              ; 2560 tavua / 4 = 640 pitkäsanaa. Laskuri = 639
            moveq   #0,d1                ; Tyhjennysväri = 0 (musta)
.clear_down_loop:
            move.l  d1,(a0)+             ; Täytetään ruudun alkuosa nollilla
            dbra    d0,.clear_down_loop

            movem.l (sp)+,d0-d2/a0-a1
            rts
