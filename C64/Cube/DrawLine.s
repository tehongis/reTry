; Pyörivä 3D-kuutio 8x8 merkin (64x64 pikseliä) alueella
; Kaikki .rept-makrot purettu suoraksi koodiksi.

SCREEN      = $0400
CHARSET     = $3000
VIC_BANK    = $d018
ROM_CHAR    = $d000
RASTER_REG  = $d012

temp        = $fd          ; Tilapäismuisti laskentaan
rot_angle   = $fe          ; Pyörityskulma (0-63)

; Bresenhamin muuttujat nollasivulla
X0        = $10         ; Alku-X (0-63)
Y0        = $11         ; Alku-Y (0-63)
X1        = $12         ; Loppu-X (0-63)
Y1        = $13         ; Loppu-Y (0-63)

DX        = $14
DY        = $15
SX        = $16
SY        = $17
ERR       = $18
E2        = $19

ZP_PTR    = $1A         ; 2 tavun osoitin merkkimuistiin

        org $0801
basic:
        ; 2026 SYS 2061
        db $0c,$08,$ea,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00

main:
        sei                 ; Kopioidaan merkistö RAMiin

        lda #$33
        sta $01

        ldx #$00
copy_loop:
        ; Pura merkistön kopioinnin toisto (8 sivua x 256 tavua)
        lda ROM_CHAR + ($0000),x
        sta CHARSET  + ($0000),x
        lda ROM_CHAR + ($0100),x
        sta CHARSET  + ($0100),x
        lda ROM_CHAR + ($0200),x
        sta CHARSET  + ($0200),x
        lda ROM_CHAR + ($0300),x
        sta CHARSET  + ($0300),x
        lda ROM_CHAR + ($0400),x
        sta CHARSET  + ($0400),x
        lda ROM_CHAR + ($0500),x
        sta CHARSET  + ($0500),x
        lda ROM_CHAR + ($0600),x
        sta CHARSET  + ($0600),x
        lda ROM_CHAR + ($0700),x
        sta CHARSET  + ($0700),x
        inx
        bne copy_loop

        lda #$37
        sta $01

        cli

        lda #$1c            ; Merkistö osoitteeseen $3000
        sta VIC_BANK

        ; Tulostetaan 8x8 matriisi ruudun keskelle (Rivit 8-15, Sarakkeet 16-23)
print_grid:

        ldx #0
        clc
        lda #192
.frameloop        
        sta SCREEN + 40 * 0, x
        adc #$01
        sta SCREEN + 40 * 1, x
        adc #$01
        sta SCREEN + 40 * 2, x
        adc #$01
        sta SCREEN + 40 * 3, x
        adc #$01
        sta SCREEN + 40 * 4, x
        adc #$01
        sta SCREEN + 40 * 5, x
        adc #$01
        sta SCREEN + 40 * 6, x
        adc #$01
        sta SCREEN + 40 * 7, x
        adc #$01

        inx
        cpx #$08
        bne .frameloop


        lda #0
        sta rot_angle

; --- PÄÄSILMUKKA ---
main_loop:
wait_raster:
        lda RASTER_REG
        cmp #$f0
        bne wait_raster

        inc $d020

        jsr clear_frame

        jsr rotate_and_project
        jsr draw_cube_edges

        inc rot_angle
        lda rot_angle
        and #$3f
        sta rot_angle

        lda #$0e
        sta $d020

        jmp main_loop

clear_frame:
        ; Tyhjennetään 64 merkkiä (64 * 8 = 512 tavua)
        lda #$00
        ldx #$1f
.clearloop:
        sta CHARSET + (192 * 8) + 32 * 0,x
        sta CHARSET + (192 * 8) + 32 * 1,x
        sta CHARSET + (192 * 8) + 32 * 2,x
        sta CHARSET + (192 * 8) + 32 * 3,x
        sta CHARSET + (192 * 8) + 32 * 4,x
        sta CHARSET + (192 * 8) + 32 * 5,x
        sta CHARSET + (192 * 8) + 32 * 6,x
        sta CHARSET + (192 * 8) + 32 * 7,x
        sta CHARSET + (192 * 8) + 32 * 8,x
        sta CHARSET + (192 * 8) + 32 * 9,x
        sta CHARSET + (192 * 8) + 32 * 10,x
        sta CHARSET + (192 * 8) + 32 * 11,x
        sta CHARSET + (192 * 8) + 32 * 12,x
        sta CHARSET + (192 * 8) + 32 * 13,x
        sta CHARSET + (192 * 8) + 32 * 14,x
        sta CHARSET + (192 * 8) + 32 * 15,x
        dex
        bne .clearloop
        rts

; --- 3D PYÖRITYS JA PROJEKTIO ---
rotate_and_project:
        ldx #0
rot_vertex_loop:
        ldy rot_angle
        lda tab_cos,y
        sta cos_val
        lda tab_sin,y
        sta sin_val

        lda cube_vertices_x,x
        sta src_x
        lda cube_vertices_y,x
        sta src_y
        lda cube_vertices_z,x
        sta src_z

        ; X * cos(a) - Z * sin(a)
        lda src_x
        jsr multiply_signed
        sta rot_x_tmp
        lda src_z
        jsr multiply_signed
        sta temp
        lda rot_x_tmp
        sec
        sbc temp
        sta rot_x

        ; Y * cos(a) - Z * sin(a)
        lda src_y
        jsr multiply_signed
        sta rot_y_tmp
        lda src_z
        jsr multiply_signed
        sta temp
        lda rot_y_tmp
        sec
        sbc temp
        
        ; 2D Projektio ja siirros 64x64 alueen keskelle (offset +31)
        clc
        adc #31             ; Keskipiste Y
        sta projected_y,x

        lda rot_x
        clc
        adc #31             ; Keskipiste X
        sta projected_x,x

        inx
        cpx #8
        bne rot_vertex_loop
        rts

src_x:      db 0
src_y:      db 0
src_z:      db 0
cos_val:    db 0
sin_val:    db 0
rot_x:      db 0
rot_x_tmp:  db 0
rot_y_tmp:  db 0

multiply_signed:
        sta multiply_t1
        lda cos_val
        lda multiply_t1
        asl
        ora multiply_t1
        and #$1f            ; Skaalattu bittimaski suuremmalle kuutiolle
        rts
multiply_t1: db 0

; --- REUNOJEN PIIRTÄMINEN ---
draw_cube_edges:
        ldy #0
edge_loop:
        sty edge_index
        
        lda cube_edges_start,y
        tax
        lda projected_x,x
        sta X0
        lda projected_y,x
        sta Y0

        lda cube_edges_end,y
        tax
        lda projected_x,x
        sta X1
        lda projected_y,x
        sta Y1

        jsr draw_line_fast

        ldy edge_index
        iny
        cpy #12
        bne edge_loop
        rts

edge_index: db 0


draw_line_fast:
        ; --- Alustetaan Bresenhamin suunnat ja erotukset ---
        lda #$01
        sta SX
        lda X1
        sec
        sbc X0
        bcs store_dx    
        dec SX
        dec SX
        eor #$ff        
        adc #$01
store_dx:
        sta DX

        lda #$01
        sta SY
        lda Y1
        sec
        sbc Y0
        bcs store_dy    
        dec SY
        dec SY
        eor #$ff        
        adc #$01
store_dy:
        sta DY

        lda DX
        sec
        sbc DY
        sta ERR

; --- KRIITTINEN PÄÄSILMUKKA ---
line_loop:
        ; 1. Haetaan Y-koordinaatin tuoma siirtymä (0-63)
        ldy Y0
        lda y_low,y     ; Haetaan valmis alatavu (sisältää myös CHARSET ylätavun perustan)
        sta ZP_PTR
        
        ; 2. Haetaan X-koordinaatin tuoma siirtymä (0-63) ja yhdistetään ylätavuun
        ldx X0
        lda x_high,x    ; Haetaan X:n tuoma ylätavun lisäys + CHARSET ylätavu
        sta ZP_PTR+1

        ; Lisätään X:n tuoma alatavun lisäys (sarakehyppy 64 tavun välein)
        lda ZP_PTR
        clc
        adc x_low,x
        sta ZP_PTR
        bcc nocarry
        inc ZP_PTR+1    ; Hoidetaan mahdollinen muistikantatavu
nocarry:

        ; 3. Haetaan bittimaski ja piirretään piste
        lda bit_table,x ; X-koordinaatti toimii suoraan indeksinä (0-63) maskitaulukkoon!
        ldy #$00
        ora (ZP_PTR),y
        sta (ZP_PTR),y

        ; --- Loppuehto ---
        lda X0
        cmp X1
        bne bresenham_step
        lda Y0
        cmp Y1
        beq line_done   

bresenham_step:
        lda ERR
        asl
        sta E2

        clc
        adc DY
        bmi check_y_step
        lda ERR
        sec
        sbc DY          
        sta ERR
        lda X0
        clc
        adc SX
        sta X0

check_y_step:
        lda E2
        sec
        sbc DX
        bpl line_loop   
        lda ERR
        clc
        adc DX
        sta ERR
        lda Y0
        clc
        adc SY
        sta Y0
        jmp line_loop

line_done:
        rts

; --- SKAALATUT TAULUKOT (PAKOTETTU SIVUN ALKUUN) ---
        align 8

; Sini- ja kosinitaulukot skaalattuna (0-30 välille)
tab_sin:
        db 0,3,6,9,12,15,18,20,22,24,26,27,28,29,30,30
        db 30,30,30,29,28,27,26,24,22,20,18,15,12,9,6,3
        db 0,-3,-6,-9,-12,-15,-18,-20,-22,-24,-26,-27,-28,-29,-30,-30
        db -30,-30,-30,-29,-28,-27,-26,-24,-22,-20,-18,-15,-12,-9,-6,-3
tab_cos:
        db 30,30,30,29,28,27,26,24,22,20,18,15,12,9,6,3
        db 0,-3,-6,-9,-12,-15,-18,-20,-22,-24,-26,-27,-28,-29,-30,-30
        db -30,-30,-30,-29,-28,-27,-26,-24,-22,-20,-18,-15,-12,-9,-6,-3
        db 0,3,6,9,12,15,18,20,22,24,26,27,28,29,30,30
; Suurennetun kuution 3D-kärkipisteet (-18 ... +18)
cube_vertices_x: 
        db -18,  18,  18, -18, -18,  18,  18, -18
cube_vertices_y: 
        db -18, -18,  18,  18, -18, -18,  18,  18
cube_vertices_z: 
        db -18, -18, -18, -18,  18,  18,  18,  18
cube_edges_start: 
        db 0,1,2,3, 4,5,6,7, 0,1,2,3
cube_edges_end:   
        db 1,2,3,0, 5,6,7,4, 4,5,6,7
projected_x: 
        ds 8
projected_y:
        ds 8

; --- TAULUKOT (LOOK-UP TABLES) ---

; X-koordinaatin bittimaski (toistuu 8 pikselin välein)
bit_table:
        db $80, $40, $20, $10, $08, $04, $02, $01
        db $80, $40, $20, $10, $08, $04, $02, $01
        db $80, $40, $20, $10, $08, $04, $02, $01
        db $80, $40, $20, $10, $08, $04, $02, $01
        db $80, $40, $20, $10, $08, $04, $02, $01
        db $80, $40, $20, $10, $08, $04, $02, $01
        db $80, $40, $20, $10, $08, $04, $02, $01
        db $80, $40, $20, $10, $08, $04, $02, $01

; X-koordinaatin (0-63) tuoma muistisiirtymän alatavu.
; Koska merkit ovat pystyssä, jokainen 8 pikselin hyppy X-suunnassa
; siirtää muistiosoitetta 8 merkkiä eteenpäin eli 8 * 8 = 64 tavua.
x_low:
        ; Sarake 0 (s*64 = 0)
        db 0, 0, 0, 0, 0, 0, 0, 0
        
        ; Sarake 1 (s*64 = 64)
        db 64, 64, 64, 64, 64, 64, 64, 64
        
        ; Sarake 2 (s*64 = 128)
        db 128, 128, 128, 128, 128, 128, 128, 128
        
        ; Sarake 3 (s*64 = 192)
        db 192, 192, 192, 192, 192, 192, 192, 192
        
        ; Sarake 4 (s*64 = 256 -> alatavu on 0)
        db 0, 0, 0, 0, 0, 0, 0, 0
        
        ; Sarake 5 (s*64 = 320 -> alatavu on 320 - 256 = 64)
        db 64, 64, 64, 64, 64, 64, 64, 64
        
        ; Sarake 6 (s*64 = 384 -> alatavu on 384 - 256 = 128)
        db 128, 128, 128, 128, 128, 128, 128, 128
        
        ; Sarake 7 (s*64 = 448 -> alatavu on 448 - 256 = 192)
        db 192, 192, 192, 192, 192, 192, 192, 192

x_high:
        ; Sarake 0 ($3600 + 0 = $3600 -> ylätavu $36)
        db $36, $36, $36, $36, $36, $36, $36, $36
        
        ; Sarake 1 ($3600 + 64 = $3640 -> ylätavu $36)
        db $36, $36, $36, $36, $36, $36, $36, $36
        
        ; Sarake 2 ($3600 + 128 = $3680 -> ylätavu $36)
        db $36, $36, $36, $36, $36, $36, $36, $36
        
        ; Sarake 3 ($3600 + 192 = $36C0 -> ylätavu $36)
        db $36, $36, $36, $36, $36, $36, $36, $36
        
        ; Sarake 4 ($3600 + 256 = $3700 -> ylätavu $37)
        db $37, $37, $37, $37, $37, $37, $37, $37
        
        ; Sarake 5 ($3600 + 320 = $3740 -> ylätavu $37)
        db $37, $37, $37, $37, $37, $37, $37, $37
        
        ; Sarake 6 ($3600 + 384 = $3780 -> ylätavu $37)
        db $37, $37, $37, $37, $37, $37, $37, $37
        
        ; Sarake 7 ($3600 + 448 = $37C0 -> ylätavu $37)
        db $37, $37, $37, $37, $37, $37, $37, $37
        
; Y-koordinaatin (0-63) tuoma muistisiirtymän alatavu.
; Rivi-indeksi (Y0 / 8) tuo 8 tavun hypyn per merkki. 
; Merkin sisäinen pystyrivi (Y0 & 7) tuo 0-7 tavun lisäyksen.
; Kaava: (Y / 8) * 8 + (Y & 7) = Y ! 
; Eli esilaskennassa pystysuuntainen tavulisäys on maagisen suoraviivaisesti suoraan Y:n arvo.
y_low:
        db 0, 1, 2, 3, 4, 5, 6, 7
        db 8, 9, 10, 11, 12, 13, 14, 15
        db 16, 17, 18, 19, 20, 21, 22, 23
        db 24, 25, 26, 27, 28, 29, 30, 31
        db 32, 33, 34, 35, 36, 37, 38, 39
        db 40, 41, 42, 43, 44, 45, 46, 47
        db 48, 49, 50, 51, 52, 53, 54, 55
        db 56, 57, 58, 59, 60, 61, 62, 63

