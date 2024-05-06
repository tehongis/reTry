

#include <stdio.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>

extern int *mt_init;
extern int *mt_music;
extern int *mt_end;
extern int *mt_data;

//struct DosLibrary *DOSBase;


    void (*mtInit)(int) = &mt_init;
    void (*mtMusic)(int) = &mt_music;
    void (*mtEnd)(int) = &mt_end;
  
int main()
{

/*

    if(DOSBase=(struct DosLibrary *)OpenLibrary("dos.library",0)){
        Write(Output(),"Hello, world!\n",14);
        CloseLibrary((struct Library *)DOSBase);
    }

*/

//    printf("%lu\n",&mt_init);
//    printf("%lu\n",&mt_data);

    mtInit();

    for (int i = 0; i < 512; i++) {
        mtMusic();
        WaitTOF();
    }
    
    mtEnd();


//    LoadView
//    WaitTOF
//    WaitTOF
//    Forbid


//    LoadView
//    WaitTOF
//    WaitTOF
//    Permit

    return 0;
}