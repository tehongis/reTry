* ProTracker2.2a replay routine by Crayon/Noxious. Improved and modified
* by Teeme of Fist! Unlimited in 1992. Share and enjoy! :)
* Rewritten for Devpac (slightly..) by CJ.

; slight edits by Tero Hongisto
; pt_init with a0 pointing to module data.

N_Note = 0  ; W
N_Cmd = 2  ; W
N_Cmdlo = 3  ; B
N_Start = 4  ; L
N_Length = 8  ; W
N_LoopStart = 10 ; L
N_Replen = 14 ; W
N_Period = 16 ; W
N_FineTune = 18 ; B
N_Volume = 19 ; B
N_DMABit = 20 ; W
N_TonePortDirec = 22 ; B
N_TonePortSpeed = 23 ; B
N_WantedPeriod = 24 ; W
N_VibratoCmd = 26 ; B
N_VibratoPos = 27 ; B
N_TremoloCmd = 28 ; B
N_TremoloPos = 29 ; B
N_WaveControl = 30 ; B
N_GlissFunk = 31 ; B
N_SampleOffset = 32 ; B
N_PattPos = 33 ; B
N_LoopCount = 34 ; B
N_FunkOffset = 35 ; B
N_WaveStart = 36 ; L
N_RealLength = 40 ; W
pt_SongDataPtr = -18
pt_Speed = -14
pt_Counter = -13
pt_SongPos = -12
pt_PBreakPos = -11
pt_PosJumpFlag = -10
pt_PBreakFlag = -9
pt_LowMask = -8
pt_PattDelTime = -7
pt_PattDelTime2 = -6
pt_PatternPos = -4
pt_DMACONTemp = -2


;	A little (not very good!) example code to
;  	play a module
;
;	movem.l	d0-d7/a0-a6,-(a7)
;	move.l	ExecBase,a6
;	jsr	Disable(a6)
;	bsr.s	pt_Init
;VBlankLoop:
;	cmpi.b	#$40,$dff006	;should use WaitTOF()
;	bne.s	VBlankLoop	;from graphics.library
;	bsr.L	pt_music
;	btst 	#6,$bfe001
;	bne.s 	VBlankLoop
;Exit:
;	bsr	pt_End
;	move.l	ExecBase,a6
;	jsr	Enable(a6)
;	movem.l	(a7)+,d0-d7/a0-a6
;	rts




pt_Init:
	lea			Variables,a5
	lea			$dff000,a6
	move.l	a0,pt_SongDataPtr(a5)
	lea			952(a0),a1
	moveq		#127,D0
	moveq		#0,D1
MTLoop:
	move.l	d1,d2
	subq.w	#1,d0
MTLoop2:
	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	MTLoop
	dbf	d0,MTLoop2
	addq.b	#1,d2

	move.l	a5,a1
	suba.w	#142,a1
	asl.l	#8,d2
	asl.l	#2,d2
	addi.l	#1084,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#30,d0
MTLoop3:
	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	add.l	d1,a2
	adda.w	#30,a0
	dbf	d0,MTLoop3

	ori.b	#2,$bfe001
	move.b	#6,pt_Speed(a5)
	clr.b	pt_Counter(a5)
	clr.b	pt_SongPos(a5)
	clr.w	pt_PatternPos(a5)
pt_End:
	clr.w	$0A8(a6)
	clr.w	$0B8(a6)
	clr.w	$0C8(a6)
	clr.w	$0D8(a6)
	move.w	#$f,$096(a6)
	rts

pt_Music:
	movem.l	d0-d4/a0-a6,-(a7)
	addq.b	#1,pt_Counter(a5)
	move.b	pt_Counter(a5),d0
	cmp.b	pt_Speed(a5),d0
	blo.s	pt_NoNewNote
	clr.b	pt_Counter(a5)
	tst.b	pt_PattDelTime2(a5)
	beq.s	pt_GetNewNote
	bsr.s	pt_NoNewAllChannels
	bra	pt_Dskip

pt_NoNewNote:
	bsr.s	pt_NoNewAllChannels
	bra	pt_NoNewPosYet
pt_NoNewAllChannels:
	move.w	#$a0,d5
	move.l	a5,a4
	suba.w	#318,a4
	bsr	pt_CheckEfx
	move.w	#$b0,d5
	adda.w	#44,a4
	bsr	pt_CheckEfx
	move.w	#$c0,d5
	adda.w	#44,a4
	bsr	pt_CheckEfx
	move.w	#$d0,d5
	adda.w	#44,a4
	bra	pt_CheckEfx
pt_GetNewNote:
	move.l	pt_SongDataPtr(a5),a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b	pt_SongPos(a5),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pt_PatternPos(a5),d1
	clr.w	pt_DMACONTemp(a5)

	move.w	#$a0,d5
	move.l	a5,a4
	suba.w	#318,a4
	bsr.s	pt_PlayVoice
	move.w	#$b0,d5
	adda.w	#44,a4
	bsr.s	pt_PlayVoice
	move.w	#$c0,d5
	adda.w	#44,a4
	bsr.s	pt_PlayVoice
	move.w	#$d0,d5
	adda.w	#44,a4
	bsr.s	pt_PlayVoice
	bra	pt_SetDMA

pt_PlayVoice:
	tst.l	(a4)
	bne.s	pt_PlvSkip
	bsr	pt_PerNop
pt_PlvSkip:
	move.l	(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	N_Cmd(a4),d2
	andi.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	andi.b	#$f0,d0
	or.b	d0,d2
	beq	pt_SetRegs
	moveq	#0,d3
	move.l	a5,a1
	suba.w	#142,a1
	move	d2,d4
	subq.l	#1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l	(a1,d2.l),N_Start(a4)
	move.w	(a3,d4.l),N_Length(a4)
	move.w	(a3,d4.l),N_RealLength(a4)
	move.b	2(a3,d4.l),N_FineTune(a4)
	move.b	3(a3,d4.l),N_Volume(a4)
	move.w	4(a3,d4.l),d3 ; Get repeat
	beq.s	pt_NoLoop
	move.l	N_Start(a4),d2 ; Get start
	add.w	d3,d3
	add.l	d3,d2		; Add repeat
	move.l	d2,N_LoopStart(a4)
	move.l	d2,N_WaveStart(a4)
	move.w	4(a3,d4.l),d0	; Get repeat
	add.w	6(a3,d4.l),d0	; Add replen
	move.w	d0,N_Length(a4)
	move.w	6(a3,d4.l),N_Replen(a4)	; Save replen
	moveq	#0,d0
	move.b	N_Volume(a4),d0
	move.w	d0,8(a6,d5.w)	; Set volume
	bra.s	pt_SetRegs

pt_NoLoop:
	move.l	N_Start(a4),d2
	add.l	d3,d2
	move.l	d2,N_LoopStart(a4)
	move.l	d2,N_WaveStart(a4)
	move.w	6(a3,d4.l),N_Replen(a4)	; Save replen
	moveq	#0,d0
	move.b	N_Volume(a4),d0
	move.w	d0,8(a6,d5.w)	; Set volume
pt_SetRegs:
	move.w	(a4),d0
	andi.w	#$0fff,d0
	beq	pt_CheckMoreEfx	; If no note
	move.w	2(a4),d0
	andi.w	#$0ff0,d0
	cmpi.w	#$0e50,d0
	beq.s	pt_DoSetFineTune
	move.b	2(a4),d0
	andi.b	#$0f,d0
	cmpi.b	#3,d0	; TonePortamento
	beq.s	pt_ChkTonePorta
	cmpi.b	#5,d0
	beq.s	pt_ChkTonePorta
	cmpi.b	#9,d0	; Sample Offset
	bne.s	pt_SetPeriod
	bsr	pt_CheckMoreEfx
	bra.s	pt_SetPeriod

pt_DoSetFineTune:
	bsr	pt_SetFineTune
	bra.s	pt_SetPeriod

pt_ChkTonePorta:
	bsr	pt_SetTonePorta
	bra	pt_CheckMoreEfx

pt_SetPeriod:
	movem.l	d0-d1/a0-a1,-(a7)
	move.w	(a4),d1
	andi.w	#$0fff,d1
	lea	pt_PeriodTable(pc),a1
	moveq	#0,d0
	moveq	#36,d7
pt_FtuLoop:
	cmp.w	(a1,d0.w),d1
	bhs.s	pt_FtuFound
	addq.l	#2,d0
	dbf	d7,pt_FtuLoop
pt_FtuFound:
	moveq	#0,d1
	move.b	N_FineTune(a4),d1
	mulu	#72,d1
	add.l	d1,a1
	move.w	(a1,d0.w),N_Period(a4)
	movem.l	(a7)+,d0-d1/a0-a1

	move.w	2(a4),d0
	andi.w	#$0ff0,d0
	cmpi.w	#$0ed0,d0 ; Notedelay
	beq	pt_CheckMoreEfx

	move.w	N_DMABit(a4),$096(a6)
	btst	#2,N_WaveControl(a4)
	bne.s	pt_Vibnoc
	clr.b	N_VibratoPos(a4)
pt_Vibnoc:
	btst	#6,N_WaveControl(a4)
	bne.s	pt_Trenoc
	clr.b	N_TremoloPos(a4)
pt_Trenoc:
	move.l	N_Start(a4),(a6,d5.w)	; Set start
	move.w	N_Length(a4),4(a6,d5.w)	; Set length
	move.w	N_Period(a4),d0
	move.w	d0,6(a6,d5.w)		; Set period
	move.w	N_DMABit(a4),d0
	or.w	d0,pt_DMACONTemp(a5)
	bra	pt_CheckMoreEfx

pt_SetDMA:
	bsr	pt_DMAWaitLoop
	move.w	pt_DMACONTemp(a5),d0
	ori.w	#$8000,d0
	move.w	d0,$096(a6)
	bsr	pt_DMAWaitLoop
	move.l	a5,a4
	suba.w	#186,a4
	move.l	N_LoopStart(a4),$d0(a6)
	move.w	N_Replen(a4),$d4(a6)
	suba.w	#44,a4
	move.l	N_LoopStart(a4),$c0(a6)
	move.w	N_Replen(a4),$c4(a6)
	suba.w	#44,a4
	move.l	N_LoopStart(a4),$b0(a6)
	move.w	N_Replen(a4),$b4(a6)
	suba.w	#44,a4
	move.l	N_LoopStart(a4),$a0(a6)
	move.w	N_Replen(a4),$a4(a6)

pt_Dskip:
	addi.w	#16,pt_PatternPos(a5)
	move.b	pt_PattDelTime(a5),d0
	beq.s	pt_Dskc
	move.b	d0,pt_PattDelTime2(a5)
	clr.b	pt_PattDelTime(a5)
pt_Dskc:
	tst.b	pt_PattDelTime2(a5)
	beq.s	pt_Dska
	subq.b	#1,pt_PattDelTime2(a5)
	beq.s	pt_Dska
	sub.w	#16,pt_PatternPos(a5)
pt_Dska:
	tst.b	pt_PBreakFlag(a5)
	beq.s	pt_Nnpysk
	clr.b	pt_PBreakFlag(a5)
	moveq	#0,d0
	move.b	pt_PBreakPos(a5),d0
	clr.b	pt_PBreakPos(a5)
	lsl.w	#4,d0
	move.w	d0,pt_PatternPos(a5)
pt_Nnpysk:
	cmpi.w	#1024,pt_PatternPos(a5)
	blo.s	pt_NoNewPosYet
pt_NextPosition:
	moveq	#0,d0
	move.b	pt_PBreakPos(a5),d0
	lsl.w	#4,d0
	move.w	d0,pt_PatternPos(a5)
	clr.b	pt_PBreakPos(a5)
	clr.b	pt_PosJumpFlag(a5)
	addq.b	#1,pt_SongPos(a5)
	andi.b	#$7F,pt_SongPos(a5)
	move.b	pt_SongPos(a5),d1
	move.l	pt_SongDataPtr(a5),a0
	cmp.b	950(a0),d1
	blo.s	pt_NoNewPosYet
	clr.b	pt_SongPos(a5)
pt_NoNewPosYet:
	tst.b	pt_PosJumpFlag(a5)
	bne.s	pt_NextPosition
	movem.l	(a7)+,d0-d4/a0-a6
	rts

pt_CheckEfx:
	bsr	pt_UpdateFunk
	move.w	N_Cmd(a4),d0
	andi.w	#$0fff,d0
	beq.s	pt_PerNop
	move.b	N_Cmd(a4),d0
	andi.b	#$0f,d0
	beq.s	pt_Arpeggio
	cmpi.b	#1,d0
	beq	pt_PortaUp
	cmpi.b	#2,d0
	beq	pt_PortaDown
	cmpi.b	#3,d0
	beq	pt_TonePortamento
	cmpi.b	#4,d0
	beq	pt_Vibrato
	cmpi.b	#5,d0
	beq	pt_TonePlusVolSlide
	cmpi.b	#6,d0
	beq	pt_VibratoPlusVolSlide
	cmpi.b	#$E,d0
	beq	pt_E_Commands
SetBack:
	move.w	N_Period(a4),6(a6,d5.w)
	cmpi.b	#7,d0
	beq	pt_Tremolo
	cmpi.b	#$a,d0
	beq	pt_VolumeSlide
pt_Return2:
	rts

pt_PerNop:
	move.w	N_Period(a4),6(a6,d5.w)
	rts

pt_Arpeggio:
	moveq	#0,d0
	move.b	pt_Counter(a5),d0
	divs	#3,d0
	swap	d0
	tst.w	D0
	beq.s	pt_Arpeggio2
	cmpi.w	#2,d0
	beq.s	pt_Arpeggio1
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	lsr.b	#4,d0
	bra.s	pt_Arpeggio3

pt_Arpeggio1:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	andi.b	#15,d0
	bra.s	pt_Arpeggio3

pt_Arpeggio2:
	move.w	N_Period(a4),d2
	bra.s	pt_Arpeggio4

pt_Arpeggio3:
	add.w	d0,d0
	moveq	#0,d1
	move.b	N_FineTune(a4),d1
	mulu	#72,d1
	lea	pt_PeriodTable(pc),a0
	add.w	d1,a0
	moveq	#0,d1
	move.w	N_Period(a4),d1
	moveq	#36,d7
pt_ArpLoop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	pt_Arpeggio4
	addq.w	#2,a0
	dbf	d7,pt_ArpLoop
	rts

pt_Arpeggio4:
	move.w	d2,6(a6,d5.w)
	rts

pt_FinePortaUp:
	tst.b	pt_Counter(a5)
	bne.s	pt_Return2
	move.b	#$0f,pt_LowMask(a5)
pt_PortaUp:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	and.b	pt_LowMask(a5),d0
	st	pt_LowMask(a5)
	sub.w	d0,N_Period(a4)
	move.w	N_Period(a4),d0
	andi.w	#$0fff,d0
	cmpi.w	#113,d0
	bpl.s	pt_PortaUskip
	andi.w	#$f000,N_Period(a4)
	ori.w	#113,N_Period(a4)
pt_PortaUskip:
	move.w	N_Period(a4),d0
	andi.w	#$0fff,d0
	move.w	d0,6(a6,d5.w)
	rts

pt_FinePortaDown:
	tst.b	pt_Counter(a5)
	bne	pt_Return2
	move.b	#$0f,pt_LowMask(a5)
pt_PortaDown:
	clr.w	d0
	move.b	N_Cmdlo(a4),d0
	and.b	pt_LowMask(a5),d0
	st	pt_LowMask(a5)
	add.w	d0,N_Period(a4)
	move.w	N_Period(a4),d0
	andi.w	#$0fff,d0
	cmpi.w	#856,d0
	bmi.s	pt_PortaDskip
	andi.w	#$f000,N_Period(a4)
	ori.w	#856,N_Period(a4)
pt_PortaDskip:
	move.w	N_Period(a4),d0
	andi.w	#$0fff,d0
	move.w	d0,6(a6,d5.w)
	rts

pt_SetTonePorta:
	move.l	a0,-(a7)
	move.w	(a4),d2
	andi.w	#$0fff,d2
	moveq	#0,d0
	move.b	N_FineTune(a4),d0
	mulu	#74,d0
	lea	pt_PeriodTable(pc),a0
	add.w	d0,a0
	moveq	#0,d0
pt_StpLoop:
	cmp.w	(a0,d0.w),d2
	bhs.s	pt_StpFound
	addq.w	#2,d0
	cmpi.w	#74,d0
	blo.s	pt_StpLoop
	moveq	#70,d0
pt_StpFound:
	move.b	N_FineTune(a4),d2
	andi.b	#8,d2
	beq.s	pt_StpGoss
	tst.w	d0
	beq.s	pt_StpGoss
	subq.w	#2,d0
pt_StpGoss:
	move.w	(a0,d0.w),d2
	move.l	(a7)+,a0
	move.w	d2,N_WantedPeriod(a4)
	move.w	N_Period(a4),d0
	clr.b	N_TonePortDirec(a4)
	cmp.w	d0,d2
	beq.s	pt_ClearTonePorta
	bge	pt_Return2
	move.b	#1,N_TonePortDirec(a4)
	rts

pt_ClearTonePorta:
	clr.w	N_WantedPeriod(a4)
	rts

pt_TonePortamento:
	move.b	N_Cmdlo(a4),d0
	beq.s	pt_TonePortNoChange
	move.b	d0,N_TonePortSpeed(a4)
	clr.b	N_Cmdlo(a4)
pt_TonePortNoChange:
	tst.w	N_WantedPeriod(a4)
	beq	pt_Return2
	moveq	#0,d0
	move.b	N_TonePortSpeed(a4),d0
	tst.b	N_TonePortDirec(a4)
	bne.s	pt_TonePortaUp
pt_TonePortaDown:
	add.w	d0,N_Period(a4)
	move.w	N_WantedPeriod(a4),d0
	cmp.w	N_Period(a4),d0
	bgt.s	pt_TonePortaSetPer
	move.w	N_WantedPeriod(a4),N_Period(a4)
	clr.w	N_WantedPeriod(a4)
	bra.s	pt_TonePortaSetPer

pt_TonePortaUp:
	sub.w	d0,N_Period(a4)
	move.w	N_WantedPeriod(a4),d0
	cmp.w	N_Period(a4),d0     	; was cmpi!!!!
	blt.s	pt_TonePortaSetPer
	move.w	N_WantedPeriod(a4),N_Period(a4)
	clr.w	N_WantedPeriod(a4)

pt_TonePortaSetPer:
	move.w	N_Period(a4),d2
	move.b	N_GlissFunk(a4),d0
	andi.b	#$0f,d0
	beq.s	pt_GlissSkip
	moveq	#0,d0
	move.b	N_FineTune(a4),d0
	mulu	#72,d0
	lea	pt_PeriodTable(pc),a0
	add.w	d0,a0
	moveq	#0,d0
pt_GlissLoop:
	cmp.w	(a0,d0.w),d2
	bhs.s	pt_GlissFound
	addq.w	#2,d0
	cmpi.w	#72,d0
	blo.s	pt_GlissLoop
	moveq	#70,d0
pt_GlissFound:
	move.w	(a0,d0.w),d2
pt_GlissSkip:
	move.w	d2,6(a6,d5.w) ; Set period
	rts

pt_Vibrato:
	move.b	N_Cmdlo(a4),d0
	beq.s	pt_Vibrato2
	move.b	N_VibratoCmd(a4),d2
	andi.b	#$0f,d0
	beq.s	pt_VibSkip
	andi.b	#$f0,d2
	or.b	d0,d2
pt_VibSkip:
	move.b	N_Cmdlo(a4),d0
	andi.b	#$f0,d0
	beq.s	pt_VibSkip2
	andi.b	#$0f,d2
	or.b	d0,d2
pt_VibSkip2:
	move.b	d2,N_VibratoCmd(a4)
pt_Vibrato2:
	move.b	N_VibratoPos(a4),d0
	lea	pt_VibratoTable(pc),a0
	lsr.w	#2,d0
	andi.w	#$001f,d0
	moveq	#0,d2
	move.b	N_WaveControl(a4),d2
	andi.b	#$03,d2
	beq.s	pt_Vib_Sine
	lsl.b	#3,d0
	cmpi.b	#1,d2
	beq.s	pt_Vib_RampDown
	st	d2
	bra.s	pt_Vib_Set
pt_Vib_RampDown:
	tst.b	N_VibratoPos(a4)
	bpl.s	pt_Vib_RampDown2
	st	d2
	sub.b	d0,d2
	bra.s	pt_Vib_Set
pt_Vib_RampDown2:
	move.b	d0,d2
	bra.s	pt_Vib_Set
pt_Vib_Sine:
	move.b	(a0,d0.w),d2
pt_Vib_Set:
	move.b	N_VibratoCmd(a4),d0
	andi.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	N_Period(a4),d0
	tst.b	N_VibratoPos(a4)
	bmi.s	pt_VibratoNeg
	add.w	d2,d0
	bra.s	pt_Vibrato3
pt_VibratoNeg:
	sub.w	d2,d0
pt_Vibrato3:
	move.w	d0,6(a6,d5.w)
	move.b	N_VibratoCmd(a4),d0
	lsr.w	#2,d0
	andi.w	#$3C,d0
	add.b	d0,N_VibratoPos(a4)
	rts

pt_TonePlusVolSlide:
	bsr	pt_TonePortNoChange
	bra	pt_VolumeSlide

pt_VibratoPlusVolSlide:
	bsr.s	pt_Vibrato2
	bra	pt_VolumeSlide

pt_Tremolo:
	move.b	N_Cmdlo(a4),d0
	beq.s	pt_Tremolo2
	move.b	N_TremoloCmd(a4),d2
	andi.b	#$0f,d0
	beq.s	pt_TreSkip
	andi.b	#$f0,d2
	or.b	d0,d2
pt_TreSkip:
	move.b	N_Cmdlo(a4),d0
	and.b	#$f0,d0
	beq.s	pt_TreSkip2
	andi.b	#$0f,d2
	or.b	d0,d2
pt_TreSkip2:
	move.b	d2,N_TremoloCmd(a4)
pt_Tremolo2:
	move.b	N_TremoloPos(a4),d0
	lea	pt_VibratoTable(pc),a0
	lsr.w	#2,d0
	andi.w	#$1f,d0
	moveq	#0,d2
	move.b	N_WaveControl(a4),d2
	lsr.b	#4,d2
	andi.b	#3,d2
	beq.s	pt_Tre_Sine
	lsl.b	#3,d0
	cmpi.b	#1,d2
	beq.s	pt_Tre_RampDown
	st	d2
	bra.s	pt_Tre_Set
pt_Tre_RampDown:
	tst.b	N_VibratoPos(a4)
	bpl.s	pt_Tre_RampDown2
	st	d2
	sub.b	d0,d2
	bra.s	pt_Tre_Set
pt_Tre_RampDown2:
	move.b	d0,d2
	bra.s	pt_Tre_Set
pt_Tre_Sine:
	move.b	(a0,d0.w),d2
pt_Tre_Set:
	move.b	N_TremoloCmd(a4),d0
	andi.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b	N_Volume(a4),d0
	tst.b	N_TremoloPos(a4)
	bmi.s	pt_TremoloNeg
	add.w	d2,d0
	bra.s	pt_Tremolo3
pt_TremoloNeg:
	sub.w	d2,d0
pt_Tremolo3:
	bpl.s	pt_TremoloSkip
	clr.w	d0
pt_TremoloSkip:
	cmpi.w	#$40,d0
	bls.s	pt_TremoloOk
	move.w	#$40,d0
pt_TremoloOk:
	move.w	d0,8(a6,d5.w)
	move.b	N_TremoloCmd(a4),d0
	lsr.w	#2,d0
	andi.w	#$3c,d0
	add.b	d0,N_TremoloPos(a4)
	rts

pt_SampleOffset:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	beq.s	pt_SoNoNew
	move.b	d0,N_SampleOffset(a4)
pt_SoNoNew:
	move.b	N_SampleOffset(a4),d0
	lsl.w	#7,d0
	cmp.w	N_Length(a4),d0
	bge.s	pt_SofSkip
	sub.w	d0,N_Length(a4)
	add.w	d0,d0
	add.l	d0,N_Start(a4)
	rts
pt_SofSkip:
	move.w	#1,N_Length(a4)
	rts

pt_VolumeSlide:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	pt_VolSlideDown
pt_VolSlideUp:
	add.b	d0,N_Volume(a4)
	cmpi.b	#$40,N_Volume(a4)
	bmi.s	pt_VsuSkip
	move.b	#$40,N_Volume(a4)
pt_VsuSkip:
	move.b	N_Volume(a4),d0
	move.w	d0,8(a6,d5.w)
	rts

pt_VolSlideDown:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
pt_VolSlideDown2:
	sub.b	d0,N_Volume(a4)
	bpl.s	pt_VsdSkip
	clr.b	N_Volume(a4)
pt_VsdSkip:
	move.b	N_Volume(a4),d0
	move.w	d0,8(a6,d5.w)
	rts

pt_PositionJump:
	move.b	N_Cmdlo(a4),pt_SongPos(a5)
	subq.b	#1,pt_SongPos(a5)
pt_PJ2:
	clr.b	pt_PBreakPos(a5)
	st 	pt_PosJumpFlag(a5)
	rts

pt_VolumeChange:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	cmpi.b	#$40,d0
	bls.s	pt_VolumeOk
	moveq	#$40,d0
pt_VolumeOk:
	move.b	d0,N_Volume(a4)
	move.w	d0,8(a6,d5.w)
	rts

pt_PatternBreak:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	move.l	d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	andi.b	#$0f,d2
	add.b	d2,d0
	cmpi.b	#63,d0
	bhi.s	pt_PJ2
	move.b	d0,pt_PBreakPos(a5)
	st	pt_PosJumpFlag(a5)
	rts

pt_SetSpeed:
	move.b	3(a4),d0
	beq	pt_Return2
	clr.b	pt_Counter(a5)
	move.b	d0,pt_Speed(a5)
	rts

pt_CheckMoreEfx:
	bsr	pt_UpdateFunk
	move.b	2(a4),d0
	andi.b	#$0f,d0
	cmpi.b	#$9,d0
	beq	pt_SampleOffset
	cmpi.b	#$b,d0
	beq	pt_PositionJump
	cmpi.b	#$d,d0
	beq.s	pt_PatternBreak
	cmpi.b	#$e,d0
	beq.s	pt_E_Commands
	cmpi.b	#$f,d0
	beq.s	pt_SetSpeed
	cmpi.b	#$c,d0
	beq	pt_VolumeChange
	bra	pt_PerNop

pt_E_Commands:
	move.b	N_Cmdlo(a4),d0
	andi.b	#$f0,d0
	lsr.b	#4,d0
	beq.s	pt_FilterOnOff
	cmpi.b	#1,d0
	beq	pt_FinePortaUp
	cmpi.b	#2,d0
	beq	pt_FinePortaDown
	cmpi.b	#3,d0
	beq.s	pt_SetGlissControl
	cmpi.b	#4,d0
	beq	pt_SetVibratoControl
	cmpi.b	#5,d0
	beq	pt_SetFineTune
	cmpi.b	#6,d0
	beq	pt_JumpLoop
	cmpi.b	#7,d0
	beq	pt_SetTremoloControl
	cmpi.b	#9,d0
	beq	pt_RetrigNote
	cmpi.b	#$a,d0
	beq	pt_VolumeFineUp
	cmpi.b	#$b,d0
	beq	pt_VolumeFineDown
	cmpi.b	#$c,d0
	beq	pt_NoteCut
	cmpi.b	#$d,d0
	beq	pt_NoteDelay
	cmpi.b	#$e,d0
	beq	pt_PatternDelay
	cmpi.b	#$f,d0
	beq	pt_FunkIt
	rts

pt_FilterOnOff:
	move.b	N_Cmdlo(a4),d0
	andi.b	#1,d0
	add.b	d0,d0
	andi.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

pt_SetGlissControl:
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	andi.b	#$f0,N_GlissFunk(a4)
	or.b	d0,N_GlissFunk(a4)
	rts

pt_SetVibratoControl:
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	andi.b	#$f0,N_WaveControl(a4)
	or.b	d0,N_WaveControl(a4)
	rts

pt_SetFineTune:
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	move.b	d0,N_FineTune(a4)
	rts

pt_JumpLoop:
	tst.b	pt_Counter(a5)
	bne	pt_Return2
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	beq.s	pt_SetLoop
	tst.b	N_LoopCount(a4)
	beq.s	pt_JumpCnt
	subq.b	#1,N_LoopCount(a4)
	beq	pt_Return2
pt_JmpLoop:
	move.b	N_PattPos(a4),pt_PBreakPos(a5)
	st	pt_PBreakFlag(a5)
	rts

pt_JumpCnt:
	move.b	d0,N_LoopCount(a4)
	bra.s	pt_JmpLoop

pt_SetLoop:
	move.w	pt_PatternPos(a5),d0
	lsr.w	#4,d0
	move.b	d0,N_PattPos(a4)
	rts

pt_SetTremoloControl:
	move.b	N_Cmdlo(a4),d0
*	andi.b	#$0f,d0
	lsl.b	#4,d0
	andi.b	#$0f,N_WaveControl(a4)
	or.b	d0,N_WaveControl(a4)
	rts

pt_RetrigNote:
	move.l	d1,-(a7)
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	beq.s	pt_RtnEnd
	moveq	#0,d1
	move.b	pt_Counter(a5),d1
	bne.s	pt_RtnSkp
	move.w	(a4),d1
	andi.w	#$0fff,d1
	bne.s	pt_RtnEnd
	moveq	#0,d1
	move.b	pt_Counter(a5),d1
pt_RtnSkp:
	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	pt_RtnEnd
pt_DoRetrig:
	move.w	N_DMABit(a4),$096(a6)	; Channel DMA off
	move.l	N_Start(a4),(a6,d5.w)	; Set sampledata pointer
	move.w	N_Length(a4),4(a6,d5.w)	; Set length
	bsr	pt_DMAWaitLoop
	move.w	N_DMABit(a4),d0
	ori.w	#$8000,d0
*	bset	#15,d0
	move.w	d0,$096(a6)
	bsr	pt_DMAWaitLoop
	move.l	N_LoopStart(a4),(a6,d5.w)
	move.l	N_Replen(a4),4(a6,d5.w)
pt_RtnEnd:
	move.l	(a7)+,d1
	rts

pt_VolumeFineUp:
	tst.b	pt_Counter(a5)
	bne	pt_Return2
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	andi.b	#$d,d0
	bra	pt_VolSlideUp

pt_VolumeFineDown:
	tst.b	pt_Counter(a5)
	bne	pt_Return2
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	bra	pt_VolSlideDown2

pt_NoteCut:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	cmp.b	pt_Counter(a5),d0   ; was cmpi!!!
	bne	pt_Return2
	clr.b	N_Volume(a4)
	clr.w	8(a6,d5.w)
	rts

pt_NoteDelay:
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	cmp.b	pt_Counter(a5),d0   ; was cmpi!!!
	bne	pt_Return2
	move.w	(a4),d0
	beq	pt_Return2
	move.l	d1,-(a7)
	bra	pt_DoRetrig

pt_PatternDelay:
	tst.b	pt_Counter(a5)
	bne	pt_Return2
	moveq	#0,d0
	move.b	N_Cmdlo(a4),d0
	andi.b	#$0f,d0
	tst.b	pt_PattDelTime2(a5)
	bne	pt_Return2
	addq.b	#1,d0
	move.b	d0,pt_PattDelTime(a5)
	rts

pt_FunkIt:
	tst.b	pt_Counter(a5)
	bne	pt_Return2
	move.b	N_Cmdlo(a4),d0
*	andi.b	#$0f,d0
	lsl.b	#4,d0
	andi.b	#$0f,N_GlissFunk(a4)
	or.b	d0,N_GlissFunk(a4)
	tst.b	d0
	beq	pt_Return2
pt_UpdateFunk:
	movem.l	a0/d1,-(a7)
	moveq	#0,d0
	move.b	N_GlissFunk(a4),d0
	lsr.b	#4,d0
	beq.s	pt_FunkEnd
	lea	pt_FunkTable(pc),a0
	move.b	(a0,d0.w),d0
	add.b	d0,N_FunkOffset(a4)
	btst	#7,N_FunkOffset(a4)
	beq.s	pt_FunkEnd
	clr.b	N_FunkOffset(a4)

	move.l	N_LoopStart(a4),d0
	moveq	#0,d1
	move.w	N_Replen(a4),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	N_WaveStart(a4),a0
	addq.w	#1,a0
	cmp.l	d0,a0
	blo.s	pt_FunkOk
	move.l	N_LoopStart(a4),a0
pt_FunkOk:
	move.l	a0,N_WaveStart(a4)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
pt_FunkEnd:
	movem.l	(a7)+,a0/d1
	rts

pt_DMAWaitLoop:
	move.w	d1,-(sp)
	moveq	#5,d0		; wait 5+1 lines
.loop	move.b	6(a6),d1		; read current raster position
.wait	cmp.b	6(a6),d1
	beq.s	.wait		; wait until it changes
	dbf	d0,.loop		; do it again
	move.w	(sp)+,d1
	rts


pt_FunkTable: dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

pt_VibratoTable:
	dc.b 0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

pt_PeriodTable:
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

pt_Chan1Temp:
	dc.l	0,0,0,0,0,$00010000,0,0,0,0,0
pt_Chan2Temp:
	dc.l	0,0,0,0,0,$00020000,0,0,0,0,0
pt_Chan3Temp:
	dc.l	0,0,0,0,0,$00040000,0,0,0,0,0
pt_Chan4Temp:
	dc.l	0,0,0,0,0,$00080000,0,0,0,0,0
pt_SampleStarts:
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
*pt_SongDataPtr:
	dc.l 0
*pt_Speed:
	dc.b 6
*pt_Counter:
	dc.b 0
*pt_SongPos:
	dc.b 0
*pt_PBreakPos:
	dc.b 0
*pt_PosJumpFlag:
	dc.b 0
*pt_PBreakFlag:
	dc.b 0
*pt_LowMask:
	dc.b 0
*pt_PattDelTime:
	dc.b 0
*pt_PattDelTime2:
	dc.b 0,0
*pt_PatternPos:
	dc.w 0
*pt_DMACONtemp:
	dc.w 0
Variables:
