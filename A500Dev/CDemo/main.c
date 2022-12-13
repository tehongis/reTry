
#include <proto/exec.h>
#include <exec/types.h>

#include <proto/intuition.h>
//#include <inline/intuition_protos.h>

#include <proto/graphics.h>
#include <graphics/gfxbase.h>


#include <hardware/custom.h>
#include <hardware/cia.h>
#include <hardware/blit.h>
#include <hardware/adkbits.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>

#define DIWSTRT_VALUE      0x2c81
#define DIWSTOP_VALUE_PAL  0x2cc1
#define DIWSTOP_VALUE_NTSC 0xf4c1

// Data fetch
#define DDFSTRT_VALUE      0x0038
#define DDFSTOP_VALUE      0x00d0

// Display dimensions and data size
#define DISPLAY_WIDTH    (320)
#define DISPLAY_HEIGHT   (256)
#define DISPLAY_ROW_BYTES (DISPLAY_WIDTH / 8)


extern struct CIA ciaa, ciab;
#define PRA_FIR0_BIT            (1 << 6)

extern struct Custom custom;
struct GfxBase *GfxBase;

static void wait_vblank()
{
    while ( custom.vposr  & 0x1ff00 != 20<<8 ) ;
}


int main()
{

  GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0);
  if (!GfxBase)
  {
    return (20);
  }

//  long OldCopper = GfxBase.StartList;

  SetTaskPri(FindTask(NULL),20);

  LoadView( NULL );
  WaitTOF();
  WaitTOF();

  Forbid();
  Disable();

  int i = 0;
  while( ( ciaa.ciapra & PRA_FIR0_BIT ) ? 1 : 0 )  {
    WaitTOF();
  
    custom.color[0] = (UBYTE) i;
    custom.color[1] = (UBYTE) 0xfff;
    i = i + 1;
    i = i & 0xfff;
  
  }


  LoadView(((struct GfxBase *) GfxBase)->ActiView);
  WaitTOF();
  WaitTOF();
  
  Enable();
  Permit();

  RethinkDisplay();

  CloseLibrary((struct Library *)GfxBase);
  return (0);
}
