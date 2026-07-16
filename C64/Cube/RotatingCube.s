; Pyörivä 3D-kuutio 8x8 merkin (64x64 pikseliä) alueella
; Kaikki .rept-makrot purettu suoraksi koodiksi.

SCREEN      = $0400
CHARSET     = $3000
VIC_BANK    = $d018
ROM_CHAR    = $d000
RASTER_REG  = $d012

zp_ptr      = $fb          ; Nollasivun osoitin viivanpiirrolle
temp        = $fd          ; Tilapäismuisti laskentaan
rot_angle   = $fe          ; Pyörityskulma (0-63)

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
        ldx #0
print_grid:
        lda #192
        sta SCREEN + (8 * 40) + 16, x
        lda #193
        sta SCREEN + (8 * 40) + 17, x
        lda #194
        sta SCREEN + (8 * 40) + 18, x
        lda #195
        sta SCREEN + (8 * 40) + 19, x
        lda #196
        sta SCREEN + (8 * 40) + 20, x
        lda #197
        sta SCREEN + (8 * 40) + 21, x
        lda #198
        sta SCREEN + (8 * 40) + 22, x
        lda #199
        sta SCREEN + (8 * 40) + 23, x

        lda #200
        sta SCREEN + (9 * 40) + 16, x
        lda #201
        sta SCREEN + (9 * 40) + 17, x
        lda #202
        sta SCREEN + (9 * 40) + 18, x
        lda #203
        sta SCREEN + (9 * 40) + 19, x
        lda #204
        sta SCREEN + (9 * 40) + 20, x
        lda #205
        sta SCREEN + (9 * 40) + 21, x
        lda #206
        sta SCREEN + (9 * 40) + 22, x
        lda #207
        sta SCREEN + (9 * 40) + 23, x

        lda #208
        sta SCREEN + (10 * 40) + 16, x
        lda #209
        sta SCREEN + (10 * 40) + 17, x
        lda #210
        sta SCREEN + (10 * 40) + 18, x
        lda #211
        sta SCREEN + (10 * 40) + 19, x
        lda #212
        sta SCREEN + (10 * 40) + 20, x
        lda #213
        sta SCREEN + (10 * 40) + 21, x
        lda #214
        sta SCREEN + (10 * 40) + 22, x
        lda #215
        sta SCREEN + (10 * 40) + 23, x

        lda #216
        sta SCREEN + (11 * 40) + 16, x
        lda #217
        sta SCREEN + (11 * 40) + 17, x
        lda #218
        sta SCREEN + (11 * 40) + 18, x
        lda #219
        sta SCREEN + (11 * 40) + 19, x
        lda #220
        sta SCREEN + (11 * 40) + 20, x
        lda #221
        sta SCREEN + (11 * 40) + 21, x
        lda #222
        sta SCREEN + (11 * 40) + 22, x
        lda #223
        sta SCREEN + (11 * 40) + 23, x

        lda #224
        sta SCREEN + (12 * 40) + 16, x
        lda #225
        sta SCREEN + (12 * 40) + 17, x
        lda #226
        sta SCREEN + (12 * 40) + 18, x
        lda #227
        sta SCREEN + (12 * 40) + 19, x
        lda #228
        sta SCREEN + (12 * 40) + 20, x
        lda #229
        sta SCREEN + (12 * 40) + 21, x
        lda #230
        sta SCREEN + (12 * 40) + 22, x
        lda #231
        sta SCREEN + (12 * 40) + 23, x

        lda #232
        sta SCREEN + (13 * 40) + 16, x
        lda #233
        sta SCREEN + (13 * 40) + 17, x
        lda #234
        sta SCREEN + (13 * 40) + 18, x
        lda #235
        sta SCREEN + (13 * 40) + 19, x
        lda #236
        sta SCREEN + (13 * 40) + 20, x
        lda #237
        sta SCREEN + (13 * 40) + 21, x
        lda #238
        sta SCREEN + (13 * 40) + 22, x
        lda #239
        sta SCREEN + (13 * 40) + 23, x

        lda #240
        sta SCREEN + (14 * 40) + 16, x
        lda #241
        sta SCREEN + (14 * 40) + 17, x
        lda #242
        sta SCREEN + (14 * 40) + 18, x
        lda #243
        sta SCREEN + (14 * 40) + 19, x
        lda #244
        sta SCREEN + (14 * 40) + 20, x
        lda #245
        sta SCREEN + (14 * 40) + 21, x
        lda #246
        sta SCREEN + (14 * 40) + 22, x
        lda #247
        sta SCREEN + (14 * 40) + 23, x

        lda #248
        sta SCREEN + (15 * 40) + 16, x
        lda #249
        sta SCREEN + (15 * 40) + 17, x
        lda #250
        sta SCREEN + (15 * 40) + 18, x
        lda #251
        sta SCREEN + (15 * 40) + 19, x
        lda #252
        sta SCREEN + (15 * 40) + 20, x
        lda #253
        sta SCREEN + (15 * 40) + 21, x
        lda #254
        sta SCREEN + (15 * 40) + 22, x
        lda #255
        sta SCREEN + (15 * 40) + 23, x

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

        inc $d020

        lda #$00
        sta x0
        lda #$00
        sta y0
        lda #$3f
        sta x1
        lda #$3f
        sta y1
        jsr draw_line_fast


;        jsr rotate_and_project
;        jsr draw_cube_edges

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
        sta x0
        lda projected_y,x
        sta y0

        lda cube_edges_end,y
        tax
        lda projected_x,x
        sta x1
        lda projected_y,x
        sta y1

        jsr draw_line_fast

        ldy edge_index
        iny
        cpy #12
        bne edge_loop
        rts

edge_index: db 0

; --- BRESENHAMIN VIIREMPIIRTO INLINE-PLOTTAUKSELLA ---
x0:      db 0
y0:      db 0
x1:      db 0
y1:      db 0
dx:      db 0
dy:      db 0
err:     db 0
step_x:  db 0
step_y:  db 0

draw_line_fast:
        lda x1
        sec
        sbc x0
        bpl .dx_pos
        eor #$ff
        clc
        adc #1
        ldx #$ff
        bne .dx_store
.dx_pos:
        ldx #$01
.dx_store:
        sta dx
        stx step_x

        lda y1
        sec
        sbc y0
        bpl .dy_pos
        eor #$ff
        clc
        adc #1
        ldx #$ff
        bne .dy_store
.dy_pos:
        ldx #$01
.dy_store:
        sta dy
        stx step_y

        lda dx
        sec
        sbc dy
        sta err

.loop:
        ; Rajatarkistus 64x64 alueelle
        lda x0
        bmi .skip_plot
        cmp #64
        bcs .skip_plot
        lda y0
        bmi .skip_plot
        cmp #64
        bcs .skip_plot

        ldx y0
        lda tab_addr_lo,x
        ldy x0
        clc
        adc tab_x_offset,y
        sta zp_ptr
        lda tab_addr_hi,x
        sta zp_ptr+1

        lda tab_bit_mask,y
        ldy #0
        ora (zp_ptr),y
        sta (zp_ptr),y

.skip_plot:
        lda x0
        cmp x1
        bne .continue
        lda y0
        cmp y1
        beq .done
.continue:

        lda err
        asl
        sta temp

        clc
        adc dy
        bmi .check_y
        lda err
        sec
        sbc dy
        sta err
        lda x0
        clc
        adc step_x
        sta x0

.check_y:
        lda dx
        sec
        sbc temp
        bmi .loop_jump
        beq .loop_jump
        lda err
        clc
        adc dx
        sta err
        lda y0
        clc
        adc step_y
        sta y0

.loop_jump:
        jmp .loop
.done:
        rts

; --- SKAALATUT TAULUKOT (PAKOTETTU SIVUN ALKUUN) ---
        align 8

; X-pikselikohtaiset bittimaskit (0-63)
tab_bit_mask:
        db $80,$40,$20,$10,$08,$04,$02,$01
        db $80,$40,$20,$10,$08,$04,$02,$01
        db $80,$40,$20,$10,$08,$04,$02,$01
        db $80,$40,$20,$10,$08,$04,$02,$01
        db $80,$40,$20,$10,$08,$04,$02,$01
        db $80,$40,$20,$10,$08,$04,$02,$01
        db $80,$40,$20,$10,$08,$04,$02,$01
        db $80,$40,$20,$10,$08,$04,$02,$01

; Y-koordinaatin matalan tavun muistiosoitteet (Y = 0-63)
tab_addr_lo:
        db 0,1,2,3,4,5,6,7, 8,9,10,11,12,13,14,15
        db 16,17,18,19,20,21,22,23, 24,25,26,27,28,29,30,31
        db 32,33,34,35,36,37,38,39, 40,41,42,43,44,45,46,47
        db 48,49,50,51,52,53,54,55, 56,57,58,59,60,61,62,63
; Y-koordinaatin korkean tavun muistiosoitteet CHARSET + (192 * 8) = $3600 pohjalta
tab_addr_hi:
        db $36,$36,$36,$36,$36,$36,$36,$36, $36,$36,$36,$36,$36,$36,$36,$36
        db $36,$36,$36,$36,$36,$36,$36,$36, $36,$36,$36,$36,$36,$36,$36,$36
        db $36,$36,$36,$36,$36,$36,$36,$36, $36,$36,$36,$36,$36,$36,$36,$36
        db $36,$36,$36,$36,$36,$36,$36,$36, $36,$36,$36,$36,$36,$36,$36,$36

; X-koordinaatin (0-63) tuoma merkkioffset tavuina: (X / 8) * 8
tab_x_offset:
        db 0,0,0,0,0,0,0,0, 8,8,8,8,8,8,8,8
        db 16,16,16,16,16,16,16,16, 24,24,24,24,24,24,24,24
        db 32,32,32,32,32,32,32,32, 40,40,40,40,40,40,40,40
        db 48,48,48,48,48,48,48,48, 56,56,56,56,56,56,56,56

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