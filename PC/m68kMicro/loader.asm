* =============================================================================
* Rocket68 Custom Indexed Bootloader (loader.asm) - 512B PURE MBR VERSION
* =============================================================================
* BIOS lataa tämän osoitteeseen $00005000 kiintolevyn LBA 0:sta.
* Koko ohjelma, data ja allekirjoitus mahtuvat nyt tasan 512 tavuun.

* --- LIITOKSET BIOS-HYPPYKIRJASTOON ---
B_HDD_READ      EQU     $00000818           
B_PRINT_STR     EQU     $00000824           
B_GLOBAL_HALT   EQU     $00000830           ; UUSI: Järjestelmätason globaali hätäjarru

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

            ; 2. Etsitään tiedosto "MONITOR.SYS" hakemistosta
            lea     DIR_BUF_RAM,a0      
            moveq   #15,d7              ; Max 16 tiedostoa

FIND_FILE_LOOP:
            lea     FILENAME_TARGET(pc),a1
            moveq   #10,d1              ; 11 merkkiä
compare_loop:
            move.b  (a0,d1.w),d0
            cmp.b   (a1,d1.w),d0
            bne     next_entry          
            dbra    d1,compare_loop

            ; Tiedosto löytyi!
            bra     LOAD_TARGET_FILE

next_entry:
            adda.l  #32,a0              
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
FILENAME_TARGET: dc.b "MONITOR.SYS "   
MSG_LOAD_DIR:    dc.b "Reading volume directory...",10,0
MSG_LOADING_SYS: dc.b "Loading Monitor.sys via index DMA...",10,0
MSG_NOT_FOUND:   dc.b "Fatal: Monitor.sys not found!",10,0

* --- PAKOTETAAN 512 TAVUN KOKO JA SIGNATURE ---
            org     $00005000+510
            dc.b    $4F,$53             ; 'OS'

* --- PUSKURI ---
DIR_BUF_RAM     EQU     $00004500