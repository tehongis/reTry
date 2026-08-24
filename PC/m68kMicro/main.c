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

#define ADDR_HDD_LBA     0x001FFF00
#define ADDR_HDD_BUFFER  0x001FFF04
#define ADDR_HDD_CMD     0x001FFF08
#define ADDR_HDD_STATUS  0x001FFF09

FILE* g_hdd_file = NULL;

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
    int has_booted = 0;      // KORJAUS: Lisätty puuttuva boottilaskuri tähän!

    setvbuf(stdout, NULL, _IONBF, 0);
    printf("==================================================================\n");
    printf("[EMU] Kaynnistetaan M68k alusta uudella FONT.ROM tiedostolla...\n");
    printf("==================================================================\n");

    g_mem = calloc(TOTAL_MEM_SIZE, 1);
    if (!g_mem) return 1;

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


    // Ladataan molemmat tiedostot ROMs/ kansiosta raakabinääreinä
    if (!load_rom_file("ROMs\\BIOS.ROM", 0x00000000, 65536)) return 1;
    if (!load_rom_file("ROMs\\FONT.ROM", ADDR_FONT_ROM, 4096)) return 1; // Tukee max 4KB fontteja

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

    while (running) {
        while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
            if (msg.message == WM_QUIT) running = FALSE;
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }

        u32 last_pc = m68k_get_pc(&g_cpu);
        m68k_execute(&g_cpu, 128000);
        u32 current_pc = m68k_get_pc(&g_cpu);

        // --- KORJATTU TURVALLINEN CPU STOP -KAATUMISVAHTI ---
        if (has_booted && (current_pc == last_pc)) {
            printf("\n[EMU HALT] CPU pysaytetty (STOP/HALT-kasky)!\n");
            dump_cpu_crash_state();
            running = FALSE;
        }

        m68k_set_irq(&g_cpu, 0);

        // Vahtitaan PC-arvoa turvallisesti sallitun 4MB RAM-muistin rajoissa
        if (m68k_get_pc(&g_cpu) >= TOTAL_MEM_SIZE) {
            printf("\n[ERROR] Bus Error / Address Error: CPU yritti suorittaa koodia muistin ulkopuolelta!\n");
            dump_cpu_crash_state();
            running = FALSE; 
        }

        // Liipaisualgoritmi Timerille (esim. joka toisella pääsilmukan kierroksella jos Sleep on 16ms, 
        // tai tarkemmin simuloimalla CPU-syklejä. Yksinkertainen tapa:)
        timer_counter++;
        if (timer_counter >= 1) { // Voit säätää taajuutta tästä
            m68k_set_irq(&g_cpu, 4); // Nostetaan Level 4 Keskeytys (Timer)
            timer_counter = 0;
        }


    // main.c - Pääsilmukan sisällä (while running)
    u8 hdd_cmd = g_mem[ADDR_HDD_CMD];
    if (hdd_cmd == 1 || hdd_cmd == 2) {
        g_mem[ADDR_HDD_STATUS] = 1; // Ohjain varattu, CPU pysäytetään siirron ajaksi

        u32 lba = (g_mem[ADDR_HDD_LBA] << 24) | (g_mem[ADDR_HDD_LBA+1] << 16) | 
                (g_mem[ADDR_HDD_LBA+2] << 8) | g_mem[ADDR_HDD_LBA+3];
        u32 ram_addr = (g_mem[ADDR_HDD_BUFFER] << 24) | (g_mem[ADDR_HDD_BUFFER+1] << 16) | 
                    (g_mem[ADDR_HDD_BUFFER+2] << 8) | g_mem[ADDR_HDD_BUFFER+3];

        if (g_hdd_file && ram_addr < TOTAL_MEM_SIZE) {
            fseek(g_hdd_file, lba * 512, SEEK_SET);
            if (hdd_cmd == 1) {
                fread(&g_mem[ram_addr], 1, 512, g_hdd_file); // DMA-siirto suoraan RAMiin
            } else {
                fwrite(&g_mem[ram_addr], 1, 512, g_hdd_file);
                fflush(g_hdd_file);
            }
            g_mem[ADDR_HDD_STATUS] = 0; // DMA valmis onnistuneesti
        } else {
            g_mem[ADDR_HDD_STATUS] = 2; // DMA-virhe
        }

        g_mem[ADDR_HDD_CMD] = 0; // Kuitataan komento suoritetuksi
        
        // NOSTETAAN LEVEL 1 KESKEYTYSPULSSI (IRQ STROBE)
        printf("[EMU IRQ-DEBUG] Nostetaan laitteistokeskeytys: LEVEL 1 IRQ (HDD)\n");
        m68k_set_irq(&g_cpu, 1); 
        
        // Suoritetaan 1-2 pientä askelta/sykliä emulaattorissa, jotta CPU ehtii rekisteröidä linjan nousun
        m68k_execute(&g_cpu, 10); 
        
        // Lasketaan linja heti alas, jottei se jää lukitsemaan suoritinta ikuiseen looppiin (Pulse mode)
        m68k_set_irq(&g_cpu, 0); 
    }


        m68k_set_irq(&g_cpu, 3);

        u16 frequency = (u16)((g_mem[ADDR_AUDIO_BEEP] << 8) | g_mem[ADDR_AUDIO_BEEP + 1]);
        if (frequency > 0) {
            // Korvataan kohiseva Beep asynkronisilla Windows-järjestelmä-äänillä taajuuden mukaan:
            if (frequency >= 800) {
                // Korkea taajuus -> Standardi ilmoitusääni (Asterisk / Info)
                MessageBeep(MB_ICONINFORMATION);
            } else {
                // Matala taajuus -> Kriittinen virheääni (Hand / Stop / Error)
                MessageBeep(MB_ICONHAND);
            }
            
            // Nollataan rekisteri, jottei jää soimaan luuppiin
            g_mem[ADDR_AUDIO_BEEP] = 0;
            g_mem[ADDR_AUDIO_BEEP + 1] = 0;
        }


        if (g_hwnd) {
            InvalidateRect(g_hwnd, NULL, FALSE);
            UpdateWindow(g_hwnd);
        }

        Sleep(16); 
    }


    free(g_mem);

    fclose(g_hdd_file);

    return 0;
}
