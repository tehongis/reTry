#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>

#include <intuition/intuition.h>

struct DosLibrary *DOSBase;
struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;

int main()
{

  DOSBase = (struct DosLibrary *)OpenLibrary("dos.library", 0);
  IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 0);
  GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0);

  if (!DOSBase | !IntuitionBase | !GfxBase)
  {
    return (20);
  }

  struct Window *myWindow;
  struct IntuiMessage *msg; /* Structure to store Intuition message data */
  struct TextFont *oldfont;
  struct RastPort *myRastport;

  int closewin = FALSE; /* Flag used to end program */
  ULONG msgClass;       /* Class value */

  struct NewWindow winlayout = {
      20, 20,
      512, 128,
      0, 1,
      CLOSEWINDOW | REFRESHWINDOW,
      WINDOWDRAG | WINDOWCLOSE | WINDOWDEPTH | ACTIVATE | SMART_REFRESH,
      NULL, NULL,
      "My Window",
      NULL, NULL,
      0, 0,
      0, 0,
      WBENCHSCREEN};

  myWindow = OpenWindow(&winlayout);
  myRastport = myWindow->RPort;
  oldfont = myRastport->Font;

  long x = 10;
  long y = 20;

  Move((struct RastPort *)myRastport, x, y);
  // ClearEOL( (struct RastPort *)myRastport )
  // ClearScreen( (struct RastPort *)myRastport )
  char rivi[] = "Testing.";
  Text((struct RastPort *)myRastport, rivi, sizeof(rivi)-1);

  while (closewin == FALSE)
  {
    Wait(1L << myWindow->UserPort->mp_SigBit);
    msg = (struct IntuiMessage *)GetMsg(myWindow->UserPort);
    msgClass = msg->Class;
    ReplyMsg((struct Message *)msg);
    if (msgClass == CLOSEWINDOW) {
      CloseWindow(myWindow);
      closewin = TRUE;
    }
    if (msgClass == REFRESHWINDOW) {
      RefreshWindowFrame(myWindow);
    }

/*
    ScrollRaster(myRastport, 0, 1,
                  myWindow->BorderLeft,
                  myWindow->BorderTop,
                  myWindow->BorderLeft+512-1,
                  myWindow->BorderTop+128-1 );
*/
//  BeginRefresh(myWindow);
//  EndRefresh(myWindow,TRUE);

  WaitTOF();
}
    //RefreshView(TRUE);

  CloseLibrary((struct Library *)GfxBase);
  CloseLibrary((struct Library *)IntuitionBase);
  CloseLibrary((struct Library *)DOSBase);

  return (0);
}
