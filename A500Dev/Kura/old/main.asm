CUSTOM		equ $dff000
BPLCON0     EQU     $100
DMACON      EQU     $096	

	SECTION Code,CODE

	XDEF    MainLoop
	XDEF    BackBuffer
	XDEF    FrontBuffer
	XDEF    FrameFlag
	XDEF    FrameCounter

	; Tuodaan muualta
	XREF    ExitGently
	XREF    BitmapA
	XREF    BitmapB
	XREF    Bpl1PtrHi
	XREF    Bpl1PtrLo
	XREF    Bpl2PtrHi
	XREF    Bpl2PtrLo
	XREF    ClearBlitterBuffer
	XREF    DrawBlitterLine

MainLoop:


	; --- TAUSTAPUSKURIN TYHJENNYS ---

	;move.l  BackBuffer,a0           
	;jsr     ClearBlitterBuffer

	; --- LIIKELOGIIKKA JA TÖRMÄYKSET ---
	; Piste 0 (X0, Y0)
	move.w  LineX0,d0
	add.w   SpeedX0,d0
	cmpi.w  #2,d0
	bgt.s   .ch_x0_max
	move.w  #2,d0
	neg.w   SpeedX0
	bra.s   .x0_done
.ch_x0_max:
	cmpi.w  #316,d0
	blt.s   .x0_done
	move.w  #316,d0
	neg.w   SpeedX0
.x0_done:
	move.w  d0,LineX0

	move.w  LineY0,d1
	add.w   SpeedY0,d1
	cmpi.w  #2,d1
	bgt.s   .ch_y0_max
	move.w  #2,d1
	neg.w   SpeedY0
	bra.s   .y0_done
.ch_y0_max:
	cmpi.w  #252,d1
	blt.s   .y0_done
	move.w  #252,d1
	neg.w   SpeedY0
.y0_done:
	move.w  d1,LineY0

	; Piste 1 (X1, Y1)
	move.w  LineX1,d2
	add.w   SpeedX1,d2
	cmpi.w  #2,d2
	bgt.s   .ch_x1_max
	move.w  #2,d2
	neg.w   SpeedX1
	bra.s   .x1_done
.ch_x1_max:
	cmpi.w  #316,d2
	blt.s   .x1_done
	move.w  #316,d2
	neg.w   SpeedX1
.x1_done:
	move.w  d2,LineX1

	move.w  LineY1,d3
	add.w   SpeedY1,d3
	cmpi.w  #2,d3
	bgt.s   .ch_y1_max
	move.w  #2,d3
	neg.w   SpeedY1
	bra.s   .y1_done
.ch_y1_max:
	cmpi.w  #252,d3
	blt.s   .y1_done
	move.w  #252,d3
	neg.w   SpeedY1
.y1_done:
	move.w  d3,LineY1



	; --- 1. PIIRRETÄÄN VIIVA BLITTERILLÄ ---
	;move.l	BackBuffer,a0           ; Kohteena taustapuskuri
	;move.w	LineX0,d0               
	;move.w	LineY0,d1
	;move.w	LineX1,d2
	;move.w	LineY1,d3
	;jsr     DrawBlitterLine         

	; =========================================================================
	; UUSI DEBUG-RUTIINI: PIIRRETÄÄN CPU:LLA PISTEET ALKU- JA LOPPUPISTEISIIN
	; =========================================================================
	
	; --- PISTE 1: ALKUpiste (LineX0, LineY0) ---
	move.w  LineX0,d0
	move.w  LineY0,d1
	move.l  BackBuffer,a0
	
	; Lasketaan osoite interleaved-linjalle: Y0 * 80 + (X0 / 16) * 2
	mulu.w  #40,d1                  ; Y0 * 80 tavua per interleaved-rivi
	add.l   d1,a0
	
	lsr.w   #4,d0                   ; X0 / 16 = Word-paikka
	add.w   d0,d0                   ; Tavut (* 2)
	ext.l   d0
	add.l   d0,a0                   ; a0 osoittaa nyt bittitason 1 paikkaan

	; Siirrytään interleaved-rakenteessa tasan 40 tavua eteenpäin, 
	; jotta kirjoitus osuu bittitasoon 2 (Vihreä/Punainen väri)
	move.w  #-1,40(a0)              ; Kirjoitetaan 16 pikseliä leveä piste!

;	; --- PISTE 2: LOPPUpiste (LineX1, LineY1) ---
	move.w  LineX1,d0
	move.w  LineY1,d1
	move.l  BackBuffer,a0

	; Lasketaan osoite interleaved-linjalle: Y0 * 80 + (X0 / 16) * 2
	mulu.w  #40,d1                  ; Y0 * 80 tavua per interleaved-rivi
	add.l   d1,a0
	
	lsr.w   #4,d0                   ; X0 / 16 = Word-paikka
	add.w   d0,d0                   ; Tavut (* 2)
	ext.l   d0
	add.l   d0,a0                   ; a0 osoittaa nyt bittitason 1 paikkaan

	; Siirrytään interleaved-rakenteessa tasan 40 tavua eteenpäin, 
	; jotta kirjoitus osuu bittitasoon 2 (Vihreä/Punainen väri)
	move.w  #-1,(a0)              ; Kirjoitetaan 16 pikseliä leveä piste!
	; =========================================================================



	
	lea     BackBuffer,a0
	add.l   #20,a0                  ; Siirretään keskelle ruutua
	jsr     DrawStaticTestLine

	; Tutkitaan hiiren vasen näppäin poistumista varten
	btst    #6,$BFE001
	bne     MainLoop

	; Jos hiirtä painettiin, poistutaan nätisti
	jmp     ExitGently

; =============================================================================
; LOGIIKAN MUUTTUJAT
; =============================================================================

	EVEN
FrontBuffer:    dc.l    0
	EVEN
BackBuffer:     dc.l    0
	EVEN
FrameCounter:   dc.l    0
	EVEN
FrameFlag:      dc.w    0
	EVEN
index:			dc.w	0	
	EVEN

; --- Viivan koordinaatit ---
	EVEN
LineX0:         dc.w    30
LineY0:         dc.w    50
LineX1:         dc.w    260
LineY1:         dc.w    190

	EVEN
SpeedX0:        dc.w    3
SpeedY0:        dc.w    2
SpeedX1:        dc.w    -2
SpeedY1:        dc.w    3
