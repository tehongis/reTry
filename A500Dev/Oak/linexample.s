linetest:
    move.w	#$4000,$dff09a     ; INTENA  - disable all interrupts
    move.w	#$01a0,$dff096     ; DMACON - disable bitplane, copper, sprite

    lea.l	screen(pc),a1      ; move address of screen into a1
    lea.l	bplcop+2(pc),a2    ; move address of plcop+2 into a2

                                   ; set BPL1PTH / BPL1PTL in bplcop to screen
    move.l	a1,d1              ; move screen pointer into d1
    move.w	d1,4(a2)           ; move a word to set BPL1PTL in bplcop
    swap	d1                 ; swap words in the 32 bit register d1
    move.w	d1,(a2)            ; move a word to set BPL1PTH in bplcop

    lea.l	copper(pc),a1      ; move address of copper into a1
    move.l	a1,$dff080         ; move long copper address into COP1LCH / COP1LCL

    move.w	#$8180,$dff096     ; DMACON - enable bitplane, copper

    bsr	initlinedraw               ; branch to subroutine initlinedraw

main:
    moveq	#100,d0            ; line pos x1 in d0
    moveq	#100,d1            ; line pos y1 in d1

    move.w	$dff00a,d2         ; move value in JOY0DAT into d2
    move.w	d2,d3              ; move value in d2 into d3
    andi.w	#$ff,d2            ; line pos x2 is mouse x values in d2
    lsr.w	#8,d3              ; line pos y2 is mouse y values in d3

    bsr.s	linedraw           ; branch to subroutine linedraw

    btst	#6,$bfe001         ; test left mouse button
    bne.s	main               ; if not pressed goto main

    move.l	4.w,a6             ; make a6 point to ExecBase of exec.library
    move.l	156(a6),a6         ; IVBLIT points to GfxBase
    move.l	38(a6),$dff080     ; copinit ptr to copper start up list restore workbench copperlist

    move.w	#$8020,$dff096     ; DMACON enable sprite
    rts                            ; return from subroutine

; ----------------------------------------------
; Linedraw subroutine is omitted, but goes here.
; The subroutine has it's own code listing.
; swid = 40 ; screen width in bytes (part of the Linedraw listing)
; ----------------------------------------------

initlinedraw:
    lea.l	screen(pc),a0      ; move address of screen into a0
    lea.l	octant(pc),a1      ; move screen of octant into a1
    move.l	#$dff000,a2        ; move value into a2

waitinit:                          ; wait for blitter
    btst	#6,$2(a2)          ; DMACONR test Blitter DMA enable
    bne.s	waitinit           ; if not Blitter DMA enable goto waitinit
    move.l	#-1,$44(a2)        ; BLTAFWM / BLTALWM
    move.l	#$ffff8000,$72(a2) ; BLTBDAT / BLTADAT
    move.w	#swid,$60(a2)      ; BLTCMOD
    move.w	#swid,$66(a2)      ; BLTDMOD
    rts                            ; return from subroutine

octant:
    dc.w	$0051,$0055,$0059,$005d
    dc.w	$0041,$0049,$0045,$004d
    dc.w	$0011,$0015,$0019,$001d
    dc.w	$0001,$0009,$0005,$000d

copper:
    dc.w	$2001,$fffe     ; wait for vpos >= $20 and hpos >= $0
    dc.w	$0102,$0000     ; set BPLCON1 (scroll)
    dc.w	$0104,$0000     ; set BPLCON2 (video)
    dc.w	$0108,$0000     ; BPL1MOD (odd bitplanes)
    dc.w	$010a,$0000     ; BPL2MOD (even bitplanes)
    dc.w	$008e,$2c81     ; DIWSTRT upper left corner at y/vpos = $2c, x = $81
    dc.w	$0090,$f4c1     ; DIWSTOP enable PAL trick
    dc.w	$0090,$38c1     ; DIWSTOP lower right corner at y/vpos = $12c, 
    dc.w	$0092,$0038     ; DDFSTRT data fetch start at vpos = DIWSTRT, hpos = $38
    dc.w	$0094,$00d0     ; DDFSTOP data fetch stop at vpos = DIWSTOP, hpos = $d0
    dc.w	$0180,$0000     ; COLOR00 set to black - background color
    dc.w	$0182,$0ff0     ; COLOR01 set to yellow - foreground color
    dc.w	$2c01,$fffe     ; wait for vpos >= $2c and hpos >= $0
bplcop:
    dc.w	$00e0,$0000     ; BPL1PTH (high bit 16-31)
    dc.w	$00e2,$0000     ; BPL1PTL (low bit 0-15)
    dc.w	$0100,$1200     ; BPLCON0 enable 1 bitplane, enable color burst
    dc.w	$ffdf,$fffe     ; wait for vpos >= $ff and hpos >= $de
    dc.w	$2c01,$fffe     ; wait for vpos >= $12c and hpos >= $0 (counter roll over)
    dc.w	$0100,$0200     ; BPLCON0 disable bitplane - older PAL chips
    dc.w	$ffff,$fffe     ; wait for vpos >= $ff and hpos >= $fe
                                ; wait indefinitely - until next vertical blanking

screen:
    blk.w	5120,0          ; Allocate mem for a 320x256 screen