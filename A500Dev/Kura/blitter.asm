; =============================================================================
; AMIGA LAITTEISTOREKISTERIT JA VAKIOT
; =============================================================================
CUSTOM      EQU     $DFF000
BLTCON0     EQU     $040
BLTCON1     EQU     $042
BLTAFWM     EQU     $044
BLTALWM     EQU     $046
BLTAPT      EQU     $050
BLTCPTH     EQU     $048
BLTDPTH     EQU     $054
BLTSIZE     EQU     $058
BLTCMOD     EQU     $060
BLTBMOD     EQU     $062
BLTAMOD     EQU     $064
BLTDMOD     EQU     $066
BLTBDAT     EQU     $072
BLTADAT     EQU     $074
DMACONR     EQU     $002
DMACONR_BB  EQU     14

SIGN_BIT    EQU     $0040

	SECTION Code,CODE

	; --- Julkiset symbolit pääohjelmalle ---
	XDEF    ClearBlitterBuffer
	XDEF    DrawBlitterLine
	XDEF    DrawStaticTestLine

; =============================================================================
; TESTI: TYHJENNETÄÄN VAIN 64 RIVIÄ PUSKURIN ALUSTA
; Inputs:  a0 = Tyhjennettävän puskurin kantaosoite (BackBuffer)
; Clobbers: a1, d0
; =============================================================================
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


; =============================================================================
; 2. VIIVAN PIIRTÄMINEN (Interleaved 2-BPL Bresenham Line Mode)
; Inputs:  a0 = bittitason kantaosoite (BackBuffer)
;          d0 = X0, d1 = Y0
;          d2 = X1, d3 = Y1
; Clobbers: d0-d7, a0-a1, a5
; =============================================================================
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
; BARE-METAL BLITTER PYSTYVIIVATESTI (KORJATTU DATALATAUS)
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


	EVEN
OctantTable:
	dc.w    $0001, $0009, $0011, $0019, $0005, $000D, $0015, $001D