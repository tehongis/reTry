#ifndef _INLINE_UTILITY_H
#define _INLINE_UTILITY_H

#ifndef CLIB_UTILITY_PROTOS_H
#define CLIB_UTILITY_PROTOS_H
#endif

#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#ifndef  EXEC_PORTS_H
#include <exec/ports.h>
#endif
#ifndef  UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif
#ifndef  UTILITY_DATE_H
#include <utility/date.h>
#endif
#ifndef  UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif
#ifndef  UTILITY_NAME_H
#include <utility/name.h>
#endif

#ifndef UTILITY_BASE_NAME
#define UTILITY_BASE_NAME UtilityBase
#endif

#define FindTagItem(tagVal, tagList) ({ \
  Tag _FindTagItem_tagVal = (tagVal); \
  CONST struct TagItem * _FindTagItem_tagList = (tagList); \
  ({ \
  register char * _FindTagItem__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((struct TagItem * (*)(char * __asm("a6"), Tag __asm("d0"), CONST struct TagItem * __asm("a0"))) \
  (_FindTagItem__bn - 30))(_FindTagItem__bn, _FindTagItem_tagVal, _FindTagItem_tagList); \
});})

#define GetTagData(tagValue, defaultVal, tagList) ({ \
  Tag _GetTagData_tagValue = (tagValue); \
  ULONG _GetTagData_defaultVal = (defaultVal); \
  CONST struct TagItem * _GetTagData_tagList = (tagList); \
  ({ \
  register char * _GetTagData__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), Tag __asm("d0"), ULONG __asm("d1"), CONST struct TagItem * __asm("a0"))) \
  (_GetTagData__bn - 36))(_GetTagData__bn, _GetTagData_tagValue, _GetTagData_defaultVal, _GetTagData_tagList); \
});})

#define PackBoolTags(initialFlags, tagList, boolMap) ({ \
  ULONG _PackBoolTags_initialFlags = (initialFlags); \
  CONST struct TagItem * _PackBoolTags_tagList = (tagList); \
  CONST struct TagItem * _PackBoolTags_boolMap = (boolMap); \
  ({ \
  register char * _PackBoolTags__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), ULONG __asm("d0"), CONST struct TagItem * __asm("a0"), CONST struct TagItem * __asm("a1"))) \
  (_PackBoolTags__bn - 42))(_PackBoolTags__bn, _PackBoolTags_initialFlags, _PackBoolTags_tagList, _PackBoolTags_boolMap); \
});})

#define NextTagItem(tagListPtr) ({ \
  struct TagItem ** _NextTagItem_tagListPtr = (tagListPtr); \
  ({ \
  register char * _NextTagItem__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((struct TagItem * (*)(char * __asm("a6"), struct TagItem ** __asm("a0"))) \
  (_NextTagItem__bn - 48))(_NextTagItem__bn, _NextTagItem_tagListPtr); \
});})

#define FilterTagChanges(changeList, originalList, apply) ({ \
  struct TagItem * _FilterTagChanges_changeList = (changeList); \
  struct TagItem * _FilterTagChanges_originalList = (originalList); \
  ULONG _FilterTagChanges_apply = (apply); \
  ({ \
  register char * _FilterTagChanges__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct TagItem * __asm("a0"), struct TagItem * __asm("a1"), ULONG __asm("d0"))) \
  (_FilterTagChanges__bn - 54))(_FilterTagChanges__bn, _FilterTagChanges_changeList, _FilterTagChanges_originalList, _FilterTagChanges_apply); \
});})

#define MapTags(tagList, mapList, mapType) ({ \
  struct TagItem * _MapTags_tagList = (tagList); \
  CONST struct TagItem * _MapTags_mapList = (mapList); \
  ULONG _MapTags_mapType = (mapType); \
  ({ \
  register char * _MapTags__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct TagItem * __asm("a0"), CONST struct TagItem * __asm("a1"), ULONG __asm("d0"))) \
  (_MapTags__bn - 60))(_MapTags__bn, _MapTags_tagList, _MapTags_mapList, _MapTags_mapType); \
});})

#define AllocateTagItems(numTags) ({ \
  ULONG _AllocateTagItems_numTags = (numTags); \
  ({ \
  register char * _AllocateTagItems__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((struct TagItem * (*)(char * __asm("a6"), ULONG __asm("d0"))) \
  (_AllocateTagItems__bn - 66))(_AllocateTagItems__bn, _AllocateTagItems_numTags); \
});})

#define CloneTagItems(tagList) ({ \
  CONST struct TagItem * _CloneTagItems_tagList = (tagList); \
  ({ \
  register char * _CloneTagItems__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((struct TagItem * (*)(char * __asm("a6"), CONST struct TagItem * __asm("a0"))) \
  (_CloneTagItems__bn - 72))(_CloneTagItems__bn, _CloneTagItems_tagList); \
});})

#define FreeTagItems(tagList) ({ \
  struct TagItem * _FreeTagItems_tagList = (tagList); \
  ({ \
  register char * _FreeTagItems__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct TagItem * __asm("a0"))) \
  (_FreeTagItems__bn - 78))(_FreeTagItems__bn, _FreeTagItems_tagList); \
});})

#define RefreshTagItemClones(clone, original) ({ \
  struct TagItem * _RefreshTagItemClones_clone = (clone); \
  CONST struct TagItem * _RefreshTagItemClones_original = (original); \
  ({ \
  register char * _RefreshTagItemClones__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct TagItem * __asm("a0"), CONST struct TagItem * __asm("a1"))) \
  (_RefreshTagItemClones__bn - 84))(_RefreshTagItemClones__bn, _RefreshTagItemClones_clone, _RefreshTagItemClones_original); \
});})

#define TagInArray(tagValue, tagArray) ({ \
  Tag _TagInArray_tagValue = (tagValue); \
  CONST Tag * _TagInArray_tagArray = (tagArray); \
  ({ \
  register char * _TagInArray__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((BOOL (*)(char * __asm("a6"), Tag __asm("d0"), CONST Tag * __asm("a0"))) \
  (_TagInArray__bn - 90))(_TagInArray__bn, _TagInArray_tagValue, _TagInArray_tagArray); \
});})

#define FilterTagItems(tagList, filterArray, logic) ({ \
  struct TagItem * _FilterTagItems_tagList = (tagList); \
  CONST Tag * _FilterTagItems_filterArray = (filterArray); \
  ULONG _FilterTagItems_logic = (logic); \
  ({ \
  register char * _FilterTagItems__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), struct TagItem * __asm("a0"), CONST Tag * __asm("a1"), ULONG __asm("d0"))) \
  (_FilterTagItems__bn - 96))(_FilterTagItems__bn, _FilterTagItems_tagList, _FilterTagItems_filterArray, _FilterTagItems_logic); \
});})

#define CallHookPkt(hook, object, paramPacket) ({ \
  struct Hook * _CallHookPkt_hook = (hook); \
  APTR _CallHookPkt_object = (object); \
  APTR _CallHookPkt_paramPacket = (paramPacket); \
  ({ \
  register char * _CallHookPkt__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), struct Hook * __asm("a0"), APTR __asm("a2"), APTR __asm("a1"))) \
  (_CallHookPkt__bn - 102))(_CallHookPkt__bn, _CallHookPkt_hook, _CallHookPkt_object, _CallHookPkt_paramPacket); \
});})

#define Amiga2Date(seconds, result) ({ \
  ULONG _Amiga2Date_seconds = (seconds); \
  struct ClockData * _Amiga2Date_result = (result); \
  ({ \
  register char * _Amiga2Date__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), ULONG __asm("d0"), struct ClockData * __asm("a0"))) \
  (_Amiga2Date__bn - 120))(_Amiga2Date__bn, _Amiga2Date_seconds, _Amiga2Date_result); \
});})

#define Date2Amiga(date) ({ \
  CONST struct ClockData * _Date2Amiga_date = (date); \
  ({ \
  register char * _Date2Amiga__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), CONST struct ClockData * __asm("a0"))) \
  (_Date2Amiga__bn - 126))(_Date2Amiga__bn, _Date2Amiga_date); \
});})

#define CheckDate(date) ({ \
  CONST struct ClockData * _CheckDate_date = (date); \
  ({ \
  register char * _CheckDate__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), CONST struct ClockData * __asm("a0"))) \
  (_CheckDate__bn - 132))(_CheckDate__bn, _CheckDate_date); \
});})

#define SMult32(arg1, arg2) ({ \
  LONG _SMult32_arg1 = (arg1); \
  LONG _SMult32_arg2 = (arg2); \
  ({ \
  register char * _SMult32__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), LONG __asm("d0"), LONG __asm("d1"))) \
  (_SMult32__bn - 138))(_SMult32__bn, _SMult32_arg1, _SMult32_arg2); \
});})

#define UMult32(arg1, arg2) ({ \
  ULONG _UMult32_arg1 = (arg1); \
  ULONG _UMult32_arg2 = (arg2); \
  ({ \
  register char * _UMult32__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), ULONG __asm("d0"), ULONG __asm("d1"))) \
  (_UMult32__bn - 144))(_UMult32__bn, _UMult32_arg1, _UMult32_arg2); \
});})

#define SDivMod32(dividend, divisor) ({ \
  LONG _SDivMod32_dividend = (dividend); \
  LONG _SDivMod32_divisor = (divisor); \
  ({ \
  register char * _SDivMod32__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), LONG __asm("d0"), LONG __asm("d1"))) \
  (_SDivMod32__bn - 150))(_SDivMod32__bn, _SDivMod32_dividend, _SDivMod32_divisor); \
});})

#define UDivMod32(dividend, divisor) ({ \
  ULONG _UDivMod32_dividend = (dividend); \
  ULONG _UDivMod32_divisor = (divisor); \
  ({ \
  register char * _UDivMod32__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), ULONG __asm("d0"), ULONG __asm("d1"))) \
  (_UDivMod32__bn - 156))(_UDivMod32__bn, _UDivMod32_dividend, _UDivMod32_divisor); \
});})

#define Stricmp(string1, string2) ({ \
  CONST_STRPTR _Stricmp_string1 = (string1); \
  CONST_STRPTR _Stricmp_string2 = (string2); \
  ({ \
  register char * _Stricmp__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"))) \
  (_Stricmp__bn - 162))(_Stricmp__bn, _Stricmp_string1, _Stricmp_string2); \
});})

#define Strnicmp(string1, string2, length) ({ \
  CONST_STRPTR _Strnicmp_string1 = (string1); \
  CONST_STRPTR _Strnicmp_string2 = (string2); \
  LONG _Strnicmp_length = (length); \
  ({ \
  register char * _Strnicmp__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), LONG __asm("d0"))) \
  (_Strnicmp__bn - 168))(_Strnicmp__bn, _Strnicmp_string1, _Strnicmp_string2, _Strnicmp_length); \
});})

#define ToUpper(character) ({ \
  ULONG _ToUpper_character = (character); \
  ({ \
  register char * _ToUpper__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((UBYTE (*)(char * __asm("a6"), ULONG __asm("d0"))) \
  (_ToUpper__bn - 174))(_ToUpper__bn, _ToUpper_character); \
});})

#define ToLower(character) ({ \
  ULONG _ToLower_character = (character); \
  ({ \
  register char * _ToLower__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((UBYTE (*)(char * __asm("a6"), ULONG __asm("d0"))) \
  (_ToLower__bn - 180))(_ToLower__bn, _ToLower_character); \
});})

#define ApplyTagChanges(list, changeList) ({ \
  struct TagItem * _ApplyTagChanges_list = (list); \
  CONST struct TagItem * _ApplyTagChanges_changeList = (changeList); \
  ({ \
  register char * _ApplyTagChanges__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct TagItem * __asm("a0"), CONST struct TagItem * __asm("a1"))) \
  (_ApplyTagChanges__bn - 186))(_ApplyTagChanges__bn, _ApplyTagChanges_list, _ApplyTagChanges_changeList); \
});})

#define SMult64(arg1, arg2) ({ \
  LONG _SMult64_arg1 = (arg1); \
  LONG _SMult64_arg2 = (arg2); \
  ({ \
  register char * _SMult64__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), LONG __asm("d0"), LONG __asm("d1"))) \
  (_SMult64__bn - 198))(_SMult64__bn, _SMult64_arg1, _SMult64_arg2); \
});})

#define UMult64(arg1, arg2) ({ \
  ULONG _UMult64_arg1 = (arg1); \
  ULONG _UMult64_arg2 = (arg2); \
  ({ \
  register char * _UMult64__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), ULONG __asm("d0"), ULONG __asm("d1"))) \
  (_UMult64__bn - 204))(_UMult64__bn, _UMult64_arg1, _UMult64_arg2); \
});})

#define PackStructureTags(pack, packTable, tagList) ({ \
  APTR _PackStructureTags_pack = (pack); \
  CONST ULONG * _PackStructureTags_packTable = (packTable); \
  CONST struct TagItem * _PackStructureTags_tagList = (tagList); \
  ({ \
  register char * _PackStructureTags__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), APTR __asm("a0"), CONST ULONG * __asm("a1"), CONST struct TagItem * __asm("a2"))) \
  (_PackStructureTags__bn - 210))(_PackStructureTags__bn, _PackStructureTags_pack, _PackStructureTags_packTable, _PackStructureTags_tagList); \
});})

#define UnpackStructureTags(pack, packTable, tagList) ({ \
  CONST_APTR _UnpackStructureTags_pack = (pack); \
  CONST ULONG * _UnpackStructureTags_packTable = (packTable); \
  struct TagItem * _UnpackStructureTags_tagList = (tagList); \
  ({ \
  register char * _UnpackStructureTags__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), CONST_APTR __asm("a0"), CONST ULONG * __asm("a1"), struct TagItem * __asm("a2"))) \
  (_UnpackStructureTags__bn - 216))(_UnpackStructureTags__bn, _UnpackStructureTags_pack, _UnpackStructureTags_packTable, _UnpackStructureTags_tagList); \
});})

#define AddNamedObject(nameSpace, object) ({ \
  struct NamedObject * _AddNamedObject_nameSpace = (nameSpace); \
  struct NamedObject * _AddNamedObject_object = (object); \
  ({ \
  register char * _AddNamedObject__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((BOOL (*)(char * __asm("a6"), struct NamedObject * __asm("a0"), struct NamedObject * __asm("a1"))) \
  (_AddNamedObject__bn - 222))(_AddNamedObject__bn, _AddNamedObject_nameSpace, _AddNamedObject_object); \
});})

#define AllocNamedObjectA(name, tagList) ({ \
  CONST_STRPTR _AllocNamedObjectA_name = (name); \
  CONST struct TagItem * _AllocNamedObjectA_tagList = (tagList); \
  ({ \
  register char * _AllocNamedObjectA__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((struct NamedObject * (*)(char * __asm("a6"), CONST_STRPTR __asm("a0"), CONST struct TagItem * __asm("a1"))) \
  (_AllocNamedObjectA__bn - 228))(_AllocNamedObjectA__bn, _AllocNamedObjectA_name, _AllocNamedObjectA_tagList); \
});})

#ifndef NO_INLINE_STDARG
static __inline__ struct NamedObject * ___AllocNamedObject(struct Library * UtilityBase, CONST_STRPTR name, ...)
{
  return AllocNamedObjectA(name, (CONST struct TagItem *) ((ULONG) &name + sizeof(CONST_STRPTR)));
}

#define AllocNamedObject(name...) ___AllocNamedObject(UTILITY_BASE_NAME, name)
#endif

#define AttemptRemNamedObject(object) ({ \
  struct NamedObject * _AttemptRemNamedObject_object = (object); \
  ({ \
  register char * _AttemptRemNamedObject__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), struct NamedObject * __asm("a0"))) \
  (_AttemptRemNamedObject__bn - 234))(_AttemptRemNamedObject__bn, _AttemptRemNamedObject_object); \
});})

#define FindNamedObject(nameSpace, name, lastObject) ({ \
  struct NamedObject * _FindNamedObject_nameSpace = (nameSpace); \
  CONST_STRPTR _FindNamedObject_name = (name); \
  CONST struct NamedObject * _FindNamedObject_lastObject = (lastObject); \
  ({ \
  register char * _FindNamedObject__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((struct NamedObject * (*)(char * __asm("a6"), struct NamedObject * __asm("a0"), CONST_STRPTR __asm("a1"), CONST struct NamedObject * __asm("a2"))) \
  (_FindNamedObject__bn - 240))(_FindNamedObject__bn, _FindNamedObject_nameSpace, _FindNamedObject_name, _FindNamedObject_lastObject); \
});})

#define FreeNamedObject(object) ({ \
  struct NamedObject * _FreeNamedObject_object = (object); \
  ({ \
  register char * _FreeNamedObject__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct NamedObject * __asm("a0"))) \
  (_FreeNamedObject__bn - 246))(_FreeNamedObject__bn, _FreeNamedObject_object); \
});})

#define NamedObjectName(object) ({ \
  struct NamedObject * _NamedObjectName_object = (object); \
  ({ \
  register char * _NamedObjectName__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((STRPTR (*)(char * __asm("a6"), struct NamedObject * __asm("a0"))) \
  (_NamedObjectName__bn - 252))(_NamedObjectName__bn, _NamedObjectName_object); \
});})

#define ReleaseNamedObject(object) ({ \
  struct NamedObject * _ReleaseNamedObject_object = (object); \
  ({ \
  register char * _ReleaseNamedObject__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct NamedObject * __asm("a0"))) \
  (_ReleaseNamedObject__bn - 258))(_ReleaseNamedObject__bn, _ReleaseNamedObject_object); \
});})

#define RemNamedObject(object, message) ({ \
  struct NamedObject * _RemNamedObject_object = (object); \
  struct Message * _RemNamedObject_message = (message); \
  ({ \
  register char * _RemNamedObject__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct NamedObject * __asm("a0"), struct Message * __asm("a1"))) \
  (_RemNamedObject__bn - 264))(_RemNamedObject__bn, _RemNamedObject_object, _RemNamedObject_message); \
});})

#define GetUniqueID() ({ \
  register char * _GetUniqueID__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"))) \
  (_GetUniqueID__bn - 270))(_GetUniqueID__bn); \
})

#define VSNPrintf(buffer, bufsize, fmt, data) ({ \
  STRPTR _VSNPrintf_buffer = (buffer); \
  ULONG _VSNPrintf_bufsize = (bufsize); \
  CONST_STRPTR _VSNPrintf_fmt = (fmt); \
  CONST_APTR _VSNPrintf_data = (data); \
  ({ \
  register char * _VSNPrintf__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), STRPTR __asm("a0"), ULONG __asm("d0"), CONST_STRPTR __asm("a1"), CONST_APTR __asm("a2"))) \
  (_VSNPrintf__bn - 312))(_VSNPrintf__bn, _VSNPrintf_buffer, _VSNPrintf_bufsize, _VSNPrintf_fmt, _VSNPrintf_data); \
});})

#ifndef NO_INLINE_STDARG
static __inline__ LONG ___SNPrintf(struct Library * UtilityBase, STRPTR buffer, ULONG bufsize, CONST_STRPTR fmt, ...)
{
  return VSNPrintf(buffer, bufsize, fmt, (CONST_APTR) ((ULONG) &fmt + sizeof(CONST_STRPTR)));
}

#define SNPrintf(buffer, bufsize, fmt...) ___SNPrintf(UTILITY_BASE_NAME, buffer, bufsize, fmt)
#endif

#define Strncpy(dst, src, size) ({ \
  STRPTR _Strncpy_dst = (dst); \
  CONST_STRPTR _Strncpy_src = (src); \
  ULONG _Strncpy_size = (size); \
  ({ \
  register char * _Strncpy__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((STRPTR (*)(char * __asm("a6"), STRPTR __asm("a1"), CONST_STRPTR __asm("a0"), ULONG __asm("d0"))) \
  (_Strncpy__bn - 438))(_Strncpy__bn, _Strncpy_dst, _Strncpy_src, _Strncpy_size); \
});})

#define Strncat(dst, src, size) ({ \
  STRPTR _Strncat_dst = (dst); \
  CONST_STRPTR _Strncat_src = (src); \
  ULONG _Strncat_size = (size); \
  ({ \
  register char * _Strncat__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((STRPTR (*)(char * __asm("a6"), STRPTR __asm("a1"), CONST_STRPTR __asm("a0"), ULONG __asm("d0"))) \
  (_Strncat__bn - 444))(_Strncat__bn, _Strncat_dst, _Strncat_src, _Strncat_size); \
});})

#define SDivMod64(hi, lo, divisor) ({ \
  LONG _SDivMod64_hi = (hi); \
  LONG _SDivMod64_lo = (lo); \
  LONG _SDivMod64_divisor = (divisor); \
  ({ \
  register char * _SDivMod64__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), LONG __asm("d1"), LONG __asm("d0"), LONG __asm("d2"))) \
  (_SDivMod64__bn - 450))(_SDivMod64__bn, _SDivMod64_hi, _SDivMod64_lo, _SDivMod64_divisor); \
});})

#define UDivMod64(hi, lo, divisor) ({ \
  ULONG _UDivMod64_hi = (hi); \
  ULONG _UDivMod64_lo = (lo); \
  ULONG _UDivMod64_divisor = (divisor); \
  ({ \
  register char * _UDivMod64__bn __asm("a6") = (char *) (UTILITY_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), ULONG __asm("d1"), ULONG __asm("d0"), ULONG __asm("d2"))) \
  (_UDivMod64__bn - 456))(_UDivMod64__bn, _UDivMod64_hi, _UDivMod64_lo, _UDivMod64_divisor); \
});})

#endif /*  _INLINE_UTILITY_H  */
