#include "rocket68.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <commctrl.h>
#include <window.h>

#define TOTAL_MEM_SIZE    (4 * 1024 * 1024) 
#define FB_WIDTH          320
#define FB_HEIGHT         256
#define FB_SIZE           (FB_WIDTH * FB_HEIGHT)

#define ADDR_AUDIO_BEEP   0x001FFFFC  
#define ADDR_KEYBOARD     0x001FFFFF  
#define ADDR_FB_START     0x00200000  
#define ADDR_PALETTE_START (ADDR_FB_START + FB_SIZE) 
#define ADDR_FONT_ROM     0x00220000  

#define ADDR_HDD_PAGE         0x001FFF00
#define ADDR_HDD_WINDOW       0x001F0000
#define HDD_TOTAL_SIZE        (10 * 1024 * 1024)
#define ADDR_HDD_CMD          0x001FFF08
#define ADDR_HDD_STATUS       0x001FFF09
#define ADDR_INT_CLEAR        0x001FFF0C

#define ADDR_HDD_DMA_ADDR 0x001FFF04  // UUSI: DMA-osoiterekisteri
#define RAM_SIZE          0x00080000  // RAM-muistin koko (sama kuin Stack Pointerin aloitus)

#define ID_RESET_BUTTON 1001
#define ID_STATUS_BAR   1002

u8* g_hdd_mem = NULL; // Globaali puskuri koko kiintolevyn sisällölle
u32 last_mapped_page = 0xFFFFFFFF; // Seuraa, milloin sivu muuttuu

HWND g_hwndStatus = NULL;
HWND g_hwndReset = NULL;
BOOL g_hdd_activity = FALSE;
int g_hdd_led_timer = 0;

FILE* g_hdd_file = NULL;

int hdd_busy_timer = 0;   // Simuloi kovalevyn lukupään mekaanista viivettä
u32 hdd_pending_lba = 0;
u32 hdd_pending_ram = 0;
u8 hdd_pending_cmd = 0;

HWND g_hwnd = NULL;
M68kCpu g_cpu;
BOOL running = false;

u8* g_mem = NULL;

RECT rPart;

void do_system_reset(void) {
    m68k_reset(&g_cpu);
}

void setup_window(HWND* hwnd, WNDCLASSEXA* wc) {
    *hwnd = CreateWindowExA(0, "Rocket68HardwareWin", "Rocket68", WS_OVERLAPPEDWINDOW | WS_VISIBLE, 
                             CW_USEDEFAULT, CW_USEDEFAULT, FB_WIDTH * 2, FB_HEIGHT * 2 + 30, NULL, NULL, GetModuleHandle(NULL), NULL);
    if (!*hwnd) {
        printf("[ERROR] Grafiikkaikkunan luominen epaonnistui!\n");
        exit(1);
    }
}

void register_window_class(WNDCLASSEXA* wc) {
    wc->cbSize = sizeof(WNDCLASSEXA);
    wc->style = CS_HREDRAW | CS_VREDRAW;
    wc->lpfnWndProc = WndProc;
    wc->hInstance = GetModuleHandle(NULL);
    wc->hCursor = LoadCursor(NULL, IDC_ARROW);
    wc->lpszClassName = "Rocket68HardwareWin";
    RegisterClassExA(wc);
}

void initialize_cpu_and_memory(M68kCpu* cpu, u8** mem, u32 size) {
    m68k_init(cpu, *mem, size);
    m68k_reset(cpu);
    *mem = calloc(size, 1);
    if (!*mem) {
        printf("[ERROR] Muistin varaus epäonnistui!\n");
        exit(1);
    }
}

void load_rom_files(const char* bios_path, const char* font_path, u8** mem) {
    FILE* f;

    f = fopen(bios_path, "rb");
    if (f) {
        fread(&mem[0x00000000], 1, 20480, f);
        fclose(f);
        printf("[LOAD] %s ladattu osoitteeseen 0x00000000.\n", bios_path);
    } else {
        printf("Kriittinen virhe: %s puuttuu!\n", bios_path);
        exit(1);
    }

    f = fopen(font_path, "rb");
    if (f) {
        fread(&mem[0x00220000], 1, 2048, f);
        fclose(f);
        printf("[LOAD] %s ladattu osoitteeseen 0x00220000.\n", font_path);
    } else {
        printf("Kriittinen virhe: %s puuttuu!\n", font_path);
        exit(1);
    }
}

void handle_window_messages(MSG* msg) {
    while (PeekMessage(msg, NULL, 0, 0, PM_REMOVE)) {
        if (msg->message == WM_QUIT) running = FALSE;
        TranslateMessage(msg);
        DispatchMessage(msg);
    }
}

void update_status_bar(HWND hwndStatus, u32 pc) {
    char statusText[64];
    sprintf(statusText, "  CPU PC: $%08X", pc);
    SendMessage(hwndStatus, SB_SETTEXTA, 1, (LPARAM)statusText);
}

void handle_hdd_io(void) {
    u8 hdd_cmd = g_mem[ADDR_HDD_CMD];
    if (hdd_cmd == 0) return;

    u32 current_page = (g_mem[ADDR_HDD_PAGE]     << 24) | 
                       (g_mem[ADDR_HDD_PAGE + 1] << 16) |
                       (g_mem[ADDR_HDD_PAGE + 2] << 8)  | 
                        g_mem[ADDR_HDD_PAGE + 3];

    u32 dma_addr = (g_mem[ADDR_HDD_DMA_ADDR]     << 24) | 
                   (g_mem[ADDR_HDD_DMA_ADDR + 1] << 16) |
                   (g_mem[ADDR_HDD_DMA_ADDR + 2] << 8)  | 
                    g_mem[ADDR_HDD_DMA_ADDR + 3];

    u32 hdd_offset = current_page * 512;

    if (g_hdd_file && (hdd_offset + 512 <= HDD_TOTAL_SIZE) && (dma_addr + 512 <= RAM_SIZE)) {
        fseek(g_hdd_file, hdd_offset, SEEK_SET);

        if (hdd_cmd == 1) {
            fread(&g_mem[dma_addr], 1, 512, g_hdd_file);
        } else if (hdd_cmd == 2) {
            fwrite(&g_mem[dma_addr], 1, 512, g_hdd_file);
            fflush(g_hdd_file);
        }
    }

    g_mem[ADDR_HDD_CMD] = 0; 
}

void main_loop(HWND hwnd, HWND hwndStatus) {
    MSG msg;
    running = TRUE;
    while (running) {
        handle_window_messages(&msg);

        m68k_execute(&g_cpu, 50000);
        u32 pc = m68k_get_pc(&g_cpu);
        update_status_bar(hwndStatus, pc);

        InvalidateRect(hwnd, NULL, FALSE);

        u8 hdd_cmd = g_mem[ADDR_HDD_CMD]; 
        if (hdd_cmd != 0) {
            handle_hdd_io();
            g_hdd_activity = TRUE;
        }

        if ((pc >= 0x000012CE && pc <= 0x000012D2)) {
            printf("\n==================================================================\n");
            printf("[EMU HALT] Jarjestelma suoritti hatajarrutuksen osoitteessa 0x%08X!\n", pc);
            printf("==================================================================\n");
            dump_cpu_crash_state();
            running = FALSE;
            break;
        }

        u8 int_clear_val = g_mem[ADDR_INT_CLEAR];
        if (int_clear_val != 0) {
            m68k_set_irq(&g_cpu, 0);
            g_mem[ADDR_INT_CLEAR] = 0;
            printf("[EMU INT-DEBUG] CPU kuittasi keskeytyksen INT 1 laitteistotasolla. Linja nollattu.\n");
        }

        int timer_counter = 0;
        if (timer_counter >= 10000) {
            m68k_set_irq(&g_cpu, 4);
            timer_counter = 0;
        }

        if (running == FALSE) {
            dump_mem();
            dump_cpu_crash_state();
        }

        Sleep(4);
    }
}

int main(void) {
    setvbuf(stdout, NULL, _IONBF, 0);
    char statusText[64];   

    WNDCLASSEXA wc;
    register_window_class(&wc);

    HWND hwnd = NULL;
    setup_window(&hwnd, &wc);

    g_mem = calloc(TOTAL_MEM_SIZE, 1);
    if (!g_mem) return 1;

    g_hdd_file = fopen("hdd.img", "rb+");
    if (!g_hdd_file) {
        printf("[KRIITTINEN VIRHE] hdd.img ei löydy!\n");
        return -1;
    }

    load_rom_files("os_bin\\bios.bin", "os_bin\\font.bin", &g_mem);

    initialize_cpu_and_memory(&g_cpu, &g_mem, TOTAL_MEM_SIZE);

    HWND hwndStatus = CreateWindowExA(0, STATUSCLASSNAMEA, NULL, 
                                       WS_CHILD | WS_VISIBLE, 
                                       0, 0, 0, 0, 
                                       hwnd, (HMENU)ID_STATUS_BAR, NULL, NULL);
    int parts[] = { 120, 320, -1 };
    SendMessage(hwndStatus, SB_SETPARTS, 3, (LPARAM)parts);

    RECT winRect = { 0, 0, FB_WIDTH * 2, (FB_HEIGHT * 2) + 30 };
    AdjustWindowRect(&winRect, WS_OVERLAPPEDWINDOW, FALSE);

    main_loop(hwnd, hwndStatus);

    free(g_mem);
    fclose(g_hdd_file);

    return 0;
}