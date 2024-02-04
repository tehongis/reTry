**
**	exec_lib library vector offsets (LVOs)
**
**	For recreational and educational use only.
**	Some assembly required.
**	Use only if linking against amiga.lib is not a viable alternative.
**

_LVOSupervisor equ -30
_LVOInitCode equ -72
_LVOInitStruct equ -78
_LVOMakeLibrary equ -84
_LVOMakeFunctions equ -90
_LVOFindResident equ -96
_LVOInitResident equ -102
_LVOAlert equ -108
_LVODebug equ -114
_LVODisable equ -120
_LVOEnable equ -126
_LVOForbid equ -132
_LVOPermit equ -138
_LVOSetSR equ -144
_LVOSuperState equ -150
_LVOUserState equ -156
_LVOSetIntVector equ -162
_LVOAddIntServer equ -168
_LVORemIntServer equ -174
_LVOCause equ -180
_LVOAllocate equ -186
_LVODeallocate equ -192
_LVOAllocMem equ -198
_LVOAllocAbs equ -204
_LVOFreeMem equ -210
_LVOAvailMem equ -216
_LVOAllocEntry equ -222
_LVOFreeEntry equ -228
_LVOInsert equ -234
_LVOAddHead equ -240
_LVOAddTail equ -246
_LVORemove equ -252
_LVORemHead equ -258
_LVORemTail equ -264
_LVOEnqueue equ -270
_LVOFindName equ -276
_LVOAddTask equ -282
_LVORemTask equ -288
_LVOFindTask equ -294
_LVOSetTaskPri equ -300
_LVOSetSignal equ -306
_LVOSetExcept equ -312
_LVOWait equ -318
_LVOSignal equ -324
_LVOAllocSignal equ -330
_LVOFreeSignal equ -336
_LVOAllocTrap equ -342
_LVOFreeTrap equ -348
_LVOAddPort equ -354
_LVORemPort equ -360
_LVOPutMsg equ -366
_LVOGetMsg equ -372
_LVOReplyMsg equ -378
_LVOWaitPort equ -384
_LVOFindPort equ -390
_LVOAddLibrary equ -396
_LVORemLibrary equ -402
_LVOOldOpenLibrary equ -408
_LVOCloseLibrary equ -414
_LVOSetFunction equ -420
_LVOSumLibrary equ -426
_LVOAddDevice equ -432
_LVORemDevice equ -438
_LVOOpenDevice equ -444
_LVOCloseDevice equ -450
_LVODoIO equ -456
_LVOSendIO equ -462
_LVOCheckIO equ -468
_LVOWaitIO equ -474
_LVOAbortIO equ -480
_LVOAddResource equ -486
_LVORemResource equ -492
_LVOOpenResource equ -498
_LVORawDoFmt equ -522
_LVOGetCC equ -528
_LVOTypeOfMem equ -534
_LVOProcure equ -540
_LVOVacate equ -546
_LVOOpenLibrary equ -552
_LVOInitSemaphore equ -558
_LVOObtainSemaphore equ -564
_LVOReleaseSemaphore equ -570
_LVOAttemptSemaphore equ -576
_LVOObtainSemaphoreList equ -582
_LVOReleaseSemaphoreList equ -588
_LVOFindSemaphore equ -594
_LVOAddSemaphore equ -600
_LVORemSemaphore equ -606
_LVOSumKickData equ -612
_LVOAddMemList equ -618
_LVOCopyMem equ -624
_LVOCopyMemQuick equ -630
_LVOCacheClearU equ -636
_LVOCacheClearE equ -642
_LVOCacheControl equ -648
_LVOCreateIORequest equ -654
_LVODeleteIORequest equ -660
_LVOCreateMsgPort equ -666
_LVODeleteMsgPort equ -672
_LVOObtainSemaphoreShared equ -678
_LVOAllocVec equ -684
_LVOFreeVec equ -690
_LVOCreatePool equ -696
_LVODeletePool equ -702
_LVOAllocPooled equ -708
_LVOFreePooled equ -714
_LVOAttemptSemaphoreShared equ -720
_LVOColdReboot equ -726
_LVOStackSwap equ -732
_LVOCachePreDMA equ -762
_LVOCachePostDMA equ -768
_LVOAddMemHandler equ -774
_LVORemMemHandler equ -780
_LVOObtainQuickVector equ -786
_LVONewMinList equ -828