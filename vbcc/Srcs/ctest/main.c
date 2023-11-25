#include <stdio.h>
#include <stdlib.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>

#include <graphics/gfxbase.h>
#include <graphics/view.h>
#include <graphics/gfxmacros.h>

#include <exec/execbase.h>
#include <exec/types.h>
#include <exec/memory.h>

#include <hardware/custom.h>
#include <hardware/cia.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>

#include "ahpc_registers.h"


#define TASK_PRIORITY           127
#define PRA_FIR0_BIT            (1 << 6)

#define DISPLAY_WIDTH       320
#define DISPLAY_HEIGHT      256
#define DISPLAY_ROW_BYTES   DISPLAY_WIDTH / 8
#define BPLANE_SIZE         DISPLAY_ROW_BYTES * DISPLAY_HEIGHT 
#define CHIP_MEM_ATTR       MEMF_CHIP|MEMF_CLEAR

// copper instruction macros
#define COP_WAIT(location,mask) location,mask
#define COP_MOVE(addr, data) addr, data
#define COP_WAIT_END  0xffff, 0xfffe

//extern struct Custom custom;
struct Custom custom;
struct GfxBase *GfxBase;
struct View *oldView;

static UWORD __chip coplist[] = {
    COP_WAIT(0x0000,0xfffe),
    COP_MOVE(BPLCON0, 0x2200),
    COP_MOVE(DDFSTRT, 0x0038),
    COP_MOVE(DDFSTOP, 0x00d0),
    COP_MOVE(DIWSTRT, 0x2c81),
    COP_MOVE(DIWSTOP, 0x2cc1),
    COP_MOVE(BPL1PTH, 0),
    COP_MOVE(BPL1PTL, 0),
    COP_MOVE(BPL2PTH, 0),
    COP_MOVE(BPL2PTL, 0),
    COP_MOVE(BPL1MOD, DISPLAY_ROW_BYTES ),
    COP_MOVE(BPL2MOD, DISPLAY_ROW_BYTES ),
    COP_MOVE(COLOR00, 0xfff),
    COP_MOVE(COLOR01, 0x000),
    COP_MOVE(COLOR02, 0x222),
    COP_MOVE(COLOR03, 0x444),
    COP_MOVE(COLOR04, 0x666),
    COP_MOVE(COLOR05, 0x888),
    COP_MOVE(COLOR06, 0xaaa),
    COP_MOVE(COLOR07, 0xccc),


    COP_WAIT_END,
    COP_WAIT_END
};





void waitmouse(void) {
    volatile UBYTE *ciaa_pra = (volatile UBYTE *) 0xbfe001;
    while ((*ciaa_pra & PRA_FIR0_BIT) != 0) ;
}


int main() {

	//SysBase = *((struct ExecBase**)4UL);

    UWORD *imgdata = AllocMem( BPLANE_SIZE, CHIP_MEM_ATTR );
    //UWORD __chip 

    GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 0);
    if (GfxBase == NULL) exit(1);
    oldView = GfxBase->ActiView;


    ULONG systemADKCON = custom.adkconr;
    ULONG systemINTENA = custom.intenar;
    ULONG systemDMACON = custom.dmaconr;


//    custom = (struct custom *) 0xdff000;

    struct Task *current_task = FindTask(NULL);
    BYTE old_prio = SetTaskPri(current_task, TASK_PRIORITY);

    LoadView(NULL);  // clear display, reset hardware registers
    WaitTOF();       // 2 WaitTOFs to wait for 1. long frame and
    WaitTOF();       // 2. short frame copper lists to finish (if interlaced)
    BOOL palFlag = (((struct GfxBase *) GfxBase)->DisplayFlags & PAL) == PAL;

    OwnBlitter();
    WaitBlit();

    Disable();
    Forbid();

    // no sprite DMA
    custom.intena = 0x7FFF;
    custom.dmacon  = 0x0020;

    custom.cop1lc = (ULONG) coplist;


    waitmouse();


    Permit();
    Enable();
    DisownBlitter();

    LoadView(oldView);
    WaitTOF();
    WaitTOF();

    FreeMem(imgdata,BPLANE_SIZE);

    return 0;
}
