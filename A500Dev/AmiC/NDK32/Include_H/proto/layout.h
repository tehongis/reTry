#ifndef PROTO_LAYOUT_H
#define PROTO_LAYOUT_H

/*
**	$VER: layout.h 47.5 (6.12.2021)
**
**	Lattice 'C' style prototype/pragma header file combo
**
**	Copyright (C) 2019-2022 Hyperion Entertainment CVBA.
**	    Developed under license.
*/

/****************************************************************************/

#ifdef _NO_INLINE

#include <clib/layout_protos.h>

#else

/***************************************************************************/

#ifndef __NOLIBBASE__

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */

extern struct Library * LayoutBase;
#endif /* __NOLIBBASE__ */

/****************************************************************************/

#if defined(LATTICE) || defined(__SASC) || defined(_DCC)

#ifndef PRAGMAS_LAYOUT_PRAGMAS_H
#include <pragmas/layout_pragmas.h>
#endif /* PRAGMAS_LAYOUT_PRAGMAS_H */

/****************************************************************************/

#elif defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)

#ifndef PRAGMA_LAYOUT_LIB_H
#include <pragma/layout_lib.h>
#endif /* PRAGMA_LAYOUT_LIB_H */

/****************************************************************************/

#elif defined(__VBCC__)

#include <clib/layout_protos.h>

#ifndef _VBCCINLINE_LAYOUT_H
#include <inline/layout_protos.h>
#endif /* _VBCCINLINE_LAYOUT_H */

/****************************************************************************/

#elif defined(__GNUC__)

#if defined(mc68000)
#ifndef _INLINE_LAYOUT_H
#include <inline/layout.h>
#endif /* _INLINE_LAYOUT_H */
#else
#include <clib/layout_protos.h>
#endif /* mc68000 */

/****************************************************************************/

/* Any other compiler */
#else

#include <clib/layout_protos.h>

/****************************************************************************/

#endif /* __GNUC__ */

/****************************************************************************/

#endif /* _NO_INLINE */

/****************************************************************************/

#endif /* PROTO_LAYOUT_H */
