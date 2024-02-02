#ifndef _PROTO_SCROLLER_H
#define _PROTO_SCROLLER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_SCROLLER_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/scroller_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ScrollerBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/scroller.h>
#else
#include <inline/scroller.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/scroller_protos.h>
#endif
#else
#include <pragma/scroller_lib.h>
#endif

#endif	/*  _PROTO_SCROLLER_H  */
