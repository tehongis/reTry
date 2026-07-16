import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

def generate_c64_sprite_data():
    longitudes = 12
    latitudes = 6
    
    # 1. Luodaan pallon 3D-pisteet (Amiga-kallistus -20 astetta mukana)
    u = np.linspace(0, 2 * np.pi, longitudes + 1)
    v = np.linspace(0, np.pi, latitudes + 1)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones(np.size(u)), np.cos(v))

    tilt_rad = np.radians(-20.0)
    x_tilted = x * np.cos(tilt_rad) - y * np.sin(tilt_rad)
    y_tilted = x * np.sin(tilt_rad) + y * np.cos(tilt_rad)
    z_tilted = z

    # Alkuperäinen värikartta (Amiga puna-valkoinen)
    color_matrix = np.zeros((longitudes, latitudes, 4))
    for i in range(longitudes):
        for j in range(latitudes):
            # 0.0=Musta tausta, 0.5=Peli/Varjo, 1.0=Valkoinen
            color_matrix[i, j] = [1.0, 1.0, 1.0, 1.0] if (i + j) % 2 == 0 else [1.0, 0.0, 0.0, 1.0]

    total_frames = 8
    max_rotation_angle = 60.0 
    target_w, target_h = 96, 84
    aspect_ratio = target_w / target_h

    # Luodaan assembler-tulostustiedosto
    asm_file = open("c64_sprites.asm", "w")
    asm_file.write("; COMMODORE 64 MULTI-COLOR SPRITE DATA\n")
    asm_file.write("; Layout: 4x4 Sprites (96x84 pixels total), Multicolor mode\n")
    asm_file.write("; Total 8 frames. Each frame = 16 sprites = 1024 bytes.\n\n")

    raw_binary_bytes = bytearray()

    print("Generoidaan Commodore 64 spritedataa...")

    for frame in range(total_frames):
        # Piirretään Matplotlibillä väliaikainen puhtaasti renderöity kuva
        fig = plt.figure(figsize=(target_w / 100.0, target_h / 100.0), dpi=100)
        ax = fig.add_axes([0, 0, 1, 1], projection='3d')
        
        angle = frame * (max_rotation_angle / total_frames)
        ax.plot_surface(x_tilted, y_tilted, z_tilted, facecolors=color_matrix, 
                        rstride=1, cstride=1, linewidth=0, shade=False)
        
        ax.view_init(roll=0, azim=angle)
        ax.set_axis_off()
        ax.set_box_aspect([1, 1, 1])
        
        zoom_y_z = 0.57
        zoom_x = zoom_y_z * aspect_ratio
        ax.set_xlim([-zoom_x, zoom_x])
        ax.set_ylim([-zoom_y_z, zoom_y_z])
        ax.set_zlim([-zoom_y_z, zoom_y_z])
        
        # Pakotetaan tausta mustaksi kvantisointia varten
        fig.patch.set_facecolor('black')
        ax.set_facecolor('black')
        
        temp_img_path = f"temp_c64_{frame}.png"
        plt.savefig(temp_img_path, dpi=100, pad_inches=0, facecolor=fig.get_facecolor())
        plt.close()

        # 2. KVANTISOINTI C64-VÄREIHIN (PIL-kirjastolla)
        # Avataan kuva ja skaalataan se tarkasti 96x84 pikseliin
        img = Image.open(temp_img_path).convert("RGB").resize((target_w, target_h))
        img_data = np.array(img)

        # Muunnetaan pikselit 2-bittisiksi C64-värikoodeiksi
        # 00 = Läpinäkyvä/Musta, 01 = Väri 1 (Punainen), 10 = Väri 2 (Valkoinen)
        c64_pixels = np.zeros((target_h, target_w), dtype=np.uint8)

        for y_idx in range(target_h):
            for x_idx in range(target_w):
                r, g, b = img_data[y_idx, x_idx]
                if r < 50 and g < 50 and b < 50:
                    c64_pixels[y_idx, x_idx] = 0 # 00 = Läpinäkyvä/Tausta
                elif r > 150 and g < 100:
                    c64_pixels[y_idx, x_idx] = 1 # 01 = Punainen
                else:
                    c64_pixels[y_idx, x_idx] = 2 # 10 = Valkoinen

        asm_file.write(f"; --- ANIMAATIORUUTU {frame + 1} ---\n")
        
        # 3. MUUNNOS C64 SPRITE-TAUTUMUOTOON
        # Jaetaan 96x84 kuva 4x4 palasiin (jokainen pala on 24x21 pikseliä)
        for sy in range(4): # 4 spriteä pystysuunnassa
            for sx in range(4): # 4 spriteä vaakasuunnassa
                asm_file.write(f"frame_{frame}_sprite_{sy}_{sx}\n")
                
                # Käydään läpi yhden spriten 21 riviä
                for row in range(21):
                    pixel_y = sy * 21 + row
                    line_bytes = [0, 0, 0] # Jokainen spriten rivi vie 3 tavua (24 pikseliä)

                    # Käydään läpi 24 pikseliä (12 moniväripikseliparia)
                    for col in range(24):
                        pixel_x = sx * 24 + col
                        
                        # Moniväritilassa luetaan pikselit pareittain (joka toinen pikseli ohitetaan)
                        # C64 vaatii, että bitit parissa osoittavat saman värin
                        color_code = c64_pixels[pixel_y, pixel_x]
                        
                        # Lasketaan mihin tavuun (0, 1 tai 2) ja mihin bittipariin pikseli kuuluu
                        byte_idx = col // 8
                        bit_shift = 6 - (col % 8)
                        
                        # C64 Multicolor-parit pakataan tavuun (siirretään 2 bittiä kerrallaan)
                        # Tehdään tuplaleveä moniväripikseli pakottamalla bitit pareittain
                        if col % 2 == 0:
                            # Parillinen pikseli: asetetaan bittiparin ylin bitti
                            line_bytes[byte_idx] |= (color_code << bit_shift)
                        else:
                            # Pariton pikseli: kopioidaan edellisen bittiparin suunta
                            pass 

                    # Kirjoitetaan rivin 3 tavua assembleriin ja binaariin
                    asm_file.write(f"    .byte ${line_bytes[0]:02x}, ${line_bytes[1]:02x}, ${line_bytes[2]:02x}\n")
                    raw_binary_bytes.extend(line_bytes)
                
                # 64. tavu on C64-spritessä käyttämätön täytetavu (padding)
                asm_file.write("    .byte $00\n")
                raw_binary_bytes.append(0)

        # Siivotaan väliaikaiset kuvat
        import os
        os.remove(temp_img_path)
        print(f"Ruutu {frame + 1}/8 pakattu Commodore 64 spritemuotoon.")

    asm_file.close()
    
    # Tallennetaan puhdas raakabinaari (.bin) kiintolevylle
    with open("c64_sprites.bin", "wb") as bin_file:
        bin_file.write(raw_binary_bytes)
        
    print("\n[ONNISTUI]")
    print("- Tekstimuotoinen C64 data tallennettu: 'c64_sprites.asm'")
    print("- Valmis C64 konekielibinaari tallennettu: 'c64_sprites.bin' (Koko: 8192 tavua)")

if __name__ == "__main__":
    generate_c64_sprite_data()
