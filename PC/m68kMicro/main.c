// main.c
#include "rocket68.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>

#define TOTAL_MEM_SIZE    (4 * 1024 * 1024) 
#define FB_WIDTH          320
#define FB_HEIGHT         256
#define FB_SIZE           (FB_WIDTH * FB_HEIGHT)

#define ADDR_AUDIO_BEEP   0x001FFFFC  
#define ADDR_KEYBOARD     0x001FFFFF  
#define ADDR_FB_START     0x00200000  
#define ADDR_PALETTE_START (ADDR_FB_START + FB_SIZE) 
#define ADDR_FONT_ROM     0x00220000  

#define ADDR_HDD_PAGE      0x001FFF00
#define ADDR_HDD_WINDOW    0x001F0000 
#define HDD_TOTAL_SIZE     (10 * 1024 * 1024) 
#define ADDR_HDD_CMD       0x001FFF08 // Lisätty puuttuva määrittely [0x1.1]
#define ADDR_HDD_STATUS    0x001FFF09
#define ADDR_INT_CLEAR     0x001FFF0C

u8* g_hdd_mem = NULL; // Globaali puskuri koko kiintolevyn sisällölle
u32 last_mapped_page = 0xFFFFFFFF; // Seuraa, milloin sivu muuttuu

#define ADDR_INT_CLEAR    0x001FFF0C

FILE* g_hdd_file = NULL;

int hdd_busy_timer = 0;   // Simuloi kovalevyn lukupään mekaanista viivettä
u32 hdd_pending_lba = 0;
u32 hdd_pending_ram = 0;
u8 hdd_pending_cmd = 0;


u8* g_mem = NULL;
HWND g_hwnd = NULL;
M68kCpu g_cpu;
BOOL running = false;

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            u8 bmi_buffer[sizeof(BITMAPINFOHEADER) + 256 * sizeof(RGBQUAD)];
            memset(bmi_buffer, 0, sizeof(bmi_buffer));

            BITMAPINFO* pbmi = (BITMAPINFO*)bmi_buffer;
            pbmi->bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
            pbmi->bmiHeader.biWidth = FB_WIDTH;
            pbmi->bmiHeader.biHeight = -FB_HEIGHT; 
            pbmi->bmiHeader.biPlanes = 1;
            pbmi->bmiHeader.biBitCount = 8; 
            pbmi->bmiHeader.biCompression = BI_RGB;
            pbmi->bmiHeader.biClrUsed = 256;

            memcpy(pbmi->bmiColors, &g_mem[ADDR_PALETTE_START], 256 * sizeof(RGBQUAD));

            RECT rect;
            GetClientRect(hwnd, &rect);
            StretchDIBits(hdc, 0, 0, rect.right, rect.bottom,
                          0, 0, FB_WIDTH, FB_HEIGHT,
                          &g_mem[ADDR_FB_START], pbmi, DIB_RGB_COLORS, SRCCOPY);

            EndPaint(hwnd, &ps);
            m68k_set_irq(&g_cpu, 3);
            return 0;
        }

        case WM_KEYDOWN: {
            u8 vk_code = (u8)(wParam & 0x7F);
            g_mem[ADDR_KEYBOARD] = (vk_code | 0x80);
            printf("KeyDown: %02x\n",vk_code);
            m68k_set_irq(&g_cpu, 2);
            return 0;
        }

        case WM_KEYUP: {
            u8 vk_code = (u8)(wParam & 0x7F);
            printf("KeyUp: %02x\n",vk_code);
            g_mem[ADDR_KEYBOARD] = vk_code;
            m68k_set_irq(&g_cpu, 2);
            return 0;
        }

        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;
    }
    return DefWindowProcA(hwnd, msg, wParam, lParam);
}

// Julistetaan disassembler, jos se ei tule suoraan rocket68.h kautta
int m68k_disasm(M68kCpu* cpu, u32 pc, char* buffer, int buf_size);

// KORJATTU: Ei oteta parametreja, luetaan PC suoraan sisällä
void dump_cpu_crash_state(void) {
    char disasm_buffer[64] = { 0 };
    printf("\n[CPU CRASH] Jarjestelma kaatui!\n");
    u32 crash_pc = m68k_get_pc(&g_cpu);
    printf("PC: 0x%08X\n", crash_pc);
    m68k_disasm(&g_cpu, crash_pc, disasm_buffer, sizeof(disasm_buffer));
    printf("Kasky: %s\n", disasm_buffer);
}

int illegal_instruction_callback(int opcode) {
    printf("\n[ERROR] Illegal Instruction (Opcode: 0x%04X)\n", (u16)opcode);
    dump_cpu_crash_state();
    running = false;
    return 0; 
}

// --- TAVUKORJATTU LEVYOHJAIN (main.c) ---
void handle_hdd_io(void) {
    // Luetaan 16-bittinen sana (Big-Endian) suoraan muistitaulukosta
    u16 hdd_cmd = (g_mem[ADDR_HDD_CMD] << 8) | g_mem[ADDR_HDD_CMD + 1];
    if (hdd_cmd == 0) return;

    // Luetaan 32-bittinen sivu (Long) Big-Endian-muodossa
    u32 current_page = (g_mem[ADDR_HDD_PAGE] << 24) | (g_mem[ADDR_HDD_PAGE + 1] << 16) | 
                       (g_mem[ADDR_HDD_PAGE + 2] << 8)  | g_mem[ADDR_HDD_PAGE + 3];
    u32 hdd_offset = current_page * 512;

    if (hdd_offset + 512 <= HDD_TOTAL_SIZE) {
        if (hdd_cmd == 1) { // LUKU
            memcpy(&g_mem[ADDR_HDD_WINDOW], &g_hdd_mem[hdd_offset], 512);
        } 
        else if (hdd_cmd == 2) { // TALLENNUS
            memcpy(&g_hdd_mem[hdd_offset], &g_mem[ADDR_HDD_WINDOW], 512);
            if (g_hdd_file) {
                fseek(g_hdd_file, hdd_offset, SEEK_SET);
                fwrite(&g_hdd_mem[hdd_offset], 1, 512, g_hdd_file);
                fflush(g_hdd_file);
            }
        }
        // Kuitataan komento
        g_mem[ADDR_HDD_CMD] = 0;
        g_mem[ADDR_HDD_CMD + 1] = 0;
        m68k_set_irq(&g_cpu, 1); 
    }

    // --- TAVUKORJATTU INTERRUPT-KUITTAUS ---
    u16 int_clear_val = (g_mem[ADDR_INT_CLEAR] << 8) | g_mem[ADDR_INT_CLEAR + 1];
    if (int_clear_val == 1) {
        m68k_set_irq(&g_cpu, 0);
        g_mem[ADDR_INT_CLEAR] = 0;
        g_mem[ADDR_INT_CLEAR + 1] = 0;
    }
}



int load_rom_file(const char* filename, u32 dest_addr, u32 max_size) {
    FILE* f = fopen(filename, "rb");
    if (!f) {
        printf("[ERROR] Tiedostoa '%s' ei loytynyt!\n", filename);
        return 0;
    }
    size_t bytes_read = fread(&g_mem[dest_addr], 1, max_size, f);
    fclose(f);
    printf("[LOAD] %s ladattu onnistuneesti osoitteeseen 0x%08X (%d tavua)\n", filename, dest_addr, (int)bytes_read);
    return 1;
}

int main(void) {

    int timer_counter = 0;

    setvbuf(stdout, NULL, _IONBF, 0);
    printf("==================================================================\n");
    printf("[EMU] Kaynnistetaan M68k...\n");
    printf("==================================================================\n");

    g_mem = calloc(TOTAL_MEM_SIZE, 1);
    if (!g_mem) return 1;

/*
    g_hdd_file = fopen("hdd.img", "rb+");
    if (!g_hdd_file) {
        // Jos tiedostoa ei ole, luodaan tyhjä 10MB virtuaalilevy testejä varten
        g_hdd_file = fopen("hdd.img", "wb+");
        if (g_hdd_file) {
            u8* empty_disk = calloc(1024 * 1024 * 10, 1);
            fwrite(empty_disk, 1, 1024 * 1024 * 10, g_hdd_file);
            free(empty_disk);
            fseek(g_hdd_file, 0, SEEK_SET);
        }
    }
    if (!g_hdd_file) {
        printf("[ERROR] Virtuaalisen kovalevyn (hdd.img) avaaminen epaonnistui!\n");
    } else {
        printf("[HDD] hdd.img liitetty onnistuneesti ohjaimeen.\n");
    }

*/

    FILE* f;

    // 1. Ladataan BIOS.ROM osoitteeseen 0x00000000
    f = fopen("ROMs\\BIOS.ROM", "rb");
    if (f) {
        fread(&g_mem[0x00000000], 1, 20480, f);
        fclose(f);
        printf("[EMU] ROMs\\BIOS.ROM esiladattu osoitteeseen 0x00000000.\n");
    } else {
        printf("Kriittinen virhe: ROMs\\BIOS.ROM puuttuu!\n");
        return -1;
    }

    // 2. Ladataan loader.bin suoraan osoitteeseen 0x00000000 + $5000
    f = fopen("os_bin\\loader.bin", "rb");
    if (f) {
        fread(&g_mem[0x00005000], 1, 512, f);
        fclose(f);
        printf("[EMU] os_bin\\loader.bin esiladattu osoitteeseen 0x00005000.\n");
    }

    // 3. Ladataan monitor.bin suoraan osoitteeseen 0x00000000 + $6000
    f = fopen("os_bin\\monitor.bin", "rb");
    if (f) {
        fread(&g_mem[0x00006000], 1, 4096, f);
        fclose(f);
        printf("[EMU] os_bin\\monitor.bin esiladattu osoitteeseen 0x00006000.\n");
    }

    // 4. Ladataan FONT.ROM osoitteeseen 0x00220000
    f = fopen("ROMs\\FONT.ROM", "rb");
    if (f) {
        fread(&g_mem[0x00220000], 1, 2048, f);
        fclose(f);
        printf("[EMU] ROMs\\FONT.ROM esiladattu osoitteeseen 0x00220000.\n");
    }


/*

    // Varataan tila ja luetaan koko levy RAMiin
    g_hdd_mem = calloc(HDD_TOTAL_SIZE, 1);
    FILE* f_hd = fopen("hdd.img", "rb");
    if (f_hd) {
        fread(g_hdd_mem, 1, HDD_TOTAL_SIZE, f_hd);
        fclose(f_hd);
        printf("[EMU HDD] Koko hdd.img (10MB) ladattu onnistuneesti virtuaalimuistiin.\n");
    }
*/

    m68k_init(&g_cpu, g_mem, TOTAL_MEM_SIZE);
    m68k_reset(&g_cpu);

    HINSTANCE hInstance = GetModuleHandle(NULL);
    WNDCLASSEXA wc = {
        .cbSize = sizeof(WNDCLASSEXA),
        .style = CS_HREDRAW | CS_VREDRAW,
        .lpfnWndProc = WndProc,
        .hInstance = hInstance,
        .hCursor = LoadCursor(NULL, IDC_ARROW),
        .lpszClassName = "Rocket68HardwareWin"
    };
    RegisterClassExA(&wc);

    RECT winRect = { 0, 0, FB_WIDTH * 2, FB_HEIGHT * 2 };
    AdjustWindowRect(&winRect, WS_OVERLAPPEDWINDOW, FALSE);

    g_hwnd = CreateWindowExA(0, "Rocket68HardwareWin", "Rocket68 Interrupt-Driven OS",
                             WS_OVERLAPPEDWINDOW | WS_VISIBLE,
                             CW_USEDEFAULT, CW_USEDEFAULT,
                             winRect.right - winRect.left, winRect.bottom - winRect.top,
                             NULL, NULL, hInstance, NULL);

    if (!g_hwnd) {
        printf("[ERROR] Grafiikkaikkunan luominen epaonnistui!\n");
        free(g_mem);
        return 1;
    }

    MSG msg;
    running = TRUE;

    running = TRUE;
    while (running) {
        while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
            if (msg.message == WM_QUIT) running = FALSE;
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }

        // 1. AJETAAN SUORITINTA ERITTÄIN PIENISSÄ JAKSOISSA!
        // Voit ajaa nyt vapaasti vaikka vain 50 tai 100 sykliä kerrallaan!
        for(int count=0;count<512;count++) {
            m68k_execute(&g_cpu, 2);
            u32 current_pc = m68k_get_pc(&g_cpu);
            printf("PC: $%08x\n",current_pc);       

            if ((current_pc >= 0x00000F30 && current_pc <= 0x00000F36)) {
                
                printf("\n==================================================================\n");
                printf("[EMU HALT] Jarjestelma suoritti hatajarrutuksen osoitteessa 0x%08X!\n", current_pc);
                printf("==================================================================\n");
                
                dump_cpu_crash_state(); // Tulostetaan rekisterivedos konsoliin
                running = FALSE;        // Pysäytetään emulaattori välittömästi
                break;
            }


            // --- RAUTATASON KESKEYTYSREKISTERIN VAHTIMINEN (INT_CLEAR) ---
            // Koska keskeytyslinja jätetään pystyyn, tämä laukeaa asynkronisesti juuri oikealla kierroksella!
            u8 int_clear_val = g_mem[ADDR_INT_CLEAR];
            if (int_clear_val == 1) { // CPU kirjoitti numero 1 merkiksi hdd-kuittauksesta
                m68k_set_irq(&g_cpu, 0);   // Lasketaan sähköinen linja alas lennosta
                g_mem[ADDR_INT_CLEAR] = 0; // Nollataan rekisteri
                printf("[EMU INT-DEBUG] CPU kuittasi keskeytyksen INT 1 laitteistotasolla. Linja nollattu.\n");
            }
       
//        handle_hdd_io();

            // Timer (Level 4) liipaisu
            timer_counter++;
            if (timer_counter >= 500) { // Säädetty yhteensopivaksi pienen syklin kanssa
                m68k_set_irq(&g_cpu, 4);
                timer_counter = 0;
            }

        }

        Sleep(1); // Pienennetään sleep-aikaa, koska kierroksia ajetaan nyt useammin sekunnissa
    }

    free(g_mem);

    fclose(g_hdd_file);

    return 0;
}
