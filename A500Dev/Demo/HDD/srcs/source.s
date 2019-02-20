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

	move.w	vlinecount,d0
	add.w	#$01,d0
	and.w	#$3f,d0
	move.w	d0,vlinecount
	
	move.w	vlinecount,d0
	add.b	#$c0,d0
	sub.w	#$01,d0
	move.b	d0,vline7
	move.b	d0,vline7+8

	move.w	vlinecount,d0
	ror.w	d0
	and.w	#$3f,d0
	add.w	#$a0,d0
	sub.w	#$01,d0
	move.b	d0,vline6
	move.b	d0,vline6+8

	move.w	vlinecount,d0
	ror.w	d0
	ror.w	d0
	and.w	#$3f,d0
	add.w	#$90,d0
	sub.w	#$01,d0
	move.b	d0,vline5
	move.b	d0,vline5+8

	move.w	vlinecount,d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	and.w	#$3f,d0
	add.w	#$88,d0
	sub.w	#$01,d0
	move.b	d0,vline4
	move.b	d0,vline4+8

	move.w	vlinecount,d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	and.w	#$3f,d0
	add.w	#$84,d0
	sub.w	#$01,d0
	move.b	d0,vline3
	move.b	d0,vline3+8

	move.w	vlinecount,d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	and.w	#$3f,d0
	add.w	#$82,d0
	sub.w	#$01,d0
	move.b	d0,vline2
	move.b	d0,vline2+8

	move.w	vlinecount,d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	ror.w	d0
	and.w	#$3f,d0
	add.w	#$80,d0
	sub.w	#$01,d0
	move.b	d0,vline1
	move.b	d0,vline1+8
	

;	jsr	drawline
	
	
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

	
drawline
;	waitblitter
	move.w	#$8000,BLTADAT
	move.w	#$ffff,BLTBDAT
	move.w	#$ffff,BLTAFWM
	move.w	#$ffff,BLTALWM

;	move.w	#$inc_majmin,BLTAMOD
;	move.w	#$inc_maj,BLTBMOD
;	move.w	#ymod,BLTDMOD
;	move.w	#ymod,BLTDMOD
;	move.w	#acc,BLTAPTR
;	move.w	#p,BLTCPTR
;	move.w	#p,BLTDPTR
;	move.w	#shift,BLTCON0	;x1 modulo 16	(bits 15-12)
;	move.w	#11,BLTCON0 (bit 11-08)
;	move.w	#xor,BLTCON0 (bit 07-00)
	
	
	
;	waitblitter
	
	rts
	
	
	
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

vlinecount
	dc.w	0
	
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

	dc.w	$2011,$fffe,COLOR0,$0fff,$00db,$80fe,COLOR0,$0000
vline1
	dc.w	$8011,$fffe,COLOR0,$0005,$80db,$fffe,COLOR0,$0000
vline2
	dc.w	$8211,$fffe,COLOR0,$0007,$82db,$fffe,COLOR0,$0000
vline3
	dc.w	$8411,$fffe,COLOR0,$0009,$84db,$fffe,COLOR0,$0000
vline4
	dc.w	$8811,$fffe,COLOR0,$000b,$88db,$fffe,COLOR0,$0000
vline5
	dc.w	$9011,$fffe,COLOR0,$000d,$90db,$fffe,COLOR0,$0000
vline6
	dc.w	$a011,$fffe,COLOR0,$000f,$a0db,$fffe,COLOR0,$0000
vline7
	dc.w	$c011,$fffe,COLOR0,$000f,$c0db,$fffe,COLOR0,$0000
	dc.w	$ffe1,$fffe		;Over the VPOS max...
	dc.w	$0011,$fffe,COLOR0,$0fff,$00db,$80fe,COLOR0,$0000
	dc.w	$2011,$fffe,COLOR0,$0fff,$20db,$80fe,COLOR0,$0000

	dc.w	$ffff,$fffe

pt_module
	incbin	"HDD/modules/mod.heatbeat-spacelove"

bitmaps
	ds.b	(320*256*3)/8,$cafe

	end

	
	
	
	
	
	
	
	
	
	
	
	
/*
LineMode
         Using blitter for line drawing:


         Besides copying data and filling areas, the blitter
         has one more talent:  drawing lines.  In line mode,
         almost all of the blitter registers change their
         functions.


         The blitter draws lines at incredible speeds, much
         faster than the 68000.  Unfortunately, you can't
         just give the blitter two points and then tell it to
         connect the dots.  You need to perform some
         calculations first.


         Let's say that you want to draw a line from point
         (x1,y1) to (x2,y2).  From these coordinates you need
         to figure out the horizontal and vertical distance
         between the line's two end points.  This is easily
         calculated using the following two formulas:


             dx = abs(x1-x2)
             dy = abs(y1-y2)


         Now you're ready to give the BLTCON1 register at
         $dff042 some information about the physical
         orientation of the line.


             If (dx >= dy) and (x1 >= x2) set bit 2.
             If (dx < dy)  and (y1 >= y2) set bit 2.
             If (dx >= dy) and (y1 >= y2) set bit 3.
             If (dx < dy)  and (x1 >= x2) set bit 3.
             If (dx >=dy)                 set bit 4.


         Together, these bits define the octant (position
         relative to the line's starting position) in which
         the line will appear.  The following shows how the
         Amiga divides the screen into octants:


              \   |   /      * = x1,y1
               \3 | 1/       Note: The numbers shown in this figure
              7 \ | / 6      represent the combined value of BLTCON1's
                 \|/         bits 2-4.  If the line appears on the border
              ----X----      of two octants, it does not matter which of
                 /|\         the two octants you select.
              5 / | \ 4
               /2 | 0\
              /   |   \


         Next, you need to determine which value is larger:
         dx or dy.  Let dmax equal the greater value, and
         dmin the lesser value.  Now use these values to set
         the following registers:


         dmax = max(dx,dy)
         dmin = min(dx,dy)
         BLTBMOD = 4* dmin
         BLTAMOD = 4 * (dmax-dmin)
         BLTAPTL = (4 * dmin) - (2 * dmax)


         These formulas define the line's slope.  If the
         result of the last calculation BLTAPTL is negative,
         you must store a 1 in the SIGN bit (6) of the
         BLTCON1 register.


         Besides holding the line's octant number and the
         negative/positive status of the line's slope,
         BLTCON1 affects the line's physical appearance.  If
         you're drawing lines to enclose an area that you
         plan to fill later using blitter fill mode, you
         should set the ONEDOT bit (1) equal to one.  This
         tells the blitter to draw lines using only one pixel
         per raster, thus providing a single pixel border for
         your object.


         To create textured lines, BLTCON1's bits 12-15 work
         in conjunction with the BLTBDAT register ($dff072).
         The bit pattern found in BLTBDAT defines the pixel
         pattern used to draw lines.  For normal solid lines,
         set all of BLTBDAT's bits to one.  (i.e.  $ffff)
         Other values create dotted or dashed lines.  Bits
         12-15 in BLTCON1 allow you to specify which bit in
         BLTBDAT, 0-15, defines the status of the first pixel
         in the line.  For most practical purposes, BLTCON1's
         bits 12-15 should be set equal to the value of x1's
         lower 4 bits.  (i.e.  x1 AND $0f) This informs the
         blitter to start the line off with the value found
         in BLTBDAT's MSB (15).  IMPORTANT:  ALWAYS SET
         BLTCON1 PRIOR TO BLTBDAT!


         BLTCON1's bit 5 should always be set to zero, as
         should bits 7 through 11.  To tell the blitter that
         you want to draw lines instead of copy data, the
         LINE bit (0) must be set to 1.


         The Amiga needs certain information about the size
         and location of the screen's bitmap before it can
         draw a line.  First, store the byte-width (number of
         pixels divided by 8) of the bitmap in the BLTCMOD
         and BLTDMOD registers ($dff060 and $dff066).  Next,
         you must put the address of the word containing the
         starting point of the line into the BLTCPT and
         BLTDPT registers.  ($dff048 and $dff054)


         Only one bitplane can be written to during a single
         blitter operation.  So, to draw a line of a
         particular color on a multiple bitplane screen, it
         may be necessary to perform two or more line blits.
         In these cases, you set the registers up for the
         first bitplane as usual, and perform the blit; then
         for subsequent bitplanes, you simply reinitialize
         the registers with the same values EXCEPT for the
         registers BLTCPT and BLTDPT, which must contain the
         address of the line's starting point within the new
         bitplane.


         As with blitter copy mode, you must set bits 0-7 in
         the BLTCON0 register ($dff040) to choose a miniterm.
         Usually, you should store $ca here, but if you
         prefer to XOR your line onto the screen (invert all
         the pixels found on the line), store a $4a here.


         BLTCON0's bits 8-11 should be set equal to $b.
         (This activates blitter source A and C, and
         destination D.) Store x1's lower four bits (x1 AND
         $0f) into BLTCON0's bits 12-15.  The blitter uses
         this value to determine the bit position of the
         line's starting point within the bitplane memory
         location specified by registers BLTCPT and BLTDPT.


         Now, set BLTADAT ($dff074) equal to $8000.  (Set
         this register only AFTER you've set BLTCON0) Only
         two more registers must be set before you can
         activate the blitter:  BLTAFWM and BLTALWM.
         ($dff044 and $dff046) Store a $ffff into both.


         Finally, you're ready to start the blitter by
         writing to the BLTSIZE register ($dff058).  Use the
         following formula to determine the value that you
         should store into this register:


      BLTSIZE = (dmax * 64) + 66


         Because writing to BLTSIZE turns on the blitter,
         this should be the last register that you set.
"@_© 2002 Winnicki.net
*/