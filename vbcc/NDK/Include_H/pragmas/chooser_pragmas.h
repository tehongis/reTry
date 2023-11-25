#ifndef PRAGMAS_CHOOSER_PRAGMAS_H
#define PRAGMAS_CHOOSER_PRAGMAS_H

/*
**	$VER: chooser_pragmas.h 47.1 (30.11.2021)
**
**	Lattice 'C', Aztec 'C', SAS/C and DICE format pragma files.
*/

#ifndef CLIB_CHOOSER_PROTOS_H
#include <clib/chooser_protos.h>
#endif /* CLIB_CHOOSER_PROTOS_H */

/* "chooser.gadget" */
/*--- functions in V40 or higher (Release 3.1) ---*/
#pragma libcall ChooserBase CHOOSER_GetClass 1e 00
#pragma libcall ChooserBase AllocChooserNodeA 24 801
#if defined(__SASC_60)
#pragma tagcall ChooserBase AllocChooserNode 24 801
#endif /* __SASC_60 */
#pragma libcall ChooserBase FreeChooserNode 2a 801
#pragma libcall ChooserBase SetChooserNodeAttrsA 30 9802
#if defined(__SASC_60)
#pragma tagcall ChooserBase SetChooserNodeAttrs 30 9802
#endif /* __SASC_60 */
#pragma libcall ChooserBase GetChooserNodeAttrsA 36 9802
#if defined(__SASC_60)
#pragma tagcall ChooserBase GetChooserNodeAttrs 36 9802
#endif /* __SASC_60 */
#pragma libcall ChooserBase ShowChooser 3c 109804
#pragma libcall ChooserBase HideChooser 42 9802

#endif /* PRAGMAS_CHOOSER_PRAGMAS_H */
