#ifndef CLIB_LOCALE_PROTOS_H
#define CLIB_LOCALE_PROTOS_H

/*
**	$VER: locale_protos.h 47.1 (30.11.2021)
**
**	'C' prototypes. For use with 32 bit integers only.
**
**	Copyright (C) 2019-2022 Hyperion Entertainment CVBA.
**	    Developed under license.
*/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef  LIBRARIES_LOCALE_H
#include <libraries/locale.h>
#endif
#ifndef  DOS_DOS_H
#include <dos/dos.h>
#endif
#ifndef  UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif
#ifndef  UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif
#ifndef  REXX_STORAGE_H
#include <rexx/storage.h>
#endif
/*--- functions in V38 or higher (Release 2.1) ---*/
VOID CloseCatalog( struct Catalog *catalog );
VOID CloseLocale( struct Locale *locale );
ULONG ConvToLower( struct Locale *locale, ULONG character );
ULONG ConvToUpper( struct Locale *locale, ULONG character );
VOID FormatDate( struct Locale *locale, CONST_STRPTR fmtTemplate, CONST struct DateStamp *date, struct Hook *putCharFunc );
APTR FormatString( struct Locale *locale, CONST_STRPTR fmtTemplate, APTR dataStream, struct Hook *putCharFunc );
STRPTR GetCatalogStr( CONST struct Catalog *catalog, LONG stringNum, CONST_STRPTR defaultString );
STRPTR GetLocaleStr( struct Locale *locale, ULONG stringNum );
BOOL IsAlNum( struct Locale *locale, ULONG character );
BOOL IsAlpha( struct Locale *locale, ULONG character );
BOOL IsCntrl( struct Locale *locale, ULONG character );
BOOL IsDigit( struct Locale *locale, ULONG character );
BOOL IsGraph( struct Locale *locale, ULONG character );
BOOL IsLower( struct Locale *locale, ULONG character );
BOOL IsPrint( struct Locale *locale, ULONG character );
BOOL IsPunct( struct Locale *locale, ULONG character );
BOOL IsSpace( struct Locale *locale, ULONG character );
BOOL IsUpper( struct Locale *locale, ULONG character );
BOOL IsXDigit( struct Locale *locale, ULONG character );
struct Catalog *OpenCatalogA( struct Locale *locale, CONST_STRPTR name, CONST struct TagItem *tags );
struct Catalog *OpenCatalog( struct Locale *locale, CONST_STRPTR name, ... );
struct Locale *OpenLocale( CONST_STRPTR name );
BOOL ParseDate( CONST struct Locale *locale, struct DateStamp *date, CONST_STRPTR fmtTemplate, struct Hook *getCharFunc );
ULONG StrConvert( struct Locale *locale, CONST_STRPTR string, APTR buffer, ULONG bufferSize, ULONG type );
LONG StrnCmp( struct Locale *locale, CONST_STRPTR string1, CONST_STRPTR string2, LONG length, ULONG type );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* CLIB_LOCALE_PROTOS_H */
