#ifndef PREFS_INPUT_H
#define PREFS_INPUT_H
/*
**	$VER: input.h 38.2 (28.6.91)
**	Includes Release 40.15
**
**	File format for input preferences
**
**	(C) Copyright 1991-1993 Commodore-Amiga, Inc.
**	All Rights Reserved
*/

/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_IFFPARSE_H
#include <libraries/iffparse.h>
#endif

#ifndef DEVICES_TIMER_H
#include <devices/timer.h>
#endif


/*****************************************************************************/


#define ID_INPT MAKE_ID('I','N','P','T')


struct InputPrefs
{
    char	   ip_Keymap[16];
    UWORD	   ip_PointerTicks;
    struct timeval ip_DoubleClick;
    struct timeval ip_KeyRptDelay;
    struct timeval ip_KeyRptSpeed;
    WORD	   ip_MouseAccel;
};


/*****************************************************************************/


#endif /* PREFS_INPUT_H */
