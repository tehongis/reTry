#ifndef CLIB_LAYOUT_PROTOS_H
#define CLIB_LAYOUT_PROTOS_H

/*
**	$VER: layout_protos.h 47.1 (30.11.2021)
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
#ifndef  INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif
#ifndef  INTUITION_CLASSES_H
#include <intuition/classes.h>
#endif
#ifndef  UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif
#ifndef  GADGETS_LAYOUT_H
#include <gadgets/layout.h>
#endif
/*--- functions in V40 or higher (Release 3.1) ---*/
Class *LAYOUT_GetClass( VOID );
BOOL ActivateLayoutGadget( struct Gadget *gadget, struct Window *window, struct Requester *requester, ULONG object );
VOID FlushLayoutDomainCache( struct Gadget *gadget );
BOOL RethinkLayout( struct Gadget *gadget, struct Window *window, struct Requester *requester, LONG refresh );
VOID LayoutLimits( struct Gadget *gadget, struct LayoutLimits *limits, struct TextFont *font, struct Screen *screen );
Class *PAGE_GetClass( VOID );
ULONG SetPageGadgetAttrsA( struct Gadget *gadget, Object *object, struct Window *window, struct Requester *requester, struct TagItem *tags );
ULONG SetPageGadgetAttrs( struct Gadget *gadget, Object *object, struct Window *window, struct Requester *requester, ... );
VOID RefreshPageGadget( struct Gadget *gadget, Object *object, struct Window *window, struct Requester *requester );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* CLIB_LAYOUT_PROTOS_H */
