#ifndef _INLINE_COMMODITIES_H
#define _INLINE_COMMODITIES_H

#ifndef CLIB_COMMODITIES_PROTOS_H
#define CLIB_COMMODITIES_PROTOS_H
#endif

#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#ifndef  EXEC_NODES_H
#include <exec/nodes.h>
#endif
#ifndef  LIBRARIES_COMMODITIES_H
#include <libraries/commodities.h>
#endif
#ifndef  DEVICES_INPUTEVENT_H
#include <devices/inputevent.h>
#endif
#ifndef  DEVICES_KEYMAP_H
#include <devices/keymap.h>
#endif

#ifndef COMMODITIES_BASE_NAME
#define COMMODITIES_BASE_NAME CxBase
#endif

#define CreateCxObj(type, arg1, arg2) ({ \
  ULONG _CreateCxObj_type = (type); \
  LONG _CreateCxObj_arg1 = (arg1); \
  LONG _CreateCxObj_arg2 = (arg2); \
  ({ \
  register char * _CreateCxObj__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((CxObj * (*)(char * __asm("a6"), ULONG __asm("d0"), LONG __asm("a0"), LONG __asm("a1"))) \
  (_CreateCxObj__bn - 30))(_CreateCxObj__bn, _CreateCxObj_type, _CreateCxObj_arg1, _CreateCxObj_arg2); \
});})

#define CxBroker(nb, error) ({ \
  CONST struct NewBroker * _CxBroker_nb = (nb); \
  LONG * _CxBroker_error = (error); \
  ({ \
  register char * _CxBroker__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((CxObj * (*)(char * __asm("a6"), CONST struct NewBroker * __asm("a0"), LONG * __asm("d0"))) \
  (_CxBroker__bn - 36))(_CxBroker__bn, _CxBroker_nb, _CxBroker_error); \
});})

#define ActivateCxObj(co, flag) ({ \
  CxObj * _ActivateCxObj_co = (co); \
  LONG _ActivateCxObj_flag = (flag); \
  ({ \
  register char * _ActivateCxObj__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), CxObj * __asm("a0"), LONG __asm("d0"))) \
  (_ActivateCxObj__bn - 42))(_ActivateCxObj__bn, _ActivateCxObj_co, _ActivateCxObj_flag); \
});})

#define DeleteCxObj(co) ({ \
  CxObj * _DeleteCxObj_co = (co); \
  ({ \
  register char * _DeleteCxObj__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"))) \
  (_DeleteCxObj__bn - 48))(_DeleteCxObj__bn, _DeleteCxObj_co); \
});})

#define DeleteCxObjAll(co) ({ \
  CxObj * _DeleteCxObjAll_co = (co); \
  ({ \
  register char * _DeleteCxObjAll__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"))) \
  (_DeleteCxObjAll__bn - 54))(_DeleteCxObjAll__bn, _DeleteCxObjAll_co); \
});})

#define CxObjType(co) ({ \
  CONST CxObj * _CxObjType_co = (co); \
  ({ \
  register char * _CxObjType__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), CONST CxObj * __asm("a0"))) \
  (_CxObjType__bn - 60))(_CxObjType__bn, _CxObjType_co); \
});})

#define CxObjError(co) ({ \
  CONST CxObj * _CxObjError_co = (co); \
  ({ \
  register char * _CxObjError__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), CONST CxObj * __asm("a0"))) \
  (_CxObjError__bn - 66))(_CxObjError__bn, _CxObjError_co); \
});})

#define ClearCxObjError(co) ({ \
  CxObj * _ClearCxObjError_co = (co); \
  ({ \
  register char * _ClearCxObjError__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"))) \
  (_ClearCxObjError__bn - 72))(_ClearCxObjError__bn, _ClearCxObjError_co); \
});})

#define SetCxObjPri(co, pri) ({ \
  CxObj * _SetCxObjPri_co = (co); \
  LONG _SetCxObjPri_pri = (pri); \
  ({ \
  register char * _SetCxObjPri__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), CxObj * __asm("a0"), LONG __asm("d0"))) \
  (_SetCxObjPri__bn - 78))(_SetCxObjPri__bn, _SetCxObjPri_co, _SetCxObjPri_pri); \
});})

#define AttachCxObj(headObj, co) ({ \
  CxObj * _AttachCxObj_headObj = (headObj); \
  CxObj * _AttachCxObj_co = (co); \
  ({ \
  register char * _AttachCxObj__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"), CxObj * __asm("a1"))) \
  (_AttachCxObj__bn - 84))(_AttachCxObj__bn, _AttachCxObj_headObj, _AttachCxObj_co); \
});})

#define EnqueueCxObj(headObj, co) ({ \
  CxObj * _EnqueueCxObj_headObj = (headObj); \
  CxObj * _EnqueueCxObj_co = (co); \
  ({ \
  register char * _EnqueueCxObj__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"), CxObj * __asm("a1"))) \
  (_EnqueueCxObj__bn - 90))(_EnqueueCxObj__bn, _EnqueueCxObj_headObj, _EnqueueCxObj_co); \
});})

#define InsertCxObj(headObj, co, pred) ({ \
  CxObj * _InsertCxObj_headObj = (headObj); \
  CxObj * _InsertCxObj_co = (co); \
  CxObj * _InsertCxObj_pred = (pred); \
  ({ \
  register char * _InsertCxObj__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"), CxObj * __asm("a1"), CxObj * __asm("a2"))) \
  (_InsertCxObj__bn - 96))(_InsertCxObj__bn, _InsertCxObj_headObj, _InsertCxObj_co, _InsertCxObj_pred); \
});})

#define RemoveCxObj(co) ({ \
  CxObj * _RemoveCxObj_co = (co); \
  ({ \
  register char * _RemoveCxObj__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"))) \
  (_RemoveCxObj__bn - 102))(_RemoveCxObj__bn, _RemoveCxObj_co); \
});})

#define SetTranslate(translator, events) ({ \
  CxObj * _SetTranslate_translator = (translator); \
  struct InputEvent * _SetTranslate_events = (events); \
  ({ \
  register char * _SetTranslate__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"), struct InputEvent * __asm("a1"))) \
  (_SetTranslate__bn - 114))(_SetTranslate__bn, _SetTranslate_translator, _SetTranslate_events); \
});})

#define SetFilter(filter, text) ({ \
  CxObj * _SetFilter_filter = (filter); \
  CONST_STRPTR _SetFilter_text = (text); \
  ({ \
  register char * _SetFilter__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"), CONST_STRPTR __asm("a1"))) \
  (_SetFilter__bn - 120))(_SetFilter__bn, _SetFilter_filter, _SetFilter_text); \
});})

#define SetFilterIX(filter, ix) ({ \
  CxObj * _SetFilterIX_filter = (filter); \
  CONST IX * _SetFilterIX_ix = (ix); \
  ({ \
  register char * _SetFilterIX__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxObj * __asm("a0"), CONST IX * __asm("a1"))) \
  (_SetFilterIX__bn - 126))(_SetFilterIX__bn, _SetFilterIX_filter, _SetFilterIX_ix); \
});})

#define ParseIX(description, ix) ({ \
  CONST_STRPTR _ParseIX_description = (description); \
  IX * _ParseIX_ix = (ix); \
  ({ \
  register char * _ParseIX__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), CONST_STRPTR __asm("a0"), IX * __asm("a1"))) \
  (_ParseIX__bn - 132))(_ParseIX__bn, _ParseIX_description, _ParseIX_ix); \
});})

#define CxMsgType(cxm) ({ \
  CONST CxMsg * _CxMsgType_cxm = (cxm); \
  ({ \
  register char * _CxMsgType__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((ULONG (*)(char * __asm("a6"), CONST CxMsg * __asm("a0"))) \
  (_CxMsgType__bn - 138))(_CxMsgType__bn, _CxMsgType_cxm); \
});})

#define CxMsgData(cxm) ({ \
  CONST CxMsg * _CxMsgData_cxm = (cxm); \
  ({ \
  register char * _CxMsgData__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((APTR (*)(char * __asm("a6"), CONST CxMsg * __asm("a0"))) \
  (_CxMsgData__bn - 144))(_CxMsgData__bn, _CxMsgData_cxm); \
});})

#define CxMsgID(cxm) ({ \
  CONST CxMsg * _CxMsgID_cxm = (cxm); \
  ({ \
  register char * _CxMsgID__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), CONST CxMsg * __asm("a0"))) \
  (_CxMsgID__bn - 150))(_CxMsgID__bn, _CxMsgID_cxm); \
});})

#define DivertCxMsg(cxm, headObj, returnObj) ({ \
  CxMsg * _DivertCxMsg_cxm = (cxm); \
  CxObj * _DivertCxMsg_headObj = (headObj); \
  CxObj * _DivertCxMsg_returnObj = (returnObj); \
  ({ \
  register char * _DivertCxMsg__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxMsg * __asm("a0"), CxObj * __asm("a1"), CxObj * __asm("a2"))) \
  (_DivertCxMsg__bn - 156))(_DivertCxMsg__bn, _DivertCxMsg_cxm, _DivertCxMsg_headObj, _DivertCxMsg_returnObj); \
});})

#define RouteCxMsg(cxm, co) ({ \
  CxMsg * _RouteCxMsg_cxm = (cxm); \
  CxObj * _RouteCxMsg_co = (co); \
  ({ \
  register char * _RouteCxMsg__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxMsg * __asm("a0"), CxObj * __asm("a1"))) \
  (_RouteCxMsg__bn - 162))(_RouteCxMsg__bn, _RouteCxMsg_cxm, _RouteCxMsg_co); \
});})

#define DisposeCxMsg(cxm) ({ \
  CxMsg * _DisposeCxMsg_cxm = (cxm); \
  ({ \
  register char * _DisposeCxMsg__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), CxMsg * __asm("a0"))) \
  (_DisposeCxMsg__bn - 168))(_DisposeCxMsg__bn, _DisposeCxMsg_cxm); \
});})

#define InvertKeyMap(ansiCode, event, km) ({ \
  ULONG _InvertKeyMap_ansiCode = (ansiCode); \
  struct InputEvent * _InvertKeyMap_event = (event); \
  CONST struct KeyMap * _InvertKeyMap_km = (km); \
  ({ \
  register char * _InvertKeyMap__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((BOOL (*)(char * __asm("a6"), ULONG __asm("d0"), struct InputEvent * __asm("a0"), CONST struct KeyMap * __asm("a1"))) \
  (_InvertKeyMap__bn - 174))(_InvertKeyMap__bn, _InvertKeyMap_ansiCode, _InvertKeyMap_event, _InvertKeyMap_km); \
});})

#define AddIEvents(events) ({ \
  struct InputEvent * _AddIEvents_events = (events); \
  ({ \
  register char * _AddIEvents__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((VOID (*)(char * __asm("a6"), struct InputEvent * __asm("a0"))) \
  (_AddIEvents__bn - 180))(_AddIEvents__bn, _AddIEvents_events); \
});})

#define MatchIX(event, ix) ({ \
  CONST struct InputEvent * _MatchIX_event = (event); \
  CONST IX * _MatchIX_ix = (ix); \
  ({ \
  register char * _MatchIX__bn __asm("a6") = (char *) (COMMODITIES_BASE_NAME);\
  ((BOOL (*)(char * __asm("a6"), CONST struct InputEvent * __asm("a0"), CONST IX * __asm("a1"))) \
  (_MatchIX__bn - 204))(_MatchIX__bn, _MatchIX_event, _MatchIX_ix); \
});})

#endif /*  _INLINE_COMMODITIES_H  */
