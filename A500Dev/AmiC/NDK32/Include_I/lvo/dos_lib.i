**
**	dos_lib library vector offsets (LVOs)
**
**	For recreational and educational use only.
**	Some assembly required.
**	Use only if linking against amiga.lib is not a viable alternative.
**

_LVOOpen equ -30
_LVOClose equ -36
_LVORead equ -42
_LVOWrite equ -48
_LVOInput equ -54
_LVOOutput equ -60
_LVOSeek equ -66
_LVODeleteFile equ -72
_LVORename equ -78
_LVOLock equ -84
_LVOUnLock equ -90
_LVODupLock equ -96
_LVOExamine equ -102
_LVOExNext equ -108
_LVOInfo equ -114
_LVOCreateDir equ -120
_LVOCurrentDir equ -126
_LVOIoErr equ -132
_LVOCreateProc equ -138
_LVOExit equ -144
_LVOLoadSeg equ -150
_LVOUnLoadSeg equ -156
_LVODeviceProc equ -174
_LVOSetComment equ -180
_LVOSetProtection equ -186
_LVODateStamp equ -192
_LVODelay equ -198
_LVOWaitForChar equ -204
_LVOParentDir equ -210
_LVOIsInteractive equ -216
_LVOExecute equ -222
_LVOAllocDosObject equ -228
_LVOFreeDosObject equ -234
_LVODoPkt equ -240
_LVOSendPkt equ -246
_LVOWaitPkt equ -252
_LVOReplyPkt equ -258
_LVOAbortPkt equ -264
_LVOLockRecord equ -270
_LVOLockRecords equ -276
_LVOUnLockRecord equ -282
_LVOUnLockRecords equ -288
_LVOSelectInput equ -294
_LVOSelectOutput equ -300
_LVOFGetC equ -306
_LVOFPutC equ -312
_LVOUnGetC equ -318
_LVOFRead equ -324
_LVOFWrite equ -330
_LVOFGets equ -336
_LVOFPuts equ -342
_LVOVFWritef equ -348
_LVOVFPrintf equ -354
_LVOFlush equ -360
_LVOSetVBuf equ -366
_LVODupLockFromFH equ -372
_LVOOpenFromLock equ -378
_LVOParentOfFH equ -384
_LVOExamineFH equ -390
_LVOSetFileDate equ -396
_LVONameFromLock equ -402
_LVONameFromFH equ -408
_LVOSplitName equ -414
_LVOSameLock equ -420
_LVOSetMode equ -426
_LVOExAll equ -432
_LVOReadLink equ -438
_LVOMakeLink equ -444
_LVOChangeMode equ -450
_LVOSetFileSize equ -456
_LVOSetIoErr equ -462
_LVOFault equ -468
_LVOPrintFault equ -474
_LVOErrorReport equ -480
_LVOCli equ -492
_LVOCreateNewProc equ -498
_LVORunCommand equ -504
_LVOGetConsoleTask equ -510
_LVOSetConsoleTask equ -516
_LVOGetFileSysTask equ -522
_LVOSetFileSysTask equ -528
_LVOGetArgStr equ -534
_LVOSetArgStr equ -540
_LVOFindCliProc equ -546
_LVOMaxCli equ -552
_LVOSetCurrentDirName equ -558
_LVOGetCurrentDirName equ -564
_LVOSetProgramName equ -570
_LVOGetProgramName equ -576
_LVOSetPrompt equ -582
_LVOGetPrompt equ -588
_LVOSetProgramDir equ -594
_LVOGetProgramDir equ -600
_LVOSystemTagList equ -606
_LVOAssignLock equ -612
_LVOAssignLate equ -618
_LVOAssignPath equ -624
_LVOAssignAdd equ -630
_LVORemAssignList equ -636
_LVOGetDeviceProc equ -642
_LVOFreeDeviceProc equ -648
_LVOLockDosList equ -654
_LVOUnLockDosList equ -660
_LVOAttemptLockDosList equ -666
_LVORemDosEntry equ -672
_LVOAddDosEntry equ -678
_LVOFindDosEntry equ -684
_LVONextDosEntry equ -690
_LVOMakeDosEntry equ -696
_LVOFreeDosEntry equ -702
_LVOIsFileSystem equ -708
_LVOFormat equ -714
_LVORelabel equ -720
_LVOInhibit equ -726
_LVOAddBuffers equ -732
_LVOCompareDates equ -738
_LVODateToStr equ -744
_LVOStrToDate equ -750
_LVOInternalLoadSeg equ -756
_LVOInternalUnLoadSeg equ -762
_LVONewLoadSeg equ -768
_LVOAddSegment equ -774
_LVOFindSegment equ -780
_LVORemSegment equ -786
_LVOCheckSignal equ -792
_LVOReadArgs equ -798
_LVOFindArg equ -804
_LVOReadItem equ -810
_LVOStrToLong equ -816
_LVOMatchFirst equ -822
_LVOMatchNext equ -828
_LVOMatchEnd equ -834
_LVOParsePattern equ -840
_LVOMatchPattern equ -846
_LVOFreeArgs equ -858
_LVOFilePart equ -870
_LVOPathPart equ -876
_LVOAddPart equ -882
_LVOStartNotify equ -888
_LVOEndNotify equ -894
_LVOSetVar equ -900
_LVOGetVar equ -906
_LVODeleteVar equ -912
_LVOFindVar equ -918
_LVOCliInitNewcli equ -930
_LVOCliInitRun equ -936
_LVOWriteChars equ -942
_LVOPutStr equ -948
_LVOVPrintf equ -954
_LVOParsePatternNoCase equ -966
_LVOMatchPatternNoCase equ -972
_LVOSameDevice equ -984
_LVOExAllEnd equ -990
_LVOSetOwner equ -996
_LVOVolumeRequestHook equ -1014
_LVOGetCurrentDir equ -1026
_LVOPutErrStr equ -1128
_LVOErrorOutput equ -1134
_LVOSelectError equ -1140
_LVODoShellMethodTagList equ -1152
_LVOScanStackToken equ -1158
