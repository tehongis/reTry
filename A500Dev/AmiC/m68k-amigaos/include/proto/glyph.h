#ifndef _PROTO_GLYPH_H
#define _PROTO_GLYPH_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_GLYPH_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/glyph_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *GlyphBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/glyph.h>
#else
#include <inline/glyph.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/glyph_protos.h>
#endif
#else
#include <pragma/glyph_lib.h>
#endif

#endif	/*  _PROTO_GLYPH_H  */
