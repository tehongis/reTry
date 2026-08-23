DIWSTRT     EQU     $08E
DIWSTOP     EQU     $090
DDFSTRT     EQU     $092
DDFSTOP     EQU     $094
BPLCON0     EQU     $100
BPLCON1     EQU     $102
BPLCON2     EQU     $104
BPL1MOD     EQU     $108
BPL2MOD     EQU     $10A
BPL1PTH     EQU     $0E0
BPL1PTL     EQU     $0E2
BPL2PTH     EQU     $0E4
BPL2PTL     EQU     $0E6  
COP1LCH     EQU     $080
COP1LCL     EQU     $082
COPJMP1     EQU     $088
DMACON      EQU     $096
INTENA      EQU     $09A
INTREQ      EQU     $09C
VHPOSR      EQU     $006
DMACONR     EQU     $002
INTENAR     EQU     $01C
COLOR00     EQU     $180
COLOR01     EQU     $182
COLOR02     EQU     $184
COLOR03     EQU     $186

	XDEF    Copper
	XDEF    BitmapA
	XDEF    BitmapB
	XDEF    Bpl1PtrHi
	XDEF    Bpl1PtrLo
	XDEF    Bpl2PtrHi
	XDEF    Bpl2PtrLo	
	XDEF    ModuleData

; =============================================================================
; 5. CHIP RAM DATA (COPPER-LISTA)
; =============================================================================
	SECTION CopperData,DATA_C
	EVEN

Copper:
	; --- 2. RUUDUN KOOT JA REKISTERIT ---
	dc.w    DIWSTRT,$2C81           ; Ruudun aloitus (Standardi 320x256)
	dc.w    DIWSTOP,$2CC1           ; Ruudun lopetus
	dc.w    DDFSTRT,$0038           ; Datafetch aloitus
	dc.w    DDFSTOP,$00D0           ; Datafetch lopetus

	dc.w    BPL1PTH
Bpl1PtrHi:
	dc.w    0
	dc.w    BPL1PTL
Bpl1PtrLo:
	dc.w    0

	dc.w    BPL2PTH
Bpl2PtrHi:
	dc.w    0
	dc.w    BPL2PTL
Bpl2PtrLo:
	dc.w    0

	dc.w    BPLCON0,$2200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000
	dc.w    BPL1MOD,$0028
	dc.w    BPL2MOD,$0028

	; --- 3. RUUDUN SISÄPUOLEN VÄRIT ---
	; Pakotetaan ruudun alue mustaksi ja viivat valkoisiksi

	; --- RUUDUN YLÄOSA (RASTERIRAJAT) ---
	dc.w    $2a11,$7FFE,COLOR00,$0000 
	dc.w    $2b11,$7FFE,COLOR00,$0f00 

	dc.w    $2c11,$7FFE
	dc.w    COLOR00,$0555           ; Taustaväri = Musta
	dc.w    COLOR01,$0fff           ; Viivaväri = Kirkas valkoinen
	dc.w    COLOR02,$00f0           ; Taustaväri = Musta
	dc.w    COLOR03,$0000           ; Viivaväri = Kirkas valkoinen

	; --- HYPPY LINJAN 255 YLI LINJALLE 256 ---
	dc.w    $FFDF,$FFFE               
	dc.w    $0001,$FFFE               

	; --- RUUDUN ALAOSA ---
	dc.w    $2d11,$FFFE,COLOR00,$0f00 
	dc.w    $2e11,$FFFE,COLOR00,$0000 

	; Copper-listan virallinen lopetus
	dc.w    $FFFF,$FFFE               
	dc.w    $FFFF,$FFFE

; =============================================================================
; MUSIIKKIDATA
; =============================================================================
	SECTION MusicData,DATA_C
	EVEN

ModuleData:
	incbin "scoopex-slideshow.mod"
	EVEN

; =============================================================================
; 6. CHIP RAM PUSKURIT (GRAFIIKKA-ALUE)
; =============================================================================
	SECTION ScreenBuffers,DATA_C    
	EVEN

BitmapA:        
	dcb.b   40*256*2,0                
	EVEN                        

BitmapB:        
	dcb.b   40*256*2,0                
	EVEN
