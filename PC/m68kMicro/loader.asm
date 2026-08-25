* =============================================================================
* Rocket68 Custom Indexed Bootloader (loader.asm) - 512B PURE MBR VERSION
* =============================================================================
* BIOS lataa tämän osoitteeseen $00005000 kiintolevyn LBA 0:sta.
* Koko ohjelma, data ja allekirjoitus mahtuvat nyt tasan 512 tavuun.

* --- LIITOKSET BIOS-HYPPYKIRJASTOON ---
* =============================================================================
* ROCKET68 BIOS V3.0 - VIRALLISET RAJAPINTAOSOITTEET (JUMP TABLE OFFSETS)
* =============================================================================
B_INIT          EQU     $00001000   ; BIOS Alustusrutiini (Cold Boot)
B_PRINT_CHAR    EQU     $00001006   ; Tulostaa yhden ASCII-merkin (D0=char, D1=X, D2=Y)
B_CLEAR_SCREEN  EQU     $0000100C   ; Tyhjentää ruudun paletin värillä 0 (Musta)
B_SCROLL_UP     EQU     $00001012   ; Skrollaa ruutua yhden tekstirivin verran ylöspäin
B_SCROLL_DOWN   EQU     $00001018   ; Skrollaa ruutua yhden tekstirivin verran alaspäin
B_HDD_READ      EQU     $0000101E   ; DMA-lukulohko (D0=LBA, A0=Kohde-RAM)
B_HDD_WRITE     EQU     $00001024   ; DMA-kirjoituslohko (D0=LBA, A0=Lähde-RAM)
B_PRINT_STR     EQU     $0000102A   ; Tulostaa nollatavuun päättyvän lokijonon (A4=Osoite)
B_GLOBAL_HALT   EQU     $00001030   ; Pysäyttää suorittimen laitteistotasolla (Panic)

            org     $00005000

LOADER_START:
REAL_LBOOT_START:
            lea     MSG_LOAD_DIR(pc),a4 ; PC-suhteellinen osoitus säästää tilaa
            jsr     (B_PRINT_STR)

            ; 1. Ladataan hakemistolohko (LBA 1) väliaikaiseen puskuriin
            move.l  #1,d0               ; LBA = 1
            lea     DIR_BUF_RAM,a0      ; Puskuri RAMissa (Kaukana koodista)
            jsr     (B_HDD_READ)
            tst.b   d0                  ; 0 = OK
            bne     BOOT_ERROR          ; Jos laitevika, hypätään virheeseen

            lea     DIR_BUF_RAM,a0      
            moveq   #15,d7              ; Max 16 tiedostoa

FIND_FILE_LOOP:
            ; Otetaan levyn hakemisto-osoite (a0) talteen a2:een,
            ; koska muuten a0-osoitin siirtyisi vertailussa eteenpäin.
            movea.l a0,a2               
            lea     FILENAME_TARGET(pc),a1
    
.compare_loop:
            move.b  (a1)+,d0            ; Luetaan merkki etsittävästä nimestä, siirretään osoitinta
            beq.s   .found_null         ; Jos se on 0, ollaan päästy loppuun -> nimi täsmää!
            
            cmp.b   (a2)+,d0            ; Verrataan levyltä luettuun merkkiin, siirretään osoitinta
            bne.s   .next_entry         ; Jos eriäväisyys, hyppää seuraavaan tiedostoon
            
            bra.s   .compare_loop       ; Jatkuva silmukka merkeille

.found_null:
            ; Jos päästiin tänne, etsittävän nimen kaikki merkit täsmäsivät levyn nimeen!
            bra     LOAD_TARGET_FILE

.next_entry:
            adda.l  #32,a0             ; Siirrytään seuraavaan aitoon 32 tavun hakemistoalkioon
            dbra    d7,FIND_FILE_LOOP


            ; Jos tiedostoa ei löydy
            lea     MSG_NOT_FOUND(pc),a4
            jsr     (B_PRINT_STR)
            jmp     (B_GLOBAL_HALT)     ; KORJAUS: Suora hyppy BIOSin globaaliin sammutukseen!

BOOT_ERROR:
            ; --- VIRHE: LAITTEISTOVIKA LEVYLLÄ ---
            jmp     (B_GLOBAL_HALT)     ; KORJAUS: Suora hyppy BIOSin globaaliin sammutukseen!

LOAD_TARGET_FILE:
            move.l  12(a0),d2           ; d2 = Aloitus-LBA levyltä
            move.l  20(a0),d3           ; d3 = Koko lohkoina

            lea     MSG_LOADING_SYS(pc),a4
            jsr     (B_PRINT_STR)

            ; 3. Ladataan Monitori lohko kerrallaan osoitteeseen $6000
            movea.l #$00006000,a2       

LOAD_SECTORS_LOOP:
            tst.l   d3                  
            beq     LAUNCH_SYSTEM       
            
            move.l  d2,d0               
            movea.l a2,a0               
            jsr     (B_HDD_READ)
            tst.b   d0
            bne.s   BOOT_ERROR

            addq.l  #1,d2               
            adda.l  #512,a2             
            subq.l  #1,d3               
            bra     LOAD_SECTORS_LOOP

LAUNCH_SYSTEM:
            jmp     $00006000           ; Käynnistetään Monitori!

* --- DATA JA TEKSTIVAKIOT (Mahtuvat hienosti mukaan) ---
            EVEN
FILENAME_TARGET: dc.b "MONITOR.SYS",0   
MSG_LOAD_DIR:    dc.b "Reading volume directory...",10,0
MSG_LOADING_SYS: dc.b "Loading Monitor.sys via index DMA...",10,0
MSG_NOT_FOUND:   dc.b "Fatal: Monitor.sys not found!",10,0

* --- PAKOTETAAN 512 TAVUN KOKO JA SIGNATURE ---
            org     $00005000+510
            dc.b    $4F,$53             ; 'OS'

* --- PUSKURI ---
DIR_BUF_RAM     EQU     $00004500