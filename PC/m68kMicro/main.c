// main.c
#include "rocket68.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <commctrl.h> // Tarvitaan Status Baria varten

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

#define ADDR_INT_CLEAR    0x001FFF0C

// Uudet ID-tunnisteet
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

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
    case WM_CREATE:
        // LUODAAN STATUS BAR (Tilarivi) alalaitaan [0x01.11]
      // 1. Luodaan Status Bar
        g_hwndStatus = CreateWindowExA(0, STATUSCLASSNAMEA, NULL, 
                                       WS_CHILD | WS_VISIBLE, 
                                       0, 0, 0, 0, 
                                       hwnd, (HMENU)ID_STATUS_BAR, NULL, NULL);

        // Jaetaan tilarivi kolmeen osaan (Lohko 0 napille, Lohko 1 PC:lle, Lohko 2 HDD:lle)
        int parts[] = { 120, 320, -1 };
        SendMessage(g_hwndStatus, SB_SETPARTS, 3, (LPARAM)parts);

        // 2. Haetaan tilarivin ensimmäisen lohkon (0) tarkat koordinaatit napille

        SendMessage(g_hwndStatus, SB_GETRECT, 0, (LPARAM)&rPart);

        // 3. Luodaan Reset-painike SUORAAN tilarivin sisälle lohkon 0 kohdalle
        g_hwndReset = CreateWindowExA(0, "BUTTON", "RESET CPU", 
                                      WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
                                      rPart.left + 2, rPart.top + 2, 
                                      (rPart.right - rPart.left) - 4, 
                                      (rPart.bottom - rPart.top) - 4, 
                                      g_hwndStatus, (HMENU)ID_RESET_BUTTON, NULL, NULL);

        break;
    case WM_SIZE:
        // Päivitetään ohjauskomponenttien paikat [0x01.11]
       SendMessage(g_hwndStatus, WM_SIZE, 0, 0);

        // Päivitetään napin paikka vastaamaan tilarivin uutta kokoa
        RECT rPart;
        SendMessage(g_hwndStatus, SB_GETRECT, 0, (LPARAM)&rPart);
        MoveWindow(g_hwndReset, 
                   rPart.left + 2, rPart.top + 2, 
                   (rPart.right - rPart.left) - 4, 
                   (rPart.bottom - rPart.top) - 4, 
                   TRUE);
        return 0;
        break;
    case WM_COMMAND:
        if (LOWORD(wParam) == ID_RESET_BUTTON) {
            do_system_reset(); // Nappia painettu [0x01.11]
        }
        break;
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

            // KORJAUS: Luetaan M68k:n Big-Endian tavut ja käännetään ne Windowsin BGRA-muotoon!
            u8* m68k_pal = &g_mem[ADDR_PALETTE_START];
            
            for (int i = 0; i < 256; i++) {
                u32 offset = i * 4; // Jokainen väri vie 4 tavua
                
                // M68k tavupaikat muistissa: 
                // offset+0 = Alpha/Tyhjä, offset+1 = Red, offset+2 = Green, offset+3 = Blue
                pbmi->bmiColors[i].rgbBlue     = m68k_pal[offset + 3]; // Blue
                pbmi->bmiColors[i].rgbGreen    = m68k_pal[offset + 2]; // Green
                pbmi->bmiColors[i].rgbRed      = m68k_pal[offset + 1]; // Red
                pbmi->bmiColors[i].rgbReserved = 0;                    // Pakotetaan Alpha näkyväksi (0)
            }
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
    printf("\n[CPU STATE ON EXIT]\n");
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

void handle_hdd_io(void) {
    // 1. Tarkistetaan komentorekisteri (16-bit)
    u16 hdd_cmd = (g_mem[ADDR_HDD_CMD] << 8) | g_mem[ADDR_HDD_CMD + 1];
    if (hdd_cmd == 0) return;

    // 2. Haetaan haluttu LBA-sektori (32-bit)
    u32 current_page = (g_mem[ADDR_HDD_PAGE]     << 24) | 
                       (g_mem[ADDR_HDD_PAGE + 1] << 16) |
                       (g_mem[ADDR_HDD_PAGE + 2] << 8)  | 
                        g_mem[ADDR_HDD_PAGE + 3];

    // 3. Haetaan DMA-kohdeosoite (32-bit)
    u32 dma_addr = (g_mem[ADDR_HDD_DMA_ADDR]     << 24) | 
                   (g_mem[ADDR_HDD_DMA_ADDR + 1] << 16) |
                   (g_mem[ADDR_HDD_DMA_ADDR + 2] << 8)  | 
                    g_mem[ADDR_HDD_DMA_ADDR + 3];

    u32 hdd_offset = current_page * 512;

    if (g_hdd_file && (hdd_offset + 512 <= HDD_TOTAL_SIZE) && (dma_addr + 512 <= RAM_SIZE)) {
        fseek(g_hdd_file, hdd_offset, SEEK_SET);

        if (hdd_cmd == 1) {
            // Suora siirto tiedostosta virtuaalisen m68k:n RAMiin
            SendMessage(g_hwndStatus, SB_SETTEXTA, 2, (LPARAM)(g_hdd_activity ? "  HDD: [ BUSY ] 🔴" : "  HDD: [ IDLE ] ⚪"));
            fread(&g_mem[dma_addr], 1, 512, g_hdd_file);
        } 
        else if (hdd_cmd == 2) {
            // Suora siirto m68k:n RAMista tiedostoon
            SendMessage(g_hwndStatus, SB_SETTEXTA, 2, (LPARAM)(g_hdd_activity ? "  HDD: [ BUSY ] 🔴" : "  HDD: [ IDLE ] ⚪"));
            fwrite(&g_mem[dma_addr], 1, 512, g_hdd_file);
            fflush(g_hdd_file);
        }

        // --- UUSI KESKEYTYSLAUKAISU ---
        // Nollataan komento heti laitteiston puolesta
        g_mem[ADDR_HDD_CMD] = 0;
        g_mem[ADDR_HDD_CMD + 1] = 0;

        // Nostetaan Level 1 keskeytys merkiksi siitä, että DMA on valmis!
        m68k_set_irq(&g_cpu, 1);
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

void dump_mem(void) {
        // =============================================================================
    // ROCKET68 SYSTEEMIDIAGNOSTIIKKA: LOPULLINEN MUISTIDUMPPI (MUKANA PALETTI)
    // =============================================================================
    printf("\n==================================================================\n");
    printf("[EMU DIAG] TULOSTETAAN JÄRJESTELMÄN KRIITTISET MUISTIALUEET LOPETUKSESSA\n");
    printf("==================================================================\n");

    // Rakenne: { Aloitusosoite, Koko tavuina, Otsikko }
    struct {
        u32 start;
        u32 size;
        const char* name;
    } regions[] = {
        { 0x00000000, 128,   "1. AUTOVECTORIT & EXCEPTION TABLE ($0000-$007F)" },
        { 0x00001000, 512,   "2. BIOS & JUMP TABLE ($1000-$1200)" },
        { 0x00005000, 256,   "3. LOADER / BOOTLOADER AREA ($5000-$5100)" },
        { 0x00200000, 512,   "4. RUUTUMUISTI / FRAMEBUFFER ALKU ($00200000-)" },
        { 0x00220000, 256,   "5. FONT ROM GLYYFIT ($00220000-)" },
        { 0x00214000, 64,  "6. REAL PALETTE RAM ($00214000-)" } // KORJATTU OSOITE!
    };

    int num_regions = sizeof(regions) / sizeof(regions[0]);

    for (int r = 0; r < num_regions; r++) {
        printf("\n--- %s ---\n", regions[r].name);
        
        for (u32 addr = regions[r].start; addr < regions[r].start + regions[r].size; addr += 16) {
            printf("$%08X: ", addr);
            
            // Hex-tavut
            for (int i = 0; i < 16; i++) {
                printf("%02X ", g_mem[addr + i]);
            }
            printf(" | ");
            
            // Luettavat ASCII-merkit
            for (int i = 0; i < 16; i++) {
                u8 ch = g_mem[addr + i];
                if (ch >= 32 && ch <= 126) {
                    printf("%c", ch);
                } else {
                    printf(".");
                }
            }
            printf("\n");
        }
    }
    printf("==================================================================\n\n");

    return;
}


int main(void) {

    int timer_counter = 0;

    setvbuf(stdout, NULL, _IONBF, 0);

    char statusText[64];   

    g_mem = calloc(TOTAL_MEM_SIZE, 1);
    if (!g_mem) return 1;

    g_hdd_file = fopen("hdd.img", "rb+");
    if (!g_hdd_file) {
        printf("[KRIITTINEN VIRHE] hdd.img ei löydy!\n");
        return -1;
    }

    FILE* f;

    // 1. Ladataan BIOS.ROM osoitteeseen 0x00000000
    f = fopen("os_bin\\bios.bin", "rb");
    if (f) {
        fread(&g_mem[0x00000000], 1, 20480, f);
        fclose(f);
        printf("[EMU] os_bin\\bios.bin esiladattu osoitteeseen 0x00000000.\n");
    } else {
        printf("Kriittinen virhe: os_bin\\bios.bin puuttuu!\n");
        return -1;
    }
/*
    // 2. Ladataan loader.bin suoraan osoitteeseen 0x00000000 + $5000
    f = fopen("os_bin\\loader.bin", "rb");
    if (f) {
        fread(&g_mem[0x00005000], 1, 512, f);
        fclose(f);
        printf("[EMU] os_bin\\loader.bin esiladattu osoitteeseen 0x00005000.\n");
    } else {
        printf("Kriittinen virhe: os_bin\\loader.bin puuttuu!\n");
        return -1;
    }


    // 3. Ladataan monitor.bin suoraan osoitteeseen 0x00000000 + $6000
    f = fopen("os_bin\\monitor.bin", "rb");
    if (f) {
        fread(&g_mem[0x00006000], 1, 4096, f);
        fclose(f);
        printf("[EMU] os_bin\\monitor.bin esiladattu osoitteeseen 0x00006000.\n");
    } else {
        printf("Kriittinen virhe: os_bin\\monitor.bin puuttuu!\n");
        return -1;
    }

*/
    // 4. Ladataan FONT.ROM osoitteeseen 0x00220000
    f = fopen("os_bin\\font.bin", "rb");
    if (f) {
        fread(&g_mem[0x00220000], 1, 2048, f);
        fclose(f);
        printf("[EMU] os_bin\\font.bin esiladattu osoitteeseen 0x00220000.\n");
    } else {
        printf("Kriittinen virhe: os_bin\\font.bin puuttuu!\n");
        return -1;
    }

    // Alustetaan ja resetoidaan suoritinydin
    m68k_init(&g_cpu, g_mem, TOTAL_MEM_SIZE);
    m68k_reset(&g_cpu);



/*
    g_cpu.sr = 0x2000; 

    g_cpu.vbr = 0x00000000;
    g_cpu.ssp = 0x00080000; // Pinon alku osoitteesta $00080000
    g_cpu.pc  = 0x00001000; // Pakotetaan CPU aloittamaan suoraan BIOS_INIT-kohdasta!

    printf("[EMU HARDWARE] Suorittimen keskeytysväylä herätetty livenä (SR=0x2000, VBR=0).\n");

*/


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

    // main() sisällä:
    // Varataan vain 30px tilaa Status Baria varten peliruudun alle
    RECT winRect = { 0, 0, FB_WIDTH * 2, (FB_HEIGHT * 2) + 30 };
    AdjustWindowRect(&winRect, WS_OVERLAPPEDWINDOW, FALSE);


    g_hwnd = CreateWindowExA(0, "Rocket68HardwareWin", "Rocket68", WS_OVERLAPPEDWINDOW | WS_VISIBLE, 
                             CW_USEDEFAULT, CW_USEDEFAULT, winRect.right - winRect.left, winRect.bottom - winRect.top, NULL, NULL, hInstance, NULL);

    if (!g_hwnd) {
        printf("[ERROR] Grafiikkaikkunan luominen epaonnistui!\n");
        free(g_mem);
        return 1;
    }

    MSG msg;


    printf("==================================================================\n");
    printf("[EMU] Kaynnistetaan M68k...\n");
    printf("==================================================================\n");

    running = TRUE;
    while (running) {
        while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
            if (msg.message == WM_QUIT) running = FALSE;
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }

//        u32 last_pc = m68k_get_pc(&g_cpu);
        m68k_execute(&g_cpu, 50000);
        u32 current_pc = m68k_get_pc(&g_cpu);
//        printf("CPU stepped from $%08x to $%08x \n",last_pc,current_pc);

        sprintf(statusText, "  CPU PC: $%08X", m68k_get_pc(&g_cpu));
        SendMessage(g_hwndStatus, SB_SETTEXTA, 1, (LPARAM)statusText);

        InvalidateRect(g_hwnd, NULL, FALSE);

        handle_hdd_io();

        if ((current_pc >= 0x000012CE && current_pc <= 0x000012D2)){
            
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
        if (int_clear_val != 0) { // CPU kirjoitti hdd-kuittauksen
            m68k_set_irq(&g_cpu, 0);   // Lasketaan sähköinen linja alas lennosta
            g_mem[ADDR_INT_CLEAR] = 0; // Nollataan rekisteri
            printf("[EMU INT-DEBUG] CPU kuittasi keskeytyksen INT 1 laitteistotasolla. Linja nollattu.\n");
        }
    
        // Timer (Level 4) liipaisu
        timer_counter++;
        if (timer_counter >= 10000) { // Säädetty yhteensopivaksi pienen syklin kanssa
            m68k_set_irq(&g_cpu, 4);
            timer_counter = 0;
        }

        if (running==FALSE) {
            dump_mem();
            dump_cpu_crash_state();
        }

        Sleep(4); // Pienennetään sleep-aikaa, koska kierroksia ajetaan nyt useammin sekunnissa
    }


    free(g_mem);

    fclose(g_hdd_file);  

    return 0;
}
