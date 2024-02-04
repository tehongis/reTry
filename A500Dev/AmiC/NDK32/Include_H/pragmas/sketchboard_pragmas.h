#ifndef PRAGMAS_SKETCHBOARD_PRAGMAS_H
#define PRAGMAS_SKETCHBOARD_PRAGMAS_H

/*
**	$VER: sketchboard_pragmas.h 47.1 (30.11.2021)
**
**	Lattice 'C', Aztec 'C', SAS/C and DICE format pragma files.
*/

#ifndef CLIB_SKETCHBOARD_PROTOS_H
#include <clib/sketchboard_protos.h>
#endif /* CLIB_SKETCHBOARD_PROTOS_H */

/* "sketchboard.gadget" */
/*--- functions in V40 or higher (Release 3.1) ---*/
#pragma libcall SketchBoardBase SKETCHBOARD_GetClass 1e 00

#endif /* PRAGMAS_SKETCHBOARD_PRAGMAS_H */
