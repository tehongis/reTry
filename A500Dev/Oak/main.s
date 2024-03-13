

	include "includes/LVOs.i"
	include "includes/Hards.i"

execBase	equ 	$4
customBase	equ		$dff000

	section mycode,code
main
	move.l	execBase,a6
	moveq.l	#0,d0
	lea		graphicsname,a1
	jsr		_LVOOpenLibrary(a6)
	move.l	d0,gfxbase
	beq		.exit

	move.l	gfxbase,a6
	move.l	34(a6),oldview
	move.l	38(a6),oldcopper

	move.l	$6c,oldVBI

	lea		customBase,a6
	move.w	DMACONR(a6),d0
	or.w	#$8000,d0
	move.w	d0,olddmareq
	move.w	INTENAR(a6),d0
	or.w	#$8000,d0
	move.w	d0,oldintena
	move.w	INTREQR(a6),d0
	or.w	#$8000,d0
	move.w	d0,oldintreq
 	move.w	ADKCONR(a6),d0
	or.w	#$8000,d0
	move.w	d0,oldadkcon

; ---------------------- End of gather
	move.l	execBase,a6
	jsr		_LVOForbid(a6)
	jsr		_LVODisable(a6)

	move.l	gfxbase,a6
	jsr		_LVOOwnBlitter(a6)
	jsr		_LVOWaitBlit(a6)
	move.l	#0,a1
 	jsr 	_LVOLoadView(a6) ; LoadView
	jsr 	_LVOWaitTOF(a6) ; WaitTOF
	jsr 	_LVOWaitTOF(a6) ; WaitTOF


	lea		modData,a0
	jsr		pt_Init

	lea		customBase,a6

	move.w 	#$0000,SPR0CTL(a6)
	move.w 	#$0000,SPR1CTL(a6)
	move.w 	#$0000,SPR2CTL(a6)
	move.w 	#$0000,SPR3CTL(a6)
	move.w 	#$0000,SPR4CTL(a6)
	move.w 	#$0000,SPR5CTL(a6)
	move.w 	#$0000,SPR6CTL(a6)
	move.w 	#$0000,SPR7CTL(a6)

	move.w	#$8200,DMACON(a6)
	lea		mycopper,a0
	move.l	a0,COP1LCH(a6)

	move.w	#$3fff,INTENA(a6)
	move.w	#$3fff,INTENA(a6)	;somewhere someone recommended two times
	lea		myVBI,a0
	move.l	a0,$6c
	move.w	#$c020,INTENA(a6)


	lea		bitmap,a0
	move.l	a0,d0
	add.l	#$320/8*0,d0
	move.w	d0,bplpointers+6+(8*0)
	swap.w  d0
	move.w	d0,bplpointers+2+(8*0)

	move.l	a0,d0
	add.l	#$320/8*1,d0
	move.w	d0,bplpointers+6+(8*1)
	swap.w  d0
	move.w	d0,bplpointers+2+(8*1)

	move.l	a0,d0
	add.l	#$320/8*2,d0
	move.w	d0,bplpointers+6+(8*2)
	swap.w  d0
	move.w	d0,bplpointers+2+(8*2)

	move.l	a0,d0
	add.l	#$320/8*3,d0
	move.w	d0,bplpointers+6+(8*3)
	swap.w  d0
	move.w	d0,bplpointers+2+(8*3)


; ---------------------- Mouse loop
.loop
	btst.b	#6,$bfe001
	bne		.loop



; ---------------------- Cleanup for exit
	lea		customBase,a6
	move.w	#$3fff,INTENA(a6)
	move.w	#$3fff,INTENA(a6)
	move.l	oldVBI,$6c

	move.w	#$7fff,DMACON(a6)
	move.w	olddmareq,DMACON(a6)
	move.w	#$7fff,INTENA(a6)
	move.w	oldintena,INTENA(a6)
	move.w	#$7fff,INTREQ(a6)
	move.w	oldintreq,INTREQ(a6)
	move.w	#$7fff,ADKCON(a6)
	move.w	oldadkcon,ADKCON(a6)

	move.l	oldcopper,COP1LCH(a6)

	move.l	gfxbase,a6
	jsr		_LVODisownBlitter(a6)

	move.l	oldview,a1
 	jsr 	_LVOLoadView(a6) ; LoadView
	jsr 	_LVOWaitTOF(a6) ; WaitTOF
	jsr 	_LVOWaitTOF(a6) ; WaitTOF

	move.l	execBase,a6
	jsr		_LVOEnable(a6)
	jsr		_LVOPermit(a6)

	move.l	execBase,a6
	move.l	gfxbase,a1
	jsr		_LVOCloseLibrary(a6)

.exit
	moveq.l	#0,d0
	rts







; ---------------------- My VBI
myVBI
	movem.l	d0-d7/a0-a6,-(sp)

	move.w	#$00f,COLOR0(a6)
	jsr		pt_Music
	move.w	#$000,COLOR0(a6)


	lea		sine,a0
	move.w	sinecounter,d0
	and.w	#$0ffe,d0
	move.w	(a0,d0),d0
	lsr.w	#2,d0
	add.w	#$a0,d0
	lsl.w	#8,d0
	or.w	#$0007,d0
;	move.w	d0,mycopper+8*11
	add		#22,sinecounter

	lea		customBase,a6
	move.w	#$0020,INTREQ(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rte




; ---------------------- Variables
oldVBI		dc.l	0
gfxbase		dc.l	0
oldview		dc.l	0
oldcopper	dc.l	0
olddmareq	dc.l	0
oldintena	dc.l	0
oldintreq	dc.l	0
oldadkcon	dc.l	0

sinecounter	dc.w	0


graphicsname
			db 	"graphics.library",0
	even




	include "protracker_replay.s"

sine
	include "includes/Sine.i"


	section copper,data_c
; ---------------------- Copper
mycopper
	dc.w	BPLCON0,$4200,BPLCON1,$0000
	dc.w	BPL1MOD,$0040,BPL2MOD,$0040
	dc.w	DIWSTRT,$2c81,DIWSTOP,$2cc1
	dc.w 	DDFSTRT,$0038,DDFSTOP,$00d0
bplpointers
	dc.w	BPL1PTH,$0000,BPL1PTL,$0000
	dc.w	BPL2PTH,$0000,BPL2PTL,$0000
	dc.w	BPL3PTH,$0000,BPL3PTL,$0000
	dc.w	BPL4PTH,$0000,BPL4PTL,$0000
	dc.w	BPL5PTH,$0000,BPL5PTL,$0000

	dc.w	COLOR0,$0000,COLOR1,$0fff
	dc.w	COLOR2,$0200,COLOR3,$0ddd
	dc.w	COLOR4,$0400,COLOR5,$0bbb
	dc.w	COLOR6,$0600,COLOR7,$0999
	dc.w	COLOR8,$0800,COLOR9,$0777
	dc.w	COLOR10,$0a00,COLOR11,$0555
	dc.w	COLOR12,$0c00,COLOR13,$0333
	dc.w	COLOR14,$0e00,COLOR15,$0111

	dc.w	$2807,$fffe, COLOR0,$0100
	dc.w	$2907,$fffe, COLOR0,$0400
	dc.w	$2a07,$fffe, COLOR0,$0800
	dc.w	$2b07,$fffe, COLOR0,$0f00
	dc.w	$2c07,$fffe, COLOR0,$0000

	dc.w	$ffdf,$fffe					;wait over 255 line
	dc.w	$2c07,$fffe, COLOR0,$0f00
	dc.w	$2d07,$fffe, COLOR0,$0800
	dc.w	$2e07,$fffe, COLOR0,$0400
	dc.w	$2f07,$fffe, COLOR0,$0100
	dc.w	$3007,$fffe, COLOR0,$0000

	dc.w	$ffff,$fffe


; ---------------------- Music mod
	section music,data_c
modData
	incbin "Data/space_debris.mod"


	section bitmap,bss_c
bitmap
	dcb.b	320/8*256*4


