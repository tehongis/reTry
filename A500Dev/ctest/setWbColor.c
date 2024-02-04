#include <graphics.h>

int main()
{
    struct ColorMap *colorMap;
    colorMap = GetColorMap(0);

    LoadRGB4(colorMap, 0, 0, 0, 0);
    LoadRGB4(colorMap, 1, 15, 15, 15);
    LoadRGB4(colorMap, 2, 0, 0, 15);
    LoadRGB4(colorMap, 3, 15, 0, 0);
    LoadRGB4(colorMap, 4, 0, 15, 0);

    SetRGB4(colorMap, 0, 0, 0, 0);
    SetRGB4(colorMap, 1, 15, 15, 15);
    SetRGB4(colorMap, 2, 0, 0, 15);
    SetRGB4(colorMap, 3, 15, 0, 0);
    SetRGB4(colorMap, 4, 0, 15, 0);

    ULONG workbenchScreenAddress = (ULONG)GfxBase->ActiView->RastPort.BitMap;
    printf("The address of the Amiga Workbench screen is %lu\n", workbenchScreenAddress);

    struct ViewPort *viewPort;
    viewPort = &(((struct IntuitionBase *)IntuitionBase)->ActiveScreen->ViewPort);
    printf("The pointer to the ViewPort of the default screen is %p\n", viewPort);

    return 0;
}

