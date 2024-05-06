

#include <stdio.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>

extern int *mt_init;
extern int *mt_music;
extern int *mt_end;
extern int *mt_data;

//struct DosLibrary *DOSBase;
struct GraphicsLibrary *GfxBase;

    void (*mtInit)(int) = &mt_init;
    void (*mtMusic)(int) = &mt_music;
    void (*mtEnd)(int) = &mt_end;
  
int main()
{


    DOSBase=(struct DosLibrary *)OpenLibrary("dos.library",0);
    if (!DOSBase) {
        exit(-5);
    }


    GfxBase=(struct GraphicsLibrary *)OpenLibrary("graphics.library",0);
    if (!GfxBase) {
        exit(-5);
    }


//    Write(Output(),"Hello, world!\n",14);

//    printf("%lu\n",&mt_init);
//    printf("%lu\n",&mt_data);

    Write(Output(),"Hello, world!\n",14);

    Disable();

    mtInit();

    for (int i = 0; i < 64; i++) {
        WaitTOF();
        mtMusic();
    }
    
    mtEnd();

    Enable();


//    LoadView
//    WaitTOF
//    WaitTOF
//    Forbid


//    LoadView
//    WaitTOF
//    WaitTOF
//    Permit

    if (GfxBase) {
        CloseLibrary((struct Library *)GfxBase);
    }

    if (DOSBase) {
        CloseLibrary((struct Library *)DOSBase);
    }


    return 0;
}