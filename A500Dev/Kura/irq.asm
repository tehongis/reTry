CUSTOM      EQU     $DFF000
INTREQ      EQU     $09C
INTREQR     EQU     $01E  

	SECTION Code,CODE
	XDEF    VBlank_IRQ

	XREF    BackBuffer
	XREF    FrontBuffer
	XREF    FrameCounter

	XREF    BitmapA
	XREF    BitmapB
	XREF    Bpl1PtrHi
	XREF    Bpl1PtrLo
	XREF    Bpl2PtrHi
	XREF    Bpl2PtrLo

VBlank_IRQ:
	movem.l d0-d7/a0-a6,-(sp)    ; Tallenna kaikki rekisterit pinoon turvaan

	lea     CUSTOM,a0
	move.w  INTREQR(a0),d0
	and.w   #$0020,d0               
	beq     .ExitIRQ

	; =========================================================================
	; 1. KAKSOISPUSKUROINTILOGIIKKA KESKEYTYKSEN SISÄLLÄ
	; =========================================================================
	lea		BitmapA,a1
	move.l	FrontBuffer,d1
	cmp.l 	a1,d1
	beq.s	.swapToB

	move.l  a1,FrontBuffer          ; FrontBuffer = BitmapA
	lea		BitmapB,a1
	move.l  a1,BackBuffer           ; BackBuffer  = BitmapB
	bra.s	.applyAddresses         ; Hypätään yli, ettei loppu nollaa tätä

.swapToB:
	lea		BitmapB,a1
	move.l  a1,FrontBuffer          ; FrontBuffer = BitmapB
	lea		BitmapA,a1
	move.l  a1,BackBuffer           ; BackBuffer  = BitmapA

.applyAddresses:
	move.l	FrontBuffer,d0
	move.l	d0,d1                   ; Otetaan puhdas kopio d1-rekisteriin tasoa 2 varten

	move.w  d0,Bpl1PtrLo            ; Aliosa Copperiin
	swap    d0
	move.w  d0,Bpl1PtrHi            ; Yläosa Copperiin

	add.l   #40,d1                  ; tasan 40 tavua interleaved-seuraavalle linjalle
	move.w  d1,Bpl2PtrLo            ; Toisen bittitason aliosa d1-rekisteristä
	swap    d1
	move.w  d1,Bpl2PtrHi            ; Toisen bittitason yläosa d1-rekisteristä

	addq.l  #1,FrameCounter         


	; =========================================================================
	; 3. DEBUG-TESTI: EOR-VÄLKYNTÄ KIINTEISIIN PAIKKOIHIN MUISTISSA
	; =========================================================================
	move.l  BackBuffer,a1
	eor.w   #-1,20(a1)              ; Välkyttää pistettä taustapuskurissa
	move.l  FrontBuffer,a1
	eor.w   #-1,24(a1)              ; Välkyttää pistettä etupuskurissa

	; =========================================================================
	; 4. KUITATAAN VBLANK-KESKEYTYS LAITTEISTOLLE
	; =========================================================================
    lea     CUSTOM,a0
	move.w  #$0020,INTREQ(a0)
	move.w  #$0020,INTREQ(a0)       

.ExitIRQ:
	movem.l (sp)+,d0-d7/a0-a6    ; Palautetaan kaikki rekisterit pinosta puhtaasti
	rte                          ; Palataan keskeytyksestä takaisin
