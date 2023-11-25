#ifndef PROTO_INTEGER_H
#define PROTO_INTEGER_H

/*
**	$VER: integer.h 47.6 (6.12.2021)
**
**	Lattice 'C' style prototype/pragma header file combo
**
**	Copyright (C) 2019-2022 Hyperion Entertainment CVBA.
**	    Developed under license.
*/

/****************************************************************************/

#ifdef _NO_INLINE

#include <clib/integer_protos.h>

#else

/***************************************************************************/

#ifndef __NOLIBBASE__

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */

extern struct Library * IntegerBase;
#endif /* __NOLIBBASE__ */

/****************************************************************************/

#if defined(LATTICE) || defined(__SASC) || defined(_DCC)

#ifndef PRAGMAS_INTEGER_PRAGMAS_H
#include <pragmas/integer_pragmas.h>
#endif /* PRAGMAS_INTEGER_PRAGMAS_H */

/****************************************************************************/

#elif defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)

#ifndef PRAGMA_INTEGER_LIB_H
#include <pragma/integer_lib.h>
#endif /* PRAGMA_INTEGER_LIB_H */

/****************************************************************************/

#elif defined(__VBCC__)

#include <clib/integer_protos.h>

#ifndef _VBCCINLINE_INTEGER_H
#include <inline/integer_protos.h>
#endif /* _VBCCINLINE_INTEGER_H */

/****************************************************************************/

#elif defined(__GNUC__)

#if defined(mc68000)
#ifndef _INLINE_INTEGER_H
#include <inline/integer.h>
#endif /* _INLINE_INTEGER_H */
#else
#include <clib/integer_protos.h>
#endif /* mc68000 */

/****************************************************************************/

/* Any other compiler */
#else

#include <clib/integer_protos.h>

/****************************************************************************/

#endif /* __GNUC__ */

/****************************************************************************/

#endif /* _NO_INLINE */

/****************************************************************************/

#endif /* PROTO_INTEGER_H */
