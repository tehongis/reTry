	IFND	EXEC_LIB_I
EXEC_LIB_I	SET	1
**
**	$VER: exec_lib.i 39.8 (12.8.93)
**	Includes Release 40.15
**
**	Library vector table
**
**	(C) Copyright 1985-1993 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

	FUNCDEF	Supervisor
	FUNCDEF	ExitIntr
	FUNCDEF	Schedule
	FUNCDEF	Reschedule
	FUNCDEF	Switch
	FUNCDEF	Dispatch
	FUNCDEF	Exception
	FUNCDEF	InitCode
	FUNCDEF	InitStruct
	FUNCDEF	MakeLibrary
	FUNCDEF	MakeFunctions
	FUNCDEF	FindResident
	FUNCDEF	InitResident
	FUNCDEF	Alert
	FUNCDEF	Debug
	FUNCDEF	Disable
	FUNCDEF	Enable
	FUNCDEF	Forbid
	FUNCDEF	Permit
	FUNCDEF	SetSR
	FUNCDEF	SuperState
	FUNCDEF	UserState
	FUNCDEF	SetIntVector
	FUNCDEF	AddIntServer
	FUNCDEF	RemIntServer
	FUNCDEF	Cause
	FUNCDEF	Allocate
	FUNCDEF	Deallocate
	FUNCDEF	AllocMem
	FUNCDEF	AllocAbs
	FUNCDEF	FreeMem
	FUNCDEF	AvailMem
	FUNCDEF	AllocEntry
	FUNCDEF	FreeEntry
	FUNCDEF	Insert
	FUNCDEF	AddHead
	FUNCDEF	AddTail
	FUNCDEF	Remove
	FUNCDEF	RemHead
	FUNCDEF	RemTail
	FUNCDEF	Enqueue
	FUNCDEF	FindName
	FUNCDEF	AddTask
	FUNCDEF	RemTask
	FUNCDEF	FindTask
	FUNCDEF	SetTaskPri
	FUNCDEF	SetSignal
	FUNCDEF	SetExcept
	FUNCDEF	Wait
	FUNCDEF	Signal
	FUNCDEF	AllocSignal
	FUNCDEF	FreeSignal
	FUNCDEF	AllocTrap
	FUNCDEF	FreeTrap
	FUNCDEF	AddPort
	FUNCDEF	RemPort
	FUNCDEF	PutMsg
	FUNCDEF	GetMsg
	FUNCDEF	ReplyMsg
	FUNCDEF	WaitPort
	FUNCDEF	FindPort
	FUNCDEF	AddLibrary
	FUNCDEF	RemLibrary
	FUNCDEF	OldOpenLibrary
	FUNCDEF	CloseLibrary
	FUNCDEF	SetFunction
	FUNCDEF	SumLibrary
	FUNCDEF	AddDevice
	FUNCDEF	RemDevice
	FUNCDEF	OpenDevice
	FUNCDEF	CloseDevice
	FUNCDEF	DoIO
	FUNCDEF	SendIO
	FUNCDEF	CheckIO
	FUNCDEF	WaitIO
	FUNCDEF	AbortIO
	FUNCDEF	AddResource
	FUNCDEF	RemResource
	FUNCDEF	OpenResource
	FUNCDEF	RawIOInit
	FUNCDEF	RawMayGetChar
	FUNCDEF	RawPutChar
	FUNCDEF	RawDoFmt
	FUNCDEF	GetCC
	FUNCDEF	TypeOfMem
	FUNCDEF	Procure
	FUNCDEF	Vacate
	FUNCDEF	OpenLibrary
	FUNCDEF	InitSemaphore
	FUNCDEF	ObtainSemaphore
	FUNCDEF	ReleaseSemaphore
	FUNCDEF	AttemptSemaphore
	FUNCDEF	ObtainSemaphoreList
	FUNCDEF	ReleaseSemaphoreList
	FUNCDEF	FindSemaphore
	FUNCDEF	AddSemaphore
	FUNCDEF	RemSemaphore
	FUNCDEF	SumKickData
	FUNCDEF	AddMemList
	FUNCDEF	CopyMem
	FUNCDEF	CopyMemQuick
	FUNCDEF	CacheClearU
	FUNCDEF	CacheClearE
	FUNCDEF	CacheControl
	FUNCDEF	CreateIORequest
	FUNCDEF	DeleteIORequest
	FUNCDEF	CreateMsgPort
	FUNCDEF	DeleteMsgPort
	FUNCDEF	ObtainSemaphoreShared
	FUNCDEF	AllocVec
	FUNCDEF	FreeVec
	FUNCDEF	CreatePool
	FUNCDEF	DeletePool
	FUNCDEF	AllocPooled
	FUNCDEF	FreePooled
	FUNCDEF	AttemptSemaphoreShared
	FUNCDEF	ColdReboot
	FUNCDEF	StackSwap
	FUNCDEF	ChildFree
	FUNCDEF	ChildOrphan
	FUNCDEF	ChildStatus
	FUNCDEF	ChildWait
	FUNCDEF	CachePreDMA
	FUNCDEF	CachePostDMA
	FUNCDEF	AddMemHandler
	FUNCDEF	RemMemHandler
	FUNCDEF	ObtainQuickVector
	FUNCDEF	ExecReserved04
	FUNCDEF	ExecReserved05
	FUNCDEF	ExecReserved06
	FUNCDEF	TaggedOpenLibrary
	FUNCDEF	ReadGayle
	FUNCDEF	ExecReserved08

	ENDC	; EXEC_LIB_I
