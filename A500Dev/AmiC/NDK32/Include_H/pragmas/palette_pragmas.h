#ifndef PRAGMAS_PALETTE_PRAGMAS_H
#define PRAGMAS_PALETTE_PRAGMAS_H

/*
**	$VER: palette_pragmas.h 47.1 (30.11.2021)
**
**	Lattice 'C', Aztec 'C', SAS/C and DICE format pragma files.
*/

#ifndef CLIB_PALETTE_PROTOS_H
#include <clib/palette_protos.h>
#endif /* CLIB_PALETTE_PROTOS_H */

/* "palette.gadget" */
/*--- functions in V40 or higher (Release 3.1) ---*/
#pragma libcall PaletteBase PALETTE_GetClass 1e 00

#endif /* PRAGMAS_PALETTE_PRAGMAS_H */
