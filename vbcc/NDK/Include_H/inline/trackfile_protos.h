#ifndef _VBCCINLINE_TRACKFILE_H
#define _VBCCINLINE_TRACKFILE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

LONG __TFStartUnitTagList(__reg("a6") void *, __reg("d0") LONG which_unit, __reg("a0") CONST struct TagItem * tags)="\tjsr\t-42(a6)";
#define TFStartUnitTagList(which_unit, tags) __TFStartUnitTagList(TrackFileBase, (which_unit), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __TFStartUnitTags(__reg("a6") void *, __reg("d0") LONG which_unit, ...)="\tmove.l\ta0,-(a7)\n\tlea\t4(a7),a0\n\tjsr\t-42(a6)\n\tmovea.l\t(a7)+,a0";
#define TFStartUnitTags(...) __TFStartUnitTags(TrackFileBase, __VA_ARGS__)
#endif

LONG __TFStopUnitTagList(__reg("a6") void *, __reg("d0") LONG which_unit, __reg("a0") CONST struct TagItem * tags)="\tjsr\t-48(a6)";
#define TFStopUnitTagList(which_unit, tags) __TFStopUnitTagList(TrackFileBase, (which_unit), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __TFStopUnitTags(__reg("a6") void *, __reg("d0") LONG which_unit, ...)="\tmove.l\ta0,-(a7)\n\tlea\t4(a7),a0\n\tjsr\t-48(a6)\n\tmovea.l\t(a7)+,a0";
#define TFStopUnitTags(...) __TFStopUnitTags(TrackFileBase, __VA_ARGS__)
#endif

LONG __TFInsertMediaTagList(__reg("a6") void *, __reg("d0") LONG which_unit, __reg("a0") CONST struct TagItem * tags)="\tjsr\t-54(a6)";
#define TFInsertMediaTagList(which_unit, tags) __TFInsertMediaTagList(TrackFileBase, (which_unit), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __TFInsertMediaTags(__reg("a6") void *, __reg("d0") LONG which_unit, ...)="\tmove.l\ta0,-(a7)\n\tlea\t4(a7),a0\n\tjsr\t-54(a6)\n\tmovea.l\t(a7)+,a0";
#define TFInsertMediaTags(...) __TFInsertMediaTags(TrackFileBase, __VA_ARGS__)
#endif

LONG __TFEjectMediaTagList(__reg("a6") void *, __reg("d0") LONG which_unit, __reg("a0") CONST struct TagItem * tags)="\tjsr\t-60(a6)";
#define TFEjectMediaTagList(which_unit, tags) __TFEjectMediaTagList(TrackFileBase, (which_unit), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __TFEjectMediaTags(__reg("a6") void *, __reg("d0") LONG which_unit, ...)="\tmove.l\ta0,-(a7)\n\tlea\t4(a7),a0\n\tjsr\t-60(a6)\n\tmovea.l\t(a7)+,a0";
#define TFEjectMediaTags(...) __TFEjectMediaTags(TrackFileBase, __VA_ARGS__)
#endif

struct TrackFileUnitData * __TFGetUnitData(__reg("a6") void *, __reg("d0") LONG which_unit)="\tjsr\t-66(a6)";
#define TFGetUnitData(which_unit) __TFGetUnitData(TrackFileBase, (which_unit))

VOID __TFFreeUnitData(__reg("a6") void *, __reg("a0") struct TrackFileUnitData * tfud)="\tjsr\t-72(a6)";
#define TFFreeUnitData(tfud) __TFFreeUnitData(TrackFileBase, (tfud))

LONG __TFChangeUnitTagList(__reg("a6") void *, __reg("d0") LONG which_unit, __reg("a0") CONST struct TagItem * tags)="\tjsr\t-78(a6)";
#define TFChangeUnitTagList(which_unit, tags) __TFChangeUnitTagList(TrackFileBase, (which_unit), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __TFChangeUnitTags(__reg("a6") void *, __reg("d0") LONG which_unit, ...)="\tmove.l\ta0,-(a7)\n\tlea\t4(a7),a0\n\tjsr\t-78(a6)\n\tmovea.l\t(a7)+,a0";
#define TFChangeUnitTags(...) __TFChangeUnitTags(TrackFileBase, __VA_ARGS__)
#endif

LONG __TFExamineFileSize(__reg("a6") void *, __reg("d0") LONG file_size)="\tjsr\t-84(a6)";
#define TFExamineFileSize(file_size) __TFExamineFileSize(TrackFileBase, (file_size))

#endif /*  _VBCCINLINE_TRACKFILE_H  */
