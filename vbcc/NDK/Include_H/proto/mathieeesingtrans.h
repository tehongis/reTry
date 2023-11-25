#ifndef PROTO_MATHIEEESINGTRANS_H
#define PROTO_MATHIEEESINGTRANS_H

/*
**	$VER: mathieeesingtrans.h 47.4 (6.12.2021)
**
**	Lattice 'C' style prototype/pragma header file combo
**
**	Copyright (C) 2019-2022 Hyperion Entertainment CVBA.
**	    Developed under license.
*/

/****************************************************************************/

#ifdef _NO_INLINE

#include <clib/mathieeesingtrans_protos.h>

#else

/****************************************************************************/

#ifndef __NOLIBBASE__

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */

extern struct Library * MathIeeeSingTransBase;
#endif /* __NOLIBBASE__ */

/****************************************************************************/

#if defined(LATTICE) || defined(__SASC) || defined(_DCC)

#ifndef PRAGMAS_MATHIEEESINGTRANS_PRAGMAS_H
#include <pragmas/mathieeesingtrans_pragmas.h>
#endif /* PRAGMAS_MATHIEEESINGTRANS_PRAGMAS_H */

/****************************************************************************/

#elif defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)

#ifndef PRAGMA_MATHIEEESINGTRANS_LIB_H
#include <pragma/mathieeesingtrans_lib.h>
#endif /* PRAGMA_MATHIEEESINGTRANS_LIB_H */

/****************************************************************************/

#elif defined(__VBCC__)

#include <clib/mathieeesingtrans_protos.h>

#ifndef _VBCCINLINE_MATHIEEESINGTRANS_H
#include <inline/mathieeesingtrans_protos.h>
#endif /* _VBCCINLINE_MATHIEEESINGTRANS_H */

/****************************************************************************/

#elif defined(__GNUC__)

#if defined(mc68000)
#ifndef _INLINE_MATHIEEESINGTRANS_H
#include <inline/mathieeesingtrans.h>
#endif /* _INLINE_MATHIEEESINGTRANS_H */
#else
#include <clib/mathieeesingtrans_protos.h>
#endif /* mc68000 */

/****************************************************************************/

/* Any other compiler */
#else

#include <clib/mathieeesingtrans_protos.h>

/****************************************************************************/

#endif /* __GNUC__ */

/****************************************************************************/

#endif /* _NO_INLINE */

/****************************************************************************/

#endif /* PROTO_MATHIEEESINGTRANS_H */
