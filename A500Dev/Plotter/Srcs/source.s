; Code by Tero Hongisto
; CodeVacation 2018
; "I never wanted to exit to the OS anyway..."




;Address	Name	Description
;DFF08E	DIWSTRT	Display window start (upper left vertical-horizontal position)
;DFF090	DIWSTOP	Display window stop (lower right vertical-horizontal position)

;These registers control the display window size and position,
;by locating the upper left and lower right corners.

;Bit	15	14	13	12	11	10	09	08	07	06	05	04	03	02	01	00
; 	V7	V6	V5	V4	V3	V2	V1	V0	H9	H8	H7	H6	H5	H4	H3	H2

;DIWSTRT is vertically restricted to the upper 2/3 of the display (V8=0),
;and horizontally restricted to the left 3/4 of the display (H8=0).

;See DIWHIGH for exceptions.


;Address	Name	Description
;DFF092	DDFSTRT	Display data fetch start (horizontal position)
;DFF094	DDFSTOP	Display data fetch stop (horizontal position)

;These registers control the horizontal timing of the beginning and
;end of the bit plane DMA timing display data fetch. The vertical bit
;plane DMA timing is identical to the display windows described above.
;The bit plane Modulos are dependent on the bit plane horizontal size,
;and on this data fetch window size.

;Register bit assignment :

;Bit	15	14	13	12	11	10	09	08	07	06	05	04	03	02	01	00
; 	0	0	0	0	0	0	0	0	H8	H7	H6	H5	H4	H3	H2	0

;The tables below show the start and stop timing for different register contents

;DDFSTRT (Left edge of display data fetch) :

;PURPOSE	H8	H7	H6	H5	H4
;Extra wide (max)	0	0	1	0	1
;wide	0	0	1	1	0
;normal	0	0	1	1	1
;narrow	0	1	0	0	0

;DDFSTOP (Right edge of display data fetch) :

;PURPOSE	H8	H7	H6	H5	H4
;narrow	1	1	0	0	1
;normal	1	1	0	1	0
;wide (max)	1	1	0	1	1

;Note that these numbers will vary with variable beam counter mode
;set: (The maxes and mins, that is).


	include LVOs.i
	include Hards.i

execBase 	equ $4
customBase	equ $dff000

	section maincode,CODE

main

	move.l	execBase.l,a6
	lea		gfxName,a1
	move.l	#$0,d0
	jsr		_LVOOpenLibrary(a6)
	move.l	d0,gfxBase
	cmp		#0,d0
	beq		.fail

	move.l	gfxBase,a6
	move.l 	34(a6),oldView
	move.l 	38(a6),oldCopper

	move.l	execBase.l,a6
	jsr		_LVOForbid(a6)

	lea		customBase,a6

	move.w	DMACONR(a6),d0
	or.w	#$8000,d0
	move.w	d0,oldDMACon

	move.w	INTENAR(a6),d0
	or.w	#$8000,d0
	move.w	d0,oldIntEna

	move.w	INTREQR(a6),d0
	or.w	#$8000,d0
	move.w	d0,oldIntReq

	move.w	ADKCONR(a6),d0
	or.w	#$8000,d0
	move.w	d0,oldAdkCon

	move.l	$6c.l,oldVBI

	move.l	gfxBase,a6
	jsr		_LVOOwnBlitter(a6)
	move.l	gfxBase,a6
	jsr		_LVOWaitBlit(a6)

	move.l	gfxBase,a6
	move.l	#0,a1
	jsr		_LVOLoadView(a6)
	jsr 	_LVOWaitTOF(a6)
	jsr 	_LVOWaitTOF(a6)

	lea		pt_module,a0
	jsr 	pt_Init

	lea		customBase,a6

	move.w	#$3fff,INTENA(a6)
	lea		myVBI,a0
	move.l	a0,$6c.l
	move.w	#$8020,INTENA(a6)

	lea		customBase,a6
	move.w	#%0000010111111111,DMACON(a6)

	lea		myCopper,a0
	move.l	a0,COP1LCH(a6)
	move.w	#0,COPJMP1(a6)

	lea		bitmaps,a1
	add.l 	#$100,a1
	move.l	a1,d0
	add.l	#38,a0		;bitmap pointers begin

	move.w	d0,(a0)
	swap	d0
	add.l	#4,a0
	move.w	d0,(a0)
	swap	d0
	add.l	#4,a0
	add.l	#$50,d0
	move.w	d0,(a0)
	swap	d0
	add.l	#4,a0
	move.w	d0,(a0)
	swap	d0
	add.l	#4,a0
	add.l	#$50,d0
	move.w	d0,(a0)
	swap	d0
	add.l	#4,a0
	move.w	d0,(a0)
	swap	d0
	add.l	#4,a0


	move.w	#%1000010111001111,DMACON(a6)

.mainloop
	bra 	.mainloop
.fail
	rts		;JUST in case... ;-)

;-------------------

myVBI
	movem.l	d0-d7/a0-a6,-(sp)

	jsr		pt_Music

	move.w	sinecounter1,d0
	add.w	#8,d0
	and.w	#$0ffe,d0
	move.w	d0,sinecounter1
	lea		sinus,a0
	add.w	d0,a0
	move.w	(a0),d0
	add.w	#$100,d0
	muls.w	#$28,d0

	lea		bitmaps,a1
	add.w	d0,a1
	eor.b	#$ff,(a1)
;No use for sine yet.

	lea		customBase,a6
	move.w	#%0000000000100000,INTREQ(a6)

	movem.l	(sp)+,d0-d7/a0-a6
	rte

	include protracker_replay.s

oldDMACon
	dc.l	0
oldIntEna
	dc.l	0
oldIntReq
	dc.l	0
oldAdkCon
	dc.l	0
oldView
	dc.l	0
oldCopper
	dc.l	0
oldVBI
	dc.l	0
gfxBase
	dc.l	0
sinecounter1
	dc.w	0
sinus
	include "okxu.i"

gfxName
	dc.b	"graphics.library",0
	even

;------ Chipdata below

	section chipdata,data_C

myCopper
	dc.w	$0011,$fffe
	dc.w	DIWSTRT,$2c81
	dc.w	DIWSTOP,$2bd1
	dc.w	DDFSTRT,$0038
	dc.w	DDFSTOP,$00d0
	dc.w	BPLCON0,$3200
	dc.w	BPLCON1,$0000
	dc.w	BPL1MOD,$0050
	dc.w	BPL2MOD,$0050

	dc.w	BPL1PTL,$0000
	dc.w	BPL1PTH,$0000
	dc.w	BPL2PTL,$0000
	dc.w	BPL2PTH,$0000
	dc.w	BPL3PTL,$0000
	dc.w	BPL3PTH,$0000

	dc.w	COLOR0,$0000
	dc.w	COLOR1,$0fff
	dc.w	COLOR2,$0f00
	dc.w	COLOR3,$00f0
	dc.w	COLOR4,$000f
	dc.w	COLOR5,$0ff0
	dc.w	COLOR6,$00ff
	dc.w	COLOR7,$0f0f

	dc.w	$2b11,$fffe
	dc.w	COLOR0,$0fff
	dc.w	$2c11,$fffe
	dc.w	COLOR0,$0000

	dc.w	$ffdf,$fffe		;Over the VPOS max...
	dc.w	$2b11,$fffe
	dc.w	COLOR0,$0fff
	dc.w	$2c11,$fffe
	dc.w	COLOR0,$0000

	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe

pt_module
	incbin	"mods/mod.heatbeat-spacelove"

bitmaps
	dcb.w	(320*256*3)/16+$100,$dead

	end
