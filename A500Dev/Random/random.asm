; Testing pseudorandom
; http://www.pjhutchison.org/emulation/AmigaAsmTutorial.txt


ExecBase	equ $4

_LVOOutput	EQU	-60
_LVOWrite	EQU	-48
_LVOOpenLibrary	EQU	-552

main	
	move.l	ExecBase.l,a6
	lea	dosname,a1
	moveq.l	#0,d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,dosbase

	move.l	d0,a6
	jsr	_LVOOutput(a6)
	move.l	d0,output_handle

	jsr 	rand
	move.l	d0,d2
	jsr	print

	moveq.l	#0,d0
	rts

rand
	move.l randseed,d0
	addq.l #5,d0
	rol.l d0,d0
	move.l d0,randseed
	rts

print
	move.l	output_handle,d1
	lea     buffer,a0
	move.l  a0,d2
	move.l	#10,d3
	move.l	dosbase,a6
	jsr	_LVOWrite(a6)
	rts

nibble
        and    #$0f,d2     ;just keep low byte
        add    #$30,d2     ;add $30
        cmp    #$3a,d2     ;was it a digit?
        bcs    _ok
        add    #7,d2       ;else add 7
_ok
        rts

dosbase
	dc.l	0

output_handle
	dc.l	0

randseed
	dc.l	$a1b2c3d4
buffer
	dc.b	"00000000",10,13,0

dosname	dc.b 	"dos.library",0

