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

    running = TRUE;
    while (running) {
        while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
            if (msg.message == WM_QUIT) running = FALSE;
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }

        // 1. AJETAAN SUORITINTA ERITTÄIN PIENISSÄ JAKSOISSA!
        // Voit ajaa nyt vapaasti vaikka vain 50 tai 100 sykliä kerrallaan!
        m68k_execute(&g_cpu, 1000);

        u32 current_pc = m68k_get_pc(&g_cpu);

        printf("PC: $%08x\n",current_pc);

        // --- LIVE-VAHTI (PC-TARKISTUS SUORAAN KIERROKSELLA) ---
        if (current_pc == 0x000011BC || current_pc == 0x000011BE || current_pc == 0x00000830) {
            printf("\n==================================================================\n");
            printf("[EMU HALT] Pysäytettiin livenä osoitteessa 0x%08X!\n", current_pc);
            printf("==================================================================\n");
            dump_cpu_crash_state();
            running = FALSE;
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

        // --- ASYNKRONINEN KIINTOLEVYOHJAIN TARKALLA SEKTORIDEBUGILLA ---
        u8 hdd_cmd = g_mem[ADDR_HDD_CMD];
        
        // Vaihe A: CPU antoi uuden komennon, tallennetaan parametrit ja aloitetaan viive
        if (hdd_cmd != 0 && hdd_busy_timer == 0) {
            hdd_pending_lba = (g_mem[ADDR_HDD_LBA] << 24) | (g_mem[ADDR_HDD_LBA+1] << 16) | 
                              (g_mem[ADDR_HDD_LBA+2] << 8) | g_mem[ADDR_HDD_LBA+3];
            hdd_pending_ram = (g_mem[ADDR_HDD_BUFFER] << 24) | (g_mem[ADDR_HDD_BUFFER+1] << 16) | 
                               (g_mem[ADDR_HDD_BUFFER+2] << 8) | g_mem[ADDR_HDD_BUFFER+3];
            hdd_pending_cmd = hdd_cmd;

            g_mem[ADDR_HDD_STATUS] = 1; // Ohjain ilmoittaa olevansa VARATTU (Busy)
            g_mem[ADDR_HDD_CMD] = 0;    // Kuitataan komento vastaanotetuksi raudalta

            // ASETETAAN VIIVE: 50 kierrosta simuloi hienosti levyn pyörähdystä
            hdd_busy_timer = 50;        
            
            printf("[EMU HDD-RAUTA] >>> KOMENTO VASTAANOTETTU: %s | Sektori LBA: %u | RAM-osoite: 0x%08X\n", 
                   (hdd_pending_cmd == 1 ? "LUE (READ)" : "KIRJOITA (WRITE)"), 
                   hdd_pending_lba, hdd_pending_ram);
            printf("[EMU HDD-RAUTA] Ohjain siirtyi Busy-tilaan (STATUS=1) simulaatioviiveen ajaksi...\n");
        }

        // Vaihe B: Ohjain raksuttaa taustalla viivettä alaspäin
        if (hdd_busy_timer > 0) {
            hdd_busy_timer--;
            
            // Kun mekaaninen hakuajastin saavuttaa nollan, suoritetaan varsinainen DMA-siirto!
            if (hdd_busy_timer == 0) {
                printf("[EMU HDD-RAUTA] Viive paattyi. Suoritetaan fyysinen DMA-siirto tiedostosta RAMiin...\n");
                
                if (g_hdd_file && hdd_pending_ram < TOTAL_MEM_SIZE) {
                    // Siirrytään tarkan LBA-lohkon kohdalle tiedostossa (512 tavua per sektori)
                    fseek(g_hdd_file, hdd_pending_lba * 512, SEEK_SET);
                    
                    if (hdd_pending_cmd == 1) {
                        size_t read_bytes = fread(&g_mem[hdd_pending_ram], 1, 512, g_hdd_file);
                        printf("[EMU HDD-RAUTA] <<< DMA LUE VALMIS: Luettu %zu tavua tiedostosta osoitteeseen 0x%08X.\n", 
                               read_bytes, hdd_pending_ram);
                    } else {
                        size_t written_bytes = fwrite(&g_mem[hdd_pending_ram], 1, 512, g_hdd_file);
                        fflush(g_hdd_file);
                        printf("[EMU HDD-RAUTA] <<< DMA KIRJOITUS VALMIS: Kirjoitettu %zu tavua levylle osoitteesta 0x%08X.\n", 
                               written_bytes, hdd_pending_ram);
                    }
                    
                    g_mem[ADDR_HDD_STATUS] = 0; // Ohjain vapautuu onnistuneesti (STATUS=0)
                } else {
                    printf("[EMU HDD-RAUTA] VIRHE: Viallinen tiedostokahva tai RAM-osoite 0x%08X muistin ulkopuolella!\n", hdd_pending_ram);
                    g_mem[ADDR_HDD_STATUS] = 2; // Ohjain ilmoittaa virheestä (STATUS=2)
                }

                // Nostetaan laitteistokeskeytys ja jätetään se pystyyn, kunnes CPU kuittaa sen INT_CLEARiin!
                printf("[EMU INT-DEBUG] Nostetaan asynkroninen laitteistokeskeytys: LEVEL 1 INT (HDD)\n");
                m68k_set_irq(&g_cpu, 1);
            }
        }

        // Timer (Level 4) liipaisu
        timer_counter++;
        if (timer_counter >= 500) { // Säädetty yhteensopivaksi pienen syklin kanssa
            m68k_set_irq(&g_cpu, 4);
            timer_counter = 0;
        }

        Sleep(1); // Pienennetään sleep-aikaa, koska kierroksia ajetaan nyt useammin sekunnissa
    }

    free(g_mem);

    fclose(g_hdd_file);

    return 0;
}
