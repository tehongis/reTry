

	include "includes/LVOs.i"
	include "includes/Hards.i"
	include "includes/dmabits.i"
	include "includes/exec/types.i"
	include "includes/hardware/blit.i"

;	include 'hardware/custom.i'
;	include 'hardware/dmabits.i'
;	include 'hardware/hw_examples.i'


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


	lea		customBase,a6
	move.w	#$8200,DMACON(a6)
	lea		mycopper,a0
	move.l	a0,COP1LCH(a6)


	lea		customBase,a6
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

	lea		customBase,a6
	move.w	#$0f0,COLOR0(a6)
	jsr		fillarea
	lea		customBase,a6
	move.w	#$000,COLOR0(a6)


	move.w	#020,d0
	move.w	#020,d1
	move.w	#220,d2
	move.w	#200,d3
	move.w	#320,d4
	lea		bitmap,a0	
	jsr		simpleline




	lea		customBase,a6
	move.w	#$00f,COLOR0(a6)
	jsr		pt_Music
	lea		customBase,a6
	move.w	#$000,COLOR0(a6)


	lea		sine,a0
	move.w	sinecounter,d0
	and.w	#$0ffe,d0
	move.w	(a0,d0),d0
;	lsl.w	#8,d0
;	or.w	#$0007,d0
;	move.w	d0,mycopper+8*11

	lea		bitmap,a0
	add.l	#$1000,a0
	add.w   #$0200,d0
	and.w	#$0ffe,d0

	eor.w	#$ffff,(a0,d0.w)
	add		#22,sinecounter

	lea		customBase,a6
	move.w	#$0020,INTREQ(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rte


fillarea
;                    AREA MODE ("normal")
;                 -------------------------
;                 BIT# BLTCON0     BLTCON1
;                 ---- -------     -------
;                 15   ASH3        BSH3
;                 14   ASH2        BSH2
;                 13   ASH1        BSH1
;                 12   ASA0        BSH0
;                 11   USEA         X
;                 10   USEB         X
;                 09   USEC         X
;                 08   USED         X
;                 07   LF7          DOFF
;                 06   LF6          X
;                 05   LF5          X
;                 04   LF4         EFE
;                 03   LF3         IFE
;                 02   LF2         FCI
;                 01   LF1         DESC
;                 00   LF0         LINE(=0)
;
;                 ASH3-0  Shift value of A source
;                 BSH3-0  Shift value of B source
;                 USEA    Mode control bit to use source A
;                 USEB    Mode control bit to use source B
;                 USEC    Mode control bit to use source C
;                 USED    Mode control bit to use destination D
;                 LF7-0   Logic function minterm select lines
;                 EFE     Exclusive fill enable
;                 IFE     Inclusive fill enable
;                 FCI     Fill carry input
;                 DESC    Descending (decreasing address) control bit
;                 LINE    Line mode control bit (set to 0)


;Calculating LF Bytes
;Instead of calculating your LF-bytes all the time you can do this
;A  EQU   %11110000
;B  EQU   %11001100
;C  EQU   %10101010
;So when you need an lf-byte you can just type:
;	move.w   #(A!B)&C,d0


height	equ 128
width	equ 320


	lea		customBase,a6
.waitblit
    btst.b  #DMAB_BLTDONE-8,DMACONR(a6)
    bne     .waitblit

	lea		bitmap,a0
	move.l	a0,BLTAPT(a6)
	move.l	a0,BLTDPT(a6)
	move.w	#$0040,BLTAMOD(a6)
	move.w	#$0040,BLTDMOD(a6)

	move.w	#$19f0,BLTCON0(a6)
	move.w	#$0000,BLTCON1(a6)
	
   	move.w   #64*height+width/2,BLTSIZE(a6)	

	lea		customBase,a6
.waitblit2
    btst.b  #DMAB_BLTDONE-8,DMACONR(a6)
    bne     .waitblit2

	rts



; -------------------- Linedraw

;   Input:  d0=x1 d1=y1 d2=x2 d3=y2 d4=width a0=aptr
;
;
;   Our entry point.
;
simpleline:
        lea     customBase,a1      ; snarf up the custom address register
        sub.w   d0,d2           ; calculate dx
        bmi     xneg            ; if negative, octant is one of [3,4,5,6]
        sub.w   d1,d3           ; calculate dy   ''   is one of [1,2,7,8]
        bmi     yneg            ; if negative, octant is one of [7,8]
        cmp.w   d3,d2           ; cmp |dx|,|dy|  ''   is one of [1,2]
        bmi     ygtx            ; if y>x, octant is 2
        moveq.l #OCTANT1+LINEMODE,d5    ; otherwise octant is 1
        bra     lineagain       ; go to the common section
ygtx:
        exg     d2,d3           ; X must be greater than Y
        moveq.l #OCTANT2+LINEMODE,d5    ; we are in octant 2
        bra     lineagain       ; and common again.
yneg:
        neg.w   d3              ; calculate abs(dy)
        cmp.w   d3,d2           ; cmp |dx|,|dy|, octant is [7,8]
        bmi     ynygtx          ; if y>x, octant is 7
        moveq.l #OCTANT8+LINEMODE,d5    ; otherwise octant is 8
        bra     lineagain
ynygtx:
        exg     d2,d3           ; X must be greater than Y
        moveq.l #OCTANT7+LINEMODE,d5    ; we are in octant 7
        bra     lineagain
xneg:
        neg.w   d2              ; dx was negative! octant is [3,4,5,6]
        sub.w   d1,d3           ; we calculate dy
        bmi     xyneg           ; if negative, octant is one of [5,6]
        cmp.w   d3,d2           ; otherwise it's one of [3,4]
        bmi     xnygtx          ; if y>x, octant is 3
        moveq.l #OCTANT4+LINEMODE,d5    ; otherwise it's 4
        bra     lineagain
xnygtx:
        exg     d2,d3           ; X must be greater than Y
        moveq.l #OCTANT3+LINEMODE,d5    ; we are in octant 3
        bra     lineagain
xyneg:
        neg.w   d3              ; y was negative, in one of [5,6]
        cmp.w   d3,d2           ; is y>x?
        bmi     xynygtx         ; if so, octant is 6
        moveq.l #OCTANT5+LINEMODE,d5    ; otherwise, octant is 5
        bra     lineagain
xynygtx:
        exg     d2,d3           ; X must be greater than Y
        moveq.l #OCTANT6+LINEMODE,d5    ; we are in octant 6
lineagain:
        mulu.w  d4,d1           ; Calculate y1 * width
        ror.l   #4,d0           ; move upper four bits into hi word
        add.w   d0,d0           ; multiply by 2
        add.l   d1,a0           ; ptr += (x1 >> 3)
        add.w   d0,a0           ; ptr += y1 * width
        swap    d0              ; get the four bits of x1
        or.w    #$BFA,d0        ; or with USEA, USEC, USED, F=A+C
        lsl.w   #2,d3           ; Y = 4 * Y
        add.w   d2,d2           ; X = 2 * X
        move.w  d2,d1           ; set up size word
        lsl.w   #5,d1           ; shift five left
        add.w   #$42,d1         ; and add 1 to height, 2 to width
        btst    #DMAB_BLTDONE-8,DMACONR(a1)     ; safety check
waitblit:
        btst    #DMAB_BLTDONE-8,DMACONR(a1)     ; wait for blitter
        bne     waitblit
        move.w  d3,BLTBMOD(a1)  ; B mod = 4 * Y
        sub.w   d2,d3
        ext.l   d3
        move.l  d3,BLTAPT(a1)   ; A ptr = 4 * Y - 2 * X
        bpl     lineover        ; if negative,
        or.w    #SIGNFLAG,d5    ; set sign bit in con1
lineover:
        move.w  d0,BLTCON0(a1)  ; write control registers
        move.w  d5,BLTCON1(a1)
        move.w  d4,BLTCMOD(a1)  ; C mod = bitplane width
        move.w  d4,BLTDMOD(a1)  ; D mod = bitplane width
        sub.w   d2,d3
        move.w  d3,BLTAMOD(a1)  ; A mod = 4 * Y - 4 * X
        move.w  #$8000,BLTADAT(a1)      ; A data = 0x8000
        moveq.l #-1,d5          ; Set masks to all ones
        move.l  d5,BLTAFWM(a1)  ; we can hit both masks at once
        move.l  a0,BLTCPT(a1)   ; Pointer to first pixel to set
        move.l  a0,BLTDPT(a1)
        move.w  d1,BLTSIZE(a1)  ; Start blit

	lea		customBase,a6
.waitblit
    btst.b  #DMAB_BLTDONE-8,DMACONR(a6)
    bne     .waitblit			
    
	rts






















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


