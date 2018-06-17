; Code by Tero Hongisto
; CodeVacation 2018
; This is ugly as hell. We just go and kill the OS with not even intending to get back...

	include LVOs.i
	include Hards.i

EXECBASE equ $4

	section maincode,CODE

main

	lea		pt_module,a0
	jsr 	pt_Init

	move.l	EXECBASE.l,a6
	jsr		_LVODisable(a6)

;	jsr		initscreen
	jsr		initVBI

.mainloop
	bra .mainloop

initscreen

	lea			CUSTOM,a6
	move.w  #%1000000110000000,DMACON(a6)
	move.w  #%0000000001111111,DMACON(a6)

	lea			myCopper,a0
	move.l	a0,COP1LCH(a6)
	move.l	#$0000,COP1JUMP(a6)

	rts

initVBI

	move.w  #%1100000000000000,INTENA(a6)
	move.w  #%0011111111111111,INTENA(a6)

	rts

myVBI

	movem.l	d0-d7/a0-a6,-(sp)

	jsr			pt_Music

	lea			CUSTOM,a6
	move.w	#%0000000000100000,INTREQ(a6)

	movem.l	(sp)+,d0-d7/a0-a6
	rte

	include protracker_replay.s

OLD_DMACON
	dc.l	0
OLD_INTENA
	dc.l	0
OLD_INTREQ
	dc.l	0
OLD_ADKCON
	dc.l	0

		section chipdata,DATA_C
pt_module
	incbin	"f-tube.mod"

myCopper
	dc.w  $3200,BPLCON0
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
	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe
