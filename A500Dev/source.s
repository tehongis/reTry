
	include LVOs.i
	include Hards.i

	section maincode,code

main
	lea			CUSTOM,a6
	move.w  #%1000000110000000,DMACON(a6)
	move.w  #%0000000001111111,DMACON(a6)
	move.w  #%1100000000000000,INTENA(a6)
	move.w  #%0011111111111111,INTENA(a6)

	lea		myCopper,a0
	move.l	a0,COP1LCH(a6)

.mainloop
	move.w	#$0000,COLOR0(a6)
	move.w	#$0000,COLOR1(a6)
	bra .mainloop

irq


OLD_DMACON
	dc.l	0
OLD_INTENA
	dc.l	0
OLD_INTREQ
	dc.l	0
OLD_ADKCON
	dc.l	0

		section chipdata,data,chip

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
	dc.w	$0180,$0000
	dc.w	$0182,$0fff
	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe
