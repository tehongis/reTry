* =============================================================================
* Rocket68 Pure BIOS / HAL with Hard Disk Autoboot & Boot Logs
* =============================================================================

* --- LAITTEISTON VAKIOMÄÄRITTELYT ---
VBLANK      EQU     $001FFFFB
BEEP_REG    EQU     $001FFFFC
KEYBOARD    EQU     $001FFFFF
FB_START    EQU     $00200000
PALETTE     EQU     $00214000
FONT_ROM    EQU     $00220000

HDD_PAGE     EQU $001FFF00 ; LBA-sektori (Long)
HDD_DMA_ADDR EQU $001FFF04 ; DMA Kohde/Lähdeosoite RAMissa (Long)
HDD_CMD      EQU $001FFF08 ; Komentorekisteri (1=Lue DMA, 2=Kirjoita DMA)
INT_CLEAR    EQU $001FFF0C ; Keskeytyskuittaus

EXT_APP_START   EQU     $00005000


            org     $00000000

* --- 1. PAKOLLISET ALUSTUSVEKTORIT (Offset 0 - 7) ---
            dc.l    $00080000           ; SP: Initial Stack Pointer ($00000000)
            dc.l    $00001000           ; PC: Initial Program Counter ($00000004) -> Kone starttaa tonnista

* --- 2. TÄYTETÄÄN VECTORIT 2 - 24 NOLLALLA (Offset 8 - 99 / $08 - $63) ---
            ; Varataan tilaa muille prosessorin poikkeuksille (Bus Error, Illegal jne.)
            ; $64 - $08 = 92 tavua -> 23 kpl 32-bittisiä pitkäsanoja (dc.l)
            dcb.l   23,0                ; Täytetään 23 seuraavaa vektoripaikkaa puhtaasti nollalla

* --- 3. NYT OLLAAN REAALIAJASSA OSOITTEESSA $00000064 (Autovektorit 1 - 4) ---
            dc.l    INT_HDD             ; Level 1 ($00000064)
            dc.l    INT_KEYBOARD        ; Level 2 ($00000068)
            dc.l    INT_VBLANK          ; Level 3 ($0000006C)
            dc.l    INT_TIMER           ; Level 4 ($00000070)

* --- 4. TÄYTETÄÄN LOPUT VEKTORIPÖYDÄSTÄ JA VARATAAN VÄLI OSOITTEESEEN $1000 ASTI ---
            ; Autovektoreiden jälkeen ollaan osoitteessa $00000074.
            ; Lasketaan täytettä tonniin asti: $1000 - $74 = 3980 tavua.
            ds.b    $1000-$00000074     ; Pakotetaan kääntäjä täyttämään loppuosa nollilla

* =============================================================================
* VIRALLINEN HYPPYTAULUKKO - TÄSMÄLLEEN OSOITTEESSA $00001000
* =============================================================================
 
B_INIT:           jmp     BIOS_INIT
B_PRINT_CHAR:     jmp     PRINT_CHAR
B_CLEAR_SCREEN:   jmp     CLEAR_SCREEN
B_SCROLL_UP:      jmp     SCROLL_UP
B_SCROLL_DOWN:    jmp     SCROLL_DOWN
B_HDD_READ:       jmp     HDD_READ_SECTOR
B_HDD_WRITE:      jmp     HDD_WRITE_SECTOR
B_PRINT_STR:      jmp     BIOS_PRINT_STR
B_GLOBAL_HALT:    jmp     GLOBAL_HALT    

BIOS_INIT:

            move.w  #$2700,sr
            
            ; Nollataan järjestelmän muuttujat
            clr.l   (USER_VBLANK)
            clr.l   (USER_KBD)
            clr.l   (USER_HDD)
            clr.l   (USER_TIMER)
            clr.l   (SYS_TICKS)
            clr.b   (BIOS_KBD_NEW)
            clr.b   (BIOS_KBD_CHAR)
            clr.b   (BIOS_HDD_DONE)

            ; Alustetaan väripaletti (Musta tausta, valkoinen teksti)
            movea.l #PALETTE,a0
            clr.l   (a0)+
            move.l  #$00FFFFFF,(a0)+

            bsr     CLEAR_SCREEN
            
            ; Asetetaan aloituskoordinaatit lokitulostukselle
            clr.b   (L_CUR_X)
            clr.b   (L_CUR_Y)

            ; Tulostetaan tervetuloviesti
            lea     MSG_WELCOME,a4
            bsr     BIOS_PRINT_STR

            ; Sallitaan keskeytykset (SR = $2000)
            move.w  #$2000,sr

* --- AUTOBOOT LOGIIKKA ---
            lea     MSG_HDD_INIT,a4
            bsr     BIOS_PRINT_STR

            ; Luetaan LBA 0 (Kovalevyn ensimmäinen sektori) väliaikaiseen puskuriin
            moveq   #0,d0               ; LBA = 0
            lea     BOOT_SECTOR_BUF,a0  ; Kohdepuskuri RAM-muistissa
            bsr     HDD_READ_SECTOR     ; Luetaan sektori
            tst.b   d0                  ; Tarkistetaan palautuskoodi (0 = OK)
            bne     BOOT_ERROR_IO

            lea     MSG_CHECK_SIG,a4
            bsr     BIOS_PRINT_STR

            ; KORJAUS: Ei luoteta a0-rekisteriin, koska PRINT_CHAR on voinut muuttaa sitä.
            ; Luetaan maagiset tavut suoraan absoluuttisesta muistiosoitteesta BOOT_SECTOR_BUF + 510.
            
            move.l  #BOOT_SECTOR_BUF+510,a1 ; Käytetään a1-rekisteriä varmuuden vuoksi
            
            ; Testataan tavu 510 (Pitäisi olla 'O' = $4F)
            cmp.b   #$4F,(a1)
            bne     BOOT_ERROR_MAGIC

            ; Testataan tavu 511 (Pitäisi olla 'S' = $53)
            cmp.b   #$53,1(a1)
            bne     BOOT_ERROR_MAGIC

            ; --- JOS MOLEMMAT TÄSMÄÄVÄT, JATKETAAN LATAUKSEEN ---
            lea     MSG_BOOT_OK,a4
            bsr     BIOS_PRINT_STR


            ; Allekirjoitus kunnossa! Ilmoitetaan latauksesta
            lea     MSG_BOOT_OK,a4
            bsr     BIOS_PRINT_STR

            ; Kopioidaan loader (510 tavua) sovellusosoitteeseen
            lea     BOOT_SECTOR_BUF,a0  ; Lähde
            movea.l #EXT_APP_START,a1   ; Kohde ($00005000)
            move.w  #254,d0             ; (255 * 2) = 510 tavua
COPY_BOOTLOADER:
            move.w  (a0)+,(a1)+
            dbra    d0,COPY_BOOTLOADER

            ; Hypätään ladatun loader.exe:n suoritukseen!
            jmp     EXT_APP_START

BOOT_ERROR_IO:
            lea     MSG_ERR_IO,a4
            bsr     BIOS_PRINT_STR
            move.w  #1000,(BEEP_REG)    ; Korkea vikapiip
            jmp     GLOBAL_HALT           ; Hypätään globaaliin sammutukseen

BOOT_ERROR_MAGIC:
            lea     MSG_ERR_SIG,a4
            bsr     BIOS_PRINT_STR
            move.w  #200,(BEEP_REG)     ; Matala virhepiip
            jmp     GLOBAL_HALT           ; Hypätään globaaliin sammutukseen

* =============================================================================
* BIOS MERKKIJONOTULOSTIN (Apufunktio lokeille)
* =============================================================================
BIOS_PRINT_STR:
            movem.l d0-d2,-(sp)
.loop_char:
            move.b  (a4)+,d0
            beq     .str_done
            
            ; Haetaan nykyiset kursoripositiot
            move.b  (L_CUR_X),d1
            move.b  (L_CUR_Y),d2
            
            ; Tarkistetaan rivinvaihto \n (ASCII 10)
            cmp.b   #10,d0
            beq     .newline
            
            ; Tulostetaan merkki näytölle
            bsr     PRINT_CHAR
            
            ; Kasvatetaan X-koordinaattia
            addq.b  #1,d1
            cmp.b   #40,d1
            bcs     .save_coords
.newline:
            clr.b   d1                  ; X = 0
            addq.b  #1,d2               ; Y++
            cmp.b   #32,d2
            bcs     .save_coords
            bsr     SCROLL_UP           ; Skrollataan jos ruutu täynnä
            move.b  #31,d2
.save_coords:
            move.b  d1,(L_CUR_X)
            move.b  d2,(L_CUR_Y)
            bra     .loop_char
.str_done:
            movem.l (sp)+,d0-d2
            rts

* =============================================================================
* KESKEYTYSKÄSITTELIJÄT
* =============================================================================
INT_VBLANK:
            movem.l d0/a0,-(sp)

            move.b  (VBLANK),d0
            movea.l (USER_VBLANK),a0
            cmpa.l  #0,a0
            beq     NO_VBL_HOOK
            jsr     (a0)
NO_VBL_HOOK:

            move.w  #1,(INT_CLEAR)  

            movem.l (sp)+,d0/a0
            rte

INT_KEYBOARD:
            movem.l d0/a0,-(sp)

            move.b  (KEYBOARD),d0
            beq     KBD_EXIT
            btst    #7,d0
            bne     KEY_RELEASED
            andi.b  #$7F,d0
            lea     SCANCODE_LUT,a0
            move.b  (a0,d0.w),d0
            beq     KBD_EXIT
            move.b  d0,(BIOS_KBD_CHAR)
            move.b  #1,(BIOS_KBD_NEW)
            movea.l (USER_KBD),a0
            cmpa.l  #0,a0
            beq     KBD_EXIT
            jsr     (a0)
            bra     KBD_EXIT
KEY_RELEASED:
            clr.b   (KEYBOARD)
KBD_EXIT:
            move.w  #1,(INT_CLEAR)  

            movem.l (sp)+,d0/a0
            rte

INT_HDD:
            movem.l d0/a0,-(sp)

            move.b  #1,(DMA_READY)      ; Asetetaan valmiusflagi
            move.w  #1,(INT_CLEAR)      ; Kuittaus emulaattorille

            movem.l (sp)+,d0/a0    rte    

INT_TIMER:
            movem.l d0/a0,-(sp)

            addq.l  #1,(SYS_TICKS)
            movea.l (USER_TIMER),a0
            cmpa.l  #0,a0
            beq     NO_TIMER_HOOK
            jsr     (a0)
NO_TIMER_HOOK:

            move.w  #-1,(INT_CLEAR)  

            movem.l (sp)+,d0/a0
            rte

HDD_READ_SECTOR:
            move.l  d0,-(sp)            ; Suojataan d0 pinon kautta
            
            clr.b   (DMA_READY)         ; Nollataan valmius-flagi
            move.l  a0,(HDD_DMA_ADDR)   ; Kohdeosoite RAMissa
            move.l  d0,(HDD_PAGE)       ; Haluttu sektori
            move.w  #1,(HDD_CMD)        ; Laukaistaan DMA-luku

.wait_dma:
            tst.b   (DMA_READY)
            beq.s   .wait_dma           ; Korjattu: Ei ä-kirjainta nimeen

            move.l  (sp)+,d0            ; Palautetaan d0
            rts

HDD_WRITE_SECTOR:
    move.l  d0,-(sp)            ; Suojataan d0 pinon kautta
    
    clr.w   (DMA_READY)         ; Nollataan valmius-flagi ennen aloitusta
    move.l  a0,(HDD_DMA_ADDR)   ; Lähdeosoite RAM-muistissa (mistä kirjoitetaan)
    move.l  d0,(HDD_PAGE)       ; Kohde-sektori (LBA) kiintolevyllä
    move.w  #2,(HDD_CMD)        ; Laukaistaan DMA-kirjoitus komennolla 2

.wait_dma_write:
    tst.w   (DMA_READY)
    beq.s   .wait_dma_write     ; Odotetaan, kunnes INT_HDD kuittaa siirron valmiiksi

    move.l  (sp)+,d0            ; Palautetaan d0 pinosta
    moveq   #0,d0              ; Palautetaan 0 (Success) merkiksi onnistumisesta
    rts

CLEAR_SCREEN:
            movea.l #FB_START,a0
            move.w  #20479,d0
CS_LOOP:    clr.l   (a0)+
            dbra    d0,CS_LOOP
            rts

SCROLL_UP:
            movea.l #FB_START,a0       
            lea     2560(a0),a1         
            move.w  #19839,d0          
SCROLL_LOOP_UP:
            move.l  (a1)+,(a0)+
            dbra    d0,SCROLL_LOOP_UP
            move.w  #639,d0             
FILL_BLANK_UP:
            clr.l   (a0)+
            dbra    d0,FILL_BLANK_UP
            rts

SCROLL_DOWN:
            movea.l #FB_START+81600,a0 
            movea.l #FB_START+81600,a1 
            lea     -2560(a0),a0
            move.l  #19759,d0
SCROLL_LOOP_DOWN:
            move.l  -(a0),-(a1) 
            dbra    d0,SCROLL_LOOP_DOWN
            movea.l #FB_START,a0
            move.w  #639,d0 
            moveq   #0,d1 
FILL_BLANK_DOWN:
            move.l  d1,(a0)+ 
            dbra    d0,FILL_BLANK_DOWN
            rts

PRINT_CHAR:
            movem.l d1-d6/a0-a1,-(sp)
            andi.l  #$000000FF,d0 
            lsl.l   #3,d0 
            movea.l #FONT_ROM,a0 
            adda.l  d0,a0 
            andi.l  #$000000FF,d2 
            lsl.l   #3,d2 
            mulu.w  #320,d2 
            andi.l  #$000000FF,d1 
            lsl.l   #3,d1 
            movea.l #FB_START,a1 
            adda.l  d2,a1
            adda.l  d1,a1 
            moveq   #7,d4 
DRAW_ROW:
            move.b  (a0)+,d5 
            moveq   #7,d6 
DRAW_ROW_LOOP:
            btst    d6,d5 
            beq     BG_PIXEL
            move.b  #1,(a1)+ 
            bra     NEXT_PIXEL
BG_PIXEL:
            move.b  #0,(a1)+ 
NEXT_PIXEL:
            dbra    d6,DRAW_ROW_LOOP
            lea     312(a1),a1 
            dbra    d4,DRAW_ROW
            movem.l (sp)+,d1-d6/a0-a1
            rts

GLOBAL_HALT:
.HALTLOOP   stop    #$2700
            bra.s   .HALTLOOP

* =============================================================================
* LOOKUP-TAULUKOT, MERKKIJONOT JA RAM-MUUTTUJAT
* =============================================================================
            EVEN
BIOS_HDD_TARGET_RAM:  ds.l    1             ; Varataan 4 tavua (Long) kohdemuistiosoitteelle
USER_VBLANK:  ds.l    1
USER_KBD:     ds.l    1
USER_HDD:     ds.l    1
USER_TIMER:   ds.l    1
SYS_TICKS:    ds.l    1

DMA_READY:   ds.w 1        ; Flagi, joka asetetaan 1 kun keskeytys saapuu

BIOS_KBD_NEW: ds.b    1
BIOS_KBD_CHAR:ds.b    1
BIOS_HDD_DONE:ds.b    1
BIOS_HDD_STATUS_REG: ds.b 1             ; UUSI: Tila keskeytyksestä palautettavalle statukselle
L_CUR_X:      ds.b    1                  ; BIOS-lokin oma X-kursori
L_CUR_Y:      ds.b    1                  ; BIOS-lokin oma Y-kursori

BOOT_SECTOR_BUF: ds.b 512

            EVEN
MSG_WELCOME:  dc.b  "Rocket68 Bios V3.0 - Initializing...",10,0
MSG_HDD_INIT: dc.b  "Accessing virtual HDD (LBA 0)...",10,0
MSG_CHECK_SIG:dc.b  "Checking boot signature...",10,0
MSG_BOOT_OK:  dc.b  "Success: Launching loader.exe...",10,0
MSG_ERR_IO:   dc.b  "Fatal: HDD read error!",10,0
MSG_ERR_SIG:  dc.b  "Fatal: No bootable signature found!",10,0
MSG_DIRECT_BOOT: dc.b "Esiladattu RAM-kayttojarjestelma havaittu. Kaynnistetaan Monitori...",10,0
            EVEN
SCANCODE_LUT:
            dc.b    0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 8, 9
            dc.b    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', $0D, 0, 'A', 'S'
            dc.b    'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', $27, '`', 0, $5C, 'Z', 'X', 'C', 'V'
            dc.b    'B', 'N', 'M', ',', '.', '/', 0, '*', 0, ' ', 0, 0, 0, 0, 0, 0

            
            end