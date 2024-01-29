#ifndef _PROTO_CONSOLE_H
#define _PROTO_CONSOLE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_CONSOLE_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/console_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Device *ConsoleDevice;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/console.h>
#else
#include <inline/console.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/console_protos.h>
#endif
#else
#include <pragma/console_lib.h>
#endif

#endif	/*  _PROTO_CONSOLE_H  */
