

// https://github.com/spec-chum/Amiga-Scoopex-C/blob/master/tut5/tut5.c
// https://codetapper.com/amiga/sprite-tricks/risky-woods/
// https://github.com/pararaum/amigaexamples/blob/master/examples/dual_playfield/dual.c

//#include <proto/exec.h>
//struct ExecBase *SysBase;

// Maybe compile with?
// 
// vasmm68k_mot -Fhunk -o=foo.o foo.s
// vlink -bamigahunk -o=foo foo.o vbcc:startup.o vbcc:libvc.a
//

#include <hardware/custom.h>
#include <hardware/cia.h>
#include <hardware/dmabits.h>

#include "support_includes/custom_defines.h"

#define CMOVE(addr, data) addr, data
#define CWAIT(vhpos, flags) vhpos, flags
#define CEND 0xffff, 0xfffe

__asm("SECTION image,DATA_C\n.incbin \"alleyrainnight-640x640x5-colors-after.raw\"");

short mul(short a, short b)
{
  register short result __asm("d0"); // declare a register variable
  result = a; // assign the first operand to the register
  asm("mulu (a7)+,d0\n"); // multiply the register by the second operand
  return result; // return the result
}

//.section "image_raw,data",chip,"ra"
//.global image_raw_start
//.incbin "alleyrainnight-640x640x5-colors-after.raw"
//.global image_raw_end

/* inline asm incbin
SECTION Image,DATA_C
.incbin "logo.raw"
extern unsigned char *Image __section("Image");
*/

/* Common structs */
extern struct ExecBase* SysBase;

volatile struct Custom *custom = (struct Custom *)CUSTOMBASE;
volatile struct CIA *ciaa = (struct CIA *)0xbfe001;

struct GfxBase *GfxBase;
struct copinit *oldCopinit;

//__far extern struct Custom custom;
//__far extern struct CIA ciaa, ciab;

// AllocMem(size,MEMF_CHIP);

void WaitRaster(ULONG raster)
{
	raster <<= 8;
	raster &= 0x1ff00;

	// not pretty, but creates pretty much same code as the asm source (MOVE.L)
	while(raster != ((*(volatile ULONG*)&custom->vposr) & 0x1ff00))
	{}
}

int main(int argc, char **argv) {

	static UWORD __chip copperlist[] = {

		CWAIT(0x0007,0xfffe),
		CMOVE(COLOR00,0x000a),
		CWAIT(0x2e07,0xfffe),
		CMOVE(COLOR00,0x0fff),
		CWAIT(0x2f07,0xfffe),
		CMOVE(COLOR00,0x0aaa),

		CMOVE(COLOR00,0x0aaa),
		CMOVE(COLOR01,0x0000),
		CMOVE(COLOR02,0x0f00),
		CMOVE(COLOR03,0x0006),

		CMOVE(BPL1PTH,0x000),
		CMOVE(BPL1PTL,0x000),
		CMOVE(BPL2PTH,0x002),
		CMOVE(BPL2PTL,0x000),

		CMOVE(BPLCON0,0x2200),

		CWAIT(0xff87,0xfffe),
		CWAIT(0x0007,0xfffe),
		CMOVE(COLOR00,0x0fff),
		CWAIT(0x0107,0xfffe),
		CMOVE(COLOR00,0x0aaa),
		CWAIT(0x0207,0xfffe),
		CMOVE(COLOR00,0x000a),
		CEND

	};


    //WORD *cust = (WORD *) 0xdff000;
	//struct Custom *custom = (struct Custom *) cust;

	// Save interrupts and DMA
	UWORD oldInt = custom->intenar;

	// disable all interrupts
	custom->intena = 0x7fff;
	
	//disable all dma
	custom->dmacon = 0x07fff;

	// enable raster and copper DMA

	custom->dmacon = DMAF_SETCLR | DMAF_COPPER | DMAF_RASTER | DMAF_MASTER;

	// initiate our copper
	custom->cop1lc = (ULONG)copperlist;
	custom->copjmp1=0;


	while(1) {
		WaitRaster(0x50);
		custom->color[1] = 0xfff;
		WaitRaster(0xa1);
		custom->color[1] = 0x000;
	}

 return 0;

}

