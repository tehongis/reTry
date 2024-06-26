#ifndef CLIB_DISK_PROTOS_H
#define CLIB_DISK_PROTOS_H

/*
**	$VER: disk_protos.h 47.1 (30.11.2021)
**
**	'C' prototypes. For use with 32 bit integers only.
**
**	Copyright (C) 2019-2022 Hyperion Entertainment CVBA.
**	    Developed under license.
*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#ifndef  RESOURCES_DISK_H
#include <resources/disk.h>
#endif
BOOL AllocUnit( LONG unitNum );
VOID FreeUnit( LONG unitNum );
struct DiskResourceUnit *GetUnit( struct DiskResourceUnit *unitPointer );
VOID GiveUnit( VOID );
LONG GetUnitID( LONG unitNum );
/*--- functions in V37 or higher (Release 2.04) ---*/
/*------ new for V37 ------*/
LONG ReadUnitID( LONG unitNum );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* CLIB_DISK_PROTOS_H */
