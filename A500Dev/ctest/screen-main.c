#include <proto/intuition.h>
#include <proto/dos.h>
#include <intuition/screens.h>
int main(void) {
    struct NewScreen Screen1 = {
     0,0,640,480,8,             /* Screen of 640 x 480 of depth 8 (2^8 = 256 colours)    */
     DETAILPEN, BLOCKPEN,
     HIRES,                     /* see graphics/view.h for view modes */
     PUBLICSCREEN,              /* Screen types */
     NULL,                      /* Text attributes (use defaults) */
     "My New Screen", 
     NULL,
     NULL
     };
     struct Screen *myScreen;
     myScreen = OpenScreen(&Screen1);  /* & (ampersand) means address of */
     Delay(500);
     if (myScreen) CloseScreen(myScreen); /* Close screen using myScreen pointer */
	  return(0);
   } 