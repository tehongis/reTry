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

	move.w	#%1000010111001111,DMACON(a6)

.mainloop
	bra 	.mainloop
.fail
	rts		;JUST in case... ;-)

;-------------------

myVBI
	movem.l	d0-d7/a0-a6,-(sp)

	jsr		pt_Music

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
gfxName
	dc.b	"graphics.library",0
	even

		section chipdata,DATA_C
myCopper
	dc.w	$0011,$fffe
	dc.w	$3200,BPLCON0
	dc.w	$0000,BPLCON1
	dc.w	$0050,BPL1MOD
	dc.w	$0050,BPL2MOD
	dc.w	$0000,BPL1PTH
	dc.w	$0000,BPL1PTL
	dc.w	$0000,BPL2PTH
	dc.w	$0000,BPL2PTL
	dc.w	$0000,BPL3PTH
	dc.w	$0000,BPL3PTL

	dc.w	$2c81,DIWSTRT
	dc.w	$c8d1,DIWSTOP
	dc.w	$0038,DDFSTRT
	dc.w	$00d0,DDFSTOP
	dc.w	$0000,COLOR0
	dc.w	$0fff,COLOR1
	dc.w	$6f11,$fffe
	dc.w	$0fff,COLOR0
	dc.w	$0000,COLOR1
	dc.w	$ef11,$fffe
	dc.w	$0000,COLOR0
	dc.w	$0fff,COLOR1
	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe

pt_module
	incbin	"f-tube.mod"

bitmaps
	ds.b	(320*256*3)/8

	end
