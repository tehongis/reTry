; =============================================================================
; LAITTEISTO- JA OS-VAKIOT (KORJATTU REKISTERISUOJAUS)
; =============================================================================
CUSTOM      EQU     $DFF000
COP1LCH     EQU     $080
COP1LCL     EQU     $082
COPJMP1     EQU     $088
DMACON      EQU     $096
INTENA      EQU     $09A
INTREQ      EQU     $09C
DMACONR     EQU     $002
INTENAR     EQU     $01C

DMA_SET      EQU    $8000
DMA_MASTER   EQU    $0200
DMA_BITPLANE EQU    $0080
DMA_COPPER   EQU    $0040
DMA_BLITTER  EQU    $0010
DMA_AUDIO    EQU    $000F

EXECBASE    EQU     4
_LVOForbid  EQU     -$84
_LVODisable EQU     -$78
_LVOEnable  EQU     -$7E
_LVOPermit  EQU     -$8A
_LVOOpenLibrary EQU -$198
_LVOCloseLibrary EQU -$1A2
VEC_INT3    EQU     $6C

_LVOLoadView    EQU -$DE
_LVOWaitTOF     EQU -$10E
gb_ActiView     EQU 34
gb_copinit      EQU 38              ; Siirtymä Workbenchin kuparilistaan

	SECTION Code,CODE

	XDEF    BackBuffer
	XDEF    FrontBuffer
	XDEF    FrameCounter

	; --- Tuodaan muualta ---
	XREF    VBlank_IRQ
	XREF    Copper
	XREF    BitmapA
	XREF    BitmapB

	XREF    ModuleData
	XREF    _mt_init
	XREF    _mt_end
	XREF    _mt_install
	XREF    _mt_remove
	XREF    _mt_Enable

Start:
	; KORJAUS 1: Tallenna kaikki AmigaOS:n rekisterit pinoon talteen heti alussa!
	movem.l d2-d7/a2-a6,-(sp)

	move.l  EXECBASE,a6
	lea     GfxName(pc),a1
	moveq   #0,d0               
	jsr     _LVOOpenLibrary(a6)
	move.l  d0,GfxBase
	beq     NoGfxLibrary

	; 3. Otetaan Workbench talteen
	move.l  GfxBase,a1
	move.l  gb_ActiView(a1),OldView 

	move.l  EXECBASE,a6
	jsr     _LVOForbid(a6)

	; 4. Tyhjennetään Workbench LoadView(NULL)
	move.l  GfxBase,a6
	suba.l  a1,a1               
	jsr     _LVOLoadView(a6)
	jsr     _LVOWaitTOF(a6)     
	jsr     _LVOWaitTOF(a6)     

	; 5. Suljetaan OS-keskeytykset
	move.l  EXECBASE,a6
	jsr     _LVODisable(a6)

	; 6. Otetaan custom-laitteisto haltuun (a6 = CUSTOM)
	lea     CUSTOM,a6
	
	move.w  DMACONR(a6),d0
	or.w    #$8000,d0
	move.w  d0,OldDMA
	move.w  INTENAR(a6),d0
	or.w    #$8000,d0
	move.w  d0,OldINT
	move.l  VEC_INT3,OldVector

	; Sammutetaan kaikki vanhat keskeytykset ja DMA:t alta pois
	move.w  #$7FFF,INTENA(a6)
	move.w  #$7FFF,INTREQ(a6)
	move.w  #$7FFF,DMACON(a6)

	; 8. Asetetaan oma VBlank-keskeytys Level 3
	move.l  #VBlank_IRQ,VEC_INT3

	; 9. Alustetaan kaksoispuskurit alkutilaan Chip-muistin osoitteilla
	move.l  #BitmapA,FrontBuffer     
	move.l  #BitmapB,BackBuffer     

	; 10. Aktivoidaan oma Copper-lista (High ensin, sitten Low)
	move.l  #Copper,d0
	swap    d0                      
	move.w  d0,COP1LCH(a6)          
	swap    d0                      
	move.w  d0,COP1LCL(a6)          
	move.w  #0,COPJMP1(a6)

	; Kytketään KAIKKI DMA-kanavat lennossa päälle (mukaan lukien Blitter eli $83DF!)
	move.w  #$83DF,DMACON(a6)         
	move.w  #$E020,INTENA(a6)       ; Sallitaan VBlank ja Level 6 keskeytykset
	
.WaitMouse
	btst    #6,$BFE001
	bne     .WaitMouse

	; Kun hiirtä painetaan, koodi tippuu suoraan ExitGently-palautukseen!

; =============================================================================
; PALAUTUS
; =============================================================================
ExitGently:
	lea     CUSTOM,a6
	
	move.w  #$7FFF,INTENA(a6)
	move.w  #$7FFF,INTREQ(a6)
	move.w  #$7FFF,DMACON(a6)
	
	move.l  OldVector,VEC_INT3

	; Palautetaan Workbench-kuparilista dynaamisesti GfxBasen siirtymällä
	move.l  GfxBase,a0
	move.l  gb_copinit(a0),a1       
	move.l  a1,COP1LCH(a6)
	move.w  #0,COPJMP1(a6)

    lea     CUSTOM,a6
	move.w  OldDMA,DMACON(a6)
	move.w  OldINT,INTENA(a6)

	; Palautetaan Workbench-näkymä LoadView-kutsulla
	move.l  GfxBase,a6
	move.l  OldView,a1              
	jsr     _LVOLoadView(a6)
	jsr     _LVOWaitTOF(a6)         
	jsr     _LVOWaitTOF(a6)

	; Päästetään AmigaOS kokonaan takaisin rattiin
	move.l  EXECBASE,a6
	jsr     _LVOEnable(a6)
	jsr     _LVOPermit(a6)

	; Suljetaan avattu graphics.library
	move.l  EXECBASE,a6
	move.l  GfxBase,a1
	jsr     _LVOCloseLibrary(a6)

NoGfxLibrary:

	; KORJAUS 2: Haetaan kaikki alkuperäiset rekisterit takaisin pinosta puhtaina!
	movem.l (sp)+,d2-d7/a2-a6

	moveq   #0,d0                    ; Kertoo AmigaOS:lle, että ohjelma sulkeutui ilman virheitä (Return code 0)
	rts

; =============================================================================
; ALUSTUKSEN MUUTTUJAT
; =============================================================================
	EVEN
GfxName:        dc.b    "graphics.library",0
	EVEN
GfxBase:        dc.l    0
OldView:        dc.l    0
OldDMA:         ds.w    1
OldINT:         ds.w    1
OldVector:      ds.l    1

	EVEN
FrontBuffer:    dc.l    0
	EVEN
BackBuffer:     dc.l    0
	EVEN
FrameCounter:   dc.l    0
	EVEN
