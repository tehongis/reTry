
	include "LVOs.i"

; =============================================================================
; ------- Init
; =============================================================================

	SECTION Code,CODE

Start:

	lea		BitmapA,a0
	move.l  a0,FrontBuffer     
	lea		BitmapB,a1
	move.l  a1,BackBuffer     

	move.l	a0,d0
	move.w  d0,Bpl1PtrLo            
	swap.w   d0
	move.w  d0,Bpl1PtrHi            

	move.l	a0,d0                   
	add.l	#40,d0
	move.w  d0,Bpl2PtrLo            
	swap.w    d0
	move.w  d0,Bpl2PtrHi  

    lea     CUSTOM,a6
	lea		ModuleData,a0
	moveq.l	#0,d0
	jsr		pt_Init

	move.l  EXECBASE,a6
	jsr     _LVOForbid(a6)

	move.l  EXECBASE,a6
	jsr     _LVODisable(a6)

    lea     CUSTOM,a6
	move.w  #INT_CLR,INTENA(a6)
	move.w  #DMA_MASTER+DMA_SPRITE+DMA_BITPLANE+DMA_COPPER+DMA_BLITTER+DMA_AUDIO,DMACON(a6)

	move.l  #CopperList,d0
	swap    d0                      
	move.w  d0,COP1LCH(a6)          
	swap    d0                      
	move.w  d0,COP1LCL(a6)          
	move.w  #0,COPJMP1(a6)

	move.w  #DMA_SET+DMA_MASTER+DMA_BITPLANE+DMA_COPPER+DMA_BLITTER+DMA_AUDIO,DMACON(a6)

	move.w  #INT_CLR,INTREQ(a6)
	move.l  #VBlank_IRQ,VEC_INT3
	move.w  #INT_SET+INT_MASTER+INT_VERTB,INTENA(a6)       ; Sallitaan vain VBlank-keskeytys

.Wait4Ever
	bne     .Wait4Ever

; =============================================================================
; ---- VBlank IRQ
; =============================================================================

VBlank_IRQ:
	movem.l d0-d7/a0-a6,-(sp)    ; Tallenna kaikki rekisterit pinoon turvaan


	jsr		pt_Music

	move.l	FrameCounter,d0
	and.w	#$4ffe,d0
	move.l  BackBuffer,a0
	eor.w   #-1,(a0,d0.w)


	eor.w	#-1,d0
	and.w	#$4ffe,d0
	move.l  FrontBuffer,a0
	eor.w   #-1,(a0,d0.w)

	addq.l  #1,FrameCounter         

	lea     CUSTOM,a0
	move.w  #INT_VERTB,INTREQ(a0)
	move.w  #INT_VERTB,INTREQ(a0)

	movem.l (sp)+,d0-d7/a0-a6    ; Palautetaan kaikki rekisterit pinosta puhtaasti
	rte                          ; Palataan keskeytyksestä takaisin


SwapBuffers:
	lea		BitmapA,a1
	move.l	FrontBuffer,d1
	cmp.l 	a1,d1
	beq.s	.swapToB

	move.l  a1,FrontBuffer
	lea		BitmapB,a1
	move.l  a1,BackBuffer
	bra.s	.joinks

.swapToB:
	lea		BitmapB,a1
	move.l  a1,FrontBuffer
	lea		BitmapA,a1
	move.l  a1,BackBuffer
.joinks:       


; ---- Update copperlist
	move.l	FrontBuffer,d0
	move.l	d0,d1                   
	add.l   #40,d1                  
	move.w  d0,Bpl1PtrLo            
	swap.w  d0
	move.w  d0,Bpl1PtrHi            
	move.w  d1,Bpl2PtrLo            
	swap.w  d1
	move.w  d1,Bpl2PtrHi            

	rts

; =============================================================================
; ---- Blitter
; =============================================================================

; Clear 
; Inputs:  a0 = Tyhjennettävän puskurin kantaosoite (BackBuffer)
ClearBlitterBuffer:
	lea     CUSTOM,a1

.WaitBlitTest:
	btst    #DMACONR_BB,DMACONR(a1)
	bne.s   .WaitBlitTest

	move.w  #$0100,BLTCON0(a1)      ; Vain kanava D päällä, mintermi $00 (nollaus)
	move.w  #$0000,BLTCON1(a1)
	move.w  #0,BLTDMOD(a1)          ; Ei moduulihyppyä
	move.l  a0,BLTDPTH(a1)          ; Kohdeosoite (BackBuffer)
	move.w  #$7f14,BLTSIZE(a1)       ; Käynnistää pienen testityhjennyksen
	rts

; LineDraw ; 
; Inputs:  a0 = bittitason kantaosoite (BackBuffer)
;          d0 = X0, d1 = Y0
;          d2 = X1, d3 = Y1
DrawBlitterLine:
	lea     CUSTOM,a1

.WaitBlitLine:
	btst    #DMACONR_BB,DMACONR(a1)
	bne.s   .WaitBlitLine

	; --- 1. ALOITUSOSOITTEEN LASKENTA (Y0 * 80 + (X0 / 16) * 2) ---
	move.w  d0,d4                   ; d4 = X0 kopio
	move.w  d1,d5                   ; d5 = Y0 kopio

	mulu.w  #80,d5                  ; 2 bittitasoa interleaved = 80 tavua per rivi
	add.l   d5,a0

	lsr.w   #4,d4                   ; X0 / 16 = Word-paikka linjalla
	add.w   d4,d4                   ; Tavut (* 2)
	ext.l   d4
	add.l   d4,a0                   ; a0 = Kohdeosoite Word-rajalla

	; --- 2. PIKSELISIIRTO LAITTEISTOLLE ---
	move.w  d0,d4                   
	and.w   #15,d4                  ; d4 = X0 & 15
	ror.w   #4,d4                   ; Siirretään bitteihin 12-15
	or.w    #$104A,d4               ; USEA, USEC, USED, Mintermi $4A (D = A XOR C)
	; HUOMIO: Linjamoodissa XOR ($4A) tai OR ($5A) ovat molemmat laillisia, 
	; mutta standardi Bresenham vaatii $4A kytkeytyäkseen oikein Agnus-siruun.

	; --- 3. ETÄISYYDET JA SUUNNAT (Bresenham) ---
	moveq   #0,d5                   ; d5 = Oktantti-indeksi
	sub.w   d0,d2                   ; dx = X1 - X0
	bpl.s   .dx_pos
	neg.w   d2                      ; abs(dx)
	addq.w  #2,d5                   ; DX negatiivinen
.dx_pos:
	sub.w   d1,d3                   ; dy = Y1 - Y0
	bpl.s   .dy_pos
	neg.w   d3                      ; abs(dy)
	addq.w  #4,d5                   ; DY negatiivinen
.dy_pos:
	cmp.w   d2,d3                   ; Kumpi akseli on hallitseva?
	ble.s   .x_dom
	exg     d2,d3                   ; d2 = Max, d3 = Min
	addq.w  #1,d5                   ; Y-hallitseva
.x_dom:

	; Haetaan suuntabitti taulukosta
	add.w   d5,d5
	lea     OctantTable(pc),a5
	move.w  (a5,d5.w),d6            ; d6 = Valmis BLTCON1 perussana (Line mode)

	; --- 4. BRESENHAM-PARAMETRIEN LASKENTA (SUOJATTU PITKILLÄ SANOILLA) ---
	; Tehdään kaikki matemaattiset operaatiot pitkinä sanoina (.l), 
	; jotta merkkibitit ja ylivuodot säilyvät täysin oikeina.
	
	; BLTAMOD = 4 * (Min - Max)
	move.w  d3,d0
	sub.w   d2,d0
	ext.l   d0
	lsl.l   #2,d0                   ; d0 = 4 * (Min - Max)

	; BLTBMOD = 4 * Min
	move.w  d3,d1
	ext.l   d1
	lsl.l   #2,d1                   ; d1 = 4 * Min

	; BLTAPT (Virhetekijä) = 4 * Min - 2 * Max
	move.w  d3,d7
	ext.l   d7
	lsl.l   #2,d7                   ; 4 * Min (Longword)
	
	move.w  d2,d3
	ext.l   d3
	lsl.l   #1,d3                   ; 2 * Max (Longword)
	
	sub.l   d3,d7                   ; d7 = 4 * Min - 2 * Max (32-bittinen signed!)

	; Asetetaan SIGN-bitti jos virhetekijä on negatiivinen
	tst.l   d7                      ; Testataan pitkänä sanana!
	bpl.s   .sign_ok
	or.w    #SIGN_BIT,d6            ; Kytketään SIGN-bitti päälle
.sign_ok:

	; --- 5. REKISTEREIDEN KIRJOITUS LAITTEISTOLLE ---
	move.w  #$FFFF,BLTAFWM(a1)
	move.w  #$FFFF,BLTALWM(a1)
	
	; Asetetaan interleaved-modulot (40 tavua)
	move.w  #40,BLTCMOD(a1)          
	move.w  #40,BLTDMOD(a1)          
	
	move.w  #$8000,BLTADAT(a1)      ; Line texture maski ($8000 = yhtenäinen viiva)
	move.w  #$FFFF,BLTBDAT(a1)      ; Solid pattern

	move.w  d0,BLTAMOD(a1)          ; 16 alinta bittiä riittää laitteistolle
	move.w  d1,BLTBMOD(a1)          
	move.w  d4,BLTCON0(a1)          ; Shift + Mintermi $4A
	move.w  d6,BLTCON1(a1)          ; Oktantti + SIGN-bitti
	move.l  d7,BLTAPT(a1)           ; Bresenham-alustusvirhe pitkänä sanana!
	move.l  a0,BLTCPTH(a1)          ; Kohde taustana (C)
	move.l  a0,BLTDPTH(a1)          ; Kohde (D)

	; Viivan pituus käynnistää Blitterin: (Max_Pituus + 1) << 6 | 2
	move.w  d2,d0                   
	addq.w  #1,d0                   
	lsl.w   #6,d0                   
	addq.w  #2,d0                   
	move.w  d0,BLTSIZE(a1)          

	rts

; =============================================================================
; VertlineTest
; Inputs:  a0 = bittitason kantaosoite (BitmapA + 20)
; =============================================================================
DrawStaticTestLine:
	lea     CUSTOM,a1

	; 1. Odotetaan että Blitter on vapaa (Varmistus, ettei sotketa rautaa)
.WaitBlitTest:
	btst    #14,$002(a1)            ; $002 = DMACONR, bitti 14 = BB
	bne.s   .WaitBlitTest

	; 2. Linjamoodin alustus
	; Kytketään päälle USEA, USEC, USED ja Mintermi $4A (D = A XOR C).
	; Tämä kääntää pikselit aina käänteiseksi taustasta, jolloin viivan on pakko näkyä!
	move.w  #$104A,$040(a1)         ; $040 = BLTCON0
	move.w  #$0005,$042(a1)         ; $042 = BLTCON1 (Y-hallitseva, suoraan alaspäin, bitti 0 = LINE)

	; 3. Modulot nollaksi (Pystyviivassa suoraan alaspäin ei tarvita erikoishypäyksiä)
	move.w  #0,$064(a1)             ; $064 = BLTAMOD
	move.w  #0,$062(a1)             ; $062 = BLTBMOD
	move.w  #0,$060(a1)             ; $060 = BLTCMOD
	move.w  #0,$066(a1)             ; $066 = BLTDMOD

	; 4. Bresenham-alustusvirhe nollaksi pystyviivalle
	move.l  #0,$050(a1)             ; $050 = BLTAPT

	; --- KRIITTINEN KORJAUS: LADATAAN DATALUKU REKISTEREIHIN JOKA KERTA ---
	move.w  #$FFFF,$044(a1)         ; $044 = BLTAFWM
	move.w  #$FFFF,$046(a1)         ; $046 = BLTALWM
	
	; Ladataan A- ja B-datarekisterit täsmälleen ennen käynnistystä!
	move.w  #$8000,$074(a1)         ; $074 = BLTADAT (Pakotetaan ykkösbitti päälle!)
	move.w  #$FFFF,$072(a1)         ; $072 = BLTBDAT (Solid linja)

	; 5. Syötetään osoitteet (Pääohjelmasta tuotu BitmapA + 20)
	move.l  a0,$048(a1)             ; $048 = BLTCPTH
	move.l  a0,$054(a1)             ; $054 = BLTDPTH

	; 6. Käynnistetään Blitter (Piirretään 100 linjaa korkea pätkä)
	; (100 << 6) | 2 = 6400 | 2 = 6402
	move.w  #6402,$058(a1)          ; $058 = BLTSIZE -> Käynnistyy!

	rts


; =============================================================================
; ---- Musicplayer
; =============================================================================

	include "protracker-player.asm"

; =============================================================================
; ---- Data and variables
; =============================================================================
	EVEN
GfxName:        dc.b    "graphics.library",0
	EVEN
GfxBase:        dc.l    0
OldView:        dc.l    0
OldVector:      ds.l    1
	EVEN
OldDMA:         ds.w    1
	EVEN
OldINT:         ds.w    1
	EVEN
FrontBuffer:    dc.l    0
	EVEN
BackBuffer:     dc.l    0
	EVEN
FrameCounter:   dc.l    0
	EVEN

OctantTable:
	dc.w    $0001, $0009, $0011, $0019, $0005, $000D, $0015, $001D
	EVEN

	SECTION Data,DATA_C

BitmapA:        
	dcb.b   40*256*2,0                
	EVEN                        

BitmapB:        
	dcb.b   40*256*2,0                


	EVEN

CopperList:
	; --- 2. RUUDUN KOOT JA REKISTERIT ---
	dc.w    BPLCON0,$3200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000

	dc.w    DIWSTRT,$2C81,DIWSTOP,$2CC1
	dc.w    DDFSTRT,$0038,DDFSTOP,$00D0

	dc.w    BPL1MOD,$0028
	dc.w    BPL2MOD,$0028


	dc.w    BPL1PTH
Bpl1PtrHi:
	dc.w    0
	dc.w    BPL1PTL
Bpl1PtrLo:
	dc.w    0

	dc.w    BPL2PTH
Bpl2PtrHi:
	dc.w    0
	dc.w    BPL2PTL
Bpl2PtrLo:
	dc.w    0


	; --- 3. RUUDUN SISÄPUOLEN VÄRIT ---
	; Pakotetaan ruudun alue mustaksi ja viivat valkoisiksi

	; --- RUUDUN YLÄOSA (RASTERIRAJAT) ---
	dc.w    $2a11,$7FFE,COLOR00,$0000 
	dc.w    $2b11,$7FFE,COLOR00,$0f00 

	dc.w    $2c11,$7FFE
	dc.w    COLOR00,$0555           ; Taustaväri = Musta
	dc.w    COLOR01,$0fff           ; Viivaväri = Kirkas valkoinen
	dc.w    COLOR02,$00f0           ; Taustaväri = Musta
	dc.w    COLOR03,$0000           ; Viivaväri = Kirkas valkoinen

	; --- HYPPY LINJAN 255 YLI LINJALLE 256 ---
	dc.w    $FFDF,$FFFE               
	dc.w    $0001,$FFFE               

	; --- RUUDUN ALAOSA ---
	dc.w    $2d11,$FFFE,COLOR00,$0f00 
	dc.w    $2e11,$FFFE,COLOR00,$0000 

	; Copper-listan virallinen lopetus
	dc.w    $FFFF,$FFFE               
	dc.w    $FFFF,$FFFE

ModuleData:
	;incbin "scoopex-slideshow.mod"
	;incbin "testmod.p61"
	incbin "c:\Users\tehon\Downloads\Update2020\MODS\Protracker\trip_-_horizon.mod"
	EVEN

	END