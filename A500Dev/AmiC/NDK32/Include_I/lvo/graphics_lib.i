**
**	graphics_lib library vector offsets (LVOs)
**
**	For recreational and educational use only.
**	Some assembly required.
**	Use only if linking against amiga.lib is not a viable alternative.
**

_LVOBltBitMap equ -30
_LVOBltTemplate equ -36
_LVOClearEOL equ -42
_LVOClearScreen equ -48
_LVOTextLength equ -54
_LVOText equ -60
_LVOSetFont equ -66
_LVOOpenFont equ -72
_LVOCloseFont equ -78
_LVOAskSoftStyle equ -84
_LVOSetSoftStyle equ -90
_LVOAddBob equ -96
_LVOAddVSprite equ -102
_LVODoCollision equ -108
_LVODrawGList equ -114
_LVOInitGels equ -120
_LVOInitMasks equ -126
_LVORemIBob equ -132
_LVORemVSprite equ -138
_LVOSetCollision equ -144
_LVOSortGList equ -150
_LVOAddAnimOb equ -156
_LVOAnimate equ -162
_LVOGetGBuffers equ -168
_LVOInitGMasks equ -174
_LVODrawEllipse equ -180
_LVOAreaEllipse equ -186
_LVOLoadRGB4 equ -192
_LVOInitRastPort equ -198
_LVOInitVPort equ -204
_LVOMrgCop equ -210
_LVOMakeVPort equ -216
_LVOLoadView equ -222
_LVOWaitBlit equ -228
_LVOSetRast equ -234
_LVOMove equ -240
_LVODraw equ -246
_LVOAreaMove equ -252
_LVOAreaDraw equ -258
_LVOAreaEnd equ -264
_LVOWaitTOF equ -270
_LVOQBlit equ -276
_LVOInitArea equ -282
_LVOSetRGB4 equ -288
_LVOQBSBlit equ -294
_LVOBltClear equ -300
_LVORectFill equ -306
_LVOBltPattern equ -312
_LVOReadPixel equ -318
_LVOWritePixel equ -324
_LVOFlood equ -330
_LVOPolyDraw equ -336
_LVOSetAPen equ -342
_LVOSetBPen equ -348
_LVOSetDrMd equ -354
_LVOInitView equ -360
_LVOCBump equ -366
_LVOCMove equ -372
_LVOCWait equ -378
_LVOVBeamPos equ -384
_LVOInitBitMap equ -390
_LVOScrollRaster equ -396
_LVOWaitBOVP equ -402
_LVOGetSprite equ -408
_LVOFreeSprite equ -414
_LVOChangeSprite equ -420
_LVOMoveSprite equ -426
_LVOLockLayerRom equ -432
_LVOUnlockLayerRom equ -438
_LVOSyncSBitMap equ -444
_LVOCopySBitMap equ -450
_LVOOwnBlitter equ -456
_LVODisownBlitter equ -462
_LVOInitTmpRas equ -468
_LVOAskFont equ -474
_LVOAddFont equ -480
_LVORemFont equ -486
_LVOAllocRaster equ -492
_LVOFreeRaster equ -498
_LVOAndRectRegion equ -504
_LVOOrRectRegion equ -510
_LVONewRegion equ -516
_LVOClearRectRegion equ -522
_LVOClearRegion equ -528
_LVODisposeRegion equ -534
_LVOFreeVPortCopLists equ -540
_LVOFreeCopList equ -546
_LVOClipBlit equ -552
_LVOXorRectRegion equ -558
_LVOFreeCprList equ -564
_LVOGetColorMap equ -570
_LVOFreeColorMap equ -576
_LVOGetRGB4 equ -582
_LVOScrollVPort equ -588
_LVOUCopperListInit equ -594
_LVOFreeGBuffers equ -600
_LVOBltBitMapRastPort equ -606
_LVOOrRegionRegion equ -612
_LVOXorRegionRegion equ -618
_LVOAndRegionRegion equ -624
_LVOSetRGB4CM equ -630
_LVOBltMaskBitMapRastPort equ -636
_LVOAttemptLockLayerRom equ -654
_LVOGfxNew equ -660
_LVOGfxFree equ -666
_LVOGfxAssociate equ -672
_LVOBitMapScale equ -678
_LVOScalerDiv equ -684
_LVOTextExtent equ -690
_LVOTextFit equ -696
_LVOGfxLookUp equ -702
_LVOVideoControl equ -708
_LVOOpenMonitor equ -714
_LVOCloseMonitor equ -720
_LVOFindDisplayInfo equ -726
_LVONextDisplayInfo equ -732
_LVOGetDisplayInfoData equ -756
_LVOFontExtent equ -762
_LVOReadPixelLine8 equ -768
_LVOWritePixelLine8 equ -774
_LVOReadPixelArray8 equ -780
_LVOWritePixelArray8 equ -786
_LVOGetVPModeID equ -792
_LVOModeNotAvailable equ -798
_LVOWeighTAMatch equ -804
_LVOEraseRect equ -810
_LVOExtendFont equ -816
_LVOStripFont equ -822
_LVOCalcIVG equ -828
_LVOAttachPalExtra equ -834
_LVOObtainBestPenA equ -840
_LVOSetRGB32 equ -852
_LVOGetAPen equ -858
_LVOGetBPen equ -864
_LVOGetDrMd equ -870
_LVOGetOutlinePen equ -876
_LVOLoadRGB32 equ -882
_LVOSetChipRev equ -888
_LVOSetABPenDrMd equ -894
_LVOGetRGB32 equ -900
_LVOAllocBitMap equ -918
_LVOFreeBitMap equ -924
_LVOGetExtSpriteA equ -930
_LVOCoerceMode equ -936
_LVOChangeVPBitMap equ -942
_LVOReleasePen equ -948
_LVOObtainPen equ -954
_LVOGetBitMapAttr equ -960
_LVOAllocDBufInfo equ -966
_LVOFreeDBufInfo equ -972
_LVOSetOutlinePen equ -978
_LVOSetWriteMask equ -984
_LVOSetMaxPen equ -990
_LVOSetRGB32CM equ -996
_LVOScrollRasterBF equ -1002
_LVOFindColor equ -1008
_LVOAllocSpriteDataA equ -1020
_LVOChangeExtSpriteA equ -1026
_LVOFreeSpriteData equ -1032
_LVOSetRPAttrsA equ -1038
_LVOGetRPAttrsA equ -1044
_LVOBestModeIDA equ -1050
_LVOWriteChunkyPixels equ -1056
