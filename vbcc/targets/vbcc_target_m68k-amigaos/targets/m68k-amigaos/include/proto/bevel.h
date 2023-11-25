#ifndef _PROTO_BEVEL_H
#define _PROTO_BEVEL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_BEVEL_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/bevel_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *BevelBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/bevel.h>
#else
#include <inline/bevel.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/bevel_protos.h>
#endif
#else
#include <pragma/bevel_lib.h>
#endif

#endif	/*  _PROTO_BEVEL_H  */
