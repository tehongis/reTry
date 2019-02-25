; reTry demo 2019 - PlotterRevisited
;
; MIT License
;
; Copyright (c) 2017 Tero Hongisto
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

SCREENLOC = $040c+40*4


	org $0801
basic
	db 	$0d, $08, $e0, $07, $9e, $28, $32, $30, $36, $34, $29, $00 ;2016 SYS (2064)

	org $0810
init

	lda	#$00
	lda	#$20
scrclear	
	sta	$0400,x
	sta	$0500,x
	sta	$0600,x
	sta	$0700,x
	inx
	bne	scrclear

	lda	#$1e
	sta	$d018
	
	ldx	#$00
	txa	
	clc
charmap	
	sta SCREENLOC+40*0,x
	adc	#$01
	sta SCREENLOC+40*1,x
	adc	#$01
	sta SCREENLOC+40*2,x
	adc	#$01
	sta SCREENLOC+40*3,x
	adc	#$01
	sta SCREENLOC+40*4,x
	adc	#$01
	sta SCREENLOC+40*5,x
	adc	#$01
	sta SCREENLOC+40*6,x
	adc	#$01
	sta SCREENLOC+40*7,x
	adc	#$01
	sta SCREENLOC+40*8,x
	adc	#$01
	sta SCREENLOC+40*9,x
	adc	#$01
	sta SCREENLOC+40*10,x
	adc	#$01
	sta SCREENLOC+40*11,x
	adc	#$01
	sta SCREENLOC+40*12,x
	adc	#$01
	sta SCREENLOC+40*13,x
	adc	#$01
	sta SCREENLOC+40*14,x
	adc	#$01
	sta SCREENLOC+40*15,x
	inx
	cpx	#$10
	bne	charmap

.loop
	jmp	.loop
	