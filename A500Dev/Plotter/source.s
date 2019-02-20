; Code by Tero Hongisto
; CodeVacation 2018
; "I never wanted to exit to the OS anyway..."

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

		section chipdata,data_C
myCopper
	dc.w	$0011,$fffe
	dc.w	DIWSTRT,$2c81
	dc.w	DIWSTOP,$c8d1
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

	dc.w	$1f11,$fffe
	dc.w	COLOR0,$0fff
	dc.w	$2011,$fffe
	dc.w	COLOR0,$0000
	dc.w	$ffdf,$fffe		;Over the VPOS max...
	dc.w	$2111,$fffe
	dc.w	COLOR0,$0fff
	dc.w	$2211,$fffe
	dc.w	COLOR0,$0000

	dc.w	$ffff,$fffe

pt_module
	incbin	"mod.12th_echo"

bitmaps
	ds.b	(320*256*3)/8,$cafe

	end
