// window.c
#include <windows.h>
#include "window.h"

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;
        // Handle other messages
        default:
            return DefWindowProc(hwnd, msg, wParam, lParam);
    }
}