#ifndef _INLINE_MATHIEEESINGBAS_H
#define _INLINE_MATHIEEESINGBAS_H

#ifndef CLIB_MATHIEEESINGBAS_PROTOS_H
#define CLIB_MATHIEEESINGBAS_PROTOS_H
#endif

#ifndef  LIBRARIES_MATHLIBRARY_H
#include <libraries/mathlibrary.h>
#endif

#ifndef MATHIEEESINGBAS_BASE_NAME
#define MATHIEEESINGBAS_BASE_NAME MathIeeeSingBasBase
#endif

#define IEEESPFix(parm) ({ \
  FLOAT _IEEESPFix_parm = (parm); \
  ({ \
  register char * _IEEESPFix__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), FLOAT __asm("d0"))) \
  (_IEEESPFix__bn - 30))(_IEEESPFix__bn, _IEEESPFix_parm); \
});})

#define IEEESPFlt(integer) ({ \
  LONG _IEEESPFlt_integer = (integer); \
  ({ \
  register char * _IEEESPFlt__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), LONG __asm("d0"))) \
  (_IEEESPFlt__bn - 36))(_IEEESPFlt__bn, _IEEESPFlt_integer); \
});})

#define IEEESPCmp(leftParm, rightParm) ({ \
  FLOAT _IEEESPCmp_leftParm = (leftParm); \
  FLOAT _IEEESPCmp_rightParm = (rightParm); \
  ({ \
  register char * _IEEESPCmp__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), FLOAT __asm("d0"), FLOAT __asm("d1"))) \
  (_IEEESPCmp__bn - 42))(_IEEESPCmp__bn, _IEEESPCmp_leftParm, _IEEESPCmp_rightParm); \
});})

#define IEEESPTst(parm) ({ \
  FLOAT _IEEESPTst_parm = (parm); \
  ({ \
  register char * _IEEESPTst__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((LONG (*)(char * __asm("a6"), FLOAT __asm("d0"))) \
  (_IEEESPTst__bn - 48))(_IEEESPTst__bn, _IEEESPTst_parm); \
});})

#define IEEESPAbs(parm) ({ \
  FLOAT _IEEESPAbs_parm = (parm); \
  ({ \
  register char * _IEEESPAbs__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), FLOAT __asm("d0"))) \
  (_IEEESPAbs__bn - 54))(_IEEESPAbs__bn, _IEEESPAbs_parm); \
});})

#define IEEESPNeg(parm) ({ \
  FLOAT _IEEESPNeg_parm = (parm); \
  ({ \
  register char * _IEEESPNeg__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), FLOAT __asm("d0"))) \
  (_IEEESPNeg__bn - 60))(_IEEESPNeg__bn, _IEEESPNeg_parm); \
});})

#define IEEESPAdd(leftParm, rightParm) ({ \
  FLOAT _IEEESPAdd_leftParm = (leftParm); \
  FLOAT _IEEESPAdd_rightParm = (rightParm); \
  ({ \
  register char * _IEEESPAdd__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), FLOAT __asm("d0"), FLOAT __asm("d1"))) \
  (_IEEESPAdd__bn - 66))(_IEEESPAdd__bn, _IEEESPAdd_leftParm, _IEEESPAdd_rightParm); \
});})

#define IEEESPSub(leftParm, rightParm) ({ \
  FLOAT _IEEESPSub_leftParm = (leftParm); \
  FLOAT _IEEESPSub_rightParm = (rightParm); \
  ({ \
  register char * _IEEESPSub__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), FLOAT __asm("d0"), FLOAT __asm("d1"))) \
  (_IEEESPSub__bn - 72))(_IEEESPSub__bn, _IEEESPSub_leftParm, _IEEESPSub_rightParm); \
});})

#define IEEESPMul(leftParm, rightParm) ({ \
  FLOAT _IEEESPMul_leftParm = (leftParm); \
  FLOAT _IEEESPMul_rightParm = (rightParm); \
  ({ \
  register char * _IEEESPMul__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), FLOAT __asm("d0"), FLOAT __asm("d1"))) \
  (_IEEESPMul__bn - 78))(_IEEESPMul__bn, _IEEESPMul_leftParm, _IEEESPMul_rightParm); \
});})

#define IEEESPDiv(dividend, divisor) ({ \
  FLOAT _IEEESPDiv_dividend = (dividend); \
  FLOAT _IEEESPDiv_divisor = (divisor); \
  ({ \
  register char * _IEEESPDiv__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), FLOAT __asm("d0"), FLOAT __asm("d1"))) \
  (_IEEESPDiv__bn - 84))(_IEEESPDiv__bn, _IEEESPDiv_dividend, _IEEESPDiv_divisor); \
});})

#define IEEESPFloor(parm) ({ \
  FLOAT _IEEESPFloor_parm = (parm); \
  ({ \
  register char * _IEEESPFloor__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), FLOAT __asm("d0"))) \
  (_IEEESPFloor__bn - 90))(_IEEESPFloor__bn, _IEEESPFloor_parm); \
});})

#define IEEESPCeil(parm) ({ \
  FLOAT _IEEESPCeil_parm = (parm); \
  ({ \
  register char * _IEEESPCeil__bn __asm("a6") = (char *) (MATHIEEESINGBAS_BASE_NAME);\
  ((FLOAT (*)(char * __asm("a6"), FLOAT __asm("d0"))) \
  (_IEEESPCeil__bn - 96))(_IEEESPCeil__bn, _IEEESPCeil_parm); \
});})

#endif /*  _INLINE_MATHIEEESINGBAS_H  */
