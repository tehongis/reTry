#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

#define CIAAPRA 0xBFE001
struct CIA *cia = (struct CIA *) CIAAPRA;
#define LEFT_BUTTON   1

struct GfxBase *GfxBase;
struct View *oldView;

static UWORD __chip copperlist[] = {
    COP_WAIT(0x0000, 0xfffe),
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


static void wait_vblank() {
    while ( custom.vhposr != (UBYTE)( 200 + 1 ) ) { };
}


BOOL check_mouse(void) {
    BOOL button = ( cia->ciapra & 0x0040 ) ? LEFT_BUTTON : 0;
    return button;
}

static void init_display(void)
{
    LoadView(NULL);  // clear display, reset hardware registers
    WaitTOF();       // 2 WaitTOFs to wait for 1. long frame and
    WaitTOF();       // 2. short frame copper lists to finish (if interlaced)
}

static void reset_display(void)
{
    LoadView(((struct GfxBase *) GfxBase)->ActiView);
    WaitTOF();
    WaitTOF();
    custom.cop1lc = (ULONG) ((struct GfxBase *) GfxBase)->copinit;
}


int main() {

	//SysBase = *((struct ExecBase**)4UL);

    static UWORD __chip bitplane[BPLANE_SIZE];

    //UWORD *bitplane = AllocMem( BPLANE_SIZE, CHIP_MEM_ATTR );
    // | MEM_CLEAR
    ULONG bplane_addr = (ULONG) &bitplane;
//    printf("bitplane address: %08x\n", bplane_addr);
    UWORD hi = ((ULONG) bplane_addr >> 16) & 0xffff;
    UWORD lo = (ULONG) bplane_addr & 0xffff;
    copperlist[13] = lo;
    copperlist[16] = hi;
//    printf("low: %04x\n", lo);
//    printf("high: %04x\n", hi);

    //exit(0);
    
/*
    UWORD *copper_mem = AllocMem( sizeof(copperlist), CHIP_MEM_ATTR );
    for (int i = 0; i < sizeof(copperlist);i++) {
        copper_mem[i] = copperlist[i];
    }
*/    
    //memcpy(copper_mem,copperlist,sizeof(copperlist));

    GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 0);
    if (GfxBase == NULL) exit(1);
    oldView = GfxBase->ActiView;


    // Backup original values
    ULONG systemADKCON = custom.adkconr;
    ULONG systemINTENA = custom.intenar;
    ULONG systemDMACON = custom.dmaconr;


//    custom = (struct custom *) 0xdff000;

    struct Task *current_task = FindTask(NULL);
    BYTE old_prio = SetTaskPri(current_task, TASK_PRIORITY);


//    init_display();

/*
    OwnBlitter();
    WaitBlit();
    Forbid();
    Disable();
*/

    // Stop all dma
    // custom.dmacon = DMAF_ALL;
    // enable bitplane and copper,blitter and blithog
    // custom.dmacon = DMAF_SETCLR|DMAF_BLITHOG|DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_SPRITE;

    // no sprite DMA
    custom.dmacon  = 0x0020;

    custom.cop1lc = (ULONG) copperlist;

    BOOL running = TRUE;
    while(running) {
        wait_vblank();
        if (check_mouse()) {
            running = FALSE;
        };
    }

/*
    Enable();
    Permit();
    DisownBlitter();
*/

    //reset_display();

    //FreeMem(bitplane,BPLANE_SIZE);

    return 0;
}
